CREATE PROCEDURE [CDN].[Detal_SprawdzNumerWersji]
  @Wersja NVARCHAR(15)     -- wersja
AS
SET NOCOUNT ON
DECLARE
@Komunikat             NVARCHAR(255)
select convert(decimal(15,2),sys_wartosc) from cdn.systemcdn  where sys_id = 3
SET NOCOUNT OFF
