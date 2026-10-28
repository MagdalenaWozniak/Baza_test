create function cdn.CRM_NumerDokSkojazonego( @ID int )
returns table
as
return(
select TrN_NumerPelny ,DoR_DoRID,
case DoR_DokumentTyp when 302 then  'FS'
when 301 then   'FZ'
when 308 then   'RO'
when 309 then   'ZD'
when 320 then   'PF'
when 306 then   'WZ'
when 307 then   'PZ'
when 303 then   'PW'
when 304 then   'RW'
when 311 then   'AI'
when 312 then   'MM'
when 310 then   'BO'
when 317 then   'PWP'
when 318 then   'RWS'
when 322 then   'FWS'
when 321 then   'FWZ'
when 350 then   'FRR'
when 305 then   'PA'
when 313 then   'PKA'
when 314 then   'WKA'
when 345 then   'TF' end as typ
from CDN.DokRelacje
join cdn.TraNag on DoR_DokumentId = Trn_TrnId AND DoR_DokumentTyp = TrN_TypDokumentu
where DoR_DokumentTyp in(302 ,301 ,308 ,309 ,320 ,306 ,307 ,303 ,304 ,311 ,312 ,310 ,317 ,318 ,322 ,321 ,350 ,305 ,313 ,314 ,345 )
and DoR_DoRID = @ID
union all
select CRK_NumerPelny,DoR_DoRID,'CRM' as typ from CDN.DokRelacje
join CDN.CrmKontakty on DoR_DokumentId = CrK_CrkId
where DoR_DokumentTyp = 700
and DoR_DoRID = @ID
union all
select VaN_Dokument,DoR_DoRID,'VAT' as typ  from CDN.DokRelacje
join  CDN.VatNag on DoR_DokumentId = Van_VanId
where DoR_DokumentTyp = 999
and DoR_DoRID = @ID
union all
select case DKB_NumerPelny when '' then DKB_Numer else DKB_NumerPelny end,DoR_DoRID,
case DKB_TypDokumentuKB when 2 then
 case DKB_Kierunek when -1 then 'ZKB-KW' else 'ZKB-KP' end
when 1 then 'PP' end as typ
 from CDN.DokRelacje
join  CDN.DokumentyKBView on DoR_DokumentId = Dkb_DkbId
where ( Dkb_TypDokumentuKB=2 or DoR_DokumentTyp<>1000) and --Dok ZKB
      ( Dkb_TypDokumentuKB=1 or DoR_DokumentTyp<>1001) and --Dok PP
 DoR_DokumentTyp in (1000, 1001)
and DoR_DoRID = @ID
union all
select EDN_NumerPelny,DoR_DoRID, 'EDK' as typ  from CDN.DokRelacje
join CDN.EwidDodNag on DoR_DokumentID = EDN_EDNID
where DoR_DokumentTyp = 101
and DoR_DoRID = @ID
union all
select SrZ_NumerPelny ,DoR_DoRID,'SRW' as typ  from CDN.DokRelacje
join CDN.SrsZlecenia on DoR_DokumentID = SrZ_SrZId
where DoR_DokumentTyp = 900
and DoR_DoRID = @ID
union all
select BDN_NumerPelny, DoR_DoRID ,
case BDN_Typ when 222 then 'PON' when 223 then 'NO' else '' end as typ  from CDN.DokRelacje
join CDN.BnkDokNag on DoR_DokumentID = BDN_BDNId where
DoR_DokumentTyp = 1002 AND
( (BDN_Typ = 222) or --PO
(BDN_Typ = 223)   )  --NO
and DoR_DoRID = @ID
-- Sekretariat
union all
select DoN_NumerPelny,DoR_DoRID, 'OBD' as typ from cdn.DokNag
join CDN.DokRelacje on DoR_DokumentID = DoN_DoNId
where DoR_DokumentTyp = 750 AND
DoR_DoRID = @ID
)
