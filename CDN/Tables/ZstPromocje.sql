CREATE TABLE [CDN].[ZstPromocje] (
    [ZPR_ID]       INT           IDENTITY (1, 1) NOT NULL,
    [ZPR_PrmID]    INT           NULL,
    [ZPR_TwrTyp]   SMALLINT      NULL,
    [ZPR_TwrFirma] INT           NULL,
    [ZPR_TwrNumer] INT           NULL,
    [ZPR_TwrLp]    SMALLINT      NULL,
    [ZPR_Nazwa]    VARCHAR (512) NULL,
    CONSTRAINT [ZPR_Primary] PRIMARY KEY CLUSTERED ([ZPR_ID] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON)
);

