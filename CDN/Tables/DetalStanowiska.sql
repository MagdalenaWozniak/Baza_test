CREATE TABLE [CDN].[DetalStanowiska] (
    [DSta_DStaId]                              INT            IDENTITY (1, 1) NOT NULL,
    [DSta_Nazwa]                               NVARCHAR (50)  NOT NULL,
    [DSta_Opis]                                NVARCHAR (100) NOT NULL,
    [DSta_Typ]                                 TINYINT        NOT NULL,
    [DSta_GenerujWZ]                           TINYINT        NOT NULL,
    [DSta_TypNettoBrutto]                      TINYINT        NOT NULL,
    [DSta_TwGGIDNumer]                         INT            NOT NULL,
    [DSta_DDfIdPA]                             INT            NOT NULL,
    [DSta_DDfIdPAKor]                          INT            NOT NULL,
    [DSta_DDfIdFS]                             INT            NOT NULL,
    [DSta_DDfIdFSKor]                          INT            NOT NULL,
    [DSta_DDfIdMM]                             INT            NOT NULL,
    [DSta_DDfIdRO]                             INT            NOT NULL,
    [DSta_DDfIdKP]                             INT            NOT NULL,
    [DSta_DDfIdKW]                             INT            NOT NULL,
    [DSta_DDfIdPKA]                            INT            NOT NULL,
    [DSta_DDfIdCRM]                            INT            NOT NULL,
    [DSta_DDfIdWZ]                             INT            CONSTRAINT [DF_DSta_DDfIdWZ] DEFAULT ((0)) NOT NULL,
    [DSta_DDfIdPF]                             INT            CONSTRAINT [DF_DSta_DDfIdPF] DEFAULT ((0)) NOT NULL,
    [DSta_BRaId]                               INT            NOT NULL,
    [DSta_Seria]                               NVARCHAR (5)   NOT NULL,
    [DSta_MagId]                               INT            NOT NULL,
    [DSta_KntGrupa]                            NVARCHAR (20)  CONSTRAINT [DF_DSta_KntGrupa] DEFAULT ('') NULL,
    [DSta_MagIdZwrotny]                        INT            NOT NULL,
    [DSta_TwCNumer]                            INT            NOT NULL,
    [DSta_Nieaktywne]                          TINYINT        NOT NULL,
    [DSta_TS_Synchro]                          DATETIME       NOT NULL,
    [DSta_TS_SynchroTwr]                       DATETIME       NOT NULL,
    [DSta_TS_SynchroKnt]                       DATETIME       NOT NULL,
    [DSta_TS_SynchroTraNag]                    DATETIME       NOT NULL,
    [DSta_TS_SynchroZapisKB]                   DATETIME       NOT NULL,
    [DSta_TS_SynchroImportKnt]                 DATETIME       NOT NULL,
    [DSta_TS_SynchroOpak]                      DATETIME       NOT NULL,
    [DSta_TS_SynchroKntPotw]                   DATETIME       NOT NULL,
    [DSta_TS_SynchroTwrPotw]                   DATETIME       NOT NULL,
    [DSta_TS_SynchroPotw]                      DATETIME       NOT NULL,
    [DSta_TS_SynchroGrup]                      DATETIME       NOT NULL,
    [DSta_TS_SynchroGrupPotw]                  DATETIME       NOT NULL,
    [DSta_EdycjaKnt]                           TINYINT        CONSTRAINT [DF_DSta_EdycjaKnt] DEFAULT ((1)) NOT NULL,
    [DSta_PobieranieSkladnikowFSUslugaZlozona] TINYINT        CONSTRAINT [DF_DSta_DSta_PobieranieSkladnikowFSUslugaZlozona] DEFAULT ((0)) NOT NULL,
    [DSta_KntOpiekun]                          TINYINT        CONSTRAINT [DF_DSta_KntOpiekun] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [DSta_Primary] PRIMARY KEY CLUSTERED ([DSta_DStaId] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE TRIGGER [CDN].[DetalStanowiska_Delete_Trigger]
  On [CDN].[DetalStanowiska]
  For Delete
As
Set NoCount On
 DELETE CDN.DetalFormyPlatnosci
    FROM CDN.DetalFormyPlatnosci, deleted
    WHERE
    DFPl_DStaId  = deleted.DSta_DStaId
 DELETE CDN.DetalOperator
    FROM CDN.DetalOperator, deleted
    WHERE
    DOpe_DStaId = deleted.DSta_DStaId
Set NoCount Off

GO
Create TRIGGER CDN.DetalStanowiska_InsertUpdate_Trigger
  ON CDN.DetalStanowiska
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy jest seria
DECLARE
@DDF_NumeracjaPA         NVarchar(50),
@DDF_NumeracjaFS         NVarchar(50),
@DDF_NumeracjaKP         NVarchar(50),
@DDF_NumeracjaKW         NVarchar(50),
@DDF_NumeracjaPKA        NVarchar(50),
@DDF_NumeracjaPAKor      NVarchar(50),
@DDF_NumeracjaFSKor      NVarchar(50),
@SymbolPA                NVarchar(20),
@SymbolFS                NVarchar(20),
@SymbolKP                NVarchar(20),
@SymbolKW                NVarchar(20),
@SymbolPKA               NVarchar(20),
@SymbolPAKor             NVarchar(20),
@SymbolFSkor             NVarchar(20),
@DDF_NumeracjaCRM        NVarchar(50),
@SymbolCRM               NVarchar(20),
@DDF_NumeracjaWZ         NVarchar(50),
@SymbolWZ                NVarchar(20),
@DDF_NumeracjaPF         NVarchar(50),
@SymbolPF                NVarchar(20),
@Typ                     INT,
@Komunikat               NVarchar(225)
IF EXISTS  (select DSta_MagId from inserted where DSta_MagId in (select Mag_MagId from cdn.Magazyny where Mag_NieAktywny = 1))
BEGIN
  RAISERROR('##OPT34506##', 16, 1)
  ROLLBACK TRAN
  SET NOCOUNT OFF
  RETURN
END
 IF EXISTS (SELECT * FROM deleted
               JOIN inserted ON deleted.DSta_DStaId = inserted.DSta_DStaId
               JOIN CDN.DetalStanowiska ON deleted.DSta_DStaId = CDN.DetalStanowiska.DSta_DStaId
               WHERE deleted.DSta_TwGGIDNumer<>inserted.DSta_TwGGIDNumer OR deleted.DSta_TwCNumer<>inserted.DSta_TwCNumer
              )
    BEGIN
      Update CDN.DetalStanowiska SET DSta_TS_SynchroTwr = '1900-01-01 00:00:00.000'
       where DSta_DStaId in(SELECT DSta_DStaId FROM deleted)
    END
select   @DDF_NumeracjaPA = A.DDf_Numeracja ,  @DDF_NumeracjaFS = B.DDf_Numeracja
       , @DDF_NumeracjaPAkor = F.DDf_Numeracja ,  @DDF_NumeracjaFSKor = G.DDf_Numeracja
       , @DDF_NumeracjaKP = C.DDf_Numeracja ,  @DDF_NumeracjaKW = D.DDf_Numeracja
       , @DDF_NumeracjaPKA = ISNULL(E.DDf_Numeracja,'')
       , @SymbolPA = A.DDf_Symbol ,@SymbolFS = B.DDf_Symbol
       , @SymbolPAKor = F.DDf_Symbol ,@SymbolFSKor = G.DDf_Symbol
       , @SymbolKP = c.DDf_Symbol ,@SymbolKW = D.DDf_Symbol
       , @SymbolPKA = isnull(E.DDf_Symbol,'')
    , @SymbolCRM = isnull(H.DDf_Symbol,''),@DDF_NumeracjaCRM = ISNULL(H.DDf_Numeracja,'')
    , @SymbolWZ = isnull(I.DDf_Symbol,''),@DDF_NumeracjaWZ = ISNULL(I.DDf_Numeracja,'')
    , @SymbolPF = isnull(J.DDf_Symbol,''),@DDF_NumeracjaPF = ISNULL(J.DDf_Numeracja,'')
    , @Typ = DSta_Typ
 from inserted
join cdn.dokdefinicje A on dsta_ddfIdPa= A.DDf_DDfId
join cdn.dokdefinicje B on dsta_ddfIdFS= B.DDf_DDfId
join cdn.dokdefinicje C on dsta_ddfIdKP= C.DDf_DDfId
join cdn.dokdefinicje D on dsta_ddfIdKW= D.DDf_DDfId
join cdn.dokdefinicje F on dsta_ddfIdPaKor= F.DDf_DDfId
join cdn.dokdefinicje G on dsta_ddfIdFSKor= G.DDf_DDfId
left join cdn.dokdefinicje E on dsta_ddfIdPKA= E.DDf_DDfId
left join cdn.dokdefinicje H on dsta_ddfIdCRM= H.DDf_DDfId
left join cdn.dokdefinicje I on dsta_ddfIdWZ= I.DDf_DDfId
left join cdn.dokdefinicje J on dsta_ddfIdPF= J.DDf_DDfId
join cdn.magazyny on DSta_MagID = Mag_MagID
  IF (select CHARINDEX('@rejestr',@DDF_NumeracjaPA)) = 0
    BEGIN
          SET @Komunikat = '##OPT34507##%%s1%%=' + @SymbolPA+ '##'--' Schemat numeracji '+ @SymbolPA +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaFS)) = 0
    BEGIN
          SET @Komunikat =  '##OPT34507##%%s1%%=' + @SymbolFS+ '##'--' Schemat numeracji '+ @SymbolFS +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
  IF (select CHARINDEX('@rejestr',@DDF_NumeracjaPAKor)) = 0
    BEGIN
          SET @Komunikat =  '##OPT34507##%%s1%%=' + @SymbolPAKor+ '##'--' Schemat numeracji '+ @SymbolPAKor +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaFSKor)) = 0
    BEGIN
          SET @Komunikat =  '##OPT34507##%%s1%%=' + @SymbolFSKor+ '##'--' Schemat numeracji '+ @SymbolFSKor +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaKP)) = 0
    BEGIN
          SET @Komunikat =  '##OPT34507##%%s1%%=' + @SymbolKP+ '##'--' Schemat numeracji '+ @SymbolKP +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaKW)) = 0
    BEGIN
          SET @Komunikat =  '##OPT34507##%%s1%%=' + @SymbolKW+ '##'--' Schemat numeracji '+ @SymbolKW +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaPKA)) = 0 AND @DDF_NumeracjaPKA <> ''
    BEGIN
          SET @Komunikat =  '##OPT34507##%%s1%%=' + @SymbolPKA+ '##'--' Schemat numeracji '+ @SymbolPKA +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaCRM)) = 0 AND @DDF_NumeracjaCRM <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat =  '##OPT34507##%%s1%%=' + @SymbolCRM+ '##'--' Schemat numeracji '+ @SymbolCRM +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaWZ)) = 0 AND @DDF_NumeracjaWZ <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat =  '##OPT34507##%%s1%%=' + @SymbolWZ+ '##'--' Schemat numeracji '+ @SymbolWZ +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaPF)) = 0 AND @DDF_NumeracjaPF <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat =  '##OPT34507##%%s1%%=' + @SymbolPF+ '##'--' Schemat numeracji '+ @SymbolPF +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
  IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaPA)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaFS)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaPAKor)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaFSKor)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaKP)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaKW)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaPKA)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
  IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaCRM)) <> 0 AND @DDF_NumeracjaCRM <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
  IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaWZ)) <> 0 AND @DDF_NumeracjaWZ <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
  IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaPF)) <> 0 AND @DDF_NumeracjaPF <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
