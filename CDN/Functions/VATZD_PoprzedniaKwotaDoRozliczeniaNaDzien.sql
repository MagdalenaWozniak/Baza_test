CREATE FUNCTION CDN.VATZD_PoprzedniaKwotaDoRozliczeniaNaDzien( @VaNId int, @BZdId int, @Typ INT, @TerminPlatnosci DateTime, @data DateTime )
RETURNS decimal(15,2)
AS
BEGIN
 declare @result decimal(15,2)
 declare @typDeklaracji int
 declare @yyyymm int
 set @typDeklaracji = 401 + @Typ -- @Typ=(1..2); mamy, 402 zakupowa; 403 sprzedazowa
 set @yyyymm = 100*year(@data) + month(@data)
 if exists( select Top 1 VaZ_SumaKwotZdarzen
    from cdn.deklnag
    join cdn.VATZD on (DkN_DkNId = VaZ_DkNId)
    join cdn.DeklElem on (DkN_DkNId = DkE_DkNId and DkE_Numer = 1)
    where
    DkN_TypDeklar = @typDeklaracji
    --and DkN_RokMiesiac < @yyyymm and DkN_Finalna = 1 and DkN_Zablokowana <> 0
    and DkN_RokMiesiac < @yyyymm and DkN_Zablokowana <> 0
    and VaZ_BZdId = @BZdId
    and VaZ_Termin = @TerminPlatnosci
    and (IsNull(DkE_WartoscL, 0) <> 0 or VaZ_VaNId_ZK Is Not Null) )
  select Top 1 @result = VaZ_SumaKwotZdarzen
  from cdn.deklnag
  join cdn.VATZD on (DkN_DkNId = VaZ_DkNId)
  join cdn.DeklElem on (DkN_DkNId = DkE_DkNId and DkE_Numer = 1)
  where
  DkN_TypDeklar = @typDeklaracji
  --and DkN_RokMiesiac < @yyyymm and DkN_Finalna = 1 and DkN_Zablokowana <> 0
  and DkN_RokMiesiac < @yyyymm and DkN_Zablokowana <> 0
  and VaZ_BZdId = @BZdId
  and VaZ_Termin = @TerminPlatnosci
  and (IsNull(DkE_WartoscL, 0) <> 0 or VaZ_VaNId_ZK Is Not Null)
  order by DkN_RokMiesiac desc
 else
  select Top 1 @result = VaZ_SumaKwotZdarzen
  from cdn.deklnag
  join cdn.VATZD on (DkN_DkNId = VaZ_DkNId)
  join cdn.DeklElem on (DkN_DkNId = DkE_DkNId and DkE_Numer = 1)
  where
  DkN_TypDeklar = @typDeklaracji
  --and DkN_RokMiesiac < @yyyymm and DkN_Finalna = 1 and DkN_Zablokowana <> 0
  and DkN_RokMiesiac < @yyyymm and DkN_Zablokowana <> 0
  and VaZ_VaNId = @VaNId
  and VaZ_Termin = @TerminPlatnosci
  and (IsNull(DkE_WartoscL, 0) <> 0 or VaZ_VaNId_ZK Is Not Null)
  order by DkN_RokMiesiac desc
 RETURN @result
END
