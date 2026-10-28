CREATE FUNCTION CDN.SklejTraVatZaliczki (@TrNId INT)
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
 select
 TrZ_Stawka, TrZ_Flaga, SUM(TrZ_KwotaNetto), SUM(TrZ_KwotaVat), SUM(TrZ_KwotaBrutto)
  from CDN.TraFakZaliczkowe where TrZ_TrnID = @TrNId
 and Trz_Uwzgledniac = 1
 group by TrZ_Stawka, TrZ_Flaga
 ORDER BY TrZ_Stawka, TrZ_Flaga
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
