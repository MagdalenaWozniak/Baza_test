CREATE PROCEDURE CDN.KntScal_SprawdzPodmioty
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT, -- ID kontrahenta podrzędnego (duplikata)
 @Karty AS TINYINT -- czy funkcja jest wołana z łączenia kart (1) czy też kopiowania obiektów podrzędnych, takich jak atrybuty (0)
AS
 SET NOCOUNT ON
 IF NOT EXISTS (SELECT * FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID)
 BEGIN
  DECLARE @nadID VARCHAR(10)
  SELECT @nadID = CONVERT(VARCHAR(10), @KntNadID)
  RAISERROR('##OPT33035##%%nadID%%=%s##', 16, 1, @nadID) --RAISERROR('Brak kontrahenta (głównego) o podanym id (%s)', 16, 1, @nadID)
  RETURN
 END
 IF NOT EXISTS (SELECT * FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID)
 BEGIN
  DECLARE @podID VARCHAR(10)
  SELECT @podID = CONVERT(VARCHAR(10), @KntPodID)
  RAISERROR('##OPT33036##%%podID%%=%s##', 16, 1, @podID) --RAISERROR('Brak kontrahenta (duplikata) o podanym id (%s)', 16, 1, @podID)
  RETURN
 END
 IF EXISTS (SELECT * FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID AND Knt_NadID Is Not NULL)
 BEGIN
  DECLARE @nadKod NVARCHAR(20)
  SELECT @nadKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntId = @KntNadID
  DECLARE @nadKod2 NVARCHAR(20)
  SELECT @nadKod2 = B.Knt_Kod FROM cdn.Kontrahenci A JOIN cdn.Kontrahenci B ON B.Knt_KntID = A.Knt_NadID WHERE A.Knt_KntID = @KntNadID
  RAISERROR('##OPT33037##%%nadKod%%=%s%%nadKod2%%=%s##', 16, 1, @nadKod, @nadKod2) --RAISERROR('Kontrahent %s, wybrany do połączenia jako nadrzędny, jest duplikatem innego kontrahenta (%s).', 16, 1, @nadKod, @nadKod2)
  RETURN
 END
 IF @Karty = 1 AND EXISTS (SELECT * FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID AND Knt_NadID = @KntNadID)
 BEGIN
  DECLARE @nadKod3 NVARCHAR(20)
  SELECT @nadKod3 = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntId = @KntNadID
  DECLARE @podKod3 NVARCHAR(20)
  SELECT @podKod3 = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntId = @KntPodID
  RAISERROR('##OPT33038##%%podKod%%=%s%%nadKod%%=%s##', 16, 1, @podKod3, @nadKod3) --RAISERROR('Kontrahent %s, wybrany do połączenia jako podrzędny, jest już duplikatem wskazanego kontrahenta głównego %s.', 16, 1, @podKod3, @nadKod3)
  RETURN
 END
 -- Kontrahent wybrany jako podrzędny może być duplikatem, byle był duplikatem innego niż kontrahent wskazany jako główny, a to dlatego, że chcemy umożliwić przepinanie
 -- duplikatów pomiędzy kontrahentami nadrzędnymi.
 IF EXISTS (SELECT * FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID AND Knt_LpAnonimizacji > 0)
 BEGIN
  DECLARE @nadKod4 NVARCHAR(20)
  SELECT @nadKod4 = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntId = @KntNadID
  RAISERROR('##OPT33039##%%nadKod%%=%s##', 16, 1, @nadKod4) --RAISERROR('Kontrahent %s, wybrany do połączenia jako nadrzędny, jest zanonimizowany.', 16, 1, @nadKod4)
  RETURN
 END
 SET NOCOUNT OFF
