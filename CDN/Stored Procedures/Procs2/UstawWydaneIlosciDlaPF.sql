--* gSkrypt.sOpis = $Tworzenie procedury UstawWydaneIlosciDlaPF$
CREATE PROCEDURE [CDN].[UstawWydaneIlosciDlaPF]
  @TrNId           INT
AS
SET NOCOUNT ON
declare
@id INT,
@terid INT,
@treidpierw INT,
@treid int,
@IloscFA DECIMAL(15,4),
@IloscJMFA DECIMAL(15,4),
@IloscPF DECIMAL(15,4),
@IloscJMPF DECIMAL(15,4),
@IloscPozostala DECIMAL(15,4),
@IloscJMPozostala DECIMAL(15,4),
@IloscWyk DECIMAL(15,4),
@IloscJMWyk DECIMAL(15,4)
if exists (select trr_faid from cdn.tranagrelacje where trr_trnid = @TrNId and trr_trntyp = 306 and trr_fatyp = 302)
return
CREATE TABLE  #Wartosci(id int identity(1,1), terid INT,treid int,treidpierw int, Ilosc DECIMAL(15,4), IloscJM DECIMAL(15,4),IloscPierw DECIMAL(15,4) ,IloscJMPierw DECIMAL(15,4))
if exists (select trr_trnid from cdn.tranagrelacje join cdn.tranag on trr_trnid = trn_trnid where trr_faid = @TrNId and trr_trntyp = 306 and trn_rodzaj = 306010)
begin
/*INSERT INTO #Wartosci(terid,treid ,treidpierw, Ilosc , IloscJM ,IloscPierw,IloscJMPierw)
select Rel.ter_terid,FA.tre_treid,PF.Tre_TreId, WZ.TrE_Ilosc,WZ.TrE_IloscJM,PF.TrE_Ilosc,PF.TrE_IloscJM from cdn.traelemrelacje Rel
join cdn.traelemrelacje RELWZ on REL.ter_parentid = RELWZ.ter_parentid and RELWZ.ter_ChildTyp = 306
join cdn.traelem  PF on PF.tre_treid = REL.ter_parentid
join cdn.traelem  FA on FA.tre_treid = REL.ter_ChildId
join cdn.traelem  WZ on WZ.tre_treid = RELWZ.ter_ChildId
where FA.tre_trnid = @TrNId  and FA.tre_TypDokumentu = 302 and PF.tre_TypDokumentu = 320 and RELWZ.ter_Info is not null*/
INSERT INTO #Wartosci(terid,treid ,treidpierw, Ilosc , IloscJM ,IloscPierw,IloscJMPierw)
select Rel.ter_terid,WZ.tre_treid,0, WZ.TrE_Ilosc,WZ.TrE_IloscJM,PF.TrE_Ilosc,PF.TrE_IloscJM from cdn.traelemrelacje Rel
join cdn.traelemrelacje RELWZ on REL.ter_parentid = RELWZ.ter_parentid and RELWZ.ter_ChildTyp = 306
join cdn.traelem  PF on PF.tre_treid = REL.ter_parentid
join cdn.traelem  FA on FA.tre_treid = REL.ter_ChildId
join cdn.traelem  WZ on WZ.tre_treid = RELWZ.ter_ChildId
join cdn.tranagrelacje on FA.tre_trnid = trr_trnid and  WZ.tre_trnid = trr_faid
where FA.tre_trnid = @TrNId  and FA.tre_TypDokumentu = 302 and PF.tre_TypDokumentu = 320 and RELWZ.ter_Info is not null
/*union all
select Rel.ter_terid,FA.tre_treid,0, FA.TrE_Ilosc,FA.TrE_IloscJM,PF.TrE_Ilosc,PF.TrE_IloscJM from cdn.traelemrelacje Rel
left join cdn.traelemrelacje RELWZ on REL.ter_parentid = RELWZ.ter_parentid and RELWZ.ter_ChildTyp = 306
join cdn.traelem  PF on PF.tre_treid = REL.ter_parentid
join cdn.traelem  FA on FA.tre_treid = REL.ter_ChildId
join cdn.Towary on FA.TrE_TwrId = Twr_TwrId
where FA.tre_trnid = @TrNId  and FA.tre_TypDokumentu = 302 and PF.tre_TypDokumentu = 320 and RELWZ.ter_Info is null and Twr_Typ = 0
*/
--group by Rel.ter_terid
/*update cdn.traelemrelacje set Ter_Info = ISNULL(ilosc,0), Ter_Info2 = ISNULL(iloscJM,0)
from cdn.traelemrelacje
join #Wartosci on ter_terid = terid*/
update cdn.traelemrelacje set Ter_Info = ISNULL(ilosc,0), Ter_Info2 = ISNULL(iloscJM,0)
from cdn.traelemrelacje
join (
select terid, sum(Ilosc)as Ilosc, sum(IloscJM) as IloscJM from
(select terid,treid ,treidpierw, Ilosc , IloscJM ,IloscPierw,IloscJMPierw from #Wartosci
union all
select terid,0,0,WZKor.TrE_Ilosc as ilosc,WZKor.TrE_IloscJM as iloscjm,IloscPierw,IloscJMPierw from #Wartosci
join cdn.traelem WZKor on tre_zwrid = treid
join cdn.tranag WZKorNag on WZKor.tre_trnid = WZKorNag.TrN_TrNID
where WZKorNag.TrN_Bufor != -1) as a
group by terid) b on ter_terid = terid
delete from #Wartosci
if exists (
select Rel.ter_terid,FA.tre_treid,0, FA.TrE_Ilosc,FA.TrE_IloscJM,PF.TrE_Ilosc,PF.TrE_IloscJM from cdn.traelemrelacje Rel
left join cdn.traelemrelacje RELWZ on REL.ter_parentid = RELWZ.ter_parentid and RELWZ.ter_ChildTyp = 306
join cdn.traelem  PF on PF.tre_treid = REL.ter_parentid
join cdn.traelem  FA on FA.tre_treid = REL.ter_ChildId
join cdn.Towary on FA.TrE_TwrId = Twr_TwrId
where FA.tre_trnid = @TrNId  and FA.tre_TypDokumentu = 302 and PF.tre_TypDokumentu = 320 and RELWZ.ter_Info is null and Twr_Typ = 0
)
begin
INSERT INTO #Wartosci(terid,treid ,treidpierw, Ilosc , IloscJM ,IloscPierw,IloscJMPierw)
select ter_terid,FA.tre_treid,PF.Tre_TreId, FA.TrE_Ilosc,fA.TrE_IloscJM,PF.TrE_Ilosc,PF.TrE_IloscJM from cdn.traelemrelacje
join cdn.traelem  PF on PF.tre_treid = ter_parentid
join cdn.traelem  FA on FA.tre_treid = ter_ChildId
where FA.tre_trnid = @TrNId  and FA.tre_TypDokumentu in (302,306) and PF.tre_TypDokumentu = 320
and TeR_TeRId in(select Rel.ter_terid from cdn.traelemrelacje Rel
left join cdn.traelemrelacje RELWZ on REL.ter_parentid = RELWZ.ter_parentid and RELWZ.ter_ChildTyp = 306
join cdn.traelem  PF on PF.tre_treid = REL.ter_parentid
join cdn.traelem  FA on FA.tre_treid = REL.ter_ChildId
join cdn.Towary on FA.TrE_TwrId = Twr_TwrId
where FA.tre_trnid = @TrNId  and FA.tre_TypDokumentu = 302 and PF.tre_TypDokumentu = 320 and RELWZ.ter_Info is null and Twr_Typ = 0)
DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
 select id, terid ,treid ,treidpierw, Ilosc , IloscJM ,IloscPierw,IloscJMPierw from #Wartosci
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
          @id
         ,@terid
         ,@treid
         ,@treidpierw
         ,@iloscFA
         ,@iloscJMFA
         ,@iloscPF
         ,@iloscJMPF
   IF @@FETCH_STATUS <> 0 BREAK
