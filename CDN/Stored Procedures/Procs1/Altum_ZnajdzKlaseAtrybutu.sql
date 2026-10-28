CREATE procedure [CDN].[Altum_ZnajdzKlaseAtrybutu]
@Nazwa nvarchar(41),
@Typ tinyint output,
@Format nvarchar(21) output,
@AtkSynchId nvarchar(36) output
as
set nocount on
 select @Typ = ATK_Typ , @Format = Atk_Format, @AtkSynchId = ATK_ImportRowId from cdn.OAtrybutyKlasy where atk_Nazwa = @Nazwa
set nocount off
