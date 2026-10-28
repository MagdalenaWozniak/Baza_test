CREATE FUNCTION CDN.KRo_RozliczenieRoznicyKursowej(@KRoId int, @DokTyp int, @DokId int)
RETURNS @Result TABLE(RozliczenieRoznicyKursowej int)
AS
BEGIN
 if @KRoId <> 0
 begin
  if exists (
   select * from cdn.KsiRozrachunki A join cdn.KsiRozrachunki B on (A.KRo_KRoId = B.KRo_RozliczenieId)
   where
   A.KRo_KRoId = @KRoId
   and (
   IsNull(A.KRo_Waluta, '') <> '' and A.KRo_KwotaDok <> 0 and A.KRo_KwotaDokWal = 0
   or
   IsNull(B.KRo_Waluta, '') <> '' and B.KRo_KwotaDok <> 0 and B.KRo_KwotaDokWal = 0
   )
   and
   (@DokTyp = 1 and A.KRo_DeEId = @DokId or @DokTyp = 2 and A.KRo_BOEId = @DokId or @DokTyp = 1 and B.KRo_DeEId = @DokId or @DokTyp = 2 and B.KRo_BOEId = @DokId)
   )
    insert into @Result (RozliczenieRoznicyKursowej) values(1);
   else
    insert into @Result (RozliczenieRoznicyKursowej) values(0);
 end
 else
 begin
  if exists(
   select * from cdn.KsiRozrachunki
   where
   (@DokTyp = 1 and KRo_DeEId = @DokId or @DokTyp = 2 and KRo_BOEId = @DokId )
   and
   IsNull(KRo_Waluta, '') <> '' and KRo_KwotaDok <> 0 and KRo_KwotaDokWal = 0
   )
    insert into @Result (RozliczenieRoznicyKursowej) values(1);
   else
    insert into @Result (RozliczenieRoznicyKursowej) values(0);
 end
 return
END
