CREATE PROCEDURE [CDN].[DostawyHistoria]
@DeAID1 INT,
@DeAID2 INT,
@DeAID3 INT,
@TypDok TEXT,
@MM    INT,
@PodID INT,
@PodTyp INT,
@Bufor INT,
@MagID INT,
@OpeID INT,
@TwrID INT,
@AtrWartosc1 NVARCHAR(102),
@AtrWartosc2 NVARCHAR(102),
@AtrWartosc3 NVARCHAR(102),
@AtrWartosc1Od DECIMAL(16,4),
@AtrWartosc2Od DECIMAL(16,4),
@AtrWartosc3Od DECIMAL(16,4),
@AtrWartosc1Do DECIMAL(16,4),
@AtrWartosc2Do DECIMAL(16,4),
@AtrWartosc3Do DECIMAL(16,4),
@DataOd DateTime,
@DataDo DateTime,
@KtoraZakladka INT,
@zakazDostepuDoCenZakupu TINYINT = 0
AS
SET NOCOUNT ON
select *
into #typydok
from CDN.Text2TableInt(@TypDok)
create table #dane(
    ID int IDENTITY (1, 1)  ,
    TrNId int,
    trEId int,
    twr_twrid INT,
    twr_kod NVARCHAR(50),
    Trn_NumerPelny NVARCHAR(30),
    Trn_NumerString NVARCHAR(30),
    Trn_NumerNr int,
    Korekta int,
    typdok  NVARCHAR(3),
    typdokumentu int,
    Data DateTime,
    Podmiot NVARCHAR(50),
    jm NVARCHAR(20),
    iloscjm DECIMAL(15,4),
    wartoscnetto DECIMAL(15,2),
    magazyn NVARCHAR(50),
    twrnazwa NVARCHAR(255),
    trs_trsid int,
    trn_bufor int,
    trn_vanid int,
    trn_dekid int,
 TsC_Cecha1_DeAId int ,
    TsC_Cecha1_Kod NVARCHAR(20),
 TsC_Cecha1_Format smallint ,
 TsC_Cecha1_Wartosc NVARCHAR(255) ,
 TsC_Cecha2_DeAId int ,
    TsC_Cecha2_Kod NVARCHAR(20),
 TsC_Cecha2_Format smallint ,
 TsC_Cecha2_Wartosc NVARCHAR(255) ,
 TsC_Cecha3_DeAId int ,
    TsC_Cecha3_Kod NVARCHAR(20),
 TsC_Cecha3_Format smallint ,
 TsC_Cecha3_Wartosc NVARCHAR(255) ,
 TsC_Cecha4_DeAId int ,
    TsC_Cecha4_Kod NVARCHAR(20),
 TsC_Cecha4_Format smallint ,
 TsC_Cecha4_Wartosc NVARCHAR(255) ,
 TsC_Cecha5_DeAId int ,
    TsC_Cecha5_Kod NVARCHAR(20),
 TsC_Cecha5_Format smallint ,
 TsC_Cecha5_Wartosc NVARCHAR(255) ,
 TsC_Cecha6_DeAId int ,
    TsC_Cecha6_Kod NVARCHAR(20),
 TsC_Cecha6_Format smallint ,
 TsC_Cecha6_Wartosc NVARCHAR(255) ,
 TsC_Cecha7_DeAId int ,
    TsC_Cecha7_Kod NVARCHAR(20),
 TsC_Cecha7_Format smallint ,
 TsC_Cecha7_Wartosc NVARCHAR(255) ,
 TsC_Cecha8_DeAId int ,
    TsC_Cecha8_Kod NVARCHAR(20),
 TsC_Cecha8_Format smallint ,
 TsC_Cecha8_Wartosc NVARCHAR(255) ,
 TsC_Cecha9_DeAId int ,
    TsC_Cecha9_Kod NVARCHAR(20),
 TsC_Cecha9_Format smallint ,
 TsC_Cecha9_Wartosc NVARCHAR(255) ,
 TsC_Cecha10_DeAId int ,
    TsC_Cecha10_Kod NVARCHAR(20),
 TsC_Cecha10_Format smallint ,
 TsC_Cecha10_Wartosc NVARCHAR(255) ,
 TsC_Cecha1_WartoscDecimal decimal(15, 4),
 TsC_Cecha2_WartoscDecimal decimal(15, 4),
 TsC_Cecha3_WartoscDecimal decimal(15, 4),
 TsC_Cecha4_WartoscDecimal decimal(15, 4),
 TsC_Cecha5_WartoscDecimal decimal(15, 4),
 TsC_Cecha6_WartoscDecimal decimal(15, 4),
 TsC_Cecha7_WartoscDecimal decimal(15, 4),
 TsC_Cecha8_WartoscDecimal decimal(15, 4),
 TsC_Cecha9_WartoscDecimal decimal(15, 4),
 TsC_Cecha10_WartoscDecimal decimal(15, 4)
)
IF @KtoraZakladka = 1
BEGIN
insert into #dane(TrnId, TrEId,twr_twrid,twr_kod,Trn_NumerPelny, Trn_NumerString, Trn_NumerNr, Korekta,typdok,typdokumentu,Data,
                  Podmiot,jm,iloscjm,wartoscnetto, magazyn, twrnazwa,trs_trsid,trn_bufor,trn_vanid,trn_dekid,
 TsC_Cecha1_DeAId,TsC_Cecha1_Kod,TsC_Cecha1_Format,TsC_Cecha1_Wartosc,
    TsC_Cecha2_DeAId,TsC_Cecha2_Kod,TsC_Cecha2_Format,TsC_Cecha2_Wartosc,
    TsC_Cecha3_DeAId,TsC_Cecha3_Kod,TsC_Cecha3_Format,TsC_Cecha3_Wartosc,
 TsC_Cecha4_DeAId,TsC_Cecha4_Kod,TsC_Cecha4_Format,TsC_Cecha4_Wartosc,
 TsC_Cecha5_DeAId,TsC_Cecha5_Kod,TsC_Cecha5_Format,TsC_Cecha5_Wartosc,
 TsC_Cecha6_DeAId,TsC_Cecha6_Kod,TsC_Cecha6_Format,TsC_Cecha6_Wartosc,
 TsC_Cecha7_DeAId,TsC_Cecha7_Kod,TsC_Cecha7_Format,TsC_Cecha7_Wartosc,
 TsC_Cecha8_DeAId,TsC_Cecha8_Kod,TsC_Cecha8_Format,TsC_Cecha8_Wartosc,
 TsC_Cecha9_DeAId,TsC_Cecha9_Kod,TsC_Cecha9_Format,TsC_Cecha9_Wartosc,
 TsC_Cecha10_DeAId,TsC_Cecha10_Kod,TsC_Cecha10_Format,TsC_Cecha10_Wartosc,
 TsC_Cecha1_WartoscDecimal,
 TsC_Cecha2_WartoscDecimal,
 TsC_Cecha3_WartoscDecimal,
 TsC_Cecha4_WartoscDecimal,
 TsC_Cecha5_WartoscDecimal,
 TsC_Cecha6_WartoscDecimal,
 TsC_Cecha7_WartoscDecimal,
 TsC_Cecha8_WartoscDecimal,
 TsC_Cecha9_WartoscDecimal,
 TsC_Cecha10_WartoscDecimal)
