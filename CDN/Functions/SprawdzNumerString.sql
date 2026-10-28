-- Sprawdzenie zgodności numeru z definicją dokumentu
CREATE Function CDN.SprawdzNumerString ( @DDfId Int, @NumerString NVARCHAR(31))
RETURNS NVARCHAR(100)
As
Begin
 Declare @DDfNumeracja NVARCHAR(50), @Komunikat NVARCHAR(100), @Symbol NVARCHAR(50)
 Set @Komunikat = ''
 If IsNull(@NumerString, '') = ''
  Begin
   Set @Komunikat = '##OPT34411##'
   Return @Komunikat
  End
 Select @DDfNumeracja = DDf_Numeracja , @Symbol = DDf_Symbol From CDN.DokDefinicje Where DDf_DDfId = @DDfId
 If IsNull(@DDfNumeracja, '') = ''
  Begin
   Set @Komunikat = '##OPT34412##'
   Return @Komunikat
  End
 Set @DDfNumeracja = Replace(Replace(@DDfNumeracja, '@brak/', ''), '/@brak', '')
 Declare @PosD Int, @PosN Int
 Declare @StrD NVARCHAR(50), @StrN NVARCHAR(31)
 Declare @MakroD NVARCHAR(50), @MakroN NVARCHAR(31)
 Declare @MakroD1 NVARCHAR(50)
 Set @StrD = @DDfNumeracja
 Set @StrN = @NumerString
 While @StrD <> '' Or @StrN <> ''
  Begin
    Set @PosD = CharIndex ('/', @StrD)
    If @PosD = 0
     Begin
      Set @MakroD = @StrD
      Set @StrD = ''
     End
    Else
     Begin
      Set @MakroD = SubString (@StrD, 1, @PosD-1)
      Set @StrD = SubString (@StrD, @PosD+1, Len(@StrD)-@PosD)
     End
    Set @PosN = CharIndex ('/', @StrN)
    If @PosN = 0
     Begin
      Set @MakroN = @StrN
      Set @StrN = ''
     End
    Else
     Begin
      Set @MakroN = SubString (@StrN, 1, @PosN-1)
      Set @StrN = SubString (@StrN, @PosN+1, Len(@StrN)-@PosN)
     End
    If @MakroD In ('@numer' , '@numerS') And @MakroD <> @MakroN
     Begin
      Set @Komunikat = '##OPT34413##'
      Return @Komunikat
     End
    If @MakroD <> '' And @MakroN = ''
     Begin
      Set @MakroD1 = @MakroD
      If @MakroD1 = '@rejestr'
        Set @MakroD1 = '@seria'
   Set @MakroD1 = Replace(@MakroD1, '@', '')
      Set @MakroD1 = Upper(Substring(@MakroD1, 1, 1)) + Substring(@MakroD1, 2, Len(@MakroD1)-1)
      Set @Komunikat = '##OPT34414##%%MakroD1%%=' + @MakroD1 +'%%s1%%='+@Symbol + '##'
      Return @Komunikat
     End
    If @MakroD = '' And @MakroN <> ''
     Begin
      Set @Komunikat = '##OPT34415##%%MakroN%%=' + @MakroN + '##'
      Return @Komunikat
     End
  End
 Return @Komunikat
End
