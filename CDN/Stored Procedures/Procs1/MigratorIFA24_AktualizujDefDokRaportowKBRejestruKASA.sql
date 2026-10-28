CREATE PROCEDURE cdn.MigratorIFA24_AktualizujDefDokRaportowKBRejestruKASA @Klasa INT, @Symbol NVARCHAR(5), @Nazwa NVARCHAR(20), @Numeracja NVARCHAR(50), @ImportSchematID INT
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @kasaBRaID INT
 DECLARE @kasaDDfID INT
 SELECT @kasaBRaID = BRa_BRaID, @kasaDDfID = BRa_DDfID FROM cdn.BnkRachunki LEFT OUTER JOIN cdn.DokDefinicje ON DDf_DDfID = BRa_DdfID WHERE DDf_Klasa = 211 AND BRa_Symbol = 'KASA'
 IF @kasaDDfID Is NOT Null
 BEGIN
  BEGIN TRY
   BEGIN TRAN
   DELETE cdn.BnkRaporty WHERE BRp_BRaID = @kasaBRaID
   --SELECT 1/0;
   ALTER TABLE CDN.DokDefinicje DISABLE TRIGGER ALL
   UPDATE CDN.DokDefinicje
    SET DDf_Klasa = @Klasa, DDf_Symbol = @Symbol, DDf_Nazwa = @Nazwa, DDf_Numeracja = @Numeracja, DDf_ImportSchematID = @ImportSchematID
    WHERE DDf_DDfID = @kasaDDfID
   ALTER TABLE CDN.DokDefinicje ENABLE TRIGGER ALL
   COMMIT
  END TRY
  BEGIN CATCH
   ROLLBACK
   DECLARE @ErrMsg NVARCHAR(1024)
   SET @ErrMsg = ERROR_MESSAGE()
   RAISERROR(@ErrMsg, 16, 1)
  END CATCH
 END
 ELSE
 BEGIN
  --RAISERROR('W bazie danych brak definicji dokumentu o klasie Raport K/B wybranej dla rejestru KASA', 16, 1)
  EXEC CDN.RaiseOptimaException 34165
 END
 SET NOCOUNT OFF
END
