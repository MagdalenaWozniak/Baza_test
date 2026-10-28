CREATE  PROCEDURE [CDN].[HisDaneOsobowe] @PracownikID int = 0
AS
SET NOCOUNT ON
select
       Id as Tmp_PreId,
       --CurrentFrom as Tmp_DataOd,
    case when CurrentFrom is null then convert(datetime,'1900-01-01 00:00:00.000',111) else convert(datetime, CurrentFrom, 111)  end as Tmp_DataOd,
       case when CurrentTo is null then convert(datetime,'2999-12-31 00:00:00.000', 111) else convert(datetime, CurrentTo, 111)  end as Tmp_DataDo,
    --CurrentTo as Tmp_DataDo,
       Name as Tmp_Imie1,
       Surname as Tmp_Nazwisko,
       SecondName as Tmp_Imie2,
       TIN as Tmp_NipE,
       NIN as Tmp_Pesel,
       convert(datetime, BirthDate, 111) as Tmp_DataUr,
       BirthPlace as Tmp_MiejsceUr,
       FatherName as Tmp_ImieOjca,
       MotherName as Tmp_ImieMatki,
       FamilyName as Tmp_NazwRodowe,
       FamilyMotherName as Tmp_NazwRodoweM,
       IdentityCard as Tmp_DowOsobisty,
       Passport as Tmp_Paszport,
       Citizenship as Tmp_Obywatelstwo,
       MaritalStatus as Tmp_StanCywilny,
       AStreet as Tmp_MLDUlica,
       AStreetNo as Tmp_MLDNrDomu,
       AUnitNumber as Tmp_MLDNrLokalu,
       AZIPCode as Tmp_MLDKodPocztowy,
       ACity as Tmp_MLDMiasto,
       AaState as Tmp_MLDGmina,
       ACountry as Tmp_MLDKraj,
       ADistrict as Tmp_MLDPoczta,
       ACounty as Tmp_MLDPowiat,
    AProvince  as Tmp_MLDWojewodztwo,
       BStreet as Tmp_KORUlica,
       BStreetNo as Tmp_KORNrDomu,
       BUnitNumber as Tmp_KORNrLokalu,
       BZIPCode as Tmp_KORKodPocztowy,
       BCity as Tmp_KORMiasto,
       BaState as Tmp_KORGmina,
       BCountry as Tmp_KORKraj,
       BDistrict as Tmp_KORPoczta,
       BCounty as Tmp_KORPowiat,
    BProvince as Tmp_KORWojewodztwo,
       CStreet as Tmp_ZAMUlica,
       CStreetNo as Tmp_ZAMNrDomu,
       CUnitNumber as Tmp_ZAMNrLokalu,
       CZIPCode as Tmp_ZAMKodPocztowy,
       CCity as Tmp_ZAMMiasto,
       CaState as Tmp_ZAMGmina,
       CCountry as Tmp_ZAMKraj,
       CDistrict as Tmp_ZAMPoczta,
       CCounty as Tmp_ZAMPowiat,
    CProvince as Tmp_ZAMWojewodztwo,
       Phone1 as Tmp_HDKTelefon1,
       Phone2 as Tmp_HDKTelefon2,
       PhoneSMS as Tmp_TelefonSms,
       FAX as Tmp_HDKFax,
       Email as Tmp_HDKEmail,
       URL as Tmp_HDKURL,
       POBOX as Tmp_SkrytkaP,
       TELEX as Tmp_Teleks,
       MilitaryBookID as Tmp_KsiazeczkaW,
/* Adres zameldowania*/
       LTRIM(CASE WHEN AStreet <> '' THEN AStreet WHEN AStreet='' AND ACity <>'' THEN ACity ELSE ADistrict END +
       CASE WHEN AStreetNo <> '' AND AUnitNumber <> '' THEN ' ' + AStreetNo + '/' + AUnitNumber WHEN AStreetNo <> '' AND AUnitNumber = '' THEN ' ' + AStreetNo WHEN AStreetNo = '' AND AUnitNumber <> '' THEN ' ' + AUnitNumber ELSE '' END +
       CASE WHEN ADistrict <> AStreet  AND ACity <> AStreet AND ACity <> ADistrict AND ADistrict <> '' AND ACity <> '' AND AStreet <> '' THEN ', ' + ACity ELSE '' END +
       CASE WHEN (ACity <> '' OR ADistrict <> '') OR (AStreet <> '' AND AZIPCode <> '') THEN + ', ' ELSE '' END +
 /* POCZTA */
       + AZIPCode + CASE WHEN AZIPCode <> '' THEN  CASE WHEN ADistrict <> '' THEN + ' ' + ADistrict ELSE + ' ' + ACity  END ELSE CASE WHEN ADistrict <> '' THEN + ADistrict ELSE + ACity END END) +
 /* WOJEWÓDZTWO */
       CASE WHEN AProvince <> '' THEN CHAR(13) + AProvince ELSE '' END +
 /* KRAJ */
       CASE WHEN ACountry <> '' THEN CHAR(13) + ACountry ELSE '' END as Tmp_AdresMLD,
