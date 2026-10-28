CREATE PROCEDURE [CDN].[Mobile_PieczatkaFirmy]
@ID INt
AS
SET NOCOUNT ON
DECLARE
@Nazwa1 NVARCHAR(254),--1156
@Nazwa2 NVARCHAR(254),--1157
@NipE NVARCHAR(254),--1101
@NipKraj NVARCHAR(254),--1101
@KodPocztowy NVARCHAR(254),--1153
@Miasto NVARCHAR(254),--1152
@Ulica NVARCHAR(254),--1149
@NrDomu NVARCHAR(254),--1150
@NrMieszkania NVARCHAR(254), --1151
@Telefon NVARCHAR(254), --1155
@Rachunek NVARCHAR(51)
select top 1 @rachunek = bra_rachuneknr  from cdn.detalformyplatnosci
join cdn.formyplatnosci on fpl_fplid = dfpl_fplid
join cdn.bnkrachunki on fpl_braid = bra_braid
where dfpl_dstaid = @ID and bra_typ = 2
select @Nazwa1 = fir_wartosc from cdn.firma where fir_numer = 1156
select @Nazwa2 = fir_wartosc from cdn.firma where fir_numer = 1157
select @NipE   = fir_wartosc from cdn.firma where fir_numer = 1101
select @NipKraj   = fir_wartosc from cdn.firma where fir_numer = 1167
select @KodPocztowy   = fir_wartosc from cdn.firma where fir_numer = 1153
select @Miasto   = fir_wartosc from cdn.firma where fir_numer = 1152
select @Ulica   = fir_wartosc from cdn.firma where fir_numer = 1149
select @NrDomu   = fir_wartosc from cdn.firma where fir_numer = 1150
select @NrMieszkania   = fir_wartosc from cdn.firma where fir_numer = 1151
select @Telefon   = fir_wartosc from cdn.firma where fir_numer = 1155
select 1 as Frm_GidNumer, @Nazwa1 as Frm_Nazwa1, @Nazwa2 as Frm_Nazwa2,'' as Frm_Nazwa3,
       @NipKraj as Frm_NipPrefiks,@NipE as Frm_NIP,
       @KodPocztowy as Frm_KodP, @Miasto as Frm_Miasto, @Ulica + ' ' + @NrDomu + case when @NrMieszkania <>'' then '/' else '' end + @NrMieszkania as Frm_Ulica,
       @Telefon as Frm_Telefon1, '' as Frm_Email, isnull(@rachunek,'') as KAR_NrRachunku
SET NOCOUNT OFF
