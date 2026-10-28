create function cdn.LimitPrzychodow (@PraId int, @Y int, @M int)
 returns decimal(15, 2)
as
begin
 declare @RetVal decimal(15, 2)
 set @RetVal = 0
 declare @RetVal2 decimal(15, 2)
 set @RetVal2 = 0
 declare @ParentId int
 select @ParentId = PRA_ParentId from cdn.PracKod where PRA_PraId = @PraId
 if @Y > 2019
 begin
  select @RetVal = sum(WPE_PodstPITZwol)
  from cdn.WypElementy
   join cdn.Wyplaty on WPE_WplId = WPL_WplId
   join cdn.PracKod on WPE_PraId = PRA_PraId
   join cdn.TypWyplata on WPE_TwpId = TWP_TwpId
   where (WPE_PraId = @PraId or (PRA_ParentId = @ParentId or PRA_PraId = @ParentId) or (PRA_Nadrzedny = 0 and PRA_ParentId = @PraId))
    and (WPL_Rok = @Y and WPL_Miesiac < @M)
    and WPL_Tryb in (0, 3) and WPL_Archiwalna = 0
    and WPE_ZalFisZwol > 0
    and TWP_Standardowy = 17
  select @RetVal2 = sum(WPE_Wartosc)
  from cdn.WypElementy
   join cdn.Wyplaty on WPE_WplId = WPL_WplId
   join cdn.PracKod on WPE_PraId = PRA_PraId
   join cdn.TypWyplata on WPE_TwpId = TWP_TwpId
   where (WPE_PraId = @PraId or (PRA_ParentId = @ParentId or PRA_PraId = @ParentId) or (PRA_Nadrzedny = 0 and PRA_ParentId = @PraId))
    and (WPL_Rok = @Y and WPL_Miesiac < @M)
    and WPL_Tryb in (0, 3) and WPL_Archiwalna = 0
    and WPE_ZalFisZwol > 0
    and TWP_Standardowy not in (15, 16, 17, 18, 19, 20, 21, 22, 23)
 end
 if @Y = 2019
 begin
  select @RetVal = sum(WPE_PodstPITZwol)
  from cdn.WypElementy
   join cdn.Wyplaty on WPE_WplId = WPL_WplId
   join cdn.PracKod on WPE_PraId = PRA_PraId
   join cdn.TypWyplata on WPE_TwpId = TWP_TwpId
   where (WPE_PraId = @PraId or (PRA_ParentId = @ParentId or PRA_PraId = @ParentId) or (PRA_Nadrzedny = 0 and PRA_ParentId = @PraId))
    and (WPL_Rok = @Y and (WPL_Miesiac >= 8 and WPL_Miesiac < @M))
    and WPL_Tryb in (0, 3) and WPL_Archiwalna = 0
    and WPE_ZalFisZwol > 0
    and TWP_Standardowy = 17
  select @RetVal2 = sum(WPE_Wartosc)
  from cdn.WypElementy
   join cdn.Wyplaty on WPE_WplId = WPL_WplId
   join cdn.PracKod on WPE_PraId = PRA_PraId
   join cdn.TypWyplata on WPE_TwpId = TWP_TwpId
   where (WPE_PraId = @PraId or (PRA_ParentId = @ParentId or PRA_PraId = @ParentId) or (PRA_Nadrzedny = 0 and PRA_ParentId = @PraId))
    and (WPL_Rok = @Y and (WPL_Miesiac >= 8 and WPL_Miesiac < @M))
    and WPL_Tryb in (0, 3) and WPL_Archiwalna = 0
    and WPE_ZalFisZwol > 0
    and TWP_Standardowy not in (15, 16, 17, 18, 19, 20, 21, 22, 23)
 end
 if @RetVal is null
  set @RetVal = 0
 if @RetVal2 is null
  set @RetVal2 = 0
 declare @Suma decimal(15, 2)
 set @Suma =  @RetVal + @RetVal2
 if @Suma is null
  set @Suma = 0
 return @Suma
end
