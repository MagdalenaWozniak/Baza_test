create function cdn.DaneOsoboweHistoria(@praid int)
returns @PersonalData table
 (
  Id int,
  CurrentFrom datetime,
  CurrentTo datetime,
  Name nvarchar(128),
  Surname nvarchar(128),
  SecondName nvarchar(128),
  TIN nvarchar(128),
  NIN nvarchar(128),
  BirthDate nvarchar(128),
  BirthPlace nvarchar(128),
  FatherName nvarchar(128),
  MotherName nvarchar(128),
  FamilyName nvarchar(128),
  FamilyMotherName nvarchar(128),
  IdentityCard nvarchar(128),
  Passport nvarchar(128),
  Citizenship nvarchar(128),
  MaritalStatus nvarchar(128),
  AAddressType nvarchar(128),
  AStreet nvarchar(128),
  AStreetNo nvarchar(128),
  AUnitNumber nvarchar(128),
  AZIPCode nvarchar(128),
  ACity nvarchar(128),
  AaState nvarchar(128),
  ACountry nvarchar(128),
  ADistrict nvarchar(128),
  ACounty nvarchar(128),
  AProvince nvarchar(128),
  BAddressType nvarchar(128),
  BStreet nvarchar(128),
  BStreetNo nvarchar(128),
  BUnitNumber nvarchar(128),
  BZIPCode nvarchar(128),
  BCity nvarchar(128),
  BaState nvarchar(128),
  BCountry nvarchar(128),
  BDistrict nvarchar(128),
  BCounty nvarchar(128),
  BProvince nvarchar(128),
  CAddressType nvarchar(128),
  CStreet nvarchar(128),
  CStreetNo nvarchar(128),
  CUnitNumber nvarchar(128),
  CZIPCode nvarchar(128),
  CCity nvarchar(128),
  CaState nvarchar(128),
  CCountry nvarchar(128),
  CDistrict nvarchar(128),
  CCounty nvarchar(128),
  CProvince nvarchar(128),
  Phone1 nvarchar(128),
  Phone2 nvarchar(128),
  PhoneSMS nvarchar(128),
  FAX nvarchar(128),
  Email nvarchar(128),
  URL nvarchar(128),
  POBOX nvarchar(128),
  TELEX nvarchar(128),
  MilitaryBookID nvarchar(128)
 )
