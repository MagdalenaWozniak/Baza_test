CREATE PROCEDURE [CDN].[IGaleria_ImportInfoBlok]
  @TSSynchrPtw                    nvarchar(50),
  @TSSynchrTwrPtw                 nvarchar(50),
  @TSSynchrKnt                    nvarchar(50)
AS
  SET NOCOUNT ON
   UPDATE cdn.eSklepStanowiska SET ESS_TS_SynchroPotw = @TSSynchrPtw,ESS_TS_SynchroTwrPotw = @TSSynchrTwrPtw,ESS_TS_SynchroKntPotw = @TSSynchrKnt
    WHERE ESS_typ = 2
 --UPDATE CDN.Firma SET Fir_Wartosc = @TSSynchrPtw WHERE Fir_Numer = 1930
 --UPDATE CDN.Firma SET Fir_Wartosc = @TSSynchrTwrPtw WHERE Fir_Numer = 1934
 --UPDATE CDN.Firma SET Fir_Wartosc = @TSSynchrKnt WHERE Fir_Numer = 1932
  SET NOCOUNT OFF