select  TrN_TrNId, TrE_TrEId,twr_twrid, twr_kod , Trn_NumerPelny, Trn_NumerString, Trn_NumerNr, TrN_Korekta , CDN.TypDokumentu(trn_typdokumentu),TrN_TypDokumentu,  TrN_DataOpe , Pod_kod ,
 twr_jm , case when Trn_TypDokumentu = 312 then ABS(trs_ilosc) else trs_ilosc end  as  trs_ilosc,
 case when Trn_TypDokumentu = 312 then ABS(trs_wartosc)else case when trs_typ = 4 and trs_wartosc =0 then tre_wartoscnetto else trs_wartosc end end as trs_wartosc,
 mag_symbol,twr_nazwa,trs_trsid,trn_bufor,trn_vanid,trn_dekid,
 TsC_Cecha1_DeAId,TsC_Cecha1_Kod,TsC_Cecha1_Format,TsC_Cecha1_Wartosc,
 TsC_Cecha2_DeAId,TsC_Cecha2_Kod,TsC_Cecha2_Format,TsC_Cecha2_Wartosc,
 TsC_Cecha3_DeAId,TsC_Cecha3_Kod,TsC_Cecha3_Format,TsC_Cecha3_Wartosc,
 TsC_Cecha4_DeAId,TsC_Cecha4_Kod,TsC_Cecha4_Format,TsC_Cecha4_Wartosc,
 TsC_Cecha5_DeAId,TsC_Cecha5_Kod,TsC_Cecha5_Format,TsC_Cecha5_Wartosc,
 TsC_Cecha6_DeAId,TsC_Cecha6_Kod,TsC_Cecha6_Format,TsC_Cecha6_Wartosc,
 TsC_Cecha7_DeAId,TsC_Cecha7_Kod,TsC_Cecha7_Format,TsC_Cecha7_Wartosc,
 TsC_Cecha8_DeAId,TsC_Cecha8_Kod,TsC_Cecha8_Format,TsC_Cecha8_Wartosc,
 TsC_Cecha9_DeAId,TsC_Cecha9_Kod,TsC_Cecha9_Format,TsC_Cecha9_Wartosc,
 TsC_Cecha10_DeAId,TsC_Cecha10_Kod,TsC_Cecha10_Format,TsC_Cecha10_Wartosc,
 case when TsC_Cecha1_Format in (2,4) and TsC_Cecha1_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha1_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha1_WartoscDecimal,
 case when TsC_Cecha2_Format in (2,4) and TsC_Cecha2_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha2_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha2_WartoscDecimal,
 case when TsC_Cecha3_Format in (2,4) and TsC_Cecha3_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha3_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha3_WartoscDecimal,
 case when TsC_Cecha4_Format in (2,4) and TsC_Cecha4_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha4_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha4_WartoscDecimal,
 case when TsC_Cecha5_Format in (2,4) and TsC_Cecha5_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha5_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha5_WartoscDecimal,
 case when TsC_Cecha6_Format in (2,4) and TsC_Cecha6_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha6_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha6_WartoscDecimal,
 case when TsC_Cecha7_Format in (2,4) and TsC_Cecha7_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha7_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha7_WartoscDecimal,
 case when TsC_Cecha8_Format in (2,4) and TsC_Cecha8_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha8_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha8_WartoscDecimal,
 case when TsC_Cecha9_Format in (2,4) and TsC_Cecha9_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha9_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha9_WartoscDecimal,
 case when TsC_Cecha10_Format in (2,4) and TsC_Cecha10_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha10_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha10_WartoscDecimal
