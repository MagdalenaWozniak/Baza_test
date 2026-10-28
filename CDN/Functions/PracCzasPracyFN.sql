create function CDN.PracCzasPracyFN
(
 @Typ smallint,  -- typ danych: 1 = kalendarz, 2 = plan pracy, 3 = czas pracy
 @Id int,  -- id danych: kalendarza lub pracownika
 @DataOd datetime, -- data pocz¦tkowa
 @DataDo datetime -- data ko˝cowa
)
returns @CzasPracy table
(
 Typ smallint default 1,
 Data datetime,
 TypDnia int default 1,
 OdwId int default null,
 Symbol nvarchar(2) default '',
 Nieobec int default null,
 TypNieob int default null,
 Lp INT,
 GodzOd datetime default CONVERT(datetime,'1899.12.30',102),
 GodzDo datetime default CONVERT(datetime,'1899.12.30',102),
 Strefa int,
 Dzial int default 1,
 Projekt int default 1,
 Norma int default 0,
 Praca int default 0,
 Zrodlo int default 0
)
as
begin
 if @DataOd is null or @DataDo is null
  return
 if @DataDo<@DataOd
  set @DataDo=@DataOd
 declare
  @GodzinaOd datetime,
  @GodzinaDo datetime,
  @GodzinaZero datetime
 set @GodzinaOd = convert(datetime, '1899-12-30 07:00:00.000', 120)
 set @GodzinaDo = convert(datetime, '1899-12-30 15:00:00.000', 120)
 set @GodzinaZero = convert(datetime, '1899-12-30 00:00:00.000', 120)
 declare
  @StrefaNiezdefiniowanaId int,
  @StrefaPodstawowaId int,
  @OdwId int,
  @Symbol nvarchar(2)
 select @StrefaNiezdefiniowanaId = DST_DstId from CDN.DefinicjeStref where DST_Standardowy = 99
 select @StrefaPodstawowaId = DST_DstId from CDN.DefinicjeStref where DST_Standardowy = 1
 select @OdwId = null
 select @Symbol = ''
 --wypełnianie tablicy domyślnymi wartościami
 declare
  @Zestaw tinyint,
  @Wymiar real,
  @GodzDo datetime,
  @Data datetime,
  @PRE_Data datetime
 set @PRE_Data = 0
 set @Wymiar = 1
 set @GodzDo = DATEADD(hour,15,CONVERT(datetime,'1899.12.30',102))
 if @Typ=1
  select @GodzDo = case KAL_NormaKalendarz when 0 then DATEADD(hour,7,KAL_NormaDobowa) else @GodzDo end from CDN.Kalendarze where KAL_KalId=@Id
 set @Data = @DataOd
 while @Data <= @DataDo
 begin
  if @Typ > 1 and @PRE_Data < @Data
  begin
   select @Wymiar=CONVERT(real,(case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end))/(case (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end) when 0 then 1 else (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end) end), @PRE_Data=PRE_DataDo from CDN.PracEtaty where PRE_PraId=@Id and @Data between PRE_DataOd and PRE_DataDo
