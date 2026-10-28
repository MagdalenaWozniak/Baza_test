CREATE FUNCTION cdn.CrmKontrolaTerminu (
@Id   INT,
@ParentId INT,
@OpiekunTyp INT,
@OpiekunId  INT,
@DataOd  DATETIME,
@DataDo  DATETIME,
@Mode  INT,
@parentCyklId INT = 0)
  RETURNS     NVARCHAR(1280)
  AS
  BEGIN
 DECLARE @wynik NVARCHAR(1280)
 SET @wynik = cdn.CrmKontrolaTerminuDlaZadania(@Id, @ParentId, @OpiekunTyp, @OpiekunId, @DataOd, @DataDo, @Mode, 0, @parentCyklId)
 RETURN @wynik
  END
