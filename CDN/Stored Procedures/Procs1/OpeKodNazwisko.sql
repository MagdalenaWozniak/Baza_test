CREATE Procedure [CDN].[OpeKodNazwisko] @opeId int, @OpeKod varchar(20) OUTPUT, @OpeNazwisko nvarchar(50) OUTPUT
AS BEGIN
 IF @opeId IS NOT NULL AND @opeId <>0
 BEGIN
  declare @retvalOUT varchar(20)
  declare @tempSQL NVARCHAR(MAX)
  SET @tempSQL = 'SELECT @OpeKod = Ope_Kod , @OpeNazwisko = Ope_Nazwisko '+
      'from '+CDN.BazaKonfiguracyjna()+'.cdn.Operatorzy WHERE Ope_OpeID = @opeId'
  EXEC sp_executesql  @tempSQL, N'@opeId int, @OpeKod varchar(20) OUTPUT, @OpeNazwisko nvarchar(50) OUTPUT', @opeId=@opeId, @OpeKod=@OpeKod OUTPUT, @OpeNazwisko=@OpeNazwisko OUTPUT
 END
 if @OpeKod IS NULL SET @OpeKod=''
 if @OpeNazwisko IS NULL SET @OpeNazwisko=''
END
