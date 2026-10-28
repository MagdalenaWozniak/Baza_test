CREATE FUNCTION CDN.TwrInTwg( @wezel int )
RETURNS TABLE
AS RETURN
 (  SELECT GIDNumer = TwG_GIDNumer
    FROM CDN.TwrGrupy
    WHERE TwG_GrOTyp=-16 AND TwG_GIDTyp=16 AND TwG_GrONumer = @wezel
 )
