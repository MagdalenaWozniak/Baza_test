create procedure cdn.OParametryWspolpracy
  @JestWspolpraca tinyint,
  @Serwer nvarchar(128),
  @Baza nvarchar(128)
 as
 set nocount on
  begin try
   update cdn.cfgwartosci set cfw_wartosc = @JestWspolpraca
     where cfw_cfkid = (select top 1 cfk_cfkid from cdn.cfgklucze where cfk_nazwa like 'Wsp%%praca z XL')
   if not exists (select top 1 cfk_cfkid from cdn.cfgklucze where cfk_nazwa = 'Serwer bazy XL')
   begin
      declare @Parametry int
      select @Parametry = cfk_cfkid from cdn.cfgklucze where cfk_nazwa = 'Parametry'
   INSERT INTO [CDN].[CfgKlucze]
        ([CFK_ParentId]
        ,[CFK_Nazwa]
        ,[CFK_OkresOd]
        ,[CFK_OkresDo]
        ,[CFK_OpeZalId]
        ,[CFK_StaZalId]
        ,[CFK_TS_Zal]
        ,[CFK_OpeModId]
        ,[CFK_StaModId]
        ,[CFK_TS_Mod])
     VALUES
        (@Parametry
        ,'Serwer bazy XL'
        , CONVERT(datetime,'1900.01.01',102)
        , CONVERT(datetime,'3000.01.01',102)
        , NULL
        , NULL
        , GETDATE()
        , NULL
        , NULL
        , GETDATE())
    INSERT INTO [CDN].[CfgWartosci]
        ([CFW_CfkId]
        ,[CFW_Nazwa]
        ,[CFW_Typ]
        ,[CFW_Wartosc]
        ,[CFW_OpeZalId]
        ,[CFW_StaZalId]
        ,[CFW_TS_Zal]
        ,[CFW_OpeModId]
        ,[CFW_StaModId]
        ,[CFW_TS_Mod])
     VALUES
        (SCOPE_IDENTITY()
        ,''
        ,8
        ,@Serwer
        ,NULL
        ,NULL
        ,GETDATE()
        ,NULL
        ,NULL
        ,GETDATE())
        INSERT INTO [CDN].[CfgKlucze]
        ([CFK_ParentId]
        ,[CFK_Nazwa]
        ,[CFK_OkresOd]
        ,[CFK_OkresDo]
        ,[CFK_OpeZalId]
        ,[CFK_StaZalId]
        ,[CFK_TS_Zal]
        ,[CFK_OpeModId]
        ,[CFK_StaModId]
        ,[CFK_TS_Mod])
     VALUES
        (@Parametry
        ,'Baza danych XL'
        , CONVERT(datetime,'1900.01.01',102)
        , CONVERT(datetime,'3000.01.01',102)
        , NULL
        , NULL
        , GETDATE()
        , NULL
        , NULL
        , GETDATE())
    INSERT INTO [CDN].[CfgWartosci]
        ([CFW_CfkId]
        ,[CFW_Nazwa]
        ,[CFW_Typ]
        ,[CFW_Wartosc]
        ,[CFW_OpeZalId]
        ,[CFW_StaZalId]
        ,[CFW_TS_Zal]
        ,[CFW_OpeModId]
        ,[CFW_StaModId]
        ,[CFW_TS_Mod])
     VALUES
        (SCOPE_IDENTITY()
        ,''
        ,8
        ,@Baza
        ,NULL
        ,NULL
        ,GETDATE()
        ,NULL
        ,NULL
        ,GETDATE())
   end
   else
   begin
    update cdn.cfgwartosci set cfw_wartosc = @Serwer
        where cfw_cfkid = (select top 1 cfk_cfkid from cdn.cfgklucze where cfk_nazwa = 'Serwer bazy XL')
    update cdn.cfgwartosci set cfw_wartosc = @Baza
        where cfw_cfkid = (select top 1 cfk_cfkid from cdn.cfgklucze where cfk_nazwa = 'Baza danych XL')
   end
  end try
  begin catch
  end catch
 set nocount off
