Create Function CDN.DeklTermin(@DkNId Int)
Returns Datetime
As
Begin
 Declare @Termin Datetime, @Typ Int, @Rok Int, @Mc Int, @Dzien Int
 Select @Typ = DkN_TypDeklar, @Rok = Floor(DkN_RokMiesiac / 100), @Mc = DkN_RokMiesiac % 100
 From CDN.DeklNag Where DkN_DkNId = @DkNId
 If IsNull(@Rok,0) = 0 Or IsNull(@Mc,0)=0 Return Null
 if @Typ = 401
  Set @Mc = @Mc + 2
 else
  Set @Mc = @Mc + 1
 If @Mc > 12
 Begin
  Set @Mc = @Mc % 12
  Set @Rok = @Rok + 1
 End
-- Ustalenie terminu dla deklaracji ZUS
 Declare @CfkId Int, @TerminTyp Int
 Set @CfkId = 1 --ROOT
 Select @CfkId = CFK_CfkId From CDN.CfgKlucze Where CFK_ParentId = @CfkId And CDN.EOMonth(100*@Rok+@Mc) Between CFK_OkresOd And CFK_OkresDo And CFK_Nazwa = 'ROOT2'
 Select @CfkId = CFK_CfkId From CDN.CfgKlucze Where CFK_ParentId = @CfkId And CDN.EOMonth(100*@Rok+@Mc) Between CFK_OkresOd And CFK_OkresDo And CFK_Nazwa = 'płace'
 Select @CfkId = CFK_CfkId From CDN.CfgKlucze Where CFK_ParentId = @CfkId And CDN.EOMonth(100*@Rok+@Mc) Between CFK_OkresOd And CFK_OkresDo And CFK_Nazwa = 'zus'
 Select @CfkId = CFK_CfkId From CDN.CfgKlucze Where CFK_ParentId = @CfkId And CDN.EOMonth(100*@Rok+@Mc) Between CFK_OkresOd And CFK_OkresDo And CFK_Nazwa = 'termin składania deklaracji'
 Select @TerminTyp = Case IsNumeric(CFW_Wartosc) When 1 Then Cast(CFW_Wartosc As Int) Else Null End From CDN.CfgWartosci Where CFW_CfkId = @CfkId
 Set @Dzien = Case
  When @Typ = 1   Then 25               -- Vat7
  When @Typ = 120 Then Case @TerminTyp When 1 Then 5 When 2 Then 10 Else 15 End -- DRA
  When @Typ = 401 Then 25               -- AKCWW
  When @Typ = 404 Then 25               -- Vat 9M
  When @Typ = 500 Then 15               -- PPK
  Else 20
  End
 Set @Termin = Convert (Datetime, Str(@Rok,4)+'-'+Replace(Str(@Mc,2),' ','0')+'-'+Replace(Str(@Dzien,2),' ','0'), 120)
 Return @Termin
End
