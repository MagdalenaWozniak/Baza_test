-- PobierzFakZaliczkowe
CREATE  PROCEDURE [CDN].[PobierzFakZaliczkowe]
@ID INT
  AS
  SET NOCOUNT ON
Declare
    @TrV_TrVID  int,
 @TrV_Stawka decimal(5, 2),
 @TrV_Flaga smallint,
 @TrV_Zrodlowa decimal(5, 2),
 @TrV_Netto decimal(15, 2),
 @TrV_VAT decimal(15, 2),
 @TrV_NettoWal decimal(15, 2),
 @TrV_VATWal decimal(15, 2),
 @TrN_NumerPelny NVARCHAR(30),
    @TrN_TrNID int,
    @TrZ_KwotaBrutto decimal(15, 2),
    @TrZ_KwotaNetto decimal(15, 2),
    @TrZ_KwotaNettoSys decimal(15, 2),
    @TrZ_KwotaVAT decimal(15, 2),
    @TrZ_KwotaVATSys decimal(15, 2)
CREATE TABLE  #FakZaliczkowe(
    TrV_TrVID int IDENTITY(1,1) NOT NULL,
 TrV_Stawka decimal(5, 2) NOT NULL,
 TrV_Flaga smallint NOT NULL,
 TrV_Zrodlowa decimal(5, 2) NOT NULL,
 TrV_Netto decimal(15, 2) NOT NULL,
 TrV_VAT decimal(15, 2) NOT NULL,
 TrV_NettoWal decimal(15, 2) NOT NULL,
 TrV_VATWal decimal(15, 2) NOT NULL,
 TrN_NumerPelny NVARCHAR(30) NOT NULL,
    TrN_TrNID int NOT NULL,
)
CREATE TABLE  #FakZaliczkoweKor(
    TrV_TrVID int IDENTITY(1,1) NOT NULL,
 TrV_Stawka decimal(5, 2) NOT NULL,
 TrV_Flaga smallint NOT NULL,
 TrV_Zrodlowa decimal(5, 2) NOT NULL,
 TrV_Netto decimal(15, 2) NOT NULL,
 TrV_VAT decimal(15, 2) NOT NULL,
 TrV_NettoWal decimal(15, 2) NOT NULL,
 TrV_VATWal decimal(15, 2) NOT NULL,
 TrN_NumerPelny NVARCHAR(30) NOT NULL,
    TrN_TrNID int NOT NULL,
)
CREATE TABLE  #FakZaliczkowePier(
    TrV_TrVID int IDENTITY(1,1) NOT NULL,
 TrV_Stawka decimal(5, 2) NOT NULL,
 TrV_Flaga smallint NOT NULL,
 TrV_Zrodlowa decimal(5, 2) NOT NULL,
 TrV_Netto decimal(15, 2) NOT NULL,
 TrV_VAT decimal(15, 2) NOT NULL,
 TrV_NettoWal decimal(15, 2) NOT NULL,
 TrV_VATWal decimal(15, 2) NOT NULL,
 TrN_NumerPelny NVARCHAR(30) NOT NULL,
    TrN_TrNID int NOT NULL,
)
insert into #FakZaliczkowePier
select trv_stawka,trv_Flaga,Trv_Zrodlowa,
trv_netto ,
trv_vat ,
trv_nettowal ,
trv_vatwal ,
trn_numerpelny,
trn_trnid
from cdn.travat join cdn.tranag on trv_trnid = trn_trnid
where trv_trnid in( select trn_trnid from cdn.tranag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId where trr_faid = @ID and trn_rodzaj = 302200 )
/*insert into #FakZaliczkoweKor
select trv_stawka,trv_Flaga,Trv_Zrodlowa,
trv_netto ,
trv_vat ,
trv_nettowal ,
trv_vatwal ,
trn_numerpelny,
trn_zwrid
from cdn.travat join cdn.tranag on trv_trnid = trn_trnid
where trv_trnid in( select trn_trnid from cdn.tranag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId where trr_faid = @ID and trn_rodzaj = 302202 )
*/
insert into #FakZaliczkoweKor
select trv_stawka,trv_Flaga,Trv_Zrodlowa,
SUM(ISNULL(trv_netto,0)) ,
SUM(ISNULL(trv_vat,0)) ,
SUM(ISNULL(trv_nettowal,0)) ,
SUM(ISNULL(trv_vatwal,0)) ,
Max(ISNULL(trn_numerpelny,0)),
trn_zwrid
from cdn.travat join cdn.tranag on trv_trnid = trn_trnid
where trv_trnid in( select trn_trnid from cdn.tranag JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId where trr_faid = @ID and trn_rodzaj = 302202 )
GROUP BY trn_zwrid,trv_stawka,Trv_Zrodlowa,trv_Flaga
insert into #FakZaliczkowe
select
 Pier.TrV_Stawka ,
 Pier.TrV_Flaga ,
 Pier.TrV_Zrodlowa ,
 Pier.TrV_Netto + ISNULL(Kor.TrV_Netto,0),
 Pier.TrV_VAT + ISNULL(Kor.TrV_VAT,0),
 Pier.TrV_NettoWal + ISNULL(Kor.TrV_NettoWal,0),
 Pier.TrV_VATWal + ISNULL(Kor.TrV_VATWal,0),
 Pier.TrN_NumerPelny,
 Pier.TrN_TrNID
