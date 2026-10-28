CREATE  FUNCTION CDN.OkresObrachunkowy (@OObID Int, @Kierunek Int)
Returns int
AS
 BEGIN
-- funnkcja podaje {kolejny, następny} w odniesieniu do @OObID identyfikator
-- okresu obrachunkowego
-- @Kierunek
-- -1 - poprzedni lub 0 gdy nie istnieje
--  1 - następny lub 0 gdy nie istnieje
  declare @AccIDResult int
  if @Kierunek = -1    -- poprzedni okres obrachunkowy
   begin
    select top 1  @AccIDResult = IsNULL(B.OOb_OObID, 0) from CDN.OkresyObrach A
    left outer join CDN.OkresyObrach B on (A.OOb_DataOtw > B.OOb_DataOtw)
    where A.OOb_OObID = @OObID
    order by B.OOb_DataOtw desc
   end
  else if @Kierunek = 1  -- następny okres obrachunkowy
   begin
    select top 1 @AccIDResult = IsNULL(B.OOb_OObID, 0) from CDN.OkresyObrach A
    left outer join CDN.OkresyObrach B on (A.OOb_DataOtw < B.OOb_DataOtw)
    where A.OOb_OObID = @OObID
    order by B.OOb_DataOtw asc
   end
 RETURN @AccIDResult
END
