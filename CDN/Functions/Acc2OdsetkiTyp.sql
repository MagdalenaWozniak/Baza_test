CREATE FUNCTION CDN.Acc2OdsetkiTyp( @NumerIdx nvarchar(50), @OObId int)
RETURNS INT
AS
BEGIN
 declare @Result int = 0;
 declare @slownikTyp int = 0;
 declare @slownikId int = 0;
 select @slownikTyp=Acc_SlownikTyp,@slownikId=Acc_SlownikId from cdn.Konta where Acc_OObId = @OObId and Acc_NumerIdx = @NumerIdx
 if @slownikTyp = 1
 begin
  declare @fizyczny int = 0;
  --select @fizyczny = C.Knt_Finalny
  --from
  --cdn.Kontrahenci P join cdn.Kontrahenci C on (P.Knt_GlID = C.Knt_KntId)
  --where P.Knt_KntId = @slownikId
  select @fizyczny = Knt_Finalny
  from
  cdn.Kontrahenci
  where Knt_KntId = @slownikId
  if @fizyczny = 1
  begin
   set @Result = 1
  end
  else
  begin
   set @Result = 4
  end
 end
 else
 if @slownikTyp = 2
 begin
  set @Result = 4
 end
 else
 begin
  set @Result = 1
 end
 return @Result
END
