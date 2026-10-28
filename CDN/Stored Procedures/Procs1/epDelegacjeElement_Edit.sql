CREATE procedure [CDN].[epDelegacjeElement_Edit]
@ID     int,
@IloscSniadan  int,
@IloscObiadow  int,
@IloscKolacji  int,
@NumerRejestracyjny nvarchar(20),
@Opis    nvarchar(255)
As
 Set NOCOUNT ON
 if IsNull(@ID, 0) = 0
 BEGIN
  RAISERROR('CDN.epDelegacjeElement_Edit. Nie podano ID rekordu do zmiany.', 16, 1)
  SET NOCOUNT OFF
  RETURN
 END
 declare @sql nvarchar(2048); set @sql = '';
 declare @upd nvarchar(2048); set @upd = '';
 if @NumerRejestracyjny is Not Null
 begin
  declare @TypPojazduString nvarchar(255);  set @TypPojazduString  = NULL;
  declare @TypPojazdu smallint;     set @TypPojazdu    = NULL;
  declare @PojazdStawkaZaKilometr decimal(15,4);  set @PojazdStawkaZaKilometr = NULL;
  if len(@NumerRejestracyjny) > 0 and exists (select * from CDN.AutoEwid where AuE_Rejestracja = @NumerRejestracyjny)
  begin
   select @TypPojazdu = AuE_KlasaPoj from CDN.AutoEwid where AuE_Rejestracja = @NumerRejestracyjny
   if @TypPojazdu = 1 set @TypPojazduString = 'Powyżej 900';
   else if @TypPojazdu = 2 set @TypPojazduString = 'Do 900';
   else if @TypPojazdu = 3 set @TypPojazduString = 'Motocykl';
   else if @TypPojazdu = 4 set @TypPojazduString = 'Motorower';
   if IsNull(@TypPojazduString, '') <> ''
   begin
    declare @DataRozliczenia DateTime;
    select @DataRozliczenia = DLN_DataRozliczenia from CDN.DlgNag join CDN.DlgElem on (DLN_DLNID = DLE_DLNID) where DLE_DLEID = @ID
    exec CDN.CfgWartoscAsDecimal @DataRozliczenia, @TypPojazduString, @Result = @PojazdStawkaZaKilometr OUTPUT;
   end
   if @TypPojazdu is Not Null
   begin
    if len(@upd) > 0 set @upd = @upd + ', '
    set @upd = @upd +  'DLE_TypPojazdu=' + convert(nvarchar, @TypPojazdu)
   end
   if @PojazdStawkaZaKilometr is Not Null
   begin
    if len(@upd) > 0 set @upd = @upd + ', '
    set @upd = @upd +  'DLE_PojazdStawkaZaKilometr=' + convert(nvarchar, @PojazdStawkaZaKilometr)
   end
  end
  if @NumerRejestracyjny is Not Null
  begin
   if len(@upd) > 0 set @upd = @upd + ', '
   set @upd = @upd +  'DLE_NumerRejestracyjny=''' + @NumerRejestracyjny + ''''
  end
 end
 if @Opis is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLE_Opis=''' + REPLACE(@Opis, '''', '''''') + ''''
 end
 if @IloscSniadan is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLE_IloscSniadan=' + convert(nvarchar, @IloscSniadan)
 end
 if @IloscObiadow is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLE_IloscObiadow=' + convert(nvarchar, @IloscObiadow)
 end
 if @IloscKolacji is Not Null
 begin
  if len(@upd) > 0 set @upd = @upd + ', '
  set @upd = @upd +  'DLE_IloscKolacji=' + convert(nvarchar, @IloscKolacji)
 end
 if len(@upd) > 0
 begin
  set @sql = 'update CDN.DlgElem Set '
     + @upd
     + ' where DLE_DLEId = ' + convert(nvarchar, @ID)
  Execute dbo.sp_executesql @sql
 end
 SET NOCOUNT OFF
