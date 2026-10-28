CREATE Procedure [CDN].[UrlopBezp] @PrcId Int,  @Data DateTime,  @Nlata Int Output, @Nmies Int Output, @Ndni Int Output
AS
DECLARE
@NieobOd DATETIME
DECLARE  @NieobDo DATETIME
SET @Ndni = 0
SET @Nmies = 0
SET @Nlata = 0
DECLARE Tmp_Urlop CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
SELECT  PNB_OkresOd, PNB_OkresDO
 FROM CDN.PracNieobec
 INNER JOIN CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
 WHERE PNB_PraId = @PrcId and PNB_Tryb<>1 and TNB_PomnStazPracy = 1 and PNB_OkresDO<=@Data
 UNION
 SELECT PNB_OkresOd, @data
 FROM CDN.PracNieobec
 INNER JOIN CDN.TypNieobec on  PNB_TnbId = TNB_TnbId
 WHERE PNB_PraId = @PrcId and PNB_Tryb<>1 and TNB_PomnStazPracy = 1 and
 (PNB_OkresOD<=@Data and PNB_OkresDo > @data)
 OPEN Tmp_Urlop
 WHILE 1=1
BEGIN
 FETCH NEXT FROM Tmp_Urlop INTO  @NieobOd, @NieobDo
 IF @@FETCH_STATUS <> 0 BREAK
 BEGIN
  EXEC  [CDN].[StazCalc] @NieobOd, @NieobDo, @Nlata output, @Nmies output, @Ndni output
 END
 END
CLOSE  Tmp_Urlop
DEALLOCATE  Tmp_Urlop
