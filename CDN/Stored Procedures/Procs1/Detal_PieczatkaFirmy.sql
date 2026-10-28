CREATE PROCEDURE [CDN].[Detal_PieczatkaFirmy]
AS
SET NOCOUNT ON
DECLARE
@Nazwa1 NVARCHAR(254),--1156
@Nazwa2 NVARCHAR(254),--1157
@Nazwa3 NVARCHAR(254),--2166
@NipE NVARCHAR(254),--1101
@KodPocztowy NVARCHAR(254),--1153
@Miasto NVARCHAR(254),--1152
@Ulica NVARCHAR(254),--1149
@NrDomu NVARCHAR(254),--1150
@NrMieszkania NVARCHAR(254), --1151
@Telefon NVARCHAR(254), --1155
@JB int, --2246
@JBNazwa1 NVARCHAR(254),
@JBNazwa2 NVARCHAR(254),
@JBNazwa3 NVARCHAR(254),
@JBNipE NVARCHAR(254),
@JBKodPocztowy NVARCHAR(254),
@JBMiasto NVARCHAR(254),
@JBUlica NVARCHAR(254),
@JBNrDomu NVARCHAR(254),
@JBNrMieszkania NVARCHAR(254),
@JBTelefon NVARCHAR(254)
set @JB =0
select @JB = convert(int,fir_wartosc) from cdn.firma where fir_numer = 2246
if @JB = 0
begin
select @Nazwa1 = fir_wartosc from cdn.firma where fir_numer = 1156
select @Nazwa2 = fir_wartosc from cdn.firma where fir_numer = 1157
select @Nazwa3 = fir_wartosc from cdn.firma where fir_numer = 2166
select @NipE   = fir_wartosc from cdn.firma where fir_numer = 1101
select @KodPocztowy   = fir_wartosc from cdn.firma where fir_numer = 1153
select @Miasto   = fir_wartosc from cdn.firma where fir_numer = 1152
select @Ulica   = fir_wartosc from cdn.firma where fir_numer = 1149
select @NrDomu   = fir_wartosc from cdn.firma where fir_numer = 1150
select @NrMieszkania   = fir_wartosc from cdn.firma where fir_numer = 1151
select @Telefon   = fir_wartosc from cdn.firma where fir_numer = 1155
select @JBNazwa1 = ''
select @JBNazwa2 = ''
select @JBNazwa3 = ''
select @JBNipE   = ''
select @JBKodPocztowy   = ''
select @JBMiasto   = ''
select @JBUlica   = ''
select @JBNrDomu   = ''
select @JBNrMieszkania   = ''
select @JBTelefon   = ''
end
else
begin
select @JBNazwa1 = fir_wartosc from cdn.firma where fir_numer = 1156
select @JBNazwa2 = fir_wartosc from cdn.firma where fir_numer = 1157
select @JBNazwa3 = fir_wartosc from cdn.firma where fir_numer = 2166
select @JBNipE   = fir_wartosc from cdn.firma where fir_numer = 1101
select @JBKodPocztowy   = fir_wartosc from cdn.firma where fir_numer = 1153
select @JBMiasto   = fir_wartosc from cdn.firma where fir_numer = 1152
select @JBUlica   = fir_wartosc from cdn.firma where fir_numer = 1149
select @JBNrDomu   = fir_wartosc from cdn.firma where fir_numer = 1150
select @JBNrMieszkania   = fir_wartosc from cdn.firma where fir_numer = 1151
select @JBTelefon   = fir_wartosc from cdn.firma where fir_numer = 1155
select @Nazwa1 = fir_wartosc from cdn.firma where fir_numer = 2247
select @Nazwa2 = fir_wartosc from cdn.firma where fir_numer = 2248
select @Nazwa3 = fir_wartosc from cdn.firma where fir_numer = 2249
select @NipE   = fir_wartosc from cdn.firma where fir_numer = 2251
select @KodPocztowy   = fir_wartosc from cdn.firma where fir_numer = 2263
select @Miasto   = fir_wartosc from cdn.firma where fir_numer = 2262
select @Ulica   = fir_wartosc from cdn.firma where fir_numer = 2259
select @NrDomu   = fir_wartosc from cdn.firma where fir_numer = 2260
select @NrMieszkania   = fir_wartosc from cdn.firma where fir_numer = 2261
select @Telefon   = fir_wartosc from cdn.firma where fir_numer = 2265
end
select @Nazwa1 as Nazwa1, @Nazwa2 as Nazwa2,@Nazwa3 as Nazwa3, @NipE as NipE,
       @KodPocztowy as KodPocztowy, @Miasto as Miasto, @Ulica as Ulica,
       @NrDomu as NrDomu, @NrMieszkania as NrMieszkania, @Telefon as Telefon,
    convert (int,@JB) as JB,@JBNazwa1 as JBNazwa1, @JBNazwa2 as JBNazwa2,@JBNazwa3 as JBNazwa3, @JBNipE as JBNipE,
       @JBKodPocztowy as JBKodPocztowy, @JBMiasto as JBMiasto, @JBUlica as JBUlica,
       @JBNrDomu as JBNrDomu, @JBNrMieszkania as JBNrMieszkania, @JBTelefon as JBTelefon
SET NOCOUNT OFF
