CREATE PROCEDURE CDN.UstalCeneTowaru
 @twr_Id                INT
,@twr_NumerCeny         INT
,@walutaDok             NVARCHAR(3) = ''
,@numerKursu            INT = 2
,@kursDokL             DECIMAL(15,4) = 0
,@kursDokM             DECIMAL(5,0) = 0
AS
BEGIN
  SET NOCOUNT ON
  DECLARE
     @Komunikat               NVARCHAR(255)
    ,@WalOstrzegaj            NVARCHAR(3)
    ,@TwC_Typ                 TINYINT
    ,@TwC_Waluta              NVARCHAR(3)
    ,@TwC_Wartosc             DECIMAL(17,4)
    ,@cenaNetto               DECIMAL(17,4)
    ,@cenaBrutto              DECIMAL(17,4)
    ,@cenaNettoPLN               DECIMAL(19,6)
    ,@cenaBruttoPLN              DECIMAL(19,6)
  ,@ustalonyKursWal       INT
  ,@KursL                 DECIMAL(15,4)
  ,@KursM                 DECIMAL(5,0)
  ,@walutaSys    NVARCHAR(3)
  ,@Brak                  INT
  ,@ServerCfgString       NVARCHAR(512)   -- np. 'Z-GAJEWSKI'
  ,@BazaCfgString         NVARCHAR(512)   -- np. 'CDN_Konfiguracja65'
 SELECT  @KursL  = 1,  @KursM  = 1
 -- Pobieraj ostatnio ustalony kurs waluty (nie ostrzegaj o zmianie kursu)
 IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 ) SELECT @WalOstrzegaj=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 ELSE SELECT @WalOstrzegaj=1
 SELECT @ServerCfgString = SYS_Wartosc FROM cdn.SystemCdn Where SYS_ID = 1001
 SELECT @BazaCfgString   = SYS_Wartosc FROM cdn.SystemCdn Where SYS_ID = 1002
 -- skeszowanie notowań wszystkich walut z konfiguracji
 declare @sqltxt nvarchar(1000),@TmpSrvName sysname
 set @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS sysname)
 if CAST ( SERVERPROPERTY ('InstanceName') AS sysname ) <> ''
 set @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS sysname)
 set @sqltxt = 'EXEC ['
 IF @ServerCfgString <> @TmpSrvName
 set @sqltxt = @sqltxt + @ServerCfgString +'].['
 set @sqltxt = @sqltxt + @BazaCfgString+'].CDN.PobierzNotowania '''',' + STR(@numerKursu) + ',''' + CONVERT(CHAR(10),getdate(),120) +''','+ @WalOstrzegaj+',1'
 CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta NVARCHAR(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
 INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
 exec sp_executesql @sqltxt
 --jaka waluta systemowa
 SELECT @walutaSys = Waluta FROM #Notowania where Systemowa=1
 IF @kursDokL <> 0 SET @ustalonyKursWal = 1
 SET @Komunikat=''
 DECLARE @NumerCeny  INT
 IF @Twr_NumerCeny IS NULL OR @Twr_NumerCeny = 0
  SELECT TOP 1 @NumerCeny = Twr_TwcNumer FROM cdn.Towary WHERE Twr_TwrId = @Twr_Id
 ELSE
  SET @NumerCeny = @Twr_NumerCeny
 DECLARE @ZaokraglajDo  SMALLINT
 IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=3048 )
  SELECT @ZaokraglajDo=case when Fir_Wartosc = 1 then 4 else 2 end FROM Cdn.Firma WHERE Fir_Numer=3048
 ELSE
  SELECT @ZaokraglajDo=2
 -- parametry ceny
 SELECT TOP 1 @TwC_Typ = TwC_Typ, @TwC_Wartosc = TwC_Wartosc, @TwC_Waluta  = TwC_Waluta,@ZaokraglajDo =case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end FROM cdn.TwrCeny JOIN cdn.Towary ON Twr_TwrId = TwC_TwrId AND TwC_TwrId = @Twr_Id AND TwC_TwCNumer = @NumerCeny
 IF ISNULL(@TwC_Waluta,'') = '' SET @TwC_Waluta = @walutaSys
 DECLARE @twr_Stawka DECIMAL(5,2)
 SELECT TOP 1 @twr_Stawka = Twr_Stawka FROM cdn.Towary WHERE Twr_TwrId = @twr_Id
 SET @cenaNetto = @TwC_Wartosc
 SET @cenaBrutto= round(@cenaNetto * (1 + ( @twr_Stawka/100 ) ),@ZaokraglajDo)
 IF @TwC_Typ = 2 -- cena brutto, to przelicz na netto
 BEGIN
  SET @cenaBrutto = @TwC_Wartosc
  SET @cenaNetto  = round(@cenaBrutto - ( @cenaBrutto * ( @twr_Stawka / ( 100 + @twr_Stawka ) ) ),@ZaokraglajDo)
 END
 IF LEN(LTRIM(RTRIM(@TwC_Waluta))) = 0 OR  @TwC_Waluta = @walutaSys --waluta ceny jest waluta systemowa
 BEGIN
  SET @KursL = 1
  SET @KursM = 1
 END
 ELSE
 BEGIN -- waluta ceny nie jest waluta systemowa
  IF @ustalonyKursWal = 1 AND @TwC_Waluta = @walutaDok
  BEGIN
  SELECT @KursL = @kursDokL,  @KursM = @kursDokM
  END
  ELSE
  BEGIN
  SELECT @KursL = KursL,  @KursM = KursM, @Brak = Brak FROM #Notowania  WHERE Waluta = @TwC_Waluta
  IF @Brak = 1
   BEGIN
   SET @KursL = 1
   SET @KursM = 1
   SET @Komunikat = '##OPT25003##%%Opis%%=' + @TwC_Waluta+ '##'
   --SET @Komunikat = 'Błąd ustalania kursu waluty '+ @TwC_Waluta+' dla ceny towaru.'
  END
  END
 END
 SET @cenaNettoPLN  = round(@cenaNetto  * ( @KursL / @KursM ),@ZaokraglajDo)
 SET @cenaBruttoPLN = round(@cenaBrutto * ( @KursL / @KursM ),@ZaokraglajDo)
 IF (LEN(LTRIM(RTRIM(@TwC_Waluta))) = 0 AND LEN(LTRIM(RTRIM(@walutaDok))) = 0) OR  @TwC_Waluta = @walutaDok GOTO KONIEC
 -- przwalutowanie z waluty ceny na walute dokumentu
 IF @ustalonyKursWal = 1
 BEGIN
  SELECT @KursL = @kursDokL,  @KursM = @kursDokM
 END
 ELSE
 BEGIN
  SELECT @KursL = KursL,  @KursM = KursM, @Brak = Brak FROM #Notowania  WHERE Waluta = @walutaDok
  IF @Brak = 1
   BEGIN
   SET @KursL = 1
   SET @KursM = 1
   SET @Komunikat = '##OPT25003##%%Opis%%=' + @walutaDok+ '##'
   --SET @Komunikat = 'Błąd ustalania kursu waluty: '+ @walutaDok + ' dla ceny towaru.'
  END
 END
 IF @KursL = 0 SET @KursL = 1
 SET @cenaNetto  = round(@cenaNettoPLN  * ( @KursM / @KursL ),@ZaokraglajDo)
 SET @cenaBrutto = round(@cenaBruttoPLN * ( @KursM / @KursL ),@ZaokraglajDo)
KONIEC:
  -- kill kesza z notowaniami
 IF EXISTS(SELECT [name] FROM tempdb.sys.tables WHERE [name] LIKE '#Notowania%') BEGIN  DROP TABLE #Notowania; END;
 SELECT @cenaNetto As CenaNettoWal, @cenaBrutto As CenaBruttoWal, @cenaNettoPLN As CenaNettoPLN, @cenaBruttoPLN As CenaBruttoPLN, @komunikat As Komunikat
END
