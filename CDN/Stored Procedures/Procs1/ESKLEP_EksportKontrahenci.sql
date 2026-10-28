CREATE PROCEDURE [CDN].[ESKLEP_EksportKontrahenci]
@ID int -- ID e-sklepu
,@TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
as
begin
declare
 @esklGrupa VARCHAR(20)
,@DateTSSynchr     DATETIME
,@TSSynchr         nvarchar(254)
,@ESklepID     INT
select
@ESklepID = ESS_ESSID
,@esklGrupa = ESS_KntGrupa
,@TSSynchr =  ESS_TS_SynchroKntOptimaPotw
from cdn.eSklepStanowiska where ESS_IdISklep = @ID
SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
select
[@GIDNumer]=b.Knt_KntId,
[@SklepID]=ESK_KnteSklepID,
[@Nazwa1]=b.Knt_Nazwa1,
[@Nazwa2]=b.Knt_Nazwa2,
[@Nazwa3]=b.Knt_Nazwa3,
[@Miasto]=b.Knt_Miasto,
[@KodP]=rtrim(b.Knt_KodPocztowy),
[@Ulica]=b.Knt_Ulica,
[@NrBudynek]=b.Knt_NrDomu,
[@NrLokal]=b.Knt_NrLokalu,
[@Wojewodztwo]=b.Knt_Wojewodztwo,
[@NIP]=b.Knt_Nip,
[@NIPUE]=b.Knt_NipKraj,
[@Kraj]= case when b.Knt_KrajISO='' then 'PL' else UPPER(b.Knt_KrajISO) end,
[@Email]=b.Knt_Email,
[@Telefon]=b.Knt_Telefon1,
[@DataUrodzenia]='',
[@Waluta]='',
[@LimitK]= b.Knt_LimitFlag,
[@LimitPP]= b.Knt_LimitPrzeterKredytFlag,
[@Typ]= case when b.Knt_Finalny= 1 then 0 else 1 end ,
[@TypTransakcji]= case b.Knt_export
      when 0 then 1
      when 1 then 3
      when 2 then 3
      when 3 then 2
      when 4 then 2
      when 5 then 1
      when 6 then 3
      when 7 then 3
      else 1  end,
