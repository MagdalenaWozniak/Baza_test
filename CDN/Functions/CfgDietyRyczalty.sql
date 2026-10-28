CREATE FUNCTION CDN.CfgDietyRyczalty(@NaDzien DateTime)
RETURNS @Result TABLE(  id int, KodKraju nvarchar(10), NazwaKraju nvarchar(100), Waluta nvarchar(3), Dieta decimal(15,2), Ryczalt decimal(15,2), Limit decimal(15,2), DataObowiazywania DateTime)
AS
BEGIN
 insert into @Result (Id, KodKraju, NazwaKraju, Waluta, Dieta, Ryczalt, Limit, DataObowiazywania)
 select
 Id,
 kod,
 nazwa,
 CfgWaluta.CFW_Wartosc,
 case when IsNull(CfgDieta.CFW_Wartosc,'') <> '' then CONVERT(decimal(15,2),replace(CfgDieta.CFW_Wartosc, ',', '.'))  end,
 case when IsNull(CfgRyczalt.CFW_Wartosc,'') <> ''  then CONVERT(decimal(15,2),replace(CfgRyczalt.CFW_Wartosc, ',', '.'))  end,
 case when IsNull(CfgLimit.CFW_Wartosc,'') <> '' then CONVERT(decimal(15,2),replace(CfgLimit.CFW_Wartosc, ',', '.'))  end,
 CfgKeyDieta.CFK_OkresOd
 from CDN.ListaPanstw()
 left outer join CDN.CfgKlucze CfgKeyWaluta on (CfgKeyWaluta.CFK_Nazwa = key_waluta) left outer join CDN.CfgWartosci CfgWaluta on (CfgWaluta.CFW_CfkId=CfgKeyWaluta.Cfk_CfkID)
 left outer join CDN.CfgKlucze CfgKeyDieta on (CfgKeyDieta.CFK_Nazwa = key_dieta) left outer join CDN.CfgWartosci CfgDieta on (CfgDieta.CFW_CfkId=CfgKeyDieta.Cfk_CfkID)
 left outer join CDN.CfgKlucze CfgKeyRyczalt on (CfgKeyRyczalt.CFK_Nazwa = key_ryczalt) left outer join CDN.CfgWartosci CfgRyczalt on (CfgRyczalt.CFW_CfkId=CfgKeyRyczalt.Cfk_CfkID)
 left outer join CDN.CfgKlucze CfgKeyLimit on (CfgKeyLimit.CFK_Nazwa = key_limit) left outer join CDN.CfgWartosci CfgLimit on (CfgLimit.CFW_CfkId=CfgKeyLimit.Cfk_CfkID)
 where
 (@NaDzien between CfgKeyWaluta.CFK_OkresOd and DateAdd(Day, -1, CfgKeyWaluta.CFK_OkresDo)
 and @NaDzien between CfgKeyDieta.CFK_OkresOd and DateAdd(Day, -1, CfgKeyDieta.CFK_OkresDo)
 and @NaDzien between CfgKeyRyczalt.CFK_OkresOd and DateAdd(Day, -1, CfgKeyRyczalt.CFK_OkresDo)
 and @NaDzien between CfgKeyLimit.CFK_OkresOd and DateAdd(Day, -1, CfgKeyLimit.CFK_OkresDo))
 --or nazwa = '-brak-'
 insert into @Result (Id, KodKraju, NazwaKraju, Waluta, Dieta, Ryczalt, Limit)
 select
 P.Id,
 P.kod,
 P.nazwa,
 '',
 0.00,
 0.00,
 0.00
 from CDN.ListaPanstw() P left outer join @Result R on (P.id =  R.id)
 where R.id is null
 return
END