FROM #FakZaliczkowePier Pier
LEFT OUTER JOIN #FakZaliczkoweKor AS Kor ON Kor.TrN_TrNID = Pier.TrN_TrNID
AND Kor.TrV_Stawka = Pier.TrV_Stawka AND Kor.TrV_Flaga = Pier.TrV_Flaga
delete from #FakZaliczkowe where TrV_Netto = 0 and  TrV_VAT = 0 and  TrV_NettoWal = 0 and TrV_VATWal = 0
  DECLARE N CURSOR LOCAL FAST_FORWARD FOR
   select * from #FakZaliczkowe
             OPEN N
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM N INTO
                  @TrV_TrVID,
                  @TrV_Stawka,
                  @TrV_Flaga,
                  @TrV_Zrodlowa,
                  @TrV_Netto,
                  @TrV_VAT,
                  @TrV_NettoWal,
                  @TrV_VATWal,
                  @TrN_NumerPelny,
                  @TrN_TrNID
                    IF @@FETCH_STATUS <> 0 BREAK
                     select @TrZ_KwotaBrutto =0,    @TrZ_KwotaNetto =0,    @TrZ_KwotaNettoSys =0,    @TrZ_KwotaVAT =0,    @TrZ_KwotaVATSys =0
                     select @TrZ_KwotaBrutto = sum(TrZ_KwotaBrutto),@TrZ_KwotaNetto = sum(TrZ_KwotaNetto),@TrZ_KwotaNettoSys = sum(TrZ_KwotaNettoSys),@TrZ_KwotaVAT = sum(TrZ_KwotaVAT),@TrZ_KwotaVATSys = sum(TrZ_KwotaVATSys) from cdn.trafakzaliczkowe
                       join cdn.tranag on TrZ_TrnId = TrN_TrnId
                      where TrZ_FZId = @TrN_TrNID and TrZ_Uwzgledniac = 1 and trn_bufor <> -1 and @TrV_Stawka = TrZ_Stawka and @TrV_Flaga = TrZ_Flaga
                      group by TrZ_FZId
                     if @TrZ_KwotaBrutto = @TrV_NettoWal + @TrV_VATWal and @TrZ_KwotaNetto = @TrV_NettoWal and @TrZ_KwotaVAT = @TrV_VATWal
                       update #FakZaliczkowe set TrV_Netto = 0, TrV_VAT = 0, TrV_NettoWal = 0,TrV_VATWal = 0 where TrV_TrVID = @TrV_TrVID
                     else
                       update #FakZaliczkowe set TrV_Netto = TrV_Netto-@TrZ_KwotaNettoSys, TrV_VAT = TrV_VAT-@TrZ_KwotaVATSys, TrV_NettoWal = TrV_NettoWal - @TrZ_KwotaNetto,TrV_VATWal = TrV_VATWal - @TrZ_KwotaVAT where TrV_TrVID = @TrV_TrVID
             END
              CLOSE N
            DEALLOCATE N
            delete from #FakZaliczkowe where TrV_Netto = 0 and  TrV_VAT = 0 and  TrV_NettoWal = 0 and TrV_VATWal = 0
   SET NOCOUNT OFF
   select * from #FakZaliczkowe
   DROP TABLE #FakZaliczkowe
