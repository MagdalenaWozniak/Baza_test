CREATE TABLE [CDN].[KntLinki] (
    [KnL_GIDTyp]          SMALLINT NOT NULL,
    [KnL_GIDFirma]        INT      NULL,
    [KnL_GIDNumer]        INT      NOT NULL,
    [KnL_GIDLp]           SMALLINT NULL,
    [KnL_GrOTyp]          SMALLINT NOT NULL,
    [KnL_GrOFirma]        INT      NULL,
    [KnL_GrONumer]        INT      NOT NULL,
    [KnL_GrOLp]           SMALLINT NULL,
    [KnL_Lisc]            SMALLINT NULL,
    [KnL_LiczbaPowtorzen] SMALLINT NULL,
    [KnL_TStampDataMod]   INT      NULL,
    CONSTRAINT [KnL_Primary] PRIMARY KEY CLUSTERED ([KnL_GIDTyp] ASC, [KnL_GIDNumer] ASC, [KnL_GrOTyp] ASC, [KnL_GrONumer] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON)
);

