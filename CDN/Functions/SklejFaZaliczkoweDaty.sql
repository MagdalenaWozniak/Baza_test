create  FUNCTION CDN.SklejFaZaliczkoweDaty ( @Id INT)
RETURNS NVARCHAR(255)
AS
BEGIN
DECLARE @Wynik NVARCHAR(4000);
DECLARE @DataDok NVARCHAR(15);
SET @Wynik ='';
DECLARE Elementy_ZAL CURSOR FAST_FORWARD FOR
select convert(NVARCHAR(10),CASE  WHEN BZp_DataDok is null
THEN B.BZd_DataReal ELSE BZp_DataDok END ,120)from cdn.TraNag join CDN.BnkZdarzenia as A on A.BZd_DokumentTyp = 1 and A.BZd_DokumentID = Trn_TrnID left outer join CDN.BnkRozRelacje on BRR_ZDokID = BZD_BzdID left outer join
CDN.BnkZapisy on Bzp_BzpID = BRR_DDokID and BRR_DDokTyp =2 left outer join CDN.BnkZdarzenia as B on B.Bzd_BzdID = BRR_DDokID and BRR_DDokTyp =1 where BRR_ZDokTyp = 1
and  trn_trnid = @Id
group by convert(NVARCHAR(10),CASE  WHEN BZp_DataDok is null THEN B.BZd_DataReal ELSE BZp_DataDok END ,120)
 OPEN Elementy_ZAL;
WHILE 1 = 1 BEGIN
FETCH NEXT FROM Elementy_ZAL  INTO @DataDok;
IF @@FETCH_STATUS <> 0 BREAK;
SET @Wynik = @Wynik + @DataDok + ', ';
END;
CLOSE Elementy_ZAL;
DEALLOCATE Elementy_ZAL;
  RETURN @Wynik
END
