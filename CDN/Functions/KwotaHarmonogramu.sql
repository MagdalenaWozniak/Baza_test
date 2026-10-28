CREATE FUNCTION CDN.KwotaHarmonogramu( @typKwoty int, @id int, @data DateTime )
RETURNS decimal(15,2)
AS
BEGIN
 -- @typKwoty {1, 2, 3, 4}
 --  1 - kwota zaksięgowana w okresie (@data)
 -- 2 - suma kwot harmonogramu (narastająco) do daty (@data) włącznie
 -- 3 - suma kwot zaksięgowanych (narastająco) do daty (@data) włącznie
 --  4 - kwota zaksięgowana ogółem dla pozycji
 --  5 - suma kwot harmonogramu dla wszystkich elementów księgowania okresowego
 --  6 - kwota zaksięgowana ogółem wszystkich elementów księgowania okresowego
 DECLARE @result decimal(15,2)
 DECLARE @yyyymm int
 set @yyyymm = 100 * Year(@data) + Month(@data)
 if @typKwoty = 1
  select @result = sum(DeE_Kwota) from cdn.DekretyElem where DeE_DokumentTyp=105 and DeE_DokumentId = @id and (100*Year(DeE_DataOpe) + Month(DeE_DataOpe)) = @yyyymm
 else if @typKwoty = 2
  select @result = sum(IsNull(OkH_Kwota, 0.00)) from cdn.OkresoweHarmonogram where OkH_OkEId = @id and (100*Year(OkH_Data) + Month(OkH_Data)) <= @yyyymm
 else if @typKwoty = 3
  select @result = sum(IsNull(DeE_Kwota, 0.00)) from cdn.DekretyElem where DeE_DokumentTyp=105 and DeE_DokumentId = @id and (100*Year(DeE_DataOpe) + Month(DeE_DataOpe)) <= @yyyymm
 else if @typKwoty = 4
  select @result = sum(IsNull(DeE_Kwota, 0.00)) from cdn.DekretyElem where DeE_DokumentTyp=105 and DeE_DokumentId = @id
 else if @typKwoty = 5
  select @result = sum(IsNull(OkE_KwotaWartosc, 0.00)) from cdn.OkresoweElem where OkE_OkNId = @id
 else if @typKwoty = 6
  select @result = sum(IsNull(DeE_Kwota, 0.00)) from cdn.DekretyElem where DeE_DokumentTyp=105 and DeE_DokumentId in (select OkE_OkEId from cdn.OkresoweElem where OkE_OkNId=@id)
 if @typKwoty <> 1
  set @result = IsNull(@result, 0.00)
 RETURN @result
END