[@Pesel]=b.Knt_Pesel,
[@Grupa]=case when rtrim(b.Knt_Grupa)= '' then null else rtrim(b.Knt_Grupa) end ,
[@GrupaID]=Gru_GruID,
[@CenaID] = KES_TypCenyDomyslnej,
[@OpiekunID] = case when isnull(b.Knt_OpiekunTyp,0) = 8 then b.Knt_OpiekunId else null end,
[@PlatDni] = case when b.Knt_TerminPlat= 1 then b.Knt_Termin else null end ,
(select
[@Nazwa1]=a.Knt_Nazwa1,
[@Nazwa2]=a.Knt_Nazwa2,
[@Nazwa3]=a.Knt_Nazwa3,
[@Miasto]=a.Knt_Miasto,
[@KodP]=rtrim(a.Knt_KodPocztowy),
[@Ulica]=a.Knt_Ulica,
[@NrBudynek]=a.Knt_NrDomu,
[@NrLokal]=a.Knt_NrLokalu,
[@Wojewodztwo]=a.Knt_Wojewodztwo,
[@Kraj]=case when a.Knt_KrajISO='' then 'PL' else UPPER(a.Knt_KrajISO) end,
[@Telefon]=a.Knt_Telefon1,
[@GIDNumer]=a.Knt_KntId,
[@AdresID]=1,
[@Domyslny]=1
from cdn.Kontrahenci a WHERE a.Knt_KntId = b.Knt_KntId
FOR XML PATH('KNA'),ROOT('KNTA'), TYPE),
( select [@GIDNumer]=b.Knt_KntId , [@PID] = KESP_KESPID , [@Imie] = KESP_Nazwisko,[@Nazwisko] = '',
[@Telefon] = KnO_Telefon,[@Email] = KESP_Email,[@Admin] = KESP_Domyslny,
( select [@VerID]=RZT_GuidVer , [@Stan] = case when isnull(PRZ_ZrodloWycofaniaId,0) = 0 then 1 else 0 end , [@IP] = case when isnull(PRZ_ZrodloWycofaniaId,0) = 0 then PRZ_IPWyrazenia else PRZ_IPWycofania end,
[@Data] =  convert ( varchar(50),case when case when isnull(PRZ_ZrodloWycofaniaId,0) = 0 then PRZ_DataWyrazenia else PRZ_DataWycofania end = DATEADD(dd, 0, DATEDIFF(dd, 0, prz_ts_mod)) then prz_ts_mod else  case when isnull(PRZ_ZrodloWycofaniaId,0) = 0 then PRZ_DataWyrazenia else PRZ_DataWycofania end end,120),
[@JezykID] = 1,
( select [@ID] = RZFK_GUID, [@Stan] = stan from
(select RZFK_GUID,case when isnull(PRZ_ZrodloWycofaniaId,0) = 0 then 1 else 0 end as stan
from cdn.PodmiotRejestracjaZgod d1
join CDN.RejestracjaZgodFormyKontaktu on RZFK_RZFKId = 1
where d1.PRZ_EMAIL = 1 and RZT_RZKID = 2 and d1.PRZ_PRZId = PRZ.PRZ_PRZId
union
select RZFK_GUID,case when isnull(PRZ_ZrodloWycofaniaId,0) = 0 then 1 else 0 end as stan
from cdn.PodmiotRejestracjaZgod d2
join CDN.RejestracjaZgodFormyKontaktu on RZFK_RZFKId = 2
where d2.PRZ_SMS = 1 and RZT_RZKID = 2  and d2.PRZ_PRZId = PRZ.PRZ_PRZId
union
select RZFK_GUID,case when isnull(PRZ_ZrodloWycofaniaId,0) = 0 then 1 else 0 end as stan
from cdn.PodmiotRejestracjaZgod d3
join CDN.RejestracjaZgodFormyKontaktu on RZFK_RZFKId = 3
where d3.PRZ_Telefon = 1 and RZT_RZKID = 2  and d3.PRZ_PRZId = PRZ.PRZ_PRZId
union all
select RZFK_GUID,case when isnull(PRZ_ZrodloWycofaniaId,0) = 0 then 1 else 0 end as stan
from cdn.PodmiotRejestracjaZgod d4
join CDN.RejestracjaZgodFormyKontaktu on RZFK_RZFKId = 4
where d4.PRZ_List = 1 and RZT_RZKID = 2 and d4.PRZ_PRZId = PRZ.PRZ_PRZId) as zz
for xml  PATH('ZGK') ,root ('ZGKI'),TYPE )
from CDN.PodmiotRejestracjaZgod PRZ
join CDN.RejestracjaZgodTresc on PRZ_TrescZgodyId = RZT_RZTId
join CDN.RejestracjaZgodTrescESklepy on RZT_RZTId = RZTES_RZTID
where PRZ_PrzedstawicielId = KnO_KnOId  and RZTES_eSklepID = @ESklepID
and ((isnull(PRZ_ZrodloWycofaniaId,0) = 0  and PRZ_WyrazenieESklepId != @ESklepID) or(isnull(PRZ_ZrodloWycofaniaId,0) > 0  and PRZ_WycofanieESklepId != @ESklepID))
and (RZTES_eSklepWyslana = 1 or RZTES_PrzyszlaZeSklep =1)  and PRZ_ts_mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
for xml  PATH('ZGD') ,root ('ZGDI'),TYPE )
from CDN.KntESklepyPrzedstawiciele
join CDN.KntOsoby on KESP_PrzedstawicielID = KnO_KnOId
where KESP_KntID = b.Knt_KntId  and KESP_eSklepID = @ESklepID and ISNULL(KnO_LpAnonimizacji, 0) = 0 and KESP_Nieaktywny = 0
for xml  PATH('KNP') ,root ('KNTP'),TYPE )
from cdn.Kontrahenci b
left outer join cdn.grupy on b.Knt_Grupa = Gru_Nazwa and Gru_Typ = 31
left outer join cdn.KntESklepy on b.Knt_KntId = KES_KntID and KES_eSklepID = @ESklepID
left outer join cdn.eSklepKntRelacje on b.Knt_KntId = ESK_KntOptimaID and ESK_eSklepID = @ESklepID
where
   KES_KntID is not null and
   b.Knt_Nieaktywny = 0 and
   b.Knt_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END and
   b.Knt_Nazwa1 <> '' and
   b.Knt_Email  <> ''and
   b.Knt_Ulica <> ''and
   b.Knt_NrDomu <> ''and
   b.Knt_KodPocztowy  <> ''and
   b.Knt_Miasto  <> ''and
   ISNULL(b.Knt_LpAnonimizacji, 0) = 0
for xml  PATH('KNT'), ROOT('KNTI')
end
