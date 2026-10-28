CREATE FUNCTION CDN.UstalRodzajPrzedKonwersja(@TrNId INT, @TrNRodzaj INT, @TrNTyp INT, @KasowanyId INT)
RETURNS INT
AS
BEGIN
  DECLARE @RodzajOrg    INT
  DECLARE @Rodzaj       INT
  DECLARE @RodzajNew    INT
IF @KasowanyId <> 0
 BEGIN
   SET @RodzajOrg = (SELECT TOP 1 TrN_Rodzaj FROM CDN.TraNag  JOIN cdn.TraNagRelacje  ON TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrNId AND Trr_TrNID = @KasowanyId
    AND TrN_Bufor <> -1 and not(( TrR_FaTyp =306 and TrN_TypDokumentu =307) or (TrR_FaTyp =307 and TrN_TypDokumentu = 306)) ORDER BY TrN_TrnId DESC)
   IF @RodzajOrg Is Null
      SET @RodzajOrg = (SELECT TOP 1 TrN_Rodzaj FROM CDN.TraNag  JOIN cdn.TraNagRelacje  ON TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrNId
       AND TrN_Bufor <> -1 and not(( TrR_FaTyp =306 and TrN_TypDokumentu =307) or (TrR_FaTyp =307 and TrN_TypDokumentu = 306)) ORDER BY TrN_TrnId DESC)
 END
