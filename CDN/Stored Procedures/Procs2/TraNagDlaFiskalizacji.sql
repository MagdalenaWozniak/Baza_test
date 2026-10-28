CREATE PROCEDURE CDN.TraNagDlaFiskalizacji
@TrnID    AS INT
,@OpeID    AS INT
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @MagSymbol  NVARCHAR(20)
   ,@MagZakaz  NVARCHAR(255)
            ,@FaID      INT
 SET @MagSymbol = ''
 SET @MagZakaz  = ''
 SELECT TOP 1 @MagSymbol = Mag_Symbol FROM cdn.MagazynZakazy
           JOIN cdn.TraNag ON MaZ_MagId=TrN_MagZrdId
           JOIN cdn.Magazyny ON MaZ_MagId=Mag_MagId
           WHERE  TrN_TrNId = @TrnID AND MaZ_OpeId = @OpeID
 IF @MagSymbol Is NULL OR @MagSymbol = ''
   SELECT TOP 1 @MagSymbol = Mag_Symbol FROM cdn.MagazynZakazy
          JOIN cdn.TraElem on MaZ_MagId=TrE_MagId
          JOIN cdn.Magazyny on MaZ_MagId=Mag_MagId
          WHERE  TrE_TrNId = @TrnID and MaZ_OpeId = @OpeID
 IF @MagSymbol Is NOT NULL AND @MagSymbol <> ''
 BEGIN
  SET @MagZakaz = 'Operator ma ustawiony zakaz na magazyn ' + @MagSymbol + '!'
 END
    SELECT @FaID=ISNULL(TrR_FaID,0) FROM CDN.TraNagRelacje where TrR_TrNId = @TrNID AND TrR_FaTyp in(302,305) AND TrR_TrNTyp in (302,305)
 SELECT TrN_TypDokumentu, TrN_Rodzaj, TrN_Bufor, @FaID As TrN_FaId, TrN_VaNId, TrN_Korekta, TrN_TypNB, TrN_Waluta, TrN_NumerPelny, TrN_RazemBrutto, TrN_RazemBruttoWal, TrN_FplId, TrN_Fiskalna, MagZakaz=@MagZakaz FROM cdn.TraNag WHERE TrN_TrNId = @TrNID
 KONIEC:
  SET NOCOUNT OFF;
  RETURN
END
