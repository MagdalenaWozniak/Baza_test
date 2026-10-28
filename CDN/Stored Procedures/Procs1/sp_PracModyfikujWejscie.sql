create procedure CDN.sp_PracModyfikujWejscie
    @id int, -- id dnia z wejsciem
    @lp int, -- liczba porzadkowa wejscia
    @baza datetime = null, -- baza
  @godzOd int = null, -- od godz
  @godzDo int = null, -- do godz
  @strefa int = null, -- strefa
  @dzial int = null, -- dzial
  @projekt int = null, -- projekt
  @orgGodzOd int = null, -- org od godz
  @orgGodzDo int = null, -- org do godz
  @orgStrefa int = null, -- org strefa
  @orgDzial int = null, -- org dzial
  @orgProjekt int = null -- org projekt
as
  declare @itemCount int
  select @itemCount=count(*)
    from CDN.PracPracaDniGodz
    where PGR_PprId=@id and PGR_Lp=@lp
      and PGR_OdGodziny=DATEADD(minute,@orgGodzOd,@baza)
      and PGR_DoGodziny=DATEADD(minute,@orgGodzDo,@baza)
      and PGR_Strefa=@orgStrefa
      and PGR_DzlId=@orgDzial
      and PGR_PrjId=@orgProjekt
  if @itemCount>0
    begin
      if (@strefa is not null) and ((@strefa > 1) or ((@strefa = 1) and (@lp = 1)))
        begin
          update CDN.PracPracaDniGodz
          set PGR_OdGodziny=DATEADD(minute,@godzOd,@baza),
            PGR_DoGodziny=DATEADD(minute,@godzDo,@baza),
            PGR_Strefa=@strefa,
            PGR_DzlId=@dzial,
            PGR_PrjId=@projekt
          where PGR_PprId=@id and PGR_Lp=@lp
            and PGR_OdGodziny=DATEADD(minute,@orgGodzOd,@baza)
            and PGR_DoGodziny=DATEADD(minute,@orgGodzDo,@baza)
            and PGR_Strefa=@orgStrefa
            and PGR_DzlId=@orgDzial
            and PGR_PrjId=@orgProjekt
        end
      else if (@strefa = 1) and (@lp > 1)
         begin
         delete from CDN.PracPracaDniGodz
         where PGR_PprId=@id and PGR_Lp=@lp
          and PGR_OdGodziny=DATEADD(minute,@orgGodzOd,@baza)
          and PGR_DoGodziny=DATEADD(minute,@orgGodzDo,@baza)
          and PGR_Strefa=@orgStrefa
          and PGR_DzlId=@orgDzial
          and PGR_PrjId=@orgProjekt
         end
    end
  else if (@strefa is not null) and (@strefa > 1) and (@lp > 1)
    begin
      insert into CDN.PracPracaDniGodz (PGR_PprId,PGR_Lp,PGR_OdGodziny,PGR_DoGodziny,PGR_Strefa,PGR_DzlId,PGR_PrjId,PGR_OdbNadg,PGR_Uwagi)
      values (@id, @lp, DATEADD(minute,@godzOd,@baza), DATEADD(minute,@godzDo,@baza),@strefa,@dzial,@projekt,1,'');
    end
