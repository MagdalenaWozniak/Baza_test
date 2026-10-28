CREATE PROCEDURE CDN.RaiseOptimaException
@ErrorCode int,
@Param1 nvarchar(50)=null, @Value1 nvarchar(255)=null,
@Param2 nvarchar(50)=null, @Value2 nvarchar(255)=null,
@Param3 nvarchar(50)=null, @Value3 nvarchar(255)=null,
@Param4 nvarchar(50)=null, @Value4 nvarchar(255)=null,
@Param5 nvarchar(50)=null, @Value5 nvarchar(255)=null
AS
BEGIN
 SET NOCOUNT ON
 declare @message nvarchar(max);
 declare @paramCount int = 0;
 set @message = '##OPT' + rtrim(ltrim(Str(@ErrorCode))) + '##';
 if IsNull(@Param1, '') <> ''
 begin
  set @message = @message + '%%' + rtrim(ltrim(@Param1)) + '%%=%s';
  set @paramCount = @paramCount + 1;
 end
 if IsNull(@Param2, '') <> ''
 begin
  set @message = @message + '%%' + rtrim(ltrim(@Param2)) + '%%=%s';
  set @paramCount = @paramCount + 1;
 end
 if IsNull(@Param3, '') <> ''
 begin
  set @message = @message + '%%' + rtrim(ltrim(@Param3)) + '%%=%s';
  set @paramCount = @paramCount + 1;
 end
 if IsNull(@Param4, '') <> ''
 begin
  set @message = @message + '%%' + rtrim(ltrim(@Param4)) + '%%=%s';
  set @paramCount = @paramCount + 1;
 end
 if IsNull(@Param5, '') <> ''
 begin
  set @message = @message + '%%' + rtrim(ltrim(@Param5)) + '%%=%s';
  set @paramCount = @paramCount + 1;
 end
 SET NOCOUNT OFF
  if @paramCount > 0
    set @message=@message+'##';
 if @paramCount = 0
  RAISERROR(@message, 16, 1);
 else if @paramCount = 1
  RAISERROR(@message, 16, 1, @Value1);
 else if @paramCount = 2
  RAISERROR(@message, 16, 1, @Value1, @Value2);
 else if @paramCount = 3
  RAISERROR(@message, 16, 1, @Value1, @Value2, @Value3);
 else if @paramCount = 4
  RAISERROR(@message, 16, 1, @Value1, @Value2, @Value3, @Value4);
 else if @paramCount = 5
  RAISERROR(@message, 16, 1, @Value1, @Value2, @Value3, @Value4, @Value5);
 return;
END
