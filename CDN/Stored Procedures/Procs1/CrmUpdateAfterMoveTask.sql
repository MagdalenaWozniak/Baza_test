CREATE PROCEDURE CDN.CrmUpdateAfterMoveTask
@crkId int,
@oldOpiekunTyp int,
@oldOpiekunId  int,
@opiekunTyp int,
@opiekunId  int,
@newStartDate DATETIME,
@newEndDate DATETIME
AS
BEGIN
 SET NOCOUNT ON;
 -- ustaw nowy termin
 UPDATE cdn.CrmKontakty
 SET CrK_TerminOd = @newStartDate
  ,CrK_TerminDo = @newEndDate
  ,CrK_CzasPrzypomnienia = DATEADD(mi, DATEDIFF(mi, CrK_TerminOd, CrK_CzasPrzypomnienia), @newStartDate)
  ,CrK_AutomatycznePrzypomnieniaMailCzasPrzypomnienia = DATEADD(mi, DATEDIFF(mi, CrK_TerminOd, CrK_AutomatycznePrzypomnieniaMailCzasPrzypomnienia), @newStartDate)
  ,CrK_AutomatycznePrzypomnieniaSmsCzasPrzypomnienia= DATEADD(mi, DATEDIFF(mi, CrK_TerminOd, CrK_AutomatycznePrzypomnieniaSmsCzasPrzypomnienia), @newStartDate)
  ,CrK_AutomatycznePrzypomnieniaOpeMailCzasPrzypomnienia = DATEADD(mi, DATEDIFF(mi, CrK_TerminOd, CrK_AutomatycznePrzypomnieniaOpeMailCzasPrzypomnienia), @newStartDate)
  ,CrK_AutomatycznePrzypomnieniaOpeSmsCzasPrzypomnienia = DATEADD(mi, DATEDIFF(mi, CrK_TerminOd, CrK_AutomatycznePrzypomnieniaOpeSmsCzasPrzypomnienia), @newStartDate)
 WHERE CrK_CrKId = @crkId
 IF @oldOpiekunTyp IS NULL RETURN
 IF @oldOpiekunId IS NULL RETURN
 IF @opiekunTyp IS NULL RETURN
 IF @opiekunId IS NULL RETURN
 IF @oldOpiekunTyp = 0 RETURN
 IF @oldOpiekunId = 0 RETURN
 IF @opiekunTyp = 0 RETURN
 IF @opiekunId = 0 RETURN
 DECLARE @crkOpiekunTyp INT, @crkOpiekunId INT, @zmianaProwadzacego INT, @zmianaUczestnika INT, @automatOpePrzyp TINYINT
 SELECT @crkOpiekunTyp = CrK_OpiekunTyp, @crkOpiekunId = CrK_OpiekunId, @automatOpePrzyp = CrK_AutomatycznePrzypomnieniaOpe FROM cdn.CrmKontakty WHERE CrK_CrKId = @crkId
 IF @crkOpiekunTyp IS NULL RETURN
 IF @crkOpiekunId IS NULL RETURN
 SET @zmianaUczestnika = 1
 IF @opiekunTyp = @oldOpiekunTyp AND @opiekunId = @oldOpiekunId
 BEGIN
  SET @zmianaUczestnika = 0
  GOTO KONIEC
 END
 -- zmieniono uczestnika
 -- ustaw nowego operatora (uczestnika)
 SET @zmianaProwadzacego = 0
 IF @crkOpiekunTyp = @oldOpiekunTyp AND @crkOpiekunId = @oldOpiekunId SET @zmianaProwadzacego = 1
 IF @zmianaProwadzacego = 1
 BEGIN
  UPDATE cdn.CrmKontakty   SET CrK_OpiekunTyp = @opiekunTyp, CrK_OpiekunId = @opiekunId  WHERE CrK_CrKId = @crkId
  UPDATE cdn.CrmUczestnicy SET CrU_Organizator = 0 WHERE CrU_CrKId = @crkId AND CrU_Organizator = 1
 END
 IF EXISTS(SELECT * FROM cdn.CrmUczestnicy WHERE CrU_CrKId = @crkId AND CrU_PodmiotTyp = @opiekunTyp AND CrU_PodmiotId = @opiekunId)
 BEGIN   -- nowy operator jest na liście uczestników
  IF @zmianaProwadzacego = 1
  BEGIN
   UPDATE cdn.CrmUczestnicy SET CrU_Organizator = 1 WHERE CrU_CrKId = @crkId AND CrU_PodmiotTyp = @opiekunTyp AND CrU_PodmiotId = @opiekunId
  END
 END
 ELSE
 BEGIN   -- nowego operatora nie ma na liście uczestników
  DECLARE @akronim nvarchar(20), @nazwisko nvarchar(255), @email nvarchar(127), @telefon varchar(20), @saUczestnicy INT
  DECLARE @result table (opis nvarchar(50), akronim nvarchar(20), nazwisko nvarchar(255), telefon varchar(20), email nvarchar(127))
  INSERT INTO @result exec  CDN.GetDaneOpiekuna @opiekunTyp, @opiekunId
  SELECT TOP 1 @akronim = akronim, @nazwisko = nazwisko, @email = email, @telefon = telefon from @result
  IF  @akronim IS NULL SET @akronim = ''
  IF  @nazwisko IS NULL SET @nazwisko = ''
  IF  @telefon IS NULL SET @telefon = ''
  IF  @email IS NULL SET @email = ''
  DECLARE @organizator TINYINT, @automatPrzyp TINYINT
  IF @zmianaProwadzacego = 1 SET @organizator = 1 ELSE SET @organizator = 0
  SELECT  @saUczestnicy = COUNT(*) FROM cdn.CrmUczestnicy WHERE CrU_CrKId = @crkId
  -- jeżeli jest to zmiana prowadzącego, to dodajemy nowego uczestnika
  IF @zmianaProwadzacego = 1 AND @saUczestnicy > 1
  BEGIN
   INSERT INTO [CDN].[CrmUczestnicy]
   ([CrU_CrKId]
   ,[CrU_PodmiotTyp]
   ,[CrU_PodmiotId]
   ,[CrU_Organizator]
   ,[CrU_Akronim]
   ,[CrU_Nazwisko]
      ,[CrU_AutomatycznePrzypomnienia]
      ,[CrU_Email]
      ,[CrU_TelefonSms]
   )
   VALUES
   (@crkId
   ,@opiekunTyp
   ,@opiekunId
   ,@organizator
   ,@akronim
   ,@nazwisko
   ,@automatOpePrzyp
   ,@email
   ,@telefon
   )
   GOTO KONIEC
  END
  -- jeżeli jest to zmiana uczestnika, który nie jest prowadzącym,
  -- albo prowadzacy jest jednym uczestnikiem
  -- to zmieniamy dane starego uczestnika na nowego
  UPDATE cdn.CrmUczestnicy
  SET CrU_PodmiotTyp = @opiekunTyp, CrU_PodmiotId = @opiekunId, CrU_Akronim = @akronim, CrU_Nazwisko = @nazwisko, CrU_Organizator = 0,
   CrU_Email = @email, CrU_TelefonSms = @telefon
  WHERE CrU_CrKId = @crkId AND CrU_PodmiotTyp = @oldOpiekunTyp AND CrU_PodmiotId = @oldOpiekunId
 END
KONIEC:
 SET NOCOUNT OFF;
END
