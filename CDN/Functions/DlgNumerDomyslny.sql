CREATE FUNCTION CDN.DlgNumerDomyslny(@data DATETIME)
RETURNS @Result TABLE( DefinicjaDokumentuId INT, NumerNr INT, NumerString nvarchar(31), NumerPelny nvarchar(31))
AS
BEGIN
 declare @ddfId int
 declare @symbol nvarchar(5)
 declare @seria nvarchar(20)
 declare @schemat nvarchar(50)
 declare @okresObrachunkowy nvarchar(5)
 declare @numerString NVARCHAR(100)
 declare @numerNr INT;
 declare @numerPelny NVARCHAR(30)
 select Top 1 @okresObrachunkowy = OOb_Symbol FROM CDN.OkresyObrach WHERE @data BETWEEN OOb_DataOtw AND DATEADD(day,-1, DATEADD(MONTH, OOb_Dlugosc, OOb_DataOtw))
 set @okresObrachunkowy = IsNull(@okresObrachunkowy, '')
 select @ddfId = convert(int, IsNull(Fir_Wartosc, 0)) from cdn.firma where fir_numer = 2183
 select @seria = convert(nvarchar, IsNull(Fir_Wartosc, '')) from cdn.firma where fir_numer = 2184
 select @symbol = DDf_Symbol, @schemat = DDf_Numeracja from CDN.DokDefinicje where Ddf_DDfId = @ddfId
 SET @numerString = [CDN].[GetDokNumString](@schemat, [CDN].[GetNumerPelny] (@schemat, @data, @seria, @symbol, 1, N'', @okresObrachunkowy));
 SELECT @numerNr = IsNull(Max(DLN_NumerNr),0)+1 From CDN.DlgNag Where DLN_NumerString = @numerString
 WHILE EXISTS(SELECT DLN_DLNId FROM CDN.DlgNag WHERE DLN_NumerPelny=[CDN].[GetNumerPelny] (@schemat, @data, @seria, @symbol, @numerNr, N'', @okresObrachunkowy))
  SET @numerNr = @numerNr + 1;
 set @numerPelny = [CDN].[GetNumerPelny] (@schemat, @data, @seria, @symbol, @numerNr, N'', @okresObrachunkowy)
 insert into @result (DefinicjaDokumentuId, NumerNr , NumerString, NumerPelny) values(@ddfId, @numerNr, @numerString, @numerPelny)
 return
END
