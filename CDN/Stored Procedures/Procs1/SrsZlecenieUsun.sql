CREATE PROCEDURE CDN.SrsZlecenieUsun
 @SrZId AS INT
,@OpeId AS INT
,@rejestrOperacji INT = 0
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS (SELECT * FROM CDN.SrsZlecenia WHERE SrZ_Bufor <> 1 AND SrZ_SrZId = @SrZId)
 BEGIN
  --RAISERROR( 'Wybrany zapis nie może być usunięty. Nie można kasować zrealizowanych zleceń!' , 16, 1)
  EXEC CDN.RaiseOptimaException 34115
  SET NOCOUNT OFF
  SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
  RETURN
 END
 IF EXISTS( SELECT * FROM CDN.SrsCzesci
    WHERE SrC_SrZId = @SrZId AND (SrC_Status & 1) > 0 )
 BEGIN
  --RAISERROR( 'Wybrany zapis nie może być usunięty. Nie można kasować zleceń, dla których pobrano części z magazynu!' , 16, 1)
  EXEC CDN.RaiseOptimaException  34117
  SET NOCOUNT OFF
  SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
  RETURN
 END
 DECLARE @status NVARCHAR(255)
 SET @status = CDN.SrsZlecenieStatus(@SrZId)
 IF  LEN(@status) > 0
 BEGIN
  --SET @status =  'Wybrany zapis nie może być usunięty. Do zlecenia  wygenerowano dokument(y): ' + RTRIM(@status) + ' !'
  --RAISERROR( @status  , 16, 1)
  SET @status = RTRIM(@status)
  EXEC CDN.RaiseOptimaException  34118, "numeryDok", @status
  SET NOCOUNT OFF
  SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
  RETURN
 END
    DECLARE @MagSymbol  NVARCHAR(20)
    SET @MagSymbol = ''
    SELECT TOP 1 @MagSymbol = Mag_Symbol    FROM cdn.MagazynZakazy
                                            JOIN cdn.SrsZlecenia ON MaZ_MagId=SrZ_MagId
                                            JOIN cdn.Magazyny ON MaZ_MagId=Mag_MagId
                                            WHERE  SrZ_SrZId = @SrZId AND MaZ_OpeId = @OpeId
    IF @MagSymbol Is NULL OR @MagSymbol = ''
            SELECT TOP 1 @MagSymbol = Mag_Symbol FROM cdn.MagazynZakazy
                                        JOIN cdn.SrSCzesci on MaZ_MagId=SrC_MagId
                                        JOIN cdn.Magazyny on MaZ_MagId=Mag_MagId
                                        WHERE SrC_SrZId = @SrZId and MaZ_OpeId = @OpeId
    IF @MagSymbol Is NOT NULL AND @MagSymbol <> ''
    BEGIN
  declare @tekst NVARCHAR(255)
  --set @tekst = 'Wybrany zapis nie może być usunięty. Operator ma ustawiony zakaz na magazyn ' + @MagSymbol + ' !'
  --RAISERROR( @tekst, 16, 1)
  EXEC CDN.RaiseOptimaException  34119, "kodMagazynu", @MagSymbol
  SET NOCOUNT OFF
  SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
  RETURN
    END
 DECLARE @numerPelny NVARCHAR(100), @opis NVARCHAR(200)
    SELECT  TOP 1 @numerPelny = SrZ_NumerPelny, @opis = CAST(SrZ_Opis AS NVARCHAR(200)) FROM cdn.SrsZlecenia WHERE SrZ_Bufor = 1 AND SrZ_SrZId = @SrZId
 BEGIN TRAN;
  DELETE FROM CDN.SrsZlecenia WHERE (SrZ_Bufor = 1 AND SrZ_SrZId = @SrZId)
KONIEC:
 IF @@Error<>0
 BEGIN
  IF @@TranCount<>0 ROLLBACK TRAN
 END
 ELSE
 BEGIN
  IF @@TranCount<>0 COMMIT TRAN
  IF @rejestrOperacji = 1
  BEGIN
   EXEC [CDN].[RejestrOperacjiDodaj]
        @ObiektTyp  = 900,
        @ObiektSubTyp = 0,
        @ObiektID  = @SrZId,
        @ObiektNazwa = @numerPelny,
        @OperacjaTyp = 3,
        @Opis   = @opis
  END
 END
 SET NOCOUNT OFF;
 SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
END
