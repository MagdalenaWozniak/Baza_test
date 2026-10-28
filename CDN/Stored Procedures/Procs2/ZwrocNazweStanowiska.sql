CREATE PROCEDURE CDN.ZwrocNazweStanowiska @IdStanowiska INT
AS
BEGIN
SET NOCOUNT ON;
DECLARE @NazwaBazy nvarchar(300)
select @NazwaBazy = CDN.BazaKonfiguracyjna()
EXEC CDN.ExecSQL 'SELECT Sta_Nazwa FROM', @NazwaBazy, '.CDN.Stanowiskakomp WHERE Sta_StaId=', @IdStanowiska
END
SET NOCOUNT OFF;
