CREATE FUNCTION CDN.NumerPozycjiZestawienia(@zkn_id int, @parent_id int, @lp_position int, @numeracja varchar(4))
RETURNS int
AS
BEGIN
 declare @Result int = 0;
 declare @numeracja_len int = len(@numeracja);
 if @parent_id is not null
  SELECT @Result = COUNT(*) FROM CDN.ZestKsiPoz join CDN.ZestKsiNag on (ZKN_ZKNId=ZKP_ZKNId)
  WHERE
  Zkp_ZkNId = @zkn_id
  and Zkp_ParId=@parent_id
  and len(case when ZKP_NUMERACJA='AUTO' then SUBSTRING(ZKN_Numeracja, ZKP_Poziom, 1) else ZKP_NUMERACJA end) = @numeracja_len
  and ascii(case when ZKP_NUMERACJA='AUTO' then SUBSTRING(ZKN_Numeracja, ZKP_Poziom, 1) else ZKP_NUMERACJA end) = ascii(@numeracja)
  and ZKP_Lp <= @lp_position
 else
  SELECT @Result = COUNT(*) FROM CDN.ZestKsiPoz  join CDN.ZestKsiNag on (ZKN_ZKNId=ZKP_ZKNId)
  WHERE
  Zkp_ZkNId = @zkn_id
  and Zkp_ParId is null
  and len(case when ZKP_NUMERACJA='AUTO' then SUBSTRING(ZKN_Numeracja, ZKP_Poziom, 1) else ZKP_NUMERACJA end) = @numeracja_len
  and ascii(case when ZKP_NUMERACJA='AUTO' then SUBSTRING(ZKN_Numeracja, ZKP_Poziom, 1) else ZKP_NUMERACJA end) = ascii(@numeracja)
  and ZKP_Lp <= @lp_position
 return IsNull(@Result, 0);
END
