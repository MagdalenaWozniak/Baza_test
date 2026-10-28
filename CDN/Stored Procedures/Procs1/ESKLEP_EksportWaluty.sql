CREATE  PROCEDURE [CDN].[ESKLEP_EksportWaluty]
  @ID INT      -- ID e-sklepu
AS
BEGIN
 DECLARE
     @WalutaSys        nvarchar(3),
     @TmpSrvName       SYSNAME,
     @ServerCfgString  VARCHAR(512),
     @BazaCfgString    VARCHAR(512),
     @TrN_DataDokChar  VARCHAR(25),
     @sqltxt           NVARCHAR (1000),
     @WalOstrzegaj     VARCHAR(3),
     @ESSId            INT
 CREATE TABLE #tmpRecordSet1(
 /*ID INT,*/
 Waluta nvarchar(3),
 Domyslna TINYINT,
 KursL decimal(15,4),
 KursM decimal(15,4),
 Data DateTime
 )
 CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta VARCHAR(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT)
 --pobranie notowania
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  SELECT @ServerCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1001
  SELECT @BazaCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1002
  SELECT @TrN_DataDokChar    = CONVERT(VARCHAR(25), GETDATE(), 102)
  -- 1 = "Pobieraj ostatnio ustalony kurs waluty (nie ostrzegaj o zmianie kursu)"
  IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 )
    SELECT @WalOstrzegaj=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540
  ELSE
    SELECT @WalOstrzegaj=1
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
    SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
  SET @sqltxt = 'EXEC ['
  IF @ServerCfgString <> @TmpSrvName
    SET @sqltxt = @sqltxt + @ServerCfgString +'].['
  SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.PobierzNotowania '''', 2,'''+ @TrN_DataDokChar+''','+ @WalOstrzegaj+''
  INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
  EXEC sp_executesql @sqltxt
      select  @WalutaSys = ESS_DomyslnaWaluta,@ESSId = ESS_ESSId
   from cdn.eSklepStanowiska where ESS_IdISklep = @ID
   insert into #tmpRecordSet1 select /*0,*/@WalutaSys,1,1,1, GETDATE()
   insert into #tmpRecordSet1
   select /*ESW_ESWId,*/ ESW_Waluta,0,
   case when ESW_ZKonfig = 1 then KursL else ESW_KursL end,
   case when ESW_ZKonfig = 1 then KursM else ESW_KursM end,
   case when ESW_ZKonfig = 1 then GETDATE() else ESW_TS_Mod end
   from cdn.eSklepWaluty
   join #Notowania on Waluta = ESW_Waluta
   where ESW_ESSId = @ESSId
   select /*ID as '@ID',*/
    Waluta as '@Waluta',
    Domyslna as '@Domyslna',
    KursL as '@KursL',
    KursM as '@KursM',
    Data as '@Data'
  from  #tmpRecordSet1
   FOR XML PATH('WAL'), ROOT ('WALK')
END
