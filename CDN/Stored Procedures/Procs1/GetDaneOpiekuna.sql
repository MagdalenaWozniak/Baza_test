CREATE PROCEDURE CDN.GetDaneOpiekuna
@opiekunTyp int,
@opiekunID  int
AS
BEGIN
    IF @opiekunTyp = 3 OR @opiekunTyp = 4
  SELECT 'pracownik'as Typ, PrE_Kod AS Akronim,PRE_Imie1 + SPACE(1) +  PrE_Nazwisko AS Nazwisko, PrE_TelefonSms AS TelefonSms, PrE_HDKEmail AS Email
  FROM CDN.PracKod JOIN CDN.PracEtaty ON Pra_PraID=PrE_PraID
  WHERE PRE_DataDo =  CONVERT(DATETIME, '2999-12-31', 120) AND PrE_PraID = @OpiekunID
    ELSE
    if @opiekunTyp = 8
    BEGIN
        DECLARE @sqlText NVARCHAR(1024)
        SET @sqlText = N'SELECT ''operator'' as Typ, Ope_Kod as Akronim, Ope_Nazwisko As Nazwisko, Ope_Telefon AS TelefonSms, Ope_Email AS Email FROM '  + CDN.BazaKonfiguracyjna() + N'.CDN.Operatorzy WHERE Ope_OpeID = ' + convert(nvarchar(20), @OpiekunID)
        EXEC sp_executesql @sqlText
    END
    ELSE
    SELECT '' as Typ, '' as Akronim, '' as Nazwisko, '' as TelefonSms, '' as Email
END
