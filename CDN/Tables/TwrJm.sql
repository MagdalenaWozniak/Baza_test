CREATE TABLE [CDN].[TwrJm] (
    [TwJ_TwrTyp]        SMALLINT        NOT NULL,
    [TwJ_TwrFirma]      INT             NOT NULL,
    [TwJ_TwrNumer]      INT             NOT NULL,
    [TwJ_TwrLp]         SMALLINT        NOT NULL,
    [TwJ_KcaTyp]        SMALLINT        NULL,
    [TwJ_KcaFirma]      INT             NULL,
    [TwJ_KcaNumer]      INT             NULL,
    [TwJ_KcaLp]         SMALLINT        NULL,
    [TwJ_JmZ]           NVARCHAR (8)    NULL,
    [TwJ_JmFormat]      TINYINT         NULL,
    [TwJ_TypJm]         TINYINT         NULL,
    [TwJ_Calkowita]     TINYINT         NULL,
    [TwJ_PrzeliczM]     DECIMAL (15)    NULL,
    [TwJ_PrzeliczL]     DECIMAL (15)    NULL,
    [TwJ_Prog]          DECIMAL (11, 4) NULL,
    [TwJ_Obowiazek]     TINYINT         NULL,
    [TwJ_Waga]          DECIMAL (7, 3)  NULL,
    [TwJ_WJm]           NVARCHAR (5)    NULL,
    [TwJ_EAN]           VARCHAR (20)    NULL,
    [TwJ_WyliczPrzySpr] SMALLINT        NULL,
    [TwJ_ObjetoscL]     DECIMAL (5)     NULL,
    [TwJ_ObjetoscM]     DECIMAL (5)     NULL,
    [TwJ_WagaBrutto]    DECIMAL (7, 3)  NULL,
    [TwJ_WJmBrutto]     NVARCHAR (5)    NULL,
    CONSTRAINT [TwJ_Primary] PRIMARY KEY CLUSTERED ([TwJ_TwrTyp] ASC, [TwJ_TwrFirma] ASC, [TwJ_TwrNumer] ASC, [TwJ_TwrLp] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [TwJKaucja]
    ON [CDN].[TwrJm]([TwJ_KcaTyp] ASC, [TwJ_KcaFirma] ASC, [TwJ_KcaNumer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TwjEAN]
    ON [CDN].[TwrJm]([TwJ_EAN] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TwrJm_InsertUpdateHandler
  ON CDN.TwrJm
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.Towary ON
                    inserted.TwJ_TwrTyp = CDN.Towary.Twr_GIDTyp
                AND inserted.TwJ_TwrNumer = CDN.Towary.Twr_GIDNumer
              WHERE CDN.Towary.Twr_GIDNumer IS NULL
                AND (
                          IsNull(inserted.TwJ_TwrTyp,0) <> 0            -- Jeżeli pola mają wartości NULL lub 0 to nie sprawdzamy relacji
                      OR  IsNull(inserted.TwJ_TwrNumer,0) <> 0            -- Jeżeli pola mają wartości NULL lub 0 to nie sprawdzamy relacji
                    )
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=Towary##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF
