CREATE  PROCEDURE [CDN].[ESKLEP_EksportMarki]
  @ID INT      -- ID e-sklepu
 ,@TypExp INT  -- Typ eksportu (0 - różnicowy, 1 - pełny)
AS
BEGIN
 DECLARE
     @TSSynchr         nvarchar(254),
     @DateTSSynchr     DATETIME
 select @TSSynchr =  ESS_TS_SynchroTwrPotw from cdn.eSklepStanowiska where ESS_IdISklep = @ID
 --IF not exists (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836) SELECT @TSSynchr = 0 ELSE SELECT @TSSynchr = Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer = 1836
 SELECT  @DateTSSynchr = dateadd( second, CONVERT(INT,@TSSynchr),CONVERT(DATETIME,'1990-01-01',120))
 SELECT
Mrk_MrkId as MrkID,
Mrk_PrdId as PdrID,
Mrk_Nazwa as MarkaNazwa,
Mrk_Logo as MarkaLogo,
( select [@MrkID]=MrkJ_MrkID , [@JezykID] = MrkJ_JezykID , [@Opis] = MrkJ_OpisHTML,[@OpisKrotki] = MrkJ_OpisKrotki,
[@PSTitle] = MrkJ_MetaTytul,[@PSKluczowe] = MrkJ_MetaSlowaKluczowe,[@POpis] = MrkJ_MetaOpis,[@NazwaNag] = MrkJ_NazwaNag
from cdn.MarkiJezykObcy where MrkJ_MrkID = Mrk_MrkId for xml  PATH('MRKJ') ,root ('MRKJI'),TYPE )
from cdn.Marki as MRK
 WHERE Mrk_TS_Mod > CASE WHEN @TypExp=0 THEN @DateTSSynchr ELSE 0 END
FOR XML AUTO
END
