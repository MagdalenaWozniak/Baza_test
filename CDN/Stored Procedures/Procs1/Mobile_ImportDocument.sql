CREATE PROCEDURE [CDN].[Mobile_ImportDocument]
@ID int,
@DocId int,
@Number int,
@Type1 int,
@Type2 int,
@Date datetime,
@Month int,
@ContractorId int,
@Seria NVARCHAR(254),
@VatFromNetValue tinyint,
@PaymentId int,
@GrossValue decimal(15,2),
@NetValue decimal(15,2),
@Discount decimal(15,2),
@PaymentDate datetime,
@ExecutionDate datetime,
@Description NVARCHAR(1024),
@IsFiscalized tinyint,
@WarehouseId int,
@AdresId int=0,
@MagKod NVARCHAR(30) = '',
@TargetContractorId int = 0,
@PayerId int = 0,
@Mpp tinyint = 0
AS
BEGIN
SET NOCOUNT ON
declare
@DDF_Numeracja         NVARCHAR(50),
@DDF_NumeracjaPelna    NVARCHAR(50),
@DDF_Symbol            NVARCHAR(20),
@opeId                 INT,
@NumerZero             NVARCHAR (6),
@FplId                 INT,
@ddfid                 INT
if @Type1 = 312
set @ExecutionDate = @Date
 select @NumerZero = '000000'
 if @Type1 not in(308,302,312,305,306,320)
 select @Type1 = case when @Type1 = 9472 then 308 else case when @Type1 = 2033 then 302 else case when @Type1 = 1603 then 312 else case when @Type1 = 2034 then 305 else 0  end end  end end
if @Type1 = 308
 select @ddfid = DSta_DDfIdRO,@DDf_Numeracja = DDf_Numeracja,@DDf_Symbol = DDf_Symbol from cdn.detalstanowiska
 join cdn.dokdefinicje on  DDf_DDfId = DSta_DDfIdRO
where dsta_dstaid = @ID
else if @Type1 = 302
 select @ddfid = DSta_DDfIdFS,@DDf_Numeracja = DDf_Numeracja,@DDf_Symbol = DDf_Symbol from cdn.detalstanowiska
 join cdn.dokdefinicje on  DDf_DDfId = DSta_DDfIdFS
where dsta_dstaid = @ID
else if @Type1 = 312
 select @ddfid = DSta_DDfIdMM,@DDf_Numeracja = DDf_Numeracja,@DDf_Symbol = DDf_Symbol from cdn.detalstanowiska
 join cdn.dokdefinicje on  DDf_DDfId = DSta_DDfIdMM
where dsta_dstaid = @ID
else if @Type1 = 305
 select @ddfid = DSta_DDfIdPA,@DDf_Numeracja = DDf_Numeracja,@DDf_Symbol = DDf_Symbol from cdn.detalstanowiska
 join cdn.dokdefinicje on  DDf_DDfId = DSta_DDfIdPA
where dsta_dstaid = @ID
else if @Type1 = 306
 select @ddfid = DSta_DDfIdWZ,@DDf_Numeracja = DDf_Numeracja,@DDf_Symbol = DDf_Symbol from cdn.detalstanowiska
 join cdn.dokdefinicje on  DDf_DDfId = DSta_DDfIdWZ
where dsta_dstaid = @ID
else if @Type1 = 320
 select @ddfid = DSta_DDfIdPF,@DDf_Numeracja = DDf_Numeracja,@DDf_Symbol = DDf_Symbol from cdn.detalstanowiska
 join cdn.dokdefinicje on  DDf_DDfId = DSta_DDfIdPF
where dsta_dstaid = @ID
else
return
select @opeId  = DOpe_OpeId from cdn.detalOperator where Dope_DstaId = @ID
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
SET  @DDF_NumeracjaPelna  = REPLACE ( @DDF_Numeracja, '@numerS', @Number )
SET  @DDF_NumeracjaPelna  = REPLACE ( @DDF_NumeracjaPelna, '@numer', substring(@NumerZero,1,6-len(@Number)) + convert(NVARCHAR(6),@Number) )
SET  @DDF_Numeracja  = REPLACE ( @DDF_Numeracja, '@magazyn', @MagKod )
SET  @DDF_NumeracjaPelna  = REPLACE ( @DDF_NumeracjaPelna, '@magazyn', @MagKod )
select @VatFromNetValue= case when @VatFromNetValue= 0 then 2 else 1 end
set @FplId = 0
if @TargetContractorId = 0
 set @TargetContractorId = @ContractorId
if not exists(select * from cdn.DetalTraNag where  DTrN_DSTrNID = @DocId AND DTrN_StanDetalID = @ID)
 INSERT INTO CDN.DetalTraNag (
 DTrN_DSTrNID ,
 DTrN_StanDetalID ,
 DTrN_FAID ,
 DTrN_TypDokumentu ,
 DTrN_NumerNr ,
 DTrN_NumerString ,
 DTrN_NumerPelny  ,
 DTrN_DataDok ,
 DTrN_Fiskalna ,
 DTrN_PodID ,
 DTrN_OdbID ,
 DTrN_RazemBrutto ,
 DTrN_Rabat ,
 DTrN_StanSynchronizacji ,
 DTrN_OsobaOdbierajaca,
 DTrN_OpeID ,
 DTrN_TS_Zal ,
 DTrN_IloscElementow ,
 DTrN_IloscPlatnosci,
 DTrN_Waluta,
 DTrN_TypNB,
 DTrN_FplId,
 DTrN_DataPlatnosci,
 DTrN_DataRealizacji,
 DTrN_Opis,
 DtrN_MagId,DtrN_AdresID,DTrN_MagKod,DTrN_ddfid,
 DTrN_PlatnikID,
 DTrN_SplitPay)
  VALUES (@DocId,@ID,0,@Type1,@Number,@DDf_Numeracja,@DDF_NumeracjaPelna,@Date,@IsFiscalized,@ContractorId,
  @TargetContractorId,@GrossValue,@Discount,1,'',@opeId ,@Date,0,0,'',@VatFromNetValue,@PaymentId,
@PaymentDate,@ExecutionDate,@Description,@WarehouseId,@AdresID,@MagKod,@ddfid,
@PayerId,ISNULL(@Mpp,0))
else update cdn.DetalTraNag set DTrN_TS_Export = GETDATE() where DTrN_DSTrNID = @DocId AND DTrN_StanDetalID = @ID
SET NOCOUNT OFF
END
