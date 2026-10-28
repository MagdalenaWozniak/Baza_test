CREATE TABLE [CDN].[Wyplaty] (
    [WPL_WplId]             INT             IDENTITY (1, 1) NOT NULL,
    [WPL_PraId]             INT             NOT NULL,
    [WPL_LplId]             INT             NOT NULL,
    [WPL_DzlId]             INT             NOT NULL,
    [WPL_DdfId]             INT             NOT NULL,
    [WPL_Tryb]              INT             NOT NULL,
    [WPL_ParentId]          INT             NULL,
    [WPL_NumerString]       VARCHAR (31)    NOT NULL,
    [WPL_NumerNr]           INT             NOT NULL,
    [WPL_NumerPelny]        AS              ([CDN].[FN_NUMERPELNY]([WPL_NUMERNR],[WPL_NUMERSTRING])),
    [WPL_DataDok]           DATETIME        NOT NULL,
    [WPL_Wartosc]           DECIMAL (15, 2) NOT NULL,
    [WPL_Miesiac]           TINYINT         NOT NULL,
    [WPL_Rok]               INT             NOT NULL,
    [WPL_DataOd]            DATETIME        NOT NULL,
    [WPL_DataDo]            DATETIME        NOT NULL,
    [WPL_Nazwa]             NVARCHAR (40)   NOT NULL,
    [WPL_Zamknieta]         TINYINT         NOT NULL,
    [WPL_KatId]             INT             NULL,
    [WPL_KategoriaOpis]     VARCHAR (50)    NOT NULL,
    [WPL_KorektaPlatnosci]  TINYINT         NOT NULL,
    [WPL_KorektaPola]       INT             NOT NULL,
    [WPL_Brutto]            DECIMAL (15, 2) NOT NULL,
    [WPL_Korekta]           TINYINT         NOT NULL,
    [WPL_Archiwalna]        TINYINT         CONSTRAINT [DF_WPL_Archiwalna] DEFAULT ((0)) NOT NULL,
    [WPL_UmowaDodZas]       SMALLINT        CONSTRAINT [DF_WPL_UmowaDodZas] DEFAULT ((0)) NOT NULL,
    [WPL_OpeZalId]          INT             NULL,
    [WPL_StaZalId]          INT             NULL,
    [WPL_TS_Zal]            DATETIME        NULL,
    [WPL_OpeModId]          INT             NULL,
    [WPL_StaModId]          INT             NULL,
    [WPL_TS_Mod]            DATETIME        NULL,
    [WPL_TS_Import]         DATETIME        NULL,
    [WPL_KursLNal]          DECIMAL (15, 4) CONSTRAINT [DF_WPL_KursLNal] DEFAULT ((1)) NOT NULL,
    [WPL_KursMNal]          DECIMAL (5)     CONSTRAINT [DF_WPL_KursMNal] DEFAULT ((1)) NOT NULL,
    [WPL_OddelegowanyDieta] DECIMAL (15, 2) CONSTRAINT [DF_WPL_OddelegowanyDieta] DEFAULT ((0)) NOT NULL,
    [WPL_KursLNalDieta]     DECIMAL (15, 4) CONSTRAINT [DF_WPL_KursLNalDieta] DEFAULT ((1)) NOT NULL,
    [WPL_KursMNalDieta]     DECIMAL (5)     CONSTRAINT [DF_WPL_KursMNalDieta] DEFAULT ((1)) NOT NULL,
    [WPL_OpeModKod]         VARCHAR (20)    CONSTRAINT [DF_WPL_OpeModKod] DEFAULT ('') NOT NULL,
    [WPL_OpeModNazwisko]    NVARCHAR (50)   CONSTRAINT [DF_WPL_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [WPL_OpeZalKod]         VARCHAR (20)    CONSTRAINT [DF_WPL_OpeZalKod] DEFAULT ('') NOT NULL,
    [WPL_OpeZalNazwisko]    NVARCHAR (50)   CONSTRAINT [DF_WPL_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [WPL_ObnizSklPPK]       TINYINT         CONSTRAINT [DF_WPL_ObnizSklPPK] DEFAULT ((0)) NOT NULL,
    [WPL_KorektaPola2]      INT             CONSTRAINT [DF_WPL_KorektaPola2] DEFAULT ((0)) NOT NULL,
    [WPL_PodstawaPodat1]    DECIMAL (15, 2) CONSTRAINT [DF_WPL_PodstawaPodat1] DEFAULT ((0)) NOT NULL,
    [WPL_PodstawaPodat2]    DECIMAL (15, 2) CONSTRAINT [DF_WPL_PodstawaPodat2] DEFAULT ((0)) NOT NULL,
    [WPL_ProcentPodat1]     DECIMAL (5, 2)  CONSTRAINT [DF_WPL_ProcentPodat1] DEFAULT ((0)) NOT NULL,
    [WPL_ProcentPodat2]     DECIMAL (5, 2)  CONSTRAINT [DF_WPL_ProcentPodat2] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [WPL_Primary] PRIMARY KEY CLUSTERED ([WPL_WplId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_WPLDdfLink] FOREIGN KEY ([WPL_DdfId]) REFERENCES [CDN].[DokDefinicje] ([DDf_DDfID]),
    CONSTRAINT [FK_WPLDzlLink] FOREIGN KEY ([WPL_DzlId]) REFERENCES [CDN].[Dzialy] ([DZL_DzlId]),
    CONSTRAINT [FK_WPLKategoria] FOREIGN KEY ([WPL_KatId]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_WPLLplLink] FOREIGN KEY ([WPL_LplId]) REFERENCES [CDN].[ListyPlac] ([LPL_LplId]) ON DELETE CASCADE,
    CONSTRAINT [FK_WPLParent] FOREIGN KEY ([WPL_ParentId]) REFERENCES [CDN].[Wyplaty] ([WPL_WplId]),
    CONSTRAINT [FK_WPLPraLink] FOREIGN KEY ([WPL_PraId]) REFERENCES [CDN].[PracKod] ([PRA_PraId])
);


GO
CREATE NONCLUSTERED INDEX [WPLPraLink]
    ON [CDN].[Wyplaty]([WPL_PraId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPLDzlLink]
    ON [CDN].[Wyplaty]([WPL_DzlId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPLLplLink]
    ON [CDN].[Wyplaty]([WPL_LplId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPLDdfLink]
    ON [CDN].[Wyplaty]([WPL_DdfId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [WplNumerPelny]
    ON [CDN].[Wyplaty]([WPL_NumerPelny] ASC, [WPL_Tryb] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPLKategoria]
    ON [CDN].[Wyplaty]([WPL_KatId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [WPLInclude]
    ON [CDN].[Wyplaty]([WPL_ParentId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Wyplaty_DeleteHandler
  ON CDN.Wyplaty
  FOR DELETE
AS
SET NOCOUNT ON
    -- obsługa sprawdzania relacji restrict do tabeli CDN.DekretyElem
    IF EXISTS
       ( SELECT * FROM CDN.DekretyElem, deleted
          WHERE
                deleted.WPL_WplId = CDN.DekretyElem.DeE_DokumentId
       AND (CDN.DekretyElem.DeE_DokumentTyp =8)
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=DekretyElem##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS(
   SELECT * FROM CDN.KwotyDodatkowe INNER JOIN deleted
   ON deleted.WPL_WplId = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=8)
  )
  DELETE CDN.KwotyDodatkowe
  FROM CDN.KwotyDodatkowe, deleted
  WHERE deleted.WPL_WplId = CDN.KwotyDodatkowe.Kdd_DokumentID AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=8)
    IF EXISTS(
   SELECT * FROM CDN.BnkZdarzenia INNER JOIN deleted
   ON deleted.WPL_WplId = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=8)
  )
 begin
  declare @DokumentIDTable cdn.IdsTableType
  insert into @DokumentIDTable select WPL_WplId from deleted
  exec cdn.UsunZdarzeniaKBDokumentuEx @DokumentTyp = 8, @DokumentIDTable = @DokumentIDTable
  /*DELETE CDN.BnkZdarzenia
  FROM CDN.BnkZdarzenia, deleted
  WHERE deleted.WPL_WplId = CDN.BnkZdarzenia.BZd_DokumentId AND (CDN.BnkZdarzenia.BZd_DokumentTyp=8)*/
 end
SET NOCOUNT OFF

GO
Create Trigger CDN.Wyplaty_Delete_Trigger
  On CDN.Wyplaty
  For Delete
As
Set NoCount On
Set ArithAbort On
 --MC12 [k.w.]
 if exists (select * from deleted where deleted.wpl_tryb = 3)
  begin
   declare @StornujacaId int, @AnulowanaId int
   select @AnulowanaId = wpl_parentid from deleted
   declare @KorygujacaId int
   select @KorygujacaId = WPL_WplId from deleted
   if @AnulowanaId > 0
    begin
     select @StornujacaId = (select top 1 wpl_wplid from cdn.wyplaty where wpl_tryb = 2 and wpl_parentid = @AnulowanaId)
      if @StornujacaId > 0 and not exists (select top 1 wpl_wplid from cdn.wyplaty where wpl_tryb = 3 and WPL_WplId <> @KorygujacaId and wpl_parentid = @AnulowanaId)
       begin
        delete from cdn.wyplaty where wpl_wplid = @StornujacaId
       end
    end
  end
 if exists (select * from deleted where deleted.wpl_tryb = 1)
  begin
       RAISERROR('##OPT32557##', 16, 1)--raiserror('Nie można usunąć anulowanej wypłaty.', 16, 1)--ERR_SQL_Place_NieMoznaUsunacAnulowanejWyplaty
       rollback tran
       set nocount off
       return
  end
Declare @DokId Int
Declare skasowane Cursor Local Fast_Forward For
 Select WPL_WPLId From deleted
Open skasowane
While 1=1
 Begin
  Fetch Next From skasowane InTo @DokId
  If @@Fetch_Status <> 0 Break
  Execute CDN.KasujRozliczenia 8, @DokId
 End
Close skasowane
Deallocate skasowane
Set NoCount Off

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[Wyplaty_Delete_Trigger]', @order = N'first', @stmttype = N'delete';


GO
create trigger CDN.Wyplaty_InsertUpdate_Trigger
  on CDN.Wyplaty
  for insert
as
set nocount on
declare @praid int, @wplid int, @rok int, @miesiac int, @ddfid int, @datadok datetime, @wartosc decimal(14,2), @kategoria int, @tryb int, @numerpelny varchar(40), @numerstring varchar(40)
select @praid = WPL_PraId, @wplid = WPL_WplId, @rok = wpl_rok, @miesiac = WPL_Miesiac, @ddfid = wpl_ddfid, @datadok = WPL_DataDok, @wartosc = WPL_Wartosc, @tryb = WPL_Tryb, @numerpelny = WPL_NumerPelny, @numerstring = WPL_NumerString
 from inserted
if exists(select wpl_wplid from cdn.Wyplaty join cdn.ListyPlac on WPL_LplId = LPL_LplId
 where WPL_WplId <> @wplid and WPL_PraId = @praid and WPL_Rok = @rok and WPL_Miesiac = @miesiac and WPL_DdfId = @ddfid and WPL_NumerString = @numerstring /*and wpl_numerpelny = @numerpelny*/ and WPL_DataDok = @datadok
 and LPL_Kategoria not in (2, 64) and WPL_Tryb = @tryb)
  begin
    RAISERROR('##OPT32558##', 16, 1)--raiserror('Wypłata została zapisana wcześniej na innym stanowisku.', 16, 1)--ERR_SQL_Place_WyplataZostalaZapisanaStan
    rollback tran
    set nocount off
    return
  end
set nocount off
