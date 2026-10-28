CREATE  PROCEDURE [CDN].[ESKLEP_EksportRabatyNew]
  @ID INT      -- ID e-sklepu
AS
BEGIN
SET NOCOUNT ON
DECLARE @ESSID  INT,
  @sqltxt           NVARCHAR (1000),
  @WalutaKoncowa    nvarchar(3),
  @TmpSrvName       SYSNAME,
  @ServerCfgString  nvarchar(512),
  @BazaCfgString    nvarchar(512),
  @WalOstrzegaj     nvarchar(3),
     @KursLWalutaKoncowa                DECIMAL(15,4),
     @KursMWalutaKoncowa                DECIMAL(5,0),
     @TrN_DataDokChar  nvarchar(25),
  @ZaokraglenieCen smallint
CREATE TABLE #Rabaty (Rab_RabId INT, Rab_Typ INT, Rab_TypCenyNB SMALLINT, Rab_TwrId INT, Rab_PodmiotId INT, Rab_RabatiSKlep DECIMAL(17,4), Rab_CenaNetto DECIMAL(17,4), Rab_CenaBrutto DECIMAL(17,4) , Rab_Grupa nvarchar(20) null default null )
CREATE TABLE #Notowania  ( Systemowa TINYINT, Waluta nvarchar(3), KursNumer INT, KursL DECIMAL(15,4), KursM DECIMAL(5,0), Brak TINYINT )
SELECT  @WalutaKoncowa = ESS_DomyslnaWaluta  from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 set @ZaokraglenieCen = 2
 SELECT @TmpSrvName = CAST ( SERVERPROPERTY ('MachineName') AS SYSNAME )
 SELECT @ServerCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1001
 SELECT @BazaCfgString =sys_wartosc FROM cdn.systemcdn where sys_id = 1002
 SELECT @TrN_DataDokChar    = CONVERT(nvarchar(25), GETDATE(), 102)
  -- 1 = "Pobieraj ostatnio ustalony kurs waluty (nie ostrzegaj o zmianie kursu)"
  IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540 )
    SELECT @WalOstrzegaj=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1540
  ELSE
    SELECT @WalOstrzegaj=1
  IF CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME  ) <> ''
    SET @TmpSrvName = @TmpSrvName + '\' + CAST ( SERVERPROPERTY ('InstanceName') AS SYSNAME )
  SET @sqltxt = 'EXEC ['
  IF @ServerCfgString <> @TmpSrvName
    SET @sqltxt = @sqltxt + @ServerCfgString +'].['
  SET @sqltxt = @sqltxt + @BazaCfgString+'].CDN.PobierzNotowania '''', 2,'''+ @TrN_DataDokChar+''','+ @WalOstrzegaj+''
  INSERT INTO  #Notowania  ( Systemowa,         Waluta ,           KursNumer,     KursL,               KursM             , Brak         )
  EXEC sp_executesql @sqltxt
  --IF NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849) SELECT @WalutaKoncowa = '' ELSE SELECT @WalutaKoncowa = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1849
  IF @WalutaKoncowa = ''
 SELECT @KursLWalutaKoncowa = 1,@KursMWalutaKoncowa =1
  ELSE
 SELECT @KursLWalutaKoncowa = KursL,@KursMWalutaKoncowa =KursM FROM #Notowania WHERE Waluta = @WalutaKoncowa
SELECT @ESSID = ESS_ESSID FROM cdn.eSklepStanowiska WHERE ESS_IdISklep = @ID
INSERT INTO #Rabaty (Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep)
SELECT distinct Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep FROM cdn.Rabaty
JOIN CDN.Grupy ON Gru_GruID  = Rab_PodmiotId AND GrU_Typ = 31
--JOIN CDN.Kontrahenci ON Gru_Nazwa = Knt_Grupa
WHERE Rab_Typ = 1 AND Rab_RabatISklep > 0 AND Rab_PodmiotTyp = 1  and exists (select Knt_kntid  from cdn.Kontrahenci left join cdn.KntESklepy on Knt_KntID = KES_KntID where Knt_Grupa = Gru_Nazwa and ISNULL(KES_KntID,0) > 0)
INSERT INTO #Rabaty (Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep)
SELECT distinct Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep FROM cdn.Rabaty
JOIN Cdn.eSklepKntRelacje ON Rab_PodmiotId = ESK_KntOptimaID
WHERE
Rab_Typ = 2 AND Rab_RabatISklep > 0 AND Rab_PodmiotTyp = 1 AND ESK_eSklepID = @ESSID
INSERT INTO #Rabaty (Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep)
SELECT distinct Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep FROM cdn.Rabaty
JOIN CDN.Grupy ON Gru_GruID  = Rab_PodmiotId AND GrU_Typ = 31
--JOIN CDN.Kontrahenci ON Gru_Nazwa = Knt_Grupa
WHERE Rab_Typ = 3 AND Rab_RabatISklep > 0 AND Rab_PodmiotTyp = 1  and exists (select Knt_kntid  from cdn.Kontrahenci left join cdn.KntESklepy on Knt_KntID = KES_KntID where Knt_Grupa = Gru_Nazwa and  ISNULL(KES_KntID,0) > 0)
INSERT INTO #Rabaty (Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep)
SELECT distinct Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep FROM cdn.Rabaty
JOIN CDN.Grupy ON Gru_GruID  = Rab_PodmiotId AND GrU_Typ = 31
JOIN CDN.Towary ON Twr_TwrId = Rab_TwrId
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
WHERE Rab_Typ = 4 AND Rab_RabatISklep > 0 AND Rab_PodmiotTyp = 1  AND  Twes_Udostepnij=1 AND
EXISTS (SELECT Knt_KntId FROM CDN.Kontrahenci  left join cdn.KntESklepy on Knt_KntID = KES_KntID  WHERE Knt_Grupa = Gru_Nazwa AND ISNULL(KES_KntID,0) > 0)
INSERT INTO #Rabaty (Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep)
SELECT distinct  Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep
FROM cdn.Rabaty
JOIN Cdn.eSklepKntRelacje ON Rab_PodmiotId = ESK_KntOptimaID
WHERE
Rab_Typ = 5 AND Rab_RabatISklep > 0 AND Rab_PodmiotTyp = 1 AND ESK_eSklepID = @ESSID
INSERT INTO #Rabaty (Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep)
SELECT  distinct Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep
FROM cdn.rabaty
JOIN Cdn.eSklepKntRelacje ON Rab_PodmiotId = ESK_KntOptimaID
JOIN cdn.towary  ON Rab_TwrId = Twr_TwrId
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
WHERE
Rab_Typ = 6 AND  Rab_RabatISklep > 0 AND Twes_Udostepnij = 1 AND Rab_PodmiotTyp = 1 AND ESK_eSklepID = @ESSID
INSERT INTO #Rabaty (Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep)
SELECT  distinct Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep
FROM cdn.rabaty
WHERE
Rab_Typ = 7 AND  Rab_RabatISklep > 0
INSERT INTO #Rabaty (Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep)
SELECT  distinct Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId, Rab_RabatISklep FROM cdn.Rabaty
JOIN cdn.towary  ON Rab_TwrId = Twr_TwrId
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
WHERE
Rab_Typ = 8 AND  Rab_RabatISklep > 0 AND Twes_Udostepnij = 1
INSERT INTO #Rabaty (Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId,  Rab_CenaNetto, Rab_CenaBrutto )
SELECT  distinct Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId,
CDN.CenaBruttoPrecyzja(Rab_Cena,Rab_TypCenyNB+2  ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa, case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),
 CDN.CenaBruttoPrecyzja(Rab_Cena,Rab_TypCenyNB  ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
    FROM cdn.Rabaty JOIN cdn.towary  ON Rab_TwrId = Twr_TwrId  LEFT OUTER JOIN #Notowania ON Rab_Waluta = Waluta
 LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
 WHERE Rab_Typ = 11 AND Twes_Udostepnij = 1
INSERT INTO #Rabaty (Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId,  Rab_CenaNetto, Rab_CenaBrutto , Rab_Grupa)
select distinct
Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId ,
CDN.CenaBruttoPrecyzja(Rab_Cena,Rab_TypCenyNB+2  ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),
CDN.CenaBruttoPrecyzja(Rab_Cena,Rab_TypCenyNB  ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),
Grupa = Gru_Nazwa
from
     cdn.Rabaty
JOIN cdn.towary  ON Rab_TwrId = Twr_TwrId
join cdn.grupy on Rab_PodmiotId=Gru_GruID  and Gru_Typ = 31 and Rab_PodmiotTyp is null
join cdn.Kontrahenci b on Knt_Grupa = Gru_Nazwa
join cdn.eSklepKntRelacje on knt_kntid = ESK_KntOptimaID
LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = ESK_eSklepID
LEFT OUTER JOIN #Notowania ON Rab_Waluta = Waluta
WHERE Rab_Typ = 12 AND  Twes_Udostepnij = 1 AND ESK_eSklepID = @ESSID
INSERT INTO #Rabaty (Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId,  Rab_CenaNetto, Rab_CenaBrutto)
SELECT  distinct Rab_RabId, Rab_Typ, Rab_TypCenyNB, Rab_TwrId, Rab_PodmiotId,
 CDN.CenaBruttoPrecyzja(Rab_Cena,Rab_TypCenyNB+2  ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end),
 CDN.CenaBruttoPrecyzja(Rab_Cena,Rab_TypCenyNB  ,Twr_Stawka, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursL END, CASE WHEN KursL IS NULL OR KursM IS NULL THEN 1 ELSE KursM END , @KursLWalutaKoncowa , @KursMWalutaKoncowa,case when Twr_CenaZCzteremaMiejscami = 1 then 4 else 2 end)
      FROM cdn.Rabaty
      JOIN Cdn.eSklepKntRelacje ON Rab_PodmiotId = ESK_KntOptimaID
      JOIN cdn.towary  ON Rab_TwrId = Twr_TwrId
      LEFT OUTER JOIN #Notowania ON Rab_Waluta = Waluta
   LEFT OUTER JOIN cdn.TwrESklep on Twr_TwrId = Twes_TwrID and Twes_eSklepID = @ESSID
 WHERE Rab_Typ = 13 AND  Twes_Udostepnij = 1 AND Rab_PodmiotTyp = 1 AND ESK_eSklepID = @ESSID
SELECT Rab_RabId AS [@ID], Rab_Typ AS [@Typ], Rab_TypCenyNB AS [@TypCena], Rab_TwrId AS [@TwrID], Rab_PodmiotId AS [@KntID], Rab_RabatISklep AS [@Rabat], Rab_CenaNetto AS [@CenaN], Rab_CenaBrutto AS [@CenaB] FROM #Rabaty
FOR XML PATH('RBT'), ROOT('RBTIOPT')
END
