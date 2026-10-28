CREATE procedure CDN.epDelegacjeZaliczki_Add
@DelegacjaElementId  int,
@KwotaSys    decimal(15,2),
@KwotaWal    decimal(15,2),
@Opis     nvarchar(255),
@Data     DateTime,
@FormaPlatnosciId  int,
@Waluta     nvarchar(3),
@KursNumer    int,
@KursL     decimal(15,4),
@KursM     decimal(5,0)
As
 Set NOCOUNT ON
 if IsNull(@DelegacjaElementId, 0) = 0
 BEGIN
  RAISERROR('epDelegacjeZaliczki_Add. Parametr DelegacjaElementId jest wymagany.', 16, 1)
  SET NOCOUNT OFF
  RETURN
 END
 if @FormaPlatnosciId is Null
 begin
  if exists(SELECT * FROM CDN.FormyPlatnosci WHERE FpL_Nieaktywny=0 and FpL_Typ = 1 and FpL_Nazwa='gotówka')
   SELECT TOP 1 @FormaPlatnosciId = Fpl_FPLID FROM CDN.FormyPlatnosci WHERE FpL_Nieaktywny=0 and FpL_Typ = 1 and FpL_Nazwa='gotówka';
  else
   SELECT TOP 1 @FormaPlatnosciId = Fpl_FPLID FROM CDN.FormyPlatnosci WHERE FpL_Nieaktywny=0 and FpL_Typ = 1 ORDER BY FPL_Nazwa;
  if @FormaPlatnosciId is Null
  begin
   RAISERROR('epDelegacjeZaliczki_Add. Brak aktywnej formy płatnościo o typie gotówka.', 16, 1)
   SET NOCOUNT OFF
   RETURN
  end
 end
 if @Opis is Null Set @Opis = ''
 if @Data is Null Set @Data = GETDATE()
 if @Waluta is Null Set @Waluta = ''
 if @KursNumer is Null Set @KursNumer = 3
 if @KursL is Null Set @KursL = 1
 if @KursM is Null Set @KursM = 1
 if @KwotaSys is Null Set @KwotaSys = @KwotaWal
 if @KwotaWal is Null Set @KwotaWal = @KwotaSys
 if @KwotaWal is Null and @KwotaSys is Null
 begin
  Set @KwotaSys = 0
  Set @KwotaWal = 0
 end
 declare @sql nvarchar(2048)
 set @sql = 'declare @Data DateTime; Set @Data = ' + CDN.Date2String(@Data, 120, 0) + ';'
   + 'exec CDN.epDelegacjeZaliczki_Insert ' +  convert(nvarchar, @DelegacjaElementId)  + ','
   + convert(nvarchar, @FormaPlatnosciId)  + ','
   + ''''+@Opis+''','
   + '@Data,'
   + ''''+@Waluta+''','
   + convert(nvarchar, @KursNumer)  + ','
   + convert(nvarchar, @KursL)  + ','
   + convert(nvarchar, @KursM)  + ','
   + convert(nvarchar, @KwotaSys)  + ','
   + convert(nvarchar, @KwotaWal)
 Execute dbo.sp_executesql @sql
 if @@ERROR = 0 exec CDN.epDelegacje_UstawStatusDoPrzeliczenia @DelegacjaElementId;
 declare @DelagacjaZaliczkaId int; set @DelagacjaZaliczkaId = 0;
 if @@ERROR = 0 set @DelagacjaZaliczkaId = IsNull(IDENT_CURRENT('CDN.DlgZaliczki'), 0);
 IF @@ERROR=0
 begin
  update CDN.DlgElem Set DLE_RazemZaliczka=IsNull(DLE_RazemZaliczka,0)+@KwotaSys where DLE_DLEId = @DelegacjaElementId
 end
 SET NOCOUNT OFF
 set @sql = 'select ' + convert(nvarchar, @DelagacjaZaliczkaId) + ' as DelagacjaZaliczkaId'
 Execute dbo.sp_executesql @sql
