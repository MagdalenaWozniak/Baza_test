CREATE TABLE [CDN].[RejestrOperacjiTypyObiektow] (
    [ROPTOb_Typ]    INT            NOT NULL,
    [ROPTOb_SubTyp] INT            NOT NULL,
    [ROPTOb_Nazwa]  NVARCHAR (100) NOT NULL,
    [ROPTOb_Jezyk]  INT            CONSTRAINT [DF_ROPTOb_Jezyk] DEFAULT ((1045)) NOT NULL,
    CONSTRAINT [ROPTOb_Primary] PRIMARY KEY CLUSTERED ([ROPTOb_Typ] ASC, [ROPTOb_SubTyp] ASC, [ROPTOb_Jezyk] ASC) WITH (FILLFACTOR = 100)
);

