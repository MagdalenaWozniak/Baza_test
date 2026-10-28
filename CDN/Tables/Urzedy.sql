CREATE TABLE [CDN].[Urzedy] (
    [Urz_UrzId]          INT            IDENTITY (1, 1) NOT NULL,
    [Urz_PodmiotTyp]     SMALLINT       CONSTRAINT [DF_Urz_PodmiotTyp] DEFAULT ((5)) NULL,
    [Urz_Akronim]        VARCHAR (20)   NOT NULL,
    [Urz_Kod]            VARCHAR (6)    NULL,
    [Urz_TypUrzedu]      SMALLINT       NOT NULL,
    [Urz_Standardowy]    SMALLINT       NOT NULL,
    [Urz_Nazwa1]         NVARCHAR (50)  NOT NULL,
    [Urz_Nazwa2]         NVARCHAR (50)  NOT NULL,
    [Urz_Kraj]           NVARCHAR (40)  NOT NULL,
    [Urz_Wojewodztwo]    NVARCHAR (40)  NOT NULL,
    [Urz_Powiat]         NVARCHAR (40)  NOT NULL,
    [Urz_Gmina]          NVARCHAR (40)  NOT NULL,
    [Urz_Ulica]          NVARCHAR (40)  NOT NULL,
    [Urz_NrDomu]         NVARCHAR (10)  NOT NULL,
    [Urz_NrLokalu]       NVARCHAR (10)  NOT NULL,
    [Urz_Miasto]         NVARCHAR (40)  NOT NULL,
    [Urz_KodPocztowy]    VARCHAR (10)   NOT NULL,
    [Urz_Poczta]         NVARCHAR (40)  NOT NULL,
    [Urz_Adres2]         NVARCHAR (40)  NOT NULL,
    [Urz_Telefon]        VARCHAR (20)   NOT NULL,
    [Urz_TelefonSms]     VARCHAR (20)   CONSTRAINT [DF_Urz_TelefonSms] DEFAULT ('') NOT NULL,
    [Urz_Fax]            VARCHAR (20)   NOT NULL,
    [Urz_Email]          NVARCHAR (127) NOT NULL,
    [Urz_URL]            VARCHAR (254)  NOT NULL,
    [Urz_KatID]          INT            NULL,
    [Urz_NieRozliczac]   TINYINT        NOT NULL,
    [Urz_TS_Export]      DATETIME       NULL,
    [Urz_ImportAppId]    VARCHAR (5)    NULL,
    [Urz_ImportRowId]    VARCHAR (36)   NULL,
    [Urz_OpeZalId]       INT            NULL,
    [Urz_StaZalId]       INT            NULL,
    [Urz_TS_Zal]         DATETIME       NOT NULL,
    [Urz_OpeModId]       INT            NULL,
    [Urz_StaModId]       INT            NULL,
    [Urz_TS_Mod]         DATETIME       NOT NULL,
    [Urz_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_Urz_OpeModKod] DEFAULT ('') NOT NULL,
    [Urz_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Urz_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Urz_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_Urz_OpeZalKod] DEFAULT ('') NOT NULL,
    [Urz_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Urz_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [Urz_Nieaktywny]     TINYINT        CONSTRAINT [DF_Urz_Nieaktywny] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [Urz_Primary] PRIMARY KEY CLUSTERED ([Urz_UrzId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_UrzKategoria] FOREIGN KEY ([Urz_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UrzAkronim]
    ON [CDN].[Urzedy]([Urz_TypUrzedu] ASC, [Urz_Akronim] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [KeyNazwa]
    ON [CDN].[Urzedy]([Urz_TypUrzedu] ASC, [Urz_Nazwa1] ASC, [Urz_UrzId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UrzGUID]
    ON [CDN].[Urzedy]([Urz_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [UrzKategoria]
    ON [CDN].[Urzedy]([Urz_KatID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Urzedy_Delete_Trigger
  ON CDN.Urzedy
  FOR DELETE
AS
SET NOCOUNT ON
-- Aktualizacja PodmiotyView
Delete CDN.PodmiotyView
  From CDN.PodmiotyView Join deleted On Pod_PodmiotTyp = 5 And Pod_PodId = Urz_UrzId
-- obsługa sprawdzania relacji restrict do tabeli CDN.TraNag
IF EXISTS
  ( SELECT * FROM CDN.TraNag, deleted WHERE Urz_UrzId = TrN_OdbID    AND TrN_OdbiorcaTyp   = 5 )
OR EXISTS
  ( SELECT * FROM CDN.TraNag, deleted WHERE Urz_UrzId = TrN_OdbDocID AND TrN_OdbiorcaDocTyp= 5 )
OR EXISTS
  ( SELECT * FROM CDN.TraNag, deleted WHERE Urz_UrzId = TrN_PodZalID AND TrN_PodmiotZalTyp = 5 )
OR EXISTS
  ( SELECT * FROM CDN.TraNag, deleted WHERE Urz_UrzId = TrN_PodID    AND TrN_PodmiotTyp    = 5 )
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=TraNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą TraNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.TraElem
IF EXISTS
  ( SELECT * FROM CDN.TraElem, deleted WHERE Urz_UrzId = TrE_PodID    AND TrE_PodmiotTyp    = 5 )
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=TraElem##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą TraElem). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.DokPodmioty
IF EXISTS
  ( SELECT * FROM CDN.DokPodmioty, deleted WHERE Urz_UrzId = DoP_PodmiotID    AND DoP_PodmiotTyp    = 5 )
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=DokPodmioty##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą DokPodmioty). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.VatNag
IF EXISTS (SELECT * FROM CDN.VatNag, deleted WHERE Urz_UrzId = VaN_PodID    AND VaN_PodmiotTyp = 5)
OR EXISTS (SELECT * FROM CDN.VatNag, deleted WHERE Urz_UrzId = VaN_PodZalID AND VaN_PodmiotZalTyp = 5)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=VatNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą VatNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.EwidDodNag
IF EXISTS (SELECT * FROM CDN.EwidDodNag, deleted WHERE Urz_UrzId = EDN_PodZalID AND EDN_PodmiotZalTyp = 5)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=EwidDodNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą EwidDodNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.PracEtaty
IF EXISTS (SELECT * FROM CDN.PracEtaty, deleted WHERE Urz_UrzId = PRE_PODUrzSkarbId)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=PracEtaty##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą PracEtaty). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.Firma
IF EXISTS (SELECT * FROM CDN.Firma, deleted WHERE Urz_UrzId in (Select Fir_Wartosc from cdn.firma where fir_Numer in (1102,1533,1766)))
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=Firma##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą Firma). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.DeklNag
IF EXISTS (SELECT * FROM CDN.DeklElem left join CDN.DeklNag on DkN_DkNID = DkE_DkNID, deleted where DkN_TypDeklar = 35 AND DkE_Numer = 99999 AND DkE_WartoscL = Urz_UrzId)
  BEGIN
    RAISERROR('##OPT32226##%%tabela%%=DeklNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą DeklNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.FormyPlatnosci
IF EXISTS (SELECT * FROM CDN.FormyPlatnosci, deleted WHERE FPl_PodmiotTyp = 5 AND FPl_PodmiotID = Urz_UrzID)
  BEGIN
    RAISERROR('##OPT32374##', 16, 1) -- RAISERROR('Usunięcie urzędu niemożliwe. Istnieją formy płatności, w których urząd jest płatnikiem. ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzanie, czy nie skasowano urzdu standardowego
IF EXISTS (SELECT * FROM deleted WHERE deleted.Urz_Standardowy <> 0)
  BEGIN
    RAISERROR('##OPT32375##', 16, 1) -- RAISERROR('Nie można kasować urzędu standardowego. ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie wystąpień na fakturach cyklicznych  (WiNi)
  IF EXISTS( SELECT FCK_FCKID FROM CDN.FaCyklKnt WHERE FCK_PodmiotTyp = 5 AND FCK_PodmiotId In (Select Urz_UrzId From deleted) )
  BEGIN
    RAISERROR('##OPT32376##', 16, 1) -- RAISERROR('Nie można usunąć wskazanej pozycji. Istnieją faktury cykliczne, na których występuje usuwany urząd.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa kasowania rabatow dla urzedu
Delete From CDN.Rabaty Where
 Rab_Typ In (1, 5, 8) And
 Rab_PodmiotTyp = 5 And
 Rab_PodmiotId In (Select Urz_UrzId From deleted)
-- Skasowanie relacji do dokumentów CRM  (WiNi)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp = 1105 AND DoR_DokumentId=deleted.Urz_UrzId
SET NOCOUNT OFF

GO
Create Trigger CDN.Urzedy_InsertUpdate_Trigger
  On CDN.Urzedy
  For Insert, Update
As
  Set NoCount On
-- Kasowanie wskanika wyeksportowania
If Not Update (Urz_TS_Export) And Exists (Select * From inserted Where Urz_TS_Export Is Not Null)
  Update CDN.Urzedy Set Urz_TS_Export = Null Where Urz_UrzId In (Select Urz_UrzId From inserted Where Urz_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where Urz_ImportRowId Is Null Or Urz_ImportRowId = '')
  Update CDN.Urzedy Set Urz_ImportRowId = NewId()
  Where Urz_UrzId In (Select Urz_UrzId From inserted Where Urz_ImportRowId Is Null Or Urz_ImportRowId = '')
-- Aktualizacja PodmiotyView
--  Aktualizacja istniejących
Update CDN.PodmiotyView Set
  Pod_Kod          = A.Urz_Akronim ,
  Pod_Nazwa1       = A.Urz_Nazwa1 ,
  Pod_Nazwa2       = A.Urz_Nazwa2 ,
  Pod_Nazwa3       = '' ,
  Pod_Kraj         = A.Urz_Kraj ,
  Pod_Wojewodztwo  = A.Urz_Wojewodztwo ,
  Pod_Powiat       = A.Urz_Powiat ,
  Pod_Gmina        = A.Urz_Gmina ,
  Pod_Ulica        = A.Urz_Ulica ,
  Pod_NrDomu       = A.Urz_NrDomu ,
  Pod_NrLokalu     = A.Urz_NrLokalu ,
  Pod_Miasto       = A.Urz_Miasto ,
  Pod_KodPocztowy  = A.Urz_KodPocztowy ,
  Pod_Poczta       = A.Urz_Poczta ,
  Pod_Adres2       = A.Urz_Adres2 ,
  Pod_Telefon1     = A.Urz_Telefon ,
  Pod_Telefon2     = A.Urz_Fax ,
  Pod_TelefonSms   = A.Urz_TelefonSms ,
  Pod_Email        = A.Urz_Email ,
  Pod_Nieaktywny   = A.Urz_Nieaktywny ,
  Pod_Rodzaj       = -5 ,
  Pod_RodzajOpis   = Case A.Urz_TypUrzedu When 4 Then 'IC' When 3 Then 'UC' When 2 Then 'ZUS' Else 'US' End,
  Pod_Grupa        = '' ,
  Pod_NipKraj      = '' ,
  Pod_NIP          = '' ,
  Pod_Regon        = '' ,
  Pod_Pesel        = '' ,
  Pod_LimitKredytu = 0 ,
  Pod_ImportRowId  = A.Urz_ImportRowId,
  Pod_NadID        = NULL,
  Pod_GlID         = A.Urz_UrzID,
  Pod_GlKod        = A.Urz_Akronim,
  Pod_GlNazwa12    = A.Urz_Nazwa1 + ' ' + A.Urz_Nazwa2
From CDN.PodmiotyView
Join inserted B     On Pod_PodmiotTyp = 5 And Pod_PodId = B.Urz_UrzId
Join CDN.Urzedy A   On A.Urz_UrzId = B.Urz_UrzId
--  Dodawanie nowych
Insert InTo CDN.PodmiotyView (
  Pod_PodmiotTyp   ,
  Pod_PodId        ,
  Pod_Kod          ,
  Pod_Nazwa1       ,
  Pod_Nazwa2       ,
  Pod_Nazwa3       ,
  Pod_Kraj         ,
  Pod_Wojewodztwo  ,
  Pod_Powiat       ,
  Pod_Gmina        ,
  Pod_Ulica        ,
  Pod_NrDomu       ,
  Pod_NrLokalu     ,
  Pod_Miasto       ,
  Pod_KodPocztowy  ,
  Pod_Poczta       ,
  Pod_Adres2       ,
  Pod_Telefon1     ,
  Pod_Telefon2     ,
  Pod_TelefonSms   ,
  Pod_Email        ,
  Pod_Nieaktywny   ,
  Pod_Rodzaj       ,
  Pod_RodzajOpis   ,
  Pod_Grupa        ,
  Pod_NipKraj      ,
  Pod_NIP          ,
  Pod_Regon        ,
  Pod_Pesel        ,
  Pod_LimitKredytu ,
  Pod_ImportRowId  ,
  Pod_KontoOdb     ,
  Pod_KontoDost    ,
  Pod_NadID        ,
  Pod_GlID         ,
  Pod_GlKod        ,
  Pod_GlNazwa12
 )
Select
  5                 ,
  A.Urz_UrzId       ,
  A.Urz_Akronim     ,
  A.Urz_Nazwa1      ,
  A.Urz_Nazwa2      ,
  ''                ,
  A.Urz_Kraj        ,
  A.Urz_Wojewodztwo ,
  A.Urz_Powiat      ,
  A.Urz_Gmina       ,
  A.Urz_Ulica       ,
  A.Urz_NrDomu      ,
  A.Urz_NrLokalu    ,
  A.Urz_Miasto      ,
  A.Urz_KodPocztowy ,
  A.Urz_Poczta      ,
  A.Urz_Adres2      ,
  A.Urz_Telefon     ,
  A.Urz_Fax         ,
  A.Urz_TelefonSms  ,
  A.Urz_Email       ,
  A.Urz_Nieaktywny  ,
  -5                ,
  Case A.Urz_TypUrzedu When 4 Then 'IC' When 3 Then 'UC' When 2 Then 'ZUS' Else 'US' End,
  ''                ,
  ''                ,
  ''                ,
  ''                ,
  ''                ,
  0                 ,
  A.Urz_ImportRowId ,
  ''                ,
  ''                ,
  NULL              ,
  A.Urz_UrzID       ,
  A.Urz_Akronim     ,
  A.Urz_Nazwa1 + ' ' + A.Urz_Nazwa2
From CDN.Urzedy A
Join inserted B On A.Urz_UrzId = B.Urz_UrzId
Left Outer Join CDN.PodmiotyView C On C.Pod_PodmiotTyp = 5 And C.Pod_PodId = B.Urz_UrzId
Where C.Pod_PodId Is Null
  Set NoCount On
