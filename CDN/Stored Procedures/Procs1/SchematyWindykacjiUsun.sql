CREATE PROCEDURE CDN.SchematyWindykacjiUsun
@SwNId AS INT
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS (SELECT * FROM CDN.Kontrahenci WHERE Knt_WindykacjaSchematId = @SwNId)
 BEGIN
 DECLARE @kontrahenci nvarchar(1024), @komunikat nvarchar(1124)
 SET @kontrahenci = cdn.KontrahenciZeSchematemWindykacji(@SwNId)
 --SET @komunikat = N'Nie można usunąć schematu windykacji, ponieważ istnieje powiązanie z kontrahentem! (' + RTRIM(@kontrahenci) + N')'
 --RAISERROR( @komunikat , 16, 1)
 SET @kontrahenci = RTRIM(@kontrahenci)
 EXEC CDN.RaiseOptimaException 34163, "kontrahenci", @kontrahenci
 SET NOCOUNT OFF
 RETURN
 END
 BEGIN TRAN;
  DELETE FROM CDN.SchematyWindykacji WHERE SwN_SwNId = @SwNId
KONIEC:
 IF @@Error<>0
 BEGIN
  IF @@TranCount<>0 ROLLBACK TRAN
 END
 ELSE
 BEGIN
  IF @@TranCount<>0 COMMIT TRAN
 END
 SET NOCOUNT OFF;
END
