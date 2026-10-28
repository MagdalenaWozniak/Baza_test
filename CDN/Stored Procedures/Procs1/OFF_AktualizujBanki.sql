CREATE  PROCEDURE CDN.OFF_AktualizujBanki
      @BNa_GidNumerChr      nvarchar(11),
      @BNa_Nazwa1           nvarchar(50),
      @BNa_Akronim          nvarchar(20),
      @BNa_Numer            nvarchar(10)
AS
   SET NOCOUNT ON
  DECLARE
      @BNa_GidFirma          INT,
      @BNa_GidTyp            SMALLINT,
      @BNa_GidNumer          INT,
      @BNa_GidLp             SMALLINT,
      @BNa_BNaId             INT,
      @BNa_Centrala          nvarchar(3)
  SELECT
       @BNa_GidFirma         = 0,
       @BNa_GidNumer         = CONVERT(INT,@BNa_GidNumerChr),
       @BNa_GidTyp           = 0,
       @BNa_GidLp            = 0
       SET @BNa_Centrala=SUBSTRING(@BNa_Numer,1,3)
       Select @BNa_BNaId=BNa_BNaId From Cdn.BnkNazwy Where BNa_GidNumer = @BNa_GidNumer or @Bna_Numer=Bna_Numer
       IF @BNa_BNaId IS NULL
          BEGIN
              INSERT INTO Cdn.BnkNazwy  ( Bna_Akronim,Bna_Numer,Bna_Nazwa1,Bna_TS_Mod,Bna_TS_Zal,Bna_FormatUS,Bna_FormatZUS,
                                        Bna_Zagraniczny,Bna_IBAN, Bna_CzasRealizacji,Bna_Format,
                                        Bna_Centrala,Bna_Swift,Bna_Nazwa2,Bna_Kraj,Bna_Wojewodztwo,
                                        Bna_Powiat,Bna_Gmina,Bna_Ulica,Bna_NrDomu,Bna_NrLokalu,Bna_Miasto,Bna_KodPocztowy,
                                        Bna_Poczta,Bna_Adres2,Bna_Modem,Bna_Telefon,Bna_EMail,Bna_Fax,Bna_URL,Bna_UID,Bna_PWD,
                                        Bna_GidTyp,Bna_GidFirma,Bna_GidLp,BNa_GidNumer, BNa_NieRozliczac)
              VALUES                    ( @Bna_Akronim,@Bna_Numer,@Bna_Nazwa1,GETDATE(),GETDATE(),0,0,
                                        0,0,0,0,
                                        @BNa_Centrala,'','','','',
                                        '','','','','','','',
                                        '','','','','','','','','',
                                        @Bna_GidTyp,@Bna_GidFirma,@Bna_GidLp,@BNa_GidNumer, 0)
          END
        ELSE
            BEGIN
               UPDATE Cdn.BnkNazwy SET Bna_Akronim = @Bna_Akronim,
                                       Bna_Numer = @Bna_Numer,
                                       Bna_Nazwa1 = @Bna_Nazwa1,
                                       Bna_Centrala = @Bna_Centrala,
                                       BNa_GidNumer = @BNa_GidNumer,
                                       BNa_GidFirma = @BNa_GidFirma,
                                       BNa_GidTyp = @BNa_GidTyp,
                                       BNa_GidLp = @BNa_GidLp
                                WHERE  BNa_BNaId=@BNa_BNaId
            END
  SET NOCOUNT OFF
