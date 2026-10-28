CREATE FUNCTION CDN.VATZD_Zobowiazania(@DataZestawienia DateTime, @McKw INT, @Typ INT,  @DknId INT, @BZdId int = NULL, @allowDelete int)
RETURNS @Result TABLE( BZdId INT,
      VaNId INT,
      TrNId INT,
      DataWys DateTime,
      Termin DateTime,
      TerminPlatnosci DateTime,
      SumaKwotZdarzen Decimal(15,2),
      SumaKwotRozliczen Decimal(15,2),
      UniqueId INT NOT NULL IDENTITY(1,1),
      PRIMARY KEY (BZdId, Vanid, DataWys, Termin, UniqueId))
BEGIN
 declare @MinDataVaN DateTime; select @MinDataVaN = min(VaN_DataWys) from cdn.VatNag
 declare @MaxDataVaN DateTime; select @MaxDataVaN = max(VaN_DataWys) from cdn.VatNag
 declare @REJESTR_ZAKUPOW int
 declare @REJESTR_SPRZEDAZY int
 set @REJESTR_ZAKUPOW = 1
 set @REJESTR_SPRZEDAZY = 2
 declare @rejestr int
 set @rejestr = @Typ
 declare @opoznienie int
 declare @dataDeklaracji DATETIME
 declare @dataWystawieniaOd DATETIME
 declare @dataWystawieniaDo DATETIME
 declare @TerminPlatnosci DATETIME
 declare @TerminPlatnosciMin DATETIME
 set @dataDeklaracji = @DataZestawienia --getdate() + 0
  /*
 if YEAR(@dataDeklaracji) < 2019
  set @opoznienie = 150
 else
  set @opoznienie = 90
 */
 set @opoznienie = 90
 set @dataWystawieniaDo = @dataDeklaracji
 set @dataWystawieniaOd = Convert(DateTime, '2011-09-01', 120) --DateAdd(year, -2, @dataWystawieniaDo)
 set @TerminPlatnosciMin = DateAdd(day, -@opoznienie, Convert(DateTime, '2013-01-01', 120))
 set @TerminPlatnosci = DateAdd(day, -@opoznienie, Convert(DateTime, @dataDeklaracji, 120))
 --set @TerminPlatnosciMin = DateAdd(day, -day(@dataZestawienia)+1 - 150, Convert(DateTime, @dataZestawienia, 120))
 --set @TerminPlatnosci = DateAdd(day, - 150, Convert(DateTime, @dataZestawienia, 120))
 if @TerminPlatnosci < @TerminPlatnosciMin
  set @TerminPlatnosci = @TerminPlatnosciMin
