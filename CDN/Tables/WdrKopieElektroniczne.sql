CREATE TABLE [CDN].[WdrKopieElektroniczne] (
    [WdKE_WdKEId]               INT             IDENTITY (1, 1) NOT NULL,
    [WdKE_CallProcId]           INT             NULL,
    [WdKE_CallProcName]         NVARCHAR (255)  NULL,
    [WdKE_ProcId]               INT             NULL,
    [WdKE_ProcName]             NVARCHAR (255)  NULL,
    [WdKE_ObjType]              INT             NULL,
    [WdKE_ObjSubType]           INT             NULL,
    [WdKE_ObjId]                INT             NULL,
    [WdKE_ObjName]              NVARCHAR (512)  NULL,
    [WdKE_ObjDescription]       NVARCHAR (1024) NULL,
    [WdKE_ObjDate]              DATETIME        NULL,
    [WdKE_ObjSubjectType]       INT             NULL,
    [WdKE_ObjSubjectId]         INT             NULL,
    [WdKE_ObjModOpeId]          INT             NULL,
    [WdKE_PrnId]                INT             NULL,
    [WdKE_PrnName]              NVARCHAR (255)  CONSTRAINT [DF_WdKE_PrnName] DEFAULT ('') NOT NULL,
    [WdKE_PrnFileName]          NVARCHAR (255)  NOT NULL,
    [WdKE_PrnDate]              DATETIME        CONSTRAINT [DF_WdKE_PrnDate] DEFAULT (getdate()) NOT NULL,
    [WdKE_PrnOpeId]             INT             NOT NULL,
    [WdKE_PrnContent]           IMAGE           NULL,
    [WdKE_PrnContentLen]        INT             NOT NULL,
    [WdKE_Flaga]                INT             NULL,
    [WdKE_ePracownik]           INT             CONSTRAINT [DF_WdKE_ePracownik] DEFAULT ((0)) NOT NULL,
    [WdKE_BIPoint]              TINYINT         CONSTRAINT [DF_WdKE_BIPoint] DEFAULT ((0)) NOT NULL,
    [WdKE_IBardId]              BIGINT          NULL,
    [WdKE_iBardSciezka]         NVARCHAR (MAX)  NULL,
    [WdKE_iBardLink]            NVARCHAR (MAX)  NULL,
    [WdKE_Udostepnil_LoginSSO]  NVARCHAR (128)  NULL,
    [WdKE_DostepnyDla_LoginSSO] NVARCHAR (128)  NULL,
    [WdKE_PrnOpeNazwisko]       NVARCHAR (50)   CONSTRAINT [DF_WdKE_PrnOpeNazwisko] DEFAULT ('') NOT NULL,
    [WdKE_ePracownikDate]       DATETIME        NULL,
    CONSTRAINT [WdKE_Primary] PRIMARY KEY CLUSTERED ([WdKE_WdKEId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [WdKE_ByCallProcId]
    ON [CDN].[WdrKopieElektroniczne]([WdKE_CallProcId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WdKE_ByProcId]
    ON [CDN].[WdrKopieElektroniczne]([WdKE_ProcId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WdKE_ByPrnDate]
    ON [CDN].[WdrKopieElektroniczne]([WdKE_PrnDate] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WdKE_ByObjDate]
    ON [CDN].[WdrKopieElektroniczne]([WdKE_ObjDate] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WdKE_ByObj]
    ON [CDN].[WdrKopieElektroniczne]([WdKE_ObjType] ASC, [WdKE_ObjSubType] ASC, [WdKE_ObjId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.WdrKopieElektroniczne_Delete_Trigger
  ON CDN.WdrKopieElektroniczne
  FOR DELETE
AS
BEGIN
 SET NOCOUNT ON
 -- obsługa kasowania
 DELETE FROM CDN.DokRelacje WHERE DoR_ParentId In (SELECT WdKE_WdKEId FROM deleted) AND DoR_ParentTyp=752
 SET NOCOUNT OFF
END

GO
CREATE TRIGGER CDN.WdrKopieElektroniczne_Insert_Trigger
ON CDN.WdrKopieElektroniczne
FOR INSERT
AS
  SET NOCOUNT ON
  IF UPDATE(WdKE_ObjType) AND UPDATE (WdKE_ObjId)
  BEGIN
     INSERT INTO [CDN].[DokRelacje](
                [DoR_ParentTyp],
                [DoR_ParentId],
                [DoR_DokumentTyp],
                [DoR_DokumentId],
                [DoR_Flaga])
  SELECT 752,
    WdKE_WdKEId,
    WdKE_ObjType,
    WdKE_ObjId,
    0
  FROM inserted
  WHERE inserted.WdKE_ObjType Is NOT Null AND inserted.WdKE_ObjId Is NOT Null
  END
  SET NOCOUNT OFF
