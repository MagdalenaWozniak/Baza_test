CREATE PROCEDURE CDN.OFF_AktualizujWzorRabatu
    @SposobLiczeniaRabatu        nvarchar(254),
    @WzorRabatGlobalny           nvarchar(254),
    @WzorRabatuPozycja           nvarchar(254)
AS
  SET NOCOUNT ON
      EXEC CDN.OFF_AktualizujFirma 1559, @SposobLiczeniaRabatu, 'SynchroXLMagSposobLiczeniaRabatu'
      EXEC CDN.OFF_AktualizujFirma 1560, @WzorRabatGlobalny, 'SynchroXLMagWzorRabatGlobalny'
        EXEC CDN.OFF_AktualizujFirma 1561, @WzorRabatuPozycja, 'SynchroXLMagWzorRabatPozycja'
  SET NOCOUNT OFF
