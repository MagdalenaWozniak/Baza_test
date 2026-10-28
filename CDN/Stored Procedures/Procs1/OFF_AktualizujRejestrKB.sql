CREATE  PROCEDURE [CDN].[OFF_AktualizujRejestrKB]
      --@Bra_GidTypChr        nvarchar(5),
      @Bra_GidNumerChr      nvarchar(11),
      --@Bra_BnkGidTypChr     nvarchar(5),
      @Bra_BnkGidNumerChr   nvarchar(11),
      @Bra_TypChr           nvarchar(11),
      @Bra_Symbol           nvarchar(5),
      @Bra_Nazwa            nvarchar(40),
      @Bra_RachunekNr       nvarchar(51),
   @OpeZalIDChr          nvarchar(11),
   @StaZalIdChr          nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
      @Bra_GidFirma           INT,
      @Bra_GidTyp             SMALLINT,
      @Bra_GidNumer           INT,
      @Bra_GidLp              SMALLINT,
      @Bra_BnkGidFirma        INT,
      @Bra_BnkGidTyp          SMALLINT,
      @Bra_BnkGidNumer        INT,
      @Bra_BnkGidLp           SMALLINT,
      @Bra_Typ                INT,
      @Bra_Akronim            nvarchar(20),
      @Bra_BraId              INT,
      @Bra_BnaId              INT,
      @IDSynchroXL            INT,
      @Komunikat              nvarchar(255),
      @OpeZalID               INT,
      @StaZalId               INT,
      @OpeModID               INT,
   @StaModId               INT
      SELECT
      @Bra_GidFirma         = 0,
      @Bra_GidTyp           = 0,
      @Bra_GidNumer         = CONVERT(INT,@Bra_GidNumerChr),
      @Bra_GidLp            = 0,
      @Bra_BnkGidFirma      = 0,
      @Bra_BnkGidTyp        = 0,
      @Bra_BnkGidNumer      = CONVERT(INT,@Bra_BnkGidNumerChr),
      @Bra_BnkGidLp         = 0,
      @Bra_Typ              = CONVERT(INT,@Bra_TypChr),
   @OpeZalID    = CONVERT(INT,@OpeZalIDChr),
   @StaZalId    = CONVERT(INT,@StaZalIdChr)
   --IDOPER I IDSTANOW TAKIE SAME
   SET @OpeModID  = @OpeZalID
   SET @StaModId  = @StaZalId
    declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
    exec CDN.OpeKodNazwisko @OpeModID, @OpeModKod OUT, @OpeModNazwisko OUT
      SET @Bra_Akronim=@Bra_Symbol
      if (@Bra_Typ = 101) SET @Bra_Typ=1
      if (@Bra_Typ = 102) SET @Bra_Typ=1
      if (@Bra_Typ = 103) SET @Bra_Typ=1
      if (@Bra_Typ = 104) SET @Bra_Typ=2
      if @Bra_RachunekNr IS NULL OR @Bra_RachunekNr ='' SET @Bra_RachunekNr = @Bra_Symbol
      if (@Bra_BnkGidNumer = 0 OR @Bra_BnkGidNumer IS NULL) SET @Bra_BnaId=1
      else
          BEGIN
            SELECT @Bra_BnaId=Bna_BnaId FROM Cdn.BnkNazwy WHERE Bna_GidNumer =@Bra_BnkGidNumer
            if @Bra_BnaId IS NULL
            BEGIN
                        SET @Komunikat = '##OPT34483##'--' Rejest do nieznanego banku '
                        RAISERROR( @Komunikat, 16, 1)
                        RETURN
            END
          END
         SELECT @Bra_BraId=Bra_BraId FROM Cdn.BnkRachunki WHERE Bra_GidNumer = @Bra_GidNumer
        IF @Bra_BraId IS NULL
                BEGIN
               INSERT INTO Cdn.BnkRachunki(Bra_Symbol,Bra_GidTyp,Bra_GidFirma,Bra_GidNumer,Bra_GidLp,
                                    Bra_RachunekNr,Bra_Nazwa,Bra_Typ,Bra_Akronim,Bra_DDfId,Bra_BnaId,
                                    Bra_TS_Mod,Bra_TS_Zal,Bra_Nieaktywny,Bra_NumeryObce,Bra_KaraZaprzekr,
                                    Bra_OprocKarne,Bra_OprocKredytu,Bra_OprocRachunku,Bra_LimitKredytu,
                                    Bra_BrpOkres,Bra_SaldoBo,Bra_SaldoBoSys,Bra_Waluta,BRa_KursSprzedazyNr,BRa_KursZakupuNr,BRa_KursNumer,BRa_KursL,BRa_KursM,
                                    Bra_IBan,BRa_KontoPrzeciwstawne,BRa_MagazynWalut,BRa_RozKur2SumaMW,BRa_KursHistorycznyMW,
         Bra_OpeZalID,Bra_OpeZalKod,Bra_OpeZalNazwisko,Bra_StaZalId,Bra_OpeModID,Bra_OpeModKod,
         Bra_OpeModNazwisko,Bra_StaModId)
               VALUES(@Bra_Symbol,@Bra_GidTyp,@Bra_GidFirma,@Bra_GidNumer,@Bra_GidLp,
                                    @Bra_RachunekNr,@Bra_Nazwa,@Bra_Typ,@Bra_Akronim,3,@Bra_BnaId,
                                    GETDATE(),GETDATE(),0,0,0,
                                    0,0,0,0,
                                    1,0,0,'',2,2,2,1,1,0,'',0,0,0,
         @OpeZalID,@OpeModKod,@OpeModNazwisko,@StaZalId,@OpeModID,@OpeModKod,@OpeModNazwisko,@StaModId)
               END
        ELSE
            BEGIN
               UPDATE Cdn.BnkRachunki SET Bra_Symbol=@Bra_Symbol,
                                    Bra_RachunekNr=@Bra_RachunekNr,
                                    Bra_Nazwa=@Bra_Nazwa,
                                    Bra_Akronim=@Bra_Akronim,
                                    Bra_BnaId=@Bra_BnaId,
                                    Bra_TS_Mod=GETDATE(),
                                    Bra_OpeModID = @OpeModID,
                                    Bra_OpeModKod = @OpeModKod,
                                    Bra_OpeModNazwisko = @OpeModNazwisko,
                                    Bra_StaModId = @StaModId
                              WHERE Bra_BraId=@Bra_BraId
            END
            if  not exists (select fir_wartosc from cdn.firma where fir_numer=1554)select @IDSynchroXL=1 else select @IDSynchroXL=fir_wartosc from cdn.firma where fir_numer=1554
            IF @IDSynchroXL<=1
            BEGIN
                  SELECT @Bra_BraId=Bra_BraId FROM Cdn.BnkRachunki WHERE Bra_Symbol=@Bra_Symbol
                  insert into cdn.bnkraporty(BRp_BraId,BRp_TS_Mod,BRp_TS_Zal,BRp_Rozchody,BRp_RozchodySys,BRp_Przychody,BRp_PrzychodySys,BRp_SaldoBO,BRp_SaldoBOSys,BRp_RoznicaKursowaSysMW,BRp_Zamkniety,BRp_DataDok,BRp_NumerNr,BRp_NumerString,BRp_NumerObcy,BRp_DDfID,
      Brp_OpeZalID,Brp_OpeZalKod,Brp_OpeZalNazwisko,Brp_StaZalId,Brp_OpeModID,Brp_OpeModKod,Brp_OpeModNazwisko,Brp_StaModId)
                  values (@Bra_BraId,GETDATE(),GETDATE(),0,0,0,0,0,0,0,0,convert(datetime,convert(nvarchar(10),GETDATE(),120),120),1,'RKB/@numer/'+cast(year(GETDATE()) as nvarchar(4))+'/'+ @Bra_Symbol,'',3
      ,@OpeZalID,@OpeModKod,@OpeModNazwisko,@StaZalId,@OpeModID,@OpeModKod,@OpeModNazwisko,@StaModId)            END
  SET NOCOUNT OFF
