CREATE    PROCEDURE CDN.MacierzRabatowa
 @lNagPoz  int ,  -- miejsce stosowania nagłówek (1)/pozycja(2)
 @lRodzajDok smallint, --  rodzaj dokumentu (przychód/rozchód)
 @lData int,   -- bieżąca data i czas jako timestamp
 @lKntTyp smallint,  -- dane kontrahenta (KNT,KNU,PRM)
 @lKntNumer int,
 @lTwrTyp smallint,  -- dane towaru (TWU,PRM)
 @lTwrNumer int,
 @lFormaNr int, -- numer formy płatności (PLT)
 @sFrsId   NVARCHAR(255),  -- oddzielone przecinkami miejsca w strukturze firmy
 @lZstNumer int, -- numer zestawu (kompletu)
 @lGIDTyp   int, -- identyfikator pozycji/dokumentu (GID)
 @lGIDNumer int, --
 @lGIDLp    int  --
AS
SET NOCOUNT ON
-- procedura zwraca recordset
--
-- PRM_ID       - identyfikator promocji
-- PRM_AKRONIM  - akronim promocji
-- PRM_TYP - typ promocji (KNT,PLT,TWU,KNU,PRM,GLO)
-- PRM_PRIORYTET- priorytet
-- TWG_NUMER    - identyfikator grupy towaru
-- TWR_NUMER - identyfikator towaru
-- UPUST_TYP - typ upustu (procentowy,wartosciowy,stalacena)
-- UPUST_WARTOSC- wartość upustu lub ceny
-- UPUST_WALUTA - wartość upustu lub ceny
-- UPUST_FLAGANB- wartość upustu lub ceny
-- UPUST_PROG - próg upustu
-- KNT_NUMER - identyfikator kontrahenta
-- PRM_OPERACJA - sposób zasotsowania (DODAJ, MNOZ)
-- PRM_POMIN - czy pominac pozostale
-- UPUST_ID  - identyfikator upustu
-- ZEST_NUMER - identyfikator zestawu
DECLARE @TwrGIDTyp smallint
DECLARE @TwrGRPTyp smallint
DECLARE @KntGRPTyp smallint
Set @TwrGIDTyp = 16
Set @TwrGRPTyp = -16
Set @KntGRPTyp = -32
DECLARE @PrmKarty TABLE ( PRM_Id INT, PRM_Akronim NVARCHAR(200), PRM_DataOd INT, PRM_DataDo INT, PRM_Typ INT, PRM_Priorytet INT, PRM_Stan INT, PRM_Aktywna INT, PRM_SposobStosowania SMALLINT, PRM_PominPozostale SMALLINT, PRM_Dokument SMALLINT, PRM_PriorytetLp INT, PRM_Cykliczna INT )
INSERT INTO @PrmKarty   ( PRM_Id,     PRM_Akronim,              PRM_DataOd,     PRM_DataDo,     PRM_Typ,     PRM_Priorytet,     PRM_Stan,     PRM_Aktywna,     PRM_SposobStosowania,          PRM_PominPozostale,          PRM_Dokument,          PRM_PriorytetLp,     PRM_Cykliczna     )
  SELECT                  PRM_Id,     PRM_Akronim,              PRM_DataOd,     PRM_DataDo,     PRM_Typ,     PRM_Priorytet,     PRM_Stan,     PRM_Aktywna,     PRM_SposobStosowania,          PRM_PominPozostale,          PRM_Dokument,          PRM_PriorytetLp,     PRM_Cykliczna
   FROM CDN.PrmKarty
   WHERE (Prm_Dokument in (0, @lRodzajDok) OR @lRodzajDok=0)
      and Prm_Stan=1
  If (@lNagPoz=2)
  BEGIN
 Declare @lGodz int
 Declare @lTylkoData int
 Set @lTylkoData = cast(@lData /86400 as int)*86400
 If(@lGIDTyp<>960 and @lGIDTyp<>8832 and @lGIDTyp<>8960 and @lGIDTyp<>9472 and @lGIDTyp<>9344) -- nie zamówienia
 BEGIN
  --set @lData = cast(@lData /86400 as int)*86400  -- ustawienie daty na początek doby
  Set @lGodz = datediff( s, convert(datetime, '19900101'),GETDATE())%86400
  Set @lData = @lTylkoData + (datediff( s, convert(datetime, '19900101'),GETDATE())%86400) -- uwzglęnienie aktualnej godziny
 END
