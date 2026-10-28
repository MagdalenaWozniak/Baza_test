CREATE PROCEDURE CDN.OFF_DodajNaglowekSchOpak
      @SON_IDXLChr     nvarchar(11),
      @SON_Kod         nvarchar(20),
      @SON_Nazwa       nvarchar(50),
      @SON_TS_XL       nvarchar(30),
      @SON_NieaktywnyChr  nvarchar(30),
      @SON_OpeZalIdChr       nvarchar(11),
      @SON_StaZalIdChr       nvarchar(11)
AS
  SET NOCOUNT ON
  DECLARE
    @SON_SONID     INT,
    @SON_IDXL      INT,
    @SON_OpeZalID  INT,
    @SON_StaZalId  INT,
    @SON_Nieaktywny INT,
    @Komunikat     nvarchar(255)
    if @SON_TS_XL = '0-00-00 00:00:00' set @SON_TS_XL = '1800-12-28 00:00:00'
  SELECT
    @SON_TS_XL           = CONVERT(DATETIME, @SON_TS_XL,    120 ),
    @SON_IDXL            = CONVERT(INT, @SON_IDXLChr),
    @SON_OpeZalID         =CONVERT(INT,@SON_OpeZalIDChr),
    @SON_StaZalId         =CONVERT(INT,@SON_StaZalIdChr),
    @SON_Nieaktywny       =CONVERT(INT,@SON_NieaktywnyChr)
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @SON_OpeZalID, @OpeModKod OUT, @OpeModNazwisko OUT
  SELECT @SON_SONID = SON_SONID
    FROM CDN.SchematyOpakNag
    WHERE SON_SONID   = @SON_IDXL
  IF @SON_SONID IS NULL
    BEGIN
Set Identity_Insert CDN.SchematyOpakNag On
      INSERT INTO CDN.SchematyOpakNag(
                        SON_SONID,
                        SON_Kod,
                        SON_Nazwa,
                        SON_TS_XL,
                        SON_OpeZalID,
      SON_OpeZalKod,
      SON_OpeZalNazwisko,
                        SON_StaZalId,
                        SON_OpeModID,
      SON_OpeModKod,
      SON_OpeModNazwisko,
                        SON_StaModID,
                        SON_TS_Zal,
                        SON_TS_Mod,
                        SON_Nieaktywny
                        )
            VALUES(     @SON_IDXL,
                        @SON_Kod,
                        @SON_Nazwa,
                        @SON_TS_XL,
                        @SON_OpeZalID,
      @OpeModKod,
      @OpeModNazwisko,
                        @SON_StaZalId,
                        @SON_OpeZalID,
      @OpeModKod,
      @OpeModNazwisko,
                        @SON_StaZalId,
                        GETDATE(),
                        GETDATE(),
                        @SON_Nieaktywny
                        )
Set Identity_Insert CDN.SchematyOpakNag Off
    END
  ELSE
    BEGIN
       IF @SON_TS_XL >= ( SELECT isnull(SON_TS_XL,0) FROM CDN.SchematyOpakNag WHERE SON_SONID   = @SON_IDXL)
        BEGIN
                  UPDATE CDN.SchematyOpakNag SET
                        SON_Kod = @SON_Kod,
                        SON_Nazwa = @SON_Nazwa,
                        SON_TS_XL = @SON_TS_XL,
                        SON_OpeModID = @SON_OpeZalID,
      SON_OpeModKod = @OpeModKod,
      SON_OpeModNazwisko = @OpeModNazwisko,
                        SON_StaModID = @SON_StaZalID,
                        SON_TS_Mod   = GETDATE(),
                        SON_Nieaktywny = @SON_Nieaktywny
                  WHERE SON_SONID = @SON_SONID
                  -- kasujemy elementy bo przyja nowe
                  DELETE FROM CDN.SchematyOpakElem
                  WHERE SOE_SONId = @SON_SONId
         END
      END
  SET NOCOUNT OFF
