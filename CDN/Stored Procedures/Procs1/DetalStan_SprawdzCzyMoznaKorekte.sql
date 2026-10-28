CREATE PROCEDURE [CDN].[DetalStan_SprawdzCzyMoznaKorekte]
@StanDetalID INT,      -- ID Detalu
@DSTrNID INT,
@CzyUpdate INT
AS
BEGIN
SET NOCOUNT ON
declare
@OptimaID INT
IF NOT EXISTS (select dtrn_dtrnid from cdn.detaltranag where dtrn_StanDetalID = @StanDetalID and dtrn_DSTrNID = @DSTrNID and ISNULL(dtrn_optimaID,0) > 0)
begin
 select 1
end
else
begin
  select @OptimaID = dtrn_optimaID from cdn.detaltranag where dtrn_StanDetalID = @StanDetalID and dtrn_DSTrNID = @DSTrNID
  -- czy jest korekta w optinie
  IF NOT EXISTS (select trn_trnid from cdn.tranag left join cdn.detaltranag on dtrn_optimaid = trn_trnid where trn_zwrid = @OptimaID and dtrn_dtrnid is null AND  TrN_Rodzaj NOT IN (306071, 306072, 306061 ))
   begin
--anulowana kor
    IF NOT EXISTS (select trn_trnid from cdn.tranag where trn_zwrid = @OptimaID and trn_bufor=-1 )
      begin
--anulowany Pa
       IF NOT EXISTS (select trn_trnid from cdn.tranag where trn_trnid = @OptimaID and trn_bufor=-1)
        begin
 --taxfree
          IF NOT EXISTS (select trr_trrid from cdn.tranagrelacje where trr_trnid = @OptimaID and trr_fatyp=345)
            begin
        -- czy jest fa w optimie
            IF NOT EXISTS (select trr_trrid from cdn.tranagrelacje left join cdn.detaltranag on dtrn_optimaid = trr_faid where trr_trnid = @OptimaID and trr_fatyp = 302 and dtrn_dtrnid is null)
              begin
 -- fa anulowane
               IF NOT EXISTS (select trr_trrid from cdn.tranagrelacje left join cdn.tranag on trr_faid = trn_trnid where trr_trnid = @OptimaID and trr_fatyp = 302 and trn_bufor=-1)
                 begin
                   if @CzyUpdate = 1
                     update cdn.detaltranag set dtrn_stankorekta = 1 where dtrn_StanDetalID = @StanDetalID and dtrn_DSTrNID = @DSTrNID
                   select 1
                 end
               else
                 select 0
              end
            else
              select 0
            end
         else
           select 0
        end
       else
         select 0
      end
     else
       select 0
   end
   else
   select 0
   end
SET NOCOUNT OFF
END
