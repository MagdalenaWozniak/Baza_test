CREATE FUNCTION CDN.VATZD_StatusVatNag( @VaNId int)
RETURNS nvarchar(10)
AS
BEGIN
 declare @status nvarchar(10)
 set @status = ''
 if exists( select CDN.VATZD.* from
    cdn.vatnag
    join CDN.VATZD on (VaN_VaNId = VAZ_VaNId)
    join CDN.DeklNag on (VAZ_DkNId = DkN_DkNId)
    join CDN.DeklElem on (DkE_DkNId = DkN_DkNId)
    where
    VaN_VaNId = @VaNId
    and DkN_Finalna = 1
    and (DkE_Numer = 1 and IsNull(DkE_WartoscL, 0) <> 0 or VaZ_VaNId_ZK Is Not Null) and VaZ_SumaKwotZdarzen <> VaZ_SumaKwotRozliczen )
 begin
  set @status = 'TAK'
  if exists( select CDN.VATZD.* from
     cdn.vatnag
     join CDN.VATZD on (VaN_VaNId = VAZ_VaNId)
     join CDN.DeklNag on (VAZ_DkNId = DkN_DkNId)
     join CDN.DeklElem on (DkE_DkNId = DkN_DkNId)
     where
     VaN_VaNId = @VaNId
     and DkN_Finalna = 1
     and (DkE_Numer = 1 and IsNull(DkE_WartoscL, 0) <> 0 or VaZ_VaNId_ZK Is Not Null) and VaZ_SumaKwotRozliczen <> 0 )
  begin
   set @status = 'TAK!'
  end
  if exists( select CDN.VATZD.* from
     cdn.vatnag
     join CDN.VATZD on (VaN_VaNId = VAZ_VaNId)
     join CDN.DeklNag on (VAZ_DkNId = DkN_DkNId)
     join CDN.DeklElem on (DkE_DkNId = DkN_DkNId)
     where
     VaN_VaNId = @VaNId
     and DkN_Finalna = 1
     and (DkE_Numer = 1 and IsNull(DkE_WartoscL, 0) <> 0 or VaZ_VaNId_ZK Is Not Null) and VaZ_SumaKwotZdarzen = VaZ_SumaKwotRozliczen and VaZ_SumaKwotZdarzen <> 0)
  begin
   set @status = ''
  end
 end
 return @status
END
