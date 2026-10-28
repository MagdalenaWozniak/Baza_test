CREATE TABLE [CDN].[Firma] (
    [Fir_FirID]   INT            IDENTITY (1, 1) NOT NULL,
    [Fir_Numer]   INT            NOT NULL,
    [Fir_Wartosc] NVARCHAR (512) NOT NULL,
    [Fir_Opis]    NVARCHAR (254) NOT NULL,
    CONSTRAINT [Fir_Primary] PRIMARY KEY CLUSTERED ([Fir_FirID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [FirNumer]
    ON [CDN].[Firma]([Fir_Numer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TRIG_Firma_Kreator
ON CDN.Firma
FOR UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    if EXISTS (select * from deleted where fir_numer=1 and fir_wartosc='1') begin
        RAISERROR('##OPT32323##', 16, 1) -- RAISERROR(N'Nastąpiła próba usuwania lub aktualizacji uruchomienia kreatora firmy. Operacja została zablokowana.', 16,1)
        if(@@TRANCOUNT >0 )
            ROLLBACK
    END
END
