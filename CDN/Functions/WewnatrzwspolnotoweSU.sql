CREATE FUNCTION CDN.WewnatrzwspolnotoweSU (@DokId int)
returns int
as
begin
declare @result int
set @result = 0
DECLARE @Export int
 SELECT @Export = VaN_Export
 FROM CDN.VatNag
 WHERE VaN_VaNID = @DokId
 IF @Export = 3 OR @Export = 4
 BEGIN
  DECLARE @RodzajZakupu int, @Stawka int, @Flaga int
  DECLARE @Uslugi int, @NieUslugi int
  SET @Uslugi = 0
  SET @NieUslugi = 0
  DECLARE PozycjeCursor CURSOR READ_ONLY FOR
  SELECT VaT_RodzajZakupu, VaT_Stawka, VaT_Flaga
  FROM CDN.VatTab
  WHERE VaT_VaNID = @DokId
  OPEN PozycjeCursor
  FETCH NEXT FROM PozycjeCursor INTO @RodzajZakupu, @Stawka, @Flaga
  WHILE @@FETCH_STATUS = 0
   BEGIN
    IF @RodzajZakupu = 4
     SET @Uslugi = 1
    ELSE
     SET @NieUslugi = 1
    FETCH NEXT FROM PozycjeCursor INTO @RodzajZakupu, @Stawka, @Flaga
   END
  CLOSE PozycjeCursor
  DEALLOCATE PozycjeCursor
  IF @Uslugi = 1 AND @NieUslugi = 0
   set @result = 1
 END
return @result
end
