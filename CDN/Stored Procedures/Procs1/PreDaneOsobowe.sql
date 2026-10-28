CREATE procedure CDN.PreDaneOsobowe @PracownikID int = 0
as
begin
 declare @PreId int
 declare @PeriodFrom nvarchar(10)
 declare @PeriodTo nvarchar(10)
 declare @DataOd datetime
 declare @DataDo datetime
 declare @prevDataOd datetime
 declare @prevPreId int
 declare @PopPreId int
 set @prevPreId = 0
 set @PopPreId = 0
 declare @Rec int
 set @Rec = 0
 declare @poprzkonto nvarchar(max)
 declare @konto nvarchar(max)
 SET  @prevDataOd =  convert(datetime, '1900-01-01', 120)
--Tworze tabele tymczasowa, ktora zwracac bedzie zmienione zapisy historyczne pracownika
declare @HisPracy TABLE (
       Tmp_PreId int,
    Tmp_DataOd datetime,
    Tmp_DataDo datetime,
       Tmp_Imie1  nvarchar(30),
       Tmp_Nazwisko  nvarchar(40),
       Tmp_Imie2 nvarchar(30),
       Tmp_NipE varchar(13),
       Tmp_Pesel nvarchar(11),
       Tmp_DataUr datetime,
       Tmp_MiejsceUr nvarchar(40),
       Tmp_ImieOjca nvarchar(30),
       Tmp_ImieMatki nvarchar(30),
       Tmp_NazwRodowe nvarchar(40),
       Tmp_NazwRodoweM nvarchar(40),
       Tmp_DowOsobisty nvarchar(12),
       Tmp_Paszport nvarchar(9),
       Tmp_Obywatelstwo nvarchar(30),
       Tmp_StanCywilny nvarchar(30),
    Tmp_MLDUlica nvarchar(40),
       Tmp_MLDNrDomu nvarchar(10),
       Tmp_MLDNrLokalu nvarchar(10),
       Tmp_MLDKodPocztowy varchar(10),
       Tmp_MLDMiasto nvarchar(40),
       Tmp_MLDGmina nvarchar(40),
       Tmp_MLDKraj nvarchar(40),
       Tmp_MLDPoczta nvarchar(40),
       Tmp_MLDPowiat nvarchar(40),
    Tmp_MLDWojewodztwo nvarchar(40),
    Tmp_KORUlica nvarchar(40),
       Tmp_KORNrDomu nvarchar(10),
       Tmp_KORNrLokalu nvarchar(10),
       Tmp_KORKodPocztowy varchar(10),
       Tmp_KORMiasto nvarchar(40),
       Tmp_KORGmina nvarchar(40),
       Tmp_KORKraj nvarchar(40),
       Tmp_KORPoczta nvarchar(40),
       Tmp_KORPowiat nvarchar(40),
    Tmp_KORWojewodztwo nvarchar(40),
    Tmp_ZAMUlica nvarchar(40),
       Tmp_ZAMNrDomu nvarchar(10),
       Tmp_ZAMNrLokalu nvarchar(10),
       Tmp_ZAMKodPocztowy varchar(10),
       Tmp_ZAMMiasto nvarchar(40),
       Tmp_ZAMGmina nvarchar(40),
       Tmp_ZAMKraj nvarchar(40),
       Tmp_ZAMPoczta nvarchar(40),
       Tmp_ZAMPowiat nvarchar(40),
    Tmp_ZAMWojewodztwo nvarchar(40),
    Tmp_HDKTelefon1 varchar(20),
    Tmp_HDKTelefon2 varchar(20),
    Tmp_TelefonSms varchar(20),
    Tmp_HDKFax varchar(20),
    Tmp_HDKEmail nvarchar(127),
    Tmp_HDKURL varchar(255),
    Tmp_AdresMLD varchar(255),
    Tmp_AdresZAM varchar(255),
    Tmp_AdresKOR varchar(255),
    Tmp_DaneKont varchar(255),
    Tmp_SkrytkaP nvarchar(20),
    Tmp_Teleks nvarchar(20),
    Tmp_KsiazeczkaW nvarchar(20)
 )
 declare HISTORIA cursor local fast_forward for
  select PRE_PreId, PRE_DataOd, PRE_DataDo from cdn.PracEtaty where PRE_PraId = @PracownikID order by PRE_DataOd
 open HISTORIA
   while (1=1)
    begin
     fetch next from HISTORIA into @PreId, @DataOd, @DataDo
     if @@fetch_status <> 0
      break
     if @prevPreId = 0
     begin
      set @prevPreId = @PreId
   set @prevDataOd = @DataOd
  end
     Set @poprzkonto = ''
     select @poprzkonto = @poprzkonto +coalesce(SPL_RachunekNr+' ',SPL_RachunekNr+' ') from cdn.schematplatnosci where SPL_PodmiotTyp = 3 and spl_podmiotid = @prevPreId
  Set @konto = ''
     select @konto = @konto +coalesce(SPL_RachunekNr+' ',SPL_RachunekNr+' ') from cdn.schematplatnosci where  SPL_PodmiotTyp = 3 and spl_podmiotid = @PreId
     set @Rec =  (select count(*)
     --from cdn.PracEtaty A join cdn.PracEtaty B on B.PRE_PreId = @prevPreId
     from cdn.PracEtaty A join cdn.PracEtaty B on B.PRE_DataOd = @prevDataOd and B.PRE_Praid = A.PRE_Praid and B.PRE_Praid = @PracownikID
   where
        (A.PRE_DataOd = @DataOd and A.PRE_DataOd = @prevDataOd)
        or
        (A.PRE_DataOd = @DataOd and A.PRE_DataOd > @prevDataOd
  and
        (
        A.PRE_Imie1 <> B.PRE_Imie1
        or A.PRE_Nazwisko <> B.PRE_Nazwisko
        or A.PRE_Imie2 <> B.PRE_Imie2
        or A.PRE_NipE <> B.PRE_NipE
        or A.PRE_Pesel <> B.PRE_Pesel
        or A.PRE_DataUr <> B.PRE_DataUr
        or A.PRE_MiejsceUr <> B.PRE_MiejsceUr
        or A.PRE_ImieOjca <> B.PRE_ImieOjca
        or A.PRE_ImieMatki <> B.PRE_ImieMatki
        or A.PRE_NazwRodowe <> B.PRE_NazwRodowe
        or A.PRE_NazwRodoweM <> B.PRE_NazwRodoweM
        or A.PRE_DowOsobisty <> B.PRE_DowOsobisty
        or A.PRE_Paszport <> B.PRE_Paszport
        or A.PRE_Obywatelstwo <> B.PRE_Obywatelstwo
        or A.PRE_StanCywilny <> B.PRE_StanCywilny
  or A.PRE_MLDUlica <> B.PRE_MLDUlica
        or A.PRE_MLDNrDomu <> B.PRE_MLDNrDomu
        or A.PRE_MLDNrLokalu <> B.PRE_MLDNrLokalu
        or A.PRE_MLDKodPocztowy <> B.PRE_MLDKodPocztowy
        or A.PRE_MLDMiasto <> B.PRE_MLDMiasto
  or A.PRE_MLDGmina <> B.PRE_MLDGmina
        or A.PRE_MLDKraj <> B.PRE_MLDKraj
        or A.PRE_MLDPoczta <> B.PRE_MLDPoczta
  or A.PRE_MLDPowiat <> B.PRE_MLDPowiat
  or A.PRE_MLDWojewodztwo <> B.PRE_MLDWojewodztwo
  or A.PRE_KORUlica <> B.PRE_KORUlica
        or A.PRE_KORNrDomu <> B.PRE_KORNrDomu
        or A.PRE_KORNrLokalu <> B.PRE_KORNrLokalu
        or A.PRE_KORKodPocztowy <> B.PRE_KORKodPocztowy
        or A.PRE_KORMiasto <> B.PRE_KORMiasto
  or A.PRE_KORGmina <> B.PRE_KORGmina
        or A.PRE_KORKraj <> B.PRE_KORKraj
        or A.PRE_KORPoczta <> B.PRE_KORPoczta
  or A.PRE_KORPowiat <> B.PRE_KORPowiat
  or A.PRE_KORWojewodztwo <> B.PRE_KORWojewodztwo
  or A.PRE_ZAMUlica <> B.PRE_ZAMUlica
        or A.PRE_ZAMNrDomu <> B.PRE_ZAMNrDomu
        or A.PRE_ZAMNrLokalu <> B.PRE_ZAMNrLokalu
        or A.PRE_ZAMKodPocztowy <> B.PRE_ZAMKodPocztowy
        or A.PRE_ZAMMiasto <> B.PRE_ZAMMiasto
  or A.PRE_ZAMGmina <> B.PRE_ZAMGmina
        or A.PRE_ZAMKraj <> B.PRE_ZAMKraj
        or A.PRE_ZAMPoczta <> B.PRE_ZAMPoczta
  or A.PRE_ZAMPowiat <> B.PRE_ZAMPowiat
  or A.PRE_ZAMWojewodztwo <> B.PRE_ZAMWojewodztwo
  or A.PRE_HDKTelefon1 <> B.PRE_HDKTelefon1
  or A.PRE_HDKTelefon2 <> B.PRE_HDKTelefon2
  or A.PRE_TelefonSms <> B.PRE_TelefonSms
  or A.PRE_HDKFax <> B.PRE_HDKFax
  or A.PRE_HDKEmail <> B.PRE_HDKEmail
  or A.PRE_HDKURL <> B.PRE_HDKURL
  or A.PRE_HDKSkrytkaPoczt <> B.PRE_HDKSkrytkaPoczt
  or A.PRE_HDKTeleks <> B.PRE_HDKTeleks
  or A.PRE_HDKWojNrKsiaz <> B.PRE_HDKWojNrKsiaz
  or (select @poprzkonto) <> (select @konto)
  )
       )
   )
    if  @Rec > 0
    begin
    set @PopPreId =  @PreId
     INSERT INTO @HisPracy
      select
    @PreId,
    @DataOd,
    @DataDo,
    rtrim(A.PRE_Imie1),
       rtrim(A.PRE_Nazwisko),
       rtrim(A.PRE_Imie2),
       A.PRE_NipE,
       A.PRE_Pesel,
       A.PRE_DataUr,
       rtrim(A.PRE_MiejsceUr),
       rtrim(A.PRE_ImieOjca) ,
       rtrim(A.PRE_ImieMatki),
       rtrim(A.PRE_NazwRodowe),
       rtrim(A.PRE_NazwRodoweM),
       rtrim(A.PRE_DowOsobisty),
       rtrim(A.PRE_Paszport),
       rtrim(A.PRE_Obywatelstwo),
       rtrim(A.PRE_StanCywilny),
    A.PRE_MLDUlica,
       A.PRE_MLDNrDomu,
       A.PRE_MLDNrLokalu,
       A.PRE_MLDKodPocztowy,
       A.PRE_MLDMiasto,
       A.PRE_MLDGmina,
       A.PRE_MLDKraj,
       A.PRE_MLDPoczta,
       A.PRE_MLDPowiat,
    A.PRE_MLDWojewodztwo,
    A.PRE_KORUlica,
       A.PRE_KORNrDomu,
       A.PRE_KORNrLokalu,
       A.PRE_KORKodPocztowy,
       A.PRE_KORMiasto,
       A.PRE_KORGmina,
       A.PRE_KORKraj,
       A.PRE_KORPoczta,
       A.PRE_KORPowiat,
    A.PRE_KORWojewodztwo,
    A.PRE_ZAMUlica,
       A.PRE_ZAMNrDomu,
       A.PRE_ZAMNrLokalu,
       A.PRE_ZAMKodPocztowy,
       A.PRE_ZAMMiasto,
       A.PRE_ZAMGmina,
       A.PRE_ZAMKraj,
       A.PRE_ZAMPoczta,
       A.PRE_ZAMPowiat,
    A.PRE_ZAMWojewodztwo,
    A.PRE_HDKTelefon1,
    A.PRE_HDKTelefon2,
    A.PRE_TelefonSms,
    A.PRE_HDKFax,
    A.PRE_HDKEmail,
    A.PRE_HDKURL,
