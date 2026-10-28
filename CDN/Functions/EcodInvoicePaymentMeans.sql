CREATE FUNCTION CDN.EcodInvoicePaymentMeans(@InvoicePaymentMeans NVARCHAR(20))
RETURNS VARCHAR(3)
AS
BEGIN
 DECLARE @paymentMeans VARCHAR(3)
 SET @paymentMeans = '42'
 SET @InvoicePaymentMeans = LOWER(@InvoicePaymentMeans)
 IF @InvoicePaymentMeans LIKE '%gotówka%' RETURN '10'
 IF @InvoicePaymentMeans LIKE '%czek%' RETURN '20'
 IF @InvoicePaymentMeans LIKE '%przelew%' RETURN  '42'
    IF @InvoicePaymentMeans LIKE '%rat%' RETURN '21'
 RETURN @paymentMeans
END
