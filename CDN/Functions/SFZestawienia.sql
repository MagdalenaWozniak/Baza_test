CREATE FUNCTION CDN.SFZestawienia()
RETURNS @Result TABLE(  id int, kod nvarchar(50),nazwa nvarchar(255))
AS
BEGIN
  insert into @Result (id, kod, nazwa) values(-1, '', '')
  insert into @Result (id, kod, nazwa) values(0, 'Bilans', 'Bilans')
  insert into @Result (id, kod, nazwa) values(1, 'RZiSKalk', 'Rachunek zysków i strat – kalkulacyjny')
  insert into @Result (id, kod, nazwa) values(2, 'RZiSPor', 'Rachunek zysków i strat – porównawczy')
  insert into @Result (id, kod, nazwa) values(3, 'ZestZmianWKapitale', 'Zmiany w kapitale')
  insert into @Result (id, kod, nazwa) values(4, 'PrzeplywyBezp', 'Przepływy pieniężne – metoda bezpośrednia')
  insert into @Result (id, kod, nazwa) values(5, 'PrzeplywyPosr', 'Przepływy pieniężne – metoda pośrednia')
  insert into @Result (id, kod, nazwa) values(6, 'RZiS', 'Rachunek zysków i strat')
 RETURN
END
