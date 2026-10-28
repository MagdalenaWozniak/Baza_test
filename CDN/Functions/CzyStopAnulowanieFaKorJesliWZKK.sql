CREATE FUNCTION CDN.CzyStopAnulowanieFaKorJesliWZKK(@TrNId INT)
RETURNS INT
AS
BEGIN
 -- Czy istnieją późniejsze dokumenty, na które pobrano towar z tych samych dostaw co na WZ skojarzone z FA
 declare @maxData DATETIME, @maxId INT, @wynik INT, @wzkk INT
 set @wynik = 0
 set @wzkk = 0
    if Exists( select TrN_TrNID from cdn.TraNag JOIN cdn.TraNagRelacje  on TrN_TrNId = TrR_TrNId where TrN_Rodzaj in (306061, 306071, 306072) and TrN_Korekta=1 and TrR_FaId = @TrNId )
  set @wzkk = 1
 else
  if Exists( select * from cdn.TraSElem S
   join cdn.TraSElem SKK   ON SKK.TrS_ZwrId = S.TrS_TrSId AND SKK.TrS_Rodzaj IN (306061,306071,306072)
   join cdn.TraElem E      ON S.TrS_TrEId = E.TrE_TrEId
   join cdn.TraNag WZ      ON WZ.TrN_TrnId = E.TrE_TrNId
   join cdn.TraNag WZKOR   ON WZKOR.TrN_ZwrId = WZ.TrN_TrNId
            JOIN cdn.TraNagRelacje REL ON WZKOR.TrN_TrNId = REL.TrR_TrNId
   join cdn.TraNag FAKOR   ON FAKOR.TrN_TrNId = REL.TrR_FaId
   where FAKOR.TrN_TrNId = @TrNId )
   set @wzkk = 1
 if @wzkk = 0
   return 0  -- nie ma powiązanych WZKK z WZ skojarzonymi z FA
 select @maxData = max(trs_DataOpe), @maxId = max(TrS_TrSId) from cdn.traselem
  join cdn.traelem on trs_treid = tre_treid
  join cdn.tranag on tre_trnid = trn_trnid
  where trn_trnid in (select trn_trnid from cdn.tranag JOIN cdn.TraNagRelacje ON TrN_TrNId = TrR_TrNId  where trr_faid=@TrNId)
 if Exists( select * from cdn.traselem
    where trs_trsiddost in
     (select distinct trs_trsiddost from cdn.traselem
      join cdn.traelem on trs_treid = tre_treid
      join cdn.tranag on tre_trnid = trn_trnid
     where trn_trnid in (select trn_trnid from cdn.tranag JOIN cdn.TraNagRelacje ON TrN_TrNId = TrR_TrNId  where trr_faid=@TrNId)
     )
    and ((TrS_DataOpe > @maxData) or (TrS_DataOpe = @maxData and TrS_TrSId > @maxId))  AND TrS_Rodzaj IN (306061,306071,306072)
   )
  set @wynik = 1
 return @wynik
END
