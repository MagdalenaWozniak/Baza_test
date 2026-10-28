create procedure cdn.Altum_DodajAtrybut
@AtrSynchId nvarchar(36),
@PracSynchId nvarchar(36),
@AtkSynchId nvarchar(36),
@DataOd datetime,
@DataDo datetime,
@Wartosc nvarchar(101),
@Throw nvarchar(256) output
as
set nocount on
             set @Throw = ''
             begin try
             declare @PraId int, @AtkId int, @NazwaKlasy nvarchar(101), @OatId int
             set @PraId = (select PRA_PraId from cdn.PracKod where PRA_ImportRowId = @PracSynchId)
             set @AtkId = (select ATK_AtkId from cdn.OAtrybutyKlasy where atk_ImportRowId = @AtkSynchId)
             set @NazwaKlasy = (select ATK_Nazwa from cdn.OAtrybutyKlasy where atk_ImportRowId = @AtkSynchId)
             set @OatId = (select Oat_Oatid from cdn.OAtrybuty where OAt_Prcid = @PraId and Oat_AtkId = @AtkId)
    if @DataOd is NULL
    set @DataOd = convert(datetime, '1900-01-01', 120)
    if @DataDo is NULL
    set @DataDo = convert(datetime, '3000-01-01', 120)
    set @DataOd = CAST(FLOOR(CAST(@DataOd AS FLOAT)) AS DATETIME)
    set @DataDo = CAST(FLOOR(CAST(@DataDo AS FLOAT)) AS DATETIME)
    if exists (select ATK_AtkId from cdn.OAtrybutyKlasy where ATK_AtkId = @AtkId and ATK_Typ = 1)
    begin
    if @Wartosc = 'TRUE'
     set @Wartosc = 'Tak'
    else if @Wartosc = 'FALSE'
     set @Wartosc = 'Nie'
    end
             if @OatId is null
             begin
                    insert into CDN.OAtrybuty
                    (OAT_PrcId,OAT_AtkId,OAT_OkresOd,OAT_OkresDo,OAT_NazwaKlasy,OAT_Wartosc)
                    values
                    (@PraId, @AtkId , @DataOd, @DataDo, @NazwaKlasy,@Wartosc)
                    set @OatId = SCOPE_IDENTITY()
     --[logowanie]
     declare @obj_name nvarchar(128)
     select @obj_name = '[' + PRI_Kod + '] ' + PRI_Imie1 + ' ' + PRI_Nazwisko from cdn.PracIdx where PRI_PraId = @PraId and PRI_Typ = 1
     declare @oid int
     set @oid = cdn.GetAltumOperatorID()
     if @oid > 0
     begin
      exec CDN.RejestrOperacjiContextInfo @oid
      exec CDN.RejestrOperacjiDodaj 24206, 0, @OatId, @NazwaKlasy, 1, @obj_name
     end
             end
             insert into CDN.OAtrybutyHist
             (ATH_PrcId,ATH_AtkId,ATH_OatId,ATH_Wartosc,ATH_DataOd,ATH_DataDo,ATH_ImportRowId)
             values
             (0, @AtkId , @OatId,@Wartosc,@DataOd, @DataDo,@AtrSynchId)
             exec cdn.AktualizujAtrybuty @OatID
             end try
             begin catch
                    set @Throw = '##OPT32403##'
             end catch
set nocount off
