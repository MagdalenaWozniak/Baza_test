create procedure CDN.OZmienStatusZaksiegowana @ID int, @Zaksiegowana tinyint
as
begin
set nocount on
 update cdn.ListyPlac set LPL_Zaksiegowana = @Zaksiegowana where LPL_LplId = @ID
set nocount off
end
