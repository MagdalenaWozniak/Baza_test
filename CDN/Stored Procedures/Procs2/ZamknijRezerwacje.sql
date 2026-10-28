CREATE PROCEDURE [CDN].[ZamknijRezerwacje]  @TrnIdROZD INT, @CzyRO INT, @OperatorID INT
AS
BEGIN
  SET NOCOUNT ON
   declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OperatorID, @OpeModKod OUT, @OpeModNazwisko OUT
if @CzyRO = 0
begin
  if exists(select TrN_TrNId from cdn.tranagrelacje
            join cdn.tranag on TrR_TrNId = TrN_TrNId
            where TrR_FaId = @TrnIdROZD and TrN_Bufor = 1 and TrN_TypDokumentu in (301,302,305,306,307,312,304) and TrN_Rodzaj not in (302200,302202) )
  BEGIN
      RAISERROR( '##OPT34438##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  update cdn.tranag set TrN_ZwroconoCalaIlosc = 4, TrN_TS_Mod=GETDATE(),TrN_OpeModID = @OperatorID, TrN_OpeModKod = @OpeModKod, TrN_OpeModNazwisko = @OpeModNazwisko where TrN_TrNId =  @TrnIdROZD
  update cdn.TrasElem set TrS_Typ = 5 from  cdn.TrasElem
  join  CDN.TraElem ON TrE_TrEId = TrS_TrEId
  where TrE_TrNID = @TrnIdROZD
end
else if @CzyRO = 2
begin
  if exists(select TrN_TrNId from cdn.tranagrelacje
            join cdn.tranag on TrR_TrNId = TrN_TrNId
            where TrR_FaId = @TrnIdROZD and TrN_Bufor = 1 and TrN_TypDokumentu in (301,302,305,306,307,312,304) and TrN_Rodzaj not in (302200,302202) )
  BEGIN
      RAISERROR( '##OPT34438##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  update cdn.tranag set TrN_ZwroconoCalaIlosc = 4 where TrN_TrNId =  @TrnIdROZD
  update cdn.TrasElem set TrS_Typ = 5 from  cdn.TrasElem
  join  CDN.TraElem ON TrE_TrEId = TrS_TrEId
  where TrE_TrNID = @TrnIdROZD
end
else
begin
 if exists(select A.trr_trnid from cdn.tranagrelacje A where A.trr_trnid = @TrnIdROZD and A.trr_fatyp = 308
                  AND EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B
                  WHERE A.Trr_FAId = B.TrR_TrNId AND   B.TrR_FAId <> @TrnIdROZD AND B.TrR_FaTyp = 320))
  BEGIN
      RAISERROR( '##OPT34439##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 if exists(select TrN_TrNId from cdn.tranagrelacje
            join cdn.tranag on TrR_TrNId = TrN_TrNId
            where TrR_FaId = @TrnIdROZD and TrN_Bufor = 1 and TrN_TypDokumentu in (302,306,308,312,304) and TrN_Rodzaj not in (302200,302202))
  BEGIN
      RAISERROR( '##OPT34438##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 update cdn.tranag set TrN_ZwroconoCalaIlosc = 4, TrN_TS_Mod=GETDATE(),TrN_OpeModID = @OperatorID, TrN_OpeModKod = @OpeModKod, TrN_OpeModNazwisko = @OpeModNazwisko where TrN_TrNId =  @TrnIdROZD
delete from cdn.traselem where trs_trsid in
(
select trs_trsid from cdn.traselem
join cdn.traelem on   trs_treid =  tre_treid
where tre_trnid = @TrnIdROZD and tre_Typdokumentu =320
)
 --create table #aaa(PFzRO int, PFzROPrzeksztalconymDalej int)
 --insert into #aaa(PFzRO,PFzROPrzeksztalconymDalej)
 --exec CDN.CzyPFzRO @TrnIdROZD
 --set @TrnIdROZD = 0
if exists(select top 1 count(a.Trr_TrNId) from cdn.tranagrelacje a
where a.TrR_FaId =@TrnIdROZD AND a.Trr_TrNTyp =308)
 begin
  update cdn.tranag set TrN_ZwroconoCalaIlosc = 4, TrN_TS_Mod=GETDATE(),TrN_OpeModID = @OperatorID, TrN_OpeModKod = @OpeModKod, TrN_OpeModNazwisko = @OpeModNazwisko where TrN_TrNId in (select a.Trr_TrNId from cdn.tranagrelacje a
where a.TrR_FaId =@TrnIdROZD AND a.Trr_TrNTyp =308)
  update cdn.TrasElem set TrS_Typ = 5 from  cdn.TrasElem
   join  CDN.TraElem ON TrE_TrEId = TrS_TrEId
   where TrE_TrNID in (select a.Trr_TrNId from cdn.tranagrelacje a
where a.TrR_FaId =@TrnIdROZD AND a.Trr_TrNTyp =308)
 end
end
  SET NOCOUNT OFF
END
