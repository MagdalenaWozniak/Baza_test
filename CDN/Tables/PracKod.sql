CREATE TABLE [CDN].[PracKod] (
    [PRA_PraId]           INT            IDENTITY (1, 1) NOT NULL,
    [PRA_Kod]             VARCHAR (20)   NOT NULL,
    [PRA_TS_Export]       DATETIME       NULL,
    [PRA_ImportAppId]     VARCHAR (5)    NULL,
    [PRA_ImportRowId]     VARCHAR (36)   NULL,
    [PRA_Archiwalny]      TINYINT        NOT NULL,
    [PRA_ParentId]        INT            NULL,
    [PRA_Nadrzedny]       TINYINT        NOT NULL,
    [PRA_EPEmail]         NVARCHAR (127) CONSTRAINT [DF_PRA_EPEmail] DEFAULT ('') NOT NULL,
    [PRA_EPTelefon]       NVARCHAR (50)  CONSTRAINT [DF_PRA_EPTelefon] DEFAULT ('') NOT NULL,
    [PRA_EPNrPokoju]      NVARCHAR (50)  CONSTRAINT [DF_PRA_EPNrPokoju] DEFAULT ('') NOT NULL,
    [PRA_EPDostep]        TINYINT        CONSTRAINT [DF_PRA_EPDostep] DEFAULT ((0)) NOT NULL,
    [PRA_EPDostepOkresOd] DATETIME       NULL,
    [PRA_EPDostepOkresDo] DATETIME       NULL,
    CONSTRAINT [PRA_Primary] PRIMARY KEY CLUSTERED ([PRA_PraId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PRAKod]
    ON [CDN].[PracKod]([PRA_Kod] ASC) WITH (FILLFACTOR = 100);


GO
CREATE UNIQUE NONCLUSTERED INDEX [PRAGUID]
    ON [CDN].[PracKod]([PRA_ImportRowId] ASC) WITH (FILLFACTOR = 100);


GO
Create Trigger CDN.PracKod_Delete_Trigger
  On CDN.PracKod
  For Delete
As
Set NoCount On
 --11
 declare @this int
 select @this = pra_praid from deleted
 if exists (select por_porid from cdn.poreczyciele where por_praid = @this)
 begin
     RAISERROR('##OPT32508##', 16, 1)--raiserror('Nie można usunąć pracownika będącego poręczycielem pożyczki PKZP. ', 16, 1) --ERR_SQL_Place_NieMoznaUsunacPoreczyciela
     rollback tran
     set nocount off
     return
 end
-- Aktualizacja PodmiotyView
Delete CDN.PodmiotyView
  From CDN.PodmiotyView Join deleted On Pod_PodmiotTyp = 3 And Pod_PodId = PRA_PRAId
 --MC2018.5 [zgody]
 delete CDN.PodmiotRejestracjaZgod
  from CDN.PodmiotRejestracjaZgod join deleted on PRZ_PodmiotTyp in(3, 4) and PRZ_PodmiotId = PRA_PraId
-- obsługa sprawdzania relacji restrict do tabeli CDN.TraNag
If Exists
  ( Select * From CDN.TraNag, deleted Where Pra_PraId = TrN_OdbID    And TrN_OdbiorcaTyp   = 3 )
Or Exists
  ( Select * From CDN.TraNag, deleted Where Pra_PraId = TrN_OdbDocID And TrN_OdbiorcaDocTyp= 3 )
Or Exists
  ( Select * From CDN.TraNag, deleted Where Pra_PraId = TrN_PodZalID And TrN_PodmiotZalTyp = 3 )
Or Exists
  ( Select * From CDN.TraNag, deleted Where Pra_PraId = TrN_PodID    And TrN_PodmiotTyp    = 3 )
  Begin
    RAISERROR('##OPT32509##', 16, 1)--RaisError('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą TraNag). ', 16, 1)--ERR_SQL_Place_NieMoznaUsunacPracownikaTraNag
    RollBack Tran
    Set NoCount Off
    Return
  End
-- obsługa sprawdzania relacji restrict do tabeli CDN.TraElem
If Exists
  ( Select * From CDN.TraElem, deleted Where Pra_PraId = TrE_PodID    And TrE_PodmiotTyp    = 3 )
  Begin
    RAISERROR('##OPT32510##', 16, 1)--RaisError('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą TraElem). ', 16, 1)--ERR_SQL_Place_NieMoznaUsunacPracownikaTraElem 32510
    RollBack Tran
    Set NoCount Off
    Return
  End
-- obsługa sprawdzania relacji restrict do tabeli CDN.DokPodmioty
If Exists
  ( Select * From CDN.DokPodmioty, deleted Where Pra_PraId = DoP_PodmiotID    And Dop_PodmiotTyp    = 3 )
  Begin
    RAISERROR('##OPT32511##', 16, 1)--RaisError('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą DokPodmioty). ', 16, 1)--ERR_SQL_Place_NieMoznaUsunacPracownikaDokPodmioty 32511
    RollBack Tran
    Set NoCount Off
    Return
  End
-- obsługa sprawdzania relacji restrict do tabeli CDN.VatNag
IF EXISTS (SELECT * FROM CDN.VatNag, deleted WHERE Pra_PraId = VaN_PodID    AND VaN_PodmiotTyp = 3)
OR EXISTS (SELECT * FROM CDN.VatNag, deleted WHERE Pra_PraId = VaN_PodZalID AND VaN_PodmiotZalTyp = 3)
  BEGIN
    RAISERROR('##OPT32512##', 16, 1)--RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą VatNag). ', 16, 1)--ERR_SQL_Place_NieMoznaUsunacPracownikaVatNag 32512
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa sprawdzania relacji restrict do tabeli CDN.EwidDodNag
IF EXISTS (SELECT * FROM CDN.EwidDodNag, deleted WHERE Pra_PraId = EDN_PodZalID AND EDN_PodmiotZalTyp = 3)
  BEGIN
    RAISERROR('##OPT32513##', 16, 1)--RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą EwidDodNag). ', 16, 1)--ERR_SQL_Place_NieMoznaUsunacPracownikaEwidDodNag 32513
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
-- obsługa kasowania rabatow dla pracownika
Delete From CDN.Rabaty Where
 Rab_Typ In (1, 5, 8) And
 Rab_PodmiotTyp = 3 And
 Rab_PodmiotId In (Select Pra_PraId From deleted)
