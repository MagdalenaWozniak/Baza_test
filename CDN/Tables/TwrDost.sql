CREATE TABLE [CDN].[TwrDost] (
    [TWD_TwrTyp]    SMALLINT        NOT NULL,
    [TWD_TwrFirma]  INT             NOT NULL,
    [TWD_TwrNumer]  INT             NOT NULL,
    [TWD_TwrLp]     SMALLINT        NOT NULL,
    [TWD_KntTyp]    SMALLINT        NULL,
    [TWD_KntFirma]  INT             NULL,
    [TWD_KntNumer]  INT             NULL,
    [TWD_KntLp]     SMALLINT        NULL,
    [TWD_KodTyp]    SMALLINT        NULL,
    [TWD_KodFirma]  INT             NULL,
    [TWD_KodNumer]  INT             NULL,
    [TWD_KodLp]     SMALLINT        NULL,
    [TWD_KlasaKnt]  SMALLINT        NOT NULL,
    [TWD_Cena]      DECIMAL (15, 4) NULL,
    [TWD_Waluta]    VARCHAR (3)     NULL,
    [TWD_NrKursu]   SMALLINT        NULL,
    [TWD_DataAkt]   INT             NULL,
    [TWD_Czas]      TINYINT         NULL,
    [TWD_KodOrgKnt] NVARCHAR (40)   NULL,
    [TWD_Notatki]   NVARCHAR (200)  NULL,
    CONSTRAINT [TWD_Primary] PRIMARY KEY CLUSTERED ([TWD_TwrTyp] ASC, [TWD_TwrFirma] ASC, [TWD_TwrNumer] ASC, [TWD_KlasaKnt] ASC, [TWD_TwrLp] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwDKontrah]
    ON [CDN].[TwrDost]([TWD_KntTyp] ASC, [TWD_KntFirma] ASC, [TWD_KntNumer] ASC, [TWD_TwrTyp] ASC, [TWD_TwrFirma] ASC, [TWD_TwrNumer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [TwDKod]
    ON [CDN].[TwrDost]([TWD_KntTyp] ASC, [TWD_KntFirma] ASC, [TWD_KntNumer] ASC, [TWD_KodOrgKnt] ASC, [TWD_KodTyp] ASC, [TWD_KodFirma] ASC, [TWD_KodNumer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TwrDost_InsertUpdateHandler
  ON CDN.TwrDost
  FOR INSERT,UPDATE
AS
SET NOCOUNT ON
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.Towary ON
                    inserted.TWD_TwrTyp = CDN.Towary.Twr_GIDTyp
                AND inserted.TWD_TwrNumer = CDN.Towary.Twr_GIDNumer
              WHERE CDN.Towary.Twr_GIDNumer IS NULL
                AND (
                          IsNull(inserted.TWD_TwrTyp,0) <> 0            -- Jeżeli pola mają wartości NULL lub 0 to nie sprawdzamy relacji
                      OR  IsNull(inserted.TWD_TwrNumer,0) <> 0            -- Jeżeli pola mają wartości NULL lub 0 to nie sprawdzamy relacji
                    )
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=Towary##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
        -- Sprawdzenie obecności wierszy w tabeli nadrzędnej
        IF EXISTS
           ( SELECT * FROM inserted LEFT OUTER JOIN CDN.Kontrahenci ON
                    inserted.TWD_KntTyp = CDN.Kontrahenci.Knt_GIDTyp
                AND inserted.TWD_KntFirma = CDN.Kontrahenci.Knt_GIDFirma
                AND inserted.TWD_KntNumer = CDN.Kontrahenci.Knt_GIDNumer
              WHERE CDN.Kontrahenci.Knt_GIDNumer IS NULL
                AND (
                          IsNull(inserted.TWD_KntTyp,0) <> 0            -- Jeżeli pola mają wartości NULL lub 0 to nie sprawdzamy relacji
                      OR  IsNull(inserted.TWD_KntFirma,0) <> 0            -- Jeżeli pola mają wartości NULL lub 0 to nie sprawdzamy relacji
                      OR  IsNull(inserted.TWD_KntNumer,0) <> 0            -- Jeżeli pola mają wartości NULL lub 0 to nie sprawdzamy relacji
                    )
           )
        BEGIN
   RAISERROR('##OPT32025##%%1%%=Kontrahenci##', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT ON
          RETURN
        END
SET NOCOUNT OFF
