CREATE PROCEDURE CDN.ZwrocSymbolWalSys
AS
BEGIN
SET NOCOUNT ON;
DECLARE @NazwaBazy nvarchar(300)
select @NazwaBazy = CDN.BazaKonfiguracyjna()
EXEC CDN.ExecSQL 'SELECT WNa_Symbol FROM', @NazwaBazy, '.CDN.WalNazwy WHERE WnA_WnaId=1'
END
SET NOCOUNT OFF
