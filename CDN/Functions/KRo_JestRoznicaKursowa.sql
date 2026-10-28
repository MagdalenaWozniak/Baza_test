CREATE FUNCTION CDN.KRo_JestRoznicaKursowa(@DokTyp int, @DokId int, @RozTyp int, @RozId int)
RETURNS int
AS
BEGIN
 if @DokTyp = 1
 begin
  if exists(select * from cdn.DekretyElem where DeE_DeEId = @DokId and IsNUll(DeE_Waluta, '') = '')
   return 0
 end
 else
 begin
  if exists(select * from cdn.BOElem where BoE_BoEId = @DokId and IsNUll(BoE_Waluta, '') = '')
   return 0
 end
 if @RozTyp = 1
 begin
  if exists(select * from cdn.DekretyElem where DeE_DeEId = @RozId and IsNUll(DeE_Waluta, '') = '')
   return 0
 end
 else
 begin
  if exists(select * from cdn.BOElem where BoE_BoEId = @RozId and IsNUll(BoE_Waluta, '') = '')
   return 0
 end
 declare @Result int;  set @Result = 0;
 declare @dokKursL decimal(15,4)
 declare @dokKursM decimal(15,4)
 declare @rozKursL decimal(15,4)
 declare @rozKursM decimal(15,4)
 declare @dokKwotaSys decimal(15,2)
 declare @dokKwotaWal decimal(15,2)
 declare @rozKwotaSys decimal(15,2)
 declare @rozKwotaWal decimal(15,2)
 declare @kD decimal(15,4)
 declare @kR decimal(15,4)
 declare @dokKurs decimal(20,4)
 declare @rozKurs decimal(20,4)
 if @DokTyp = 1
 begin
  select @dokKursL = DeE_KursL, @dokKursM = DeE_KursM, @dokKwotaSys = DeE_Kwota, @dokKwotaWal = DeE_KwotaWal from cdn.DekretyElem where DeE_DeEId = @DokId
 end
 else
 begin
  select @dokKursL = BoE_KursL, @dokKursM = BoE_KursM,
  @dokKwotaSys=case when BoE_KwotaWn<>0 then BoE_KwotaWn else BoE_KwotaMa end,
  @dokKwotaWal=case when BoE_KwotaWn<>0 then BoE_KwotaWnWal else BOE_KwotaMaWal end
  from cdn.BOElem where BoE_BoEId = @DokId
 end
 if @RozTyp = 1
 begin
  select @rozKursL = DeE_KursL, @rozKursM = DeE_KursM, @rozKwotaSys = DeE_Kwota, @rozKwotaWal = DeE_KwotaWal from cdn.DekretyElem where DeE_DeEId = @RozId
 end
 else
 begin
  select @rozKursL = BoE_KursL, @rozKursM = BoE_KursM,
  @rozKwotaSys=case when BoE_KwotaWn<>0 then BoE_KwotaWn else BoE_KwotaMa end,
  @rozKwotaWal=case when BoE_KwotaWn<>0 then BoE_KwotaWnWal else BOE_KwotaMaWal end
  from cdn.BOElem where BoE_BoEId = @RozId
 end
 set @kD = @dokKursL * @dokKursM;
 set @kR = @rozKursL * @rozKursM;
 if @kD = 0 or @kD = 1
 begin
  if @dokKwotaWal <> 0
   set @dokKurs = 10000.0 * @dokKwotaSys / @dokKwotaWal;
  else
   set @dokKurs = 0
 end
 else
  set @dokKurs = 10000.0 * @dokKursL * @dokKursM
 if @kR = 0 or @kR = 1
 begin
  if @rozKwotaWal <> 0
   set @rozKurs = 10000.0 * @rozKwotaSys / @rozKwotaWal;
  else
   set @rozKurs = 0
 end
 else
  set @rozKurs = 10000.0 * @rozKursL * @rozKursM
 if @rozKurs <> @dokKurs or @rozKurs = @dokKurs and @rozKwotaWal <> 0 and @dokKwotaWal <> 0 and @rozKwotaSys / @rozKwotaWal <> @dokKwotaSys / @dokKwotaWal
  set @Result = 1
 else
  set @Result = 0
 RETURN @Result
END
