CREATE PROCEDURE [CDN].[TowaryZCenaDoAktualizacji]
  @TrNId INT,      -- ID dokumentu
  @NieZmienione TINYInt = 1
AS
declare @TwrId int, @TwrLp int
BEGIN
SET NOCOUNT ON
CREATE Table #Towary(Twr_TwrId INT PRIMARY KEY, Twr_Lp INT)
DECLARE Towary CURSOR LOCAL FAST_FORWARD FOR
select e.TrE_TwrId, min(e.TrE_Lp) as LP
 from cdn.TraElem e
 join cdn.TwrCeny on TwC_TwrID = e.TrE_TwrId and TwC_TwCNumer = 1
 join cdn.TraNag on trn_trnId = e.TrE_TrNId and TrN_TrNID = @TrNId and (e.TrE_IloscJM > 0 or (e.TrE_IloscJM = 0 and (e.TrE_WartoscNettoWal != 0 or e.TrE_WartoscBruttoWal != 0  or e.TrE_Cena0WD != e.TrE_CenaWWD)  and TrN_Korekta in (2,5)) )
 where TwC_DokID in( select trn_trnid from cdn.TraNag where TrN_TrNId = @TrNId OR TrN_FAId = @TrNId)
 group by e.TrE_TwrId order by LP
    OPEN Towary
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Towary INTO @TwrId, @TwrLp
    IF @@FETCH_STATUS <> 0 BREAK
    if @NieZmienione = 1 and (exists(select TwC_Aktualizacja from cdn.TwrCeny
    join cdn.defCeny ON DfC_Lp = TwC_TwCNumer
    join Cdn.Towary on Twr_TwrId = TwC_TwrID WHERE Twr_TwrId = @TwrId and TwC_Aktualizacja = 1 and TwC_TwCNumer <> 1 and ISNULL(DfC_Nieaktywna,0) = 0))
  insert into #Towary(Twr_TwrId, Twr_Lp) select @TwrId, @TwrLp
 if @NieZmienione = 0 and (exists(select TwC_Aktualizacja from cdn.TwrCeny
    join cdn.defCeny ON DfC_Lp = TwC_TwCNumer
    join Cdn.Towary on Twr_TwrId = TwC_TwrID WHERE Twr_TwrId = @TwrId and TwC_Aktualizacja = 1 and TwC_TwCNumer <> 1 and ISNULL(DfC_Nieaktywna,0) = 0))
    and exists (
 select TwC_Aktualizacja from cdn.TwrCeny
    join cdn.defCeny ON DfC_Lp = TwC_TwCNumer
    join Cdn.Towary on Twr_TwrId = TwC_TwrID
        WHERE Twr_TwrId = @TwrId and TwC_TwCNumer = 1 and
    ((Twr_typ = 1 and ( TwC_WartoscZakOld != TwC_Wartosc or Twr_Waluta != TwR_WalutaZakOld or TwR_KursL != TwR_KursLZakOld or TwR_KursM != TwR_KursMZakOld))
    or (Twr_typ = 0 and ( TwR_KosztUslugiOld != TwR_KosztUslugi or Twr_Waluta != TwR_WalutaZakOld or TwR_KursL != TwR_KursLZakOld or TwR_KursM != TwR_KursMZakOld))))
  insert into #Towary(Twr_TwrId, Twr_Lp) select @TwrId, @TwrLp
  END
    CLOSE Towary
    DEALLOCATE Towary
    select Twr_TwrId from #Towary order by Twr_Lp
SET NOCOUNT OFF
END
