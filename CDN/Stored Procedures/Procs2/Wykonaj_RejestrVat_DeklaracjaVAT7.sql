CREATE procedure CDN.Wykonaj_RejestrVat_DeklaracjaVAT7
@filtrDeklaracje_Rok INT,
@filtrDeklaracje_Miesiac INT,
@filtrDeklaracje_Nieokreslony INT,
@RejestrTyp INT,
@Deklaracje_CalyKwartal INT,
@FiltrApp NVARCHAR(255)
As
Declare @stmt NVarChar(2550)
Set @stmt = 'Select * from  CDN.RejestrVat_DeklaracjaVAT7('+cast(@filtrDeklaracje_Rok as varchar(10))+','+cast(@filtrDeklaracje_Miesiac as varchar(10))+','
+cast(@filtrDeklaracje_Nieokreslony as varchar(10))+','+cast(@RejestrTyp as varchar(10))+','+cast(@Deklaracje_CalyKwartal as varchar(10))+') where ' + @FiltrApp
Execute dbo.sp_executesql @stmt
