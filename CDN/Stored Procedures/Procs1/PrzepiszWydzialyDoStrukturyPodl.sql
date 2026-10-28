--/////////////////////////////////////////////////////////////////////////////////////////////////////
create procedure [CDN].[PrzepiszWydzialyDoStrukturyPodl]
as
set nocount on
if (select COUNT(cnt_cntid) from cdn.Centra) > 2
begin
 set identity_insert cdn.centra on
 insert into cdn.Centra
 (CNT_CntId, CNT_Kod, CNT_Nazwa, CNT_ParentId, CNT_Nieaktywny, CNT_AdresWezla, CNT_Poziom, CNT_Lisc, CNT_AddMethod, CNT_ImpId, CNT_Last, CNT_OpeZalId, CNT_StaZalId, CNT_TS_Zal, CNT_OpeModId, CNT_StaModId, CNT_TS_Mod)
  select DZL_DzlId, DZL_Kod, DZL_Nazwa, DZL_ParentId, DZL_Nieaktywny, DZL_AdresWezla, DZL_Poziom, DZL_Lisc, DZL_AddMethod, 0, DZL_Last, 1, 1, GETDATE(), 1, 1, GETDATE()
   from cdn.Dzialy where DZL_DzlId > 3 order by DZL_DzlId
 set identity_insert cdn.centra off
end
set nocount off
