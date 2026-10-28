CREATE FUNCTION CDN.SFRZiSPorNumber(@id int)
RETURNS nvarchar(255)
AS
BEGIN
 declare @Result nvarchar(255) = upper(CDN.SFZestawieniaAutoNumber(@id));
 set @Result = REPLACE(@Result, 'H_II_-', 'H_II_J');
 set @Result = REPLACE(@Result, 'H_I_-', 'H_I_J');
 set @Result = REPLACE(@Result, 'G_III_-', 'G_III_J');
 set @Result = REPLACE(@Result, 'G_II_-', 'G_II_J');
 set @Result = REPLACE(@Result, 'G_I_B_-', 'G_I_B_1');
 set @Result = REPLACE(@Result, 'G_I_A_-', 'G_I_A_1');
 set @Result = REPLACE(@Result, 'B_VI_-', 'B_VI_1');
 set @Result = REPLACE(@Result, 'B_IV_-', 'B_IV_1');
 set @Result = REPLACE(@Result, 'A_-', 'A_J');
 return @Result
END
