CREATE FUNCTION cdn.CrmCzasPozaZakresem (@DataOd DATETIME, @DataDo DATETIME)
  RETURNS     INT
  AS
  BEGIN
 if Convert (NVARCHAR(10), @DataOd, 120) = Convert (NVARCHAR(10), @DataDo, 120)
 BEGIN -- jesli ten sam dzien
  if( DATEPART(hh, @DataOd) < 6  AND DATEPART(hh, @DataDo) < 6 )
   RETURN 1
  if( DATEPART(hh, @DataOd) >= 21 )
   RETURN 1
 END
 if Convert (NVARCHAR(10), @DataDo, 120) = Convert (NVARCHAR(10), DateAdd(day, 1, @DataOd), 120)
 BEGIN -- jesli przelom dni
  if( DATEPART(hh, @DataOd) >= 21  AND DATEPART(hh, @DataDo) < 6 )
   RETURN 1
 END
 RETURN 0
END
