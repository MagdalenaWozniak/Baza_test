CREATE Procedure [CDN].[OpeDaneOperatora] @opeId int OUTPUT, @OpeKod varchar(20) OUTPUT, @OpeNazwisko nvarchar(50) OUTPUT,@Log int OUTPUT
AS BEGIN
 BEGIN
  declare @retvalOUT varchar(20)
  declare @tempSQL NVARCHAR(MAX)
  declare @Operator nvarchar(50)
  declare @BinVar varbinary(128);
  declare @OpeLen INT;
  SET @Operator = N''
  SET @BinVar = CONTEXT_INFO()
  SET @Log = CAST (substring ( @BinVar , 1, 4) AS INT)
  if @Log = NULL
 SET @Log = 0
  SET @OpeLen = CAST (substring ( @BinVar , 5, 4) AS INT)
  if @OpeLen = NULL
 SET @OpeLen = 0
  IF @OpeLen >0
 SET @Operator = CAST ( substring ( @BinVar , 9, @OpeLen*2) AS NVARCHAR(50))
 if len(@Operator) > 0
  begin
   SET @tempSQL = 'SELECT @opeId=Ope_OpeId, @OpeKod = Ope_Kod , @OpeNazwisko = Ope_Nazwisko '+
    'from '+CDN.BazaKonfiguracyjna()+'.cdn.Operatorzy WHERE Ope_Nazwisko = @Operator'
    EXEC sp_executesql  @tempSQL, N'@Operator nvarchar(50), @opeId int OUTPUT, @OpeKod varchar(20) OUTPUT, @OpeNazwisko nvarchar(50) OUTPUT',@Operator = @Operator, @opeId=@opeId OUTPUT, @OpeKod=@OpeKod OUTPUT, @OpeNazwisko=@OpeNazwisko OUTPUT
   if @opeId IS NULL
    SET @tempSQL = 'SELECT @opeId=Ope_OpeId, @OpeKod = Ope_Kod , @OpeNazwisko = Ope_Nazwisko '+
    'from '+CDN.BazaKonfiguracyjna()+'.cdn.Operatorzy WHERE Ope_Kod = @Operator'
    EXEC sp_executesql  @tempSQL, N'@Operator nvarchar(50), @opeId int OUTPUT, @OpeKod varchar(20) OUTPUT, @OpeNazwisko nvarchar(50) OUTPUT',@Operator = @Operator, @opeId=@opeId OUTPUT, @OpeKod=@OpeKod OUTPUT, @OpeNazwisko=@OpeNazwisko OUTPUT
  end
  END
 if @opeId IS NULL SET @opeId=0
 if @OpeKod IS NULL SET @OpeKod=''
 if @OpeNazwisko IS NULL SET @OpeNazwisko=''
 if @Log = NULL SET @Log = 0
END
