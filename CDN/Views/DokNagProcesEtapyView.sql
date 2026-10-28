create view cdn.DokNagProcesEtapyView
(	  [DnPr_DnPrID]
      ,[DnPr_DoNID]
      ,[DnPr_Typ]
      ,[DnPr_Lp]
      ,[DnPr_Poziom]
      ,[DnPr_PoprzedniLp]
)
as
select
	  [DnPr_DnPrID]
      ,[DnPr_DoNID]
      ,[DnPr_Typ]
      ,[DnPr_Lp]
      ,[DnPr_Poziom]
      ,[DnPr_PoprzedniLp]
from cdn.DokNagProcesEtapy
union all
select
	  [DnPr_DnPrID]
      ,[DnPr_DoNID]
      ,[DnPr_Typ]
      ,[DnPr_Lp]
      ,[DnPr_Poziom]
      ,[DnPr_PoprzedniLp]
from [SRV1].[CDN_KNF_ONE].cdn.DokNagProcesEtapy