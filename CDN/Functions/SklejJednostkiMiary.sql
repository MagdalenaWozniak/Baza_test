CREATE FUNCTION CDN.SklejJednostkiMiary (@TrNId INT)
RETURNS NVARCHAR(255)
AS
BEGIN
  DECLARE @TrEJM NVARCHAR(20)
  DECLARE @IloscJM  DECIMAL(15,0)
  DECLARE @SumaJednostekMiar NVARCHAR(255)
  SET @SumaJednostekMiar = ''
  DECLARE SumujJednostkiMiary CURSOR LOCAL FAST_FORWARD FOR
     SELECT TrE_Jm, SUM(TrE_IloscJM)
      FROM CDN.TraElem
      WHERE TrE_TrNId = @TrNId AND (TrE_Kaucja = 1 OR TrE_TypDokumentu IN(314,313))
      GROUP BY TrE_Jm
      OPEN SumujJednostkiMiary
    WHILE 1 = 1
      BEGIN
        FETCH NEXT FROM SumujJednostkiMiary INTO @TrEJM, @IloscJM
          IF @@FETCH_STATUS <> 0 BREAK
        SET @SumaJednostekMiar = @SumaJednostekMiar + STR(@IloscJM, 15, 0)+ ' ' + CONVERT (CHAR(20),@TrEJM)
      END
  CLOSE SumujJednostkiMiary
  RETURN @SumaJednostekMiar
END
