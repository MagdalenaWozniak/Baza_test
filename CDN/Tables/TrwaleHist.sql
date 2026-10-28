CREATE TABLE [CDN].[TrwaleHist] (
    [SrH_SrHID]               INT             IDENTITY (1, 1) NOT NULL,
    [SrH_SrTID]               INT             NULL,
    [SrH_Typ]                 SMALLINT        NOT NULL,
    [SrH_Grupa]               VARCHAR (20)    NOT NULL,
    [SrH_TypDokumentu]        SMALLINT        NOT NULL,
    [SrH_Rodzaj]              TINYINT         NOT NULL,
    [SrH_DataOpe]             DATETIME        NULL,
    [SrH_KwotaKoszt]          DECIMAL (15, 2) NOT NULL,
    [SrH_KwotaBilan]          DECIMAL (15, 2) NOT NULL,
    [SrH_KwotaUm]             DECIMAL (15, 2) NOT NULL,
    [SrH_KwotaAm]             DECIMAL (15, 2) NOT NULL,
    [SrH_DokumentTyp]         INT             NULL,
    [SrH_DokumentID]          INT             NULL,
    [SrH_Numer]               NVARCHAR (256)  NULL,
    [SrH_KatID]               INT             NULL,
    [SrH_Kategoria]           VARCHAR (50)    NOT NULL,
    [SrH_Metoda]              TINYINT         NOT NULL,
    [SrH_MetodaBil]           TINYINT         NOT NULL,
    [SrH_Stawka]              DECIMAL (5, 2)  NOT NULL,
    [SrH_StawkaBil]           DECIMAL (5, 2)  NOT NULL,
    [SrH_Wspolczynnik]        DECIMAL (7, 4)  NOT NULL,
    [SrH_WspolczynnikBil]     DECIMAL (7, 4)  NOT NULL,
    [SrH_Ulga]                TINYINT         NOT NULL,
    [SrH_KPRId]               INT             NULL,
    [SrH_DekId]               INT             NULL,
    [SrH_DataPrzekazaniaOd]   DATETIME        NULL,
    [SrH_DataPrzekazaniaDo]   DATETIME        NULL,
    [SrH_PrcID1]              INT             NULL,
    [SrH_PrcImieNazwisko1]    NVARCHAR (255)  NULL,
    [SrH_MiejsceUzytkowania1] NVARCHAR (255)  NULL,
    [SrH_PrcID2]              INT             NULL,
    [SrH_PrcImieNazwisko2]    NVARCHAR (255)  NULL,
    [SrH_MiejsceUzytkowania2] NVARCHAR (255)  NULL,
    [SrH_Opis]                NVARCHAR (MAX)  NULL,
    [SrH_PreDekId]            INT             NULL,
    [SrH_OpeZalID]            INT             NULL,
    [SrH_StaZalId]            INT             NULL,
    [SrH_TS_Zal]              DATETIME        NOT NULL,
    [SrH_OpeModID]            INT             NULL,
    [SrH_StaModId]            INT             NULL,
    [SrH_TS_Mod]              DATETIME        NOT NULL,
    [SrH_LTDataAmo]           DATETIME        NULL,
    [SrH_LTDataAmoBil]        DATETIME        NULL,
    [SrH_LTWyliczUm]          TINYINT         CONSTRAINT [DF_SrH_LTWyliczUm] DEFAULT ((0)) NOT NULL,
    [SrH_UwzglKsgBadRozw]     TINYINT         CONSTRAINT [DF_SrH_UwzglKsgBadRozw] DEFAULT ((0)) NOT NULL,
    [SrH_ZakID]               INT             NULL,
    [SrH_OpeModKod]           VARCHAR (20)    CONSTRAINT [DF_SrH_OpeModKod] DEFAULT ('') NOT NULL,
    [SrH_OpeModNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_SrH_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [SrH_OpeZalKod]           VARCHAR (20)    CONSTRAINT [DF_SrH_OpeZalKod] DEFAULT ('') NOT NULL,
    [SrH_OpeZalNazwisko]      NVARCHAR (50)   CONSTRAINT [DF_SrH_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [SrH_Primary] PRIMARY KEY CLUSTERED ([SrH_SrHID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SrHKategoria] FOREIGN KEY ([SrH_KatID]) REFERENCES [CDN].[Kategorie] ([Kat_KatID]),
    CONSTRAINT [FK_SrHTrwale] FOREIGN KEY ([SrH_SrTID]) REFERENCES [CDN].[Trwale] ([SrT_SrTID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrHTrwale]
    ON [CDN].[TrwaleHist]([SrH_SrTID] ASC, [SrH_DataOpe] ASC, [SrH_SrHID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrHChrono]
    ON [CDN].[TrwaleHist]([SrH_Typ] ASC, [SrH_TypDokumentu] ASC, [SrH_DataOpe] ASC, [SrH_SrTID] ASC, [SrH_SrHID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrHChronoGrupa]
    ON [CDN].[TrwaleHist]([SrH_Typ] ASC, [SrH_Grupa] ASC, [SrH_TypDokumentu] ASC, [SrH_DataOpe] ASC, [SrH_SrTID] ASC, [SrH_SrHID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrHKPR]
    ON [CDN].[TrwaleHist]([SrH_KPRId] ASC, [SrH_SrHID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrHDekrety]
    ON [CDN].[TrwaleHist]([SrH_DekId] ASC, [SrH_SrHID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrHPreDekret]
    ON [CDN].[TrwaleHist]([SrH_PreDekId] ASC) WITH (FILLFACTOR = 100);


GO
CREATE NONCLUSTERED INDEX [SrHDokument]
    ON [CDN].[TrwaleHist]([SrH_DokumentTyp] ASC, [SrH_DokumentID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [SrHKategoria]
    ON [CDN].[TrwaleHist]([SrH_KatID] ASC, [SrH_DataOpe] ASC, [SrH_SrHID] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.TrwaleHist_Delete_Trigger
  ON CDN.TrwaleHist
  FOR DELETE
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy środek trwały nie został zlikwidowany
  IF EXISTS (SELECT * FROM deleted JOIN CDN.Trwale On SrH_SrTId = SrT_SrTId
             WHERE SrT_Stan <> 0)
    BEGIN
      RAISERROR('##OPT32369##', 16, 1) -- RAISERROR('Nie można kasować dokumentów dla środków trwałych zlikwidowanych.', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy zapisy nie są zaksięgowane do KPiR
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.SrH_KpRId IS NOT NULL)
    BEGIN
      RAISERROR('##OPT32283##', 16, 1) -- RAISERROR('Nie można kasować zapisów zaksięgowanych (KPiR)', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Sprawdzenie, czy zapisy nie są zaksięgowane na konta
  IF EXISTS (SELECT * FROM deleted
             WHERE deleted.SrH_DekId IS NOT NULL)
    BEGIN
      RAISERROR('##OPT32370##', 16, 1) -- RAISERROR('Nie można kasować zapisów zaksięgowanych (Dekrety)', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
-- Skasowanie relacji do dokumentów z biblioteki  (RZ )
  DELETE CDN.DokRelacje
  FROM CDN.DokRelacje JOIN deleted ON DoR_DokumentTyp=1007 AND DoR_DokumentId=deleted.SrH_SrHId
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.TrwaleHist_InsertUpdate_Trigger
  ON CDN.TrwaleHist
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy nie zmieniono grupy środka trwałego
IF EXISTS (SELECT * FROM inserted JOIN CDN.Trwale
          ON     inserted.SrH_SrTId =  CDN.Trwale.SrT_SrTId
          WHERE  inserted.SrH_Typ   <> CDN.Trwale.SrT_Typ)
    BEGIN
      RAISERROR('##OPT32371##', 16, 1) -- RAISERROR('Typ niezgodny z kartą środka trwałego (Trwale)', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
--Sprawdzanie obecności wierszy w tabeli nadrzędnej ZapisyKPR
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.ZapisyKPR ON
                    inserted.SrH_KPRID       = CDN.ZapisyKPR.KPR_KPRID
              WHERE CDN.ZapisyKPR.KPR_KPRID IS NULL
                AND inserted.SrH_KPRID IS NOT NULL
           )
        BEGIN
          RAISERROR('##OPT32242##%%tabela%%=ZapisyKPR##', 16, 1) -- RAISERROR('Brak wartości w tabeli nadrzędnej (ZapisyKPR) ', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--Sprawdzanie obecności wierszy w tabeli nadrzędnej DekretyNag
        IF EXISTS
           (  SELECT * FROM inserted LEFT OUTER JOIN CDN.DekretyNag ON
                    inserted.SrH_DekID       = CDN.DekretyNag.DeN_DeNId
              WHERE CDN.DekretyNag.DeN_DeNId IS NULL
                AND inserted.SrH_DekID IS NOT NULL
           )
        BEGIN
          RAISERROR('##OPT32242##%%tabela%%=DekretyNag##', 16, 1) -- RAISERROR('Brak wartości w tabeli nadrzędnej (DekretyNag) ', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--Sprawdzanie czy nie aktualizowane są kwoty środka zlikwidowanego
  IF UPDATE (SrH_KwotaBilan) OR UPDATE (SrH_KwotaKoszt) OR UPDATE (SrH_KwotaUm) OR UPDATE (SrH_KwotaAm)
   IF EXISTS (SELECT * FROM inserted JOIN CDN.Trwale ON SrH_SrTId=SrT_SrTId WHERE NOT (SrH_TypDokumentu=5 AND SrH_Rodzaj<>0) AND SrT_Stan<>0)
     OR EXISTS (SELECT * FROM inserted i WHERE (SELECT COUNT(*) FROM CDN.TrwaleHist h WHERE h.SrH_SrTID = i.SrH_SrTID AND H.SrH_TypDokumentu = 5 AND H.SrH_Rodzaj <> 0) > 1)
        BEGIN
          RAISERROR('##OPT32372##', 16, 1) -- RAISERROR('Środek trwały został zlikwidowany.', 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
-- Sprawdzanie (w przypadku księgowości kontowej) czy nie dodajemy dokumentu po końcu ostatniego OO
 DECLARE @rk INT
 SELECT @rk = Fir_Wartosc FROM cdn.Firma WHERE Fir_Opis = 'Rodzaj księgowości'
 IF @rk=3
 BEGIN
  DECLARE @dataMax DATETIME
  SELECT TOP 1 @dataMax = OOb_dataKoncowa FROM CDN.OkresyObrach ORDER BY OOb_dataKoncowa DESC
   IF EXISTS (SELECT inserted.SrH_SrHID FROM inserted WHERE NOT EXISTS (SELECT deleted.SrH_SrHID FROM deleted WHERE deleted.SrH_SrHID = inserted.SrH_SrHID)
              AND inserted.SrH_DataOpe>@dataMax)
   BEGIN
    RAISERROR('##OPT32373##', 16, 1) -- RAISERROR('Nie można dodawać dokumentów środków trwałych poza okresem obrachunkowym.', 16, 1)
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
   END
 END
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.TrwaleHist_DeleteHandler
  ON CDN.TrwaleHist
  FOR DELETE
AS
  SET NOCOUNT ON
    -- obsługa sprawdzania relacji restrict do tabeli CDN.DekretyElem
    IF EXISTS
       ( SELECT * FROM deleted d JOIN CDN.DekretyElem ON DeE_DokumentId = d.SrH_SrHID
     JOIN cdn.DekretyNag ON DeN_DeNId = DeE_DeNID
          WHERE DeE_DokumentTyp =7 AND DeN_Typ <> 1
       )
    BEGIN
      RAISERROR('##OPT32226##%%tabela%%=DekretyElem##', 16, 1) -- RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą DekretyElem). ', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
/*
    -- obsługa kaskadowego kasowania wierszy z tabeli CDN.KwotyDodatkowe
    DELETE CDN.KwotyDodatkowe
    FROM CDN.KwotyDodatkowe, deleted
    WHERE
          deleted.SrH_SrHID = CDN.KwotyDodatkowe.Kdd_DokumentID
      AND (CDN.KwotyDodatkowe.KDD_DokumentTyp=7)
*/
    -- obsługa kaskadowego kasowania wierszy z tabeli CDN.DekretyNag (predekrety)
 IF EXISTS (SELECT DeN_DeNID FROM CDN.DekretyNag JOIN deleted ON DeN_DeNId = deleted.SrH_PreDekID)
  DELETE CDN.DekretyNag FROM CDN.DekretyNag JOIN deleted ON DeN_DeNId = deleted.SrH_PreDekID
   WHERE deleted.SrH_PreDekID = CDN.DekretyNag.DeN_DeNID
  SET NOCOUNT OFF
