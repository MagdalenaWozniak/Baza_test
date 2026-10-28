CREATE FUNCTION CDN.KontoWymiaruAnalitycznego(@WyWId int, @strona int, @Value nvarchar(1024))
RETURNS nvarchar(255)
AS
BEGIN
 --declare @Result nvarchar(255) = @Value;
 declare @Result nvarchar(255) = null;
 Declare @tWymiar int = 1;
 Declare @tPodwymiar int = 2;
 Declare @tOpis int = 3;
 Declare @twOpis int = 1;
 Declare @twKategoria int = 2;
 Declare @twPlanKont int = 3;
 Declare @twSlownik int = 4;
 declare @WyyId int = 0;
 declare @Typ int = 0;
 declare @TypWymiaru int = 0;
 declare @SlownikTyp int = 0;
 if @Value is not null
 begin
  select @WyyId = WyW_WyyId from CDN.WymiaryWartosci where WyW_WyWId = @WyWId and CHARINDEX(@Value, WyW_Wartosc)=1;
  if IsNUll(@WyyId, 0)=0
   return @Result;
 end
 select @WyyId = WyW_WyyId from CDN.WymiaryWartosci where WyW_WyWId = @WyWId;
 select @Typ =Wyy_Typ, @TypWymiaru = Wyy_TypWymiaru, @SlownikTyp = Wyy_SlownikTyp from CDN.Wymiary where Wyy_WyyID = @WyyId;
 -- wymiar opisowy, element
 if @Typ = @tOpis and @TypWymiaru = @twOpis
  select @Result = Wyy_KontoNumer from CDN.Wymiary where Wyy_WyyID = @WyyId;
 -- wymiar, konto
 else if @TypWymiaru = @twPlanKont
  select @Result = Acc_Numer from CDN.WymiaryWartosci join CDN.Wymiary on (WyW_WyyId = Wyy_WyyID) join cdn.Konta on (Wyy_TypWymiaru=@TypWymiaru and WyW_SlownikId = Acc_AccID) where WyW_WyWId = @WyWId;
 -- wymiar, kategoria, strona Wn
 else if @TypWymiaru = @twKategoria and @strona = 1
    select @Result = Kat_KontoSegmentWn from CDN.WymiaryWartosci join CDN.Wymiary on (WyW_WyyId = Wyy_WyyID) join cdn.Kategorie on (Wyy_TypWymiaru=@TypWymiaru and WyW_SlownikId = Kat_KatID) where WyW_WyWId = @WyWId;
 -- wymiar, kategoria, strona Ma
 else if @TypWymiaru = @twKategoria and @strona = 2
    select @Result = Kat_KontoSegmentMa from CDN.WymiaryWartosci join CDN.Wymiary on (WyW_WyyId = Wyy_WyyID) join cdn.Kategorie on (Wyy_TypWymiaru=@TypWymiaru and WyW_SlownikId = Kat_KatID) where WyW_WyWId = @WyWId;
 -- wymiar, słownik, strona Wn
 else if @TypWymiaru = @twSlownik and @strona = 1
 begin
  if @SlownikTyp = 3
   select @Result = Pod_KontoOdb from CDN.WymiaryWartosci join CDN.Wymiary on (WyW_WyyId = Wyy_WyyID) join cdn.PodmiotyView on (Pod_PodmiotTyp = 3 and Pod_Rodzaj = -3 and WyW_SlownikId = Pod_PodId) where WyW_WyWId = @WyWId;
  else if @SlownikTyp = 4
   select @Result = Pod_KontoOdb from CDN.WymiaryWartosci join CDN.Wymiary on (WyW_WyyId = Wyy_WyyID) join cdn.PodmiotyView on (Pod_PodmiotTyp = 3 and Pod_Rodzaj = -4 and WyW_SlownikId = Pod_PodId) where WyW_WyWId = @WyWId;
  else
   select @Result = Pod_KontoOdb from CDN.WymiaryWartosci join CDN.Wymiary on (WyW_WyyId = Wyy_WyyID) join cdn.PodmiotyView on (Wyy_SlownikTyp=Pod_PodmiotTyp and WyW_SlownikId = Pod_PodId) where WyW_WyWId = @WyWId;
 end
 -- wymiar, słownik, strona Ma
 else if @TypWymiaru = @twSlownik and @strona = 2
 begin
  if @SlownikTyp = 3
   select @Result = Pod_KontoDost from CDN.WymiaryWartosci join CDN.Wymiary on (WyW_WyyId = Wyy_WyyID) join cdn.PodmiotyView on (Pod_PodmiotTyp = 3 and Pod_Rodzaj = -3 and WyW_SlownikId = Pod_PodId) where WyW_WyWId = @WyWId;
  else if @SlownikTyp = 4
   select @Result = Pod_KontoDost from CDN.WymiaryWartosci join CDN.Wymiary on (WyW_WyyId = Wyy_WyyID) join cdn.PodmiotyView on (Pod_PodmiotTyp = 3 and Pod_Rodzaj = -4 and WyW_SlownikId = Pod_PodId) where WyW_WyWId = @WyWId;
  else
   select @Result = Pod_KontoDost from CDN.WymiaryWartosci join CDN.Wymiary on (WyW_WyyId = Wyy_WyyID) join cdn.PodmiotyView on (Wyy_SlownikTyp=Pod_PodmiotTyp and WyW_SlownikId = Pod_PodId) where WyW_WyWId = @WyWId;
 end
 return @Result
END
