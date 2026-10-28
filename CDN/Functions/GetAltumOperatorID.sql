create function cdn.GetAltumOperatorID()
returns int
 as
 begin
  return (select Fir_Wartosc from cdn.Firma where Fir_Numer = 2202)
 end
