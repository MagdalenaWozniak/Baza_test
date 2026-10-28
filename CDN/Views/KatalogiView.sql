
  CREATE VIEW [CDN].[KatalogiView](
     [KtlV_DonTyp]
    ,[KtlV_KtlId]
    ,[KtlV_Symbol]
    ,[KtlV_Nazwa]
    ,[KtlV_Numeracja]
    ,[KtlV_OpeZalID]
    ,[KtlV_StaZalId]
    ,[KtlV_TS_Zal]
    ,[KtlV_OpeModID]
    ,[KtlV_StaModId]
    ,[KtlV_TS_Mod]
    ,[KtlV_SSID]
  )
  AS
  SELECT
    2
    ,[Ktl_KtlId]
    ,[Ktl_Symbol]
    ,[Ktl_Nazwa]
    ,[Ktl_Numeracja]
    ,[Ktl_OpeZalID]
    ,[Ktl_StaZalId]
    ,[Ktl_TS_Zal]
    ,[Ktl_OpeModID]
    ,[Ktl_StaModId]
    ,[Ktl_TS_Mod]
    ,[Ktl_SSID]
  FROM  [SRV1].[CDN_KNF_ONE].[CDN].[Katalogi]
  UNION ALL
  SELECT
    1
    ,[Ktl_KtlId]
    ,[Ktl_Symbol]
    ,[Ktl_Nazwa]
    ,[Ktl_Numeracja]
    ,[Ktl_OpeZalID]
    ,[Ktl_StaZalId]
    ,[Ktl_TS_Zal]
    ,[Ktl_OpeModID]
    ,[Ktl_StaModId]
    ,[Ktl_TS_Mod]
    ,[Ktl_SSID]
  FROM [CDN].[Katalogi]