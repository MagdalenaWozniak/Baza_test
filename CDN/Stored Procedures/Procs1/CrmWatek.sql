CREATE PROCEDURE cdn.CrmWatek
@crkId  AS INT,
@parentId AS INT
AS
BEGIN
 SET NOCOUNT ON;
 IF @parentId is null OR @parentId = 0
 BEGIN
  IF EXISTS(
   SELECT *
   FROM cdn.CrmKontakty
   WHERE (CRK_ParId Is Not NULL AND CRK_ParId = @crkId)
  )
   SELECT *
   FROM cdn.CrmKontakty
   WHERE CrK_WatekId = @crkId
   ORDER BY CRK_TerminOd
  ELSE
   SELECT * FROM cdn.CrmKontakty WHERE 1=0
 END
 ELSE
 BEGIN
  SELECT  *
  FROM cdn.CrmKontakty
  WHERE CrK_WatekId = @parentId
  ORDER BY CRK_TerminOd
 END
 SET NOCOUNT OFF;
END
