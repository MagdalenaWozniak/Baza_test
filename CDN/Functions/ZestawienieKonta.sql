CREATE FUNCTION CDN.ZestawienieKonta(@OkresObrachunkowyId int, @ZestawienieId int, @podpieteNiepodpiete int, @kontaWszystkie int, @kontaKoszty4 int, @kontaKoszty5 int)
RETURNS @Result TABLE(
            ZKaId INTEGER,
      ParentZKaId INTEGER,
      OObId INTEGER,
      ZKNId INTEGER ,
      ZKPId INTEGER ,
      AccId INTEGER ,
      ParentAccId INTEGER,
      Funkcja NVARCHAR(50),
      FunkcjaNorma NVARCHAR(50),
      ZKN_Symbol NVARCHAR(20),
      ZKN_Nazwa NVARCHAR(255),
      ZKP_Nazwa NVARCHAR(255)
      )
AS
BEGIN
  declare @KontaPodpiete int = 1;
  declare @KontaNiePodpiete int = 2;
  declare @typKontaKoszty int = 5;
  declare @typZestawienia int = -1;
  declare @tzBilans int = 0;
  declare @tzRZiSKalk int = 1;
  declare @tzRZiSPor int = 2;
  declare @tzZestZmianWKapitale int = 3;
  declare @tzPrzeplywyBezp int = 4;
  declare @tzPrzeplywyPosr int = 5;
  declare @tzRZiS int = 6;
  declare @tzPIT36 int = 101;
  declare @tzCIT8 int = 102;
