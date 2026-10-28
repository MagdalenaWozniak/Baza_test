CREATE PROCEDURE CDN.RejestrOperacjiZapiszKontrahenta
@ID     INT,
@Kod       NVARCHAR(20),
@TypOperacji  INT
AS
BEGIN
 IF @Kod = ''
  SELECT @Kod = Knt_Kod FROM CDN.Kontrahenci WHERE Knt_KntID = @ID
 EXEC [CDN].[RejestrOperacjiDodaj]
   @ObiektTyp = 1103, -- OptimaObjectType_Kontrahent
   @ObiektSubTyp = 0,
   @ObiektID = @ID,
   @ObiektNazwa = @Kod,
   @OperacjaTyp = @TypOperacji,
   @Opis = ''
END
