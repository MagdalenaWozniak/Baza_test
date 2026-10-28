CREATE PROCEDURE CDN.OFF_AktualizujTwrCenyZakupu
    @TwC_Waluta             nvarchar(3),
    @IloscCenAutoChr        nvarchar(11),
    @NumerCenyWzorcowejChr  nvarchar(11),
    @NumerCenyDomyslnejChr  nvarchar(11)
AS
  SET NOCOUNT ON
DECLARE
 @Dfc_Lp                  INT,
 @Dfc_DfcId               INT,
 @Lp                      INT,
 @Dfc_Typ                 INT,
 @Dfc_TypCenykopiowanej   INT,
 @IloscCenAuto            INT,
 @NumerCenyWzorcowej      INT,
 @NumerCenyDomyslnej      INT
 select
   @IloscCenAuto              = CONVERT(INT, @IloscCenAutoChr),
   @NumerCenyWzorcowej        = CONVERT(INT,@NumerCenyWzorcowejChr),
   @NumerCenyDomyslnej        = CONVERT(INT,@NumerCenyDomyslnejChr)
    --dodanie ceny autonomiczne jezeli zajdzie taka potrzeba..
    SET @Lp =1
    while @Lp <= @IloscCenAuto
    BEGIN
         SELECT @Dfc_DfcId=Dfc_DfcId FROM cdn.DefCeny WHERE Dfc_Lp = -@Lp-10 AND Dfc_XL_Lp is not null
         IF @Dfc_DfcId IS NULL
                 BEGIN
                 INSERT INTO cdn.DefCeny(Dfc_Lp,Dfc_XL_Lp,Dfc_Nazwa,Dfc_Typ,Dfc_Waluta,Dfc_Aktualizacja,Dfc_Marza,Dfc_Zaokraglenie,Dfc_Offset)
                        SELECT -@Lp-10,-@Lp-11,'AUTO '+convert(nvarchar,@Lp),Dfc_Typ,Dfc_Waluta,Dfc_Aktualizacja,Dfc_Marza,Dfc_Zaokraglenie,Dfc_Offset from cdn.DefCeny where DfC_XL_Lp = @NumerCenyWzorcowej
                 END
           ELSE
                 BEGIN
                  UPDATE CDN.DefCeny SET DfC_Nieaktywna = 0 WHERE Dfc_Lp = -@Lp-10 AND Dfc_XL_Lp is not null
                 END
         SET @Lp = @Lp+1
    END
      INSERT INTO Cdn.TwrCeny(TwC_TwrId,TwC_Offset,TwC_Marza,TwC_Zaokraglenie,TwC_Aktualizacja,TwC_Wartosc,TwC_Typ,TwC_TwCNumer,TwC_Waluta,Twc_TwrTyp,Twc_TwrFirma,Twc_TwrNumer,Twc_TwrLp,Twc_MarzaWSTU)
      SELECT                   Twr_TwrId,0,            0,      0,            0,              0,            1,      1,       @TwC_Waluta,Twr_GidTyp,Twr_GidFirma,Twr_GidNumer,0,          0
      FROM cdn.towary
      LEFT OUTER JOIN Cdn.TwrCeny
      ON Twr_TwrId=Twc_TwrId and TwC_TwcNumer=1
      WHERE TwC_TwcNumer is null
       SET @Lp =1
         while @Lp <= @IloscCenAuto
         BEGIN
           SELECT @Dfc_Typ=Dfc_Typ FROM cdn.DefCeny WHERE Dfc_Lp = -@Lp-10
           INSERT INTO Cdn.TwrCeny(TwC_TwrId,TwC_Offset,TwC_Marza,TwC_Zaokraglenie,TwC_Aktualizacja,TwC_Wartosc,TwC_Typ,TwC_TwCNumer,TwC_Waluta,Twc_TwrTyp,Twc_TwrFirma,Twc_TwrNumer,Twc_TwrLp,Twc_MarzaWSTU)
           SELECT                   Twr_TwrId,        0,        0,               0,               0,
             ISNULL(
             CASE
               WHEN (@Dfc_Typ = a.TwC_Typ) THEN a.TwC_Wartosc
               ELSE
                  CASE
                    WHEN @Dfc_Typ < a.TwC_Typ THEN  a.TwC_Wartosc -  ( a.TwC_Wartosc * ( Twr_Stawka / ( 100 + Twr_Stawka ) ) )
                    ELSE (a.TwC_Wartosc  +  ( a.TwC_Wartosc * ( Twr_Stawka / 100 )))
                   END
               END,0), @Dfc_Typ,-@Lp-10,ISNULL(a.TwC_Waluta,''),Twr_GidTyp,Twr_GidFirma,Twr_GidNumer,-@Lp-11,          0
           FROM cdn.towary
           LEFT OUTER JOIN Cdn.TwrCeny as B
           ON Twr_TwrId=B.Twc_TwrId and B.TwC_TwcNumer= -@Lp-10
           LEFT OUTER JOIN Cdn.TwrCeny as A on A.Twc_TwrId=Twr_TwrId and A.TwC_TwrLp = @NumerCenyWzorcowej
           WHERE B.TwC_TwcNumer is null
           SET @Lp = @Lp+1
     END
      IF @NumerCenyDomyslnejChr<>'' AND  @NumerCenyDomyslnejChr<>0
            UPDATE Cdn.Towary set Twr_TwCNumer = @NumerCenyDomyslnej+1
      ELSE
        BEGIN
       UPDATE cdn.Towary
       SET Twr_TwCNumer = TwCNumer
       FROM cdn.Towary
       JOIN  ( SELECT TwrId = TwC_TwrId, TwCNumer = MIN(TwC_TwCNumer)
           FROM cdn.TwrCeny
           WHERE TwC_TwCNumer <> 1
                AND TwC_TwrId IN (
                                                 SELECT Twr_TwrId
                                                 FROM cdn.Towary
                                                 LEFT OUTER JOIN cdn.TwrCeny ON Twr_TwrId=Twc_TwrId and Twr_TwCNumer = TwC_TwCNumer
                                                 WHERE TwC_TwCId IS NULL
                                  )
           GROUP BY TwC_TwrId
        ) AS TwrCeny ON TwrId = Twr_TwrId
        END
  SET NOCOUNT OFF
