CREATE PROCEDURE [CDN].jdp_checkTwrGroupName
   @Group NVARCHAR(255) = '',
 @Exists int output
AS
IF @Group = ''
 SET @Exists = 1
ELSE
 SET @Exists = (SELECT COUNT(*) FROM CDN.TwrGrupyView WHERE Sciezka = ' ' + REPLACE('/' + @Group, '/', '\ '))
SELECT @Exists
