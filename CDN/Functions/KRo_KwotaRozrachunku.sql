CREATE FUNCTION CDN.KRo_KwotaRozrachunku( @DokTyp   int,
               @DokID   int,
            @DokStrona int,
                                                @Waluta     NVARCHAR(3) = NULL)
RETURNS decimal(15,2)
AS
BEGIN
 declare @KwotaRozrachunku decimal(15,2)
 set @KwotaRozrachunku = 0.00
 if @DokTyp = 1 -- dekret
 begin
        if @Waluta is NULL      -- podajemy kwoty w walucie dekretów
        begin
      select @KwotaRozrachunku = sum(IsNull(case when (KRo_Waluta is NULL or KRo_Waluta ='') then KRo_Kwota else KRo_KwotaWal end, 0.00)) from CDN.KsiRozrachunki
      where KRo_DeEId = @DokID and KRo_Strona = @DokStrona
        end
        else
        if @Waluta = 'SYS'      -- podajemy wartość w walucie systemowej
        begin
      select @KwotaRozrachunku = sum(IsNull(KRo_Kwota, 0.00)) from CDN.KsiRozrachunki
      where KRo_DeEId = @DokID and KRo_Strona = @DokStrona
        end
        else
        begin                   -- podajemy wartość w zadanej walucie
      select @KwotaRozrachunku = sum(IsNull(KRo_KwotaWal, 0.00)) from CDN.KsiRozrachunki
      where KRo_DeEId = @DokID and KRo_Strona = @DokStrona
        end
 end
 else
 if @DokTyp = 2 -- bilans
 begin
        if @Waluta is NULL      -- podajemy kwoty w walucie dekretów
        begin
      select @KwotaRozrachunku = sum(IsNull(case when (KRo_Waluta is NULL or KRo_Waluta ='') then KRo_Kwota else KRo_KwotaWal end, 0.00)) from CDN.KsiRozrachunki
      where KRo_BOEId = @DokID and KRo_Strona = @DokStrona
        end
        else
        if @Waluta = 'SYS'      -- podajemy wartość w walucie systemowej
        begin
      select @KwotaRozrachunku = sum(IsNull(KRo_Kwota, 0.00)) from CDN.KsiRozrachunki
      where KRo_BOEId = @DokID and KRo_Strona = @DokStrona
        end
        else                    -- podajemy wartość w zadanej walucie
        begin
            select @KwotaRozrachunku = sum(IsNull(KRo_KwotaWal, 0.00)) from CDN.KsiRozrachunki
            where KRo_BOEId = @DokID and KRo_Strona = @DokStrona
        end
 end
  RETURN @KwotaRozrachunku
END
