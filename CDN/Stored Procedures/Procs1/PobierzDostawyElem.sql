CREATE PROCEDURE  [CDN].[PobierzDostawyElem]  @TreOrgId INT
AS
BEGIN
  --SET NOCOUNT ON
  --SET NOCOUNT OFF
if exists (SELECT PdE_TrEIdRWS FROM CDN.ProdElem WHERE PdE_TrEIdRWS = @TreOrgId)
    SELECT TsD_TsDID
      ,TsD_TrSID
      ,TsD_TrEId
   ,TsD_PdEId
      ,TsD_TrSIdDost
      ,TsD_ZwrId
      ,TsD_NumerPelny
      ,TsD_NumerObcy
      ,TsD_DataOpe
      ,TsD_Dostawca
      ,TsD_Ilosc
      ,TsD_IloscDostepna
      ,TsD_Wartosc
      ,TsD_Cecha1_DeAId
      ,TsD_Cecha1_Format
      ,TsD_Cecha1_Kod
      ,TsD_Cecha1_Wartosc
      ,TsD_Cecha2_DeAId
      ,TsD_Cecha2_Format
      ,TsD_Cecha2_Kod
      ,TsD_Cecha2_Wartosc
      ,TsD_Cecha3_DeAId
      ,TsD_Cecha3_Format
      ,TsD_Cecha3_Kod
      ,TsD_Cecha3_Wartosc
      ,TsD_Cecha4_DeAId
      ,TsD_Cecha4_Format
      ,TsD_Cecha4_Kod
      ,TsD_Cecha4_Wartosc
      ,TsD_Cecha5_DeAId
      ,TsD_Cecha5_Format
      ,TsD_Cecha5_Kod
      ,TsD_Cecha5_Wartosc
      ,TsD_Cecha6_DeAId
      ,TsD_Cecha6_Format
      ,TsD_Cecha6_Kod
      ,TsD_Cecha6_Wartosc
      ,TsD_Cecha7_DeAId
      ,TsD_Cecha7_Format
      ,TsD_Cecha7_Kod
      ,TsD_Cecha7_Wartosc
      ,TsD_Cecha8_DeAId
      ,TsD_Cecha8_Format
      ,TsD_Cecha8_Kod
      ,TsD_Cecha8_Wartosc
      ,TsD_Cecha9_DeAId
      ,TsD_Cecha9_Format
      ,TsD_Cecha9_Kod
      ,TsD_Cecha9_Wartosc
      ,TsD_Cecha10_DeAId
      ,TsD_Cecha10_Format
      ,TsD_Cecha10_Kod
      ,TsD_Cecha10_Wartosc
   ,round(TsD_Ilosc, 4) AS TsD_IloscOrg
   FROM CDN.TraSElemDost
   join CDN.ProdElem on TsD_PdEId = PdE_PdEId
   WHERE PdE_TrEIdRWS = @TreOrgId
