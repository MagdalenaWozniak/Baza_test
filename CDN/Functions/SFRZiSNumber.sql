CREATE FUNCTION CDN.SFRZiSNumber(@id int)
RETURNS nvarchar(255)
AS
BEGIN
 declare @Result nvarchar(255) = upper(CDN.SFZestawieniaAutoNumber(@id));
 if @Result = 'C_I'
  Set @Result = 'C_1';
 else if @Result = 'D_I'
  Set @Result = 'D_1';
 /*
 set @Result = REPLACE(@Result, 'J_I_A_-', 'J_I_A_1');
 set @Result = REPLACE(@Result, 'J_I_B_-', 'J_I_B_1');
 set @Result = REPLACE(@Result, 'J_II_-', 'J_II_J');
 set @Result = REPLACE(@Result, 'J_III_-', 'J_III_J');
 set @Result = REPLACE(@Result, 'K_I_-', 'K_I_J');
 set @Result = REPLACE(@Result, 'K_II_-', 'K_II_J')
 set @Result = REPLACE(@Result, 'A_-', 'A_J');
 set @Result = REPLACE(@Result, 'B_-', 'B_J');
 */
 return @Result
END
