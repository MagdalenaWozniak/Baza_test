Create Procedure CDN.GenerujVatTab7 @VaNId Int
As
Begin
Set NoCount On
Declare @VaNTyp Int, @DeklRokMies Int, @VaNData DateTime, @VaNDataOpe DateTime, @AutoVat7 Int, @TrNId Int, @RozliczacVat Int, @Wewnetrzna smallint, @MyIdentity Int
DECLARE @DataNowejObslugi DATETIME, @RodzajTransakcji TINYINT, @PodatnikVATCzynny TINYINT, @NowaObsluga INT, @Finalny TINYINT, @Waluta varchar(3), @KursDoKsi TinyInt
DECLARE @KursLDoVAT DECIMAL(15,4), @KursMDoVAT DECIMAL(5,0), @RazemBruttoDoVAT DECIMAL (15,2), @MetodaKasowa INT
SET @DataNowejObslugi = CONVERT(DATETIME, '2013-01-01', 120)
Select
 @VaNTyp = VaN_Typ,
 @NowaObsluga = CASE WHEN DATEDIFF(day, @DataNowejObslugi, VaN_DataZap) < 0 THEN 0 ELSE 1 END,
 @DeklRokMies = VaN_DeklRokMiesKasa,
 @VaNData = case when Year(VaN_DataZap) < 2014 then VaN_DataZap else case when van_typ=1 then VaN_DataPrawaOdliczenia else VaN_DataObowiazkuPodatkowego end end,
 @VaNDataOpe = VaN_DataOpe,
 @AutoVat7 = VaN_AutoVat7Kasa,
 @TrNId = IsNull(VaN_TrNId,0),
 @RozliczacVat = VaN_RozliczacVat7,
 @RodzajTransakcji = VaN_Export,
 @PodatnikVATCzynny = VaN_PodatekVAT,
 @Finalny = VaN_Finalny,
 @Wewnetrzna = VaN_Wewnetrzna,
 @Waluta = VaN_Waluta,
 @KursDoKsi = VaN_KursDoKsiegowania,
 @KursLDoVAT = VaN_KursLDoVAT,
 @KursMDoVAT = CASE VaN_KursMDoVAT WHEN 0 THEN 1 ELSE VaN_KursMDoVAT END,
 @RazemBruttoDoVAT = VaN_RazemBruttoDoVAT,
 @MetodaKasowa = VaN_MetodaKasowa
From CDN.VatNag Where VaN_VaNId = @VaNId
--SET @NowaObsluga = CASE WHEN DATEDIFF(day, @DataNowejObslugi, @VaNData) < 0 THEN 0 ELSE 1 END
If @VaNTyp = 1
Begin
 IF @NowaObsluga = 0
 BEGIN
  If @AutoVat7 = 0 Return
  Declare @DataRoz DateTime, @ObliczRokMies Int
  Set @DataRoz = Null
  If @TrnId = 0
  Begin
   If Not Exists (Select * From CDN.BnkZdarzenia Where BZd_DokumentTyp = 2 And BZd_DokumentId = @VaNId And BZd_Rozliczono < 2)
    Select @DataRoz = Max(IsNull(BZd_DataRoz,0.00)) From CDN.BnkZdarzenia Where BZd_DokumentTyp = 2 And BZd_DokumentId = @VaNId
  End
  Else
  Begin
   If Not Exists (Select * From CDN.BnkZdarzenia Join CDN.TraNag On BZd_DokumentTyp = 1 And BZd_DokumentId = TrN_TrNId Where TrN_VaNId = @VaNId And BZd_Rozliczono < 2)
    Select @DataRoz = Max(IsNull(BZd_DataRoz,0.00)) From CDN.BnkZdarzenia Join CDN.TraNag On BZd_DokumentTyp = 1 And BZd_DokumentId = TrN_TrNId Where TrN_VaNId = @VaNId
  End
  Set @ObliczRokMies = IsNull (100 * Year(@DataRoz) + Month(@DataRoz), 0)
  If @ObliczRokMies <> @DeklRokMies
   Update CDN.VatNag Set VaN_DeklRokMiesKasa = @ObliczRokMies Where VaN_VaNId = @VaNId
  Set NoCount Off
  Return
 END