--[JK] TFS:11439
--   select @GodzDo = DATEADD(minute,CONVERT(int,CEILING((case KAL_NormaKalendarz when 0 then DATEDIFF(minute,CONVERT(datetime,'1899.12.30',102),KAL_NormaDobowa) else 480 end)*(case KAL_UwzglWymiarEtatu when 0 then 1 else @Wymiar end)))%1440,DATEADD(hour,7,CONVERT(datetime,'1899.12.30',102)))
        select @GodzDo = DATEADD(minute,CONVERT(int,CEILING((case KAL_NormaKalendarz when 0 then case DATEDIFF(minute,CONVERT(datetime,'1899.12.30',102),KAL_NormaDobowa) when 0 then 480  else DATEDIFF(minute,CONVERT(datetime,'1899.12.30',102),KAL_NormaDobowa) end else 480 end)*(case KAL_UwzglWymiarEtatu when 0 then 1 else @Wymiar end)))%1440,DATEADD(hour,7,CONVERT(datetime,'1899.12.30',102)))
   from CDN.Kalendarze
   where KAL_KalId = (select (case PRE_PRMPracaRodzic when 1 then PRE_PRMKalId else PRE_KalId end) from CDN.PracEtaty where PRE_PraId=@Id and @Data between PRE_DataOd and PRE_DataDo)
  end
  if not exists(select Data from @CzasPracy where Data = @Data)
  begin
   if (DATEPART(weekday,@Data)+@@DATEFIRST)%7 between 2 and 6
   --[JK] TFS:159911 - dodano pole LP z wartością 1
    insert into @CzasPracy (Data, GodzOd, GodzDo, Strefa, Lp)
     values (@Data, DATEADD(hour,7,CONVERT(datetime,'1899.12.30',102)), @GodzDo, @StrefaPodstawowaId,1)
   else
   --[JK] TFS:159911 - dodano pole LP z wartością 1
    insert into @CzasPracy (Data,TypDnia, OdwId, Symbol, Strefa,Lp)
     values (@Data, case (DATEPART(weekday,@Data)+@@DATEFIRST)%7 when 1 then 3 else 2 end, @OdwId, @Symbol, @StrefaNiezdefiniowanaId,1)
  end
   set @Data = DATEADD(day,1,@Data)
 end
 --usuwam dni, które istnieją w kalendarzu
 delete from @CzasPracy
  where exists (select * from cdn.KalendDni where Data = KAD_Data
 --[JK] zgł.148786 - dodanie warunku na id kalendarza danego pracownika.
  and KAD_KalId = (select (case PRE_PRMPracaRodzic when 1 then PRE_PRMKalId else PRE_KalId end) from CDN.PracEtaty where PRE_PraId=@Id and
  --[JK] TFS:151203 @Data
  Data
  between PRE_DataOd and PRE_DataDo)
  )
 --dodaję dni istniejące w kalendarzu
 insert into @CzasPracy(Typ,Data, TypDnia, OdwId, Symbol, Nieobec,TypNieob,Lp, GodzOd, GodzDo, Strefa, Dzial, Projekt, Norma,Praca)
  select 2, KAD_Data, KAD_TypDnia, KAD_OdwId, '', null, null, KDG_lp,KDG_OdGodziny,
   case when @Typ=1 or Kdg_DoGodziny = KDG_OdGodziny or (select KAL_UwzglWymiarEtatu*((case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end)-(case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end)) from CDN.Kalendarze, CDN.PracEtaty where KAL_KalId = (case PRE_PRMPracaRodzic when 1 then PRE_PRMKalId else PRE_KalId end) and PRE_PraId = @Id and KAD_Data between PRE_DataOd and PRE_DataDo)=0 then KDG_DoGodziny else DATEADD(minute,CONVERT(int,CEILING(((case when KDG_DoGodziny <= KDG_OdGodziny then 1440 else 0 end) + DATEDIFF(minute,KDG_OdGodziny,KDG_DoGodziny))*(select CONVERT(decimal,(case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end))/(case (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end) when 0 then 1 else (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end) end) from CDN.PracEtaty where PRE_PraId = @Id and KAD_Data between PRE_DataOd and PRE_DataDo)))%1440,KDG_OdGodziny) end,
   KDG_Strefa, null, null, 0,0
   from cdn.KalendDni join cdn.KalendDniGodz on KAD_KadId = KDG_KadId
   where KAD_Data between @DataOd and @DataDo
    and KAD_Data not in (select Data from @CzasPracy)
    and KAD_KalID=(case @Typ when 1 then @Id else (select (case PRE_PRMPracaRodzic when 1 then PRE_PRMKalId else PRE_KalId end) from CDN.PracEtaty where PRE_PraId=@Id and KAD_Data between PRE_DataOd and PRE_DataDo) end)
 if @Typ = 2
 begin
  --usuwam dni, które istnieją w planie pracy
  delete from @CzasPracy
   where exists (select * from cdn.PracPlanDni where PPL_PraId = @Id and Data = PPL_Data)
  --dodaję dni istniejące w kalendarzu
  insert into @CzasPracy(Typ,Data, TypDnia, OdwId, Symbol, Nieobec,TypNieob,Lp, GodzOd,GodzDo, Strefa, Dzial, Projekt, Norma,Praca)
   select 3, PPL_Data, PPL_TypDnia, PPL_OdwId, '', null, null, PGL_Lp,PGL_OdGodziny,
   PGL_DoGodziny,
    --case when @Typ=1 or PGL_DoGodziny = PGL_OdGodziny or (select KAL_UwzglWymiarEtatu*((case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end)-(case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end)) from CDN.Kalendarze, CDN.PracEtaty where KAL_KalId = (case PRE_PRMPracaRodzic when 1 then PRE_PRMKalId else PRE_KalId end) and PRE_PraId = @Id and PPL_Data between PRE_DataOd and PRE_DataDo)=0 then PGL_DoGodziny else DATEADD(minute,CONVERT(int,CEILING(((case when PGL_DoGodziny <= PGL_OdGodziny then 1440 else 0 end) + DATEDIFF(minute,PGL_OdGodziny,PGL_DoGodziny))*(select CONVERT(decimal,(case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatL else PRE_ETAEtatL end))/(case (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end) when 0 then 1 else (case PRE_PRMPracaRodzic when 1 then PRE_PRMEtatM else PRE_ETAEtatM end) end) from CDN.PracEtaty where PRE_PraId = @Id and PPL_Data between PRE_DataOd and PRE_DataDo)))%1440,PGL_OdGodziny) end,
    PGL_Strefa, null, null, 0,0
    from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId
    where PPL_Data between @DataOd and @DataDo
     and PPL_Data not in (select Data from @CzasPracy)
     --[JK]
     and PPL_PraId = @Id
 end
 --uzupełniam informacją o normie
 update @CzasPracy
  set Norma = (case when (select DST_UwzglCzasPracy from CDN.DefinicjeStref where DST_DstId=Strefa)>0 then DATEDIFF(minute,GodzOd,GodzDo)+(case when GodzOd>=GodzDo then 1440 else 0 end) else 0 end)
 --uzupełniam informacją o pracy (jeśli funkcja wywołana jest z parametrem 1 lub spełniony jest warunek w poniższym zapytaniu)
 declare @Baza datetime
 set @Baza = CONVERT(datetime,'1899.12.30',102)
 update @CzasPracy
  set Praca = Norma where @Typ = 1 or (select PRE_ZestCzasuPracy from CDN.PracEtaty where PRE_PraId = @Id and Data between PRE_DataOd and PRE_DataDo and PRE_ZatrudnionyOd <> @Baza and PRE_ZatrudnionyOd <= Data and (PRE_ZatrudnionyDo = @Baza or Data <= PRE_ZatrudnionyDo)) = 0
 if @Typ = 3
 begin
 --[JK] TFS:148919
 --usuwam dni, które istnieją w planie pracy
  delete from @CzasPracy
   where exists (select * from cdn.PracPlanDni where PPL_PraId = @Id and Data = PPL_Data)
  --dodaję dni istniejące w kalendarzu
  insert into @CzasPracy(Typ,Data, TypDnia, OdwId, Symbol, Nieobec,TypNieob,Lp,GodzOd, GodzDo, Strefa, Dzial, Projekt, Norma,Praca)
   select 3, PPL_Data, PPL_TypDnia, PPL_OdwId, '', null, null, PGL_Lp,PGL_OdGodziny,
    PGL_DoGodziny,
    PGL_Strefa, null, null, 0,0
    from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId
    where PPL_Data between @DataOd and @DataDo
     and PPL_Data not in (select Data from @CzasPracy)
     --[JK]
     and PPL_PraId = @Id
