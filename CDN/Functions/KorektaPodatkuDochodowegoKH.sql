CREATE FUNCTION CDN.KorektaPodatkuDochodowegoKH(@Data DateTime, @Okres Int, @NaDzien Int, @DekId Int)
RETURNS @Result TABLE( DokumentId Int,
      DokumentTyp Int,
      Numer Varchar(30),
            Data DateTime,
            Kwota Decimal(15,2),
            Opis nvarchar(254),
      SumaKwotZdarzen Decimal(15,2),
      SumaKwotRozliczen Decimal(15,2),
      Rozliczono Int,
      DataKur DateTime,
      Waluta Varchar(3),
      KursL Decimal(15,4),
      KursM Decimal(5,0),
      KursNumer Int,
      DataWys DateTime,
      Termin DateTime)
AS
BEGIN
DECLARE @DataOtwarcia DateTime
DECLARE @DataKoncowa DateTime
SET @DataOtwarcia = (SELECT OOb_DataOtw FROM CDN.OkresyObrach WHERE OOb_OObID = @Okres)
--SET @DataKoncowa = (SELECT OOb_DataKoncowa FROM CDN.OkresyObrach WHERE OOb_OObID = @Okres)
IF @DataOtwarcia >= CONVERT(datetime, '2013-01-01', 120)
insert into @Result
SELECT Id,
    Typ,
    VaN_Dokument,
    DeN_DataWys,
    CAST(SUM(CASE WHEN VaT_Odliczenia = 0 THEN VaT_Netto + VaT_VAT ELSE VaT_Netto END)*(1 - (kwotaDokumentu - sumaKwotZdarzen + IsNull(sumaKwotRozliczen,0))/kwotaDokumentu) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id and DPD_Termin = Termin and DPD_Skreslony <> 1 and DPD_DekId <> @DekId and (DPD_DataKorekty <= @Data or DPD_DataKorekty is null)) AS decimal(15,2)),
    --CASE WHEN EXISTS (SELECT DPD_DPDID FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id)
   --THEN  CAST(((SELECT TOP 1 DPD_SumaKwotRozliczen FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota > 0 ORDER BY DPD_Kwota DESC) - IsNull(sumaKwotRozliczen, 0) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota < 0))*SUM(CASE WHEN VaT_Odliczenia = 0 THEN VaT_Netto + VaT_VAT ELSE VaT_Netto END)/sumaKwotZdarzen AS decimal(15,2))
   --ELSE CAST(SUM(CASE WHEN VaT_Odliczenia = 0 THEN VaT_Netto + VaT_VAT ELSE VaT_Netto END)*(1 - IsNull(sumaKwotRozliczen, 0)/sumaKwotZdarzen) AS decimal(15,2)) END,
    VaN_Kategoria,
    sumaKwotZdarzen,
    IsNull(sumaKwotRozliczen, 0),
    CASE WHEN IsNull(sumaKwotRozliczen, 0) = sumaKwotZdarzen THEN 1 ELSE 0 END,
    VaN_DataKur,
    VaN_Waluta,
    VaN_KursL,
    VaN_KursM,
    VaN_KursNumer,
    VaN_DataWys,
    Termin
FROM CDN.VatNag JOIN CDN.DokumentyDoKorekty(@Data) ON (VaN_VaNID = Id AND Typ = 2)
    JOIN CDN.DekretyNag ON VaN_DekID = DeN_DeNId
    JOIN CDN.VatTab ON VaT_VaNID = VaN_VaNID
    --JOIN CDN.OkresyObrach ON OOb_OObID = @Okres
WHERE DeN_DataDok >= CONVERT(datetime, '2013-01-01', 120)
    AND ((DATEDIFF(day, DeN_DataDok, Termin) <= 60 AND Opoznienie >= (CASE @NaDzien WHEN 1 THEN 30 ELSE 31 END)) OR (DATEDIFF(day, DeN_DataDok, Termin) > 60 AND DATEDIFF(day, DeN_DataDok, @Data) >= (CASE @NaDzien WHEN 1 THEN 90 ELSE 91 END)))
   --AND OOb_DataOtw >= CONVERT(datetime, '2013-01-01', 120)
   --AND DeN_DataDok BETWEEN @DataOtwarcia AND @DataKoncowa
   AND ((DeN_DataDok >= @DataOtwarcia AND @DataOtwarcia <= CONVERT(datetime, '2013-12-31', 120)) OR @DataOtwarcia >= CONVERT(datetime, '2014-01-01', 120))
   AND exists(select * from CDN.DekretyKonta join CDN.Konta on (Acc_KorektaKosztow <> 0 and Acc_AccId = DeK_AccID) where DeK_DeNId = DeN_DeNId)
