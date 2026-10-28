CREATE PROCEDURE [CDN].[Med_AnulujDokument]
 @DSTrNID int ,  -- id obce dokumentu
 @StanDetalID int  -- id stanowiska
  AS
SET NOCOUNT ON
 if exists(SELECT  *
    FROM CDN.DetalTraNag
    WHERE DTrN_DSTrNId = @DSTrNID and DTrN_StanDetalID= @StanDetalID and DTrN_Anulowanie = 0)
  update CDN.DetalTraNag set DTrN_Anulowanie = 1 WHERE DTrN_DSTrNId = @DSTrNID and DTrN_StanDetalID= @StanDetalID
    else
    begin
  RAISERROR( 'Nie ma takiego dokumentu', 16, 1)
  RETURN
 end
  SET NOCOUNT OFF
