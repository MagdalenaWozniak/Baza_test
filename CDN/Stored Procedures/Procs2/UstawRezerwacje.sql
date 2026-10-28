CREATE PROCEDURE [CDN].[UstawRezerwacje]  @TreIdWZPZ INT, @Kasowanie INT, @TypDok INT
AS
BEGIN
  SET NOCOUNT ON
    DECLARE
    @IloscRezer         DECIMAL(15,4),
    @TrS_DataOpe        DATETIME,
    @IloscWydan         DECIMAL(15,4),
    @IloscWydanJuz      DECIMAL(15,4),
    @IloscZInnychWydan  DECIMAL(15,4),
    @IloscRezerReszta   DECIMAL(15,4),
    @IloscPozostala     DECIMAL(15,4),
    @IloscWydanZRezer   DECIMAL(15,4),
    @TreIdROZD          INT,
    @TrS_Typ            INT,
    @TrE_TypDok         INT,
    @TrE_Rodzaj         INT,
    @TrS_MagId          INT
-- jeśli Kasowanie = 1 to znaczy ze odbudowujemy reszte rezerwacji po skasowaniu
-- jeśli Kasowanie = 0 to znaczy ze zmieniło się coś na WZ/PA/FA FZ/PZ i należy przeliczyc rezerwacje z których powstały te dokumenty
-- przed trzeba wyzerować ilości dla elementów rezerwacji na -  powstałych dla @TreIdWZPZ
 UPDATE CDN.TrasElem SET TrS_Ilosc = 0 WHERE TrS_TreIdWydania is not null and  TrS_TreIdWydania = @TreIdWZPZ
 select @TrE_TypDok= TrE_TypDokumentu from cdn.traelem where tre_treid = @TreIdWZPZ;
  if @TrE_TypDok is null and @TypDok != 0
 select   @TrE_TypDok = @TypDok
if not exists( SELECT top 1 TrS_TreId FROM CDN.TrasElem
      JOIN CDN.TraElemRelacje ON TeR_ParentId = TrS_TreId and TeR_ParentTyp < 400
     WHERE TeR_ChildId =@TreIdWZPZ AND  TeR_ChildTyp = @TrE_TypDok  AND ISNULL(TrS_TreIdWydania,0) = 0 AND TrS_ZwrId IS NULL)
return
   --szukamy sunelementów rezerwacyjnych i przeliczamy wszystko
   DECLARE N CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrS_TreId,TrS_Typ,TrS_MagId FROM CDN.TrasElem
      JOIN CDN.TraElemRelacje ON TeR_ParentId = TrS_TreId and TeR_ParentTyp < 400
     WHERE TeR_ChildId =@TreIdWZPZ AND  TeR_ChildTyp = @TrE_TypDok AND  ISNULL(TrS_TreIdWydania,0) = 0 AND TrS_ZwrId IS NULL
     OPEN N
     WHILE 1=1
     BEGIN
       FETCH NEXT FROM N INTO @TreIdROZD,@TrS_Typ,@TrS_MagId
       IF @@FETCH_STATUS <> 0 BREAK
       -- ilość na rezerwacji
       SELECT @IloscRezer = ISNULL(TrS_Ilosc,0) FROM CDN.TrasElem WHERE TrS_TreId = @TreIdROZD AND  ISNULL(TrS_TreIdWydania,0) = 0 AND TrS_ZwrId IS NULL and TrS_MagId = @TrS_MagId
       -- ilość zrealizowana na dokumencie który wlasnie edytujemy
       IF @Kasowanie = 0
       BEGIN
          IF @TrS_Typ  in (13,14)
          BEGIN
   select @TrE_Rodzaj= TrN_Rodzaj from cdn.traelem join cdn.TraNag on TrE_TrNId = TrN_TrNID where tre_treid = @TreIdWZPZ;
   IF @TrE_Rodzaj != 302004 or (@TrE_Rodzaj = 302004 and  exists(select tre_treid  from cdn.traelem
     join cdn.traelemrelacje RelFAPF on RelFAPF.ter_childid = @TreIdWZPZ and RelFAPF.ter_parentid = tre_treid and RelFAPF.TeR_ParentTyp = 320
     left join cdn.traelemrelacje RelPFWZ on RelFAPF.ter_parentid = RelPFWZ.ter_parentid and  RelPFWZ.TeR_childTyp = 306 where RelPFWZ.ter_terid is null))
    SELECT @IloscWydan = ISNULL(Tre_Ilosc,0)  FROM CDN.TraElem WHERE TrE_TreId = @TreIdWZPZ
     ELSE
      SELECT @IloscWydan = 0
    END
          ELSE
            SELECT @IloscWydan = ISNULL(SUM (ISNULL(TrS_Ilosc,0)),0), @TrS_DataOpe = MAX(TrS_DataOpe)  FROM CDN.TrasElem WHERE TrS_TreId = @TreIdWZPZ and TrS_MagId = @TrS_MagId
          IF @TrS_DataOpe IS NULL
       SELECT  @TrS_DataOpe = MAX(TrE_DataOpe)  FROM CDN.TraElem WHERE TrE_TreId = @TreIdWZPZ
       END
       ELSE
          SET @IloscWydan = 0
       -- ile juz wydalismy dla tego dokumentu
       SELECT @IloscWydanJuz = ISNULL(SUM (ISNULL(TrS_Ilosc,0)),0) FROM CDN.TrasElem WHERE TrS_TreIdWydania is not null and  TrS_TreIdWydania = @TreIdWZPZ
       --jak juz gdzies rozchodowana to zmniejszamy
       SET @IloscWydan = @IloscWydan + @IloscWydanJuz
       -- sprawdzamy czy czasem inne dokumenty juz cos rozchodowały i ile nam zostało rezerwacji
       SELECT @IloscZInnychWydan = ISNULL(SUM (ISNULL(TrS_Ilosc,0)),0)
         FROM CDN.TrasElem
        WHERE TrS_TreId = @TreIdROZD AND  ISNULL(TrS_TreIdWydania,0) <> @TreIdWZPZ AND  ISNULL(TrS_TreIdWydania,0) > 0 and TrS_MagId = @TrS_MagId
        SET @IloscRezerReszta = @IloscRezer + @IloscZInnychWydan
        -- i liczymy ile czego powinno byc
        IF @IloscRezerReszta > 0
        BEGIN
        IF @IloscRezerReszta > @IloscWydan
           BEGIN
              SET @IloscWydanZRezer = -@IloscWydan
              SET @IloscPozostala = -(@IloscRezerReszta - @IloscWydan)
           END
           ELSE
           BEGIN
              SET @IloscWydanZRezer = -@IloscRezerReszta
              SET @IloscPozostala = 0
           END
         END
         ELSE
         BEGIN
           SET @IloscWydanZRezer = 0
           SET @IloscPozostala = 0
         END
        -- if @IloscWydanZRezer = 0 AND @TrS_Typ  in (13,14)
  -- select @IloscWydanZRezer = -Tre_Ilosc FROM CDN.TraElem WHERE TrE_TreId = @TreIdWZPZ
         --i UPDATE ilosci reszty
         UPDATE CDN.TrasElem SET TrS_Ilosc = @IloscPozostala
          WHERE TrS_zwrid = (SELECT Top 1 TrS_TrSId FROM CDN.TrasElem WHERE TrS_TreId = @TreIdROZD AND  ISNULL(TrS_TreIdWydania,0) = 0 AND TrS_ZwrId IS NULL) AND ISNULL(TrS_TreIdWydania,0) = 0 AND TrS_Typ <> 5 and TrS_MagId = @TrS_MagId
         --zmieniamy ilosci dla dokumentu rozchodowego
         IF @Kasowanie = 0
           IF EXISTS (SELECT * FROM CDN.TrasElem WHERE TrS_TreId = @TreIdROZD AND  ISNULL(TrS_TreIdWydania,0) = @TreIdWZPZ)
