CREATE TABLE [CDN].[PodmiotyView] (
    [Pod_PodmiotTyp]   SMALLINT        NOT NULL,
    [Pod_PodId]        INT             NOT NULL,
    [Pod_Kod]          VARCHAR (20)    NOT NULL,
    [Pod_Nazwa1]       NVARCHAR (50)   NOT NULL,
    [Pod_Nazwa2]       NVARCHAR (50)   NOT NULL,
    [Pod_Nazwa3]       NVARCHAR (250)  NOT NULL,
    [Pod_Kraj]         NVARCHAR (40)   NOT NULL,
    [Pod_Wojewodztwo]  NVARCHAR (40)   NOT NULL,
    [Pod_Powiat]       NVARCHAR (40)   NOT NULL,
    [Pod_Gmina]        NVARCHAR (40)   NOT NULL,
    [Pod_Ulica]        NVARCHAR (40)   NOT NULL,
    [Pod_NrDomu]       NVARCHAR (10)   NOT NULL,
    [Pod_NrLokalu]     NVARCHAR (10)   NOT NULL,
    [Pod_Miasto]       NVARCHAR (40)   NOT NULL,
    [Pod_KodPocztowy]  VARCHAR (10)    NOT NULL,
    [Pod_Poczta]       NVARCHAR (40)   NOT NULL,
    [Pod_Telefon1]     VARCHAR (20)    NOT NULL,
    [Pod_Telefon2]     VARCHAR (20)    NOT NULL,
    [Pod_TelefonSms]   VARCHAR (20)    CONSTRAINT [DF_POD_TelefonSms] DEFAULT ('') NOT NULL,
    [Pod_Adres2]       NVARCHAR (40)   NOT NULL,
    [Pod_Email]        NVARCHAR (127)  CONSTRAINT [PodmiotyView_EmailDefault] DEFAULT ('') NOT NULL,
    [Pod_Rodzaj]       SMALLINT        NOT NULL,
    [Pod_RodzajOpis]   NVARCHAR (20)   NOT NULL,
    [Pod_Grupa]        VARCHAR (20)    NOT NULL,
    [Pod_NipKraj]      VARCHAR (2)     NOT NULL,
    [Pod_NIP]          NVARCHAR (20)   NOT NULL,
    [Pod_Regon]        VARCHAR (20)    NOT NULL,
    [Pod_Pesel]        NVARCHAR (11)   NOT NULL,
    [Pod_LimitKredytu] DECIMAL (15, 2) NOT NULL,
    [Pod_ImportRowId]  VARCHAR (36)    NOT NULL,
    [Pod_KontoOdb]     NVARCHAR (50)   NOT NULL,
    [Pod_KontoDost]    NVARCHAR (50)   NOT NULL,
    [Pod_GlID]         INT             NULL,
    [Pod_GlKod]        VARCHAR (20)    NULL,
    [Pod_GlNazwa12]    NVARCHAR (101)  NULL,
    [Pod_NadID]        INT             NULL,
    [Pod_Nieaktywny]   TINYINT         CONSTRAINT [PodmiotyView_Nieaktywny] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [Pod_Primary] PRIMARY KEY CLUSTERED ([Pod_PodId] ASC, [Pod_PodmiotTyp] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [PodKod]
    ON [CDN].[PodmiotyView]([Pod_Kod] ASC, [Pod_PodmiotTyp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PodGridLookupFilter]
    ON [CDN].[PodmiotyView]([Pod_Kod] ASC, [Pod_PodmiotTyp] ASC, [Pod_PodId] ASC)
    INCLUDE([Pod_Nazwa1], [Pod_Email]) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.PodmiotyView_DeleteHandler
  ON CDN.PodmiotyView
  FOR DELETE
AS
SET NOCOUNT ON
    -- obsługa sprawdzania relacji restrict do tabeli CDN.Konta
    IF EXISTS
       ( SELECT * FROM CDN.Konta, deleted
          WHERE
                deleted.Pod_PodId = CDN.Konta.Acc_SlownikId
            AND deleted.Pod_PodmiotTyp = CDN.Konta.Acc_SlownikTyp
       AND (CDN.Konta.Acc_SlownikTyp In (1,2,3,4,5))
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=Konta##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- obsługa sprawdzania relacji restrict do tabeli CDN.DekretyElem
    IF EXISTS
       ( SELECT * FROM CDN.DekretyElem, deleted
          WHERE
                deleted.Pod_PodId = CDN.DekretyElem.DeE_SlownikId
            AND deleted.Pod_PodmiotTyp = CDN.DekretyElem.DeE_SlownikTyp
       AND (CDN.DekretyElem.DeE_SlownikTyp IN (1,2,3,4,5))
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=DekretyElem##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- obsługa sprawdzania relacji restrict do tabeli CDN.BnkZdarzenia
    IF EXISTS
       ( SELECT * FROM CDN.BnkZdarzenia, deleted
          WHERE
                deleted.Pod_PodId = CDN.BnkZdarzenia.BZd_PodmiotID
            AND deleted.Pod_PodmiotTyp = CDN.BnkZdarzenia.BZd_PodmiotTyp
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=BnkZdarzenia##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- obsługa sprawdzania relacji restrict do tabeli CDN.BnkZapisy
    IF EXISTS
       ( SELECT * FROM CDN.BnkZapisy, deleted
          WHERE
                deleted.Pod_PodId = CDN.BnkZapisy.BZp_PodmiotID
            AND deleted.Pod_PodmiotTyp = CDN.BnkZapisy.BZp_PodmiotTyp
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=BnkZapisy##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- obsługa sprawdzania relacji restrict do tabeli CDN.BnkDokNag
    IF EXISTS
       ( SELECT * FROM CDN.BnkDokNag, deleted
          WHERE
                deleted.Pod_PodId = CDN.BnkDokNag.BDN_PodmiotID
            AND deleted.Pod_PodmiotTyp = CDN.BnkDokNag.BDN_PodmiotTyp
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=BnkDokNag##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    -- obsługa sprawdzania relacji restrict do tabeli CDN.NotyOdsNag
    IF EXISTS
       ( SELECT * FROM CDN.NotyOdsNag, deleted
          WHERE
                deleted.Pod_PodId = CDN.NotyOdsNag.NON_PodmiotID
            AND deleted.Pod_PodmiotTyp = CDN.NotyOdsNag.NON_PodmiotTyp
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=NotyOdsNag##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
SET NOCOUNT OFF
