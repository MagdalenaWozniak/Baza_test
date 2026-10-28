CREATE PROCEDURE [CDN].[ESLKEP_ImportInfoBlok]
   @IDOddzialu                     nvarchar(50),  -- nie uzywane
  @TSSynchrPtw                    nvarchar(50),
  @TSSynchrTwrPtw                 nvarchar(50),
  @TSSynchrGrupPtw                nvarchar(50),
  @TSSynchrKnt                    nvarchar(50),
  @TSSynchrKntOptimaPtw           nvarchar(50),
  @TSSynchrCSellingPtw            nvarchar(50),
  @TSSynchrBinPtw      nvarchar(50),
  @TypSklepu          TINYINT,
  @WersjaProt          DECIMAL(5,2)
AS
  SET NOCOUNT ON
  update cdn.eSklepStanowiska set ESS_TS_SynchroPotw = @TSSynchrPtw,ESS_TS_SynchroTwrPotw= @TSSynchrTwrPtw,
  ESS_TS_SynchroGrupPotw = @TSSynchrGrupPtw,ESS_TS_SynchroKntPotw = @TSSynchrKnt,ESS_TS_SynchroKntOptimaPotw = @TSSynchrKntOptimaPtw,
  ESS_TS_SynchroZestawyTwrPotw = @TSSynchrCSellingPtw , ESS_TS_SynchroBinPotw = @TSSynchrBinPtw, ESS_TypSklepu = @TypSklepu, ESS_WersjaProt = @WersjaProt where ESS_IdISklep = convert( int , @IDOddzialu)
 --UPDATE CDN.Firma SET Fir_Wartosc = @TSSynchrPtw WHERE Fir_Numer = 1828
 -- UPDATE CDN.Firma SET Fir_Wartosc = @TSSynchrTwrPtw WHERE Fir_Numer = 1836
 --UPDATE CDN.Firma SET Fir_Wartosc = @TSSynchrGrupPtw WHERE Fir_Numer = 1841
 --UPDATE CDN.Firma SET Fir_Wartosc = @TSSynchrKnt WHERE Fir_Numer = 1830
  SET NOCOUNT OFF
