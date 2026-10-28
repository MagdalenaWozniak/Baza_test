CREATE procedure CDN.epDelegacjeZaliczki
@Fields nvarchar(2048) = NULL,
@Where nvarchar(2048) = NULL,
@DelegacjaId int  = NULL,
@ElementId int = NULL,
@PodmiotTyp int = NULL,
@PodmiotId int = NULL,
@ZaliczkaId int = NULL
As
 if @Fields is Null
  set @Fields = 'CDN.DlgZaliczki.*'
 Declare @sql nvarchar(3072)
 Declare @whr nvarchar(3072)
 set @whr = ' where DLZ_Typ=1'
 if @DelegacjaId is Not Null
 begin
  if @whr is Not Null
   set @whr = @whr + ' and DLN_DLNId='+convert(nvarchar, @DelegacjaId)
  else
   set @whr = ' where DLN_DLNId='+convert(nvarchar, @DelegacjaId)
 end
 if @ElementId is Not Null
 begin
  if @whr is Not Null
   set @whr = @whr + ' and DLE_DLEId=' + convert(nvarchar, @ElementId)
  else
   set @whr = ' where DLE_DLEId='+convert(nvarchar, @ElementId)
 end
 if @PodmiotTyp is Not Null
 begin
  if @whr is Not Null
   set @whr = @whr + ' and DLN_PodmiotTyp=' + convert(nvarchar, @PodmiotTyp)
  else
   set @whr = ' where DLN_PodmiotTyp='+convert(nvarchar, @PodmiotTyp)
 end
 if @PodmiotId is Not Null
 begin
  if @whr is Not Null
   set @whr = @whr + ' and DLN_PodmiotId=' + convert(nvarchar, @PodmiotId)
  else
   set @whr = ' where DLN_PodmiotId='+convert(nvarchar, @PodmiotId)
 end
 if @ZaliczkaId is Not Null
 begin
  if @whr is Not Null
   set @whr = @whr + ' and DLZ_DLZId=' + convert(nvarchar, @ZaliczkaId)
  else
   set @whr = ' where DLZ_DLZId='+convert(nvarchar, @ZaliczkaId)
 end
 if @Where Is Not Null
 begin
  if @whr is Not Null
   set @whr = @whr + ' and ' + @Where
  else
   set @whr = ' where ' + @Where
 end
 set @whr = IsNull(@whr, '')
 Declare @podmiotyView nvarchar(256)
 set @podmiotyView = ' left outer join CDN.PodmiotyView on (DLN_PodmiotId = Pod_PodID and DLN_PodmiotTyp = Pod_PodmiotTyp)'
 Set @sql = 'select ' + @Fields + ' from CDN.DlgZaliczki join CDN.DlgElem on (DLZ_DLEId=DLE_DLEId) join CDN.DlgNag on (DLN_DLNId = DLE_DLNId)' + @podmiotyView + @whr
 Execute dbo.sp_executesql @sql