from cdn.traselem
left join cdn.traselemcechy on tsc_trsid = trs_trsid
join cdn.towary on trs_twrid = twr_twrid
join cdn.traelem on trs_treid = tre_treid
join cdn.tranag on trn_trnid = tre_trnid
join cdn.podmiotyview on pod_podmiottyp = trn_podmiottyp and pod_podid = trn_podid
join cdn.magazyny on mag_magid = trs_magid
where (Trn_TypDokumentu IN (select NextIdInt from #typydok ) or (Trn_TypDokumentu = 312 and Trs_ilosc < 0 AND @MM IN(0,1) ))
and (Twr_TwrID = @TwrID OR @TwrID=0)
AND (trn_podid IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID and @PodTyp = 1  UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID and @PodTyp = 1 ) AND trn_podmiottyp = @PodTyp OR @PodTyp = 0)
AND (TrN_Bufor = @Bufor OR @Bufor=2)
AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
AND ((TrN_MagZrdID = @MagID AND Trn_TypDokumentu <> 312) OR (TrN_MagDocID = @MagID AND Trn_TypDokumentu = 312) OR @MagID = 0)
AND TrN_DataOpe BETWEEN @DataOd AND @DataDo
AND TrN_Bufor <> -1 AND TrN_Korekta in (0,1)
AND (TsC_Cecha1_DeAId  = @DeAID1 OR
     TsC_Cecha2_DeAId  = @DeAID1 OR
     TsC_Cecha3_DeAId  = @DeAID1 OR
     TsC_Cecha4_DeAId  = @DeAID1 OR
     TsC_Cecha5_DeAId  = @DeAID1 OR
     TsC_Cecha6_DeAId  = @DeAID1 OR
     TsC_Cecha7_DeAId  = @DeAID1 OR
     TsC_Cecha8_DeAId  = @DeAID1 OR
     TsC_Cecha9_DeAId  = @DeAID1 OR
     TsC_Cecha10_DeAId = @DeAID1 OR
     @DeAID1 = 0)
AND (TsC_Cecha1_DeAId  = @DeAID2 OR
     TsC_Cecha2_DeAId  = @DeAID2 OR
     TsC_Cecha3_DeAId  = @DeAID2 OR
     TsC_Cecha4_DeAId  = @DeAID2 OR
     TsC_Cecha5_DeAId  = @DeAID2 OR
     TsC_Cecha6_DeAId  = @DeAID2 OR
     TsC_Cecha7_DeAId  = @DeAID2 OR
     TsC_Cecha8_DeAId  = @DeAID2 OR
     TsC_Cecha9_DeAId  = @DeAID2 OR
     TsC_Cecha10_DeAId = @DeAID2 OR
     @DeAID2 = 0)
AND (TsC_Cecha1_DeAId  = @DeAID3 OR
     TsC_Cecha2_DeAId  = @DeAID3 OR
     TsC_Cecha3_DeAId  = @DeAID3 OR
     TsC_Cecha4_DeAId  = @DeAID3 OR
     TsC_Cecha5_DeAId  = @DeAID3 OR
     TsC_Cecha6_DeAId  = @DeAID3 OR
     TsC_Cecha7_DeAId  = @DeAID3 OR
     TsC_Cecha8_DeAId  = @DeAID3 OR
     TsC_Cecha9_DeAId  = @DeAID3 OR
     TsC_Cecha10_DeAId = @DeAID3 OR
     @DeAID3 = 0)
insert into #dane(TrnId, TrEId,twr_twrid,twr_kod,Trn_NumerPelny, Trn_NumerString, Trn_NumerNr, Korekta,typdok,typdokumentu,Data,
 Podmiot,jm,iloscjm,wartoscnetto, magazyn, twrnazwa,trs_trsid,trn_bufor,trn_vanid,trn_dekid,
 TsC_Cecha1_DeAId,TsC_Cecha1_Kod,TsC_Cecha1_Format,TsC_Cecha1_Wartosc,
    TsC_Cecha2_DeAId,TsC_Cecha2_Kod,TsC_Cecha2_Format,TsC_Cecha2_Wartosc,
    TsC_Cecha3_DeAId,TsC_Cecha3_Kod,TsC_Cecha3_Format,TsC_Cecha3_Wartosc,
 TsC_Cecha4_DeAId,TsC_Cecha4_Kod,TsC_Cecha4_Format,TsC_Cecha4_Wartosc,
 TsC_Cecha5_DeAId,TsC_Cecha5_Kod,TsC_Cecha5_Format,TsC_Cecha5_Wartosc,
 TsC_Cecha6_DeAId,TsC_Cecha6_Kod,TsC_Cecha6_Format,TsC_Cecha6_Wartosc,
 TsC_Cecha7_DeAId,TsC_Cecha7_Kod,TsC_Cecha7_Format,TsC_Cecha7_Wartosc,
 TsC_Cecha8_DeAId,TsC_Cecha8_Kod,TsC_Cecha8_Format,TsC_Cecha8_Wartosc,
 TsC_Cecha9_DeAId,TsC_Cecha9_Kod,TsC_Cecha9_Format,TsC_Cecha9_Wartosc,
 TsC_Cecha10_DeAId,TsC_Cecha10_Kod,TsC_Cecha10_Format,TsC_Cecha10_Wartosc,
 TsC_Cecha1_WartoscDecimal,
 TsC_Cecha2_WartoscDecimal,
 TsC_Cecha3_WartoscDecimal,
 TsC_Cecha4_WartoscDecimal,
 TsC_Cecha5_WartoscDecimal,
 TsC_Cecha6_WartoscDecimal,
 TsC_Cecha7_WartoscDecimal,
 TsC_Cecha8_WartoscDecimal,
 TsC_Cecha9_WartoscDecimal,
 TsC_Cecha10_WartoscDecimal)
