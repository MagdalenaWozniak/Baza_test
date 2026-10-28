CREATE FUNCTION CDN.SFBilansNumber(@SourceNumber nvarchar(255), @Lisc int)
RETURNS nvarchar(255)
AS
BEGIN
 declare @Result nvarchar(255) = '';
 declare @n1 nvarchar(2) = SubString(@SourceNumber,  1, 2);
 declare @n2 nvarchar(2) = SubString(@SourceNumber,  4, 2);
 declare @n3 nvarchar(2) = SubString(@SourceNumber,  7, 2);
 declare @n4 nvarchar(2) = SubString(@SourceNumber, 10, 2);
 declare @n5 nvarchar(2) = SubString(@SourceNumber, 13, 2);
 declare @n6 nvarchar(2) = SubString(@SourceNumber, 16, 2);
 declare @n7 nvarchar(2) = SubString(@SourceNumber, 19, 2);
 declare @n8 nvarchar(2) = SubString(@SourceNumber, 22, 2);
 declare @n9 nvarchar(2) = SubString(@SourceNumber, 25, 2);
 if @n1 = ' 1' and @SourceNumber <> @n1 set @Result = @Result + 'Aktywa';
 else if @n1 = ' 1' and @SourceNumber = @n1 and @Lisc = 0 set @Result = @Result + 'Aktywa';
 if @n1 = ' 3' and @SourceNumber <> @n1 set @Result = @Result + 'Pasywa';
 else if @n1 = ' 3' and @SourceNumber = @n1 and @Lisc = 0 set @Result = @Result + 'Pasywa';
 if @n2 = ' 1' set @Result = @Result + '_A';
 if @n2 = ' 2' set @Result = @Result + '_B';
 if @n2 = ' 3' set @Result = @Result + '_C';
 if @n2 = ' 4' set @Result = @Result + '_D';
 if @n2 = ' 5' set @Result = @Result + '_E';
 if @n2 = ' 6' set @Result = @Result + '_F';
 if @n3 = ' 1' set @Result = @Result + '_I';
 if @n3 = ' 2' set @Result = @Result + '_II';
 if @n3 = ' 3' set @Result = @Result + '_III';
 if @n3 = ' 4' set @Result = @Result + '_IV';
 if @n3 = ' 5' set @Result = @Result + '_V';
 if @n3 = ' 6' set @Result = @Result + '_VI';
 if @n3 = ' 7' set @Result = @Result + '_VII';
 if @n3 = ' 8' set @Result = @Result + '_VIII';
 if @n3 = ' 9' set @Result = @Result + '_IX';
 if @n4 = ' 1' set @Result = @Result + '_1';
 if @n4 = ' 2' set @Result = @Result + '_2';
 if @n4 = ' 3' set @Result = @Result + '_3';
 if @n4 = ' 4' set @Result = @Result + '_4';
 if @n4 = ' 5' set @Result = @Result + '_5';
 if @n4 = ' 6' set @Result = @Result + '_6';
 if @n4 = ' 7' set @Result = @Result + '_7';
 if @n4 = ' 8' set @Result = @Result + '_8';
 if @n4 = ' 9' set @Result = @Result + '_9';
 if @n1 = ' 3' and @n2 = ' 2' and @n3 = ' 4' and  @n5 = ' 1' set @Result = @Result + '_1';
 else if @n5 = ' 1' set @Result = @Result + '_A';
 if @n1 = ' 3' and @n2 = ' 2' and @n3 = ' 4' and  @n5 = ' 2' set @Result = @Result + '_2';
 else if @n5 = ' 2' set @Result = @Result + '_B';
 if @n1 = ' 3' and @n2 = ' 2' and @n3 = ' 4' and  @n5 = ' 3' set @Result = @Result + '_3';
 else if @n5 = ' 3' set @Result = @Result + '_C';
 if @n1 = ' 3' and @n2 = ' 2' and @n3 = ' 4' and  @n5 = ' 4' set @Result = @Result + '_4';
 else if @n5 = ' 4' set @Result = @Result + '_D';
 if @n1 = ' 3' and @n2 = ' 2' and @n3 = ' 4' and  @n5 = ' 5' set @Result = @Result + '_5';
 else if @n5 = ' 5' set @Result = @Result + '_E';
 if @n1 = ' 3' and @n2 = ' 2' and @n3 = ' 4' and  @n5 = ' 6' set @Result = @Result + '_6';
 else if @n5 = ' 6' set @Result = @Result + '_F';
 if @n1 = ' 3' and @n2 = ' 2' and @n3 = ' 4' and  @n5 = ' 7' set @Result = @Result + '_7';
 else if @n5 = ' 7' set @Result = @Result + '_G';
 if @n1 = ' 3' and @n2 = ' 2' and @n3 = ' 4' and  @n5 = ' 8' set @Result = @Result + '_8';
 else if @n5 = ' 8' set @Result = @Result + '_H';
 if @n1 = ' 3' and @n2 = ' 2' and @n3 = ' 4' and  @n5 = ' 9' set @Result = @Result + '_9';
 else if @n5 = ' 9' set @Result = @Result + '_I';
 if @n6 = ' 1' set @Result = @Result + '_1';
 if @n6 = ' 2' set @Result = @Result + '_2';
 if @n6 = ' 3' set @Result = @Result + '_3';
 if @n6 = ' 4' set @Result = @Result + '_4';
 if @n6 = ' 5' set @Result = @Result + '_5';
 if @n6 = ' 6' set @Result = @Result + '_6';
 return @Result
END
