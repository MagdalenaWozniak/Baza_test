CREATE TABLE [CDN].[DaneKadMod] (
    [DKM_DkmId]      INT            IDENTITY (1, 1) NOT NULL,
    [DKM_Rodzaj]     TINYINT        NOT NULL,
    [DKM_Nazwa]      VARCHAR (280)  NOT NULL,
    [DKM_Opis]       NVARCHAR (60)  NOT NULL,
    [DKM_Robotnicze] TINYINT        NOT NULL,
    [DKM_ZjeId]      NVARCHAR (128) CONSTRAINT [DF_DKM_ZjeId] DEFAULT ('') NOT NULL,
    CONSTRAINT [DKM_Primary] PRIMARY KEY CLUSTERED ([DKM_DkmId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [DKMZjeLink]
    ON [CDN].[DaneKadMod]([DKM_ZjeId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DaneKadMod_Delete_Trigger
  ON CDN.DaneKadMod
  FOR DELETE
AS
  SET NOCOUNT ON
    -- Sprawdzanie, czy nie skasowano kontrahenta o Id=1 (nieokreślony)
    IF EXISTS (SELECT * FROM deleted WHERE deleted.DKM_Rodzaj = 8 and DKM_Robotnicze > 0)
    BEGIN
      RAISERROR('##OPT32498##', 16, 1)--RAISERROR('Nie można kasować domyślnego wzoru naliczania odsetek. ', 16, 1)--ERR_SQL_Place_NieMoznaUsunacWzoru
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.DaneKadMod_Update_Trigger
  ON CDN.DaneKadMod
  FOR UPDATE
AS
  SET NOCOUNT ON
 declare @thisID int
  select @thisID = dkm_dkmid from inserted
    -- Sprawdzanie, czy nie skasowano kontrahenta o Id=1 (nieokreślony)
    IF EXISTS (SELECT * FROM inserted WHERE inserted.DKM_Rodzaj = 8 and DKM_Robotnicze > 0)
    BEGIN
      RAISERROR('##OPT32499##', 16, 1)--RAISERROR('Nie można modyfikować domyślnego wzoru naliczania odsetek. ', 16, 1)--ERR_SQL_Place_NieMoznaModyfikowacWzoru
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
 if exists (select * from cdn.harmonogram where hrm_dkmid = @thisID)
  begin
   RAISERROR('##OPT32500##', 16, 1)--raiserror('Nie można modyfikować wzoru użytego w harmonogramie spłat pożyczki.', 16, 1)--ERR_SQL_Place_NieMoznaModyfikowacWzoruHarm
          rollback tran
      set nocount off
      return
  end
  SET NOCOUNT OFF
