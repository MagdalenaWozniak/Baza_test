CREATE View cdn.CrmKontaktyParentView
As
 SELECT
  CRKV2_CrkvID   = c.CRK_CrkId,
  CRKV2_WatekID   = w.CRK_CrkId,
  CRKV2_ParentID   = IsNull(c.CRK_ParId, 0),
  CRKV2_NumerPelny     = Case IsNull(c.CRK_ParId, 0) When 0 Then c.CRK_NumerPelny Else SPACE(5) + c.CRK_NumerPelny End,
  CRKV2_Bufor          = c.CRK_Bufor,
  CRKV2_PodmiotTyp     = c.CRK_PodmiotTyp,
  CRKV2_PodID          = c.CRK_PodID,
  CRKV2_OpiekunTyp     = c.CRK_OpiekunTyp,
  CRKV2_OpiekunId      = c.CRK_OpiekunId,
  CRKV2_Obsluga        = c.CRK_Obsluga,
  CRKV2_DataDok        = c.CRK_DataDok,
  CRKV2_CzasPrzygot  = c.CRK_CzasPrzygot,
  CRKV2_CzasKontaktu   = c.CRK_CzasKontaktu,
  CRKV2_CzasOpracow    = c.CRK_CzasOpracow,
  CRKV2_Zadanie        = c.CRK_Zadanie,
  CRKV2_TerminOd       = c.CRK_TerminOd,
  CRKV2_TerminDo       = c.CRK_TerminDo,
  CRKV2_Przypomnienie  = c.CRK_Przypomnienie,
  CRKV2_CzasPrzypomnienia   = c.CRK_CzasPrzypomnienia,
  CRKV2_Priorytet      = c.CRK_Priorytet,
  CRKV2_Wykonano       = c.CRK_Wykonano,
  CRKV2_EtapRealizacji = c.CRK_EtapRealizacji,
     CRKV2_Temat    = c.CRK_Temat,
  CRKV2_Opis           = c.CRK_Opis,
  CRKV2_OpeZalID       = c.CRK_OpeZalID,
  CRKV2_StaZalId       = c.CRK_StaZalId,
  CRKV2_TS_Zal         = c.CRK_TS_Zal,
  CRKV2_OpeModID       = c.CRK_OpeModID,
  CRKV2_StaModId       = c.CRK_StaModId,
  CRKV2_TS_Mod         = c.CRK_TS_Mod
 FROM cdn.CrmKontakty c INNER JOIN cdn.CrmKontakty w
    ON  (c.CRK_CrkId = w.CRK_CrkId AND c.CRK_ParId Is NULL)
    OR  (c.CRK_ParId = w.CRK_CrkId AND c.CRK_ParId Is Not NULL)
 WHERE IsNull(c.CRK_ParId, 0) = 0
