CREATE PROCEDURE CDN.KntScal_Konfig
 @KntNadID AS INT, -- ID kontrahenta nadrzędnego (głównego)
 @KntPodID AS INT  -- ID kontrahenta podrzędnego (duplikata)
AS
 SET NOCOUNT ON
 --EXEC cdn.KntScal_SprawdzPodmioty @KntNadID, @KntPodID, 0
 --IF @@ERROR <> 0 RETURN
 DECLARE @KntNadKod NVARCHAR(20)
 DECLARE @KntPodKod NVARCHAR(20)
 DECLARE @KntNadNazwa NVARCHAR(512)
 SELECT @KntNadKod = Knt_Kod, @KntNadNazwa = Knt_Nazwa1 FROM cdn.Kontrahenci WHERE Knt_KntID = @KntNadID
 SELECT @KntPodKod = Knt_Kod FROM cdn.Kontrahenci WHERE Knt_KntID = @KntPodID
 SELECT @KntNadKod = REPLACE(@KntNadKod, '''', ''''''), @KntNadNazwa = REPLACE(@KntNadNazwa, '''', ''''''), @KntPodKod = REPLACE(@KntPodKod, '''', '''''')
 DECLARE @cmd NVARCHAR(2048)
 DECLARE @cnfSvr NVARCHAR(256)
 SELECT @cnfSvr = SYS_Wartosc FROM cdn.SystemCDN WHERE SYS_ID = 1001
 DECLARE @cnfDb NVARCHAR(256)
 SELECT @cnfDb = SYS_Wartosc FROM cdn.SystemCDN WHERE SYS_ID = 1002
 DECLARE @cnf NVARCHAR(520)
 SELECT @cnf = '[' + @cnfSvr + '].[' + @cnfDb + ']'
 DECLARE @firmDbGuid NVARCHAR(255)
 SELECT @firmDbGuid = SYS_Wartosc FROM cdn.SystemCDN WHERE SYS_ID = 1004
 SELECT @cmd = 'INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod) SELECT ''cdn.MailWiadomosci'', MWD_MWDID, MWD_NumerPelny, {podID}, ''{podKod}'', {nadID}, ''{nadKod}''' +
 ' FROM {cnf}.cdn.MailWiadomosci WHERE MWD_PodmiotAdresatTyp = 1 AND MWD_PodmiotAdresatID = {podID} AND MWD_BazaGUID = ''{guid}''; '
 --SELECT @cmd = @cmd + 'ALTER TABLE {cnf}.cdn.MailWiadomosci DISABLE TRIGGER ALL; UPDATE {cnf}.cdn.MailWiadomosci SET MWD_PodmiotAdresatID = {nadID} WHERE MWD_PodmiotAdresatTyp = 1 AND MWD_PodmiotAdresatID = {podID} AND MWD_BazaGUID = ''{guid}''; ALTER TABLE {cnf}.cdn.MailWiadomosci ENABLE TRIGGER ALL'
 SELECT @cmd = @cmd + 'UPDATE {cnf}.cdn.MailWiadomosci SET MWD_PodmiotAdresatID = {nadID} WHERE MWD_PodmiotAdresatTyp = 1 AND MWD_PodmiotAdresatID = {podID} AND MWD_BazaGUID = ''{guid}'''
 SELECT @cmd = REPLACE(@cmd, '{cnf}', @cnf)
 SELECT @cmd = REPLACE(@cmd, '{nadID}', @KntNadID)
 SELECT @cmd = REPLACE(@cmd, '{nadKod}', @KntNadKod)
 SELECT @cmd = REPLACE(@cmd, '{podID}', @KntPodID)
 SELECT @cmd = REPLACE(@cmd, '{podKod}', @KntPodKod)
 SELECT @cmd = REPLACE(@cmd, '{guid}', @firmDbGuid)
 EXEC sp_executesql @cmd
 SELECT @cmd = 'INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod) SELECT ''cdn.MailWiadomosci'', MWD_MWDID, MWD_NumerPelny, {podID}, ''{podKod}'', {nadID}, ''{nadKod}''' +
 ' FROM {cnf}.cdn.MailWiadomosci WHERE MWD_PodmiotDotyczyTyp = 1 AND MWD_PodmiotDotyczyID = {podID} AND MWD_BazaGUID = ''{guid}''; '
 --SELECT @cmd = @cmd + 'ALTER TABLE {cnf}.cdn.MailWiadomosci DISABLE TRIGGER ALL; UPDATE {cnf}.cdn.MailWiadomosci SET MWD_PodmiotDotyczyID = {nadID} WHERE MWD_PodmiotDotyczyTyp = 1 AND MWD_PodmiotDotyczyID = {podID} AND MWD_BazaGUID = ''{guid}''; ALTER TABLE {cnf}.cdn.MailWiadomosci ENABLE TRIGGER ALL'
 SELECT @cmd = @cmd + 'UPDATE {cnf}.cdn.MailWiadomosci SET MWD_PodmiotDotyczyID = {nadID} WHERE MWD_PodmiotDotyczyTyp = 1 AND MWD_PodmiotDotyczyID = {podID} AND MWD_BazaGUID = ''{guid}'''
 SELECT @cmd = REPLACE(@cmd, '{cnf}', @cnf)
 SELECT @cmd = REPLACE(@cmd, '{nadID}', @KntNadID)
 SELECT @cmd = REPLACE(@cmd, '{nadKod}', @KntNadKod)
 SELECT @cmd = REPLACE(@cmd, '{podID}', @KntPodID)
 SELECT @cmd = REPLACE(@cmd, '{podKod}', @KntPodKod)
 SELECT @cmd = REPLACE(@cmd, '{guid}', @firmDbGuid)
 EXEC sp_executesql @cmd
 SELECT @cmd = 'INSERT INTO cdn.KntScalHist (KSH_NazwaTabeli, KSH_IDWiersza, KSH_NumerDok, KSH_OldKntID, KSH_OldKntKod, KSH_NewKntID, KSH_NewKntKod) SELECT ''cdn.SMS'', SMS_SMSID, '''', {podID}, ''{podKod}'', {nadID}, ''{nadKod}''' +
 ' FROM {cnf}.cdn.SMS WHERE SMS_PodmiotAdresatTyp = 1 AND SMS_PodmiotAdresatID = {podID} AND SMS_BazaGUID = ''{guid}''; '
 --SELECT @cmd = @cmd + 'ALTER TABLE {cnf}.cdn.SMS DISABLE TRIGGER ALL; UPDATE {cnf}.cdn.SMS SET SMS_PodmiotAdresatID = {nadID} WHERE SMS_PodmiotAdresatTyp = 1 AND SMS_PodmiotAdresatID = {podID} AND SMS_BazaGUID = ''{guid}''; ALTER TABLE {cnf}.cdn.SMS ENABLE TRIGGER ALL'
 SELECT @cmd = @cmd + 'UPDATE {cnf}.cdn.SMS SET SMS_PodmiotAdresatID = {nadID}, SMS_PodmiotAdresatKod = ''{nadKod}'', SMS_PodmiotAdresatNazwa = ''{nadNazwa}'' WHERE SMS_PodmiotAdresatTyp = 1 AND SMS_PodmiotAdresatID = {podID} AND SMS_BazaGUID = ''{guid}'''
 SELECT @cmd = REPLACE(@cmd, '{cnf}', @cnf)
 SELECT @cmd = REPLACE(@cmd, '{nadID}', @KntNadID)
 SELECT @cmd = REPLACE(@cmd, '{nadKod}', @KntNadKod)
 SELECT @cmd = REPLACE(@cmd, '{nadNazwa}', @KntNadNazwa)
 SELECT @cmd = REPLACE(@cmd, '{podID}', @KntPodID)
 SELECT @cmd = REPLACE(@cmd, '{podKod}', @KntPodKod)
 SELECT @cmd = REPLACE(@cmd, '{guid}', @firmDbGuid)
 EXEC sp_executesql @cmd
 SET NOCOUNT OFF
