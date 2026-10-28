CREATE PROCEDURE CDN.EcodAwizoConsignmentXml
 @trnID   AS INT
,@awizoId  AS INT
AS
BEGIN
    DECLARE @PackageId INT, @ParentId INT, @PackageNumber INT, @PackageType NVARCHAR(17),
   @PackageAdditionalInstructions NVARCHAR(35), @PackageDescription NVARCHAR(70),
   @SerialNumber NVARCHAR(25),
   @GrossWeightStr VARCHAR(17), @VolumeStr VARCHAR(17),
   @buyerTyp INT, @buyerId INT, @lineNumber INT
 SELECT TOP 1
  @buyerTyp = AWZ_PodTyp,
  @buyerId = AWZ_PodId
 FROM cdn.Awizo
 WHERE AWZ_AWZID = @awizoId
 SET @PackageNumber = 1
 SET @lineNumber = 0
 DECLARE packingSequenceCursor CURSOR FOR
 SELECT AWO_OpakowanieID, AWO_ParentID,
   AWO_Opis As PackageDescription,
   (SELECT Convert(NVARCHAR(17), AWTO_Kod)  FROM [CDN].[AwizoTypyOpakowan] WHERE AWTO_AWTOID = AWO_TypOpakowaniaId) As PackageType,
   (SELECT Convert(NVARCHAR(35),AWTO_Nazwa) FROM [CDN].[AwizoTypyOpakowan] WHERE AWTO_AWTOID = AWO_TypOpakowaniaId) As PackageAdditionalInstructions,
   AWO_KodSSCC,
   LTrim(Str(AWO_Waga,15,3)) As GrossWeightStr,
   LTrim(Str(AWO_Objetosc,15,3)) As VolumeStr
 FROM [CDN].[AwizoOpakowania] WHERE AWO_AWZId = @awizoId AND AWO_OpakowanieId > 0
 OPEN packingSequenceCursor
 WHILE 1=1
 BEGIN
  FETCH NEXT FROM packingSequenceCursor INTO @PackageId, @ParentId, @PackageDescription, @PackageType, @PackageAdditionalInstructions, @SerialNumber, @GrossWeightStr, @VolumeStr
  IF @@FETCH_STATUS <> 0 BREAK
  exec cdn.EcodAwizoInsert 'Packing-Sequence',  '', -1
   exec cdn.EcodAwizoInsert 'Packing-Reference',  '', -1
    exec cdn.EcodAwizoInsert 'PackageId', @PackageId, 0
    IF @ParentId IS NOT NULL AND @ParentId > 0
    BEGIN
     exec cdn.EcodAwizoInsert 'ParentId', @ParentId, 0
    END
    exec cdn.EcodAwizoInsert 'PackageNumber', @PackageNumber, 0
    exec cdn.EcodAwizoInsert 'PackageType',  @PackageType, 0
    exec cdn.EcodAwizoInsert 'PackageDescription', @PackageDescription, 11
    exec cdn.EcodAwizoInsert 'SerialNumber', @SerialNumber, 0
    exec cdn.EcodAwizoInsert 'AdditionalInstructions', @PackageAdditionalInstructions, 11
    exec cdn.EcodAwizoInsert 'Measurements',  '', -1
     exec cdn.EcodAwizoInsert 'GrossWeight', @GrossWeightStr, 0
     exec cdn.EcodAwizoInsert 'Volume',  @VolumeStr, 0
    exec cdn.EcodAwizoInsert 'Measurements', '', 1
   exec cdn.EcodAwizoInsert 'Packing-Reference', '', 1
   exec cdn.EcodAwizoPackingSequenceLinesXml @awizoId=@awizoId, @packageId=@PackageId, @buyerTyp=@buyerTyp, @buyerId=@buyerId, @lineNumber=@lineNumber OUTPUT
  exec cdn.EcodAwizoInsert 'Packing-Sequence', '',  1
 END
 CLOSE packingSequenceCursor
 DEALLOCATE packingSequenceCursor
END
