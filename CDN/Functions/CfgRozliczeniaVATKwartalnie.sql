Create  FUNCTION CDN.CfgRozliczeniaVATKwartalnie ( @RokMiesiac INT )
  RETURNS     INT
  AS
  BEGIN
  Declare @Result Int    -- {0,1}; 0 - miesięcznie; 1 - kwartalnie
  SELECT @Result = CAST(CFW_Wartosc AS INT)
  FROM CDN.CfgWartosci left outer join CDN.CfgKlucze ON (CFW_CfkId = CFK_CfkId)
  WHERE
          CFK_Nazwa    = 'Rozliczanie VAT kwartalnie'
      and @RokMiesiac >= YEAR (CFK_OkresOd)*100 + MONTH(CFK_OkresOd)
      and @RokMiesiac <  YEAR (CFK_OkresDo)*100 + MONTH(CFK_OkresDo)
  RETURN @Result;
  END
