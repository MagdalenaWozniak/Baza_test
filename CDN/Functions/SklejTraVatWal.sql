CREATE  FUNCTION CDN.SklejTraVatWal (@TrNId INT)
RETURNS NVARCHAR(255)
AS
BEGIN
  DECLARE @StawkaVat NUMERIC(5,2)
  DECLARE @FlagaVat  SMALLINT
  DECLARE @Netto     NUMERIC(15,2)
  DECLARE @Vat       NUMERIC(15,2)
  DECLARE @Brutto    NUMERIC(15,2)
  DECLARE @TabelaVat NVARCHAR(255)
  DECLARE @Stawka    CHAR(5)
  SET @TabelaVat = ''
  DECLARE AgregatyVat CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrV_Stawka, TrV_Flaga, SUM(TrV_NettoWal), SUM(TrV_VatWal), SUM(TrV_NettoWal+TrV_VatWal)
      FROM CDN.TraVat
      WHERE TrV_TrNId = @TrNId
      GROUP BY TrV_Stawka, TrV_Flaga
      ORDER BY TrV_Flaga, TrV_Stawka
    OPEN AgregatyVat
    WHILE 1 = 1
      BEGIN
        FETCH NEXT FROM AgregatyVat INTO @StawkaVat, @FlagaVat, @Netto, @Vat, @Brutto
          IF @@FETCH_STATUS <> 0 BREAK
        SET @Stawka = CASE @FlagaVat WHEN 1 THEN '  ZW.' WHEN 4 THEN '  NP.' ELSE STR(@StawkaVat, 3)+' %' END
        SET @TabelaVat = @TabelaVat + @Stawka + STR(@Netto, 15, 2) + STR(@Vat, 15, 2) -- + STR(@Brutto, 15, 2)
      END
  CLOSE AgregatyVat
  RETURN @TabelaVat
END
