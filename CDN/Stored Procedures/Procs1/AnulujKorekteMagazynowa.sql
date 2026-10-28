CREATE PROCEDURE CDN.AnulujKorekteMagazynowa
@FaID             AS INT
AS
BEGIN
 BEGIN TRAN;
 SET NOCOUNT ON;
 DECLARE @Err  INT
 DECLARE @WynikString    NVARCHAR(512)
 SET @Err = 0
 Exec CDN.AnulowanieKorektMagazynowych @FaID, 0, @WynikString OUTPUT
 SET NOCOUNT OFF;
 IF @@TRANCOUNT <> 0
 BEGIN
  IF @WynikString <> ''
   ROLLBACK TRAN
  ELSE
   COMMIT TRAN
 END
 SELECT 0   -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
END
