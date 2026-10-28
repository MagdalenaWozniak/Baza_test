CREATE PROCEDURE CDN.SrsRodzajUUsun
@SrRId AS INT
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS (SELECT * FROM CDN.SrsUrzadzenia WHERE SrU_SrRId = @SrRId)
 BEGIN
  --RAISERROR( 'Wybrany zapis nie może być usunięty. Nie można kasować definicji rodzaju do którego przyporządkowano urządzenie serwisowe!' , 16, 1)
  EXEC CDN.RaiseOptimaException  34121
  SET NOCOUNT OFF
  SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
  RETURN
 END
 BEGIN TRAN;
  DELETE FROM CDN.SrsRodzajeU WHERE SrR_SrRId = @SrRId
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
 SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
END