--[JK] TFS:149233
 update @CzasPracy
  set Norma = (case when (select DST_UwzglCzasPracy from CDN.DefinicjeStref where DST_DstId=Strefa)>0 then DATEDIFF(minute,GodzOd,GodzDo)+(case when GodzOd>=GodzDo then 1440 else 0 end) else 0 end)
  --usuwam dni, które istnieją w czasie pracy
  delete from @CzasPracy
   where exists (select * from cdn.PracPracaDni where PPR_PraId = @Id and Data = PPR_Data)
 declare @MaByc int
 declare @Jest int
 set @MaByc = DATEDIFF(day,@DataOd,@DataDo)+1
    declare @Lp INT
 declare @GodzOd_N datetime
 declare @GodzDo_N datetime
 declare @roznica INT
 declare @godzinyNb INT
 declare @intTemp INT
 declare @strefa NVARCHAR(50)
 declare @datemin datetime
 set @datemin = CONVERT(datetime,'1899.12.30',102)
 set @Data = @DataOd
 while @Data<=@DataDo
    begin
IF exists (select 1 from @CzasPracy where Data = @Data and Typ < 4 and @Typ = 3 or @Typ=2)
 BEGIN
  --select @GodzOd_N = GodzOd, @GodzDo_N = GodzDo, @strefa = Strefa from @CzasPracy where Data = @Data
  -- Pomniejszamy czas pracy o niebecności częściowe
  SELECT @godzinyNb = SUM(DATEDIFF(minute, @datemin,PNB_Godz)) from CDN.PracNieobec where PNB_PraId=@Id and @Data between PNB_OkresOd and PNB_OkresDo and Pnb_Tryb<>1 and PnB_Calodzienna = 0
  DECLARE c CURSOR LOCAL FORWARD_ONLY FOR SELECT Lp, GodzOd, GodzDo, Strefa FROM @CzasPracy WHERE Data = @Data order by Lp Desc
  OPEN c
  FETCH NEXT FROM c INTO @Lp, @GodzOd_N, @GodzDo_N, @Strefa
  WHILE @@FETCH_STATUS = 0
  BEGIN
    if  @strefa<>'undefined' and @godzinyNb <> 0 and exists (select 1 from CDN.DefinicjeStref where DST_DstId = @strefa and DST_UwzglCzasPracy = 1)
   BEGIN
    IF @GodzDo_N >= @GodzOd_N
     set @roznica = DATEDIFF(minute, @GodzOd_N,@GodzDo_N)
    ELSE
     set @roznica = (DATEDIFF(minute, @GodzOd_N,@GodzDo_N) + 1440)%1440
    IF @godzinyNb > @roznica
    BEGIN
     set @GodzOd_N = @datemin
     set @GodzDo_N = @datemin
     set @godzinyNb = @godzinyNb - @roznica
    END
    ELSE
    BEGIN
     set @GodzDo_N = DATEADD(minute, @roznica - @godzinyNb ,@GodzOd_N)
     set @GodzDo_N = DATEADD(minute,DATEPART(minute,@GodzDo_N)+ 60*DATEPART(hour,@GodzDo_N),CONVERT(datetime,'1899.12.30',102))
     set @godzinyNb = 0
     --BREAK
    END
   END
   UPDATE @CzasPracy SET GodzOd = @GodzOd_N, GodzDo = @GodzDo_N WHERE Data = @Data AND Lp = @Lp
    --PK!17! Dni , w ktorych suma niebecności częsciowych jest równa normie traktujemy jak nieobecność całodzienną
   UPDATE @CzasPracy SET Typ = 5, Nieobec = PNB_PnbId
   FROM @CzasPracy join CDN.PracNieobec on PNB_PraId=@Id join CDN.TypNieobec on TNB_TnbId=PnB_TnBId and Data between PNB_OkresOd and PNB_OkresDo and Pnb_Tryb<>1 and PnB_Calodzienna = 0
   WHERE Data = @Data AND Lp = @Lp and GodzOd = GodzDo and TNB_PomnCzasPracy = 1
   FETCH NEXT FROM c INTO @Lp, @GodzOd_N, @GodzDo_N, @Strefa
  END
  CLOSE c
  DEALLOCATE c
