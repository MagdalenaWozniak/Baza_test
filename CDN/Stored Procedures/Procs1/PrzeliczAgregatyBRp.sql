CREATE PROCEDURE [CDN].[PrzeliczAgregatyBRp]
AS
BEGIN
  SET NOCOUNT ON;
  Begin Transaction
  Alter Table CDN.BnkRaporty Disable Trigger All
  Declare @BRp_BRaId_Prev           Int
  Declare @BRp_Zamkniety_Prev       Int
  Declare @BRa_Saldo                Decimal (15,2)
  Declare @BRa_SaldoSys             Decimal (15,2)
  Declare @BRp_BRpID                Int
  Declare @BRp_BRaId                Int
  Declare @BRp_DataDok              DateTime
  Declare @BRa_Waluta               varchar(3)
  Declare @BRp_Zamkniety            Int
  Declare @BRa_StanPoczatkowy       Decimal (15,2)
  Declare @BRa_StanPoczatkowySys    Decimal (15,2)
  Declare @PrzychodyCalc            Decimal (15,2)
  Declare @RozchodyCalc             Decimal (15,2)
  Declare @PrzychodyCalcSys         Decimal (15,2)
  Declare @RozchodyCalcSys          Decimal (15,2)
  Declare @RoznicaKursowaSysMWCalc Decimal (15,2)
  Set @BRp_BRaId_Prev     = 0
  Set @BRp_Zamkniety_Prev = 0
  Set @BRa_Saldo          = 0
  Set @BRa_SaldoSys       = 0
  Declare cur_BnkRaporty Cursor Local Fast_Forward For
  select
  BRp_BRpID, BRp_BRaId, BRp_DataDok, BRa_Waluta, BRp_Zamkniety,
  BRa_SaldoBO     as BRa_StanPoczatkowy,
  BRa_SaldoBOSys  as BRa_StanPoczatkowySys,
  IsNull(Sum(Case IsNull(BZp_Kierunek, 0) When 1  Then 1 Else 0 End *
    Case BRa_Waluta When '' Then IsNull(BZp_KwotaSys, 0) Else IsNull(BZp_Kwota, 0) End), 0)   as PrzychodyCalc,
  IsNull(Sum(Case IsNull(BZp_Kierunek, 0) When -1 Then 1 Else 0 End *
    Case BRa_Waluta When '' Then IsNull(BZp_KwotaSys, 0) Else IsNull(BZp_Kwota, 0) End), 0)   as RozchodyCalc,
  IsNull(Sum(Case IsNull(BZp_Kierunek, 0) When 1  Then 1 Else 0 End * IsNULL(BZp_KwotaSys,0)), 0)  as PrzychodyCalcSys,
  IsNull(Sum(Case IsNull(BZp_Kierunek, 0) When -1 Then 1 Else 0 End * IsNULL(BZp_KwotaSys,0)), 0) as RozchodyCalcSys,
  BRp_RoznicaKursowaSysMW as RoznicaKursowaSysMWCalc
  from
  CDN.BnkRaporty
  left outer join CDN.BnkZapisy   on (BRp_BRpID=BZp_BRpID)
  left outer join CDN.BnkRachunki on (BRp_BRaID=BRa_BRaID)
  group by BRp_BRpID, BRp_BRaId, BRp_DataDok, BRa_Waluta, BRp_Zamkniety, BRa_SaldoBO,BRa_SaldoBOSys, BRp_RoznicaKursowaSysMW
  order by BRp_BRaId, BRp_DataDok
  Open cur_BnkRaporty
  While 1 = 1
  Begin
    Fetch Next From cur_BnkRaporty InTo @BRp_BRpID,
                                        @BRp_BRaId,
                                        @BRp_DataDok,
                                        @BRa_Waluta,
                                        @BRp_Zamkniety,
                                        @BRa_StanPoczatkowy,
                                        @BRa_StanPoczatkowySys,
                                        @PrzychodyCalc,
                                        @RozchodyCalc,
                                        @PrzychodyCalcSys,
                                        @RozchodyCalcSys,
                                        @RoznicaKursowaSysMWCalc
    If @@Fetch_Status <> 0 Break
    if (@BRp_BRaId_Prev <> @BRp_BRaId) -- nowy rejestr kasowo bankowy, przepisanie kwot poczatkowych
      Begin
          Set @BRa_Saldo      = @BRa_StanPoczatkowy
          Set @BRa_SaldoSys   = @BRa_StanPoczatkowySys
          Set @BRp_BRaId_Prev = @BRp_BRaId
      End
    Else
      Begin
        if (@BRp_Zamkniety = 0 And @BRp_Zamkniety_Prev = 0)
          Begin
            Set @BRa_Saldo    = 0
            Set @BRa_SaldoSys = 0
          End
      End
    Update CDN.BnkRaporty Set BRp_SaldoBO       = @BRa_Saldo,
                              BRp_SaldoBOSys    = @BRa_SaldoSys,
                              BRp_Przychody     = @PrzychodyCalc,
                              BRp_PrzychodySys  = @PrzychodyCalcSys,
                              BRp_Rozchody      = @RozchodyCalc,
                              BRp_RozchodySys   = @RozchodyCalcSys
    Where BRp_BRpId = @BRp_BRpID
    -- wyliczenie stanu poczatkowego dla kolejnego raportu
    Set @BRa_Saldo    = @BRa_Saldo    + @PrzychodyCalc    - @RozchodyCalc
    Set @BRa_SaldoSys = @BRa_SaldoSys + @PrzychodyCalcSys - @RozchodyCalcSys + @RoznicaKursowaSysMWCalc
    -- zapamietane stanu zamkniety/otwarty
    Set @BRp_Zamkniety_Prev = @BRp_Zamkniety
    If @@Error <> 0
    Begin
      If @@Trancount > 0
        Rollback Tran
        Break
    End
  End --While 1 = 1
  Close cur_BnkRaporty
  Deallocate cur_BnkRaporty
  Alter Table CDN.BnkRaporty Enable Trigger All
  If @@Trancount > 0
    Commit Tran
  Set NoCount OFF
END
