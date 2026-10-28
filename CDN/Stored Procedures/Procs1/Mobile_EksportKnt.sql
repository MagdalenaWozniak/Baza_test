CREATE Procedure [CDN].[Mobile_EksportKnt]
@ID           INT, -- ID centrum praw struktury firmy - id mobilnego sprzedawcy
@TypEksportu  INT, -- Typ eksportu (0 - różnicowy, 1 - pełny)
@PackageSize   INT, -- rozmiar paczki
@PackageNumber INT -- numer paczki
AS
BEGIN
SET NOCOUNT ON
DECLARE
@DSta_TS_SynchroKNT  DATETIME,
@FplId int,
@KntGrupa NVARCHAR(20)
        UPDATE CDN.DetalStanowiska SET Dsta_TS_SynchroKnt = GetDate() WHERE DSta_DStaID=@ID
  select @DSta_TS_SynchroKnt = DSta_TS_SynchroKntPotw, @KntGrupa = DSta_KntGrupa FROM CDN.DetalStanowiska  WHERE DSta_DStaId = @ID
  select @FplId =dfpl_fplid  from cdn.detalformyplatnosci
  where Dfpl_Dstaid = @ID and  Dfpl_Domyslna = 1
  ORDER BY Dfpl_dfplid
  if @KntGrupa = ''
BEGIN
        SELECT
    DISTINCT
    IDENTITY(INT,1,1) AS Rank,
                Knt_KntId,
                0  As Knt_Typ, --typ kontrahenta
                Knt_Kod,
                ISNULL(Knt_Nazwa1,'') as Knt_Nazwa1,
                ISNULL(Knt_Nazwa2,'') as Knt_Nazwa2,
                ISNULL(Knt_Nazwa3,'') as Knt_Nazwa3,
                Knt_KodPocztowy,
                Knt_Miasto,
                Knt_Wojewodztwo,
                Knt_Ulica + ' ' + Knt_NrDomu + case when Knt_NrLokalu <>'' then '/' else '' end + Knt_NrLokalu as Knt_Ulica,
                Knt_NipE,
                Knt_NipKraj,
                Knt_Regon,
                Knt_Pesel,
                Knt_Telefon1,
                Knt_Telefon2,
                Knt_Fax,
                Knt_Email,
                Knt_URL,
                '' As Knt_GSM,
                Knt_PodatekVat,
                0 As Knt_LastTransLockDate,
                999 as Knt_MaxZwloka,
               case when dfpl_fplid is null then @FplId else dfpl_fplid end as Knt_FplId,
               case when dfpl_fplid is null then 0 else case when Knt_TerminPlat = 1 then Knt_Termin else fpl_termin end end as Knt_LimitOkres,
               case when Knt_ceny = 1 then 0 else Knt_ceny end as Knt_Cena,
               0 as Knt_SposobDst,
               knt_finalny
INTO #TempMobile1
        FROM CDN.Kontrahenci
        LEFT JOIN cdn.detalformyplatnosci ON Knt_FplId = dfpl_fplid and @ID =dfpl_dstaid
        LEFT JOIN cdn.formyplatnosci ON dfpl_fplid = fpl_fplid
    WHERE Knt_NieAktywny=0
          AND Knt_TS_Mod > CASE WHEN @TypEksportu=0 THEN @DSta_TS_SynchroKnt ELSE 0 END
 DELETE FROM #TempMobile1
 WHERE Rank <= @packageSize * (@packageNumber - 1) OR Rank > @packageSize * @packageNumber
 SELECT * FROM #TempMobile1
 DROP TABLE #TempMobile1
END
else
BEGIN
        SELECT
    DISTINCT
    IDENTITY(INT,1,1) AS Rank,
                Knt_KntId,
                0  As Knt_Typ, --typ kontrahenta
                Knt_Kod,
                ISNULL(Knt_Nazwa1,'') as Knt_Nazwa1,
                ISNULL(Knt_Nazwa2,'') as Knt_Nazwa2,
                ISNULL(Knt_Nazwa3,'') as Knt_Nazwa3,
                Knt_KodPocztowy,
                Knt_Miasto,
                Knt_Wojewodztwo,
                Knt_Ulica + ' ' + Knt_NrDomu + case when Knt_NrLokalu <>'' then '/' else '' end + Knt_NrLokalu as Knt_Ulica,
                Knt_NipE,
                Knt_NipKraj,
                Knt_Regon,
                Knt_Pesel,
                Knt_Telefon1,
                Knt_Telefon2,
                Knt_Fax,
                Knt_Email,
                Knt_URL,
                '' As Knt_GSM,
                Knt_PodatekVat,
                0 As Knt_LastTransLockDate,
                999 as Knt_MaxZwloka,
               case when dfpl_fplid is null then @FplId else dfpl_fplid end as Knt_FplId,
               case when dfpl_fplid is null then 0 else case when Knt_TerminPlat = 1 then Knt_Termin else fpl_termin end end as Knt_LimitOkres,
               case when Knt_ceny = 1 then 0 else Knt_ceny end as Knt_Cena,
               0 as Knt_SposobDst,
               knt_finalny
INTO #TempMobile2
        FROM CDN.Kontrahenci
        LEFT JOIN cdn.detalformyplatnosci ON Knt_FplId = dfpl_fplid and @ID =dfpl_dstaid
        LEFT JOIN cdn.formyplatnosci ON dfpl_fplid = fpl_fplid
    WHERE Knt_NieAktywny=0
          AND Knt_TS_Mod > CASE WHEN @TypEksportu=0 THEN @DSta_TS_SynchroKnt ELSE 0 END
          AND (Knt_Grupa = @KntGrupa or Knt_KntId = 1)
 DELETE FROM #TempMobile2
 WHERE Rank <= @packageSize * (@packageNumber - 1) OR Rank > @packageSize * @packageNumber
 SELECT * FROM #TempMobile2
 DROP TABLE #TempMobile2
END
SET NOCOUNT OFF
END
