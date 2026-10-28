CREATE PROCEDURE [CDN].[IGaleria_EksportInfoBlok]
 @ExpOpcje     INT    -- Maska opcji eksportu
AS
 SET NOCOUNT ON
 DECLARE
     @TSSynchr nvarchar(254),
     @TSSynchrTwr nvarchar(254),
     @TSSynchrKntPtw nvarchar(254),
     @TimeStamp INT,
     @CustomerID    INT,
     @TypSynchro    INT,
     @CzyOstatniPlik INT
     SET @TimeStamp = DATEDIFF(s,CONVERT(DATETIME,'19900101',121),GETDATE())
  IF (@ExpOpcje  = 0)    -- eksport potwierdzeń i statusuów
  UPDATE cdn.eSklepStanowiska SET ESS_TS_Synchro = @TimeStamp WHERE ESS_typ = 2
     --UPDATE CDN.Firma SET Fir_Wartosc = @TimeStamp WHERE Fir_Numer = 1929
     IF (@ExpOpcje & 1 = 1)   -- eksport cennika
        UPDATE cdn.eSklepStanowiska SET ESS_TS_SynchroTwr = @TimeStamp WHERE ESS_typ = 2
        --UPDATE CDN.Firma SET Fir_Wartosc = @TimeStamp WHERE Fir_Numer = 1933
     select  top 1 @TSSynchr = ESS_TS_Synchro ,@TSSynchrTwr = ESS_TS_SynchroTwr,@TSSynchrKntPtw = ESS_TS_SynchroKntPotw,@CustomerID = ESS_IdKlienta
     from cdn.eSklepStanowiska where ESS_typ = 2
        --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1929) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1929
        --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1933) SELECT @TSSynchrTwr = 0 ELSE SELECT @TSSynchrTwr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1933
        --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1932) SELECT @TSSynchrKntPtw = 0 ELSE SELECT @TSSynchrKntPtw = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1932
        --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1911) SELECT @CustomerID = 0 ELSE SELECT @CustomerID = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1911
     IF (@ExpOpcje & 1 = 0)
  set @CzyOstatniPlik = 1
     ELSE
     begin
         exec [CDN].[IGaleria_CzyEksportDaneBinarne] @ExpOpcje,@CzyOstatniPlik OUTPUT
         if @CzyOstatniPlik = 1
            set @CzyOstatniPlik = 0
         else
            set @CzyOstatniPlik = 1
     end
SELECT  TOP 1
   @CustomerID     AS CustomerID
  ,@TSSynchr       AS TSSynchr
  ,@TSSynchrTwr    AS TSSynchrTwr
  ,@TSSynchrKntPtw AS TSSynchrKntPtw
  ,@ExpOpcje       AS EksportTyp
  ,1               AS ZrodloID
  ,@CzyOstatniPlik AS Koniec
FROM CDN.Firma     AS INFOBLOK
FOR XML AUTO
SET NOCOUNT OFF
