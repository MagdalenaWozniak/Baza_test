CREATE PROCEDURE cdn.CheckGruNazwa(@addNew INT, @typ INT, @nazwa VARCHAR(20) OUTPUT)
AS
BEGIN
  DECLARE @nazwaGru VARCHAR(20)
  SELECT @nazwaGru = Gru_Nazwa FROM CDN.Grupy WHERE  Gru_Typ=@typ AND Lower(Gru_Nazwa)=Lower(@nazwa);
  IF @nazwaGru IS NULL SET @nazwaGru = ''
  IF @nazwaGru = '' AND @nazwa <> '' AND  @addNew = 1
  BEGIN
 SET @nazwaGru = @nazwa
 INSERT INTO [CDN].[Grupy](Gru_Typ, Gru_Nazwa, Gru_Opis, Gru_TS_Zal, Gru_TS_Mod) VALUES(@typ, @nazwa, N'', GetDate(), GetDate())
  END
  SET @nazwa = @nazwaGru
END
