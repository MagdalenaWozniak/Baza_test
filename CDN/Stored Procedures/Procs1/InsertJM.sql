CREATE PROCEDURE cdn.InsertJM
 @jm   NVARCHAR(20),
 @opis  NVARCHAR(100) = NULL
AS
BEGIN
 SET NOCOUNT ON;
 IF not EXISTS(SELECT * FROM cdn.Grupy WHERE Gru_Typ = 32 AND Gru_Nazwa = @jm)
 BEGIN
  IF @opis IS NULL SET @opis = @jm
  IF @opis = N'' SET @opis = @jm
  INSERT INTO cdn.Grupy(Gru_Typ,Gru_Nazwa,Gru_Opis,Gru_Flaga) values(32, @jm, @opis, NULL)
 END
KONIEC:
 SET NOCOUNT OFF;
END
