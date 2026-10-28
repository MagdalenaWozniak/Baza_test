-- TextToUTF8Binary
CREATE FUNCTION cdn.TextToUTF8Binary(@txt NVARCHAR(max), @modified bit)
returns varbinary(max)
as
begin
    set @modified = isnull(@modified, 0)
    declare @chars table (
    ix int identity primary key,
    codepoint int,
    utf8 varbinary(6)
    )
    declare @ix int
    set @ix = 0
    while @ix < datalength(@txt)/2
    begin
        set @ix = @ix + 1
        insert @chars(codepoint)
        select unicode(substring(@txt, @ix, 1))
    end
   update c1 set codepoint = ((c1.codepoint & 0x07ff) * 0x0800) + (c2.codepoint & 0x07ff) + 0x10000
    from @chars c1 inner join @chars c2 on c1.ix = c2.ix -1
    where c1.codepoint >= 0xD800 and c1.codepoint <=0xDBFF
    and c2.codepoint >= 0xDC00 and c2.codepoint <=0xDFFF
    -- Get rid of the trailing half of the pair where found
    delete c2
    from @chars c1 inner join @chars c2 on c1.ix = c2.ix -1
    where c1.codepoint >= 0x10000
     update c
    set utf8 =
    case
    -- One-byte encodings (modified UTF8 outputs zero as a two-byte encoding)
    when codepoint <= 0x7f and (@modified = 0 OR codepoint <> 0)
    then cast(substring(cast(codepoint as binary(4)), 4, 1) as varbinary(6))
    -- Two-byte encodings
    when codepoint <= 0x07ff
    then substring(cast((0x00C0 + ((codepoint/0x40) & 0x1f)) as binary(4)),4,1)
    + substring(cast((0x0080 + (codepoint & 0x3f)) as binary(4)),4,1)
    -- Three-byte encodings
    when codepoint <= 0x0ffff
    then substring(cast((0x00E0 + ((codepoint/0x1000) & 0x0f)) as binary(4)),4,1)
    + substring(cast((0x0080 + ((codepoint/0x40) & 0x3f)) as binary(4)),4,1)
    + substring(cast((0x0080 + (codepoint & 0x3f)) as binary(4)),4,1)
    -- Four-byte encodings
    when codepoint <= 0x1FFFFF
    then substring(cast((0x00F0 + ((codepoint/0x00040000) & 0x07)) as binary(4)),4,1)
    + substring(cast((0x0080 + ((codepoint/0x1000) & 0x3f)) as binary(4)),4,1)
    + substring(cast((0x0080 + ((codepoint/0x40) & 0x3f)) as binary(4)),4,1)
    + substring(cast((0x0080 + (codepoint & 0x3f)) as binary(4)),4,1)
    end
    from @chars c
    declare @ret varbinary(max)
    set @ret = cast('' as varbinary(max))
    select @ret = @ret + utf8 from @chars c order by ix
    return  @ret
end
