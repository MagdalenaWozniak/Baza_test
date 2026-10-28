CREATE FUNCTION CDN.UsunNiedozwoloneZnaki( @Nazwa NVARCHAR(50), @PauzeTez INT )
RETURNS NVARCHAR(50)
AS
  -- usuwa niedozwolone znaki z nazwy konta ksiegowego
BEGIN
  IF( @PauzeTez > 0 )
    SET @Nazwa = REPLACE( @Nazwa, '-', '_' )
  RETURN ( REPLACE(REPLACE(REPLACE(@Nazwa, '.', '_'), ' ', '_'), '''', '_') )
END
