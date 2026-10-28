Create Function CDN.KontaAnalityczne (@AccId Int, @Syntetyki Int)
Returns @Konta Table (Anl_AccId Int)
As
Begin
 Declare @Analityka Int
 If Not Exists (Select * From CDN.Konta Where Acc_ParId = @AccId)
   Set @Analityka = 1
 Else
   Set @Analityka = 0
 If @Analityka <> 0 Or @Syntetyki <> 0
   Insert Into @Konta (Anl_AccId) Values (@AccId)
 If @Analityka = 0
  Begin
   Insert Into @Konta (Anl_AccId) Select Acc_AccId From CDN.Konta Where Acc_ParId = @AccId And Acc_Analityka = 1
   Declare @AnlId Int
   Declare ana Cursor Local Fast_Forward For
    Select Acc_AccId From CDN.Konta Where Acc_ParId = @AccId And Acc_Analityka = 0
   Open ana
   While 1=1
    Begin
     Fetch Next From ana InTo @AnlId
     If @@Fetch_Status <> 0 Break
     Insert Into @Konta (Anl_AccId) Select Anl_AccId From CDN.KontaAnalityczne (@AnlId, @Syntetyki)
    End
   Close ana
   Deallocate ana
  End
 Return
End
