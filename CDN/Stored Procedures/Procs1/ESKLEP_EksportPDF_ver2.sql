CREATE PROCEDURE [CDN].[ESKLEP_EksportPDF_ver2]
  @ID INT      -- ID e-sklepu
AS
BEGIN
 DECLARE
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME,
     @ESSID            INT,
     @ExpPDF           INT
      SELECT  @ESSID = ESS_ESSID, @TSSynchr = ESS_TS_SynchroPotw,@ExpPDF = ESS_FakturaPDF
 FROM cdn.eSklepStanowiska WHERE ESS_IdISklep = @ID
 SELECT @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
  if @ExpPDF = 1
     SELECT  1 as '@Typ' ,GIDNumer as '@ID',WdKE_PrnContent AS '@Dane'
 from
 (
  select distinct A.TrN_GIDNumer as GIDNumer, WdKE_WdKEId as WdKEId
      FROM CDN.TraNag A
      LEFT OUTER JOIN CDN.TraNagRelacje ON a.TrN_TrNId = TrR_TrNId AND TrR_FaTyp = 302
      LEFT OUTER JOIN CDN.TraNag B ON B.TrN_TrNId = TrR_FaId AND b.TrN_TypDokumentu = 302
      LEFT OUTER JOIN cdn.WdrKopieElektroniczne ON WdKE_ObjId = B.TrN_TrNId
      WHERE A.TrN_GIDNumer > 0 and A.TrN_eSklepID = @ESSID and B.TrN_Bufor = 0 and WdKE_PrnDate > @DateTSSynchr --and A.TrN_PodID <> 1
      and substring (right(WdKE_PrnFileName,4), convert(int,patindex('%.%',right(WdKE_PrnFileName,4)))+1,4) in ('pdf')
   and B.TrN_DataDok >=GETDATE() -30
   and WdKE_WdKEId in((select max(WdKE_WdKEId) from cdn.WdrKopieElektroniczne where WdKE_ObjType =302 group by WdKE_ObjId))
   and WdKE_ObjType = 302
 union all
    select distinct A.TrN_GIDNumer as GIDNumer, WdKE_WdKEId
      FROM CDN.TraNag A
      LEFT OUTER JOIN CDN.TraNagRelacje REL ON a.TrN_TrNId = REL.TrR_TrNId AND REL.TrR_FaTyp = 306
      LEFT OUTER JOIN CDN.TraNagRelacje RELFA ON REL.TrR_faId = RELFA.TrR_TrNId AND RELFA.TrR_FaTyp = 302
      LEFT OUTER JOIN CDN.TraNag B ON B.TrN_TrNId = RELFA.TrR_FaId AND b.TrN_TypDokumentu = 302
      LEFT OUTER JOIN cdn.WdrKopieElektroniczne ON WdKE_ObjId = B.TrN_TrNId
      WHERE A.TrN_GIDNumer > 0 and A.TrN_eSklepID = @ESSID and B.TrN_Bufor = 0 and WdKE_PrnDate > @DateTSSynchr --and A.TrN_PodID <> 1
      and substring (right(WdKE_PrnFileName,4), convert(int,patindex('%.%',right(WdKE_PrnFileName,4)))+1,4) in ('pdf')
   and B.TrN_DataDok >=GETDATE() -30
   and WdKE_WdKEId in((select max(WdKE_WdKEId) from cdn.WdrKopieElektroniczne where WdKE_ObjType =302 group by WdKE_ObjId))
   and WdKE_ObjType = 302
   ) zz
   LEFT OUTER JOIN cdn.WdrKopieElektroniczne ON WdKEId = WdKE_WdKEId
  FOR XML PATH('DOK'), type
END
