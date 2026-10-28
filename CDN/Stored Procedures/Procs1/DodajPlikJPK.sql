CREATE PROCEDURE [CDN].[DodajPlikJPK]
@JPK_Mode int,
@JPK_KodOsoby NVARCHAR(254),
@JPK_Typ NVARCHAR(254),
@JPK_Nazwa NVARCHAR(254),
@JPK_Path NVARCHAR(254),
@JPK_DataUtworzenia DATETIME,
@JPK_KodUrzedu NVARCHAR(254),
@JPK_DataWyslania NVARCHAR(254),
@JPK_DataWplyniecia NVARCHAR(254),
@JPK_KodOsobyOdbierajacej NVARCHAR(254),
@JPK_DataOdebrania NVARCHAR(254),
@JPK_XML VARBINARY(MAX),
@JPK_OkresOd DATETIME,
@JPK_OkresDo DATETIME,
@JPK_CelZlozenia INT,
@JPK_WariantFormularza INT,
@JPK_RodzajWysylki INT,
@JPK_DknId INT,
@JPK_JpkId INT,
@JPK_SourceJpkId INT,
@JPK_JpkNagId INT,
@OutID INT = 0 OUTPUT
AS
BEGIN
SET NOCOUNT ON
if @JPK_DknId=0
 Set @JPK_DknId = NULL;
if @JPK_SourceJpkId=0
 Set @JPK_SourceJpkId = NULL;
if @JPK_JpkId = 0
begin
  INSERT INTO CDN.PlikiJPK(
  JPK_Mode,
  JPK_KodOsoby,
  JPK_Typ,
  JPK_Nazwa,
  JPK_Path,
  JPK_DataUtworzenia,
  JPK_KodUrzedu,
  JPK_DataWyslania,
  JPK_DataWplyniecia,
  JPK_KodOsobyOdbierajacej,
  JPK_DataOdebrania,
  JPK_XML,
  JPK_OkresOd,
  JPK_OkresDo,
  JPK_CelZlozenia,
  JPK_WariantFormularza,
  JPK_RodzajWysylki,
  JPK_DkNId,
  JPK_SourceJpkId,
  JPK_JpkNagId
  ) VALUES (
  @JPK_Mode,
  @JPK_KodOsoby,
  @JPK_Typ,
  @JPK_Nazwa,
  @JPK_Path,
  @JPK_DataUtworzenia,
  @JPK_KodUrzedu,
  @JPK_DataWyslania,
  @JPK_DataWplyniecia,
  @JPK_KodOsobyOdbierajacej,
  @JPK_DataOdebrania,
  @JPK_XML,
  @JPK_OkresOd,
  @JPK_OkresDo,
  @JPK_CelZlozenia,
  @JPK_WariantFormularza,
  @JPK_RodzajWysylki,
  @JPK_DknId,
  @JPK_SourceJpkId,
  @JPK_JpkNagId
  )
  set @OutID = SCOPE_IDENTITY()
end
else
begin
  update CDN.PlikiJPK set
  --JPK_Mode=@JPK_Mode,
  JPK_KodOsoby = @JPK_KodOsoby,
  --JPK_Typ= @JPK_Typ,
  JPK_Nazwa= @JPK_Nazwa,
  JPK_Path= @JPK_Path,
  JPK_DataUtworzenia= @JPK_DataUtworzenia,
  JPK_KodUrzedu= @JPK_KodUrzedu,
  JPK_DataWyslania= @JPK_DataWyslania,
  JPK_DataWplyniecia= @JPK_DataWplyniecia,
  JPK_KodOsobyOdbierajacej= @JPK_KodOsobyOdbierajacej,
  JPK_DataOdebrania= @JPK_DataOdebrania,
  JPK_XML= @JPK_XML,
  JPK_OkresOd= @JPK_OkresOd,
  JPK_OkresDo= @JPK_OkresDo,
  JPK_CelZlozenia= @JPK_CelZlozenia,
  JPK_WariantFormularza= @JPK_WariantFormularza,
  JPK_RodzajWysylki= @JPK_RodzajWysylki,
  JPK_DkNId= @JPK_DknId,
  JPK_JpkNagId= @JPK_JpkNagId
  where JPK_JpkId=@JPK_JpkId
  set @OutID = @JPK_JpkId
end
IF @@ERROR <> 0
 IF @@TRANCOUNT <> 0 ROLLBACK TRANSACTION
SET NOCOUNT OFF
END
