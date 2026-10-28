CREATE FUNCTION [CDN].[Mobile_EksportKntZal]
(@KNTID           INT,@Date DateTime)
RETURNS DECIMAL(18,2)
AS
BEGIN
declare @Wartosc DECIMAL(18,2)
SELECT @Wartosc  = Sum(Bzd_KwotaSys-Bzd_KwotaRozSys) From cdn.BnkZdarzenia Where BzD_Kierunek=1 And Bzd_Rozliczono=1
And BzD_PodmiotTyp=1
And BzD_PodmiotId=@KNTID
And BzD_DataReal< @Date
RETURN @Wartosc
END
