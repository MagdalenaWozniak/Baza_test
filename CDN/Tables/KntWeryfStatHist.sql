CREATE TABLE [CDN].[KntWeryfStatHist] (
    [KWSH_KWSHID]         INT           IDENTITY (1, 1) NOT NULL,
    [KWSH_KntID]          INT           NOT NULL,
    [KWSH_Nip]            NVARCHAR (20) NOT NULL,
    [KWSH_Data]           DATETIME      NOT NULL,
    [KWSH_Status]         INT           NOT NULL,
    [KWSH_TypWeryfikacji] TINYINT       CONSTRAINT [DF_KWSH_TypWeryfikacji] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [KWSH_Primary] PRIMARY KEY CLUSTERED ([KWSH_KWSHID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WgKnt] FOREIGN KEY ([KWSH_KntID]) REFERENCES [CDN].[Kontrahenci] ([Knt_KntId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [KWSHKntChron]
    ON [CDN].[KntWeryfStatHist]([KWSH_KntID] ASC, [KWSH_Data] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.KntWeryfStatHist_Delete_Trigger
  On CDN.KntWeryfStatHist
  For Delete
As
Set NoCount On
-- Skasowanie powiązanych danych w tabeli DaneBinarne
  DELETE From CDN.DaneBinarne WHERE DaB_Typ = 11 AND DaB_TWAID In (Select KWSH_KWSHID From deleted)
Set NoCount Off
