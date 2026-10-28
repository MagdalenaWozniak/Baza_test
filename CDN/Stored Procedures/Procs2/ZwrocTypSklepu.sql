CREATE PROCEDURE [CDN].[ZwrocTypSklepu]
AS
SET NOCOUNT ON
if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 and ESS_Nieaktywny = 0) and exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1 and ESS_Nieaktywny = 0)
select 3
else
if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 and ESS_Nieaktywny = 0) select 2
else
if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1 and ESS_Nieaktywny = 0) select 1
else
select 0
SET NOCOUNT OFF
