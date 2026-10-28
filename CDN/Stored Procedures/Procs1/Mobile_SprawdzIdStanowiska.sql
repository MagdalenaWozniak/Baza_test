CREATE PROCEDURE [CDN].[Mobile_SprawdzIdStanowiska]
  @OpeId Int
AS
SET NOCOUNT ON
 select top 1 dsta_dstaid from cdn.detaloperator
join cdn.detalstanowiska on dope_dstaid = dsta_dstaid and dsta_typ = 2
where dope_opeid =  @OpeId
SET NOCOUNT OFF
