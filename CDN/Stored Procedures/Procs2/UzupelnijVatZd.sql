CREATE PROCEDURE CDN.UzupelnijVatZd
@DknId int,
@OldVaNId_ZK int,
@NewVaNId_ZK int
AS
BEGIN
 SET NOCOUNT ON
 declare @TypDeklaracji int;
 declare @RokMiesiac int;
 select @TypDeklaracji = DkN_TypDeklar, @RokMiesiac = DkN_RokMiesiac from cdn.DeklNag where DkN_DkNId = @DknId;
 insert into CDN.VatZD (
 VaZ_Bufor,
 VaZ_VaNId,
 VaZ_TrNId,
 VaZ_Typ,
 VaZ_DknId,
 VaZ_SumaKwotZdarzen,
 VaZ_SumaKwotRozliczen,
 VaZ_KntNazwa1,
 VaZ_KntNazwa2,
 VaZ_KntNazwa3,
 VaZ_KntNipE,
 VaZ_Dokument,
 VaZ_DataWys,
 VaZ_Termin,
 VaZ_RazemNetto,
 VaZ_RazemVAT,
 VaZ_RazemBrutto,
 VaZ_RodzajZakupu,
 VaZ_Odliczenia,
 VaZ_Flaga,
 VaZ_Stawka,
 VaZ_Netto,
 VaZ_VAT,
 VaZ_Brutto,
 VaZ_KorektaNetto,
 VaZ_KorektaVat,
 VaZ_PoprzednioDoRoliczenia,
 VaZ_PoprzednioRozliczono,
 VaZ_DoRoliczeniaNaDzienObliczenia,
 VaZ_RoliczonoNaDzienObliczenia,
 VaZ_VaNId_ZK
 )
 select top 1
 1,
 VaZ_VaNId,
 VaZ_TrNId,
 VaZ_Typ,
 @DknId,
 0, --VaZ_SumaKwotZdarzen
 0, --VaZ_SumaKwotRozliczen
 VaZ_KntNazwa1,
 VaZ_KntNazwa2,
 VaZ_KntNazwa3,
 VaZ_KntNipE,
 VaZ_Dokument,
 VaZ_DataWys,
 VaZ_Termin,
 0, --VaZ_RazemNetto
 0, --VaZ_RazemVAT
 0, --VaZ_RazemBrutto
 0, --VaZ_RodzajZakupu
 0, --VaZ_Odliczenia
 0, --VaZ_Flaga
 0, --VaZ_Stawka
 0, --VaZ_Netto
 0, --VaZ_VAT
 0, --VaZ_Brutto
 0, --VaZ_KorektaNetto
 0, --VaZ_KorektaVat
 0, --VaZ_PoprzednioDoRoliczenia
 0, --VaZ_PoprzednioRozliczono
 0, --VaZ_DoRoliczeniaNaDzienObliczenia
 0, --VaZ_RoliczonoNaDzienObliczenia
 @NewVaNId_ZK --VaZ_VaNId_ZK
 from
 cdn.vatzd join cdn.DeklNag on (VaZ_DkNId = DkN_DkNID)
 where VaZ_VaNId_ZK = @OldVaNId_ZK and DkN_Finalna = 0 and DkN_TypDeklar = @TypDeklaracji and DkN_RokMiesiac = @RokMiesiac
 SET NOCOUNT OFF
END