END
set @Data = DATEADD(day,1,@Data)
end
  insert into @CzasPracy(Typ,Data, Nieobec,TypNieob,Lp,GodzOd, GodzDo, Strefa, Dzial, Projekt, Norma,Praca)
  select 4, PPR_Data, null, null, PGR_Lp,PGR_OdGodziny, PGR_DoGodziny, PGR_Strefa, PGR_DzlId, PGR_PrjId, 0,(case when (select DST_UwzglCzasPracy from CDN.DefinicjeStref where DST_DstId=PGR_Strefa)> 0 then DATEDIFF(minute,PGR_OdGodziny,PGR_DoGodziny)+(case when PGR_OdGodziny>=PGR_DoGodziny then 1440 else 0 end) else 0 end)
   from cdn.PracPracaDni join cdn.pracpracadnigodz on PPR_PprId = PGR_PprId and PPR_PraId = @Id
   --[JK]
   where PPR_Data between @DataOd and @DataDo
  --uzupełniam informacją o normie
 /*update @CzasPracy
  set Norma = (case when (select DST_UwzglCzasPracy from CDN.DefinicjeStref where DST_DstId=Strefa)>0 then DATEDIFF(minute,GodzOd,GodzDo)+(case when GodzOd>=GodzDo then 1440 else 0 end) else 0 end)*/
 /*update @CzasPracy
      set Typ=4, GodzOd=PGR_OdGodziny, GodzDo=PGR_DoGodziny, Strefa=PGR_Strefa, Dzial=PGR_DzlId, Projekt=PGR_PrjId, Praca = (case when (select DST_UwzglCzasPracy from CDN.DefinicjeStref where DST_DstId=PGR_Strefa)> 0 then DATEDIFF(minute,PGR_OdGodziny,PGR_DoGodziny)+(case when PGR_OdGodziny>=PGR_DoGodziny then 1440 else 0 end) else 0 end)
        from @CzasPracy inner join CDN.PracPracaDni on PPR_PraId = @Id join cdn.PracPracaDniGodz on PPR_PprId = PGR_PprId and PPR_Data=Data*/
    update @CzasPracy
  set Praca = (case when (select DST_UwzglCzasPracy from CDN.DefinicjeStref where DST_DstId=Strefa)>0 then DATEDIFF(minute,GodzOd,GodzDo)+(case when GodzOd>=GodzDo and Typ<>5 then 1440 else 0 end) else 0 end) where (select pre_ZestCzasuPracy
  from CDN.PracKod join cdn.pracetaty on pre_praid=pra_praid
  where pra_praid = @Id and pre_dataod <= Data and pre_datado >= Data and pre_zatrudnionyod <> @datemin and pre_zatrudnionyod <= Data and (pre_zatrudnionydo = @datemin or Data <= pre_zatrudnionydo)) = 0
 update @CzasPracy
  set Typ=5, Nieobec=PNB_PnbId, TypNieob=PNB_TnbId, Praca=case when (select TNB_PomnCzasPracy from CDN.TypNieobec where TNB_TnbId=PNB_TnbId)>0 then 0 else Praca end
   from @CzasPracy join CDN.PracNieobec on PNB_PraId=@Id and Data between PNB_OkresOd and PNB_OkresDo and PNB_Tryb<>1 and PNB_Calodzienna = 1 and PNB_PracaRodzic <> 1
  -- [KB] TFS:174061 - dodałam case na czas pracy dla nieobecności nie pomniejszającej czasu pracy oraz ustawiam strefę na 2
 insert into @CzasPracy(Data,Typ,Nieobec,TypNieob,Strefa, Norma,Praca)
  select Data,5,PNB_PnbId,PNB_TnbId,2,DATEDIFF(minute,@datemin,PNB_Godz), (case when TNB_PomnCzasPracy=0 then DATEDIFF(minute,@datemin,PNB_Godz) else 0 end)
   from @CzasPracy
   join CDN.PracNieobec on PNB_PraId=@Id and Data between PNB_OkresOd and PNB_OkresDo and PNB_Tryb<>1 and PNB_Calodzienna = 0
   join CDN.TypNieobec on TNB_TnbId=PnB_TnBId
    /*update @CzasPracy
  set Norma = Norma - isnull((select SUM(cp.Norma) from @CzasPracy cp where cp2.Data = Data and cp.Nieobec is not null ),0)
   from @CzasPracy cp2
   where cp2.Nieobec is null and cp2.Typ in (1,2,3,4)
 */
 end
 if @Typ = 3
  --[JK] dodałem warunek na Typ <> 5 aby uzyskać godziny nieobecności na część dnia
  update @CzasPracy set Norma = 0 where Typ <> 5
  --[JK] TFS:150666
  --update @CzasPracy set Praca =Praca-DATEDIFF(minute, CONVERT(datetime,'1899.12.30',102),PNB_Godz) from @CzasPracy join CDN.PracNieobec on Data between PNB_OkresOd and PNB_OkresDo and PNB_Tryb<>1 and isnull(Nieobec,0)=0 and PnB_Calodzienna = 0 where PNB_PraId=@Id and Praca>0
  --[JK] TFS:148841
  --update @CzasPracy set TypDnia = PPL_TypDnia,GodzOd=PGL_OdGodziny,GodzDo=PGL_DoGodziny, Strefa=PGL_Strefa, Praca = DATEDIFF(minute,PGL_OdGodziny,PGL_DoGodziny)+(case when PGL_OdGodziny>=PGL_DoGodziny and PGL_Strefa > 1 then 1440 else 0 end) from cdn.PracPlanDni join cdn.PracPlanDniGodz on PPL_PplId = PGL_PplId where PPL_PraId=@Id and PPL_Data = Data and Typ <> 5
 if @Typ = 2
  update @CzasPracy set Praca = 0 --where Typ <> 4
  --[JK] TFS:150666
 --update @CzasPracy set Norma = Norma-DATEDIFF(minute, CONVERT(datetime,'1899.12.30',102),PNB_Godz)
    --from @CzasPracy join CDN.PracNieobec on Data between PNB_OkresOd and PNB_OkresDo and PNB_Tryb<>1 and isnull(Nieobec,0)=0 and PnB_Calodzienna = 0 where PNB_PraId=@Id and Norma>0
 update @CzasPracy set Zrodlo = (select PPL_Zrodlo from cdn.PracPlanDni where PPL_PraId = @Id and PPL_Data = Data) where Typ = 3
 update @CzasPracy set Zrodlo = (select PPR_Zrodlo from cdn.PracPracaDni where PPR_PraId = @Id and PPR_Data = Data) where Typ = 4
 update @CzasPracy set Zrodlo = (select PNB_Zrodlo from cdn.PracNieobec where PNB_PraId = @Id and PNB_PnbId = Nieobec) where Typ = 5
 return
end
