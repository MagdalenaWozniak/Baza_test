CREATE TABLE [CDN].[Grupy] (
    [Gru_GruID]          INT            IDENTITY (1, 1) NOT NULL,
    [Gru_Typ]            SMALLINT       NOT NULL,
    [Gru_Nazwa]          VARCHAR (32)   NOT NULL,
    [Gru_Opis]           NVARCHAR (128) NOT NULL,
    [Gru_Flaga]          SMALLINT       NULL,
    [Gru_NazwaPEF]       NVARCHAR (20)  CONSTRAINT [DF_Gru_NazwaPEF] DEFAULT ('') NOT NULL,
    [Gru_KontoWn]        NVARCHAR (50)  NULL,
    [Gru_KontoMa]        NVARCHAR (50)  NULL,
    [Gru_OpeZalID]       INT            NULL,
    [Gru_StaZalId]       INT            NULL,
    [Gru_TS_Zal]         DATETIME       NULL,
    [Gru_OpeZalKod]      VARCHAR (20)   CONSTRAINT [DF_Gru_OpeZalKod] DEFAULT ('') NOT NULL,
    [Gru_OpeZalNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Gru_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    [Gru_OpeModID]       INT            NULL,
    [Gru_StaModId]       INT            NULL,
    [Gru_TS_Mod]         DATETIME       NULL,
    [Gru_OpeModKod]      VARCHAR (20)   CONSTRAINT [DF_Gru_OpeModKod] DEFAULT ('') NOT NULL,
    [Gru_OpeModNazwisko] NVARCHAR (50)  CONSTRAINT [DF_Gru_OpeModNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [Gru_Primary] PRIMARY KEY CLUSTERED ([Gru_GruID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [GruNazwa]
    ON [CDN].[Grupy]([Gru_Typ] ASC, [Gru_Nazwa] ASC) WITH (FILLFACTOR = 100);


GO
CREATE TRIGGER CDN.Grupy_InsertUpdateDelete_Trigger
  ON CDN.Grupy
  FOR INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
--Sprawdzenie, czy grupa nie ma pustej nazwy
      IF EXISTS (SELECT * FROM inserted WHERE inserted.Gru_Nazwa = '' OR inserted.Gru_Nazwa IS NULL)
        BEGIN
          UPDATE CDN.Grupy SET CDN.Grupy.Gru_Nazwa = '$TEMP' + STR(CDN.Grupy.Gru_GruId, 10)
          WHERE CDN.Grupy.Gru_GruId IN (SELECT inserted.Gru_GruId FROM inserted WHERE inserted.Gru_Nazwa = '' OR inserted.Gru_Nazwa IS NULL)
-- Rollback transakcji w przypadku błędu
          IF @@ERROR <> 0
            BEGIN
     exec CDN.RiseOptimaException 32614
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
            END
        END
--Sprawdzenie, czy seria nie zostala wybrana w detalu
       IF EXISTS  (select gru_nazwa from inserted where gru_typ <> 1 and gru_typ <> 2 and gru_typ <> 11 and gru_typ <> 12 and
    gru_typ <> 21 and gru_typ <> 31 and gru_typ <> 32 and gru_typ <> 34 and gru_typ <> 35 and
    gru_nazwa in (select DSta_Seria from cdn.detalstanowiska))
        BEGIN
     exec CDN.RiseOptimaException 32615
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
--Sprawdzenie, czy skasowano rekord lub zmieniono kod
  IF EXISTS (SELECT * FROM deleted
             LEFT OUTER JOIN inserted
             ON     deleted.Gru_GruId   =inserted.Gru_GruId
             WHERE deleted.Gru_Nazwa <> inserted.Gru_Nazwa OR inserted.Gru_Nazwa IS NULL)
    BEGIN
--Sprawdzenie, czy zmiana dotyczy nie pustego rejestru VAT
      IF EXISTS (SELECT * FROM deleted
                JOIN   CDN.VatNag
                ON     deleted.Gru_Typ   = CDN.VatNag.VaN_Typ
                AND    deleted.Gru_Nazwa = CDN.VatNag.VaN_Rejestr)
        BEGIN
    exec CDN.RiseOptimaException 32616
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--Sprawdzenie, czy zmiana dotyczy nie pustej grupy środków trwałych
      IF EXISTS (SELECT * FROM deleted
                JOIN   CDN.Trwale
                ON     deleted.Gru_Typ   = CDN.Trwale.SrT_typ
                AND    deleted.Gru_Nazwa = CDN.Trwale.SrT_Grupa)
        BEGIN
    exec CDN.RiseOptimaException 32617
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--Sprawdzenie, czy zmiana dotyczy nie pustej grupy kontrahentów
      IF EXISTS (SELECT * FROM deleted
                JOIN   CDN.Kontrahenci
                ON     deleted.Gru_Typ   = 31
                AND    deleted.Gru_Nazwa = CDN.Kontrahenci.Knt_Grupa)
        BEGIN
    exec CDN.RiseOptimaException 32618
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
        END
--Sprawdzenie, czy zmiana dotyczy nie pustej grupy towarów
-- zmień kod
-- Aktualizacja FaCyklKnt
 Update CDN.FaCyklKnt Set
  FcK_Kod          = A.Gru_Nazwa ,
  FcK_Nazwa        = A.Gru_Opis
  From CDN.FaCyklKnt
  Join inserted B  On B.Gru_Typ=31 And FcK_PodmiotTyp = 0 And FcK_PodmiotId = B.Gru_GruId
  Join CDN.Grupy A On A.Gru_GruId = B.Gru_GruId
    END
If Not Exists (Select * From inserted)
  Begin
    -- obsługa kasowania rabatow dla grup kontrahentow
    Delete From CDN.Rabaty Where
     Rab_Typ In (2, 3, 4) And
     Rab_PodmiotTyp = 1 And
     Rab_PodmiotId In (Select Gru_GruId From deleted Where Gru_Typ=31)
    -- obsługa kasowania rabatow dla grup towarow
    Delete From CDN.Rabaty Where
     Rab_Typ In (3, 7, 8) And
     Rab_TwrId In (Select Gru_GruId From deleted Where Gru_Typ=33)
    -- obsługa kasowania FaCykl
 Delete From CDN.FaCyklKnt Where
  FCK_PodmiotTyp=0
  And FCK_PodmiotId In (Select Gru_GruId From deleted Where Gru_Typ=31)
  End
  SET NOCOUNT OFF