else
begin
IF EXISTS(SELECT TsD_Ilosc FROM CDN.TraSElemDost WHERE TsD_TrEID=@TreOrgId)
    SELECT TsD_TsDID
      ,TsD_TrSID
      ,TsD_TrEId
      ,TsD_TrSIdDost
      ,TsD_ZwrId
      ,TsD_NumerPelny
      ,TsD_NumerObcy
      ,TsD_DataOpe
      ,TsD_Dostawca
      ,TsD_Ilosc
      ,TsD_IloscDostepna
      ,TsD_Wartosc
      ,TsD_Cecha1_DeAId
      ,TsD_Cecha1_Format
      ,TsD_Cecha1_Kod
      ,TsD_Cecha1_Wartosc
      ,TsD_Cecha2_DeAId
      ,TsD_Cecha2_Format
      ,TsD_Cecha2_Kod
      ,TsD_Cecha2_Wartosc
      ,TsD_Cecha3_DeAId
      ,TsD_Cecha3_Format
      ,TsD_Cecha3_Kod
      ,TsD_Cecha3_Wartosc
      ,TsD_Cecha4_DeAId
      ,TsD_Cecha4_Format
      ,TsD_Cecha4_Kod
      ,TsD_Cecha4_Wartosc
      ,TsD_Cecha5_DeAId
      ,TsD_Cecha5_Format
      ,TsD_Cecha5_Kod
      ,TsD_Cecha5_Wartosc
      ,TsD_Cecha6_DeAId
      ,TsD_Cecha6_Format
      ,TsD_Cecha6_Kod
      ,TsD_Cecha6_Wartosc
      ,TsD_Cecha7_DeAId
      ,TsD_Cecha7_Format
      ,TsD_Cecha7_Kod
      ,TsD_Cecha7_Wartosc
      ,TsD_Cecha8_DeAId
      ,TsD_Cecha8_Format
      ,TsD_Cecha8_Kod
      ,TsD_Cecha8_Wartosc
      ,TsD_Cecha9_DeAId
      ,TsD_Cecha9_Format
      ,TsD_Cecha9_Kod
      ,TsD_Cecha9_Wartosc
      ,TsD_Cecha10_DeAId
      ,TsD_Cecha10_Format
      ,TsD_Cecha10_Kod
      ,TsD_Cecha10_Wartosc
      ,round(TsD_Ilosc*(TrE_JMPrzelicznikL/TrE_JMPrzelicznikM),4) AS TsD_IloscOrg FROM CDN.TraSElemDost
    JOIN CDN.TraElem ON TrE_TrEId = TsD_TrEID
    WHERE TsD_TrEID=@TreOrgId and TsD_PdEId = 0 order by TsD_DataOpe,Tsd_TrsIdDost
