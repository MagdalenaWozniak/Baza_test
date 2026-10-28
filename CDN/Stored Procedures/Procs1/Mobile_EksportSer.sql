CREATE Procedure [CDN].[Mobile_EksportSer]
@ID    INT
AS
SELECT  1 as SER_GIDNumer,
        rtrim(DSta_Seria)as SER_Nazwa
FROM    CDN.DetalStanowiska where DSta_DStaId = @ID
