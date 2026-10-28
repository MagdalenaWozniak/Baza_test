CREATE PROCEDURE [CDN].[DetalStan_ImportTraElem]
  @ID INT      -- ID Detalu
 ,@DateTSSynchr DATETIME  -- TimeStemp ostatniej synchronizacji
 ,@CzyTaSamaBaza tinyint
AS
SET NOCOUNT ON
declare
 @DSTrEID int ,
 @DSTrNID int ,
 @ZwrID int ,
 @TwrID int ,
 @Stawka decimal(5, 2) ,
 @Flaga smallint ,
 @Cena decimal(17, 4) ,
 @Rabat decimal(5, 2) ,
 @CenaPoRabacie decimal(17, 4) ,
 @Kaucja tinyint ,
 @Ilosc decimal(15, 4) ,
 @IloscJM decimal(15, 4) ,
 @Jm nvarchar(20) ,
 @JmCalkowite tinyint ,
 @JMPrzelicznikL decimal(15, 2),
 @JMPrzelicznikM decimal(7, 0),
 @WartoscBrutto decimal(15, 2)
if @CzyTaSamaBaza = 1
BEGIN
 DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
  SELECT
 DSTrE_DSTrEID ,
 DSTrE_DSTrNID ,
 DSTrE_ZwrID ,
 DSTwr_OptimaId ,
 DSTrE_Stawka ,
 DSTrE_Flaga ,
 DSTrE_Cena ,
 DSTrE_Rabat ,
 DSTrE_CenaPoRabacie ,
 DSTrE_Kaucja ,
 DSTrE_Ilosc ,
 DSTrE_Jm ,
 DSTrE_JmCalkowite ,
 DSTrE_JMPrzelicznikL ,
 DSTrE_JMPrzelicznikM ,
 DSTrE_WartoscBrutto
  FROM CDN.DetalStanTraElem join CDN.DetalStanTowary ON DSTrE_TwrID = DSTwr_DSTwrID
join CDN.DetalStanTraNag C ON DSTrE_DSTrNID = C.DSTrN_DSTrNID
join CDN.DetalTraNag X ON DSTrE_DSTrNID = X.DTrN_DSTrNID
left join CDN.DetalStanTraNag D ON C.DSTrN_FAID = D.DSTrN_DSTrNID
where C.DSTrN_Bufor = 0 and ISNULL(D.DSTrN_Bufor,0) = 0 and ISNULL(C.DSTrN_StanSynchronizacji,0) < 2 and  DSTrE_StornoID = 0 AND DSTrE_Ilosc <>0 and C.DSTrN_StanDetalID = @ID
   OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
 @DSTrEID ,
 @DSTrNID ,
 @ZwrID ,
 @TwrID ,
 @Stawka ,
 @Flaga ,
 @Cena ,
 @Rabat ,
 @CenaPoRabacie ,
 @Kaucja ,
 @IloscJM ,
 @Jm ,
 @JmCalkowite ,
 @JMPrzelicznikL,
 @JMPrzelicznikM,
 @WartoscBrutto
   IF @@FETCH_STATUS <> 0 BREAK
 SET @Ilosc = @IloscJM *(@JMPrzelicznikL/@JMPrzelicznikM)
  EXEC CDN.Detal_AktualizujTraElem
 @DSTrEID ,
 @DSTrNID ,
 @ID,
 @ZwrID ,
 @TwrID ,
 @Stawka ,
 @Flaga ,
 @Cena ,
 @Rabat ,
 @CenaPoRabacie ,
 @Kaucja ,
 @Ilosc ,
 @IloscJM ,
 @Jm ,
 @JmCalkowite ,
 @JMPrzelicznikL,
 @JMPrzelicznikM,
 @WartoscBrutto
END
   -- po udanym update towarow ustawiamy date
   -- UPDATE CDN.DetalStanKonfiguracja SET DSKnf_TS_SynchroKnt = @DateTSSynchrNew WHERE DSKnf_StanDetalID = @ID
   -- UPDATE CDN.DetalStanowiska SET DSta_TS_SynchroKnt = @DateTSSynchrNew WHERE DSta_DStaId = @ID
    CLOSE Dodawane
    DEALLOCATE Dodawane
END
ELSE
SELECT
 DSTrE_DSTrEID ,
 DSTrE_DSTrNID ,
 DSTrE_ZwrID ,
 @ID,
 DSTwr_OptimaId ,
 DSTrE_Stawka ,
 DSTrE_Flaga ,
 DSTrE_Cena ,
 DSTrE_Rabat ,
 DSTrE_CenaPoRabacie ,
 DSTrE_Kaucja ,
 DSTrE_Ilosc ,
 DSTrE_Jm ,
 DSTrE_JmCalkowite ,
 DSTrE_JMPrzelicznikL,
 DSTrE_JMPrzelicznikM,
 DSTrE_WartoscBrutto
  FROM CDN.DetalStanTraElem join CDN.DetalStanTowary ON DSTrE_TwrID = DSTwr_DSTwrID
join CDN.DetalStanTraNag C ON DSTrE_DSTrNID = C.DSTrN_DSTrNID
join CDN.DetalTraNag X ON DSTrE_DSTrNID = X.DTrN_DSTrNID
left join CDN.DetalStanTraNag D ON C.DSTrN_FAID = D.DSTrN_DSTrNID
where C.DSTrN_Bufor = 0 and ISNULL(D.DSTrN_Bufor,0) = 0 and ISNULL(C.DSTrN_StanSynchronizacji,0) < 2 and  DSTrE_StornoID = 0 AND DSTrE_Ilosc <>0 and C.DSTrN_StanDetalID = @ID
SET NOCOUNT OFF
