CREATE FUNCTION CDN.TypKontaAsString(@TypKonta int)
RETURNS varchar(20)
AS
BEGIN
 declare @Aktywa int = 1;
 declare @Pasywa int = 2;
 declare @AktywaPasywa int = 3;
 declare @Przychody int = 4;
 declare @Koszty int = 5;
 declare @Pozabilansowe int = 6;
 declare @PrzychodyKoszty int = 7;
 declare @Result varchar(20) = ''
 if      @TypKonta = @Aktywa Set @Result = 'Aktywa'
 else if @TypKonta = @Pasywa Set @Result = 'Pasywa'
 else if @TypKonta = @AktywaPasywa Set @Result = 'AktywaPasywa'
 else if @TypKonta = @Przychody Set @Result = 'Przychody'
 else if @TypKonta = @Koszty Set @Result = 'Koszty'
 else if @TypKonta = @Pozabilansowe Set @Result = 'Pozabilansowe'
 else if @TypKonta = @PrzychodyKoszty Set @Result = 'PrzychodyKoszty'
 return @Result
END
