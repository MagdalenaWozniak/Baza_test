CREATE TABLE [CDN].[KorektaPodatkuDochodowego] (
    [KPD_KPDID]     INT             IDENTITY (1, 1) NOT NULL,
    [KPD_Numer]     VARCHAR (30)    NOT NULL,
    [KPD_Data]      DATETIME        NOT NULL,
    [KPD_Koszty]    DECIMAL (15, 2) NOT NULL,
    [KPD_Przychody] DECIMAL (15, 2) NOT NULL,
    [KPD_ReNID]     INT             NULL,
    [KPD_Bufor]     SMALLINT        NOT NULL,
    [KPD_KPRID]     INT             NULL,
    CONSTRAINT [KPD_Primary] PRIMARY KEY CLUSTERED ([KPD_KPDID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_KPDLp] FOREIGN KEY ([KPD_ReNID]) REFERENCES [CDN].[RemanentNag] ([ReN_ReNID])
);


GO
CREATE  TRIGGER CDN.KorektaPodatkuDochodowego_InsertDelete_Trigger
  ON CDN.KorektaPodatkuDochodowego
  FOR INSERT, DELETE
AS
  SET NOCOUNT ON
declare @zwiekszanyNr integer
SELECT @zwiekszanyNr = KPR_SpisZNatury FROM CDN.ZapisyKPR WHERE KPR_KPRID IN (SELECT KPD_KPRID FROM inserted)
UPDATE CDN.ZapisyKPR SET KPR_SpisZNatury = IsNull(@zwiekszanyNr, 0) + 1 WHERE KPR_KPRID IN (SELECT KPD_KPRID FROM inserted)
declare @zmniejszanyNr integer
SELECT @zmniejszanyNr = KPR_SpisZNatury FROM CDN.ZapisyKPR WHERE KPR_KPRID IN (SELECT KPD_KPRID FROM deleted)
UPDATE CDN.ZapisyKPR SET KPR_SpisZNatury = IsNull(@zmniejszanyNr, 0) - 1 WHERE KPR_KPRID IN (SELECT KPD_KPRID FROM deleted)
SET NOCOUNT OFF
