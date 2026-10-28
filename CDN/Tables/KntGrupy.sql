CREATE TABLE [CDN].[KntGrupy] (
    [KnG_GIDTyp]          SMALLINT     NOT NULL,
    [KnG_GIDFirma]        INT          NULL,
    [KnG_GIDNumer]        INT          NOT NULL,
    [KnG_GIDLp]           SMALLINT     NULL,
    [KnG_GrOTyp]          SMALLINT     NOT NULL,
    [KnG_GrOFirma]        INT          NULL,
    [KnG_GrONumer]        INT          NOT NULL,
    [KnG_GrOLp]           SMALLINT     NULL,
    [KnG_Akronim]         VARCHAR (20) NULL,
    [KnG_CzasModyfikacji] INT          NULL,
    CONSTRAINT [KnG_Primary] PRIMARY KEY CLUSTERED ([KnG_GIDTyp] ASC, [KnG_GIDNumer] ASC, [KnG_GrOTyp] ASC, [KnG_GrONumer] ASC) WITH (FILLFACTOR = 80, PAD_INDEX = ON)
);

