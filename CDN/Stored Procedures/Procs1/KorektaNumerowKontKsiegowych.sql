create  procedure  CDN.KorektaNumerowKontKsiegowych @OObID Int
As
Begin
 while exists( select * from cdn.Konta where Acc_OObId = @OObID and (Acc_NumerIdx like('%''%') or Acc_NumerIdx like('% %') or Acc_Segment like('%-%') ) )
 begin
  declare @acc_id    int
  declare @acc_segment NVARCHAR(100)
  declare @acc_numeridx NVARCHAR(100)
  declare @acc_numer  NVARCHAR(100)
  declare @old_acc_numeridx NVARCHAR(100)
  declare @old_acc_numer  NVARCHAR(100)
  declare @old_acc_segment NVARCHAR(100)
  declare @new_acc_numeridx NVARCHAR(100)
  declare @new_acc_numer  NVARCHAR(100)
  select top 1  @acc_id      = Acc_AccID,
         @acc_segment    = Acc_Segment,
         @old_acc_numeridx = Acc_NumerIdx,
         @old_acc_numer  = Acc_Numer
  from CDN.Konta
  where  Acc_OObID = @OObID
  and  (Acc_NumerIdx like ('%''%') or Acc_NumerIdx like('% %') or Acc_Segment like('%-%'))
  order by Acc_NumerIdx asc
  set @old_acc_segment = @acc_segment
  set @acc_segment = replace(@acc_segment, '''', '_')
  set @acc_segment = replace(@acc_segment, ' ', '_')
  set @acc_segment = replace(@acc_segment, '-', '_')
  declare @sufixIdx int
  Set @sufixIdx = 0
  declare @AccId   int
  select @AccId = Acc_ParId from CDN.Konta where Acc_AccID=@acc_id
  set @acc_numeridx   = @acc_segment
  While @AccId Is NOT NULL
  Begin
   IF NOT EXISTS (SELECT * FROM CDN.Konta WHERE Acc_AccId = @AccId) BREAK
   SELECT @AccId = Acc_ParId, @acc_numeridx = Acc_Segment + CASE @acc_numeridx WHEN '' THEN @acc_numeridx ELSE '.' + @acc_numeridx END FROM CDN.Konta WHERE Acc_AccId = @AccId
  End
  if exists( select * from cdn.konta where Acc_OObId = @OObID and Acc_NumerIdx=@acc_numeridx )
  begin
   while exists( select * from CDN.Konta where Acc_OObId = @OObID and Acc_NumerIdx=@acc_numeridx+'_'+cast(@sufixIdx as NVARCHAR(2)))
   begin
    set @sufixIdx = @sufixIdx + 1
   end
   set @acc_numeridx = @acc_numeridx+'_'+cast(@sufixIdx as NVARCHAR(2))
   set @acc_segment = @acc_segment+'_'+cast(@sufixIdx as NVARCHAR(2))
  end
  if LEN( @acc_numeridx) > 50
  begin
   exec CDN.RiseOptimaException 32495, 's1', @old_acc_numer
   BREAK
  end
  if LEN( @acc_segment) > 20
  begin
   exec CDN.RiseOptimaException 32496, 's1', @old_acc_segment, 's2', @old_acc_numer
   BREAK
  end
  update cdn.konta set  Acc_Segment  = @acc_segment,
             Acc_NumerIdx  = @acc_numeridx,
             Acc_Numer   = replace(@acc_numeridx, '.', '-')
  where Acc_AccID = @acc_id
  select @new_acc_numer = Acc_Numer, @new_acc_numeridx = Acc_NumerIdx from CDN.Konta where Acc_AccID = @acc_id
  -- poprawa na dekretach i przeszacowaniach walut
  UPDATE CDN.DekretyElem SET DeE_KontoWn=@new_acc_numer WHERE DeE_AccWnId=@acc_id
  UPDATE CDN.DekretyElem SET DeE_KontoMa=@new_acc_numer WHERE DeE_AccMaId=@acc_id
  UPDATE CDN.PrzeszacWalutNag SET PWN_KontoWn=@new_acc_numer WHERE PWN_AccWnId=@acc_id
  UPDATE CDN.PrzeszacWalutNag SET PWN_KontoMa=@new_acc_numer WHERE PWN_AccMaId=@acc_id
  UPDATE CDN.PrzeszacWalutElem SET PWE_KontoWn=@new_acc_numer WHERE PWE_AccWnId=@acc_id
  UPDATE CDN.PrzeszacWalutElem SET PWE_KontoMa=@new_acc_numer WHERE PWE_AccMaId=@acc_id
        UPDATE CDN.KsiDokNag SET KDN_KontoNumer = @new_acc_numer, KDN_KontoNumerIdx = @new_acc_numeridx where KDN_AccID = @acc_id
        UPDATE CDN.KsiRozrachunki SET KRo_Konto = @new_acc_numer, KRo_KontoIdx = @new_acc_numeridx where KRo_KontoIdx = @old_acc_numeridx
        -- a to część Bartkowa
  -- PB Bartkowa i niestety problemowa.
        --update CDN.Kontrahenci
        --set Knt_KontoDost = replace(Knt_KontoDost, '''', '_')
        --update CDN.Kontrahenci
        --set Knt_KontoOdb  =  replace(Knt_KontoOdb, '''', '_')
        --update CDN.Kontrahenci
        --set Knt_KontoDost = replace(Knt_KontoDost, ' ', '_')
        --update CDN.Kontrahenci
        --set Knt_KontoOdb  =  replace(Knt_KontoOdb, ' ', '_')
        --update CDN.kategorie
        --set Kat_KontoSegmentMA = replace(Kat_KontoSegmentMA, ' ', '_')
        --update CDN.kategorie
        --set Kat_KontoSegmentMA = replace(Kat_KontoSegmentMA, '''', '_')
        --update CDN.kategorie
        --set Kat_KontoSegmentWn = replace(Kat_KontoSegmentWN, ' ', '_')
        --update CDN.kategorie
        --set Kat_KontoSegmentWn = replace(Kat_KontoSegmentWn, '''', '_')
        --update CDN.BnkZapisy
        --set BZp_KontoPrzeciwstawne = replace(BZp_KontoPrzeciwstawne, '''', '_')
        --where exists (select * from cdn.bnkraporty where bzp_brpid=brp_brpid AND BRp_DekID is null)
        --update CDN.BnkZapisy
        --set BZp_KontoPrzeciwstawne = replace(BZp_KontoPrzeciwstawne, ' ', '_')
        --where exists (select * from cdn.bnkraporty where bzp_brpid=brp_brpid AND BRp_DekID is null)
 end
 update CDN.Kontrahenci set Knt_KontoDost = replace(Knt_KontoDost, '''', '_') where Knt_KontoDost like ('%''%')
 update CDN.Kontrahenci set Knt_KontoOdb  =  replace(Knt_KontoOdb, '''', '_') where Knt_KontoOdb like ('%''%')
 update CDN.Kontrahenci set Knt_KontoDost = replace(Knt_KontoDost, ' ', '_') where Knt_KontoDost like ('% %')
 update CDN.Kontrahenci set Knt_KontoOdb  =  replace(Knt_KontoOdb, ' ', '_') where Knt_KontoOdb like ('% %')
 update CDN.kategorie set Kat_KontoSegmentMA = replace(Kat_KontoSegmentMA, ' ', '_') where Kat_KontoSegmentMA like ('% %')
 update CDN.kategorie set Kat_KontoSegmentMA = replace(Kat_KontoSegmentMA, '''', '_' )where Kat_KontoSegmentMA like ('%''%')
 update CDN.kategorie set Kat_KontoSegmentWn = replace(Kat_KontoSegmentWN, ' ', '_') where Kat_KontoSegmentWn like ('% %')
 update CDN.kategorie set Kat_KontoSegmentWn = replace(Kat_KontoSegmentWn, '''', '_') where Kat_KontoSegmentWn like ('%''%')
 update CDN.BnkZapisy set BZp_KontoPrzeciwstawne = replace(BZp_KontoPrzeciwstawne, '''', '_')
 where
 BZp_KontoPrzeciwstawne like ('%''%')
 and exists (select * from cdn.bnkraporty where bzp_brpid=brp_brpid AND BRp_DekID is null)
 update CDN.BnkZapisy
 set BZp_KontoPrzeciwstawne = replace(BZp_KontoPrzeciwstawne, ' ', '_')
 where
 BZp_KontoPrzeciwstawne like ('% %')
 and exists (select * from cdn.bnkraporty where bzp_brpid=brp_brpid AND BRp_DekID is null)
End