select @IloscWyk = ISNULL(sum(TeR_Info),0), @IloscJMWyk = ISNULL(sum(TeR_Info2),0) from
(select ISNULL(TeR_Info,0) as TeR_Info,ISNULL(TeR_Info2,0)as TeR_Info2
from cdn.traelemrelacje
join cdn.traelem FAElem on FAElem.tre_treid = ter_childid
JOIN Cdn.TraNag FA ON FA.TrN_TrNId = FAElem.TrE_TrNId
where ter_parentid = @treidpierw and ter_childid <> @treid AND FA.TrN_TypDokumentu in(306,302)
                              AND  FAElem.TrE_Kaucja = 0 AND FA.TrN_Bufor <> -1
                              AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B
                              JOIN Cdn.TraNag WZ ON B.Trr_trnId = WZ.TRN_TrNId
                              WHERE B.Trr_FAId = FA.TrN_TrNId  AND B.TrR_FaTyp = 306 AND B.TrR_TRNTyp = 302
                              )
union all
select ISNULL(tre_ilosc,0) as TeR_Info,ISNULL(tre_iloscjm,0)  as TeR_Info2 from cdn.traelem WZKor where WZKor.tre_zwrid in (
select Tre_treid
from cdn.traelemrelacje
join cdn.traelem FAElem on FAElem.tre_treid = ter_childid
JOIN Cdn.TraNag FA ON FA.TrN_TrNId = FAElem.TrE_TrNId
where ter_parentid = @treidpierw and ter_childid <> @treid AND FA.TrN_TypDokumentu in(306)
                              AND  FAElem.TrE_Kaucja = 0 AND FA.TrN_Bufor <> -1
                              AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B
                              JOIN Cdn.TraNag WZ ON B.Trr_trnId = WZ.TRN_TrNId
                              WHERE B.Trr_FAId = FA.TrN_TrNId  AND B.TrR_FaTyp = 306 AND B.TrR_TRNTyp = 302
                              ))
) as b
select @IloscPozostala = @IloscFA - (@IloscPF-@IloscWyk) ,@IloscJMPozostala = @IloscJMFA - (@IloscJMPF-@IloscJMWyk)
if @IloscPozostala < 0 or @IloscJMPozostala < 0
 select @IloscPozostala = 0,@IloscJMPozostala = 0
 update #Wartosci set ilosc = @IloscFA - @IloscPozostala, iloscJM = @IloscJMFA - @IloscJMPozostala where id = @id
 update #Wartosci set ilosc = @IloscPozostala, iloscJM = @IloscJMPozostala where treid = @treid and terid <> @terid and id>@id
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
update cdn.traelemrelacje set Ter_Info = ISNULL(ilosc,0), Ter_Info2 = ISNULL(iloscJM,0)
from cdn.traelemrelacje
join #Wartosci on ter_terid = terid
end
end
else
begin
INSERT INTO #Wartosci(terid,treid ,treidpierw, Ilosc , IloscJM ,IloscPierw,IloscJMPierw)
select ter_terid,FA.tre_treid,PF.Tre_TreId, FA.TrE_Ilosc,fA.TrE_IloscJM,PF.TrE_Ilosc,PF.TrE_IloscJM from cdn.traelemrelacje
join cdn.traelem  PF on PF.tre_treid = ter_parentid
join cdn.traelem  FA on FA.tre_treid = ter_ChildId
where FA.tre_trnid = @TrNId  and FA.tre_TypDokumentu in (302,306) and PF.tre_TypDokumentu = 320
DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
 select id, terid ,treid ,treidpierw, Ilosc , IloscJM ,IloscPierw,IloscJMPierw from #Wartosci
 OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO
          @id
         ,@terid
         ,@treid
         ,@treidpierw
         ,@iloscFA
         ,@iloscJMFA
         ,@iloscPF
         ,@iloscJMPF
   IF @@FETCH_STATUS <> 0 BREAK
