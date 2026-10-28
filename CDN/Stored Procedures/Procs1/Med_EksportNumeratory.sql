CREATE PROCEDURE  [CDN].[Med_EksportNumeratory]
as
select DDf_DDfID,DDf_Klasa,DDf_Symbol,ddf_numeracja from cdn.dokdefinicje where DDf_Klasa in (302,305) and DDf_Nieaktywna = 0
