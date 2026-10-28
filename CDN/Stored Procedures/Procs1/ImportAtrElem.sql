CREATE PROCEDURE CDN.ImportAtrElem
@SlowId int,
@OnlyNew smallint,
@ConfigDBName nvarchar(50),
@ServerName nvarchar(50),
@DAE_Wartosc nvarchar(100),
@ZrdId nvarchar(5),
@OpeId int,
@IdParam int OUTPUT,
@Warnings nvarchar(1000) OUTPUT
AS
SET NOCOUNT ON
BEGIN
 INSERT INTO CDN.DefAtrElem
 (
  DAE_DeAId,
  DAE_Wartosc
 )
 VALUES
 (
  @SlowId,
  @DAE_Wartosc
 )
END
