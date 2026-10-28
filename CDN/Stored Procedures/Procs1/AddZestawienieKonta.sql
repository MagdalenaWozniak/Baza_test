CREATE PROCEDURE CDN.AddZestawienieKonta
@OkresObrachunkowyId int,
@ZestawienieId int,
@PozycjaId int,
@KontoNumerIdx nvarchar(50),
@Funkcja nvarchar(50)
AS
BEGIN
 SET NOCOUNT ON
 declare @accId int; select @accId = Acc_AccId from CDN.Konta where Acc_OObId = @OkresObrachunkowyId and Acc_NumerIdx = @KontoNumerIdx;
 declare @kontoId int = @accId;
 if IsNull(@accId, 0) = 0
 begin
  SET NOCOUNT OFF;
  return;
 end
 -- dodanie nowych
 declare @FunkcjaNorma NVARCHAR(50) = Upper(@Funkcja);
 Declare kontaAnalityczneCursor Cursor Local Fast_Forward For
 Select Anl_AccId From CDN.KontaAnalityczne (@accId, 1);
 Open kontaAnalityczneCursor
 While 1=1
 Begin
  Fetch Next From kontaAnalityczneCursor InTo @kontoId
  If @@Fetch_Status<> 0 Break
  if not exists(select * from CDN.ZestawieniaKonta where ZKa_AccId = @kontoId and ZKa_OObId = @OkresObrachunkowyId and ZKa_ZKNId = @ZestawienieId
  and ZKa_ZKPId = @PozycjaId and ZKa_FunkcjaNorma = @FunkcjaNorma)
  begin
   insert into CDN.ZestawieniaKonta (ZKa_OObId,ZKa_ZKNId,ZKa_ZKPId,ZKa_AccId,ZKa_Funkcja,ZKa_FunkcjaNorma)
   values(@OkresObrachunkowyId, @ZestawienieId, @PozycjaId, @kontoId, @Funkcja, @FunkcjaNorma);
  end
 End
 Close kontaAnalityczneCursor
 Deallocate kontaAnalityczneCursor
 SET NOCOUNT OFF
 return;
END
