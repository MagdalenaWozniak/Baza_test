CREATE PROCEDURE [CDN].[KasujTowary]
AS
  SET NOCOUNT ON
update cdn.RemanentElem set ReE_TwrId = NULL where ReE_TwrId in
(select twr_twrid from cdn.towary where Twr_NieAktywny = 1 and ISNULL(Twr_GidFirma,0) != 1 --and ISNULL(Twr_GidFirma,0) != 2  zgłoszenie 148251
and not exists(select * from cdn.TraElem where tre_twrid = twr_twrid)
and not exists(select * from cdn.TraSElem where trs_twrid = twr_twrid)
and not exists(select * from cdn.PodArkuszInwenElem where PAE_TwrId = twr_twrid)
and not exists(select * from cdn.ProdElem where PdE_TwrId = twr_twrid)
and not exists(select * from cdn.ProdReceptury where PdR_TwrId = twr_twrid)
and not exists(select * from cdn.ProdSkladniki where PdS_TwrId = twr_twrid)
and not exists(select * from cdn.SrsUrzadzenia where SrU_TwrId = twr_twrid)
and not exists(select * from cdn.SrsZlecenia where SrZ_ZbiorczeTwrIdCzesci = twr_twrid )
and not exists(select * from cdn.SrsZlecenia where SrZ_ZbiorczeTwrIdCzynnosci = twr_twrid )
and not exists(select * from cdn.SrsCzesci where SrC_TwrId = twr_twrid )
and not exists(select * from cdn.SrsCzynnosci where SrY_TwrId = twr_twrid )
and not exists(select * from cdn.SchematyOpakElem where SOE_TwrId = twr_twrid))
update cdn.Towary set Twr_GidFirma = 0 where  Twr_TwrId in
(select twr_twrid from cdn.towary where Twr_NieAktywny = 1 and ISNULL(Twr_GidFirma,0) != 1 --and ISNULL(Twr_GidFirma,0) != 2  zgłoszenie 148251
and not exists(select * from cdn.TraElem where tre_twrid = twr_twrid)
and not exists(select * from cdn.TraSElem where trs_twrid = twr_twrid)
and not exists(select * from cdn.PodArkuszInwenElem where PAE_TwrId = twr_twrid)
and not exists(select * from cdn.ProdElem where PdE_TwrId = twr_twrid)
and not exists(select * from cdn.ProdReceptury where PdR_TwrId = twr_twrid)
and not exists(select * from cdn.ProdSkladniki where PdS_TwrId = twr_twrid)
and not exists(select * from cdn.SrsUrzadzenia where SrU_TwrId = twr_twrid)
and not exists(select * from cdn.SrsZlecenia where SrZ_ZbiorczeTwrIdCzesci = twr_twrid )
and not exists(select * from cdn.SrsZlecenia where SrZ_ZbiorczeTwrIdCzynnosci = twr_twrid )
and not exists(select * from cdn.SrsCzesci where SrC_TwrId = twr_twrid )
and not exists(select * from cdn.SrsCzynnosci where SrY_TwrId = twr_twrid )
and not exists(select * from cdn.SchematyOpakElem where SOE_TwrId = twr_twrid))
and ISNULL(Twr_GidFirma,0) = 2
delete from cdn.towary
where twr_twrid in
(select twr_twrid from cdn.towary where Twr_NieAktywny = 1 and ISNULL(Twr_GidFirma,0) != 1 --and ISNULL(Twr_GidFirma,0) != 2   zgłoszenie 148251
and not exists(select * from cdn.TraElem where tre_twrid = twr_twrid)
and not exists(select * from cdn.TraSElem where trs_twrid = twr_twrid)
and not exists(select * from cdn.PodArkuszInwenElem where PAE_TwrId = twr_twrid)
and not exists(select * from cdn.ProdElem where PdE_TwrId = twr_twrid)
and not exists(select * from cdn.ProdReceptury where PdR_TwrId = twr_twrid)
and not exists(select * from cdn.ProdSkladniki where PdS_TwrId = twr_twrid)
--and not exists(select * from cdn.RemanentElem where ReE_TwrId = twr_twrid)
and not exists(select * from cdn.SrsUrzadzenia where SrU_TwrId = twr_twrid)
and not exists(select * from cdn.SrsZlecenia where SrZ_ZbiorczeTwrIdCzesci = twr_twrid )
and not exists(select * from cdn.SrsZlecenia where SrZ_ZbiorczeTwrIdCzynnosci = twr_twrid )
and not exists(select * from cdn.SrsCzesci where SrC_TwrId = twr_twrid )
and not exists(select * from cdn.SrsCzynnosci where SrY_TwrId = twr_twrid )
and not exists(select * from cdn.SchematyOpakElem where SOE_TwrId = twr_twrid))
SET NOCOUNT OFF
