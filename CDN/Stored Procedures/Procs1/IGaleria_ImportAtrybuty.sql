CREATE   PROCEDURE [CDN].[IGaleria_ImportAtrybuty]
  @IGA_IGKIdChr            nvarchar(11),
  @IGA_IGAIdChr         nvarchar(11),
  @IGA_Nazwa      nvarchar(100),
  @IGA_TypChr                       nvarchar(2),
  @IGA_Jednostka                    nvarchar(30),
  @IGA_AktywnyChr                   nvarchar(2),
  @IGA_DowolnaWartoscChr            nvarchar(2)
AS
  SET NOCOUNT ON
  DECLARE
  @IGA_IGKId                 INT,
  @IGA_IGAId                 INT,
  @IGA_Typ                   TINYINT,
  @IGA_Aktywny               TINYINT,
  @IGA_DowolnaWartosc        TINYINT
  SELECT
    @IGA_IGKId            = CONVERT(INT,@IGA_IGKIdChr),
    @IGA_IGAId            = CONVERT(INT,@IGA_IGAIdChr),
    @IGA_Typ              = CONVERT(INT,@IGA_TypChr),
    @IGA_Aktywny          = CONVERT(TINYINT,@IGA_AktywnyChr),
    @IGA_DowolnaWartosc   = CONVERT(TINYINT,@IGA_DowolnaWartoscChr)
  IF NOT EXISTS ( SELECT IGA_IGAId FROM CDN.IGaleriaAtrybuty WHERE IGA_IGAId = @IGA_IGAId)
   INSERT INTO [CDN].[IGaleriaAtrybuty]
           ([IGA_IGAId]
           ,[IGA_IGKId]
           ,[IGA_Nazwa]
           ,[IGA_Typ]
           ,[IGA_Jednostka]
           ,[IGA_Aktywny]
           ,[IGA_DowolnaWartosc])
     VALUES
           (@IGA_IGAId
           ,@IGA_IGKId
           ,@IGA_Nazwa
           ,@IGA_Typ
           ,@IGA_Jednostka
           ,@IGA_Aktywny
           ,@IGA_DowolnaWartosc)
  ELSE
    UPDATE  CDN.IGaleriaAtrybuty
    SET IGA_IGKId          = @IGA_IGKId
       ,IGA_Nazwa          = @IGA_Nazwa
       ,IGA_Typ            = @IGA_Typ
       ,IGA_Jednostka      = @IGA_Jednostka
       ,IGA_Aktywny        = @IGA_Aktywny
       ,IGA_DowolnaWartosc = @IGA_DowolnaWartosc
    WHERE
       IGA_IGAId = @IGA_IGAId
SET NOCOUNT OFF
