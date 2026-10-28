CREATE     FUNCTION CDN.AnalizaKonta(@_konto NVARCHAR(50))
returns @Analiza_Konta Table (poziom INT, syntetyka NVARCHAR(50))
AS
Begin
 declare @sSQL     NVARCHAR(255)
 declare @sKonto    NVARCHAR(50)
 declare @sSynteza   NVARCHAR(50)
 declare @nIdx     int
 declare @nPoziom   int
 declare @sSeparator  NVARCHAR(1)
 set @sKonto   = @_konto
 set @sSynteza  = ''
 set @sSeparator = ''
 set @sSynteza  = ''
 set @nPoziom  = 0
 set @nIdx    = CHARINDEX ( '-' , @sKonto )
 if @nIdx > 0
 while @nIdx > 0
 begin
  set @nPoziom = @nPoziom + 1
  if len(@sSynteza) > 0
   set @sSeparator='-'
  else
   set @sSeparator=''
  set @sSynteza  = @sSynteza + @sSeparator + SUBSTRING ( @sKonto , 1 , @nIdx-1 )
  set @sKonto   = STUFF   ( @sKonto , 1 , @nIdx , '' )
  set @nIdx    = CHARINDEX ( '-' , @sKonto )
  insert into @Analiza_Konta (poziom, syntetyka) values( @nPoziom, @sSynteza )
 end
 return
end
