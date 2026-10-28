CREATE PROCEDURE [CDN].[Mobile_EksportDokMag]
@ID INT
AS
SET NOCOUNT ON
declare @MagId int, @MagIdZwrotny int
 declare @def table(
Typ int, MagID int, Domyslny int)
select @MagId = dsta_magid, @MagIdZwrotny = dsta_magidzwrotny from cdn.detalstanowiska where dsta_dstaid = @ID
insert into @def values
(2033,@MagId,@MagId)
insert into @def values
(2034,@MagId,@MagId)
insert into @def values
(1603,@MagIdZwrotny,@MagIdZwrotny)
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
select mag_magid from cdn.magazyny
where  mag_nieaktywny = 0 and mag_typ = 1
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO  @MagId
 IF @@FETCH_STATUS <> 0 BREAK
insert into @def values
(9472,@MagId,@MagIdZwrotny)
END
        CLOSE Dodawane
        DEALLOCATE Dodawane
select * from @def
SET NOCOUNT OFF
