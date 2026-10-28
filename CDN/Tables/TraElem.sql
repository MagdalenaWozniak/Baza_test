CREATE TABLE [CDN].[TraElem] (
    [TrE_TrEID]                   INT             IDENTITY (1, 1) NOT NULL,
    [TrE_TrNId]                   INT             NOT NULL,
    [TrE_ZwrId]                   INT             NULL,
    [TrE_TrEIdProd]               INT             NULL,
    [TrE_PdRId]                   INT             NULL,
    [TrE_Lp]                      INT             NOT NULL,
    [TrE_LpPow]                   INT             NOT NULL,
    [TrE_LpPowRel]                INT             NULL,
    [TrE_TypDokumentu]            INT             NOT NULL,
    [TrE_Aktywny]                 TINYINT         NOT NULL,
    [TrE_DataDok]                 DATETIME        NOT NULL,
    [TrE_RabatPromocyjny]         DECIMAL (15, 4) NULL,
    [TrE_RabatKorekta]            DECIMAL (15, 4) NULL,
    [TrE_Promocje]                INT             NULL,
    [TrE_DataOpe]                 DATETIME        NOT NULL,
    [TrE_PodmiotTyp]              SMALLINT        NULL,
    [TrE_PodID]                   INT             NULL,
    [TrE_KatID]                   INT             NULL,
    [TrE_TwrId]                   INT             NULL,
    [TrE_MagId]                   INT             NULL,
    [TrE_TwrNazwa]                NVARCHAR (255)  NOT NULL,
    [TrE_TwrEAN]                  VARCHAR (40)    NOT NULL,
    [TrE_TwrNumerKat]             NVARCHAR (40)   NOT NULL,
    [TrE_TwrKod]                  VARCHAR (50)    NOT NULL,
    [TrE_TwrOpis]                 NVARCHAR (1024) NOT NULL,
    [TrE_TwrSWW]                  VARCHAR (20)    NOT NULL,
    [TrE_TwrTyp]                  TINYINT         NOT NULL,
    [TrE_TwrKodDostawcy]          NVARCHAR (50)   NOT NULL,
    [TrE_Stawka]                  DECIMAL (5, 2)  NOT NULL,
    [TrE_Flaga]                   SMALLINT        NOT NULL,
    [TrE_Zrodlowa]                DECIMAL (5, 2)  NOT NULL,
    [TrE_TwCNumer]                INT             NOT NULL,
    [TrE_TypNB]                   TINYINT         NOT NULL,
    [TrE_Cena0]                   DECIMAL (17, 4) NOT NULL,
    [TrE_Rabat]                   DECIMAL (5, 2)  NOT NULL,
    [TrE_CenaW]                   DECIMAL (17, 4) NOT NULL,
    [TrE_Waluta]                  VARCHAR (3)     NOT NULL,
    [TrE_Kaucja]                  TINYINT         NOT NULL,
    [TrE_WyborDostaw]             TINYINT         CONSTRAINT [DF_TrE_WyborDostaw] DEFAULT ((0)) NULL,
    [TrE_KursNumer]               INT             NOT NULL,
    [TrE_KursL]                   DECIMAL (15, 4) NOT NULL,
    [TrE_KursM]                   DECIMAL (5)     NOT NULL,
    [TrE_CenaT]                   DECIMAL (17, 4) NOT NULL,
    [TrE_Ilosc]                   DECIMAL (15, 4) NOT NULL,
    [TrE_IloscKW]                 DECIMAL (15, 4) NOT NULL,
    [TrE_Jm]                      NVARCHAR (20)   NOT NULL,
    [TrE_JmZ]                     NVARCHAR (20)   NOT NULL,
    [TrE_JmCalkowite]             TINYINT         NOT NULL,
    [TrE_JMPrzelicznikL]          DECIMAL (15, 2) NOT NULL,
    [TrE_JMPrzelicznikM]          DECIMAL (7)     NOT NULL,
    [TrE_IloscJM]                 DECIMAL (15, 4) NOT NULL,
    [TrE_IloscJMKW]               DECIMAL (15, 4) NOT NULL,
    [TrE_WartoscNetto]            DECIMAL (15, 2) NOT NULL,
    [TrE_WartoscBrutto]           DECIMAL (15, 2) NOT NULL,
    [TrE_KosztUslugi]             DECIMAL (15, 2) NOT NULL,
    [TrE_KosztKGO]                DECIMAL (15, 2) CONSTRAINT [DF_TrE_KosztKGO] DEFAULT ((0)) NOT NULL,
    [Tre_AkcyzaJMPomPrzelicznikL] DECIMAL (15, 2) CONSTRAINT [DF_Tre_AkcyzaJMPomPrzelicznikL] DEFAULT ((1)) NOT NULL,
    [Tre_AkcyzaJMPomPrzelicznikM] INT             CONSTRAINT [DF_Tre_AkcyzaJMPomPrzelicznikM] DEFAULT ((1)) NOT NULL,
    [TrE_AkcyzaOpal]              DECIMAL (15, 2) CONSTRAINT [DF_TrE_AkcyzaOpal] DEFAULT ((0)) NOT NULL,
    [TrE_AkcyzaStawka]            DECIMAL (15, 2) CONSTRAINT [DF_TrE_AkcyzaStawka] DEFAULT ((0)) NOT NULL,
    [TrE_Akcyza_DeAId]            INT             NULL,
    [TrE_Akcyza_Kod]              VARCHAR (20)    CONSTRAINT [DF_TrE_Akcyza_Kod] DEFAULT ('') NOT NULL,
    [TrE_Akcyza_Wartosc]          NVARCHAR (100)  CONSTRAINT [DF_TrE_Akcyza_Wartosc] DEFAULT ('') NOT NULL,
    [Tre_OdwrotneObciazenie]      TINYINT         CONSTRAINT [DF_Tre_OdwrotneObciazenie] DEFAULT ((0)) NOT NULL,
    [TrE_KodCN]                   VARCHAR (8)     CONSTRAINT [DF_TrE_KodCN] DEFAULT ('') NOT NULL,
    [TrE_WartoscZakupuWylicz]     DECIMAL (15, 2) NOT NULL,
    [TrE_Cena0WD]                 DECIMAL (17, 4) NOT NULL,
    [TrE_CenaWWD]                 DECIMAL (17, 4) NOT NULL,
    [TrE_WartoscNettoWal]         DECIMAL (15, 2) NOT NULL,
    [TrE_WartoscBruttoWal]        DECIMAL (15, 2) NOT NULL,
    [TrE_WartoscTymczasowa]       INT             NULL,
    [TrE_Atr1_DeAId]              INT             NULL,
    [TrE_Atr1_Kod]                VARCHAR (20)    NOT NULL,
    [TrE_Atr1_Wartosc]            NVARCHAR (100)  NOT NULL,
    [TrE_Atr2_DeAId]              INT             NULL,
    [TrE_Atr2_Kod]                VARCHAR (20)    NOT NULL,
    [TrE_Atr2_Wartosc]            NVARCHAR (100)  NOT NULL,
    [TrE_Atr3_DeAId]              INT             NULL,
    [TrE_Atr3_Kod]                VARCHAR (20)    NOT NULL,
    [TrE_Atr3_Wartosc]            NVARCHAR (100)  NOT NULL,
    [TrE_Atr4_DeAId]              INT             NULL,
    [TrE_Atr4_Kod]                VARCHAR (20)    NOT NULL,
    [TrE_Atr4_Wartosc]            NVARCHAR (100)  NOT NULL,
    [TrE_Atr5_DeAId]              INT             NULL,
    [TrE_Atr5_Kod]                VARCHAR (20)    NOT NULL,
    [TrE_Atr5_Wartosc]            NVARCHAR (100)  NOT NULL,
    [TrE_Prog]                    DECIMAL (15, 2) NOT NULL,
    [TrE_UpustTyp]                TINYINT         NOT NULL,
    [TrE_Upust]                   DECIMAL (15, 2) NOT NULL,
    [TrE_UpustKnt]                DECIMAL (15, 2) NOT NULL,
    [TrE_UpustKntTyp]             TINYINT         NOT NULL,
    [TrE_IFA24Mag]                TINYINT         CONSTRAINT [DF_TrE_IFA24Mag] DEFAULT ((0)) NOT NULL,
    [TrE_IFA24]                   TINYINT         CONSTRAINT [DF_TrE_IFA24] DEFAULT ((0)) NOT NULL,
    [TrE_ZTwID]                   INT             CONSTRAINT [DF_TrE_ZTwID] DEFAULT ((0)) NOT NULL,
    [TrE_ZestawWiazanie]          INT             CONSTRAINT [DF_TrE_ZestawWiazanie] DEFAULT ((0)) NOT NULL,
    [TrE_ZTwGlowny]               TINYINT         CONSTRAINT [DF_TrE_ZTwGlowny] DEFAULT ((0)) NOT NULL,
    [TrE_ZTwKod]                  VARCHAR (20)    CONSTRAINT [DF_TrE_ZTwKod] DEFAULT ('') NOT NULL,
    [TrE_ZTwIlosc]                DECIMAL (15, 4) CONSTRAINT [DF_TrE_ZTwIlosc] DEFAULT ((0)) NOT NULL,
    [TrE_DoZwrotu]                DECIMAL (15, 4) CONSTRAINT [DF_TrE_DoZwrotu] DEFAULT ((0)) NOT NULL,
    [TrE_UslugaZlozonaId]         INT             CONSTRAINT [DF_TrE_UslugaZlozonaId] DEFAULT ((0)) NOT NULL,
    [TrE_UslugaZlozona]           TINYINT         CONSTRAINT [DF_TrE_UslugaZlozona] DEFAULT ((0)) NOT NULL,
    [TrE_PATrEId]                 INT             CONSTRAINT [DF_TrE_PATrEId] DEFAULT ((0)) NOT NULL,
    [TrE_KWRoznicaKursowa]        DECIMAL (15, 2) CONSTRAINT [DF_TrE_KWRoznicaKursowa] DEFAULT ((0)) NOT NULL,
    [Tre_CenaZCzteremaMiejscami]  TINYINT         CONSTRAINT [DF_Tre_CenaZCzteremaMiejscami] DEFAULT ((0)) NOT NULL,
    [TrE_WartoscZakupu]           AS              ([CDN].[FNTRE_WARTOSCZAKUPU]([TRE_TREID],[TRE_TRNID],[TRE_LPPOW],[TRE_TWRID])+[TRE_KOSZTUSLUGI]),
    [TrE_FakZalKwotaMax]          DECIMAL (15, 2) CONSTRAINT [DF_Tre_FakZalKwotaMax] DEFAULT ((0)) NOT NULL,
    [Tre_UstawAtrSQL]             INT             CONSTRAINT [DF_Tre_UstawAtrSQL] DEFAULT ((-1)) NOT NULL,
    [Tre_UstawAtrSQLDokTyp]       INT             CONSTRAINT [DF_Tre_UstawAtrSQLDokTyp] DEFAULT ((1)) NOT NULL,
    [TrE_SJRodzajPaliwa]          NVARCHAR (500)  CONSTRAINT [DF_TrE_SJRodzajPaliwa] DEFAULT ('') NOT NULL,
    [TrE_SJSystemCertyfikacji]    NVARCHAR (500)  CONSTRAINT [DF_TrE_SJSystemCertyfikacji] DEFAULT ('') NOT NULL,
    [TrE_SJPopiol]                NVARCHAR (15)   CONSTRAINT [DF_TrE_SJPopiol] DEFAULT ('') NOT NULL,
    [TrE_SJCzesciLotne]           NVARCHAR (15)   CONSTRAINT [DF_TrE_SJCzesciLotne] DEFAULT ('') NOT NULL,
    [TrE_SJWartoscOpalowa]        NVARCHAR (15)   CONSTRAINT [DF_TrE_SJWartoscOpalowa] DEFAULT ('') NOT NULL,
    [TrE_SJZdolnoscSpiekania]     NVARCHAR (15)   CONSTRAINT [DF_TrE_SJZdolnoscSpiekania] DEFAULT ('') NOT NULL,
    [TrE_SJWymiarZiarna]          NVARCHAR (15)   CONSTRAINT [DF_TrE_SJWymiarZiarna] DEFAULT ('') NOT NULL,
    [TrE_SJZawartoscPodziarna]    NVARCHAR (15)   CONSTRAINT [DF_TrE_SJZawartoscPodziarna] DEFAULT ('') NOT NULL,
    [TrE_SJZawartoscNadziarna]    NVARCHAR (15)   CONSTRAINT [DF_TrE_SJZawartoscNadziarna] DEFAULT ('') NOT NULL,
    [TrE_SJZawartoscWilgoci]      NVARCHAR (15)   CONSTRAINT [DF_TrE_SJZawartoscWilgoci] DEFAULT ('') NOT NULL,
    [TrE_SplitPay]                TINYINT         CONSTRAINT [DF_TrE_SplitPay] DEFAULT ((0)) NOT NULL,
    [TrE_KV7ID]                   INT             CONSTRAINT [DF_TrE_KV7ID] DEFAULT ((0)) NOT NULL,
    [TrE_CzySaCechyWymagane]      INT             CONSTRAINT [DF_TrE_CzySaCechyWymagane] DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [TrE_Primary] PRIMARY KEY CLUSTERED ([TrE_TrEID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TrEKategoria] FOREIGN KEY ([TrE_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_TrEPodmiot] FOREIGN KEY ([TrE_PodID], [TrE_PodmiotTyp]) REFERENCES [CDN].[PodmiotyView] ([Pod_PodId], [Pod_PodmiotTyp]),
    CONSTRAINT [FK_TrETowar] FOREIGN KEY ([TrE_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId]),
    CONSTRAINT [FK_TrETraNag] FOREIGN KEY ([TrE_TrNId]) REFERENCES [CDN].[TraNag] ([TrN_TrNID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [TrEMagazyn]
    ON [CDN].[TraElem]([TrE_MagId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrETraNag]
    ON [CDN].[TraElem]([TrE_TrNId] ASC, [TrE_Lp] ASC, [TrE_TrEID] ASC)
    INCLUDE([TrE_LpPow], [TrE_TypDokumentu], [TrE_TwrId], [TrE_KosztUslugi]) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrEPodmiot]
    ON [CDN].[TraElem]([TrE_PodID] ASC, [TrE_PodmiotTyp] ASC, [TrE_DataOpe] ASC, [TrE_TrEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrETowar]
    ON [CDN].[TraElem]([TrE_TwrId] ASC, [TrE_DataOpe] ASC, [TrE_TrEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrEKategoria]
    ON [CDN].[TraElem]([TrE_KatID] ASC, [TrE_DataOpe] ASC, [TrE_TrEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrEZwrot]
    ON [CDN].[TraElem]([TrE_ZwrId] ASC, [TrE_TrEID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrEUslugaZlozona]
    ON [CDN].[TraElem]([TrE_UslugaZlozonaId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrEProdukt]
    ON [CDN].[TraElem]([TrE_TrEIdProd] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrETwrKod]
    ON [CDN].[TraElem]([TrE_TrNId] ASC, [TrE_TwrKod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TraElem_Delete_Trigger ON cdn.TraElem FOR DELETE
AS
  SET NOCOUNT ON
  -- usuwanie atrybutów powiązanych z pozycją dokumentu HaMag
  IF EXISTS ( SELECT * FROM deleted )
  BEGIN
    DELETE FROM cdn.TraElemAtr WHERE TrA_TrEId > 0 AND TrA_TrEId IN (SELECT TrE_TrEId FROM deleted)
  END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.TraElem_InsertUpdateDelete_Trigger
  ON cdn.TraElem
  FOR INSERT, UPDATE, DELETE
AS
declare @intTranCount int
set @intTranCount = @@TRANCOUNT
IF (SELECT TOP 1 TrE_TypDokumentu FROM inserted where TrE_TypDokumentu = 301) = 301
BEGIN
DECLARE @EFakturaTrNId int
Declare dodane Cursor Local Fast_Forward For
Select TrE_TrNId
 From inserted
Open Dodane
While 1=1
  Begin
    Fetch Next From Dodane InTo
        @EfakturaTrNID
     If @@Fetch_Status <> 0 Break
   IF exists (SELECT * FROM CDN.TraNag WHERE TrN_TrNid = @EfakturaTrNId AND TrN_DabID IS NOT NULL AND TrN_TypDokumentu = 301 and TrN_EfakturaGUID IS NOT NULL)
   AND Exists (SELECT tre_treid FROM inserted where tre_cenat = 0 and tre_trnid = @EfakturaTrNId)
     BEGIN
          RAISERROR('##OPT34550##', 16, 1)--RaisError ('Nie można modyfikować e-faktury', 16,1)
          RollBack Tran
          Return
     END
END
END
  -- jesli zmienimy lppow na proformie to trzeba tez na wz do nich nalezacych
IF exists (SELECT TrE_TypDokumentu FROM inserted where TrE_TypDokumentu in (308,309,320) )
BEGIN
   IF  UPDATE( TrE_LpPow )
       AND NOT UPDATE( TrE_TrEId )
       AND NOT UPDATE( TrE_TrNId )
       AND NOT UPDATE( TrE_ZwrId )
       AND NOT UPDATE( TrE_TrEIdProd )
       AND NOT UPDATE( TrE_TypDokumentu )
       AND NOT UPDATE( TrE_Aktywny )
       AND NOT UPDATE( TrE_DataDok )
       AND NOT UPDATE( TrE_DataOpe )
       AND NOT UPDATE( TrE_TwrId )
       AND NOT UPDATE( TrE_Stawka )
       AND NOT UPDATE( TrE_Flaga )
       AND NOT UPDATE( TrE_Zrodlowa )
       AND NOT UPDATE( TrE_TwCNumer )
       AND NOT UPDATE( TrE_TypNB )
       AND NOT UPDATE( TrE_Cena0 )
       AND NOT UPDATE( TrE_Rabat )
       AND NOT UPDATE( TrE_CenaW )
       AND NOT UPDATE( TrE_CenaT )
       AND NOT UPDATE( TrE_Ilosc )
       AND NOT UPDATE( TrE_Jm )
       AND NOT UPDATE( TrE_JmZ )
       AND NOT UPDATE( TrE_JmCalkowite )
       AND NOT UPDATE( TrE_JmPrzelicznikL )
       AND NOT UPDATE( TrE_JmPrzelicznikM )
       AND NOT UPDATE( TrE_IloscJM )
       AND NOT UPDATE( TrE_WartoscNetto )
       AND NOT UPDATE( TrE_WartoscBrutto )
       AND NOT UPDATE( TrE_Cena0WD )
       AND NOT UPDATE( TrE_CenaWWD )
       AND NOT UPDATE( TrE_WartoscNettoWal )
       AND NOT UPDATE( TrE_WartoscBruttoWal )
       AND NOT UPDATE( TrE_KosztUslugi)
       AND NOT UPDATE (TrE_Atr1_DeAId)
       AND NOT UPDATE (TrE_Atr1_Kod)
       AND NOT UPDATE (TrE_Atr1_Wartosc)
       AND NOT UPDATE (TrE_Atr2_DeAId)
       AND NOT UPDATE (TrE_Atr2_Kod)
       AND NOT UPDATE (TrE_Atr2_Wartosc)
       AND NOT UPDATE (TrE_Atr3_DeAId)
       AND NOT UPDATE (TrE_Atr3_Kod)
       AND NOT UPDATE (TrE_Atr3_Wartosc)
       AND NOT UPDATE (TrE_Atr4_DeAId)
       AND NOT UPDATE (TrE_Atr4_Kod)
       AND NOT UPDATE (TrE_Atr4_Wartosc)
       AND NOT UPDATE (TrE_Atr5_DeAId)
       AND NOT UPDATE (TrE_Atr5_Kod)
       AND NOT UPDATE (TrE_Atr5_Wartosc)
     BEGIN
     set nocount on
       DECLARE
         @TrE_TrEId1 INT,
         @TrN_Rodzaj1 INT,
         @TrE_TrNId1 INT,
         @TrE_TypDokumentu1 INT,
         @TrE_LpPow1 INT,
         @TrE_TrEId2 INT,
         @PFzRO int,
         @TrE_TrEIdRO INT,
         @TrE_LpPow2 INT,
   @TrE_TrEIdWZ INT
       DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
         SELECT TrE_TrEId, TrE_TrNId, TrE_LpPow, TrE_TypDokumentu
         FROM inserted
         ORDER BY TrE_TrNId, TrE_Lp
       OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO @TrE_TrEId1, @TrE_TrNId1,  @TrE_LpPow1, @TrE_TypDokumentu1
          IF @@FETCH_STATUS <> 0 BREAK
          SELECT TOP 1
            @TrN_Rodzaj1     = TrN_Rodzaj
          FROM cdn.TraNag
            JOIN cdn.TraElem ON TrN_TrNId = TrE_TrNId AND TrE_TrEId = @TrE_TrEId1
         IF (UPDATE (TrE_LpPow) and @TrE_TypDokumentu1 = 320)
         begin
    SELECT TOP 1 @TrE_TrEIdWZ = a.TrE_TrEId
            FROM CDN.TraElem a
            JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID AND TrR_FaTyp =320 AND TrR_TrNTyp NOT IN (317,309,320)
            JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow
            JOIN CDN.tranag  on TrR_TrNId = TrN_TrNID
            WHERE b.TrE_TrEId = @TrE_TrEId1 AND TrN_Rodzaj not in (302200,302202) AND a.TrE_TrEId not in (SELECT TeR_ChildId FROM CDN.TraElemRelacje WHERE TeR_ParentId = @TrE_TrEId1)
            AND a.TrE_TrEId not in (SELECT TeR_ParentId FROM CDN.TraElemRelacje WHERE TeR_ChildId = @TrE_TrEId1)
            ORDER BY TrR_TrRId DESC
           INSERT INTO CDN.TraElemRelacje (TeR_ParentTyp,TeR_ParentId,TeR_ChildTyp,TeR_ChildId,TeR_Flaga)
            SELECT TOP 1 b.TrE_TypDokumentu,b.TrE_TrEId,a.TrE_TypDokumentu,a.TrE_TrEId,0
            FROM CDN.TraElem a
            JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID AND TrR_FaTyp =320 AND TrR_TrNTyp NOT IN (317,309,320)
            JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow
            JOIN CDN.tranag  on TrR_TrNId = TrN_TrNID
            WHERE b.TrE_TrEId = @TrE_TrEId1 AND TrN_Rodzaj not in (302200,302202) AND a.TrE_TrEId not in (SELECT TeR_ChildId FROM CDN.TraElemRelacje WHERE TeR_ParentId = @TrE_TrEId1)
            AND a.TrE_TrEId not in (SELECT TeR_ParentId FROM CDN.TraElemRelacje WHERE TeR_ChildId = @TrE_TrEId1)
            ORDER BY TrR_TrRId DESC
           select @PFzRO = a.Trr_TrNId from cdn.tranagrelacje a
           where a.TrR_FaId =@TrE_TrNId1 AND a.Trr_TrNTyp =308 AND a.Trr_FaTyp =320
    if @PFzRO > 0
  begin
select @TrE_TrEIdRO = 0, @TrE_TrEId2 = 0
create table #RO (TrE_TrEIdRO int ,TrE_TrEIdFA int)
    insert into #RO(TrE_TrEIdRO)
 select TeR_ChildId from cdn.traelemrelacje where TeR_ParentId = @TrE_TrEId1 and TeR_ParentTyp = 320  and TeR_ChildTyp = 308
    insert into #RO(TrE_TrEIdRO)
 select TeR_ParentId from cdn.traelemrelacje where TeR_ChildId = @TrE_TrEId1 and TeR_ChildTyp = 320  and TeR_ParentTyp = 308
select top 1 @TrE_TrEId2 = TeR_ChildId from cdn.traelemrelacje where TeR_ParentId = @TrE_TrEId1 and TeR_ParentTyp = 320  and TeR_ChildTyp in (302,306)
and TeR_ChildId not in (SELECT TeR_ChildId FROM CDN.TraElemRelacje WHERE TeR_ParentId in (select TrE_TrEIdRO from #RO)) order by ter_terid desc
if @TrE_TrEId2 = 0
  select top 1 @TrE_TrEId2 = TeR_ParentId from cdn.traelemrelacje where TeR_ChildId = @TrE_TrEId1 and TeR_ChildTyp = 320  and TeR_ParentTyp in (302,306)
  and TeR_ParentId not in (SELECT TeR_ChildId FROM CDN.TraElemRelacje WHERE TeR_ParentId in (select TrE_TrEIdRO from #RO)) order by ter_terid desc
if @TrE_TrEId2 <> 0
begin
update #RO set TrE_TrEIdFA = @TrE_TrEId2
insert into CDN.TraElemRelacje (TeR_ParentTyp,TeR_ParentId,TeR_ChildTyp,TeR_ChildId,TeR_Flaga)
select 308,TrE_TrEIdRO,TrE_TypDokumentu,TrE_TrEIdFA,0 from #RO join cdn.traelem on TrE_TrEIdFA = TrE_TrEId--where  TrE_TrEID = @TrE_TrEId2
--select 308,@TrE_TrEIdRO,TrE_TypDokumentu,@TrE_TrEId2,0 from cdn.traelem where  TrE_TrEID = @TrE_TrEId2
exec [CDN].[UstawRezerwacje] @TrE_TrEId2,0,0
end
drop table #RO
/*
     select @TrE_LpPow2 = TrE_Lppow
     FROM Cdn.TraElem
     where TrE_TreId = @TrE_TrEId1
     select @TrE_TrEIdRO = tre_treid from cdn.traelem where tre_trnid = @PFzRO and tre_lppow = @TrE_LpPow2
     SELECT TOP 1 @TrE_TrEId2 = a.TrE_TrEId
     FROM CDN.TraElem a
     JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID AND TrR_FaTyp IN (308,309) AND TrR_TrNTyp NOT IN (317,309,308,320)
     JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = @TrE_Lppow1
     WHERE b.TrE_TrEId = @TrE_TrEIdRO AND a.TrE_TrEId not in (SELECT TeR_ChildId FROM CDN.TraElemRelacje WHERE TeR_ParentId = @TrE_TrEIdRO)
     ORDER BY TrR_TrRId DESC
     INSERT INTO CDN.TraElemRelacje (TeR_ParentTyp,TeR_ParentId,TeR_ChildTyp,TeR_ChildId,TeR_Flaga)
     SELECT TOP 1 b.TrE_TypDokumentu,b.TrE_TrEId,a.TrE_TypDokumentu,a.TrE_TrEId,0
     FROM CDN.TraElem a
     JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID AND TrR_FaTyp IN (308,309) AND TrR_TrNTyp NOT IN (317,309,308,320)
     JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = @TrE_Lppow1
     WHERE b.TrE_TrEId = @TrE_TrEIdRO AND a.TrE_TrEId not in (SELECT TeR_ChildId FROM CDN.TraElemRelacje WHERE TeR_ParentId = @TrE_TrEIdRO)
     ORDER BY TrR_TrRId DESC
     exec [CDN].[UstawRezerwacje] @TrE_TrEId2,0,0
*/
    end
  end
          /*IF (UPDATE (TrE_LpPow) and @TrN_Rodzaj1 = 320009)
          BEGIN
            UPDATE a SET a.TrE_LppowRel = d.TrE_Lppow
            FROM Cdn.TraElem a
            JOIN deleted d ON  d.TrE_TreId = @TrE_TrEId1
            where a.TrE_TreId = @TrE_TrEId1
          END*/
          IF (UPDATE (TrE_LpPow) and @TrN_Rodzaj1 in (320000,320009))
          BEGIN
            UPDATE a SET a.TrE_Lppow = d.TrE_Lppow
            FROM Cdn.TraElem a
            JOIN deleted d ON  d.TrE_TreId = @TrE_TrEId1
            where a.TrE_TreId = @TrE_TrEId1
   --poprawa zgłoszenia 150109
    UPDATE a SET a.TrE_LppowRel = a.TrE_Lppow ,a.TrE_Lppow = @TrE_Lppow1 FROM Cdn.TraElem a
    JOIN deleted d ON  d.TrE_TreId = @TrE_TrEId1
     join cdn.traelemrelacje on TeR_ChildId = a.tre_treid and TeR_ParentId = @TrE_TrEId1 and TeR_ChildTyp = 306
  join cdn.tranag WZ on a.tre_trnid = WZ.trn_trnid
  join cdn.tranagrelacje on trr_faid =  WZ.trn_trnid and TrR_TrNTyp = 302
  join cdn.traelem b on b.tre_trnid = TrR_TrNId and b.tre_treid = @TrE_TrEIdWZ
   --poprawa zgłoszenia 154645
    UPDATE a SET a.TrE_LppowRel = a.TrE_Lppow ,a.TrE_Lppow = @TrE_Lppow1 FROM Cdn.TraElem a
    where a.tre_zwrid in(
    select a.tre_treid FROM Cdn.TraElem a
     JOIN deleted d ON  d.TrE_TreId = @TrE_TrEId1
     join cdn.traelemrelacje on TeR_ChildId = a.tre_treid and TeR_ParentId = @TrE_TrEId1 and TeR_ChildTyp = 306
  join cdn.tranag WZ on a.tre_trnid = WZ.trn_trnid
  join cdn.tranagrelacje on trr_faid =  WZ.trn_trnid and TrR_TrNTyp = 302
  join cdn.traelem b on b.tre_trnid = TrR_TrNId and b.tre_treid = @TrE_TrEIdWZ)
            --UPDATE a SET a.TrE_LppowRel = a.TrE_Lppow ,a.TrE_Lppow = @TrE_Lppow1
            --FROM Cdn.TraElem a
            --JOIN deleted d ON  d.TrE_TreId = @TrE_TrEId1 and a.TrE_Lppow = d.TrE_Lppow and a.TrE_TwrId = d.TrE_TwrId
            --JOIN CDN.TraNagRelacje ON d.TrE_TrnId = TrR_FaId
            --WHERE TrR_TrNTyp = 306 AND a.TrE_TrnId = TrR_TrNId
          END
          IF (UPDATE (TrE_LpPow) and @TrE_TypDokumentu1 in (308,309))
           BEGIN
            SELECT TOP 1 @TrE_TrEId2 = a.TrE_TrEId
            FROM CDN.TraElem a
            JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID AND TrR_FaTyp IN (308,309) AND TrR_TrNTyp NOT IN (317,309,308,320)
            JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow
            WHERE b.TrE_TrEId = @TrE_TrEId1 AND a.TrE_TrEId not in (SELECT TeR_ChildId FROM CDN.TraElemRelacje WHERE TeR_ParentId = @TrE_TrEId1)
            ORDER BY TrR_TrRId DESC
            INSERT INTO CDN.TraElemRelacje (TeR_ParentTyp,TeR_ParentId,TeR_ChildTyp,TeR_ChildId,TeR_Flaga)
            SELECT TOP 1 b.TrE_TypDokumentu,b.TrE_TrEId,a.TrE_TypDokumentu,a.TrE_TrEId,0
            FROM CDN.TraElem a
            JOIN CDN.tranagrelacje on TrR_TrNID = a.TrE_TrNID AND TrR_FaTyp IN (308,309) AND TrR_TrNTyp NOT IN (317,309,308)
            JOIN CDN.traelem b on TrR_FaId = b.TrE_TrNID AND a.TrE_Lppow = b.TrE_LpPow
            WHERE b.TrE_TrEId = @TrE_TrEId1 AND a.TrE_TrEId not in (SELECT TeR_ChildId FROM CDN.TraElemRelacje WHERE TeR_ParentId = @TrE_TrEId1)
            AND a.TrE_TrEId not in (SELECT TeR_ParentId FROM CDN.TraElemRelacje WHERE TeR_ChildId = @TrE_TrEId1) and b.TrE_LppowRel is not null
            ORDER BY TrR_TrRId DESC
            UPDATE CDN.TraElem SET TrE_Lppow = TrE_LppowRel,TrE_LppowRel = NULL  WHERE TrE_TrEId = @TrE_TrEId1 and TrE_LppowRel is not null
            exec [CDN].[UstawRezerwacje] @TrE_TrEId2,0,0
           END
       END
      CLOSE Dodawane
      DEALLOCATE Dodawane
      set nocount off
    END
 end
IF exists (SELECT TrE_TypDokumentu FROM inserted where TrE_TypDokumentu = 311 ) or exists (SELECT TrE_TypDokumentu FROM deleted where TrE_TypDokumentu = 311 )
BEGIN
     set nocount on
 /*      DECLARE
         @TrE_TrEIdAI INT
    DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
         SELECT TrE_TrEId
         FROM inserted
         ORDER BY TrE_TrNId, TrE_Lp
       OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO @TrE_TrEIdAI
          IF @@FETCH_STATUS <> 0 BREAK
    IF @@TranCount !=@intTranCount
   BREAK
If (Update (TrE_Atr1_DeAId) Or Update (TrE_Atr1_Kod) Or Update (TrE_Atr1_Wartosc) Or Update (TrE_Atr2_DeAId) Or Update (TrE_Atr2_Kod) Or Update (TrE_Atr2_Wartosc)
         Or Update (TrE_Atr3_DeAId) Or Update (TrE_Atr3_Kod) Or Update (TrE_Atr3_Wartosc) Or Update (TrE_Atr4_DeAId) Or Update (TrE_Atr4_Kod) Or Update (TrE_Atr4_Wartosc)
         Or Update (TrE_Atr5_DeAId) Or Update (TrE_Atr5_Kod) Or Update (TrE_Atr5_Wartosc))
         BEGIN
           DELETE FROM Cdn.TraElemAtr WHERE  Tra_TrEId =@TrE_TrEIdAI
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,1,TrE_Atr1_DeAId,TrE_Atr1_Kod,TrE_Atr1_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEIdAI AND TrE_Atr1_DeAId>0 AND TrE_Atr1_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,2,TrE_Atr2_DeAId,TrE_Atr2_Kod,TrE_Atr2_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEIdAI AND TrE_Atr2_DeAId>0 AND TrE_Atr2_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,3,TrE_Atr3_DeAId,TrE_Atr3_Kod,TrE_Atr3_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEIdAI AND TrE_Atr3_DeAId>0 AND TrE_Atr3_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,4,TrE_Atr4_DeAId,TrE_Atr4_Kod,TrE_Atr4_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEIdAI AND TrE_Atr4_DeAId>0 AND TrE_Atr4_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,5,TrE_Atr5_DeAId,TrE_Atr5_Kod,TrE_Atr5_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEIdAI AND TrE_Atr5_DeAId>0 AND TrE_Atr5_DeAId is not NULL
         END
    END
      CLOSE Dodawane
      DEALLOCATE Dodawane*/
     set nocount off
return
end
  -- uruchamiamy procedurę obsługi zasobów, jesli są podmieniane jakiekolwiek pola za wyjatkiem TrE_LpPow
   IF        (    UPDATE( TrE_LpPow )
              OR UPDATE( TrE_Lp )
              OR UPDATE( TrE_PodmiotTyp )
              OR UPDATE( TrE_PodId )
              OR UPDATE( TrE_KatId )
              OR UPDATE( TrE_TwrNazwa )
              OR UPDATE( TrE_TwrEAN )
              OR UPDATE( TrE_TwrNumerKat )
              OR UPDATE( TrE_TwrKod )
              OR UPDATE( TrE_TwrOpis )
     OR UPDATE( TrE_KosztKGO )
              OR UPDATE( TrE_TwrSWW )
              OR UPDATE( TrE_Prog )
              OR UPDATE( TrE_UpustTyp )
              OR UPDATE( TrE_Upust )
              OR UPDATE( TrE_UpustKnt )
              OR UPDATE( TrE_UpustKntTyp )
              OR UPDATE( TrE_Waluta )
              OR UPDATE( TrE_KursNumer )
              OR UPDATE( TrE_KursL )
              OR UPDATE( TrE_KursM )
              OR UPDATE( TrE_WartoscZakupuWylicz )
              OR UPDATE (TrE_Atr1_DeAId)
              OR UPDATE (TrE_Atr1_Kod)
              OR UPDATE (TrE_Atr1_Wartosc)
              OR UPDATE (TrE_Atr2_DeAId)
              OR UPDATE (TrE_Atr2_Kod)
              OR UPDATE (TrE_Atr2_Wartosc)
              OR UPDATE (TrE_Atr3_DeAId)
              OR UPDATE (TrE_Atr3_Kod)
              OR UPDATE (TrE_Atr3_Wartosc)
              OR UPDATE (TrE_Atr4_DeAId)
              OR UPDATE (TrE_Atr4_Kod)
              OR UPDATE (TrE_Atr4_Wartosc)
              OR UPDATE (TrE_Atr5_DeAId)
              OR UPDATE (TrE_Atr5_Kod)
              OR UPDATE (TrE_Atr5_Wartosc)
     OR UPDATE (TrE_WartoscTymczasowa)
     OR UPDATE (TrE_ZTwID)
              OR UPDATE (TrE_ZTwGlowny)
              OR UPDATE (TrE_ZestawWiazanie)
              OR UPDATE (TrE_zTwKod)
     OR UPDATE (TrE_TwrTyp)
     OR UPDATE (TrE_TwrKodDostawcy)
     OR UPDATE (TrE_DoZwrotu)
     OR UPDATE (TrE_SplitPay)
            )
       AND NOT UPDATE( TrE_TrEId )
       AND NOT UPDATE( TrE_TrNId )
       AND NOT UPDATE( TrE_ZwrId )
       AND NOT UPDATE( TrE_TrEIdProd )
--       AND NOT UPDATE( TrE_Lp )
       AND NOT UPDATE( TrE_TypDokumentu )
       AND NOT UPDATE( TrE_Aktywny )
       AND NOT UPDATE( TrE_DataDok )
       AND NOT UPDATE( TrE_DataOpe )
--       AND NOT UPDATE( TrE_PodmiotTyp )
--       AND NOT UPDATE( TrE_PodID )
--       AND NOT UPDATE( TrE_KatID )
       AND NOT UPDATE( TrE_TwrId )
--       AND NOT UPDATE( TrE_TwrNazwa )
--       AND NOT UPDATE( TrE_TwrEAN )
--       AND NOT UPDATE( TrE_TwrNumerKat )
--       AND NOT UPDATE( TrE_TwrKod )
--       AND NOT UPDATE( TrE_TwrOpis )
--       AND NOT UPDATE( TrE_TwrSWW )
       AND NOT UPDATE( TrE_Stawka )
       AND NOT UPDATE( TrE_Flaga )
       AND NOT UPDATE( TrE_Zrodlowa )
       AND NOT UPDATE( TrE_TwCNumer )
       AND NOT UPDATE( TrE_TypNB )
       AND NOT UPDATE( TrE_Cena0 )
       AND NOT UPDATE( TrE_Rabat )
       AND NOT UPDATE( TrE_CenaW )
--       AND NOT UPDATE( TrE_Waluta )
--       AND NOT UPDATE( TrE_KursNumer )
--       AND NOT UPDATE( TrE_KursL )
--       AND NOT UPDATE( TrE_KursM )
       AND NOT UPDATE( TrE_CenaT )
       AND NOT UPDATE( TrE_Ilosc )
       AND NOT UPDATE( TrE_Jm )
       AND NOT UPDATE( TrE_JmZ )
       AND NOT UPDATE( TrE_JmCalkowite )
       AND NOT UPDATE( TrE_JmPrzelicznikL )
       AND NOT UPDATE( TrE_JmPrzelicznikM )
       AND NOT UPDATE( TrE_IloscJM )
       AND NOT UPDATE( TrE_WartoscNetto )
       AND NOT UPDATE( TrE_WartoscBrutto )
       AND NOT UPDATE( TrE_Cena0WD )
       AND NOT UPDATE( TrE_CenaWWD )
       AND NOT UPDATE( TrE_WartoscNettoWal )
       AND NOT UPDATE( TrE_WartoscBruttoWal )
       AND NOT UPDATE( TrE_MagId )
--       AND NOT UPDATE( TrE_Prog )
--       AND NOT UPDATE( TrE_UpustTyp )
--       AND NOT UPDATE( TrE_Upust )
--       AND NOT UPDATE( TrE_UpustKnt )
--       AND NOT UPDATE( TrE_UpustKntTyp )
       AND NOT UPDATE( TrE_KosztUslugi)
       AND NOT UPDATE (TrE_WyborDostaw)
       BEGIN
     set nocount on
  --trzeba skasowac subelemnty dla mm jak były dostawy bo sa dwa na dwa magazyny a potem nie wiadomo jak znalesc oba bo mamy link do jednego
   DECLARE @TrE1 TABLE ( TrEId INT )
   INSERT INTO @TrE1 ( TrEId ) SELECT TrE_TrEId FROM deleted join cdn.tranag on tre_trnid = trn_trnid   where TrE_TypDokumentu =312 and TrE_WyborDostaw = 1 and trn_bufor = 1
   DELETE cdn.TraSElem FROM cdn.TraSElem JOIN @TrE1 ON TrEId = TrS_TrEId
      /*If (Update (TrE_Atr1_DeAId) Or Update (TrE_Atr1_Kod) Or Update (TrE_Atr1_Wartosc) Or Update (TrE_Atr2_DeAId) Or Update (TrE_Atr2_Kod) Or Update (TrE_Atr2_Wartosc)
         Or Update (TrE_Atr3_DeAId) Or Update (TrE_Atr3_Kod) Or Update (TrE_Atr3_Wartosc) Or Update (TrE_Atr4_DeAId) Or Update (TrE_Atr4_Kod) Or Update (TrE_Atr4_Wartosc)
         Or Update (TrE_Atr5_DeAId) Or Update (TrE_Atr5_Kod) Or Update (TrE_Atr5_Wartosc))
         begin
       DECLARE
         @TrE_TrEIdAtr INT
    DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
         SELECT TrE_TrEId
         FROM inserted
         ORDER BY TrE_TrNId, TrE_Lp
       OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO @TrE_TrEIdAtr
          IF @@FETCH_STATUS <> 0 BREAK
    IF @@TranCount !=@intTranCount
   BREAK
If (Update (TrE_Atr1_DeAId) Or Update (TrE_Atr1_Kod) Or Update (TrE_Atr1_Wartosc) Or Update (TrE_Atr2_DeAId) Or Update (TrE_Atr2_Kod) Or Update (TrE_Atr2_Wartosc)
         Or Update (TrE_Atr3_DeAId) Or Update (TrE_Atr3_Kod) Or Update (TrE_Atr3_Wartosc) Or Update (TrE_Atr4_DeAId) Or Update (TrE_Atr4_Kod) Or Update (TrE_Atr4_Wartosc)
         Or Update (TrE_Atr5_DeAId) Or Update (TrE_Atr5_Kod) Or Update (TrE_Atr5_Wartosc))
         BEGIN
           DELETE FROM Cdn.TraElemAtr WHERE  Tra_TrEId =@TrE_TrEIdAtr
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,1,TrE_Atr1_DeAId,TrE_Atr1_Kod,TrE_Atr1_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEIdAtr AND TrE_Atr1_DeAId>0 AND TrE_Atr1_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,2,TrE_Atr2_DeAId,TrE_Atr2_Kod,TrE_Atr2_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEIdAtr AND TrE_Atr2_DeAId>0 AND TrE_Atr2_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,3,TrE_Atr3_DeAId,TrE_Atr3_Kod,TrE_Atr3_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEIdAtr AND TrE_Atr3_DeAId>0 AND TrE_Atr3_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,4,TrE_Atr4_DeAId,TrE_Atr4_Kod,TrE_Atr4_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEIdAtr AND TrE_Atr4_DeAId>0 AND TrE_Atr4_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,5,TrE_Atr5_DeAId,TrE_Atr5_Kod,TrE_Atr5_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEIdAtr AND TrE_Atr5_DeAId>0 AND TrE_Atr5_DeAId is not NULL
         END
    END
      CLOSE Dodawane
      DEALLOCATE Dodawane
      end*/
     set nocount off
GOTO KOMUNIKAT
end
  DECLARE
    @MyIdentity         INT, -- niezwykle ważne dla ProdElem
    -- zmienne pomocnicze dla kursora
    @TrE_TrEId          INT,
    @TrE_TrNId         INT,
    @TrE_ZwrId          INT,
    @TrE_Lp             INT,
    @TrE_LpPow           INT,
    @TrE_TypDokumentu   SMALLINT,
    @TrE_Aktywny        SMALLINT,
    @TrE_DataDok        DATETIME,
    @TrE_DataOpe        DATETIME,
    @TrE_TwrId          INT,
    @TrE_TwrKod         NVarchar(50),
    @TrE_TwrNazwa       NVarchar(255),
    @TrE_Stawka         DECIMAL(5,2),
    @TrE_CenaW          DECIMAL(17,4),
    @TrE_CenaWWD        DECIMAL(17,4),
    @TrE_CenaT          DECIMAL(17,4),
    @TrE_Waluta         NVarchar(3),
    @TrE_KursNumer      INT,
    @TrE_KursL          DECIMAL(15,4),
    @TrE_KursM          DECIMAL(5,0),
    @TrE_Ilosc          DECIMAL(15,4),
    @TrE_WartoscNetto   DECIMAL(15,2),
    @TrE_WartoscBrutto  DECIMAL(15,2),
    @TrE_WartoscZakupu  DECIMAL(15,2),
    @TrE_JMPrzelicznikL DECIMAL(15,2),
    @TrE_JMPrzelicznikM DECIMAL( 7,0),
    @TrE_IloscJM        DECIMAL(15,4),
    @TrE_PodmiotTyp     INT,
    @TrE_PodId          INT,
    @TrE_KosztUslugi    DECIMAL(15,2),
    @TrE_TypNB          TINYINT,
    @Tre_WyborDostaw    TINYINT,
    @TrE_IFA24Mag       INT,
    @Tre_MagId          INT,
 @TrE_Kaucja   SMALLINT,
 @TrE_KosztUslugiZDok DECIMAL(15,2),
    -- zmienne z naglowka dla poprawnego zbudowania subelementu
    @TrN_TrNId      INT,
    @TrN_FaId       INT,
    @TrN_ZwrId      INT,
    @TrN_Rodzaj     INT,
    @TrN_Bufor      SMALLINT,
    @TrN_MagZrdId   INT,
    @TrN_MagDocId   INT,
    @TrN_DataDok    DATETIME,
    @TrN_DataWys    DATETIME,
    @TrN_DataOpe    DATETIME,
    @TrN_TrSTyp     SMALLINT,
    @TrN_TypNB      TINYINT,
    @TrN_PodmiotTyp     INT,
    @TrN_PodId          INT,
    @TrN_Centrala   TINYINT,
    @TrN_Waluta     NVarchar(3),
    @TrN_KursNumer      INT,
    @TrN_KursL     DECIMAL(15,4),
    @TrN_KursM     DECIMAL(5,0),
    @WalutaSys     NVarchar(3),
    @TrN_DekId     INT,
    @TrN_NumerPelny  NVarchar(31),
    -- zmienne dla dokumentu pierwotnego
    @TrN_TrNId_Old        INT,
    @TrN_TrNId_PAdoFA_Old INT,
    @TrN_FaId_Old         INT,
    @TrE_TrEId_Old        INT,
    -- zmienne dla kreowanego subelementu
    @TrS_TrSId      INT,
    @TrS_TrEId      INT,
    @TrS_TrSIdDost  INT,
    @TrS_ZwrId      INT,
    @TrS_TwrId      INT,
    @TrS_MagId      INT,
    @TrS_Rodzaj     INT,
    @TrS_Typ        INT,
    @TrS_Metoda     INT,
    @TrS_DataOpe    DATETIME,
    @TrS_Ilosc      DECIMAL(15,4),
    @TrS_Wartosc    DECIMAL(15,2),
    @TrS_Cena       DECIMAL(17,4),
    @TrS_Termin     DATETIME,
    -- zmienne pomocnicze dla metody
    @QUAN           INT,
    @Metoda         INT,
    @ZawszeBraki    INT,
 @ZezwalajMimoRez INT,
    @DataZamowienia INT,
    -- zmienne pomocnicze symulacji marży
    @Marza_Sym_Ostatnia   INT,
    @Marza_Sym_Srednia    INT,
    -- Pomocnicza dla kursora
    @TrS_TrSId_K    INT,
    @TrS_TrEId_K    INT,
    -- zmienna dla aktualizacji ceny zakupu i marz
    @TwC_TwCId          INT,
    @TwC_TwCNumer       INT,
    @TwC_Wartosc        DECIMAL(17,4),
    @TwC_Marza          DECIMAL(15,2), -- potrzebna, zeby zbadać, czy nie jest za duża
    @TwC_MarzaWStu      DECIMAL(15,2), -- potrzebna, zeby zbadać, czy nie jest za duża
    @TwC_Waluta         NVarchar(3),
    @TwC_Typ            SMALLINT,
    @Twr_Typ            SMALLINT,
    @Twr_KosztUslugiTyp SMALLINT,
    @Twr_KosztUslugi    DECIMAL(17,4),
    @Twr_Stawka         DECIMAL(5,2),
    @Twr_KursL          DECIMAL(15,4),
    @Twr_KursM          DECIMAL(5,0),
    @Twr_KosztUslugiNew     DECIMAL(17,4),
    @Twr_KosztUslugiWalNew  DECIMAL(17,4),
    @Waluta     NVarchar(3),
    @KursNumer  INT,
    @KursL     DECIMAL(15,4),
    @KursM     DECIMAL(5,0),
    @CenaW_New       DECIMAL(17,4),
    -- aktualizacja ceny zakupu przy zapisie MM-OL
    @Aktualizuj_CenaZ_MMOL TINYINT,
    -- dla liczenia wzoru na marże cen sprzedaży, gdy aktualizacja jest na "Nie"
    @CenaZakupuNew    DECIMAL(17,4),
    @CenaZakupuNewPLN DECIMAL(17,4),
    @CenaZakupuNewWal DECIMAL(17,4),
    -- dla dostaw
    @DostIloscRecordowReal int,
    @DostIloscRecordow int,
    @DostIloscRecordowDodanych int,
    @DostTrS_Ilosc decimal(15,4),
    @DostTrS_TrSId int,
    @ResztaWartosc DECIMAL(15,2),
 --dla atrybutów
 @Tre_UstawAtrSQL INT,
 @Tre_UstawAtrSQLDokTyp INT,
    -- pomocnicze dla komunikatu
    @Data_Dost          DATETIME,
    @Komunikat          NVarchar(250)
  SET NOCOUNT ON
  -- ustawienie komunikatu
  SET @Komunikat = ''
  --zaokraglenia
   DECLARE @ZaokraglajDo  SMALLINT
   IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=3048 )
    SELECT @ZaokraglajDo=case when Fir_Wartosc = 1 then 4 else 2 end FROM Cdn.Firma WHERE Fir_Numer=3048
  ELSE
    SELECT @ZaokraglajDo=2
  -- symbol waluty systemowej
  SET @WalutaSys = ( SELECT SUBSTRING(Fir_Wartosc,1,3) FROM cdn.Firma WHERE Fir_Numer = 3 )
  -- elementy kasowane jesli wybordostawy = 2 to nie robimy nic
  DECLARE @TrE TABLE ( TrEId INT )
  INSERT INTO @TrE ( TrEId ) SELECT TrE_TrEId FROM deleted
  IF EXISTS(SELECT TrS_WyborDostaw FROM cdn.TraSElem JOIN @TrE ON TrEId = TrS_TrEId WHERE ISNULL(TrS_WyborDostaw,0) = 2)
  RETURN
  IF EXISTS(SELECT d.TrE_Aktywny FROM deleted d JOIN inserted i ON  d.TrE_TrEId = i.TrE_TrEId WHERE d.TrE_Aktywny = 3 and i.TrE_Aktywny =1)
  RETURN
  IF EXISTS(SELECT d.TrE_Aktywny FROM deleted d JOIN inserted i ON  d.TrE_TrEId = i.TrE_TrEId WHERE d.TrE_Aktywny = 2 and i.TrE_Aktywny =1)
  RETURN
  DELETE cdn.TraSElem FROM cdn.TraSElem JOIN @TrE ON TrEId = TrS_TrEId -- WHERE TrS_TrEId IN ( SELECT TrE_TrEId FROM deleted ) -- = @TrE_TrEId
  IF NOT EXISTS ( SELECT * FROM inserted ) AND EXISTS ( SELECT * FROM deleted )
  BEGIN
      DECLARE
         @TrE_TrEId3 INT,
         @TrE_TypDok3 INT
       DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
         SELECT TrE_TrEId, TrE_TypDokumentu
         FROM deleted
         ORDER BY TrE_TrEId
       OPEN Dodawane
       WHILE 1=1
        BEGIN
          FETCH NEXT FROM Dodawane INTO @TrE_TrEId3, @TrE_TypDok3
          IF @@FETCH_STATUS <> 0 BREAK
          EXEC [CDN].[UstawRezerwacje]  @TrE_TrEId3, 1,@TrE_TypDok3
      DELETE CDN.TraElemRelacje WHERE TeR_ParentTyp=@TrE_TypDok3 and TeR_ParentId=@TrE_TrEId3
   DELETE CDN.TraElemRelacje WHERE TeR_ChildTyp=@TrE_TypDok3 and TeR_ChildId=@TrE_TrEId3
       END
      CLOSE Dodawane
      DEALLOCATE Dodawane
     DELETE CDN.TraSElem WHERE TRS_TrEIdWydania in(SELECT TrE_TrEId FROM deleted)
  END
  -- Metoda rozliczania magazynu
  IF EXISTS ( SELECT * FROM inserted )
    BEGIN
      SET @Metoda = ( SELECT TOP 1 ISNULL( Fir_Wartosc,1 ) FROM cdn.Firma WHERE Fir_Numer = 1352 )
      SET @QUAN   = ( SELECT TOP 1 ISNULL( Fir_Wartosc,0 ) FROM cdn.Firma WHERE Fir_Numer = 1485 )
    END
  -- elementy dodawane
  DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrE_TrEId, TrE_TrNId, TrE_ZwrId, TrE_Lp, TrE_TypDokumentu, TrE_Aktywny, TrE_DataDok, TrE_DataOpe, TrE_TwrId, TrE_TwrKod, TrE_Stawka ,
           TrE_CenaW, TrE_CenaWWD, TrE_CenaT, TrE_Waluta, TrE_KursNumer, TrE_KursL, TrE_KursM, TrE_Ilosc, TrE_WartoscNetto, TrE_WartoscBrutto,
           TrE_JMPrzelicznikL, TrE_JMPrzelicznikM, TrE_PodmiotTyp, TrE_PodId, TrE_LpPow, TrE_IloscJM, TrE_TypNB, Tre_WyborDostaw, Tre_MagID, TrE_IFA24Mag, TrE_KosztUslugi , case when Tre_CenaZCzteremaMiejscami = 1 then 4 else 2 end ,Tre_UstawAtrSQL,Tre_UstawAtrSQLDokTyp, TrE_Kaucja
      FROM inserted
      ORDER BY TrE_TrNId, TrE_Lp
    OPEN Dodawane
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM Dodawane INTO @TrE_TrEId, @TrE_TrNId,  @TrE_ZwrId, @TrE_Lp, @TrE_TypDokumentu, @TrE_Aktywny, @TrE_DataDok, @TrE_DataOpe, @TrE_TwrId, @TrE_TwrKod, @TrE_Stawka,
                                      @TrE_CenaW, @TrE_CenaWWD, @TrE_CenaT, @TrE_Waluta, @TrE_KursNumer, @TrE_KursL, @TrE_KursM, @TrE_Ilosc, @TrE_WartoscNetto, @TrE_WartoscBrutto,
                                      @TrE_JMPrzelicznikL, @TrE_JMPrzelicznikM, @TrE_PodmiotTyp, @TrE_PodId, @TrE_LpPow, @TrE_IloscJM, @TrE_TypNB, @Tre_WyborDostaw, @TrE_MagId, @TrE_IFA24Mag , @TrE_KosztUslugiZDok, @ZaokraglajDo  ,@Tre_UstawAtrSQL,@Tre_UstawAtrSQLDokTyp, @TrE_Kaucja
        IF @@FETCH_STATUS <> 0 BREAK
  IF @@TranCount !=@intTranCount
  BREAK
        -- Zmiana towaru musimy usunąć relacje na elementach
        IF UPDATE( TrE_TwrId )
          BEGIN
            IF NOT EXISTS (SELECT TrE_TwrId FROM deleted WHERE  @TrE_TrEId =  TrE_TrEId AND @TrE_TwrId = TrE_TwrId)
               BEGIN
     DECLARE
      @TrE_TrEIdWiNi1 INT,
      @TrE_TypWiNi1 INT
     DECLARE Kasowane CURSOR LOCAL FAST_FORWARD FOR
      SELECT TrE_TrEId, TrE_TypDokumentu
      FROM deleted
      ORDER BY TrE_TrEId
     OPEN Kasowane
     WHILE 1=1
     BEGIN
      FETCH NEXT FROM Kasowane INTO @TrE_TrEIdWiNi1, @TrE_TypWiNi1
      IF @@FETCH_STATUS <> 0 BREAK
      DELETE CDN.TraElemRelacje WHERE TeR_ParentTyp=@TrE_TypWiNi1 and TeR_ParentId=@TrE_TrEIdWiNi1
      DELETE CDN.TraElemRelacje WHERE TeR_ChildTyp=@TrE_TypWiNi1 and TeR_ChildId=@TrE_TrEIdWiNi1
     END
     CLOSE Kasowane
     DEALLOCATE Kasowane
               END
          END
        -- Sprawdzenie zgodności przeliczników i ilości
        IF    (( @TrE_JMPrzelicznikL =  @TrE_JMPrzelicznikM AND @TrE_Ilosc <> @TrE_IloscJM)
           OR ( @TrE_JMPrzelicznikL <> @TrE_JMPrzelicznikM AND @TrE_Ilosc =  @TrE_IloscJM  AND round(@TrE_IloscJM*@TrE_JMPrzelicznikL/@TrE_JMPrzelicznikM,4) != @TrE_Ilosc))
           AND (@TrE_Ilosc<>0 AND @TrE_IloscJM<>0)
          BEGIN
            SET @Komunikat = '##OPT34591##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')+ '##'--@Komunikat = 'Zapis niemożliwy !  Dla towaru  ' + @TrE_TwrKod + ' przeliczniki miar niezgodne z ilościami ! '
            IF @Komunikat <> '' GOTO KOMUNIKAT
          END
        -- Przepisujemy z PA na FA czy wybor dostaw
        IF @TrE_TypDokumentu = 302
         update FA set FA.TrE_WyborDostaw = PA.TrE_WyborDostaw from cdn.TraElem FA left join cdn.TraElem PA on FA.TrE_PATrEID = PA.TrE_TrEID
   where FA.TrE_TrEId = @TrE_TrEId AND FA.TrE_PATrEID > 0
        -- Niezwykle istotne ze wzglednu na prawidlowy FK dla ProdElem po wykonaniu triggera
        SET @MyIdentity = @@IDENTITY
        -- Odczytanie z naglowka informacji potrzebnych do zbudowania subelementu i decyzji o sposobie aktualizowania ceny zakupu
        SELECT TOP 1
          @TrN_TrNId      = TrN_TrNId,
          @TrN_FaId       = case when TrN_TypDokumentu= 313 or  TrN_TypDokumentu= 314 then CDN.TraNagRelacjeFaId (TrN_TrNID,0,2 ) else CDN.TraNagRelacjeFaId (TrN_TrNID,0,0 ) end ,
          --@TrN_FaId       = TrN_FaId,
          @TrN_ZwrId      = TrN_ZwrId,
          @TrN_Rodzaj     = TrN_Rodzaj,
          @TrN_Bufor      = TrN_Bufor,
          @TrN_MagZrdId   = TrN_MagZrdId,
          @TrN_MagDocId   = TrN_MagDocId,
          @TrN_DataDok    = TrN_DataDok,
          @TrN_DataWys    = TrN_DataWys,
          @TrN_DataOpe    = TrN_DataOpe,
          @TrN_TrSTyp     = ISNULL(TrN_TrSTyp,3),
          @TrN_TypNB      = TrN_TypNB,
          @TrN_PodmiotTyp = TrN_PodmiotTyp,
          @TrN_PodId      = TrN_PodId,
          @TrN_Centrala   = TrN_Centrala,
          @TrN_Waluta     = TrN_Waluta,
          @TrN_KursNumer  = TrN_KursNumer,
          @TrN_KursL      = TrN_KursL,
          @TrN_KursM      = TrN_KursM
        FROM cdn.TraNag
          JOIN cdn.TraElem ON TrN_TrNId = TrE_TrNId AND TrE_TrEId = @TrE_TrEId
        -- ustalenie symbolu waluty, jeśli jest to waluta systemowa
        IF ( @TrN_Waluta = '' OR @TrN_Waluta = @WalutaSys ) AND @TrN_KursL=1 AND @TrN_KursM = 1
          SET @TrN_Waluta = @WalutaSys
        -- Sprawdzenie zgodności podmiotu między nagłówkiem i elementem (ZB)
        If IsNull(@TrN_PodmiotTyp, 0) <> IsNull(@TrE_PodmiotTyp, 0) Or IsNull(@TrN_PodId, 0) <> IsNull(@TrE_PodId, 0)
          Update CDN.TraElem Set TrE_PodmiotTyp = @TrN_PodmiotTyp, TrE_PodId = @TrN_PodId Where TrE_TrEId = @TrE_TrEId
        -- Ustalenie metody rozliczania magazynu dla dodawanego elementu
        IF @QUAN = 1 AND @TrE_DataOpe > ( SELECT ISNULL(MAX(TrN_DataOpe),0) FROM cdn.TraNag WHERE TrN_Rodzaj = 310005 )
          SET @Metoda = 4
        -- ustawiamy lppow dla wz jesli zmienia sie lppow na proformie
       IF (Update (TrE_LpPow) and @TrN_Rodzaj in (320000,320009))
        BEGIN
         UPDATE a SET a.TrE_Lppow = @TrE_Lppow
         FROM Cdn.TraElem a
         join deleted d on  d.TrE_Treid = @TrE_TrEId and a.TrE_lppow = d.TrE_lppow and a.TrE_TwrId = d.TrE_TwrId
            JOIN CDN.TraNagRelacje ON d.TrE_TrnId = TrR_FaId
            --JOIN Cdn.TraNag c ON d.TrE_TrnId = c.TrN_RelTrnId
            WHERE TrR_FaTyp = 306 AND a.TrE_TrnId = TrR_TrNId
         --WHERE c.TrN_TypDokumentu = 306 and a.TrE_TrnId = c.TrN_TrNId
        END
         /*   If (Update (TrE_Atr1_DeAId) Or Update (TrE_Atr1_Kod) Or Update (TrE_Atr1_Wartosc) Or Update (TrE_Atr2_DeAId) Or Update (TrE_Atr2_Kod) Or Update (TrE_Atr2_Wartosc)
         Or Update (TrE_Atr3_DeAId) Or Update (TrE_Atr3_Kod) Or Update (TrE_Atr3_Wartosc) Or Update (TrE_Atr4_DeAId) Or Update (TrE_Atr4_Kod) Or Update (TrE_Atr4_Wartosc)
         Or Update (TrE_Atr5_DeAId) Or Update (TrE_Atr5_Kod) Or Update (TrE_Atr5_Wartosc))
         BEGIN
           DELETE FROM Cdn.TraElemAtr WHERE  Tra_TrEId =@TrE_TrEId
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,1,TrE_Atr1_DeAId,TrE_Atr1_Kod,TrE_Atr1_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEId AND TrE_Atr1_DeAId>0 AND TrE_Atr1_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,2,TrE_Atr2_DeAId,TrE_Atr2_Kod,TrE_Atr2_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEId AND TrE_Atr2_DeAId>0 AND TrE_Atr2_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,3,TrE_Atr3_DeAId,TrE_Atr3_Kod,TrE_Atr3_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEId AND TrE_Atr3_DeAId>0 AND TrE_Atr3_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,4,TrE_Atr4_DeAId,TrE_Atr4_Kod,TrE_Atr4_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEId AND TrE_Atr4_DeAId>0 AND TrE_Atr4_DeAId is not NULL
           INSERT INTO Cdn.TraElemAtr SELECT Tre_TreId,5,TrE_Atr5_DeAId,TrE_Atr5_Kod,TrE_Atr5_Wartosc FROM Cdn.TraElem WHERE Tre_TreId=@TrE_TrEId AND TrE_Atr5_DeAId>0 AND TrE_Atr5_DeAId is not NULL
         END*/
    if @Tre_UstawAtrSQL = 0 and @Tre_UstawAtrSQLDokTyp = 1
    begin
    INSERT INTO [CDN].[TraElemAtr]
      ([TrA_TrEId]
      ,[TrA_Lp]
      ,[TrA_DeAId]
     ,[TrA_Kod]
     ,[TrA_Wartosc]
     ,[TrA_ESklep])
    select @TrE_TrEId, ROW_NUMBER() OVER( ORDER BY Twa_Lp ) AS LP,A.TwA_DeAID,A.DeA_Kod, A.TwA_Wartosctxt, 0 from
    (
     SELECT  TwA_LP,TwA_DeAID,DeA_Kod, TwA_Wartosctxt FROM CDN.TwrAtrybuty
       JOIN CDN.DefAtrybuty ON TwA_DeAID = DeA_DeAID
       WHERE TwA_CzyPrzenosic = 1 AND TwA_TwrID = @TrE_TwrId
         AND TwA_Zalezny = 0
     UNION
      SELECT TwA_LP,TwA_DeAID,DeA_Kod, TKA_Wartosctxt FROM CDN.TwrAtrybuty
       JOIN cdn.DefAtrybuty ON TwA_DeAID = DeA_DeAID
       JOIN cdn.TwrKntAtrybuty ON TKA_TwAID = TwA_TwAID
       WHERE TwA_CzyPrzenosic = 1 AND TwA_Zalezny = 1
        AND TwA_TwrID = @TrE_TwrId AND TKA_PodmiotTyp = @TrN_PodmiotTyp
        AND TKA_PodmiotID = @TrN_PodId
   )
   as A order by Twa_Lp
   update CDN.TraElem set  Tre_UstawAtrSQL = -1 where TrE_TrEID = @TrE_TrEId
    end
    if @Tre_UstawAtrSQL > 0  and @Tre_UstawAtrSQLDokTyp = 1
    begin
     INSERT INTO [CDN].[TraElemAtr]
       ([TrA_TrEId]
       ,[TrA_Lp]
       ,[TrA_DeAId]
       ,[TrA_Kod]
       ,[TrA_Wartosc]
       ,[TrA_ESklep])
     select @TrE_TrEId,TrA_Lp,TrA_DeAId,TrA_Kod,TrA_Wartosc,0 from CDN.TraElemAtr where TrA_TrEId = @Tre_UstawAtrSQL
     update CDN.TraElem set  Tre_UstawAtrSQL = -1 where TrE_TrEID = @TrE_TrEId
        end
  if @Tre_UstawAtrSQL > 0  and @Tre_UstawAtrSQLDokTyp > 1
    begin
     INSERT INTO [CDN].[TraElemAtr]
       ([TrA_TrEId]
       ,[TrA_Lp]
       ,[TrA_DeAId]
       ,[TrA_Kod]
       ,[TrA_Wartosc]
       ,[TrA_ESklep])
     select @TrE_TrEId,TrA_Lp,TrA_DeAId,TrA_Kod,TrA_Wartosc,0 from CDN.TraElemAtr where TrA_DokId = @Tre_UstawAtrSQL and TrA_DokTyp = @Tre_UstawAtrSQLDokTyp
     update CDN.TraElem set  Tre_UstawAtrSQL = -1 where TrE_TrEID = @TrE_TrEId
        end
        -- Kreowanie subelementów jest podejmowane tylko w uzasadnionych przypadkach
        -- Anulowane
        IF @TrE_Aktywny = 0
        BEGIN
          DELETE FROM CDN.TrasElemDost WHERE TsD_TrEId = @TrE_TrEID
          -- Kasujemy rezerwacje na subelementach dla RO/ZD i ich relacje
          exec [CDN].[UstawRezerwacje]  @TrE_TrEId, 1, @TrE_TypDokumentu
          DELETE CDN.TraSElem WHERE TRS_TrEIdWydania = @TrE_TrEId
          DELETE CDN.TraElemRelacje WHERE TeR_ParentTyp=@TrE_TypDokumentu and TeR_ParentId = @TrE_TrEId
          DELETE CDN.TraElemRelacje WHERE TeR_ChildTyp=@TrE_TypDokumentu and TeR_ChildId = @TrE_TrEId
    IF @TrN_Rodzaj IN (302006,302004)
           begin
      update WZ set WZ.TrE_LpPow =  FA.TrE_LpPow from cdn.traelem WZ
      left join cdn.tranagrelacje on WZ.TrE_TrNId =  TrR_TrNId and TrR_FaTyp = 305 and TrR_TrNTyp= 306
      left join cdn.TraElem PA on PA.TrE_TrNId = TrR_FaId
      left join cdn.TraElem FA on FA.TrE_PATrEID = PA.TrE_TrEID
      where FA.TrE_TrEId = @TrE_TrEId AND  WZ.TrE_Lppow = PA.TrE_LpPow and   FA.TrE_PATrEID > 0
      update PA set PA.TrE_LpPow =  FA.TrE_LpPow from cdn.TraElem PA left join cdn.TraElem FA on FA.TrE_PATrEID = PA.TrE_TrEID where FA.TrE_TrEId = @TrE_TrEId AND FA.TrE_PATrEID > 0
           end
    --PA z Pobraniem- >FA -> Korekta nie zwraca na magazyn
          IF @TrN_Rodzaj IN (302006) AND @TrN_Bufor = 0
           begin
      --update TraS set trs_treid = @TrE_TrEId from  cdn.TraSElem TraS join cdn.TraElem  on tre_treid = trs_treid where TrE_TrNId = @TrN_FaId and TrE_LpPow = @tre_lppow and TrE_TypDokumentu != 304 --usługa złozona RW nie przepinamy.
      update TraS set trs_treid = FA.TrE_TrEId from  cdn.TraSElem TraS
      left join cdn.TraElem PA on PA.TrE_TrEID = TraS.TrS_TrEId
      left join cdn.TraElem FA on FA.TrE_PATrEID = PA.TrE_TrEID
      where FA.TrE_TrEId = @TrE_TrEId  and PA.TrE_TypDokumentu != 304 --usługa złozona RW nie przepinamy.
      update TraS set tsd_treid = FA.TrE_TrEId from  cdn.TraSElemDost TraS
      left join cdn.TraElem PA on PA.TrE_TrEID = TraS.Tsd_TrEId
      left join cdn.TraElem FA on FA.TrE_PATrEID = PA.TrE_TrEID
      where FA.TrE_TrEId = @TrE_TrEId  and PA.TrE_TypDokumentu != 304 --usługa złozona RW nie przepinamy.
           end
          CONTINUE
        END
/*
        -- FZ z PZ, FZKI z PZKI akceptowane trwale lub w buforze
        IF @TrN_Rodzaj IN ( 301004, 301005 ) AND @TrN_Bufor IN ( 0, 1 )
        begin
        -- Sprawdzenie, czy należy aktualizować cenę zakupu na MM-OL
        -- Rodzaj marży: 0 = "od stu", 1 = "w stu"
        IF @TrN_Rodzaj = 301004
          AND @TrE_Ilosc > 0
          AND @TrN_Bufor IN ( 0 )
          BEGIN
        SELECT
          @Twr_Typ            = Twr_Typ,
          @Twr_KosztUslugiTyp = Twr_KosztUslugiTyp,
          @Twr_KosztUslugi    = Twr_KosztUslugi,
          @Twr_Stawka         = Twr_Stawka,
          @Twr_KursL          = Twr_KursL,
          @Twr_KursM          = Twr_KursM
        FROM cdn.Towary
        WHERE Twr_TwrId = @TrE_TwrId
        IF @TrN_Waluta = @WalutaSys
          BEGIN
            SET @Waluta    = @TrE_Waluta
            SET @KursNumer = @TrE_KursNumer
            SET @KursL     = @TrE_KursL
            SET @KursM     = @TrE_KursM
            SET @CenaW_New = @TrE_CenaW
          END
        -- parametry waluty z nagłówka
        ELSE
          BEGIN
            SET @Waluta    = @TrN_Waluta
            SET @KursNumer = @TrN_KursNumer
            SET @KursL     = @TrN_KursL
            SET @KursM     = @TrN_KursM
            SET @CenaW_New = @TrE_CenaWWD
          END
            -- parametry kursu waluty dla towaru lub usługi z typem kwotowym
            IF @Twr_Typ = 1 OR ( @Twr_Typ = 0 AND @Twr_KosztUslugiTyp = 1 )
              UPDATE cdn.Towary SET
                Twr_Waluta         = @Waluta,
                Twr_KursNumer      = @KursNumer,
                Twr_KursL          = @KursL,
                Twr_KursM          = @KursM
              WHERE Twr_TwrId = @TrE_TwrId
            -- koszt usługi ( usługa i typ kosztu kwotowy )
            IF @Twr_Typ = 0 AND @Twr_KosztUslugiTyp = 1
              BEGIN
                -- od netto
                IF @TrE_TypNB = 1
                  BEGIN
                    SET @Twr_KosztUslugiNew    = @TrE_CenaT
                    SET @Twr_KosztUslugiWalNew = @CenaW_New
                  END
                -- od brutto
                ELSE IF @TrE_TypNB = 2
                  BEGIN
                    SET @Twr_KosztUslugiNew    = @TrE_CenaT   - ROUND ( @TrE_CenaT   * @TrE_Stawka / (100 + @TrE_Stawka) , 2 )
                    SET @Twr_KosztUslugiWalNew =  @CenaW_New - ROUND (  @CenaW_New  * @TrE_Stawka / (100 + @TrE_Stawka) , 2 )
                  END
                UPDATE cdn.Towary SET
                  Twr_KosztUslugi    = @Twr_KosztUslugiNew,
                  Twr_KosztUslugiWal = @Twr_KosztUslugiWalNew
                WHERE Twr_TwrId = @TrE_TwrId
              END
            -- Kursor po cenach dla towaru lub usługi z kosztem kwotowym:
            -- aktualizacja ceny zakupu (TwC_TwCNumer = 1)
            -- aktualizacja marży dla cen sprzedaży z aktualizacją ustawiną na "Nie" ( TwC_TwCNumer <> 1 AND TwC_Aktualizacja = 0 )
            IF @Twr_Typ = 1 OR ( @Twr_Typ = 0 AND @Twr_KosztUslugiTyp = 1 )
              BEGIN
                DECLARE TwrCeny CURSOR LOCAL FAST_FORWARD FOR
                SELECT TwC_TwCNumer, TwC_TwCId, TwC_Waluta, TwC_Wartosc, TwC_Typ
                  FROM cdn.TwrCeny
                  WHERE TwC_TwrId = @TrE_TwrId AND TwC_TwCNumer = 1
                UNION ALL
                SELECT TwC_TwCNumer, TwC_TwCId, TwC_Waluta, TwC_Wartosc, TwC_Typ
                  FROM cdn.TwrCeny
                  WHERE TwC_TwrId = @TrE_TwrId AND TwC_TwCNumer <> 1 AND TwC_Aktualizacja = 0
                OPEN TwrCeny
                  WHILE 1=1
                    BEGIN
                      FETCH NEXT FROM TwrCeny INTO @TwC_TwCNumer, @TwC_TwCId, @TwC_Waluta, @TwC_Wartosc, @TwC_Typ
                      IF @@FETCH_STATUS <> 0 BREAK
                      -- aktualizacja ceny zakupu
                      IF @TwC_TwCNumer = 1
                        BEGIN
                          -- od netto
                          IF @TrE_TypNB = 1
                            IF @TwC_Typ = 1
                              SET @TwC_Wartosc = @CenaW_New  * ( @TrE_JMPrzelicznikM / @TrE_JMPrzelicznikL )
                            ELSE
                              SET @TwC_Wartosc = ( @CenaW_New + ROUND( @CenaW_New * @TrE_Stawka / 100, 2 ) ) * (  @TrE_JMPrzelicznikM / @TrE_JMPrzelicznikL )
                          -- od brutto
                          ELSE IF @TrE_TypNB = 2
                            IF @TwC_Typ = 1
                              SET @TwC_Wartosc = ( @CenaW_New  - ROUND( @CenaW_New * @TrE_Stawka / ( 100+@TrE_Stawka), 2 ) ) *  ( @TrE_JMPrzelicznikM / @TrE_JMPrzelicznikL )
                            ELSE
                              SET @TwC_Wartosc =  @CenaW_New   *  ( @TrE_JMPrzelicznikM / @TrE_JMPrzelicznikL )
                          UPDATE cdn.TwrCeny SET
                            TwC_Wartosc = @TwC_Wartosc,
                            TwC_Waluta  = @Waluta
                          WHERE TwC_TwCId = @TwC_TwCId
                          SET @CenaZakupuNew = @TwC_Wartosc
                          SET @CenaZakupuNewWal = @CenaZakupuNew
                          SET @CenaZakupuNewPLN = @CenaZakupuNew * @KursL/@KursM
                        END  -- @TwC_TWCNumer = 1
                      -- aktualizacja marż dla cen sprzedaży
                      -- tylko wtedy, gdy waluta zakupu i sprzedaży są równe lub gdy waluta sprzedazy jest systemowa
                      ELSE IF @TwC_TwCNumer <> 1 AND  ( @TwC_Waluta = @Waluta OR @TwC_Waluta = @WalutaSys )
                        BEGIN
                          -- cena sprzedaży brutto - obliczamy jej reprezentację netto
                          IF @TwC_Typ = 2
                            SET @TwC_Wartosc  =  @TwC_Wartosc - ROUND( @TwC_Wartosc * @Twr_Stawka / ( 100 + @Twr_Stawka), 2 )
                          -- marża "od stu" i "w stu"
                          IF @CenaZakupuNew <> 0
                            BEGIN
                             -- jeśli waluta zakupu i sprzedaży są równe, to bierzemy cenę zakupu w walucie dokumentu
                             -- w przeciwnym przypadku, gdy cena sprzedaży jest w walucie systemowej, to bierzemy cenę zakupu w walucie systemowej
                             IF @TwC_Waluta = @WalutaSys AND @Waluta <> @WalutaSys
                               SET @CenaZakupuNew = @CenaZakupuNewPLN
                             ELSE
                               SET @CenaZakupuNew = @CenaZakupuNewWal
                              SET @TwC_Marza = ( ( @TwC_Wartosc / @CenaZakupuNew ) - 1 ) * 100
                              IF ( @TwC_Marza = -100 )  OR ( @CenaZakupuNew = @TwC_Wartosc )
                                SET @TwC_MarzaWStu = 100
                              ELSE IF @TwC_Wartosc = 0
                                SET @TwC_MarzaWStu = -100
                              ELSE
                                SET @TwC_MarzaWStu = 100 * @TwC_Marza / ( 100 + @TwC_Marza )
                              IF @TwC_Marza     > 99999.99 SET @TwC_Marza     = 99999.99
                              IF @TwC_MarzaWStu > 99999.99 SET @TwC_MarzaWStu = 99999.99
                              IF @TwC_Marza     < - 99999.99 SET @TwC_Marza     = -99999.99
                              IF @TwC_MarzaWStu < - 99999.99 SET @TwC_MarzaWStu = -99999.99
                            END
                            IF @TwC_Marza IS NOT NULL AND @TwC_MarzaWStu IS NOT NULL
                            UPDATE cdn.TwrCeny SET
                              TwC_Marza = @TwC_Marza,
                              TwC_MarzaWStu = @TwC_MarzaWStu
                            WHERE TwC_TwCId = @TwC_TwCId
                        END
                    END -- kursor TwrCeny
                CLOSE TwrCeny
                DEALLOCATE TwrCeny
              END -- Towar lub usługa z kosztem kwotowym
          END -- aktualizacji ostatniej ceny zakupu
          CONTINUE
        end
*/
    --dla 149306 mimo ze FAWZ to trzeba ustawić rezerwację
    IF  UPDATE( TrE_Ilosc ) and @TrN_Rodzaj = 302004 and exists(
             SELECT Twr_Typ FROM cdn.Towary WHERE Twr_TwrId = @TrE_TwrId and Twr_Typ = 0)
               EXEC [CDN].[UstawRezerwacje] @TrE_TrEId,0,@TrE_TypDokumentu
        -- FA z WZ, PA z WZ, FAKI z WZKI, PAKI z WZ, FZKI z PZ, AI, AI z PW/RW, RO z PA, RO z FA, RO z WZ akceptowane trwale, PF z FA, PF z RO
        IF @TrN_Rodzaj IN ( 302004, 305004, 302005, 305005, 301005, 311000, 311001, 308008, 308009, 308010, 320008, 320009, 320000 ) AND @TrN_Bufor IN ( 0 )  and @TrE_TypDokumentu != 304
          CONTINUE
        -- ZD konwertowane do PZ/FZ
        IF @TrN_Rodzaj IN ( /*309000,*/ 309008, 309009 ) --AND @TrN_FaId IS NOT NULL
          CONTINUE
        -- FZKW, PZKW w buforze
        IF @TrN_Rodzaj IN  ( 301002, 307002, 310002, 301006, 307006,303002,307003, 307011 ) AND @TrN_Bufor IN ( 1 )
          CONTINUE
        -- RO, ZD z pzeznaczeniem do centrali XL
        IF @TrN_Rodzaj IN  ( 308000, 309000 ) AND @TrN_Centrala IN ( 1 )
          CONTINUE
        -- FA z PA z buforze
        IF @TrN_Rodzaj IN (302006) AND @TrN_Bufor = 1
          CONTINUE
        -- PWP - pierwszy przebieg (TrE_Aktywny = 1 - nie liczymy zasobów, najpierw RWS musi wyliczyć koszt)
        IF @TrE_TypDokumentu IN (317) AND @TrE_Aktywny = 1
          CONTINUE
        -- PWP - drugi przebieg (TrE_Aktywny = 2 - liczymy zsoby, PdE_Wartosc są już policzone)
        IF @TrE_TypDokumentu IN (317) AND @TrE_Aktywny = 2 AND ISNULL(@Tre_WyborDostaw,0)  = 0
          BEGIN
            UPDATE cdn.TraElem SET TrE_Aktywny = 1 WHERE TrE_TrEId = @TrE_TrEId
            SET @TrE_Aktywny = 1
          END
        IF @TrE_TypDokumentu IN (317) AND @TrE_Aktywny = 3 AND ISNULL(@Tre_WyborDostaw,0)  = 0
          BEGIN
            UPDATE cdn.TraElem SET TrE_Aktywny = 1 WHERE TrE_TrEId = @TrE_TrEId
            SET @TrE_Aktywny = 1
          END
        -- przeksztalcenia ZD do PZ, RO do FA/PA/WZ, PA do FA, PF do FS, PF do RO, ZD do FZ
        -- skasowanie subelementów zamowieniowych/rezerwacyjnych z dokumentu pierwotnego
 /*       IF  @TrN_Rodzaj IN ( 307010, 302008, 305008, 306008, 306010, 302006, 302009, 308011, 301011 )
          BEGIN
            SET @TrN_FaId_Old  = ( SELECT TOP 1 TrN_TrNId FROM cdn.TraNag  WHERE TrN_TrNId = @TrE_TrNId    )
            -- tablica nagłówków do przeglądnięcia i skasowania subelemntów
            DECLARE @TrN_TrNId_Prw TABLE (TrN_TrNId INT)
            INSERT INTO @TrN_TrNId_Prw SELECT TrN_TrNId FROM cdn.TraNag
            JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId
            WHERE TrR_FaId  = @TrN_FaId_Old
            DECLARE E CURSOR LOCAL FAST_FORWARD FOR
              SELECT TrE_TrEId
              FROM cdn.TraElem
              WHERE TrE_TrNId IN ( SELECT TrN_TrNId FROM @TrN_TrNId_Prw ) --  AND TrE_TwrId = @TrE_TwrId
                OPEN E
                  WHILE 1=1
                    BEGIN
                      FETCH NEXT FROM E INTO @TrE_TrEId_Old
                      IF @@FETCH_STATUS <> 0 BREAK
                      -- skasowanie subelementów z dokumentu pierwotnego
                      DELETE FROM cdn.TraSElem WHERE TrS_TrEId = @TrE_TrEId_Old
                    END
                CLOSE E
            DEALLOCATE E
          END*/
       IF  @TrN_Rodzaj IN (   306010, 302006, 302009, 308011 )
          BEGIN
              DELETE FROM cdn.TraSElem WHERE TrS_TrEId in (SELECT TrE_TrEId
              FROM cdn.TraElem
              WHERE TrE_TrNId IN ( SELECT TrN_TrNId FROM cdn.TraNag
              JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId
              WHERE TrR_FaId  = @TrE_TrNId and trn_typdokumentu = 320 and trn_trstyp = 3) )
/*
            SET @TrN_FaId_Old  = ( SELECT TOP 1 TrN_TrNId FROM cdn.TraNag  WHERE TrN_TrNId = @TrE_TrNId    )
            -- tablica nagłówków do przeglądnięcia i skasowania subelemntów
            DECLARE @TrN_TrNId_Prw TABLE (TrN_TrNId INT)
            INSERT INTO @TrN_TrNId_Prw SELECT TrN_TrNId FROM cdn.TraNag
            JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId
            WHERE TrR_FaId  = @TrN_FaId_Old
            DECLARE E CURSOR LOCAL FAST_FORWARD FOR
              SELECT TrE_TrEId
              FROM cdn.TraElem
              WHERE TrE_TrNId IN ( SELECT TrN_TrNId FROM @TrN_TrNId_Prw ) --  AND TrE_TwrId = @TrE_TwrId
                OPEN E
                  WHILE 1=1
                    BEGIN
                      FETCH NEXT FROM E INTO @TrE_TrEId_Old
                      IF @@FETCH_STATUS <> 0 BREAK
                      -- skasowanie subelementów z dokumentu pierwotnego
                      DELETE FROM cdn.TraSElem WHERE TrS_TrEId = @TrE_TrEId_Old
                    END
                CLOSE E
            DEALLOCATE E*/
          END
         /*IF  @TrN_Rodzaj IN ( 307010, 302008, 305008, 306008,  301011 )
          BEGIN
            SET @TrN_FaId_Old  = ( SELECT TOP 1 TrN_TrNId FROM cdn.TraNag  WHERE TrN_TrNId = @TrE_TrNId    )
            -- tablica nagłówków do przeglądnięcia i skasowania subelemntów
            DECLARE @TrN_TrNId_Prw1 TABLE (TrN_TrNId INT)
            INSERT INTO @TrN_TrNId_Prw1 SELECT TrN_TrNId FROM cdn.TraNag
            JOIN CDN.TraNagRelacje ON TrN_TrNId = TrR_TrNId
            WHERE TrR_FaId  = @TrN_FaId_Old
            DECLARE E CURSOR LOCAL FAST_FORWARD FOR
              SELECT TrE_TrEId
              FROM cdn.TraElem
              WHERE TrE_TrNId IN ( SELECT TrN_TrNId FROM @TrN_TrNId_Prw1 ) --  AND TrE_TwrId = @TrE_TwrId
                OPEN E
                  WHILE 1=1
                    BEGIN
                      FETCH NEXT FROM E INTO @TrE_TrEId_Old
                      IF @@FETCH_STATUS <> 0 BREAK
                      -- skasowanie subelementów z dokumentu pierwotnego
                      --DELETE FROM cdn.TraSElem WHERE TrS_TrEId = @TrE_TrEId_Old
                    END
                CLOSE E
            DEALLOCATE E
          END*/
        -- przed trwalym zapisem skasowanie subelemntów z dokumentu konwertowanego
        -- nie można przepinać zasobów, ponieważ na dokumencie pierwotnym mogą być usługi, które zaburzaja LP
        -- WZ z FA, WZ z PA, WZKI z FA, WZKI z PA, PZ z FZ, PZKI z FZKI, WZ z RO
        --
       IF  @TrN_Rodzaj IN ( /*306004, 306006,*/ 306005, 306007, /*307004,*/ 307005 /*, 306008*/ )
          EXEC CDN.KasujTraSElemZDokZrodlowych @TrN_TrNId, @TrN_Rodzaj, @TrN_FaId
        -- zainicjowanie typu
        SET @TrS_Typ        = -1
        -- dokumenty w buforze
        IF @TrN_Bufor = 1
          BEGIN
            -- FZ, PW, PZ z ZD, BO, PWP, ZD, PW z AI, FZ z ZD
            IF @TrN_Rodzaj IN  ( 301000, 303000, 307000, 307010, 310000, 317000, 309000, 303010, 312010, 301011, 301050, 313000, 313004 )
              SET @TrS_Typ = 4
            -- FA, FA z RO, PA, PA z RO
            IF @TrN_Rodzaj IN ( 302000, 302008, 305000, 305008, 318000, 302009, 320000 )
              SET @TrS_Typ = @TrN_TrSTyp
            IF @TrN_Rodzaj IN ( 302004,305004 ) and @TrE_TypDokumentu = 304
              SET @TrS_Typ = @TrN_TrSTyp
            -- FA z WZ dla elementów dodanych
            IF @TrN_Rodzaj IN ( 302004 ) AND @TrE_LpPow < 0
              SET @TrS_Typ = @TrN_TrSTyp
            -- RO, RO z PF
            IF @TrN_Rodzaj IN ( 308000, 308011 )
               SET @TrS_Typ = 3
            -- RW, WZ, WZ z FA, WZ z PA, MM, RW z AI
            IF @TrN_Rodzaj IN ( 304000, 304006, 304004,304008, 306000, 306004, 306006, 312000,312008, 304010, 306008, 306010, 312100, 314000, 314004, 314006 )
              SET @TrS_Typ = 2
            -- FAKI, FAKI z WZKI, PAKI, PAKI z WZKI, RWKI, WZKI  w buforze
            IF @TrN_Rodzaj IN  ( 302001, 302005, 305001, 305005, 304001, 306001, 314001, 318001 ) AND @TrN_Bufor IN ( 1 )
              SET @TrS_Typ = 4
            -- FAKI, FAKI z WZKI, PAKI, PAKI z WZKI, RWKI, WZKI  w buforze dla ilości dodatnich
            IF @TrN_Rodzaj IN  ( 302001, 302005, 305001, 305005, 318001 ) AND @TrN_Bufor IN ( 1 ) AND @TrE_Ilosc > 0
              BEGIN
                DECLARE @TrN_TrSTyp_Pierw INT
                -- dla nie RWSK z dokumentu pierwotnego
                IF @TrN_Rodzaj <> 318001
                  SELECT TOP 1
                    @TrN_TrSTyp_Pierw = ISNULL(MAX(TrN_TrSTyp),0)
                  FROM cdn.TraNag
                    JOIN cdn.TraElem ON TrE_TrNId = TrN_TrNId
                  WHERE TrE_TrEId = @TrE_ZwrId
                -- dla RWSK ze skojarzonego dokumentu PWPK
                ELSE
                  SELECT TOP 1
                    @TrN_TrSTyp_Pierw = ISNULL(MAX(PWP_N.TrN_TrSTyp),0)
                  FROM cdn.TraNag RWS_N
                    JOIN cdn.TraElem RWS_E ON RWS_E.TrE_TrNId = RWS_N.TrN_TrNId
                    JOIN cdn.TraNag PWP_N ON PWP_N.TrN_TrNId = RWS_N.TrN_FaId
                  WHERE RWS_E.TrE_TrEId = @TrE_TrEId
                -- jeśli na pierwotnym nie jest ustawione "pobranie", to z pierwotnego
                IF @TrN_TrSTyp_Pierw = 2
                  SET @TrS_Typ = @TrN_TrSTyp_Pierw
                ELSE
                  SET @TrS_Typ = 3
              END
            -- FAKI, FAKI z WZKI, PAKI, PAKI z WZKI w buforze dla ilości dodatnich
            IF @TrN_Rodzaj IN  ( 306001, 314001 ) AND @TrN_Bufor IN ( 1 ) AND @TrE_Ilosc > 0
              SET @TrS_Typ = 2
            -- FZKI, FZKI z PZKI, PWKI, PZKI, BOMKI w buforze
            IF (@TrN_Rodzaj IN  ( 301001, 301005, 303001, 307001, 310001, 313001, 317001 ) AND @TrN_Bufor IN ( 1 )) or (@TrN_Rodzaj = 301051  AND @TrN_Bufor = 1  and not exists (select * from cdn.TraNag where TrN_FaId = @TrN_TrNId and TrN_Rodzaj = 307005))
              SET @TrS_Typ = 3
            -- FZKI, FZKI z PZKI, PWKI, PZKI, BOMKI w buforze dla ilości dodatnich
            IF (@TrN_Rodzaj IN  ( 301001, 301005, 303001, 307001, 310001, 313001, 317001) AND @TrN_Bufor IN ( 1 ) AND @TrE_Ilosc > 0) or (@TrN_Rodzaj = 301051  AND @TrN_Bufor = 1  AND @TrE_Ilosc > 0 and not exists (select * from cdn.TraNag where TrN_FaId = @TrN_TrNId and TrN_Rodzaj = 307005))
              SET @TrS_Typ = 4
          END
        -- dokumenty zaakceptowane trwale
        ELSE IF @TrN_Bufor = 0
          BEGIN
            -- FZ, FZKI, FZKI z PZKI, ZD, FZ z ZD
            IF @TrN_Rodzaj IN ( 301000, 301001, 301005, 309000, 301011, 301050)  or (@TrN_Rodzaj = 301051   and not exists (select * from cdn.TraNag where TrN_FaId = @TrN_TrNId and TrN_Rodzaj = 307005))
              SET @TrS_Typ = 4
            -- PW, PWKI, PZ, PZ z FZ, PZKI, PZKI z FZKI, PZKW, PZKW z FZKW, PZ z ZD, BO, PWP, PW z AI, BOMKI, BOMKW
            IF @TrN_Rodzaj IN ( 303000, 303001, 303002, 307000, 307004, 307001, 307005, 307002, 307003, 307011, 307006, 307010, 310000, 317000, 303010, 310001, 310002, 312010, 313000, 313001, 313002, 313004, 317001 )
              SET @TrS_Typ = 1
            -- FAKI, PAKI - subelement o typie z dokumentu pierwotnego
            IF @TrN_Rodzaj IN ( 302001, 305001 )
              SET @TrS_Typ = ISNULL( ( SELECT MAX(TrS_Typ) FROM cdn.TraElem JOIN cdn.TraSElem ON TrS_TrEId = TrE_TrEId WHERE TrE_TrEId = @TrE_ZwrId ), 0 )
            -- FA, FA z WZ, PA, FA z RO, PA z RO, PF, PF z FA, PF z RO, FA z PF
            IF @TrN_Rodzaj IN ( 302000, 302006, 305000, 302008, 305008, 320000, 320008, 320009, 302009 )
              SET @TrS_Typ = @TrN_TrSTyp
   IF @TrN_Rodzaj IN ( 302004,305004 ) and @TrE_TypDokumentu = 304
              SET @TrS_Typ = @TrN_TrSTyp
            -- FA z WZ dla elementów dodanych
            IF @TrN_Rodzaj IN ( 302004 ) AND @TrE_LpPow < 0
              SET @TrS_Typ = @TrN_TrSTyp
            -- RO, FA z RO, PA z RO
            IF @TrN_Rodzaj IN ( 308000, 308011 )
               SET @TrS_Typ = 3
            -- RW, RWKI, WZ, WZKI, WZ z FA, WZ z PA, WZKI, WZKI z FAKI, WZKI z PAKI, MM, RWS, RW z AI
            IF @TrN_Rodzaj IN ( 304000, 304006, 304004,304008, 304001, 306000, 306004, 306006, 306001, 306005, 306007, 312000,312008, 318000, 304010, 306008, 306010, 312100, 314000, 314001, 314004, 314006, 318001 )
              SET @TrS_Typ = 2
          END
        -- Jesli nie ustawiono prawidlowego typu - nie kreujemy subelementow
        IF @TrS_Typ NOT IN ( 1, 2, 3, 4 )
          CONTINUE
        -- Update wartości i cen elementu dla PWP - ( musi być przed ustawieniem subelementu - jest już RWS )
        IF @TrE_TypDokumentu = 317
          BEGIN
           SET @TrE_WartoscZakupu = ( SELECT ISNULL(SUM(PdE_WartoscZakupu),0) FROM cdn.ProdElem WHERE PdE_TrEId = @TrE_TrEId )
            UPDATE cdn.TraElem SET
              TrE_WartoscNetto     = @TrE_WartoscZakupu,
              TrE_WartoscBrutto    = ROUND(@TrE_WartoscZakupu * ( ( 100 + TrE_Stawka ) / 100 ), 2 ),
              TrE_WartoscNettoWal  = @TrE_WartoscZakupu,
              TrE_WartoscBruttoWal = ROUND(@TrE_WartoscZakupu * ( ( 100 + TrE_Stawka ) / 100 ), 2 ),
              TrE_Rabat            = 0,
              TrE_CenaT            = round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END,@ZaokraglajDo),
              TrE_CenaW            = round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END,@ZaokraglajDo) ,
              TrE_Cena0            = round(CASE TrE_Ilosc   WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_Ilosc   END,@ZaokraglajDo) ,
              TrE_CenaWWD          = round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END,@ZaokraglajDo),
              TrE_Cena0WD          = round(CASE TrE_Ilosc   WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_Ilosc   END,@ZaokraglajDo),
              TrE_Waluta           = @WalutaSys,
              TrE_KursNumer        = 0,
              TrE_KursL            = 1,
              TrE_KursM            = 1
            WHERE TrE_TrEId = @TrE_TrEId
            -- Wczytanie poprawionych wartości
            SELECT
              @TrE_WartoscNetto     = @TrE_WartoscZakupu,
              @TrE_CenaT            = round(CASE @TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / @TrE_IloscJM END,@ZaokraglajDo),
              @TrE_CenaW            = round(CASE @TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / @TrE_IloscJM END,@ZaokraglajDo),
              @TrE_CenaWWD          = round(CASE @TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / @TrE_IloscJM END,@ZaokraglajDo),
              @TrE_Waluta           = @WalutaSys,
              @TrE_KursNumer        = 0,
              @TrE_KursL            = 1,
              @TrE_KursM            = 1
          END
        -- wartosci pozostalych pol
        SET @TrS_TrSId       = ( SELECT ISNULL(MAX(TrS_TrSId),0) FROM cdn.TraSElem ) + 1
        SET @TrS_TrEId       = @TrE_TrEId
        SET @TrS_TrSIdDost   = NULL
        SET @TrS_ZwrId       = NULL
        SET @TrS_TwrId       = @TrE_TwrId
        SET @TrS_MagId       = CASE WHEN @TrN_Rodzaj <> 312010 THEN CASE WHEN @TrE_MagId is null THEN @TrN_MagZrdId ELSE @TrE_MagId END ELSE @TrN_MagDocId END
        SET @TrS_Rodzaj      = @TrN_Rodzaj
        SET @TrS_Metoda      = @Metoda
        SET @TrS_DataOpe     = @TrE_DataOpe
        SET @TrS_Ilosc       = @TrE_Ilosc
        SET @TrS_Wartosc     = 0
        SET @TrS_Cena        = @TrE_CenaT
        SET @TrS_Termin      = NULL
        -- dostawy
        IF @TrS_Typ = 1
          BEGIN
            SET @TrS_Wartosc = @TrE_WartoscNetto
            SET @TrS_Cena    = round(case when @TrE_Ilosc <> 0 THEN @TrE_WartoscNetto / @TrE_Ilosc ELSE @TrS_Wartosc END,@ZaokraglajDo)
          END
        -- Zwykłe dostawy PZ, PZ z FZ, PW, BO, PZ z ZD, PWP, PW z AI, MM-OL
        IF @TrS_Rodzaj IN ( 307000, 307004, 303000, 310000, 307010, 317000, 303010, 312010, 313000, 313004  )
          BEGIN
            -- TrS_TrSIdDost i TrS_ZwrId
            SET @TrS_TrSIdDost  = @TrS_TrSId
            SET @TrS_ZwrId      = NULL
          END
        -- Korekty ilościowe dostaw PZKI, PZKI z FZKI, PWKI, PZKW, BOMKI, BOMKW
        IF @TrS_Rodzaj IN ( 307001, 307005, 303001, 303002, 307002, 310001, 310002, 307003, 307011, 307006, 313001, 313002, 317001 )
          BEGIN
            SELECT
              @TrS_TrSIdDost  = TrS_TrSIdDost,
              @TrS_Cena       = TrS_Cena,
              @TrS_ZwrId      = TrS_TrSId
            FROM cdn.TraSElem
            WHERE TrS_TrSId = ( -- TrS_TrSId pierwotnej dostawy
                                SELECT TOP 1 A.TrS_TrSId
                                FROM cdn.TraSElem A
                                  JOIN cdn.TraElem B ON B.TrE_TrEId = A.TrS_TrEId
                                WHERE B.TrE_TrEId = @TrE_ZwrId
                               )
          END
        -- Dostawa i QUAN - zerowa cena i wartosc subelementu
        IF @TrS_Typ = 1 AND @TrS_Metoda = 4
          BEGIN
            SET @TrS_Wartosc = 0
            SET @TrS_Cena    = 0
          END
        -- daty dla rezerwacji i zamowien
        -- Rezerwacja - bufor
        IF @TrN_Rodzaj IN ( 308000, 308011 ) -- AND @TrN_Bufor = 1
          BEGIN
            SET @TrS_Termin  = @TrN_DataWys
          END
/*
        -- Rezerwacja - zapis trwaly (rezerwacja bezterminowa)
        IF @TrN_Rodzaj IN ( 308000 ) AND @TrN_Bufor = 0
          SET @TrS_DataOpe = NULL --@TrE_DataDok
*/
        -- Zamówienie - bufor i zapis trwaly
        IF @TrN_Rodzaj IN ( 309000 )
          BEGIN
            SELECT @DataZamowienia = ISNULL(MAX(Fir_Wartosc),2) FROM cdn.Firma WHERE Fir_Numer = 2075
            IF @DataZamowienia = 2
              SET @TrS_DataOpe = @TrN_DataWys
          END
        -- odwrotne ilosci dla korekt w buforze
        -- FAKI, FAKI z WZKI, PAKI, PAKI z WZKI, FZKI, FZKI z PZKI, PWKI, RWKI, WZKI, PZKI, BOMKI  w buforze
        IF (@TrN_Rodzaj IN  ( 302001, 302005, 305001, 305005, 301001, 301005, 303001, 304001, 306001, 307001, 310001, 313001, 314001, 318001, 317001) AND @TrN_Bufor IN ( 1 ) AND @TrS_Typ IN ( 3, 4 ) AND @TrS_Ilosc < 0 )
         or (@TrN_Rodzaj = 301051 AND @TrN_Bufor IN ( 1 ) AND @TrS_Typ IN ( 3, 4 ) AND @TrS_Ilosc < 0 and not exists (select * from cdn.TraNag where TrN_FaId = @TrN_TrNId and TrN_Rodzaj = 307005) )
          BEGIN
            SET @TrS_Ilosc = - @TrE_Ilosc
/*            IF @TrS_Typ IN ( 3, 4 ) AND @TrS_Ilosc < 0
              SELECT
                @TrS_Typ  = CASE @TrS_Typ WHEN 4 THEN 3 ELSE 4 END,
                @TrS_Ilosc = -@TrS_Ilosc
*/
          END
        -- insert subelemntu i procedura aktualizacji wartości zakupu (subelement dodawany tylko dla towaru)
        -- odczytanie typu karty (towar/usługa) oraz typu kosztu usługi i stawki VAT dla późniejszej aktualizacji ceny zakupu
        SELECT
          @Twr_Typ            = Twr_Typ,
          @Twr_KosztUslugiTyp = Twr_KosztUslugiTyp,
          @Twr_KosztUslugi    = Twr_KosztUslugi,
          @Twr_Stawka         = Twr_Stawka,
          @Twr_KursL          = Twr_KursL,
          @Twr_KursM          = Twr_KursM
        FROM cdn.Towary
        WHERE Twr_TwrId = @TrE_TwrId
        -- Kontrola ilosci przed dodaniem subelemntu
        IF @Twr_Typ = 1 AND (( @TrS_Typ = 1 AND @TrS_Ilosc < 0 ) OR ( @TrS_Typ = 2 AND @TrS_Ilosc > 0 ))  AND @TrE_IFA24Mag = 0
          BEGIN
            SELECT @ZawszeBraki = ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1536
   if (SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1970) = 1 or  ((SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1776) = 1 and @TrE_LpPow > 0)
   select @ZezwalajMimoRez = 1
    else
   select @ZezwalajMimoRez = 0
   --SELECT @ZezwalajMimoRez = ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1970
       IF ((@TrS_Rodzaj IN (305001,302001,306001,302000,302009, 305000, 306000,304000,302008, 305008, 306008,304008) AND @TrS_Typ = 2)
   and exists (select * from deleted join inserted on deleted.TrE_TrEID = inserted.TrE_TrEID and inserted.TrE_TrEID = @TrE_TrEId and deleted.tre_ilosc >= inserted.tre_ilosc and deleted.TrE_DataOpe = inserted.TrE_DataOpe))
    or
   ((@TrS_Rodzaj IN ( 306004,306006) AND @TrS_Typ = 2 and @TrE_LpPow > 0)
   and exists (select TrN_TrSTyp from cdn.traelem join cdn.tranagrelacje on trr_faid= tre_trnid and trr_trnid = @TrE_TrNID  join cdn.tranag on tre_trnid = trn_trnid  where TrN_TrSTyp =2))
     SET @Komunikat = CDN.TwrIlosciErr ( 1, @TrS_Typ, @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, @TrS_Ilosc, 3)
   ELSE
    IF ((@TrS_Rodzaj IN (302008, 305008, 306008,304008,312008) AND @TrS_Typ = 2)
       OR  (@TrS_Rodzaj =306010 AND @TrS_Typ = 2 AND exists(select trr_trrid from cdn.tranagrelacje join cdn.tranag on trr_faid = trn_trnid where  trr_trnid = @trn_trnid and Trr_fatyp = 308 and trn_bufor = 0 and TrN_ZwroconoCalaIlosc < 4))
       OR  (@TrS_Rodzaj =302009 AND @TrE_LpPow > 0 AND @TrS_Typ = 2 and exists(select trr_trrid from cdn.tranagrelacje join cdn.tranag on trr_faid = trn_trnid where  trr_trnid = @trn_trnid and Trr_fatyp = 308 and trn_bufor = 0 and TrN_ZwroconoCalaIlosc < 4))
       OR  (@TrS_Rodzaj =306004 AND @TrS_Typ = 2 AND exists(select trr_trrid from cdn.tranagrelacje join cdn.tranag on trr_faid = trn_trnid where  trr_trnid = @trn_trnid and Trr_fatyp = 308 and trn_bufor = 0 and TrN_ZwroconoCalaIlosc < 4)))
      and not exists (select * from deleted join inserted on deleted.TrE_TrEID = inserted.TrE_TrEID and inserted.TrE_TrEID = @TrE_TrEId and deleted.tre_ilosc < inserted.tre_ilosc)
     IF @ZezwalajMimoRez = 1 and(@TrS_rodzaj in (306008,306010,306004,304008,312008) or (@TrS_rodzaj in (302009) AND @TrS_Typ = 2)  or (@TrS_rodzaj in (302008) AND @TrS_Typ = 2) or (@TrS_rodzaj in (305008) AND @TrS_Typ = 2))
      SET @Komunikat = CDN.TwrIlosciErr ( 1, @TrS_Typ, @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, @TrS_Ilosc, 2 )
     ELSE
      SET @Komunikat = CDN.TwrIlosciErr ( 1, @TrS_Typ, @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, @TrS_Ilosc, 1 )
    else
     SET @Komunikat = CDN.TwrIlosciErr ( 1, @TrS_Typ, @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, @TrS_Ilosc, 0)
            IF @Komunikat <> '' GOTO KOMUNIKAT
          END
        -- Marze symulowane dla FA, PA, FA z PA, RWS (symulacja poprzez ustawienie wartosci na subelemencie rezerwacyjnym)
        IF @Twr_Typ = 1 AND @TrS_Typ IN ( 3, 4 )
          BEGIN
            SET @Marza_Sym_Ostatnia = ( SELECT TOP 1 ISNULL(Fir_Wartosc,0) FROM cdn.Firma WHERE Fir_Numer = 1481 )
            SET @Marza_Sym_Srednia  = ( SELECT TOP 1 ISNULL(Fir_Wartosc,0) FROM cdn.Firma WHERE Fir_Numer = 1482 )
            -- Marze symulowane tylko dla elementów z subelementami rezerwacyjnymi - poprawa wartosći na subelementach rezerwacyjnych
            IF @Marza_Sym_Ostatnia = 1 OR @Marza_Sym_Srednia = 1
              BEGIN
                 -- w każdym przypadku symulwoana wg ostatniej ceny zakupu
                 SET @TrS_Wartosc = @TrE_Ilosc * ( SELECT ROUND(ISNULL(TwC_Wartosc,0)*(@Twr_KursL/@Twr_KursM),@ZaokraglajDo) FROM cdn.TwrCeny WHERE TwC_TwrId = @TrS_TwrId AND TwC_TwCNumer = 1 )
                 -- jeśli marża ze średniej z zasobów i nie brakuje zasobów
                 IF @Marza_Sym_Srednia = 1
                   IF ( SELECT ISNULL(SUM(TwZ_Ilosc),0) FROM cdn.TwrZasoby WHERE TwZ_TwrId = @TrS_TwrId ) <> 0
                     SET @TrS_Wartosc = @TrE_Ilosc * ( SELECT ISNULL(SUM(TwZ_Wartosc)/SUM(TwZ_Ilosc),0) FROM cdn.TwrZasoby WHERE TwZ_TwrId = @TrS_TwrId )
                 SET @TrS_Cena = CASE @TrS_Ilosc WHEN 0 THEN 0 ELSE round(@TrS_Wartosc / @TrS_Ilosc,@ZaokraglajDo) END
              END
          END
        -- Liczenie kosztu usługi dla RWS (na pozostałych wewnętrznych koszt usługi jest zapisywany z obiektu)
        IF @Twr_Typ = 0 AND @TrE_TypDokumentu = 318  and @TrE_KosztUslugiZDok = 0
          BEGIN
            IF @Twr_KosztUslugiTyp = 1
              SET @TrE_KosztUslugi = ROUND( @TrE_Ilosc * @Twr_KosztUslugi, 2 )
            ELSE IF @Twr_KosztUslugiTyp = 2
              SET @TrE_KosztUslugi = ROUND( @TrE_WartoscNetto * @Twr_KosztUslugi / 100, 2 )
            UPDATE cdn.TraElem SET TrE_KosztUslugi = @TrE_KosztUslugi WHERE TrE_TrEId = @TrE_TrEId
          END
        -- AVCO - przed dodaniem subelementu dostawczego lub kosztowego sprawdzić date ostatniej modyfikacji zasobu
        IF @TrS_Metoda = 3 AND @TrS_Typ IN ( 1, 2 )
          BEGIN
            SET @Data_Dost = ( SELECT ISNULL(TwZ_Data,'1800-01-01') FROM cdn.TwrZasoby WHERE TwZ_TwrId = @TrS_TwrId AND TwZ_MagId = @TrS_MagId AND TwZ_TrSIdDost IS NULL )
            IF @TrS_DataOpe < @Data_Dost
              BEGIN
              -- jeśli kontrola daty ostatniej modyfiakcji zasobu zaznaczona
              IF ( SELECT TOP 1 ISNULL(MAX(SUBSTRING(Fir_Wartosc,1,1)),0) FROM cdn.Firma WHERE Fir_Numer = 1688 ) = 0
                BEGIN
      SET @Komunikat = '##OPT34592##%%s1%%=' + REPLACE(@TrE_TwrKod,'%','%%')
      +'%%s3%%='+CONVERT( NVarchar(10), @Data_Dost, 120 )
      +'%%s4%%='+CONVERT( NVarchar(10), @TrS_DataOpe, 120 )
      + '##'
      --SET @Komunikat = 'Zapis niemożliwy !  Dla towaru ' + @TrE_TwrKod + ' data ostatniej modyfikacji zasobu (' + CONVERT( NVarchar(10), @Data_Dost, 120 ) + ') jest późniejsza niż data transakcji (' + CONVERT( NVarchar(10), @TrS_DataOpe, 120 ) + ')'
                  IF @Komunikat <> '' GOTO KOMUNIKAT
                END
              END
          END
        -- ustawienia korekty wartosci dla PZ z dostawami
         SET @DostIloscRecordow = 0
         SET @DostIloscRecordowReal = 0
        IF (@TrS_Rodzaj IN ( 307002,307006,310002,303002,307003, 307011)) or (@TrS_Rodzaj IN ( 317001) and @TrE_Ilosc = 0  and @Tre_WyborDostaw = 0)
          BEGIN
            SELECT @DostIloscRecordowReal =count(A.TrS_TrSId)
             FROM cdn.TraSElem A
             JOIN cdn.TraElem B ON B.TrE_TrEId = A.TrS_TrEId
            WHERE B.TrE_TrEId = @TrE_ZwrId
          END
        IF @DostIloscRecordowReal > 1
          BEGIN
            SELECT  @DostIloscRecordow =count(A.TrS_TrSId)
              FROM cdn.TraSElem A
              JOIN cdn.TraElem B ON B.TrE_TrEId = A.TrS_TrEId
              JOIN (SELECT A.TrS_TrSId, abs(ISNULL(A.TrS_Ilosc,0))-abs(ISNULL(B.TrS_Ilosc,0)) as Roznica
                    FROM cdn.TraSElem A
                    LEFT OUTER JOIN cdn.TraSElem B ON A.TrS_TrSId = B.TrS_ZwrId
     WHERE A.TrS_Typ = 1 AND A.TrS_TrEId = @TrE_ZwrId) AS C ON C.TrS_TrSId = A.TrS_TrSId
              WHERE B.TrE_TrEId = @TrE_ZwrId AND C.Roznica > 0
             SELECT @DostTrS_Ilosc =
             (SELECT ISNULL(sum(TrS_Ilosc),0) FROM cdn.TraSElem WHERE Trs_Typ = 1 AND TrS_TrEId = @TrE_ZwrId)
              +
             (SELECT ISNULL(sum(TrS_Ilosc),0) FROM cdn.TraSElem WHERE Trs_Typ = 1 AND TrS_Zwrid
              in(SELECT TrS_TrSId FROM cdn.TraSElem WHERE Trs_Typ = 1 AND TrS_TrEId = @TrE_ZwrId ))
           SET @DostIloscRecordowDodanych = 1
           SET @ResztaWartosc = @TrE_WartoscNetto
           DECLARE DostawyKorektaWartosci CURSOR LOCAL FAST_FORWARD FOR
            SELECT A.TrS_TrSId
              FROM cdn.TraSElem A
              JOIN cdn.TraElem B ON B.TrE_TrEId = A.TrS_TrEId
              JOIN (SELECT A.TrS_TrSId, abs(ISNULL(A.TrS_Ilosc,0))-abs(ISNULL(B.TrS_Ilosc,0)) AS Roznica
                    FROM cdn.TraSElem A
                    LEFT OUTER JOIN (SELECT B.TrS_ZwrId, SUM(ISNULL(B.TrS_Ilosc,0))  as TrS_Ilosc
                                     FROM cdn.TraSElem A
                                     LEFT OUTER JOIN  cdn.TraSElem B ON A.TrS_TrSId = B.TrS_ZwrId WHERE A.TrS_Typ = 1 AND A.TrS_TrEId = @TrE_ZwrId AND B.TrS_ZwrId IS NOT NULL
                                     GROUP BY B.TrS_ZwrId) B ON A.TrS_TrSId = B.TrS_ZwrId
                    WHERE A.TrS_Typ = 1 AND A.TrS_TrEId = @TrE_ZwrId) AS C ON C.TrS_TrSId = A.TrS_TrSId
             WHERE B.TrE_TrEId = @TrE_ZwrId AND c.roznica > 0
           OPEN DostawyKorektaWartosci
           WHILE 1=1
           BEGIN
             FETCH NEXT FROM DostawyKorektaWartosci INTO @DostTrS_TrSId
             IF @@FETCH_STATUS <> 0 BREAK
               IF @DostIloscRecordowDodanych = @DostIloscRecordow
               SELECT
                @TrS_TrSIdDost  = TrS_TrSIdDost,
                @TrS_Cena       = TrS_Cena,
                @TrS_Wartosc    = @ResztaWartosc,
                @TrS_ZwrId      = TrS_TrSId
              FROM cdn.TraSElem
              WHERE TrS_TrSId = @DostTrS_TrSId
               ELSE
               SELECT
                @TrS_TrSIdDost  = MAX(TrS_TrSIdDost),
                @TrS_Cena       = MAX(TrS_Cena),
                @TrS_Wartosc    = ROUND( (@TrE_WartoscNetto/@DostTrS_Ilosc)*SUM(TrS_Ilosc),2),
                @TrS_ZwrId      = MIN(TrS_TrSId)
              FROM cdn.TraSElem
              WHERE TrS_TrSId = @DostTrS_TrSId OR TrS_ZwrID = @DostTrS_TrSId
              SET @DostIloscRecordowDodanych = @DostIloscRecordowDodanych + 1
              SET @ResztaWartosc = @ResztaWartosc - @TrS_Wartosc
     SET @TrS_TrSId       = ( SELECT ISNULL(MAX(TrS_TrSId),0) FROM cdn.TraSElem ) + 1
              --select @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc as wartosc, @TrS_Cena, @TrS_Termin, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor
              EXECUTE CDN.AktualizujTraSElem @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrS_Termin, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor
          END
          CLOSE DostawyKorektaWartosci
          DEALLOCATE DostawyKorektaWartosci
          UPDATE cdn.TraElem SET TrE_KosztUslugi = 0 WHERE TrE_TrEId = @TrE_TrEId
        END
        -- dodanie subelemntu (towary lub usługi gdy dokumenty rozchodowe )
        IF @Twr_Typ = 1 AND ISNULL(@Tre_WyborDostaw,0)  = 0 AND @DostIloscRecordowReal  < 2 AND @TrE_IFA24Mag = 0
          BEGIN
            EXECUTE CDN.AktualizujTraSElem @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrS_Termin, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor
            UPDATE cdn.TraElem SET TrE_KosztUslugi = 0 WHERE TrE_TrEId = @TrE_TrEId
          END
        -- dodanie subelemntu dla rezerwacji (usługi)
        IF @Twr_Typ = 0
          BEGIN
             IF  @TrS_Rodzaj IN ( 307010, 302008, 305008, 306008,  301011 , 306004, 307004, 302009, 302004, 306010,304000,304008,312008,312100)
               EXEC [CDN].[UstawRezerwacje] @TrS_TrEId,0,0
             IF  @TrE_TypDokumentu IN ( 308, 309)
               BEGIN
                 SET @TrS_Typ = @TrS_Typ + 10
                 EXECUTE CDN.AktualizujTraSElem @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj,  @TrS_Typ , @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrS_Termin, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor
               END
          END
        -- Update wartości i cen elementu dla dokumentów wewnętrznych
        IF @TrE_TypDokumentu IN ( 304, 312, 318 ) AND @TrN_Rodzaj NOT IN ( 312010 )
          BEGIN
            SET @TrE_WartoscZakupu = ( SELECT TrE_WartoscZakupu FROM cdn.TraElem WHERE TrE_TrEId = @TrE_TrEId )
            UPDATE cdn.TraElem SET
              TrE_WartoscNetto     = @TrE_WartoscZakupu,
              TrE_WartoscBrutto    = ROUND(@TrE_WartoscZakupu * ( ( 100 + TrE_Stawka ) / 100 ), 2 ),
              TrE_WartoscNettoWal  = @TrE_WartoscZakupu,
              TrE_WartoscBruttoWal = ROUND(@TrE_WartoscZakupu * ( ( 100 + TrE_Stawka ) / 100 ), 2 ),
              TrE_Rabat            = 0,
              TrE_CenaT            = round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END,@ZaokraglajDo),
              TrE_CenaW            = round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END ,@ZaokraglajDo),
              TrE_Cena0            = round(CASE TrE_Ilosc   WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_Ilosc   END,@ZaokraglajDo) ,
              TrE_CenaWWD          = round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END,@ZaokraglajDo),
              TrE_Cena0WD          = round(CASE TrE_Ilosc   WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_Ilosc   END,@ZaokraglajDo),
              TrE_Waluta           = @WalutaSys,
              TrE_KursNumer        = 0,
              TrE_KursL            = 1,
              TrE_KursM            = 1
            WHERE TrE_TrEId = @TrE_TrEId
          END
        -- Aktualizacja ceny zakupu towaru i kosztu usługi na karcie magazynowej dla każdego elementu PWP
        -- Jeśli waluta dokumentu (naglowka) jest systemowa, to zmiana ceny zakupu na podstawie waluty elemetnu
        -- parametry waluty z elementu
        IF @TrN_Waluta = @WalutaSys
          BEGIN
            SET @Waluta    = @TrE_Waluta
            SET @KursNumer = @TrE_KursNumer
            SET @KursL     = @TrE_KursL
            SET @KursM     = @TrE_KursM
            SET @CenaW_New = @TrE_CenaW
          END
        -- parametry waluty z nagłówka
        ELSE
          BEGIN
            SET @Waluta    = @TrN_Waluta
            SET @KursNumer = @TrN_KursNumer
            SET @KursL     = @TrN_KursL
            SET @KursM     = @TrN_KursM
            SET @CenaW_New = @TrE_CenaWWD
          END
/*
        -- Sprawdzenie, czy należy aktualizować cenę zakupu na MM-OL
        IF @TrN_Rodzaj = 312010
          SELECT TOP 1 @Aktualizuj_CenaZ_MMOL = CONVERT(TINYINT, ISNULL(Fir_Wartosc,0)) FROM cdn.Firma WHERE Fir_Numer = 1758
        -- Rodzaj marży: 0 = "od stu", 1 = "w stu"
        IF ( @TrE_TypDokumentu IN ( 310, 303, 307, 301, 317, 313 ) OR ( @TrN_Rodzaj = 312010 AND @Aktualizuj_CenaZ_MMOL = 1 ) )
          AND @TrE_Ilosc > 0
          AND @TrN_Bufor IN ( 0 )
          BEGIN
            -- parametry kursu waluty dla towaru lub usługi z typem kwotowym
            IF @Twr_Typ = 1 OR ( @Twr_Typ = 0 AND @Twr_KosztUslugiTyp = 1 )
              UPDATE cdn.Towary SET
                Twr_Waluta         = @Waluta,
                Twr_KursNumer      = @KursNumer,
                Twr_KursL          = @KursL,
                Twr_KursM          = @KursM
              WHERE Twr_TwrId = @TrE_TwrId
            -- koszt usługi ( usługa i typ kosztu kwotowy )
            IF @Twr_Typ = 0 AND @Twr_KosztUslugiTyp = 1
              BEGIN
                -- od netto
                IF @TrE_TypNB = 1
                  BEGIN
                    SET @Twr_KosztUslugiNew    = @TrE_CenaT
                    SET @Twr_KosztUslugiWalNew = @CenaW_New
                  END
                -- od brutto
                ELSE IF @TrE_TypNB = 2
                  BEGIN
                    SET @Twr_KosztUslugiNew    = @TrE_CenaT   - ROUND ( @TrE_CenaT   * @TrE_Stawka / (100 + @TrE_Stawka) , 2 )
                    SET @Twr_KosztUslugiWalNew = @CenaW_New - ROUND (  @CenaW_New  * @TrE_Stawka / (100 + @TrE_Stawka) , 2 )
                  END
                UPDATE cdn.Towary SET
                  Twr_KosztUslugi    = @Twr_KosztUslugiNew,
                  Twr_KosztUslugiWal = @Twr_KosztUslugiWalNew
                WHERE Twr_TwrId = @TrE_TwrId
              END
            -- Kursor po cenach dla towaru lub usługi z kosztem kwotowym:
            -- aktualizacja ceny zakupu (TwC_TwCNumer = 1)
            -- aktualizacja marży dla cen sprzedaży z aktualizacją ustawiną na "Nie" ( TwC_TwCNumer <> 1 AND TwC_Aktualizacja = 0 )
            IF @Twr_Typ = 1 OR ( @Twr_Typ = 0 AND @Twr_KosztUslugiTyp = 1 )
              BEGIN
                DECLARE TwrCeny CURSOR LOCAL FAST_FORWARD FOR
                SELECT TwC_TwCNumer, TwC_TwCId, TwC_Waluta, TwC_Wartosc, TwC_Typ
                  FROM cdn.TwrCeny
                  WHERE TwC_TwrId = @TrE_TwrId AND TwC_TwCNumer = 1
                UNION ALL
                SELECT TwC_TwCNumer, TwC_TwCId, TwC_Waluta, TwC_Wartosc, TwC_Typ
                  FROM cdn.TwrCeny
                  WHERE TwC_TwrId = @TrE_TwrId AND TwC_TwCNumer <> 1 AND TwC_Aktualizacja = 0
                OPEN TwrCeny
                  WHILE 1=1
                    BEGIN
                      FETCH NEXT FROM TwrCeny INTO @TwC_TwCNumer, @TwC_TwCId, @TwC_Waluta, @TwC_Wartosc, @TwC_Typ
                      IF @@FETCH_STATUS <> 0 BREAK
                      -- aktualizacja ceny zakupu
                      IF @TwC_TwCNumer = 1
                        BEGIN
                          -- od netto
                          IF @TrE_TypNB = 1
                            IF @TwC_Typ = 1
                              SET @TwC_Wartosc = @CenaW_New  * ( @TrE_JMPrzelicznikM / @TrE_JMPrzelicznikL )
                            ELSE
                              SET @TwC_Wartosc = ( @CenaW_New + ROUND( @CenaW_New * @TrE_Stawka / 100, 2 ) ) * (  @TrE_JMPrzelicznikM / @TrE_JMPrzelicznikL )
                          -- od brutto
                          ELSE IF @TrE_TypNB = 2
                            IF @TwC_Typ = 1
                              SET @TwC_Wartosc = ( @CenaW_New  - ROUND( @CenaW_New * @TrE_Stawka / ( 100+@TrE_Stawka), 2 ) ) *  ( @TrE_JMPrzelicznikM / @TrE_JMPrzelicznikL )
                            ELSE
                              SET @TwC_Wartosc =  @CenaW_New   *  ( @TrE_JMPrzelicznikM / @TrE_JMPrzelicznikL )
                          UPDATE cdn.TwrCeny SET
                            TwC_Wartosc = @TwC_Wartosc,
                            TwC_Waluta  = @Waluta
                          WHERE TwC_TwCId = @TwC_TwCId
                          SET @CenaZakupuNew = @TwC_Wartosc
                          SET @CenaZakupuNewWal = @CenaZakupuNew
                          SET @CenaZakupuNewPLN = @CenaZakupuNew * @KursL/@KursM
                        END  -- @TwC_TWCNumer = 1
                      -- aktualizacja marż dla cen sprzedaży
                      -- tylko wtedy, gdy waluta zakupu i sprzedaży są równe lub gdy waluta sprzedazy jest systemowa
                      ELSE IF @TwC_TwCNumer <> 1 AND  ( @TwC_Waluta = @Waluta OR @TwC_Waluta = @WalutaSys )
                        BEGIN
                          -- cena sprzedaży brutto - obliczamy jej reprezentację netto
                          IF @TwC_Typ = 2
                            SET @TwC_Wartosc  =  @TwC_Wartosc - ROUND( @TwC_Wartosc * @Twr_Stawka / ( 100 + @Twr_Stawka), 2 )
                          -- marża "od stu" i "w stu"
                          IF @CenaZakupuNew <> 0
                            BEGIN
                             -- jeśli waluta zakupu i sprzedaży są równe, to bierzemy cenę zakupu w walucie dokumentu
                             -- w przeciwnym przypadku, gdy cena sprzedaży jest w walucie systemowej, to bierzemy cenę zakupu w walucie systemowej
                             IF @TwC_Waluta = @WalutaSys AND @Waluta <> @WalutaSys
                               SET @CenaZakupuNew = @CenaZakupuNewPLN
                             ELSE
                               SET @CenaZakupuNew = @CenaZakupuNewWal
                              SET @TwC_Marza = ( ( @TwC_Wartosc / @CenaZakupuNew ) - 1 ) * 100
                              IF ( @TwC_Marza = -100 )  OR ( @CenaZakupuNew = @TwC_Wartosc )
                                SET @TwC_MarzaWStu = 100
                              ELSE IF @TwC_Wartosc = 0
                                SET @TwC_MarzaWStu = -100
                              ELSE
                                SET @TwC_MarzaWStu = 100 * @TwC_Marza / ( 100 + @TwC_Marza )
                              IF @TwC_Marza     > 99999.99 SET @TwC_Marza     = 99999.99
                              IF @TwC_MarzaWStu > 99999.99 SET @TwC_MarzaWStu = 99999.99
         IF @TwC_Marza     < - 99999.99 SET @TwC_Marza     = -99999.99
                              IF @TwC_MarzaWStu < - 99999.99 SET @TwC_MarzaWStu = -99999.99
                            END
                            IF @TwC_Marza IS NOT NULL AND @TwC_MarzaWStu IS NOT NULL
                            UPDATE cdn.TwrCeny SET
                              TwC_Marza = @TwC_Marza,
                              TwC_MarzaWStu = @TwC_MarzaWStu
                            WHERE TwC_TwCId = @TwC_TwCId
                        END
                    END -- kursor TwrCeny
                CLOSE TwrCeny
                DEALLOCATE TwrCeny
              END -- Towar lub usługa z kosztem kwotowym
          END -- aktualizacji ostatniej ceny zakupu
        IF @MyIdentity IS NOT NULL
          BEGIN
            SET IDENTITY_INSERT cdn.Idn ON
            INSERT INTO cdn.Idn (i) VALUES (@MyIdentity)
            SET IDENTITY_INSERT cdn.Idn OFF
   DELETE FROM cdn.Idn  WHERE i = @MyIdentity --WiNi
          END
*/
--automatyczne zasoby
if exists (SELECT TOP 1 ISNULL( Fir_Wartosc,1 ) FROM cdn.Firma WHERE Fir_Numer = 3154 and Fir_Wartosc = 1 )
and exists (select top 1 twa_twrid from CDN.Twratrybuty where twa_twrid =  @TrE_TwrId and TwA_CzyPrzenosicNaDostawy = 1)
and not exists(select * from cdn.tranag where trn_trnid = @TrE_TrNId and TrN_GIDFirma = 2)
and not exists(select * from cdn.tranag
left join cdn.tranagrelacje on trr_trnid = trn_trnid
where trr_faid = @TrE_TrNId and TrN_GIDFirma = 2 and TrR_FaTyp in(306,304) and trr_trnTyp in(302,305))
--and not exists (select top 1 tsd_treid from CDN.TraselemDost where tsd_treid =  @TrE_TrEId )
and @TrE_TypDokumentu != 314  and @TrE_Kaucja = 0
begin
INSERT INTO [CDN].[TraSElemDost]
           ([TsD_TrSID]
           ,[TsD_TrEId]
           ,[TsD_TrSIdDost]
           ,[TsD_ZwrId]
           ,[TsD_NumerPelny]
           ,[TsD_NumerObcy]
           ,[TsD_DataOpe]
           ,[TsD_Ilosc]
           ,[TsD_IloscDostepna]
           ,[TsD_Wartosc]
           ,[TsD_Cecha1_DeAId]
           ,[TsD_Cecha1_Format]
           ,[TsD_Cecha1_Kod]
     ,[TsD_Cecha1_Wartosc]
           ,[TsD_Cecha2_DeAId]
           ,[TsD_Cecha2_Format]
           ,[TsD_Cecha2_Kod]
     ,[TsD_Cecha2_Wartosc]
           ,[TsD_Cecha3_DeAId]
           ,[TsD_Cecha3_Format]
           ,[TsD_Cecha3_Kod]
     ,[TsD_Cecha3_Wartosc]
           ,[TsD_Cecha4_DeAId]
           ,[TsD_Cecha4_Format]
           ,[TsD_Cecha4_Kod]
     ,[TsD_Cecha4_Wartosc]
           ,[TsD_Cecha5_DeAId]
           ,[TsD_Cecha5_Format]
           ,[TsD_Cecha5_Kod]
     ,[TsD_Cecha5_Wartosc]
           ,[TsD_Cecha6_DeAId]
           ,[TsD_Cecha6_Format]
           ,[TsD_Cecha6_Kod]
     ,[TsD_Cecha6_Wartosc]
           ,[TsD_Cecha7_DeAId]
           ,[TsD_Cecha7_Format]
           ,[TsD_Cecha7_Kod]
     ,[TsD_Cecha7_Wartosc]
           ,[TsD_Cecha8_DeAId]
           ,[TsD_Cecha8_Format]
           ,[TsD_Cecha8_Kod]
     ,[TsD_Cecha8_Wartosc]
           ,[TsD_Cecha9_DeAId]
           ,[TsD_Cecha9_Format]
           ,[TsD_Cecha9_Kod]
     ,[TsD_Cecha9_Wartosc]
           ,[TsD_Cecha10_DeAId]
           ,[TsD_Cecha10_Format]
           ,[TsD_Cecha10_Kod]
           ,[TsD_Cecha10_Wartosc]
           ,[TsD_Dostawca]
           ,[TsD_PdEId])
select
case  when trasElemWZ.TrS_Rodzaj in (312000,312008) then (trasElemWZ.TrS_TrSID+1) else  trasElemWZ.TrS_TrSID end,
trasElemWZ.TrS_TrEId,
trasElemWZ.TrS_TrSIdDost,
Null,
PZ.TrN_NumerPelny,
PZ.TrN_NumerObcy,
trasElemPZ.TrS_DataOpe,
trasElemWZ.TrS_Ilosc,
trasElemWZ.TrS_Ilosc,
ROUND(trasElemWZ.TrS_Wartosc/trasElemWZ.TrS_Ilosc,4),
         isnull(TsC_Cecha1_DeAId,0),
         isnull(TsC_Cecha1_Format,0),
         isnull(TsC_Cecha1_Kod,''),
         isnull(TsC_Cecha1_Wartosc,''),
         isnull(TsC_Cecha2_DeAId,0),
         isnull(TsC_Cecha2_Format,0),
         isnull(TsC_Cecha2_Kod,''),
         isnull(TsC_Cecha2_Wartosc,''),
         isnull(TsC_Cecha3_DeAId,0),
         isnull(TsC_Cecha3_Format,0),
         isnull(TsC_Cecha3_Kod,''),
         isnull(TsC_Cecha3_Wartosc,''),
         isnull(TsC_Cecha4_DeAId,0),
         isnull(TsC_Cecha4_Format,0),
         isnull(TsC_Cecha4_Kod,''),
         isnull(TsC_Cecha4_Wartosc,''),
         isnull(TsC_Cecha5_DeAId,0),
         isnull(TsC_Cecha5_Format,0),
         isnull(TsC_Cecha5_Kod,''),
         isnull(TsC_Cecha5_Wartosc,''),
         isnull(TsC_Cecha6_DeAId,0),
         isnull(TsC_Cecha6_Format,0),
         isnull(TsC_Cecha6_Kod,''),
         isnull(TsC_Cecha6_Wartosc,''),
         isnull(TsC_Cecha7_DeAId,0),
         isnull(TsC_Cecha7_Format,0),
         isnull(TsC_Cecha7_Kod,''),
         isnull(TsC_Cecha7_Wartosc,''),
         isnull(TsC_Cecha8_DeAId,0),
         isnull(TsC_Cecha8_Format,0),
         isnull(TsC_Cecha8_Kod,''),
         isnull(TsC_Cecha8_Wartosc,''),
         isnull(TsC_Cecha9_DeAId,0),
         isnull(TsC_Cecha9_Format,0),
         isnull(TsC_Cecha9_Kod,''),
         isnull(TsC_Cecha9_Wartosc,''),
         isnull(TsC_Cecha10_DeAId,0),
         isnull(TsC_Cecha10_Format,0),
         isnull(TsC_Cecha10_Kod,''),
         isnull(TsC_Cecha10_Wartosc,''),
   '',0
from CDN.TraSElem trasElemWZ
left join CDN.TraElem ElemWZ on ElemWZ.TrE_TrEId = trasElemWZ.TrS_TrEId
left join CDN.TraSElem trasElemPZ on trasElemWZ.TrS_TrSIdDost = trasElemPZ.TrS_TrSId
LEFT JOIN CDN.TraSElemCechy TraSElemCechy ON trasElemPZ.TrS_TrSId = TsC_TrSId
left join CDN.TraElem ElemPZ on ElemPZ.TrE_TrEId = trasElemPZ.TrS_TrEId
left join CDN.TraNag PZ on ElemPZ.TrE_TrNId = PZ.TrN_TrNId
where trasElemWZ.trs_treid = @TrE_TrEId and trasElemWZ.trs_typ = 2
and trasElemWZ.TrS_WyborDostaw = 0 and trasElemWZ.TrS_Ilosc > 0
INSERT INTO [CDN].[TraSElemCechy] ([TsC_TrSID],[TsC_Cecha1_DeAId] ,[TsC_Cecha1_Format] ,[TsC_Cecha1_Kod] ,[TsC_Cecha1_Wartosc] ,[TsC_Cecha2_DeAId] ,[TsC_Cecha2_Format] ,[TsC_Cecha2_Kod] ,[TsC_Cecha2_Wartosc] ,[TsC_Cecha3_DeAId] ,[TsC_Cecha3_Format]
              ,[TsC_Cecha3_Kod] ,[TsC_Cecha3_Wartosc] ,[TsC_Cecha4_DeAId] ,[TsC_Cecha4_Format] ,[TsC_Cecha4_Kod] ,[TsC_Cecha4_Wartosc] ,[TsC_Cecha5_DeAId] ,[TsC_Cecha5_Format] ,[TsC_Cecha5_Kod] ,[TsC_Cecha5_Wartosc] ,[TsC_Cecha6_DeAId]
              ,[TsC_Cecha6_Format],[TsC_Cecha6_Kod] ,[TsC_Cecha6_Wartosc] ,[TsC_Cecha7_DeAId] ,[TsC_Cecha7_Format] ,[TsC_Cecha7_Kod] ,[TsC_Cecha7_Wartosc] ,[TsC_Cecha8_DeAId] ,[TsC_Cecha8_Format] ,[TsC_Cecha8_Kod] ,[TsC_Cecha8_Wartosc]
              ,[TsC_Cecha9_DeAId] ,[TsC_Cecha9_Format] ,[TsC_Cecha9_Kod] ,[TsC_Cecha9_Wartosc] ,[TsC_Cecha10_DeAId] ,[TsC_Cecha10_Format] ,[TsC_Cecha10_Kod] ,[TsC_Cecha10_Wartosc])
SELECT
TrS_TrSID,
isnull(TsD_Cecha1_DeAId,0),
isnull(TsD_Cecha1_Format,0),
isnull(TsD_Cecha1_Kod,''),
isnull(TsD_Cecha1_Wartosc,''),
isnull(TsD_Cecha2_DeAId,0),
isnull(TsD_Cecha2_Format,0),
isnull(TsD_Cecha2_Kod,''),
isnull(TsD_Cecha2_Wartosc,''),
isnull(TsD_Cecha3_DeAId,0),
isnull(TsD_Cecha3_Format,0),
isnull(TsD_Cecha3_Kod,''),
isnull(TsD_Cecha3_Wartosc,''),
isnull(TsD_Cecha4_DeAId,0),
isnull(TsD_Cecha4_Format,0),
isnull(TsD_Cecha4_Kod,''),
isnull(TsD_Cecha4_Wartosc,''),
isnull(TsD_Cecha5_DeAId,0),
isnull(TsD_Cecha5_Format,0),
isnull(TsD_Cecha5_Kod,''),
isnull(TsD_Cecha5_Wartosc,''),
isnull(TsD_Cecha6_DeAId,0),
isnull(TsD_Cecha6_Format,0),
isnull(TsD_Cecha6_Kod,''),
isnull(TsD_Cecha6_Wartosc,''),
isnull(TsD_Cecha7_DeAId,0),
isnull(TsD_Cecha7_Format,0),
isnull(TsD_Cecha7_Kod,''),
isnull(TsD_Cecha7_Wartosc,''),
isnull(TsD_Cecha8_DeAId,0),
isnull(TsD_Cecha8_Format,0),
isnull(TsD_Cecha8_Kod,'') ,
isnull(TsD_Cecha8_Wartosc,''),
isnull(TsD_Cecha9_DeAId,0),
isnull(TsD_Cecha9_Format,0),
isnull(TsD_Cecha9_Kod,''),
isnull(TsD_Cecha9_Wartosc,''),
isnull(TsD_Cecha10_DeAId,0),
isnull(TsD_Cecha10_Format,0),
isnull(TsD_Cecha10_Kod,''),
isnull(TsD_Cecha10_Wartosc,'')
from CDN.TraSElem
left join CDN.TraSElemDost  on Tsd_TrSId = TrS_TrSId
where trs_treid = @TrE_TrEId and trs_typ = 2
and TrS_WyborDostaw = 0 and trs_ilosc > 0
if exists(select * from cdn.traselemdost where  tsd_treid = @TrE_TrEId and isnull(TsD_PdEId,0) = 0)
and exists(select * from CDN.TraSElem trasElemWZ
where trasElemWZ.trs_treid = @TrE_TrEId and trasElemWZ.trs_typ = 2
and trasElemWZ.TrS_WyborDostaw = 0 and trasElemWZ.TrS_Ilosc > 0)
begin
 update CDN.TraSElem set TrS_WyborDostaw = 1 where TrS_TrEId = @TrE_TrEId and TrS_WyborDostaw != 1
 update CDN.TraElem set TrE_WyborDostaw = 1 where TrE_TrEID = @TrE_TrEId and TrE_WyborDostaw != 1
 if exists(select PAFA.tre_treid from cdn.traelem WZ
      left join cdn.tranagrelacje on WZ.TrE_TrNId =  TrR_TrNId AND TrR_FaTyp in(302, 305) AND TrR_TrNTyp= 306
      left join cdn.TraElem PAFA on PAFA.TrE_TrNId = TrR_FaId
         where WZ.TrE_TrEId = @TrE_TrEId AND WZ.TrE_TypDokumentu = 306 AND  WZ.TrE_Lppow = PAFA.TrE_LpPow and PAFA.TrE_WyborDostaw = 0 and WZ.TrE_WyborDostaw = 1 AND PAFA.TrE_TypDokumentu != 314)
      update CDN.TraElem set TrE_WyborDostaw = 1 where TrE_TrEId IN (
      select PAFA.tre_treid from cdn.traelem WZ
      left join cdn.tranagrelacje on WZ.TrE_TrNId =  TrR_TrNId AND TrR_FaTyp in(302, 305) AND TrR_TrNTyp= 306
      left join cdn.TraElem PAFA on PAFA.TrE_TrNId = TrR_FaId
         where WZ.TrE_TrEId = @TrE_TrEId AND WZ.TrE_TypDokumentu = 306 AND  WZ.TrE_Lppow = PAFA.TrE_LpPow  and PAFA.TrE_WyborDostaw = 0 and WZ.TrE_WyborDostaw = 1 AND PAFA.TrE_TypDokumentu != 314)
      and TrE_WyborDostaw != 1
end
end
      END
    CLOSE Dodawane
  DEALLOCATE Dodawane
  -- KosztUslugi = 0 dla towarów
  UPDATE CDN.TraElem SET TrE_KosztUslugi = 0 WHERE TrE_TrEId IN (select TrE_TrEId FROM inserted join cdn.towary on inserted.tre_twrid = twr_twrid and twr_typ = 1)
  -- sprawdzenie towaru z elementu po modyfikacjach dla dodawanych i kasowanych
  DECLARE EKI CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrE_TrEId, TrE_TwrId, TrE_DataOpe, TrE_TwrKod, TrE_TwrNazwa
      FROM (
             SELECT TrE_TrEId, TrE_TwrId, TrE_DataOpe, TrE_TwrKod, TrE_TwrNazwa
             FROM deleted where ISNULL(Tre_WyborDostaw,0) = 0
             UNION ALL
             SELECT TrE_TrEId, TrE_TwrId, TrE_DataOpe, TrE_TwrKod, TrE_TwrNazwa
             FROM inserted where ISNULL(Tre_WyborDostaw,0) = 0
           ) AS TrE_ERR
      GROUP BY TrE_TrEId, TrE_TwrId, TrE_DataOpe, TrE_TwrKod, TrE_TwrNazwa
    OPEN EKI
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM EKI INTO @TrE_TrEId, @TrE_TwrId, @TrE_DataOpe, @TrE_TwrKod,@TrE_TwrNazwa
        IF @@FETCH_STATUS <> 0 BREAK
  if (@TrE_Aktywny != 3)
        SET @Komunikat = CDN.TwrZasobyErr ( @TrE_TrEId, @TrE_TwrId, @TrE_TwrKod,@TrE_TwrNazwa, @TrE_DataOpe )
        IF @Komunikat <> '' GOTO KOMUNIKAT
      END
    CLOSE EKI
  DEALLOCATE EKI
  -- Wyswietlenie komunikatu i rollback całej transakcji
  KOMUNIKAT:
  IF @Komunikat <> ''
    BEGIN
      RAISERROR( @Komunikat, 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
