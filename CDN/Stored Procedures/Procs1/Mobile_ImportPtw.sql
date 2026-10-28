CREATE PROCEDURE [CDN].[Mobile_ImportPtw]
@GIDTyp int,
@GIDNumer int,
@IDO int,
@Typ int
AS
BEGIN
SET NOCOUNT ON
SET ARITHABORT ON
update cdn.tranag set trn_GIDNumer = @IDO where trn_trnid = @GIDNumer
SET NOCOUNT OFF
SET ARITHABORT OFF
END
