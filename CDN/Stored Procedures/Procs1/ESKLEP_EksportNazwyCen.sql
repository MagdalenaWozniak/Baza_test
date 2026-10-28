CREATE PROCEDURE CDN.ESKLEP_EksportNazwyCen
AS
BEGIN
 SELECT DISTINCT
 DfC_Lp as ID,
 DfC_Nazwa as Nazwa,
 1 as JezykID
 from cdn.defceny as CND where DfC_Lp > 1
 FOR XML AUTO
END
