CREATE Function CDN.KntDuplikaty(@NipE NVARCHAR(20), @Nazwa NVARCHAR(130), @Miasto NVARCHAR(50), @Ulica NVARCHAR(50), @NrDomu NVARCHAR(16), @NrLokalu NVARCHAR(16), @notID INT)
Returns Table
Return
( SELECT Knt_KntID, Knt_Kod, Knt_Nazwa1, Knt_NipKraj, Knt_NipE, Knt_Miasto
 FROM CDN.Kontrahenci JOIN CDN.KntListaMask(@NipE, @Nazwa, @Miasto, CDN.KntListaUsunZnakiSpecjalneIPrefiksy(@Ulica, @NrDomu, @NrLokalu)) ON Knt_KntId = KntId WHERE Knt_KntId <> @notID AND Knt_Nieaktywny = 0)
