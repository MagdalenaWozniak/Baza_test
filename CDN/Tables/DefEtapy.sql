CREATE TABLE [CDN].[DefEtapy] (
    [DEt_DEtId]   INT            IDENTITY (1, 1) NOT NULL,
    [DEt_Typ]     INT            NOT NULL,
    [DEt_Lp]      INT            NULL,
    [DEt_Kod]     VARCHAR (20)   NOT NULL,
    [DEt_Opis]    NVARCHAR (255) NOT NULL,
    [DEt_CzyData] TINYINT        NOT NULL,
    CONSTRAINT [DEt_Primary] PRIMARY KEY CLUSTERED ([DEt_DEtId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DEtKod]
    ON [CDN].[DefEtapy]([DEt_Typ] ASC, [DEt_Kod] ASC) WITH (FILLFACTOR = 100);

