CREATE FUNCTION [CDN].[RozbijNumer] (@TrN_DDfId  INT,@StringNumer nvarchar(31))
RETURNS @TableRokSeria table(rok nvarchar(5),seria nvarchar(5),miesiac nvarchar(5))
AS
  BEGIN
  -- zmienne pomocnicze
  DECLARE
    --@lenghtnumer  INT,
    --@lenghtrok    INT,
    --@lenghtrejestr  INT,
    --@lenghtmiesiac  INT,
 @lengh   INT,
 @lengh0  INT,
    @lengh1  INT,
    @lengh2  INT,
    @lengh3  INT,
    @lengh4  INT,
 @strdef0 nvarchar(50),
    @strdef1 nvarchar(50),
    @strdef2 nvarchar(50),
    @strdef3 nvarchar(50),
    @strdef4 nvarchar(50),
    @len   INT,
 @len0  INT,
    @len1  INT,
    @len2  INT,
    @len3  INT,
    @len4  INT,
 @str0 nvarchar(50),
    @str1 nvarchar(50),
    @str2 nvarchar(50),
    @str3 nvarchar(50),
    @str4 nvarchar(50),
    @rok  nvarchar(50),
    @rejestr nvarchar(50),
    @stringdef nvarchar(50),
    @miesiac  nvarchar(50)
    select   @rok = '',
    @rejestr = '',
    @stringdef = '',
    @miesiac  = ''
    SELECT @stringdef= DDf_Numeracja FROM CDN.DokDefinicje WHERE DDf_DDfID=@TrN_DDfId
    SELECT @stringdef = REPLACE(@stringdef,'@brak/','');
    SELECT @stringdef = REPLACE(@stringdef,'/@brak','');
 SELECT @lengh0 = CHARINDEX('/',@stringdef,1)
    SELECT @len0 = CHARINDEX('/',@stringnumer,1)
    SELECT @str0 = SUBSTRING(@stringnumer,0,@len0)
    SELECT @strdef0 = SUBSTRING(@stringdef,0,@lengh0)
    if @strdef0 = '@rok_kal'
     select @rok = @str0
    if @strdef0 = '@rejestr'
     select @rejestr = @str0
    if @strdef0 = '@miesiac'
     select @miesiac = @str0
    SELECT @lengh =len(@stringdef)
    SELECT @len =len(@stringnumer)
    SELECT @lengh1 = CHARINDEX('/',@stringdef,1)+1
    SELECT @len1 = CHARINDEX('/',@stringnumer,1)+1
    SELECT @lengh2 = CHARINDEX('/',@stringdef,@lengh1+1)
    SELECT @len2 = CHARINDEX('/',@stringnumer,@len1+1)
 SELECT @str1 = SUBSTRING(@stringnumer,@len1,@len2-@len1)
    SELECT @strdef1 = SUBSTRING(@stringdef,@lengh1,@lengh2-@lengh1)
    if @strdef1 = '@rok_kal'
     select @rok = @str1
    if @strdef1 = '@rejestr'
     select @rejestr = @str1
    if @strdef1 = '@miesiac'
     select @miesiac = @str1
    SELECT @lengh3 = CHARINDEX('/',@stringdef,@lengh2+1)
    SELECT @len3 = CHARINDEX('/',@stringnumer,@len2+1)
    if @len3 = 0
  SELECT @len3=@len+1
    if @lengh3 = 0
  SELECT @lengh3=@lengh+1
 SELECT @str2 = SUBSTRING(@stringnumer,@len2+1,@len3-@len2-1)
    SELECT @strdef2 = SUBSTRING(@stringdef,@lengh2+1,@lengh3-@lengh2-1)
    if @strdef2 = '@rok_kal'
     select @rok = @str2
    if @strdef2 = '@rejestr'
     select @rejestr = @str2
    if @strdef2 = '@miesiac'
     select @miesiac = @str2
   if @len3 <> @len+1
   begin
    SELECT @len4 = CHARINDEX('/',@stringnumer,@len3+1)
    SELECT @lengh4 = CHARINDEX('/',@stringdef,@lengh3+1)
    if @len4 = 0
  SELECT @len4=@len+1
    if @lengh4 = 0
  SELECT @lengh4=@lengh+1
 SELECT @str3 = SUBSTRING(@stringnumer,@len3+1,@len4-@len3-1)
    SELECT @strdef3 = SUBSTRING(@stringdef,@lengh3+1,@lengh4-@lengh3-1)
    if @strdef3 = '@rok_kal'
     select @rok = @str3
    if @strdef3 = '@rejestr'
     select @rejestr = @str3
    if @strdef3 = '@miesiac'
     select @miesiac = @str3
 SELECT @str4 = SUBSTRING(@stringnumer,@len4+1,@len-1)
    SELECT @strdef4 = SUBSTRING(@stringdef,@lengh4+1,@len-1)
    if @strdef4 = '@rok_kal'
     select @rok = @str4
    if @strdef4 = '@rejestr'
     select @rejestr = @str4
    if @strdef4 = '@miesiac'
     select @miesiac = @str4
   end
   else
   begin
  SELECT @str3 = SUBSTRING(@stringnumer,@len3+1,@len-1)
        SELECT @strdef3 = SUBSTRING(@stringdef,@lengh3+1,@len-1)
   if @strdef3 = '@rok_kal'
     select @rok = @str3
    if @strdef3 = '@rejestr'
     select @rejestr = @str3
    if @strdef3 = '@miesiac'
     select @miesiac = @str3
   end
   INSERT  @TableRokSeria SELECT @rok  ,@rejestr, @miesiac
   RETURN
   END
