CREATE    PROCEDURE CDN.KRo_UstawDateRozrachunku
@ASrcKRoID   int,
@ADstKRoID   int,
@ADateType    int,
@AToDay       datetime
AS
    --  @ADateType {1,2,3,4,5}
    --  1 - data wystawienia
    --  2 - data operacji
    --  3 - data księgowania
    --  4 - termin płatności
    --  5 - data bieżąca
    -- @AToDay
    -- data bieżąca w O!
  SET NOCOUNT ON
  declare @SrcDate datetime
  declare @DstDate datetime
  select @SrcDate =
  case @ADateType
  when 1 then case when KRo_Typ = 1 then DeE_DataWys     else  BOE_DataDok   end
  when 2 then case when KRo_Typ = 1 then DeE_DataOpe     else  BOE_DataDok   end
  when 3 then case when KRo_Typ = 1 then DeN_DataDok      else  BOE_DataDok end
  when 4 then case when KRo_Typ = 1 then DeE_TerminRoz    else  BOE_TerminRoz end
  else
   @AToDay
  end
  from
  CDN.KsiRozrachunki
  left outer join CDN.DekretyElem   on (KRo_Typ= 1 and KRo_DeEID = DeE_DeEID)
  left outer join CDN.DekretyNag   on (DeE_DeNID = DeN_DeNID)
  left outer join CDN.BOElem    on (KRo_Typ= 2 and KRo_BoEID = BoE_BoEID)
  where KRo_KRoID = @ASrcKRoID
  select @DstDate =
  case @ADateType
  when 1 then case when KRo_Typ = 1 then DeE_DataWys     else  BOE_DataDok   end
  when 2 then case when KRo_Typ = 1 then DeE_DataOpe     else  BOE_DataDok   end
  when 3 then case when KRo_Typ = 1 then DeN_DataDok      else  BOE_DataDok end
  when 4 then case when KRo_Typ = 1 then DeE_TerminRoz    else  BOE_TerminRoz end
  else
   @AToDay
  end
  from
  CDN.KsiRozrachunki
  left outer join CDN.DekretyElem   on (KRo_Typ= 1 and KRo_DeEID = DeE_DeEID)
  left outer join CDN.DekretyNag   on (DeE_DeNID = DeN_DeNID)
  left outer join CDN.BOElem    on (KRo_Typ= 2 and KRo_BoEID = BoE_BoEID)
  where KRo_KRoID = @ADstKRoID
  update CDN.KsiRozrachunki
    set KRo_DataRoz = case when @SrcDate > @DstDate then @SrcDate else @DstDate end
  where KRo_KRoID = @ASrcKRoID
  update CDN.KsiRozrachunki
    set KRo_DataRoz = case when @SrcDate > @DstDate then @SrcDate else @DstDate end
  where KRo_KRoID = @ADstKRoID
  SET NOCOUNT OFF
