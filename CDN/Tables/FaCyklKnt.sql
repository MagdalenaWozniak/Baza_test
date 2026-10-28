CREATE TABLE [CDN].[FaCyklKnt] (
    [FCK_FcKID]          INT             IDENTITY (1, 1) NOT NULL,
    [FCK_FcNID]          INT             NOT NULL,
    [FCK_TypKnt]         TINYINT         NOT NULL,
    [FCK_LpDlaTypKnt]    INT             NOT NULL,
    [FCK_PodmiotTyp]     SMALLINT        NULL,
    [FCK_PodmiotID]      INT             NULL,
    [FCK_Kod]            VARCHAR (20)    NOT NULL,
    [FCK_Nazwa]          NVARCHAR (350)  NOT NULL,
    [FCK_ObowiazujeOd]   TINYINT         NOT NULL,
    [FCK_TerminOd]       DATETIME        NULL,
    [FCK_ObowiazujeDo]   TINYINT         NOT NULL,
    [FCK_TerminDo]       DATETIME        NULL,
    [FCK_OdbiorcaTyp]    SMALLINT        NULL,
    [FCK_OdbiorcaId]     INT             NULL,
    [FCK_OdbiorcaKod]    VARCHAR (20)    CONSTRAINT [DF_FCK_OdbiorcaKod] DEFAULT ('') NOT NULL,
    [FCK_OdbiorcaNazwa]  NVARCHAR (352)  CONSTRAINT [DF_FCK_OdbiorcaNazwa] DEFAULT ('') NOT NULL,
    [FCK_OpisNaFakturze] NVARCHAR (1024) NULL,
    CONSTRAINT [FCK_Primary] PRIMARY KEY CLUSTERED ([FCK_FcKID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_FCKNaglowek] FOREIGN KEY ([FCK_FcNID]) REFERENCES [CDN].[FaCyklNag] ([FCN_FcNID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [FCKNaglowek]
    ON [CDN].[FaCyklKnt]([FCK_FcNID] ASC, [FCK_FcKID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [FcKKontrahent]
    ON [CDN].[FaCyklKnt]([FCK_TypKnt] ASC, [FCK_PodmiotTyp] ASC, [FCK_PodmiotID] ASC, [FCK_FcNID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [FCKKod]
    ON [CDN].[FaCyklKnt]([FCK_TypKnt] ASC, [FCK_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.FaCyklKnt_Delete_Trigger
  ON CDN.FaCyklKnt
  FOR DELETE
AS
  SET NOCOUNT ON
  -- wykasuj dane o ilościach i cenach dla kontrahentów: TFS: 143940
  DELETE FROM cdn.FaCyklTwrKnt WHERE FCT_FcKId IN (SELECT FcK_FcKId FROM deleted)
  SET NOCOUNT OFF
