-- IloscDlaFAzPF
CREATE  PROCEDURE [CDN].[IloscDlaFAzPF]
@ID INT,
@ElemID INT,
@CzyPFzWZ INT,
@iloscPF decimal(15,4)
  AS
  SET NOCOUNT ON
declare @ilosc decimal(15,4),
@Stawka decimal(5,2),
@Flaga smallint,
@Typ smallint
set @ilosc = 0
set @Stawka = -1
set @Flaga  = -1
select top 1 @Typ = Twr_Typ from cdn.towary join CDN.TraElem on tre_twrid = twr_twrid where TrE_TrEID = @ElemID
--wz
-- jesli jest właczony parametr przenoszenia usług na WZ to usługa przechodzi tylko jak jest na WZ
if exists(select fir_wartosc from cdn.Firma where Fir_Numer = 1576 and Fir_Wartosc ='1')
 set @Typ = 1
if @CzyPFzWZ = 1 and @Typ = 0
begin
if exists (
select tre_treid  from cdn.traelem
join cdn.traelemrelacje on ter_parentid = @ElemID and ter_childid = tre_treid
join cdn.tranag on tre_trnid= trn_trnid
JOIN cdn.TraNagRelacje a on TrN_TrNId = a.TrR_TrNId
left JOIN cdn.TraNagRelacje b on TrN_TrNId = b.TrR_TrNId and  b.TrR_FaTyp = 302
where trn_typdokumentu = 306 and b.TrR_FaTyp is null and tre_aktywny = 1 and a.trr_FaId=@ID)
set @Typ = 1
end
if @CzyPFzWZ = 1 and @Typ = 1
begin
/*select @ilosc = ISNULL( SUM( TrE_IloscJM), 0 ) from cdn.traelem
join cdn.traelemrelacje on ter_parentid = @ElemID and ter_childid = tre_treid
join cdn.tranag on tre_trnid= trn_trnid
JOIN cdn.TraNagRelacje a on TrN_TrNId = a.TrR_TrNId
left JOIN cdn.TraNagRelacje b on TrN_TrNId = b.TrR_TrNId and  b.TrR_FaTyp = 302
where trn_typdokumentu = 306 and b.TrR_FaTyp is null and tre_aktywny = 1 and a.trr_FaId=@ID --and tre_lppow =@LpPow
*/
select @ilosc = ISNULL( SUM( TrE_IloscJM), 0 ), @Stawka = ISNULL(max(TrE_Stawka),-1 ), @Flaga = ISNULL(max(TrE_Flaga),-1 ) from (
select ISNULL( SUM( TrE_Ilosc), 0 ) as TrE_IloscJM, ISNULL(max(TrE_Stawka),-1 ) as TrE_Stawka, ISNULL(max(TrE_Flaga),-1 ) as TrE_Flaga  from cdn.traelem
join cdn.traelemrelacje on ter_parentid = @ElemID and ter_childid = tre_treid
join cdn.tranag on tre_trnid= trn_trnid
JOIN cdn.TraNagRelacje a on TrN_TrNId = a.TrR_TrNId
left JOIN cdn.TraNagRelacje b on TrN_TrNId = b.TrR_TrNId and  b.TrR_FaTyp = 302
where trn_typdokumentu = 306 and b.TrR_FaTyp is null and tre_aktywny = 1 and a.trr_FaId=@ID
union  all
select ISNULL( SUM( TrE_Ilosc), 0 ) as TrE_IloscJM, -1,-1 from cdn.traelem
JOIN cdn.TraNag ON TrE_TrNId = TrN_TrNId
where tre_zwrid  in(
select tre_treid from cdn.traelem
join cdn.traelemrelacje on ter_parentid = @ElemID and ter_childid = tre_treid
join cdn.tranag on tre_trnid= trn_trnid
JOIN cdn.TraNagRelacje a on TrN_TrNId = a.TrR_TrNId
left JOIN cdn.TraNagRelacje b on TrN_TrNId = b.TrR_TrNId and  b.TrR_FaTyp = 302
where trn_typdokumentu = 306 and b.TrR_FaTyp is null and tre_aktywny = 1 and a.trr_FaId=@ID )
and TrN_Bufor <> -1
) as a
end
else --FA
if exists(
select TrE_treid from cdn.traelem
join cdn.traelemrelacje on TeR_ChildId = TrE_treid and ter_parenttyp = 320 and ter_parentid = @ElemID
join cdn.tranag on tre_trnid= trn_trnid
JOIN cdn.TraNagRelacje a on TrN_TrNId = a.TrR_TrNId
where trn_typdokumentu = 302  and tre_aktywny = 1 and a.trr_FaId=@ID --and tre_lppow =@LpPow
)
/*select @ilosc  = @iloscPF - ISNULL( SUM( TrE_IloscJM), 0 ) from cdn.traelem
join cdn.traelemrelacje on TeR_ChildId = TrE_treid and ter_parenttyp = 320 and ter_parentid = @ElemID
join cdn.tranag on tre_trnid= trn_trnid
JOIN cdn.TraNagRelacje a on TrN_TrNId = a.TrR_TrNId
where trn_typdokumentu = 302  and tre_aktywny = 1 and a.trr_FaId=@ID --and tre_lppow =@LpPow*/
select @ilosc  = @iloscPF - ISNULL( SUM( Ter_Info), 0 ) from cdn.traelemrelacje
where ter_parentid = @ElemID and ter_childtyp = 302
else
select  @ilosc = @iloscPF
if @ilosc < 0 set @ilosc = 0
select @ilosc,@Stawka,@Flaga
SET NOCOUNT OFF
