create  PROCEDURE [CDN].[DodajPOO]
@Nazwa1 NVARCHAR(254),
@KodPocztowy NVARCHAR(254),
@Miasto NVARCHAR(254),
@Ulica NVARCHAR(254),
@NrDomu NVARCHAR(254),
@NrMieszkania NVARCHAR(254),
@KrajISO NVARCHAR(254),
@Wojew NVARCHAR(254),
@Tel NVARCHAR(254),
@GSM NVARCHAR(254),
@Nazwa2 NVARCHAR(254),
@POOIDEsklep   nvarchar(11),
@IDEsklep   nvarchar(11),
@SANKOD NVARCHAR(254),  -- zmiana/nowy
@ID INT = 0
AS
SET NOCOUNT ON
DECLARE
 @Kod nvarchar(20),
 @Val1                           nvarchar(20),
 @Val2                           nvarchar(20),
 @AAA                            nvarchar(20),
 @SANID       int
if @ID > 0
BEGIN
 select
 @Nazwa1 = trn_eSklepPunktOdbioruOsobistegoNazwa1,
 @KodPocztowy= trn_eSklepPunktOdbioruOsobistegoKodPocztowy,
 @Miasto= trn_eSklepPunktOdbioruOsobistegoMiasto,
 @Ulica= trn_eSklepPunktOdbioruOsobistegoUlica,
 @NrDomu= trn_eSklepPunktOdbioruOsobistegoNrBudynku,
 @NrMieszkania= trn_eSklepPunktOdbioruOsobistegoNrLokalu,
 @KrajISO= trn_eSklepPunktOdbioruOsobistegoKrajISO,
 @Wojew= trn_eSklepPunktOdbioruOsobistegoWojewodztwo,
 @Tel= trn_eSklepPunktOdbioruOsobistegoTelefon,
 @GSM= trn_eSklepPunktOdbioruOsobistegoGSM,
 @Nazwa2= isnull(trn_eSklepPunktOdbioruOsobistegoNazwa2,''),
 @POOIDEsklep= trn_eSklepPunktOdbioruOsobistegoIDeSklep,
 @IDEsklep= trn_eSklepID
 from cdn.tranag where trn_trnid = @ID
END
if not exists(select * from CDN.SENDitAdresyNadawcze where SAN_SANID = 1)
 exec [CDN].[SENDit_AdresNadawczy]
if (@SANKOD != '')
BEGIN
 update cdn.sENDitadresynadawcze set SAN_Nazwa =@Nazwa1, SAN_KodPocztowy = @KodPocztowy, SAN_Miasto = @Miasto, SAN_Ulica = @Ulica ,SAN_NrDomu= @NrDomu,
 SAN_NrMieszkania = @NrMieszkania,SAN_KrajISO = @KrajISO, SAN_Wojewodztwo= @Wojew,  SAN_Telefon = @Tel, SAN_Nazwa2 = @Nazwa2,SAN_TelefonGSM = @GSM, SAN_PunktOdbioruOsobistego = 1
 where SAN_KOD = @SANKOD
 set @Kod = @SANKOD
END
else
BEGIN
--tworzymy kod
 SET @Kod = 'ESKLPOO_' +@IDEsklep+'_' + @POOIDEsklep
 DECLARE @I INT
 SET @I=1
 WHILE @I < 1000
 BEGIN
  SET @I=@I+1
  IF EXISTS ( SELECT SAN_Kod FROM cdn.SENDitAdresyNadawcze WHERE SAN_Kod = @Kod )
  BEGIN
    SET @Kod = REVERSE(@Kod)
    IF(CHARINDEX('(', @Kod)!=0 AND substring(@Kod,1,1)=')')
     BEGIN
      SET @Val1=substring(@Kod,2,CHARINDEX('(', @Kod)-2)
      SET @Val2=substring(@Kod,CHARINDEX('(', @Kod)+1,20)
      SET @AAA = REVERSE(@Val1) +1;
      SET @Val2 = REVERSE(@Val2)
      SET @Kod=SUBSTRING(@Val2,1,20-LEN(@AAA)-2)+'('+CONVERT(nvarchar(3),@AAA)+')'
     END
    ELSE
     BEGIN
      SET @Kod = REVERSE(@Kod)
      SET @Kod = substring(@Kod,1,17)+'(1)'
     END
  END
  ELSE
  BEGIN
   BREAK
  END
 END
 INSERT INTO CDN.SENDitAdresyNadawcze
           (SAN_Kod
           ,SAN_Nazwa
           ,SAN_Ulica
           ,SAN_NrDomu
           ,SAN_NrMieszkania
           ,SAN_Miasto
           ,SAN_KodPocztowy
           ,SAN_Domyslny
           ,SAN_Korespondencyjny
           ,SAN_KrajISO
           ,SAN_Wojewodztwo
           ,SAN_Telefon
           ,SAN_TelefonGSM
           ,SAN_Nazwa2
           ,SAN_PunktOdbioruOsobistego )
 VALUES
           (@Kod
           ,@Nazwa1
           ,@Ulica
           ,@NrDomu
           ,@NrMieszkania
           ,@Miasto
           ,@KodPocztowy
           ,0
           ,0
           ,@KrajISO
           ,@Wojew
           ,@Tel
           ,@GSM
           ,@Nazwa2
           ,1)
END
SELECT @SANID = SAN_SANID FROM CDN.SENDitAdresyNadawcze WHERE SAN_Kod = @Kod
if not exists (select * from [CDN].[eSklepAdresyNadawczeRelacje] where ESAN_SANOptimaID = @SANID AND ESAN_SANeSklepID = @POOIDEsklep AND ESAN_eSklepID = @IDEsklep)
     INSERT INTO [CDN].[eSklepAdresyNadawczeRelacje]
           ([ESAN_SANOptimaID]
           ,[ESAN_SANeSklepID]
           ,[ESAN_eSklepID]
           ,ESAN_TS)
     VALUES
           (@SANID
           ,@POOIDEsklep
           ,@IDEsklep
     ,GETDATE())
if @ID > 0 and @SANID > 0
     update CDN.TraNag set TrN_eSklepPunktOdbioruOsobistegoID = @SANID where TrN_TrNID = @ID
select @SANID
SET NOCOUNT OFF
