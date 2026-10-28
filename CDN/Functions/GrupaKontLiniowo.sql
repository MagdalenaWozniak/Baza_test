Create  function CDN.GrupaKontLiniowo(@AccId int, @OObId int)
Returns @Konta Table(
AccId int
)
as
Begin
-- zwraca hierarchie kont dla konta o wskazanym ID
 declare @parent integer
 declare @par integer
 Set @parent = @AccId
 declare @kontoId int
 set @kontoId = -1
 Declare @Numer NVARCHAR(50)
 Set @Numer = (Select Acc_Numer
 From CDN.Konta
 Where Acc_AccId = @AccId and Acc_OObID = @OObId)
 if @Numer <> ''
 begin
  Insert into @Konta
  Select Acc_AccId as AccId FROM CDN.Konta
  Where Acc_Numer like @Numer+'-%' and Acc_OObID = @OObId
 end
  WHILE @parent <> 0
  BEGIN
   Set @par = (Select Top 1 isnull(Acc_ParId,0)
   from CDN.KontaAnalityczne (@parent, 1)
    join cdn.konta on anl_accid=acc_accid
   Where Acc_OObID = @OObId
   Order by acc_Numer)
   Set @parent = @par
   set @kontoId = @parent
   if @kontoId > 0
   begin
    Insert into @Konta
    Select @kontoId
   end
  END
return
End
