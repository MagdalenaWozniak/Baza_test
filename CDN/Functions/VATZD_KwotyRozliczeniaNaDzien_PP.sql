create FUNCTION [CDN].[VATZD_KwotyRozliczeniaNaDzien_PP]( @Typ INT, @data DateTime, @McKw INT, @DknId INT )
RETURNS @Result TABLE(
    BZdId     int,
    VaNId       int,
    KwotaDoRozliczeniaNaDzien Decimal(15,2),
    KwotaRozliczonaNaDzien  Decimal(15,2),
   Termin DateTime,
   /*PP dodany indeks to tabeli*/
   Uniqueifier INT NOT NULL IDENTITY(1,1),
   PRIMARY KEY (BZdId, Vanid, Termin, Uniqueifier))
AS
BEGIN
 insert into @result
 /*PP warunek na VANID IS NOT NULLi grupowanie również po terminie */
 --select BZdId, Vanid, Sum(IsNull(SumaKwotZdarzen,0)), Sum(IsNull(SumaKwotRozliczen,0)), Termin from CDN.VATZD_Zobowiazania(@data, @McKw, @Typ, @DknId, NULL, null) where  VANID is not null group by BZdId, VANID, Termin
 select BZdId, Vanid, Sum(IsNull(SumaKwotZdarzen,0)), Sum(IsNull(SumaKwotRozliczen,0)), Termin from CDN.VATZD_Zobowiazania(@data, @McKw, @Typ, @DknId, NULL, null) group by BZdId, VANID, Termin
 return
END