as
begin
 declare @PreId int
 declare @PeriodFrom datetime
 declare @PeriodTo datetime
 declare @prevPreId int
 set @prevPreId = 0
 declare @CurrentFrom datetime, @CurrentTo datetime
 declare @minId int, @maxId int
 declare HISTORIA cursor local fast_forward for
  select PRE_PreId, PRE_DataOd, PRE_DataDo from cdn.PracEtaty where PRE_PraId = @praid
 open HISTORIA
   while (1=1)
   begin
    fetch next from HISTORIA into @PreId, @PeriodFrom, @PeriodTo
    if @@fetch_status <> 0
     break
    if @prevPreId = 0
    begin
     set @minId = @PreId
     set @prevPreId = @PreId
     set @CurrentFrom = @PeriodFrom
    end
    set @CurrentTo = @PeriodTo
    declare @BylaZmiana int
    set @BylaZmiana = 0
    select @BylaZmiana = cdn.BylaZmiana(@PreId, @prevPreId)
    if @BylaZmiana > 0
    begin
     set @CurrentFrom = @PeriodFrom
     insert into @PersonalData
     (
     Id, CurrentFrom, CurrentTo, Name, Surname, SecondName, TIN, NIN, BirthDate, BirthPlace, FatherName, MotherName, FamilyName, FamilyMotherName, IdentityCard, Passport, Citizenship, MaritalStatus)
      select
       @PreId,
       @CurrentFrom,
       @CurrentTo,
       rtrim(A.PRE_Imie1) as [Name],
       rtrim(A.PRE_Nazwisko) as [Surname],
       rtrim(A.PRE_Imie2) as [SecondName],
       case when isnull(A.PRE_NipE, '') = '' then null else A.PRE_NipE end as [TIN],
       case when isnull(A.PRE_Pesel, '') = '' then null else A.PRE_Pesel end as [NIN],
       rtrim(convert(nvarchar(10), A.PRE_DataUr, 111)) as [BirthDate],
       rtrim(A.PRE_MiejsceUr) as [BirthPlace],
       rtrim(A.PRE_ImieOjca) as [FatherName],
       rtrim(A.PRE_ImieMatki) as [MotherName],
       rtrim(A.PRE_NazwRodowe) as [FamilyName],
       rtrim(A.PRE_NazwRodoweM) as [FamilyMotherName],
       rtrim(A.PRE_DowOsobisty) as [IdentityCard],
       rtrim(A.PRE_Paszport) as [Passport],
       rtrim(A.PRE_Obywatelstwo) as [Citizenship],
       rtrim(A.PRE_StanCywilny) as [MaritalStatus]
      from cdn.PracEtaty A
       where A.PRE_PreId = @PreId
      update @PersonalData
       set AAddressType = 'GeneralAddress',
        AStreet = A.PRE_MLDUlica,
        AStreetNo = A.PRE_MLDNrDomu,
        AUnitNumber = A.PRE_MLDNrLokalu,
        AZIPCode = A.PRE_MLDKodPocztowy,
        ACity = A.PRE_MLDMiasto,
        AaState = A.PRE_MLDGmina,
        ACountry = A.PRE_MLDKraj,
        ADistrict = A.PRE_MLDPoczta,
        ACounty = A.PRE_MLDPowiat,
        AProvince = A.PRE_MLDWojewodztwo
       from cdn.PracEtaty A
        where A.PRE_PreId = @PreId
        and Id = @PreId
      update @PersonalData
       set BAddressType = 'CorrespondenceAddress',
        BStreet = A.PRE_KORUlica,
        BStreetNo = A.PRE_KORNrDomu,
        BUnitNumber = A.PRE_KORNrLokalu,
        BZIPCode = A.PRE_KORKodPocztowy,
        BCity = A.PRE_KORMiasto,
        BaState = A.PRE_KORGmina,
        BCountry = A.PRE_KORKraj,
        BDistrict = A.PRE_KORPoczta,
        BCounty = A.PRE_KORPowiat,
        BProvince = A.PRE_KORWojewodztwo
       from cdn.PracEtaty A
        where A.PRE_PreId = @PreId
        and Id = @PreId
      update @PersonalData
       set CAddressType = 'Address',
        CStreet = A.PRE_ZAMUlica,
        CStreetNo = A.PRE_ZAMNrDomu,
        CUnitNumber = A.PRE_ZAMNrLokalu,
        CZIPCode = A.PRE_ZAMKodPocztowy,
        CCity = A.PRE_ZAMMiasto,
        CaState = A.PRE_ZAMGmina,
        CCountry = A.PRE_ZAMKraj,
        CDistrict = A.PRE_ZAMPoczta,
        CCounty = A.PRE_ZAMPowiat,
        CProvince = A.PRE_ZAMWojewodztwo
       from cdn.PracEtaty A
        where A.PRE_PreId = @PreId
        and Id = @PreId
      update @PersonalData
       set Phone1 = A.PRE_HDKTelefon1,
        Phone2 = A.PRE_HDKTelefon2,
        PhoneSMS = A.PRE_TelefonSms,
        FAX = A.PRE_HDKFax,
        Email = A.PRE_HDKEmail,
        URL = A.PRE_HDKURL,
        POBOX = A.PRE_HDKSkrytkaPoczt,
        TELEX = A.PRE_HDKTeleks,
        MilitaryBookID = A.PRE_HDKWojNrKsiaz
       from cdn.PracEtaty A
        where A.PRE_PreId = @PreId
        and Id = @PreId
     set @maxId = @PreId
    end
    set @prevPreId = @PreId
   end
  update @PersonalData set CurrentFrom = null where Id = @minId
  update @PersonalData set CurrentTo = null where Id = @maxId
 return
end
