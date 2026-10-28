CREATE PROCEDURE CDN.RiseOptimaException
@ErrorCode int,
@Param1 nvarchar(50)=null, @Value1 nvarchar(255)=null,
@Param2 nvarchar(50)=null, @Value2 nvarchar(255)=null,
@Param3 nvarchar(50)=null, @Value3 nvarchar(255)=null,
@Param4 nvarchar(50)=null, @Value4 nvarchar(255)=null,
@Param5 nvarchar(50)=null, @Value5 nvarchar(255)=null
AS
BEGIN
 EXEC CDN.RaiseOptimaException @ErrorCode, @Param1, @Value1, @Param2, @Value2, @Param3, @Value3, @Param4, @Value4, @Param5, @Value5
END