select  TrN_TrNId, TrE_TrEId,twr_twrid, twr_kod , Trn_NumerPelny, Trn_NumerString, Trn_NumerNr, TrN_Korekta , CDN.TypDokumentu(trn_typdokumentu),TrN_TypDokumentu,  TrN_DataOpe , Pod_kod ,
 twr_jm , ABS(a.trs_ilosc) as  trs_ilosc, ABS(a.trs_wartosc) as trs_wartosc, mag_symbol,twr_nazwa,a.trs_trsid,trn_bufor,trn_vanid,trn_dekid,
 TsC_Cecha1_DeAId,TsC_Cecha1_Kod,TsC_Cecha1_Format,TsC_Cecha1_Wartosc,
    TsC_Cecha2_DeAId,TsC_Cecha2_Kod,TsC_Cecha2_Format,TsC_Cecha2_Wartosc,
    TsC_Cecha3_DeAId,TsC_Cecha3_Kod,TsC_Cecha3_Format,TsC_Cecha3_Wartosc,
 TsC_Cecha4_DeAId,TsC_Cecha4_Kod,TsC_Cecha4_Format,TsC_Cecha4_Wartosc,
 TsC_Cecha5_DeAId,TsC_Cecha5_Kod,TsC_Cecha5_Format,TsC_Cecha5_Wartosc,
 TsC_Cecha6_DeAId,TsC_Cecha6_Kod,TsC_Cecha6_Format,TsC_Cecha6_Wartosc,
 TsC_Cecha7_DeAId,TsC_Cecha7_Kod,TsC_Cecha7_Format,TsC_Cecha7_Wartosc,
 TsC_Cecha8_DeAId,TsC_Cecha8_Kod,TsC_Cecha8_Format,TsC_Cecha8_Wartosc,
 TsC_Cecha9_DeAId,TsC_Cecha9_Kod,TsC_Cecha9_Format,TsC_Cecha9_Wartosc,
 TsC_Cecha10_DeAId,TsC_Cecha10_Kod,TsC_Cecha10_Format,TsC_Cecha10_Wartosc,
 case when TsC_Cecha1_Format in (2,4) and TsC_Cecha1_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha1_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha1_WartoscDecimal,
 case when TsC_Cecha2_Format in (2,4) and TsC_Cecha2_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha2_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha2_WartoscDecimal,
 case when TsC_Cecha3_Format in (2,4) and TsC_Cecha3_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha3_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha3_WartoscDecimal,
 case when TsC_Cecha4_Format in (2,4) and TsC_Cecha4_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha4_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha4_WartoscDecimal,
 case when TsC_Cecha5_Format in (2,4) and TsC_Cecha5_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha5_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha5_WartoscDecimal,
 case when TsC_Cecha6_Format in (2,4) and TsC_Cecha6_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha6_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha6_WartoscDecimal,
 case when TsC_Cecha7_Format in (2,4) and TsC_Cecha7_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha7_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha7_WartoscDecimal,
 case when TsC_Cecha8_Format in (2,4) and TsC_Cecha8_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha8_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha8_WartoscDecimal,
 case when TsC_Cecha9_Format in (2,4) and TsC_Cecha9_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha9_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha9_WartoscDecimal,
 case when TsC_Cecha10_Format in (2,4) and TsC_Cecha10_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha10_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha10_WartoscDecimal
from cdn.traselem a
join  cdn.traselem b on a.trs_treid = b.trs_treid and a.trs_trsiddost = b.trs_trsiddost and b.trs_ilosc < 0
left join cdn.traselemcechy on tsc_trsid = b.trs_trsid
join cdn.towary on a.trs_twrid = twr_twrid
join cdn.traelem on a.trs_treid = tre_treid
join cdn.tranag on trn_trnid = tre_trnid
join cdn.podmiotyview on pod_podmiottyp = trn_podmiottyp and pod_podid = trn_podid
join cdn.magazyny on mag_magid = a.trs_magid
where Trn_TypDokumentu =312 AND @MM IN(0,2)
and a.trs_ilosc > 0
and (Twr_TwrID = @TwrID OR @TwrID=0)
AND (trn_podid IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID) AND trn_podmiottyp = @PodTyp OR @PodTyp = 0)
AND (TrN_Bufor = @Bufor OR @Bufor=2)
AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
AND (TrN_MagZrdID = @MagID OR @MagID = 0)
AND TrN_DataOpe BETWEEN @DataOd AND @DataDo
AND TrN_Bufor <> -1
AND (TsC_Cecha1_DeAId  = @DeAID1 OR
     TsC_Cecha2_DeAId  = @DeAID1 OR
     TsC_Cecha3_DeAId  = @DeAID1 OR
     TsC_Cecha4_DeAId  = @DeAID1 OR
     TsC_Cecha5_DeAId  = @DeAID1 OR
     TsC_Cecha6_DeAId  = @DeAID1 OR
     TsC_Cecha7_DeAId  = @DeAID1 OR
     TsC_Cecha8_DeAId  = @DeAID1 OR
     TsC_Cecha9_DeAId  = @DeAID1 OR
     TsC_Cecha10_DeAId = @DeAID1 OR
     @DeAID1 = 0)
AND (TsC_Cecha1_DeAId  = @DeAID2 OR
     TsC_Cecha2_DeAId  = @DeAID2 OR
     TsC_Cecha3_DeAId  = @DeAID2 OR
     TsC_Cecha4_DeAId  = @DeAID2 OR
     TsC_Cecha5_DeAId  = @DeAID2 OR
     TsC_Cecha6_DeAId  = @DeAID2 OR
     TsC_Cecha7_DeAId  = @DeAID2 OR
     TsC_Cecha8_DeAId  = @DeAID2 OR
     TsC_Cecha9_DeAId  = @DeAID2 OR
     TsC_Cecha10_DeAId = @DeAID2 OR
     @DeAID2 = 0)
AND (TsC_Cecha1_DeAId  = @DeAID3 OR
     TsC_Cecha2_DeAId  = @DeAID3 OR
     TsC_Cecha3_DeAId  = @DeAID3 OR
     TsC_Cecha4_DeAId  = @DeAID3 OR
     TsC_Cecha5_DeAId  = @DeAID3 OR
     TsC_Cecha6_DeAId  = @DeAID3 OR
     TsC_Cecha7_DeAId  = @DeAID3 OR
     TsC_Cecha8_DeAId  = @DeAID3 OR
     TsC_Cecha9_DeAId  = @DeAID3 OR
     TsC_Cecha10_DeAId = @DeAID3 OR
     @DeAID3 = 0)
