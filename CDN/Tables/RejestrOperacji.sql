CREATE TABLE [CDN].[RejestrOperacji] (
    [ROP_ROPID]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [ROP_ObiektTyp]    INT             NOT NULL,
    [ROP_ObiektSubTyp] INT             NULL,
    [ROP_ObiektID]     INT             NULL,
    [ROP_ObiektNazwa]  NVARCHAR (300)  NULL,
    [ROP_Data]         DATETIME        NOT NULL,
    [ROP_Operator]     NVARCHAR (50)   NULL,
    [ROP_OperacjaTyp]  INT             NOT NULL,
    [ROP_Opis]         NVARCHAR (1000) NULL,
    CONSTRAINT [ROP_Primary] PRIMARY KEY CLUSTERED ([ROP_ROPID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [ROP_IdTypObiektu]
    ON [CDN].[RejestrOperacji]([ROP_ObiektID] ASC, [ROP_ObiektTyp] ASC) WITH (FILLFACTOR = 100);

