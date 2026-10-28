CREATE PROCEDURE cdn.CrmUsun
@crkId AS INT, @opeNazwisko NVARCHAR(50), @rejestrOperacji INT
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS (SELECT * FROM cdn.CrmKontakty WHERE CRK_Bufor <> 1 AND CRK_CrkId = @crkId)
 BEGIN
  --RAISERROR( 'Wybrany zapis nie może być usunięty. Nie można kasować kontaktów nie będących w buforze!' , 16, 1)
  EXEC CDN.RaiseOptimaException 34150
  SET NOCOUNT OFF
  SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
  RETURN
 END
 DECLARE @pow INT
 SET @pow = cdn.CrmZadanieGlowne(@crkId)
 IF @pow >= 8
 BEGIN
  --RAISERROR( 'Wybrany zapis nie może być usunięty ponieważ istnieją anulowane zadania/kontakty powiązane z kasowanym zadaniem.' , 16, 1)
  EXEC CDN.RaiseOptimaException 34151
  SET NOCOUNT OFF
  SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
  RETURN
 END
 IF @pow >= 4
 BEGIN
  --RAISERROR( 'Wybrany zapis nie może być usunięty ponieważ istnieją zamknięte zadania/kontakty powiązane z kasowanym zadaniem.' , 16, 1)
  EXEC CDN.RaiseOptimaException 34152
  SET NOCOUNT OFF
  SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
  RETURN
 END
 IF @pow = 1
 BEGIN
  --RAISERROR( 'Wybrany zapis nie może być usunięty ponieważ istnieją zadania/kontakty powiązane z kasowanym zadaniem.' , 16, 1)
  EXEC CDN.RaiseOptimaException 34153
  SET NOCOUNT OFF
  SELECT 0 -- wywołanie przez getSingleResult wymaga resultatu, by nie zwrócić błędu
  RETURN
 END
 BEGIN TRAN;
  -- usuń powiązane
  IF @rejestrOperacji = 1
  BEGIN
   INSERT INTO CDN.RejestrOperacji(ROP_ObiektTyp, ROP_ObiektSubTyp, ROP_ObiektID, ROP_ObiektNazwa, ROP_Data, ROP_Operator, ROP_OperacjaTyp, ROP_Opis)
   SELECT DISTINCT 700, NULL, CrK_CrKId, CrK_NumerPelny, GetDate(), @opeNazwisko, 3, N'' FROM cdn.CrmKontakty WHERE (CRK_Bufor = 1 AND CRK_ParId Is Not NULL AND CRK_ParId = @crkId)
   IF @@Error<>0 GOTO KONIEC
  END
  DELETE FROM cdn.CrmKontakty  WHERE (CRK_Bufor = 1 AND CRK_ParId Is Not NULL AND CRK_ParId = @crkId)
  IF @@Error<>0 GOTO KONIEC
  DELETE FROM cdn.CrmKontakty WHERE (CRK_Bufor = 1 AND CRK_CrkId = @crkId)
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
