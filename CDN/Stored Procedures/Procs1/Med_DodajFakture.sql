CREATE PROCEDURE [CDN].[Med_DodajFakture]
  @DSTrNID int ,  -- id obce dokumentu
  @StanDetalID int , -- id stanowiska
  @NumerNr int , -- numer dokumentu kolejne id np 1,2,3...
  @NumerString NVARCHAR(31) , -- numer dokumentu bez numeru np FA/@Numer/2010/MED
  @NumerPelny  NVARCHAR(50) , -- FA/1/2010/MED
  @DataDok datetime , -- data dokumentu
  @Fiskalna tinyint , -- czy zafiskalizowany (0/1)
  @PodID int , -- id podmiotu (kontrahenta) w optimie
  @OdbID int , -- id odbiorcy (kontrahenta) w optimie
  @Wartosc decimal(15, 2) , -- suma brutto
  @Rabat decimal(5, 2) , -- rabat
  @OsobaOdbierajaca nvarchar(40), -- imie i nazwisko osoby odbierajacej moze byc puste ''
  @OpeID int , -- id operatora
  @TS_Zal datetime , -- data zapisania faktury
  @IloscElementow int, -- ilosc elementow na fakturze - ilosc kontrolna
  @IloscPlatnosci int, -- ilosc platnosci na fakturze - ilosc kontrolna
  @TypNB int, -- 1 netto ,2 brutto
  @Korekta int, -- czy korekta
  @ZwrId int, -- id dokumentu korygowanego
  @PAId int = 0 -- id paragonu do ktorego jest faktura
AS
SET NOCOUNT ON
declare
    @DTrN_DTrNId INT
  SELECT  @DTrN_DTrNId = DTrN_DTrNId
    FROM CDN.DetalTraNag
    WHERE DTrN_DSTrNId = @DSTrNID and DTrN_StanDetalID= @StanDetalID
  IF @DTrN_DTrNId IS NULL
    BEGIN
       INSERT INTO CDN.DetalTraNag (
        DTrN_DSTrNID ,
        DTrN_StanDetalID ,
        DTrN_FAID ,
        DTrN_ZwrID ,
        DTrN_Korekta ,
        DTrN_TypDokumentu ,
        DTrN_NumerNr ,
        DTrN_NumerString ,
        DTrN_NumerPelny  ,
        DTrN_DataDok ,
        DTrN_Fiskalna ,
        DTrN_PodID ,
        DTrN_OdbID ,
        DTrN_RazemBrutto ,
        DTrN_Rabat ,
        DTrN_StanSynchronizacji ,
        DTrN_OsobaOdbierajaca,
        DTrN_OpeID ,
        DTrN_TS_Zal ,
        DTrN_IloscElementow ,
        DTrN_IloscPlatnosci,
        DTrN_Waluta,
        DTrN_TypNB )
  VALUES (
  @DSTrNID ,
  @StanDetalID ,
  @PAId ,
  @ZwrId,
  @Korekta,
  302 ,
  @NumerNr ,
  @NumerString ,
  @NumerPelny  ,
  @DataDok ,
  @Fiskalna ,
  @PodID ,
  @OdbID ,
  @Wartosc ,
  @Rabat ,
  1,
  @OsobaOdbierajaca,
  @OpeID ,
  @TS_Zal,
  @IloscElementow,
  @IloscPlatnosci,
  '',
  @TypNB
         )
END
  SET NOCOUNT OFF
