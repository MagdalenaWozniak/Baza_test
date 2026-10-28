CREATE PROCEDURE CDN.DetalStan_SprawdzCzyWyslanyDoCentrali
@StanDetalID INT,      -- ID Detalu
@DSTrNID INT
AS
BEGIN
SET NOCOUNT ON
declare
@OptimaID INT,
@PracaRozproszona int,
@OFFPrawoDoAnulowania tinyint,
@OFFPrawoDoFAPA tinyint
select @PracaRozproszona = CONVERT(int, Fir_Wartosc) from cdn.Firma where Fir_Numer = 1470
if (@PracaRozproszona <> 4)
 select 0
IF NOT EXISTS (select dtrn_dtrnid from cdn.detaltranag where dtrn_StanDetalID = @StanDetalID and dtrn_DSTrNID = @DSTrNID and ISNULL(dtrn_optimaID,0) > 0)
 select 0
else
begin
  select @OptimaID = dtrn_optimaID from cdn.detaltranag where dtrn_StanDetalID = @StanDetalID and dtrn_DSTrNID = @DSTrNID
  if (@OptimaID is null)
 select 0
  else
  begin
 select @OFFPrawoDoAnulowania = ISNULL(TrN_OFFPrawoDoAnulowania,0), @OFFPrawoDoFAPA = ISNULL(TrN_OFFPrawoDoFAPA,0)
 from cdn.TraNag where TrN_TrNID = @OptimaID
 if (@OFFPrawoDoAnulowania > 0 OR @OFFPrawoDoFAPA > 0)
  select 1
 else
  select 0
  end
end
SET NOCOUNT OFF
END
