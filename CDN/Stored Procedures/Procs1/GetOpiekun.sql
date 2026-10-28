CREATE PROCEDURE CDN.GetOpiekun
@ConfigStr nvarchar(70),
@OpiekunID int,
@OpiekunTyp int
AS
BEGIN
 DECLARE @sqlText nvarchar(1000)
 if @OpiekunTyp = 3
 SELECT 'pracownik'as Typ, PRI_Kod as Kod
  FROM CDN.PracIdx
  WHERE PRI_PraID = @OpiekunID
 ELSE
 if @OpiekunTyp = 8
 BEGIN
  SET @sqlText = 'SELECT ''operator'' as Typ, Ope_Kod as Kod
  FROM ' + @ConfigStr + '.CDN.Operatorzy' +
  ' WHERE Ope_OpeID = ' + convert(nvarchar(20), @OpiekunID)
  EXEC sp_executesql @sqlText
 END
 ELSE
 SELECT NULL as Typ, NULL as Kod
END
