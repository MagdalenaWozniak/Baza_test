CREATE   PROCEDURE [CDN].[OFF_AktualizujNazwyCen]
      @Dfc_XL_LpChr   nvarchar(11),
      @Dfc_Nazwa      nvarchar(20),
      @Dfc_TypChr     nvarchar(2)
AS
  SET NOCOUNT ON
  DECLARE
      @Dfc_XL_Lp INT,
      @Dfc_Typ   TINYINT,
      @Dfc_Lp    INT,
      @Dfc_DfcId INT
      SELECT
      @Dfc_XL_Lp      =CONVERT(INT,@Dfc_XL_LpChr),
      @Dfc_Typ      =CONVERT(TINYINT,@Dfc_TypChr)
      SET @Dfc_Lp = @Dfc_XL_Lp + 1
      SELECT @Dfc_DfcId=Dfc_DfcId FROM cdn.DefCeny WHERE Dfc_Lp = @Dfc_Lp AND Dfc_XL_Lp is not null
        IF @Dfc_DfcId IS NULL
                BEGIN
                INSERT INTO cdn.DefCeny(Dfc_Lp,Dfc_XL_Lp,Dfc_Nazwa,Dfc_Typ,Dfc_Waluta,Dfc_Aktualizacja,Dfc_Marza,Dfc_Zaokraglenie,Dfc_Offset,Dfc_Nieaktywna)
                                 VALUES(@Dfc_Lp,@Dfc_XL_Lp,@Dfc_Nazwa,@Dfc_Typ,'',0,0,0,0,0)
               END
        ELSE
            BEGIN
               UPDATE cdn.DefCeny SET  Dfc_Lp     = @Dfc_Lp,
                                       Dfc_XL_Lp  = @Dfc_XL_Lp,
                                       Dfc_Nazwa  = @Dfc_Nazwa,
                                       Dfc_Typ    = @Dfc_Typ,
                                       Dfc_Waluta = '',
                                       Dfc_Nieaktywna = 0
                                WHERE  Dfc_DfcId  = @Dfc_DfcId
            END
      if exists(select DfC_Xl_Lp from cdn.defceny where DfC_Xl_Lp is null) delete cdn.defceny where dfc_xl_lp is null
  SET NOCOUNT OFF
