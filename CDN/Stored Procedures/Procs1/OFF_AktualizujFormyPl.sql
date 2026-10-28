CREATE PROCEDURE CDN.OFF_AktualizujFormyPl
   @FPl_XLIDChr         nvarchar(11),
   @FPl_RabatChr        nvarchar(11),
   @FPl_Nazwa           nvarchar(20),
   --@RejestrGidTypChr    nvarchar(5),
   @RejestrGidNumerChr  nvarchar(11),
   @FPl_AktChr          nvarchar(5),
   @FPl_TerminChr       nvarchar(5)
AS
  SET NOCOUNT ON
  DECLARE
   @FPl_XLID            INT,
   @FPl_Rabat           DECIMAL(5,2),
   @RejestrGidTyp       SMALLINT,
   @RejestrGidNumer     INT,
   @RejestrGidFirma     INT,
   @RejestrGidLp        SMALLINT,
   @FPl_Typ             SMALLINT,
   @FPl_Akt             SMALLINT,
   @FPl_Termin          SMALLINT,
   @IDSynchroXL         INT,
   @Bra_BraId           INT,
   @FPl_FPlId           INT,
   @FPl_Nieaktywny      SMALLINT,
   @Fir_Wartosc         nvarchar(254),
   @J                   INT,
   @Val1                nvarchar(20),
   @Val2                nvarchar(20),
   @AAA                 nvarchar(20),
   @Komunikat           nvarchar(255)
   SELECT
      @RejestrGidFirma   = 0,
      @RejestrGidTyp     = 0,
      @RejestrGidNumer   = CONVERT(INT,@RejestrGidNumerChr),
      @RejestrGidLp      = 0,
      @FPl_XLID          = CONVERT(INT,@FPl_XLIDChr),
      @FPl_Rabat         = CONVERT(DECIMAL(5,2),@FPl_RabatChr),
      @FPl_Akt           = CONVERT(SMALLINT,@FPl_AktChr),
      @FPl_Termin        = CONVERT(SMALLINT,@FPl_TerminChr)
   --SPRAWDZAM NAZWE CZY JUZ NIE WYSTEPUJE
      SET @J=1
      WHILE @J < 1000
           BEGIN
               SET @J=@J+1
               IF EXISTS ( SELECT Fpl_Nazwa FROM Cdn.FormyPlatnosci WHERE Fpl_Nazwa = @FPl_Nazwa AND Fpl_XLID !=@FPl_XLID)
                  BEGIN
                     SET @FPl_Nazwa = REVERSE(@FPl_Nazwa)
                     IF(CHARINDEX('(', @FPl_Nazwa)!=0 AND substring(@FPl_Nazwa,1,1)=')')
                        BEGIN
                            SET @Val1=substring(@FPl_Nazwa,2,CHARINDEX('(', @FPl_Nazwa)-2)
                            SET @Val2=substring(@FPl_Nazwa,CHARINDEX('(', @FPl_Nazwa)+1,20)
                            SET @AAA = REVERSE(@Val1) +1;
                            SET @Val2 = REVERSE(@Val2)
                            SET @FPl_Nazwa=SUBSTRING(@Val2,1,20-LEN(@AAA)-2)+'('+CONVERT(nvarchar(3),@AAA)+')'
                        END
                     ELSE
                        BEGIN
                            SET @FPl_Nazwa = REVERSE(@FPl_Nazwa)
                            SET @FPl_Nazwa = substring(@FPl_Nazwa,1,17)+'(1)'
                        END
                 END
           END
      IF(@FPl_Rabat IS NULL) SET @FPl_Rabat = 0
      IF @FPl_Akt<>0 SET @FPl_Nieaktywny      = 0
      ELSE SET @FPl_Nieaktywny = 1
      SELECT @Bra_BraId=Bra_BraId FROM Cdn.BnkRachunki WHERE Bra_GidNumer =@RejestrGidNumer
      SELECT @FPl_FPlId=FPl_FPlId FROM Cdn.FormyPlatnosci WHERE Fpl_XLID = @FPl_XLID
      IF (@FPl_XLID > 9 AND @FPl_XLID < 20) OR (@FPl_XLID > 39 AND @FPl_XLID < 50) SET @FPl_Typ=1
      IF (@FPl_XLID > 19 AND @FPl_XLID < 40) SET @FPl_Typ=2
      IF (@FPl_XLID > 49 ) SET @FPl_Typ=3
      IF @FPl_FPlId IS NULL
            BEGIN
                INSERT INTO Cdn.FormyPlatnosci(FPl_XLId,FPl_Nazwa,FPl_Typ,FPl_Rabat,FPl_BraID,FPl_Nieaktywny,FPl_Termin)
                                        VALUES(@FPl_XLId,@FPl_Nazwa,@FPl_Typ,@FPl_Rabat,@Bra_BraID,@FPl_Nieaktywny,@FPl_Termin)
            END
      ELSE
            BEGIN
                UPDATE Cdn.FormyPlatnosci SET FPl_XLId       = @FPl_XLId,
                                              FPl_Nazwa      = @FPl_Nazwa,
                                              FPl_Typ        = @FPl_Typ,
                                              FPl_Rabat      = @FPl_Rabat,
                                              FPl_BraID      = @Bra_BraID,
                                              FPl_Nieaktywny = @FPl_Nieaktywny,
                                              FPl_Termin     = @FPl_Termin
                                   WHERE      FPl_FPlId      = @FPl_FPlId
            END
      IF (@FPl_XLID = 10) UPDATE Cdn.Kontrahenci SET Knt_FplId =  (SELECT MIN(Fpl_FplId) FROM Cdn.FormyPlatnosci WHERE Fpl_Typ = 1 and FPl_XLID = 10 ) WHERE Knt_KntId =1
      IF  NOT EXISTS (SELECT Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1554) SELECT @IDSynchroXL=1 ELSE SELECT @IDSynchroXL=Fir_Wartosc FROM Cdn.Firma WHERE Fir_Numer=1554
      IF @IDSynchroXL<2
            BEGIN
                IF (@FPl_XLID = 10)
                     BEGIN
                        Select @Fir_Wartosc=Fir_Wartosc From Cdn.Firma Where Fir_Numer = 1601 and Fir_Wartosc!='' and Fir_Wartosc!=1 and Fir_Wartosc!=0
                        IF @Fir_Wartosc IS NULL
                              BEGIN
                                    SELECT @FPl_FPlId=FPl_FPlId FROM Cdn.FormyPlatnosci WHERE Fpl_XLID = @FPl_XLID
                                    if not exists(Select * From Cdn.Firma Where Fir_Numer = 1601 ) INSERT INTO Cdn.Firma(Fir_Numer,Fir_Wartosc,Fir_Opis) VALUES (1601,@FPl_FPlId,'FormaPlatnosciPOS') else update Cdn.Firma set Fir_Wartosc=@FPl_FPlId Where Fir_Numer = 1601
                                    if not exists(Select * From Cdn.Firma Where Fir_Numer = 1606 ) INSERT INTO Cdn.Firma(Fir_Numer,Fir_Wartosc,Fir_Opis) VALUES (1606,@FPl_Nazwa,'FormaPlatnosciPOSNazwa') else update Cdn.Firma set Fir_Wartosc=@FPl_Nazwa Where Fir_Numer = 1606
                               END
                    END
            END
  SET NOCOUNT OFF
