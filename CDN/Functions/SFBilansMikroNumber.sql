CREATE FUNCTION CDN.SFBilansMikroNumber(@id int)
RETURNS nvarchar(255)
AS
BEGIN
 declare @Result nvarchar(255);
 declare @SourceNumber nvarchar(255);
 declare @Lisc int;
 select @SourceNumber = ZKP_Numer, @Lisc = ZKP_Lisc from CDN.ZestKsiPoz where ZKP_ZKPId = @id;
 set @Result = CDN.SFBilansNumber(@SourceNumber, @Lisc);
--Aktywa_B_1 – zapasy
--Aktywa_B_2 – należności krótkoterminowe
--Pasywa_B_1 – rezerwy na zobowiązania
--Pasywa_B_2 – zobowiązania z tytułu kredytów i pożyczek
 if @Result = 'Aktywa_B_II'
  set @Result = REPLACE(@Result, 'Aktywa_B_II', 'Aktywa_B_2');
 else if @Result = 'Aktywa_B_I'
  set @Result = REPLACE(@Result, 'Aktywa_B_I', 'Aktywa_B_1');
 set @Result = REPLACE(@Result, 'Aktywa_B_II_1_B', 'Aktywa_B_II_A_2');
 set @Result = REPLACE(@Result, 'Aktywa_B_II_1_A', 'Aktywa_B_II_A_1');
 set @Result = REPLACE(@Result, 'Aktywa_B_II_1',  'Aktywa_B_II_A');
 set @Result = REPLACE(@Result, 'Aktywa_B_III_1_A', 'Aktywa_B_III_A_1');
 set @Result = REPLACE(@Result, 'Aktywa_B_III_1', 'Aktywa_B_III_A');
 if @Result = 'Pasywa_B_II'
  set @Result = REPLACE(@Result, 'Pasywa_B_II', 'Pasywa_B_1');
 else if @Result = 'Pasywa_B_III'
  set @Result = REPLACE(@Result, 'Pasywa_B_III', 'Pasywa_B_2');
 set @Result = REPLACE(@Result, 'Pasywa_B_III_2_B', 'Pasywa_B_III_B_2');
 set @Result = REPLACE(@Result, 'Pasywa_B_III_2_A', 'Pasywa_B_III_B_1');
 set @Result = REPLACE(@Result, 'Pasywa_B_III_3', 'Pasywa_B_III_C');
 set @Result = REPLACE(@Result, 'Pasywa_B_III_2', 'Pasywa_B_III_B');
 set @Result = REPLACE(@Result, 'Pasywa_B_III_1', 'Pasywa_B_III_A');
 return @Result
END
