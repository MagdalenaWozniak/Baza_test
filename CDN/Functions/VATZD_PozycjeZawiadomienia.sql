CREATE FUNCTION CDN.VATZD_PozycjeZawiadomienia(@DknId INT, @McKw INT, @DataZestawienia DateTime, @ZestawienieNaDzien DateTime, @Typ INT, @SprzedazStawkaNP INT, @ZakupStawkaZero INT)
RETURNS @Result TABLE(
      BZdId    int,
      VaN_VaNId   int,
      VaN_Typ    int,
      VaN_TrNId   int,
      bzd_TerminR   DateTime,
      SumaKwotZdarzen  decimal(15,2),
      SumaKwotRozliczen decimal(15,2),
      VaN_KntNazwa1  nvarchar(255),
      VaN_KntNazwa2  nvarchar(255),
      VaN_KntNazwa3  nvarchar(255),
      VaN_KntNipE   nvarchar(20),
      VaN_Dokument  nvarchar(256),
      VaN_DataWys   DateTime,
      VaN_Termin   DateTime,
      RazemNetto   decimal(15,2),
      RazemVAT   decimal(15,2),
      RazemBrutto   decimal(15,2),
      VaT_RodzajZakupu int, --  tylko dla zakupĂłw
      VaT_Odliczenia  int, --  tylko dla zakupĂłw
      VaT_Flaga   int,
      VaT_Stawka   decimal(15,2),
      Netto    decimal(15,2),
      VAT     decimal(15,2),
      Brutto    decimal(15,2),
      PoprzednioDoRoliczenia   decimal(15,2),
      PoprzednioRozliczono   decimal(15,2),
      DoRoliczeniaNaDzienObliczenia decimal(15,2),
      RoliczonoNaDzienObliczenia  decimal(15,2),
        /*PP dodany indeks do tabeli tymczasowej*/
        Uniqueifier INT NOT NULL IDENTITY(1,1),
        PRIMARY KEY CLUSTERED (BZdId, bzd_TerminR, Uniqueifier)
      )