ELSE
    IF EXISTS(
    SELECT  TsD_TsDID
    FROM CDN.TraElem a
    JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID
    JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow
    JOIN CDN.TraSElemDost TraSElemDost on b.TrE_TrEID = TsD_TrEID
    JOIN (SELECT TsD_TrsIdDost,sum(tsd_ilosc) AS ilosc FROM CDN.traelem a
          JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID
          JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow
          JOIN CDN.TraSElemDost TraSElemDost on b.TrE_TrEID = TsD_TrEID
          WHERE a.TrE_TrEID = @TreOrgId  and TsD_PdEId = 0 AND a.TrE_TypDokumentu <> 322 AND NOT(TrR_FaTyp = 301 AND TrR_TrNTyp =302) AND NOT(TrR_FaTyp = 307 AND TrR_TrNTyp =306) AND NOT(TrR_FaTyp = 306 AND TrR_TrNTyp =307) AND NOT(TrR_FaTyp = 302 AND TrR_TrNTyp =301)
          GROUP BY TsD_TrsIdDost) AS z ON z.TsD_TrsIdDost = TraSElemDost.TsD_TrsIdDost
    WHERE a.TrE_TrEID = @TreOrgId and z.ilosc > 0 and a.TrE_TypDokumentu NOT IN (313,314))
   SELECT MAX(TsD_TsDID) as TsD_TsDID,MAX( TsD_TrSID ) as TsD_TrSID,z.ID as Tsd_TrEId,MAX( TsD_ZwrId ) as TsD_ZwrId,
           MAX(TraSElemDost.TsD_TrsIdDost) as TsD_TrsIdDost,case when MIN( TsD_NumerPelny ) = ''  then  MIN( TrN_NumerPelny ) else MIN( TsD_NumerPelny )  end as TsD_NumerPelny,
           MAX( TsD_NumerObcy ) as TsD_NumerObcy,MAX( TsD_DataOpe ) as TsD_DataOpe,MAX( TsD_Dostawca ) as TsD_Dostawca,
           MAX(z.ilosc) as TsD_Ilosc ,MAX( TsD_IloscDostepna ) as TsD_IloscDostepna,MAX( TsD_Wartosc ) as TsD_Wartosc,
           MAX( TsD_Cecha1_DeAId ) as TsD_Cecha1_DeAId,MAX( TsD_Cecha1_Format ) as TsD_Cecha1_Format,MAX( TsD_Cecha1_Kod ) as TsD_Cecha1_Kod,MAX( TsD_Cecha1_Wartosc ) as TsD_Cecha1_Wartosc,
           MAX( TsD_Cecha2_DeAId ) as TsD_Cecha2_DeAId,MAX( TsD_Cecha2_Format ) as TsD_Cecha2_Format,MAX( TsD_Cecha2_Kod ) as TsD_Cecha2_Kod,MAX( TsD_Cecha2_Wartosc ) as TsD_Cecha2_Wartosc,
           MAX( TsD_Cecha3_DeAId ) as TsD_Cecha3_DeAId,MAX( TsD_Cecha3_Format ) as TsD_Cecha3_Format,MAX( TsD_Cecha3_Kod ) as TsD_Cecha3_Kod,MAX( TsD_Cecha3_Wartosc ) as TsD_Cecha3_Wartosc,
           MAX( TsD_Cecha4_DeAId ) as TsD_Cecha4_DeAId,MAX( TsD_Cecha4_Format ) as TsD_Cecha4_Format,MAX( TsD_Cecha4_Kod ) as TsD_Cecha4_Kod,MAX( TsD_Cecha4_Wartosc ) as TsD_Cecha4_Wartosc,
           MAX( TsD_Cecha5_DeAId ) as TsD_Cecha5_DeAId,MAX( TsD_Cecha5_Format ) as TsD_Cecha5_Format,MAX( TsD_Cecha5_Kod ) as TsD_Cecha5_Kod,MAX( TsD_Cecha5_Wartosc ) as TsD_Cecha5_Wartosc,
           MAX( TsD_Cecha6_DeAId ) as TsD_Cecha6_DeAId,MAX( TsD_Cecha6_Format ) as TsD_Cecha6_Format,MAX( TsD_Cecha6_Kod ) as TsD_Cecha6_Kod,MAX( TsD_Cecha6_Wartosc ) as TsD_Cecha6_Wartosc,
           MAX( TsD_Cecha7_DeAId ) as TsD_Cecha7_DeAId,MAX( TsD_Cecha7_Format ) as TsD_Cecha7_Format,MAX( TsD_Cecha7_Kod ) as TsD_Cecha7_Kod,MAX( TsD_Cecha7_Wartosc ) as TsD_Cecha7_Wartosc,
           MAX( TsD_Cecha8_DeAId ) as TsD_Cecha8_DeAId,MAX( TsD_Cecha8_Format ) as TsD_Cecha8_Format,MAX( TsD_Cecha8_Kod ) as TsD_Cecha8_Kod,MAX( TsD_Cecha8_Wartosc ) as TsD_Cecha8_Wartosc,
           MAX( TsD_Cecha9_DeAId ) as TsD_Cecha9_DeAId,MAX( TsD_Cecha9_Format ) as TsD_Cecha9_Format,MAX( TsD_Cecha9_Kod ) as TsD_Cecha9_Kod,MAX( TsD_Cecha9_Wartosc ) as TsD_Cecha9_Wartosc,
           MAX( TsD_Cecha10_DeAId ) as TsD_Cecha10_DeAId,MAX( TsD_Cecha10_Format ) as TsD_Cecha10_Format,MAX( TsD_Cecha10_Kod ) as TsD_Cecha10_Kod,MAX( TsD_Cecha10_Wartosc ) as TsD_Cecha10_Wartosc
    FROM CDN.TraElem a
    JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID
    JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow
    JOIN CDN.TraNag on TrN_TrNId = b.tre_trnid
    JOIN CDN.TraSElemDost TraSElemDost on b.TrE_TrEID = TsD_TrEID
    JOIN (
select TsD_TrsIdDost, sum(tsd_ilosc) as ilosc,ID from
(SELECT TsD_TrsIdDost, tsd_ilosc, b.tre_zwrid as ID FROM CDN.traelem a
          JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID
          JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow
          JOIN CDN.TraSElemDost TraSElemDost on b.TrE_TrEID = TsD_TrEID and TsD_PdEId = 0
          WHERE a.TrE_TrEID = @TreOrgId AND a.TrE_TypDokumentu <> 322 and tsd_zwrid is not null
union all
SELECT TsD_TrsIdDost,tsd_ilosc,b.tre_treid  as ID FROM CDN.traelem a
          JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID
          JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow  and b.TrE_TypDokumentu != 304
          JOIN CDN.TraSElemDost TraSElemDost on b.TrE_TrEID = TsD_TrEID and TsD_PdEId = 0
          WHERE a.TrE_TrEID = @TreOrgId AND a.TrE_TypDokumentu <> 322 and tsd_zwrid is null
)as y
          GROUP BY y.ID, y.TsD_TrsIdDost
) AS z ON z.TsD_TrsIdDost = TraSElemDost.TsD_TrsIdDost
    WHERE a.TrE_TrEID = @TreOrgId and z.ilosc > 0 and a.TrE_TypDokumentu NOT IN (313,314)
    GROUP BY  z.ID,TraSElemDost.TsD_TrsIdDost,TsD_DataOpe
    order by TsD_DataOpe,TraSElemDost.TsD_TrsIdDost
    else
    SELECT TsD_TsDID
      ,TsD_TrSID
      ,TsD_TrEId
      ,TsD_TrSIdDost
      ,TsD_ZwrId
      ,TsD_NumerPelny
      ,TsD_NumerObcy
      ,TsD_DataOpe
      ,TsD_Dostawca
      ,TsD_Ilosc
      ,TsD_IloscDostepna
      ,TsD_Wartosc
      ,TsD_Cecha1_DeAId
      ,TsD_Cecha1_Format
      ,TsD_Cecha1_Kod
      ,TsD_Cecha1_Wartosc
      ,TsD_Cecha2_DeAId
      ,TsD_Cecha2_Format
      ,TsD_Cecha2_Kod
      ,TsD_Cecha2_Wartosc
      ,TsD_Cecha3_DeAId
      ,TsD_Cecha3_Format
      ,TsD_Cecha3_Kod
      ,TsD_Cecha3_Wartosc
      ,TsD_Cecha4_DeAId
      ,TsD_Cecha4_Format
      ,TsD_Cecha4_Kod
      ,TsD_Cecha4_Wartosc
      ,TsD_Cecha5_DeAId
      ,TsD_Cecha5_Format
      ,TsD_Cecha5_Kod
      ,TsD_Cecha5_Wartosc
      ,TsD_Cecha6_DeAId
      ,TsD_Cecha6_Format
      ,TsD_Cecha6_Kod
      ,TsD_Cecha6_Wartosc
      ,TsD_Cecha7_DeAId
      ,TsD_Cecha7_Format
      ,TsD_Cecha7_Kod
      ,TsD_Cecha7_Wartosc
      ,TsD_Cecha8_DeAId
      ,TsD_Cecha8_Format
      ,TsD_Cecha8_Kod
      ,TsD_Cecha8_Wartosc
      ,TsD_Cecha9_DeAId
      ,TsD_Cecha9_Format
      ,TsD_Cecha9_Kod
      ,TsD_Cecha9_Wartosc
      ,TsD_Cecha10_DeAId
      ,TsD_Cecha10_Format
      ,TsD_Cecha10_Kod
      ,TsD_Cecha10_Wartosc
   ,round(TsD_Ilosc, 4) AS TsD_IloscOrg
   FROM CDN.TraSElemDost WHERE TsD_TrEID=@TreOrgId  and TsD_PdEId = 0
END
END
