CREATE FUNCTION CDN.RozliczeniaR2R()
RETURNS @Result TABLE(
ID int IDENTITY(1,1),
LBRKId int,
LDokKbId int,
LDokKbTyp int,
LDokKhTyp int,
LDokKhId int,
LDokKbNumerPelny nvarchar(50),
LKRo_Status nvarchar(50),
LKRo_Dokument nvarchar(256),
LKRo_DataDokumentu datetime,
LKRo_TerminPlatnosci datetime,
LKRo_DataRozliczenia datetime,
LKRo_DataRoz datetime,
LKRo_KwotaDok decimal(15,2),
LKRo_Kwota decimal(15,2),
LKRo_SumRozliczen decimal(15,2),
LKRo_Bufor tinyint,
LKRo_Storno tinyint,
LKRo_KwotaDokWal decimal(15,2),
LKRo_KwotaWal decimal(15,2),
LKRo_SumRozliczenWal decimal(15,2),
LKRo_Waluta nvarchar(3),
LKRo_IdentKsieg nvarchar(50),
LKRo_Konto nvarchar(50),
LKRo_KontoPrzeciw nvarchar(50),
LKRo_NrDziennika nvarchar(50),
LKRo_Dziennik nvarchar(50),
PBRKId int,
PDokKbId int,
PDokKbTyp int,
PDokKhTyp int,
PDokKhId int,
PDokKbNumerPelny nvarchar(50),
PKRo_Status nvarchar(50),
PKRo_Dokument nvarchar(256),
PKRo_DataDokumentu datetime,
PKRo_TerminPlatnosci datetime,
PKRo_DataRozliczenia datetime,
PKRo_DataRoz datetime,
PKRo_KwotaDok decimal(15,2),
PKRo_Kwota decimal(15,2),
PKRo_SumRozliczen decimal(15,2),
PKRo_Bufor tinyint,
PKRo_Storno tinyint,
PKRo_KwotaDokWal decimal(15,2),
PKRo_KwotaWal decimal(15,2),
PKRo_SumRozliczenWal decimal(15,2),
PKRo_Waluta nvarchar(3),
PKRo_IdentKsieg nvarchar(50),
PKRo_Konto nvarchar(50),
PKRo_KontoPrzeciw nvarchar(50),
PKRo_NrDziennika nvarchar(50),
PKRo_Dziennik nvarchar(50)
)
AS
BEGIN
 insert into @result (
 LBRKId, LDokKbId, LDokKbTyp, LDokKhTyp, LDokKhId, LDokKbNumerPelny,
 LKRo_Status,
 LKRo_Dokument,
 LKRo_DataDokumentu,
 LKRo_TerminPlatnosci,
 LKRo_DataRozliczenia,
 LKRo_DataRoz,
 LKRo_KwotaDok,
 LKRo_Kwota,
 LKRo_SumRozliczen,
 LKRo_Bufor,
 LKRo_Storno,
 LKRo_KwotaDokWal,
 LKRo_KwotaWal,
 LKRo_SumRozliczenWal,
 LKRo_Waluta,
 LKRo_IdentKsieg,
 LKRo_Konto,
 LKRo_KontoPrzeciw,
 LKRo_NrDziennika,
 LKRo_Dziennik,
 PBRKId, PDokKbId, PDokKbTyp, PDokKhTyp, PDokKhId, PDokKbNumerPelny,
 PKRo_Status,
 PKRo_Dokument,
 PKRo_DataDokumentu,
 PKRo_TerminPlatnosci,
 PKRo_DataRozliczenia,
 PKRo_DataRoz,
 PKRo_KwotaDok,
 PKRo_Kwota,
 PKRo_SumRozliczen,
 PKRo_Bufor,
 PKRo_Storno,
 PKRo_KwotaDokWal,
 PKRo_KwotaWal,
 PKRo_SumRozliczenWal,
 PKRo_Waluta,
 PKRo_IdentKsieg,
 PKRo_Konto,
 PKRo_KontoPrzeciw,
 PKRo_NrDziennika,
 PKRo_Dziennik)
 select  * from (
 select DISTINCT
 dokumenty.KRo_BRKId as LBRKId,
 case when LZdarzeniaDES.BZd_BZdID is not null then LZdarzeniaDES.BZd_BZdID
 else case when LZdarzeniaBO.BZd_BZdID is not null then LZdarzeniaBO.BZd_BZdID
 else case when LZdarzeniaDE.BZd_BZdID is not null then LZdarzeniaDE.BZd_BZdID
 else case when LZapisyDE.BZp_BZpID is not null then LZapisyDE.BZp_BZpID end end end end as LDokKbId,
 case when LZdarzeniaDES.BZd_BZdID is not null then 1
 else case when LZdarzeniaBO.BZd_BZdID is not null then 1
 else case when LZdarzeniaDE.BZd_BZdID is not null then 1
 else case when LZapisyDE.BZp_BZpID is not null then 2 end end end end as LDokKbTyp,
 dokumenty.KRo_Typ as LDokKhTyp,
 case when dokumenty.KRo_Typ = 1 then dokumenty.KRo_DeEID else dokumenty.KRo_BoEID end LDokKhId,
    case when LZdarzeniaDES.BZd_BZdID is not null then LZdarzeniaDES.BZd_NumerPelny
            else case when LZdarzeniaBO.BZd_BZdID is not null then LZdarzeniaBO.BZd_NumerPelny
            else case when LZdarzeniaDE.BZd_BZdID is not null then LZdarzeniaDE.BZd_NumerPelny
            else case when LZapisyDE.BZp_BZpID is not null then LZapisyDE.BZp_NumerPelny end end end end as LDokKbNumerPelny,
 case when dokumenty.KRo_SumRozliczen = dokumenty.KRo_KwotaDok then 'Rozrachowany całkowicie'
      when dokumenty.KRo_SumRozliczen <> 0 and dokumenty.KRo_SumRozliczen < dokumenty.KRo_KwotaDok then 'Rozrachowany częściowo'
   else 'Nierozrachowany' end as LKRo_Status,
 dokumenty.KRo_Dokument as LKRo_Dokument,
 dokumenty.KRo_DataDokumentu as LKRo_DataDokumentu,
 dokumenty.KRo_TerminPlatnosci as LKRo_TerminPlatnosci,
 dokumenty.KRo_DataRozliczenia as LKRo_DataRozliczenia,
 dokumenty.KRo_DataRoz as LKRo_DataRoz,
 dokumenty.KRo_KwotaDok as LKRo_KwotaDok,
 dokumenty.KRo_Kwota as LKRo_Kwota,
 dokumenty.KRo_SumRozliczen as LKRo_SumRozliczen,
 dokumenty.KRo_Bufor as LKRo_Bufor,
 dokumenty.KRo_Storno as LKRo_Storno,
 dokumenty.KRo_KwotaDokWal as LKRo_KwotaDokWal,
 dokumenty.KRo_KwotaWal as LKRo_KwotaWal,
 dokumenty.KRo_SumRozliczenWal as LKRo_SumRozliczenWal,
 dokumenty.KRo_Waluta as LKRo_Waluta,
 dokumenty.KRo_IdentKsieg as LKRo_IdentKsieg,
 dokumenty.KRo_Konto as LKRo_Konto,
 dokumenty.KRo_KontoPrzeciw as LKRo_KontoPrzeciw,
 rtrim(convert(char, dokumenty.KRo_Nrksiegi)) + case dokumenty.KRo_Bufor when 1 then ' B' else ' ' end as LKRo_NrDziennika,
 case when dokumenty.Kro_Typ = 1 then
  case when LOOb.OOb_CiaglaNumeracjaDC <> 0
  then rtrim(dokumenty.KRo_Dziennik + '/' + convert(char, dokumenty.KRo_NumerDziennika))
  else rtrim(dokumenty.KRo_Dziennik+ '/' + convert(char(7), dokumenty.KRo_DataDokumentu, 111) + '/' + convert(char, dokumenty.KRo_NumerDziennika))
  end
 else dokumenty.KRo_Nrksiegi
 end as LKRo_Dziennik,
 case when PZdarzeniaDES.BZd_BZdID is not null then PZdarzeniaDES.BZd_BZdID
 else case when PZdarzeniaBO.BZd_BZdID is not null then PZdarzeniaBO.BZd_BZdID
 else case when PZdarzeniaDE.BZd_BZdID is not null then PZdarzeniaDE.BZd_BZdID
 else case when PZapisyDE.BZp_BZpID is not null then PZapisyDE.BZp_BZpID end end end end as PDokKbId,
 rozliczenie.KRo_BRKId as PBRKId,
 case when PZdarzeniaDES.BZd_BZdID is not null then 1
 else case when PZdarzeniaBO.BZd_BZdID is not null then 1
 else case when PZdarzeniaDE.BZd_BZdID is not null then 1
 else case when PZapisyDE.BZp_BZpID is not null then 2 end end end end as PDokKbTyp,
 rozliczenie.KRo_Typ as PDokKhTyp,
 case when rozliczenie.KRo_Typ = 1 then rozliczenie.KRo_DeEID else rozliczenie.KRo_BoEID end PDokKhId,
    case when PZdarzeniaDES.BZd_BZdID is not null then PZdarzeniaDES.BZd_NumerPelny
            else case when PZdarzeniaBO.BZd_BZdID is not null then PZdarzeniaBO.BZd_NumerPelny
            else case when PZdarzeniaDE.BZd_BZdID is not null then PZdarzeniaDE.BZd_NumerPelny
            else case when PZapisyDE.BZp_BZpID is not null then PZapisyDE.BZp_NumerPelny end end end end as PDokKbNumerPelny,
 case when rozliczenie.KRo_SumRozliczen = rozliczenie.KRo_KwotaDok then 'Rozrachowany całkowicie'
      when rozliczenie.KRo_SumRozliczen <> 0 and rozliczenie.KRo_SumRozliczen < rozliczenie.KRo_KwotaDok then 'Rozrachowany częściowo'
   else 'Nierozrachowany' end as PKRo_Status,
 rozliczenie.KRo_Dokument as PKRo_Dokument,
 rozliczenie.KRo_DataDokumentu as PKRo_DataDokumentu,
 rozliczenie.KRo_TerminPlatnosci as PKRo_TerminPlatnosci,
 rozliczenie.KRo_DataRozliczenia as PKRo_DataRozliczenia,
 rozliczenie.KRo_DataRoz as PKRo_DataRoz,
 rozliczenie.KRo_KwotaDok as PKRo_KwotaDok,
 rozliczenie.KRo_Kwota as PKRo_Kwota,
 rozliczenie.KRo_SumRozliczen as PKRo_SumRozliczen,
 rozliczenie.KRo_Bufor as PKRo_Bufor,
 rozliczenie.KRo_Storno as PKRo_Storno,
 rozliczenie.KRo_KwotaDokWal as PKRo_KwotaDokWal,
 rozliczenie.KRo_KwotaWal as PKRo_KwotaWal,
 rozliczenie.KRo_SumRozliczenWal as PKRo_SumRozliczenWal,
 rozliczenie.KRo_Waluta as PKRo_Waluta,
 rozliczenie.KRo_IdentKsieg as PKRo_IdentKsieg,
 rozliczenie.KRo_Konto as PKRo_Konto,
 rozliczenie.KRo_KontoPrzeciw as PKRo_KontoPrzeciw,
 rtrim(convert(char, rozliczenie.KRo_Nrksiegi)) + case rozliczenie.KRo_Bufor when 1 then ' B' else ' ' end as PKRo_NrDziennika,
 case when rozliczenie.Kro_Typ = 1 then
  case when POOb.OOb_CiaglaNumeracjaDC <> 0
  then rtrim(rozliczenie.KRo_Dziennik + '/' + convert(char, rozliczenie.KRo_NumerDziennika))
  else rtrim(rozliczenie.KRo_Dziennik+ '/' + convert(char(7), rozliczenie.KRo_DataDokumentu, 111) + '/' + convert(char, rozliczenie.KRo_NumerDziennika))
  end
 else rozliczenie.KRo_Nrksiegi
 end as PKRo_Dziennik
 from
 cdn.KsiRozrachunki dokumenty
 join cdn.KsiRozrachunki rozliczenie on (dokumenty.KRo_KRoId = rozliczenie.KRo_RozliczenieId)
 left outer join CDN.DekretyElem LDE on (dokumenty.KRo_Typ = 1 and dokumenty.KRo_DeEID = LDE.DeE_DeEID)
 left outer join CDN.BOElem LBE on (dokumenty.KRo_Typ = 2 and dokumenty.KRo_BoEID = LBE.BOE_BOEID)
 left outer join cdn.BnkZdarzenia LZdarzeniaDES on (LZdarzeniaDES.BZd_BZdID = LDE.DeE_BZdId)
 left outer join cdn.BnkZdarzenia LZdarzeniaBO on (LZdarzeniaBO.BZd_DokumentTyp in (39, 40) and LZdarzeniaBO.BZd_DokumentId = LBE.BOE_BOEId)
 left outer join cdn.BnkZdarzenia LZdarzeniaDE on (LZdarzeniaDE.BZd_DokumentTyp in (27, 28) and LZdarzeniaDE.BZd_DokumentId = LDE.DeE_DeEID)
 left outer join cdn.BnkZapisy LZapisyDE on (LDE.DeE_DokumentTyp=14 and LZapisyDE.BZp_BZpId = LDE.DeE_DokumentId)
 left outer join CDN.DekretyElem PDE on (rozliczenie.KRo_Typ = 1 and rozliczenie.KRo_DeEID = PDE.DeE_DeEID)
 left outer join CDN.BOElem PBE on (rozliczenie.KRo_Typ = 2 and rozliczenie.KRo_BoEID = PBE.BOE_BOEID)
 left outer join cdn.BnkZdarzenia PZdarzeniaDES on (PZdarzeniaDES.BZd_BZdID = PDE.DeE_BZdId)
 left outer join cdn.BnkZdarzenia PZdarzeniaBO on (PZdarzeniaBO.BZd_DokumentTyp in (39, 40) and PZdarzeniaBO.BZd_DokumentId = PBE.BOE_BOEId)
 left outer join cdn.BnkZdarzenia PZdarzeniaDE on (PZdarzeniaDE.BZd_DokumentTyp in (27, 28) and PZdarzeniaDE.BZd_DokumentId = PDE.DeE_DeEID)
 left outer join cdn.BnkZapisy PZapisyDE on (PDE.DeE_DokumentTyp=14 and PZapisyDE.BZp_BZpId = PDE.DeE_DokumentId)
 join cdn.OkresyObrach LOOb on (LOOb.OOb_OObId = dokumenty.KRo_OObId)
 join cdn.OkresyObrach POOb on (POOb.OOb_OObId = rozliczenie.KRo_OObId)
 --left outer join cdn.BnkRozKwoty on (rozliczenie.KRo_BRKID = BRK_BRKID)
 where dokumenty.KRo_BRKId Is Not Null and rozliczenie.KRo_BRKId Is Not Null
 ) as R2RSource
 --
 return
END
