CREATE  Procedure  CDN.Rodzina2 @DataUr DateTime, @Data DateTime
As
  SET NOCOUNT ON
  SET @DataUr = CONVERT(DATETIME, CONVERT(NVARCHAR(10),@DataUr,120)+' 00:00:000', 120)
  SET @Data   = CONVERT(DATETIME, CONVERT(NVARCHAR(10),@Data,120)+' 00:00:000', 120)
  DECLARE @Lata Int
  DECLARE @Mies Int
  DECLARE @Dni Int
  SET @Lata = 0
  SET @MIes = 0
  SET @Dni = 0
  exec CDN.StazCalc @DataUr, @Data, @Lata output, @Mies output, @Dni output
if (YEAR(@DataUr)=1899)and (MONTH(@DataUr)= 12) and (DAY(@DataUr)=30)
 begin
  SET @Lata = 0
  SET @Mies = 0
  SET @Dni  = 0
 end
  select @Lata As Lata, @Mies As Mies, @Dni As Dni
SET NOCOUNT OFF
