CREATE PROCEDURE CDN.OFF_Ex_BnkZapisy
 @Brp_BrpID INT
  AS
 SELECT  BnRid=Max(bzp_BrpId),
         Bzp_NumerPelny=Max(Bzp_NumerPelny),
         BnRLp=BzP_BrPLp,
         KntId =Max(CASE WHEN Knt_KntId = 1 THEN 0 ELSE Knt_KntId END),
         KntGidTyp=MAX(Knt_GidTyp),
         KntGidNumer=MAX((CASE WHEN Knt_GidTyp < 1 OR Knt_GidTyp is NULL THEN NULL ELSE Knt_GidNumer END)),
         TrNId=Max(CASE WHEN TrN_Rodzaj = 302101 THEN NULL ELSE BzD_DokumentId END),
         TrnGidTyp=Max(Trn_GidTyp),
         TrnGidFirma=Max(Trn_GidFirma),
         TrnGidNumer=Max(Trn_GidNumer),
         TrnGidLp=Max(Trn_GidLp),
         FormaXLId = MAX(isnull(FPl_XLId,case when bzp_typ = 2 then 20 else 10 end)),
         Kierunek=Max(CASE WHEN Bzp_Kierunek = 1 THEN 2 ELSE 1 END),
         Kwota=MAX(BzP_Kwota),
         Data=Max(Bzp_DataDok),
         Opis=Max(Bzp_Opis),
         OpeZalId=Max(Bzp_OpeZalId),
         OpeModId=Max(Bzp_OpeModId),
         NiePodlega=Max(CASE WHEN Bzp_Rozliczono = 0 THEN 1 ELSE 0 END)
 FROM cdn.BnkZapisy
 left outer JOIN cdn.BnkRozRelacje ON (BzP_BzPId = BrR_ZDokId AND BrR_ZDokTyp = 2)
 left outer JOIN cdn.BnkZdarzenia ON (BzD_BzDId = BrR_DDokId AND BrR_DDokTyp = 1)
 left outer JOIN cdn.Kontrahenci ON Knt_KntId = BzP_PodmiotId
 left outer JOIN cdn.FormyPlatnosci ON Fpl_FplId = BzD_FPLId
 left outer JOIN cdn.Tranag ON  Trn_TrnId = BzD_DokumentId
 WHERE bzp_BrpId=@Brp_BrpID group by bzp_brplp, BzD_DokumentId
