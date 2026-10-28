CREATE View cdn.CrmKontaktyView
As
 SELECT
  CRKV_CrkvID   = c.CRK_CrkId,
  CRKV_WatekID  = w.CRK_CrkId,
  CRKV_ParentID  = IsNull(c.CRK_ParId, 0),
  CRKV_Rodzaj   = CASE c.CRK_zadanie WHEN 1 THEN 'Z' ELSE 'K' END,
  CRKV_KodKnt   = (SELECT IsNull(Pod_Kod, '') From cdn.PodmiotyView WHERE Pod_PodmiotTyp = c.CRK_PodmiotTyp AND Pod_PodId = c.CRK_PodId),
  CRKV_NumerPelny     = Case IsNull(c.CRK_ParId, 0) When 0 Then c.CRK_NumerPelny Else SPACE(5) + c.CRK_NumerPelny End,
  CRKV_Bufor          = c.CRK_Bufor,
  CRKV_PodmiotTyp     = c.CRK_PodmiotTyp,
  CRKV_PodID          = c.CRK_PodID,
  CRKV_OpiekunTyp     = c.CRK_OpiekunTyp,
  CRKV_OpiekunId      = c.CRK_OpiekunId,
  CRKV_Obsluga        = c.CRK_Obsluga,
  CRKV_DataDok        = c.CRK_DataDok,
  CRKV_CzasPrzygot = c.CRK_CzasPrzygot,
  CRKV_CzasKontaktu   = c.CRK_CzasKontaktu,
  CRKV_CzasOpracow = c.CRK_CzasOpracow,
  CRKV_Zadanie        = c.CRK_Zadanie,
  CRKV_TerminOd       = c.CRK_TerminOd,
  CRKV_TerminDo       = c.CRK_TerminDo,
  CRKV_Przypomnienie  = c.CRK_Przypomnienie,
  CRKV_CzasPrzypomnienia = c.CRK_CzasPrzypomnienia,
  CRKV_Priorytet      = c.CRK_Priorytet,
  CRKV_Wykonano       = c.CRK_Wykonano,
  CRKV_EtapRealizacji = c.CRK_EtapRealizacji,
     CRKV_Temat   = Case c.CRK_Temat When '' Then Convert (NVARCHAR(255), c.CRK_Opis) Else Convert (NVARCHAR(255), c.CRK_Temat) End,
  CRKV_Opis           = c.CRK_Opis,
  CRKV_OpeZalID       = c.CRK_OpeZalID,
  CRKV_StaZalId       = c.CRK_StaZalId,
  CRKV_TS_Zal         = c.CRK_TS_Zal,
  CRKV_OpeModID       = c.CRK_OpeModID,
  CRKV_StaModId       = c.CRK_StaModId,
  CRKV_TS_Mod         = c.CRK_TS_Mod
 FROM cdn.CrmKontakty c INNER JOIN cdn.CrmKontakty w
    ON  (c.CRK_CrkId = w.CRK_CrkId AND c.CRK_ParId Is NULL)
    OR  (c.CRK_ParId = w.CRK_CrkId AND c.CRK_ParId Is Not NULL)
