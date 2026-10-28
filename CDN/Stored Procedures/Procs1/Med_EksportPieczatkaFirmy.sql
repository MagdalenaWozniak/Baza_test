CREATE PROCEDURE CDN.Med_EksportPieczatkaFirmy
AS
SET NOCOUNT ON
DECLARE
@Nazwa1 NVARCHAR(254),--1156
@Nazwa2 NVARCHAR(254),--1157
@NipE NVARCHAR(254),--1101
@KodPocztowy NVARCHAR(254),--1153
@Miasto NVARCHAR(254),--1152
@Ulica NVARCHAR(254),--1149
@NrDomu NVARCHAR(254),--1150
@NrMieszkania NVARCHAR(254), --1151
@Telefon NVARCHAR(254) --1155
select @Nazwa1 = fir_wartosc from cdn.firma where fir_numer = 1156
select @Nazwa2 = fir_wartosc from cdn.firma where fir_numer = 1157
select @NipE   = fir_wartosc from cdn.firma where fir_numer = 1101
select @KodPocztowy   = fir_wartosc from cdn.firma where fir_numer = 1153
select @Miasto   = fir_wartosc from cdn.firma where fir_numer = 1152
select @Ulica   = fir_wartosc from cdn.firma where fir_numer = 1149
select @NrDomu   = fir_wartosc from cdn.firma where fir_numer = 1150
select @NrMieszkania   = fir_wartosc from cdn.firma where fir_numer = 1151
select @Telefon   = fir_wartosc from cdn.firma where fir_numer = 1155
select @Nazwa1 as Nazwa1, @Nazwa2 as Nazwa2, @NipE as NipE,
       @KodPocztowy as KodPocztowy, @Miasto as Miasto, @Ulica as Ulica,
       @NrDomu as NrDomu, @NrMieszkania as NrMieszkania, @Telefon as Telefon
SET NOCOUNT OFF
