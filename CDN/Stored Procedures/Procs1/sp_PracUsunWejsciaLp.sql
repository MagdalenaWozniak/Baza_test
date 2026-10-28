create procedure CDN.sp_PracUsunWejsciaLp
    @id int, -- id dnia z wejsciem
    @lp int, -- liczba porzadkowa wejscia
    @baza datetime = null, -- baza
 @orgGodzOd int = null, -- org od godz
 @orgGodzDo int = null, -- org do godz
 @orgStrefa int = null, -- org strefa
 @orgDzial int = null, -- org dzial
 @orgProjekt int = null -- org projekt
as
 delete from CDN.PracPracaDniGodz
 where PGR_PprId=@id and PGR_Lp=@lp
  and PGR_OdGodziny=DATEADD(minute,@orgGodzOd,@baza)
  and PGR_DoGodziny=DATEADD(minute,@orgGodzDo,@baza)
  and PGR_Strefa=@orgStrefa
  and PGR_DzlId=@orgDzial
  and PGR_PrjId=@orgProjekt
