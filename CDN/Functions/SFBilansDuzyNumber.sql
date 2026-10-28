CREATE FUNCTION CDN.SFBilansDuzyNumber(@id int)
RETURNS nvarchar(255)
AS
BEGIN
 declare @Result nvarchar(255);
 declare @SourceNumber nvarchar(255);
 declare @Lisc int;
 select @SourceNumber = ZKP_Numer, @Lisc = ZKP_Lisc from CDN.ZestKsiPoz where ZKP_ZKPId = @id;
 set @Result = CDN.SFBilansNumber(@SourceNumber, @Lisc);
 if @Result = 'Pasywa_B_I_2_A'
  set @Result = REPLACE(@Result, 'Pasywa_B_I_2_A', 'Pasywa_B_I_2_1');
 else if @Result = 'Pasywa_B_I_2_B'
  set @Result = REPLACE(@Result, 'Pasywa_B_I_2_B', 'Pasywa_B_I_2_2');
 else if @Result = 'Pasywa_B_I_3_A'
  set @Result = REPLACE(@Result, 'Pasywa_B_I_3_A', 'Pasywa_B_I_3_1');
 else if @Result = 'Pasywa_B_I_3_B'
  set @Result = REPLACE(@Result, 'Pasywa_B_I_3_B', 'Pasywa_B_I_3_2');
 return @Result
END
