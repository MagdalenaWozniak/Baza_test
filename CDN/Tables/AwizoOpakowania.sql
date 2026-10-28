CREATE TABLE [CDN].[AwizoOpakowania] (
    [AWO_AWOId]           INT             IDENTITY (1, 1) NOT NULL,
    [AWO_AWZId]           INT             NOT NULL,
    [AWO_OpakowanieID]    INT             NOT NULL,
    [AWO_ParentID]        INT             NOT NULL,
    [AWO_Opis]            NVARCHAR (70)   NOT NULL,
    [AWO_NrZamowienia]    NVARCHAR (35)   NOT NULL,
    [AWO_NrOdbiorca]      NVARCHAR (100)  NOT NULL,
    [AWO_TrEID]           INT             NOT NULL,
    [AWO_KodSSCC]         NVARCHAR (18)   NOT NULL,
    [AWO_TwrID]           INT             NOT NULL,
    [AWO_TwrIlosc]        DECIMAL (15, 4) NOT NULL,
    [AWO_Objetosc]        DECIMAL (15, 2) NOT NULL,
    [AWO_Waga]            DECIMAL (15, 2) NOT NULL,
    [AWO_TypOpakowaniaId] INT             NOT NULL,
    CONSTRAINT [AWO_Primary] PRIMARY KEY CLUSTERED ([AWO_AWOId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AWOAwizo] FOREIGN KEY ([AWO_AWZId]) REFERENCES [CDN].[Awizo] ([AWZ_AWZId]) ON DELETE CASCADE
);


GO
create TRIGGER [CDN].[AwizoOpakowania_InsertUpdate_Trigger]
ON [CDN].[AwizoOpakowania]
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  If Update (AWO_KodSSCC)
    Begin
      If Exists (
         Select * From inserted A, CDN.AwizoOpakowania B Where
          A.AWO_KodSSCC   = B.AWO_KodSSCC And A.AWO_KodSSCC <> '' And
           A.AWO_AWOId   <> B.AWO_AWOId)
        Begin
          RaisError ('##OPT34504##', 16,1)
          RollBack Tran
          Return
        End
    End
  SET NOCOUNT OFF