-- Else
-- BEGIN
  -- Set @lGodz = cast(@lData % 86400 as int)
-- END
 Select  Prm_Id    as PRM_ID,
  Prm_Akronim  as PRM_AKRONIM,
  Prm_Typ   as PRM_TYP,
  Prm_Priorytet  as PRM_PRIORYTET,
  Prm_PriorytetLp  as PRM_PRIORYTETLP,
  Tpr_TwGNumer  as TWG_NUMER,
  Tpr_TwrNumer  as TWR_NUMER,
  Tpr_Typ   as UPUST_TYP,
  Tpr_Wartosc  as UPUST_WARTOSC,
  Tpr_Waluta  as UPUST_WALUTA,
  Tpr_FlagaNB  as UPUST_FLAGANB,
--  Tpr_Prog  as UPUST_PROG,  TID:69432
--  case when Tpr_Typ=3 then 99999 else Tpr_Prog end as UPUST_PROG,
  Tpr_Prog   as UPUST_PROG,   -- TID:77415
  @lKntNumer  as KNT_NUMER,
  Prm_Sposobstosowania as PRM_OPERACJA,
  Prm_PominPozostale as PRM_POMIN,
  IsNull(Tpr_Lp,0) as UPUST_ID,
  IsNull(Zpr_TwrNumer,0) as ZEST_NUMER, -- *
  1000*(case when Tpr_Typ=3 then 1 else 2 end)+100*(case when tpr_twrtyp=@TwrGIDTyp then 1 else 2 end) as UPUST_SORT
 From Cdn.TwrPromocje
 join @PrmKarty on Prm_Id = TPR_PrmId left outer join CDN.ZstPromocje on TpR_ZstId = ZPR_ID -- and Zpr_TwrNumer=@lZstNumer
 Where
-- case
--  when Prm_Cykliczna=0 and Prm_DataOd<= @lData and @lData <= Prm_DataDo then 1
--  when Prm_Cykliczna=1 and Prm_DataOd<= @lGodz and @lGodz <= Prm_DataDo then 1
--  when Prm_Cykliczna=2 and Prm_DataOd<= @lData and @lData <= Prm_DataDo then 1
--  else 0
-- end = 1
 CDN.CzyPromocjaObowiazuje(PRM_DataOd, PRM_DataDo, PRM_Cykliczna, @lData) = 1
-- 8.6     (Prm_Dokument in (0, @lRodzajDok) OR @lRodzajDok=0)
-- 8.6      Prm_Stan=1
 and ( IsNull(Zpr_TwrNumer,0) = 0 or IsNull(Zpr_TwrNumer,0) = @lZstNumer)
 and  (case
  when Tpr_TwrTyp is null then 1
  when Tpr_TwrTyp=@TwrGIDTyp and Tpr_TwrNumer=@lTwrNumer then 1
  when Tpr_TwrTyp=@TwrGRPTyp and exists(
      Select  TwL_GIDNumer
      From CDN.TwrLinki
      Where  TwL_GroTyp   = TPR_TwrTyp
      and  TwL_GroNumer = TPR_TwrNumer
      and  TwL_GIDTyp = @TwrGIDTyp
      and TwL_GIDNumer = @lTwrNumer
     ) then 1
  End) = 1
 and
 (Case  when PrM_Typ in (3) then 1   -- TWU
  when exists (  Select *
    from Cdn.KntPromocje
    where  KPR_PrmId = Prm_Id
    and (case when  Kpr_KntTyp=@lKntTyp and Kpr_KntNumer=@lKntNumer then 1
       when Kpr_KntTyp=@KntGRPTyp and exists(
        Select  KnL_GIDNumer
        From CDN.KntLinki
        Where KnL_GroTyp = KPR_KntTyp
        and KnL_GroNumer = KPR_KntNumer
        and KnL_GIDTyp = @lKntTyp
        and KnL_GIDNumer = @lKntNumer
         )
       then 1
         end) =1
       ) then 1
 End)=1
 and
 (Case  when PrM_Typ in (3,4) then 1   -- TWU,KNU
  when exists (  Select *
    from Cdn.FrsPromocje
    where  FPR_PrmId = Prm_Id
    --and Fpr_FrsId in (@sFrsid)
    and CharIndex(','+ltrim(cast(Fpr_FrsId as NVARCHAR(5)))+',', ','+ltrim(@sFrsId)+',',1)>0
       ) then 1
 End)=1
  union  -- i jeszcze rekord typu GLO
 Select  Prm_Id    as PRM_ID,
  Prm_Akronim  as PRM_AKRONIM,
  Prm_Typ   as PRM_TYP,
  Prm_Priorytet  as PRM_PRIORYTET,
  Prm_PriorytetLp  as PRM_PRIORYTETLP,
  0   as TWG_NUMER,
  0   as TWR_NUMER,
  1   as UPUST_TYP,
  0   as UPUST_WARTOSC,
  'PLN'   as UPUST_WALUTA,
  'N'   as UPUST_FLAGANB,
  0   as UPUST_PROG,
  0   as KNT_NUMER,
  Prm_Sposobstosowania as PRM_OPERACJA,
  Prm_PominPozostale as PRM_POMIN,
  99999    as UPUST_ID, -- ,*
  0   as ZEST_NUMER,-- *
  99999 as UPUST_SORT
 From @PrmKarty
 Where Prm_Typ=6
