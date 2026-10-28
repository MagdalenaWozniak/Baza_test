CREATE PROCEDURE [CDN].[Mobile_EksportDokDef]
  @ID INT      -- ID Detalu
AS
SET NOCOUNT ON
DECLARE
@DDF_NumeracjaRO         NVARCHAR(50),
@DDF_NumeracjaFS         NVARCHAR(50),
@DDF_NumeracjaPA         NVARCHAR(50),
@SymbolRO                NVARCHAR(20),
@SymbolFS                NVARCHAR(20),
@SymbolPA                NVARCHAR(20),
@DDF_NumeracjaKP         NVARCHAR(50),
@DDF_NumeracjaKW         NVARCHAR(50),
@SymbolKP                NVARCHAR(20),
@SymbolKW                NVARCHAR(20),
@DDF_NumeracjaMM        NVARCHAR(50),
@SymbolMM               NVARCHAR(20),
--@RokKal                INT,
@Miesiac               CHAR(2),
--@RokObr                NVARCHAR(5),
@Rejestr               NVARCHAR(20),
@Magazyn               NVARCHAR(5),
@NazwaStanowiska       NVARCHAR(50),
@TypNettoBrutto        Tinyint,
@Komunikat             NVARCHAR(255),
@sqltxt              NVARCHAR (1000),
@TmpSrvName          SYSNAME,
@ServerCfgString     NVARCHAR(512),
@BazaCfgString       NVARCHAR(512),
@CzyKontrola         INT ,
@CzyKontrolaMarza    INT ,
@opeId               INT
  DECLARE @ParamDefinition NVARCHAR(32)
select top 1 @opeId = dope_opeid from cdn.detaloperator where DOpe_DStaId =@ID
set @CzyKontrola = 2
set @CzyKontrolaMarza = 1
  SET @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
  SELECT @ServerCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1001
  SELECT @BazaCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1002
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
    SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
  --SET @sqltxt = 'EXEC ['
   SET @sqltxt = 'select top 1 @CzyKontrolap = ope_platnoscisprzedaztrwaly  from '
  IF @ServerCfgString <> @TmpSrvName
    SET @sqltxt = @sqltxt + @ServerCfgString +'.'
    SET @sqltxt = @sqltxt + @BazaCfgString+'.CDN.operatorzy where ope_opeid = ' + convert(NVARCHAR(15),@opeId)
    SET @ParamDefinition = N'@CzyKontrolap int OUTPUT';
EXEC sp_executesql @sqltxt,@ParamDefinition,@CzyKontrolap = @CzyKontrola OUTPUT--,@CzyKontrolaMarzap = @CzyKontrolaMarza OUTPUT
select @CzyKontrola = case when @CzyKontrola = 0 then 1 else 0 end
   SET @sqltxt = 'select top 1 @CzyKontrolaMarzap = Ope_MinMarzaHaMag from '
  IF @ServerCfgString <> @TmpSrvName
    SET @sqltxt = @sqltxt + @ServerCfgString +'.'
    SET @sqltxt = @sqltxt + @BazaCfgString+'.CDN.operatorzy where ope_opeid = ' + convert(NVARCHAR(15),@opeId)
    SET @ParamDefinition = N'@CzyKontrolaMarzap int OUTPUT';
EXEC sp_executesql @sqltxt,@ParamDefinition,@CzyKontrolaMarzap = @CzyKontrolaMarza OUTPUT
select @CzyKontrolaMarza = case when @CzyKontrolaMarza = 0 then 1 else 0 end
select @Magazyn =  Mag_Rejestr,@Rejestr = DSta_Seria, @SymbolRO = A.DDf_Symbol , @DDF_NumeracjaRO = A.DDf_Numeracja , @SymbolFS = B.DDf_Symbol, @DDF_NumeracjaFS = B.DDf_Numeracja
       , @SymbolMM = E.DDf_Symbol, @DDF_NumeracjaMM = E.DDf_Numeracja, @SymbolPA = F.DDf_Symbol, @DDF_NumeracjaPA = F.DDf_Numeracja
       , @SymbolKP = C.DDf_Symbol , @DDF_NumeracjaKP = C.DDf_Numeracja, @SymbolKW = D.DDf_Symbol , @DDF_NumeracjaKW = D.DDf_Numeracja, @NazwaStanowiska = DSta_Nazwa,@TypNettoBrutto = DSta_TypNettoBrutto
 from cdn.detalstanowiska
