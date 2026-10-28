CREATE FUNCTION [CDN].[fun_GR_DokumentyKB]
 (
  @CDN_OperatorID    [int] = 0,
  @OgraniczDoFormyPlatnosci [smallint] = 0,
  @FormaPlatnosci    [smallint] = 0
  --, @FormaPlatnosciTyp   [smallint] = 0
 )
RETURNS TABLE
AS
 RETURN
 (
  SELECT
    BZp_BZpId   AS 'DKB_DKBID',
    BZp_TypDokumentuKB AS 'DKB_TypDokumentuKB',
    1     AS 'DKB_PodmiotTyp',
    BZp_PodmiotId  AS 'DKB_PodmiotId',
    BZp_DataDok   AS 'DKB_DataDok',
    BZp_DataDok   AS 'DKB_Termin',
    BZp_NumerPelny  AS 'DKB_NumerPelny',
    BZp_Numer   AS 'DKB_Numer',
    BZp_KwotaSys  AS 'DKB_KwotaSys',
    BZp_KwotaRozSys  AS 'DKB_KwotaRozSys',
    BZp_Kierunek  AS 'DKB_Kierunek',
    0     AS 'DKB_Stan',
    BZp_Rozliczono  AS 'DKB_Rozliczono'
  FROM CDN.BnkZapisy
  WHERE BZp_PodmiotTyp = 1
   AND NOT EXISTS
     (
      SELECT brz_opeid
      FROM [CDN].[BnkRachZakazy]
      WHERE [brz_braid] = [BZp_braid]
       AND [brz_opeid] = @CDN_OperatorID
       AND [brz_rachr] = 1
       AND [brz_zapp]  = 1
     )
   AND ( (@OgraniczDoFormyPlatnosci = 0)
      --OR ([BZp_Typ] = @FormaPlatnosciTyp)
OR ([BZp_Typ] = (
SELECT TOP 1 fpl_typ FROM CDN.FormyPlatnosci WHERE fpl_fplid = @FormaPlatnosci ))
    )
  UNION ALL
  SELECT
    BZd_BZdId,
    BZd_TypDokumentuKB,
    1,
    BZd_PodmiotId,
    BZd_DataDok,
    BZd_Termin,
    BZd_NumerPelny,
    BZd_Numer,
    BZd_KwotaSys,
    BZd_KwotaRozSys,
    BZd_Kierunek,
    BZd_Stan,
    BZd_Rozliczono
  FROM CDN.BnkZdarzenia
  WHERE BZd_PodmiotTyp = 1
   AND NOT EXISTS
     (
      SELECT brz_opeid
      FROM [CDN].[BnkRachZakazy]
      WHERE [brz_braid]  = [BZd_braid]
       AND [brz_opeid]  = @CDN_OperatorID
       AND [brz_rachr]  = 1
       AND [brz_zdarzp] = 1
     )
   AND ( (@OgraniczDoFormyPlatnosci = 0) OR ( [BZd_fplid] = @FormaPlatnosci) )
 )
