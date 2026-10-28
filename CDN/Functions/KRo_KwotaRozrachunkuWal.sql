CREATE FUNCTION CDN.KRo_KwotaRozrachunkuWal(@KRoId int)
RETURNS decimal(15,2)
AS
BEGIN
 declare @Result decimal(15,2);  set @Result = NULL;
 declare @Waluta nvarchar(3)
 declare @KwotaDokWal decimal(15,2)
 declare @DoRozliczenia decimal(15,2)
 select @Waluta = IsNull(KRo_Waluta, ''), @DoRozliczenia = (KRo_KwotaDokWal - KRo_SumRozliczenWal) from cdn.KsiRozrachunki where KRo_KRoId = @KRoId
 if @Waluta = '' or @Waluta = 'PLN' or @Waluta = 'SYS'
  set @Waluta = 'SYS'
 if @Waluta <> 'SYS'
 begin
  set @Result = @DoRozliczenia
 end
 RETURN @Result
END
