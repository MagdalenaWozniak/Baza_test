Create function CDN.Atr(@DeAID INT, @TypDok TEXT, @PodID INT, @PodTyp INT, @Bufor INT, @MagID INT, @OpeID INT, @TwrID INT, @AtrWartosc NVARCHAR(102), @AtrWartoscOd DECIMAL(16,4), @AtrWartoscDo DECIMAL(16,4), @DataOd INT, @DataDo INT)
returns table
as return
select Trn_TrnId as 'trnid', 0 as 'treid', Trn_DataOpe as 'data', Trn_NumerPelny as 'kod',
' ' as 'twrnazwa', Pod_kod as 'wartosc', ' ' as 'tre_jm', 0 as 'tre_iloscjm', 0 as 'tre_wartoscnetto', 0 as 'poziom', '' as 'tra_kod', 0 as 'tra_deaid', trn_typdokumentu, trn_korekta, CDN.TypDokumentu(trn_typdokumentu) as 'typdok'
from cdn.tranag join cdn.podmiotyview on pod_podmiottyp = trn_podmiottyp and pod_podid = trn_podid where trn_trnid in (select tre_trnid from cdn.TrEAtrybutyView
where (Tra_Wartosc LIKE @AtrWartosc OR @AtrWartosc = '')
AND (Tra_WartoscDecimal BETWEEN @AtrWartoscOd AND @AtrWartoscDo OR (@AtrWartoscOd = 0 AND @AtrWartoscDo = 0) )
and (tra_DeAID = @DeAID OR @DeAID = 0)
and (TrE_TwrID = @TwrID OR @TwrID=0) )
AND Trn_TypDokumentu IN (select NextIdInt from CDN.Text2TableInt(@TypDok))
AND (trn_podid = @PodID AND trn_podmiottyp = @PodTyp OR @PodTyp = 0)
AND (TrN_Bufor = @Bufor OR @Bufor=2)
AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
AND (TrN_MagZrdID = @MagID OR TrN_MagDocID = @MagID OR @MagID = 0)
AND TrN_DataOpe BETWEEN dateadd(day,@DataOd,'18001228') AND dateadd(day,@DataDo,'18001228')
AND TrN_Rodzaj not in (302100, 305100, 301100, 302200, 302202)
AND TrN_Bufor <> -1
union
select tre_trnid as 'trnid', tra_treid as 'treid', TrE_DataOpe as 'data', tre_twrkod as 'kod',
tre_twrnazwa as 'twrnazwa', tra_wartosc as 'wartosc', tre_jm as 'tre_jm', tre_iloscjm as 'tre_iloscjm', tre_wartoscnetto, 1 as 'poziom', tra_kod as 'tra_kod', tra_deaid as 'tra_deaid', 0 as 'trn_typdokumentu', 0 as 'trn_korekta', '' as 'typdok'
from cdn.TrEAtrybutyView
where (Tra_Wartosc LIKE @AtrWartosc OR @AtrWartosc = '')
AND (Tra_WartoscDecimal BETWEEN @AtrWartoscOd AND @AtrWartoscDo OR (@AtrWartoscOd = 0 AND @AtrWartoscDo = 0) )
and (tra_DeAID = @DeAID OR @DeAID = 0 )
and (TrE_TwrID = @TwrID OR @TwrID=0)
and tre_trnid in (select trn_trnid from cdn.tranag
where Trn_TypDokumentu IN (select NextIdInt from CDN.Text2TableInt(@TypDok))
AND (trn_podid = @PodID AND trn_podmiottyp = @PodTyp OR @PodTyp = 0)
AND (TrN_Bufor = @Bufor OR @Bufor=2)
AND (TrN_OpeZalID = @OpeID OR @OpeID = 0)
AND (TrN_MagZrdID = @MagID OR TrN_MagDocID = @MagID OR @MagID = 0)
AND TrN_DataOpe BETWEEN dateadd(day,@DataOd,'18001228') AND dateadd(day,@DataDo,'18001228')
AND TrN_Rodzaj not in (302100, 305100, 301100, 302200, 302202)
AND TrN_Bufor <> -1)