--Sprawdzenie, czy seria juz nie istnieje
IF EXISTS (SELECT * FROM CDN.Firma WHERE Fir_Numer = 1470 AND Fir_Wartosc = '4') and UPDATE( DSta_Seria )
BEGIN
       IF EXISTS  (select DSta_Seria from inserted where DSta_Seria in
                          (select Bra_Symbol from cdn.BnkRachunki))
        BEGIN
              RAISERROR('##OPT34509##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
  declare @gru_nazwa NVarchar(5)
  DECLARE N CURSOR LOCAL FAST_FORWARD FOR
  select DSta_Seria from inserted
             OPEN N
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM N INTO @gru_nazwa
                    IF @@FETCH_STATUS <> 0 BREAK
      if exists( select * from cdn.firma where  fir_wartosc = @gru_nazwa)
        BEGIN
              RAISERROR('##OPT34510##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
      if exists( select * from cdn.tranag where trn_numerpelny like '%/'+@gru_nazwa)
      or exists( select * from cdn.tranag where trn_numerpelny like '%/'+@gru_nazwa+'/%')
      or exists( select * from cdn.tranag where trn_numerpelny like @gru_nazwa+'/%')
        BEGIN
              RAISERROR('##OPT34511##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
     END
     CLOSE N
     DEALLOCATE N
END
ELSE
BEGIN
       IF EXISTS  (select DSta_Seria from inserted where DSta_Seria in
                          (select gru_nazwa from cdn.grupy where gru_typ > 299 and gru_typ <400 union select DSta_Seria from cdn.detalstanowiska where dsta_dstaid not in (select DSta_DStaId from inserted)))
        BEGIN
              RAISERROR('##OPT34512##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
       IF EXISTS  (select DSta_Seria from inserted where DSta_Seria in
                          (select Bra_Symbol from cdn.BnkRachunki))
        BEGIN
              RAISERROR('##OPT34512##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
END
delete from cdn.grupy where gru_nazwa in (select DSta_Seria from inserted)  and gru_typ > 299 and gru_typ <400
--END
Set NoCount Off

GO
CREATE TRIGGER CDN.DetalStanowiska_InsertINSTEADOF_Trigger
  ON CDN.DetalStanowiska INSTEAD OF
  INSERT
AS
  SET NOCOUNT ON
-- Sprawdzenie, czy jest seria
DECLARE
@DDF_NumeracjaPA         NVarchar(50),
@DDF_NumeracjaFS         NVarchar(50),
@DDF_NumeracjaKP         NVarchar(50),
@DDF_NumeracjaKW         NVarchar(50),
@DDF_NumeracjaPKA        NVarchar(50),
@DDF_NumeracjaPAKor      NVarchar(50),
@DDF_NumeracjaFSKor      NVarchar(50),
@SymbolPA                NVarchar(20),
@SymbolFS                NVarchar(20),
@SymbolKP                NVarchar(20),
@SymbolKW                NVarchar(20),
@SymbolPKA               NVarchar(20),
@SymbolPAKor             NVarchar(20),
@SymbolFSkor             NVarchar(20),
@SymbolCRM               NVarchar(20),
@DDF_NumeracjaCRM        NVarchar(50),
@DDF_NumeracjaWZ         NVarchar(50),
@SymbolWZ                NVarchar(20),
@DDF_NumeracjaPF         NVarchar(50),
@SymbolPF                NVarchar(20),
@Typ                     INT,
@Komunikat               NVarchar(225)
select   @DDF_NumeracjaPA = A.DDf_Numeracja ,  @DDF_NumeracjaFS = B.DDf_Numeracja
       , @DDF_NumeracjaPAkor = F.DDf_Numeracja ,  @DDF_NumeracjaFSKor = G.DDf_Numeracja
       , @DDF_NumeracjaKP = C.DDf_Numeracja ,  @DDF_NumeracjaKW = D.DDf_Numeracja
       , @DDF_NumeracjaPKA = ISNULL(E.DDf_Numeracja,'')
       , @SymbolPA = A.DDf_Symbol ,@SymbolFS = B.DDf_Symbol
       , @SymbolPAKor = F.DDf_Symbol ,@SymbolFSKor = G.DDf_Symbol
       , @SymbolKP = c.DDf_Symbol ,@SymbolKW = D.DDf_Symbol
       , @SymbolPKA = isnull(E.DDf_Symbol,'')
    , @SymbolCRM = isnull(H.DDf_Symbol,''),@DDF_NumeracjaCRM = ISNULL(H.DDf_Numeracja,'')
    , @SymbolWZ = isnull(I.DDf_Symbol,''),@DDF_NumeracjaWZ = ISNULL(I.DDf_Numeracja,'')
    , @SymbolPF = isnull(J.DDf_Symbol,''),@DDF_NumeracjaPF = ISNULL(J.DDf_Numeracja,'')
    , @Typ = DSta_Typ
 from inserted
join cdn.dokdefinicje A on dsta_ddfIdPa= A.DDf_DDfId
join cdn.dokdefinicje B on dsta_ddfIdFS= B.DDf_DDfId
join cdn.dokdefinicje C on dsta_ddfIdKP= C.DDf_DDfId
join cdn.dokdefinicje D on dsta_ddfIdKW= D.DDf_DDfId
join cdn.dokdefinicje F on dsta_ddfIdPaKor= F.DDf_DDfId
join cdn.dokdefinicje G on dsta_ddfIdFSKor= G.DDf_DDfId
left join cdn.dokdefinicje E on dsta_ddfIdPKA= E.DDf_DDfId
left join cdn.dokdefinicje H on dsta_ddfIdCRM= H.DDf_DDfId
left join cdn.dokdefinicje I on dsta_ddfIdWZ= I.DDf_DDfId
left join cdn.dokdefinicje J on dsta_ddfIdPF= J.DDf_DDfId
join cdn.magazyny on DSta_MagID = Mag_MagID
  IF (select CHARINDEX('@rejestr',@DDF_NumeracjaPA)) = 0
    BEGIN
          SET @Komunikat = '##OPT34507##%%s1%%=' + @SymbolPA+ '##'--' Schemat numeracji '+ @SymbolPA +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaFS)) = 0
    BEGIN
          SET @Komunikat = '##OPT34507##%%s1%%=' + @SymbolFS+ '##'--' Schemat numeracji '+ @SymbolFS +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
  IF (select CHARINDEX('@rejestr',@DDF_NumeracjaPAKor)) = 0
    BEGIN
          SET @Komunikat = '##OPT34507##%%s1%%=' + @SymbolPAKor+ '##'--' Schemat numeracji '+ @SymbolPAKor +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaFSKor)) = 0
    BEGIN
          SET @Komunikat = '##OPT34507##%%s1%%=' + @SymbolFSKor+ '##'--' Schemat numeracji '+ @SymbolFSKor +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaKP)) = 0
    BEGIN
          SET @Komunikat = '##OPT34507##%%s1%%=' + @SymbolKP+ '##'--' Schemat numeracji '+ @SymbolKP +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaKW)) = 0
    BEGIN
          SET @Komunikat = '##OPT34507##%%s1%%=' + @SymbolKW+ '##'--' Schemat numeracji '+ @SymbolKW +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaPKA)) = 0 AND @DDF_NumeracjaPKA <> ''
    BEGIN
          SET @Komunikat = '##OPT34507##%%s1%%=' + @SymbolPKA+ '##'--' Schemat numeracji '+ @SymbolPKA +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaCRM)) = 0 AND @DDF_NumeracjaCRM <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat = '##OPT34507##%%s1%%=' + @SymbolCRM+ '##'--' Schemat numeracji '+ @SymbolCRM +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaWZ)) = 0 AND @DDF_NumeracjaWZ <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat = '##OPT34507##%%s1%%=' + @SymbolWZ+ '##'--' Schemat numeracji '+ @SymbolWZ +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rejestr',@DDF_NumeracjaPF)) = 0 AND @DDF_NumeracjaPF <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat = '##OPT34507##%%s1%%=' + @SymbolPF+ '##'--' Schemat numeracji '+ @SymbolPF +' nie zawiera obowiązkowego elementu: Seria. Wybierz inny schemat numeracji.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
  IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaPA)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaFS)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaPAKor)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaFSKor)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaKP)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaKW)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaPKA)) <> 0
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
 IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaCRM)) <> 0 AND @DDF_NumeracjaCRM <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaWZ)) <> 0 AND @DDF_NumeracjaWZ <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
  IF (select CHARINDEX('@rok_obr',@DDF_NumeracjaPF)) <> 0 AND @DDF_NumeracjaPF <> '' AND @Typ <> 1
    BEGIN
          SET @Komunikat = '##OPT34508##'--'Wybrano schemat numeracji z rokiem obrachunkowym. W CDN OPT!MA DETAL schemat numeracji nie może działać w obrębie roku obrachunkowego.'
          RAISERROR(@Komunikat, 16, 1)
          ROLLBACK TRAN
          SET NOCOUNT OFF
          RETURN
    END
