CREATE PROCEDURE [CDN].[UstawStatusRezerwacji]  @TrEIdROZD INT
AS
BEGIN
  SET NOCOUNT ON
   declare
   @TrNId int,
   @status int,
   @TypDok int,
   @IloscOrg decimal(15,4),
   @IloscZreal decimal(15,4),
   @typ int,
   @typ1 int
select @TrNId = TrE_TrNId,@TypDok = TrE_TypDokumentu from cdn.traelem where tre_treid =  @TrEIdROZD
if exists(select TrN_ZwroconoCalaIlosc from cdn.tranag where TrN_TrNId =  @TrNId AND TrN_ZwroconoCalaIlosc = 4 )
RETURN
IF @TypDok = 308
  select @typ = 3,@typ1 = 13
ELSE
  select @typ =4,@typ1 = 14
select @IloscOrg = ABS(ISNULL(sum(a.trs_ilosc),0)) from cdn.traselem a
join cdn.traelem on tre_treid = a.trs_treid
where tre_trnid = @TrNId
and a.trs_typ in( @typ,@typ1)
and a.TrS_TreIdWydania = 0
and a.Trs_ZwrId is null
select @IloscZreal = ABS(ISNULL(sum(a.trs_ilosc),0)) from cdn.traselem a
join cdn.traelem on tre_treid = a.trs_treid
where tre_trnid = @TrNId
and a.trs_typ in( @typ,@typ1)
and a.TrS_TreIdWydania <> 0
and a.Trs_ZwrId is not null
IF @IloscOrg = @IloscZreal SET  @status = 3
IF @IloscZreal = 0 SET  @status = 1
IF @IloscZreal <> 0 AND @IloscOrg > @IloscZreal SET  @status = 2
update cdn.tranag set TrN_ZwroconoCalaIlosc = @status, TrN_TS_Mod=GETDATE() where TrN_TrNId = @TrNId
  SET NOCOUNT OFF
END
