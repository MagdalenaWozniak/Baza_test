CREATE PROCEDURE [CDN].[Med_DodajElementDokumentu]
 @DSTrEID int , -- id obce elementu
 @DSTrNID int , -- id obce dokumentu
 @StanDetalID int, -- id stanowiska
 @ZwrId int, -- id obce pozycji do ktorej jest korekta
 @TwrID int , -- id towaru
 @Stawka decimal(5, 2) , -- stawka vat
 @Flaga smallint , -- stawka Zwolniona = 1,Opodatkowana = 2,Zaniżona  = 3,Niepodległa = 4
 @Cena decimal(15, 2) , -- cena towaru
 @Rabat decimal(5, 2) , -- rabat
 @CenaPoRabacie decimal(15, 2) , -- cena po rabacie
 @Ilosc decimal(15, 4) , -- ilosc
 @Jm nvarchar(20) , -- symbol jednostki miary
 @Wartosc decimal(15, 2), -- wartosc elementu czyli cenaporabacie * ilosc
 @Zlozony tinyint = 0, --czy jest to usługa złożona
 @UslugaZlozonaRecepturaID int = 0 -- id receptury która ma być użyta 0 - domyślna
AS
SET NOCOUNT ON
DECLARE
    @DTrE_DTrEId INT
  SELECT  @DTrE_DTrEId = DTrE_DTrEId
    FROM CDN.DetalTraElem
    WHERE DTrE_DSTrEId = @DSTrEID and  DTrE_StanDetalID = @StanDetalID
  IF @DTrE_DTrEId IS NULL
    BEGIN
       INSERT INTO CDN.DetalTraElem (
 DTrE_DSTrEID ,
 DTrE_DSTrNID ,
 DTrE_StanDetalID,
 DTrE_ZwrID ,
 DTrE_TwrID ,
 DTrE_Stawka ,
 DTrE_Flaga ,
 DTrE_Cena ,
 DTrE_Rabat ,
 DTrE_CenaPoRabacie ,
 DTrE_Kaucja ,
 DTrE_Ilosc ,
 DTrE_Jm ,
 DTrE_JmCalkowite ,
 DTrE_WartoscBrutto,
 DTrE_Waluta ,
 DTrE_UslugaZlozona ,
 DTrE_UslugaZlozonaRecepturaID )
  VALUES (
 @DSTrEID ,
 @DSTrNID ,
    @StanDetalID ,
 @ZwrID ,
 @TwrID ,
 @Stawka ,
 @Flaga ,
 @Cena ,
 @Rabat ,
 @CenaPoRabacie ,
 0 ,
 @Ilosc ,
 @Jm ,
 0 ,
 @Wartosc,
 '',
 @Zlozony,
 @UslugaZlozonaRecepturaID
         )
    END
  SET NOCOUNT OFF