/*
@podpieteNiepodpiete enum StatusUzyciaKontaType -
        {
            Undefined,
            Podpiete,
            Niepodpiete
        }
*/
  if @podpieteNiepodpiete = @KontaPodpiete
  begin
    insert into @Result(ZKaId, ParentZKaId, OObId, ZKNId, ZKPId, AccId, ParentAccId, Funkcja, FunkcjaNorma, ZKN_Symbol, ZKN_Nazwa, ZKP_Nazwa)
    select ROW_NUMBER() OVER(ORDER BY Zka_ZkaID), NULL, ZKa_OObId, ZKa_ZKNId, ZKa_ZKPId, Acc_AccId, Acc_ParId, ZKa_Funkcja, ZKa_FunkcjaNorma, ZKN_Symbol, ZKN_Nazwa, ZKP_Nazwa
    from
    CDN.Konta
    left outer join CDN.ZestawieniaKonta on (Acc_AccId = ZKa_AccId)
    left outer join CDN.ZestKsiNag on (ZKa_ZKNId=ZKN_ZKNId)
    left outer join CDN.ZestKsiPoz on (ZKa_ZKPId = ZKP_ZKPId)
    where
    ZKa_ZKaId is not null
    and ZKa_ZKNId = @ZestawienieId
    update r1 set r1.ParentZKaId = r2.ZKaId
    from @Result r1 join @Result r2 on (r1.ParentAccId = r2.AccId and r1.ZKPId = r2.ZKPId)
  end
  else
  begin
    --stage 1, lookup on where phaze
    insert into @Result(ZKaId, ParentZKaId, OObId, AccId, ParentAccId)
    select ROW_NUMBER() OVER(ORDER BY Acc_AccID), NULL, Acc_OObId, Acc_AccId, Acc_ParId
    from
    CDN.Konta
    where
    Acc_OObId = @OkresObrachunkowyId
    and Acc_AccID not in (
    select Acc_AccId from cdn.konta join CDN.ZestawieniaKonta on (Acc_AccId = ZKa_AccId)
    where ZKa_ZKNId = @ZestawienieId
    )
    select @typZestawienia = case when ZKN_TypZest=0 then ZKN_TypZestawienia else 100+ZKN_TypZest end from CDN.ZestKsiNag where ZKN_ZKNId = @ZestawienieId
    --delete from @Result where ZKNId is not null
    if @typZestawienia = @tzBilans
    begin
   if @kontaWszystkie=0
   begin
    delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
    where Acc_TypKonta not BETWEEN 1 AND 3
   end
          /*
          delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
          where Acc_TypKonta = 1 and FunkcjaNorma = '@SALDOWN'
          delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
          where Acc_TypKonta = 2 and FunkcjaNorma = '@SALDOMA'
          delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
          where Acc_TypKonta = 3
          and exists (select * from @Result E where E.AccId = r.AccId and FunkcjaNorma = '@SALDOWN')
          and exists (select * from @Result E where E.AccId = r.AccId and FunkcjaNorma = '@SALDOMA')
          */
    end
    if @typZestawienia in(@tzRZiSKalk, @tzRZiSPor, @tzRZiS)
    begin
   if @kontaWszystkie=0
   begin
    delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
    where Acc_TypKonta not in (4,5,7)
   end
          /*
          delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
          where Acc_TypKonta = 4 and FunkcjaNorma = '@OBROTYMA'
          delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
          where Acc_TypKonta = 5 and FunkcjaNorma = '@OBROTYWN'
          delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
          where Acc_TypKonta = 7
          and exists (select * from @Result E where E.AccId = r.AccId and FunkcjaNorma = '@OBROTYWN')
          and exists (select * from @Result E where E.AccId = r.AccId and FunkcjaNorma = '@OBROTYMA')
          */
    end
    if @typZestawienia in(@tzPIT36, @tzCIT8)
    begin
   if @kontaWszystkie=0
   begin
    delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
    where Acc_TypKonta not in (4,5,7)
   end
          /*
          delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
          where Acc_TypKonta = 4 and FunkcjaNorma = '@OBROTYMA'
          delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
          where Acc_TypKonta = 5 and FunkcjaNorma = '@OBROTYWN'
          delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
          where Acc_TypKonta = 7
          and exists (select * from @Result E where E.AccId = r.AccId and FunkcjaNorma = '@OBROTYWN')
          and exists (select * from @Result E where E.AccId = r.AccId and FunkcjaNorma = '@OBROTYMA')
          */
    end
    declare @kosztyInne int = 0;
    if @typZestawienia in(@tzPIT36, @tzCIT8, @tzRZiSKalk, @tzRZiSPor, @tzRZiS)
      set @kosztyInne = 1;
    if @kontaWszystkie = 0
    begin
      if @kosztyInne = 0
      begin
        if @kontaKoszty4 = 0 and @kontaKoszty5 = 0
        begin
            delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
            where Acc_TypKonta = @typKontaKoszty and Acc_NumerIdx like '4%' and Acc_NumerIdx like '5%'
        end
        else if @kontaKoszty4 = 1 and @kontaKoszty5 = 1
        begin
            delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
            where Acc_TypKonta = @typKontaKoszty and Acc_NumerIdx not like '4%' and Acc_NumerIdx not like '5%'
        end
        else if @kontaKoszty4 = 1 and @kontaKoszty5 = 0
        begin
            delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
            where Acc_TypKonta = @typKontaKoszty and Acc_NumerIdx not like '4%';
        end
        else if @kontaKoszty4 = 0 and @kontaKoszty5 = 1
        begin
            delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
            where Acc_TypKonta = @typKontaKoszty and Acc_NumerIdx not like '5%';
        end
      end
      else
      begin
        if @kontaKoszty4 = 1 and @kontaKoszty5 = 0
        begin
            delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
            where Acc_AccId in (select Acc_AccId from CDN.Konta where Acc_Numer like '5%')
        end
        else if @kontaKoszty4 = 0 and @kontaKoszty5 = 1
        begin
            delete from r from @Result r join CDN.Konta on (r.AccId = Acc_AccId)
            where Acc_AccId in (select Acc_AccId from CDN.Konta where Acc_Numer like '4%')
        end
      end
    end
    update r1 set r1.ParentZKaId = r2.ZKaId
    from @Result r1 join @Result r2 on (r1.ParentAccId = r2.AccId)
  end
 return
END
