CREATE TABLE [CDN].[TwrESklep] (
    [Twes_TwesId]                             INT             IDENTITY (1, 1) NOT NULL,
    [Twes_ESklepId]                           INT             NOT NULL,
    [Twes_Udostepnij]                         INT             NOT NULL,
    [Twes_TwrID]                              INT             NOT NULL,
    [Twes_ESklepBezRabatu]                    SMALLINT        NOT NULL,
    [Twes_ESklepStatus]                       SMALLINT        NOT NULL,
    [Twes_ESklepDostepnosc]                   SMALLINT        NOT NULL,
    [Twes_ESklepKalkulacjaDostaw]             TINYINT         NOT NULL,
    [Twes_ESklepKalkulacjaDostawWartosc]      DECIMAL (15, 2) NOT NULL,
    [Twes_ESklepFlaga_Nowosc]                 TINYINT         NOT NULL,
    [Twes_ESklepFlaga_Promocja]               TINYINT         NOT NULL,
    [Twes_ESklepFlaga_ProduktzGazetki]        TINYINT         NOT NULL,
    [Twes_ESklepFlaga_ProduktPolecany]        TINYINT         NOT NULL,
    [Twes_ESklepFlaga_Wyprzedaz]              TINYINT         NOT NULL,
    [Twes_ESklepFlaga_SuperJakosc]            TINYINT         NOT NULL,
    [Twes_ESklepFlaga_SuperCena]              TINYINT         NOT NULL,
    [Twes_ESklepFlaga_NajlepiejOceniany]      TINYINT         NOT NULL,
    [Twes_ESklepFlaga_RekomendacjaSprzedawcy] TINYINT         NOT NULL,
    [Twes_TwGGIDNumer]                        INT             NOT NULL,
    [Twes_ESklepZapytajOCene]                 SMALLINT        CONSTRAINT [DF_Twes_ESklepZapytajOCene] DEFAULT ((0)) NOT NULL,
    [Twes_ESklepNieKontrolujStanow]           SMALLINT        CONSTRAINT [DF_Twes_ESklepNieKontrolujStanow] DEFAULT ((0)) NOT NULL,
    [Twes_ESklepDostepnyOd]                   SMALLINT        CONSTRAINT [DF_Twes_ESklepDostepnyOd] DEFAULT ((0)) NOT NULL,
    [Twes_ESklepDataDostepnosci]              DATETIME        CONSTRAINT [DF_Twes_ESklepDataDostepnosci] DEFAULT (getdate()) NOT NULL,
    [Twes_ESklepFlaga_Nagroda]                TINYINT         CONSTRAINT [DF_Twes_ESklepFlaga_Nagroda] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [Twes_Primary] PRIMARY KEY CLUSTERED ([Twes_TwesId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TwesESklepStanowiska] FOREIGN KEY ([Twes_ESklepId]) REFERENCES [CDN].[eSklepStanowiska] ([ESS_ESSId]) ON DELETE CASCADE,
    CONSTRAINT [FK_TwesTowar] FOREIGN KEY ([Twes_TwrID]) REFERENCES [CDN].[Towary] ([Twr_TwrId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [TwesTowar]
    ON [CDN].[TwrESklep]([Twes_TwrID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER [CDN].[TwrESklep_InsertUpdate_Trigger]
ON [CDN].[TwrESklep]
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
-- Sprawdzanie flagi esklep towaru i zestawu
  If Update (Twes_udostepnij)
    begin
      update cdn.danebinarne set dab_ts_mod = getdate()
       where dab_dabid in (select DBL_dabid from cdn.DaneBinarneLinki where not DBL_DabId is null and DBL_twrid in (select twes_twrid from inserted where Twes_udostepnij = 1))
      update cdn.twrgrupy SET TwG_CzasModyfikacji = DATEDIFF(s,CONVERT(datetime,'1990-01-01',120),GETDATE())
       where TwG_GIDNumer in (select twes_twrid from inserted join cdn.towary twes_twrid on twes_twrid = twr_twrid where Twes_udostepnij = 1 and Twr_nieaktywny = 0) and TwG_GIDTyp = 16
      update Twr  set TwTS_TS_ModESklep = GETDATE() from CDN.TwrTSModEsklep Twr
      join cdn.Towary on TwTS_TwrId = Twr_TwrId
       where Twr_ESklepFantomID in (select twes_twrid from inserted where Twes_udostepnij = 0)
    and Not exists (select * from cdn.TwrESklep where Twes_udostepnij = 1  and Twes_TwrID = Twr_ESklepFantomID)
      insert into  CDN.TwrTSModEsklep
      select Twr_TwrId,GETDATE() from cdn.towary
      left join CDN.TwrTSModEsklep on TwTS_TwrId = Twr_TwrId
       where TwTS_TwrId is null and Twr_ESklepFantomID in (select twes_twrid from inserted where Twes_udostepnij = 0)
    and Not exists (select * from cdn.TwrESklep where Twes_udostepnij = 1  and Twes_TwrID = Twr_ESklepFantomID)
      update cdn.Towary set Twr_ESklepFantomID = null/*,Twr_ts_mod = getdate()*/  where Twr_ESklepFantomID in (select twes_twrid from inserted where Twes_udostepnij = 0)
    and Not exists (select * from cdn.TwrESklep where Twes_udostepnij = 1  and Twes_TwrID = Twr_ESklepFantomID)
    end
  SET NOCOUNT OFF