END
ELSE
insert into #dane(TrnId, TrEId,twr_twrid,twr_kod,Trn_NumerPelny, Trn_NumerString, Trn_NumerNr, Korekta,typdok,typdokumentu,Data,
 Podmiot,jm,iloscjm,wartoscnetto,magazyn,twrnazwa,trs_trsid,trn_bufor,trn_vanid,trn_dekid,
 TsC_Cecha1_DeAId,TsC_Cecha1_Kod,TsC_Cecha1_Format,TsC_Cecha1_Wartosc,
    TsC_Cecha2_DeAId,TsC_Cecha2_Kod,TsC_Cecha2_Format,TsC_Cecha2_Wartosc,
    TsC_Cecha3_DeAId,TsC_Cecha3_Kod,TsC_Cecha3_Format,TsC_Cecha3_Wartosc,
 TsC_Cecha4_DeAId,TsC_Cecha4_Kod,TsC_Cecha4_Format,TsC_Cecha4_Wartosc,
 TsC_Cecha5_DeAId,TsC_Cecha5_Kod,TsC_Cecha5_Format,TsC_Cecha5_Wartosc,
 TsC_Cecha6_DeAId,TsC_Cecha6_Kod,TsC_Cecha6_Format,TsC_Cecha6_Wartosc,
 TsC_Cecha7_DeAId,TsC_Cecha7_Kod,TsC_Cecha7_Format,TsC_Cecha7_Wartosc,
 TsC_Cecha8_DeAId,TsC_Cecha8_Kod,TsC_Cecha8_Format,TsC_Cecha8_Wartosc,
 TsC_Cecha9_DeAId,TsC_Cecha9_Kod,TsC_Cecha9_Format,TsC_Cecha9_Wartosc,
 TsC_Cecha10_DeAId,TsC_Cecha10_Kod,TsC_Cecha10_Format,TsC_Cecha10_Wartosc,
 TsC_Cecha1_WartoscDecimal,
 TsC_Cecha2_WartoscDecimal,
 TsC_Cecha3_WartoscDecimal,
 TsC_Cecha4_WartoscDecimal,
 TsC_Cecha5_WartoscDecimal,
 TsC_Cecha6_WartoscDecimal,
 TsC_Cecha7_WartoscDecimal,
 TsC_Cecha8_WartoscDecimal,
 TsC_Cecha9_WartoscDecimal,
 TsC_Cecha10_WartoscDecimal)
select  TrN_TrNId, TrE_TrEId,twr_twrid, twr_kod , Trn_NumerPelny, Trn_NumerString, Trn_NumerNr, TrN_Korekta , CDN.TypDokumentu(trn_typdokumentu),TrN_TypDokumentu,  TrN_DataOpe , Pod_kod ,
 twr_jm , twz_ilosc as trs_ilosc, twz_wartosc as trs_wartosc, mag_symbol,twr_nazwa,trs_trsid,trn_bufor,trn_vanid,trn_dekid,
 TsC_Cecha1_DeAId,TsC_Cecha1_Kod,TsC_Cecha1_Format,TsC_Cecha1_Wartosc,
    TsC_Cecha2_DeAId,TsC_Cecha2_Kod,TsC_Cecha2_Format,TsC_Cecha2_Wartosc,
    TsC_Cecha3_DeAId,TsC_Cecha3_Kod,TsC_Cecha3_Format,TsC_Cecha3_Wartosc,
 TsC_Cecha4_DeAId,TsC_Cecha4_Kod,TsC_Cecha4_Format,TsC_Cecha4_Wartosc,
 TsC_Cecha5_DeAId,TsC_Cecha5_Kod,TsC_Cecha5_Format,TsC_Cecha5_Wartosc,
 TsC_Cecha6_DeAId,TsC_Cecha6_Kod,TsC_Cecha6_Format,TsC_Cecha6_Wartosc,
 TsC_Cecha7_DeAId,TsC_Cecha7_Kod,TsC_Cecha7_Format,TsC_Cecha7_Wartosc,
 TsC_Cecha8_DeAId,TsC_Cecha8_Kod,TsC_Cecha8_Format,TsC_Cecha8_Wartosc,
 TsC_Cecha9_DeAId,TsC_Cecha9_Kod,TsC_Cecha9_Format,TsC_Cecha9_Wartosc,
 TsC_Cecha10_DeAId,TsC_Cecha10_Kod,TsC_Cecha10_Format,TsC_Cecha10_Wartosc,
 case when TsC_Cecha1_Format in (2,4) and TsC_Cecha1_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha1_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha1_WartoscDecimal,
 case when TsC_Cecha2_Format in (2,4) and TsC_Cecha2_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha2_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha2_WartoscDecimal,
 case when TsC_Cecha3_Format in (2,4) and TsC_Cecha3_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha3_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha3_WartoscDecimal,
 case when TsC_Cecha4_Format in (2,4) and TsC_Cecha4_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha4_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha4_WartoscDecimal,
 case when TsC_Cecha5_Format in (2,4) and TsC_Cecha5_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha5_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha5_WartoscDecimal,
 case when TsC_Cecha6_Format in (2,4) and TsC_Cecha6_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha6_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha6_WartoscDecimal,
 case when TsC_Cecha7_Format in (2,4) and TsC_Cecha7_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha7_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha7_WartoscDecimal,
 case when TsC_Cecha8_Format in (2,4) and TsC_Cecha8_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha8_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha8_WartoscDecimal,
 case when TsC_Cecha9_Format in (2,4) and TsC_Cecha9_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha9_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha9_WartoscDecimal,
 case when TsC_Cecha10_Format in (2,4) and TsC_Cecha10_Wartosc <> '' then convert(decimal(15, 4),replace(TsC_Cecha10_Wartosc,',','.'))  ELSE - 99999999 end as TsC_Cecha10_WartoscDecimal
 FROM CDN.TwrZasoby
 LEFT JOIN CDN.TraSElem TraSElem ON Twz_TrSIdDost = TrS_TrSId
