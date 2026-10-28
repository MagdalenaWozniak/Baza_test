CREATE PROCEDURE [CDN].[Mobile_ImportCashRecord]
@ID int,
@RecordId int,
@Lp int,
@RecordNumber int,
@ReportId int,
@Income tinyint,
@Content NVARCHAR(254),
@ContractorId int,
@Date datetime,
@Description NVARCHAR(254),
@Value decimal(15,2),
@Typ  INT = 1
AS
BEGIN
SET NOCOUNT ON
declare
@DDF_Numeracja         NVARCHAR(50),
@DDF_NumeracjaPelna    NVARCHAR(50),
@DDF_Symbol            NVARCHAR(20),
@opeId                 INT,
@NumerZero             NVARCHAR(6),
@TypDokumentu          INT,
@Seria                 NVARCHAR(10),
@FPlId                 INT,
@ddfid                 INT
 select @NumerZero = '000000'
 if @Income = 1
 begin
 select @ddfid = DSta_DDfIdKP,@DDf_Numeracja = DDf_Numeracja,@DDf_Symbol = DDf_Symbol, @Seria =DSta_Seria from cdn.detalstanowiska
  join cdn.dokdefinicje on  DDf_DDfId = DSta_DDfIdKP
  where dsta_dstaid = @ID
  set @TypDokumentu = 1
 end
 else if @Income = 0
 begin
 select @ddfid = DSta_DDfIdKW,@DDf_Numeracja = DDf_Numeracja,@DDf_Symbol = DDf_Symbol, @Seria =DSta_Seria from cdn.detalstanowiska
  join cdn.dokdefinicje on  DDf_DDfId = DSta_DDfIdKW
  where dsta_dstaid = @ID
  set @TypDokumentu = 2
 end
else
return
select @opeId  = DOpe_OpeId from cdn.detalOperator where Dope_DstaId = @ID
if not exists(
select * from cdn.detalformyplatnosci
join cdn.formyplatnosci on fpl_fplid = dfpl_fplid where fpl_Typ = 1 and dfpl_dstaid =@ID)
begin
   --RAISERROR('Brak formy płatności gotówka ', 16, 1)
   EXEC CDN.RaiseOptimaException 34167
   rollback
   SET NOCOUNT OFF
   RETURN
end
else
select top 1 @FPlId= dfpl_FPlId from cdn.detalformyplatnosci
join cdn.formyplatnosci on fpl_fplid = dfpl_fplid where fpl_Typ = 1 and dfpl_dstaid =@ID
order by dfpl_Domyslna desc
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@symbol' , @DDF_Symbol  )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rejestr', @Seria)
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@brak/'  , ''       )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '/@brak'  , ''       )
 -- SET @DDF_Numeracja    = REPLACE ( @DDF_NumeracjaPA, '@magazyn', @Magazyn )
  SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rok_kal', datepart(yy,@Date)  )
  --SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@rok_obr', @RokObr  )
    if datepart(m,@Date) < 10
 SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@miesiac', '0'+ convert(varchar(3),datepart(m,@Date)) )
  else
 SET @DDF_Numeracja    = REPLACE ( @DDF_Numeracja, '@miesiac', datepart(m,@Date) )
SET  @DDF_NumeracjaPelna  = REPLACE ( @DDF_Numeracja, '@numerS', @RecordNumber )
SET  @DDF_NumeracjaPelna  = REPLACE ( @DDF_NumeracjaPelna, '@numer', substring(@NumerZero,1,6-len(@RecordNumber)) + convert(NVARCHAR(6),@RecordNumber) )
if not exists(select * from cdn.DetalZapisyKB where  DZKB_DSZKBID = @RecordId AND DZKB_StanDetalID = @ID)
  INSERT INTO CDN.DetalZapisyKB (
 DZKB_DSZKBID,
 DZKB_StanDetalID,
 DZKB_DSFPlId,
 DZKB_TypDokumentu,
 DZKB_NumerNr,
 DZKB_NumerString,
 DZKB_NumerPelny,
 DZKB_DataDok,
 DZKB_PodID,
 DZKB_RazemBrutto,
 DZKB_StanSynchronizacji,
 DZKB_OpeID,
 DZKB_Opis,
 DZKB_DDfID,
 DZKB_Typ
    )
  VALUES (
 @RecordId,
 @ID,
 @FPlId,
 @TypDokumentu,
 @RecordNumber,
 @DDF_Numeracja,
 @DDF_NumeracjaPelna,
 @Date,
 @ContractorId,
 @Value,
 1,
 @opeId,
 case when @TypDokumentu = 1 then isnull(@Description + case when @ContractorId = 0 then ' wpłata własna operatora.'else  '' end,'') else isnull(@Description + case when @ContractorId = 0 then ' wypłata własna operatora.'else  '' end,'') end,
  @ddfid,
  @Typ
         )
SET NOCOUNT OFF
END
