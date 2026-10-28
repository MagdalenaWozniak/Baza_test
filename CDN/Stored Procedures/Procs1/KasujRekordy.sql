CREATE PROCEDURE [CDN].[KasujRekordy]
   @DataOpeStr    nvarchar(20)
AS
 SET NOCOUNT ON
  declare @DataOpe datetime
  DECLARE @Id TABLE ( Id INT )
  DECLARE @IdTrS TABLE ( Id INT )
  DECLARE @IdDost TABLE ( Id INT )
  set @DataOpe         = CONVERT(DATETIME, @DataOpeStr, 120 )
  CREATE TABLE  #Zasoby(TowarID INT, Ilosc DECIMAL(15,4),Wartosc DECIMAL(15,2), MagId INT )
  -- zasoby
  INSERT INTO #Zasoby (TowarID,Ilosc,Wartosc,MagId)
 SELECT distinct TwI_TwrId,TwI_Ilosc,TwI_Wartosc, TwI_magId
    FROM cdn.twrilosci
      where twi_twiid = CDN.TwrIlosciID ( twi_twrid, twi_magid, @DataOpe)
--rezerwacje/zamówienia
delete from cdn.TraSElem where  TrS_TrSID in(
select trs_trsid from cdn.TraSElem
join cdn.TraElem on TrE_TrEID = TrS_TrEId
join cdn.TraNag on TrE_TrNId = TrN_TrNID
where TrN_TypDokumentu in(308,309) and  TrS_Typ in (3,4) and TrN_ZwroconoCalaIlosc < 3 and TrN_DataOpe <= @DataOpe  and TrN_Bufor = 0 )
--rezerwacje/zamówienia faktury
delete from cdn.TraSElem where  TrS_TrSID in(
select trs_trsid  from cdn.TraSElem
join cdn.TraElem on TrE_TrEID = TrS_TrEId
join cdn.TraNag on TrE_TrNId = TrN_TrNID
where TrN_TypDokumentu not in(308,309) and  TrS_Typ in (3,4)  and TrN_DataOpe <= @DataOpe and TrN_Bufor = 0
union all
select trs_trsid from cdn.TraSElem
join cdn.TraElem on TrE_TrEID = TrS_TrEId
join cdn.TraNag KOR on TrE_TrNId = KOR.TrN_TrNID
join cdn.TraNag TRN on KOR.TrN_ZwrId = TRN.TrN_TrNID
where KOR.TrN_TypDokumentu not in(308,309) and  KOR.TrN_Korekta > 0  and  TrS_Typ in (3,4)  and KOR.TrN_DataOpe > @DataOpe  and TRN.TrN_DataOpe <= @DataOpe and TRN.TrN_Bufor = 0
)
insert into @Id
select FPF.TrN_TrNID from cdn.tranag FPF
join cdn.TraNagRelacje on TrR_TrNId = FPF.TrN_TrNID
join cdn.TraNag Reszta on TrR_FaId= Reszta.TrN_TrNID
where FPF.TrN_TypDokumentu = 320 and Reszta.TrN_TypDokumentu != 309 and Reszta.TrN_TypDokumentu != 308 and reszta.TrN_Rodzaj != 302000 and Reszta.TrN_Rodzaj != 302009 and Reszta.TrN_DataOpe > @DataOpe
insert into @Id
select FPF.TrN_TrNID from cdn.tranag FPF
join cdn.TraNagRelacje on TrR_TrNId = FPF.TrN_TrNID
join cdn.TraNag Reszta on TrR_FaId= Reszta.TrN_TrNID
where FPF.TrN_TypDokumentu = 317 and Reszta.TrN_TypDokumentu = 318  and Reszta.TrN_DataOpe > @DataOpe
union all
select FPF.TrN_TrNID from cdn.tranag FPF
join cdn.TraNagRelacje on TrR_TrNId = FPF.TrN_TrNID
join cdn.TraNag Reszta on TrR_FaId= Reszta.TrN_TrNID
where FPF.TrN_TypDokumentu = 318 and Reszta.TrN_TypDokumentu = 317  and Reszta.TrN_DataOpe > @DataOpe
insert into @Id
select Trr_FAID from cdn.TraNagRelacje
where TrR_TrNId in (select Id from @Id) and not(TrR_TrNTyp = 317 and TrR_FaTyp = 308)
insert into @IdTrS
select Trs_TrsId from cdn.TraSElem
join cdn.TraElem on TrE_TrEID = TrS_TrEId
where TrE_TrNId in (select Id from @Id)
insert into @IdTrS
select distinct Trs_TrsIDDost from cdn.TraSElem
join cdn.TraElem on TrE_TrEID = TrS_TrEId
where TrE_TrNId in (select Id from @Id) and Trs_TrsIDDost is not null and  Trs_TrsIDDost > 0
union all
select distinct Wyk.Trs_TrsIdDost from cdn.TraSElem Wyk
join cdn.TraSElem Dost on Wyk.Trs_TrsIdDost = Dost.TrS_TrSID
where Wyk.TrS_DataOpe > @DataOpe and Dost.TrS_DataOpe <= @DataOpe
union all
select distinct trs_trsid from cdn.twrzasoby
join cdn.TraSElem on TrS_TrSID = TwZ_TrSIdDost
join cdn.Towary on TrS_TwrId = Twr_TwrID
where twz_data <=@DataOpe
insert into @IdTrS
select Trs_TrsId from cdn.TraSElem
where TrS_TrSIdDost in (select Id from @IdTrS) and TrS_Rodzaj in (312000,312008)
insert into @IdDost
select distinct trs_trsid from cdn.twrzasoby
join cdn.TraSElem on TrS_TrSID = TwZ_TrSIdDost
join cdn.Towary on TrS_TwrId = Twr_TwrID
where twz_data <=@DataOpe
Alter Table CDN.TraNag disable trigger all
Alter Table CDN.TraNagRelacje disable trigger all
Alter Table CDN.TraElem disable trigger all
Alter Table CDN.TraSElem disable trigger all
Alter Table CDN.BnkZapisy disable trigger all
Alter Table CDN.BnkZdarzenia disable trigger all
Alter Table CDN.BnkRozKwoty disable trigger all
Alter Table CDN.BnkRozRelacje disable trigger all
update Zdarz  set BZd_DokumentID = trn_vanid, BZd_DokumentTyp = 2, BZd_Srw = 1 from cdn.BnkZdarzenia Zdarz
join cdn.TraNag on TrN_TrNId = BZd_DokumentID
where BZd_DokumentTyp = 1 and  trn_vanid is not null and trn_vanid > 0 and TrN_DataOpe <= @DataOpe and TrN_TrNID not in (select Id from @Id)
update Zdarz  set BZd_DokumentID = 0, BZd_DokumentTyp = 0, BZd_Srw = 1 from cdn.BnkZdarzenia Zdarz
join cdn.TraNag on TrN_TrNId = BZd_DokumentID
where BZd_DokumentTyp = 1 and  trn_vanid is null and TrN_DataOpe <= @DataOpe and TrN_TrNID not in (select Id from @Id)
update VAT  set VaN_TrnID= null, VaN_Srw = 1 from cdn.VatNag VAT
join cdn.TraNag on TrN_TrNId = VaN_TrnID
where TrN_DataOpe <= @DataOpe and TrN_TrNID not in (select Id from @Id)
update VAT  set VaN_TrnID= null, VaN_Srw = 1 from cdn.VatNag VAT
join cdn.TraNag on TrN_VaNId = VaN_VaNID
where TrN_DataOpe <= @DataOpe and TrN_TrNID not in (select Id from @Id) and   VaN_TrnID = -1
update DEK  set  DeN_Zrodlo=2 from CDN.DekretyNag DEK
join cdn.TraNag on TrN_DekId = DEN_DENID
where  DeN_Zrodlo=1 and  TrN_DataOpe <= @DataOpe and TrN_TrNID not in (select Id from @Id) and TrN_TypDokumentu in (302,301,305,345,321,322 )
Delete From CDN.TraNag where TrN_DataOpe <= @DataOpe and TrN_TrNID not in (select Id from @Id)
Delete From CDN.TraElem where Tre_DataOpe <= @DataOpe and TrE_TrNID not in (select Id from @Id)
update a set trs_ilosc = trs_ilosc + ilosc  , trs_wartosc = trs_wartosc+ wartosc from cdn.TraSElem a
join (
select trs_zwrid as zwrid, sum(trs_ilosc) as ilosc,sum(TrS_Wartosc)as wartosc from cdn.TraSElem where TrS_ZwrId is not null and trs_zwrid > 0 and  Trs_DataOpe <= @DataOpe and Trs_TrsID not in (select Id from @IdTrS)
group by trs_zwrid)b on a.TrS_TrSID = zwrid
where  Trs_DataOpe <= @DataOpe
Delete From CDN.TraSelem where TrS_Rodzaj in (308000,309000,308011) and Trs_DataOpe > @DataOpe and trs_treid in( select distinct trs_treid from cdn.TraSElem where TrS_Rodzaj in (308000,309000,308011) and Trs_DataOpe <= @DataOpe and Trs_TrsID not in (select Id from @IdTrS))
Delete From CDN.TraSelem where Trs_DataOpe <= @DataOpe and Trs_TrsID not in (select Id from @IdTrS)
Delete From CDN.TwrZasoby where Twz_Data <= @DataOpe and TwZ_TrSIdDost not in (select Id from @IdDost)
Delete From CDN.TwrIlosci where TwI_Data <= @DataOpe
--delete from cdn.traselemdost where TsD_DataOpe <= @DataOpe and TsD_TrSID not in (select Id from @IdTrS)
delete from CDN.TraSElemDost where TsD_TsDID in (
select TsD_TsDID from CDN.TraSElemDost
left join cdn.TraSElem on TrS_TrSID = TsD_TrSID
where  TrS_TrSID is null  and TsD_TrSID > 0  )
delete from cdn.DokRelacje where DoR_DoRId in(
select DoR_DoRId from cdn.DokRelacje
left join cdn.TraNag on TrN_TrNID = DoR_DokumentId
where DoR_DokumentTyp >300 and DoR_DokumentTyp <400 and DoR_ParentTyp in (700,750,1011,1010,1020) and TrN_TrNID is null )
delete from cdn.traelemrelacje
where TeR_TeRId in
(select TeR_TeRId from cdn.TraElemRelacje
left join cdn.TraElem on TrE_TrEID = TeR_ParentId
where TeR_ParentTyp >300 and TeR_ParentTyp <400 and Ter_childTyp not in (901,902) and TrE_TrEID is null
union all
select TeR_TeRId from cdn.TraElemRelacje
left join cdn.TraElem on TrE_TrEID = TeR_ChildId
where TeR_ChildTyp >300 and TeR_ChildTyp <400 and Ter_ParentTyp not in (901,902) and TrE_TrEID is null )
update TraNag  set TrN_Srw = 1 from cdn.TraNag TraNag
where trn_trnid in(select distinct TrR_FAId from cdn.TraNagRelacje
left join cdn.TraNag on TrN_TrNID = TrR_TrNId
where TrN_TrNID is null)
update TraNag  set TrN_Srw = 1 from cdn.TraNag TraNag
where trn_trnid in(select KOR.TrN_TrNId from cdn.TraNag KOR
left join cdn.TraNag FA on FA.TrN_TrNID = KOR.TrN_ZwrId
where FA.TrN_TrNID is null and KOR.TrN_ZwrId is not null and KOR.TrN_ZwrId>0
union all
select KOR.TrN_TrNId from cdn.TraNag KOR
left join cdn.TraNag FA on FA.TrN_TrNID = KOR.TrN_ZwrIdWZKK
where FA.TrN_TrNID is null and KOR.TrN_ZwrIdWZKK is not null and KOR.TrN_ZwrIdWZKK>0
)
delete from cdn.tranagrelacje
where TrR_TrRId in
(select distinct TrR_TrRId from cdn.TraNagRelacje
left join cdn.TraNag on TrN_TrNID = TrR_TrNId
where TrN_TrNID is null
union all
select distinct TrR_TrRId from cdn.TraNagRelacje
left join cdn.TraNag on TrN_TrNID= TrR_FAId
where TrN_TrNID is null )
if exists (select * from cdn.Firma where Fir_Numer=1938 )
update cdn.Firma set Fir_Wartosc = @DataOpeStr where Fir_Numer=1938
else
INSERT INTO CDN.Firma
           (Fir_Numer
           ,Fir_Wartosc
           ,Fir_Opis)
     VALUES
           (1938
           ,@DataOpeStr
           ,'Data kasowania rekordow')
--dodajemy rekordy z iloscia 0 na date ciecia aby ewentualne zwroty pojawily sie z ta data
 INSERT INTO CDN.TwrIlosci
           (TwI_TwrId
           ,TwI_MagId
           ,TwI_Data
           ,TwI_Ilosc
           ,TwI_Wartosc
           ,TwI_Braki
           ,TwI_Rezerwacje
           ,TwI_Zamowienia)
select distinct TrS_TwrId,MagId,@DataOpe,Ilosc,Wartosc,0,0,0
  from cdn.traselem
  join #Zasoby on TrS_TwrId = TowarID
  where TrS_DataOpe <= @DataOpe
Alter Table CDN.TraNag enable trigger all
Alter Table CDN.TraNagRelacje enable trigger all
Alter Table CDN.TraElem enable trigger all
Alter Table CDN.TraSElem enable trigger all
Alter Table CDN.BnkZapisy enable  trigger all
Alter Table CDN.BnkZdarzenia enable  trigger all
Alter Table CDN.BnkRozKwoty enable  trigger all
Alter Table CDN.BnkRozRelacje enable  trigger all
SET NOCOUNT OFF
