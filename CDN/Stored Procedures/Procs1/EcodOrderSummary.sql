CREATE PROCEDURE CDN.EcodOrderSummary
@TrnID            AS INT
AS
BEGIN
    DECLARE @TotalLines INT, @TotalOrderedAmount DECIMAL(15,3), @TotalNetAmount DECIMAL(15,2)
    SELECT
    @TotalLines = Count(*),
    @TotalOrderedAmount = Sum(TrE_IloscJM),
    @TotalNetAmount = Sum(TrE_WartoscNetto)
    FROM cdn.TraElem
    WHERE TrE_TrNId = @TrnID
    GROUP BY TrE_TrNId
 exec cdn.EcodOrderInsert 'Order-Summary',  '', -1
  exec cdn.EcodOrderInsert 'TotalLines',    @TotalLines, 0
  exec cdn.EcodOrderInsert 'TotalOrderedAmount',  @TotalOrderedAmount, 0
  exec cdn.EcodOrderInsert 'TotalNetAmount',   @TotalNetAmount, 0
 exec cdn.EcodOrderInsert 'Order-Summary',  '', 1
END
