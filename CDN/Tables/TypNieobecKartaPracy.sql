CREATE TABLE [CDN].[TypNieobecKartaPracy] (
    [TNK_TnkId]     INT           IDENTITY (1, 1) NOT NULL,
    [TNK_Akronim]   VARCHAR (20)  NOT NULL,
    [TNK_Nazwa]     NVARCHAR (40) NOT NULL,
    [TNK_SortOrder] TINYINT       NULL,
    CONSTRAINT [TNK_Primary] PRIMARY KEY CLUSTERED ([TNK_TnkId] ASC) WITH (FILLFACTOR = 100)
);

