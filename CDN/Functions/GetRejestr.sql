CREATE FUNCTION CDN.GetRejestr( @DokTyp int)
RETURNS nvarchar(30)
AS
BEGIN
 DECLARE @FirCon int,
  @Result nvarchar(20),
  @GruTyp int
 SELECT @FirCon =
 case @DokTyp
  when 301 then 1473  --"Faktura zakupu"
  when 302 then 1474  --"Faktura sprzedaży"
  when 303 then 1478 --"Przyjęcie wewnętrzne"
  when 304 then 1477  --"Rozchód wewnętrzny"
  when 305 then 1474  --"Paragon"
  when 306 then 1475  --"Wydanie zewnętrzne"
  when 307 then 1476  --"Przyjęcie zewnętrzne"
  when 312 then 1479  --"Przesunięcie międzymagazynowe"
  when 321 then 1658  --"Faktura wewnętrzna zakupu"
  when 322 then 1659  --"Faktura wewnętrzna sprzedaży"
  when 313 then 1743 --"Przyjęcie kaucji"
  when 314 then 1742  -- "Wydanie kaucji"
  when 317 then 1478 -- "PW produktów"
  when 318 then 1477 -- "RW składników"
  when 345 then 1474  -- "TaxFree" ????? nie wiem który rejestr tutaj być powinien
  else 0
 end,
 @GruTyp =
 case @DokTyp
  when 301 then 1  --"Faktura zakupu"
  when 302 then 2  --"Faktura sprzedaży"
  when 303 then 35 --"Przyjęcie wewnętrzne"
  when 304 then 34  --"Rozchód wewnętrzny"
  when 305 then 2  --"Paragon"
  when 306 then 34  --"Wydanie zewnętrzne"
  when 307 then 35  --"Przyjęcie zewnętrzne"
  when 312 then 35  --"Przesunięcie międzymagazynowe"
  when 321 then 1  --"Faktura wewnętrzna zakupu"
  when 322 then 2  --"Faktura wewnętrzna sprzedaży"
  when 313 then 35 --"Przyjęcie kaucji"
  when 314 then 34  --"Wydanie kaucji"
  when 317 then 35 --"PW produktów"
  when 318 then 34 --"RW składników"
  when 345 then 2  --"TaxFree" ????? nie wiem który rejestr tutaj być powinien
  else 0
 end
 IF(@FirCon = 0)
 RETURN ''
 SELECT @Result = Fir_Wartosc
 FROM CDN.Firma
 WHERE Fir_Numer = @FirCon
 -- Sprawdzenie czy rejestr jest aktywny
 IF(EXISTS(SELECT Gru_GruID from CDN.Grupy WHERE Gru_Typ=@GruTyp AND Gru_Nazwa=@Result AND ISNULL(Gru_Flaga,0) <> 0))
  SET @Result=''
 RETURN @Result
END