End
If @AutoVat7 = 0
Begin
 IF @Wewnetrzna <> 0
  RETURN
 If Exists (
  Select * From
  (Select VaT_Stawka, VaT_Flaga, VaT_Zrodlowa, VaT_RodzajZakupu, Sum(VaT_NettoDoVAT) As VaT_RazemNetto, Sum(VaT_VatDoVAT) As VaT_RazemVat
  From CDN.VatTab
  Where VaT_VaNId=@VaNId
  Group By VaT_Stawka, VaT_Flaga, VaT_Zrodlowa, VaT_RodzajZakupu) As V1
  Full Outer Join
  (Select Va7_Stawka, Va7_Flaga, Va7_Zrodlowa, Va7_RodzajZakupu, Sum(Va7_Netto) As Va7_RazemNetto, Sum(Va7_Vat) As Va7_RazemVat
  From CDN.VatTab7
  Where Va7_VaNId=@VaNId
  Group By Va7_Stawka, Va7_Flaga, Va7_Zrodlowa, Va7_RodzajZakupu) As V2
  On VaT_Stawka = Va7_Stawka And VaT_Flaga = Va7_Flaga And VaT_Zrodlowa = Va7_Zrodlowa And VaT_RodzajZakupu = Va7_RodzajZakupu
  Where IsNull(VaT_RazemNetto,0) <> IsNull(Va7_RazemNetto,0) Or IsNull(VaT_RazemVat,0) <> IsNull(Va7_RazemVat,0))
 Begin
  exec CDN.RiseOptimaException 32016
  If @@TranCount <> 0 RollBack Tran
  Set NoCount Off
  Return
 End
 Set NoCount Off
 RETURN
