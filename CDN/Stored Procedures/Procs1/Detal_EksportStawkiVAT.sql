CREATE PROCEDURE CDN.Detal_EksportStawkiVAT
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
DECLARE
 @Stawka decimal(5, 2) ,
 @Flaga smallint,
    @sqltxt           NVARCHAR (1000),
    @TmpSrvName       SYSNAME,
    @ServerCfgString  NVARCHAR(512),
    @BazaCfgString    NVARCHAR(512),
    @TrN_DataDokChar  NVARCHAR(25)
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  SELECT @ServerCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1001
  SELECT @BazaCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1002
  SELECT @TrN_DataDokChar    = CONVERT(NVARCHAR(25), GETDATE(), 102)
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
    SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
  SET @sqltxt = 'EXEC ['
  IF @ServerCfgString <> @TmpSrvName
  SET @sqltxt = @sqltxt + @ServerCfgString +'].['
  SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.Detal_PobierzStawkiVAT '
create Table #VatTbl(
 Id int,
Stawka decimal(15,2),
Flaga smallint,
Nazwa NVARCHAR(254)
 )
insert into #VatTbl(Id,Stawka,Flaga,Nazwa) EXEC sp_executesql @sqltxt
if @CzyTaSamaBaza = 1
BEGIN
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  select Stawka,Flaga from #VatTbl
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
   @Stawka,
   @Flaga
   IF @@FETCH_STATUS <> 0 BREAK
  exec [CDN].[DetalStan_AktualizujStawkiVAT]
            @ID,
   @Stawka,
   @Flaga
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
  select * from #VatTbl
SET NOCOUNT OFF
