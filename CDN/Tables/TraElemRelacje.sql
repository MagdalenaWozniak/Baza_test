CREATE TABLE [CDN].[TraElemRelacje] (
    [TeR_TeRId]     INT             IDENTITY (1, 1) NOT NULL,
    [TeR_ParentTyp] SMALLINT        NOT NULL,
    [TeR_ParentId]  INT             NOT NULL,
    [TeR_ChildTyp]  SMALLINT        NOT NULL,
    [TeR_ChildId]   INT             NOT NULL,
    [TeR_Flaga]     SMALLINT        NULL,
    [TeR_Info]      DECIMAL (15, 4) NULL,
    [TeR_Info2]     DECIMAL (15, 4) NULL,
    CONSTRAINT [TeR_Primary] PRIMARY KEY CLUSTERED ([TeR_TeRId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [TeR_Parent]
    ON [CDN].[TraElemRelacje]([TeR_ParentTyp] ASC, [TeR_ParentId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TeR_Child]
    ON [CDN].[TraElemRelacje]([TeR_ChildTyp] ASC, [TeR_ChildId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [TeR_ParentIdChildId]
    ON [CDN].[TraElemRelacje]([TeR_ChildId] ASC, [TeR_ParentId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TraElemRelacje_Insert_Trigger
  ON CDN.TraElemRelacje
  FOR INSERT
AS
SET NOCOUNT ON
-- Obliczenie statusu zleceń
-- Status zlecenia zależy od tego, czy poszczególne pozycje są powiązane z pozycjami dokumentów HaMag
 DECLARE @klasa INT
 SET @klasa = 901
 UPDATE cdn.SrsZlecenia
 SET SrZ_Stan = CDN.SrsZlecenieUstalStan(SrZ_SrZId)
 FROM cdn.SrsZlecenia
 JOIN cdn.SrsCzynnosci ON SrY_SrZId = SrZ_SrZId
 WHERE SrY_SrYId IN (SELECT Inserted.TeR_ParentId FROM Inserted WHERE Inserted.TeR_ParentTyp=@klasa)
 SET @klasa = 902
 UPDATE cdn.SrsZlecenia
 SET SrZ_Stan = CDN.SrsZlecenieUstalStan(SrZ_SrZId)
 FROM cdn.SrsZlecenia
    JOIN cdn.SrsCzesci ON SrC_SrZId = SrZ_SrZId
 WHERE SrC_SrCId IN (SELECT Inserted.TeR_ParentId FROM Inserted WHERE Inserted.TeR_ParentTyp=@klasa)
Set NoCount Off

GO
CREATE TRIGGER CDN.TraElemRelacje_Delete_Trigger
  ON CDN.TraElemRelacje
  FOR DELETE
AS
SET NOCOUNT ON
-- Obliczenie statusu zleceń
-- Status zlecenia zależy od tego, czy poszczególne pozycje są powiązane z pozycjami dokumentów HaMag
 DECLARE @klasa INT
 SET @klasa = 901
 UPDATE cdn.SrsZlecenia
 SET SrZ_Stan = CDN.SrsZlecenieUstalStan(SrZ_SrZId)
 FROM cdn.SrsZlecenia
 JOIN cdn.SrsCzynnosci ON SrY_SrZId = SrZ_SrZId
 WHERE SrY_SrYId IN (SELECT deleted.TeR_ParentId FROM deleted WHERE deleted.TeR_ParentTyp=@klasa)
 SET @klasa = 902
 UPDATE cdn.SrsZlecenia
 SET SrZ_Stan = CDN.SrsZlecenieUstalStan(SrZ_SrZId)
 FROM cdn.SrsZlecenia
    JOIN cdn.SrsCzesci ON SrC_SrZId = SrZ_SrZId
 WHERE SrC_SrCId IN (SELECT deleted.TeR_ParentId FROM deleted WHERE deleted.TeR_ParentTyp=@klasa)
Set NoCount Off
