Create Function CDN.Konfiguracja (@Tryb TinyInt, @Klucz NVARCHAR(512), @Rok SmallInt, @Miesiac TinyInt)
Returns NVARCHAR(255)
As
Begin
Declare @Wynik NVARCHAR(255)
Set @Wynik = ''
If @Tryb = 1
  Begin
    -- Konfiguracja niehistoryczna (plik Konfig)
    If IsNumeric(@Klucz) = 1
      Select @Wynik = Fir_Wartosc From CDN.Firma Where Fir_Numer = Cast(@Klucz As Int)
  End
Else
  Begin
    Declare @Pos2 Int, @Pos1 Int, @Segment NVARCHAR(512), @Data DateTime, @CfkId Int, @CfkIdTmp Int
    Set @Data = CDN.EOMonth(100*@Rok+@Miesiac)
    Set @CfkId = 1 --ROOT
    Select @CfkId = CFK_CfkId From CDN.CfgKlucze Where CFK_ParentId = @CfkId And @Data Between CFK_OkresOd And CFK_OkresDo And CFK_Nazwa = 'ROOT2'
    Set @Pos1 = 1
    While 1=1
      Begin
        Set @Pos2 = CharIndex('\', @Klucz, @Pos1)
        If @Pos2 = 0
          Begin
            -- Ostatnia pozycja w kluczu
            Set @Segment = SubString(@Klucz, @Pos1, Len(@Klucz)-@Pos1+1)
          End
        Else
          Begin
            Set @Segment = SubString(@Klucz, @Pos1, @Pos2-@Pos1)
            Set @Pos1 = @Pos2+1
          End
        Set @CfkIdTmp = Null
        Select @CfkIdTmp = CFK_CfkId From CDN.CfgKlucze Where CFK_ParentId = @CfkId And @Data Between CFK_OkresOd And CFK_OkresDo And CFK_Nazwa = @Segment
        Set @CfkId = @CfkIdTmp
        If @CfkId Is Null Break
        If @Pos2 = 0 Break
      End
    Select @Wynik = CFW_Wartosc From CDN.CfgWartosci Where CFW_CFKId = @CfkId And CFW_Nazwa = ''
  End
Return IsNull(@Wynik, '')
End
