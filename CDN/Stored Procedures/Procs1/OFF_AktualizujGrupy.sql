CREATE  PROCEDURE CDN.OFF_AktualizujGrupy
  @Gru_Typ    SMALLINT,
  @Gru_Nazwa  nvarchar(20),
  @Gru_Opis   nvarchar(50)
AS
  SET NOCOUNT ON
  DECLARE  @Gru_GruId INT
  SELECT TOP 1 @Gru_GruId = Gru_GruId
    FROM  cdn.Grupy
    WHERE Gru_Typ   = @Gru_Typ
      AND Gru_Nazwa = @Gru_Nazwa
  IF @Gru_GruId IS NULL
    INSERT INTO cdn.Grupy (  Gru_Typ,  Gru_Nazwa,  Gru_Opis )
      VALUES              ( @Gru_Typ, @Gru_Nazwa, @Gru_Opis )
  ELSE
    UPDATE cdn.Grupy SET Gru_Nazwa = @Gru_Nazwa WHERE Gru_GruID = @Gru_GruId
  SET NOCOUNT OFF
