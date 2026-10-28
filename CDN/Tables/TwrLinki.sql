CREATE TABLE [CDN].[TwrLinki] (
    [TwL_GIDTyp]          SMALLINT NOT NULL,
    [TwL_GIDFirma]        INT      NOT NULL,
    [TwL_GIDNumer]        INT      NOT NULL,
    [TwL_GIDLp]           SMALLINT NULL,
    [TwL_GrOTyp]          SMALLINT NOT NULL,
    [TwL_GrOFirma]        INT      NOT NULL,
    [TwL_GrONumer]        INT      NOT NULL,
    [TwL_GrOLp]           SMALLINT NULL,
    [TwL_Lisc]            SMALLINT NULL,
    [TwL_LiczbaPowtorzen] SMALLINT NULL,
    [TwL_TStampDataMod]   INT      NULL,
    CONSTRAINT [TwL_Primary] PRIMARY KEY CLUSTERED ([TwL_GIDTyp] ASC, [TwL_GrONumer] ASC, [TwL_GIDNumer] ASC) WITH (FILLFACTOR = 100)
);

