CREATE procedure CDN.KH_DoBufora
 @DocumentType int,  -- {1, 2, 3}, 1 - BO, 2 - Dekret
 @DocumentId int
As
 SET NOCOUNT ON
 declare @numer nvarchar(255);
 if @DocumentType = 1
 begin
  select @numer = BON_NumerPelny from CDN.BONag where BON_BONId = @DocumentId;
  UPDATE CDN.BONag SET BON_Bufor = 1 WHERE BON_BONId = @DocumentId;
  exec [CDN].[RejestrOperacjiDodaj] @ObiektTyp = 500, @ObiektSubTyp = 0, @ObiektID = @DocumentId, @ObiektNazwa = @numer, @OperacjaTyp = 124, @Opis = ''
  --OptimaOperationType_Dezaktywacja
 end
 else if @DocumentType = 2
 begin
  select @numer = DeN_Dokument from CDN.DekretyNag where DeN_DeNId = @DocumentId;
  update CDN.DekretyNag set DeN_Bufor = 1 where DeN_DeNID = @DocumentId;
  exec [CDN].[RejestrOperacjiDodaj] @ObiektTyp = 1006, @ObiektSubTyp = 0, @ObiektID = @DocumentId, @ObiektNazwa = @numer, @OperacjaTyp = 124, @Opis = ''
  --OptimaOperationType_Dezaktywacja
 end
 else if @DocumentType = 3
 begin
  select @numer = PWN_Numer from CDN.PrzeszacWalutNag where PWN_PWNId = @DocumentId;
  update CDN.PrzeszacWalutNag set PWN_Bufor = 1 where PWN_PWNId = @DocumentId;
  exec [CDN].[RejestrOperacjiDodaj] @ObiektTyp = 1038, @ObiektSubTyp = 0, @ObiektID = @DocumentId, @ObiektNazwa = @numer, @OperacjaTyp = 124, @Opis = ''
  --OptimaOperationType_Dezaktywacja
 end
 SET NOCOUNT OFF
