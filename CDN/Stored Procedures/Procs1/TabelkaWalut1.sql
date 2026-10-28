create Procedure [CDN].[TabelkaWalut1]
@Dzien NVARCHAR(10)
AS
Set NoCount on
DECLARE @fulldbname nVARCHAR(300)
select @fulldbname = CDN.BazaKonfiguracyjna()
declare @Query1  nvarchar(4000)
set @Query1 =
N'select
NotowaniaA.WNo_KursL / NotowaniaA.WNo_KursM as Notowanie,
NotowaniaA.WNo_KursL , NotowaniaA.WNo_KursM,
NotowaniaB.WNa_Symbol,NotowaniaB.Wku_WkuId,
NotowaniaB.Wku_Symbol
from
'+@fulldbname+'.cdn.walnotowania as NotowaniaA
right outer join
(
select
( select top 1  WNo_WnoId   from
'+@fulldbname+'.cdn.walnotowania as Kurs
where
Kurs.wno_wnaid=wna_wnaID and
Kurs.wno_wkuID=WkuID
and Kurs.wno_tstamp <= CONVERT( datetime , '''+ CONVERT ( NVARCHAR(10) ,  @Dzien , 120 ) +  ''' , 120)
order by wno_tstamp desc
) AS NotowanieId
 ,WNa_Symbol,Wku_WkuId,Wku_Symbol
 from
'+@fulldbname+'.CDN.WALNAZWY cross join
(
select
 WKu_WKuID,
 WKu_Symbol, WKu_Nazwa, WKu_URL, WKu_NieAktywny,
 WKu_TS_Export, WKu_OpeZalID, WKu_StaZalId, WKu_TS_Zal,
 WKu_OpeModID, WKu_StaModId , WKu_WKuID as  WkuID
from
'+@fulldbname+'.CDN.WALKURSY
union '
+ 'select
0 as WKu_WKuID,
'''' as  WKu_Symbol, WKu_Nazwa, WKu_URL, WKu_NieAktywny,
WKu_TS_Export, WKu_OpeZalID, WKu_StaZalId, WKu_TS_Zal,
 WKu_OpeModID, WKu_StaModId ,  WKu_WKuID as  WkuID
 from
'+@fulldbname+'.CDN.WALKURSY where
 WKu_WKuID = '
+'(SELECT Kon_Wartosc FROM
'+@fulldbname+'.CDN.Konfig WHERE Kon_Numer = 260)
) as KursyZDomyslnym
) as NotowaniaB on NotowaniaA.WNo_WnoId = NotowaniaB.NotowanieId
'
Set NoCount Off
Execute dbo.sp_executesql @Query1
