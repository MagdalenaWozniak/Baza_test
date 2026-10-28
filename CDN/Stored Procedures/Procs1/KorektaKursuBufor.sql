Create PROCEDURE [CDN].[KorektaKursuBufor] @TrnId INT
AS
 SET NOCOUNT ON
 select
 case when isnull(b.TrN_NumerPelny,'') != '' then  b.TrN_NumerPelny
 when isnull(c.TrN_NumerPelny,'') != '' then  c.TrN_NumerPelny
 else '' end
 from cdn.tranag a
 left join cdn.tranag b on B.TrN_ZwrId = A.TrN_TrNID and b.trn_korekta = 8 and b.trn_bufor = 1
 left join cdn.TraNagRelacje on TrR_TrNTyp in (306,307) and trr_trnid = A.TrN_TrNID and TrR_FaTyp in (301,302)
 left join cdn.tranag c on C.TrN_ZwrId = TrR_FaId and C.trn_korekta = 8 and C.trn_bufor = 1
 where
 a.trn_trnid = @TrnId
 SET NOCOUNT OFF
