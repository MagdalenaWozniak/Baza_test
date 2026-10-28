CREATE TABLE [CDN].[BnkNazwy] (
    [BNa_BNaId]           INT            IDENTITY (1, 1) NOT NULL,
    [BNa_PodmiotTyp]      SMALLINT       CONSTRAINT [DF_BNa_PodmiotTyp] DEFAULT ((2)) NULL,
    [BNa_Akronim]         VARCHAR (20)   NOT NULL,
    [BNa_Numer]           NVARCHAR (10)  NOT NULL,
    [BNa_Centrala]        NVARCHAR (3)   NOT NULL,
    [BNa_Swift]           NVARCHAR (20)  NOT NULL,
    [BNa_Nazwa1]          NVARCHAR (50)  NOT NULL,
    [BNa_Nazwa2]          NVARCHAR (50)  NOT NULL,
    [BNa_Kraj]            NVARCHAR (40)  NOT NULL,
    [BNa_Wojewodztwo]     NVARCHAR (40)  NOT NULL,
    [BNa_Powiat]          NVARCHAR (40)  NOT NULL,
    [BNa_Gmina]           NVARCHAR (40)  NOT NULL,
    [BNa_Ulica]           NVARCHAR (40)  NOT NULL,
    [BNa_NrDomu]          NVARCHAR (10)  NOT NULL,
    [BNa_NrLokalu]        NVARCHAR (10)  NOT NULL,
    [BNa_Miasto]          NVARCHAR (40)  NOT NULL,
    [BNa_KodPocztowy]     VARCHAR (10)   NOT NULL,
    [BNa_Poczta]          NVARCHAR (40)  NOT NULL,
    [BNa_Adres2]          NVARCHAR (40)  NOT NULL,
    [BNa_Modem]           NVARCHAR (20)  NOT NULL,
    [BNa_Telefon]         VARCHAR (20)   NOT NULL,
    [BNa_TelefonSms]      VARCHAR (20)   CONSTRAINT [DF_BNa_TelefonSms] DEFAULT ('') NOT NULL,
    [BNa_Fax]             VARCHAR (20)   NOT NULL,
    [BNa_Email]           NVARCHAR (127) NOT NULL,
    [BNa_URL]             VARCHAR (254)  NOT NULL,
    [BNa_UID]             NVARCHAR (30)  NOT NULL,
    [BNa_PWD]             NVARCHAR (30)  NOT NULL,
    [BNa_Format]          SMALLINT       NOT NULL,
    [BNa_FormatUS]        SMALLINT       NULL,
    [BNa_FormatZUS]       SMALLINT       NULL,
    [BNa_FormatImp]       SMALLINT       NULL,
    [BNa_CzasRealizacji]  SMALLINT       NOT NULL,
    [BNa_IBAN]            SMALLINT       NOT NULL,
    [BNa_Zagraniczny]     SMALLINT       NOT NULL,
    [BNa_KatID]           INT            NULL,
    [BNa_NieRozliczac]    TINYINT        NOT NULL,
    [BNa_TS_Export]       DATETIME       NULL,
    [BNa_ImportAppId]     VARCHAR (5)    NULL,
    [BNa_ImportRowId]     VARCHAR (36)   NULL,
    [BNa_OpeZalId]        INT            NULL,
    [BNa_StaZalId]        INT            NULL,
    [BNa_TS_Zal]          DATETIME       NOT NULL,
    [BNa_OpeModId]        INT            NULL,
    [BNa_StaModId]        INT            NULL,
    [BNa_TS_Mod]          DATETIME       NOT NULL,
    [BNa_GIDTyp]          SMALLINT       NULL,
    [BNa_GIDFirma]        INT            NULL,
    [BNa_GIDNumer]        INT            NULL,
    [BNa_GIDLp]           SMALLINT       NULL,
    [BNa_CDCKontaktOsoba] NVARCHAR (140) NULL,
    [BNa_CDCKontakt]      NVARCHAR (140) NULL,
    [BNa_CDCOplatyPonosi] TINYINT        NULL,
    [BNa_Nieaktywny]      TINYINT        CONSTRAINT [DF_BNa_Nieaktywny] DEFAULT ((0)) NOT NULL,
    [BNa_RachunekNr]      NVARCHAR (51)  CONSTRAINT [DF_BNa_RachunekNr] DEFAULT ('') NOT NULL,
    [BNa_OpeModKod]       VARCHAR (20)   CONSTRAINT [DF_BNa_OpeModKod] DEFAULT ('') NOT NULL,
    [BNa_OpeModNazwisko]  NVARCHAR (50)  CONSTRAINT [DF_BNa_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [BNa_OpeZalKod]       VARCHAR (20)   CONSTRAINT [DF_BNa_OpeZalKod] DEFAULT ('') NOT NULL,
    [BNa_OpeZalNazwisko]  NVARCHAR (50)  CONSTRAINT [DF_BNa_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [BNa_FormatSplitPay]  SMALLINT       NULL,
    [BNa_CDCClientID]     NVARCHAR (256) NULL,
    [BNa_CDCSecretKey]    NVARCHAR (256) NULL,
    CONSTRAINT [BNa_Primary] PRIMARY KEY CLUSTERED ([BNa_BNaId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BNaKategoria] FOREIGN KEY ([BNa_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID])
);


GO
CREATE NONCLUSTERED INDEX [BNaKategoria]
    ON [CDN].[BnkNazwy]([BNa_KatID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BNaAkronim]
    ON [CDN].[BnkNazwy]([BNa_Akronim] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BNaNumer]
    ON [CDN].[BnkNazwy]([BNa_Numer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BNaGUID]
    ON [CDN].[BnkNazwy]([BNa_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [BNaGID]
    ON [CDN].[BnkNazwy]([BNa_GIDTyp] ASC, [BNa_GIDFirma] ASC, [BNa_GIDNumer] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [BNaGridLookupFilter]
    ON [CDN].[BnkNazwy]([BNa_Akronim] ASC, [BNa_BNaId] ASC)
    INCLUDE([BNa_Nazwa1], [BNa_Numer]) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.BnkNazwy_Delete_Trigger
  ON CDN.BnkNazwy
  FOR DELETE
AS
SET NOCOUNT ON
IF EXISTS (SELECT * FROM deleted
           WHERE deleted.BNa_Numer = '10100071')
  BEGIN
    RAISERROR('##OPT34785##', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie, czy nie została skasowana kasa gotówkowa
IF EXISTS (SELECT * FROM deleted
           WHERE deleted.BNa_BNaID = 1)
  BEGIN
    RAISERROR('##OPT32227##', 16, 1) -- RAISERROR('Nie można usunąć kasy gotówkowej (BnkNazwy)', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Aktualizacja PodmiotyView
Delete CDN.PodmiotyView
  From CDN.PodmiotyView Join deleted On Pod_PodmiotTyp = 2 And Pod_PodId = BNa_BNaId
-- obsługa sprawdzania relacji restrict do tabeli CDN.TraNag
IF EXISTS
  ( SELECT * FROM CDN.TraNag, deleted WHERE BNa_BNaId = TrN_OdbID    AND TrN_OdbiorcaTyp   = 2 )
OR EXISTS
  ( SELECT * FROM CDN.TraNag, deleted WHERE BNa_BNaId = TrN_PodZalID AND TrN_PodmiotZalTyp = 2 )
OR EXISTS
  ( SELECT * FROM CDN.TraNag, deleted WHERE BNa_BNaId = TrN_PodID    AND TrN_PodmiotTyp    = 2 )
OR EXISTS
  ( SELECT * FROM CDN.TraNag, deleted WHERE BNa_BNaId = TrN_OdbDocID AND TrN_OdbiorcaDocTyp= 2 )
  BEGIN
 RAISERROR('##OPT32226##%%tabela%%=TraNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą TraNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.DokPodmioty
IF EXISTS
  ( SELECT * FROM CDN.DokPodmioty, deleted WHERE BNa_BNaId = DoP_PodmiotID    AND DoP_PodmiotTyp   = 2 )
  BEGIN
 RAISERROR('##OPT32226##%%tabela%%=DokNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą DokNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- Sprawdzenie wystąpień na fakturach cyklicznych  (WiNi)
  IF EXISTS( SELECT FCK_FCKID FROM CDN.FaCyklKnt WHERE FCK_PodmiotTyp = 2 AND FCK_PodmiotId In (Select BNa_BNaId From deleted) )
  BEGIN
 RAISERROR('##OPT32228##', 16, 1) -- RAISERROR('Nie można usunąć wskazanej pozycji. Istnieją faktury cykliczne, na których występuje usuwany bank.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.TraElem
IF EXISTS
  ( SELECT * FROM CDN.TraElem, deleted WHERE BNa_BNaId = TrE_PodID    AND TrE_PodmiotTyp    = 2 )
  BEGIN
 RAISERROR('##OPT32226##%%tabela%%=TraElem##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą TraElem). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.VatNag
IF EXISTS (SELECT * FROM CDN.VatNag, deleted WHERE BNa_BNaId = VaN_PodID    AND VaN_PodmiotTyp = 2)
OR EXISTS (SELECT * FROM CDN.VatNag, deleted WHERE BNa_BNaId = VaN_PodZalID AND VaN_PodmiotZalTyp = 2)
  BEGIN
 RAISERROR('##OPT32226##%%tabela%%=VatNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą VatNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.EwidDodNag
IF EXISTS (SELECT * FROM CDN.EwidDodNag, deleted WHERE BNa_BNaId = EDN_PodZalID AND EDN_PodmiotZalTyp = 2)
  BEGIN
 RAISERROR('##OPT32226##%%tabela%%=EwidDodNag##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą EwidDodNag). ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.FormyPlatnosci
IF EXISTS (SELECT * FROM CDN.FormyPlatnosci, deleted WHERE FPl_PodmiotTyp = 2 AND FPl_PodmiotID = BNa_BNaID)
  BEGIN
 RAISERROR('##OPT32229##', 16, 1) -- RAISERROR('Usunięcie banku niemożliwe. Istnieją formy płatności, w których bank jest płatnikiem. ', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa kasowania rabatow dla banku
Delete From CDN.Rabaty Where
 Rab_Typ In (1, 5, 8) And
 Rab_PodmiotTyp = 2 And
 Rab_PodmiotId In (Select BNa_BNaId From deleted)
-- Skasowanie relacji do dokumentów CRM  (WiNi)
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp = 1102 AND DoR_DokumentId=deleted.BNa_BNaId
  SET NOCOUNT OFF

GO
Create Trigger CDN.BnkNazwy_InsertUpdate_Trigger
  On CDN.BnkNazwy
  For Insert, Update
As
  Set NoCount On
  If Update (BNa_GIDTyp) Or Update (BNa_GIDFirma) Or Update (BNa_GIDNumer)
    Begin
      If Exists (
        Select * From inserted A, CDN.BnkNazwy B Where
          A.BNa_GIDTyp   = B.BNa_GIDTyp   And
          A.BNa_GIDFirma = B.BNa_GIDFirma And
          A.BNa_GIDNumer = B.BNa_GIDNumer And
          A.BNa_BNaId   <> B.BNa_BNaId    And
          IsNull(A.BNa_GIDTyp, 0) <> 0    And
          IsNull(A.BNa_GIDFirma, 0) <> 0  And
          IsNull(A.BNa_GIDNumer, 0) <> 0)
        Begin
    RAISERROR('##OPT32230##', 16, 1) -- RaisError ('Duplikacja identyfikatora GID', 16,1)
          RollBack Tran
          Return
        End
    End
-- Kasowanie wskanika wyeksportowania
If Not Update (BNa_TS_Export) And Exists (Select * From inserted Where BNa_TS_Export Is Not Null)
  Update CDN.BnkNazwy Set BNa_TS_Export = Null Where BNa_BNaId In (Select BNa_BNaId From inserted Where BNa_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where BNa_ImportRowId Is Null Or BNa_ImportRowId = '')
  Update CDN.BnkNazwy Set BNa_ImportRowId = NewId()
  Where BNa_BNaId In (Select BNa_BNaId From inserted Where BNa_ImportRowId Is Null Or BNa_ImportRowId = '')
-- Aktualizacja PodmiotyView
--  Aktualizacja istniejących
Update CDN.PodmiotyView Set
  Pod_Kod          = A.BNa_Akronim ,
  Pod_Nazwa1       = A.BNa_Nazwa1 ,
  Pod_Nazwa2       = A.BNa_Nazwa2 ,
  Pod_Nazwa3       = '' ,
  Pod_Kraj         = A.BNa_Kraj ,
  Pod_Wojewodztwo  = A.BNa_Wojewodztwo ,
  Pod_Powiat       = A.BNa_Powiat ,
  Pod_Gmina        = A.BNa_Gmina ,
  Pod_Ulica        = A.BNa_Ulica ,
  Pod_NrDomu       = A.BNa_NrDomu ,
  Pod_NrLokalu     = A.BNa_NrLokalu ,
  Pod_Miasto       = A.BNa_Miasto ,
  Pod_KodPocztowy  = A.BNa_KodPocztowy ,
  Pod_Poczta       = A.BNa_Poczta ,
  Pod_Adres2       = A.BNa_Adres2 ,
  Pod_Telefon1     = A.BNa_Telefon ,
  Pod_Telefon2     = A.BNa_Fax ,
  Pod_TelefonSms   = A.BNa_TelefonSms ,
  Pod_Email        = A.BNa_Email ,
  Pod_Nieaktywny   = A.BNa_Nieaktywny ,
  Pod_Rodzaj       = -2 ,
  Pod_RodzajOpis   = 'bank' ,
  Pod_Grupa        = '' ,
  Pod_NipKraj      = '' ,
  Pod_NIP          = '' ,
  Pod_Regon        = '' ,
  Pod_Pesel        = '' ,
  Pod_LimitKredytu = 0 ,
  Pod_ImportRowId  = A.BNa_ImportRowId,
  Pod_NadID        = NULL,
  Pod_GlID         = A.BNa_BNaID,
  Pod_GlKod        = A.BNa_Akronim,
  Pod_GlNazwa12    = A.BNa_Nazwa1 + ' ' + A.BNa_Nazwa2
From CDN.PodmiotyView
Join inserted B     On Pod_PodmiotTyp = 2 And Pod_PodId = B.BNa_BNaId
Join CDN.BnkNazwy A On A.BNa_BNaId = B.BNa_BNaId
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
  Pod_Email     ,
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
  2                 ,
  A.BNa_BNaId       ,
  A.BNa_Akronim     ,
  A.BNa_Nazwa1      ,
  A.BNa_Nazwa2      ,
  ''                ,
  A.BNa_Kraj        ,
  A.BNa_Wojewodztwo ,
  A.BNa_Powiat      ,
  A.BNa_Gmina       ,
  A.BNa_Ulica       ,
  A.BNa_NrDomu      ,
  A.BNa_NrLokalu    ,
  A.BNa_Miasto      ,
  A.BNa_KodPocztowy ,
  A.BNa_Poczta      ,
  A.BNa_Adres2      ,
  A.BNa_Telefon     ,
  A.BNa_Fax         ,
  A.BNa_TelefonSms  ,
  A.BNa_Email       ,
  A.BNa_Nieaktywny  ,
  -2                ,
  'bank'            ,
  ''                ,
  ''                ,
  ''                ,
  ''                ,
  ''                ,
  0                 ,
  A.BNa_ImportRowId ,
  ''                ,
  ''                ,
  NULL              ,
  A.BNa_BNaId       ,
  A.BNa_Akronim     ,
  A.BNa_Nazwa1 + ' ' + A.BNa_Nazwa2
From CDN.BnkNazwy A
Join inserted B On A.BNa_BNaId = B.BNa_BNaId
Left Outer Join CDN.PodmiotyView C On C.Pod_PodmiotTyp = 2 And C.Pod_PodId = B.BNa_BNaId
Where C.Pod_PodId Is Null
IF Update(BNa_Format) OR Update(BNa_FormatImp)
BEGIN
 DELETE cdn.BnkCertyfikaty WHERE
 BnC_BNaID IN
  (SELECT i.BNa_BNaID FROM inserted i LEFT OUTER JOIN cdn.BnkFormatyNag f ON f.BFN_BFNID = i.BNa_Format LEFT OUTER JOIN cdn.BnkFormatyNag fimp ON fimp.BFN_BFNID = i.BNa_FormatImp
   WHERE NOT (IsNull(f.BFN_CDCRodzajCertyfikatow, 0) = 2 OR IsNull(f.BFN_CDCRodzajCertyfikatow, 0) = 0 AND IsNull(fimp.BFN_CDCRodzajCertyfikatow, 0) = 2) AND BnC_OpeID IS NULL)
 DELETE cdn.BnkCertyfikaty WHERE
 BnC_BNaID IN
  (SELECT i.BNa_BNaID FROM inserted i LEFT OUTER JOIN cdn.BnkFormatyNag f ON f.BFN_BFNID = i.BNa_Format LEFT OUTER JOIN cdn.BnkFormatyNag fimp ON fimp.BFN_BFNID = i.BNa_FormatImp
   WHERE NOT (IsNull(f.BFN_CDCRodzajCertyfikatow, 0) = 1 OR IsNull(f.BFN_CDCRodzajCertyfikatow, 0) = 0 AND IsNull(fimp.BFN_CDCRodzajCertyfikatow, 0) = 1) AND BnC_OpeID IS NOT NULL)
END
  Set NoCount On
