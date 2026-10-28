CREATE PROCEDURE CDN.Sendit_AdresNadawczy
AS
SET NOCOUNT ON
DECLARE
@Nazwa1 NVARCHAR(254),--1156
@KodPocztowy NVARCHAR(254),--1153
@Miasto NVARCHAR(254),--1152
@Ulica NVARCHAR(254),--1149
@NrDomu NVARCHAR(254),--1150
@NrMieszkania NVARCHAR(254), --1151
@KrajISO NVARCHAR(254), --1169
@Wojew NVARCHAR(254), --1146
@Tel NVARCHAR(254), --1155
@Nazwa2 NVARCHAR(254) -- 1157
select @Nazwa1 = Fir_Wartosc from CDN.Firma where Fir_Numer = 1156
select @KodPocztowy   = Fir_Wartosc from CDN.Firma where Fir_Numer = 1153
select @Miasto   = Fir_Wartosc from CDN.Firma where Fir_Numer = 1152
select @Ulica   = Fir_Wartosc from CDN.Firma where Fir_Numer = 1149
select @NrDomu   = Fir_Wartosc from CDN.Firma where Fir_Numer = 1150
select @NrMieszkania   = fir_wartosc from cdn.firma where Fir_Numer = 1151
select @KrajISO  = fir_wartosc from cdn.firma where Fir_Numer = 1169
select @Wojew  = fir_wartosc from cdn.firma where Fir_Numer = 1146
select @Tel  = fir_wartosc from cdn.firma where Fir_Numer = 1155
select @Nazwa2  = fir_wartosc from cdn.firma where Fir_Numer = 1157
if exists (select * from CDN.SenditAdresyNadawcze where SAN_SANID = 1 and (SAN_Nazwa != @Nazwa1 or @KodPocztowy != SAN_KodPocztowy or @Miasto != SAN_Miasto or @Ulica != SAN_Ulica or
@NrDomu != SAN_NrDomu or @NrMieszkania != SAN_NrMieszkania or SAN_Wojewodztwo != @Wojew or SAN_Telefon != @Tel or  SAN_Nazwa2 != @Nazwa2 or SAN_KrajISO != @KrajISO))
update cdn.senditadresynadawcze set SAN_Nazwa =@Nazwa1, SAN_KodPocztowy = @KodPocztowy, SAN_Miasto = @Miasto, SAN_Ulica = @Ulica ,SAN_NrDomu= @NrDomu,
SAN_NrMieszkania = @NrMieszkania,SAN_KrajISO = @KrajISO, SAN_Wojewodztwo= @Wojew,  SAN_Telefon = @Tel, SAN_Nazwa2 = @Nazwa2
where SAN_SANID = 1
if not exists (select * from cdn.senditadresynadawcze)
INSERT INTO CDN.SenditAdresyNadawcze
           (SAN_Kod
           ,SAN_Nazwa
           ,SAN_Ulica
           ,SAN_NrDomu
           ,SAN_NrMieszkania
           ,SAN_Miasto
           ,SAN_KodPocztowy
           ,SAN_Domyslny
           ,SAN_Korespondencyjny
     ,SAN_KrajISO
     ,SAN_Wojewodztwo
     ,SAN_Telefon
     ,SAN_Nazwa2 )
     VALUES
           ('Firmowy'
           ,@Nazwa1
           ,@Ulica
           ,@NrDomu
           ,@NrMieszkania
           ,@Miasto
           ,@KodPocztowy
           ,1
           ,1
     ,@KrajISO
     ,@Wojew
     ,@Tel
     ,@Nazwa2)
