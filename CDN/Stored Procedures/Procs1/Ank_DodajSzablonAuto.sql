CREATE PROCEDURE [CDN].Ank_DodajSzablonAuto(@spID INT, @opeId INT, @staId INT)
AS
BEGIN
 DECLARE @sonID INT, @typPytania INT
 SELECT TOP 1 @sonID = AnkSp_AnkSonId, @typPytania = AnkSp_TypPytania FROM cdn.AnkSlownikPytan WHERE AnkSp_AnkSpId = @spID AND AnkSp_TypPytania = 1
 IF @sonID IS NOT NULL OR @sonID > 0 RETURN
 IF @typPytania IS NULL OR @typPytania = 0 RETURN
 DECLARE @opeModKod varchar(20), @opeModNazwisko nvarchar(50)
 SET @opeModKod = N''
 SET @opeModNazwisko = N''
 IF @opeId IS NOT NULL
  EXEC CDN.OpeKodNazwisko @opeId, @opeModKod OUT, @opeModNazwisko OUT
 DECLARE @name NVARCHAR(250), @newId INT
 SET @name = NewId()
 INSERT INTO [CDN].[AnkSzablonOdpNag](
   [AnkSoN_Nazwa]
     ,[AnkSoN_Auto]
           ,[AnkSoN_OpeZalID]
           ,[AnkSoN_StaZalId]
           ,[AnkSoN_TS_Zal]
           ,[AnkSoN_OpeModID]
           ,[AnkSoN_StaModId]
           ,[AnkSoN_TS_Mod]
           ,[AnkSoN_OpeModKod]
           ,[AnkSoN_OpeModNazwisko]
           ,[AnkSoN_OpeZalKod]
           ,[AnkSoN_OpeZalNazwisko])
 VALUES(@name
  ,1
  ,@opeId
  ,@staId
  ,GetDate()
  ,@opeId
  ,@staId
  ,GetDate()
  ,@opeModKod
  ,@opeModNazwisko
  ,@opeModKod
  ,@opeModNazwisko)
 SET @sonID = SCOPE_IDENTITY()
 UPDATE cdn.AnkSlownikPytan    SET AnkSp_AnkSonId = @sonID, AnkSp_AnkSonAuto = 1  WHERE AnkSp_AnkSpId = @spID
 UPDATE cdn.AnkSlownikPytanOdp SET AnkSpO_AnkSonId= @sonID WHERE AnkSpO_AnkSpId = @spID
 INSERT INTO [CDN].[AnkSzablonOdpElem]
      ([AnkSoE_AnkSonId]
      ,[AnkSoE_Lp]
      ,[AnkSoE_Mode]
      ,[AnkSoE_Punkty]
      ,[AnkSoE_Wartosc])
 SELECT
    @sonID
      ,AnkSpO_Lp
      ,AnkSpO_Mode
      ,AnkSpO_Punkty
      ,AnkSpO_Wartosc
 FROM cdn.AnkSlownikPytanOdp WHERE AnkSpO_AnkSpId = @spID
 UPDATE  spo
 SET spo.AnkSpO_AnkSoEId = AnkSoE_AnkSoeId
 FROM cdn.AnkSlownikPytanOdp spo
 JOIN [CDN].[AnkSzablonOdpElem] ON [AnkSoE_AnkSonId] = @sonID AND spo.AnkSpO_Lp = [AnkSoE_Lp]
 WHERE spo.AnkSpO_AnkSoNId = @sonID
 UPDATE ankwap
 SET ankwap.AnkWaP_AnkSonId = AnkSp_AnkSoNId
 FROM  cdn.AnkWzorzecAnkietyPyt ankwap
 JOIN  cdn.AnkSlownikPytan ON ankwap.AnkWaP_AnkSpId = AnkSp_AnkSpId
 WHERE AnkSp_AnkSpId = @spID
END