/* Adres zamieszkania*/
       LTRIM(CASE WHEN CStreet <> '' THEN CStreet WHEN CStreet='' AND CCity <>'' THEN CCity ELSE CDistrict END +
       CASE WHEN CStreetNo <> '' AND CUnitNumber <> '' THEN ' ' + CStreetNo + '/' + CUnitNumber WHEN CStreetNo <> '' AND CUnitNumber = '' THEN ' ' + CStreetNo WHEN CStreetNo = '' AND CUnitNumber <> '' THEN ' ' + CUnitNumber ELSE '' END +
       CASE WHEN CDistrict <> CStreet  AND CCity <> CStreet AND CCity <> CDistrict AND CDistrict <> '' AND CCity <> '' AND CStreet <> '' THEN ', ' + CCity ELSE '' END +
       CASE WHEN (CCity <> '' OR CDistrict <> '') OR (CStreet <> '' AND CZIPCode <> '') THEN + ', ' ELSE '' END +
 /* POCZTA */
       + CZIPCode + CASE WHEN CZIPCode <> '' THEN  CASE WHEN CDistrict <> '' THEN + ' ' + CDistrict ELSE + ' ' + CCity  END ELSE CASE WHEN CDistrict <> '' THEN + CDistrict ELSE + CCity END END) +
 /* WOJEWÓDZTWO */
       CASE WHEN CProvince <> '' THEN CHAR(13) + CProvince ELSE '' END +
 /* KRAJ */
       CASE WHEN CCountry <> '' THEN CHAR(13) + CCountry ELSE '' END as Tmp_AdresZAM,
/* Adres korespondencyjny*/
       LTRIM(CASE WHEN BStreet <> '' THEN BStreet WHEN BStreet='' AND BCity <>'' THEN BCity ELSE BDistrict END +
       CASE WHEN BStreetNo <> '' AND BUnitNumber <> '' THEN ' ' + BStreetNo + '/' + BUnitNumber WHEN BStreetNo <> '' AND BUnitNumber = '' THEN ' ' + BStreetNo WHEN BStreetNo = '' AND BUnitNumber <> '' THEN ' ' + BUnitNumber ELSE '' END +
       CASE WHEN BDistrict <> BStreet  AND BCity <> BStreet AND BCity <> BDistrict AND BDistrict <> '' AND BCity <> '' AND BStreet <> '' THEN ', ' + BCity ELSE '' END +
       CASE WHEN (BCity <> '' OR BDistrict <> '') OR (BStreet <> '' AND BZIPCode <> '') THEN + ', ' ELSE '' END +
 /* POCZTA */
       + BZIPCode + CASE WHEN BZIPCode <> '' THEN  CASE WHEN BDistrict <> '' THEN + ' ' + BDistrict ELSE + ' ' + BCity  END ELSE CASE WHEN BDistrict <> '' THEN + BDistrict ELSE + BCity END END) +
 /* WOJEWÓDZTWO */
       CASE WHEN BProvince <> '' THEN CHAR(13) + BProvince ELSE '' END +
 /* KRAJ */
       CASE WHEN BCountry <> '' THEN CHAR(13) + BCountry ELSE '' END as Tmp_AdresKOR,
    --DANE KONTAKTOWE
       CASE WHEN (Phone1 <> '' OR Phone2 <> '' OR PhoneSMS <> '') THEN
       + 'Telefon:' +
      CHAR(9) + CHAR(9) + CHAR(9) + ltrim(
      CASE WHEN Phone1 <> '' THEN + '     ' + Phone1  ELSE '' END +
      CASE WHEN Phone2 <> '' THEN + '     ' + Phone2  ELSE '' END +
      CASE WHEN PhoneSMS <> '' THEN + '     ' + PhoneSMS ELSE '' END
      )
      ELSE '' END +
 /* FAX */
      CASE WHEN FAX <> '' THEN CHAR(13) + 'FAX: ' + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + FAX ELSE '' END +
 /* EMAIL */
      CASE WHEN Email <> '' THEN CHAR(13) + 'E-mail: ' + CHAR(9) + CHAR(9) + CHAR(9) + Email ELSE '' END +
 /* URL */
      CASE WHEN URL <> '' THEN CHAR(13) + 'URL: ' + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + URL ELSE '' END +
/* SKRYTKA POCZTOWA */
      CASE WHEN POBOX <> '' THEN CHAR(13) + 'Skrytka pocztowa: ' + CHAR(9) + POBOX ELSE '' END +
/* TELEKS */
      CASE WHEN TELEX <> '' THEN CHAR(13) + 'Teleks: ' + CHAR(9) + CHAR(9) + CHAR(9) + TELEX ELSE '' END as Tmp_DaneKont
from [CDN].[DaneOsoboweHistoria](@PracownikID)
SET NOCOUNT OFF
