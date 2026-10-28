create function cdn.GetEOperatorID ()
returns int
 as
 begin
  return (select isnull(Fir_Wartosc, 1) from cdn.Firma where Fir_Numer = 2185)
 end
