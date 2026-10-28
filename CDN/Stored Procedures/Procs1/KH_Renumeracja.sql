CREATE procedure CDN.KH_Renumeracja
 @OkresObrachunkowyId int
As
 SET NOCOUNT ON
 UPDATE CDN.DekretyNag SET DeN_NrDziennika = 0, DeN_NrKsiegi = 0 WHERE DeN_Typ=2 and DeN_Bufor = 1 and DeN_OObId = @OkresObrachunkowyId;
 Declare @errorBuffer int = @@error;
 if @errorBuffer = 0
 begin
  Declare @deNId int = 0;
  Declare @numer nvarchar(255);
  Declare ZrenumerowaneDekrety Cursor Local Fast_Forward For
  Select DeN_DeNId, DeN_Dokument from CDN.DekretyNag where  DeN_Typ=2 and DeN_Bufor = 1 and DeN_OObId = @OkresObrachunkowyId;
  Open ZrenumerowaneDekrety
  While 1=1
  Begin
   Fetch Next From ZrenumerowaneDekrety InTo @deNId, @numer;
   If @@Fetch_Status <> 0 Break
   exec [CDN].[RejestrOperacjiDodaj] @ObiektTyp = 1006, @ObiektSubTyp = 0, @ObiektID = @deNId, @ObiektNazwa = @numer, @OperacjaTyp = 2, @Opis = ''
  End
  Close ZrenumerowaneDekrety
  Deallocate ZrenumerowaneDekrety
 end
 SET NOCOUNT OFF;
 SELECT @errorBuffer;
