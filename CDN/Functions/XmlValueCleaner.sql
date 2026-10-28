CREATE   Function CDN.XmlValueCleaner( @input NVARCHAR(max) )
Returns NVARCHAR(max)
As
Begin
 Declare @result NVARCHAR(max)
 Set @result = @input;
 Declare @index int;
 set @index = CHARINDEX(CHAR(0x00), @result); if @index <> 0 set @result = replace(@result, CHAR(0x00), '');
 set @index = CHARINDEX(CHAR(0x01), @result); if @index <> 0 set @result = replace(@result, CHAR(0x01), '');
 set @index = CHARINDEX(CHAR(0x02), @result); if @index <> 0 set @result = replace(@result, CHAR(0x02), '');
 set @index = CHARINDEX(CHAR(0x03), @result); if @index <> 0 set @result = replace(@result, CHAR(0x03), '');
 set @index = CHARINDEX(CHAR(0x04), @result); if @index <> 0 set @result = replace(@result, CHAR(0x04), '');
 set @index = CHARINDEX(CHAR(0x05), @result); if @index <> 0 set @result = replace(@result, CHAR(0x05), '');
 set @index = CHARINDEX(CHAR(0x06), @result); if @index <> 0 set @result = replace(@result, CHAR(0x06), '');
 set @index = CHARINDEX(CHAR(0x07), @result); if @index <> 0 set @result = replace(@result, CHAR(0x07), '');
 set @index = CHARINDEX(CHAR(0x08), @result); if @index <> 0 set @result = replace(@result, CHAR(0x08), '');
 set @index = CHARINDEX(CHAR(0x09), @result); if @index <> 0 set @result = replace(@result, CHAR(0x09), '');
 set @index = CHARINDEX(CHAR(0x0a), @result); if @index <> 0 set @result = replace(@result, CHAR(0x0a), '');
 set @index = CHARINDEX(CHAR(0x0b), @result); if @index <> 0 set @result = replace(@result, CHAR(0x0b), '');
 set @index = CHARINDEX(CHAR(0x0c), @result); if @index <> 0 set @result = replace(@result, CHAR(0x0c), '');
 set @index = CHARINDEX(CHAR(0x0d), @result); if @index <> 0 set @result = replace(@result, CHAR(0x0d), '');
 set @index = CHARINDEX(CHAR(0x0e), @result); if @index <> 0 set @result = replace(@result, CHAR(0x0e), '');
 set @index = CHARINDEX(CHAR(0x0f), @result); if @index <> 0 set @result = replace(@result, CHAR(0x0f), '');
 set @index = CHARINDEX(CHAR(0x10), @result); if @index <> 0 set @result = replace(@result, CHAR(0x10), '');
 set @index = CHARINDEX(CHAR(0x11), @result); if @index <> 0 set @result = replace(@result, CHAR(0x11), '');
 set @index = CHARINDEX(CHAR(0x12), @result); if @index <> 0 set @result = replace(@result, CHAR(0x12), '');
 set @index = CHARINDEX(CHAR(0x13), @result); if @index <> 0 set @result = replace(@result, CHAR(0x13), '');
 set @index = CHARINDEX(CHAR(0x14), @result); if @index <> 0 set @result = replace(@result, CHAR(0x14), '');
 set @index = CHARINDEX(CHAR(0x15), @result); if @index <> 0 set @result = replace(@result, CHAR(0x15), '');
 set @index = CHARINDEX(CHAR(0x16), @result); if @index <> 0 set @result = replace(@result, CHAR(0x16), '');
 set @index = CHARINDEX(CHAR(0x17), @result); if @index <> 0 set @result = replace(@result, CHAR(0x17), '');
 set @index = CHARINDEX(CHAR(0x18), @result); if @index <> 0 set @result = replace(@result, CHAR(0x18), '');
 set @index = CHARINDEX(CHAR(0x19), @result); if @index <> 0 set @result = replace(@result, CHAR(0x19), '');
 set @index = CHARINDEX(CHAR(0x1a), @result); if @index <> 0 set @result = replace(@result, CHAR(0x1a), '');
 set @index = CHARINDEX(CHAR(0x1b), @result); if @index <> 0 set @result = replace(@result, CHAR(0x1b), '');
 set @index = CHARINDEX(CHAR(0x1c), @result); if @index <> 0 set @result = replace(@result, CHAR(0x1c), '');
 set @index = CHARINDEX(CHAR(0x1d), @result); if @index <> 0 set @result = replace(@result, CHAR(0x1d), '');
 set @index = CHARINDEX(CHAR(0x1e), @result); if @index <> 0 set @result = replace(@result, CHAR(0x1e), '');
 set @index = CHARINDEX(CHAR(0x1f), @result); if @index <> 0 set @result = replace(@result, CHAR(0x1f), '');
 set @index = CHARINDEX(CHAR(0x7f), @result); if @index <> 0 set @result = replace(@result, CHAR(0x7f), '');
 Return rtrim(ltrim(@result))
End
