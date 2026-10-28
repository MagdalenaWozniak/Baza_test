create procedure cdn.RozliczenieFPPRDlaFRR
-- Faktura RR rozliczenie wpłat na fundusz promocji produkcji rolnej.
@FaID NVARCHAR(100),
@Tryb smallint
AS
Set NoCount on
if not exists (select * from tempdb.dbo.sysobjects where name like '##Tabla_Funduszy_Stawek_SWW' and xtype='U')
begin
create table ##Tabla_Funduszy_Stawek_SWW
(
Fundusz_Id int,
Fundusz_Nazwa NVARCHAR(200),
TwrSWW NVARCHAR(20),
wspolczynnik decimal( 15,4 ),
metoda smallint
)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Wieprzowego', N'01.46.10.0', CAST(0.001 AS Decimal(18, 4)), 1 ,1)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Wołowego', N'01.41.10.0', CAST(0.001 AS Decimal(18, 4)), 1,2)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Wołowego', N'01.42.11.0', CAST(0.001 AS Decimal(18, 4)), 1,2)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Wołowego', N'01.42.12.0', CAST(0.001 AS Decimal(18, 4)), 1,2)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Końskiego', N'01.43.10.0', CAST(0.001 AS Decimal(18, 4)), 1,3)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Owczego', N'01.45.11.0', CAST(0.001 AS Decimal(18, 4)), 1,4)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ziarna Zbóż i Przetworów Zbożowych', N'01.11.11.0', CAST(0.001 AS Decimal(18, 4)), 1,5)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ziarna Zbóż i Przetworów Zbożowych', N'01.11.12.0', CAST(0.001 AS Decimal(18, 4)), 1,5)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ziarna Zbóż i Przetworów Zbożowych', N'01.11.20.0', CAST(0.001 AS Decimal(18, 4)), 1,5)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ziarna Zbóż i Przetworów Zbożowych', N'01.11.31.0', CAST(0.001 AS Decimal(18, 4)), 1,5)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ziarna Zbóż i Przetworów Zbożowych', N'01.11.32.0', CAST(0.001 AS Decimal(18, 4)), 1,5)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ziarna Zbóż i Przetworów Zbożowych', N'01.11.33.0', CAST(0.001 AS Decimal(18, 4)), 1,5)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ziarna Zbóż i Przetworów Zbożowych', N'01.11.49.0', CAST(0.001 AS Decimal(18, 4)), 1,5)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.11.61.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.11.62.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.11.71.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.11.72.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.11.73.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.11.74.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.11.75.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.12.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.13.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.14.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.15.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.16.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.19.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.31.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.32.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.33.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.34.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.39.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.41.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.42.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.43.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.44.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.49.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.51.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.80.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.13.90.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.21.11.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.21.12.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.24.10.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.24.21.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.24.22.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.24.23.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.24.24.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.24.25.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.24.26.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.24.27.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.24.28.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.24.29.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.25.12.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.25.13.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.25.19.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Owoców i Warzyw', N'01.25.90.0', CAST(0.001 AS Decimal(18, 4)), 1,6)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Drobiowego', N'01.47.11.0', CAST(0.001 AS Decimal(18, 4)), 1,7)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Drobiowego', N'01.47.12.0', CAST(0.001 AS Decimal(18, 4)), 1,7)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Drobiowego', N'01.47.13.0', CAST(0.001 AS Decimal(18, 4)), 1,7)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Drobiowego', N'01.47.14.0', CAST(0.001 AS Decimal(18, 4)), 1,7)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Drobiowego', N'01.49.12.1', CAST(0.001 AS Decimal(18, 4)), 1,7)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mięsa Drobiowego', N'01.49.12.9', CAST(0.001 AS Decimal(18, 4)), 1,7)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ryb', N'03.00.12.0', CAST(0.001 AS Decimal(18, 4)), 1,8)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ryb', N'03.00.13.0', CAST(0.001 AS Decimal(18, 4)), 1,8)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ryb', N'03.00.14.0', CAST(0.001 AS Decimal(18, 4)), 1,8)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ryb', N'03.00.15.0', CAST(0.001 AS Decimal(18, 4)), 1,8)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ryb', N'03.00.21.0', CAST(0.001 AS Decimal(18, 4)), 1,8)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ryb', N'03.00.22.0', CAST(0.001 AS Decimal(18, 4)), 1,8)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ryb', N'03.00.23.0', CAST(0.001 AS Decimal(18, 4)), 1,8)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Ryb', N'03.00.24.0', CAST(0.001 AS Decimal(18, 4)), 1,8)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mleka', N'01.41.20.0', CAST(0.0010 AS Decimal(18, 4)), 2,9)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mleka', N'01.45.21.0', CAST(0.0010 AS Decimal(18, 4)), 2,9)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mleka', N'01.45.22.0', CAST(0.0010 AS Decimal(18, 4)), 2,9)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Mleka', N'01.49.22.0', CAST(0.0010 AS Decimal(18, 4)), 2,9)
     INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Roślin Oleistych', N'01.11.93.0', CAST(0.002 AS Decimal(18, 4)), 1,10)
                 INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Roślin Oleistych', N'01.11.81.0', CAST(0.002 AS Decimal(18, 4)), 1,10)
                 INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Roślin Oleistych', N'01.11.91.0', CAST(0.002 AS Decimal(18, 4)), 1,10)
                 INSERT ##Tabla_Funduszy_Stawek_SWW (Fundusz_Nazwa, TwrSWW, wspolczynnik, metoda , Fundusz_Id ) VALUES (N'Fundusz Promocji Roślin Oleistych', N'01.16.19.0', CAST(0.002 AS Decimal(18, 4)), 1,10)
