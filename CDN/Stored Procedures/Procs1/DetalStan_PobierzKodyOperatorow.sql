CREATE PROCEDURE [CDN].[DetalStan_PobierzKodyOperatorow]
@posId int,
@onlyActive tinyint,
@onlyWithPass tinyint
AS
BEGIN
SET NOCOUNT ON
IF @onlyActive = 1 AND @onlyWithPass = 1
BEGIN
 SELECT DSOpe_Kod, DSOpe_Nazwisko, DSOpe_KodFunkcji, DSOpe_KonfiguracjaProgramu FROM CDN.DetalStanOperatorzy
  WHERE DSOpe_StanDetalID = @posId AND DSOpe_OpeNieAktywny = 0
  AND DSOpe_Haslo <> ''
END
ELSE IF @onlyActive = 1 AND @onlyWithPass = 0
BEGIN
 SELECT DSOpe_Kod, DSOpe_Nazwisko, DSOpe_KodFunkcji, DSOpe_KonfiguracjaProgramu FROM CDN.DetalStanOperatorzy
  WHERE DSOpe_StanDetalID = @posId AND DSOpe_OpeNieAktywny = 0
END
ELSE IF @onlyActive = 0 AND @onlyWithPass = 1
BEGIN
 SELECT DSOpe_Kod, DSOpe_Nazwisko, DSOpe_KodFunkcji, DSOpe_KonfiguracjaProgramu FROM CDN.DetalStanOperatorzy
  WHERE DSOpe_StanDetalID = @posId AND DSOpe_Haslo <> ''
END
ELSE IF @onlyActive = 0 AND @onlyWithPass = 0
BEGIN
 SELECT DSOpe_Kod, DSOpe_Nazwisko, DSOpe_KodFunkcji, DSOpe_KonfiguracjaProgramu FROM CDN.DetalStanOperatorzy
  WHERE DSOpe_StanDetalID = @posId
END
SET NOCOUNT OFF
END