begin
               SELECT @TrS_DataOpe = (case when @TrS_DataOpe < TrS_DataOpe then TrS_DataOpe else @TrS_DataOpe end)
               FROM CDN.TrasElem WHERE TrS_TreId = @TreIdROZD AND  ISNULL(TrS_TreIdWydania,0) = 0 AND TrS_ZwrId IS NULL and TrS_MagId = @TrS_MagId
               UPDATE CDN.TrasElem SET TrS_ilosc = @IloscWydanZRezer, TrS_DataOpe = @TrS_DataOpe WHERE TrS_TreId = @TreIdROZD AND  ISNULL(TrS_TreIdWydania,0) = @TreIdWZPZ AND TrS_Typ <> 5 and TrS_MagId = @TrS_MagId
--UPDATE CDN.TrasElem SET TrS_ilosc = @IloscWydanZRezer, TrS_DataOpe = case when  @TrS_DataOpe < TrS_DataOpe then TrS_DataOpe else @TrS_DataOpe end WHERE TrS_TreId = @TreIdROZD AND  ISNULL(TrS_TreIdWydania,0) = @TreIdWZPZ AND TrS_Typ <> 5
end
            ELSE
               INSERT INTO CDN.TrasElem ( TrS_TreId, TrS_TrSIdDost,  TrS_ZwrId,  TrS_TwrId,  TrS_MagId,  TrS_Rodzaj,  TrS_Typ,  TrS_Metoda,  TrS_DataOpe,    TrS_Ilosc,   TrS_Wartosc,  TrS_Cena , TrS_TreIdWydania)
               SELECT TrS_TreId, TrS_TrSIdDost, TrS_TrSId,  TrS_TwrId,  TrS_MagId,  TrS_Rodzaj,  TrS_Typ,  TrS_Metoda,  case when  @TrS_DataOpe < TrS_DataOpe then TrS_DataOpe else @TrS_DataOpe end ,    @IloscWydanZRezer,   0,  TrS_Cena ,@TreIdWZPZ
               FROM CDN.TrasElem WHERE TrS_TreId = @TreIdROZD AND  ISNULL(TrS_TreIdWydania,0) = 0 AND TrS_ZwrId IS NULL and TrS_MagId = @TrS_MagId
     END
     CLOSE N
     DEALLOCATE N
  SET NOCOUNT OFF
END
