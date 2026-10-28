CREATE PROCEDURE [CDN].[PobierzCechyDlaDostawy] @TwrId INT
AS
  SET NOCOUNT ON
    declare @table table (ida int identity(1,1),deaid int, kod NVARCHAR(40), wartosctxt NVARCHAR(255),format int ,obowiazkowy int)
    declare @iloscmax int
    declare @deaid1 int,@deaid2 int,@deaid3 int,@deaid4 int,@deaid5 int,@deaid6 int,@deaid7 int,@deaid8 int,@deaid9 int,@deaid10 int
    declare @kod1 NVARCHAR(20),@kod2 NVARCHAR(20),@kod3 NVARCHAR(20),@kod4 NVARCHAR(20),@kod5 NVARCHAR(20),@kod6 NVARCHAR(20),@kod7 NVARCHAR(20),@kod8 NVARCHAR(20),@kod9 NVARCHAR(20),@kod10 NVARCHAR(20)
    declare @wartosc1 NVARCHAR(100),@wartosc2 NVARCHAR(100),@wartosc3 NVARCHAR(100),@wartosc4 NVARCHAR(100),@wartosc5 NVARCHAR(100),@wartosc6 NVARCHAR(100),@wartosc7 NVARCHAR(100),@wartosc8 NVARCHAR(100),@wartosc9 NVARCHAR(100),@wartosc10 NVARCHAR(100)
    declare @format1 int,@format2 int,@format3 int,@format4 int,@format5 int,@format6 int,@format7 int,@format8 int,@format9 int,@format10 int
    declare @obowiazkowy1 int,@obowiazkowy2 int,@obowiazkowy3 int,@obowiazkowy4 int,@obowiazkowy5 int,@obowiazkowy6 int,@obowiazkowy7 int,@obowiazkowy8 int,@obowiazkowy9 int,@obowiazkowy10 int
    select @deaid1 = 0,@deaid2 = 0,@deaid3 = 0,@deaid4 = 0,@deaid5 = 0,@deaid6 = 0,@deaid7 = 0,@deaid8 = 0,@deaid9 = 0,@deaid10 = 0
    select @kod1 = '',@kod2 = '',@kod3 = '',@kod4 = '',@kod5 = '',@kod6 = '',@kod7 = '',@kod8 = '',@kod9 = '',@kod10 = ''
    select @wartosc1 = '',@wartosc2 = '',@wartosc3 = '',@wartosc4 = '',@wartosc5 = '',@wartosc6 = '',@wartosc7 = '',@wartosc8 = '',@wartosc9 = '',@wartosc10 = ''
    select @format1 = 0,@format2 = 0,@format3 = 0,@format4 = 0,@format5 = 0,@format6 = 0,@format7 = 0,@format8 = 0,@format9 = 0,@format10 = 0
    select @obowiazkowy1 = 0,@obowiazkowy2 = 0,@obowiazkowy3 = 0,@obowiazkowy4 = 0,@obowiazkowy5 = 0,@obowiazkowy6 = 0,@obowiazkowy7 = 0,@obowiazkowy8 = 0,@obowiazkowy9 = 0,@obowiazkowy10 = 0
    select top 10 @iloscmax = count(TwA_TwAId) from cdn.twratrybuty
        where TwA_TwrId = @TwrId and TwA_CzyPrzenosicNaDostawy = 1
    insert into @table (deaid , kod , wartosctxt, format, obowiazkowy)
        select top 10 TwA_DeAId,DeA_Kod,TwA_WartoscTxt,DeA_Format, TwA_CzyObowiazkowyDostawy from cdn.twratrybuty
        join cdn.defatrybuty on TwA_DeAId = DeA_DeAId
        where TwA_TwrId = @TwrId and TwA_CzyPrzenosicNaDostawy = 1 order by twa_lp
    if @iloscmax > 0
     select @deaid1 = deaid, @kod1 = kod, @wartosc1 = wartosctxt, @format1 = format, @obowiazkowy1 = obowiazkowy  from @table where ida = 1
    if @iloscmax > 1
     select @deaid2 = deaid, @kod2 = kod, @wartosc2 = wartosctxt, @format2 = format, @obowiazkowy2 = obowiazkowy  from @table where ida = 2
    if @iloscmax > 2
     select @deaid3 = deaid, @kod3 = kod, @wartosc3 = wartosctxt, @format3 = format, @obowiazkowy3 = obowiazkowy  from @table where ida = 3
    if @iloscmax > 3
     select @deaid4 = deaid, @kod4 = kod, @wartosc4 = wartosctxt, @format4 = format, @obowiazkowy4 = obowiazkowy  from @table where ida = 4
    if @iloscmax > 4
     select @deaid5 = deaid, @kod5 = kod, @wartosc5 = wartosctxt, @format5 = format, @obowiazkowy5 = obowiazkowy  from @table where ida = 5
    if @iloscmax > 5
     select @deaid6 = deaid, @kod6 = kod, @wartosc6 = wartosctxt, @format6 = format, @obowiazkowy6 = obowiazkowy  from @table where ida = 6
    if @iloscmax > 6
     select @deaid7 = deaid, @kod7 = kod, @wartosc7 = wartosctxt, @format7 = format, @obowiazkowy7 = obowiazkowy  from @table where ida = 7
    if @iloscmax > 7
     select @deaid8 = deaid, @kod8 = kod, @wartosc8 = wartosctxt, @format8 = format, @obowiazkowy8 = obowiazkowy  from @table where ida = 8
    if @iloscmax > 8
     select @deaid9 = deaid, @kod9 = kod, @wartosc9 = wartosctxt, @format9 = format, @obowiazkowy9 = obowiazkowy  from @table where ida = 9
    if @iloscmax > 9
     select @deaid10 = deaid, @kod10 = kod, @wartosc10 = wartosctxt, @format10 = format, @obowiazkowy10 = obowiazkowy  from @table where ida = 10
  SET NOCOUNT OFF
  select @deaid1 as Cecha1_DeAId, @kod1 as Cecha1_Kod,@wartosc1 as Cecha1_Wartosc, @format1 as Cecha1_Format,@obowiazkowy1,
         @deaid2 as Cecha2_DeAId, @kod2 as Cecha2_Kod,@wartosc2 as Cecha2_Wartosc, @format2 as Cecha2_Format,@obowiazkowy2,
         @deaid3 as Cecha3_DeAId, @kod3 as Cecha3_Kod,@wartosc3 as Cecha3_Wartosc, @format3 as Cecha3_Format,@obowiazkowy3,
         @deaid4 as Cecha4_DeAId, @kod4 as Cecha4_Kod,@wartosc4 as Cecha4_Wartosc, @format4 as Cecha4_Format,@obowiazkowy4,
         @deaid5 as Cecha5_DeAId, @kod5 as Cecha5_Kod,@wartosc5 as Cecha5_Wartosc, @format5 as Cecha5_Format,@obowiazkowy5,
         @deaid6 as Cecha6_DeAId, @kod6 as Cecha6_Kod,@wartosc6 as Cecha6_Wartosc, @format6 as Cecha6_Format,@obowiazkowy6,
         @deaid7 as Cecha7_DeAId, @kod7 as Cecha7_Kod,@wartosc7 as Cecha7_Wartosc, @format7 as Cecha7_Format,@obowiazkowy7,
         @deaid8 as Cecha8_DeAId, @kod8 as Cecha8_Kod,@wartosc8 as Cecha8_Wartosc, @format8 as Cecha8_Format,@obowiazkowy8,
         @deaid9 as Cecha9_DeAId, @kod9 as Cecha9_Kod,@wartosc9 as Cecha9_Wartosc, @format9 as Cecha9_Format,@obowiazkowy9,
         @deaid10 as Cecha10_DeAId, @kod10 as Cecha10_Kod,@wartosc10 as Cecha10_Wartosc, @format10 as Cecha10_Format,@obowiazkowy10
