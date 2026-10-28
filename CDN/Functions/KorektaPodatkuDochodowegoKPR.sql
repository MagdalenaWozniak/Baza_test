CREATE FUNCTION CDN.KorektaPodatkuDochodowegoKPR(@Data DateTime, @NaDzien Int, @KPRID Int)
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
insert into @Result
SELECT Id,
    Typ,
    VaN_Dokument,
    DataDokumentu,
    CAST((KPR_Towary + KPR_Uboczne + KPR_Wynagrodz + KPR_Inne)*(1 - (kwotaDokumentu - sumaKwotZdarzen + IsNull(sumaKwotRozliczen,0))/kwotaDokumentu) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id and DPD_Termin = Termin and DPD_Skreslony <> 1 and DPD_KPRId <> @KPRID and (DPD_DataKorekty <= @Data or DPD_DataKorekty is null) ) AS decimal(15,2)),
    --CASE WHEN EXISTS (SELECT DPD_DPDID FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id)
   --THEN  CAST((SELECT TOP 1 DPD_SumaKwotRozliczen FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota > 0 ORDER BY DPD_Kwota DESC) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota < 0)- IsNull(sumaKwotRozliczen, 0)*(KPR_Towary + KPR_Uboczne + KPR_Wynagrodz + KPR_Inne)/sumaKwotZdarzen AS decimal(15,2))
   --ELSE CAST((KPR_Towary + KPR_Uboczne + KPR_Wynagrodz + KPR_Inne)*(1 - IsNull(sumaKwotRozliczen, 0)/sumaKwotZdarzen) AS decimal(15,2)) END,
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
    JOIN CDN.ZapisyKPR ON VaN_KpRID = KPR_KPRID
WHERE KPR_DataOpe >= CONVERT(datetime, '2013-01-01', 120)
    AND ((DATEDIFF(day, KPR_DataOpe, Termin) <= 60 AND Opoznienie >= (CASE @NaDzien WHEN 1 THEN 30 ELSE 31 END)) OR (DATEDIFF(day, KPR_DataOpe, Termin) > 60 AND DATEDIFF(day, KPR_DataOpe, @Data) >= (CASE @NaDzien WHEN 1 THEN 90 ELSE 91 END)))
UNION
SELECT Id,
    Typ,
    CASE WHEN EDN_NumerObcy <> '' THEN EDN_NumerObcy ELSE EDN_NumerPelny END,
    DataDokumentu,
    CAST((KPR_Towary + KPR_Uboczne + KPR_Wynagrodz + KPR_Inne)*(1 - (kwotaDokumentu - sumaKwotZdarzen + IsNull(sumaKwotRozliczen,0))/kwotaDokumentu) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 12 AND DPD_DokumentID = Id and DPD_Termin = Termin and DPD_Skreslony <> 1 and DPD_KPRId <> @KPRID and (DPD_DataKorekty <= @Data or DPD_DataKorekty is null)) AS decimal(15,2)),
    --CASE WHEN EXISTS (SELECT DPD_DPDID FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id)
   --THEN  CAST((SELECT TOP 1 DPD_SumaKwotRozliczen FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota > 0 ORDER BY DPD_Kwota DESC) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota < 0)- IsNull(sumaKwotRozliczen, 0)*(KPR_Towary + KPR_Uboczne + KPR_Wynagrodz + KPR_Inne)/sumaKwotZdarzen AS decimal(15,2))
   --ELSE CAST((KPR_Towary + KPR_Uboczne + KPR_Wynagrodz + KPR_Inne)*(1 - IsNull(sumaKwotRozliczen, 0)/sumaKwotZdarzen) AS decimal(15,2)) END,
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
        JOIN CDN.ZapisyKPR ON EDN_KPRId = KPR_KPRID
WHERE KPR_DataOpe >= CONVERT(datetime, '2013-01-01', 120)
    AND ((DATEDIFF(day, KPR_DataOpe, Termin) <= 60 AND Opoznienie >= (CASE @NaDzien WHEN 1 THEN 30 ELSE 31 END)) OR (DATEDIFF(day, KPR_DataOpe, Termin) > 60 AND DATEDIFF(day, KPR_DataOpe, @Data) >= (CASE @NaDzien WHEN 1 THEN 90 ELSE 91 END)))
UNION
SELECT Id,
    Typ,
    CASE WHEN TrN_NumerObcy <> '' THEN TrN_NumerObcy ELSE TrN_NumerPelny END,
    DataDokumentu,
    CAST((KPR_Towary + KPR_Uboczne + KPR_Wynagrodz + KPR_Inne)*(1 - (kwotaDokumentu - sumaKwotZdarzen + IsNull(sumaKwotRozliczen,0))/kwotaDokumentu) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 1 AND DPD_DokumentID = Id and DPD_Termin = Termin and DPD_Skreslony <> 1 and DPD_KPRId <> @KPRID and (DPD_DataKorekty <= @Data or DPD_DataKorekty is null)) AS decimal(15,2)),
     --CASE WHEN EXISTS (SELECT DPD_DPDID FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id)
   --THEN  CAST((SELECT TOP 1 DPD_SumaKwotRozliczen FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota > 0 ORDER BY DPD_Kwota DESC) - (SELECT IsNull(SUM(DPD_Kwota),0) FROM CDN.DPD WHERE DPD_DokumentTyp = 2 AND DPD_DokumentID = Id AND DPD_Kwota < 0)- IsNull(sumaKwotRozliczen, 0)*(KPR_Towary + KPR_Uboczne + KPR_Wynagrodz + KPR_Inne)/sumaKwotZdarzen AS decimal(15,2))
   --ELSE CAST((KPR_Towary + KPR_Uboczne + KPR_Wynagrodz + KPR_Inne)*(1 - IsNull(sumaKwotRozliczen, 0)/sumaKwotZdarzen) AS decimal(15,2)) END,
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
FROM CDN.TraNag JOIN CDN.VatNag ON TrN_VaNId = VaN_VaNID
    JOIN CDN.DokumentyDoKorekty(@Data) ON (TrN_TrNId = Id AND Typ = 1)
    JOIN CDN.ZapisyKPR ON VaN_KpRID = KPR_KPRID
WHERE KPR_DataOpe >= CONVERT(datetime, '2013-01-01', 120)
    AND ((DATEDIFF(day, KPR_DataOpe, Termin) <= 60 AND Opoznienie >= (CASE @NaDzien WHEN 1 THEN 30 ELSE 31 END)) OR (DATEDIFF(day, KPR_DataOpe, Termin) > 60 AND DATEDIFF(day, KPR_DataOpe, @Data) >= (CASE @NaDzien WHEN 1 THEN 90 ELSE 91 END)))
   AND TrN_TypDokumentu IN (301, 313)
RETURN
END
