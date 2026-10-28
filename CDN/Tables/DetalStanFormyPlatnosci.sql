CREATE TABLE [CDN].[DetalStanFormyPlatnosci] (
    [DSFPl_DSFPlId]           INT           IDENTITY (1, 1) NOT NULL,
    [DSFPl_StanDetalID]       INT           NOT NULL,
    [DSFPl_OptimaId]          INT           NOT NULL,
    [DSFPl_Nazwa]             NVARCHAR (20) NOT NULL,
    [DSFPl_Nieaktywny]        TINYINT       NOT NULL,
    [DSFPl_Domyslna]          TINYINT       NOT NULL,
    [DSFPl_Gotowka]           TINYINT       NOT NULL,
    [DSFPl_TypGotowka]        TINYINT       NOT NULL,
    [DSFPl_Termin]            SMALLINT      NOT NULL,
    [DSFPl_DFNr]              INT           NULL,
    [DSFPl_TS_Mod]            DATETIME      NOT NULL,
    [DSFPl_BnkNazwa]          NVARCHAR (50) NOT NULL,
    [DSFPl_RachunekNr]        NVARCHAR (51) NOT NULL,
    [DSFPl_TerminalPlatniczy] SMALLINT      CONSTRAINT [DF_DSFPl_TerminalPlatniczy] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [DSFPl_Primary] PRIMARY KEY CLUSTERED ([DSFPl_DSFPlId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [CK_DSFPl_Termin] CHECK ([DSFPL_TERMIN]>=(0))
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DSFPlIdDetalStanOptimaId]
    ON [CDN].[DetalStanFormyPlatnosci]([DSFPl_OptimaId] ASC, [DSFPl_StanDetalID] ASC) WITH (FILLFACTOR = 100);

