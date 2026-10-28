CREATE PROCEDURE [CDN].[Detal_AktualizujKartyOperatorow]
AS
BEGIN
SET NOCOUNT ON
DECLARE @kod NVARCHAR(20)
DECLARE @karta NVARCHAR(254)
CREATE TABLE #Operators (OpeKod NVARCHAR(20), OpeKarta NVARCHAR(254))
INSERT INTO #Operators Select DSOpe_Kod, DSOpe_Karta FROM CDN.DetalStanOperatorzy WHERE
DSOPe_Karta <> '' GROUP BY DSOpe_Kod, DSOpe_Karta
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  select #Operators.* from #Operators
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
            @kod, @karta
    IF @@FETCH_STATUS <> 0 BREAK
    UPDATE CDN.DetalStanOperatorzy SET DSOPe_Karta = @karta
   WHERE DSOpe_Kod = @kod
  END
  CLOSE Dodawane
  DEALLOCATE Dodawane
SET NOCOUNT OFF
END
