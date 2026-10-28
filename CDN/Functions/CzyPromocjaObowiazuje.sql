CREATE FUNCTION CDN.CzyPromocjaObowiazuje(@DataOd INT, @DataDo INT, @Cykl INT, @DataSprawdzana INT)
RETURNS int
AS
BEGIN
-- e_PRM_CYKL_DATA
 IF (@Cykl=0)
 BEGIN
  IF ((@DataOD<=@DataSprawdzana) AND (@DataDo>=@DataSprawdzana)) RETURN 1
  ELSE RETURN 0
 END
-- e_PRM_CYKL_GODZ
 DECLARE @Czas INT
 SET @Czas=(@DataSprawdzana % 86400)
 IF (@Cykl=1)
 BEGIN
  IF (@DataOd<=@Czas) AND (@DataDo>=@Czas) RETURN 1
  ELSE RETURN 0
 END
-- e_PRM_CYKL_GODZDATA
 DECLARE @CzasOd  INT
 DECLARE @CzasDo  INT
 SET @CzasOd=(@DataOd % 86400)
 SET @CzasDo=(@DataDo % 86400)
 IF (@Cykl=2)
 BEGIN
  IF (@DataOd<=@DataSprawdzana) AND (@DataDo>=@DataSprawdzana) AND (@CzasOd<=@Czas) AND (@CzasDo>=@Czas) RETURN 1
  ELSE RETURN 0
 END
-- Nieznany identyfikator @Cykl
 RETURN 0
END
