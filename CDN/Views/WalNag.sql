
    CREATE VIEW [CDN].[WalNag](
       [WaN_Symbol]
      ,[WaN_KontoPlus]
      ,[WaN_KontoMinus]
      ,[WaN_Nazwa]
      ,[WaN_Panstwo]
      ,[WaN_Slownie1]
      ,[WaN_Slownie2]
      ,[WaN_Aktywna]
      ,[WaN_Wsk]
      ,[WaN_SymbolEMU]
      ,[WaN_Parytet]
    )
    AS
    SELECT
       [WaN_Symbol]
      ,[WaN_KontoPlus]
      ,[WaN_KontoMinus]
      ,[WaN_Nazwa]
      ,[WaN_Panstwo]
      ,[WaN_Slownie1]
      ,[WaN_Slownie2]
      ,[WaN_Aktywna]
      ,[WaN_Wsk]
      ,[WaN_SymbolEMU]
      ,[WaN_Parytet]
    FROM [SRV1].[CDN_KNF_ONE].[CDN].[WalNagView]