-- 8.6    and (Prm_Dokument in (0, @lRodzajDok) OR @lRodzajDok=0)
 order by Prm_Priorytet, PRM_PriorytetLP,
   ZEST_NUMER DESC, UPUST_SORT, UPUST_PROG DESC, UPUST_Id
  END
  ELSE
  BEGIN
 Select  Prm_Id    as PRM_ID,
  Prm_Akronim  as PRM_AKRONIM,
  Prm_Typ   as PRM_TYP,
  Prm_Priorytet  as PRM_PRIORYTET,
  Prm_PriorytetLp  as PRM_PRIORYTETLP,
  0   as TWG_NUMER,
  0   as TWR_NUMER,
  Kpr_Typ   as UPUST_TYP,
  Kpr_wartosc  as UPUST_WARTOSC,
  'PLN'   as UPUST_WALUTA,
  'N'   as UPUST_FLAGANB,
  0   as UPUST_PROG,
  @lKntNumer  as KNT_NUMER,
  Prm_Sposobstosowania as PRM_OPERACJA,
  Prm_PominPozostale as PRM_POMIN,
  IsNull(Kpr_Id,0) as UPUST_ID,-- *
  0   as ZEST_NUMER,-- *
  99999 as UPUST_SORT
 From Cdn.KntPromocje
 join @PrmKarty on Prm_Id = KPR_PrmId
 Where
-- 8.6          (Prm_Dokument in (0, @lRodzajDok) OR @lRodzajDok=0)
-- 8.6       and Prm_Stan=1
/* 8.6 and */ Prm_Typ=1
 and  (case
  when Kpr_KntTyp=@lKntTyp and Kpr_KntNumer=@lKntNumer then 1
  when Kpr_KntTyp=@KntGRPTyp and exists(
      Select  KnL_GIDNumer
      From CDN.KntLinki
      Where  KnL_GroTyp   = KPR_KntTyp
      and  KnL_GroNumer = KPR_KntNumer
      and  KnL_GIDTyp = @lKntTyp
      and KnL_GIDNumer = @lKntNumer
     ) then 1
  End) = 1
 Union
 Select  Prm_Id    as PRM_ID,
  Prm_Akronim  as PRM_AKRONIM,
  Prm_Typ   as PRM_TYP,
  Prm_Priorytet  as PRM_PRIORYTET,
  Prm_PriorytetLp  as PRM_PRIORYTETLP,
  0   as TWG_NUMER,
  0   as TWR_NUMER,
  1   as UPUST_TYP,
  Ppr_wartosc  as UPUST_WARTOSC,
  'PLN'   as UPUST_WALUTA,
  'N'   as UPUST_FLAGANB,
  0   as UPUST_PROG,
  @lKntNumer  as KNT_NUMER,
  Prm_Sposobstosowania as PRM_OPERACJA,
  Prm_PominPozostale as PRM_POMIN,
  IsNull(Ppr_Id,0) as UPUST_ID, -- *
  0   as ZEST_NUMER,-- *
  99999 as UPUST_SORT
 From Cdn.PltPromocje
 join @PrmKarty on Prm_Id = PPR_PrmId
 Where
-- 8.6          (Prm_Dokument in (0, @lRodzajDok) OR @lRodzajDok=0)
-- 8.6       and Prm_Stan=1
/* 8.6  and */        Prm_typ=2
 and PPR_PltId = @lFormaNr
 order by Prm_Priorytet, PRM_PriorytetLP,
   ZEST_NUMER DESC, UPUST_SORT, UPUST_PROG DESC, UPUST_Id
  SET NOCOUNT OFF
  END
