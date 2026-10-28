CREATE PROCEDURE CDN.ZmienTypKonta
@accId int,
@typKontaDst int,
@OperatorId int
AS
BEGIN
 SET NOCOUNT ON
 declare @syntetyka int  = 0;
 declare @typKontaCurrent int = 0;
 declare @typKontaParent int = 0;
 declare @Aktywa int = 1;
 declare @Pasywa int = 2;
 declare @AktywaPasywa int = 3;
 declare @Przychody int = 4;
 declare @Koszty int = 5;
 declare @Pozabilansowe int = 6;
 declare @PrzychodyKoszty int = 7;
 declare @NumerKonta nvarchar(255) = '';
 /*
  select @NumerKonta = Acc_Numer from CDN.Konta where Acc_AccId = @accId;
  if exists(select * from CDN.KontaZakazy where AcZ_OpeId = @OperatorId)
  begin
    exec CDN.RiseOptimaException 32568, 's1', @NumerKonta
    SET NOCOUNT OFF
    return;
  end
  */
  select @NumerKonta = Acc_Numer from CDN.KontaZakazy
  join CDN.KontaAnalityczne (@accId, 1) on (Anl_AccId=AcZ_AccId)
  join CDN.Konta on (AcZ_AccId=Acc_AccId)
  if ISNULL(@NumerKonta, '') <> ''
  begin
    exec CDN.RiseOptimaException 32568, 's1', @NumerKonta
    SET NOCOUNT OFF
    return;
  end
  update CDN.Konta Set Acc_TypKonta = @typKontaDst where
  Acc_AccId in (select Anl_AccId from  CDN.KontaAnalityczne (@accId, 1));
  /*
 if exists(select Anl_AccId from CDN.KontaAnalityczne (@accId, 0) where Anl_AccId <> @accId)
 begin
  set @syntetyka = 0;
  set @typKontaParent = 0;
 end
 else
 begin
  set @syntetyka = 1;
  select @typKontaParent = Acc_TypKonta from CDN.Konta where Acc_AccId in (select Acc_ParId from CDN.Konta where Acc_AccId = @accId);
 end
 select @typKontaCurrent = Acc_TypKonta from CDN.Konta where Acc_AccId = @accId;
 if @syntetyka = 1
 begin
  if @typKontaParent in (@Aktywa, @Pasywa, @Przychody, @Koszty, @Pozabilansowe) and @typKontaParent <> @typKontaDst
  begin
   exec CDN.RiseOptimaException 32768
   SET NOCOUNT OFF
   return;
  end
  else if @typKontaParent = @AktywaPasywa and @typKontaDst not in (@Aktywa, @Pasywa, @AktywaPasywa)
  begin
   exec CDN.RiseOptimaException 32768
   SET NOCOUNT OFF
   return;
  end
  else if @typKontaParent = @PrzychodyKoszty and @typKontaDst not in (@Przychody, @Koszty, @PrzychodyKoszty)
  begin
   exec CDN.RiseOptimaException 32768
   SET NOCOUNT OFF
   return;
  end
 end
 update CDN.Konta Set Acc_TypKonta = @typKontaDst where Acc_AccId = @accId;
  */
 SET NOCOUNT OFF
 return;
END
