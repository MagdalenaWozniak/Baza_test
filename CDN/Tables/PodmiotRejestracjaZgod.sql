CREATE TABLE [CDN].[PodmiotRejestracjaZgod] (
    [PRZ_PRZId]              INT             IDENTITY (1, 1) NOT NULL,
    [PRZ_PodmiotId]          INT             NOT NULL,
    [PRZ_PodmiotTyp]         SMALLINT        NOT NULL,
    [PRZ_PrzedstawicielId]   INT             CONSTRAINT [DF_PRZ_Przedstawiciel] DEFAULT ((0)) NOT NULL,
    [PRZ_TrescZgodyId]       INT             NOT NULL,
    [PRZ_EMAIL]              TINYINT         NOT NULL,
    [PRZ_SMS]                TINYINT         NOT NULL,
    [PRZ_Telefon]            TINYINT         NOT NULL,
    [PRZ_List]               TINYINT         NOT NULL,
    [PRZ_DataWyrazenia]      DATETIME        NOT NULL,
    [PRZ_ZrodloPozyskaniaId] INT             NOT NULL,
    [PRZ_IPWyrazenia]        NVARCHAR (254)  NOT NULL,
    [PRZ_DataWycofania]      DATETIME        NULL,
    [PRZ_ZrodloWycofaniaId]  INT             CONSTRAINT [DF_PRZ_ZrodloWycofaniaId] DEFAULT ((0)) NOT NULL,
    [PRZ_IPWycofania]        NVARCHAR (254)  CONSTRAINT [DF_PRZ_IPWycofania] DEFAULT ('') NOT NULL,
    [PRZ_PowodWycofania]     NVARCHAR (1000) CONSTRAINT [DF_PRZ_PowodWycofania] DEFAULT ('') NOT NULL,
    [PRZ_Akronim]            NVARCHAR (50)   CONSTRAINT [DF_PRZ_Akronim] DEFAULT ('') NOT NULL,
    [PRZ_ImieNazwisko]       NVARCHAR (150)  CONSTRAINT [DF_PRZ_ImieNazwisko] DEFAULT ('') NOT NULL,
    [PRZ_JezykId]            INT             CONSTRAINT [DF_PRZ_JezykId] DEFAULT ((1)) NOT NULL,
    [PRZ_WyrazenieESklepId]  INT             CONSTRAINT [DF_PRZ_WyrazenieESklepId] DEFAULT ((0)) NOT NULL,
    [PRZ_WycofanieESklepId]  INT             CONSTRAINT [DF_PRZ_WycofanieESklepId] DEFAULT ((0)) NOT NULL,
    [PRZ_TS_Mod]             DATETIME        CONSTRAINT [DF_PRZ_TS_Mod] DEFAULT (getdate()) NOT NULL,
    [PRZ_TrNId]              INT             CONSTRAINT [DF_PRZ_TrNId] DEFAULT ((0)) NOT NULL,
    [PRZ_WyrazenieMobileId]  INT             CONSTRAINT [DF_PRZ_WyrazenieMobileId] DEFAULT ((0)) NOT NULL,
    [PRZ_WycofanieMobileId]  INT             CONSTRAINT [DF_PRZ_WycofanieMobileId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PRZ_Primary] PRIMARY KEY CLUSTERED ([PRZ_PRZId] ASC) WITH (FILLFACTOR = 100)
);


GO
create TRIGGER [CDN].[PodmiotRejestracjaZgodUpdate_CzasModyfikacji]
  ON CDN.PodmiotRejestracjaZgod
  FOR UPDATE
AS
BEGIN
SET NOCOUNT ON
  IF NOT UPDATE(PRZ_TS_Mod)
  UPDATE CDN.PodmiotRejestracjaZgod SET PRZ_TS_Mod = GETDATE()
       FROM  CDN.PodmiotRejestracjaZgod P JOIN inserted I ON P.PRZ_PRZID = I.PRZ_PRZID
SET NOCOUNT OFF
END
