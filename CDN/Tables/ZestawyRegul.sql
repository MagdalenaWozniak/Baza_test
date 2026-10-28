CREATE TABLE [CDN].[ZestawyRegul] (
    [ZRG_ZrgId]   INT           IDENTITY (1, 1) NOT NULL,
    [ZRG_Akronim] VARCHAR (8)   NOT NULL,
    [ZRG_Nazwa]   NVARCHAR (50) NOT NULL,
    CONSTRAINT [ZRG_Primary] PRIMARY KEY CLUSTERED ([ZRG_ZrgId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ZRGZrgAkronim]
    ON [CDN].[ZestawyRegul]([ZRG_Akronim] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ZRGZrgNazwa]
    ON [CDN].[ZestawyRegul]([ZRG_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.ZestawyRegul_Delete_Trigger
  ON CDN.ZestawyRegul
  FOR DELETE
AS
  SET NOCOUNT ON
    -- Sprawdzanie, czy nie skasowano kontrahenta o Id=1 (nieokreślony)
    IF EXISTS (SELECT * FROM deleted WHERE deleted.Zrg_ZrgId = 1)
    BEGIN
      RAISERROR('Nie można kasować standardowego Zestawu reguł. ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF
