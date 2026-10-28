CREATE procedure [CDN].[FA_GetRelatedDocsEN]
 @Identyfikator int = 0
AS
BEGIN
 DECLARE @Dok_typ int,
 @Dok_FaId int,
 @Dok_DataWys datetime
 SELECT @Dok_typ = Trn_Rodzaj,
 @Dok_FaId = TrN_FaId,
 @Dok_DataWys = TrN_DataWys
 FROM CDN.TraNag WHERE TrN_TrNID = @Identyfikator
 --FA_Koncowa
 IF @Dok_typ = 302009 OR (@Dok_typ = 302004 AND exists (SELECT TrZ_TrZID FROM CDN.TraFakZaliczkowe LEFT JOIN cdn.tranag on trz_fzid = trn_trnid WHERE TrZ_TrNID = @Identyfikator))
 BEGIN
  SELECT
   CAST(TrZ_NumerPelny as nvarchar(30)) [Dok_Numer],
   TrN_DataDok [Dok_Data],
   CAST(CASE TrZ_Uwzgledniac WHEN 1 THEN TrZ_KwotaBrutto ELSE 0 END as decimal(16,2)) [Dok_Brutto],
   CAST(CASE TrN_Waluta WHEN '' THEN ' PLN' ELSE ' ' + TrN_Waluta END as varchar(4))[Dok_Waluta],
   CASE WHEN TrZ_Flaga = 1 THEN CAST('ZW' as varchar(16))
    WHEN TrZ_Flaga = 4 AND ((TrN_Export=5 and (TrN_PodatekVat=1 OR TrN_DataOpe < CONVERT(DATETIME, '2015-07-01', 120))) OR TrN_Export in (8,9)) THEN char(45)+char(45)+char(45)+char(42)
    WHEN TrZ_Flaga = 4 AND ((TrN_Export<>5 OR (TrN_PodatekVat<>1 AND TrN_DataOpe > CONVERT(DATETIME, '2015-07-01', 120))) AND TrN_Export not in (8,9)) THEN 'NP'
    ELSE CAST(CAST(TrZ_Stawka as INT) as varchar(16)) + '%' END [Vat_Stawka],
   CAST(TrZ_KwotaNettoSys as decimal(16,2)) [Vat_Netto],
   CAST(TrZ_KwotaVATSys as decimal(16,2)) [Vat_Kwota],
   CAST(TrZ_KwotaBruttoSys as decimal(16,2)) [Vat_Brutto]
  FROM CDN.TraFakZaliczkowe
  LEFT JOIN cdn.tranag on trz_fzid = trn_trnid
  WHERE TrZ_TrNID = @Identyfikator
  ORDER BY TrZ_Stawka desc,Vat_Stawka desc
  RETURN 0
 END
 --FA_Zaliczkowa
IF @Dok_typ = 302200
 BEGIN
 SELECT
    CAST(TrN_NumerPelny as nvarchar(30)) [Dok_Numer],
   TrN_DataDok [Dok_Data],
   CAST(TrN_RazemBruttoWal as decimal(16,2)) [Dok_Brutto],
   CAST(CASE TrN_Waluta WHEN '' THEN ' PLN' ELSE ' ' + TrN_Waluta END as varchar(4))[Dok_Waluta],
   CAST('' as varchar(16)) + '%' [Vat_Stawka],
   CAST(0.00 as decimal(16,2)) [Vat_Netto],
   CAST(0.00 as decimal(16,2)) [Vat_Kwota],
   CAST(0.00 as decimal(16,2)) [Vat_Brutto]
  FROM CDN.TraNag
  WHERE
  TrN_TrNID <> @Identyfikator AND
  TrN_FaID = @Dok_FaId AND
  TrN_DataWys <=  @Dok_DataWys AND
  TrN_Rodzaj in (302200, 302202)
  Order by TrN_DataDok asc
 END
 ELSE
 BEGIN
  SELECT DISTINCT
   CAST(TrN_NumerPelny as nvarchar(30)) [Dok_Numer],
   TrN_DataDok  [Dok_Data],
   CAST(0 as decimal(16,2)) [Dok_Brutto],
   CAST('' as varchar(4)) [Dok_Waluta],
   CAST('' as varchar(16)) [Vat_Stawka],
   CAST(0 as decimal(16,2)) [Vat_Netto],
   CAST(0 as decimal(16,2)) [Vat_Kwota],
   CAST(0 as decimal(16,2)) [Vat_Brutto]
  FROM CDN.TraNagRelacje
  LEFT JOIN CDN.TraNag ON TrR_TrNId = TrN_TrNID
  WHERE TrR_FaId = @Identyfikator AND TrR_FaTyp = 302
  ORDER BY TrN_DataDok
 END
END
