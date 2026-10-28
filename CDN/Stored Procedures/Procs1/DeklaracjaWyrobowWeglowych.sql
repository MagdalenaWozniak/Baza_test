CREATE PROCEDURE  [CDN].[DeklaracjaWyrobowWeglowych]
@ROK int,
@Miesiac int,
@TypDok TEXT,
@Korekty int,
@Okres int=0
AS
set nocount on
Declare
@AtrID INT
CREATE TABLE #Miesiace(miesiac int)
CREATE TABLE #DANE (Opis nvarchar(255),KodCN varchar(8),AkcyzaOpal decimal(15,2), AkcyzaStawka decimal(15,2), Ilosc decimal(15,4), AkcyzaJMPomPrzelicznikM decimal(15,2),AkcyzaJMPomPrzelicznikL decimal(15,2), atr int  )
insert into #Miesiace select @Miesiac
if @Okres = 1
begin
 insert into #Miesiace select @Miesiac -1
 insert into #Miesiace select @Miesiac -2
end
set @AtrID = 0
select @AtrID= Fir_Wartosc from cdn.Firma where Fir_Numer = 2157
select *
into #typydok
from CDN.Text2TableInt(@TypDok)
;with dane as (
select
    TrE_TrEID,
 KCN_Opis,
 TrE_KodCN,
 Tre_AkcyzaOpal,
 Tre_AkcyzaStawka,
 Tre_Ilosc,
 Tre_AkcyzaJMPomPrzelicznikM,
 Tre_AkcyzaJMPomPrzelicznikL--,
  --case when TrA_DeAId IS Not null Then 1 else 0 end as ubytki
 from cdn.tranag
 join cdn.TraElem on TrE_TrNId = trn_trnid
 right join cdn.KodyCN on  TrE_KodCN = KCN_Kod
 left join CDN.TraNagRelacje REL2 ON TrN_TrNID = REL2.TrR_FaId AND REL2.TrR_TrNTyp = 305 AND TrN_TypDokumentu = 302
 where TrN_TypDokumentu IN (select NextIdInt from #typydok )
 and ((Year(TrN_dataope) = @ROK and MONTH(TrN_dataope) in (select miesiac from #Miesiace) and TrN_TypDokumentu =306) or (Year(TrN_datadok) = @ROK and MONTH(TrN_datadok) in (select miesiac from #Miesiace) and TrN_TypDokumentu != 306))
 and TrN_ZwolnionyZAkcyzy = 0  and TrE_AkcyzaOpal != 0
 and TrN_Korekta IN(0,@Korekty) and trn_bufor != -1 AND REL2.TrR_TrNId is NULL
)
insert into #DANE
select
 SUBSTRING(KCN_Opis,1,255) as KCN_Opis,
 TrE_KodCN,
 Tre_AkcyzaOpal,
 Tre_AkcyzaStawka,
 Tre_Ilosc,
 Tre_AkcyzaJMPomPrzelicznikM,
 Tre_AkcyzaJMPomPrzelicznikL,
 case when TrA_DeAId IS Not null Then 1 else 0 end as ubytki
 from dane
 left join (select distinct TrA_TrEId,TrA_DeAId from CDN.TraElemAtr where TrA_DeAId = @AtrID and TrA_TrEID in (select TrE_TrEID from dane))a on TrE_TrEID = TrA_TrEId and TrA_DeAId = @AtrID
set nocount off
select
 nazwa,
 KodCN,
 SUM(wartoscopalowa) as wartoscopalowa,
 AkcyzaStawka,
 ROUND(AkcyzaStawka*  SUM(wartoscopalowa),0) as kwota
 from
 (
 select
 case when Atr = 1 Then substring(MAX(Opis),1,20) + ' - Ubytki' else MAX(Opis) end as nazwa,
 KodCN,
 ROUND(SUM(Ilosc) * AkcyzaOpal * AkcyzaJMPomPrzelicznikM/AkcyzaJMPomPrzelicznikL,3) as wartoscopalowa,
 AkcyzaStawka,
 ROUND(ROUND(SUM(Ilosc) * AkcyzaOpal * AkcyzaJMPomPrzelicznikM/AkcyzaJMPomPrzelicznikL,3)* AkcyzaStawka,0) as kwota
 from #DANE
 group by KodCN,AkcyzaStawka,AkcyzaOpal,AkcyzaJMPomPrzelicznikM,AkcyzaJMPomPrzelicznikL,Atr
) a
 group by KodCN,nazwa,AkcyzaStawka
