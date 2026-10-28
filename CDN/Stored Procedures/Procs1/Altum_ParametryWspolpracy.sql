create procedure cdn.Altum_ParametryWspolpracy
  @JestWspolpraca tinyint,
  @Serwer nvarchar(128),
  @Baza nvarchar(128),
  @CentrumID int,
  @CentrumNazwa nvarchar(128),
  @Throw nvarchar(256) output  --treść wyjątku
 as
 set nocount on
  set @Throw = ''
  begin try
   update cdn.firma
    set fir_wartosc = @JestWspolpraca
     where fir_numer = 2000
   update cdn.firma
    set fir_wartosc = @Serwer
     where fir_numer = 2001
   update cdn.firma
    set fir_wartosc = @Baza
     where fir_numer = 2002
   update cdn.firma
    set fir_wartosc = @CentrumNazwa
     where fir_numer = 2003
   update cdn.firma
    set fir_wartosc = @CentrumID
     where fir_numer = 2004
   if @JestWspolpraca > 0
    update cdn.cfgwartosci set cfw_wartosc = '0'
     where cfw_cfkid = (select top 1 cfk_cfkid from cdn.cfgklucze where cfk_nazwa = 'Współpraca z XL')
  end try
  begin catch
   set @Throw = '##OPT34179##'
  end catch
 set nocount off