join cdn.dokdefinicje A on dsta_ddfIdRO= A.DDf_DDfId
join cdn.dokdefinicje B on dsta_ddfIdFS= B.DDf_DDfId
join cdn.dokdefinicje C on dsta_ddfIdKP= C.DDf_DDfId
join cdn.dokdefinicje D on dsta_ddfIdKW= D.DDf_DDfId
join cdn.dokdefinicje E on dsta_ddfIdMM= E.DDf_DDfId
left join cdn.dokdefinicje F on dsta_ddfIdPA= F.DDf_DDfId
join cdn.magazyny on DSta_MagID = Mag_MagID
where DSta_DStaId = @ID
 declare @def table(
Typ int, symbol NVARCHAR(20), nazwa NVARCHAR (40), formatNumeru NVARCHAR(20),Platnosc int,NB int, ser int, rabatprawo int,
marza int, cenabazowa int, kntlimitprawo int, limituwzgldokbezplat int, limituwzglzam int)
if @TypNettoBrutto is null
return
  SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '@symbol/' , ''  )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@symbol/' , ''  )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@symbol/' , ''  )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@symbol/' , '' )
  SET @DDF_NumeracjaMM    = REPLACE ( @DDF_NumeracjaMM, '@symbol/' , '' )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '@symbol/' , '' )
  SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '@numerS/'  , '1/'       )
  SET @DDF_NumeracjaMM    = REPLACE ( @DDF_NumeracjaMM, '@numerS/'  , '1/'       )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@numerS/'  , '1/'       )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@numerS/'  , '1/'       )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@numerS/'  , '1/'       )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '@numerS/'  , '1/'       )
  SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '/@numerS'  , '/1'       )
  SET @DDF_NumeracjaMM    = REPLACE ( @DDF_NumeracjaMM, '/@numerS'  , '/1'       )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '/@numerS'  , '/1'       )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '/@numerS'  , '/1'       )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '/@numerS'  , '/1'       )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '/@numerS'  , '/1'       )
  SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '@numer/'  , '2/'       )
  SET @DDF_NumeracjaMM    = REPLACE ( @DDF_NumeracjaMM, '@numer/'  , '2/'       )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@numer/'  , '2/'       )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@numer/'  , '2/'       )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@numer/'  , '2/'       )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '@numer/'  , '2/'       )
  SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '/@numer'  , '/2'       )
  SET @DDF_NumeracjaMM    = REPLACE ( @DDF_NumeracjaMM, '/@numer'  , '/2'       )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '/@numer'  , '/2'       )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '/@numer'  , '/2'       )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '/@numer'  , '/2'       )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '/@numer'  , '/2'       )
  SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '@rok_kal/'  , '4/'       )
  SET @DDF_NumeracjaMM    = REPLACE ( @DDF_NumeracjaMM, '@rok_kal/'  , '4/'       )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@rok_kal/'  , '4/'       )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@rok_kal/'  , '4/'       )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@rok_kal/'  , '4/'       )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '@rok_kal/'  , '4/'       )
  SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '/@rok_kal'  , '/4'       )
  SET @DDF_NumeracjaMM    = REPLACE ( @DDF_NumeracjaMM, '/@rok_kal'  , '/4'       )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '/@rok_kal'  , '/4'       )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '/@rok_kal'  , '/4'       )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '/@rok_kal'  , '/4'       )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '/@rok_kal'  , '/4'       )
  SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '@rejestr', '5' )
  SET @DDF_NumeracjaMM    = REPLACE ( @DDF_NumeracjaMM, '@rejestr', '5' )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@rejestr', '5' )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '@rejestr', '5' )
  --SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@rejestr', '5' )
  --SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@rejestr', '5' )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '/@rejestr', '' )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '/@rejestr', '' )
  SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '@miesiac', '7' )
  SET @DDF_NumeracjaMM    = REPLACE ( @DDF_NumeracjaMM, '@miesiac', '7' )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@miesiac', '7' )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@miesiac', '7' )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@miesiac', '7' )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '@miesiac', '7' )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@brak/'  , ''       )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@brak/'  , ''       )
  SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '@brak/'  , ''       )
  SET @DDF_NumeracjaMM    = REPLACE ( @DDF_NumeracjaMM, '@brak/'  , ''       )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@brak/'  , ''       )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '@brak/'  , ''       )
  SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '/@brak'  , ''       )
  SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '/@brak'  , ''       )
  SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '/@brak'  , ''       )
  SET @DDF_NumeracjaMM    = REPLACE ( @DDF_NumeracjaMM, '/@brak'  , ''       )
  SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '/@brak'  , ''       )
  SET @DDF_NumeracjaPA    = REPLACE ( @DDF_NumeracjaPA, '/@brak'  , ''       )
  --SET @DDF_NumeracjaRO    = REPLACE ( @DDF_NumeracjaRO, '@magazyn', @Magazyn )
  --SET @DDF_NumeracjaFS    = REPLACE ( @DDF_NumeracjaFS, '@magazyn', @Magazyn )
  --SET @DDF_NumeracjaKW    = REPLACE ( @DDF_NumeracjaKW, '@magazyn', @Magazyn )
  --SET @DDF_NumeracjaKP    = REPLACE ( @DDF_NumeracjaKP, '@magazyn', @Magazyn )
  --SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rok_kal', @RokKal  )
  --SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rok_obr', @RokObr  )
  --SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@miesiac', @Miesiac )
