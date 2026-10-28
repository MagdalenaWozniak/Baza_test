CREATE FUNCTION CDN.KodStawkiVat( @Rejestr int, @Flaga int, @Stawka decimal(15,2))
RETURNS nvarchar(3)
AS
BEGIN
 declare @result nvarchar(3)
 declare @vat_zwolniony  int
 declare @vat_opodatkowany int
 declare @vat_zanizony  int
 declare @vat_nie_podlega int
 declare @REJESTR_ZAKUPOW int
 declare @REJESTR_SPRZEDAZY int
 set @REJESTR_ZAKUPOW = 1
 set @REJESTR_SPRZEDAZY = 2
 set @vat_zwolniony  = 1
 set @vat_opodatkowany = 2
 set @vat_zanizony  = 3
 set @vat_nie_podlega = 4
 if @Rejestr = @REJESTR_SPRZEDAZY
 begin
  if @Stawka = 0 and @Flaga = @vat_zwolniony
   set @result =  'ZW'
  else if @Stawka = 0 and @Flaga = @vat_nie_podlega
   set @result =  'NP'
  else if @Stawka = 0 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '0%'
  else if @Stawka = 3 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '3%'
  else if @Stawka = 4 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '4%'
  else if @Stawka = 5 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '5%'
  else if @Stawka = 6 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '6%'
  else if @Stawka = 7 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '7%'
  else if @Stawka = 8 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '8%'
  else if @Stawka = 22 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '22%'
  else if @Stawka = 23 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '23%'
  else set @result =  '??'
 end
 else
 begin
  if @Stawka = 0 and @Flaga = @vat_zwolniony
   set @result =  'ZW'
  else if @Stawka = 0 and @Flaga = @vat_nie_podlega
   set @result =  'NP'
  else if @Stawka = 0 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '0%'
  else if @Stawka = 3 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '3%'
  else if @Stawka = 4 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '4%'
  else if @Stawka = 5 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '5%'
  else if @Stawka = 6 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '6%'
  else if @Stawka = 7 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '7%'
  else if @Stawka = 8 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '8%'
  else if @Stawka = 22 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '22%'
  else if @Stawka = 23 and (@Flaga = @vat_opodatkowany or @Flaga = @vat_zanizony )
   set @result =  '23%'
  else set @result =  '??'
 end
 set @result =  IsNull(@result, '??')
 return @result
END