/* Adres zameldowania*/
       LTRIM(CASE WHEN A.PRE_MLDUlica <> '' THEN A.PRE_MLDUlica WHEN A.PRE_MLDUlica='' AND A.PRE_MLDMiasto <>'' THEN A.PRE_MLDMiasto ELSE A.PRE_MLDPoczta END +
       CASE WHEN A.PRE_MLDNrDomu <> '' AND A.PRE_MLDNrLokalu <> '' THEN ' ' + A.PRE_MLDNrDomu + '/' + A.PRE_MLDNrLokalu WHEN A.PRE_MLDNrDomu <> '' AND A.PRE_MLDNrLokalu = '' THEN ' ' + A.PRE_MLDNrDomu WHEN A.PRE_MLDNrDomu = '' AND A.PRE_MLDNrLokalu <> '' THEN ' ' + A.PRE_MLDNrLokalu ELSE '' END +
       CASE WHEN A.PRE_MLDPoczta <> A.PRE_MLDUlica  AND A.PRE_MLDMiasto <> A.PRE_MLDUlica AND A.PRE_MLDMiasto <> A.PRE_MLDPoczta AND A.PRE_MLDPoczta <> '' AND A.PRE_MLDMiasto <> '' AND A.PRE_MLDUlica <> '' THEN ', ' + A.PRE_MLDMiasto ELSE '' END +
       CASE WHEN (A.PRE_MLDMiasto <> '' OR A.PRE_MLDPoczta <> '') OR (A.PRE_MLDUlica <> '' AND A.PRE_MLDKodPocztowy <> '') THEN + ', ' ELSE '' END +
 /* POCZTA */
       + A.PRE_MLDKodPocztowy + CASE WHEN A.PRE_MLDKodPocztowy <> '' THEN  CASE WHEN A.PRE_MLDPoczta <> '' THEN + ' ' + A.PRE_MLDPoczta ELSE + ' ' + A.PRE_MLDMiasto  END ELSE CASE WHEN A.PRE_MLDPoczta <> '' THEN + A.PRE_MLDPoczta ELSE + A.PRE_MLDMiasto END END) +
 /* WOJEWÓDZTWO */
       CASE WHEN A.PRE_MLDWojewodztwo <> '' THEN CHAR(13) + A.PRE_MLDWojewodztwo ELSE '' END +
 /* KRAJ */
       CASE WHEN A.PRE_MLDKraj <> '' THEN CHAR(13) + A.PRE_MLDKraj ELSE '' END,
