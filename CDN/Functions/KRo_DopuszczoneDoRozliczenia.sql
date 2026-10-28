CREATE FUNCTION CDN.KRo_DopuszczoneDoRozliczenia(@DokKRoId int, @RozKRoId int)
RETURNS int
AS
BEGIN
 declare @Result int;  set @Result = 1;
 declare @Waluta nvarchar(3);
 declare @WalutaRo nvarchar(3);
 declare @KwotaDokumentuWal decimal(15,2);
 declare @KwotaRoDokumentuWal decimal(15,2);
 declare @KwotaPozostaloWal decimal(15,2);
 declare @KwotaRoPozostaloWal decimal(15,2);
 select @Waluta    = KRo_Waluta,
   @KwotaDokumentuWal = KRo_KwotaDokWal,
   @KwotaPozostaloWal = KRo_KwotaDokWal - KRo_SumRozliczenWal
 from cdn.KsiRozrachunki where KRo_KRoId = @DokKRoId
 select @WalutaRo    = KRo_Waluta,
   @KwotaRoDokumentuWal = KRo_KwotaDokWal,
   @KwotaRoPozostaloWal = KRo_KwotaDokWal - KRo_SumRozliczenWal
 from cdn.KsiRozrachunki where KRo_KRoId = @RozKRoId
 if len(IsNull(@Waluta, '')) = 0 set @WalutaRo = NULL
    if len(IsNull(@WalutaRo, '')) = 0 set @WalutaRo = NULL
 if @Waluta is not NULL and @KwotaDokumentuWal <> 0.00 and @KwotaPozostaloWal <= 0.00 and @WalutaRo is not NULL and (@KwotaRoDokumentuWal <> 0.00 or @KwotaRoPozostaloWal <> 0.00)
  set @Result = 0;
 if @WalutaRo is not NULL and @KwotaRoDokumentuWal <> 0.00 and @KwotaRoPozostaloWal <= 0.00 and @Waluta is not NULL and (@KwotaDokumentuWal <> 0.00 or @KwotaPozostaloWal <> 0.00)
  set @Result = 0;
 RETURN @Result
END
