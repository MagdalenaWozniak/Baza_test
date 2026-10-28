create function cdn.GetXLOperatorID()
returns int
 as
 begin
  return (select Fir_Wartosc from cdn.Firma where Fir_Numer = 2204)
 end
