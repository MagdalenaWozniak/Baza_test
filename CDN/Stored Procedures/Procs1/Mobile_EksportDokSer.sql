create  PROCEDURE [CDN].[Mobile_EksportDokSer]
  @ID INT      -- ID Detalu
AS
SET NOCOUNT ON
 declare @def table(
Typ int, Ser_numer int, Ser_Domyslna int)
insert into @def values
(9472,1,1)
insert into @def values
(2033,1,1)
--insert into @def values
--(7841,1,1)
--insert into @def values
--(7842,1,1)
insert into @def values
(2034,1,1)
insert into @def values
(1603,1,1)
insert into @def values
(1604,1,1)
select * from @def
SET NOCOUNT OFF
