/*
Procedura tworzy zapis techniczny dodanej faktury z rejestru VAT.
*/
CREATE PROCEDURE CDN.KopiaFaFiskalnej
@VaN_VaNID int,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 DECLARE
 @VaN_Typ smallint,
 @VaN_Rodzaj tinyint,
 @VaN_Rejestr nvarchar(20),
 @VaN_RokMies int,
 @VaN_Lp int,
 @VaN_DataObowiazkuPodatkowego datetime,
 @VaN_DataPrawaOdliczenia datetime,
 @VaN_DataZap datetime,
 @VaN_DataWys datetime,
 @VaN_DataOpe datetime,
 @VaN_DataKur datetime,
 @VaN_KursDoKsiegowania tinyint,
 @VaN_DataKurDoVAT datetime,
 @VaN_DeklRokMies int,
 @VaN_DeklRokMiesKasa int,
 @VaN_RozliczacVat7 tinyint,
 @VaN_RozliczacVatUE tinyint,
 @VaN_RozliczacVat27 tinyint,
 @VaN_AutoVat7Kasa tinyint,
 @VaN_MetodaKasowa tinyint,
 @VaN_JPK_FA tinyint,
 @VaN_IdentKsieg varchar(50),
 @VaN_IdentKsiegNumeracja varchar(50),
 @VaN_IdentKsiegDDfID int,
 @VaN_Dokument varchar(256),
 @VaN_DokumentyNadrzedne varchar(256),
 @VaN_KorektaDo nvarchar(30),
 @VaN_Korekta tinyint,
 @VaN_Fiskalna tinyint,
 @VaN_KorektaVAT tinyint,
 @VaN_Detal tinyint,
 @VaN_Wewnetrzna tinyint,
 @VaN_PodmiotTyp smallint,
 @VaN_PodID int,
 @VaN_KntNazwa1 nvarchar(50),
 @VaN_KntNazwa2 nvarchar(50),
 @VaN_KntNazwa3 nvarchar(250),
 @VaN_KntKraj nvarchar(40),
 @VaN_KntWojewodztwo nvarchar(40),
 @VaN_KntPowiat nvarchar(40),
 @VaN_KntGmina nvarchar(40),
 @VaN_KntUlica nvarchar(40),
 @VaN_KntNrDomu nvarchar(10),
 @VaN_KntNrLokalu nvarchar(10),
 @VaN_KntMiasto nvarchar(40),
 @VaN_KntKodPocztowy varchar(10),
 @VaN_KntPoczta nvarchar(40),
 @VaN_KntAdres2 nvarchar(40),
 @VaN_KntNipKraj varchar(2),
 @VaN_KntNipE varchar(13),
 @VaN_Pesel nvarchar(11),
 @VaN_KntKonto nvarchar(20),
 @VaN_Finalny tinyint,
 @VaN_Export tinyint,
 @VaN_PodatekVat tinyint,
 @VaN_MalyPod tinyint,
 @VaN_Rolnik tinyint,
 @VaN_PlatnikTyp smallint,
 @VaN_PlatnikID int,
 @VaN_PlatnikRachunekLp int,
 @VaN_PlatnikKraj nvarchar(40),
 @VaN_PlatnikWojewodztwo nvarchar(40),
 @VaN_PlatnikPowiat nvarchar(40),
 @VaN_PlatnikGmina nvarchar(40),
 @VaN_PlatnikUlica nvarchar(40),
 @VaN_PlatnikNrDomu nvarchar(10),
 @VaN_PlatnikNrLokalu nvarchar(10),
 @VaN_PlatnikMiasto nvarchar(40),
 @VaN_PlatnikKodPocztowy nvarchar(10),
 @VaN_PlatnikPoczta nvarchar(40),
 @VaN_PlatnikAdres2 nvarchar(40),
 @VaN_PlatnikNazwa1 nvarchar(50),
 @VaN_PlatnikNazwa2 nvarchar(50),
 @VaN_PlatnikNazwa3 nvarchar(250),
 @Van_PlatnikRachunekNr nvarchar(51),
 @VaN_KatID int,
 @VaN_Kategoria varchar(50),
 @VaN_WzID int,
 @VaN_Rozliczono tinyint,
 @VaN_Zaplacono tinyint,
 @VaN_FplID int,
 @VaN_Termin datetime,
 @VaN_RazemNetto decimal(15, 2),
 @VaN_RazemNettoDoVAT decimal(15, 2),
 @VaN_RazemVAT decimal(15, 2),
 @VaN_RazemVATDoVAT decimal(15, 2),
 @VaN_RazemBrutto decimal(15, 2),
 @VaN_RazemBruttoDoVAT decimal(15, 2),
 @VaN_RazemBruttoWal decimal(15, 2),
 @VaN_KwotaNKUP decimal(15, 2),
 @VaN_VATNKUP decimal(15, 2),
 @VaN_Waluta varchar(3),
 @VaN_WalutaDoVAT varchar(3),
 @VaN_KursNumer int,
 @VaN_KursNumerDoVAT int,
 @VaN_KursL decimal(15, 4),
 @VaN_KursLDoVAT decimal(15, 4),
 @VaN_KursM decimal(5, 0),
 @VaN_KursMDoVAT decimal(5, 0),
 @VaN_Zaplata decimal(15, 2),
 @VaN_WartoscZak decimal(15, 2),
 @VaN_AkcyzaWegiel decimal(15, 2),
 @VaN_AkcyzaWegiel_KolumnaKPR int,
 @VaN_TrybNettoVAT tinyint,
 @VaN_PodmiotZalTyp smallint,
 @VaN_PodZalId int,
 @VaN_AppRowID varchar(20),
 @VaN_AppID int,
 @VaN_TrnID int,
 @VaN_VanOrgId int,
 @VaN_CloProc decimal(5, 2),
 @VaN_CloWart decimal(15, 2),
 @VaN_AkcyzaProc decimal(5, 2),
 @VaN_AkcyzaWart decimal(15, 2),
 @VaN_PodImpProc decimal(5, 2),
 @VaN_PodImpWart decimal(15, 2),
 @VaN_TS_Export datetime,
 @VaN_OpeZalID int,
 @VaN_StaZalId int,
 @VaN_TS_Zal datetime,
 @VaN_OpeModID int,
 @VaN_StaModId int,
 @VaN_TS_Mod datetime,
 @VaN_OpeModKod varchar(20),
 @VaN_OpeModNazwisko nvarchar(50),
 @VaN_OpeZalKod varchar(20),
 @VaN_OpeZalNazwisko nvarchar(50),
 @VaN_Srw smallint,
 @VaN_ZakID int,
 @notUsed     int,
 @DOpe datetime
 SELECT
    @VaN_Typ = VaN_Typ
      ,@VaN_Rodzaj = VaN_Rodzaj
      ,@VaN_Rejestr = VaN_Rejestr
      ,@VaN_RokMies = VaN_RokMies
      ,@VaN_Lp = VaN_Lp
      ,@VaN_DataObowiazkuPodatkowego = VaN_DataObowiazkuPodatkowego
      ,@VaN_DataPrawaOdliczenia = VaN_DataPrawaOdliczenia
      ,@VaN_DataZap = VaN_DataZap
      ,@VaN_DataWys = VaN_DataWys
      ,@VaN_DataOpe = VaN_DataOpe
      ,@VaN_DataKur = VaN_DataKur
      ,@VaN_KursDoKsiegowania = VaN_KursDoKsiegowania
      ,@VaN_DataKurDoVAT = VaN_DataKurDoVAT
      ,@VaN_DeklRokMies = VaN_DeklRokMies
      ,@VaN_DeklRokMiesKasa = VaN_DeklRokMiesKasa
      ,@VaN_RozliczacVat7 = VaN_RozliczacVat7
      ,@VaN_RozliczacVatUE = VaN_RozliczacVatUE
      ,@VaN_RozliczacVat27 = VaN_RozliczacVat27
      ,@VaN_AutoVat7Kasa = VaN_AutoVat7Kasa
      ,@VaN_MetodaKasowa = VaN_MetodaKasowa
      ,@VaN_JPK_FA = VaN_JPK_FA
      ,@VaN_IdentKsieg = VaN_IdentKsieg
      ,@VaN_IdentKsiegNumeracja = VaN_IdentKsiegNumeracja
      ,@VaN_IdentKsiegDDfID = VaN_IdentKsiegDDfID
      ,@VaN_Dokument = VaN_Dokument
      ,@VaN_DokumentyNadrzedne = VaN_DokumentyNadrzedne
      ,@VaN_KorektaDo = VaN_KorektaDo
      ,@VaN_Korekta = VaN_Korekta
      ,@VaN_Fiskalna = VaN_Fiskalna
      ,@VaN_KorektaVAT = VaN_KorektaVAT
      ,@VaN_Detal = VaN_Detal
      ,@VaN_Wewnetrzna = VaN_Wewnetrzna
      ,@VaN_PodmiotTyp = VaN_PodmiotTyp
      ,@VaN_PodID = VaN_PodID
      ,@VaN_KntNazwa1 = VaN_KntNazwa1
      ,@VaN_KntNazwa2 = VaN_KntNazwa2
      ,@VaN_KntNazwa3 = VaN_KntNazwa3
      ,@VaN_KntKraj = VaN_KntKraj
      ,@VaN_KntWojewodztwo = VaN_KntWojewodztwo
      ,@VaN_KntPowiat = VaN_KntPowiat
      ,@VaN_KntGmina = VaN_KntGmina
      ,@VaN_KntUlica = VaN_KntUlica
      ,@VaN_KntNrDomu = VaN_KntNrDomu
      ,@VaN_KntNrLokalu = VaN_KntNrLokalu
      ,@VaN_KntMiasto = VaN_KntMiasto
      ,@VaN_KntKodPocztowy = VaN_KntKodPocztowy
      ,@VaN_KntPoczta = VaN_KntPoczta
      ,@VaN_KntAdres2 = VaN_KntAdres2
      ,@VaN_KntNipKraj = VaN_KntNipKraj
      ,@VaN_KntNipE = VaN_KntNipE
      ,@VaN_Pesel = VaN_Pesel
      ,@VaN_KntKonto = VaN_KntKonto
      ,@VaN_Finalny = VaN_Finalny
      ,@VaN_Export = VaN_Export
      ,@VaN_PodatekVat = VaN_PodatekVat
      ,@VaN_MalyPod = VaN_MalyPod
      ,@VaN_Rolnik = VaN_Rolnik
      ,@VaN_PlatnikTyp = VaN_PlatnikTyp
      ,@VaN_PlatnikID = VaN_PlatnikID
      ,@VaN_PlatnikRachunekLp = VaN_PlatnikRachunekLp
      ,@VaN_PlatnikKraj = VaN_PlatnikKraj
      ,@VaN_PlatnikWojewodztwo = VaN_PlatnikWojewodztwo
      ,@VaN_PlatnikPowiat = VaN_PlatnikPowiat
      ,@VaN_PlatnikGmina = VaN_PlatnikGmina
      ,@VaN_PlatnikUlica = VaN_PlatnikUlica
      ,@VaN_PlatnikNrDomu = VaN_PlatnikNrDomu
      ,@VaN_PlatnikNrLokalu = VaN_PlatnikNrLokalu
      ,@VaN_PlatnikMiasto = VaN_PlatnikMiasto
      ,@VaN_PlatnikKodPocztowy = VaN_PlatnikKodPocztowy
      ,@VaN_PlatnikPoczta = VaN_PlatnikPoczta
      ,@VaN_PlatnikAdres2 = VaN_PlatnikAdres2
      ,@VaN_PlatnikNazwa1 = VaN_PlatnikNazwa1
      ,@VaN_PlatnikNazwa2 = VaN_PlatnikNazwa2
      ,@VaN_PlatnikNazwa3 = VaN_PlatnikNazwa3
      ,@Van_PlatnikRachunekNr = Van_PlatnikRachunekNr
      ,@VaN_KatID = VaN_KatID
      ,@VaN_Kategoria = VaN_Kategoria
      ,@VaN_WzID = VaN_WzID
      ,@VaN_Rozliczono = VaN_Rozliczono
      ,@VaN_Zaplacono = VaN_Zaplacono
      ,@VaN_FplID = VaN_FplID
      ,@VaN_Termin = VaN_Termin
      ,@VaN_RazemNetto = VaN_RazemNetto
      ,@VaN_RazemNettoDoVAT = VaN_RazemNettoDoVAT
      ,@VaN_RazemVAT = VaN_RazemVAT
      ,@VaN_RazemVATDoVAT = VaN_RazemVATDoVAT
      ,@VaN_RazemBrutto = VaN_RazemBrutto
      ,@VaN_RazemBruttoDoVAT = VaN_RazemBruttoDoVAT
      ,@VaN_RazemBruttoWal = VaN_RazemBruttoWal
      ,@VaN_KwotaNKUP = VaN_KwotaNKUP
      ,@VaN_VATNKUP = VaN_VATNKUP
      ,@VaN_Waluta = VaN_Waluta
      ,@VaN_WalutaDoVAT = VaN_WalutaDoVAT
      ,@VaN_KursNumer = VaN_KursNumer
      ,@VaN_KursNumerDoVAT = VaN_KursNumerDoVAT
      ,@VaN_KursL = VaN_KursL
      ,@VaN_KursLDoVAT = VaN_KursLDoVAT
      ,@VaN_KursM = VaN_KursM
      ,@VaN_KursMDoVAT = VaN_KursMDoVAT
      ,@VaN_Zaplata = VaN_Zaplata
      ,@VaN_WartoscZak = VaN_WartoscZak
      ,@VaN_AkcyzaWegiel = VaN_AkcyzaWegiel
      ,@VaN_AkcyzaWegiel_KolumnaKPR = VaN_AkcyzaWegiel_KolumnaKPR
      ,@VaN_TrybNettoVAT = VaN_TrybNettoVAT
      ,@VaN_PodmiotZalTyp = VaN_PodmiotZalTyp
      ,@VaN_PodZalId = VaN_PodZalId
      ,@VaN_AppRowID = VaN_AppRowID
      ,@VaN_AppID = VaN_AppID
      ,@VaN_TrnID = VaN_TrnID
      ,@VaN_VanOrgId = VaN_VanOrgId
      ,@VaN_CloProc = VaN_CloProc
      ,@VaN_CloWart = VaN_CloWart
      ,@VaN_AkcyzaProc = VaN_AkcyzaProc
      ,@VaN_AkcyzaWart = VaN_AkcyzaWart
      ,@VaN_PodImpProc = VaN_PodImpProc
      ,@VaN_PodImpWart = VaN_PodImpWart
      ,@VaN_TS_Export = VaN_TS_Export
      ,@VaN_OpeZalID = VaN_OpeZalID
      ,@VaN_StaZalId = VaN_StaZalId
      ,@VaN_TS_Zal = VaN_TS_Zal
      ,@VaN_OpeModID = VaN_OpeModID
      ,@VaN_StaModId = VaN_StaModId
      ,@VaN_TS_Mod = VaN_TS_Mod
      ,@VaN_OpeModKod = VaN_OpeModKod
      ,@VaN_OpeModNazwisko = VaN_OpeModNazwisko
      ,@VaN_OpeZalKod = VaN_OpeZalKod
      ,@VaN_OpeZalNazwisko = VaN_OpeZalNazwisko
      ,@VaN_Srw = VaN_Srw
      ,@VaN_ZakID = VaN_ZakID
 FROM CDN.VatNag WHERE VaN_VaNID = @VaN_VaNID
 SELECT @VaN_IdentKsieg = VaN_IdentKsieg FROM CDN.VatNag WHERE VaN_VaNID = @VaN_VaNID
 SET @VaN_IdentKsieg = CASE (SELECT Fir_Wartosc
        FROM CDN.Firma
        WHERE Fir_Numer = 1762)
    WHEN '1' THEN 'Tech. ' + @VaN_IdentKsieg
    ELSE ''
    END
 SET @VaN_Lp = @VaN_Lp + 1;
 SET @VaN_Kategoria = 'Zapis techniczny do rozliczenia JPK_V7';
 SET @VaN_Rodzaj = 10;
 SET @VaN_VaNOrgID = @VaN_VaNID;
 SET @VaN_Wewnetrzna = 1;
 INSERT INTO CDN.VatNag
           (VaN_Typ
           ,VaN_Rodzaj
           ,VaN_Rejestr
           ,VaN_RokMies
           ,VaN_Lp
           ,VaN_DataObowiazkuPodatkowego
           ,VaN_DataPrawaOdliczenia
           ,VaN_DataZap
           ,VaN_DataWys
           ,VaN_DataOpe
           ,VaN_DataKur
           ,VaN_KursDoKsiegowania
           ,VaN_DataKurDoVAT
           ,VaN_DeklRokMies
           ,VaN_DeklRokMiesKasa
           ,VaN_RozliczacVat7
           ,VaN_RozliczacVatUE
           ,VaN_RozliczacVat27
           ,VaN_AutoVat7Kasa
           ,VaN_MetodaKasowa
           ,VaN_JPK_FA
           ,VaN_IdentKsieg
           ,VaN_IdentKsiegNumeracja
           ,VaN_IdentKsiegDDfID
           ,VaN_Dokument
           ,VaN_DokumentyNadrzedne
           ,VaN_KorektaDo
           ,VaN_Korekta
           ,VaN_Fiskalna
           ,VaN_KorektaVAT
           ,VaN_Detal
           ,VaN_Wewnetrzna
           ,VaN_PodmiotTyp
           ,VaN_PodID
           ,VaN_KntNazwa1
           ,VaN_KntNazwa2
           ,VaN_KntNazwa3
           ,VaN_KntKraj
           ,VaN_KntWojewodztwo
           ,VaN_KntPowiat
           ,VaN_KntGmina
           ,VaN_KntUlica
           ,VaN_KntNrDomu
           ,VaN_KntNrLokalu
           ,VaN_KntMiasto
           ,VaN_KntKodPocztowy
           ,VaN_KntPoczta
           ,VaN_KntAdres2
           ,VaN_KntNipKraj
           ,VaN_KntNipE
           ,VaN_Pesel
           ,VaN_KntKonto
           ,VaN_Finalny
           ,VaN_Export
           ,VaN_PodatekVat
           ,VaN_MalyPod
           ,VaN_Rolnik
           ,VaN_PlatnikTyp
           ,VaN_PlatnikID
           ,VaN_PlatnikRachunekLp
           ,VaN_PlatnikKraj
           ,VaN_PlatnikWojewodztwo
           ,VaN_PlatnikPowiat
           ,VaN_PlatnikGmina
           ,VaN_PlatnikUlica
           ,VaN_PlatnikNrDomu
           ,VaN_PlatnikNrLokalu
           ,VaN_PlatnikMiasto
           ,VaN_PlatnikKodPocztowy
           ,VaN_PlatnikPoczta
           ,VaN_PlatnikAdres2
           ,VaN_PlatnikNazwa1
           ,VaN_PlatnikNazwa2
           ,VaN_PlatnikNazwa3
           ,Van_PlatnikRachunekNr
           ,VaN_KatID
           ,VaN_Kategoria
           ,VaN_WzID
           ,VaN_Rozliczono
           ,VaN_Zaplacono
           ,VaN_FplID
           ,VaN_Termin
           ,VaN_RazemNetto
           ,VaN_RazemNettoDoVAT
           ,VaN_RazemVAT
           ,VaN_RazemVATDoVAT
           ,VaN_RazemBrutto
           ,VaN_RazemBruttoDoVAT
           ,VaN_RazemBruttoWal
           ,VaN_KwotaNKUP
           ,VaN_VATNKUP
           ,VaN_Waluta
           ,VaN_WalutaDoVAT
           ,VaN_KursNumer
           ,VaN_KursNumerDoVAT
           ,VaN_KursL
           ,VaN_KursLDoVAT
           ,VaN_KursM
           ,VaN_KursMDoVAT
           ,VaN_Zaplata
           ,VaN_WartoscZak
           ,VaN_AkcyzaWegiel
           ,VaN_AkcyzaWegiel_KolumnaKPR
           ,VaN_TrybNettoVAT
           ,VaN_PodmiotZalTyp
           ,VaN_PodZalId
           ,VaN_AppRowID
           ,VaN_AppID
           ,VaN_TrnID
           ,VaN_VanOrgId
           ,VaN_CloProc
           ,VaN_CloWart
           ,VaN_AkcyzaProc
           ,VaN_AkcyzaWart
           ,VaN_PodImpProc
           ,VaN_PodImpWart
           ,VaN_KpRID
           ,VaN_RycID
           ,VaN_DekID
           ,VaN_PreDekID
           ,VaN_ImportAppId
           ,VaN_ImportRowId
           ,VaN_TS_Export
           ,VaN_OpeZalID
           ,VaN_StaZalId
           ,VaN_TS_Zal
           ,VaN_OpeModID
           ,VaN_StaModId
           ,VaN_TS_Mod
           ,VaN_OpeModKod
           ,VaN_OpeModNazwisko
           ,VaN_OpeZalKod
           ,VaN_OpeZalNazwisko
           ,VaN_Srw
           ,VaN_ZakID
           ,VaN_ZbVaNID)
     VALUES
           (@VaN_Typ
      ,@VaN_Rodzaj
      ,@VaN_Rejestr
      ,@VaN_RokMies
      ,@VaN_Lp
      ,@VaN_DataObowiazkuPodatkowego
      ,@VaN_DataPrawaOdliczenia
      ,@VaN_DataZap
      ,@VaN_DataWys
      ,@VaN_DataOpe
      ,@VaN_DataKur
      ,@VaN_KursDoKsiegowania
      ,@VaN_DataKurDoVAT
      ,@VaN_DeklRokMies
      ,@VaN_DeklRokMiesKasa
      ,@VaN_RozliczacVat7
      ,@VaN_RozliczacVatUE
      ,@VaN_RozliczacVat27
      ,@VaN_AutoVat7Kasa
      ,@VaN_MetodaKasowa
      ,@VaN_JPK_FA
      ,@VaN_IdentKsieg
      ,@VaN_IdentKsiegNumeracja
      ,@VaN_IdentKsiegDDfID
      ,@VaN_Dokument
      ,@VaN_DokumentyNadrzedne
      ,@VaN_KorektaDo
      ,@VaN_Korekta
      ,@VaN_Fiskalna
      ,@VaN_KorektaVAT
      ,@VaN_Detal
      ,@VaN_Wewnetrzna
      ,@VaN_PodmiotTyp
      ,@VaN_PodID
      ,@VaN_KntNazwa1
      ,@VaN_KntNazwa2
      ,@VaN_KntNazwa3
      ,@VaN_KntKraj
      ,@VaN_KntWojewodztwo
      ,@VaN_KntPowiat
      ,@VaN_KntGmina
      ,@VaN_KntUlica
      ,@VaN_KntNrDomu
      ,@VaN_KntNrLokalu
      ,@VaN_KntMiasto
      ,@VaN_KntKodPocztowy
      ,@VaN_KntPoczta
      ,@VaN_KntAdres2
      ,@VaN_KntNipKraj
      ,@VaN_KntNipE
      ,@VaN_Pesel
      ,@VaN_KntKonto
      ,@VaN_Finalny
      ,@VaN_Export
      ,@VaN_PodatekVat
      ,@VaN_MalyPod
      ,@VaN_Rolnik
      ,@VaN_PlatnikTyp
      ,@VaN_PlatnikID
      ,@VaN_PlatnikRachunekLp
      ,@VaN_PlatnikKraj
      ,@VaN_PlatnikWojewodztwo
      ,@VaN_PlatnikPowiat
      ,@VaN_PlatnikGmina
      ,@VaN_PlatnikUlica
      ,@VaN_PlatnikNrDomu
      ,@VaN_PlatnikNrLokalu
      ,@VaN_PlatnikMiasto
      ,@VaN_PlatnikKodPocztowy
      ,@VaN_PlatnikPoczta
      ,@VaN_PlatnikAdres2
      ,@VaN_PlatnikNazwa1
      ,@VaN_PlatnikNazwa2
      ,@VaN_PlatnikNazwa3
      ,@Van_PlatnikRachunekNr
      ,@VaN_KatID
      ,@VaN_Kategoria
      ,@VaN_WzID
      ,@VaN_Rozliczono
      ,@VaN_Zaplacono
      ,@VaN_FplID
      ,@VaN_Termin
      ,@VaN_RazemNetto
      ,@VaN_RazemNettoDoVAT
      ,@VaN_RazemVAT
      ,@VaN_RazemVATDoVAT
      ,@VaN_RazemBrutto
      ,@VaN_RazemBruttoDoVAT
      ,@VaN_RazemBruttoWal
      ,@VaN_KwotaNKUP
      ,@VaN_VATNKUP
      ,@VaN_Waluta
      ,@VaN_WalutaDoVAT
      ,@VaN_KursNumer
      ,@VaN_KursNumerDoVAT
      ,@VaN_KursL
      ,@VaN_KursLDoVAT
      ,@VaN_KursM
      ,@VaN_KursMDoVAT
      ,@VaN_Zaplata
      ,@VaN_WartoscZak
      ,@VaN_AkcyzaWegiel
      ,@VaN_AkcyzaWegiel_KolumnaKPR
      ,@VaN_TrybNettoVAT
      ,@VaN_PodmiotZalTyp
      ,@VaN_PodZalId
      ,@VaN_AppRowID
      ,@VaN_AppID
      ,@VaN_TrnID
      ,@VaN_VanOrgId
      ,@VaN_CloProc
      ,@VaN_CloWart
      ,@VaN_AkcyzaProc
      ,@VaN_AkcyzaWart
      ,@VaN_PodImpProc
      ,@VaN_PodImpWart
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,''
   ,''
      ,NULL
      ,@VaN_OpeZalID
      ,@VaN_StaZalId
      ,@VaN_TS_Zal
      ,@VaN_OpeModID
      ,@VaN_StaModId
      ,@VaN_TS_Mod
      ,@VaN_OpeModKod
      ,@VaN_OpeModNazwisko
      ,@VaN_OpeZalKod
      ,@VaN_OpeZalNazwisko
      ,@VaN_Srw
      ,@VaN_ZakID
      ,NULL)
 DECLARE @DokID INT
 SET @DokID = SCOPE_IDENTITY()
 DECLARE @ID INT
 SELECT @ID = KV7_KV7ID FROM cdn.KodyJPKV7 WHERE KV7_Kod = 'RO'
 IF NOT EXISTS(SELECT * FROM cdn.DokKodyJPKV7 WHERE DKV7_ParentTyp = 2 AND DKV7_ParentID = @DokId AND DKV7_KV7ID = @ID)
  INSERT INTO cdn.DokKodyJPKV7 (DKV7_ParentTyp, DKV7_ParentID, DKV7_KV7ID) VALUES(2, @DokId, @ID)
 INSERT INTO [CDN].[VatTab]
           ([VaT_VaNID]
           ,[VaT_VaTOrgId]
           ,[VaT_Stawka]
           ,[VaT_Flaga]
           ,[VaT_Zrodlowa]
           ,[VaT_RodzajZakupu]
           ,[VaT_Odliczenia]
           ,[VaT_Netto]
           ,[VaT_NettoDoVAT]
           ,[VaT_VAT]
           ,[VaT_VATDoVAT]
           ,[VaT_NettoWal]
           ,[VaT_VATWal]
           ,[VaT_KatID]
           ,[VaT_KolumnaKPR]
           ,[VaT_KolumnaRYC]
           ,[VaT_KatOpis]
           ,[VaT_Kat2ID]
           ,[VaT_Kat2Opis]
           ,[VaT_Lp]
           ,[VaT_KwotaNKUP]
           ,[VaT_VATNKUP]
           ,[VaT_StawkaSymbol])
     SELECT
            @DokID
           ,VaT_VaTOrgId
           ,VaT_Stawka
           ,VaT_Flaga
           ,VaT_Zrodlowa
           ,VaT_RodzajZakupu
           ,VaT_Odliczenia
           ,VaT_Netto
           ,VaT_NettoDoVAT
           ,VaT_VAT
           ,VaT_VATDoVAT
           ,VaT_NettoWal
           ,VaT_VATWal
           ,VaT_KatID
           ,0
           ,0
           ,VaT_KatOpis
           ,VaT_Kat2ID
           ,VaT_Kat2Opis
           ,VaT_Lp
           ,VaT_KwotaNKUP
           ,VaT_VATNKUP
           ,VaT_StawkaSymbol
     FROM CDN.VatTab WHERE VaT_VaNID = @VaN_VaNID
 EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 999,
   @ObiektSubTyp = @VaN_Typ,
   @ObiektID = @DokID,
   @ObiektNazwa = @VaN_Dokument,
   @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
   @Opis = @VaN_Dokument
 SET @Warnings = ''
END
