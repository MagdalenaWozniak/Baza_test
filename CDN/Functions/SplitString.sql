CREATE FUNCTION cdn.SplitString
(
    @RowData nvarchar(max),
    @SplitOn nvarchar(16)
)
RETURNS @RtnValue table
(
    Id int identity(1,1),
    Data nvarchar(max)
)
AS
BEGIN
    Declare @Cnt int
    Set @Cnt = 1
    While (Charindex(@SplitOn,@RowData)>0)
    Begin
        Insert Into @RtnValue (data)
        Select
            Data = ltrim(rtrim(Substring(@RowData,1,Charindex(RTrim(@SplitOn),@RowData)-1)))
        Set @RowData = Substring(@RowData,Charindex(RTrim(@SplitOn),@RowData)+1,len(@RowData))
        Set @Cnt = @Cnt + 1
    End
    Insert Into @RtnValue (data)
    Select Data = ltrim(rtrim(@RowData))
    Return
END
