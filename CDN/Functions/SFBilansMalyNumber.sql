CREATE FUNCTION CDN.SFBilansMalyNumber(@id int)
RETURNS nvarchar(255)
AS
BEGIN
 declare @Result nvarchar(255);
 declare @SourceNumber nvarchar(255);
 declare @Lisc int;
 select @SourceNumber = ZKP_Numer, @Lisc = ZKP_Lisc from CDN.ZestKsiPoz where ZKP_ZKPId = @id;
 set @Result = CDN.SFBilansNumber(@SourceNumber, @Lisc);
 set @Result = REPLACE(@Result, 'Aktywa_B_II_1_B', 'Aktywa_B_II_A_2');
 set @Result = REPLACE(@Result, 'Aktywa_B_II_1_A', 'Aktywa_B_II_A_1');
 set @Result = REPLACE(@Result, 'Aktywa_B_II_1',  'Aktywa_B_II_A');
 set @Result = REPLACE(@Result, 'Aktywa_B_III_1_A', 'Aktywa_B_III_A_1');
 set @Result = REPLACE(@Result, 'Aktywa_B_III_1', 'Aktywa_B_III_A');
 set @Result = REPLACE(@Result, 'Pasywa_B_III_2_B', 'Pasywa_B_III_B_2');
 set @Result = REPLACE(@Result, 'Pasywa_B_III_2_A', 'Pasywa_B_III_B_1');
 set @Result = REPLACE(@Result, 'Pasywa_B_III_3', 'Pasywa_B_III_C');
 set @Result = REPLACE(@Result, 'Pasywa_B_III_2', 'Pasywa_B_III_B');
 set @Result = REPLACE(@Result, 'Pasywa_B_III_1', 'Pasywa_B_III_A');
 return @Result
END
