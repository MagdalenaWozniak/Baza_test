CREATE TABLE [CDN].[TraSElemDost] (
    [TsD_TsDID]           INT             IDENTITY (1, 1) NOT NULL,
    [TsD_TrSID]           INT             NOT NULL,
    [TsD_TrEId]           INT             NOT NULL,
    [TsD_TrSIdDost]       INT             NULL,
    [TsD_ZwrId]           INT             NULL,
    [TsD_NumerPelny]      VARCHAR (30)    NOT NULL,
    [TsD_NumerObcy]       VARCHAR (256)   NOT NULL,
    [TsD_DataOpe]         DATETIME        NOT NULL,
    [TsD_Dostawca]        NVARCHAR (50)   NOT NULL,
    [TsD_Ilosc]           DECIMAL (15, 4) NOT NULL,
    [TsD_IloscDostepna]   DECIMAL (15, 4) NOT NULL,
    [TsD_Wartosc]         DECIMAL (15, 4) NOT NULL,
    [TsD_Cecha1_DeAId]    INT             NOT NULL,
    [TsD_Cecha1_Format]   SMALLINT        NOT NULL,
    [TsD_Cecha1_Kod]      VARCHAR (20)    NOT NULL,
    [TsD_Cecha1_Wartosc]  NVARCHAR (255)  NOT NULL,
    [TsD_Cecha2_DeAId]    INT             NOT NULL,
    [TsD_Cecha2_Format]   SMALLINT        NOT NULL,
    [TsD_Cecha2_Kod]      VARCHAR (20)    NOT NULL,
    [TsD_Cecha2_Wartosc]  NVARCHAR (255)  NOT NULL,
    [TsD_Cecha3_DeAId]    INT             NOT NULL,
    [TsD_Cecha3_Format]   SMALLINT        NOT NULL,
    [TsD_Cecha3_Kod]      VARCHAR (20)    NOT NULL,
    [TsD_Cecha3_Wartosc]  NVARCHAR (255)  NOT NULL,
    [TsD_Cecha4_DeAId]    INT             NOT NULL,
    [TsD_Cecha4_Format]   SMALLINT        NOT NULL,
    [TsD_Cecha4_Kod]      VARCHAR (20)    NOT NULL,
    [TsD_Cecha4_Wartosc]  NVARCHAR (255)  NOT NULL,
    [TsD_Cecha5_DeAId]    INT             NOT NULL,
    [TsD_Cecha5_Format]   SMALLINT        NOT NULL,
    [TsD_Cecha5_Kod]      VARCHAR (20)    NOT NULL,
    [TsD_Cecha5_Wartosc]  NVARCHAR (255)  NOT NULL,
    [TsD_Cecha6_DeAId]    INT             NOT NULL,
    [TsD_Cecha6_Format]   SMALLINT        NOT NULL,
    [TsD_Cecha6_Kod]      VARCHAR (20)    NOT NULL,
    [TsD_Cecha6_Wartosc]  NVARCHAR (255)  NOT NULL,
    [TsD_Cecha7_DeAId]    INT             NOT NULL,
    [TsD_Cecha7_Format]   SMALLINT        NOT NULL,
    [TsD_Cecha7_Kod]      VARCHAR (20)    NOT NULL,
    [TsD_Cecha7_Wartosc]  NVARCHAR (255)  NOT NULL,
    [TsD_Cecha8_DeAId]    INT             NOT NULL,
    [TsD_Cecha8_Format]   SMALLINT        NOT NULL,
    [TsD_Cecha8_Kod]      VARCHAR (20)    NOT NULL,
    [TsD_Cecha8_Wartosc]  NVARCHAR (255)  NOT NULL,
    [TsD_Cecha9_DeAId]    INT             NOT NULL,
    [TsD_Cecha9_Format]   SMALLINT        NOT NULL,
    [TsD_Cecha9_Kod]      VARCHAR (20)    NOT NULL,
    [TsD_Cecha9_Wartosc]  NVARCHAR (255)  NOT NULL,
    [TsD_Cecha10_DeAId]   INT             NOT NULL,
    [TsD_Cecha10_Format]  SMALLINT        NOT NULL,
    [TsD_Cecha10_Kod]     VARCHAR (20)    NOT NULL,
    [TsD_Cecha10_Wartosc] NVARCHAR (255)  NOT NULL,
    [TsD_PdEId]           INT             CONSTRAINT [DF_TsD_PdEId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [TsD_Primary] PRIMARY KEY CLUSTERED ([TsD_TsDID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TrSTraElemD] FOREIGN KEY ([TsD_TrEId]) REFERENCES [CDN].[TraElem] ([TrE_TrEID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TrSTraElemD]
    ON [CDN].[TraSElemDost]([TsD_TrEId] ASC, [TsD_TrSID] ASC, [TsD_TsDID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TrSDostawa]
    ON [CDN].[TraSElemDost]([TsD_TrSIdDost] ASC) WITH (FILLFACTOR = 100);


GO
Create TRIGGER [CDN].[TrasElemDost_InsertUpdate_Trigger]
  ON [CDN].[TraSElemDost]
  FOR INSERT, UPDATE, DELETE
AS
 /*IF  UPDATE( TsD_DataOpe )
       AND NOT UPDATE( TsD_TsDID )
       AND NOT UPDATE( TsD_TrSID  )
       AND NOT UPDATE( TsD_TrEId  )
       AND NOT UPDATE( TsD_TrSIdDost )
       AND NOT UPDATE( TsD_NumerPelny  )
       AND NOT UPDATE( TsD_NumerObcy  )
       AND NOT UPDATE( TsD_Dostawca )
       AND NOT UPDATE( TsD_Ilosc )
       AND NOT UPDATE( TsD_IloscDostepna )
       AND NOT UPDATE( TsD_Cecha1_DeAId  )
       AND NOT UPDATE( TsD_Cecha1_Format )
       AND NOT UPDATE( TsD_Cecha1_Kod )
       AND NOT UPDATE( TsD_Cecha1_Wartosc )
       AND NOT UPDATE( TsD_Cecha2_DeAId  )
       AND NOT UPDATE( TsD_Cecha2_Format )
       AND NOT UPDATE( TsD_Cecha2_Kod )
       AND NOT UPDATE( TsD_Cecha2_Wartosc )
       AND NOT UPDATE( TsD_Cecha3_DeAId  )
       AND NOT UPDATE( TsD_Cecha3_Format )
       AND NOT UPDATE( TsD_Cecha3_Kod )
       AND NOT UPDATE( TsD_Cecha3_Wartosc )
       AND NOT UPDATE( TsD_Cecha4_DeAId  )
       AND NOT UPDATE( TsD_Cecha4_Format )
       AND NOT UPDATE( TsD_Cecha4_Kod )
       AND NOT UPDATE( TsD_Cecha4_Wartosc )
       AND NOT UPDATE( TsD_Cecha5_DeAId  )
       AND NOT UPDATE( TsD_Cecha5_Format )
       AND NOT UPDATE( TsD_Cecha5_Kod )
       AND NOT UPDATE( TsD_Cecha5_Wartosc )
       AND NOT UPDATE( TsD_Cecha6_DeAId  )
       AND NOT UPDATE( TsD_Cecha6_Format )
       AND NOT UPDATE( TsD_Cecha6_Kod )
       AND NOT UPDATE( TsD_Cecha6_Wartosc )
       AND NOT UPDATE( TsD_Cecha7_DeAId  )
       AND NOT UPDATE( TsD_Cecha7_Format )
       AND NOT UPDATE( TsD_Cecha7_Kod )
       AND NOT UPDATE( TsD_Cecha7_Wartosc )
       AND NOT UPDATE( TsD_Cecha8_DeAId  )
       AND NOT UPDATE( TsD_Cecha8_Format )
       AND NOT UPDATE( TsD_Cecha8_Kod )
       AND NOT UPDATE( TsD_Cecha8_Wartosc )
       AND NOT UPDATE( TsD_Cecha9_DeAId  )
       AND NOT UPDATE( TsD_Cecha9_Format )
       AND NOT UPDATE( TsD_Cecha9_Kod )
       AND NOT UPDATE( TsD_Cecha9_Wartosc )
       AND NOT UPDATE( TsD_Cecha10_DeAId  )
       AND NOT UPDATE( TsD_Cecha10_Format )
       AND NOT UPDATE( TsD_Cecha10_Kod )
       AND NOT UPDATE( TsD_Cecha10_Wartosc )
     BEGIN
     RETURN
     END*/
    DECLARE
    @TsD_TsDID int,
    @TsD_TrSID int ,
    @TsD_TrEId int ,
    @TsD_TrSIdDost int,
    @TsD_NumerPelny  NVarchar(30),
    @TsD_NumerObcy NVarchar(30),
    @TsD_DataOpe datetime ,
    @TsD_Dostawca NVarchar(20) ,
    @TsD_Ilosc decimal (15, 4) ,
    @TsD_IloscDostepna decimal (15, 4) ,
    @TsD_Cecha1_DeAId int ,
    @TsD_Cecha1_Format smallint ,
    @TsD_Cecha1_Kod NVarchar(20) ,
    @TsD_Cecha1_Wartosc NVarchar(255) ,
    @TsD_Cecha2_DeAId int ,
    @TsD_Cecha2_Format smallint ,
    @TsD_Cecha2_Kod NVarchar(20) ,
    @TsD_Cecha2_Wartosc NVarchar(255) ,
    @TsD_Cecha3_DeAId int ,
    @TsD_Cecha3_Format smallint ,
    @TsD_Cecha3_Kod NVarchar(20) ,
    @TsD_Cecha3_Wartosc NVarchar(255) ,
    @TsD_Cecha4_DeAId int ,
    @TsD_Cecha4_Format smallint ,
    @TsD_Cecha4_Kod NVarchar(20) ,
    @TsD_Cecha4_Wartosc NVarchar(255) ,
    @TsD_Cecha5_DeAId int ,
    @TsD_Cecha5_Format smallint ,
    @TsD_Cecha5_Kod NVarchar(20) ,
    @TsD_Cecha5_Wartosc NVarchar(255) ,
    @TsD_Cecha6_DeAId int ,
    @TsD_Cecha6_Format smallint ,
    @TsD_Cecha6_Kod NVarchar(20) ,
    @TsD_Cecha6_Wartosc NVarchar(255) ,
    @TsD_Cecha7_DeAId int ,
    @TsD_Cecha7_Format smallint ,
    @TsD_Cecha7_Kod NVarchar(20) ,
    @TsD_Cecha7_Wartosc NVarchar(255) ,
    @TsD_Cecha8_DeAId int ,
    @TsD_Cecha8_Format smallint ,
    @TsD_Cecha8_Kod NVarchar(20) ,
    @TsD_Cecha8_Wartosc NVarchar(255) ,
    @TsD_Cecha9_DeAId int ,
    @TsD_Cecha9_Format smallint ,
    @TsD_Cecha9_Kod NVarchar(20) ,
    @TsD_Cecha9_Wartosc NVarchar(255) ,
    @TsD_Cecha10_DeAId int ,
    @TsD_Cecha10_Format smallint ,
    @TsD_Cecha10_Kod NVarchar(20) ,
    @TsD_Cecha10_Wartosc NVarchar(255) ,
    @TsD_ZwrId int ,
    @TsD_Wartosc decimal(15,4),
    @TsD_TrEIdPWP int ,
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
  -- zmienne z elementu dla poprawnego zbudowania subelementu
    @TrE_TrEId          INT,
    @TrE_ZwrId          INT,
    @TrE_LpPow          INT,
    @TrE_TwrId          INT,
    @TrE_DataOpe        DATETIME,
    @TrE_Ilosc          DECIMAL(15,4),
    @TrE_WartoscNetto   DECIMAL(15,2),
    @TrE_WartoscZakupu  DECIMAL(15,2),
    @TrE_CenaT          DECIMAL(17,4),
    @TrE_WyborDostaw    SMALLINT,
    @TrE_TwrKod         NVarchar(50),
    @TrE_TwrNazwa       NVarchar(255),
    @TrE_JMPrzelicznikL DECIMAL(15,2),
    @TrE_JMPrzelicznikM DECIMAL(7,0),
    @TrE_Aktywny        TINYINT,
    @TrE_TypDokumentu   INT,
    @Twr_Typ            SMALLINT,
    @Tre_MagId          INT,
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
    -- zmienne pomocnicze symulacji marży
    @Marza_Sym_Ostatnia   INT,
    @Marza_Sym_Srednia    INT,
    -- Pomocnicza dla kursora
    @TrS_TrSId_K    INT,
    @TrS_TrEId_K    INT,
    @max            INT,
    @Komunikat          NVarchar(250),
    @DostIloscRecordowReal int,
    @DostIloscRecordow int,
 @DostIloscRecordowDodanych int,
    @DostTrS_Ilosc decimal(15,4),
    @DostTrS_TrSId int,
    @ResztaWartosc DECIMAL(15,2)
    SET NOCOUNT ON
 SET @DostIloscRecordow = 0
    SET @DostIloscRecordowReal = 0
 SET @DostIloscRecordowDodanych = 1
 SET @ResztaWartosc = -1
    -- ustawienie komunikatu
    SET @Komunikat = ''
    -- Metoda rozliczania magazynu
    IF EXISTS ( SELECT * FROM inserted )
      BEGIN
        SET @Metoda = ( SELECT TOP 1 ISNULL( Fir_Wartosc,1 ) FROM CDN.Firma WHERE Fir_Numer = 1352 )
        SET @QUAN   = ( SELECT TOP 1 ISNULL( Fir_Wartosc,0 ) FROM CDN.Firma WHERE Fir_Numer = 1485 )
      END
    DECLARE @ZaokraglajDo  SMALLINT
    IF EXISTS(SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=3048 )
      SELECT @ZaokraglajDo=case when Fir_Wartosc = 1 then 4 else 2 end FROM Cdn.Firma WHERE Fir_Numer=3048
    ELSE
      SELECT @ZaokraglajDo=2
    IF @Metoda in( 1,2) and @QUAN = 0
    BEGIN
      -- elementy kasowane
      DECLARE @TrS TABLE ( TrSId INT, TrEId INT )
      INSERT INTO @TrS ( TrSId, TrEId ) SELECT TsD_TrSId, TsD_TrEId FROM deleted where TsD_PdEId = 0
      DELETE cdn.TraSElem FROM cdn.TraSElem JOIN @TrS ON TrSId = TrS_TrSId AND  TrS_TrEId = TrEId-- WHERE TrS_TrEId IN ( SELECT TrE_TrEId FROM deleted ) -- = @TrE_TrEId
      -- elementy dodawane
      DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
      SELECT  [TsD_TsDID],[TsD_TrSID] ,[TsD_TrEId] ,[TsD_TrSIdDost] ,[TsD_NumerPelny] ,[TsD_NumerObcy] ,[TsD_DataOpe] ,[TsD_Dostawca] ,[TsD_Ilosc] ,[TsD_IloscDostepna]
              ,[TsD_Cecha1_DeAId] ,[TsD_Cecha1_Format] ,[TsD_Cecha1_Kod] ,[TsD_Cecha1_Wartosc] ,[TsD_Cecha2_DeAId] ,[TsD_Cecha2_Format] ,[TsD_Cecha2_Kod]
              ,[TsD_Cecha2_Wartosc] ,[TsD_Cecha3_DeAId] ,[TsD_Cecha3_Format] ,[TsD_Cecha3_Kod] ,[TsD_Cecha3_Wartosc] ,[TsD_Cecha4_DeAId] ,[TsD_Cecha4_Format]
              ,[TsD_Cecha4_Kod] ,[TsD_Cecha4_Wartosc] ,[TsD_Cecha5_DeAId] ,[TsD_Cecha5_Format] ,[TsD_Cecha5_Kod] ,[TsD_Cecha5_Wartosc] ,[TsD_Cecha6_DeAId]
              ,[TsD_Cecha6_Format] ,[TsD_Cecha6_Kod] ,[TsD_Cecha6_Wartosc] ,[TsD_Cecha7_DeAId] ,[TsD_Cecha7_Format] ,[TsD_Cecha7_Kod] ,[TsD_Cecha7_Wartosc]
              ,[TsD_Cecha8_DeAId] ,[TsD_Cecha8_Format] ,[TsD_Cecha8_Kod] ,[TsD_Cecha8_Wartosc] ,[TsD_Cecha9_DeAId] ,[TsD_Cecha9_Format] ,[TsD_Cecha9_Kod]
              ,[TsD_Cecha9_Wartosc] ,[TsD_Cecha10_DeAId] ,[TsD_Cecha10_Format] ,[TsD_Cecha10_Kod] ,[TsD_Cecha10_Wartosc],tre_magid, TsD_ZwrId, TsD_Wartosc
      FROM inserted
      join cdn.traelem on tre_treid = tsd_treid
   where TsD_PdEId = 0
      ORDER BY TsD_TrEId, TsD_TrSId, TsD_TsDId
      OPEN Dodawane
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM Dodawane INTO @TsD_TsDID, @TsD_TrSID, @TsD_TrEId, @TsD_TrSIdDost, @TsD_NumerPelny, @TsD_NumerObcy, @TsD_DataOpe,
               @TsD_Dostawca, @TsD_Ilosc, @TsD_IloscDostepna, @TsD_Cecha1_DeAId, @TsD_Cecha1_Format, @TsD_Cecha1_Kod,
               @TsD_Cecha1_Wartosc, @TsD_Cecha2_DeAId, @TsD_Cecha2_Format, @TsD_Cecha2_Kod, @TsD_Cecha2_Wartosc, @TsD_Cecha3_DeAId ,
               @TsD_Cecha3_Format, @TsD_Cecha3_Kod, @TsD_Cecha3_Wartosc, @TsD_Cecha4_DeAId, @TsD_Cecha4_Format, @TsD_Cecha4_Kod,
               @TsD_Cecha4_Wartosc, @TsD_Cecha5_DeAId, @TsD_Cecha5_Format, @TsD_Cecha5_Kod, @TsD_Cecha5_Wartosc, @TsD_Cecha6_DeAId,
               @TsD_Cecha6_Format, @TsD_Cecha6_Kod, @TsD_Cecha6_Wartosc, @TsD_Cecha7_DeAId, @TsD_Cecha7_Format, @TsD_Cecha7_Kod,
               @TsD_Cecha7_Wartosc, @TsD_Cecha8_DeAId, @TsD_Cecha8_Format, @TsD_Cecha8_Kod, @TsD_Cecha8_Wartosc, @TsD_Cecha9_DeAId,
               @TsD_Cecha9_Format, @TsD_Cecha9_Kod, @TsD_Cecha9_Wartosc, @TsD_Cecha10_DeAId, @TsD_Cecha10_Format, @TsD_Cecha10_Kod ,
               @TsD_Cecha10_Wartosc,@tre_magid, @TsD_ZwrId, @TsD_Wartosc
       IF @@FETCH_STATUS <> 0 BREAK
       IF @TsD_Ilosc = 0  and isnull(@TsD_ZwrId,0) = 0
         BEGIN
           SELECT TOP 1
              @TrN_Bufor      = TrN_Bufor
           FROM CDN.TraNag
           JOIN CDN.TraElem ON TrN_TrNId = TrE_TrNId AND TrE_TrEId = @TsD_TrEId
           IF @TrN_Bufor = 0
              DELETE FROM CDN.TraSElemDost WHERE TsD_TsDID = @TsD_TsDID
         END
       ELSE
         BEGIN
          SELECT TOP 1
           @TrN_TrNId      = TrN_TrNId,
           @TrN_FaId       = case when TrN_TypDokumentu= 313 or  TrN_TypDokumentu= 314 then CDN.TraNagRelacjeFaId (TrN_TrNID,0,2 ) else CDN.TraNagRelacjeFaId (TrN_TrNID,0,0 ) end ,
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
           @TrN_KursM      = TrN_KursM,
           @TrE_ZwrId      = TrE_ZwrId,
           @TrE_LpPow      = TrE_LpPow,
           @TrE_TwrId      = TrE_TwrId,
           @TrE_DataOpe    = TrE_DataOpe,
           @TrE_Ilosc      = TrE_Ilosc,
           @TrE_WartoscNetto = TrE_WartoscNetto,
           @TrE_CenaT     = TrE_CenaT,
           @TrE_WyborDostaw = TrE_WyborDostaw,
           @TrE_JMPrzelicznikL = TrE_JMPrzelicznikL,
           @TrE_JMPrzelicznikM = TrE_JMPrzelicznikM,
           @TrE_Aktywny = TrE_Aktywny,
           @TrE_TypDokumentu = TrE_TypDokumentu,
     @ZaokraglajDo = case when TrE_CenaZCzteremaMiejscami = 1 then 4 else 2 end
          FROM CDN.TraNag
          JOIN CDN.TraElem ON TrN_TrNId = TrE_TrNId AND TrE_TrEId = @TsD_TrEId
          -- Kreowanie subelementów jest podejmowane tylko w uzasadnionych przypadkach
          -- Anulowane
          IF @TrE_Aktywny = 0
            CONTINUE
          -- FZ z PZ, FZKI z PZKI akceptowane trwale lub w buforze
          IF @TrN_Rodzaj IN ( 301004, 301005 ) AND @TrN_Bufor IN ( 0, 1 )
            CONTINUE
          -- FA z WZ, PA z WZ, FAKI z WZKI, PAKI z WZ, FZKI z PZ, AI, AI z PW/RW, RO z PA, RO z FA, RO z WZ akceptowane trwale, PF z FA, PF z RO
          IF @TrN_Rodzaj IN ( 302004, 305004, 302005, 305005, 301005, 311000, 311001, 308008, 308009, 308010, 320008, 320009 ) AND @TrN_Bufor IN ( 0 )
            CONTINUE
          -- ZD konwertowane do PZ/FZ
          IF @TrN_Rodzaj IN ( /*309000,*/ 309008, 309009 ) --AND @TrN_FaId IS NOT NULL
            CONTINUE
          -- FZKW, PZKW w buforze
          IF @TrN_Rodzaj IN  ( 301002, 307002, 310002, 301006, 307006 ,307003, 307011) AND @TrN_Bufor IN ( 1 )
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
          IF @TrE_TypDokumentu IN (317) AND @TrE_Aktywny = 2
          BEGIN
            UPDATE cdn.TraElem SET TrE_Aktywny = 1 WHERE TrE_TrEId = @TrE_TrEId
            SET @TrE_Aktywny = 1
          END
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
        -- FA z WZ dla elementów dodanych
        IF @TrN_Rodzaj IN ( 302004 ) AND @TrE_LpPow < 0
          SET @TrS_Typ = @TrN_TrSTyp
        -- RO, RO z PF
       IF @TrN_Rodzaj IN ( 308000, 308011 )
          SET @TrS_Typ = 3
        -- RW, WZ, WZ z FA, WZ z PA, MM, RW z AI
        IF @TrN_Rodzaj IN ( 304000, 306000, 306004, 306006, 312000,312008, 304010, 306008, 306010, 312100, 314000, 314004, 314006,304008,304006,304004 )
          SET @TrS_Typ = 2
        -- FAKI, FAKI z WZKI, PAKI, PAKI z WZKI, RWKI, WZKI  w buforze
        IF @TrN_Rodzaj IN  ( 302001, 302005, 305001, 305005, 304001, 306001, 314001, 318001 ) AND @TrN_Bufor IN ( 1 )
         SET @TrS_Typ = 4
        IF (@TrN_Rodzaj IN  ( 301001, 301005, 303001, 307001, 310001, 313001, 317001 ) AND @TrN_Bufor IN ( 1 )) or (@TrN_Rodzaj = 301051  AND @TrN_Bufor = 1  and not exists (select * from cdn.TraNag where TrN_FaId = @TrN_TrNId and TrN_Rodzaj = 307005))
          SET @TrS_Typ = 3
         END
       -- dokumenty zaakceptowane trwale
       ELSE IF @TrN_Bufor = 0
         BEGIN
        -- FZ, FZKI, FZKI z PZKI, ZD, FZ z ZD
    IF @TrN_Rodzaj IN ( 301000, 301001, 301005, 309000, 301011, 301050)  or (@TrN_Rodzaj = 301051   and not exists (select * from cdn.TraNag where TrN_FaId = @TrN_TrNId and TrN_Rodzaj = 307005))
          SET @TrS_Typ = 4
        -- PW, PWKI, PZ, PZ z FZ, PZKI, PZKI z FZKI, PZKW, PZKW z FZKW, PZ z ZD, BO, PWP, PW z AI, BOMKI, BOMKW
        IF @TrN_Rodzaj IN ( 303000, 303001, 303002, 307000, 307004, 307001, 307005, 307002, 307006, 307003, 307011, 307010, 310000, 317000, 303010, 310001, 310002, 312010, 313000, 313001, 313002, 313004, 317001 )
          SET @TrS_Typ = 1
        -- FAKI, PAKI - subelement o typie z dokumentu pierwotnego
        IF @TrN_Rodzaj IN ( 302001, 305001 )
          SET @TrS_Typ = ISNULL( ( SELECT MAX(TrS_Typ) FROM CDN.TraElem JOIN CDN.TraSElem ON TrS_TrEId = TrE_TrEId WHERE TrE_TrEId = @TrE_ZwrId ), 0 )
        -- FA, FA z WZ, PA, FA z RO, PA z RO, PF, PF z FA, PF z RO, FA z PF
        IF @TrN_Rodzaj IN ( 302000, 302006, 305000, 302008, 305008, 320000, 320008, 320009, 302009 )
          SET @TrS_Typ = @TrN_TrSTyp
       -- FA z WZ dla elementów dodanych
        IF @TrN_Rodzaj IN ( 302004 ) AND @TrE_LpPow < 0
          SET @TrS_Typ = @TrN_TrSTyp
        -- RO, FA z RO, PA z RO
        IF @TrN_Rodzaj IN ( 308000, 308011 )
          SET @TrS_Typ = 3
        -- RW, RWKI, WZ, WZKI, WZ z FA, WZ z PA, WZKI, WZKI z FAKI, WZKI z PAKI, MM, RWS, RW z AI
        IF @TrN_Rodzaj IN ( 304000, 304001,304008,304006,304004 , 306000, 306004, 306006, 306001, 306005, 306007, 312000,312008, 318000, 304010, 306008, 306010, 312100, 314000, 314001, 314004, 314006, 318001 )
          SET @TrS_Typ = 2
         END
       -- Jesli nie ustawiono prawidlowego typu - nie kreujemy subelementow
       IF @TrS_Typ NOT IN ( 1, 2, 3, 4 )
         CONTINUE
      IF @TrE_TypDokumentu = 317
          BEGIN
           SET @TrE_WartoscZakupu = ( SELECT ISNULL(SUM(PdE_WartoscZakupu),0) FROM cdn.ProdElem WHERE PdE_TrEId = @TsD_TrEId )
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
              @TrE_CenaT            = round(CASE @TsD_Ilosc WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / @TsD_Ilosc END,@ZaokraglajDo)
          END
          -- wartosci pozostalych pol
          SET @TrS_TrSId       = ( SELECT ISNULL(MAX(TrS_TrSId),0) FROM CDN.TraSElem ) + 1
          if (SELECT ISNULL(MAX(Tsd_TrSId),0) FROM CDN.TraSElemdost where tsd_treid = @TsD_TrEId) >= @TrS_TrSId
    SET @TrS_TrSId = (SELECT ISNULL(MAX(Tsd_TrSId),0) FROM CDN.TraSElemdost where tsd_treid = @TsD_TrEId)+ 1
          SET @TrS_TrEId       = @TsD_TrEId
         if  ISNULL(@TsD_TrSIdDost,0) = 0
                 SET @TrS_TrSIdDost   = NULL
          else
                 SET @TrS_TrSIdDost   = @TsD_TrSIdDost
         SET @TrS_ZwrId       = NULL
          SET @TrS_TwrId       = @TrE_TwrId
          SET @TrS_MagId       = CASE WHEN @TrN_Rodzaj <> 312010 THEN @TrE_MagId ELSE @TrN_MagDocId END
          SET @TrS_Rodzaj      = @TrN_Rodzaj
          SET @TrS_Metoda      = @Metoda
          SET @TrS_DataOpe     = @TrE_DataOpe
         SET @TrS_Ilosc       = round(@TsD_Ilosc*(@TrE_JMPrzelicznikL/@TrE_JMPrzelicznikM),4)
         SET @TrS_Wartosc     = 0
         SET @TrS_Cena        = @TrE_CenaT
         SET @TrS_Termin      = NULL
         -- dostawy
         IF @TrS_Typ = 1
           BEGIN
            SET @TrS_Wartosc = ROUND(case when @TrE_Ilosc <> 0 THEN ((@TrE_WartoscNetto/@TrE_Ilosc)*@TsD_Ilosc*(@TrE_JMPrzelicznikL/@TrE_JMPrzelicznikM)) else @TrE_WartoscNetto end ,2)
            SET @TrS_Cena    = round(case when @TrE_Ilosc <> 0 THEN @TrE_WartoscNetto / @TrE_Ilosc ELSE @TrS_Wartosc END,@ZaokraglajDo)
           END
        IF @TrS_Typ = 4 and @TrS_Rodzaj IN (304001)
           BEGIN
      select @TrS_Wartosc = ROUND( ((TrE_WartoscNetto/TrE_Ilosc)*@TsD_Ilosc*(@TrE_JMPrzelicznikL/@TrE_JMPrzelicznikM)),2) from CDN.TraElem where TrE_TrEID = @TrE_ZwrId
     select @TrS_Cena    = round(case when @TrE_Ilosc <> 0 THEN TrE_WartoscNetto / TrE_Ilosc ELSE @TrS_Wartosc END,@ZaokraglajDo) from CDN.TraElem where TrE_TrEID = @TrE_ZwrId
           END
         -- Zwykłe dostawy PZ, PZ z FZ, PW, BO, PZ z ZD, PWP, PW z AI, MM-OL
         IF @TrS_Rodzaj IN ( 307000, 307004, 303000, 310000, 307010, 317000, 303010, 312010, 313000, 313004  )
           BEGIN
            -- TrS_TrSIdDost i TrS_ZwrId
            SET @TrS_TrSIdDost  = @TrS_TrSId
            SET @TrS_ZwrId      = NULL
           END
         -- Korekty ilościowe dostaw PZKI, PZKI z FZKI, PWKI, PZKW, BOMKI, BOMKW
         IF @TrS_Rodzaj IN ( 307001, 307005, 303001, 303002, 307002, 310001, 310002, 307006, 307003, 307011, 313001, 313002, 317001 ) and @TrS_TrSIdDost   = NULL
           BEGIN
            SELECT
              @TrS_TrSIdDost  = TrS_TrSIdDost,
              @TrS_Cena       = TrS_Cena,
              @TrS_ZwrId      = TrS_TrSId
            FROM CDN.TraSElem
            WHERE TrS_TrSId = ( -- TrS_TrSId pierwotnej dostawy
                           SELECT TOP 1 A.TrS_TrSId
                           FROM CDN.TraSElem A
                             JOIN CDN.TraElem B ON B.TrE_TrEId = A.TrS_TrEId
                           WHERE B.TrE_TrEId = @TrE_ZwrId
                           )
           END
         IF @TrS_Rodzaj IN ( 307001, 307005, 303001, 303002, 307002, 310001, 310002, 307006, 307003, 307011, 313001, 313002, 317001 ) and @TrS_TrSIdDost   is NOT NULL
           BEGIN
            SELECT
              @TrS_TrSIdDost  = @TsD_TrSIdDost,
              @TrS_ZwrId      = @TsD_TrSIdDost
           END
         -- odwrotne ilosci dla korekt w buforze
         -- FAKI, FAKI z WZKI, PAKI, PAKI z WZKI, FZKI, FZKI z PZKI, PWKI, RWKI, WZKI, PZKI, BOMKI  w buforze
   IF (@TrN_Rodzaj IN  ( 302001, 302005, 305001, 305005, 301001, 301005, 303001, 304001, 306001, 307001, 310001, 313001, 314001, 318001, 317001) AND @TrN_Bufor IN ( 1 ) AND @TrS_Typ IN ( 3, 4 ) AND @TrS_Ilosc < 0 )
         or (@TrN_Rodzaj = 301051 AND @TrN_Bufor IN ( 1 ) AND @TrS_Typ IN ( 3, 4 ) AND @TrS_Ilosc < 0 and not exists (select * from cdn.TraNag where TrN_FaId = @TrN_TrNId and TrN_Rodzaj = 307005) )
           BEGIN
            SET @TrS_Ilosc = - @TsD_Ilosc
           END
         -- insert subelemntu i procedura aktualizacji wartości zakupu (subelement dodawany tylko dla towaru)
         -- odczytanie typu karty (towar/usługa) oraz typu kosztu usługi i stawki VAT dla późniejszej aktualizacji ceny zakupu
         SELECT
           @Twr_Typ            = Twr_Typ
         FROM CDN.Towary
         WHERE Twr_TwrId = @TrE_TwrId
         -- Kontrola ilosci przed dodaniem subelemntu
         IF @Twr_Typ = 1 AND (( @TrS_Typ = 1 AND @TrS_Ilosc < 0 ) OR ( @TrS_Typ = 2 AND @TrS_Ilosc > 0 ))
          BEGIN
             SELECT @ZawszeBraki = ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1536
     if (SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1970) = 1 or  (SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1776) = 1
     select @ZezwalajMimoRez = 1
   else
     select @ZezwalajMimoRez = 0
     --SELECT @ZezwalajMimoRez = ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1970
     IF  @TrE_WyborDostaw  = 1
     IF ((@TrS_Rodzaj IN (302000,302009, 305000, 306000,304000) AND @TrS_Typ = 2) and exists (select * from deleted join inserted on deleted.TsD_TSdID = inserted.TsD_TSdID and inserted.TsD_TSdID = @TsD_TSdID and deleted.TsD_ilosc >= inserted.TsD_ilosc))
    or
    ((@TrS_Rodzaj IN ( 306004,306006) AND @TrS_Typ = 2) and exists (select TrN_TrSTyp from cdn.tranag join cdn.tranagrelacje on trr_faid= trn_trnid and trr_trnid = @TrN_TrNID where TrN_TrSTyp =2))
     SET @Komunikat = CDN.TwrIlosciErr ( 1, @TrS_Typ, @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, @TrS_Ilosc, 3)
     else
            IF ((@TrS_Rodzaj IN (302008, 305008, 306008,304008,312008) AND @TrS_Typ = 2)
               OR  (@TrS_Rodzaj =306010 AND @TrS_Typ = 2 and exists(select trr_trrid from cdn.tranagrelacje where  trr_trnid = @trn_trnid and Trr_fatyp = 308 ))
      OR  (@TrS_Rodzaj =302009 AND @TrS_Typ = 2 and exists(select trr_trrid from cdn.tranagrelacje where  trr_trnid = @trn_trnid and Trr_fatyp = 308 ))
               OR  (@TrS_Rodzaj =306004 AND @TrS_Typ = 2 and exists(select trr_trrid from cdn.tranagrelacje where  trr_trnid = @trn_trnid and Trr_fatyp = 308 )))
    and not exists (select * from deleted join inserted on deleted.TsD_TSdID = inserted.TsD_TSdID and inserted.TsD_TSdID = @TsD_TSdID and deleted.TsD_ilosc < inserted.TsD_ilosc)
                IF @ZezwalajMimoRez = 1 and(@TrS_rodzaj in (306008,306010,306004,304008,312008) or (@TrS_rodzaj in (302008) AND @TrS_Typ = 2) or (@TrS_rodzaj in (302009) AND @TrS_Typ = 2)  or (@TrS_rodzaj in (305008) AND @TrS_Typ = 2))
     SET @Komunikat = CDN.TwrIlosciErr ( 1, @TrS_Typ, @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, @TrS_Ilosc, 2 )
    ELSE
                 SET @Komunikat = CDN.TwrIlosciErr ( 1, @TrS_Typ, @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, @TrS_Ilosc, 1 )
   ELSE
     SET @Komunikat = CDN.TwrIlosciErr ( 1, @TrS_Typ, @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, @TrS_Ilosc, 0)
            IF @Komunikat <> '' GOTO KOMUNIKAT
          END
    IF @Twr_Typ = 1 AND @TrS_Typ IN ( 3, 4 ) AND @TrS_Wartosc = 0
      select @TrS_Wartosc = round(@TsD_Wartosc*@TsD_Ilosc,2), @TrS_Cena = @TrS_Wartosc
    IF @DostIloscRecordowReal = 0 and ( @Twr_Typ = 1 and @TrE_WyborDostaw  = 1 and @TrS_Rodzaj IN ( 317001) and @TrE_Ilosc = 0 and @Tre_WyborDostaw = 1)
          BEGIN
            SELECT @DostIloscRecordowReal =count(A.TrS_TrSId)
             FROM cdn.TraSElem A
             JOIN cdn.TraElem B ON B.TrE_TrEId = A.TrS_TrEId
            WHERE B.TrE_TrEId = @TrE_ZwrId
          END
    IF @DostIloscRecordowReal > 1
          BEGIN
   if @DostIloscRecordow = 0
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
   if (@ResztaWartosc = -1)
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
     WHERE A.TrS_Typ = 1 AND A.TrS_TrEId = @TrE_ZwrId) AS C ON C.TrS_TrSId = A.TrS_TrSId and a.TrS_TrSIdDost = @TrS_TrSIdDost
   WHERE B.TrE_TrEId = @TrE_ZwrId AND c.roznica > 0 and a.TrS_TrSIdDost = @trs_trsiddost
   OPEN DostawyKorektaWartosci
   WHILE 1=1
   BEGIN
    FETCH NEXT FROM DostawyKorektaWartosci INTO @DostTrS_TrSId
    IF @@FETCH_STATUS <> 0 BREAK
    IF @DostIloscRecordowDodanych = @DostIloscRecordow
    SELECT
    @TrS_Wartosc    = @ResztaWartosc,
    @TrS_Cena    = round(case when @DostTrS_Ilosc <> 0 THEN ROUND(@TrE_WartoscNetto/@DostTrS_Ilosc,2) ELSE @TrE_WartoscNetto END,@ZaokraglajDo)
    FROM cdn.TraSElem
    WHERE TrS_TrSId = @DostTrS_TrSId
    ELSE
    SELECT
    @TrS_Wartosc    = ROUND( (@TrE_WartoscNetto/@DostTrS_Ilosc)*SUM(TrS_Ilosc),2),
    @TrS_Cena    = round(case when @DostTrS_Ilosc <> 0 THEN ROUND(@TrE_WartoscNetto/@DostTrS_Ilosc,2) ELSE @TrE_WartoscNetto END,@ZaokraglajDo)
    FROM cdn.TraSElem
    WHERE TrS_TrSId = @DostTrS_TrSId OR TrS_ZwrID = @DostTrS_TrSId
    SET @DostIloscRecordowDodanych = @DostIloscRecordowDodanych + 1
    SET @ResztaWartosc = @ResztaWartosc - @TrS_Wartosc
   END
   CLOSE DostawyKorektaWartosci
   DEALLOCATE DostawyKorektaWartosci
  end
         -- dodanie subelemntu (towary lub usługi gdy dokumenty rozchodowe )
        IF @Twr_Typ = 1 and @TrE_WyborDostaw  = 1--tu czy wskaz dost
           BEGIN
           EXECUTE CDN.AktualizujTraSElem @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrS_Termin, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor--, @Trs_TrSIdost = @max OUTPUT
           IF (@TrS_Typ = 1 AND @TrS_Ilosc > 0) or @TrS_Typ IN ( 3, 4 )
                SELECT @max =  @TrS_TrSId
           ELSE
                SELECT  @max= IDENT_CURRENT('cdn.traselem')
   if exists (select * from cdn.traselem where trs_trsid = @max)
         UPDATE CDN.TrasElemDost SET TsD_TrsId = @max where Tsd_TsdId = @Tsd_TsdId
            IF @TrS_Rodzaj not in (301001,302005,305005,301051)
            BEGIN
              IF NOT (@TrS_Rodzaj in (312000,312008,306001,304001,302001,305001,318001) AND @TrN_Bufor = 1)
                UPDATE CDN.TrasElemDost SET TsD_TrsIddost = case when ISNULL(TrS_TrsIdDost,0) = 0 then case when TrS_ZwrId is NULL then TsD_TrsId else TrS_ZwrId end else ISNULL(TrS_TrsIdDost,0) end FROM CDN.TrasElemDost
                  JOIN CDN.TrasElem on  TsD_TrsId = TrS_TrSId where Tsd_TsdId = @Tsd_TsdId
            END
         -- ustawiamy korekty jesli idodst sie zmienilo
   if exists (select @TsD_TrsIddost from deleted d where d.TsD_TrsIddost = @TsD_TrsIddost and @TsD_TrsIddost!= 0)
     UPDATE t set  t.TsD_ZwrId = tnew.TsD_TreId, t.TsD_TrsIddost = tnew.TsD_TrsIdDost FROM CDN.TrasElemDost t
           join deleted d on d.TsD_TrsIddost =t.TsD_TrsIddost and  d.TsD_TreId = t.TsD_ZwrId and d.TsD_TrsIddost = @TsD_TrsIddost
           join CDN.TrasElemDost tnew on d.TsD_TsDId =tnew.TsD_TsDId
   if exists (select * from cdn.traselem where trs_trsid = @max)
            INSERT INTO [CDN].[TraSElemCechy] ([TsC_TrSID],[TsC_Cecha1_DeAId] ,[TsC_Cecha1_Format] ,[TsC_Cecha1_Kod] ,[TsC_Cecha1_Wartosc] ,[TsC_Cecha2_DeAId] ,[TsC_Cecha2_Format] ,[TsC_Cecha2_Kod] ,[TsC_Cecha2_Wartosc] ,[TsC_Cecha3_DeAId] ,[TsC_Cecha3_Format]
              ,[TsC_Cecha3_Kod] ,[TsC_Cecha3_Wartosc] ,[TsC_Cecha4_DeAId] ,[TsC_Cecha4_Format] ,[TsC_Cecha4_Kod] ,[TsC_Cecha4_Wartosc] ,[TsC_Cecha5_DeAId] ,[TsC_Cecha5_Format] ,[TsC_Cecha5_Kod] ,[TsC_Cecha5_Wartosc] ,[TsC_Cecha6_DeAId]
              ,[TsC_Cecha6_Format],[TsC_Cecha6_Kod] ,[TsC_Cecha6_Wartosc] ,[TsC_Cecha7_DeAId] ,[TsC_Cecha7_Format] ,[TsC_Cecha7_Kod] ,[TsC_Cecha7_Wartosc] ,[TsC_Cecha8_DeAId] ,[TsC_Cecha8_Format] ,[TsC_Cecha8_Kod] ,[TsC_Cecha8_Wartosc]
              ,[TsC_Cecha9_DeAId] ,[TsC_Cecha9_Format] ,[TsC_Cecha9_Kod] ,[TsC_Cecha9_Wartosc] ,[TsC_Cecha10_DeAId] ,[TsC_Cecha10_Format] ,[TsC_Cecha10_Kod] ,[TsC_Cecha10_Wartosc])
            SELECT @max, @TsD_Cecha1_DeAId,  @TsD_Cecha1_Format, @TsD_Cecha1_Kod,  @TsD_Cecha1_Wartosc,  @TsD_Cecha2_DeAId,  @TsD_Cecha2_Format, @TsD_Cecha2_Kod,  @TsD_Cecha2_Wartosc,  @TsD_Cecha3_DeAId,  @TsD_Cecha3_Format, @TsD_Cecha3_Kod,  @TsD_Cecha3_Wartosc,
              @TsD_Cecha4_DeAId, @TsD_Cecha4_Format, @TsD_Cecha4_Kod,  @TsD_Cecha4_Wartosc,  @TsD_Cecha5_DeAId,  @TsD_Cecha5_Format, @TsD_Cecha5_Kod,  @TsD_Cecha5_Wartosc,  @TsD_Cecha6_DeAId,  @TsD_Cecha6_Format, @TsD_Cecha6_Kod,  @TsD_Cecha6_Wartosc,
              @TsD_Cecha7_DeAId, @TsD_Cecha7_Format, @TsD_Cecha7_Kod,  @TsD_Cecha7_Wartosc,  @TsD_Cecha8_DeAId,  @TsD_Cecha8_Format, @TsD_Cecha8_Kod,  @TsD_Cecha8_Wartosc,  @TsD_Cecha9_DeAId,  @TsD_Cecha9_Format, @TsD_Cecha9_Kod,  @TsD_Cecha9_Wartosc,
              @TsD_Cecha10_DeAId, @TsD_Cecha10_Format, @TsD_Cecha10_Kod,  @TsD_Cecha10_Wartosc
            UPDATE CDN.TrasElem SET TrS_WyborDostaw  = 1 WHERE TrS_TrEId = @TrS_TrEId and TrS_WyborDostaw != 1
            -- Update wartości i cen elementu dla dokumentów wewnętrznych
            IF @TrE_TypDokumentu IN ( 304, 312, 318 ) AND @TrN_Rodzaj NOT IN ( 312010 )
             BEGIN
               SET @TrE_WartoscZakupu = ( SELECT TrE_WartoscZakupu FROM cdn.TraElem WHERE TrE_TrEId = @TrS_TrEId )
               UPDATE CDN.TrasElem SET TrS_WyborDostaw  = 2 WHERE TrS_TrEId = @TrS_TrEId
               UPDATE cdn.TraElem SET
                 TrE_WartoscNetto     = @TrE_WartoscZakupu,
                 TrE_WartoscBrutto    = ROUND(@TrE_WartoscZakupu * ( ( 100 + TrE_Stawka ) / 100 ), 2 ),
                 TrE_WartoscNettoWal  = @TrE_WartoscZakupu,
                 TrE_WartoscBruttoWal = ROUND(@TrE_WartoscZakupu * ( ( 100 + TrE_Stawka ) / 100 ), 2 ),
                 TrE_Rabat            = 0,
                 TrE_CenaT            = Round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END,@ZaokraglajDo),
                 TrE_CenaW            = Round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END,@ZaokraglajDo) ,
                 TrE_Cena0            = Round(CASE TrE_Ilosc   WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_Ilosc   END,@ZaokraglajDo) ,
                 TrE_CenaWWD          = Round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END,@ZaokraglajDo),
                 TrE_Cena0WD          = Round(CASE TrE_Ilosc   WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_Ilosc   END,@ZaokraglajDo)
                 --TrE_Waluta           = @WalutaSys,
                 --TrE_KursNumer        = 0,
                 --TrE_KursL            = 1,
                 --TrE_KursM            = 1
               WHERE TrE_TrEId = @TrS_TrEId
               UPDATE CDN.TrasElem SET TrS_WyborDostaw  = 1 WHERE TrS_TrEId = @TrS_TrEId and TrS_WyborDostaw != 1
          END
    END
   END
  END
   CLOSE Dodawane
    DEALLOCATE Dodawane
  END
  DECLARE EKI CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrE_TrEId, TrE_TwrId, TrE_DataOpe, TrE_TwrKod,TrE_TwrNazwa
      FROM (
             SELECT TrE_TrEId , TrE_TwrId, TrE_DataOpe, TrE_TwrKod,TrE_TwrNazwa
             FROM deleted
             join CDN.TraElem on TrE_TrEId = TsD_TrEID
             where Tre_WyborDostaw = 1 and TsD_PdEId = 0 --tu czy wskaz dost
             UNION ALL
             SELECT TrE_TrEId , TrE_TwrId, TrE_DataOpe, TrE_TwrKod,TrE_TwrNazwa
             FROM inserted
             join CDN.TraElem on TrE_TrEId = TsD_TrEID
             where Tre_WyborDostaw = 1 and TsD_PdEId = 0 --tu czy wskaz dost
           ) AS TrE_ERR
      GROUP BY TrE_TrEId, TrE_TwrId, TrE_DataOpe, TrE_TwrKod,TrE_TwrNazwa
    OPEN EKI
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM EKI INTO @TrE_TrEId, @TrE_TwrId, @TrE_DataOpe, @TrE_TwrKod, @TrE_TwrNazwa
        IF @@FETCH_STATUS <> 0 BREAK
        SET @Komunikat = CDN.TwrZasobyErr ( @TrE_TrEId, @TrE_TwrId, @TrE_TwrKod,@TrE_TwrNazwa, @TrE_DataOpe )
        IF @Komunikat <> '' GOTO KOMUNIKAT
      END
    CLOSE EKI
  DEALLOCATE EKI
--pwp/rws
 IF @Metoda in( 1,2) and @QUAN = 0
    BEGIN
      -- elementy kasowane
      DECLARE @TrSSkladniki TABLE ( TrSId INT, TrEId INT )
      INSERT INTO @TrSSkladniki ( TrSId, TrEId ) SELECT TsD_TrSId, PdE_TrEIdRWS FROM deleted join cdn.prodelem on TsD_PdEId = PdE_PdEId  where TsD_PdEId > 0
      DELETE cdn.TraSElem FROM cdn.TraSElem JOIN @TrSSkladniki ON TrSId = TrS_TrSId AND  TrS_TrEId = TrEId-- WHERE TrS_TrEId IN ( SELECT TrE_TrEId FROM deleted ) -- = @TrE_TrEId
      -- elementy dodawane
      DECLARE Dodawane CURSOR LOCAL FAST_FORWARD FOR
      SELECT  [TsD_TsDID],[TsD_TrSID] ,PdE_TrEIdRWS ,[TsD_TrSIdDost] ,[TsD_NumerPelny] ,[TsD_NumerObcy] ,[TsD_DataOpe] ,[TsD_Dostawca] ,[TsD_Ilosc] ,[TsD_IloscDostepna]
              ,[TsD_Cecha1_DeAId] ,[TsD_Cecha1_Format] ,[TsD_Cecha1_Kod] ,[TsD_Cecha1_Wartosc] ,[TsD_Cecha2_DeAId] ,[TsD_Cecha2_Format] ,[TsD_Cecha2_Kod]
              ,[TsD_Cecha2_Wartosc] ,[TsD_Cecha3_DeAId] ,[TsD_Cecha3_Format] ,[TsD_Cecha3_Kod] ,[TsD_Cecha3_Wartosc] ,[TsD_Cecha4_DeAId] ,[TsD_Cecha4_Format]
              ,[TsD_Cecha4_Kod] ,[TsD_Cecha4_Wartosc] ,[TsD_Cecha5_DeAId] ,[TsD_Cecha5_Format] ,[TsD_Cecha5_Kod] ,[TsD_Cecha5_Wartosc] ,[TsD_Cecha6_DeAId]
              ,[TsD_Cecha6_Format] ,[TsD_Cecha6_Kod] ,[TsD_Cecha6_Wartosc] ,[TsD_Cecha7_DeAId] ,[TsD_Cecha7_Format] ,[TsD_Cecha7_Kod] ,[TsD_Cecha7_Wartosc]
              ,[TsD_Cecha8_DeAId] ,[TsD_Cecha8_Format] ,[TsD_Cecha8_Kod] ,[TsD_Cecha8_Wartosc] ,[TsD_Cecha9_DeAId] ,[TsD_Cecha9_Format] ,[TsD_Cecha9_Kod]
              ,[TsD_Cecha9_Wartosc] ,[TsD_Cecha10_DeAId] ,[TsD_Cecha10_Format] ,[TsD_Cecha10_Kod] ,[TsD_Cecha10_Wartosc],PdE_magid, TsD_ZwrId, TsD_Wartosc, TsD_TrEID
      FROM inserted
      join cdn.prodelem on TsD_PdEId = PdE_PdEId
   where TsD_PdEId > 0
      ORDER BY PdE_TrEIdRWS, TsD_TrSId, TsD_TsDId
      OPEN Dodawane
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM Dodawane INTO @TsD_TsDID, @TsD_TrSID, @TsD_TrEId, @TsD_TrSIdDost, @TsD_NumerPelny, @TsD_NumerObcy, @TsD_DataOpe,
               @TsD_Dostawca, @TsD_Ilosc, @TsD_IloscDostepna, @TsD_Cecha1_DeAId, @TsD_Cecha1_Format, @TsD_Cecha1_Kod,
               @TsD_Cecha1_Wartosc, @TsD_Cecha2_DeAId, @TsD_Cecha2_Format, @TsD_Cecha2_Kod, @TsD_Cecha2_Wartosc, @TsD_Cecha3_DeAId ,
               @TsD_Cecha3_Format, @TsD_Cecha3_Kod, @TsD_Cecha3_Wartosc, @TsD_Cecha4_DeAId, @TsD_Cecha4_Format, @TsD_Cecha4_Kod,
               @TsD_Cecha4_Wartosc, @TsD_Cecha5_DeAId, @TsD_Cecha5_Format, @TsD_Cecha5_Kod, @TsD_Cecha5_Wartosc, @TsD_Cecha6_DeAId,
               @TsD_Cecha6_Format, @TsD_Cecha6_Kod, @TsD_Cecha6_Wartosc, @TsD_Cecha7_DeAId, @TsD_Cecha7_Format, @TsD_Cecha7_Kod,
               @TsD_Cecha7_Wartosc, @TsD_Cecha8_DeAId, @TsD_Cecha8_Format, @TsD_Cecha8_Kod, @TsD_Cecha8_Wartosc, @TsD_Cecha9_DeAId,
               @TsD_Cecha9_Format, @TsD_Cecha9_Kod, @TsD_Cecha9_Wartosc, @TsD_Cecha10_DeAId, @TsD_Cecha10_Format, @TsD_Cecha10_Kod ,
               @TsD_Cecha10_Wartosc,@tre_magid, @tsd_zwrid, @TsD_Wartosc, @TsD_TrEIdPWP
       IF @@FETCH_STATUS <> 0 BREAK
       IF @TsD_Ilosc = 0 and isnull(@TsD_ZwrId,0) = 0
         BEGIN
           SELECT TOP 1
              @TrN_Bufor      = TrN_Bufor
           FROM CDN.TraNag
           JOIN CDN.TraElem ON TrN_TrNId = TrE_TrNId AND TrE_TrEId = @TsD_TrEId
           IF @TrN_Bufor = 0
              DELETE FROM CDN.TraSElemDost WHERE TsD_TsDID = @TsD_TsDID
         END
       ELSE
         BEGIN
          SELECT TOP 1
           @TrN_TrNId      = TrN_TrNId,
           @TrN_FaId       = CDN.TraNagRelacjeFaId (TrN_TrNID,0,0 ),
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
           @TrN_KursM      = TrN_KursM,
           @TrE_ZwrId      = TrE_ZwrId,
           @TrE_LpPow      = TrE_LpPow,
           @TrE_TwrId      = TrE_TwrId,
           @TrE_DataOpe    = TrE_DataOpe,
           @TrE_Ilosc      = TrE_Ilosc,
           @TrE_WartoscNetto = TrE_WartoscNetto,
           @TrE_CenaT     = TrE_CenaT,
           @TrE_WyborDostaw = TrE_WyborDostaw,
           @TrE_JMPrzelicznikL = TrE_JMPrzelicznikL,
           @TrE_JMPrzelicznikM = TrE_JMPrzelicznikM,
           @TrE_Aktywny = TrE_Aktywny,
           @TrE_TypDokumentu = TrE_TypDokumentu,
           @ZaokraglajDo = case when TrE_CenaZCzteremaMiejscami = 1 then 4 else 2 end
          FROM CDN.TraNag
          JOIN CDN.TraElem ON TrN_TrNId = TrE_TrNId AND TrE_TrEId = @TsD_TrEId
    --date trzeba pobrac z PWP a nie z RWS bo rws zapisywany pozniej
           SELECT TOP 1 @TrE_DataOpe    = TrE_DataDok from cdn.traelem where tre_treid = @TsD_TrEIdPWP
          -- Kreowanie subelementów jest podejmowane tylko w uzasadnionych przypadkach
          -- Anulowane
          IF @TrE_Aktywny = 0
            CONTINUE
          -- FA z WZ, PA z WZ, FAKI z WZKI, PAKI z WZ, FZKI z PZ, AI, AI z PW/RW, RO z PA, RO z FA, RO z WZ akceptowane trwale, PF z FA, PF z RO
          -- zainicjowanie typu
         SET @TrS_Typ        = -1
         -- dokumenty w buforze
         IF @TrN_Bufor = 1
           BEGIN
        IF @TrN_Rodzaj IN (318000 )
          SET @TrS_Typ = @TrN_TrSTyp
        -- FAKI, FAKI z WZKI, PAKI, PAKI z WZKI, RWKI, WZKI  w buforze
        IF @TrN_Rodzaj IN  ( 318001 ) AND @TrN_Bufor IN ( 1 )
         SET @TrS_Typ = 4
    IF @TrN_Rodzaj IN  ( 318001 ) AND @TrN_Bufor IN ( 1 ) AND @TrE_Ilosc > 0
              BEGIN
                DECLARE @TrN_TrSTyp_Pierw INT
                -- dla nie RWSK z dokumentu pierwotnego
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
         END
       -- dokumenty zaakceptowane trwale
       ELSE IF @TrN_Bufor = 0
         BEGIN
        -- RW, RWKI, WZ, WZKI, WZ z FA, WZ z PA, WZKI, WZKI z FAKI, WZKI z PAKI, MM, RWS, RW z AI
        IF @TrN_Rodzaj IN ( 318000 , 318001)
          SET @TrS_Typ = 2
         END
       -- Jesli nie ustawiono prawidlowego typu - nie kreujemy subelementow
       IF @TrS_Typ NOT IN ( 1, 2, 3, 4 )
         CONTINUE
          -- wartosci pozostalych pol
          SET @TrS_TrSId       = ( SELECT ISNULL(MAX(TrS_TrSId),0) FROM CDN.TraSElem ) + 1
          if (SELECT ISNULL(MAX(Tsd_TrSId),0) FROM CDN.TraSElemdost where tsd_treid = @TsD_TrEId) >= @TrS_TrSId
    SET @TrS_TrSId = (SELECT ISNULL(MAX(Tsd_TrSId),0) FROM CDN.TraSElemdost where tsd_treid = @TsD_TrEId)+ 1
          SET @TrS_TrEId       = @TsD_TrEId
         if  ISNULL(@TsD_TrSIdDost,0) = 0
                 SET @TrS_TrSIdDost   = NULL
          else
                 SET @TrS_TrSIdDost   = @TsD_TrSIdDost
         SET @TrS_ZwrId       = NULL
          SET @TrS_TwrId       = @TrE_TwrId
          SET @TrS_MagId       = CASE WHEN @TrN_Rodzaj <> 312010 THEN @TrE_MagId ELSE @TrN_MagDocId END
          SET @TrS_Rodzaj      = @TrN_Rodzaj
          SET @TrS_Metoda      = @Metoda
          SET @TrS_DataOpe     = @TrE_DataOpe
         SET @TrS_Ilosc       = round(@TsD_Ilosc*(@TrE_JMPrzelicznikL/@TrE_JMPrzelicznikM),4)
         SET @TrS_Wartosc     = 0
         SET @TrS_Cena        = @TrE_CenaT
         SET @TrS_Termin      = NULL
         -- dostawy
         IF @TrS_Typ = 1
           BEGIN
            SET @TrS_Wartosc = ROUND(case when @TrE_Ilosc <> 0 THEN ((@TrE_WartoscNetto/@TrE_Ilosc)*@TsD_Ilosc*(@TrE_JMPrzelicznikL/@TrE_JMPrzelicznikM)) else @TrE_WartoscNetto end ,2)
            SET @TrS_Cena    = round(case when @TrE_Ilosc <> 0 THEN @TrE_WartoscNetto / @TrE_Ilosc ELSE @TrS_Wartosc END,@ZaokraglajDo)
           END
        IF @TrS_Typ = 4 and @TrS_Rodzaj IN (304001)
           BEGIN
      select @TrS_Wartosc = ROUND( ((TrE_WartoscNetto/TrE_Ilosc)*@TsD_Ilosc*(@TrE_JMPrzelicznikL/@TrE_JMPrzelicznikM)),2) from CDN.TraElem where TrE_TrEID = @TrE_ZwrId
     select @TrS_Cena    = round(case when @TrE_Ilosc <> 0 THEN TrE_WartoscNetto / TrE_Ilosc ELSE @TrS_Wartosc END,@ZaokraglajDo) from CDN.TraElem where TrE_TrEID = @TrE_ZwrId
           END
         -- odwrotne ilosci dla korekt w buforze
         -- FAKI, FAKI z WZKI, PAKI, PAKI z WZKI, FZKI, FZKI z PZKI, PWKI, RWKI, WZKI, PZKI, BOMKI  w buforze
   IF (@TrN_Rodzaj IN  (  318001) AND @TrN_Bufor IN ( 1 ) AND @TrS_Typ IN ( 3, 4 ) AND @TrS_Ilosc < 0 )
            BEGIN
            SET @TrS_Ilosc = - @TsD_Ilosc
           END
         -- insert subelemntu i procedura aktualizacji wartości zakupu (subelement dodawany tylko dla towaru)
         -- odczytanie typu karty (towar/usługa) oraz typu kosztu usługi i stawki VAT dla późniejszej aktualizacji ceny zakupu
         SELECT
           @Twr_Typ            = Twr_Typ
         FROM CDN.Towary
         WHERE Twr_TwrId = @TrE_TwrId
         -- Kontrola ilosci przed dodaniem subelemntu
         IF @Twr_Typ = 1 AND (( @TrS_Typ = 1 AND @TrS_Ilosc < 0 ) OR ( @TrS_Typ = 2 AND @TrS_Ilosc > 0 ))
          BEGIN
             SELECT @ZawszeBraki = ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1536
         if (SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1970) = 1 or  (SELECT ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1776) = 1
            select @ZezwalajMimoRez = 1
         else
            select @ZezwalajMimoRez = 0
     --SELECT @ZezwalajMimoRez = ISNULL(MAX(Fir_Wartosc),0) FROM cdn.Firma WHERE Fir_Numer = 1970
     IF  @TrE_WyborDostaw  = 1
        SET @Komunikat = CDN.TwrIlosciErr ( 1, @TrS_Typ, @TrS_TwrId, @TrS_MagId, @TrS_DataOpe, @TrS_Ilosc, 0)
            IF @Komunikat <> '' GOTO KOMUNIKAT
          END
        IF @Twr_Typ = 1 AND @TrS_Typ IN ( 3, 4 ) AND @TrS_Wartosc = 0
            select @TrS_Wartosc = round(@TsD_Wartosc*@TsD_Ilosc,2), @TrS_Cena = @TrS_Wartosc
         -- dodanie subelemntu (towary lub usługi gdy dokumenty rozchodowe )
         IF @Twr_Typ = 1 and @TrE_WyborDostaw  = 1--tu czy wskaz dost
           BEGIN
           EXECUTE CDN.AktualizujTraSElem @TrS_TrSId, @TrS_TrEId, @TrS_TrSIdDost, @TrS_ZwrId, @TrS_TwrId, @TrS_MagId, @TrS_Rodzaj, @TrS_Typ, @TrS_Metoda, @TrS_DataOpe, @TrS_Ilosc, @TrS_Wartosc, @TrS_Cena, @TrS_Termin, @TrE_ZwrId, @TrN_TrNId, @TrN_MagDocId, @TrN_Bufor--, @Trs_TrSIdost = @max OUTPUT
           IF (@TrS_Typ = 1 AND @TrS_Ilosc > 0) or @TrS_Typ IN ( 3, 4 )
                SELECT @max =  @TrS_TrSId
           ELSE
                SELECT  @max= IDENT_CURRENT('cdn.traselem')
         if exists (select * from cdn.traselem where trs_trsid = @max)
         UPDATE CDN.TrasElemDost SET TsD_TrsId = @max where Tsd_TsdId = @Tsd_TsdId
            IF @TrS_Rodzaj not in (301001,302005,305005,301051)
            BEGIN
              IF NOT (@TrS_Rodzaj in (312000,312008,306001,304001,302001,305001,318001) AND @TrN_Bufor = 1)
                UPDATE CDN.TrasElemDost SET TsD_TrsIddost = case when ISNULL(TrS_TrsIdDost,0) = 0 then case when TrS_ZwrId is NULL then TsD_TrsId else TrS_ZwrId end else ISNULL(TrS_TrsIdDost,0) end FROM CDN.TrasElemDost
                  JOIN CDN.TrasElem on  TsD_TrsId = TrS_TrSId where Tsd_TsdId = @Tsd_TsdId
            END
         -- ustawiamy korekty jesli idodst sie zmienilo
   if exists (select @TsD_TrsIddost from deleted d where d.TsD_TrsIddost = @TsD_TrsIddost and @TsD_TrsIddost!= 0)
     UPDATE t set  t.TsD_ZwrId = tnew.TsD_TreId, t.TsD_TrsIddost = tnew.TsD_TrsIdDost FROM CDN.TrasElemDost t
           join deleted d on d.TsD_TrsIddost =t.TsD_TrsIddost and  d.TsD_TreId = t.TsD_ZwrId and d.TsD_TrsIddost = @TsD_TrsIddost
           join CDN.TrasElemDost tnew on d.TsD_TsDId =tnew.TsD_TsDId
   if exists (select * from cdn.traselem where trs_trsid = @max)
            INSERT INTO [CDN].[TraSElemCechy] ([TsC_TrSID],[TsC_Cecha1_DeAId] ,[TsC_Cecha1_Format] ,[TsC_Cecha1_Kod] ,[TsC_Cecha1_Wartosc] ,[TsC_Cecha2_DeAId] ,[TsC_Cecha2_Format] ,[TsC_Cecha2_Kod] ,[TsC_Cecha2_Wartosc] ,[TsC_Cecha3_DeAId] ,[TsC_Cecha3_Format]
              ,[TsC_Cecha3_Kod] ,[TsC_Cecha3_Wartosc] ,[TsC_Cecha4_DeAId] ,[TsC_Cecha4_Format] ,[TsC_Cecha4_Kod] ,[TsC_Cecha4_Wartosc] ,[TsC_Cecha5_DeAId] ,[TsC_Cecha5_Format] ,[TsC_Cecha5_Kod] ,[TsC_Cecha5_Wartosc] ,[TsC_Cecha6_DeAId]
              ,[TsC_Cecha6_Format],[TsC_Cecha6_Kod] ,[TsC_Cecha6_Wartosc] ,[TsC_Cecha7_DeAId] ,[TsC_Cecha7_Format] ,[TsC_Cecha7_Kod] ,[TsC_Cecha7_Wartosc] ,[TsC_Cecha8_DeAId] ,[TsC_Cecha8_Format] ,[TsC_Cecha8_Kod] ,[TsC_Cecha8_Wartosc]
              ,[TsC_Cecha9_DeAId] ,[TsC_Cecha9_Format] ,[TsC_Cecha9_Kod] ,[TsC_Cecha9_Wartosc] ,[TsC_Cecha10_DeAId] ,[TsC_Cecha10_Format] ,[TsC_Cecha10_Kod] ,[TsC_Cecha10_Wartosc])
            SELECT @max, @TsD_Cecha1_DeAId,  @TsD_Cecha1_Format, @TsD_Cecha1_Kod,  @TsD_Cecha1_Wartosc,  @TsD_Cecha2_DeAId,  @TsD_Cecha2_Format, @TsD_Cecha2_Kod,  @TsD_Cecha2_Wartosc,  @TsD_Cecha3_DeAId,  @TsD_Cecha3_Format, @TsD_Cecha3_Kod,  @TsD_Cecha3_Wartosc,
              @TsD_Cecha4_DeAId, @TsD_Cecha4_Format, @TsD_Cecha4_Kod,  @TsD_Cecha4_Wartosc,  @TsD_Cecha5_DeAId,  @TsD_Cecha5_Format, @TsD_Cecha5_Kod,  @TsD_Cecha5_Wartosc,  @TsD_Cecha6_DeAId,  @TsD_Cecha6_Format, @TsD_Cecha6_Kod,  @TsD_Cecha6_Wartosc,
              @TsD_Cecha7_DeAId, @TsD_Cecha7_Format, @TsD_Cecha7_Kod,  @TsD_Cecha7_Wartosc,  @TsD_Cecha8_DeAId,  @TsD_Cecha8_Format, @TsD_Cecha8_Kod,  @TsD_Cecha8_Wartosc,  @TsD_Cecha9_DeAId,  @TsD_Cecha9_Format, @TsD_Cecha9_Kod,  @TsD_Cecha9_Wartosc,
              @TsD_Cecha10_DeAId, @TsD_Cecha10_Format, @TsD_Cecha10_Kod,  @TsD_Cecha10_Wartosc
            UPDATE CDN.TrasElem SET TrS_WyborDostaw  = 1 WHERE TrS_TrEId = @TrS_TrEId and TrS_WyborDostaw != 1
            -- Update wartości i cen elementu dla dokumentów wewnętrznych
            IF @TrE_TypDokumentu IN ( 304, 312, 318 ) AND @TrN_Rodzaj NOT IN ( 312010 )
             BEGIN
               SET @TrE_WartoscZakupu = ( SELECT TrE_WartoscZakupu FROM cdn.TraElem WHERE TrE_TrEId = @TrS_TrEId )
               UPDATE CDN.TrasElem SET TrS_WyborDostaw  = 2 WHERE TrS_TrEId = @TrS_TrEId
               UPDATE cdn.TraElem SET
                 TrE_WartoscNetto     = @TrE_WartoscZakupu,
                 TrE_WartoscBrutto    = ROUND(@TrE_WartoscZakupu * ( ( 100 + TrE_Stawka ) / 100 ), 2 ),
                 TrE_WartoscNettoWal  = @TrE_WartoscZakupu,
                 TrE_WartoscBruttoWal = ROUND(@TrE_WartoscZakupu * ( ( 100 + TrE_Stawka ) / 100 ), 2 ),
                 TrE_Rabat            = 0,
                 TrE_CenaT            = Round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END,@ZaokraglajDo),
                 TrE_CenaW            = Round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END,@ZaokraglajDo) ,
                 TrE_Cena0            = Round(CASE TrE_Ilosc   WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_Ilosc   END,@ZaokraglajDo) ,
                 TrE_CenaWWD          = Round(CASE TrE_IloscJM WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_IloscJM END,@ZaokraglajDo),
                 TrE_Cena0WD          = Round(CASE TrE_Ilosc   WHEN 0 THEN 0 ELSE @TrE_WartoscZakupu / TrE_Ilosc   END,@ZaokraglajDo)
                 --TrE_Waluta           = @WalutaSys,
                 --TrE_KursNumer        = 0,
                 --TrE_KursL            = 1,
                 --TrE_KursM            = 1
               WHERE TrE_TrEId = @TrS_TrEId
               UPDATE CDN.TrasElem SET TrS_WyborDostaw  = 1 WHERE TrS_TrEId = @TrS_TrEId and TrS_WyborDostaw != 1
          END
    END
   END
  END
   CLOSE Dodawane
    DEALLOCATE Dodawane
  END
  DECLARE EKI CURSOR LOCAL FAST_FORWARD FOR
    SELECT TrE_TrEId, TrE_TwrId, TrE_DataOpe, TrE_TwrKod,TrE_TwrNazwa
      FROM (
             SELECT TrE_TrEId , TrE_TwrId, TrE_DataOpe, TrE_TwrKod,TrE_TwrNazwa
             FROM deleted
    join cdn.prodelem on TsD_PdEId = PdE_PdEId
             join CDN.TraElem on TrE_TrEId = PdE_TrEIdRWS
             where Tre_WyborDostaw = 1 and TsD_PdEId > 0--tu czy wskaz dost
             UNION ALL
             SELECT TrE_TrEId , TrE_TwrId, TrE_DataOpe, TrE_TwrKod,TrE_TwrNazwa
             FROM inserted
    join cdn.prodelem on TsD_PdEId = PdE_PdEId
             join CDN.TraElem on TrE_TrEId = PdE_TrEIdRWS
             where Tre_WyborDostaw = 1 and TsD_PdEId > 0 --tu czy wskaz dost
           ) AS TrE_ERR
      GROUP BY TrE_TrEId, TrE_TwrId, TrE_DataOpe, TrE_TwrKod,TrE_TwrNazwa
    OPEN EKI
      WHILE 1=1
      BEGIN
        FETCH NEXT FROM EKI INTO @TrE_TrEId, @TrE_TwrId, @TrE_DataOpe, @TrE_TwrKod, @TrE_TwrNazwa
        IF @@FETCH_STATUS <> 0 BREAK
        SET @Komunikat = CDN.TwrZasobyErr ( @TrE_TrEId, @TrE_TwrId, @TrE_TwrKod,@TrE_TwrNazwa, @TrE_DataOpe )
        IF @Komunikat <> '' GOTO KOMUNIKAT
      END
    CLOSE EKI
  DEALLOCATE EKI
--pwp/rws
  -- Wyswietlenie komunikatu i rollback całej transakcji
  KOMUNIKAT:
  IF @Komunikat <> ''
    BEGIN
      RAISERROR( @Komunikat, 16, 1 )
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
