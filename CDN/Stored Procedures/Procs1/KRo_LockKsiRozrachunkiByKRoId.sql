CREATE   PROCEDURE CDN.KRo_LockKsiRozrachunkiByKRoId
@KRoID  int
AS
 if @KRoID is Not Null
 begin
  SET NOCOUNT ON
  declare @docDeEId int
  declare @docBoEId int
  declare @rozDeEId int
  declare @rozBoEId int
  select @docDeEId = doc.KRo_DeEId, @docBoEId = doc.KRo_BOEId,
    @rozDeEId = roz.KRo_DeEId, @rozBoEId = roz.KRo_BOEId
  from cdn.KsiRozrachunki doc left outer join CDN.KsiRozrachunki roz on (doc.KRo_KRoId = Roz.KRo_RozliczenieId)
  where doc.KRo_KRoId = @KRoID
  if (@docDeEId Is Not NULL)
  begin
   if exists(SELECT * FROM CDN.KsiRozrachunki WITH (UPDLOCK) where KRo_DeEId = @docDeEId)
   begin
    set @docDeEId = @docDeEId
   end
  end
  if (@docBoEId Is Not NULL)
  begin
   if exists(SELECT * FROM CDN.KsiRozrachunki WITH (UPDLOCK) where KRo_BOEId = @docBoEId)
   begin
    set @docBoEId = @docBoEId
   end
  end
  if (@rozDeEId Is Not NULL and @docDeEId <> @rozDeEId)
  begin
   if exists(SELECT * FROM CDN.KsiRozrachunki WITH (UPDLOCK) where KRo_DeEId = @rozDeEId)
   begin
    set @rozDeEId = @rozDeEId
   end
  end
  if (@rozBoEId Is Not NULL and @docBoEId <> @rozBoEId)
  begin
   if exists(SELECT * FROM CDN.KsiRozrachunki WITH (UPDLOCK) where KRo_BOEId = @rozBoEId)
   begin
    set @rozBoEId = @rozBoEId
   end
  end
  SET NOCOUNT OFF
 end
