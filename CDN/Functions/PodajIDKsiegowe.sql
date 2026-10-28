CREATE FUNCTION CDN.PodajIDKsiegowe(@data DATETIME, @rejestr NVARCHAR(20), @OOBID INT, @DDfID INT, @BaseTable INT)
RETURNS NVARCHAR(1000)
AS
BEGIN
 declare @result NVARCHAR(1000); set @result = null;
 declare @schematNumeracji NVARCHAR(50), @symbolNumeracji NVARCHAR(5), @rok_obr NVARCHAR(5), @numerString NVARCHAR(100), @numerNr INT;
 SELECT @schematNumeracji=DDf_Numeracja,@symbolNumeracji=DDf_Symbol from CDN.DokDefinicje WHERE DDf_DDfID = @DDfID
    SET @rok_obr  = ISNULL(( SELECT TOP 1 OOb_Symbol FROM CDN.OkresyObrach WHERE @data BETWEEN OOb_DataOtw AND DATEADD(day,-1, DATEADD(MONTH, OOb_Dlugosc, OOb_DataOtw))),'')
 SET @numerString = [CDN].[GetDokNumString](@schematNumeracji, [CDN].[GetNumerPelny] (@schematNumeracji, @data, @rejestr, @symbolNumeracji, 1, N'', @rok_obr));
 IF( @BaseTable = 1 ) -- dekrety
 BEGIN
  SELECT @numerNr = IsNull(Max(DeN_IdentKsiegNr),0)+1 From CDN.DekretyNag Where DeN_IdentKsiegStr = @numerString
  set @result = [CDN].[GetNumerPelny] (@schematNumeracji, @data, @rejestr, @symbolNumeracji, @numerNr, N'', @rok_obr)
  if exists(SELECT * FROM CDN.DekretyNag WHERE DeN_IdentKsieg=@result)
  begin
   WHILE EXISTS(SELECT DeN_DeNID FROM CDN.DekretyNag WHERE DeN_IdentKsieg=[CDN].[GetNumerPelny] (@schematNumeracji, @data, @rejestr, @symbolNumeracji, @numerNr, N'', @rok_obr))
    SET @numerNr = @numerNr + 1;
   set @result = [CDN].[GetNumerPelny] (@schematNumeracji, @data, @rejestr, @symbolNumeracji, @numerNr, N'', @rok_obr);
  end
 END
 ELSE IF ( @BaseTable = 2 ) -- vaty
 BEGIN
  SELECT @numerNr = IsNull(Max(VaN_IdentKsiegNr),0)+1 From CDN.VatNag Where VaN_IdentKsiegStr = @numerString
  set @result = [CDN].[GetNumerPelny] (@schematNumeracji, @data, @rejestr, @symbolNumeracji, @numerNr, N'', @rok_obr)
  if exists(SELECT * FROM CDN.VatNag WHERE VaN_IdentKsieg=@result)
  begin
   WHILE EXISTS(SELECT VaN_VaNID FROM CDN.VatNag WHERE VaN_IdentKsieg=[CDN].[GetNumerPelny] (@schematNumeracji, @data, @rejestr, @symbolNumeracji, @numerNr, N'', @rok_obr))
    SET @numerNr = @numerNr + 1;
   set @result = [CDN].[GetNumerPelny] (@schematNumeracji, @data, @rejestr, @symbolNumeracji, @numerNr, N'', @rok_obr)
  end
 END
 RETURN @result
END
