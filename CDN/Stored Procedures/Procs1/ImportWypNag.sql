CREATE PROCEDURE CDN.ImportWypNag @PraID INT, @Mc INT, @Rok INT, @Etat INT, @OpeID INT, @data DATETIME, @ID INT OUT
AS
BEGIN
 DECLARE @rokMies INT;
 SET @rokMies=100*@Rok+@Mc;
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeID, @OpeModKod OUT, @OpeModNazwisko OUT
 INSERT INTO CDN.WyplatyNag (
 WyN_PrcID,
 WyN_RokMies,
 WyN_DataWyp,
 WyN_Etat,
 WyN_OpeZalID,
 WyN_OpeZalKod,
 WyN_OpeZalNazwisko,
 WyN_TS_Zal,
 WyN_OpeModID,
 WyN_OpeModKod,
 WyN_OpeModNazwisko,
 WyN_TS_Mod,
 WyN_Kategoria ,
 WyN_BruttoRazem,
 WyN_BruttoOpodat,
 WyN_BruttoKoszt,
 WyN_BruttoGotowka,
 WyN_UbEmerytPrac,
 WyN_UbEmerytFir,
 WyN_UbRentowPrac,
 WyN_UbRentowFir,
 WyN_UbChorobPrac,
 WyN_UbWypadkFir,
 WyN_PodstawaFGSP,
 WyN_PodstawaFP,
 WyN_KosztyUzyskania,
 WyN_Podatek,
 WyN_UbZdrowotne,
 WyN_UbZdrowNOdl,
 WyN_ZaliczkaUS,
 WyN_Gotowka,
 WyN_PodstawaFEP,
 WyN_SkladkaFEP
 )
 VALUES(
 @PraID,
 @rokMies,
 CDN.EOMonth(@rokMies),
 @Etat,
 @OpeID,
 @OpeModKod,
 @OpeModNazwisko,
 @data,
 @OpeID,
 @OpeModKod,
 @OpeModNazwisko,
 @data,
 '',
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 )
 SELECT @ID = SCOPE_IDENTITY()
END
