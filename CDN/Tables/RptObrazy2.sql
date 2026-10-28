CREATE TABLE [CDN].[RptObrazy2] (
    [RPO2_RPO2ID]      INT   IDENTITY (1, 1) NOT NULL,
    [RPO2_ZrodloID]    INT   NOT NULL,
    [RPO2_RpWID]       INT   NOT NULL,
    [RPO2_RpFID]       INT   NOT NULL,
    [RPO2_DokumentTyp] INT   NOT NULL,
    [RPO2_DokumentID]  INT   NOT NULL,
    [RPO2_Wartosc]     IMAGE NULL,
    [RPO2_Rozmiar]     INT   NULL,
    CONSTRAINT [RPO2_Primary] PRIMARY KEY CLUSTERED ([RPO2_RPO2ID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [RPO2Dokument]
    ON [CDN].[RptObrazy2]([RPO2_DokumentTyp] ASC, [RPO2_DokumentID] ASC, [RPO2_ZrodloID] ASC, [RPO2_RpWID] ASC, [RPO2_RpFID] ASC, [RPO2_RPO2ID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.RptObrazy2_Delete_Trigger
  ON CDN.RptObrazy2
  FOR DELETE
AS
SET NOCOUNT ON
    -- obsługa kaskadowego kasowania wierszy z tabeli CDN.RptObrazy2
  IF EXISTS (SELECT * FROM deleted d join cdn.bnkzdarzenia on bzd_dokumentid = d.rpo2_dokumentid)
  BEGIN
  DELETE FROM CDN.RptObrazy2 WHERE Rpo2_DokumentTyp=120 AND Rpo2_DokumentId IN (
  SELECT Bzd_BzdId from deleted d join cdn.bnkzdarzenia on
      d.rpo2_dokumentid =  bzd_dokumentid and bzd_dokumenttyp=6)
   END
     -- obsługa kaskadowego kasowania wierszy dla tabeli CDN.RptObrazy2
    IF EXISTS (SELECT * FROM CDN.DeklNag JOIN deleted on dkn_dknid = rpo2_dokumentid and rpo2_dokumenttyp=100 and dkn_zablokowana = 0)
      BEGIN
        DELETE FROM CDN.RptObrazy2 WHERE Rpo2_DokumentId IN (SELECT A.Dkn_DknId From CDN.DeklNag A Join CDN.Deklnag B
           On A.DkN_TypDeklar In (13,14) And B.DkN_TypDeklar = 11 And A.DkN_RokMiesiac = B.DkN_RokMiesiac
           AND B.dkn_dknid IN (Select Rpo2_DokumentId FROM Deleted where rpo2_dokumenttyp = 100) )
      END
     -- obsługa kaskadowego kasowania wierszy dla tabeli CDN.RptObrazy2
    IF EXISTS (SELECT * FROM CDN.DeklNag JOIN deleted on dkn_dknid = rpo2_dokumentid and rpo2_dokumenttyp=100 and dkn_zablokowana = 1)
      BEGIN
        DELETE FROM CDN.RptObrazy2 WHERE Rpo2_DokumentId IN (SELECT A.Dkn_DknId From CDN.DeklNag A Join CDN.Deklnag B
           On A.DkN_TypDeklar In (13,14) And B.DkN_TypDeklar = 11 And A.DkN_RokMiesiac = B.DkN_RokMiesiac
           AND B.dkn_dknid IN (Select Rpo2_DokumentId FROM Deleted where rpo2_dokumenttyp = 100) )
      END
SET NOCOUNT OFF
