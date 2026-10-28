CREATE PROCEDURE [CDN].[DetalStan_UaktualnijKorekte]
@RazemBrutto decimal (15, 2),
@Ts_zal datetime,
@Bufor smallint,
@Id int,
@OsobaOdbierajaca NVARCHAR(40),
@Opis NVARCHAR(1024)
AS
BEGIN
SET NOCOUNT ON
UPDATE CDN.DetalStanTraNag SET
 DSTrN_RazemBrutto = @RazemBrutto,
 DSTrN_TS_Zal = @Ts_zal,
 DSTrN_Bufor = @Bufor,
 DSTrN_OsobaOdbierajaca = @OsobaOdbierajaca,
 DSTrN_Opis = @Opis
 WHERE DSTrN_DSTrNID = @Id
SET NOCOUNT OFF
END
