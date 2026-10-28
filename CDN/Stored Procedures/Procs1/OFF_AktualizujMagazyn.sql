CREATE  PROCEDURE CDN.OFF_AktualizujMagazyn
@OddzialChr    nvarchar(5),
@Mag_Symbol    nvarchar(20),
@Mag_Nazwa    nvarchar(50),
@Mag_Opis    nvarchar(254),
@Mag_GidNumerChr  nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
    @Mag_MagId    INT,
    @Mag_GidNumer INT,
    @Oddzial      TINYINT
      --UPDATE MAGAZYNU ODDZIAL
    SELECT
            @Mag_GIDNumer            = CONVERT(INT, @Mag_GIDNumerChr),
            @Oddzial                 = CONVERT(TINYINT, @OddzialChr)
    if @Oddzial =1
      UPDATE Cdn.Magazyny SET
            Mag_Symbol = @Mag_Symbol,
            Mag_Nazwa  = @Mag_Nazwa,
            Mag_Opis   = @Mag_Opis,
            Mag_GidNumer = @Mag_GidNumer,
            Mag_NieAktywny = 0
            WHERE      Mag_MagId = 1
     ELSE
       BEGIN
      --UPDATE LUB INSERT MAGAZYNU CENTRALA
        SELECT @Mag_MagId=Mag_MagId FROM Cdn.Magazyny WHERE Mag_GidNumer = @Mag_GidNumer
        IF @Mag_MagId IS NULL AND @Oddzial = 2
                BEGIN
                   SELECT @Mag_MagId=Mag_MagId FROM Cdn.Magazyny WHERE Mag_Typ = 2 AND Mag_GidNumer is null
                END
        IF @Mag_MagId IS NULL
                BEGIN
                  INSERT INTO Cdn.Magazyny(Mag_typ,Mag_Symbol,Mag_Nazwa,
                                           Mag_Opis,Mag_TS_Mod,Mag_TS_Zal,
                                           Mag_NieAktywny,Mag_Rejestr,
                                           Mag_Unijny,Mag_UEKraj,Mag_KodTransakcji,Mag_GidNumer)
                                   VALUES (2,@Mag_Symbol,@Mag_Nazwa,
                                           @Mag_Opis,GETDATE(),GETDATE(),
                                           0,'',0,'','',@Mag_GidNumer)
                END
        ELSE
                BEGIN
                  UPDATE Cdn.Magazyny SET
                        Mag_Symbol = @Mag_Symbol,
                        Mag_Nazwa  = @Mag_Nazwa,
                        Mag_Opis   = @Mag_Opis,
                        Mag_GidNumer = @Mag_GidNumer,
                        Mag_NieAktywny = 0
                  WHERE Mag_MagId = @Mag_MagId
                END
     END
   if @Oddzial = 2
     UPDATE Cdn.Magazyny SET
      Mag_MagazynZwrotnyXL = 1
     WHERE Mag_GidNumer = @Mag_GidNumer
  SET NOCOUNT OFF