GROUP BY Id, Typ, VaN_Dokument, DeN_DataDok, sumaKwotZdarzen, SumaKwotRozliczen, VaN_Kategoria, VaN_DataKur, VaN_Waluta, VaN_KursL, VaN_KursM, VaN_KursNumer, VaN_DataWys, Termin, kwotaDokumentu, DeN_DataWys
UNION
SELECT Id,
    Typ,
    CASE WHEN EDN_NumerObcy <> '' THEN EDN_NumerObcy ELSE EDN_NumerPelny END,
    DeN_DataWys,
    CAST(EDN_KwotaRazemSys*(1 - (kwotaDokumentu - sumaKwotZdarzen + IsNull(sumaKwotRozliczen,0))/kwotaDokumentu) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 12 AND DPD_DokumentID = Id and DPD_Termin = Termin and DPD_Skreslony <> 1 and DPD_DekId <> @DekId and (DPD_DataKorekty <= @Data or DPD_DataKorekty is null)) AS decimal(15,2)),
    --CASE WHEN EXISTS (SELECT DPD_DPDID FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id)
   --THEN  CAST(((SELECT TOP 1 DPD_SumaKwotRozliczen FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota > 0 ORDER BY DPD_Kwota DESC) - IsNull(sumaKwotRozliczen, 0) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota < 0))*EDN_KwotaRazemSys/sumaKwotZdarzen AS decimal(15,2))
   --ELSE CAST(EDN_KwotaRazemSys*(1 - IsNull(sumaKwotRozliczen, 0)/sumaKwotZdarzen) AS decimal(15,2)) END,
    EDN_Kategoria,
    sumaKwotZdarzen,
    IsNull(sumaKwotRozliczen, 0),
    CASE WHEN IsNull(sumaKwotRozliczen, 0) = sumaKwotZdarzen THEN 1 ELSE 0 END,
    EDN_DataKur,
    EDN_Waluta,
    EDN_KursL,
    EDN_KursM,
    EDN_KursNumer,
    EDN_DataWys,
    Termin
FROM CDN.EwidDodNag JOIN CDN.DokumentyDoKorekty(@Data) ON (EDN_EDNID = Id AND Typ = 12)
     JOIN CDN.DekretyNag  ON EDN_DekId = DeN_DeNId
     --JOIN CDN.OkresyObrach ON OOb_OObID = @Okres
WHERE DeN_DataDok >= CONVERT(datetime, '2013-01-01', 120)
   AND ((DATEDIFF(day, DeN_DataDok, Termin) <= 60 AND Opoznienie >= (CASE @NaDzien WHEN 1 THEN 30 ELSE 31 END)) OR (DATEDIFF(day, DeN_DataDok, Termin) > 60 AND DATEDIFF(day, DeN_DataDok, @Data) >= (CASE @NaDzien WHEN 1 THEN 90 ELSE 91 END)))
   --AND OOb_DataOtw >= CONVERT(datetime, '2013-01-01', 120)
   --AND DeN_DataDok BETWEEN @DataOtwarcia AND @DataKoncowa
   AND ((DeN_DataDok >= @DataOtwarcia AND @DataOtwarcia <= CONVERT(datetime, '2013-12-31', 120)) OR @DataOtwarcia >= CONVERT(datetime, '2014-01-01', 120))
   AND exists(select * from CDN.DekretyKonta join CDN.Konta on (Acc_KorektaKosztow <> 0 and Acc_AccId = DeK_AccID) where DeK_DeNId = DeN_DeNId)