Set NoCount Off

GO
CREATE TRIGGER CDN.PracKod_DeleteHandler
  ON CDN.PracKod
  FOR DELETE
AS
SET NOCOUNT ON
    -- obsługa sprawdzania relacji restrict do tabeli CDN.Kontrahenci
    IF EXISTS
       ( SELECT * FROM CDN.Kontrahenci, deleted
          WHERE
                deleted.PRA_PraId = CDN.Kontrahenci.Knt_OpiekunId
       AND (CDN.Kontrahenci.Knt_OpiekunTyp=3)
       )
    BEGIN
   RAISERROR('##OPT32058##%%1%%=Kontrahenci##', 16, 1)
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.PracKod2WypSkladniki_Delete_Trigger
  ON CDN.PracKod
  FOR DELETE
AS
SET NOCOUNT ON
-- obsługa sprawdzania relacji restrict do tabeli CDN.WypSkladniki
IF EXISTS (SELECT * FROM CDN.WypSkladniki JOIN deleted ON Pra_PraId = WPS_ZrodloId
           WHERE CDN.WypSkladniki.WPS_RodzajZrodla IN (2,3,5,7,10,11))
  BEGIN
 RAISERROR('##OPT32559##', 16, 1)
    --RAISERROR('Istnieją zapisy powiązane z modyfikowanym rekordem (powiązanie z tabelą WypSkladniki). ', 16, 1)--ERR_SQL_Place_WypSkladnikiPowiazanieWPS 32559
    ROLLBACK TRAN
    SET NOCOUNT OFF
    RETURN
  END
SET NOCOUNT OFF

GO
Create Trigger CDN.PracKod_InsertUpdate_Trigger
  On CDN.PracKod
  For Insert, Update
As
Set NoCount On
-- Kasowanie wskanika wyeksportowania
If Not Update (PRA_TS_Export) And Exists (Select * From inserted Where PRA_TS_Export Is Not Null)
  Update CDN.PracKod Set PRA_TS_Export = Null Where PRA_PRAId In (Select PRA_PRAId From inserted Where PRA_TS_Export Is Not Null)
-- Ustawianie unikalnego identyfikatora
If Exists (Select * From inserted Where PRA_ImportRowId Is Null Or PRA_ImportRowId = '')
  Update CDN.PracKod Set PRA_ImportRowId = NewId()
  Where PRA_PRAId In (Select PRA_PRAId From inserted Where PRA_ImportRowId Is Null Or PRA_ImportRowId = '')
--14
declare @ParentId int,
   @PraId int
select @PraId = PRA_PraId, @ParentId = PRA_ParentId from inserted
if @ParentId < 1
  update cdn.prackod set pra_parentid = null where pra_praid = @PraId
Set NoCount Off
