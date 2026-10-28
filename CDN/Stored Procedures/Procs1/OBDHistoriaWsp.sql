CREATE PROCEDURE CDN.OBDHistoriaWsp @ID int
AS
BEGIN
Set NoCount on
declare @Query1  nvarchar(2000)
set @Query1 =
N'select dneh_dnehid, dneh_donid, dneh_typ, dneh_symbolprzed, dneh_symbolpo, dneh_opeid, dneh_opekod, dneh_datazmiany, dneh_komentarz
from ' + [CDN].[BazaKonfiguracyjna]() +N'.CDN.DokNagEtapyHistoria WHERE dneh_donid='
+ convert(nvarchar(20),@ID)
Set NoCount Off
Execute dbo.sp_executesql @Query1
END
