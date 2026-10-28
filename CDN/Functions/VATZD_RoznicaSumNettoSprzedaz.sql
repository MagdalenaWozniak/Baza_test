CREATE FUNCTION CDN.VATZD_RoznicaSumNettoSprzedaz( @DkNId int, @Rodzaj int, @Odliczenia int, @Stawka decimal(15,2), @Flaga int)
RETURNS decimal(15,2)
AS
BEGIN
 if @Stawka = 0 return 0
 declare @result decimal(15,2)
 declare @Rab decimal(15,2)
 declare @Ra decimal(15,2)
 declare @Rb decimal(15,2)
 declare @stawkaP decimal(15,2)
      if @Stawka = 3 set @stawkaP = 5
 else if @Stawka = 5 set @stawkaP = 3
 else if @Stawka = 7 set @stawkaP = 8
 else if @Stawka = 8 set @stawkaP = 7
 else if @Stawka = 22 set @stawkaP = 23
 else if @Stawka = 23 set @stawkaP = 22
 else set @stawkaP = 0
 if not exists( select * from CDN.VatZd
     where
     VaZ_DkNId = @DkNId
     and CDN.VATZD_Rodzaj( VaZ_Typ, VaZ_RodzajZakupu) = @Rodzaj
     and VaZ_Odliczenia = @Odliczenia
     and VaZ_Stawka = @StawkaP and vaZ_Flaga = @Flaga )
  return 0
 if @stawkaP >  @Stawka
  return 0
 select @Rab = sum(VaZ_KorektaNetto) from CDN.VatZD
 where
 VaZ_DkNId = @DkNId
 and CDN.VATZD_Rodzaj( VaZ_Typ, VaZ_RodzajZakupu) = @Rodzaj
 and VaZ_Odliczenia = @Odliczenia
 and (VaZ_Stawka = @Stawka or VaZ_Stawka = @stawkaP)and vaZ_Flaga = @Flaga
 select @Ra = sum(VaZ_KorektaNetto) from CDN.VatZD
 where
 VaZ_DkNId = @DkNId
 and CDN.VATZD_Rodzaj( VaZ_Typ, VaZ_RodzajZakupu) = @Rodzaj
 and VaZ_Odliczenia = @Odliczenia
 and VaZ_Stawka = @Stawka and vaZ_Flaga = @Flaga
 select @Rb = sum(VaZ_KorektaNetto) from CDN.VatZD
 where
 VaZ_DkNId = @DkNId
 and CDN.VATZD_Rodzaj( VaZ_Typ, VaZ_RodzajZakupu) = @Rodzaj
 and VaZ_Odliczenia = @Odliczenia
 and VaZ_Stawka = @stawkaP and vaZ_Flaga = @Flaga
 set @Rab = cast( @Rab as decimal(15,0) )
 set @Ra  = cast( @Ra  as decimal(15,0) )
 set @Rb  = cast( @Rb  as decimal(15,0) )
 return @Rab - (@Ra+@Rb)
END
