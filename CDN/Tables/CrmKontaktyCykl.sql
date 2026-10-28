CREATE TABLE [CDN].[CrmKontaktyCykl] (
    [CRC_CRCId]                                             INT      IDENTITY (1, 1) NOT NULL,
    [CRC_CRKId]                                             INT      NOT NULL,
    [CRC_TerminOd]                                          DATETIME NOT NULL,
    [CRC_TerminDo]                                          DATETIME NOT NULL,
    [CRC_Przypomnienie]                                     TINYINT  NOT NULL,
    [CRC_CzasPrzypomnienia]                                 DATETIME NULL,
    [CRC_Aktywny]                                           INT      NOT NULL,
    [CRC_Bufor]                                             SMALLINT NOT NULL,
    [CRC_CrKWylaczonyId]                                    INT      NULL,
    [CRC_AutomatycznePrzypomnieniaSmsCzasPrzypomnienia]     DATETIME NULL,
    [CRC_AutomatycznePrzypomnieniaSmsWyslano]               DATETIME NULL,
    [CRC_AutomatycznePrzypomnieniaMailCzasPrzypomnienia]    DATETIME NULL,
    [CRC_AutomatycznePrzypomnieniaMailWyslano]              DATETIME NULL,
    [CRC_AutomatycznePrzypomnieniaOpeSmsCzasPrzypomnienia]  DATETIME NULL,
    [CRC_AutomatycznePrzypomnieniaOpeSmsWyslano]            DATETIME NULL,
    [CRC_AutomatycznePrzypomnieniaOpeMailCzasPrzypomnienia] DATETIME NULL,
    [CRC_AutomatycznePrzypomnieniaOpeMailWyslano]           DATETIME NULL,
    CONSTRAINT [CRC_Primary] PRIMARY KEY CLUSTERED ([CRC_CRCId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CRCCRMKontakty] FOREIGN KEY ([CRC_CRKId]) REFERENCES [CDN].[CRMKontakty] ([CRK_CRKId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [CRCCRMKontakty]
    ON [CDN].[CrmKontaktyCykl]([CRC_CRKId] ASC, [CRC_CRCId] ASC) WITH (FILLFACTOR = 100);

