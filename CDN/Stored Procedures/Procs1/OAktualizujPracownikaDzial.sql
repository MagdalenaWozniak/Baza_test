CREATE procedure [CDN].[OAktualizujPracownikaDzial]
@IdDzial int,
@IdPracownika int
as
begin try
declare @s nvarchar(128)
declare @set int
 exec cdn.SynchStrPodlXL @pWynik = @set OUTPUT
 if @set = 1
  return
  declare @adresDzial nvarchar(400)
  set @adresDzial = (select DZL_AdresWezla from cdn.Dzialy where DZL_DzlId = @IdDzial)
UPDATE [CDN].PracEtaty
   SET PRE_DzlId  = @IdDzial,
    PRE_AdresDzialu = @adresDzial
 WHERE PRE_PraId = @IdPracownika
 and PRE_DataDo = convert(datetime, '2999-12-31', 120)
 declare @arch int, @parentid int, @nadrzedny int
      select @arch = PRA_Archiwalny, @parentid = PRA_ParentId,
      @nadrzedny = PRA_Nadrzedny from cdn.PracKod where PRA_PraId = @IdPracownika
      execute cdn.AktualizujPracIdx @IdPracownika, @arch, @parentid, @nadrzedny
end try
begin catch
  set @s = '##OPT32412##'
        raiserror(@s, 16, 1)
end catch
