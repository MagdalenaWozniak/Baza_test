create function cdn.PreDaneOsoboweXML(@praid int, @optimaver varchar(20))
returns nvarchar(max)
as
begin
 declare @retval nvarchar(max)
 declare @xml xml
 declare @xml_tempmain nvarchar(max)
 select @xml_tempmain = ''
 declare @histdata_element_begin nvarchar(128)
 declare @histdata_element_end nvarchar(128)
 select @histdata_element_end = '</HistoricalData>'
 declare @PeriodFrom nvarchar(10)
 declare @PeriodTo nvarchar(10)
 declare @dtPeriodFrom datetime
 declare @dtPeriodTo datetime
 declare @xml_temp nvarchar(max)
 declare
  @PreId int,
  @CurrentFrom datetime,
  @CurrentTo datetime,
  @Name nvarchar(128),
  @Surname nvarchar(128),
  @SecondName nvarchar(128),
  @TIN nvarchar(128),
  @NIN nvarchar(128),
  @BirthDate nvarchar(128),
  @BirthPlace nvarchar(128),
  @FatherName nvarchar(128),
  @MotherName nvarchar(128),
  @FamilyName nvarchar(128),
  @FamilyMotherName nvarchar(128),
  @IdentityCard nvarchar(128),
  @Passport nvarchar(128),
  @Citizenship nvarchar(128),
  @MaritalStatus nvarchar(128),
  @AAddressType nvarchar(128),
  @AStreet nvarchar(128),
  @AStreetNo nvarchar(128),
  @AUnitNumber nvarchar(128),
  @AZIPCode nvarchar(128),
  @ACity nvarchar(128),
  @AaState nvarchar(128),
  @ACountry nvarchar(128),
  @ADistrict nvarchar(128),
  @ACounty nvarchar(128),
  @AProvince nvarchar(128),
  @BAddressType nvarchar(128),
  @BStreet nvarchar(128),
  @BStreetNo nvarchar(128),
  @BUnitNumber nvarchar(128),
  @BZIPCode nvarchar(128),
  @BCity nvarchar(128),
  @BaState nvarchar(128),
  @BCountry nvarchar(128),
  @BDistrict nvarchar(128),
  @BCounty nvarchar(128),
  @BProvince nvarchar(128),
  @CAddressType nvarchar(128),
  @CStreet nvarchar(128),
  @CStreetNo nvarchar(128),
  @CUnitNumber nvarchar(128),
  @CZIPCode nvarchar(128),
  @CCity nvarchar(128),
  @CaState nvarchar(128),
  @CCountry nvarchar(128),
  @CDistrict nvarchar(128),
  @CCounty nvarchar(128),
  @CProvince nvarchar(128),
  @Phone1 nvarchar(128),
  @Phone2 nvarchar(128),
  @PhoneSMS nvarchar(128),
  @FAX nvarchar(128),
  @Email nvarchar(128),
  @URL nvarchar(128),
  @POBOX nvarchar(128),
  @TELEX nvarchar(128),
  @MilitaryBookID nvarchar(128)
 declare HISTORIA cursor local fast_forward for
  select * from cdn.DaneOsoboweHistoria(@praid) order by Id desc
 open HISTORIA
   while (1=1)
   begin
    fetch next from HISTORIA into @PreId, @CurrentFrom, @CurrentTo, @Name, @Surname, @SecondName, @TIN, @NIN,
           @BirthDate, @BirthPlace, @FatherName, @MotherName, @FamilyName, @FamilyMotherName,
           @IdentityCard, @Passport, @Citizenship, @MaritalStatus,
           @AAddressType, @AStreet, @AStreetNo, @AUnitNumber, @AZIPCode, @ACity, @AaState, @ACountry, @ADistrict, @ACounty, @AProvince,
           @BAddressType, @BStreet, @BStreetNo, @BUnitNumber, @BZIPCode, @BCity, @BaState, @BCountry, @BDistrict, @BCounty, @BProvince,
           @CAddressType, @CStreet, @CStreetNo, @CUnitNumber, @CZIPCode, @CCity, @CaState, @CCountry, @CDistrict, @CCounty, @CProvince,
           @Phone1, @Phone2, @PhoneSMS, @FAX, @Email, @URL, @POBOX, @TELEX, @MilitaryBookID
    if @@fetch_status <> 0
     break
   if @PreId > 0
   begin
    select @dtPeriodFrom = @CurrentFrom, @dtPeriodTo = @CurrentTo, @PeriodFrom = convert(nvarchar(10), @CurrentFrom, 111), @PeriodTo = convert(nvarchar(10), @CurrentTo, 111)
    select @xml_temp = ''
     if(@dtPeriodTo is null and @dtPeriodFrom is null)
      select @histdata_element_begin = '<HistoricalData>'
     else
     begin
      if(@dtPeriodFrom is null)
       select @histdata_element_begin = '<HistoricalData CurrentTo="' + @PeriodTo + '">'
      else if(@dtPeriodTo is null)
       select @histdata_element_begin = '<HistoricalData CurrentFrom="' + @PeriodFrom + '">'
      else
       select @histdata_element_begin = '<HistoricalData CurrentFrom="' + @PeriodFrom + '" CurrentTo="' + @PeriodTo + '">'
     end
     select @xml_temp = @histdata_element_begin + isnull(
      (
       select
        @Name as [Name],
        @Surname as [Surname],
        @SecondName as [SecondName],
        @TIN as [TIN],
        @NIN as [NIN],
        @BirthDate as [BirthDate],
        @BirthPlace as [BirthPlace],
        @FatherName as [FatherName],
        @MotherName as [MotherName],
        @FamilyName as [FamilyName],
        @FamilyMotherName as [FamilyMotherName],
        @IdentityCard as [IdentityCard],
        @Passport as [Passport],
        @Citizenship as [Citizenship],
        @MaritalStatus as [MartialStatus]
       for xml path('BasicData')
      )
      , '')
     select @xml_temp = @xml_temp + '<Addresses>'
     select @xml_temp = @xml_temp + isnull(
      (select
       case when isnull(AddressType, '') = '' then null else AddressType end as [AddressType],
       case when isnull(Street, '') = '' then null else Street end as [Street],
       case when isnull(StreetNo, '') = '' then null else StreetNo end as [StreetNo],
       case when isnull(UnitNumber, '') = '' then null else UnitNumber end as [UnitNumber],
       case when isnull(ZIPCode, '') = '' then null else ZIPCode end as [ZIPCode],
       case when isnull(City, '') = '' then null else City end as [City],
       case when isnull(aState, '') = '' then null else aState end as [State],
       case when isnull(District, '') = '' then null else District end as [District],
       case when isnull(County, '') = '' then null else County end as [County],
       case when isnull(Province, '') = '' then null else Province end as [Province],
       case
        when isnull(City, '') = '' then null
        when isnull(City, '') = '' and isnull(Country, '') = '' then null else Country
       end as [Country]
       from
       (
        select
         AddressType = 'GeneralAddress',
         Street = @AStreet, StreetNo = @AStreetNo, UnitNumber = @AUnitNumber,
         ZIPCode = @AZIPCode, City = @ACity, aState = null, Country = @ACountry, District = @ADistrict, County = null,
         Province = @AProvince
        union all
        select
         AddressType = 'CorrespondenceAddress',
         Street = @BStreet, StreetNo = @BStreetNo, UnitNumber = @BUnitNumber,
         ZIPCode = @BZIPCode, City = @BCity, aState = null, Country = @BCountry, District = @BDistrict, County = null,
         Province = @BProvince
        union all
        select
         AddressType = 'Address',
         Street = @CStreet, StreetNo = @CStreetNo, UnitNumber = @CUnitNumber,
         ZIPCode = @CZIPCode, City = @CCity, aState = null, Country = @CCountry, District = @CDistrict, County = null,
         Province = @CProvince
       ) as Addresses for xml path('Address')
      ), '')
     select @xml_temp = @xml_temp + '</Addresses>'
     select @xml_temp = @xml_temp + '<ContactDetails>'
     select @xml_temp = @xml_temp + isnull(
      (select
       case when isnull(Phone1, '') = '' then null else Phone1 end as [Phone1],
       case when isnull(Phone2, '') = '' then null else Phone2 end as [Phone2],
       case when isnull(PhoneSMS, '') = '' then null else PhoneSMS end as [PhoneSMS],
       case when isnull(FAX, '') = '' then null else FAX end as [FAX],
       case when isnull(EMail, '') = '' then null else EMail end as [EMail],
       case when isnull(URL, '') = '' then null else URL end as [URL],
       case when isnull(POBOX, '') = '' then null else POBOX end as [POBOX],
       case when isnull(TELEX, '') = '' then null else TELEX end as [TELEX]
       from
       (
        select
         Phone1 = @Phone1, Phone2 = @Phone2, PhoneSMS = @PhoneSMS,
         FAX = @FAX, Email = @Email, URL = @URL, POBOX = @POBOX, TELEX = @TELEX
       ) as ContactDetails for xml path('ContactData')
      ), '')
     select @xml_temp = @xml_temp + '</ContactDetails>'
     select @xml_temp = @xml_temp + '<OtherInformations>'
     select @xml_temp = @xml_temp + isnull(
      (select
       case when isnull(MilitaryBookID, '') = '' then null else MilitaryBookID end as [MilitaryBookID]
       from
       (
        select
         MilitaryBookID = @MilitaryBookID
       ) as OtherInformations for xml path('OtherInformation')
      ), '')
     select @xml_temp = @xml_temp + '</OtherInformations>'
     select @xml_temp = @xml_temp + '<BankDetails>'
     select @xml_temp =  @xml_temp + isnull(
     (select
      A.Bank,
      A.AccountNumber
      from cdn.DaneOsoboweSchematPlatnosci(@preid) A
     for xml path('BankAccount')
     ), '')
     select @xml_temp = @xml_temp + '</BankDetails>'
     select @xml_temp = @xml_temp + @histdata_element_end
     select @xml_tempmain = @xml_tempmain + @xml_temp
    end
   end
 close HISTORIA
 deallocate HISTORIA
 select @xml_temp = '<OtherData>'
 select @xml_temp = @xml_temp + '<Education>'
 select @xml_temp = @xml_temp + isnull(
  (select
   case when isnull(Name, '') = '' then null else Name end as [Name],
   case when isnull(Profession, '') = '' then null else Profession end as [Profession],
   case when isnull(Speciality, '') = '' then null else Speciality end as [Speciality],
   case when isnull(Degree, '') = '' then null else Degree end as [Degree],
   case when isnull(Title, '') = '' then null else Title end as [Title]
   from
   (
    select
     Name = A.Name,
     Profession = A.Profession,
     Speciality = A.Speciality,
     Degree = A.Degree,
     Title = A.Title
    from cdn.DaneOsoboweHistoriaWyksztalcenia(@praid) A
   ) as Education for xml path('Institution')
  ), '')
 select @xml_temp = @xml_temp + '</Education>'
 select @xml_temp = @xml_temp + '<Qualifications>'
 select @xml_temp = @xml_temp + isnull(
  (select
   case when isnull(Name, '') = '' then null else Name end as [Name],
   case when isnull(ValidTo, '') = '' then null else ValidTo end as [ValidTo]
   from
   (
    select
     Name = A.Name,
     ValidTo = A.ValidTo
    from cdn.DaneOsoboweUprawnienia(@praid) A
   ) as Qualification for xml path('Skill')
  ), '')
 select @xml_temp = @xml_temp + isnull(
  (select
   case when isnull(Name, '') = '' then null else Name end as [Name],
   case when isnull(KnownledgeInSpeech, '') = '' then null else KnownledgeInSpeech end as [KnownledgeInSpeech],
   case when isnull(KnownledgeInWriting, '') = '' then null else KnownledgeInWriting end as [KnownledgeInWriting]
   from
   (
    select
     Name = A.Name,
     KnownledgeInSpeech = A.KnownledgeInSpeech,
     KnownledgeInWriting = A.KnownledgeInWriting
    from cdn.DaneOsoboweJezykiObce(@praid) A
   ) as Lang for xml path('Language')
  ), '')
 select @xml_temp = @xml_temp + '</Qualifications>'
 select @xml_temp = @xml_temp + '<Diseases>'
 select @xml_temp = @xml_temp + isnull(
  (select
   case when isnull(Name, '') = '' then null else Name end as [Name],
   case when isnull(DateFrom, '') = '' then null else DateFrom end as [DateFrom],
   case when isnull(DateTo, '') = '' then null else DateTo end as [DateTo]
   from
   (
    select
     Name = A.Name,
     DateFrom = A.DateFrom,
     DateTo = A.DateTo
    from cdn.DaneOsoboweSchorzenia(@praid) A
   ) as Lang for xml path('Disease')
  ), '')
 select @xml_temp = @xml_temp + '</Diseases>'
 select @xml_temp = @xml_temp + '<EmploymentHistory>'
 select @xml_temp = @xml_temp + isnull(
  (select
   case when isnull(Name, '') = '' then null else Name end as [Name],
   case when isnull(DateFrom, '') = '' then null else DateFrom end as [DateFrom],
   case when isnull(DateTo, '') = '' then null else DateTo end as [DateTo]
   from
   (
    select
     Name = A.Name,
     DateFrom = A.DateFrom,
     DateTo = A.DateTo
    from cdn.DaneOsoboweHistoriaZatrudnienia(@praid) A
   ) as Lang for xml path('Workplace')
  ), '')
 select @xml_temp = @xml_temp + '</EmploymentHistory>'
 select @xml_temp = @xml_temp + '</OtherData>'
 select @xml_tempmain = @xml_tempmain + @xml_temp
 select @xml = convert(xml, @xml_tempmain)
 select @retval = '<?xml version="1.0"?> <PersonalData xmlns="http://tempuri.org/xmlschema.xsd" xmlns:xsd="http://www.w3.org/2001/xmlschema" xmlns:xsi="http://www.w3.org/2001/xmlschema-instance" CurrentDate="' + convert(varchar(40), getdate(), 126) + '" version="Comarch ERP Optima ' + @optimaver + '" OwnerType="Employee">' + convert(nvarchar(max), @xml)
 select @retval = @retval + '</PersonalData>';
 return @retval
end
