CREATE PROCEDURE [CDN].[ZwrocIdTowar]
  @Towar                   NVARCHAR(255),           -- cała nazwa/kod/ean towaru
  @EANIlosciowy            NVARCHAR(10),            -- jesli ean ilosciowy
  @Flaga                   INT                     -- czy szukamy nazwy czy kodu w pierwszej kolejnosci
AS
SET NOCOUNT ON
  DECLARE
    @TowarID                INT,
    @KodWagowy              INT,
    @EAN     INT
    SET @KodWagowy=0
   --jesli podano ean ilosciowy to trzeba sprawdzic czy wystepuje
   if @EANIlosciowy<>''
     BEGIN
      SELECT Top 1 @TowarID=TwE_TwrID FROM CDN.TwrEAN
          WHERE TwE_EAN=@EANIlosciowy
      if @TowarID<>'' SET @KodWagowy = 1
     END
  -- a jak nie znajdzie to spradza w kolejnosci ean/kod/nazwa
   if @Flaga = 1
   BEGIN
     IF ((SELECT COUNT(Twr_Nazwa) FROM CDN.Towary WHERE Twr_Nazwa=@Towar)>1)
        SET @TowarID = 0
     ELSE
      BEGIN
       if @TowarID is null
         SELECT  Top 1 @TowarID=Twr_TwrID  FROM CDN.Towary
          WHERE Twr_Nazwa=@Towar
          order by  Twr_Kod,Twr_Nazwa
       if @TowarID is null
         SELECT  Top 1 @TowarID=Twr_TwrID  FROM CDN.Towary
         left JOIN CDN.TwrEan on Twr_TwrId = twe_twrid
          WHERE (TwE_EAN=@Towar or Twr_Kod=@Towar or Twr_PLU=@Towar)
          order by  Twr_Kod,Twr_Nazwa
     END
   END
   ELSE
   BEGIN
     if @TowarID is null
     BEGIN
       SELECT  Top 1 @TowarID=Twr_TwrID  FROM CDN.Towary
       left JOIN CDN.TwrEan on Twr_TwrId = twe_twrid
        WHERE (TwE_EAN=@Towar or Twr_Kod=@Towar or Twr_PLU=@Towar)
        order by  case when TwE_EAN =@Towar then 1 when Twr_Kod =@Towar then 2 when Twr_Kod =@Towar then 3 end
     END
     if @TowarID is null
     IF ((SELECT COUNT(Twr_Nazwa) FROM CDN.Towary WHERE Twr_Nazwa=@Towar AND Twr_NieAktywny = 0)>1)
        SET @TowarID = 0
     ELSE
       SELECT  Top 1 @TowarID=Twr_TwrID  FROM CDN.Towary
        WHERE Twr_Nazwa=@Towar  AND Twr_NieAktywny = 0
        order by  Twr_Kod,Twr_Nazwa
   END
   if @KodWagowy = 1
 set @EAN = 1
   else
 if exists(SELECT Top 1 TwE_TwrID FROM CDN.TwrEAN
          WHERE TwE_EAN=@Towar) select @EAN = 1 else select @EAN = 0
  select isnull(@TowarID,0) as TowarID,@KodWagowy as CzyKodWagowy,@EAN as CzyEAN
 SET NOCOUNT OFF
