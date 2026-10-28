create procedure cdn.OAktualizujSchematPlatnosci
@spl_podmiotid smallint,
@SPl_FPlId int,
@SPL_BnaID int,
@SPL_RachunekNr nvarchar(51),
@SPL_IBAN tinyint
as
begin
 declare @s nvarchar(128)
if exists (select * from sysobjects where name = 'Synch2015 ' And xtype = 'p')
 begin
 declare @set int
 exec cdn.Synch2015 @pWynik = @set OUTPUT
 if @set = 1
  return
 end
else
 return
 begin try
 declare @NewPreId int
set @NewPreId = 0
select @NewPreId = PRE_PreId from CDN.PracEtaty
where PRE_PraId = @spl_podmiotid and PRE_DataDo = (select max(PRE_DataDo)
                     from CDN.PracEtaty
                    where PRE_PraId = @spl_podmiotid)
 declare @liczbaPorz int
 set @liczbaPorz = (select min(SPL_LiczbaPorz)from cdn.SchematPlatnosci where SPL_PodmiotID =  @NewPreId)
 if @SPL_BnaId = 0
   set @SPL_BnaID = NULL
  update cdn.SchematPlatnosci
     set
      SPL_FplId = @SPl_FPlId,
      SPL_BnaId = @SPL_BnaID,
      SPL_RachunekNr = @SPL_RachunekNr,
      SPL_IBAN = @spl_iban
     where
      spl_podmiotid = @NewPreId and SPL_LiczbaPorz = @liczbaPorz
 end try
    begin catch
        set @s = '##OPT32397##'
        raiserror(@s, 16, 1)
    end catch
end
