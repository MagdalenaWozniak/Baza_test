create function CDN.DokAtr(@DeAID INT, @TypDok TEXT, @PodID INT, @PodTyp INT, @Bufor INT, @MagID INT, @OpeID INT, @AtrWartosc NVARCHAR(102), @AtrWartoscOd DECIMAL(16,4), @AtrWartoscDo DECIMAL(16,4), @DataOd INT, @DataDo INT)
returns table
as return
select pod_kod, dat_wartosctxt, dea_kod, dea_format, trn_numerpelny, trn_dataope, trn_trnid, CDN.TypDokumentu(trn_typdokumentu) as 'TrN_TypDok', trn_korekta, trn_bufor, TrN_RazemNetto, trn_typdokumentu
from cdn.DokAtrybuty
join cdn.tranag on dat_trnid = trn_trnid
join cdn.podmiotyview on pod_podmiottyp = trn_podmiottyp and pod_podid = trn_podid
join cdn.defatrybuty on dea_deaid = dat_deaid
where (dat_Wartosctxt LIKE @AtrWartosc OR @AtrWartosc = '')
AND (DAt_WartoscDecimal BETWEEN @AtrWartoscOd AND @AtrWartoscDo OR (@AtrWartoscOd = 0 AND @AtrWartoscDo = 0) )
and (dat_DeAID = @DeAID OR @DeAID = 0 )
and dat_trnid in (select trn_trnid from cdn.tranag
where Trn_TypDokumentu IN (select NextIdInt from CDN.Text2TableInt(@TypDok))
AND (trn_podid = @PodID AND trn_podmiottyp = @PodTyp OR @PodTyp = 0)
AND (TrN_Bufor = @Bufor OR @Bufor=2)
AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
AND (TrN_MagZrdID = @MagID OR TrN_MagDocID = @MagID OR @MagID = 0)
AND TrN_DataOpe BETWEEN dateadd(day,@DataOd,'18001228') AND dateadd(day,@DataDo,'18001228')
AND TrN_Rodzaj not in (302100, 305100, 301100, 302200, 302202)
AND TrN_Bufor <> -1)