select @IloscWyk = ISNULL(sum(TeR_Info),0), @IloscJMWyk = ISNULL(sum(TeR_Info2),0) from
(select ISNULL(TeR_Info,0) as TeR_Info,ISNULL(TeR_Info2,0)as TeR_Info2
from cdn.traelemrelacje
join cdn.traelem FAElem on FAElem.tre_treid = ter_childid
JOIN Cdn.TraNag FA ON FA.TrN_TrNId = FAElem.TrE_TrNId
where ter_parentid = @treidpierw and ter_childid <> @treid AND FA.TrN_TypDokumentu in(306,302)
                              AND  FAElem.TrE_Kaucja = 0 AND FA.TrN_Bufor <> -1
                              AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B
                              JOIN Cdn.TraNag WZ ON B.Trr_trnId = WZ.TRN_TrNId
                              WHERE B.Trr_FAId = FA.TrN_TrNId  AND B.TrR_FaTyp = 306 AND B.TrR_TRNTyp = 302
                              )
union all
select ISNULL(tre_ilosc,0) as TeR_Info,ISNULL(tre_iloscjm,0)  as TeR_Info2 from cdn.traelem WZKor where WZKor.tre_zwrid in (
select Tre_treid
from cdn.traelemrelacje
join cdn.traelem FAElem on FAElem.tre_treid = ter_childid
JOIN Cdn.TraNag FA ON FA.TrN_TrNId = FAElem.TrE_TrNId
where ter_parentid = @treidpierw and ter_childid <> @treid AND FA.TrN_TypDokumentu in(306)
                              AND  FAElem.TrE_Kaucja = 0 AND FA.TrN_Bufor <> -1
                              AND NOT EXISTS (SELECT B.Trr_TrRId FROM CDN.TraNagRelacje B
                              JOIN Cdn.TraNag WZ ON B.Trr_trnId = WZ.TRN_TrNId
                              WHERE B.Trr_FAId = FA.TrN_TrNId  AND B.TrR_FaTyp = 306 AND B.TrR_TRNTyp = 302
                              ))
) as b
select @IloscPozostala = @IloscFA - (@IloscPF-@IloscWyk) ,@IloscJMPozostala = @IloscJMFA - (@IloscJMPF-@IloscJMWyk)
if @IloscPozostala < 0 or @IloscJMPozostala < 0
 select @IloscPozostala = 0,@IloscJMPozostala = 0
 update #Wartosci set ilosc = @IloscFA - @IloscPozostala, iloscJM = @IloscJMFA - @IloscJMPozostala where id = @id
 update #Wartosci set ilosc = @IloscPozostala, iloscJM = @IloscJMPozostala where treid = @treid and terid <> @terid and id>@id
END
    CLOSE Dodawane
    DEALLOCATE Dodawane
update cdn.traelemrelacje set Ter_Info = ISNULL(ilosc,0), Ter_Info2 = ISNULL(iloscJM,0)
from cdn.traelemrelacje
join #Wartosci on ter_terid = terid
end
  SET NOCOUNT OFF
