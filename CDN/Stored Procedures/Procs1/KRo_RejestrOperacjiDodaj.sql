CREATE   PROCEDURE CDN.KRo_RejestrOperacjiDodaj
@DokumentId  int,
@DokumentTyp int,
@TypOperacji int,
@KRoId        int
AS
begin
 declare @objectType int = 0;
 declare @numer varchar(256);
 declare @naglowekId int = 0;
 if IsNUll(@KRoId, 0) = 0
 begin
    if @DokumentTyp = 1
    begin
      set @objectType = 1006;
      select top 1 @numer = KRo_Dokument from CDN.KsiRozrachunki where KRo_DeEId = @DokumentId;
      select @naglowekId = DeE_DeNId from cdn.DekretyElem where DeE_DeEId = @DokumentId;
    end
    else
    begin
      set @objectType = 500;
      select top 1 @numer = KRo_Dokument from CDN.KsiRozrachunki where KRo_BoEId = @DokumentId;
      select @naglowekId = BoE_BoNId from cdn.BOElem where BoE_BoEId = @DokumentId;
    end
  end
  else
  begin
    select
    @DokumentId = IsNUll(KRo_DeEId, KRo_BoEId),
    @objectType = case when KRo_DeEId is not Null then 1006 else 500 end,
    @numer = KRo_Dokument
    from CDN.KsiRozrachunki where KRo_KRoId = @KRoId;
    if @objectType = 1006
      select @naglowekId = DeE_DeNId from cdn.DekretyElem where DeE_DeEId = @DokumentId;
    else
      select @naglowekId = BoE_BoNId from cdn.BOElem where BoE_BoEId = @DokumentId;
  end
 EXEC [CDN].[RejestrOperacjiDodaj]
          @ObiektTyp  = @objectType,
          @ObiektSubTyp = 0,
          @ObiektID  = @naglowekId,
          @ObiektNazwa = @numer,
          @OperacjaTyp = @TypOperacji,
          @Opis   = ''
end
