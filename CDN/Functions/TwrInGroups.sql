CREATE FUNCTION [CDN].[TwrInGroups](@singleGroups text , @groupsWithChildren text)
RETURNS @Twr TABLE (TwrID INT, PRIMARY KEY (TwrId))
AS
BEGIN
 INSERT INTO @Twr
     SELECT TwrID FROM CDN.TwrInSubTwG(@singleGroups, 0)
 INSERT INTO @Twr
     SELECT TwrID FROM CDN.TwrInSubTwG(@groupsWithChildren , 1) where TwrID not in (select TwrID from @Twr)
 RETURN
END
