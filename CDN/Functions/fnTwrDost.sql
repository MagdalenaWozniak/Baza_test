CREATE FUNCTION [CDN].[fnTwrDost](@Twz_TwrId INT)
returns table
as return
SELECT  MAX(Twz_TwrId) as Twz_TwrId,  MAX(Twz_TwzID) as Twz_TwzID,  Twz_TrnId = MAX(Trn_TrnID), Mag = MAX(Mag_Symbol),
Mag1 = MAX(Mag_Symbol),Dok = MAX(CDN.TypDokumentu(TrN_TypDokumentu)),  Nr_Dok  = MAX(ISNULL(TrN_NumerPelny,'Dokument usunięty')),
Nr_Zrd  = MAX(TrN_NumerObcy),  Data = MAX(TwZ_Data),  Data1 = MAX(TwZ_Data),  Kon = MAX(Pod_Kod),
Ilosc = NULL,  Wartosc = NULL,  Cena = NULL, 0 as 'poziom',
MAX(TsC_Cecha1_Wartosc)as TsC_Cecha1_Wartosc, MAX(TsC_Cecha1_Format) as TsC_Cecha1_Format,
MAX(TsC_Cecha2_Wartosc)as TsC_Cecha2_Wartosc, MAX(TsC_Cecha2_Format) as TsC_Cecha2_Format,
MAX(TsC_Cecha3_Wartosc)as TsC_Cecha3_Wartosc, MAX(TsC_Cecha3_Format) as TsC_Cecha3_Format,
MAX(TsC_Cecha4_Wartosc)as TsC_Cecha4_Wartosc, MAX(TsC_Cecha4_Format) as TsC_Cecha4_Format,
MAX(TsC_Cecha5_Wartosc)as TsC_Cecha5_Wartosc, MAX(TsC_Cecha5_Format) as TsC_Cecha5_Format,
MAX(TsC_Cecha6_Wartosc)as TsC_Cecha6_Wartosc, MAX(TsC_Cecha6_Format) as TsC_Cecha6_Format,
MAX(TsC_Cecha7_Wartosc)as TsC_Cecha7_Wartosc, MAX(TsC_Cecha7_Format) as TsC_Cecha7_Format,
MAX(TsC_Cecha8_Wartosc)as TsC_Cecha8_Wartosc, MAX(TsC_Cecha8_Format) as TsC_Cecha8_Format,
MAX(TsC_Cecha9_Wartosc)as TsC_Cecha9_Wartosc, MAX(TsC_Cecha9_Format) as TsC_Cecha9_Format,
MAX(TsC_Cecha10_Wartosc)as TsC_Cecha10_Wartosc, MAX(TsC_Cecha10_Format) as TsC_Cecha10_Format,
TrS_TrEId as TrE_TrEId,MAX(TrS_TrSId) as TrS_TrSId
FROM cdn.TwrZasoby
JOIN cdn.TraSElem ON TwZ_TrSIdDost = TrS_TrSIdDost AND TrS_Typ=1
LEFT JOIN cdn.TraSElemCechy ON TsC_TrSId = TrS_TrSId
LEFT JOIN cdn.TraElem ON TrE_TrEId = TrS_TrEId
LEFT JOIN cdn.TraNag ON TrN_TrNId =TrE_TrNId
LEFT JOIN cdn.Magazyny ON Mag_MagId = TwZ_MagId
LEFT JOIN cdn.PodmiotyView ON Pod_PodId = TrN_PodId AND TrN_PodmiotTyp = Pod_PodmiotTyp
WHERE Twz_TwrId = @Twz_TwrId AND (TrN_Korekta=0 or TrN_Korekta is null)
GROUP BY Trs_TreId,twz_magid,twz_data
UNION
SELECT  Twz_TwrId,  Twz_TwzID,  Twz_TrnId = Trn_TrnID, Mag = '',
Mag1 = Mag_Symbol,Dok = '',  Nr_Dok  = '',
Nr_Zrd  = '',  Data = NULL,  Data1 = TwZ_Data,  Kon = '',
Ilosc = TwZ_Ilosc,  Wartosc = TwZ_Wartosc,  Cena = TwZ_Cena ,1 as 'poziom',
TsC_Cecha1_Wartosc, TsC_Cecha1_Format,
TsC_Cecha2_Wartosc, TsC_Cecha2_Format,
TsC_Cecha3_Wartosc, TsC_Cecha3_Format,
TsC_Cecha4_Wartosc, TsC_Cecha4_Format,
TsC_Cecha5_Wartosc, TsC_Cecha5_Format,
TsC_Cecha6_Wartosc, TsC_Cecha6_Format,
TsC_Cecha7_Wartosc, TsC_Cecha7_Format,
TsC_Cecha8_Wartosc, TsC_Cecha8_Format,
TsC_Cecha9_Wartosc, TsC_Cecha9_Format,
TsC_Cecha10_Wartosc, TsC_Cecha10_Format,
TrS_TrEId as TrE_TrEId,TrS_TrSId
FROM cdn.TwrZasoby
JOIN cdn.TraSElem ON TwZ_TrSIdDost = TrS_TrSIdDost AND TrS_Typ=1
LEFT JOIN cdn.TraSElemCechy ON TsC_TrSId = TrS_TrSId
LEFT JOIN cdn.TraElem ON TrE_TrEId = TrS_TrEId
LEFT JOIN cdn.TraNag ON TrN_TrNId =TrE_TrNId
LEFT JOIN cdn.Magazyny ON Mag_MagId = TwZ_MagId
WHERE Twz_TwrId = @Twz_TwrId AND (TrN_Korekta=0 or TrN_Korekta is null)
