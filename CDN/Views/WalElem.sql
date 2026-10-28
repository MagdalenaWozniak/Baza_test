
    CREATE VIEW [CDN].[WalElem](
       [WaE_Symbol]
      ,[WaE_KursTS]
      ,[WaE_Lp]
      ,[WaE_KursM]
      ,[WaE_KursL]
    )
    AS
    SELECT
       [WaE_Symbol]
      ,[WaE_KursTS]
      ,[WaE_Lp]
      ,[WaE_KursM]
      ,[WaE_KursL]
    FROM [SRV1].[CDN_KNF_ONE].[CDN].[WalElemView]