/* Adres zamieszkania*/
       LTRIM(CASE WHEN A.PRE_ZAMUlica <> '' THEN A.PRE_ZAMUlica WHEN A.PRE_ZAMUlica='' AND A.PRE_ZAMMiasto <>'' THEN A.PRE_ZAMMiasto ELSE A.PRE_ZAMPoczta END +
       CASE WHEN A.PRE_ZAMNrDomu <> '' AND A.PRE_ZAMNrLokalu <> '' THEN ' ' + A.PRE_ZAMNrDomu + '/' + A.PRE_ZAMNrLokalu WHEN A.PRE_ZAMNrDomu <> '' AND A.PRE_ZAMNrLokalu = '' THEN ' ' + A.PRE_ZAMNrDomu WHEN A.PRE_ZAMNrDomu = '' AND A.PRE_ZAMNrLokalu <> '' THEN ' ' + A.PRE_ZAMNrLokalu ELSE '' END +
       CASE WHEN A.PRE_ZAMPoczta <> A.PRE_ZAMUlica  AND A.PRE_ZAMMiasto <> A.PRE_ZAMUlica AND A.PRE_ZAMMiasto <> A.PRE_ZAMPoczta AND A.PRE_ZAMPoczta <> '' AND A.PRE_ZAMMiasto <> '' AND A.PRE_ZAMUlica <> '' THEN ', ' + A.PRE_ZAMMiasto ELSE '' END +
       CASE WHEN (A.PRE_ZAMMiasto <> '' OR A.PRE_ZAMPoczta <> '') OR (A.PRE_ZAMUlica <> '' AND A.PRE_ZAMKodPocztowy <> '') THEN + ', ' ELSE '' END +
 /* POCZTA */
       + A.PRE_ZAMKodPocztowy + CASE WHEN A.PRE_ZAMKodPocztowy <> '' THEN  CASE WHEN A.PRE_ZAMPoczta <> '' THEN + ' ' + A.PRE_ZAMPoczta ELSE + ' ' + A.PRE_ZAMMiasto  END ELSE CASE WHEN A.PRE_ZAMPoczta <> '' THEN + A.PRE_ZAMPoczta ELSE + A.PRE_ZAMMiasto END END) +
 /* WOJEWÓDZTWO */
       CASE WHEN A.PRE_ZAMWojewodztwo <> '' THEN CHAR(13) + A.PRE_ZAMWojewodztwo ELSE '' END +
 /* KRAJ */
       CASE WHEN A.PRE_ZAMKraj <> '' THEN CHAR(13) + A.PRE_ZAMKraj ELSE '' END,