--
 declare @dateLimit DateTime = convert(DateTime, '2019-01-01', 120);
 declare @limit int = 90;
 declare @dateOd90 DateTime;
 declare @dateDo90 DateTime;
 declare @dateOd150 DateTime;
 declare @dateDo150 DateTime;
 declare @opoznienie90A int = 90;
 declare @opoznienie90B int = 90;
 declare @opoznienie150A int = 150;
 declare @opoznienie150B int = 150;
 if @McKw = 1
 begin
  set @dateOd90 = DateAdd(Day, -@opoznienie90B, DateAdd(Day, -Day(@DataZestawienia)+1,  @DataZestawienia) );
  set @dateDo90 = DateAdd(Day, -@opoznienie90A, @DataZestawienia);
  set @dateOd150 = DateAdd(Day, -@opoznienie150B, DateAdd(Day, -Day(@DataZestawienia)+1,  @DataZestawienia) );
  set @dateDo150 = DateAdd(Day, -@opoznienie150A, @DataZestawienia);
 end
 else
 begin
  set @dateOd90 = DateAdd(Month, -2, DateAdd(Day, 0, DateAdd(Day, -Day(@DataZestawienia)+1,  @DataZestawienia) ));
  set @dateDo90 = @DataZestawienia;
  set @dateOd150 = DateAdd(Month, -2, DateAdd(Day, 0, DateAdd(Day, -Day(@DataZestawienia)+1,  @DataZestawienia) ));
  set @dateDo150 = @DataZestawienia;
  set @dateOd90 = DateAdd(Day, -@opoznienie90B, @dateOd90 );
  set @dateDo90 = DateAdd(Day, -@opoznienie90A, @DataZestawienia);
  set @dateOd150 = DateAdd(Day, -@opoznienie150B, @dateOd150 );
  set @dateDo150 = DateAdd(Day, -@opoznienie150A, @DataZestawienia);
 end
 if @BZdId is NULL
 begin
    declare @brk_vat Table(BZdId INT, brk_waluta nvarchar(3),brk_kwota decimal(15,2),brk_DokTyp int,brk_DokID int,brk_LDokTyp int,brk_LDokID int,brk_PDokTyp int,brk_PDokID int,BRK_KwotaSysL decimal(15,2),BRK_KwotaSysP decimal(15,2),brk_dataDok datetime);
    insert into @brk_vat
    select BZd_BZdId, brk_waluta,brk_kwota,brk_LDokTyp,brk_LDokID,brk_LDokTyp,brk_LDokID,brk_PDokTyp,brk_PDokID,BRK_KwotaSysL,BRK_KwotaSysP,brk_dataDok
    from cdn.VatNag
    join cdn.BnkZdarzenia on (bzd_DokumentTyp = 2 and bzd_DokumentID = VaN_VaNId)
    join cdn.BnkRozKwoty on (brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID and brk_dataDok is NULL)
    union
    select BZd_BZdId, brk_waluta,brk_kwota,brk_PDokTyp,brk_PDokID,brk_LDokTyp,brk_LDokID,brk_PDokTyp,brk_PDokID,BRK_KwotaSysL,BRK_KwotaSysP,brk_dataDok
    from cdn.VatNag
    join cdn.BnkZdarzenia on (bzd_DokumentTyp = 2 and bzd_DokumentID = VaN_VaNId)
    join cdn.BnkRozKwoty on (brk_PDokTyp = 1 AND brk_PDokID = bzd_BzDID and brk_dataDok is NULL)
    union
    select BZd_BZdId, brk_waluta,brk_kwota,brk_LDokTyp,brk_LDokID,brk_LDokTyp,brk_LDokID,brk_PDokTyp,brk_PDokID,BRK_KwotaSysL,BRK_KwotaSysP,brk_dataDok
    from cdn.VatNag
    join cdn.BnkZdarzenia on (bzd_DokumentTyp = 2 and bzd_DokumentID = VaN_VaNId)
    join cdn.BnkRozKwoty on (brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID and brk_dataDok <= @dataDeklaracji)
    union
    select BZd_BZdId, brk_waluta,brk_kwota,brk_PDokTyp,brk_PDokID,brk_LDokTyp,brk_LDokID,brk_PDokTyp,brk_PDokID,BRK_KwotaSysL,BRK_KwotaSysP,brk_dataDok
    from cdn.VatNag
    join cdn.BnkZdarzenia on (bzd_DokumentTyp = 2 and bzd_DokumentID = VaN_VaNId)
    join cdn.BnkRozKwoty on (brk_PDokTyp = 1 AND brk_PDokID = bzd_BzDID and brk_dataDok <= @dataDeklaracji)
    declare @brk_fa Table(BZdId INT, brk_waluta nvarchar(3),brk_kwota decimal(15,2),brk_DokTyp int,brk_DokID int,brk_LDokTyp int,brk_LDokID int,brk_PDokTyp int,brk_PDokID int,BRK_KwotaSysL decimal(15,2),BRK_KwotaSysP decimal(15,2),brk_dataDok datetime);
    insert into @brk_fa
    select BZd_BZdId, brk_waluta,brk_kwota,brk_LDokTyp,brk_LDokID,brk_LDokTyp,brk_LDokID,brk_PDokTyp,brk_PDokID,BRK_KwotaSysL,BRK_KwotaSysP,brk_dataDok
    from cdn.VatNag join cdn.tranag on (TrN_VaNId = VaN_VaNId)
    join cdn.BnkZdarzenia on (bzd_DokumentTyp = 1 and bzd_DokumentID = TrN_TrNId)
    join cdn.BnkRozKwoty on (brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID and brk_dataDok is NULL)
    union
    select BZd_BZdId, brk_waluta,brk_kwota,brk_PDokTyp,brk_PDokID,brk_LDokTyp,brk_LDokID,brk_PDokTyp,brk_PDokID,BRK_KwotaSysL,BRK_KwotaSysP,brk_dataDok
    from cdn.VatNag join cdn.tranag on (TrN_VaNId = VaN_VaNId)
    join cdn.BnkZdarzenia on (bzd_DokumentTyp = 1 and bzd_DokumentID = TrN_TrNId)
    join cdn.BnkRozKwoty on (brk_PDokTyp = 1 AND brk_PDokID = bzd_BzDID and brk_dataDok is NULL)
    union
    select BZd_BZdId, brk_waluta,brk_kwota,brk_LDokTyp,brk_LDokID,brk_LDokTyp,brk_LDokID,brk_PDokTyp,brk_PDokID,BRK_KwotaSysL,BRK_KwotaSysP,brk_dataDok
    from cdn.VatNag join cdn.tranag on (TrN_VaNId = VaN_VaNId)
    join cdn.BnkZdarzenia on (bzd_DokumentTyp = 1 and bzd_DokumentID = TrN_TrNId)
    join cdn.BnkRozKwoty on (brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID and brk_dataDok <= @dataDeklaracji)
    union
    select BZd_BZdId, brk_waluta,brk_kwota,brk_PDokTyp,brk_PDokID,brk_LDokTyp,brk_LDokID,brk_PDokTyp,brk_PDokID,BRK_KwotaSysL,BRK_KwotaSysP,brk_dataDok
    from cdn.VatNag join cdn.tranag on (TrN_VaNId = VaN_VaNId)
    join cdn.BnkZdarzenia on (bzd_DokumentTyp = 1 and bzd_DokumentID = TrN_TrNId)
    join cdn.BnkRozKwoty on (brk_PDokTyp = 1 AND brk_PDokID = bzd_BzDID and brk_dataDok <= @dataDeklaracji)
    declare @mrvct Table (Data DAte, Motoda int)
    insert into @mrvct select * from CDN.MetodaRozliczaniaVatConfigTable_For_VatNag() where Metoda = 1
  insert into @Result
   select BZd_BZdId, VaN_VaNId as VaNId,VaN_TrnId as TrNId, VaN_DataWys, bzd_TerminR, bzd_Termin,
   SumaKwotZdarzen = NULL,
   SumaKwotRozliczen = sum(IsNull( case when VaN_WalutaDoVat = brk_waluta then
            case when brk_waluta = '' then BZd_Kierunek * brk_kwota else
             case when VaN_KursNumerDoVat = -1
              then
               --case when brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID then BZd_Kierunek * BRK_KwotaSysL else BZd_Kierunek * BRK_KwotaSysP end
               cast((BZd_Kierunek * brk_kwota * VaN_RazemBruttoDoVAT/VaN_RazemBruttoWal) as decimal(15,2))
                            else
                              cast((BZd_Kierunek * brk_kwota * VaN_KursLDoVAT/VaN_KursMDoVAT) as decimal(15,2))
                            end
            end
                        else
                          case when brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID then BZd_Kierunek * BRK_KwotaSysL else BZd_Kierunek * BRK_KwotaSysP end
                        end,
         0.0))
   from
   cdn.VatNag
   --left outer join CDN.MetodaRozliczaniaVatConfigTable(@MinDataVaN, @MaxDataVaN) on (VaN_DataWys=Data)
   left outer join @mrvct on (VaN_DataWys=Data)
   left outer join cdn.Kontrahenci on (VaN_PodId = Knt_KntId)
   left outer join cdn.BnkZdarzenia on (bzd_DokumentTyp = 2 and bzd_DokumentID = VaN_VaNId)
   left outer join @brk_vat on (brk_DokID = bzd_BzDID)
   --left outer join cdn.BnkRozKwoty on (brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID or brk_PDokTyp = 1 AND brk_PDokID = bzd_BzDID) AND (brk_dataDok is NULL or brk_dataDok <= @dataDeklaracji)
   where
   --Knt_PowiazanyUoV = 0
   --and
   --Metoda = 1
   --and Knt_NieUwzglVATZD = 0
   --and
   VaN_MetodaKasowa = 0
   and VaN_TrnId is Null
   and VaN_Typ = @rejestr
   and VaN_RozliczacVAT7 = 1
   --and (VaN_Export = 0 and VaN_PodatekVat<> 0 or VaN_Export=5)
   and (VaN_Export in (0,5) and VaN_PodatekVat<> 0
   or VaN_Export = 5 and VaN_PodatekVat = 0  and VaN_DataOpe < Convert(DateTime, '2015-07-01', 120))
   and VaN_Finalny = 0
   --pb and (VaN_Typ = @REJESTR_ZAKUPOW or DateDiff(month, (DATEADD(year, Year(VaN_DataWys)-1899, 0 )-1), @dataDeklaracji) <= 24 ) -- nie minÄ™Ĺ‚o dwa lata
   and VaN_DataWys <= @dataWystawieniaDo
   and bzd_TerminR >= @TerminPlatnosciMin and bzd_TerminR <= @TerminPlatnosci
   and BZd_Rozliczono<>0 and BZd_Rozliczono2<>0
   and ((BZd_Rozliczono<>2 or BZd_Rozliczono2<>2) and (DATEDIFF(DAY, bzd_TerminR, @dataDeklaracji) >= @opoznienie)
     or BZd_Rozliczono=2 and BZd_Rozliczono2=2 and exists (select * from cdn.BnkRozKwoty BRK where (BRK.brk_LDokTyp = 1 AND BRK.brk_LDokID = bzd_BzDID or BRK.brk_PDokTyp = 1 AND BRK.brk_PDokID = bzd_BzDID) and DATEDIFF(DAY, bzd_TerminR, brk_dataDok) >= @opoznienie))
   group by BZd_BZdId, VaN_TrnId, VaN_VaNId, VaN_Dokument, VaN_DataWys, bzd_TerminR, bzd_Termin
      -- Handel
   union
   select BZd_BZdId, VaN_VaNId as VaNId, -1 as TrNId, VaN_DataWys, bzd_TerminR, bzd_Termin,
   SumaKwotZdarzen = NULL,
   SumaKwotRozliczen = sum(IsNull( case when VaN_WalutaDoVat = brk_waluta then
            case when brk_waluta = '' then BZd_Kierunek * brk_kwota else
             case when VaN_KursNumerDoVat = -1
              then
                              --case when brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID then BZd_Kierunek * BRK_KwotaSysL else BZd_Kierunek * BRK_KwotaSysP end
                              cast((BZd_Kierunek * brk_kwota * VaN_RazemBruttoDoVAT/VaN_RazemBruttoWal) as decimal(15,2))
              else
                              cast((BZd_Kierunek * brk_kwota * VaN_KursLDoVAT/VaN_KursMDoVAT) as decimal(15,2))
                            end
            end
                        else
                          case when brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID then BZd_Kierunek * BRK_KwotaSysL else BZd_Kierunek * BRK_KwotaSysP end
                        end,
         0.0))
   from
   cdn.VatNag join cdn.tranag on (TrN_VaNId = VaN_VaNId)
   --left outer join CDN.MetodaRozliczaniaVatConfigTable(@MinDataVaN, @MaxDataVaN) on (VaN_DataWys=Data)
   left outer join @mrvct on (VaN_DataWys=Data)
   left outer join cdn.Kontrahenci on (VaN_PodId = Knt_KntId)
   left outer join cdn.BnkZdarzenia on (bzd_DokumentTyp = 1 and bzd_DokumentID = TrN_TrNId)
   left outer join @brk_fa on (brk_DokID = bzd_BzDID)
   --left outer join cdn.BnkRozKwoty on (brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID or brk_PDokTyp = 1 AND brk_PDokID = bzd_BzDID) AND (brk_dataDok is NULL or brk_dataDok <= @dataDeklaracji)
   where
   --Metoda = 1
   --and TrN_TypDokumentu = 305
   --and Knt_PowiazanyUoV = 0
   --and Knt_NieUwzglVATZD = 0
   --and
   VaN_MetodaKasowa = 0
   and VaN_Typ = @rejestr
   and VaN_RozliczacVAT7 = 1
   --and (VaN_Export = 0 and VaN_PodatekVat<> 0 or VaN_Export=5)
   and (VaN_Export in (0,5) and VaN_PodatekVat<> 0
   or VaN_Export = 5 and VaN_PodatekVat = 0  and VaN_DataOpe < Convert(DateTime, '2015-07-01', 120))
   and VaN_Finalny = 0
   --pb and (VaN_Typ = @REJESTR_ZAKUPOW or DateDiff(month, (DATEADD(year, Year(VaN_DataWys)-1899, 0 )-1), @dataDeklaracji) <= 24 ) -- nie minÄ™Ĺ‚o dwa lata
   and VaN_DataWys <= @dataWystawieniaDo
   and bzd_TerminR >= @TerminPlatnosciMin and bzd_TerminR <= @TerminPlatnosci
   and BZd_Rozliczono<>0 and BZd_Rozliczono2<>0
   and ((BZd_Rozliczono<>2 or BZd_Rozliczono2<>2) and (DATEDIFF(DAY, bzd_TerminR, @dataDeklaracji) >= @opoznienie)
     or BZd_Rozliczono=2 and BZd_Rozliczono2=2 and exists (select * from cdn.BnkRozKwoty BRK where (BRK.brk_LDokTyp = 1 AND BRK.brk_LDokID = bzd_BzDID or BRK.brk_PDokTyp = 1 AND BRK.brk_PDokID = bzd_BzDID) and DATEDIFF(DAY, bzd_TerminR, brk_dataDok) >= @opoznienie))
   group by BZd_BZdId, VaN_VaNId, VaN_Dokument, VaN_DataWys, bzd_TerminR, bzd_Termin
   if IsNull(@allowDelete, 0) <> 0
   begin
    -- usuwamy powiÄ…zane tylko poprzez VANId
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_VaNId = VaNId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    --left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is null
    and DateAdd(Day, @limit, Termin) >= @dateLimit and Termin not between @dateOd90 and @dateDo90
    and VaZ_VaZId is Null
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_VaNId = VaNId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    --left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is null
    and DateAdd(Day, @limit, Termin) < @dateLimit and Termin not between @dateOd150 and @dateDo150
    and VaZ_VaZId is Null
    -- usuniÄ™cie pozycji ktĂłre data wystawienie przekracza dwa lata i dotej pory nie byĹ‚y uwzglÄ™dnione na VATZD
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_VaNId = VaNId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    --left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is null
    and DateDiff(month, (DATEADD(year, Year(DataWys)-1899, 0 )-1), @dataZestawienia) > 24
    and VaZ_VaZId is Null
    --
    -- usuwamy powiÄ…zane poprzez BZdId
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is not null
    and DateAdd(Day, @limit, Termin) >= @dateLimit and Termin not between @dateOd90 and @dateDo90
    and VaZ_VaZId is Null
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is not null
    and DateAdd(Day, @limit, Termin) < @dateLimit and Termin not between @dateOd150 and @dateDo150
    and VaZ_VaZId is Null
    -- usuniÄ™cie pozycji ktĂłre data wystawienie przekracza dwa lata i dotej pory nie byĹ‚y uwzglÄ™dnione na VATZD
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is not null
    and DateDiff(month, (DATEADD(year, Year(DataWys)-1899, 0 )-1), @dataZestawienia) > 24
    and VaZ_VaZId is Null
    --
   end
   -- Rejestr VAT
   Update @Result set SumaKwotZdarzen = (
   select sum( IsNull( case when VaN_WalutaDoVat = bzd_waluta then
         case when bzd_waluta = '' then BZd_Kierunek * bzd_kwota else
          case when VaN_KursNumerDoVat = -1
           then
                        --BZd_Kierunek * BZd_KwotaSys
                        cast((BZd_Kierunek * bzd_kwota * VaN_RazemBruttoDoVAT/VaN_RazemBruttoWal) as decimal(15,2))
                      else
                        cast((BZd_Kierunek * bzd_kwota * VaN_KursLDoVAT/VaN_KursMDoVAT) as decimal(15,2))
                      end
         end
                  else
                    BZd_Kierunek * BZd_KwotaSys
                  end,
      0.0))
   From CDN.VatNag join cdn.BnkZdarzenia on (BZd_BZdId = BZdId and bzd_DokumentTyp = 2 and VaN_VaNId = VaNId and bzd_DokumentID = VaNId)
   where BZd_Rozliczono<>0 and BZd_Rozliczono2<>0 and VaN_TrnId is null and Termin = bzd_TerminR
   and bzd_TerminR >= @TerminPlatnosciMin and bzd_TerminR <= @TerminPlatnosci
   )
   where TrNId is null
   -- Handel Paragony
   Update @Result set SumaKwotZdarzen = (
   select sum(IsNull( case when VaN_WalutaDoVat = bzd_waluta then
         case when bzd_waluta = '' then BZd_Kierunek * bzd_kwota else
          case when VaN_KursNumerDoVat = -1
           then
                        --BZd_Kierunek * BZd_KwotaSys
                        cast((BZd_Kierunek * bzd_kwota * VaN_RazemBruttoDoVAT/VaN_RazemBruttoWal) as decimal(15,2))
           else
                        cast((BZd_Kierunek * bzd_kwota * VaN_KursLDoVAT/VaN_KursMDoVAT) as decimal(15,2))
                      end
         end
                  else
                    BZd_Kierunek * BZd_KwotaSys
                  end,
      0.0))
   From CDN.VatNag join cdn.tranag on (VaN_VaNId = vanid and TrN_VaNId = VaN_VaNId)
   join cdn.BnkZdarzenia on (BZd_BZdId = BZdId and bzd_DokumentTyp = 1 and bzd_DokumentID = TrN_TrNId)
   where BZd_Rozliczono<>0 and BZd_Rozliczono2<>0 and Termin = bzd_TerminR and bzd_TerminR >= @TerminPlatnosciMin and bzd_TerminR <= @TerminPlatnosci
   )
   where TrNId = -1
 end
 else
 begin
  insert into @Result
   select BZd_BZdId, VaN_VaNId as VaNId,VaN_TrnId as TrNId, VaN_DataWys, bzd_TerminR, bzd_Termin,
   SumaKwotZdarzen = NULL,
   SumaKwotRozliczen = sum(IsNull( case when VaN_WalutaDoVat = brk_waluta then
            case when brk_waluta = '' then BZd_Kierunek * brk_kwota else
             case when VaN_KursNumerDoVat = -1
              then
               --case when brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID then BZd_Kierunek * BRK_KwotaSysL else BZd_Kierunek * BRK_KwotaSysP end
               cast((BZd_Kierunek * brk_kwota * VaN_RazemBruttoDoVAT/VaN_RazemBruttoWal) as decimal(15,2))
              else
                              cast((BZd_Kierunek * brk_kwota * VaN_KursLDoVAT/VaN_KursMDoVAT) as decimal(15,2))
                            end
            end
                        else
                          case when brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID then BZd_Kierunek * BRK_KwotaSysL else BZd_Kierunek * BRK_KwotaSysP end
                        end,
         0.0))
   from
   cdn.VatNag
   left outer join cdn.BnkZdarzenia on (bzd_DokumentTyp = 2 and bzd_DokumentID = VaN_VaNId)
   left outer join cdn.BnkRozKwoty on (brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID or brk_PDokTyp = 1 AND brk_PDokID = bzd_BzDID) AND (brk_dataDok is NULL or brk_dataDok <= @dataDeklaracji)
   where
   BZd_BZdId = @BZdId
   and bzd_TerminR >= @TerminPlatnosciMin and bzd_TerminR <= @TerminPlatnosci
   and BZd_Rozliczono<>0 and BZd_Rozliczono2<>0
   and ((BZd_Rozliczono<>2 or BZd_Rozliczono2<>2) and (DATEDIFF(DAY, bzd_TerminR, @dataDeklaracji) >= @opoznienie)
     or BZd_Rozliczono=2 and BZd_Rozliczono2=2 and exists (select * from cdn.BnkRozKwoty BRK where (BRK.brk_LDokTyp = 1 AND BRK.brk_LDokID = bzd_BzDID or BRK.brk_PDokTyp = 1 AND BRK.brk_PDokID = bzd_BzDID) and DATEDIFF(DAY, bzd_TerminR, brk_dataDok) >= @opoznienie))
   group by BZd_BZdId, VaN_TrnId, VaN_VaNId, VaN_Dokument, VaN_DataWys, bzd_TerminR, bzd_Termin
      -- Handel
   union
   select BZd_BZdId, VaN_VaNId as VaNId, -1 as TrNId, VaN_DataWys, bzd_TerminR, bzd_Termin,
   SumaKwotZdarzen = NULL,
   SumaKwotRozliczen = sum(IsNull( case when VaN_WalutaDoVat = brk_waluta then
            case when brk_waluta = '' then BZd_Kierunek * brk_kwota else
             case when VaN_KursNumerDoVat = -1
              then
               --case when brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID then BZd_Kierunek * BRK_KwotaSysL else BZd_Kierunek * BRK_KwotaSysP end
               cast((BZd_Kierunek * brk_kwota * VaN_RazemBruttoDoVAT/VaN_RazemBruttoWal) as decimal(15,2))
              else
                              cast((BZd_Kierunek * brk_kwota * VaN_KursLDoVAT/VaN_KursMDoVAT) as decimal(15,2))
                            end
            end
                        else
                          case when brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID then BZd_Kierunek * BRK_KwotaSysL else BZd_Kierunek * BRK_KwotaSysP end
                        end,
         0.0))
   from
   cdn.VatNag join cdn.tranag on (TrN_VaNId = VaN_VaNId)
   left outer join cdn.BnkZdarzenia on (bzd_DokumentTyp = 1 and bzd_DokumentID = TrN_TrNId)
   left outer join cdn.BnkRozKwoty on (brk_LDokTyp = 1 AND brk_LDokID = bzd_BzDID or brk_PDokTyp = 1 AND brk_PDokID = bzd_BzDID) AND (brk_dataDok is NULL or brk_dataDok <= @dataDeklaracji)
   where
   BZd_BZdId = @BZdId
   and bzd_TerminR >= @TerminPlatnosciMin and bzd_TerminR <= @TerminPlatnosci
   and BZd_Rozliczono<>0 and BZd_Rozliczono2<>0
   and ((BZd_Rozliczono<>2 or BZd_Rozliczono2<>2) and (DATEDIFF(DAY, bzd_TerminR, @dataDeklaracji) >= @opoznienie)
     or BZd_Rozliczono=2 and BZd_Rozliczono2=2 and exists (select * from cdn.BnkRozKwoty BRK where (BRK.brk_LDokTyp = 1 AND BRK.brk_LDokID = bzd_BzDID or BRK.brk_PDokTyp = 1 AND BRK.brk_PDokID = bzd_BzDID) and DATEDIFF(DAY, bzd_TerminR, brk_dataDok) >= @opoznienie))
   group by BZd_BZdId, VaN_VaNId, VaN_Dokument, VaN_DataWys, bzd_TerminR, bzd_Termin
   if IsNull(@allowDelete, 0) <> 0
   begin
    -- usuwamy powiÄ…zane tylko poprzez VANId
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_VaNId = VaNId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    --left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is null
    and DateAdd(Day, @limit, Termin) >= @dateLimit and Termin not between @dateOd90 and @dateDo90
    and VaZ_VaZId is Null
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_VaNId = VaNId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    --left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is null
    and DateAdd(Day, @limit, Termin) < @dateLimit and Termin not between @dateOd150 and @dateDo150
    and VaZ_VaZId is Null
    -- usuniÄ™cie pozycji ktĂłre data wystawienie przekracza dwa lata i dotej pory nie byĹ‚y uwzglÄ™dnione na VATZD
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_VaNId = VaNId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    --left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is null
    and DateDiff(month, (DATEADD(year, Year(DataWys)-1899, 0 )-1), @dataZestawienia) > 24
    and VaZ_VaZId is Null
    --
    -- usuwamy powiÄ…zane poprzez BZdId
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is not null
    and DateAdd(Day, @limit, Termin) >= @dateLimit and Termin not between @dateOd90 and @dateDo90
    and VaZ_VaZId is Null
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is not null
    and DateAdd(Day, @limit, Termin) < @dateLimit and Termin not between @dateOd150 and @dateDo150
    and VaZ_VaZId is Null
    -- usuniÄ™cie pozycji ktĂłre data wystawienie przekracza dwa lata i dotej pory nie byĹ‚y uwzglÄ™dnione na VATZD
    delete r
    from @Result r
    left outer join cdn.VATZD on (VaZ_BZdId = BZdId) left outer join cdn.deklnag on (DkN_DkNId = VaZ_DkNId and DkN_DkNId <> @DknId and DkN_Finalna=1)
    where
    VaZ_BZdId is not null
    and DateDiff(month, (DATEADD(year, Year(DataWys)-1899, 0 )-1), @dataZestawienia) > 24
    and VaZ_VaZId is Null
    --
   end
   -- Rejestr VAT
   Update @Result set SumaKwotZdarzen = (
   select sum( IsNull( case when VaN_WalutaDoVat = bzd_waluta then
         case when bzd_waluta = '' then BZd_Kierunek * bzd_kwota else
          case when VaN_KursNumerDoVat = -1
           then
                        --BZd_Kierunek * BZd_KwotaSys
                        cast((BZd_Kierunek * bzd_kwota * VaN_RazemBruttoDoVAT/VaN_RazemBruttoWal) as decimal(15,2))
                      else
                        cast((BZd_Kierunek * bzd_kwota * VaN_KursLDoVAT/VaN_KursMDoVAT) as decimal(15,2))
                      end
         end
                  else
                    BZd_Kierunek * BZd_KwotaSys
                  end,
      0.0))
   From CDN.VatNag join cdn.BnkZdarzenia on (BZd_BZdId = BZdId and bzd_DokumentTyp = 2 and VaN_VaNId = VaNId and bzd_DokumentID = VaNId)
   where BZd_Rozliczono<>0 and BZd_Rozliczono2<>0 and VaN_TrnId is null and Termin = bzd_TerminR
   and bzd_TerminR >= @TerminPlatnosciMin and bzd_TerminR <= @TerminPlatnosci
   )
   where TrNId is null
   -- Handel Paragony
   Update @Result set SumaKwotZdarzen = (
   select sum(IsNull( case when VaN_WalutaDoVat = bzd_waluta then
         case when bzd_waluta = '' then BZd_Kierunek * bzd_kwota else
          case when VaN_KursNumerDoVat = -1
           then
                        --BZd_Kierunek * BZd_KwotaSys
                        cast((BZd_Kierunek * bzd_kwota * VaN_RazemBruttoDoVAT/VaN_RazemBruttoWal) as decimal(15,2))
           else
                        cast((BZd_Kierunek * bzd_kwota * VaN_KursLDoVAT/VaN_KursMDoVAT) as decimal(15,2))
                      end
         end
                  else
                    BZd_Kierunek * BZd_KwotaSys
                  end,
      0.0))
   From CDN.VatNag join cdn.tranag on (VaN_VaNId = vanid and TrN_VaNId = VaN_VaNId)
   join cdn.BnkZdarzenia on (BZd_BZdId = BZdId and bzd_DokumentTyp = 1 and bzd_DokumentID = TrN_TrNId)
   where BZd_Rozliczono<>0 and BZd_Rozliczono2<>0 and Termin = bzd_TerminR and bzd_TerminR >= @TerminPlatnosciMin and bzd_TerminR <= @TerminPlatnosci
   )
   where TrNId = -1
 end
 return
END
