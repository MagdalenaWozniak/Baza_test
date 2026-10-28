CREATE TABLE [CDN].[ZestawyTwr] (
    [ZTw_ZTwId]             INT             IDENTITY (1, 1) NOT NULL,
    [ZTw_TwrId]             INT             NULL,
    [ZTw_Kod]               VARCHAR (20)    NOT NULL,
    [ZTw_Nazwa]             NVARCHAR (512)  NOT NULL,
    [ZTw_TypRabatu]         TINYINT         NOT NULL,
    [ZTw_Wartosc]           DECIMAL (17, 4) NOT NULL,
    [ZTw_Waluta]            VARCHAR (3)     NOT NULL,
    [ZTw_DataOd]            DATETIME        NOT NULL,
    [ZTw_DataDo]            DATETIME        NOT NULL,
    [ZTw_GodzinaOd]         DATETIME        NOT NULL,
    [ZTw_GodzinaDo]         DATETIME        NOT NULL,
    [ZTw_ESklep]            TINYINT         NOT NULL,
    [ZTw_CzyOgraniczacDaty] TINYINT         NOT NULL,
    [ZTw_CzyOgraniczacCzas] TINYINT         NOT NULL,
    [ZTw_Opis]              NVARCHAR (254)  NOT NULL,
    [ZTw_OpeZalID]          INT             NULL,
    [ZTw_StaZalId]          INT             NULL,
    [ZTw_TS_Zal]            DATETIME        NOT NULL,
    [ZTw_OpeModID]          INT             NULL,
    [ZTw_StaModId]          INT             NULL,
    [ZTw_TS_Mod]            DATETIME        NOT NULL,
    [ZTw_OpeModKod]         VARCHAR (20)    CONSTRAINT [DF_ZTw_OpeModKod] DEFAULT ('') NOT NULL,
    [ZTw_OpeModNazwisko]    NVARCHAR (50)   CONSTRAINT [DF_ZTw_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [ZTw_OpeZalKod]         VARCHAR (20)    CONSTRAINT [DF_ZTw_OpeZalKod] DEFAULT ('') NOT NULL,
    [ZTw_OpeZalNazwisko]    NVARCHAR (50)   CONSTRAINT [DF_ZTw_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [ZTw_Primary] PRIMARY KEY CLUSTERED ([ZTw_ZTwId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ZTwTwrKod] FOREIGN KEY ([ZTw_TwrId]) REFERENCES [CDN].[Towary] ([Twr_TwrId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [ZTwTwrKod]
    ON [CDN].[ZestawyTwr]([ZTw_TwrId] ASC, [ZTw_Kod] ASC) WITH (FILLFACTOR = 100);


GO
Create TRIGGER [CDN].[ZestawyTwr_InsertUpdate_Trigger]
ON [CDN].[ZestawyTwr]
FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  SET NOCOUNT OFF

GO
CREATE TRIGGER [CDN].[ZestawyTwr_Delete_Trigger]
ON [CDN].[ZestawyTwr]
FOR DELETE
AS
  SET NOCOUNT ON
if exists (select * from deleted where ZTw_ESklep = 1 )
Begin
          if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 ) and exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1)
   RAISERROR('##OPT34541##', 16, 1)
    else
   if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 )
    RAISERROR('##OPT34543##', 16, 1)
      else
   if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1 )
    RaisError ('##OPT34542##', 16,1)
   else
    RaisError ('##OPT34541##', 16,1)
          RollBack Tran
          Return
end
if exists (select * from deleted where ZTw_ESklep = 0 and  exists (select * from cdn.eSklepStanowiska where  dateadd( second, CONVERT(INT,ESS_TS_SynchroTwrPotw),CONVERT(DATETIME,'1990-01-01',120))  < ZTw_TS_Mod and dateadd( second, CONVERT(INT,ESS_TS_SynchroTwrPotw),CONVERT(DATETIME,'1990-01-01',120)) > ZTw_TS_Zal))
Begin
          if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 ) and exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1)
   RaisError ('##OPT34538##', 16,1)
  else
  if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 2 )
   RaisError ('##OPT34540##', 16,1)
  else
  if exists (select * from cdn.eSklepStanowiska where ESS_Typ = 1 )
   RaisError ('##OPT34539##', 16,1)
  else
   RaisError ('##OPT34538##', 16,1)
          RollBack Tran
          Return
end
  SET NOCOUNT OFF
