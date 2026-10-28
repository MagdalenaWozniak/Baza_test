CREATE PROCEDURE CDN.OKontrolaDuplikacjiPracownikow
 @Pesel nvarchar(11),
 @Duplikacja  tinyint output
as
set nocount on
Set @Duplikacja = 0
declare @KontrolaUnikalnosci tinyint
declare @JestKonflikt tinyint
set @KontrolaUnikalnosci = (select Fir_Wartosc from CDN.Firma where Fir_Numer = 3038)
if exists(
select top 1 pre_preid from cdn.PracEtaty where PRE_TypPracownika = 0 and PRE_Pesel = @Pesel and PRE_DataDo = convert(datetime, '2999-12-31', 120))
 set @JestKonflikt = 1
else
 return
if @KontrolaUnikalnosci = 1
 SET @Duplikacja = 1
else if @KontrolaUnikalnosci = 2
 SET @Duplikacja = 2;
set nocount off
