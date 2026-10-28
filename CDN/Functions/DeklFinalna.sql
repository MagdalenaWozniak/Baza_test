CREATE FUNCTION CDN.DeklFinalna ( @DkN_DkNID INT, @DkN_RokMiesiac INT )
  RETURNS     INT
  AS
  BEGIN
        DECLARE @RESULT     INT
  DECLARE @TypDeklar  INT
        DECLARE @PraID      INT
  SELECT  @TypDeklar  = DkN_TypDeklar,
                @PraID      = DkN_PraID
        FROM CDN.DeklNag
        WHERE DkN_DkNID = @DkN_DkNID
        IF @TypDeklar = 1   -- DEKLARACJA VAT-7
        BEGIN
      DECLARE @RozliczeniaVATKwartalnie INT
      DECLARE @Rok INT
      DECLARE @Miesiac INT
      DECLARE @MM_OD INT
      SET @RozliczeniaVATKwartalnie = CDN.CfgRozliczeniaVATKwartalnie(@DkN_RokMiesiac)
      SET @Rok                      = Floor(@DkN_RokMiesiac / 100)
      SET @Miesiac      = @DkN_RokMiesiac % 100
      IF @RozliczeniaVATKwartalnie = 0 -- VAT roliczany jest w okresach miesiecznych
   BEGIN
       IF Exists ( Select DkN_DkNId From CDN.DeklNag
         where
              DkN_TypDeklar = @TypDeklar
           and DkN_RokMiesiac = @DkN_RokMiesiac
           and DkN_DkNId > @DkN_DkNID)
    BEGIN
     RETURN 0
    END
            END
      ELSE              -- VAT rozliczany jest w okresach kwaralnych
            BEGIN
    if (@Miesiac=1 or @Miesiac=2)
     begin
      SET @Miesiac=3
     end
    else
    if (@Miesiac=4 or @Miesiac=5 )
     begin
       SET @Miesiac=6
     end
    else
    if (@Miesiac=7 or @Miesiac=8)
     begin
      SET @Miesiac=9
     end
    else
    if (@Miesiac=10 or @Miesiac=11)
     begin
      SET @Miesiac=12
     end
    SET @MM_OD = @Miesiac - 2
    IF Exists ( Select DkN_DkNId From CDN.DeklNag
          where
               DkN_TypDeklar = 1
            and DkN_RokMiesiac between(100 * @Rok + @MM_OD)
             and (100 * @Rok + @Miesiac)
            and DkN_DkNId > @DkN_DkNID)
     BEGIN
      RETURN 0
     END
   END
        END
        ELSE
  IF @TypDeklar = 33  -- DEKLARACJA VAT27
        BEGIN
            if exists(  select *
                        from CDN.DeklNag A join CDN.DeklNag B on (A.DkN_RokMiesiac = B.DkN_RokMiesiac and A.DkN_Numer < B.DkN_Numer)
                        where
                        A.DkN_DkNID = @DkN_DkNID
                        and A.DkN_TypDeklar in (33)
                        and B.DkN_TypDeklar in (33) )
                return 0
            else
                return 1
        END
        ELSE
  IF @TypDeklar = 35  -- DEKLARACJA PIT37
        BEGIN
            if exists(  select *
                        from CDN.DeklNag A join CDN.DeklNag B on (A.DkN_RokMiesiac = B.DkN_RokMiesiac and A.DkN_Numer < B.DkN_Numer and A.DkN_ConstNIP = B.DkN_ConstNIP)
                        where
                        A.DkN_DkNID = @DkN_DkNID
                        and A.DkN_TypDeklar in (35)
                        and B.DkN_TypDeklar in (35) )
                return 0
            else
                return 1
        END
        ELSE
        IF @TypDeklar = 11 or @TypDeklar = 22  -- DEKLARACJA VATUE / VATUEK
        BEGIN
            if exists(  select *
                        from CDN.DeklNag A join CDN.DeklNag B on (A.DkN_RokMiesiac = B.DkN_RokMiesiac and A.DkN_Numer < B.DkN_Numer)
                        where
                        A.DkN_DkNID = @DkN_DkNID
                        and A.DkN_TypDeklar in (11, 22)
                        and B.DkN_TypDeklar in (11, 22) )
                return 0
            else
                return 1
        END
        ELSE
        IF @TypDeklar = 13 or @TypDeklar = 14  or @TypDeklar = 23 -- ZAŁĄCZNIKI VATUE
        BEGIN
            if exists(select * from CDN.DeklNag where DkN_TypDeklar = 22 and DkN_RokMiesiac = @DkN_RokMiesiac)
                return 0
            else
                return 1
        END
  ELSE IF @TypDeklar = 402 or @TypDeklar = 403
  BEGIN
            if exists(  select *
                        from CDN.DeklNag A join CDN.DeklNag B on (A.DkN_DKNId <> B.DkN_DKNId and A.DkN_RokMiesiac = B.DkN_RokMiesiac and A.DkN_TypDeklar=B.DkN_TypDeklar and A.DkN_Numer < B.DkN_Numer)
                        where
                        A.DkN_DkNID = @DkN_DkNID and A.DkN_TypDeklar = @TypDeklar)
                return 0
            else
                return 1
  END
        ELSE
        -- IF @TypDeklar = 20 -- deklarajca PIT-28
        IF @PraID IS NOT NULL -- wszystkie deklaracje, co zawierają podatnika
        BEGIN
       IF EXISTS(SELECT DkN_DknID FROM CDN.DeklNag WHERE DkN_TypDeklar = @TypDeklar
            and DkN_RokMiesiac = @DkN_RokMiesiac AND DkN_PraID = @PraID
            and DkN_DkNId > @DkN_DkNID)
        return 0
       ELSE
        return 1
        END
        ELSE
        BEGIN
       IF EXISTS(SELECT DkN_DknID FROM CDN.DeklNag
       WHERE DkN_TypDeklar = @TypDeklar
         and DkN_RokMiesiac = @DkN_RokMiesiac
         and DkN_DkNId > @DkN_DkNID)
        return 0
       ELSE
        return 1
        END
  RETURN 1
  END
