CREATE FUNCTION CDN.VATZD_PozycjeVat(@DataZestawienia DateTime, @McKw INT, @Typ INT, @DknId INT, @SprzedazStawkaNP INT, @ZakupStawkaZero INT)
RETURNS @Result TABLE( BZdId    int,
      VaN_VaNId   int,
      VaN_Typ    int,
      VaN_TrNId   int,
      SumaKwotZdarzen  decimal(15,2),
      SumaKwotRozliczen decimal(15,2),
      VaN_KntNazwa1  nvarchar(255),
      VaN_KntNazwa2  nvarchar(255),
      VaN_KntNazwa3  nvarchar(255),
      VaN_KntNipE   nvarchar(20),
      VaN_Dokument  nvarchar(256),
      VaN_DataWys   DateTime,
      bzd_TerminR   DateTime,
      bzd_Termin   DateTime,
      RazemNetto   decimal(15,2),
      RazemVAT   decimal(15,2),
      RazemBrutto   decimal(15,2),
      VaT_RodzajZakupu int, --  tylko dla zakupĂłw
      VaT_Odliczenia  int, --  tylko dla zakupĂłw
      VaT_Flaga   int,
      VaT_Stawka   decimal(15,2),
      Netto    decimal(15,2),
      VAT     decimal(15,2),
      Brutto    decimal(15,2) )
AS
BEGIN
 declare @REJESTR_ZAKUPOW int
 declare @REJESTR_SPRZEDAZY int
 set @REJESTR_ZAKUPOW = 1
 set @REJESTR_SPRZEDAZY = 2
 if @Typ = @REJESTR_ZAKUPOW
 begin
  insert into @Result
  select  BZdId,
     VaN_VaNId, VaN_Typ, VaN_TrNId, SumaKwotZdarzen, SumaKwotRozliczen,
     VaN_KntNazwa1, VaN_KntNazwa2, VaN_KntNazwa3, VaN_KntNipE,
     VaN_Dokument,VaN_DataWys, Termin, TerminPlatnosci,
     VaN_RazemNettoDoVAT As RazemNetto, VaN_RazemVATDoVAT as RazemVAT, VaN_RazemBruttoDoVAT as RazemBrutto,
     VaT_RodzajZakupu, --  tylko dla zakupĂłw
     VaT_Odliczenia,  --  tylko dla zakupĂłw
     VaT_Flaga,
     VaT_Stawka,
     Sum(VaT_NettoDoVAT) as Netto, Sum(VaT_VATDoVAT) as VAT, Sum(VaT_NettoDoVAT + VaT_VATDoVAT) as Brutto
  from  CDN.VATZD_Zobowiazania(@dataZestawienia, @McKw, @Typ, @DknId, NULL, 1)
     join CDN.VatNag on (VaN_VaNId = VaNId)
     join CDN.VatTab on (Vat_VaNId = VaN_VaNId)
  where  VaT_Odliczenia <> 0
     and ( ((VaT_Flaga <> 2 and VaT_Flaga <> 3) or VaT_Stawka <> 0) or 1=@ZakupStawkaZero) -- stawka zero 0%
     and (VaT_Flaga <> 1 and VaT_Flaga <> 4 or VaT_Stawka <> 0) -- pomijamy NP i ZW
  group by BZdId,
     VaN_VaNId, VaN_Typ, VaN_TrNId, SumaKwotZdarzen, SumaKwotRozliczen,
     VaN_KntNazwa1, VaN_KntNazwa2, VaN_KntNazwa3, VaN_KntNipE,
     VaN_Dokument,VaN_DataWys, Termin, TerminPlatnosci,
     VaN_RazemNettoDoVAT , VaN_RazemVATDoVAT , VaN_RazemBruttoDoVAT ,
     VaT_RodzajZakupu, --
     VaT_Odliczenia,  --  tylko dla zakupĂłw
     VaT_Flaga,
     VaT_Stawka
  order by Termin asc
 end
 else if @Typ = @REJESTR_SPRZEDAZY
 begin
  insert into @Result
  select  BZdId,
     VaN_VaNId, VaN_Typ, VaN_TrNId, SumaKwotZdarzen, SumaKwotRozliczen,
     VaN_KntNazwa1, VaN_KntNazwa2, VaN_KntNazwa3, VaN_KntNipE,
     VaN_Dokument,VaN_DataWys, Termin, TerminPlatnosci,
     VaN_RazemNettoDoVAT As RazemNetto, VaN_RazemVATDoVAT as RazemVAT, VaN_RazemBruttoDoVAT as RazemBrutto,
     VaT_RodzajZakupu,  --
     1,     -- odliczenia dla przedaĹĽy na tak
     VaT_Flaga,
     VaT_Stawka,
     Sum(VaT_NettoDoVAT) as Netto, Sum(VaT_VATDoVAT) as VAT, Sum(VaT_NettoDoVAT + VaT_VATDoVAT) as Brutto
  from  CDN.VATZD_Zobowiazania(@dataZestawienia, @McKw, @Typ, @DknId, NULL, 1)
     join CDN.VatNag on (VaN_VaNId = VaNId)
     join CDN.VatTab on (Vat_VaNId = VaN_VaNId)
  where  --VaT_Odliczenia <> 0 and
     ((VaT_Flaga <> 4 or VaT_Stawka <> 0) or 1=@SprzedazStawkaNP)-- stawka NP
  group by BZdId,
     VaN_VaNId, VaN_Typ, VaN_TrNId, SumaKwotZdarzen, SumaKwotRozliczen,
     VaN_KntNazwa1, VaN_KntNazwa2, VaN_KntNazwa3, VaN_KntNipE,
     VaN_Dokument,VaN_DataWys, Termin, TerminPlatnosci,
     VaN_RazemNettoDoVAT , VaN_RazemVATDoVAT , VaN_RazemBruttoDoVAT ,
     VaT_RodzajZakupu,
     VaT_Flaga,
     VaT_Stawka
  order by Termin asc
 end
 return
END
