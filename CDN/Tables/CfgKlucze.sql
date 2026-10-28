CREATE TABLE [CDN].[CfgKlucze] (
    [CFK_CfkId]          INT           IDENTITY (1, 1) NOT NULL,
    [CFK_ParentId]       INT           NOT NULL,
    [CFK_Nazwa]          VARCHAR (32)  NOT NULL,
    [CFK_OkresOd]        DATETIME      NOT NULL,
    [CFK_OkresDo]        DATETIME      NOT NULL,
    [CFK_OpeZalId]       INT           NULL,
    [CFK_StaZalId]       INT           NULL,
    [CFK_TS_Zal]         DATETIME      NULL,
    [CFK_OpeModId]       INT           NULL,
    [CFK_StaModId]       INT           NULL,
    [CFK_TS_Mod]         DATETIME      NULL,
    [CFK_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_CFK_OpeModKod] DEFAULT ('') NOT NULL,
    [CFK_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_CFK_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [CFK_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_CFK_OpeZalKod] DEFAULT ('') NOT NULL,
    [CFK_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_CFK_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [CFK_Primary] PRIMARY KEY CLUSTERED ([CFK_CfkId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CFK_Parent] FOREIGN KEY ([CFK_ParentId]) REFERENCES [CDN].[CfgKlucze] ([CFK_CfkId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [CFKParent]
    ON [CDN].[CfgKlucze]([CFK_ParentId] ASC, [CFK_Nazwa] ASC, [CFK_OkresOd] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.CfgKlucze_Update_Trigger ON CDN.CfgKlucze
FOR INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
UPDATE CDN.CfgKlucze
SET CFK_OkresDo = Tmp_OkresDO
FROM
CDN.CfgKlucze
JOIN (SELECT A.CFK_CFKId As Tmp_CFKId, (SELECT IsNull(MIN(B.CFK_OkresOd),CONVERT(datetime,'3000-01-01',120)) FROM CDN.CfgKlucze B WHERE B.CFK_ParentId = A.CFK_ParentId AND B.CFK_Nazwa = A.CFK_Nazwa AND B.CFK_OkresOd > A.CFK_OkresOd) As Tmp_OkresDo
FROM CDN.CfgKlucze A
where A.CFK_CFKId IN
  (SELECT C.CFK_CFKId FROM CDN.CfgKlucze C
    JOIN (SELECT CFK_ParentId, CFK_Nazwa FROM Deleted
     UNION
     SELECT CFK_ParentId, CFK_Nazwa FROM Inserted) As D ON D.CFK_ParentId = C.CFK_ParentId AND D.CFK_Nazwa = C.CFK_Nazwa )
) As TmpDaty
 ON CDN.CfgKlucze.CFK_CFKId = TmpDaty.Tmp_CFKId
WHERE CDN.CfgKlucze.CFK_OkresDo <> TmpDaty.Tmp_OkresDo OR CDN.CfgKlucze.CFK_OkresDo IS NULL
SET NOCOUNT OFF
