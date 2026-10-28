CREATE  FUNCTION CDN.NieobName()
RETURNS NVARCHAR(400)
AS
BEGIN
declare @nameNieob as NVARCHAR(400)
declare @namePom as NVARCHAR(40)
declare @IdNieob as Int
SET @nameNieob =  ''
SET @IdNieob = 13
WHILE @IdNieob < 21
  BEGIN
   select @namePom =  tnk_nazwa from CDN.TypNieobecKartaPracy where  tnk_tnkid =  @IdNieob
   SET @nameNieob =  @namePom +'--'+@nameNieob
   SET @IdNieob = @IdNieob + 1
  END
Return @nameNieob
END
