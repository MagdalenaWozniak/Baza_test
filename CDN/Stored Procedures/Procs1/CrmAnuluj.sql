CREATE PROCEDURE cdn.CrmAnuluj
@crkId AS INT
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @pow INT
 SET @pow = cdn.CrmZadanieGlowne(@crkId)
 IF @pow > 1 AND @pow <> 9   --sa powiazane i nie wszystkie sa anulowane(9)
 BEGIN
  --RAISERROR( 'Wybrany zapis nie może być anulowany ponieważ istnieją zadania/kontakty powiązane z anulowanym zadaniem.' , 16, 1)
  EXEC CDN.RaiseOptimaException 34155
  SET NOCOUNT OFF
  RETURN
 END
 DECLARE @bufor INT, @numerPelny NVARCHAR(30), @opis NVARCHAR(200)
 SELECT @bufor = IsNull(CRK_Bufor, 0), @numerPelny = CRK_NumerPelny, @opis = CAST(CrK_Temat AS NVARCHAR(200))  FROM cdn.CrmKontakty WHERE CRK_CrkId = @crkId
 IF @bufor = -1
 BEGIN
  --RAISERROR( 'Do anulowania wybrano zadanie/kontakt już wcześniej anulowane.' , 16, 1)
  EXEC CDN.RaiseOptimaException 34156
  SET NOCOUNT OFF
  RETURN
 END
 IF @bufor = 1
 BEGIN
  --RAISERROR( 'Do anulowania wybrano zadanie/kontakt znajdujące się w buforze.' , 16, 1)
  EXEC CDN.RaiseOptimaException 34157
  SET NOCOUNT OFF
  RETURN
 END
 BEGIN TRAN;
 UPDATE cdn.CrmKontakty SET CRK_Bufor = -1 WHERE CRK_CrkId = @crkId
 IF @@Error<>0
 BEGIN
  IF @@TranCount<>0 ROLLBACK TRAN
 END
 ELSE
 BEGIN
  IF @@TranCount<>0 COMMIT TRAN
  IF @numerPelny IS NULL SET @numerPelny = ''
  EXEC [CDN].[RejestrOperacjiDodaj]
          @ObiektTyp  = 700,
          @ObiektSubTyp = 0,
          @ObiektID  = @crkId,
          @ObiektNazwa = @numerPelny,
          @OperacjaTyp = 107,
          @Opis   = @opis
 END
 SET NOCOUNT OFF;
 SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
END
