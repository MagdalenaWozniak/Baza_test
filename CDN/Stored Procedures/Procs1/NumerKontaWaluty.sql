CREATE PROCEDURE CDN.NumerKontaWaluty
 @AWaluta NVARCHAR(3),
 @ATypKonta NVARCHAR(2)
AS
BEGIN
 SET NOCOUNT ON
 DECLARE @result NVARCHAR(50)
 DECLARE @sqlst NVARCHAR(300)
 DECLARE @NazwaBazy nvarchar(300)
 select @NazwaBazy = CDN.BazaKonfiguracyjna()
 EXEC CDN.sp_ExecSQL 'SELECT WNa_Konto',@ATypKonta, ' FROM ', @NazwaBazy,'.CDN.WalNazwy WHERE WNa_Symbol =''',@AWaluta, ''''
 SET NOCOUNT OFF
END
