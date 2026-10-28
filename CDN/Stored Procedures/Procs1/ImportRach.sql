CREATE PROCEDURE CDN.ImportRach
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@BRa_ImportRowId nvarchar(36),
@BRa_Symbol nvarchar(5),
@BRa_Akronim nvarchar(20),
@BRa_Nazwa nvarchar(40),
@BRa_Typ smallint,
@BRa_Waluta nvarchar(3),
@BRa_KursL decimal(15,4),
@BRa_KursM decimal(5,0),
@BRa_SaldoBOSys decimal(15,2),
@WKu_Symbol1 nvarchar(5),
@WKu_Symbol2 nvarchar(5),
@WKu_Symbol3 nvarchar(5),
@BNa_Numer nvarchar(10),
@BNa_ImportRowId nvarchar(36),
@BRa_RachunekNr nvarchar(51),
@BRa_IBAN tinyint,
@KKr_Nazwa nvarchar(20),
@BRa_KartaDW nvarchar(10),
@BRa_BRpOkres smallint,
@BRa_SaldoBO decimal(15,2),
@BRa_LimitKredytu decimal(15,2),
@BRa_OprocRachunku decimal(7,3),
@BRa_OprocKredytu decimal(7,3),
@BRa_OprocKarne decimal(7,3),
@BRa_KaraZaPrzekr decimal(15,2),
@DDf_Symbol nvarchar(5),
@DDf_ImportRowId nvarchar(36),
@BRa_NumeryObce smallint,
@BRa_KontoPrzeciwstawne nvarchar(50),
@BRa_Nieaktywny smallint,
@BRa_PrzelewySEPA smallint,
@BRa_SplitPay tinyint,
@ZrdId nvarchar(5),
@OpeId int,
@SlowId int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
BEGIN
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 DECLARE @OperationType INT
 SET @OperationType = 0
 DECLARE @DDf_Id int
 DECLARE @BNa_id int
 DECLARE @BRa_KursSprzedazyNr int
 DECLARE @BRa_KursZakupuNr int
 DECLARE @BRa_KursNumer int
 DECLARE @BRa_KKrID int
 DECLARE @sqltxt NVARCHAR (1000),@TmpSrvName SYSNAME
 SET @DDf_Id = CDN.GetDDfIDFromRowIDOrSymbol(@DDf_ImportRowId, @DDf_Symbol);
 SELECT @BNa_Id = BNa_BNaId
 FROM CDN.BnkNazwy
 WHERE BNa_ImportRowId = @BNa_ImportRowId
 IF @BNa_Id is NULL
  SELECT @BNa_Id = BNa_BNaId
  FROM CDN.BnkNazwy
  WHERE BNa_Numer = @BNa_Numer
 EXECUTE @BRa_KursSprzedazyNr = CDN.GetTypKursuWaluty @WKu_Symbol1, @ConfigDBName, @ServerName
 EXECUTE @BRa_KursZakupuNr = CDN.GetTypKursuWaluty @WKu_Symbol2, @ConfigDBName, @ServerName
 EXECUTE @BRa_KursNumer = CDN.GetTypKursuWaluty @WKu_Symbol3, @ConfigDBName, @ServerName
 SELECT  @BRa_KKrId = KKr_KKrId
 FROM CDN.KartyKredytowe
 WHERE KKr_Nazwa = @KKr_Nazwa
 IF((SELECT count(*)
  FROM CDN.BnkRachunki
  WHERE (IsNull(@BRa_ImportRowId, '') <> '' AND  BRa_ImportRowId = @BRa_ImportRowId)
    OR (IsNull(@BRa_ImportRowId, '') = '' AND BRa_Akronim = @BRa_Akronim)) = 0)
 BEGIN
  INSERT INTO CDN.BnkRachunki
  (
  BRa_ImportRowId,
  BRa_Symbol,
  BRa_Akronim,
  BRa_Nazwa,
  BRa_Typ,
  BRa_Waluta,
  BRa_KursL,
  BRa_KursM,
  BRa_SaldoBOSys,
  BRa_KursSprzedazyNr,
  BRa_KursZakupuNr,
  BRa_KursNumer,
  BRa_BNaId,
  BRa_RachunekNr,
  BRa_IBAN,
  BRa_KKrId,
  BRa_KartaDW,
  BRa_BRpOkres,
  BRa_SaldoBO,
  BRa_LimitKredytu,
  BRa_OprocRachunku,
  BRa_OprocKredytu,
  BRa_OprocKarne,
  BRa_KaraZaPrzekr,
  BRa_DDfId,
  BRa_NumeryObce,
  BRa_KontoPrzeciwstawne,
  BRa_Nieaktywny,
  BRa_MagazynWalut,
  BRa_KursHistorycznyMW,
  BRa_RozKur2SumaMW,
  BRa_PrzelewySEPA,
  BRa_SplitPay,
  BRa_TS_Mod,
  BRa_TS_Zal,
  BRa_OpeZalId,
  Bra_OpeZalKod,
  Bra_OpeZalNazwisko,
  Bra_OpeModId,
  Bra_OpeModKod,
  Bra_OpeModNazwisko,
  Bra_TS_Export,
  Bra_ImportAppId
  )
  VALUES
  (
  @BRa_ImportRowId,
  @BRa_Symbol,
  @BRa_Akronim,
  @BRa_Nazwa,
  @BRa_Typ,
  @BRa_Waluta,
  case when @BRa_KursL=0 then 1 else @BRa_KursL end,
  case when @BRa_KursM=0 then 1 else @BRa_KursM end,
  @BRa_SaldoBOSys,
  @BRa_KursSprzedazyNr,
  @BRa_KursZakupuNr,
  @BRa_KursNumer,
  @BNa_Id,
  IsNull(@BRa_RachunekNr, ''),
  IsNull(@BRa_IBAN, 0),
  @BRa_KKrId,
  convert(datetime, @BRa_KartaDW, 120),
  @BRa_BRpOkres,
  @BRa_SaldoBO,
  @BRa_LimitKredytu,
  @BRa_OprocRachunku,
  @BRa_OprocKredytu,
  @BRa_OprocKarne,
  @BRa_KaraZaPrzekr,
  @DDf_Id,
  @BRa_NumeryObce,
  @BRa_KontoPrzeciwstawne,
  @BRa_Nieaktywny,
  0, --BRa_MagazynWalut
  0,
  0,
  @BRa_PrzelewySEPA,
  IsNull(@BRa_SplitPay, 0),
  GETDATE(),
  GETDATE(),
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  @OpeId,
  @OpeModKod,
  @OpeModNazwisko,
  GETDATE(),
  @ZrdId
  )
  SELECT @SlowID = SCOPE_IDENTITY()
  SET @OperationType = 1 -- OptimaOperationType_Dodanie
 END
 ELSE IF ( @OnlyNew <> 1 )
 BEGIN
 -- jezeli sa raporty do tego rejstru, to nie zmieniamy schematu numeracji!
  SET @DDf_Id = CASE WHEN EXISTS(SELECT BRp_BRpID FROM CDN.BnkRaporty INNER JOIN CDN.BnkRachunki ON BRa_BraID=BRp_BRaID
           WHERE (IsNull(@BRa_ImportRowId, '') <> '' AND  BRa_ImportRowId = @BRa_ImportRowId)
           OR (IsNull(@BRa_ImportRowId, '') = '' AND BRa_Akronim = @BRa_Akronim) )
             THEN NULL
       ELSE @DDf_Id
        END
  SELECT @SlowID = BRa_BRaID FROM CDN.BnkRachunki WHERE (IsNull(@BRa_ImportRowId, '') <> '' AND  BRa_ImportRowId = @BRa_ImportRowId) OR (IsNull(@BRa_ImportRowId, '') = '' AND BRa_Akronim = @BRa_Akronim)
  UPDATE CDN.BnkRachunki
  SET
  BRa_ImportRowId = @BRa_ImportRowId,
  BRa_Symbol = @BRa_Symbol,
  BRa_Akronim = @BRa_Akronim,
  BRa_Nazwa = @BRa_Nazwa,
  BRa_Typ = @BRa_Typ,
  BRa_Waluta = @BRa_Waluta,
  BRa_KursL = @BRa_KursL,
  BRa_KursM = @BRa_KursM,
  BRa_SaldoBOSys = @BRa_SaldoBOSys,
  BRa_KursSprzedazyNr = @BRa_KursSprzedazyNr,
  BRa_KursZakupuNr = @BRa_KursZakupuNr,
  BRa_KursNumer = @BRa_KursNumer,
  BRa_BNaId = @BNa_Id,
  BRa_RachunekNr = IsNull(@BRa_RachunekNr, ''),
  BRa_IBAN = IsNull(@BRa_IBAN, 0),
  BRa_KKrId = @BRa_KKrId,
  BRa_KartaDW = convert(datetime, @BRa_KartaDW, 120),
  BRa_BRpOkres = @BRa_BRpOkres,
  BRa_SaldoBO = @BRa_SaldoBO,
  BRa_LimitKredytu = @BRa_LimitKredytu,
  BRa_OprocRachunku = @BRa_OprocRachunku,
  BRa_OprocKredytu = @BRa_OprocKredytu,
  BRa_OprocKarne = @BRa_OprocKarne,
  BRa_KaraZaPrzekr = @BRa_KaraZaPrzekr,
  BRa_DDfId = ISNULL(@DDf_Id,BRa_DDfId),
  BRa_NumeryObce = @BRa_NumeryObce,
  -- BRa_KontoPrzeciwstawne = @BRa_KontoPrzeciwstawne, -- TID: 150969
  BRa_Nieaktywny = @BRa_Nieaktywny,
  BRa_PrzelewySEPA = @BRa_PrzelewySEPA,
  BRa_SplitPay = IsNull(@BRa_SplitPay, 0),
  BRa_TS_Mod = GETDATE(),
  BRa_OpeModId = @OpeId,
  BRa_OpeModKod = @OpeModKod,
  BRa_OpeModNazwisko = @OpeModNazwisko
  WHERE BRa_BRaID = @SlowID
  SET @OperationType = 2 -- OptimaOperationType_Modyfikacja
 END
 ELSE
  RAISERROR('##OPT33041##', 16, 1) --RAISERROR('Taki zapis już istnieje. Element nie został dodany', 16, 1)
 IF @OperationType <> 0
  EXEC [CDN].[RejestrOperacjiDodaj]
    @ObiektTyp = 1120, -- OptimaObjectType_Rachunek
    @ObiektSubTyp = 0,
    @ObiektID = @SlowID,
    @ObiektNazwa = @BRa_Symbol,
    @OperacjaTyp = @OperationType,
    @Opis = '' --@BRa_Nazwa
END