/* Adres korespondencyjny*/
       LTRIM(CASE WHEN A.PRE_KORUlica <> '' THEN A.PRE_KORUlica WHEN A.PRE_KORUlica='' AND A.PRE_KORMiasto <>'' THEN A.PRE_KORMiasto ELSE A.PRE_KORPoczta END +
       CASE WHEN A.PRE_KORNrDomu <> '' AND A.PRE_KORNrLokalu <> '' THEN ' ' + A.PRE_KORNrDomu + '/' + A.PRE_KORNrLokalu WHEN A.PRE_KORNrDomu <> '' AND A.PRE_KORNrLokalu = '' THEN ' ' + A.PRE_KORNrDomu WHEN A.PRE_KORNrDomu = '' AND A.PRE_KORNrLokalu <> '' THEN ' ' + A.PRE_KORNrLokalu ELSE '' END +
       CASE WHEN A.PRE_KORPoczta <> A.PRE_KORUlica  AND A.PRE_KORMiasto <> A.PRE_KORUlica AND A.PRE_KORMiasto <> A.PRE_KORPoczta AND A.PRE_KORPoczta <> '' AND A.PRE_KORMiasto <> '' AND A.PRE_KORUlica <> '' THEN ', ' + A.PRE_KORMiasto ELSE '' END +
       CASE WHEN (A.PRE_KORMiasto <> '' OR A.PRE_KORPoczta <> '') OR (A.PRE_KORUlica <> '' AND A.PRE_KORKodPocztowy <> '') THEN + ', ' ELSE '' END +
 /* POCZTA */
       + A.PRE_KORKodPocztowy + CASE WHEN A.PRE_KORKodPocztowy <> '' THEN  CASE WHEN A.PRE_KORPoczta <> '' THEN + ' ' + A.PRE_KORPoczta ELSE + ' ' + A.PRE_KORMiasto  END ELSE CASE WHEN A.PRE_KORPoczta <> '' THEN + A.PRE_KORPoczta ELSE + A.PRE_KORMiasto END END) +
 /* WOJEWÓDZTWO */
       CASE WHEN A.PRE_KORWojewodztwo <> '' THEN CHAR(13) + A.PRE_KORWojewodztwo ELSE '' END +
 /* KRAJ */
       CASE WHEN A.PRE_KORKraj <> '' THEN CHAR(13) + A.PRE_KORKraj ELSE '' END,
    --DANE KONTAKTOWE
       CASE WHEN (A.PRE_HDKTelefon1 <> '' OR A.PRE_HDKTelefon2 <> '' OR A.PRE_TelefonSms <> '') THEN
       + 'Telefon:' +
      CHAR(9) + CHAR(9) + CHAR(9) + ltrim(
      CASE WHEN A.PRE_HDKTelefon1 <> '' THEN + '     ' + A.PRE_HDKTelefon1  ELSE '' END +
      CASE WHEN A.PRE_HDKTelefon2 <> '' THEN + '     ' + A.PRE_HDKTelefon2  ELSE '' END +
      CASE WHEN A.PRE_TelefonSms <> '' THEN + '     ' + A.PRE_TelefonSms ELSE '' END
      )
      ELSE '' END +
 /* FAX */
      CASE WHEN A.PRE_HDKFax <> '' THEN CHAR(13) + 'FAX: ' + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + A.PRE_HDKFax ELSE '' END +
 /* EMAIL */
      CASE WHEN A.PRE_HDKEmail <> '' THEN CHAR(13) + 'E-mail: ' + CHAR(9) + CHAR(9) + CHAR(9) + A.PRE_HDKEmail ELSE '' END +
 /* URL */
      CASE WHEN A.PRE_HDKURL <> '' THEN CHAR(13) + 'URL: ' + CHAR(9) + CHAR(9) + CHAR(9) + CHAR(9) + A.PRE_HDKURL ELSE '' END +
