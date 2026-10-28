CREATE PROCEDURE [CDN].[Detal_SprawdzCzyIstniejeStanowisko]
  @ID INT      -- ID Detalu
AS
SET NOCOUNT ON
DECLARE
@Komunikat             NVARCHAR(255)
if not exists (select DSta_DStaId from cdn.detalstanowiska where DSta_DStaId = @ID and DSta_Typ = 1 and DSta_Nieaktywne = 0)
begin
    SET @Komunikat = 'Nie istnieje stanowisko w konfiguracji Optimy o ID = ' + convert(NVARCHAR(16),@ID)
    RAISERROR(@Komunikat, 16, 1)
    SET NOCOUNT OFF
    RETURN
end
SET NOCOUNT OFF
