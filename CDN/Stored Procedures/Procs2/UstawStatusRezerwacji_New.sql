CREATE PROCEDURE [CDN].[UstawStatusRezerwacji_New]  @ROZDTrNId INT, @RealizujaceTrNId INT
AS
BEGIN
  SET NOCOUNT ON
   declare
   @status int,
   @TypDok int,
   @IloscOrg decimal(15,4),
   @IloscZreal decimal(15,4),
   @typ int,
   @typ1 int
if @ROZDTrNId =0
begin
if not exists (select trr_trrid from cdn.TraNagRelacje where trr_trnid = @RealizujaceTrNId and trr_fatyp in (308,309))
RETURN
      DECLARE dok CURSOR LOCAL FAST_FORWARD FOR
       select trr_faid from cdn.TraNagRelacje where trr_trnid = @RealizujaceTrNId and trr_fatyp in (308,309)
          OPEN dok
          WHILE 1=1
            BEGIN
              FETCH NEXT FROM dok INTO @ROZDTrNId
              IF @@FETCH_STATUS <> 0 BREAK
select @TypDok = TrN_TypDokumentu from cdn.TraNag where TrN_TrNID =  @ROZDTrNId
if not exists(select TrN_ZwroconoCalaIlosc from cdn.tranag where TrN_TrNId =  @ROZDTrNId AND TrN_ZwroconoCalaIlosc = 4 )
begin
IF @TypDok = 308
  select @typ = 3,@typ1 = 13
ELSE
  select @typ =4,@typ1 = 14
select @IloscOrg = ABS(ISNULL(sum(a.trs_ilosc),0)) from cdn.traselem a
join cdn.traelem on tre_treid = a.trs_treid
where tre_trnid = @ROZDTrNId
and a.trs_typ in( @typ,@typ1)
and a.TrS_TreIdWydania = 0
and a.Trs_ZwrId is null
select @IloscZreal = ABS(ISNULL(sum(a.trs_ilosc),0)) from cdn.traselem a
join cdn.traelem on tre_treid = a.trs_treid
where tre_trnid = @ROZDTrNId
and a.trs_typ in( @typ,@typ1)
and a.TrS_TreIdWydania <> 0
and a.Trs_ZwrId is not null
IF @IloscOrg = @IloscZreal SET  @status = 3
IF @IloscZreal = 0 SET  @status = 1
IF @IloscZreal <> 0 AND @IloscOrg > @IloscZreal SET  @status = 2
update cdn.tranag set TrN_ZwroconoCalaIlosc = @status, TrN_TS_Mod=GETDATE() where TrN_TrNId = @ROZDTrNId
end
            END
          CLOSE dok
      DEALLOCATE dok
end
else
begin
select @TypDok = TrN_TypDokumentu from cdn.TraNag where TrN_TrNID =  @ROZDTrNId
if exists(select TrN_ZwroconoCalaIlosc from cdn.tranag where TrN_TrNId =  @ROZDTrNId AND TrN_ZwroconoCalaIlosc = 4 )
RETURN
IF @TypDok = 308
  select @typ = 3,@typ1 = 13
ELSE
  select @typ =4,@typ1 = 14
select @IloscOrg = ABS(ISNULL(sum(a.trs_ilosc),0)) from cdn.traselem a
join cdn.traelem on tre_treid = a.trs_treid
where tre_trnid = @ROZDTrNId
and a.trs_typ in( @typ,@typ1)
and a.TrS_TreIdWydania = 0
and a.Trs_ZwrId is null
select @IloscZreal = ABS(ISNULL(sum(a.trs_ilosc),0)) from cdn.traselem a
join cdn.traelem on tre_treid = a.trs_treid
where tre_trnid = @ROZDTrNId
and a.trs_typ in( @typ,@typ1)
and a.TrS_TreIdWydania <> 0
and a.Trs_ZwrId is not null
IF @IloscOrg = @IloscZreal SET  @status = 3
IF @IloscZreal = 0 SET  @status = 1
IF @IloscZreal <> 0 AND @IloscOrg > @IloscZreal SET  @status = 2
update cdn.tranag set TrN_ZwroconoCalaIlosc = @status, TrN_TS_Mod=GETDATE() where TrN_TrNId = @ROZDTrNId
end
  SET NOCOUNT OFF
END
