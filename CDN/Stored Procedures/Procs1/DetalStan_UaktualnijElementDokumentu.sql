CREATE PROCEDURE [CDN].[DetalStan_UaktualnijElementDokumentu]
@Cena decimal(15, 2),
@Rabat decimal(5, 2),
@CenaPoRabacie decimal(15, 2),
@Ilosc decimal(15, 4),
@JM nvarchar(20),
@JMPrzelicznikL decimal(15, 2),
@JMPrzelicznikM decimal(7, 0),
@StornoId int,
@WartBrutto decimal(15, 2),
@Waluta NVARCHAR(3),
@Id int
AS
BEGIN
SET NOCOUNT ON
UPDATE CDN.DetalStanTraElem
SET DSTrE_Cena = @Cena,
 DSTrE_Rabat = @Rabat,
 DSTrE_CenaPoRabacie = @CenaPoRabacie,
 DSTrE_Ilosc = @Ilosc,
 DSTrE_JM = @JM,
 DSTrE_JMPrzelicznikL = @JMPrzelicznikL,
 DSTrE_JMPrzelicznikM = @JMPrzelicznikM,
 DSTrE_StornoID = @StornoId,
 DSTrE_WartoscBrutto = @WartBrutto,
 DSTrE_Waluta = @Waluta
WHERE DSTrE_DSTrEID = @Id
SET NOCOUNT OFF
END
