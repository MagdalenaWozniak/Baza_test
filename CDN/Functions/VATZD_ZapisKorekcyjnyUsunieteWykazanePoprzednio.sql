CREATE FUNCTION CDN.VATZD_ZapisKorekcyjnyUsunieteWykazanePoprzednio(@typRejestru int, @rokMiesiac int, @typDeklaracji int, @dknId int)
RETURNS @Result TABLE(VaN_VaNId int , Rodzaj int, Odliczenia int , Flaga int , Stawka decimal(15,2), Netto decimal(15,2), Vat decimal(15,2), VaNId_P int, SumNetto_P decimal(15,2), SumVat_P decimal(15,2))
AS
BEGIN
 if @typRejestru = 1 -- zakupy
 begin
  insert into @Result(VaN_VaNId, Rodzaj, Odliczenia, Flaga, Stawka, Netto, Vat)
  select VaN_VaNId, VaT_RodzajZakupu as Rodzaj, VaT_Odliczenia as Odliczenia, VaT_Flaga as Flaga, VaT_Stawka as Stawka, sum(VaT_NettoWal) as Netto, Sum(VaT_VATWal) as Vat
  from
  cdn.VatNag join CDN.VatTab on (VaT_VaNId = VaN_VaNId)
  where
  VaN_VaNId in (
   select VaZ_VaNId_ZK from cdn.vatzd join cdn.DeklNag on (VaZ_DkNId = DkN_DkNID )
   where
   VaZ_VaNId_ZK is Not Null
   and DkN_Finalna = 0
   and DkN_RokMiesiac=@rokMiesiac
   and DkN_TypDeklar = @typDeklaracji
   and VaZ_VaNId not in ( select VaZ_VaNId from cdn.vatzd join cdn.DeklNag on (VaZ_DkNId = DkN_DkNID) where DkN_DkNId = @dknId)
  )
  group by VaN_VaNId, VaT_RodzajZakupu, VaT_Odliczenia, VaT_Flaga, VaT_Stawka order by VaN_VaNId
 end
 else
 begin
  insert into @Result(VaN_VaNId, Rodzaj, Odliczenia, Flaga, Stawka, Netto, Vat)
        select VaN_VaNId, 1 as Rodzaj, VaT_Odliczenia as Odliczenia, VaT_Flaga as Flaga, VaT_Stawka as Stawka, sum(VaT_NettoWal) as Netto, Sum(VaT_VATWal) as Vat
  from cdn.VatNag join CDN.VatTab on (VaT_VaNId = VaN_VaNId)
        where
  VaN_VaNId in (
   select VaZ_VaNId_ZK from cdn.vatzd join cdn.DeklNag on (VaZ_DkNId = DkN_DkNID)
   where
   VaZ_VaNId_ZK is Not Null
   and DkN_Finalna = 0
   and DkN_RokMiesiac=@rokMiesiac
   and DkN_TypDeklar = @typDeklaracji
   and VaZ_VaNId not in (select VaZ_VaNId from cdn.vatzd join cdn.DeklNag on (VaZ_DkNId = DkN_DkNID) where DkN_DkNId = @dknId)
        )
        group by VaN_VaNId, VaT_Odliczenia, VaT_Flaga, VaT_Stawka order by VaN_VaNId
 end
 update @Result set VaNId_P = VaZ_VaNId
 from
 @Result join CDN.VatZD on (VaZ_VaNId_ZK = VaN_VaNId)
 join cdn.DeklNag on (DkN_Finalna=0 and DkN_RokMiesiac = @rokMiesiac and DkN_TypDeklar = @typDeklaracji and VAZ_DkNId = DkN_DkNID);
 update O
 set
 O.SumVat_P = (select sum(I.Vat) from  @Result I where I.VaNId_P = O.VaNId_P and I.Rodzaj=O.Rodzaj and I.Odliczenia = O.Odliczenia and I.Flaga=O.Flaga and I.Stawka=O.Stawka),
 O.SumNetto_P = (select sum(I.Netto) from  @Result I where I.VaNId_P = O.VaNId_P and I.Rodzaj=O.Rodzaj and I.Odliczenia = O.Odliczenia and I.Flaga=O.Flaga and I.Stawka=O.Stawka)
 from
 @Result O;
 WITH CTE AS(
    SELECT VaNId_P,
     RN = ROW_NUMBER()OVER(PARTITION BY Rodzaj, Odliczenia, Flaga, Stawka, VaNId_P, SumNetto_P, SumVat_P ORDER BY VaN_VaNId desc)
    FROM @Result
 )
 DELETE FROM CTE WHERE RN > 1
 return
 end
