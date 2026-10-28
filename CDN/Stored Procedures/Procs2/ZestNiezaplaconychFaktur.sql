CREATE PROCEDURE CDN.ZestNiezaplaconychFaktur
@DodDni int,@Nadzien datetime,@dataDokOd datetime, @dataDokDo datetime
AS
BEGIN
 SET NOCOUNT ON
   DECLARE  @FZ table(
   Licznik       INT IDENTITY(1,1),
   poziom int,
   TypDokKB      INT,
   IDDokKB       INT,
   Kierunek      INT,
      NumerDok nvarchar(30),
      NumerObcy nvarchar(256),
   KwotaNetto  decimal(15,2),
   Kwota       DECIMAL(15,2),
   KwotaSys    decimal(15,2),
   Nalez       DECIMAL(15,2),
   NalezSys    DECIMAL(15,2),
   Zobow       DECIMAL(15,2),
   ZobowSys    DECIMAL(15,2),
      Termin datetime,
      PoTerminie int,
      DataDok datetime,
      PoTerminieDoDoch int,
   PZID int,
   FZID int,
   bzdid int,
   WartoscBrutto decimal(15,2),
   Nazwa nvarchar(526)
    )
   DECLARE @Licznik INT
   DECLARE @Max INT
   DECLARE @TypDokKB INT
   DECLARE @IDDOKKb INT
   DECLARE @Kierunek INT
   DECLARE @Kwota DECIMAL (15,2)
   DECLARE @KwotaSys DECIMAL (15,2)
   DECLARE @NalezRozlL  DECIMAL(15,2)
   DECLARE @NalezSysRozlL DECIMAL(15,2)
   DECLARE @ZobowRozlL  DECIMAL(15,2)
   DECLARE @ZobowSysRozlL DECIMAL(15,2)
   DECLARE @NalezRozlP  DECIMAL(15,2)
   DECLARE @NalezSysRozlP DECIMAL(15,2)
   DECLARE @ZobowRozlP  DECIMAL(15,2)
   DECLARE @ZobowSysRozlP DECIMAL(15,2)
   DECLARE @NalezRozl   DECIMAL(15,2)
   DECLARE @NalezSysRozl  DECIMAL(15,2)
   DECLARE @ZobowRozl  DECIMAL(15,2)
   DECLARE @ZobowSysRozl  DECIMAL(15,2)
   insert into @FZ(
      poziom ,
      TypDokKB,
      IDDokKB,
      Kierunek,
      NumerDok ,
      NumerObcy ,
      KwotaNetto ,
      Kwota,
      KwotaSys ,
      Termin ,
      PoTerminie,
      DataDok ,
      PoTerminieDoDoch ,
      PZID,
      FZID ,
   bzdid,
   WartoscBrutto,
   Nazwa)
    SELECT
      0 as 'poziom',
      TypDokKB = 1,
      IDDokKB = BZd_BZdID,
      Kierunek= BZd_Kierunek,
      NumerDok = TrN_NumerPelny,
      NumerObcy = TrN_NumerObcy,
      KwotaNetto  = TrN_RazemNetto,
      Kwota  = BZd_Kwota,
      KwotaSys = BZd_KwotaSys ,
      Termin = BZd_Termin,
      PoTerminie = DATEDIFF(dd, BZd_Termin, @Nadzien),
      DataDok = TrN_DataOpe,
      PoTerminieDoDoch = CASE WHEN DATEDIFF(day, BZd_DataDok, BZd_Termin)<=60 THEN
      DATEDIFF(day, BZd_Termin, @naDzien - (29 + @DodDni))
      ELSE
      DATEDIFF(day,
      ( TrN_DataOpe),
     @naDzien - (89 +  @DodDni))
      END,
      PZID = ISNULL( TrR_FAID,0) ,
      TrN_TrNID,
   bzdid = BZd_BZdID,
   trn_RazemBrutto,
   TrN_PodNazwa1 +' '+ TrN_PodNazwa2 + ' ' + TrN_PodNazwa3
    FROM cdn.BnkZdarzenia
      JOIN CDN.DokDefinicje ON DDf_DDfID=BZd_DDfID
      LEFT OUTER JOIN CDN.TraNag ON BZd_DokumentTyp IN (1, 101) AND TrN_TrNID = BZd_DokumentID
      left join cdn.TraNagRelacje Rel on TrN_TrNID = TrR_TrNId  and TrR_FaTyp in (307,313)
    WHERE
      (BZd_Stan>0 )
      AND DDf_KierunekOrg = -1
      AND BZd_Kierunek = -1
      AND BZd_DataDok<=@NaDzien
      --AND ( bzd_datadok>=@dataDokOd AND bzd_datadok<=@dataDokDo)
      AND BZd_Rozliczono<>0
      AND TrN_TypDokumentu = 301
      AND YEAR( TrN_DataOpe)  >= 2013
      -- AND DATEDIFF(day, BZd_Termin, @NaDzien) >= 30
      AND CASE
      WHEN DATEDIFF(day, BZd_DataDok, BZd_Termin)<=60 THEN
      DATEDIFF(day, BZd_Termin, @naDzien - (29 + @DodDni))
      ELSE
      DATEDIFF(day,
      (TrN_DataOpe),
       @naDzien - (89 +  @DodDni)) END > 0
 SELECT @Licznik = 1
  SELECT @Max = Max(Licznik) FROM @FZ
  WHILE 1=1 AND @Licznik <= @Max
  BEGIN
    SELECT @TypDokKB = TypDokKB, @IDDokKB = IDDokKB, @Kierunek = Kierunek, @Kwota = Kwota, @KwotaSys = KwotaSys
    FROM @FZ
    WHERE Licznik = @Licznik
    SELECT @NalezRozlL    = isnull(SUM(CASE @kierunek WHEN 1  THEN isnull(BRK_Kwota, 0) ELSE 0 END), 0),
           @NalezSysRozlL = isnull(SUM(CASE @kierunek WHEN 1  THEN isnull(BRK_KwotaSysL, 0) ELSE 0 END), 0),
           @ZobowRozlL    = isnull(SUM(CASE @kierunek WHEN -1 THEN isnull(BRK_Kwota, 0) ELSE 0 END), 0),
           @ZobowSysRozlL = isnull(SUM(CASE @kierunek WHEN -1 THEN isnull(BRK_KwotaSysL, 0) ELSE 0 END), 0)
    FROM cdn.BnkRozKwoty
    WHERE BRK_LDokTyp=@TypDokKb AND BRK_LDokID=@IDDokKB AND BRK_DataDok<=@naDzien
    SELECT @NalezRozlP    = isnull(SUM(CASE @kierunek WHEN 1  THEN isnull(BRK_Kwota, 0) ELSE 0 END), 0),
           @NalezSysRozlP = isnull(SUM(CASE @kierunek WHEN 1  THEN isnull(BRK_KwotaSysP, 0) ELSE 0 END), 0),
           @ZobowRozlP    = isnull(SUM(CASE @kierunek WHEN -1 THEN isnull(BRK_Kwota, 0) ELSE 0 END), 0),
           @ZobowSysRozlP = isnull(SUM(CASE @kierunek WHEN -1 THEN isnull(BRK_KwotaSysP, 0) ELSE 0 END), 0)
    FROM cdn.BnkRozKwoty
    WHERE BRK_PDokTyp=@TypDokKb AND BRK_PDokID=@IdDokKb AND BRK_DataDok<=@naDzien
    SELECT @NalezRozl = @NalezRozlL + @NalezRozlP,
            @NalezSysRozl = @NalezSysRozlL + @NalezSysRozlP,
            @ZobowRozl = @ZobowRozlL + @ZobowRozlP,
            @ZobowSysRozl = @ZobowSysRozlL + @ZobowSysRozlP
    UPDATE @FZ
              SET Nalez = CASE @kierunek WHEN 1 THEN @Kwota - @NalezRozl ELSE 0 END,
                  NalezSys = CASE @kierunek WHEN 1 THEN @KwotaSys - @NalezSysRozl ELSE 0 END,
                  Zobow = CASE @kierunek WHEN -1 THEN @Kwota - @ZobowRozl ELSE 0 END,
                  ZobowSys = CASE @kierunek WHEN -1 THEN @KwotaSys - @ZobowSysRozl ELSE 0 END
    WHERE TypDokKB = @TypDokKB AND IDDokKB = @IdDokKb AND Licznik = @licznik
    IF @licznik > @max BREAK
      SELECT @Licznik = @licznik + 1
  END
  DELETE FROM @FZ WHERE Nalez=0 AND NalezSys=0 AND Zobow=0 AND ZobowSys=0
