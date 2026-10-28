CREATE PROCEDURE CDN.ImportRemanentElem @ReNID INT, @CEN_Kod NVARCHAR(20), @CEN_Nazwa NVARCHAR(40), @CEN_JM NVARCHAR(4), @OpeID INT, @CEN_Stan DECIMAL(15,4), @CEN_Wazona DECIMAL(15,6), @DataAktualna DATETIME, @Lp INT
AS
 DECLARE @TwrID INT;
 DECLARE @Ilosc DECIMAL(15,4);
 DECLARE @Wartosc DECIMAL(15,2);
 DECLARE @Cena DECIMAL(15,2);
 SET @TwrID = NULL;
 SELECT @TwrID = Twr_TwrID FROM CDN.Towary WHERE Twr_Kod = @CEN_Kod;
 IF NOT EXISTS(SELECT Gru_GruID FROM CDN.Grupy WHERE Gru_Typ=32 AND RTRIM(LTRIM(Gru_Nazwa))=RTRIM(LTRIM(@CEN_JM)))
  INSERT INTO CDN.Grupy (Gru_Typ, Gru_Nazwa, Gru_Opis) VALUES (32, @CEN_JM, '');
 SET @Ilosc = ROUND(@CEN_Stan, 4);
 SET @Wartosc = ROUND(@CEN_Stan * @CEN_Wazona, 2);
 SET @Cena = CASE WHEN @Ilosc = 0 THEN 0 ELSE ROUND(@Wartosc / @Ilosc, 2) END;
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeID, @OpeModKod OUT, @OpeModNazwisko OUT
 INSERT INTO CDN.RemanentElem (
  ReE_ReNID,
  ReE_TwrID,
  ReE_Nazwa,
  ReE_JM,
  ReE_MetodaOblicz,
  ReE_Ilosc,
  ReE_Wartosc,
  ReE_Cena,
  ReE_CenaNabycia,
  ReE_OpeZalID,
  ReE_OpeZalKod,
  ReE_OpeZalNazwisko,
  ReE_TS_Zal,
  ReE_OpeModID,
  ReE_OpeModKod,
  ReE_OpeModNazwisko,
  ReE_TS_Mod,
  ReE_Lp,
  ReE_Opis )
 VALUES
  (@ReNID,
  @TwrID,
  @CEN_Nazwa,
  @CEN_JM,
  2, -- e_mk_nMetodaOblicz_Cena,
  @Ilosc,
  @Wartosc,
  @Cena,
  @Cena,
  @OpeID,
  @OpeModKod,
  @OpeModNazwisko,
  @DataAktualna,
  @OpeID,
  @OpeModKod,
  @OpeModNazwisko,
  @DataAktualna,
  @Lp,
  '');