left join cdn.traselemcechy on tsc_trsid = trs_trsid
join cdn.towary on trs_twrid = twr_twrid
join cdn.traelem on trs_treid = tre_treid
join cdn.tranag on trn_trnid = tre_trnid
join cdn.podmiotyview on pod_podmiottyp = trn_podmiottyp and pod_podid = trn_podid
join cdn.magazyny on mag_magid = twz_magid
where Trn_TypDokumentu IN (select NextIdInt from #typydok )
and (Twr_TwrID = @TwrID OR @TwrID=0)
AND (trn_podid IN (SELECT @PodID UNION SELECT Knt_KntID FROM CDN.Kontrahenci WHERE Knt_NadID = @PodID UNION SELECT Knt_NadID FROM CDN.Kontrahenci WHERE Knt_KntID = @PodID) AND trn_podmiottyp = @PodTyp OR @PodTyp = 0)
AND (TrN_Bufor = @Bufor OR @Bufor=2)
AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
AND (twz_magid = @MagID OR @MagID = 0)
AND TrN_DataOpe BETWEEN @DataOd AND @DataDo
AND (TsC_Cecha1_DeAId  = @DeAID1 OR
     TsC_Cecha2_DeAId  = @DeAID1 OR
     TsC_Cecha3_DeAId  = @DeAID1 OR
     TsC_Cecha4_DeAId  = @DeAID1 OR
     TsC_Cecha5_DeAId  = @DeAID1 OR
     TsC_Cecha6_DeAId  = @DeAID1 OR
     TsC_Cecha7_DeAId  = @DeAID1 OR
     TsC_Cecha8_DeAId  = @DeAID1 OR
     TsC_Cecha9_DeAId  = @DeAID1 OR
     TsC_Cecha10_DeAId = @DeAID1 OR
     @DeAID1 = 0)
AND (TsC_Cecha1_DeAId  = @DeAID2 OR
     TsC_Cecha2_DeAId  = @DeAID2 OR
     TsC_Cecha3_DeAId  = @DeAID2 OR
     TsC_Cecha4_DeAId  = @DeAID2 OR
     TsC_Cecha5_DeAId  = @DeAID2 OR
     TsC_Cecha6_DeAId  = @DeAID2 OR
     TsC_Cecha7_DeAId  = @DeAID2 OR
     TsC_Cecha8_DeAId  = @DeAID2 OR
     TsC_Cecha9_DeAId  = @DeAID2 OR
     TsC_Cecha10_DeAId = @DeAID2 OR
     @DeAID2 = 0)
AND (TsC_Cecha1_DeAId  = @DeAID3 OR
     TsC_Cecha2_DeAId  = @DeAID3 OR
     TsC_Cecha3_DeAId  = @DeAID3 OR
     TsC_Cecha4_DeAId  = @DeAID3 OR
     TsC_Cecha5_DeAId  = @DeAID3 OR
     TsC_Cecha6_DeAId  = @DeAID3 OR
     TsC_Cecha7_DeAId  = @DeAID3 OR
     TsC_Cecha8_DeAId  = @DeAID3 OR
     TsC_Cecha9_DeAId  = @DeAID3 OR
     TsC_Cecha10_DeAId = @DeAID3 OR
     @DeAID3 = 0)
SET NOCOUNT OFF
select TrNId, TrEId, twr_twrid,twr_kod as 'kod',Korekta,typdok,typdokumentu, data, podmiot,
 jm as 'jm', iloscjm ,
 CASE @zakazDostepuDoCenZakupu WHEN 1 THEN   NULL ELSE wartoscnetto END  As wartoscnetto,
1 as 'poziom', magazyn,TwrNazwa as 'TwrNazwa', Trn_NumerPelny, Trn_NumerString, Trn_NumerNr,
trs_trsid,trn_bufor as bufor ,trn_vanid as vanid,trn_dekid as dekid,
TsC_Cecha1_Kod as 'CechaKod1' , TsC_Cecha1_Wartosc as wartosc1,TsC_Cecha1_Format as format1, TsC_Cecha2_Kod as 'CechaKod2' , TsC_Cecha2_Wartosc as wartosc2,TsC_Cecha2_Format as format2,
TsC_Cecha3_Kod as 'CechaKod3' , TsC_Cecha3_Wartosc as wartosc3,TsC_Cecha3_Format as format3, TsC_Cecha4_Kod as 'CechaKod4' , TsC_Cecha4_Wartosc as wartosc4,TsC_Cecha4_Format as format4,
TsC_Cecha5_Kod as 'CechaKod5' , TsC_Cecha5_Wartosc as wartosc5,TsC_Cecha5_Format as format5, TsC_Cecha6_Kod as 'CechaKod6' , TsC_Cecha6_Wartosc as wartosc6,TsC_Cecha6_Format as format6,
TsC_Cecha7_Kod as 'CechaKod7' , TsC_Cecha7_Wartosc as wartosc7,TsC_Cecha7_Format as format7, TsC_Cecha8_Kod as 'CechaKod8' , TsC_Cecha8_Wartosc as wartosc8,TsC_Cecha8_Format as format8,
TsC_Cecha9_Kod as 'CechaKod9' , TsC_Cecha9_Wartosc as wartosc9,TsC_Cecha9_Format as format9, TsC_Cecha10_Kod as 'CechaKod10' , TsC_Cecha10_Wartosc as wartosc10,TsC_Cecha10_Format as format10
from #dane
where
    (((TsC_Cecha1_DeAId  = @DeAID1 OR @DeAID1 = 0) AND (TsC_Cecha1_Wartosc LIKE @AtrWartosc1 OR @AtrWartosc1 = '%%')
     AND (TsC_Cecha1_WartoscDecimal  BETWEEN @AtrWartosc1Od AND @AtrWartosc1Do OR (@AtrWartosc1Od = 0 AND @AtrWartosc1Do = 0)) ) OR
    ((TsC_Cecha2_DeAId  = @DeAID1 OR @DeAID1 = 0) AND (TsC_Cecha2_Wartosc LIKE @AtrWartosc1 OR @AtrWartosc1 = '%%')
     AND (TsC_Cecha2_WartoscDecimal  BETWEEN @AtrWartosc1Od AND @AtrWartosc1Do OR (@AtrWartosc1Od = 0 AND @AtrWartosc1Do = 0)) ) OR
    ((TsC_Cecha3_DeAId  = @DeAID1 OR @DeAID1 = 0)AND (TsC_Cecha3_Wartosc LIKE @AtrWartosc1 OR @AtrWartosc1 = '%%')
     AND (TsC_Cecha3_WartoscDecimal  BETWEEN @AtrWartosc1Od AND @AtrWartosc1Do OR (@AtrWartosc1Od = 0 AND @AtrWartosc1Do = 0)) ) OR
    ((TsC_Cecha4_DeAId  = @DeAID1 OR @DeAID1 = 0)AND (TsC_Cecha4_Wartosc LIKE @AtrWartosc1 OR @AtrWartosc1 = '%%')
     AND (TsC_Cecha4_WartoscDecimal  BETWEEN @AtrWartosc1Od AND @AtrWartosc1Do OR (@AtrWartosc1Od = 0 AND @AtrWartosc1Do = 0)) ) OR
    ((TsC_Cecha5_DeAId  = @DeAID1 OR @DeAID1 = 0)AND (TsC_Cecha5_Wartosc LIKE @AtrWartosc1 OR @AtrWartosc1 = '%%')
     AND (TsC_Cecha5_WartoscDecimal  BETWEEN @AtrWartosc1Od AND @AtrWartosc1Do OR (@AtrWartosc1Od = 0 AND @AtrWartosc1Do = 0)) ) OR
    ((TsC_Cecha6_DeAId  = @DeAID1 OR @DeAID1 = 0)AND (TsC_Cecha6_Wartosc LIKE @AtrWartosc1 OR @AtrWartosc1 = '%%')
     AND (TsC_Cecha6_WartoscDecimal  BETWEEN @AtrWartosc1Od AND @AtrWartosc1Do OR (@AtrWartosc1Od = 0 AND @AtrWartosc1Do = 0)) ) OR
    ((TsC_Cecha7_DeAId  = @DeAID1 OR @DeAID1 = 0)AND (TsC_Cecha7_Wartosc LIKE @AtrWartosc1 OR @AtrWartosc1 = '%%')
     AND (TsC_Cecha7_WartoscDecimal  BETWEEN @AtrWartosc1Od AND @AtrWartosc1Do OR (@AtrWartosc1Od = 0 AND @AtrWartosc1Do = 0)) ) OR
    ((TsC_Cecha8_DeAId  = @DeAID1 OR @DeAID1 = 0)AND (TsC_Cecha8_Wartosc LIKE @AtrWartosc1 OR @AtrWartosc1 = '%%')
     AND (TsC_Cecha8_WartoscDecimal  BETWEEN @AtrWartosc1Od AND @AtrWartosc1Do OR (@AtrWartosc1Od = 0 AND @AtrWartosc1Do = 0)) ) OR
    ((TsC_Cecha9_DeAId  = @DeAID1 OR @DeAID1 = 0)AND (TsC_Cecha9_Wartosc LIKE @AtrWartosc1 OR @AtrWartosc1 = '%%')
     AND (TsC_Cecha9_WartoscDecimal  BETWEEN @AtrWartosc1Od AND @AtrWartosc1Do OR (@AtrWartosc1Od = 0 AND @AtrWartosc1Do = 0)) ) OR
    ((TsC_Cecha10_DeAId  = @DeAID1 OR @DeAID1 = 0) AND (TsC_Cecha10_Wartosc LIKE @AtrWartosc1 OR @AtrWartosc1 = '%%')
     AND (TsC_Cecha10_WartoscDecimal  BETWEEN @AtrWartosc1Od AND @AtrWartosc1Do OR (@AtrWartosc1Od = 0 AND @AtrWartosc1Do = 0)) ))
 AND (((TsC_Cecha1_DeAId  = @DeAID2 OR @DeAID2 = 0) AND (TsC_Cecha1_Wartosc LIKE @AtrWartosc2 OR @AtrWartosc2 = '%%')
     AND (TsC_Cecha1_WartoscDecimal  BETWEEN @AtrWartosc2Od AND @AtrWartosc2Do OR (@AtrWartosc2Od = 0 AND @AtrWartosc2Do = 0)) ) OR
    ((TsC_Cecha2_DeAId  = @DeAID2 OR @DeAID2 = 0) AND (TsC_Cecha2_Wartosc LIKE @AtrWartosc2 OR @AtrWartosc2 = '%%')
     AND (TsC_Cecha2_WartoscDecimal  BETWEEN @AtrWartosc2Od AND @AtrWartosc2Do OR (@AtrWartosc2Od = 0 AND @AtrWartosc2Do = 0)) ) OR
    ((TsC_Cecha3_DeAId  = @DeAID2 OR @DeAID2 = 0) AND (TsC_Cecha3_Wartosc LIKE @AtrWartosc2 OR @AtrWartosc2 = '%%')
     AND (TsC_Cecha3_WartoscDecimal  BETWEEN @AtrWartosc2Od AND @AtrWartosc2Do OR (@AtrWartosc2Od = 0 AND @AtrWartosc2Do = 0)) ) OR
    ((TsC_Cecha4_DeAId  = @DeAID2 OR @DeAID2 = 0) AND (TsC_Cecha4_Wartosc LIKE @AtrWartosc2 OR @AtrWartosc2 = '%%')
     AND (TsC_Cecha4_WartoscDecimal  BETWEEN @AtrWartosc2Od AND @AtrWartosc2Do OR (@AtrWartosc2Od = 0 AND @AtrWartosc2Do = 0)) ) OR
    ((TsC_Cecha5_DeAId  = @DeAID2 OR @DeAID2 = 0) AND (TsC_Cecha5_Wartosc LIKE @AtrWartosc2 OR @AtrWartosc2 = '%%')
     AND (TsC_Cecha5_WartoscDecimal  BETWEEN @AtrWartosc2Od AND @AtrWartosc2Do OR (@AtrWartosc2Od = 0 AND @AtrWartosc2Do = 0)) ) OR
    ((TsC_Cecha6_DeAId  = @DeAID2 OR @DeAID2 = 0) AND (TsC_Cecha6_Wartosc LIKE @AtrWartosc2 OR @AtrWartosc2 = '%%')
     AND (TsC_Cecha6_WartoscDecimal  BETWEEN @AtrWartosc2Od AND @AtrWartosc2Do OR (@AtrWartosc2Od = 0 AND @AtrWartosc2Do = 0)) ) OR
    ((TsC_Cecha7_DeAId  = @DeAID2 OR @DeAID2 = 0) AND (TsC_Cecha7_Wartosc LIKE @AtrWartosc2 OR @AtrWartosc2 = '%%')
     AND (TsC_Cecha7_WartoscDecimal  BETWEEN @AtrWartosc2Od AND @AtrWartosc2Do OR (@AtrWartosc2Od = 0 AND @AtrWartosc2Do = 0)) ) OR
    ((TsC_Cecha8_DeAId  = @DeAID2 OR @DeAID2 = 0) AND (TsC_Cecha8_Wartosc LIKE @AtrWartosc2 OR @AtrWartosc2 = '%%')
     AND (TsC_Cecha8_WartoscDecimal  BETWEEN @AtrWartosc2Od AND @AtrWartosc2Do OR (@AtrWartosc2Od = 0 AND @AtrWartosc2Do = 0)) ) OR
    ((TsC_Cecha9_DeAId  = @DeAID2 OR @DeAID2 = 0) AND (TsC_Cecha9_Wartosc LIKE @AtrWartosc2 OR @AtrWartosc2 = '%%')
     AND (TsC_Cecha9_WartoscDecimal  BETWEEN @AtrWartosc2Od AND @AtrWartosc2Do OR (@AtrWartosc2Od = 0 AND @AtrWartosc2Do = 0)) ) OR
    ((TsC_Cecha10_DeAId  = @DeAID2 OR @DeAID2 = 0) AND (TsC_Cecha10_Wartosc LIKE @AtrWartosc2 OR @AtrWartosc2 = '%%')
     AND (TsC_Cecha10_WartoscDecimal  BETWEEN @AtrWartosc2Od AND @AtrWartosc2Do OR (@AtrWartosc2Od = 0 AND @AtrWartosc2Do = 0)) ) )
AND (((TsC_Cecha1_DeAId  = @DeAID3 OR @DeAID3 = 0) AND (TsC_Cecha1_Wartosc LIKE @AtrWartosc3 OR @AtrWartosc3 = '%%')
     AND (TsC_Cecha1_WartoscDecimal  BETWEEN @AtrWartosc3Od AND @AtrWartosc3Do OR (@AtrWartosc3Od = 0 AND @AtrWartosc3Do = 0)) ) OR
    ((TsC_Cecha2_DeAId  = @DeAID3 OR @DeAID3 = 0)AND (TsC_Cecha2_Wartosc LIKE @AtrWartosc3 OR @AtrWartosc3 = '%%')
     AND (TsC_Cecha2_WartoscDecimal  BETWEEN @AtrWartosc3Od AND @AtrWartosc3Do OR (@AtrWartosc3Od = 0 AND @AtrWartosc3Do = 0)) ) OR
    ((TsC_Cecha3_DeAId  = @DeAID3 OR @DeAID3 = 0)AND (TsC_Cecha3_Wartosc LIKE @AtrWartosc3 OR @AtrWartosc3 = '%%')
     AND (TsC_Cecha3_WartoscDecimal  BETWEEN @AtrWartosc3Od AND @AtrWartosc3Do OR (@AtrWartosc3Od = 0 AND @AtrWartosc3Do = 0)) ) OR
    ((TsC_Cecha4_DeAId  = @DeAID3 OR @DeAID3 = 0) AND (TsC_Cecha4_Wartosc LIKE @AtrWartosc3 OR @AtrWartosc3 = '%%')
     AND (TsC_Cecha4_WartoscDecimal  BETWEEN @AtrWartosc3Od AND @AtrWartosc3Do OR (@AtrWartosc3Od = 0 AND @AtrWartosc3Do = 0)) ) OR
    ((TsC_Cecha5_DeAId  = @DeAID3 OR @DeAID3 = 0)AND (TsC_Cecha5_Wartosc LIKE @AtrWartosc3 OR @AtrWartosc3 = '%%')
     AND (TsC_Cecha5_WartoscDecimal  BETWEEN @AtrWartosc3Od AND @AtrWartosc3Do OR (@AtrWartosc3Od = 0 AND @AtrWartosc3Do = 0)) ) OR
    ((TsC_Cecha6_DeAId  = @DeAID3 OR @DeAID3 = 0)AND (TsC_Cecha6_Wartosc LIKE @AtrWartosc3 OR @AtrWartosc3 = '%%')
     AND (TsC_Cecha6_WartoscDecimal  BETWEEN @AtrWartosc3Od AND @AtrWartosc3Do OR (@AtrWartosc3Od = 0 AND @AtrWartosc3Do = 0)) ) OR
    ((TsC_Cecha7_DeAId  = @DeAID3 OR @DeAID3 = 0)AND (TsC_Cecha7_Wartosc LIKE @AtrWartosc3 OR @AtrWartosc3 = '%%')
     AND (TsC_Cecha7_WartoscDecimal  BETWEEN @AtrWartosc3Od AND @AtrWartosc3Do OR (@AtrWartosc3Od = 0 AND @AtrWartosc3Do = 0)) ) OR
    ((TsC_Cecha8_DeAId  = @DeAID3 OR @DeAID3 = 0)AND (TsC_Cecha8_Wartosc LIKE @AtrWartosc3 OR @AtrWartosc3 = '%%')
     AND (TsC_Cecha8_WartoscDecimal  BETWEEN @AtrWartosc3Od AND @AtrWartosc3Do OR (@AtrWartosc3Od = 0 AND @AtrWartosc3Do = 0)) ) OR
    ((TsC_Cecha9_DeAId  = @DeAID3 OR @DeAID3 = 0)AND (TsC_Cecha9_Wartosc LIKE @AtrWartosc3 OR @AtrWartosc3 = '%%')
     AND (TsC_Cecha9_WartoscDecimal  BETWEEN @AtrWartosc3Od AND @AtrWartosc3Do OR (@AtrWartosc3Od = 0 AND @AtrWartosc3Do = 0)) ) OR
    ((TsC_Cecha10_DeAId  = @DeAID3 OR @DeAID3 = 0)AND (TsC_Cecha10_Wartosc LIKE @AtrWartosc3 OR @AtrWartosc3 = '%%')
     AND (TsC_Cecha10_WartoscDecimal  BETWEEN @AtrWartosc3Od AND @AtrWartosc3Do OR (@AtrWartosc3Od = 0 AND @AtrWartosc3Do = 0)) ))
order by kod,poziom,data,trs_trsid
