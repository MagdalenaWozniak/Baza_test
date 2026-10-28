CREATE PROCEDURE CDN.DokRelacjeGetItem(@typDok INT, @dokId INT, @guidStr VARCHAR(50))
AS
BEGIN
	SET NOCOUNT OFF;
	DECLARE @guid uniqueidentifier,@configBaseName nvarchar(100), @configBaseServer nvarchar(100)
	DECLARE  @sqlText NVARCHAR(1024), @paramDefinition NVARCHAR(254)
	IF LEN(@guidStr) > 35 AND (@typDok = 1010 OR @typDok = 1011) --  e_op_KlasaWW, e_op_KlasaWP (e-mail)
	BEGIN
		SET @guid = CONVERT(uniqueidentifier, @guidStr)
		SELECT @configBaseServer = sys_wartosc FROM cdn.systemcdn WHERE sys_id = 1001
		SELECT @configBaseName = sys_wartosc FROM cdn.systemcdn WHERE sys_id = 1002

		SET @sqlText = N'SELECT TOP 1 [MWD_NumerPelny] As NumerDok,''e-mail'' As TypDok,CONVERT(NVARCHAR(255),[MWD_Temat]) As OpisDok,[MWD_DataDok] As DataDok,[MWD_PodmiotAdresatKod] As PodmiotDok,''E'' As RodzajDok FROM ['
		    + @configBaseServer+'].[' + @configBaseName
			+ N'].[CDN].[MailWiadomosci] WHERE MWD_IDWiadomosci=@IDWiadomosci'
		SET @paramDefinition = N'@IDWiadomosci UNIQUEIDENTIFIER'
		EXEC sp_executeSQL @sqlText, @paramDefinition, @IDWiadomosci=@guid
		GOTO KONIEC
	END
	IF LEN(@guidStr) > 35 AND (@typDok = 1020) --  e_op_KlasaSms
	BEGIN
		SET @guid = CONVERT(uniqueidentifier, @guidStr)
		SELECT @configBaseServer = sys_wartosc FROM cdn.systemcdn WHERE sys_id = 1001
		SELECT @configBaseName = sys_wartosc FROM cdn.systemcdn WHERE sys_id = 1002

		SET @sqlText = N'SELECT TOP 1 Convert(NVARCHAR(30), SmS_Telefon) As NumerDok,''sms'' As TypDok,CONVERT(NVARCHAR(255),[SmS_Tresc]) As OpisDok,CASE WHEN SMS_Status=0 THEN SMS_DataDok ELSE SMS_Wyslano END As DataDok,[SmS_PodmiotAdresatKod] As PodmiotDok,''S'' As RodzajDok FROM ['
		    + @configBaseServer+'].[' + @configBaseName
			+ N'].[CDN].[Sms] WHERE SmS_IDWiadomosci=@IDWiadomosci'
		SET @paramDefinition = N'@IDWiadomosci UNIQUEIDENTIFIER'
		EXEC sp_executeSQL @sqlText, @paramDefinition, @IDWiadomosci=@guid
		GOTO KONIEC
	END
	EXEC CDN.DokRelacjeGetDocument @typDok, @dokId
KONIEC:
	SET NOCOUNT ON;
END
