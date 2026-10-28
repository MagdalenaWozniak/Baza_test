CREATE PROCEDURE cdn.CrmOdblokuj
@crkId AS INT
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @bufor  INT
 DECLARE @parentId  INT
 DECLARE @numerPelny NVARCHAR(30)
 DECLARE @opis  NVARCHAR(200)
 SET @parentId = 0
 SET @bufor  = 0
 SELECT @parentId = IsNull(CRK_ParId, 0), @bufor = IsNull(CRK_Bufor,0), @numerPelny = CRK_NumerPelny, @opis = CAST(CrK_Temat AS NVARCHAR(200))  FROM cdn.CrmKontakty WHERE CRK_CrkId = @crkId
 IF @bufor = 1
 BEGIN
  --RAISERROR( 'Do otwarcia wybrano zadanie/kontakt znajdujące się w buforze.' , 16, 1)
  EXEC CDN.RaiseOptimaException 34161
  SET NOCOUNT OFF
  RETURN
 END
 IF @parentId <> 0 -- nie jest to zadanie główne
 BEGIN
  SELECT @bufor = CRK_Bufor  FROM cdn.CrmKontakty WHERE CRK_CrkId = @parentId
  IF @bufor = 0 -- zadanie główne nie jest w buforze
  BEGIN
   --RAISERROR( 'Zadanie/kontakt nadrzędny jest zamknięty. Otwórz najpierw zadanie/kontakt nadrzędny.' , 16, 1)
   EXEC CDN.RaiseOptimaException 34162
   SET NOCOUNT OFF
   RETURN
  END
 END
 BEGIN TRAN;
 UPDATE cdn.CrmKontakty SET CRK_Bufor = 1 WHERE CRK_CrkId = @crkId
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
          @OperacjaTyp = 102,
          @Opis   = @opis
 END
 SET NOCOUNT OFF;
 SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
END