UNION
SELECT Id,
    Typ,
    CASE WHEN TrN_NumerObcy <> '' THEN TrN_NumerObcy ELSE TrN_NumerPelny END,
    DeN_DataWys,
    CAST((CASE WHEN TrN_VaNId IS NOT NULL THEN SUM(CASE WHEN VaT_Odliczenia = 0 THEN VaT_Netto + VaT_VAT ELSE VaT_Netto END) ELSE TrN_RazemNetto END)*(1 - (kwotaDokumentu - sumaKwotZdarzen + IsNull(sumaKwotRozliczen,0))/kwotaDokumentu) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 1 AND DPD_DokumentID = Id and DPD_Termin = Termin and DPD_Skreslony <> 1 and DPD_DekId <> @DekId and (DPD_DataKorekty <= @Data or DPD_DataKorekty is null)) AS decimal(15,2)),
     --CASE WHEN EXISTS (SELECT DPD_DPDID FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id)
   --THEN  CAST(((SELECT TOP 1 DPD_SumaKwotRozliczen FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota > 0 ORDER BY DPD_Kwota DESC) - IsNull(sumaKwotRozliczen, 0) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota < 0))*(CASE WHEN TrN_VaNId IS NOT NULL THEN SUM(CASE WHEN VaT_Odliczenia = 0 THEN VaT_Netto + VaT_VAT ELSE VaT_Netto END) ELSE TrN_RazemNetto END)/sumaKwotZdarzen AS decimal(15,2))
   --ELSE CAST((CASE WHEN TrN_VaNId IS NOT NULL THEN SUM(CASE WHEN VaT_Odliczenia = 0 THEN VaT_Netto + VaT_VAT ELSE VaT_Netto END) ELSE TrN_RazemNetto END)*(1 - IsNull(sumaKwotRozliczen, 0)/sumaKwotZdarzen) AS decimal(15,2)) END,
    TrN_Kategoria,
    sumaKwotZdarzen,
    IsNull(sumaKwotRozliczen, 0),
    CASE WHEN IsNull(sumaKwotRozliczen, 0) = sumaKwotZdarzen THEN 1 ELSE 0 END,
    TrN_DataKur,
    TrN_Waluta,
    TrN_KursL,
    TrN_KursM,
    TrN_KursNumer,
    TrN_DataWys,
    Termin
FROM CDN.TraNag LEFT JOIN CDN.VatTab ON TrN_VaNId = VaT_VaNID
    JOIN CDN.DokumentyDoKorekty(@Data) ON (TrN_TrNId = Id AND Typ = 1)
    JOIN CDN.DekretyNag ON TrN_DekId = DeN_DeNId
    --JOIN CDN.OkresyObrach ON OOb_OObID = @Okres
WHERE DeN_DataDok >= CONVERT(datetime, '2013-01-01', 120)
   AND ((DATEDIFF(day, DeN_DataDok, Termin) <= 60 AND Opoznienie >= (CASE @NaDzien WHEN 1 THEN 30 ELSE 31 END)) OR (DATEDIFF(day, DeN_DataDok, Termin) > 60 AND DATEDIFF(day, DeN_DataDok, @Data) >= (CASE @NaDzien WHEN 1 THEN 90 ELSE 91 END)))
   AND TrN_TypDokumentu IN (301, 313)
   --AND OOb_DataOtw >= CONVERT(datetime, '2013-01-01', 120)
   --AND DeN_DataDok BETWEEN @DataOtwarcia AND @DataKoncowa
   AND ((DeN_DataDok >= @DataOtwarcia AND @DataOtwarcia <= CONVERT(datetime, '2013-12-31', 120)) OR @DataOtwarcia >= CONVERT(datetime, '2014-01-01', 120))
   AND exists(select * from CDN.DekretyKonta join CDN.Konta on (Acc_KorektaKosztow <> 0 and Acc_AccId = DeK_AccID) where DeK_DeNId = DeN_DeNId)
GROUP BY Id, Typ, TrN_NumerPelny, DeN_DataDok, TrN_Kategoria, sumaKwotZdarzen, sumaKwotRozliczen, TrN_TrNId, TrN_RazemNetto, TrN_VaNId, TrN_DataKur, TrN_Waluta, TrN_KursL, TrN_KursM, TrN_KursNumer, TrN_DataWys, Termin, kwotaDokumentu, DeN_DataWys, TrN_NumerObcy
RETURN
END
