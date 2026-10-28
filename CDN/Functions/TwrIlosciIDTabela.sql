CREATE FUNCTION CDN.TwrIlosciIDTabela ( @TwrId INT, @MagId VARCHAR(100), @Data DATETIME )
 RETURNS     TABLE
AS
RETURN
SELECT ZZ FROM
(
    SELECT TwI_TwIId AS ZZ, ROW_NUMBER () OVER (PARTITION BY TwI_MagId ORDER BY
       TwI_Data DESC) rn  From CDN.TwrIlosci
    JOIN CDN.Text2TableVarchar (@MagId) ON NextIdVarchar = TwI_MagId
    Where TwI_TwrId = @TwrId  And TwI_Data <= @Data
) AS Der WHERE rn=1
