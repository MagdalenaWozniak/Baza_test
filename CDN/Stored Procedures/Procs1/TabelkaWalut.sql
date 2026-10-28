-- Generowanie tabelki walut według domyślego typu kursu
CREATE Procedure [CDN].[TabelkaWalut]
@Dzien NVARCHAR(10)
AS
SET NOCOUNT ON;
DECLARE @fulldbname nvarchar(300)
SET @fulldbname = CDN.BazaKonfiguracyjna()
DECLARE @Query1  nvarchar(4000)
SET @Query1 =N'
SELECT  NotowaniaA.WNo_KursL / NotowaniaA.WNo_KursM as Notowanie, NotowaniaB.WNa_Symbol, NotowaniaA.WNo_NrTabeli
   FROM '+@fulldbname+'.CDN.Walnotowania as NotowaniaA
   JOIN
    (SELECT
     (SELECT TOP 1 WNo_WnoId FROM '+@fulldbname+'.CDN.Walnotowania as Kurs
      WHERE Kurs.wno_wnaid=wna_wnaID
       AND Kurs.wno_wkuID=WkuID
       AND Kurs.wno_tstamp <= CONVERT( datetime , '''+ CONVERT ( NVARCHAR(10) ,  @Dzien , 120 ) +  ''' , 120)
       ORDER BY wno_tstamp DESC) AS NotowanieId
    ,WNa_Symbol, Wku_WkuId, Wku_Symbol
    FROM '+@fulldbname+'.CDN.WALNAZWY
     CROSS JOIN (SELECT 0 as WKu_WKuID, '''' as WKu_Symbol, WKu_Nazwa, WKu_URL, WKu_NieAktywny, WKu_TS_Export,
        WKu_OpeZalID, WKu_StaZalId, WKu_TS_Zal, WKu_OpeModID, WKu_StaModId ,  WKu_WKuID as  WkuID
        FROM '+@fulldbname+'.CDN.WALKURSY WHERE WKu_WKuID = (SELECT Kon_Wartosc FROM '+@fulldbname+'.CDN.Konfig WHERE Kon_Numer = 260)
        ) AS KursyZDomyslnym
    ) AS NotowaniaB ON NotowaniaA.WNo_WnoId = NotowaniaB.NotowanieId'
Set NoCount Off
Execute dbo.sp_executesql @Query1
