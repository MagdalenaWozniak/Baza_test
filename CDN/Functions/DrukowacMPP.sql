CREATE function [CDN].[DrukowacMPP](@TrnId int)
returns int
as
begin
 return (SELECT CASE WHEN Trn_DataWys >= CONVERT(datetime,'2019-11-01',120) AND TrN_DataOpe >= CONVERT(datetime,'2019-11-01',120) THEN TrN_SplitPay ELSE 0 END FROM cdn.TraNag WHERE trn_trnid = @TrnId)
 /*return (SELECT CASE WHEN
    T1.TrN_Export IN (5,0)  AND
    T1.TrN_SplitPay = 1  AND
    T1.TrN_Finalny = 0  AND
    T1.TrN_WartoscSP > 0 AND
    T1.TrN_RazemBrutto > 15000  AND
    T1.Trn_DataOpe >= '2019-11-01' AND
    T1.TrN_DataDok >= '2019-11-01' AND
    T1.TrN_DataWys >= '2019-11-01'
    THEN 1 ELSE 0 END
   FROM cdn.TraNag T1
   WHERE trn_trnid = ( SELECT CASE ISNULL(T2.TrN_ZwrId, 0) WHEN 0 THEN T2.TrN_TrNID ELSE T2.TrN_ZwrId END
        FROM cdn.TraNag T2 where T2.TrN_TrNID = @TrnId))*/
end