AS
BEGIN
 -- @DknId podczas liczenia korekty ktĂłra jeszcze nie dostaĹ‚a ID po jest nowa @DknId ma miec wartoĹ›Ä‡ ID korygowanej.
 declare @REJESTR_ZAKUPOW int
 declare @REJESTR_SPRZEDAZY int
 set @REJESTR_ZAKUPOW = 1
 set @REJESTR_SPRZEDAZY = 2
 declare @M decimal(15,2)
 if @Typ = @REJESTR_ZAKUPOW
 begin
  Set @M = -1
 end
 else
 begin
  Set @M = 1
 end
 if @Typ = @REJESTR_ZAKUPOW --or 1=1
 begin
  insert into @Result
  select pv.BZdId,
    VaN_VaNId,
    VaN_Typ,
    VaN_TrNId,
    bzd_TerminR,
    @M * SumaKwotZdarzen,
    @M * SumaKwotRozliczen,
    VaN_KntNazwa1,
    VaN_KntNazwa2,
    VaN_KntNazwa3,
    VaN_KntNipE,
    VaN_Dokument,
    VaN_DataWys,
    bzd_Termin,
    RazemNetto,
    RazemVAT,
    RazemBrutto,
    VaT_RodzajZakupu,
    VaT_Odliczenia,
    VaT_Flaga,
    VaT_Stawka,
    Netto,
    VAT,
    Brutto,
    IsNull(CDN.VATZD_PoprzedniaKwotaDoRozliczeniaNaDzien (pv.van_vanid, pv.BZdId, VaN_Typ, bzd_TerminR, @DataZestawienia), 0.00),
    IsNull(CDN.VATZD_PoprzedniaKwotaRozliczonaNaDzien  (pv.van_vanid, pv.BZdId, VaN_Typ, bzd_TerminR, @DataZestawienia), 0.00),
    @M * IsNull(KwotaDoRozliczeniaNaDzien, 0.00),
    @M * IsNull(KwotaRozliczonaNaDzien,  0.00)
  from CDN.VATZD_PozycjeVat(@DataZestawienia, @McKw, @Typ, @DknId, @SprzedazStawkaNP , @ZakupStawkaZero) pv
  inner join CDN.[VATZD_KwotyRozliczeniaNaDzien_PP](@Typ, @ZestawienieNaDzien, @McKw, @DknId ) kwoty on pv.BZdId=kwoty.BZdId
  where kwoty.Termin = pv.bzd_TerminR
 end
 else
 begin
  insert into @Result
  select BZdId,
    VaN_VaNId,
    VaN_Typ,
    VaN_TrNId,
    bzd_TerminR,
    @M * SumaKwotZdarzen,
    @M * SumaKwotRozliczen,
    VaN_KntNazwa1,
    VaN_KntNazwa2,
    VaN_KntNazwa3,
    VaN_KntNipE,
    VaN_Dokument,
    VaN_DataWys,
    bzd_Termin,
    RazemNetto,
    RazemVAT,
    RazemBrutto,
    VaT_RodzajZakupu,
    VaT_Odliczenia,
    VaT_Flaga,
    VaT_Stawka,
    Netto,
    VAT,
    Brutto,
    IsNull(CDN.VATZD_PoprzedniaKwotaDoRozliczeniaNaDzien (van_vanid, BZdId, VaN_Typ, bzd_TerminR, @DataZestawienia), 0.00),
    IsNull(CDN.VATZD_PoprzedniaKwotaRozliczonaNaDzien  (van_vanid, BZdId, VaN_Typ, bzd_TerminR, @DataZestawienia), 0.00),
    0.00,
    0.00
    --@M * IsNull(KwotaDoRozliczeniaNaDzien, 0.00),
    --@M * IsNull(KwotaRozliczonaNaDzien,  0.00)
  from CDN.VATZD_PozycjeVat(@DataZestawienia, @McKw, @Typ, @DknId, @SprzedazStawkaNP , @ZakupStawkaZero)
  declare @deklaracje_finalne Table (BZdId int)
  insert into @deklaracje_finalne
  select distinct VaZ_BZdId from cdn.VATZD join CDN.DeklNag on (VaZ_DkNId=DkN_DkNID) where DkN_Finalna = 1 and DkN_DkNID <> @DknId
  update @Result Set DoRoliczeniaNaDzienObliczenia = @M * IsNull(KwotaDoRozliczeniaNaDzien, 0.00),
                        RoliczonoNaDzienObliczenia  = @M * IsNull(KwotaRozliczonaNaDzien,  0.00)
  from
    @Result r INNER JOIN CDN.VATZD_KwotyRozliczeniaNaDzien_PP(@Typ,  @ZestawienieNaDzien, @McKw, @DknId) kwoty on r.BZdId=kwoty.BZdId
    where r.bzd_TerminR = kwoty.Termin and not exists(select * from @deklaracje_finalne where BZdId = r.BZdId)
  --@Result r CROSS APPLY CDN.VATZD_KwotyRozliczeniaNaDzien(r.BZdId, VaN_Typ, bzd_TerminR,  @ZestawienieNaDzien)
  --where not exists(select * from cdn.VATZD join CDN.DeklNag on (VaZ_DkNId=DkN_DkNID) where DkN_Finalna = 1 and DkN_DkNID <> @DknId and VaZ_VaNId = VaN_VaNID and VaZ_BZdId = r.BZdId)
  declare @ZND DateTime; set @ZND = @DataZestawienia
  update @Result Set DoRoliczeniaNaDzienObliczenia = @M * IsNull(KwotaDoRozliczeniaNaDzien, 0.00),
                        RoliczonoNaDzienObliczenia  = @M * IsNull(KwotaRozliczonaNaDzien,  0.00)
  from
    @Result r INNER JOIN CDN.VATZD_KwotyRozliczeniaNaDzien_PP(@Typ,  @ZND, @McKw, @DknId) kwoty on r.BZdId=kwoty.BZdId
    where r.bzd_TerminR = kwoty.Termin and exists(select * from @deklaracje_finalne where BZdId = r.BZdId)
  --from
  --@Result r CROSS APPLY CDN.VATZD_KwotyRozliczeniaNaDzien(r.BZdId, VaN_Typ, bzd_TerminR,  @ZND)
  --where exists(select * from cdn.VATZD join CDN.DeklNag on (VaZ_DkNId=DkN_DkNID) where DkN_Finalna = 1 and DkN_DkNID <> @DknId and VaZ_VaNId = VaN_VaNID and VaZ_BZdId = r.BZdId)
 end
  --return;
 -- usuniÄ™cie pozycji ktĂłre nie przypadajÄ… na okres deklaracji
 declare @dateLimit DateTime = convert(DateTime, '2019-01-01', 120);
 declare @limit int = 90;
 declare @dateOd90 DateTime;
 declare @dateDo90 DateTime;
 declare @dateOd150 DateTime;
 declare @dateDo150 DateTime;
 declare @opoznienie90A int = 90;
 declare @opoznienie90B int = 90;
 declare @opoznienie150A int = 150;
 declare @opoznienie150B int = 150;
 if @McKw = 1
 begin
  set @dateOd90 = DateAdd(Day, -@opoznienie90B, DateAdd(Day, -Day(@DataZestawienia)+1,  @DataZestawienia) );
  set @dateDo90 = DateAdd(Day, -@opoznienie90A, @DataZestawienia);
  set @dateOd150 = DateAdd(Day, -@opoznienie150B, DateAdd(Day, -Day(@DataZestawienia)+1,  @DataZestawienia) );
  set @dateDo150 = DateAdd(Day, -@opoznienie150A, @DataZestawienia);
 end
 else
 begin
  set @dateOd90 = DateAdd(Month, -2, DateAdd(Day, 0, DateAdd(Day, -Day(@DataZestawienia)+1,  @DataZestawienia) ));
  set @dateDo90 = @DataZestawienia;
  set @dateOd150 = DateAdd(Month, -2, DateAdd(Day, 0, DateAdd(Day, -Day(@DataZestawienia)+1,  @DataZestawienia) ));
  set @dateDo150 = @DataZestawienia;
  set @dateOd90 = DateAdd(Day, -@opoznienie90B, @dateOd90 );
  set @dateDo90 = DateAdd(Day, -@opoznienie90A, @DataZestawienia);
  set @dateOd150 = DateAdd(Day, -@opoznienie150B, @dateOd150 );
  set @dateDo150 = DateAdd(Day, -@opoznienie150A, @DataZestawienia);
 end
 -- usuwamy powiÄ…zane tylko poprzez VANId
 /*
 delete r
 from @Result r
 join CDN.VATZD_KwotyRozliczeniaNaDzien_PP(@Typ,  @ZestawienieNaDzien, @McKw, @DknId) kwoty on (r.VaN_VaNId=kwoty.VaNId)
 where
 kwoty.BZdId is null
 and r.bzd_TerminR = kwoty.Termin
 and DateAdd(Day, @limit, bzd_TerminR) >= @dateLimit and bzd_TerminR not between @dateOd90 and @dateDo90
 and PoprzednioRozliczono=KwotaRozliczonaNaDzien
 delete r
 from @Result r
 join CDN.VATZD_KwotyRozliczeniaNaDzien_PP(@Typ,  @ZestawienieNaDzien, @McKw, @DknId) kwoty on (r.VaN_VaNId=kwoty.VaNId)
 where
 kwoty.BZdId is null
 and r.bzd_TerminR = kwoty.Termin
 and DateAdd(Day, @limit, bzd_TerminR) < @dateLimit and bzd_TerminR not between @dateOd150 and @dateDo150
 and PoprzednioRozliczono=KwotaRozliczonaNaDzien
  */
 -- usuwamy powiÄ…zane poprzez BZdId
 /*
 delete from @Result
 where
 DateAdd(Day, @limit, bzd_TerminR) >= @dateLimit and bzd_TerminR not between @dateOd90 and @dateDo90
 and PoprzednioRozliczono=SumaKwotZdarzen
 delete from @Result
 where
 DateAdd(Day, @limit, bzd_TerminR) < @dateLimit and bzd_TerminR not between @dateOd150 and @dateDo150
 and PoprzednioRozliczono=SumaKwotZdarzen
  */
 delete r
 from @Result r
 join CDN.VATZD_KwotyRozliczeniaNaDzien_PP(@Typ,  @ZestawienieNaDzien, @McKw, @DknId) kwoty on (r.BZdId=kwoty.BZdId)
 where r.bzd_TerminR = kwoty.Termin
 and DateAdd(Day, @limit, bzd_TerminR) >= @dateLimit and bzd_TerminR not between @dateOd90 and @dateDo90
 and PoprzednioRozliczono=SumaKwotRozliczen
 delete r
 from @Result r
 join CDN.VATZD_KwotyRozliczeniaNaDzien_PP(@Typ,  @ZestawienieNaDzien, @McKw, @DknId) kwoty on (r.BZdId=kwoty.BZdId)
 where r.bzd_TerminR = kwoty.Termin
 and DateAdd(Day, @limit, bzd_TerminR) < @dateLimit and bzd_TerminR not between @dateOd150 and @dateDo150
 and PoprzednioRozliczono=SumaKwotRozliczen
 return
END
