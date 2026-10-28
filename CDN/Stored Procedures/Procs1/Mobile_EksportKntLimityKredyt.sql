CREATE Procedure [CDN].[Mobile_EksportKntLimityKredyt]
@ID     INT, -- ID centrum praw struktury firmy - id mobilnego sprzedawcy
@TypEksportu   INT, -- Typ eksportu (0 - różnicowy, 1 - pełny)
@PackageSize   INT, -- rozmiar paczki
@PackageNumber INT  -- numer paczki
AS
BEGIN
declare
@KntGrupa NVARCHAR(20)
  select @KntGrupa = DSta_KntGrupa FROM CDN.DetalStanowiska  WHERE DSta_DStaId = @ID
 if @KntGrupa = ''
BEGIN
            SELECT DISTINCT
                IDENTITY(INT,1,1) As Rank,
                Knt_KntId,
                case when Knt_LimitFlag = 1 then 2 else 0 end as Knt_LimitTerminowy, /*0-nieograniczony 1-terminowy 2-bezterminowy*/
                Knt_LimitKredytu as Knt_MaxLimitWart,
                case when knt_limitprzeterkredytflag = 1 then Knt_LimitPrzeterKredytWartosc else case when Knt_LimitFlag = 1 then Knt_LimitKredytu else Knt_LimitPrzeterKredytWartosc end end as Knt_KwotaDozwolonaPoTerminie,
                null as Knt_KwotaDoWykorzystaniaZS,
                case when Knt_LimitFlag = 1 then case when Knt_LimitKredytu - Knt_LimitKredytuWykorzystany > 0 then(Knt_LimitKredytu - Knt_LimitKredytuWykorzystany)else 0 end else null end as Knt_KwotaDoWykorzystaniaFS,
                null as Knt_KwotaDoWykorzystaniaWZ,
                0 as Knt_IstniejaPlatnosciPrzeterminowane,
                null as Knt_KwotaPrzeterminowanaZS,
                case when knt_limitprzeterkredytflag = 1 then ISNULL(cdn.Mobile_EksportKntZal (Knt_KntId,GETDATE()-1),0) else 0 end as Knt_KwotaPrzeterminowanaFS,
                null as Knt_KwotaPrzeterminowanaWZ,
                null as Knt_DataWygasniecia
  INTO #TempMobile
  FROM CDN.Kontrahenci
        LEFT JOIN cdn.detalformyplatnosci ON Knt_FplId = dfpl_fplid and @ID =dfpl_dstaid
        LEFT JOIN cdn.formyplatnosci ON dfpl_fplid = fpl_fplid
    WHERE Knt_NieAktywny=0
 DELETE FROM #TempMobile
 WHERE Rank <= @packageSize * (@packageNumber - 1) OR Rank > @packageSize * @packageNumber
 SELECT * FROM #TempMobile
 DROP TABLE #TempMobile
END
else
BEGIN
    SELECT DISTINCT
                IDENTITY(INT,1,1) As Rank,
                Knt_KntId,
                case when Knt_LimitFlag = 1 then 2 else 0 end as Knt_LimitTerminowy, /*0-nieograniczony 1-terminowy 2-bezterminowy*/
                Knt_LimitKredytu as Knt_MaxLimitWart,
                case when knt_limitprzeterkredytflag = 1 then Knt_LimitPrzeterKredytWartosc else case when Knt_LimitFlag = 1 then Knt_LimitKredytu else Knt_LimitPrzeterKredytWartosc end end as Knt_KwotaDozwolonaPoTerminie,
                null as Knt_KwotaDoWykorzystaniaZS,
                case when Knt_LimitFlag = 1 then case when Knt_LimitKredytu - Knt_LimitKredytuWykorzystany > 0 then(Knt_LimitKredytu - Knt_LimitKredytuWykorzystany)else 0 end else null end as Knt_KwotaDoWykorzystaniaFS,
                null as Knt_KwotaDoWykorzystaniaWZ,
                0 as Knt_IstniejaPlatnosciPrzeterminowane,
                null as Knt_KwotaPrzeterminowanaZS,
                case when knt_limitprzeterkredytflag = 1 then ISNULL(cdn.Mobile_EksportKntZal (Knt_KntId,GETDATE()-1),0) else 0 end as Knt_KwotaPrzeterminowanaFS,
                null as Knt_KwotaPrzeterminowanaWZ,
                null as Knt_DataWygasniecia
  INTO #TempMobile1
  FROM CDN.Kontrahenci
        LEFT JOIN cdn.detalformyplatnosci ON Knt_FplId = dfpl_fplid and @ID =dfpl_dstaid
        LEFT JOIN cdn.formyplatnosci ON dfpl_fplid = fpl_fplid
    WHERE Knt_NieAktywny=0  AND Knt_Grupa = @KntGrupa
 DELETE FROM #TempMobile1
 WHERE Rank <= @packageSize * (@packageNumber - 1) OR Rank > @packageSize * @packageNumber
 SELECT * FROM #TempMobile1
 DROP TABLE #TempMobile1
END
END
