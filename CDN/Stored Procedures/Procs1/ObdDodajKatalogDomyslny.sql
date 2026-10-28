CREATE PROCEDURE CDN.ObdDodajKatalogDomyslny
AS
BEGIN
    SET NOCOUNT ON;
 IF NOT EXISTS (SELECT * FROM CDN.Katalogi WHERE Ktl_Symbol = '!Domyślny!')
 BEGIN
  INSERT INTO [CDN].[Katalogi] ([Ktl_Symbol],[Ktl_Nazwa],[Ktl_Numeracja],[Ktl_IBard24], Ktl_Domyslny,[Ktl_OpeZalID],[Ktl_TS_Zal],[Ktl_OpeModID],[Ktl_TS_Mod])
                     VALUES('!Domyślny!',N'!Katalog domyślny',N'DOMYŚ', '', 1, 1,GETDATE(),1,GETDATE())
 END
KONIEC:
    SET NOCOUNT OFF;
END
