CREATE FUNCTION CDN.SFJednostki()
RETURNS @Result TABLE(  id int, kod nvarchar(50), nazwa nvarchar(50))
AS
BEGIN
 insert into @Result (id, kod, nazwa) values(-1, '', '')
 insert into @Result (id, kod, nazwa) values(0, 'Inna', 'Jednostka duża')
 insert into @Result (id, kod, nazwa) values(1, 'Mała', 'Jednostka mała')
 insert into @Result (id, kod, nazwa) values(2, 'Mikro', 'Jednostka mikro')
 --insert into @Result (id, kod, nazwa) values(3, 'Skonsolidowane', 'Skonsolidowane')
 --insert into @Result (id, kod, nazwa) values(4, 'OP', 'Jednostka OP')
 RETURN
END