insert into @FZ( poziom ,
      NumerDok ,
      NumerObcy ,
   KwotaNetto ,
      KwotaSys ,
      Termin ,
      PoTerminie,
      DataDok ,
      PoTerminieDoDoch ,
   PZID,
   FZID,
   bzdid )
select 1  as poziom,numerpelny,null,sum(wartosc) as wartosc,null,null,null,MAX(data),null, MAX(idPZ) ,
max(FZID),
null
from
(
select
case when isnull(max(REL2.TrR_faid),0) >0 then MAX(FA.TrN_NumerPelny)   else
case when isnull(max(REL.TrR_faid),0) >0 then MAX(PA.TrN_NumerPelny)  else MAX(numerpelny) end
end as numerpelny,
SUM(wartosc)as wartosc,MAX(data) as data, idPZ ,
(select max(FZID) from @FZ where PZID = idPZ) as FZID
from (
 SELECT    MAX(TrNId) as idPZ,
           MAX(P.TrS_Ilosc) + SUM(ISNULL(K.TrS_Ilosc,0)) as ilosc,
           MAX(P.TrS_Wartosc) + SUM(ISNULL(K.TrS_Wartosc,0)) as wartosc ,
           MAX(dok.TrN_Bufor) as Bufor,
            case when max(p.trs_rodzaj) in (306061,306071,306072) then MAX(skoj.TrN_TrNID) else MAX(dok.TrN_TrNID) end as idWZ,
            case when max(p.trs_rodzaj) in (306061,306071,306072) then MAX(skoj.TrN_DataDok) else MAX(dok.TrN_DataDok) end as data,
            case when max(p.trs_rodzaj) in (306061,306071,306072) then MAX(skoj.trn_numerpelny) else MAX(dok.trn_numerpelny) end as numerpelny
          FROM CDN.TraSElem P
            LEFT OUTER JOIN CDN.TraSElem K ON P.TrS_TrSId = K.TrS_ZwrId
            JOIN CDN.TraElem ON TrE_TrEId = P.TrS_TrEId
            JOIN CDN.TraNag Dok ON dok.TrN_TrNId = TrE_TrNId
            left join cdn.TraNag Skoj on dok.TrN_ZwrId = skoj.trn_trnid
            join (select TrS_TrSIdDost as TrSIdDost,TrE_TrNId as TrNId from cdn.TraSElem
            join cdn.TraElem on TrE_TrEID = TrS_TrEId
            where TrE_TrNId in (select PZID from @FZ join cdn.TraNag on TrN_TrNID = PZID where TrN_Korekta in( 0) )) Dostawy on  TrSIdDost = P.TrS_TrSIdDost
          WHERE
            P.TrS_Typ       = 2
            AND P.TrS_ZwrId IS NULL
            AND P.TrS_Ilosc    >= 0
            AND dok.TrN_Rodzaj not in (312000,312008)
            AND ( dok.TrN_MagDocId IS NULL  OR ( dok.TrN_Rodzaj = 312100 AND dok.TrN_MagDocId IS NOT NULL ) )
            AND ( dok.TrN_datadok>=@dataDokOd AND dok.TrN_datadok<=@dataDokDo)
          GROUP BY P.TrS_TrSId
          ) a
          left join cdn.TraNagRelacje Rel on idWZ = Rel.TrR_TrNId  and Rel.TrR_FaTyp in (305) and  Rel.TrR_TrNTyp in (306)
          left join CDN.TraNagRelacje REL2 ON idWZ = REL2.TrR_TrNId AND REL2.TrR_FaTyp in (302)  and  Rel2.TrR_TrNTyp in (306)
          left join cdn.TraNag PA on PA.TrN_TrNID = Rel.TrR_FaId
          left join cdn.TraNag FA on FA.TrN_TrNID = Rel2.TrR_FaId
          where ilosc > 0 and idPZ in (select PZID from @FZ)
          group by idPZ,idWZ
) aa
group by idPZ,numerpelny
  SET NOCOUNT OFF
  --select * from @FZ  order by FZID,poziom
  select distinct poziom, NumerDok, NumerObcy,KwotaNetto,ZobowSys as KwotaSys,Termin,PoTerminie,DataDok,PoTerminieDoDoch, case poziom when 0 then null else PZID end as pzid,FZID,bzdid ,WartoscBrutto,Nazwa from @FZ   order by FZID,poziom
  end
