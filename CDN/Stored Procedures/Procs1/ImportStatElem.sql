CREATE  PROCEDURE CDN.ImportStatElem
@headId int,
@typeElem int,
@sumElemEksp nvarchar(10),
@sumElemImp int
AS
BEGIN
 INSERT INTO CDN.StatElem
 (
 StE_StNId,
 StE_LiczbaElemEksp,
 StE_LiczbaElemImp,
 StE_TypElem
 )
 VALUES
 (
 @headId,
 convert(int, @sumElemEksp),
 @sumElemImp,
 @typeElem
 )
END
