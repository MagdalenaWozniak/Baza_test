CREATE FUNCTION CDN.KursyRozliczeniaDelegacji()
RETURNS @Result TABLE(id int, nazwa nvarchar(32) )
AS
BEGIN
 insert into @result (id, nazwa) values(1, 'Data zaliczki');
 insert into @result (id, nazwa) values(2, 'Data rozliczenia delegacji');
 insert into @result (id, nazwa) values(3, 'Data zakończenia delegacji');
 insert into @result (id, nazwa) values(4, 'Inna');
 return
END
