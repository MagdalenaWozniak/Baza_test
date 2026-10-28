CREATE   PROCEDURE CDN.KRo_KasujRozliczenia
@DokTyp  int,
@DokID  int,
@OObId  int,
@UsuwanieRoznicKursowych int
AS
    SET NOCOUNT ON
    declare @KRoID int
 declare @DeEID int
 BEGIN TRANSACTION
 if @DokTyp = 1  -- dekrety
 begin
                Declare RozrachunkiKRoID Cursor Local Fast_Forward For
    Select KRo_KRoID, KRo_DeEId
          from
          CDN.DekretyElem
          inner join CDN.KsiRozrachunki on (KRo_DeEID = DeE_DeEID)
          where
          DeE_DeNID = @DokID and DeE_Rozrachunki = 1
    Open RozrachunkiKRoID
    While 1=1
    Begin
      Fetch Next From RozrachunkiKRoID InTo @KRoID, @DeEID
      If @@Fetch_Status <> 0 Break
                        execute CDN.KRo_KasujRozliczenie @KRoID, @OObId, @UsuwanieRoznicKursowych
      --execute CDN.KRo_AktualizujStatusRozrachunku 1, @DeEID
    End
    Close RozrachunkiKRoID
    Deallocate RozrachunkiKRoID
 end
 else
 if @DokTyp = 2  -- bilanse
 begin
                Declare RozrachunkiKRoID Cursor Local Fast_Forward For
    Select KRo_KRoID
          from
          CDN.BOElem
          inner join CDN.KsiRozrachunki on (KRo_BOEID = BOE_BOEID)
          where
          BOE_BONID = @DokID and BOE_Rozrachunki = 1
    Open RozrachunkiKRoID
    While 1=1
    Begin
      Fetch Next From RozrachunkiKRoID InTo @KRoID
      If @@Fetch_Status <> 0 Break
                        execute CDN.KRo_KasujRozliczenie @KRoID, @OObId, @UsuwanieRoznicKursowych
    End
    Close RozrachunkiKRoID
    Deallocate RozrachunkiKRoID
 end
 if @@TranCount<>0 COMMIT
  SET NOCOUNT OFF