ELSE
 SET @RodzajOrg = (SELECT TOP 1 TrN_Rodzaj FROM CDN.TraNag  JOIN cdn.TraNagRelacje  ON TrN_TrNId = TrR_TrNId WHERE TrR_FaID = @TrNId
  AND TrN_Bufor <> -1 and not(( TrR_FaTyp =306 and TrN_TypDokumentu =307) or (TrR_FaTyp =307 and TrN_TypDokumentu = 306)) ORDER BY TrN_TrnId DESC)
 IF @RodzajOrg Is Null
  BEGIN
   IF @TrNRodzaj IN (302100, 302101,302102,302103,301101,301102,301103,305101,305102)
     SET @RodzajOrg = (SELECT TOP 1 (TrN_TypDokumentu * 1000)+ 100 + TrN_Korekta FROM CDN.TraNag WHERE TrN_TrNId=@TrNId ORDER BY TrN_TrnId DESC)
   ELSE
     SET @RodzajOrg = (SELECT TOP 1 (TrN_TypDokumentu * 1000) + case when TrN_Korekta = 8 then 2 else TrN_Korekta end FROM CDN.TraNag WHERE TrN_TrNId=@TrNId ORDER BY TrN_TrnId DESC)
   SET @RodzajNew = @RodzajOrg
  END
 ELSE
  BEGIN
   SET @RodzajNew = @TrNRodzaj
  END
 SET  @Rodzaj =
     CASE
      WHEN @RodzajOrg=320009 AND @TrNTyp =308 THEN 308011
      WHEN @RodzajOrg=320000 AND @TrNTyp =308 THEN 308011
      WHEN @RodzajOrg=302200 AND @TrNRodzaj=320000 THEN 320000
      WHEN @RodzajOrg=302200 AND @TrNRodzaj=320008 THEN 320008
      WHEN @RodzajOrg=307004 AND @TrNRodzaj=301050 THEN 301004
      WHEN @RodzajOrg=307004 AND @TrNRodzaj=313000 THEN 313000
      WHEN @RodzajOrg=307004 AND @TrNRodzaj=313001 THEN 313001
      WHEN @RodzajOrg=307004 AND @TrNRodzaj=313002 THEN 313002
      WHEN @RodzajOrg=306004 AND @TrNRodzaj=314000 THEN 314000
      WHEN @RodzajOrg=306004 AND @TrNRodzaj=314001 THEN 314001
      WHEN @RodzajOrg=306004 AND @TrNRodzaj=314002 THEN 314002
      WHEN @RodzajOrg=302004 AND @TrNRodzaj=308000 THEN 308000
      WHEN @RodzajOrg=301004 AND @TrNRodzaj<>322021 AND @TrNTyp<>309  AND @TrNTyp<>313 THEN 307004
      WHEN @RodzajOrg=301004 AND @TrNTyp=309 THEN 309000
      WHEN @RodzajOrg=301004 AND @TrNRodzaj=322021 THEN 322021
      WHEN @RodzajOrg=301004 AND @TrNRodzaj=309000 THEN 308000
      WHEN @RodzajOrg=307004 AND @TrNRodzaj=301050 THEN 301050
      WHEN @RodzajOrg=307004 AND @TrNRodzaj=301000 THEN 301004
      WHEN @RodzajOrg=306004 AND @TrNTyp<>314 THEN 302004
      WHEN @RodzajOrg=302004 AND @TrNTyp<>314 THEN 306004
      WHEN @RodzajOrg=307004 AND @TrNTyp<>313 AND @TrNTyp<>309 THEN 301004  -- FZ powstaly z PZ
      WHEN @RodzajOrg=307005  THEN 301004  -- FZ powstaly z PZ korekta ilosci
      WHEN @RodzajOrg=307006  THEN 301004  -- FZ powstaly z PZ korekta wartosc
   WHEN @RodzajOrg=307011  THEN 301004  -- FZ powstaly z PZ korekta VAT
   WHEN @RodzajOrg=306011  THEN 302004
      WHEN @RodzajOrg=307007  THEN 301004  -- FZ powstaly z PZ korekta VAT
      WHEN @RodzajOrg=309008 AND @TrNTyp <> 307 THEN 301011  -- FZ powstaly z ZD
                     WHEN @RodzajOrg=350008  THEN 301050  -- FZ powstaly z FRR
      WHEN @RodzajOrg=301090 THEN 301000  --
      WHEN @RodzajOrg=302004 THEN
       CASE
        WHEN @TrNTyp=305 THEN 305004
        ELSE @RodzajNew
       END
      WHEN @RodzajOrg=302090 THEN 302000
      WHEN @RodzajOrg=306005 THEN 306001
      WHEN @RodzajOrg=306006 THEN
       CASE
        WHEN @TrNTyp=305 THEN 305004
        ELSE @RodzajNew
       END
      WHEN @RodzajOrg=306009 THEN 306002
      WHEN @RodzajOrg=307005 THEN 307001
      WHEN @RodzajOrg=307009 THEN 307002
   WHEN @RodzajOrg=307011 THEN 307003
      WHEN @RodzajOrg=306010 AND @RodzajNew=320200 THEN 320000
   WHEN @RodzajOrg=306011 THEN 306003
      WHEN @RodzajOrg=309000 AND @RodzajNew=320200 THEN 320000
      WHEN @RodzajOrg=308008 OR @RodzajOrg=308009 THEN
       CASE
        WHEN @TrNTyp=305 THEN 305008
        WHEN @TrNTyp=302 THEN 302008
        WHEN @TrNTyp=306 THEN 306008
        ELSE @RodzajNew
       END
      WHEN @RodzajOrg=308000 OR @RodzajOrg=308010 OR @RodzajOrg=308011 THEN
       CASE
        WHEN @TrNTyp=305 THEN 305008
        WHEN @TrNTyp=302 THEN 302008
        WHEN @TrNTyp=306 THEN 306008
        ELSE @RodzajNew
       END
      WHEN @RodzajOrg=309008 THEN
       CASE
        WHEN @TrNTyp=301 THEN 301011
        WHEN @TrNTyp=307 THEN 307010
        ELSE @RodzajNew
       END
      WHEN @RodzajOrg=309009 THEN
       CASE
        WHEN @TrNTyp=301 THEN 301011    --FZ
          WHEN @TrNTyp=307 THEN 307010    --PZ
        ELSE @RodzajNew
       END
   --   WHEN @RodzajOrg=320008 THEN 302009
   --   WHEN @RodzajOrg=320009 THEN 308011
      WHEN @RodzajNew = 320000 AND @RodzajOrg = 308011 THEN 320009
      WHEN @RodzajOrg = 309000 AND @RodzajNew = 307004 THEN 307010 --SO, status w przypadku kasowania FZ w buforze, gdzie PZ skojarzona jest z ZD
      WHEN @RodzajOrg = 309000 AND @RodzajNew = 320009 THEN 320000
      WHEN @RodzajOrg = 306010 AND @RodzajNew = 320008 THEN 320000
      WHEN @RodzajOrg = 309000 AND @RodzajNew = 320008 THEN 320000
      WHEN @RodzajOrg = 320009 AND @RodzajNew = 308000 THEN 308011
      WHEN @RodzajOrg = 309000 AND @RodzajNew = 307000 THEN 307010
      WHEN @RodzajOrg = 308011 AND @RodzajNew = 306004 THEN 306008 --SO, status w przypadku kasowania FS w buforze, gdzie WZ skojarzona jest z RO
      WHEN @RodzajOrg = 308011 AND @RodzajNew = 306000 THEN 306008 --SO, status w przypadku anulowania FS , gdzie WZ skojarzona jest z RO
      WHEN @RodzajOrg = 308000 AND @RodzajNew = 306004 THEN 306008 --SO, status w przypadku kasowania FS w buforze, gdzie WZ skojarzona jest z RO
      WHEN @RodzajOrg = 308000 AND @RodzajNew = 306000 THEN 306008 --SO, status w przypadku anulowania FS , gdzie WZ skojarzona jest z RO
      WHEN @RodzajOrg = 314000 AND @TrNRodzaj=306004   THEN 306000
   WHEN @RodzajOrg = 314001 AND @TrNRodzaj=306004   THEN 306000
      WHEN @RodzajOrg = 314002 AND @TrNRodzaj=306004   THEN 306000
      WHEN @RodzajOrg = 314000 AND @TrNRodzaj=306006   THEN 306000
      WHEN @RodzajOrg = 313000 AND @TrNRodzaj=307004   THEN 307000
   WHEN @RodzajOrg = 313001 AND @TrNRodzaj=307004   THEN 307000
   WHEN @RodzajOrg = 313002 AND @TrNRodzaj=307004   THEN 307000
           ELSE @RodzajNew
      END
if  @TrNRodzaj in (320009,320000)
begin
 if exists(select trr_trnid from cdn.tranagrelacje join cdn.tranag on trn_trnid = trr_faid where trr_trnid = @TrNId and trr_fatyp = 308 and trn_bufor <> -1)
  set @Rodzaj = 320009
else
 set @Rodzaj = 320000
end
if  @TrNRodzaj in (308000,308011)
begin
 if exists(select trr_trnid from cdn.tranagrelacje join cdn.tranag on trn_trnid = trr_faid where trr_trnid = @TrNId and trr_fatyp = 320 and trn_bufor <> -1)
  set @Rodzaj = 308011
else
 set @Rodzaj = 308000
end
 IF @TrNRodzaj = 302010
 set @Rodzaj = 302010
  RETURN @Rodzaj
END
