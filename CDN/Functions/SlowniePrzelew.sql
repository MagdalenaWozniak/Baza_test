CREATE FUNCTION CDN.SlowniePrzelew(@Kwota NVARCHAR(20))
RETURNS NVARCHAR(255)
AS
BEGIN
Declare @KwotaSlownie NVARCHAR(255)
Declare @L Int
Declare @X Int
Declare @Cyfra Int
Set @X = 0
Set @L = Len(@Kwota)-3
Set @KwotaSlownie = ''
While @X < @L
Begin
Set @X = @X + 1
Set @Cyfra = Substring(@Kwota, @X, 1)
If @Cyfra = 0 Set @KwotaSlownie = RTrim(@KwotaSlownie) +  'zer*'
Else If @Cyfra = 1 Set @KwotaSlownie = RTrim(@KwotaSlownie) +  'jed*'
Else If @Cyfra = 2 Set @KwotaSlownie = RTrim(@KwotaSlownie) +  'dwa*'
Else If @Cyfra = 3 Set @KwotaSlownie = RTrim(@KwotaSlownie) +  'trz*'
Else If @Cyfra = 4 Set @KwotaSlownie = RTrim(@KwotaSlownie) +  'czt*'
Else If @Cyfra = 5 Set @KwotaSlownie = RTrim(@KwotaSlownie) +  'pię*'
Else If @Cyfra = 6 Set @KwotaSlownie = RTrim(@KwotaSlownie) +  'sze*'
Else If @Cyfra = 7 Set @KwotaSlownie = RTrim(@KwotaSlownie) +  'sie*'
Else If @Cyfra = 8 Set @KwotaSlownie = RTrim(@KwotaSlownie) +  'osi*'
Else If @Cyfra = 9 Set @KwotaSlownie = RTrim(@KwotaSlownie) +  'dzi*'
End
Set @KwotaSlownie = RTrim(@KwotaSlownie) + ' ' + Substring(@Kwota, Len(@Kwota)-1, 2) + '/100'
Return @KwotaSlownie
END