end
if @Tryb=0
begin
  select
  Fundusz_Nazwa as FunduszNazwa,
   case when metoda = 1 then
  -- Od Netto
    round ( sum (TrE_WartoscNetto) , 0 )
  else
  -- Od Kilograma
   sum (TrE_Ilosc ) end as FunduszWartosc,
  convert( decimal( 18,2 ) ,round(
  case when metoda = 1 then
  -- Od Netto
   round ( sum (TrE_WartoscNetto ), 0) * wspolczynnik
  else
  -- Od Kilograma
   sum (TrE_Ilosc )* wspolczynnik
  end ,0)) as FunduszWartoscSkladki
  , Fundusz_Id
  from cdn.TraElem join ##Tabla_Funduszy_Stawek_SWW on TwrSWW = TrE_TwrSWW
  where tre_trnId = convert( int ,  @FaId )
  group by Fundusz_Nazwa, Fundusz_Id , wspolczynnik ,metoda
end
if @Tryb=1
begin
create table #A ( a int )
insert #A values(1)
select elem.FunduszNazwa,  sum(FunduszWartosc) as FunduszWartosc, sum(FunduszWartoscSkladki) as FunduszWartoscSkladki , elem.Fundusz_Id from #A cross join
(
select
  Fundusz_Nazwa as FunduszNazwa,
   case when metoda = 1 then
  -- Od Netto
    round ( sum (TrE_WartoscNetto) ,0 )
  else
  -- Od Kilograma
   sum (TrE_Ilosc ) end as FunduszWartosc,
  convert( decimal( 18,2 ) ,round(
  case when metoda = 1 then
  -- Od Netto
   round( sum (TrE_WartoscNetto ), 0) * wspolczynnik
  else
  -- Od Kilograma
   sum (TrE_Ilosc )* wspolczynnik
  end ,0)) as FunduszWartoscSkladki
  , Fundusz_Id
  from cdn.TraElem join ##Tabla_Funduszy_Stawek_SWW on TwrSWW = TrE_TwrSWW
  join cdn.RptZaznaczenia2 on RpZ2_GIDNumer = tre_trnId
                join cdn.TraNag on trn_trnId = tre_trnID
  where RpZ2_GUID  = @FaId and trn_Bufor <> -1
  group by tre_trnId,Fundusz_Nazwa, Fundusz_Id , wspolczynnik ,metoda
) as elem
group by a,elem.FunduszNazwa, elem.Fundusz_Id
end
drop table ##Tabla_Funduszy_Stawek_SWW
