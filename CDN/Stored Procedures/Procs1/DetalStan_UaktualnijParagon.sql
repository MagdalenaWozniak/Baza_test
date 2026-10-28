CREATE PROCEDURE [CDN].[DetalStan_UaktualnijParagon]
@RazemBrutto decimal (15, 2),
@Rabat decimal (5, 2),
@Ts_zal datetime,
@Bufor smallint,
@KontrahentId int,
@Waluta NVARCHAR(3),
@Fiskalna tinyint,
@Error int,
@FAID int,
@OsOdbierajaca NVARCHAR(40),
@Id int,
@OpeId int,
@Opis NVARCHAR(1024)
AS
BEGIN
SET NOCOUNT ON
IF @OpeId > 0
BEGIN
 UPDATE CDN.DetalStanTraNag SET
 DSTrN_RazemBrutto = @RazemBrutto,
 DSTrN_Rabat = @Rabat,
 DSTrN_TS_Zal = @Ts_zal,
 DSTrN_Bufor = @Bufor,
 DSTrN_PodID = @KontrahentId,
 DSTrN_OdbID = @KontrahentId,
 DSTrN_Waluta = @Waluta,
 DSTrN_Fiskalna = @Fiskalna,
 DSTrN_FiskalnaErr = @Error,
 DSTrN_FaId = @FAID,
 DSTrN_OsobaOdbierajaca = @OsOdbierajaca,
 DSTrN_OpeID = @OpeId,
 DSTRN_Opis = @Opis
 WHERE DSTrN_DSTrNID = @Id
END
ELSE
BEGIN
 UPDATE CDN.DetalStanTraNag SET
 DSTrN_RazemBrutto = @RazemBrutto,
 DSTrN_Rabat = @Rabat,
 DSTrN_TS_Zal = @Ts_zal,
 DSTrN_Bufor = @Bufor,
 DSTrN_PodID = @KontrahentId,
 DSTrN_OdbID = @KontrahentId,
 DSTrN_Waluta = @Waluta,
 DSTrN_Fiskalna = @Fiskalna,
 DSTrN_FiskalnaErr = @Error,
 DSTrN_FaId = @FAID,
 DSTrN_OsobaOdbierajaca = @OsOdbierajaca,
 DSTRN_Opis = @Opis
 WHERE DSTrN_DSTrNID = @Id
END
SET NOCOUNT OFF
END
