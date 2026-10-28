CREATE TABLE [CDN].[PlikiJPK] (
    [JPK_JPKID]                   INT             IDENTITY (1, 1) NOT NULL,
    [JPK_KodOsoby]                NVARCHAR (254)  NULL,
    [JPK_Typ]                     NVARCHAR (254)  NOT NULL,
    [JPK_Nazwa]                   NVARCHAR (254)  NOT NULL,
    [JPK_DataUtworzenia]          DATETIME        NOT NULL,
    [JPK_XML]                     VARBINARY (MAX) NULL,
    [JPK_RefNr]                   NVARCHAR (254)  NULL,
    [JPK_Path]                    NVARCHAR (254)  NOT NULL,
    [JPK_Status]                  INT             NULL,
    [JPK_StatusOpis]              NVARCHAR (1000) NULL,
    [JPK_KodUrzedu]               NVARCHAR (254)  NULL,
    [JPK_DataWyslania]            NVARCHAR (254)  NULL,
    [JPK_DataWplyniecia]          NVARCHAR (254)  NULL,
    [JPK_KodOsobyOdbierajacej]    NVARCHAR (254)  NULL,
    [JPK_DataOdebrania]           NVARCHAR (254)  NULL,
    [JPK_SkrotDokumentu]          NVARCHAR (240)  NULL,
    [JPK_SkrotStruktury]          NVARCHAR (240)  NULL,
    [JPK_StrukturaLogiczna]       NVARCHAR (240)  NULL,
    [JPK_StempelCzasu]            NVARCHAR (240)  NULL,
    [JPK_SigningTime]             NVARCHAR (50)   NULL,
    [JPK_NazwaPodmiotu]           NVARCHAR (254)  NULL,
    [JPK_NIP1]                    NVARCHAR (20)   NULL,
    [JPK_StatusCode]              INT             NULL,
    [JPK_OkresOd]                 DATETIME        NULL,
    [JPK_OkresDo]                 DATETIME        NULL,
    [JPK_JPKScaID]                INT             NULL,
    [JPK_CelZlozenia]             INT             CONSTRAINT [DF_JPK_CelZlozenia] DEFAULT ((0)) NOT NULL,
    [JPK_WariantFormularza]       INT             CONSTRAINT [DF_JPK_WariantFormularza] DEFAULT ((1)) NOT NULL,
    [JPK_RodzajWysylki]           INT             CONSTRAINT [DF_JPK_RodzajWysylki] DEFAULT ((2)) NOT NULL,
    [JPK_PodpisanyXML]            VARBINARY (MAX) NULL,
    [JPK_SciezkaPodpisanegoPliku] NVARCHAR (254)  NULL,
    [JPK_TypWysylki]              INT             CONSTRAINT [DF_JPK_TypWysylki] DEFAULT ((-1)) NOT NULL,
    [JPK_DkNID]                   INT             NULL,
    [JPK_JpkNagId]                INT             NULL,
    [JPK_SourceJpkId]             INT             NULL,
    [JPK_Mode]                    INT             NULL,
    CONSTRAINT [JPK_Primary] PRIMARY KEY CLUSTERED ([JPK_JPKID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PlikiJPK2DeklNag] FOREIGN KEY ([JPK_DkNID]) REFERENCES [CDN].[DeklNag] ([DkN_DkNID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [JPKPath]
    ON [CDN].[PlikiJPK]([JPK_Path] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER [CDN].[RO_PlikiJPK_InsertUpdateDelete_Trigger]
  ON [CDN].[PlikiJPK]
  FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
  DECLARE
  @JPK_JPKID INT,
  @JPK_Nazwa NVARCHAR(254),
  @JPK_Status INT,
  @JPK_StatusCode INT,
  @JPK_Typ NVARCHAR(254),
  @JPK_DkNID INT
  DECLARE
  @TypOperacji INT,
  @TypObiektu INT
  DECLARE Dodane Cursor Local Fast_Forward For
  SELECT
  JPK_JPKID,
  JPK_Nazwa,
  JPK_Status,
  JPK_StatusCode,
  JPK_Typ,
  JPK_DkNID
  FROM inserted
  Open Dodane
  While 1=1
  BEGIN
   Fetch Next From Dodane Into
   @JPK_JPKID,
   @JPK_Nazwa,
   @JPK_Status,
   @JPK_StatusCode,
   @JPK_Typ,
   @JPK_DkNID
   IF @@Fetch_Status <> 0 Break
   SET @TypObiektu = CASE WHEN @JPK_Typ IN ('JPK_V7M', 'JPK_V7K') THEN 2001 ELSE 2000 END
   IF EXISTS(select * from deleted where deleted.JPK_JPKID = @JPK_JPKID)
  BEGIN
   IF((select ISNULL(JPK_Status, 0) FROM deleted WHERE deleted.JPK_JPKID = @JPK_JPKID) <> 2 AND @JPK_Status = 2) -- czy wyslany
    BEGIN
     SET @TypOperacji = 106
    END
   ELSE IF(UPDATE(JPK_Status) AND @JPK_Status = 3 OR @JPK_Status = 2) -- czy upo
    BEGIN
     IF(@JPK_StatusCode = 200)
      BEGIN
       SET @TypOperacji = 121
      END
     ELSE IF(@JPK_StatusCode = 300 OR @JPK_StatusCode >= 400)
      BEGIN
       SET @TypOperacji = 126
      END
     ELSE
      CONTINUE
    END
   ELSE IF(UPDATE(JPK_JPKScaID)) -- czy scalony / zmodyfikowany
    BEGIN
     SET @TypOperacji = 2
    END
   ELSE -- podpis ePUAP itd.
    CONTINUE
  END
  ELSE -- dodany
  SET @TypOperacji = 1
 IF(@TypObiektu = 2001 AND @JPK_DkNID IS NOT NULL AND @TypOperacji IN (106, 121, 126))
 BEGIN
  DECLARE
  @Wersja INT,
  @TypDeklar INT,
  @Nazwa NVARCHAR(254)
  SELECT @TypDeklar = 30000 + DkN_TypDeklar, @Wersja = DkN_Wersja, @Nazwa = CDN.DeklNumer(DkN_DkNID) FROM CDN.DeklNag WHERE DkN_DkNID = @JPK_DkNID
  EXEC CDN.RejestrOperacjiDodaj @TypDeklar, @Wersja, @JPK_DkNID, @Nazwa, @TypOperacji, ''
 END
 EXEC CDN.RejestrOperacjiDodaj @TypObiektu, 0, @JPK_JPKID, @JPK_Nazwa, @TypOperacji, ''
  END
  DECLARE Usuniete Cursor Local Fast_Forward For
  SELECT
  JPK_JPKID,
  JPK_Nazwa,
  JPK_Typ
  FROM deleted
  Open Usuniete
  While 1=1
  BEGIN
   Fetch Next From Usuniete Into
   @JPK_JPKID,
   @JPK_Nazwa,
   @JPK_Typ
   If @@Fetch_Status <> 0 Break
   SET @TypObiektu = CASE WHEN @JPK_Typ IN ('JPK_V7M', 'JPK_V7K') THEN 2001 ELSE 2000 END
   IF NOT EXISTS(select * from inserted where inserted.JPK_JPKID = @JPK_JPKID)
  BEGIN
   EXEC CDN.RejestrOperacjiDodaj @TypObiektu, 0, @JPK_JPKID, @JPK_Nazwa, 3, ''
  END
  END
  Close Dodane
  Close Usuniete
  Deallocate Dodane
  Deallocate Usuniete
  SET NOCOUNT OFF
