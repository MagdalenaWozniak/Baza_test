create function cdn.AtrybutLiczba(@_PracownikId int, @_AtrybutNazwa nvarchar(128), @_SkladnikOkresDo datetime)
returns @RetVal table (ColDecimal decimal(14,4), ColType int, ColSql nvarchar(2048))
 as
 begin
  declare
   @KlasaId int,
   @KlasaTyp int,
   @KlasaSql nvarchar(1024),
   @AtrybutId int,
   @AtrybutWartoscNaDzien nvarchar(128),
   @PracownikHistoriaId int,
   @PracownikHistoriaDzialId int,
   @AtrybutWartoscNaDzienDec decimal(14, 4)
  set @KlasaId = 0
  set @AtrybutId = 0
  set @PracownikHistoriaId = 0
  select top 1 @KlasaId = ATK_AtkId, @KlasaTyp = ATK_Typ, @KlasaSql = ATK_SQL
   from cdn.OAtrybutyKlasy
   where ATK_Nazwa = @_AtrybutNazwa
  if @KlasaId > 0
  begin
   select top 1 @AtrybutId = OAT_OatId
    from cdn.OAtrybuty
    where OAT_PrcId = @_PracownikId
     and OAT_AtkId = @KlasaId
   if @AtrybutId > 0
   begin
    select top 1 @AtrybutWartoscNaDzien = ATH_Wartosc
     from cdn.OAtrybutyHist
     where ATH_OatId = @AtrybutId
      and (ATH_DataOd <= @_SkladnikOkresDo and ATH_DataDo >= @_SkladnikOkresDo)
     --order by ATH_DataOd
    if @KlasaTyp in (1, 2)
    begin
     if len(rtrim(@AtrybutWartoscNaDzien)) <= 0
      insert into @RetVal values (0, 0, '')
     else
      insert into @RetVal
       select cast(@AtrybutWartoscNaDzien as decimal(14,4)), 0, ''
    end
    else if @KlasaTyp = 3
    begin
     if len(rtrim(@AtrybutWartoscNaDzien)) <= 0
      insert into @RetVal values (0, 0, '')
     else
     begin
      declare @Value1 decimal(14,4)
      set @Value1 = cdn.ZamienZnak(@AtrybutWartoscNaDzien)
      insert into @RetVal
       select @Value1, 0, ''
     end
    end
    else if @KlasaTyp in (4, 6)
     insert into @RetVal values (0, 0, '')
    else if @KlasaTyp = 5
    begin
     if len(rtrim(@AtrybutWartoscNaDzien)) > 0
     begin
      declare @Value2 decimal(14,4)
      set @Value2 = cdn.ZamienZnak(@AtrybutWartoscNaDzien)
      insert into @RetVal
       select @Value2, 0, ''
     end
     else
     begin
      insert into @RetVal values (0, @KlasaTyp, @KlasaSql)
      --select @PracownikHistoriaId = PRE_PreId, @PracownikHistoriaDzialId = PRE_DzlId
       --from cdn.PracEtaty
       --where PRE_PraId = @_PracownikId
        --and (PRE_DataOd <= @_SkladnikOkresDo and PRE_DataDo >= @_SkladnikOkresDo)
      --declare @Result decimal(14,2)
      --exec @Result = sp_executesql @KlasaSql, N'@PracId int, @HistId int, @DzialId int', @PracId = @_PracownikId, @HistId = @PracownikHistoriaId, @DzialId = @PracownikHistoriaDzialId
      --insert into @RetVal
       --select @Result, 0
     end
    end
   end
   else
    insert into @RetVal values (0, 0, '')
  end
  else
   insert into @RetVal values (0, 0, '')
  return
 end
