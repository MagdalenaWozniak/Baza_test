CREATE TABLE [CDN].[TwrEan] (
    [TwE_TwEId]    INT            IDENTITY (1, 1) NOT NULL,
    [TwE_TwrID]    INT            NOT NULL,
    [TwE_EAN]      VARCHAR (40)   NOT NULL,
    [TwE_Opis]     NVARCHAR (100) NOT NULL,
    [TwE_Domyslny] TINYINT        NOT NULL,
    [TwE_JM]       NVARCHAR (20)  NOT NULL,
    CONSTRAINT [TwE_Primary] PRIMARY KEY CLUSTERED ([TwE_TwEId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TwETowar] FOREIGN KEY ([TwE_TwrID]) REFERENCES [CDN].[Towary] ([Twr_TwrId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [TwEEan]
    ON [CDN].[TwrEan]([TwE_EAN] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwETowar]
    ON [CDN].[TwrEan]([TwE_TwrID] ASC, [TwE_EAN] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER [CDN].[TwrEAN_InsertUpdate_Trigger]
ON [CDN].[TwrEAN]
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  If Update (TwE_EAN)
    Begin
      If Exists (
        Select * From inserted A, CDN.Towary B Where
          A.TwE_EAN   = B.Twr_EAN And B.Twr_EAN <> '' And
           A.TwE_TwrId   <> B.Twr_TwrId)
       Or Exists (
         Select * From inserted A, CDN.TwrEAN B Where
          A.TwE_EAN   = B.TwE_EAN And A.TwE_EAN <> '' And
           A.TwE_TwrId   <> B.TwE_TwrId)
  Or Exists (
         Select * From inserted A, CDN.Towary B Where
           B.Twr_Kod   = A.TwE_EAN And
           B.Twr_TwrId   <> A.TwE_TwrId)
        Begin
          RaisError ('##OPT32345##', 16,1)
          RollBack Tran
          Return
        End
    End
  SET NOCOUNT OFF
