CREATE PROCEDURE [CDN].[Mobile_SprawdzNumerWersji]
  @Wersja NVARCHAR(15)     -- wersja
AS
BEGIN
SET NOCOUNT ON
DECLARE
@Komunikat             NVARCHAR(255)
declare @nr decimal(15,2)
select @nr = convert(decimal(15,2),sys_wartosc) from cdn.systemcdn  where sys_id = 3
--if @nr in (2012.00,2012.01,2012.02,2012.03,2012.04,2012.05)
 select 17.03
--else
-- select @nr
SET NOCOUNT OFF
END
