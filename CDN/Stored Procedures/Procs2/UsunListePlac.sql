create procedure cdn.UsunListePlac @_LplId int
 as
 set nocount on
  delete from cdn.Wyplaty where WPL_LplId = @_LplId
  delete from cdn.ListyPlac where LPL_LplId = @_LplId
 set nocount off