End
Begin
 Set @MyIdentity = @@IDENTITY
 Delete From CDN.VatTab7 Where Va7_VaNId = @VaNId
 Declare @RokMiesTemp Int, @Va7Id Int
 Declare @Stawka Numeric(15,2), @Flaga Int, @Zrodlowa Numeric(15,2), @RodzajZakupu Int, @Odliczenia SmallInt
 Declare @NettoJest Numeric(15,2), @VatJest Numeric(15,2)
 Set Identity_Insert CDN.VatTab7 On
 Select @Va7Id = IsNull(Max(Va7_Va7Id),0) From CDN.VatTab7
 IF @RodzajTransakcji NOT IN (0, 5) AND NOT (@VanTyp = 2 AND @MetodaKasowa = 1)
 BEGIN
  SET @RokMiesTemp = 100*YEAR(@VaNData)+MONTH(@VaNData)
  DECLARE Stawki CURSOR LOCAL FAST_FORWARD FOR
   SELECT VaT_Stawka, VaT_Flaga, VaT_Zrodlowa, VaT_RodzajZakupu, VaT_Odliczenia, SUM(VaT_NettoDoVAT), SUM(VaT_VATDoVAT) FROM CDN.VatTab WHERE VaT_VaNID = @VaNId
   GROUP BY VaT_Stawka, VaT_Flaga, VaT_Zrodlowa, VaT_RodzajZakupu, VaT_Odliczenia
  OPEN Stawki
  WHILE 1=1
  BEGIN
   FETCH NEXT FROM Stawki INTO @Stawka, @Flaga, @Zrodlowa, @RodzajZakupu, @Odliczenia, @NettoJest, @VatJest
   IF @@FETCH_STATUS <> 0 BREAK
   SET @Va7Id = @Va7Id + 1
   INSERT INTO CDN.VatTab7 (Va7_Va7ID, Va7_VaNID, Va7_RokMiesiac, Va7_Stawka, Va7_Flaga, Va7_Zrodlowa, Va7_RodzajZakupu, Va7_Odliczenia, Va7_Netto,  Va7_VAT )
   VALUES     (@Va7Id,    @VaNID,    @RokMiesTemp,   @Stawka,    @Flaga,    @Zrodlowa,    @RodzajZakupu,   @Odliczenia,    @NettoJest, @VatJest)
  END
  CLOSE Stawki
  DEALLOCATE Stawki
 END
 ELSE
 BEGIN
    DECLARE @KwotaCalk Numeric(15,2), @mnoznik SMALLINT
   SET @mnoznik=CASE @vanTyp WHEN 1 THEN -1 ELSE 1 END;
    If @TrNId = 0
      Select @KwotaCalk = IsNull(Sum(BZd_KwotaSys*Bzd_Kierunek*@mnoznik),0) From CDN.BnkZdarzenia Where BZd_DokumentTyp=2 And BZd_DokumentId=@VaNId
    Else
      Select @KwotaCalk = IsNull(Sum(BZd_KwotaSys*Bzd_Kierunek*@mnoznik),0) From CDN.BnkZdarzenia Join CDN.TraNag On BZd_DokumentTyp=1 And BZd_DokumentId=TrN_TrNId Where TrN_VaNId=@VaNId
   IF @KwotaCalk <> 0
  BEGIN
   Declare @DataStop DateTime, @DataTemp DateTime, @RokMiesStop Int
   Declare @KwotaRozl DECIMAL(15,2), @KwotaRozlDoVAT DECIMAL(15,2), @KwotaTmp Numeric(15,2), @KwotaTmp2 Numeric(15,2)
   Declare @NettoRazem Numeric(15,2), @VatRazem Numeric(15,2)
   Declare @NettoObl Numeric(15,2), @VatObl Numeric(15,2), @BruttoNar DECIMAL(15,2)
   Declare @Rok Int, @Miesiac Int, @LiczProporcjeZKursowWalut TinyInt
   SET @KwotaRozl = 0;
   SET @KwotaRozlDoVAT = 0;
   IF @VanTyp = 1 OR (@VanTyp = 2 AND ((@NowaObsluga = 1 AND @Finalny = 0 AND @PodatnikVATCzynny = 1) OR @MetodaKasowa = 1) )
    Set @RokMiesStop = 999999;
   ELSE
   BEGIN
    IF @NowaObsluga = 0
     SET @DataStop = DateAdd(day, 90, @VaNDataOpe)
    ELSE
     SET @DataStop = DateAdd(day, 180, @VaNDataOpe)
    SET @RokMiesStop = 100*Year(@DataStop)+Month(@DataStop)
   END
      IF @Waluta <> CDN.Waluta('') AND @KursDoKsi <> 0
        SET @LiczProporcjeZKursowWalut = 1;
      ELSE
        SET @LiczProporcjeZKursowWalut = 0;
   IF @LiczProporcjeZKursowWalut = 0
   BEGIN
        If @TrNId = 0
          Declare Rozliczenia Cursor Local Fast_Forward For
            SELECT SUM(Kwota) AS Kwota, Rok, Miesiac FROM (
              SELECT IsNull(Sum( (CASE WHEN BRK_LDokTyp=1 AND BRK_LDokID=BZd_BZdID THEN BRK_KwotaSysL ELSE BRK_KwotaSysP END) * Bzd_Kierunek * @mnoznik),0) AS Kwota, YEAR(BRK_DataDok) AS Rok, MONTH(BRK_DataDok) AS Miesiac
              From CDN.BnkZdarzenia
              Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
              Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
              WHERE BZd_DokumentTyp = 2 And BZd_DokumentId = @VaNId
              GROUP BY YEAR(BRK_DataDok), MONTH(BRK_DataDok)
              UNION ALL
              SELECT 0, CAST(@RokMiesStop/100 AS INT), @RokMiesStop % 100 WHERE @RokMiesStop <> 999999
            ) AS InnerFrom
            GROUP BY Rok, Miesiac
            ORDER BY Rok ASC, Miesiac ASC
        Else
          Declare Rozliczenia Cursor Local Fast_Forward For
            SELECT SUM(Kwota) AS Kwota, Rok, Miesiac FROM (
              SELECT IsNull(Sum( (CASE WHEN BRK_LDokTyp=1 AND BRK_LDokID=BZd_BZdID THEN BRK_KwotaSysL ELSE BRK_KwotaSysP END) * Bzd_Kierunek * @mnoznik),0) AS Kwota, YEAR(BRK_DataDok) AS Rok, MONTH(BRK_DataDok) AS Miesiac
              From CDN.BnkZdarzenia
              Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
              Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
              Join CDN.TraNag On BZd_DokumentTyp=1 And BZd_DokumentId=TrN_TrNId
              Where TrN_VaNId=@VaNId
              GROUP BY YEAR(BRK_DataDok), MONTH(BRK_DataDok)
              UNION ALL
              SELECT 0, CAST(@RokMiesStop/100 AS INT), @RokMiesStop % 100 WHERE @RokMiesStop <> 999999
            ) AS InnerFrom
            GROUP BY Rok, Miesiac
            ORDER BY Rok ASC, Miesiac ASC
      END
      ELSE
      BEGIN
        If @TrNId = 0
          Declare Rozliczenia Cursor Local Fast_Forward For
            SELECT SUM(Kwota) AS Kwota, Rok, Miesiac FROM (
              SELECT IsNull(Sum( BRK_Kwota * Bzd_Kierunek * @mnoznik),0) AS Kwota, YEAR(BRK_DataDok) AS Rok, MONTH(BRK_DataDok) AS Miesiac
              From CDN.BnkZdarzenia
              Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
              Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
              WHERE BZd_DokumentTyp = 2 And BZd_DokumentId = @VaNId
              GROUP BY YEAR(BRK_DataDok), MONTH(BRK_DataDok)
              UNION ALL
              SELECT 0, CAST(@RokMiesStop/100 AS INT), @RokMiesStop % 100 WHERE @RokMiesStop <> 999999
            ) AS InnerFrom
            GROUP BY Rok, Miesiac
            ORDER BY Rok ASC, Miesiac ASC
        Else
          Declare Rozliczenia Cursor Local Fast_Forward For
            SELECT SUM(Kwota) AS Kwota, Rok, Miesiac FROM (
              SELECT IsNull(Sum( BRK_Kwota * Bzd_Kierunek * @mnoznik),0) AS Kwota, YEAR(BRK_DataDok) AS Rok, MONTH(BRK_DataDok) AS Miesiac
              From CDN.BnkZdarzenia
              Join CDN.BnkRozRelacje On BRR_ZDokTyp = 1 And BRR_ZDokId = BZd_BZdId
              Join CDN.BnkRozKwoty   On BRK_BRKId = BRR_BRKId
              Join CDN.TraNag On BZd_DokumentTyp=1 And BZd_DokumentId=TrN_TrNId
              Where TrN_VaNId=@VaNId
              GROUP BY YEAR(BRK_DataDok), MONTH(BRK_DataDok)
              UNION ALL
              SELECT 0, CAST(@RokMiesStop/100 AS INT), @RokMiesStop % 100 WHERE @RokMiesStop <> 999999
            ) AS InnerFrom
            GROUP BY Rok, Miesiac
            ORDER BY Rok ASC, Miesiac ASC
        If @TrNId = 0
          Select @KwotaCalk = IsNull(Sum(BZd_Kwota*Bzd_Kierunek*@mnoznik),0) From CDN.BnkZdarzenia Where BZd_DokumentTyp=2 And BZd_DokumentId=@VaNId
        Else
          Select @KwotaCalk = IsNull(Sum(BZd_Kwota*Bzd_Kierunek*@mnoznik),0) From CDN.BnkZdarzenia Join CDN.TraNag On BZd_DokumentTyp=1 And BZd_DokumentId=TrN_TrNId Where TrN_VaNId=@VaNId
      END
   Open Rozliczenia
   While 1=1
   Begin
    Fetch Next From Rozliczenia InTo @KwotaTmp, @Rok, @Miesiac
     If @@Fetch_Status <> 0 Break
    Set @KwotaRozl = @KwotaRozl + @KwotaTmp
    Set @KwotaRozlDoVAT = @KwotaRozlDoVAT + ((@KwotaTmp * @KursLDoVAT) / @KursMDoVAT)
    Set @RokMiesTemp = @Rok * 100 + @Miesiac
    Set @BruttoNar = 0
    IF @RokMiesTemp = @RokMiesStop
    BEGIN
     SET @KwotaRozlDoVAT = @RazemBruttoDoVAT
     SET @KwotaRozl = @KwotaCalk
    END
    Declare Stawki Cursor Local Fast_Forward For
     Select VaT_Stawka, VaT_Flaga, VaT_Zrodlowa, VaT_RodzajZakupu, VaT_Odliczenia, Sum(VaT_NettoDoVAT), Sum(VaT_VatDoVAT)
     From CDN.VatTab
     Where VaT_VaNId = @VaNId
     Group By VaT_Stawka, VaT_Flaga, VaT_Zrodlowa, VaT_RodzajZakupu, VaT_Odliczenia
     Order By Sum(Abs(VaT_NettoDoVAT))
    Open Stawki
    While 1=1
    Begin
     Fetch Next From Stawki InTo @Stawka, @Flaga, @Zrodlowa, @RodzajZakupu, @Odliczenia, @NettoRazem, @VatRazem
     If @@Fetch_Status <> 0 Break
     Set @NettoObl  = (@KwotaRozl / @KwotaCalk) * @NettoRazem
     Set @VatObl    = (@KwotaRozl / @KwotaCalk) * @VatRazem
     Set @BruttoNar = @BruttoNar + @NettoObl + @VatObl
     Select @NettoJest = Sum(Va7_Netto), @VatJest = Sum(Va7_Vat)
     From CDN.VatTab7
     Where Va7_VaNId=@VaNId And Va7_Stawka=@Stawka And Va7_Flaga=@Flaga And Va7_Zrodlowa=@Zrodlowa And Va7_RodzajZakupu = @RodzajZakupu And Va7_Odliczenia = @Odliczenia
      And Va7_RokMiesiac <= @RokMiesTemp
     If (@NettoJest IS NULL AND (@NettoObl <> 0 OR @VatObl <> 0)) OR @NettoJest<>@NettoObl Or @VatJest<>@VatObl
     Begin
      Set @Va7Id = @Va7Id + 1
      Set @NettoJest=ISNULL(@NettoJest,0)
      Set @VatJest=ISNULL(@VatJest,0)
      Insert Into CDN.VatTab7 (Va7_Va7Id, Va7_VaNID, Va7_RokMiesiac, Va7_Stawka, Va7_Flaga, Va7_Zrodlowa, Va7_RodzajZakupu, Va7_Odliczenia, Va7_Netto,            Va7_VAT)
           Values (@Va7Id,    @VaNId,    @RokMiesTemp,   @Stawka,    @Flaga,    @Zrodlowa,    @RodzajZakupu, @Odliczenia,    @NettoObl-@NettoJest, @VatObl-@VatJest)
     End
    End
    Close Stawki
    Deallocate Stawki
    if @LiczProporcjeZKursowWalut = 0
            SET @KwotaRozlDoVAT = @KwotaRozl
    ELSE if @KwotaRozl = @KwotaCalk
            SET @KwotaRozlDoVAT = @RazemBruttoDoVAT
    If @BruttoNar <> @KwotaRozlDoVAT
     Update CDN.VatTab7 Set Va7_Netto = Va7_Netto + @KwotaRozlDoVAT - @BruttoNar Where Va7_Va7Id = @Va7Id
    IF @KwotaRozl = @KwotaCalk
     break
   End
   Close Rozliczenia
   Deallocate Rozliczenia
  END -- koniec: @KwotaCalk <> 0
 END
 IF EXISTS( SELECT VaT_Stawka, VaT_Flaga, VaT_Zrodlowa, VaT_RodzajZakupu, VaT_Odliczenia FROM CDN.VatTab WHERE VaT_VaNID = @VaNId
    GROUP BY VaT_Stawka, VaT_Flaga, VaT_Zrodlowa, VaT_RodzajZakupu, VaT_Odliczenia
    HAVING SUM(Vat_NettoDoVAT)=0 AND SUM(Vat_VatDoVAT)=0
    EXCEPT
    SELECT Va7_Stawka, Va7_Flaga, Va7_Zrodlowa, Va7_RodzajZakupu, Va7_Odliczenia FROM CDN.VatTab7 WHERE Va7_VaNID = @VaNId
    GROUP BY Va7_Stawka, Va7_Flaga, Va7_Zrodlowa, Va7_RodzajZakupu, Va7_Odliczenia)
 BEGIN
  Set @RokMiesTemp = 100*Year(@VaNData)+Month(@VaNData)
  Declare Stawki Cursor Local Fast_Forward For
   SELECT VaT_Stawka, VaT_Flaga, VaT_Zrodlowa, VaT_RodzajZakupu, VaT_Odliczenia FROM CDN.VatTab WHERE VaT_VaNID = @VaNId
   GROUP BY VaT_Stawka, VaT_Flaga, VaT_Zrodlowa, VaT_RodzajZakupu, VaT_Odliczenia
   HAVING SUM(Vat_NettoDoVAT)=0 AND SUM(Vat_VatDoVAT)=0
   EXCEPT
   SELECT Va7_Stawka, Va7_Flaga, Va7_Zrodlowa, Va7_RodzajZakupu, Va7_Odliczenia FROM CDN.VatTab7 WHERE Va7_VaNID = @VaNId
   GROUP BY Va7_Stawka, Va7_Flaga, Va7_Zrodlowa, Va7_RodzajZakupu, Va7_Odliczenia
  Open Stawki
  While 1=1
  Begin
   Fetch Next From Stawki InTo @Stawka, @Flaga, @Zrodlowa, @RodzajZakupu, @Odliczenia
   If @@Fetch_Status <> 0 Break
   Set @Va7Id = @Va7Id + 1
   INSERT INTO CDN.VatTab7 (Va7_Va7ID, Va7_VaNID, Va7_RokMiesiac, Va7_Stawka, Va7_Flaga, Va7_Zrodlowa, Va7_RodzajZakupu, Va7_Odliczenia, Va7_Netto, Va7_VAT)
   VALUES     (@Va7Id,    @VaNID,    @RokMiesTemp,   @Stawka,    @Flaga,    @Zrodlowa,    @RodzajZakupu,   @Odliczenia,    0,         0)
  End
  Close Stawki
  Deallocate Stawki
 END
 Set Identity_Insert CDN.VatTab7 Off
 IF @MyIdentity IS NOT NULL
 BEGIN
  Create Table #IdTmp ( Ident INT Identity )
  Set Identity_Insert #IdTmp On
  Insert InTo #IdTmp (Ident) Values (1)
  Set Identity_Insert #IdTmp Off
  Drop Table #IdTmp
 END
END
Set NoCount Off
End