/*FUNCTION CDN.fn_RozbijNumer (@TrN_DDfId  INT,@StringNumer nvarchar(31))
RETURNS @TableRokSeria table(rok nvarchar(5),seria nvarchar(5))
AS
  BEGIN
  -- zmienne pomocnicze
  DECLARE
    @lenghtnumer  INT,
    @lenghtrok    INT,
    @lenghtrejestr  INT,
    @len   INT,
    @len1  INT,
    @len2  INT,
    @len3  INT,
    @str1 nvarchar(50),
    @str2 nvarchar(50),
    @str3 nvarchar(50),
    @rok  nvarchar(50),
    @rejestr nvarchar(50),
    @stringdef nvarchar(50)
    SELECT @stringdef= DDf_Numeracja FROM CDN.DokDefinicje WHERE DDf_DDfID=@TrN_DDfId
    SELECT @lenghtnumer =CHARINDEX('/@numer',@stringdef,1)
    SELECT @lenghtrok = CHARINDEX('/@rok_kal',@stringdef,1)
    SELECT @lenghtrejestr = CHARINDEX('/@rejestr',@stringdef,1)
    if @lenghtrejestr = 0 SELECT @lenghtrejestr=1000
    SELECT @len =len(@stringnumer)
    SELECT @len1 = CHARINDEX('/',@stringnumer,1)+1
    SELECT @len2 = CHARINDEX('/',@stringnumer,@len1+1)
    SELECT @len3 = CHARINDEX('/',@stringnumer,@len2+1)
    if @len3 = 0 SELECT @len3=@len+1
    SELECT @str1 = SUBSTRING(@stringnumer,@len1,@len2-@len1)
    SELECT @str2 = SUBSTRING(@stringnumer,@len2+1,@len3-@len2-1)
    SELECT @str3 = SUBSTRING(@stringnumer,@len3+1,@len-1)
    if @str1 = '@numer'
      if @lenghtrok>@lenghtrejestr
         SELECT @rok = @str3,@rejestr = @str2
      else
         SELECT @rok = @str2,@rejestr = @str3
    if @str2 = '@numer'
      if @lenghtrok>@lenghtrejestr
         SELECT @rok = @str3,@rejestr = @str1
      else
         SELECT @rok = @str1,@rejestr = @str3
    if @str3 = '@numer'
      if @lenghtrok>@lenghtrejestr
         SELECT @rok = @str2,@rejestr = @str1
      else
         SELECT @rok = @str1,@rejestr = @str2
   INSERT  @TableRokSeria SELECT @rok  ,@rejestr
   RETURN
   END*/
