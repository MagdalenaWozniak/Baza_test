CREATE FUNCTION [CDN].[TwrInSubTwG](@wezel text , @CzyPodGrupy int)
RETURNS @Twr TABLE (TwrID INT, PRIMARY KEY (TwrId))
AS
BEGIN
declare @TwrGrupy TABLE  (TwGID INT, GIDNumer INT, GrONumer INT, Poziom INT)
 INSERT INTO @TwrGrupy (TwGID, GIDNumer,  GrONumer, Poziom)
     SELECT TwG_TwGID, TwG_GIDNumer, TwG_GrONumer, 0
 FROM CDN.TwrGrupy WHERE TwG_GrOTyp=-16 AND TwG_GIDTyp=-16 AND TwG_GIDNumer
 IN (select nextidint from cdn.Text2TableIntNew(@wezel) )
if @CzyPodGrupy = 1
begin
 DECLARE @Poziom INT
 SET @Poziom = 0
 WHILE 1=1
 BEGIN
  INSERT INTO @TwrGrupy (TwGID, GidNumer, GroNumer, Poziom)
  SELECT
   TwG_TwGID,
   TwG_GIDNumer,
   TwG_GroNumer,
   @Poziom + 1
  FROM
   @TwrGrupy JOIN CDN.TwrGrupy ON TwG_GrOTyp=-16 AND TwG_GIDTyp=-16 AND TwG_GrONumer = GidNumer AND Poziom = @Poziom
     --WHERE TwG_GidNumer > @wezel
  IF @@ROWCOUNT = 0 BREAK
  SET @Poziom = @Poziom + 1
 END
insert into @Twr
    SELECT distinct TwG_GIDNumer
    FROM CDN.TwrGrupy
    WHERE TwG_GrOTyp=-16 AND TwG_GIDTyp=16 AND TwG_GrONumer in(select GidNumer from @TwrGrupy)
end
else
insert into @Twr
SELECT distinct TwG_GIDNumer
    FROM CDN.TwrGrupy
    WHERE TwG_GrOTyp=-16 AND TwG_GIDTyp=16 AND TwG_GrONumer  in(select GidNumer from @TwrGrupy)
 RETURN
END