insert into @def values
(9472,@SymbolRO,'Zamówienie sprzedaży',@DDF_NumeracjaRO,0,@TypNettoBrutto,1,1,@CzyKontrolaMarza,0,2,0,0)
insert into @def values
(2033,@SymbolFS,'Faktura sprzedaży',@DDF_NumeracjaFS,1,@TypNettoBrutto,1,1,@CzyKontrolaMarza,0,@CzyKontrola,0,0)
insert into @def values
(7841,@SymbolKP,'Kasa przyjęła',@DDF_NumeracjaKP,0,@TypNettoBrutto,0,0,0,0,0,0,0)
insert into @def values
(7842,@SymbolKW,'Kasa wydała',@DDF_NumeracjaKW,0,@TypNettoBrutto,0,0,0,0,0,0,0)
insert into @def values
(1603,'MMW','Przesunięcie międzymagazynowe wydanie',@DDF_NumeracjaMM,0,0,1,1,0,0,2,0,0)
insert into @def values
(1604,'MMP','Przesunięcie międzymagazynowe przyjęcie',@DDF_NumeracjaMM,0,0,1,1,0,0,2,0,0)
if @SymbolPA IS NOT NULL
insert into @def values
(2034,@SymbolPA,'Paragon',@DDF_NumeracjaPA,1,1,1,1,@CzyKontrolaMarza,0,@CzyKontrola,0,0)
/*insert into @def
values (Typ int, symbol NVARCHAR(20), nazwa NVARCHAR (40), formatNumeru NVARCHAR(20),Platnosc int,NB int, ser int, rabatprawo int,
marza int, cenabazowa int, kntlimitprawo int, limituwzgldokbezplat int, limituwzglzam int)
*/
select * from @def
SET NOCOUNT OFF
/*
Oznaczenie członów
1 – NUMER (N)
2 – NUMER (0N)
3 – ROK (RR)
4 – ROK (RRRR)
5 – SERIA
6 – MIESIĄC (M)
7 – MIESIĄC (MM)
*/
