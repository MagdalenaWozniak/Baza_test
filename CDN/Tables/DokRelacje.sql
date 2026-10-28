CREATE TABLE [CDN].[DokRelacje] (
    [DoR_DoRId]        INT              IDENTITY (1, 1) NOT NULL,
    [DoR_ParentTyp]    SMALLINT         NOT NULL,
    [DoR_ParentId]     INT              NOT NULL,
    [DoR_ParentGUID]   UNIQUEIDENTIFIER NULL,
    [DoR_DokumentTyp]  SMALLINT         NOT NULL,
    [DoR_DokumentId]   INT              NOT NULL,
    [DoR_DokumentGUID] UNIQUEIDENTIFIER NULL,
    [DoR_Flaga]        SMALLINT         NOT NULL,
    [DoR_HRM]          SMALLINT         NULL,
    CONSTRAINT [DoR_Primary] PRIMARY KEY CLUSTERED ([DoR_DoRId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE NONCLUSTERED INDEX [DoSDokument]
    ON [CDN].[DokRelacje]([DoR_DokumentTyp] ASC, [DoR_DokumentId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [DosParent]
    ON [CDN].[DokRelacje]([DoR_ParentTyp] ASC, [DoR_ParentId] ASC, [DoR_DoRId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [DoRUniqueDok]
    ON [CDN].[DokRelacje]([DoR_ParentTyp] ASC, [DoR_ParentId] ASC, [DoR_DokumentTyp] ASC, [DoR_DokumentId] ASC, [DoR_ParentGUID] ASC, [DoR_DokumentGUID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.DokRelacje_Delete_Trigger
  ON CDN.DokRelacje
  FOR DELETE
AS
 SET NOCOUNT ON
 DECLARE @klasa INT
 SET @klasa = 900
 IF EXISTS (SELECT * FROM cdn.SrsZlecenia  WHERE SrZ_SrZId IN (SELECT deleted.DoR_ParentId FROM deleted WHERE deleted.DoR_ParentTyp=@klasa AND deleted.DoR_Flaga=255 ))
 BEGIN
  UPDATE cdn.SrsZlecenia
  SET SrZ_DokStatus = CDN.SrsZlecenieStatus(SrZ_SrZId),
   SrZ_Stan = CDN.SrsZlecenieUstalStan(SrZ_SrZId)
  FROM cdn.SrsZlecenia
  WHERE SrZ_SrZId IN (SELECT deleted.DoR_ParentId FROM deleted WHERE deleted.DoR_ParentTyp=@klasa)
 END
SET NOCOUNT OFF

GO
CREATE TRIGGER [CDN].[DokRelacje_InsertUpdate_Trigger]
ON [CDN].[DokRelacje]
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
 DECLARE
 @OperatorID  INT,
 @OpeModKod   VARCHAR(20),
 @OpeModNazwisko NVARCHAR(50),
 @Log    INT
  IF EXISTS (SELECT DoR_ParentTyp FROM inserted WHERE  DoR_ParentTyp = 1011 AND DoR_DokumentTyp >300 AND DoR_DokumentTyp <= 350)
  BEGIN
 EXEC CDN.OpeDaneOperatora @OperatorID OUT, @OpeModKod OUT, @OpeModNazwisko OUT,@Log OUT
 UPDATE CDN.TraNag SET TrN_OpeeMailID =  CONVERT(VARCHAR(15), @OperatorID) ,TrN_OpeeMailKod =  @OpeModKod ,TrN_OpeeMailNazwisko =  @OpeModNazwisko , TrN_TS_eMail = GETDATE()
 WHERE TRN_TRNID IN(
 SELECT DoR_DokumentId FROM inserted WHERE  DoR_ParentTyp = 1011 AND DoR_DokumentTyp >300 AND DoR_DokumentTyp <= 350)
  END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.DokRelacje_InsteadOf_Insert_Trigger
   ON CDN.DokRelacje INSTEAD OF INSERT
AS
  INSERT INTO [CDN].[DokRelacje]
      ([DoR_ParentTyp]
      ,[DoR_ParentId]
      ,[DoR_ParentGUID]
      ,[DoR_DokumentTyp]
      ,[DoR_DokumentId]
      ,[DoR_DokumentGUID]
      ,[DoR_Flaga]
      ,[DoR_HRM])
   SELECT
    [DoR_ParentTyp]
      ,[DoR_ParentId]
      ,[DoR_ParentGUID]
      ,[DoR_DokumentTyp]
      ,[DoR_DokumentId]
      ,[DoR_DokumentGUID]
      ,[DoR_Flaga]
      ,[DoR_HRM]
  FROM inserted i
  WHERE NOT EXISTS( SELECT 1 FROM [CDN].[DokRelacje] t2
     WHERE i.[DoR_ParentTyp]    = t2.[DoR_ParentTyp]
     AND   i.[DoR_ParentId]     = t2.[DoR_ParentId]
     AND   i.[DoR_DokumentTyp]  = t2.[DoR_DokumentTyp]
     AND   i.[DoR_DokumentId]   = t2.[DoR_DokumentId]
     AND   ((i.DoR_ParentGUID   = t2.DoR_ParentGUID)   OR (i.DoR_ParentGUID IS NULL AND t2.DoR_ParentGUID IS NULL) )
     AND   ((i.DoR_DokumentGUID = t2.DoR_DokumentGUID) OR (i.DoR_DokumentGUID IS NULL AND t2.DoR_DokumentGUID IS NULL) )
     )
