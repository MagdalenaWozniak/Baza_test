CREATE FUNCTION cdn.AtrybutDateTimeValue(@clarionDateTime INT)
RETURNS NVARCHAR(10)
AS
BEGIN
 IF( @clarionDateTime is NULL OR @clarionDateTime = 0 OR @clarionDateTime = 36161)
  RETURN ''
 RETURN Convert(NVARCHAR(10),cdn.FromClarionDate(@clarionDateTime), 120)
END