/* SKRYTKA POCZTOWA */
      CASE WHEN A.PRE_HDKSkrytkaPoczt <> '' THEN CHAR(13) + 'Skrytka pocztowa: ' + CHAR(9) + A.PRE_HDKSkrytkaPoczt ELSE '' END +
/* TELEKS */
      CASE WHEN A.PRE_HDKTeleks <> '' THEN CHAR(13) + 'Teleks: ' + CHAR(9) + CHAR(9) + CHAR(9) + A.PRE_HDKTeleks ELSE '' END,
     A.PRE_HDKSkrytkaPoczt,
   A.PRE_HDKTeleks,
   A.PRE_HDKWojNrKsiaz
   --from cdn.PracEtaty A join cdn.PracEtaty B on B.PRE_PreId = @prevPreId
   from cdn.PracEtaty A join cdn.PracEtaty B on B.PRE_DataOd = @prevDataOd and B.PRE_Praid = A.PRE_Praid and B.PRE_Praid = @PracownikID
      where
        (A.PRE_DataOd = @DataOd and A.PRE_DataOd = @prevDataOd)
        or
        (A.PRE_DataOd = @DataOd and A.PRE_DataOd > @prevDataOd
        and
        (
        A.PRE_Imie1 <> B.PRE_Imie1
        or A.PRE_Nazwisko <> B.PRE_Nazwisko
        or A.PRE_Imie2 <> B.PRE_Imie2
        or A.PRE_NipE <> B.PRE_NipE
        or A.PRE_Pesel <> B.PRE_Pesel
        or A.PRE_DataUr <> B.PRE_DataUr
        or A.PRE_MiejsceUr <> B.PRE_MiejsceUr
        or A.PRE_ImieOjca <> B.PRE_ImieOjca
        or A.PRE_ImieMatki <> B.PRE_ImieMatki
        or A.PRE_NazwRodowe <> B.PRE_NazwRodowe
        or A.PRE_NazwRodoweM <> B.PRE_NazwRodoweM
        or A.PRE_DowOsobisty <> B.PRE_DowOsobisty
        or A.PRE_Paszport <> B.PRE_Paszport
        or A.PRE_Obywatelstwo <> B.PRE_Obywatelstwo
        or A.PRE_StanCywilny <> B.PRE_StanCywilny
  or A.PRE_MLDUlica <> B.PRE_MLDUlica
        or A.PRE_MLDNrDomu <> B.PRE_MLDNrDomu
        or A.PRE_MLDNrLokalu <> B.PRE_MLDNrLokalu
        or A.PRE_MLDKodPocztowy <> B.PRE_MLDKodPocztowy
        or A.PRE_MLDMiasto <> B.PRE_MLDMiasto
  or A.PRE_MLDGmina <> B.PRE_MLDGmina
        or A.PRE_MLDKraj <> B.PRE_MLDKraj
        or A.PRE_MLDPoczta <> B.PRE_MLDPoczta
  or A.PRE_MLDPowiat <> B.PRE_MLDPowiat
  or A.PRE_MLDWojewodztwo <> B.PRE_MLDWojewodztwo
  or A.PRE_KORUlica <> B.PRE_KORUlica
        or A.PRE_KORNrDomu <> B.PRE_KORNrDomu
        or A.PRE_KORNrLokalu <> B.PRE_KORNrLokalu
        or A.PRE_KORKodPocztowy <> B.PRE_KORKodPocztowy
        or A.PRE_KORMiasto <> B.PRE_KORMiasto
  or A.PRE_KORGmina <> B.PRE_KORGmina
        or A.PRE_KORKraj <> B.PRE_KORKraj
        or A.PRE_KORPoczta <> B.PRE_KORPoczta
  or A.PRE_KORPowiat <> B.PRE_KORPowiat
  or A.PRE_KORWojewodztwo <> B.PRE_KORWojewodztwo
  or A.PRE_ZAMUlica <> B.PRE_ZAMUlica
        or A.PRE_ZAMNrDomu <> B.PRE_ZAMNrDomu
        or A.PRE_ZAMNrLokalu <> B.PRE_ZAMNrLokalu
        or A.PRE_ZAMKodPocztowy <> B.PRE_ZAMKodPocztowy
        or A.PRE_ZAMMiasto <> B.PRE_ZAMMiasto
  or A.PRE_ZAMGmina <> B.PRE_ZAMGmina
        or A.PRE_ZAMKraj <> B.PRE_ZAMKraj
        or A.PRE_ZAMPoczta <> B.PRE_ZAMPoczta
  or A.PRE_ZAMPowiat <> B.PRE_ZAMPowiat
  or A.PRE_ZAMWojewodztwo <> B.PRE_ZAMWojewodztwo
  or A.PRE_HDKTelefon1 <> B.PRE_HDKTelefon1
  or A.PRE_HDKTelefon2 <> B.PRE_HDKTelefon2
  or A.PRE_TelefonSms <> B.PRE_TelefonSms
  or A.PRE_HDKFax <> B.PRE_HDKFax
  or A.PRE_HDKEmail <> B.PRE_HDKEmail
  or A.PRE_HDKURL <> B.PRE_HDKURL
  or A.PRE_HDKSkrytkaPoczt <> B.PRE_HDKSkrytkaPoczt
  or A.PRE_HDKTeleks <> B.PRE_HDKTeleks
  or A.PRE_HDKWojNrKsiaz <> B.PRE_HDKWojNrKsiaz
        or (select @poprzkonto) <> (select @konto)
  )
       )
  end
  else
  begin
       update @HisPracy set Tmp_DataDo = @DataDo where Tmp_PreId = @PopPreId
  end
  /*
      select
        case when isnull(rtrim(bna_nazwa1 + ' ' + bna_nazwa2), '') = '' then null else bna_nazwa1 + ' ' + bna_nazwa2 end as [@bank],
        case when isnull(spl_rachuneknr, '') = '' then null else spl_rachuneknr end as [@accountnumber]
        from cdn.schematplatnosci join cdn.bnknazwy on bna_bnaid = spl_bnaid where spl_podmiottyp = 3 and spl_podmiotid = @PreId
    */
     set @prevPreId = @PreId
  set @prevDataOd = @DataOd
    end
 close HISTORIA
 deallocate HISTORIA
end
select * from @HisPracy
