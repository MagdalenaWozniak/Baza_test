CREATE TABLE [CDN].[Trwale] (
    [SrT_SrTID]                   INT             IDENTITY (1, 1) NOT NULL,
    [SrT_Typ]                     SMALLINT        NOT NULL,
    [SrT_Grupa]                   VARCHAR (20)    NOT NULL,
    [SrT_Lp]                      INT             NOT NULL,
    [SrT_VaNID]                   INT             NULL,
    [SrT_Dokument]                VARCHAR (30)    NOT NULL,
    [SrT_DataZak]                 DATETIME        NOT NULL,
    [SrT_DataPrz]                 DATETIME        NULL,
    [SrT_DataAmo]                 DATETIME        NULL,
    [SrT_DataUmo]                 DATETIME        NULL,
    [SrT_Nazwa]                   NVARCHAR (256)  NOT NULL,
    [SrT_KatID]                   INT             NULL,
    [SrT_Kategoria]               VARCHAR (50)    NOT NULL,
    [SrT_KRST]                    NVARCHAR (20)   NOT NULL,
    [SrT_NrInwent]                VARCHAR (20)    NOT NULL,
    [SrT_WartoscBilan]            DECIMAL (15, 2) NOT NULL,
    [SrT_WartoscKoszt]            DECIMAL (15, 2) NOT NULL,
    [SrT_Bilansowa]               TINYINT         NOT NULL,
    [SrT_UlgaInwestyc]            DECIMAL (15, 2) NOT NULL,
    [SrT_Metoda]                  TINYINT         NOT NULL,
    [SrT_MetodaBil]               TINYINT         NOT NULL,
    [SrT_Stawka]                  DECIMAL (5, 2)  NOT NULL,
    [SrT_StawkaBil]               DECIMAL (5, 2)  NOT NULL,
    [SrT_Wspolczynnik]            DECIMAL (7, 4)  NOT NULL,
    [SrT_WspolczynnikBil]         DECIMAL (7, 4)  NOT NULL,
    [SrT_Sezonowy]                TINYINT         NOT NULL,
    [SrT_SezonowyBil]             TINYINT         NOT NULL,
    [SrT_ZawieszenieAmoKst]       TINYINT         CONSTRAINT [DF_SrT_ZawieszenieAmoKst] DEFAULT ((0)) NOT NULL,
    [SrT_ZawieszenieAmoBil]       TINYINT         CONSTRAINT [DF_SrT_ZawieszenieAmoBil] DEFAULT ((0)) NOT NULL,
    [SrT_PrcID]                   INT             NULL,
    [SrT_PrcNazwisko]             NVARCHAR (100)  NOT NULL,
    [SrT_KontoGl]                 NVARCHAR (20)   NOT NULL,
    [SrT_KontoUm]                 NVARCHAR (20)   NOT NULL,
    [SrT_KontoAmKoszt]            NVARCHAR (20)   NOT NULL,
    [SrT_KontoAmRozn]             NVARCHAR (20)   NOT NULL,
    [SrT_DataLikw]                DATETIME        NULL,
    [SrT_Stan]                    TINYINT         NOT NULL,
    [SrT_Likwidacja]              NVARCHAR (50)   NOT NULL,
    [SrT_LikwDokument]            NVARCHAR (256)  NOT NULL,
    [SrT_LikwDekID]               INT             NULL,
    [SrT_Rodzaj]                  TINYINT         NOT NULL,
    [SrT_WZestawie]               TINYINT         NOT NULL,
    [SrT_WBudowie]                TINYINT         NOT NULL,
    [SrT_Opis]                    NVARCHAR (MAX)  NOT NULL,
    [SrT_ImportAppId]             VARCHAR (5)     NULL,
    [SrT_ImportRowId]             VARCHAR (36)    NULL,
    [SrT_OpeZalID]                INT             NULL,
    [SrT_StaZalId]                INT             NULL,
    [SrT_TS_Zal]                  DATETIME        NOT NULL,
    [SrT_OpeModID]                INT             NULL,
    [SrT_StaModId]                INT             NULL,
    [SrT_TS_Mod]                  DATETIME        NOT NULL,
    [SrT_UniqueNrInwBuster]       AS              (case when [SrT_WBudowie]<>(0) AND [SrT_NrInwent]='' then [SrT_SrTID] else (0) end),
    [SrT_UwzglKsgBadRozw]         TINYINT         CONSTRAINT [DF_SrT_UwzglKsgBadRozw] DEFAULT ((0)) NOT NULL,
    [SrT_KodKreskowy]             VARCHAR (128)   CONSTRAINT [DF_SrT_KodKreskowy] DEFAULT ('') NOT NULL,
    [SrT_UniqueKodKreskowyBuster] AS              (case when [SrT_KodKreskowy]='' then [SrT_SrTID] else (0) end),
    [SrT_ZakID]                   INT             NULL,
    [SrT_OpeModKod]               VARCHAR (20)    CONSTRAINT [DF_SrT_OpeModKod] DEFAULT ('') NOT NULL,
    [SrT_OpeModNazwisko]          NVARCHAR (50)   CONSTRAINT [DF_SrT_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SrT_OpeZalKod]               VARCHAR (20)    CONSTRAINT [DF_SrT_OpeZalKod] DEFAULT ('') NOT NULL,
    [SrT_OpeZalNazwisko]          NVARCHAR (50)   CONSTRAINT [DF_SrT_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SrT_Primary] PRIMARY KEY CLUSTERED ([SrT_SrTID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrTKategoria] FOREIGN KEY ([SrT_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_SrTPracownik] FOREIGN KEY ([SrT_PrcID]) REFERENCES [CDN].[PracKod] ([PRA_PraId])
);


GO
CREATE NONCLUSTERED INDEX [SrTKategoria]
    ON [CDN].[Trwale]([SrT_KatID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrTPracownik]
    ON [CDN].[Trwale]([SrT_PrcID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTLp]
    ON [CDN].[Trwale]([SrT_Typ] ASC, [SrT_Grupa] ASC, [SrT_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTNazwa]
    ON [CDN].[Trwale]([SrT_Typ] ASC, [SrT_Nazwa] ASC, [SrT_SrTID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTNazwaGrupa]
    ON [CDN].[Trwale]([SrT_Typ] ASC, [SrT_Grupa] ASC, [SrT_Nazwa] ASC, [SrT_Lp] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTDekrety]
    ON [CDN].[Trwale]([SrT_LikwDekID] ASC, [SrT_SrTID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTNrInwent]
    ON [CDN].[Trwale]([SrT_NrInwent] ASC, [SrT_UniqueNrInwBuster] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTKodKreskowy]
    ON [CDN].[Trwale]([SrT_KodKreskowy] ASC, [SrT_UniqueKodKreskowyBuster] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrTGUID]
    ON [CDN].[Trwale]([SrT_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Trwale_Delete_Trigger
  ON CDN.Trwale
  FOR DELETE
AS
SET NOCOUNT ON
SET ARITHABORT ON
-- obsługa sprawdzania relacji restrict do tabeli CDN.TrwaleAIElem
IF EXISTS (SELECT * FROM CDN.TrwaleAIElem join deleted ON SrTAIE_SrTID = SrT_SrTID)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=TrwaleAIElem##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą TrwaleAIElem). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Skasowanie relacji do dokumentów z biblioteki  (RZ za WJ)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1004 AND DoR_DokumentId=deleted.SrT_SrtId
SET NOCOUNT OFF

GO
EXECUTE sp_settriggerorder @triggername = N'[CDN].[Trwale_Delete_Trigger]', @order = N'first', @stmttype = N'delete';


GO
CREATE TRIGGER CDN.Trwale_InsertUpdate_Trigger
  ON CDN.Trwale
  FOR INSERT, UPDATE
AS
Set NoCount On
If Exists (select * from inserted join cdn.TrwaleHist on SrH_SrTID = inserted.SrT_SrTID
 where inserted.SrT_WBudowie <> 0 and SrH_TypDokumentu <> 4 and SrH_TypDokumentu <> 5 and SrH_TypDokumentu <> 6)
BEGIN
 RAISERROR('##OPT32364##', 16, 1) -- RAISERROR('Środek w budowie nie może posiadać dokumentów innych niż OT, LT i PT. Należy usunąć wygenerowane dokumenty.',16,1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
END
If Exists (select * from inserted join cdn.TrwaleHist on SrH_SrTID = inserted.SrT_SrTID
 where inserted.SrT_WBudowie <> 0  and SrH_TypDokumentu = 4 and (IsNull(SrH_DekId, 0)<>0 or IsNull(SrH_KPRId, 0)<>0))
BEGIN
 RAISERROR('##OPT32365##', 16, 1) -- RAISERROR('Środek w budowie nie może posiadać zaksięgowanych dokumentów OT. Usuń księgowanie.',16,1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
END
If (UPDATE(SrT_DataPrz) OR UPDATE(SrT_DataZak)) AND
 Exists (select * from inserted inner join cdn.TrwaleAIElem ON SrTAIE_SrTID = inserted.SrT_SrTID inner join cdn.TrwaleAINag ON SrTAIN_SrTAINID = SrTAIE_SrTAINID
    where inserted.SrT_DataPrz > SrTAIN_DataDok OR inserted.SrT_DataZak > SrTAIN_DataDok)
BEGIN
 RAISERROR('##OPT32366##', 16, 1) -- RAISERROR('Środek trwały został wybrany na dokumencie inwentaryzacji. Data zakupu/przyjęcia nie może być wcześniejsza niż data wystawienia dokumentu inwentaryzacji, na którym ten środek został uwzględniony.',16,1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
END
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where SrT_ImportRowId Is Null Or SrT_ImportRowId = '')
  Update CDN.Trwale Set SrT_ImportRowId = NewId()
  Where SrT_SrTId In (Select SrT_SrTId From inserted Where SrT_ImportRowId Is Null Or SrT_ImportRowId = '')
Declare
 @SrT_SrTID Int,
 @SrT_Typ SmallInt,
 @SrT_WBudowie TinyInt,
 @SrT_Grupa NVarchar(20),
 @SrT_Lp Int,
 @SrT_Rodzaj Int,
 @SrT_VaNID Int,
 @SrT_Dokument NVarchar(30),
 @SrT_DataZak DateTime,
 @SrT_DataPrz DateTime,
 @SrT_DataAmo DateTime,
 @SrT_DataUmo DateTime,
 @SrT_Nazwa NVarchar(50),
 @SrT_KatID Int,
 @SrT_Kategoria NVarchar(50),
 @SrT_KRST NVarchar(20),
 @SrT_NrInwent NVarchar(20),
 @SrT_WartoscBilan Decimal (15, 2),
 @SrT_WartoscKoszt Decimal (15, 2),
 @SrT_Bilansowa TinyInt,
 @SrT_UlgaInwestyc Decimal (15, 2),
 @SrT_Metoda TinyInt,
 @SrT_MetodaBil TinyInt,
 @SrT_Stawka Decimal (5, 2),
 @SrT_StawkaBil Decimal (5, 2),
 @SrT_Wspolczynnik Decimal (5, 2),
 @SrT_WspolczynnikBil Decimal (5, 2),
 @SrT_Sezonowy TinyInt,
 @SrT_SezonowyBil TinyInt,
 @SrT_PrcID Int,
 @SrT_PrcNazwisko NVarchar(100),
 @SrT_KontoGl NVarchar(20),
 @SrT_KontoUm NVarchar(20),
 @SrT_KontoAmKoszt NVarchar(20),
 @SrT_KontoAmRozn NVarchar(20),
 @SrT_DataLikw DateTime,
 @SrT_Stan TinyInt,
 @SrT_Likwidacja NVarchar(50),
 @SrT_LikwDokument NVarchar(256),
 @SrT_LikwDekID Int,
 @SrT_Opis NVarchar(MAX),
 @SrT_ZakID Int,
 @SrT_OpeZalID Int,
 @SrT_OpeZalKod varchar(20),
 @SrT_OpeZalNazwisko nvarchar(50),
 @SrT_StaZalId Int,
 @SrT_TS_Zal DateTime,
 @SrT_OpeModID Int,
 @SrT_OpeModKod varchar(20),
 @SrT_OpeModNazwisko nvarchar(50),
 @SrT_StaModId Int,
 @SrT_TS_Mod DateTime,
 @SrH_KwotaKoszt Decimal (15, 2),
 @SrH_KwotaBilan Decimal (15, 2),
 @SrH_KwotaUm Decimal (15, 2),
 @SrH_KwotaAm Decimal (15, 2),
 @MyIdentity Int,
 @ZmniejszOdpisyO   Decimal(15,2),
 @SkrocOkresO       Decimal(15,2),
 @NewId    INT,
 @SrH_NumerDokumentu nvarchar(256),
 @WhereParam NVARCHAR(MAX)
CREATE TABLE #SrHIDs (ID INT)
INSERT INTO #SrHIDs SELECT SrH_SrHID from inserted join cdn.TrwaleHist ON SrH_SrTID = inserted.SrT_SrTID where inserted.SrT_WBudowie <> 0 and SrH_TypDokumentu = 4
EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1007', -- OptimaObjectType_DokumentST
        @ObiektSubTyp = '4', -- e_op_OtrzymanieST
        @ObiektID = 'SrH_SrHID',
        @ObiektNazwa = 'SrH_Numer',
        @OperacjaTyp = 3, -- OptimaOperationType_Usuniecie
        @Opis = '''''',
        @From = 'cdn.TrwaleHist',
        @Where = 'SrH_SrHID IN (SELECT ID FROM #SrHIDs)'
DROP TABLE #SrHIDs
delete from cdn.TrwaleHist where SrH_SrHID in (select SrH_SrHID from inserted join cdn.TrwaleHist on SrH_SrTID = inserted.SrT_SrTID
where inserted.SrT_WBudowie <> 0 and SrH_TypDokumentu = 4)
If Not Exists (Select * From deleted)
 Set @MyIdentity = @@IDENTITY
Else
 Set @MyIdentity = Null
Declare dodane Cursor Local Fast_Forward For
Select
 SrT_SrTID,
 SrT_Typ,
 SrT_WBudowie,
 SrT_Grupa,
 SrT_Lp,
 SrT_Rodzaj,
 SrT_VaNID,
 SrT_Dokument,
 SrT_DataZak,
 SrT_DataPrz,
 SrT_DataAmo,
 SrT_DataUmo,
 SrT_Nazwa,
 SrT_KatID,
 SrT_Kategoria,
 SrT_KRST,
 SrT_NrInwent,
 SrT_WartoscBilan,
 SrT_WartoscKoszt,
 SrT_Bilansowa,
 SrT_UlgaInwestyc,
 SrT_Metoda,
 SrT_MetodaBil,
 SrT_Stawka,
 SrT_StawkaBil,
 SrT_Wspolczynnik,
 SrT_WspolczynnikBil,
 SrT_Sezonowy,
 SrT_SezonowyBil,
 SrT_PrcID,
 SrT_PrcNazwisko,
 SrT_KontoGl,
 SrT_KontoUm,
 SrT_KontoAmKoszt,
 SrT_KontoAmRozn,
 SrT_DataLikw,
 SrT_Stan,
 SrT_Likwidacja,
 SrT_LikwDokument,
 SrT_LikwDekID,
 SrT_Opis,
 SrT_ZakID,
 SrT_OpeZalID,
 SrT_OpeZalKod,
 SrT_OpeZalNazwisko,
 SrT_StaZalId,
 SrT_TS_Zal,
 SrT_OpeModID,
 SrT_OpeModKod,
 SrT_OpeModNazwisko,
 SrT_StaModId,
 SrT_TS_Mod
From inserted
Open dodane
While 1=1
Begin
 Fetch Next From dodane InTo
  @SrT_SrTID,
  @SrT_Typ,
  @SrT_WBudowie,
  @SrT_Grupa,
  @SrT_Lp,
  @SrT_Rodzaj,
  @SrT_VaNID,
  @SrT_Dokument,
  @SrT_DataZak,
  @SrT_DataPrz,
  @SrT_DataAmo,
  @SrT_DataUmo,
  @SrT_Nazwa,
  @SrT_KatID,
  @SrT_Kategoria,
  @SrT_KRST,
  @SrT_NrInwent,
  @SrT_WartoscBilan,
  @SrT_WartoscKoszt,
  @SrT_Bilansowa,
  @SrT_UlgaInwestyc,
  @SrT_Metoda,
  @SrT_MetodaBil,
  @SrT_Stawka,
  @SrT_StawkaBil,
  @SrT_Wspolczynnik,
  @SrT_WspolczynnikBil,
  @SrT_Sezonowy,
  @SrT_SezonowyBil,
  @SrT_PrcID,
  @SrT_PrcNazwisko,
  @SrT_KontoGl,
  @SrT_KontoUm,
  @SrT_KontoAmKoszt,
  @SrT_KontoAmRozn,
  @SrT_DataLikw,
  @SrT_Stan,
  @SrT_Likwidacja,
  @SrT_LikwDokument,
  @SrT_LikwDekID,
  @SrT_Opis,
  @SrT_ZakID,
  @SrT_OpeZalID,
  @SrT_OpeZalKod,
  @SrT_OpeZalNazwisko,
  @SrT_StaZalId,
  @SrT_TS_Zal,
  @SrT_OpeModID,
  @SrT_OpeModKod,
  @SrT_OpeModNazwisko,
  @SrT_StaModId,
  @SrT_TS_Mod
 If @@Fetch_Status <> 0 Break
  -- Aktualizacja grupy środka trwałego w historii
 If Update (SrT_Grupa)
 Begin
  SELECT @SrH_NumerDokumentu = 'OT/'+LTRIM(@SrT_Grupa)+'/'+LTRIM(RTRIM(STR(@SrT_Lp)))
  SELECT @WhereParam = 'SrH_SrTID = ' + CONVERT(VARCHAR(10), @SrT_SrTId) + ' And SrH_Grupa <> ''' + @SrT_Grupa + ''' AND IsNull(SrH_DekID, 0)=0 AND IsNull(SrH_KPRID, 0)=0 AND IsNull(SrH_PreDekID, 0)=0'
  EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1007', -- OptimaObjectType_DokumentST
         @ObiektSubTyp = 'SrH_TypDokumentu',
         @ObiektID = 'SrH_SrHID',
         @ObiektNazwa = 'SrH_Numer',
         @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
         @Opis = '''''',
         @From = 'cdn.TrwaleHist',
         @Where = @WhereParam
  Update CDN.TrwaleHist Set SrH_Grupa = @SrT_Grupa, SrH_Numer = @SrH_NumerDokumentu
   Where SrH_SrTId = @SrT_SrTId And SrH_Grupa <> @SrT_Grupa AND IsNull(SrH_DekID, 0)=0 AND IsNull(SrH_KPRID, 0)=0 AND IsNull(SrH_PreDekID, 0)=0
 End
  -- Aktualizacja kategorii środka trwałego w historii
 If Update (SrT_KatID)
 Begin
  SELECT @WhereParam = 'SrH_SrTID = ' + CONVERT(VARCHAR(10), @SrT_SrTId) + ' And ((IsNull(SrH_KatID, 0) = 0) And IsNull(SrH_KatID, 0) <> IsNull(' + CONVERT(VARCHAR(10), @SrT_KatID) + ', 0)) AND IsNull(SrH_DekID, 0)=0 AND IsNull(SrH_KPRID, 0)=0 AND IsNull(SrH_PreDekID, 0)=0'
  --RAISERROR(@WhereParam, 16, 1)
  EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1007', -- OptimaObjectType_DokumentST
         @ObiektSubTyp = 'SrH_TypDokumentu',
         @ObiektID = 'SrH_SrHID',
         @ObiektNazwa = 'SrH_Numer',
         @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
         @Opis = '''''',
         @From = 'cdn.TrwaleHist',
         @Where = @WhereParam
  Update CDN.TrwaleHist Set SrH_KatID = @SrT_KatID
   Where SrH_SrTId = @SrT_SrTId And ((IsNull(SrH_KatID, 0) = 0) And IsNull(SrH_KatID, 0) <> IsNull(@SrT_KatID, 0))
   AND IsNull(SrH_DekID, 0)=0 AND IsNull(SrH_KPRID, 0)=0 AND IsNull(SrH_PreDekID, 0)=0
 End
 If Update (SrT_Kategoria)
 Begin
  SELECT @WhereParam = 'SrH_SrTID = ' + CONVERT(VARCHAR(10), @SrT_SrTId) + ' And IsNull(SrH_Kategoria, '''') = '''' And IsNull(SrH_Kategoria, '''') <> ''' + @SrT_Kategoria + ''' AND IsNull(SrH_DekID, 0)=0 AND IsNull(SrH_KPRID, 0)=0 AND IsNull(SrH_PreDekID, 0)=0'
  EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1007', -- OptimaObjectType_DokumentST
         @ObiektSubTyp = 'SrH_TypDokumentu',
         @ObiektID = 'SrH_SrHID',
         @ObiektNazwa = 'SrH_Numer',
         @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
         @Opis = '''''',
         @From = 'cdn.TrwaleHist',
         @Where = @WhereParam
  Update CDN.TrwaleHist Set SrH_Kategoria = @SrT_Kategoria
   Where SrH_SrTId = @SrT_SrTId And IsNull(SrH_Kategoria, '') = '' And IsNull(SrH_Kategoria, '') <> @SrT_Kategoria
   AND IsNull(SrH_DekID, 0)=0 AND IsNull(SrH_KPRID, 0)=0 AND IsNull(SrH_PreDekID, 0)=0
 End
 If Update (SrT_Opis)
 Begin
  SELECT @WhereParam = 'SrH_SrTID = ' + CONVERT(VARCHAR(10), @SrT_SrTId) + ' And IsNull(SrH_Opis, '''') = '''' And IsNull(SrH_Opis, '''') <> ''' + @SrT_Opis + ''' AND IsNull(SrH_DekID, 0)=0 AND IsNull(SrH_KPRID, 0)=0 AND IsNull(SrH_PreDekID, 0)=0'
  EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1007', -- OptimaObjectType_DokumentST
         @ObiektSubTyp = 'SrH_TypDokumentu',
         @ObiektID = 'SrH_SrHID',
         @ObiektNazwa = 'SrH_Numer',
         @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
         @Opis = '''''',
         @From = 'cdn.TrwaleHist',
         @Where = @WhereParam
  Update CDN.TrwaleHist Set SrH_Opis = @SrT_Opis
   Where SrH_SrTId = @SrT_SrTId And IsNull(SrH_Opis, '') = '' And IsNull(SrH_Opis, '') <> @SrT_Opis
   AND IsNull(SrH_DekID, 0)=0 AND IsNull(SrH_KPRID, 0)=0 AND IsNull(SrH_PreDekID, 0)=0
 End
  -- Tworzenie / aktualizacja dokumentu OT
  --If @SrT_Rodzaj<>1
  --Begin
    If Update (SrT_DataPrz) Or Update (SrT_WartoscBilan) Or Update (SrT_WartoscKoszt) Or Update (SrT_VaNId)
    Begin
  If Exists (Select * From CDN.TrwaleHist Where SrH_SrTId = @SrT_SrTId And SrH_TypDokumentu = 4)
      -- Aktualizacja
  Begin
   Update CDN.TrwaleHist Set
     SrH_DataOpe = @SrT_DataPrz,
     SrH_KwotaKoszt  = @SrT_WartoscKoszt,
     SrH_KwotaBilan  = @SrT_WartoscBilan,
     SrH_DokumentTyp = 2,
     SrH_DokumentID  = @SrT_VaNId,
     SrH_OpeModID  = @SrT_OpeModID,
     SrH_OpeModKod  = @SrT_OpeModKod,
     SrH_OpeModNazwisko  = @SrT_OpeModNazwisko,
     SrH_StaModId  = @SrT_StaModId,
     SrH_TS_Mod  = @SrT_TS_Mod
     Where SrH_SrTId = @SrT_SrTId And SrH_TypDokumentu = 4
   SELECT @WhereParam = 'SrH_SrTID = ' + CONVERT(VARCHAR(10), @SrT_SrTId) + ' AND SrH_TypDokumentu = 4'
   EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1007', -- OptimaObjectType_DokumentST
          @ObiektSubTyp = 'SrH_TypDokumentu',
          @ObiektID = 'SrH_SrHID',
          @ObiektNazwa = 'SrH_Numer',
          @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
          @Opis = '''''',
          @From = 'cdn.TrwaleHist',
          @Where = @WhereParam
  End
  Else
  Begin
   If @SrT_WBudowie = 0
   Begin
   -- Dodanie brakujacych
    SELECT @SrH_NumerDokumentu = 'OT/'+LTRIM(@SrT_Grupa)+'/'+LTRIM(RTRIM(STR(@SrT_Lp)))
    Insert Into CDN.TrwaleHist (
    SrH_SrTID,
    SrH_Typ,
    SrH_Grupa,
    SrH_TypDokumentu,
    SrH_Rodzaj,
    SrH_DataOpe,
    SrH_KwotaKoszt,
    SrH_KwotaBilan,
    SrH_KwotaUm,
    SrH_KwotaAm,
    SrH_DokumentTyp,
    SrH_DokumentID,
    SrH_Numer,
    SrH_KatID,
    SrH_Kategoria,
    SrH_Metoda,
    SrH_MetodaBil,
    SrH_Stawka,
    SrH_StawkaBil,
    SrH_Wspolczynnik,
    SrH_WspolczynnikBil,
    SrH_Ulga,
    SrH_KPRId,
    SrH_DekId,
    SrH_Opis,
    SrH_OpeZalID,
    SrH_OpeZalKod,
    SrH_OpeZalNazwisko,
    SrH_StaZalId,
    SrH_TS_Zal,
    SrH_OpeModID,
    SrH_OpeModKod,
    SrH_OpeModNazwisko,
    SrH_StaModId,
    SrH_TS_Mod
    )
    Values (
    @SrT_SrTId,
    @SrT_Typ,
    @SrT_Grupa,
    4,
    0,
    @SrT_DataPrz,
    @SrT_WartoscKoszt,
    @SrT_WartoscBilan,
    0,
    0,
    2,
    @SrT_VaNID,
    @SrH_NumerDokumentu,
    @SrT_KatId,
    @SrT_Kategoria,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    Null,
    Null,
    @SrT_Opis,
    @SrT_OpeZalID,
    @SrT_OpeZalKod,
    @SrT_OpeZalNazwisko,
    @SrT_StaZalId,
    @SrT_TS_Zal,
    @SrT_OpeModID,
    @SrT_OpeModKod,
    @SrT_OpeModNazwisko,
    @SrT_StaModId,
    @SrT_TS_Mod
    )
    SET @NewId = SCOPE_IDENTITY()
    EXEC [CDN].[RejestrOperacjiDodaj]
     @ObiektTyp = 1007, -- OptimaObjectType_DokumentST
     @ObiektSubTyp = 4, -- e_op_OtrzymanieST
     @ObiektID = @NewId,
     @ObiektNazwa = @SrH_NumerDokumentu,
     @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
     @Opis = ''
   End
  End
 End
  -- Tworzenie / aktualizacja dokumentu LT
 If Update (SrT_DataLikw) Or Update (SrT_Stan) Or Update (SrT_WartoscKoszt) Or Update (SrT_WartoscBilan) Or Update (SrT_Likwidacja)
    Begin
  If @SrT_Stan = 0
  -- Przywrócenie do użytkowania - usuwamy LT
  Begin
   SELECT @WhereParam = 'SrH_SrTID = ' + CONVERT(VARCHAR(10), @SrT_SrTId) + ' And SrH_TypDokumentu = 5 And SrH_Rodzaj <> 0'
   EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1007', -- OptimaObjectType_DokumentST
          @ObiektSubTyp = '5', -- e_op_LikwidacjaST
          @ObiektID = 'SrH_SrHID',
          @ObiektNazwa = 'SrH_Numer',
          @OperacjaTyp = 3, -- OptimaOperationType_Usuniecie
          @Opis = '''''',
          @From = 'cdn.TrwaleHist',
          @Where = @WhereParam
   Delete From CDN.TrwaleHist
   Where SrH_SrTId = @SrT_SrTId And SrH_TypDokumentu = 5 And SrH_Rodzaj <> 0
  End
  Else
  Begin
        -- Likwidacja - dodajemy lub modyfikujemy LT
   Set @ZmniejszOdpisyO  = 0
   Set @SkrocOkresO      = 0
   Select  @ZmniejszOdpisyO = Case Fir_Wartosc When 1 Then @SrT_UlgaInwestyc Else 0 End,
     @SkrocOkresO = Case Fir_Wartosc When 2 Then @SrT_UlgaInwestyc Else 0 End
   From CDN.Firma
   Where Fir_Numer = 1209  -- Parametr: amortyzacja w przypadku ulg inwestycyjnych
        --
   Set @SrH_KwotaKoszt = 0
   Set @SrH_KwotaBilan = 0
   Set @SrH_KwotaUm    = 0
   Set @SrH_KwotaAm    = 0
   If @SrT_WBudowie = 0
    Select
     @SrH_KwotaKoszt = IsNull( Sum (SrH_KwotaKoszt), 0),
     @SrH_KwotaBilan = IsNull( Sum (SrH_KwotaBilan), 0),
     @SrH_KwotaUm    = IsNull( Sum (SrH_KwotaUm), 0),
     @SrH_KwotaAm    = IsNull( Sum (SrH_KwotaAm), 0)
     From CDN.TrwaleHist Where SrH_SrTId = @SrT_SrTId And Not (SrH_TypDokumentu = 5 And SrH_Rodzaj <> 0) AND SrH_TypDokumentu <> 6
   Else
    Select
     @SrH_KwotaKoszt = IsNull( Sum (SrTP_Kwota), 0),
     @SrH_KwotaBilan = IsNull( Sum (SrTP_Kwota), 0)
    From CDN.TrwalePowiazania Where SrTP_SrTId = @SrT_SrTId
   If Exists (Select * From CDN.TrwaleHist Where SrH_SrTId = @SrT_SrTId And SrH_TypDokumentu = 5 And SrH_Rodzaj <> 0)
   -- Aktualizacja
   Begin
    Update CDN.TrwaleHist
    Set
    SrH_Rodzaj  = @SrT_Stan,
    SrH_DataOpe = @SrT_DataLikw,
    SrH_KwotaKoszt  = - @SrH_KwotaKoszt + @ZmniejszOdpisyO,
    SrH_KwotaBilan  = - @SrH_KwotaBilan,
    SrH_KwotaUm = - @SrH_KwotaUm,
    SrH_KwotaAm = - @SrH_KwotaAm - @SkrocOkresO,
    SrH_Kategoria = @SrT_Likwidacja,
    SrH_OpeModID  = @SrT_OpeModID,
    SrH_OpeModKod  = @SrT_OpeModKod,
    SrH_OpeModNazwisko  = @SrT_OpeModNazwisko,
    SrH_StaModId  = @SrT_StaModId,
    SrH_TS_Mod  = @SrT_TS_Mod
    Where SrH_SrTId = @SrT_SrTId And SrH_TypDokumentu = 5 And SrH_Rodzaj <> 0
    SELECT @WhereParam = 'SrH_SrTID = ' + CONVERT(VARCHAR(10), @SrT_SrTId) + ' And SrH_TypDokumentu = 5 And SrH_Rodzaj <> 0'
    EXEC cdn.RejestrOperacjiDodajEx @ObiektTyp = '1007', -- OptimaObjectType_DokumentST
           @ObiektSubTyp = '5', -- e_op_LikwidacjaST
           @ObiektID = 'SrH_SrHID',
           @ObiektNazwa = 'SrH_Numer',
           @OperacjaTyp = 2, -- OptimaOperationType_Modyfikacja
           @Opis = '''''',
           @From = 'cdn.TrwaleHist',
           @Where = @WhereParam
   End
   Else IF @SrH_KwotaKoszt + @ZmniejszOdpisyO <> 0 OR @SrH_KwotaBilan <> 0 OR @SrH_KwotaUm <> 0 OR @SrH_KwotaAm - @SkrocOkresO <> 0
   Begin
   -- Dodanie brakujących
    SELECT @SrH_NumerDokumentu = 'LT/'+LTrim(@SrT_Grupa)+'/'+LTrim(RTrim(Str(@SrT_Lp)))
    Insert Into CDN.TrwaleHist (
      SrH_SrTID,
      SrH_Typ,
      SrH_Grupa,
      SrH_TypDokumentu,
      SrH_Rodzaj,
      SrH_DataOpe,
      SrH_KwotaKoszt,
      SrH_KwotaBilan,
      SrH_KwotaUm,
      SrH_KwotaAm,
      SrH_DokumentTyp,
      SrH_DokumentID,
      SrH_Numer,
      SrH_KatID,
      SrH_Kategoria,
      SrH_Metoda,
      SrH_MetodaBil,
      SrH_Stawka,
      SrH_StawkaBil,
      SrH_Wspolczynnik,
      SrH_WspolczynnikBil,
      SrH_Ulga,
      SrH_KPRId,
      SrH_DekId,
      SrH_ZakID,
      SrH_OpeZalID,
      SrH_OpeZalKod,
      SrH_OpeZalNazwisko,
      SrH_StaZalId,
      SrH_TS_Zal,
      SrH_OpeModID,
      SrH_OpeModKod,
      SrH_OpeModNazwisko,
      SrH_StaModId,
      SrH_TS_Mod
      )
    Values (
      @SrT_SrTId,
      @SrT_Typ,
      @SrT_Grupa,
      5,
      @SrT_Stan,
      @SrT_DataLikw,
      - @SrH_KwotaKoszt + @ZmniejszOdpisyO,
      - @SrH_KwotaBilan,
      - @SrH_KwotaUm,
      - @SrH_KwotaAm - @SkrocOkresO,
      Null,
      Null,
      @SrH_NumerDokumentu,
      @SrT_KatId,
      @SrT_Likwidacja,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      Null,
      Null,
      @SrT_ZakID,
      @SrT_OpeZalID,
      @SrT_OpeZalKod,
      @SrT_OpeZalNazwisko,
      @SrT_StaZalId,
      @SrT_TS_Zal,
      @SrT_OpeModID,
      @SrT_OpeModKod,
      @SrT_OpeModNazwisko,
      @SrT_StaModId,
      @SrT_TS_Mod
      )
    SET @NewId = SCOPE_IDENTITY()
    EXEC [CDN].[RejestrOperacjiDodaj]
     @ObiektTyp = 1007, -- OptimaObjectType_DokumentST
     @ObiektSubTyp = 5, -- e_op_LikwidacjaST
     @ObiektID = @NewId,
     @ObiektNazwa = @SrH_NumerDokumentu,
     @OperacjaTyp = 1, -- OptimaOperationType_Dodanie
     @Opis = '' -- @SrT_Likwidacja
   End
  End
 End
End
Close dodane
Deallocate dodane
IF @MyIdentity IS NOT NULL
 BEGIN
  CREATE TABLE #IdTmp ( Ident INT Identity )
  SET IDENTITY_INSERT #IdTmp ON
  INSERT INTO #IdTmp (Ident) VALUES (@MyIdentity)
  SET IDENTITY_INSERT #IdTmp OFF
  DROP TABLE #IdTmp
 END
Set NoCount Off
