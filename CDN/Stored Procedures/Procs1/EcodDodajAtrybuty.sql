-- Dodawanie predefiniowanych atrybutów dla ECOD
CREATE PROCEDURE CDN.EcodDodajAtrybuty
AS
BEGIN
 -- atrybuty towaru
 IF NOT EXISTS ( SELECT * FROM CDN.DefAtrybuty WHERE DeA_Typ=1 AND DeA_Kod='BUYERITEMCODE')
 BEGIN
  INSERT INTO CDN.DefAtrybuty (DeA_Typ,DeA_Kod,DeA_Nazwa,DeA_Format,DeA_Zalezny,DeA_CzyKopiowacFA,DeA_CzyKopiowacDoVAT,DeA_CzyKod,DeA_CzyPrzenosic,DeA_CzyDrukowac,DeA_ImportRowId, DeA_OpeZalID, DeA_TS_Zal, DeA_OpeModID, DeA_TS_Mod, DeA_CzyPrzenosicNaDostawy, DeA_CzyObowiazkowyDostawy)
  VALUES(1, 'BUYERITEMCODE', 'ECOD-kod produktu wg nabywcy', 1, 1, 0, 0, 0, 0, 0, '', NULL, CAST(GetDate() AS smalldatetime), NULL, CAST( GetDate() AS smalldatetime), 0, 0)
 END
 -- atrybuty kontrahenta
 IF NOT EXISTS ( SELECT * FROM CDN.DefAtrybuty WHERE DeA_Typ=2 AND DeA_Kod='CODEBYBUYER')
 BEGIN
  INSERT INTO CDN.DefAtrybuty (DeA_Typ,DeA_Kod,DeA_Nazwa,DeA_Format,DeA_Zalezny,DeA_CzyKopiowacFA,DeA_CzyKopiowacDoVAT,DeA_CzyKod,DeA_CzyPrzenosic,DeA_CzyDrukowac,DeA_ImportRowId, DeA_OpeZalID, DeA_TS_Zal, DeA_OpeModID, DeA_TS_Mod, DeA_CzyPrzenosicNaDostawy, DeA_CzyObowiazkowyDostawy)
  VALUES(2, 'CODEBYBUYER','ECOD-kod dostawcy wg kupującego', 1, 1, 0, 0, 0, 1, 0, '', NULL, CAST(GetDate() AS smalldatetime), NULL, CAST( GetDate() AS smalldatetime), 0, 0)
 END
 IF NOT EXISTS ( SELECT * FROM CDN.DefAtrybuty WHERE DeA_Typ=2 AND DeA_Kod='DELIVERYADDRESS')
 BEGIN
  DECLARE @DeaId INT
  INSERT INTO CDN.DefAtrybuty (DeA_Typ,DeA_Kod,DeA_Nazwa,DeA_Format,DeA_Zalezny,DeA_CzyKopiowacFA,DeA_CzyKopiowacDoVAT,DeA_CzyKod,DeA_CzyPrzenosic,DeA_CzyDrukowac,DeA_ImportRowId, DeA_OpeZalID, DeA_TS_Zal, DeA_OpeModID, DeA_TS_Mod, DeA_CzyPrzenosicNaDostawy, DeA_CzyObowiazkowyDostawy)
  VALUES(2, 'DELIVERYADDRESS','ECOD-zapisuj adres miejsca dostawy', 3, 0, 0, 0, 0, 0, 0, '', NULL, CAST(GetDate() AS smalldatetime), NULL, CAST( GetDate() AS smalldatetime), 0, 0)
  SET @DeaId = SCOPE_IDENTITY()
  INSERT INTO [CDN].[DefAtrElem]([DAE_DeAId],[DAE_Wartosc]) VALUES(@DeaId, 'Tak')
  INSERT INTO [CDN].[DefAtrElem]([DAE_DeAId],[DAE_Wartosc]) VALUES(@DeaId, 'Nie')
 END
 -- atrybuty dokumentu
 IF NOT EXISTS ( SELECT * FROM CDN.DefAtrybuty WHERE DeA_Typ=4 AND DeA_Kod='CODEBYBUYER')
 BEGIN
  INSERT INTO CDN.DefAtrybuty (DeA_Typ,DeA_Kod,DeA_Nazwa,DeA_Format,DeA_Zalezny,DeA_CzyKopiowacFA,DeA_CzyKopiowacDoVAT,DeA_CzyKod,DeA_CzyPrzenosic,DeA_CzyDrukowac,DeA_ImportRowId, DeA_OpeZalID, DeA_TS_Zal, DeA_OpeModID, DeA_TS_Mod, DeA_CzyPrzenosicNaDostawy, DeA_CzyObowiazkowyDostawy)
  VALUES(4, 'CODEBYBUYER','ECOD-kod dostawcy wg kupującego', 1, 0, 0, 0, 0, 1, 0, '', NULL, CAST(GetDate() AS smalldatetime), NULL, CAST( GetDate() AS smalldatetime), 0, 0)
 END
 IF NOT EXISTS ( SELECT * FROM CDN.DefAtrybuty WHERE DeA_Typ=4 AND DeA_Kod='CORRECTIONREASON')
 BEGIN
  INSERT INTO CDN.DefAtrybuty (DeA_Typ,DeA_Kod,DeA_Nazwa,DeA_Format,DeA_Zalezny,DeA_CzyKopiowacFA,DeA_CzyKopiowacDoVAT,DeA_CzyKod,DeA_CzyPrzenosic,DeA_CzyDrukowac,DeA_ImportRowId, DeA_OpeZalID, DeA_TS_Zal, DeA_OpeModID, DeA_TS_Mod, DeA_CzyPrzenosicNaDostawy, DeA_CzyObowiazkowyDostawy)
  VALUES(4, 'CORRECTIONREASON','ECOD- przyczyna (typ) korekty', 1, 0, 0, 0, 0, 1, 0, '', NULL, CAST(GetDate() AS smalldatetime), NULL, CAST( GetDate() AS smalldatetime), 0, 0)
 END
 IF NOT EXISTS ( SELECT * FROM CDN.DefAtrybuty WHERE DeA_Typ=4 AND DeA_Kod='RETURNSNOTICENUMBER')
 BEGIN
  INSERT INTO CDN.DefAtrybuty (DeA_Typ,DeA_Kod,DeA_Nazwa,DeA_Format,DeA_Zalezny,DeA_CzyKopiowacFA,DeA_CzyKopiowacDoVAT,DeA_CzyKod,DeA_CzyPrzenosic,DeA_CzyDrukowac,DeA_ImportRowId, DeA_OpeZalID, DeA_TS_Zal, DeA_OpeModID, DeA_TS_Mod, DeA_CzyPrzenosicNaDostawy, DeA_CzyObowiazkowyDostawy)
  VALUES(4, 'RETURNSNOTICENUMBER','ECOD-numer zawiadomienia o zwrotach', 1, 0, 0, 0, 0, 1, 0, '', NULL, CAST(GetDate() AS smalldatetime), NULL, CAST( GetDate() AS smalldatetime), 0, 0)
 END
 IF NOT EXISTS ( SELECT * FROM CDN.DefAtrybuty WHERE DeA_Typ=4 AND DeA_Kod='RETURNSNOTICEDATE')
 BEGIN
  INSERT INTO CDN.DefAtrybuty (DeA_Typ,DeA_Kod,DeA_Nazwa,DeA_Format,DeA_Zalezny,DeA_CzyKopiowacFA,DeA_CzyKopiowacDoVAT,DeA_CzyKod,DeA_CzyPrzenosic,DeA_CzyDrukowac,DeA_ImportRowId, DeA_OpeZalID, DeA_TS_Zal, DeA_OpeModID, DeA_TS_Mod, DeA_CzyPrzenosicNaDostawy, DeA_CzyObowiazkowyDostawy)
  VALUES(4, 'RETURNSNOTICEDATE','ECOD-data zawiadomienia o zwrotach', 4, 0, 0, 0, 0, 1, 0, '', NULL, CAST(GetDate() AS smalldatetime), NULL, CAST( GetDate() AS smalldatetime), 0, 0)
 END
 IF NOT EXISTS ( SELECT * FROM CDN.DefAtrybuty WHERE DeA_Typ=4 AND DeA_Kod='BUYERORDERNUMBER')
 BEGIN
  INSERT INTO CDN.DefAtrybuty (DeA_Typ,DeA_Kod,DeA_Nazwa,DeA_Format,DeA_Zalezny,DeA_CzyKopiowacFA,DeA_CzyKopiowacDoVAT,DeA_CzyKod,DeA_CzyPrzenosic,DeA_CzyDrukowac,DeA_ImportRowId, DeA_OpeZalID, DeA_TS_Zal, DeA_OpeModID, DeA_TS_Mod, DeA_CzyPrzenosicNaDostawy, DeA_CzyObowiazkowyDostawy)
  VALUES(4, 'BUYERORDERNUMBER','ECOD-numer zamówienia lub noty kor.', 1, 0, 0, 0, 0, 0, 0, '', NULL, CAST(GetDate() AS smalldatetime), NULL, CAST( GetDate() AS smalldatetime), 0, 0)
 END
 IF NOT EXISTS ( SELECT * FROM CDN.DefAtrybuty WHERE DeA_Typ=4 AND DeA_Kod='BUYERORDERDATE')
 BEGIN
  INSERT INTO CDN.DefAtrybuty (DeA_Typ,DeA_Kod,DeA_Nazwa,DeA_Format,DeA_Zalezny,DeA_CzyKopiowacFA,DeA_CzyKopiowacDoVAT,DeA_CzyKod,DeA_CzyPrzenosic,DeA_CzyDrukowac,DeA_ImportRowId, DeA_OpeZalID, DeA_TS_Zal, DeA_OpeModID, DeA_TS_Mod, DeA_CzyPrzenosicNaDostawy, DeA_CzyObowiazkowyDostawy)
  VALUES(4, 'BUYERORDERDATE','ECOD-data zamówienia lub noty kor.', 4, 0, 0, 0, 0, 0, 0, '', NULL, CAST(GetDate() AS smalldatetime), NULL, CAST( GetDate() AS smalldatetime), 0, 0)
 END
 IF NOT EXISTS (SELECT * FROM CDN.DefAtrybuty WHERE DeA_Typ=4 AND DeA_Kod='ULTIMATECUSTOMERGLN')
 BEGIN
  INSERT INTO CDN.DefAtrybuty (DeA_Typ,DeA_Kod,DeA_Nazwa,DeA_Format,DeA_Zalezny,DeA_CzyKopiowacFA,DeA_CzyKopiowacDoVAT,DeA_CzyKod,DeA_CzyPrzenosic,DeA_CzyDrukowac,DeA_ImportRowId, DeA_OpeZalID, DeA_TS_Zal, DeA_OpeModID, DeA_TS_Mod, DeA_CzyPrzenosicNaDostawy, DeA_CzyObowiazkowyDostawy)
  VALUES(4, 'ULTIMATECUSTOMERGLN','ECOD-GLN odbiorcy zamówienia', 1, 0, 0, 0, 0, 0, 0, '', NULL, CAST(GetDate() AS smalldatetime), NULL, CAST( GetDate() AS smalldatetime), 0, 0)
 END
END