--Sprawdzenie, czy seria juz nie istnieje
IF EXISTS (SELECT * FROM CDN.Firma WHERE Fir_Numer = 1470 AND Fir_Wartosc = '4')
BEGIN
     IF EXISTS  (select DSta_Seria from inserted where DSta_Seria in
                          (select Bra_Symbol from cdn.BnkRachunki))
        BEGIN
              RAISERROR('##OPT34509##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
  declare @gru_nazwa NVarchar(5)
  DECLARE N CURSOR LOCAL FAST_FORWARD FOR
  select DSta_Seria from inserted
             OPEN N
              WHILE 1=1
                BEGIN
                  FETCH NEXT FROM N INTO @gru_nazwa
                    IF @@FETCH_STATUS <> 0 BREAK
      if exists( select * from cdn.firma where  fir_wartosc = @gru_nazwa)
        BEGIN
              RAISERROR('##OPT34510##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
      if exists( select * from cdn.tranag where trn_numerpelny like '%/'+@gru_nazwa)
      or exists( select * from cdn.tranag where trn_numerpelny like '%/'+@gru_nazwa+'/%')
      or exists( select * from cdn.tranag where trn_numerpelny like @gru_nazwa+'/%')
        BEGIN
              RAISERROR('##OPT34511##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
     END
     CLOSE N
     DEALLOCATE N
END
ELSE
BEGIN
       IF EXISTS  (select DSta_Seria from inserted where DSta_Seria in
                          (select gru_nazwa from cdn.grupy where gru_typ > 299 and gru_typ <400 union select DSta_Seria from cdn.detalstanowiska where dsta_dstaid not in (select DSta_DStaId from inserted)))
        BEGIN
              RAISERROR('##OPT34512##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
     IF EXISTS  (select DSta_Seria from inserted where DSta_Seria in
                          (select Bra_Symbol from cdn.BnkRachunki))
        BEGIN
              RAISERROR('##OPT34512##', 16, 1)
              ROLLBACK TRAN
              SET NOCOUNT OFF
              RETURN
        END
end
insert into CDN.DetalStanowiska
           ([DSta_Nazwa]
           ,[DSta_TwGGIDNumer]
           ,[DSta_DDfIdPA]
           ,[DSta_DDfIdFS]
           ,[DSta_DDfIdPAKor]
           ,[DSta_DDfIdFSKor]
           ,[DSta_DDfIdKP]
           ,[DSta_DDfIdKW]
           ,[DSta_Seria]
           ,[DSta_MagId]
           ,[DSta_TwCNumer]
           ,[DSta_Nieaktywne]
           ,[DSta_TS_Synchro]
           ,[DSta_TS_SynchroTwr]
           ,[DSta_TS_SynchroKnt]
           ,[DSta_TS_SynchroTraNag]
           ,[DSta_TS_SynchroZapisKB]
           ,[DSta_TS_SynchroImportKnt]
           ,[DSta_TS_SynchroOpak]
           ,[DSta_DDfIdPKA]
           ,[DSta_DDfIdMM]
           ,[DSta_DDfIdRO]
           ,[DSta_Opis]
           ,[DSta_MagIdZwrotny]
           ,[DSta_Typ]
           ,[DSta_TypNettoBrutto]
           ,[DSta_TS_SynchroTwrPotw]
           ,[DSta_TS_SynchroKntPotw]
           ,[DSta_TS_SynchroPotw]
           ,[DSta_BRaId]
           ,[DSta_TS_SynchroGrup]
           ,[DSta_TS_SynchroGrupPotw]
           ,[DSta_GenerujWZ]
           ,[DSta_KntGrupa]
           ,[DSta_DDfIdCRM]
     ,[DSta_DDfIdWZ]
     ,[DSta_DDfIdPF]
     ,[DSta_edycjaknt])
select  [DSta_Nazwa]
           ,[DSta_TwGGIDNumer]
           ,[DSta_DDfIdPA]
           ,[DSta_DDfIdFS]
           ,[DSta_DDfIdPAKor]
           ,[DSta_DDfIdFSKor]
           ,[DSta_DDfIdKP]
           ,[DSta_DDfIdKW]
           ,[DSta_Seria]
           ,[DSta_MagId]
           ,[DSta_TwCNumer]
           ,[DSta_Nieaktywne]
           ,[DSta_TS_Synchro]
           ,[DSta_TS_SynchroTwr]
           ,[DSta_TS_SynchroKnt]
           ,[DSta_TS_SynchroTraNag]
           ,[DSta_TS_SynchroZapisKB]
           ,[DSta_TS_SynchroImportKnt]
           ,[DSta_TS_SynchroOpak]
           ,[DSta_DDfIdPKA]
           ,[DSta_DDfIdMM]
           ,[DSta_DDfIdRO]
           ,[DSta_Opis]
           ,[DSta_MagIdZwrotny]
           ,[DSta_Typ]
           ,[DSta_TypNettoBrutto]
           ,[DSta_TS_SynchroTwrPotw]
           ,[DSta_TS_SynchroKntPotw]
           ,[DSta_TS_SynchroPotw]
           ,[DSta_BRaId]
           ,[DSta_TS_SynchroGrup]
           ,[DSta_TS_SynchroGrupPotw]
           ,[DSta_GenerujWZ]
           ,[DSta_KntGrupa]
     ,[DSta_DDfIdCRM]
     ,[DSta_DDfIdWZ]
     ,[DSta_DDfIdPF]
     ,[DSta_edycjaknt]
from inserted
delete from cdn.grupy where gru_nazwa in (select DSta_Seria from inserted)  and gru_typ > 299 and gru_typ <400
Set NoCount Off
