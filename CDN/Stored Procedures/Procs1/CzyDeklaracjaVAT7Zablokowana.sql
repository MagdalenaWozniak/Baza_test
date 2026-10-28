CREATE PROCEDURE CDN.CzyDeklaracjaVAT7Zablokowana
(
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@Data nvarchar(10),
@OpeId int,
@RetVal INT OUTPUT
)
As
BEGIN
 SET @RetVal = 0
 DECLARE @sqltxt NVARCHAR (1000), @TmpSrvName SYSNAME
 SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
 IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
  SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
 SET @sqltxt = 'SELECT Ope_BlokadaVATDoVAT7 as blokada FROM ['
 IF @ServerName <> @TmpSrvName
  SET @sqltxt = @sqltxt + @ServerName +'].['
 SET @sqltxt = @sqltxt + @ConfigDBName + ']' + '.[CDN].[Operatorzy] WHERE Ope_OpeID = ' + convert(nvarchar(10), @OpeId)
 CREATE TABLE #TmpTable (blokada TINYINT)
 INSERT INTO #TmpTable (blokada)
 EXEC sp_executesql @sqltxt
 DECLARE @BlokadaVATDoVAT7 INT
 SELECT @BlokadaVATDoVAT7 = BLOKADA FROM #TmpTable
 DROP TABLE #TmpTable
 IF @BlokadaVATDoVAT7 > 0
 BEGIN
  DECLARE @deklZablokowana INT
  declare @DataRM int
    select @DataRM = 100*CONVERT(INT, SUBSTRING(@Data, 1, 4), 0) + CONVERT(INT, SUBSTRING(@Data, 6, 2), 0)
  if exists
  (
   select * from cdn.deklnag join CDN.DeklElem on (DkN_DkNId = DkE_DkNID and DkE_Numer = 10008) where DkN_TypDeklar=1
    and DkN_Zablokowana<>0 and DkN_Finalna <> 0 and
    DateAdd(month, @DataRM % 100-1, DateAdd(year,@DataRM/100-1900,0)) >=
     (case
      when DkE_WartoscL = 0 then
       DateAdd(month, DkN_RokMiesiac % 100-1, DateAdd(year,DkN_RokMiesiac/100-1900,0))
      else
       DateAdd(month, DkN_RokMiesiac % 100-3, DateAdd(year,DkN_RokMiesiac/100-1900,0))
      end
     ) and
     DateAdd(month, @DataRM % 100-1, DateAdd(year,@DataRM/100-1900,0)) <=
      (DateAdd(month, DkN_RokMiesiac % 100, DateAdd(year,DkN_RokMiesiac/100-1900,0))-1)
  )
    select @deklZablokowana = 1
   else
    select @deklZablokowana = 0
  IF @deklZablokowana <> 0
  BEGIN
   IF @BlokadaVATDoVAT7 = 1
    SET @RetVal = 1
   ELSE
    BEGIN
     IF @BlokadaVATDoVAT7 = 2
      SET @retVal = 2
    END
  END
 END
END
