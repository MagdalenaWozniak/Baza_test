CREATE Function [CDN].[OfertaKontrahenci] (@OfdId int)
 Returns varchar(255)
Begin
 declare @nazwa varchar(255)
 declare @ilosc   int
 select @ilosc = COUNT(*) from CDN.OfertyKnt Where OfK_OfDId = @OfdId
 select TOP (1) @nazwa = Cdn.PodmiotyView.Pod_Kod from CDN.OfertyKnt
  JOIN CDN.PodmiotyView ON CDN.PodmiotyView.Pod_PodId = CDN.OfertyKnt.OfK_PodID
  AND CDN.PodmiotyView.Pod_PodmiotTyp = cdn.OfertyKnt.OfK_PodmiotTyp
 Where OfK_OfDId = @OfdId ORDER BY Cdn.PodmiotyView.Pod_Kod
 if(@ilosc>1) SET @nazwa = @nazwa + ' + '+ LTRIM( STR(@ilosc-1))
 Return @nazwa
END
