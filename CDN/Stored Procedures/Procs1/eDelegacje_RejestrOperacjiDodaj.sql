CREATE   PROCEDURE CDN.eDelegacje_RejestrOperacjiDodaj
@DokumentId  int,
@TypOperacji int,
@OperatorId  int
AS
begin
 if IsNUll(@OperatorId, 0) = 0
 begin
  SELECT @OperatorId = CONVERT (INT, Fir_Wartosc)
  FROM   cdn.Firma
  WHERE  Fir_Numer = 2185;
 end
 if IsNUll(@OperatorId, 0) <> 0
 begin
  declare @objectType int = 114;
  declare @numer varchar(255);
  select @numer = DLN_NumerPelny from CDN.DlgNag where DLN_DLNId = @DokumentId
  EXEC [CDN].[EP_RejestrOperacjiDodaj]
           @ObiektTyp  = @objectType,
           @ObiektSubTyp = 0,
           @ObiektID  = @DokumentId,
           @ObiektNazwa = @numer,
           @OperacjaTyp = @TypOperacji,
           @Opis   = '';
 end
end
