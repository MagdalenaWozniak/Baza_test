CREATE PROCEDURE CDN.Med_StanowiskoFormyPlatnosci
   @DStaId int, -- id stanowiska (cdn.detalstanowiska)
   @FPlId int -- id formyplatnosci ( cdn.formyplatnosci)
AS
BEGIN
SET NOCOUNT ON
declare @nazwa NVARCHAR(20)
select  @nazwa  = FPl_nazwa from cdn.formyplatnosci where FPl_FPlId = @FPlId
INSERT INTO DetalFormyPlatnosci
           (DFPl_DStaId
           ,DFPl_FPlId
           ,DFPl_Nazwa
           ,DFPl_NazwaDetal
           ,DFPl_Domyslna)
     VALUES
           (@DStaId,
            @FPlId,
            @Nazwa,
            @Nazwa,
            0)
SET NOCOUNT OFF
END
