Create Procedure CDN.KontoSlownikowe @ParId Int, @SloTyp Int, @SloId Int, @OpeId Int, @StaId Int, @Waluta NVARCHAR(3)= NULL
As
Begin
 Set NoCount On
 If IsNull(@SloTyp,0)=0 Or IsNull(@SloId,0)=0
  Begin
   exec CDN.RiseOptimaException 32536
   Return
  End
 If Not Exists (Select * From CDN.Konta Where Acc_AccId = @ParId)
  Begin
   exec CDN.RiseOptimaException 32537
   Return
  End
 Declare
  @ParOObId    Int,
  @ParNumer    NVARCHAR(50),
  @ParSegment  NVARCHAR(20),
  @ParGrupy    Int,
  @ParSloTyp   Int,
  @ParTypKonta Int,
  @ParRozrach  Int,
  @ParSaldo    Int,
  @SloKod      NVARCHAR(20),
  @SloNazwa    NVARCHAR(50),
  @SloGrupa    NVARCHAR(20),
  @SloNip      NVARCHAR(20),
  @Numer       NVARCHAR(50),
  @Nazwa       NVARCHAR(50),
  @AccId       Int,
  @NumerAcc    NVARCHAR(50),
  @Nieaktywne  TinyInt,
  @SubAnalWal  TinyInt,
  @Analityka   TinyInt
 Set @Waluta = IsNull(@Waluta, '')
 Set @SubAnalWal = 0
 Select
  @ParOObId    = Acc_OObId,
  @ParNumer    = Acc_Numer,
  @ParSegment  = Acc_Segment,
  @ParGrupy    = Acc_SlownikGrupa,
  @ParSloTyp   = Acc_Slownik,
  @ParTypKonta = Acc_TypKonta,
  @ParRozrach  = Acc_Rozrachunkowe,
  @ParSaldo    = Acc_KontrolaSalda
 From CDN.Konta Where Acc_AccId = @ParId
 If Not (@SloTyp = @ParSloTyp)
  Begin
   exec CDN.RiseOptimaException 32538
   Return
  End
 Set @SloKod = Null
 --If @SloTyp In (1,2,3,5)
 -- Begin
 -- Select @SloKod = Pod_Kod, @SloNazwa = Pod_Nazwa1, @SloGrupa = Pod_Grupa, @SloNip = Replace (Pod_NIP, '-', '')
 --   From CDN.PodmiotyView Where Pod_PodmiotTyp = @SloTyp And Pod_PodId = @SloId
 -- End
 If @SloTyp In (1,2,5)
  Begin
   Select @SloKod = Pod_Kod, @SloNazwa = Pod_Nazwa1, @SloGrupa = Pod_Grupa, @SloNip = replace(case when IsNull(POD_NIP, '') <> '' then POD_NIP else POD_PESEL end, '-','')
    From CDN.PodmiotyView Where Pod_PodmiotTyp = @SloTyp And Pod_PodId = @SloId
  End
 Else If @SloTyp = 3
  Begin
   Select @SloKod = Pod_Kod, @SloNazwa = Pod_Nazwa1+' '+Pod_Nazwa2, @SloGrupa = Pod_Grupa, @SloNip = replace(case when IsNull(POD_NIP, '') <> '' then POD_NIP else POD_PESEL end, '-','')
    From CDN.PodmiotyView Where Pod_PodmiotTyp = @SloTyp And Pod_PodId = @SloId
  End
 Else If @SloTyp = 6
  Begin
   Select @SloKod = SrT_NrInwent, @SloNazwa = SrT_Nazwa, @SloGrupa = SrT_Grupa, @SloNip = SrT_NrInwent
    From CDN.Trwale Where SrT_SrTId = @SloId
  End
 Else If @SloTyp = 7
  Begin
  Select @SloKod = Twr_Kod, @SloNazwa = Twr_Nazwa, @SloGrupa = IsNull(TwG_Kod,''), @SloNip = Twr_Kod
    From CDN.Towary Left Outer Join CDN.TwrGrupy On TwG_GIDTyp = -16 AND TwG_GIDNumer = Twr_TwGGIDNumer
    Where Twr_TwrId = @SloId
  End
 Else
  Begin
   exec CDN.RiseOptimaException 32539
   Return
  End
 If @SloKod Is Null
  Begin
   exec CDN.RiseOptimaException 32540
   Return
  End
 If @ParGrupy <> 0
  Begin
   Set @SloGrupa = RTrim(@SloGrupa)
   If @SloGrupa = ''
    Begin
     exec CDN.RiseOptimaException 32541
     Return
    End
   If @ParGrupy = 1
    Begin
     If Exists (Select * From CDN.Konta Where Acc_ParId = @ParId And Acc_Segment = CDN.UsunNiedozwoloneZnaki(@SloGrupa, 1))
      Begin
       Select @ParId = Acc_AccId, @ParNumer = Acc_Numer From CDN.Konta Where Acc_ParId = @ParId And Acc_Segment = CDN.UsunNiedozwoloneZnaki(@SloGrupa, 1)
      End
     Else If Exists (Select * From CDN.Konta Where Acc_ParId = @ParId And Acc_Segment = CDN.UsunNiedozwoloneZnaki(@SloGrupa, 1))
      Begin
       Select @ParId = Acc_AccId, @ParNumer = Acc_Numer From CDN.Konta Where Acc_ParId = @ParId And Acc_Segment = CDN.UsunNiedozwoloneZnaki(@SloGrupa, 1)
      End
     Else
      Begin
       Set @ParNumer = @ParNumer + '-' + CDN.UsunNiedozwoloneZnaki(@SloGrupa, 1)
       Set @Nazwa = 'Grupa: [' + @SloGrupa + ']'
       exec CDN.DodajKonto
        @OObId  = @ParOObId,
        @Numer  = @ParNumer,
        @Nazwa  = @Nazwa,
        @TypKonta = @ParTypKonta,
        @Rozrachunkowe = @ParRozrach,
        @KontrolaSalda = @ParSaldo,
        @Slownik = @SloTyp,
        @SlownikGrupa = 2,
        @SlownikTyp = Null,
        @SlownikId = Null,
        @OpeId  = @OpeId,
        @StaId  = @StaId,
  @OutID  = @ParId output
      End
    End
   Else If @ParGrupy = 2
    Begin
     If  @ParSegment <> CDN.UsunNiedozwoloneZnaki(@SloGrupa, 1)
     And @ParSegment <> CDN.UsunNiedozwoloneZnaki(@SloGrupa, 1)
     Begin
      exec CDN.RiseOptimaException 32542
      Return
     End
    End
  End
 Set @AccId = Null
 Select @AccId = Acc_AccId, @NumerAcc = Acc_Numer, @Nieaktywne = Acc_Nieaktywne, @Analityka = Acc_Analityka From CDN.Konta
  Where Acc_ParId = @ParId And Acc_SlownikTyp = @SloTyp And Acc_SlownikId = @SloId And Acc_Waluta = @Waluta
 If @AccId Is Not Null
  Begin
    If @Analityka = 1
      Begin
        Set NoCount Off
        Select AccId = @AccId, Numer = @NumerAcc, Nieaktywne = @Nieaktywne
        Return
      End
    Else
      Begin
        exec CDN.RiseOptimaException 32543, 's1', @NumerAcc
        Return
      End
  End
 If @Waluta <> ''
  Begin
   Set @AccId = Null
   Select @AccId = B.Acc_AccId, @NumerAcc = B.Acc_Numer, @Nieaktywne = B.Acc_Nieaktywne
    From CDN.Konta A Join CDN.Konta B On A.Acc_AccId = B.Acc_ParId
    Where A.Acc_ParId = @ParId And A.Acc_SlownikTyp = @SloTyp And A.Acc_SlownikId = @SloId And B.Acc_Waluta = @Waluta
   If @AccId Is Not Null
    Begin
     Set NoCount Off
     Select AccId = @AccId, Numer = @NumerAcc, Nieaktywne = @Nieaktywne
     Return
    End
  End
 Declare @Auto Char(1), @TypAuto Char(1)
 Select @Auto = Cast (Fir_Wartosc As Char(1)) From CDN.Firma Where Fir_Numer = 245
 If @Auto <> '1'
  Begin
   exec CDN.RiseOptimaException 32544
   Return
  End
 If @Waluta <> '' And Exists (Select * From CDN.Firma Where Fir_Numer = 1684 And Fir_Wartosc='1')
  Begin
   Set @SubAnalWal = 1
   Set @AccId = Null
   Select @AccId = Acc_AccId, @NumerAcc = Acc_Numer From CDN.Konta Where Acc_ParId = @ParId And Acc_SlownikTyp = @SloTyp And Acc_SlownikId = @SloId And Acc_Waluta=''
    And Not Exists (Select * From CDN.DekretyKonta Where DeK_AccId = Acc_AccId)
   If @AccId Is Not Null
    Begin
     Set @Numer = @NumerAcc + '-' + CDN.UsunNiedozwoloneZnaki(@Waluta, 1)
     exec CDN.DodajKonto
      @OObId  = @ParOObId,
      @Numer  = @Numer,
      @Nazwa  = @SloNazwa,
      @TypKonta  = @ParTypKonta,
      @Rozrachunkowe = @ParRozrach,
      @KontrolaSalda = @ParSaldo,
      @Slownik  = 0,
      @SlownikGrupa  = 0,
      @SlownikTyp  = @SloTyp,
      @SlownikId  = @SloId,
      @OpeId  = @OpeId,
      @StaId  = @StaId,
      @Waluta       = @Waluta,
   @OutID  = @AccId output
     Set NoCount Off
     Select AccId = @AccId, Numer = @Numer, Nieaktywne = 0
     Return
    End
  End
   If @SloTyp In (1,3)
    Select @TypAuto = Cast (Fir_Wartosc As Char(1)) From CDN.Firma Where Fir_Numer = 246
   Else
    Select @TypAuto = Cast (Fir_Wartosc As Char(1)) From CDN.Firma Where Fir_Numer = 1585
   If @TypAuto = '1'
    Begin
     Set @Numer = LTrim(RTrim(Str(@SloId)))
    End
   Else If @TypAuto = '2'
    Begin
     Set @Numer = CDN.UsunNiedozwoloneZnaki(@SloKod, 1)
     Set @AccId = Null
     Select @AccId = Acc_AccId, @NumerAcc = Acc_Numer, @Nieaktywne = Acc_Nieaktywne From CDN.Konta
     Where Acc_ParId = @ParId And Acc_SlownikId Is Null And Acc_Segment = @Numer
     If @AccId Is Not Null
      Begin
       Update CDN.Konta Set Acc_SlownikTyp = @SloTyp, Acc_SlownikId = @SloId Where Acc_AccId = @AccId
       Set NoCount Off
       Select AccId = @AccId, Numer = @NumerAcc, Nieaktywne = @Nieaktywne
       Return
      End
     If Exists (Select * From CDN.Konta Where Acc_ParId = @ParId And Acc_Segment = @Numer)
      Begin
       Declare @NumerTmp NVARCHAR(20), @Lp Int
       Set @Lp = 1
       While @Lp<100
        Begin
         Set @NumerTmp = Cast(@Numer As NVARCHAR(17)) + '_' + LTrim(Str(@Lp))
         If Not Exists (Select * From CDN.Konta Where Acc_ParId = @ParId And Acc_Segment = @NumerTmp) Break
         Set @Lp = @Lp + 1
        End
       If @Lp = 100
        Begin
         exec CDN.RiseOptimaException 32545
         Return
        End
       Else
        Set @Numer = @NumerTmp
      End
    End
   Else If @TypAuto = '3'
    Begin
     Set @Numer = CDN.UsunNiedozwoloneZnaki(@SloNip, 1)
    End
   Else
    Begin
     exec CDN.RiseOptimaException 32546
     Return
    End
 If @Numer = ''
  Begin
   exec CDN.RiseOptimaException 32547
   Return
  End
 Set @Numer = @ParNumer + '-' + @Numer
 If @SubAnalWal = 1
  Begin
   exec CDN.DodajKonto
    @OObId  = @ParOObId,
    @Numer  = @Numer,
    @Nazwa  = @SloNazwa,
    @TypKonta  = @ParTypKonta,
    @Rozrachunkowe = @ParRozrach,
    @KontrolaSalda = @ParSaldo,
    @Slownik  = 0,
    @SlownikGrupa = 0,
    @SlownikTyp  = @SloTyp,
    @SlownikId  = @SloId,
    @OpeId  = @OpeId,
    @StaId  = @StaId,
    @Waluta       = ''
   Set @Numer = @Numer + '-' + @Waluta
  End
 exec CDN.DodajKonto
  @OObId  = @ParOObId,
  @Numer  = @Numer,
  @Nazwa  = @SloNazwa,
  @TypKonta  = @ParTypKonta,
  @Rozrachunkowe = @ParRozrach,
  @KontrolaSalda = @ParSaldo,
  @Slownik  = 0,
  @SlownikGrupa = 0,
  @SlownikTyp  = @SloTyp,
  @SlownikId  = @SloId,
  @OpeId  = @OpeId,
  @StaId  = @StaId,
  @Waluta       = @Waluta,
  @OutID  = @AccId output
 Set NoCount Off
 Select AccId = @AccId, Numer = @Numer, Nieaktywne = 0
 Return
End
