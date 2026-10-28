create View AtrybutyKlasyAltumView
(ATK_Nazwa, ATK_Typ , ATK_Format, ATK_Nieaktywny , ATK_ImportRowId , ATK_SynchronizowanyAltum)
as
SELECT        ATK_Nazwa, ATK_Typ , ATK_Format, ATK_Nieaktywny , ATK_ImportRowId , ATK_SynchronizowanyAltum
FROM            CDN.OAtrybutyKlasy
