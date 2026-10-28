CREATE TABLE [CDN].[Awizo] (
    [AWZ_AWZId]            INT           IDENTITY (1, 1) NOT NULL,
    [AWZ_Numer]            NVARCHAR (20) NOT NULL,
    [AWZ_Data]             DATETIME      NOT NULL,
    [AWZ_DataDostawy]      DATETIME      NOT NULL,
    [AWZ_PodId]            INT           NOT NULL,
    [AWZ_OdbId]            INT           NOT NULL,
    [AWZ_TypTransportuID]  INT           NOT NULL,
    [AWZ_WarunkiDostawyID] INT           NOT NULL,
    [AWZ_TrNID]            INT           NOT NULL,
    [AWZ_TS_Zal]           DATETIME      NOT NULL,
    [AWZ_OpeModId]         INT           NULL,
    [AWZ_StaModId]         INT           NULL,
    [AWZ_TS_Mod]           DATETIME      NOT NULL,
    [AWZ_OpeZalId]         INT           NULL,
    [AWZ_StaZalId]         INT           NULL,
    [AWZ_Bufor]            SMALLINT      NOT NULL,
    [AWZ_PodTyp]           SMALLINT      NULL,
    [AWZ_OdbTyp]           SMALLINT      NULL,
    [AWZ_OpeModKod]        VARCHAR (20)  CONSTRAINT [DF_AWZ_OpeModKod] DEFAULT ('') NOT NULL,
    [AWZ_OpeModNazwisko]   NVARCHAR (50) CONSTRAINT [DF_AWZ_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [AWZ_OpeZalKod]        VARCHAR (20)  CONSTRAINT [DF_AWZ_OpeZalKod] DEFAULT ('') NOT NULL,
    [AWZ_OpeZalNazwisko]   NVARCHAR (50) CONSTRAINT [DF_AWZ_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [AWZ_Primary] PRIMARY KEY CLUSTERED ([AWZ_AWZId] ASC) WITH (FILLFACTOR = 100)
);


GO
create TRIGGER [CDN].[Awizo_InsertUpdate_Trigger]
  ON [CDN].[Awizo]
  FOR Insert,Update
AS
  SET NOCOUNT ON
if exists( Select * From inserted A, CDN.Awizo B Where
           B.AWZ_Numer   = A.AWZ_Numer And
           B.AWZ_AWZID   <> A.AWZ_AWZID )
        Begin
          RaisError ('##OPT34503##', 16,1)
          RollBack Tran
          Return
        END
     SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Awizo_Delete_Trigger
  ON CDN.Awizo
  FOR DELETE
AS
  SET NOCOUNT ON
  Set ArithAbort On
-- Skasowanie relacji do dokumentów serwisowych  (WiNi)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=380AND DoR_DokumentId=deleted.AWZ_AWZId
  Set NoCount Off
