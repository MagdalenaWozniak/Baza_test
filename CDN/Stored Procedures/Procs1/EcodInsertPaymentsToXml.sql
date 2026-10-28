CREATE PROCEDURE CDN.EcodInsertPaymentsToXml
@TrnID            AS INT
AS
BEGIN
  DECLARE @walSys VARCHAR(3)
  EXEC CDN.SymbolWalSys @walSys OUTPUT
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Payments', '', -1)
   DECLARE @InvoicePaymentDueDate DATETIME, @InvoicePaymentMeans VARCHAR(3), @paymentMeans NVARCHAR(20), @PaymentAmount DECIMAL(15,2), @PaymentCurrency VARCHAR(3)
   DECLARE paymentsCursor CURSOR FOR
   SELECT BZd_Termin, (SELECT FPl_Nazwa FROM CDN.FormyPlatnosci WHERE FPl_FPlId = BZd_FPlId) As FplTyp, (BZd_Kierunek * BZd_Kwota) As BZd_Kwota, BZd_Waluta FROM cdn.BnkZdarzenia WHERE BzD_DokumentTyp=1 AND  BZd_DokumentID = @TrnID ORDER BY  BZd_BzdId
   OPEN paymentsCursor
   WHILE 1=1
   BEGIN
    FETCH NEXT FROM paymentsCursor INTO @InvoicePaymentDueDate, @paymentMeans, @PaymentAmount, @PaymentCurrency
    IF @@FETCH_STATUS <> 0 BREAK
    SET @InvoicePaymentMeans = CDN.EcodInvoicePaymentMeans(@paymentMeans)
    IF @PaymentCurrency = ''  SET @PaymentCurrency = @walSys
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Payment', '', -1)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoicePaymentDueDate', Convert(nvarchar(10), @InvoicePaymentDueDate, 120), 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('InvoicePaymentMeans', @InvoicePaymentMeans, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PaymentAmount',   LTrim(Str(@PaymentAmount,15,2)), 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('PaymentCurrency',  @PaymentCurrency, 0)
    INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Payment', '', 1)
   END
   CLOSE paymentsCursor
   DEALLOCATE paymentsCursor
  INSERT INTO #EcodXml (Tag, Wartosc, Flaga) VALUES('Payments', '', 1)
END
