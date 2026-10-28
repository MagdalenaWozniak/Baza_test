CREATE FUNCTION CDN.UtworzSchematNumeracjiXL (@SchematXL nvarchar(30),@Symbol nvarchar(5))
RETURNS nvarchar(50)
AS
  BEGIN
  -- zmienne pomocnicze
  DECLARE
    @StringNumer nvarchar(50),
    @strdef1 nvarchar(50),
    @strdef2 nvarchar(50),
    @strdef3 nvarchar(50),
    @strdef4 nvarchar(50)
/*
Oznaczenie członów
1 – NUMER (N)
2 – NUMER (0N)
3 – ROK (RR)
4 – ROK (RRRR)
5 – SERIA
6 – MIESIĄC (M)
7 – MIESIĄC (MM)
*/
  SELECT @strdef1 =SUBSTRING(@SchematXL,1,1)
  SELECT @strdef2 =SUBSTRING(@SchematXL,3,1)
  SELECT @strdef3 =SUBSTRING(@SchematXL,5,1)
  SELECT @strdef4 =SUBSTRING(@SchematXL,7,1)
    if @strdef1 = '1'
     select @strdef1 = '/@numer'
    if @strdef1 = '2'
     select @strdef1 = '/@numerS'
    if @strdef1 = '3'
     select @strdef1 = '/@rok_kal'
    if @strdef1 = '4'
     select @strdef1 = '/@rok_kal'
    if @strdef1 = '5'
     select @strdef1 = '/@rejestr'
    if @strdef1 = '6'
     select @strdef1 = '/@miesiac'
    if @strdef1 = '7'
     select @strdef1 = '/@miesiac'
    if @strdef2 = '1'
     select @strdef2 = '/@numer'
    if @strdef2 = '2'
     select @strdef2 = '/@numerS'
    if @strdef2 = '3'
     select @strdef2 = '/@rok_kal'
    if @strdef2 = '4'
     select @strdef2 = '/@rok_kal'
    if @strdef2 = '5'
     select @strdef2 = '/@rejestr'
    if @strdef2 = '6'
     select @strdef2 = '/@miesiac'
    if @strdef2 = '7'
     select @strdef2 = '/@miesiac'
    if @strdef3 = '1'
     select @strdef3 = '/@numer'
    if @strdef3 = '2'
     select @strdef3 = '/@numerS'
    if @strdef3 = '3'
     select @strdef3 = '/@rok_kal'
    if @strdef3 = '4'
     select @strdef3 = '/@rok_kal'
    if @strdef3 = '5'
     select @strdef3 = '/@rejestr'
    if @strdef3 = '6'
     select @strdef3 = '/@miesiac'
    if @strdef3 = '7'
     select @strdef3 = '/@miesiac'
    if @strdef4 = '1'
     select @strdef4 = '/@numer'
    if @strdef4 = '2'
     select @strdef4 = '/@numerS'
    if @strdef4 = '3'
     select @strdef4 = '/@rok_kal'
    if @strdef4 = '4'
     select @strdef4 = '/@rok_kal'
    if @strdef4 = '5'
     select @strdef4 = '/@rejestr'
    if @strdef4 = '6'
     select @strdef4 = '/@miesiac'
    if @strdef4 = '7'
     select @strdef4 = '/@miesiac'
   select @StringNumer = '@brak/'+@Symbol+@strdef1 +@strdef2+@strdef3+@strdef4
   RETURN @StringNumer
   END
