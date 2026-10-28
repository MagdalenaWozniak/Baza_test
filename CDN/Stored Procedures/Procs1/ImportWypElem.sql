CREATE PROCEDURE CDN.ImportWypElem @WyNID INT, @Opis NVARCHAR(50), @Brutto DECIMAL(15,2), @R1 NVARCHAR(10), @UbEmerytPrac DECIMAL(15,2), @UbEmerytFir DECIMAL(15,2), @UbRentowPrac DECIMAL(15,2), @UbRentowFir DECIMAL(15,2), @UbChorobPrac DECIMAL(15,2), @UbWypadkFir DECIMAL(15,2), @UbZdrowo DECIMAL(15,2), @FGSP DECIMAL(15,2), @FEP DECIMAL(15,2), @FP DECIMAL(15,2), @Podatek DECIMAL(15,2), @Netto DECIMAL(15,2)
AS
BEGIN
 DECLARE @WyE_Wartosc DECIMAL(15,2);
 DECLARE @WyE_Koszt INT, @WyE_Opodatkowany INT, @WyE_UbEmeryt INT, @WyE_UbRentow INT, @WyE_UbChorob INT, @WyE_UbWypadk INT, @WyE_UbZdrowo INT
 IF(@R1 = 'NEP')
  SET @WyE_Wartosc = -@Brutto;
 ELSE
  SET @WyE_Wartosc = @Brutto;
 IF(@R1 = 'ZAS')
  SET @WyE_Koszt = 0;
 ELSE
  SET @WyE_Koszt = 1;
 IF @R1 <> 'NED' AND @R1 <> 'NEP' -- To zależy od rodzaju składnika
  SET @WyE_Opodatkowany = 1
 ELSE
  SET @WyE_Opodatkowany = 0
 IF @UbEmerytPrac<>0 OR @UbEmerytFir<>0
  SET @WyE_UbEmeryt = 1;
 ELSE
  SET @WyE_UbEmeryt = 0;
 IF @UbRentowPrac<>0 OR @UbRentowFir<>0
  SET @WyE_UbRentow = 1;
 ELSE
  SET @WyE_UbRentow = 0;
 IF @UbChorobPrac<>0
  SET @WyE_UbChorob = 1;
 ELSE
  SET @WyE_UbChorob = 0;
 IF @UbWypadkFir<>0
  SET @WyE_UbWypadk = 1;
 ELSE
  SET @WyE_UbWypadk = 0;
 IF @UbZdrowo<>0
  SET @WyE_UbZdrowo = 1;
 ELSE
  SET @WyE_UbZdrowo = 0;
 INSERT INTO CDN.WyplatyElem (
  WyE_WyNId,
  WyE_Kategoria,
  WyE_Wartosc,
  WyE_Gotowka,
  WyE_Koszt,
  WyE_Opodatkowany,
  WyE_UbEmeryt,
  WyE_UbRentow,
  WyE_UbChorob,
  WyE_UbWypadk,
  WyE_UbZdrowo,
  WyE_Potracenie
 )
 VALUES(
  @WyNID,
  @Opis,
  @WyE_Wartosc,
  1,
  @WyE_Koszt,
  @WyE_Opodatkowany,
  @WyE_UbEmeryt,
  @WyE_UbRentow,
  @WyE_UbChorob,
  @WyE_UbWypadk,
  @WyE_UbZdrowo,
  0
 )
  IF @R1 = 'NEP'       --Potrącenie nieopodatkowane - uwzględniamy ze znakiem minus
  BEGIN
 UPDATE CDN.WyplatyNag SET
  WyN_BruttoRazem    = WyN_BruttoRazem - @Brutto,
  WyN_BruttoKoszt    = WyN_BruttoKoszt - @Brutto,
  WyN_BruttoGotowka  = WyN_BruttoGotowka - @Brutto,
  WyN_UbEmerytPrac   = WyN_UbEmerytPrac - @UbEmerytPrac,
  WyN_UbEmerytFir    = WyN_UbEmerytFir - @UbEmerytFir,
  WyN_UbRentowPrac   = WyN_UbRentowPrac - @UbRentowPrac,
  WyN_UbRentowFir    = WyN_UbRentowFir - @UbRentowFir,
  WyN_UbChorobPrac   = WyN_UbChorobPrac - @UbChorobPrac,
  WyN_UbWypadkFir    = WyN_UbWypadkFir - @UbWypadkFir,
  WyN_PodstawaFGSP   = WyN_PodstawaFGSP - @FGSP,
  WyN_PodstawaFP     = WyN_PodstawaFP - @FP,
  WyN_KosztyUzyskania = 0,
  WyN_Podatek        = WyN_Podatek - (@UbZdrowo+@Podatek),
  WyN_UbZdrowotne    = WyN_UbZdrowotne - @UbZdrowo,
  WyN_Gotowka        = WyN_Gotowka - @Netto,
  WyN_SkladkaFEP     = WyN_SkladkaFEP - @FEP,
  WyN_PodstawaFEP    = WyN_PodstawaFEP - CASE WHEN @WyE_UbEmeryt = 1 AND @FEP <> 0 THEN @Brutto ELSE 0 END
 WHERE WyN_WyNId=@WyNID
  END
  ELSE          --Elementy zwiększające kwotę - ze znakiem +
  BEGIN
 UPDATE CDN.WyplatyNag SET
  WyN_BruttoRazem    = WyN_BruttoRazem + @Brutto,
  WyN_BruttoOpodat = WyN_BruttoOpodat + CASE WHEN @R1<>'NED' THEN @Brutto ELSE 0 END,
  WyN_BruttoKoszt  = WyN_BruttoKoszt + CASE WHEN @R1<>'ZAS' THEN @Brutto ELSE 0 END,
  WyN_BruttoGotowka  = WyN_BruttoGotowka + @Brutto,
  WyN_UbEmerytPrac   = WyN_UbEmerytPrac + @UbEmerytPrac,
  WyN_UbEmerytFir    = WyN_UbEmerytFir + @UbEmerytFir,
  WyN_UbRentowPrac   = WyN_UbRentowPrac + @UbRentowPrac,
  WyN_UbRentowFir    = WyN_UbRentowFir + @UbRentowFir,
  WyN_UbChorobPrac   = WyN_UbChorobPrac + @UbChorobPrac,
  WyN_UbWypadkFir    = WyN_UbWypadkFir + @UbWypadkFir,
  WyN_PodstawaFGSP   = WyN_PodstawaFGSP + @FGSP,
  WyN_PodstawaFP     = WyN_PodstawaFP + @FP,
  WyN_KosztyUzyskania = 0,
  WyN_Podatek        = WyN_Podatek + (@UbZdrowo+@Podatek),
  WyN_UbZdrowotne    = WyN_UbZdrowotne + @UbZdrowo,
  WyN_Gotowka        = WyN_Gotowka + @Netto,
  WyN_ZaliczkaUS     = WyN_ZaliczkaUS + @Podatek,
  WyN_SkladkaFEP     = WyN_SkladkaFEP + @FEP,
        WyN_PodstawaFEP    = WyN_PodstawaFEP + CASE WHEN @WyE_UbEmeryt = 1 and @FEP <> 0 THEN @Brutto ELSE 0 END
    WHERE WyN_WyNId = @WyNID
  END
END
