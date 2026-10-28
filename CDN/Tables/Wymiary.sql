CREATE TABLE [CDN].[Wymiary] (
    [Wyy_WyyID]          INT           IDENTITY (1, 1) NOT NULL,
    [Wyy_ParentID]       INT           NULL,
    [Wyy_RootID]         INT           NULL,
    [Wyy_TypWymiaru]     SMALLINT      NOT NULL,
    [Wyy_Typ]            SMALLINT      NOT NULL,
    [Wyy_KatId]          INT           NULL,
    [Wyy_SlownikTyp]     SMALLINT      NULL,
    [Wyy_SlownikId]      INT           NULL,
    [Wyy_Wartosc]        VARCHAR (255) NULL,
    [Wyy_Kod]            VARCHAR (20)  NOT NULL,
    [Wyy_Nazwa]          VARCHAR (128) NULL,
    [Wyy_Opis]           VARCHAR (255) NULL,
    [Wyy_Systemowy]      TINYINT       NOT NULL,
    [Wyy_Aktywny]        TINYINT       NOT NULL,
    [Wyy_KontoNumer]     VARCHAR (50)  NULL,
    [Wyy_D001]           TINYINT       NULL,
    [Wyy_D002]           TINYINT       NULL,
    [Wyy_D003]           TINYINT       NULL,
    [Wyy_D004]           TINYINT       NULL,
    [Wyy_D005]           TINYINT       NULL,
    [Wyy_D006]           TINYINT       NULL,
    [Wyy_D007]           TINYINT       NULL,
    [Wyy_D008]           TINYINT       NULL,
    [Wyy_D009]           TINYINT       NULL,
    [Wyy_D010]           TINYINT       NULL,
    [Wyy_D011]           TINYINT       NULL,
    [Wyy_D012]           TINYINT       NULL,
    [Wyy_D013]           TINYINT       NULL,
    [Wyy_D014]           TINYINT       NULL,
    [Wyy_D015]           TINYINT       NULL,
    [Wyy_D016]           TINYINT       NULL,
    [Wyy_D017]           TINYINT       NULL,
    [Wyy_D018]           TINYINT       NULL,
    [Wyy_D019]           TINYINT       NULL,
    [Wyy_D020]           TINYINT       NULL,
    [Wyy_D021]           TINYINT       NULL,
    [Wyy_D022]           TINYINT       NULL,
    [Wyy_D023]           TINYINT       NULL,
    [Wyy_D024]           TINYINT       NULL,
    [Wyy_D025]           TINYINT       NULL,
    [Wyy_D026]           TINYINT       NULL,
    [Wyy_D027]           TINYINT       NULL,
    [Wyy_D028]           TINYINT       NULL,
    [Wyy_D029]           TINYINT       NULL,
    [Wyy_D030]           TINYINT       NULL,
    [Wyy_D031]           TINYINT       NULL,
    [Wyy_D032]           TINYINT       NULL,
    [Wyy_D033]           TINYINT       NULL,
    [Wyy_D034]           TINYINT       NULL,
    [Wyy_D035]           TINYINT       NULL,
    [Wyy_D036]           TINYINT       NULL,
    [Wyy_D037]           TINYINT       NULL,
    [Wyy_D038]           TINYINT       NULL,
    [Wyy_D039]           TINYINT       NULL,
    [Wyy_D040]           TINYINT       NULL,
    [Wyy_W001]           TINYINT       NULL,
    [Wyy_W002]           TINYINT       NULL,
    [Wyy_W003]           TINYINT       NULL,
    [Wyy_W004]           TINYINT       NULL,
    [Wyy_W005]           TINYINT       NULL,
    [Wyy_W006]           TINYINT       NULL,
    [Wyy_W007]           TINYINT       NULL,
    [Wyy_W008]           TINYINT       NULL,
    [Wyy_W009]           TINYINT       NULL,
    [Wyy_W010]           TINYINT       NULL,
    [Wyy_W011]           TINYINT       NULL,
    [Wyy_W012]           TINYINT       NULL,
    [Wyy_W013]           TINYINT       NULL,
    [Wyy_W014]           TINYINT       NULL,
    [Wyy_W015]           TINYINT       NULL,
    [Wyy_W016]           TINYINT       NULL,
    [Wyy_W017]           TINYINT       NULL,
    [Wyy_W018]           TINYINT       NULL,
    [Wyy_W019]           TINYINT       NULL,
    [Wyy_W020]           TINYINT       NULL,
    [Wyy_W021]           TINYINT       NULL,
    [Wyy_W022]           TINYINT       NULL,
    [Wyy_W023]           TINYINT       NULL,
    [Wyy_W024]           TINYINT       NULL,
    [Wyy_W025]           TINYINT       NULL,
    [Wyy_W026]           TINYINT       NULL,
    [Wyy_W027]           TINYINT       NULL,
    [Wyy_W028]           TINYINT       NULL,
    [Wyy_W029]           TINYINT       NULL,
    [Wyy_W030]           TINYINT       NULL,
    [Wyy_W031]           TINYINT       NULL,
    [Wyy_W032]           TINYINT       NULL,
    [Wyy_W033]           TINYINT       NULL,
    [Wyy_W034]           TINYINT       NULL,
    [Wyy_W035]           TINYINT       NULL,
    [Wyy_W036]           TINYINT       NULL,
    [Wyy_W037]           TINYINT       NULL,
    [Wyy_W038]           TINYINT       NULL,
    [Wyy_W039]           TINYINT       NULL,
    [Wyy_W040]           TINYINT       NULL,
    [Wyy_OpeZalID]       INT           NULL,
    [Wyy_StaZalId]       INT           NULL,
    [Wyy_TS_Zal]         DATETIME      NOT NULL,
    [Wyy_OpeModID]       INT           NULL,
    [Wyy_StaModId]       INT           NULL,
    [Wyy_TS_Mod]         DATETIME      NOT NULL,
    [Wyy_OpeModKod]      VARCHAR (20)  CONSTRAINT [DF_Wyy_OpeModKod] DEFAULT ('') NOT NULL,
    [Wyy_OpeModNazwisko] NVARCHAR (50) CONSTRAINT [DF_Wyy_OpeModNazwisko] DEFAULT ('') NOT NULL,
    [Wyy_OpeZalKod]      VARCHAR (20)  CONSTRAINT [DF_Wyy_OpeZalKod] DEFAULT ('') NOT NULL,
    [Wyy_OpeZalNazwisko] NVARCHAR (50) CONSTRAINT [DF_Wyy_OpeZalNazwisko] DEFAULT ('') NOT NULL,
    CONSTRAINT [Wyy_Primary] PRIMARY KEY CLUSTERED ([Wyy_WyyID] ASC) WITH (FILLFACTOR = 100)
);


GO
CREATE TRIGGER CDN.Wymiary_Delete_Trigger
  ON CDN.Wymiary
  FOR DELETE
AS
  SET NOCOUNT ON
  declare @kod varchar(255);
  declare @id int;
  declare @systemowy int;
  DECLARE Usuniete CURSOR LOCAL FAST_FORWARD FOR
  SELECT Wyy_WyyId, Wyy_Kod, Wyy_Systemowy FROM deleted
  OPEN Usuniete
  WHILE 1=1
  begin
    FETCH NEXT FROM Usuniete INTO @id, @kod, @systemowy
    IF @@FETCH_STATUS <> 0 BREAK
    if IsNull( @systemowy, 0) =1
    begin
   exec CDN.RiseOptimaException 32647, 's', @kod
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    end
    IF EXISTS (SELECT * FROM CDN.Wymiary where Wyy_ParentID = @id)
    BEGIN
   exec CDN.RiseOptimaException 32648, 's', @kod
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    IF EXISTS (SELECT * FROM cdn.WymiaryWartosci where WyW_WyyId = @id)
    BEGIN
   exec CDN.RiseOptimaException 32649, 's', @kod
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
  end
 Close Usuniete
 Deallocate Usuniete
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Wymiary_AfterUpdate_Trigger
  ON CDN.Wymiary
  AFTER UPDATE
AS
  SET NOCOUNT ON
  declare @kod varchar(255);
  declare @id int;
  declare @aktywny tinyint;
  declare
  @Wyy_D001 tinyint,@Wyy_D002 tinyint,@Wyy_D003 tinyint,@Wyy_D004 tinyint,@Wyy_D005 tinyint,
  @Wyy_D006 tinyint,@Wyy_D007 tinyint,@Wyy_D008 tinyint,@Wyy_D009 tinyint,@Wyy_D010 tinyint,
  @Wyy_D011 tinyint,@Wyy_D012 tinyint,@Wyy_D013 tinyint,@Wyy_D014 tinyint,@Wyy_D015 tinyint,
  @Wyy_D016 tinyint,@Wyy_D017 tinyint,@Wyy_D018 tinyint,@Wyy_D019 tinyint,@Wyy_D020 tinyint,
  @Wyy_D021 tinyint,@Wyy_D022 tinyint,@Wyy_D023 tinyint,@Wyy_D024 tinyint,@Wyy_D025 tinyint,
  @Wyy_D026 tinyint,@Wyy_D027 tinyint,@Wyy_D028 tinyint,@Wyy_D029 tinyint,@Wyy_D030 tinyint,
  @Wyy_D031 tinyint,@Wyy_D032 tinyint,@Wyy_D033 tinyint,@Wyy_D034 tinyint,@Wyy_D035 tinyint,
  @Wyy_D036 tinyint,@Wyy_D037 tinyint,@Wyy_D038 tinyint,@Wyy_D039 tinyint,@Wyy_D040 tinyint,
  @Wyy_W001 tinyint,@Wyy_W002 tinyint,@Wyy_W003 tinyint,@Wyy_W004 tinyint,@Wyy_W005 tinyint,
  @Wyy_W006 tinyint,@Wyy_W007 tinyint,@Wyy_W008 tinyint,@Wyy_W009 tinyint,@Wyy_W010 tinyint,
  @Wyy_W011 tinyint,@Wyy_W012 tinyint,@Wyy_W013 tinyint,@Wyy_W014 tinyint,@Wyy_W015 tinyint,
  @Wyy_W016 tinyint,@Wyy_W017 tinyint,@Wyy_W018 tinyint,@Wyy_W019 tinyint,@Wyy_W020 tinyint,
  @Wyy_W021 tinyint,@Wyy_W022 tinyint,@Wyy_W023 tinyint,@Wyy_W024 tinyint,@Wyy_W025 tinyint,
  @Wyy_W026 tinyint,@Wyy_W027 tinyint,@Wyy_W028 tinyint,@Wyy_W029 tinyint,@Wyy_W030 tinyint,
  @Wyy_W031 tinyint,@Wyy_W032 tinyint,@Wyy_W033 tinyint,@Wyy_W034 tinyint,@Wyy_W035 tinyint,
  @Wyy_W036 tinyint,@Wyy_W037 tinyint,@Wyy_W038 tinyint,@Wyy_W039 tinyint,@Wyy_W040 tinyint;
  DECLARE Dodane CURSOR LOCAL FAST_FORWARD FOR
  SELECT Wyy_WyyId, Wyy_Kod, Wyy_Aktywny,
  Wyy_D001,Wyy_D002,Wyy_D003,Wyy_D004,Wyy_D005,
  Wyy_D006,Wyy_D007,Wyy_D008,Wyy_D009,Wyy_D010,
  Wyy_D011,Wyy_D012,Wyy_D013,Wyy_D014,Wyy_D015,
  Wyy_D016,Wyy_D017,Wyy_D018,Wyy_D019,Wyy_D020,
  Wyy_D021,Wyy_D022,Wyy_D023,Wyy_D024,Wyy_D025,
  Wyy_D026,Wyy_D027,Wyy_D028,Wyy_D029,Wyy_D030,
  Wyy_D031,Wyy_D032,Wyy_D033,Wyy_D034,Wyy_D035,
  Wyy_D036,Wyy_D037,Wyy_D038,Wyy_D039,Wyy_D040,
  Wyy_W001,Wyy_W002,Wyy_W003,Wyy_W004,Wyy_W005,
  Wyy_W006,Wyy_W007,Wyy_W008,Wyy_W009,Wyy_W010,
  Wyy_W011,Wyy_W012,Wyy_W013,Wyy_W014,Wyy_W015,
  Wyy_W016,Wyy_W017,Wyy_W018,Wyy_W019,Wyy_W020,
  Wyy_W021,Wyy_W022,Wyy_W023,Wyy_W024,Wyy_W025,
  Wyy_W026,Wyy_W027,Wyy_W028,Wyy_W029,Wyy_W030,
  Wyy_W031,Wyy_W032,Wyy_W033,Wyy_W034,Wyy_W035,
  Wyy_W036,Wyy_W037,Wyy_W038,Wyy_W039,Wyy_W040
  FROM inserted
  OPEN Dodane
  WHILE 1=1
  begin
    FETCH NEXT FROM Dodane INTO @id, @kod, @aktywny,
    @Wyy_D001,@Wyy_D002,@Wyy_D003,@Wyy_D004,@Wyy_D005,
    @Wyy_D006,@Wyy_D007,@Wyy_D008,@Wyy_D009,@Wyy_D010,
    @Wyy_D011,@Wyy_D012,@Wyy_D013,@Wyy_D014,@Wyy_D015,
    @Wyy_D016,@Wyy_D017,@Wyy_D018,@Wyy_D019,@Wyy_D020,
    @Wyy_D021,@Wyy_D022,@Wyy_D023,@Wyy_D024,@Wyy_D025,
    @Wyy_D026,@Wyy_D027,@Wyy_D028,@Wyy_D029,@Wyy_D030,
    @Wyy_D031,@Wyy_D032,@Wyy_D033,@Wyy_D034,@Wyy_D035,
    @Wyy_D036,@Wyy_D037,@Wyy_D038,@Wyy_D039,@Wyy_D040,
    @Wyy_W001,@Wyy_W002,@Wyy_W003,@Wyy_W004,@Wyy_W005,
    @Wyy_W006,@Wyy_W007,@Wyy_W008,@Wyy_W009,@Wyy_W010,
    @Wyy_W011,@Wyy_W012,@Wyy_W013,@Wyy_W014,@Wyy_W015,
    @Wyy_W016,@Wyy_W017,@Wyy_W018,@Wyy_W019,@Wyy_W020,
    @Wyy_W021,@Wyy_W022,@Wyy_W023,@Wyy_W024,@Wyy_W025,
    @Wyy_W026,@Wyy_W027,@Wyy_W028,@Wyy_W029,@Wyy_W030,
    @Wyy_W031,@Wyy_W032,@Wyy_W033,@Wyy_W034,@Wyy_W035,
    @Wyy_W036,@Wyy_W037,@Wyy_W038,@Wyy_W039,@Wyy_W040
    IF @@FETCH_STATUS <> 0 BREAK
    if Update(Wyy_Aktywny)
    or Update(Wyy_D001) or Update(Wyy_D002) or Update(Wyy_D003) or Update(Wyy_D004) or Update(Wyy_D005)
    or Update(Wyy_D006) or Update(Wyy_D007) or Update(Wyy_D008) or Update(Wyy_D009) or Update(Wyy_D010)
    or Update(Wyy_D011) or Update(Wyy_D012) or Update(Wyy_D013) or Update(Wyy_D014) or Update(Wyy_D015)
    or Update(Wyy_D016) or Update(Wyy_D017) or Update(Wyy_D018) or Update(Wyy_D019) or Update(Wyy_D020)
    or Update(Wyy_D021) or Update(Wyy_D022) or Update(Wyy_D023) or Update(Wyy_D024) or Update(Wyy_D025)
    or Update(Wyy_D026) or Update(Wyy_D027) or Update(Wyy_D028) or Update(Wyy_D029) or Update(Wyy_D030)
    or Update(Wyy_D031) or Update(Wyy_D032) or Update(Wyy_D033) or Update(Wyy_D034) or Update(Wyy_D035)
    or Update(Wyy_D036) or Update(Wyy_D037) or Update(Wyy_D038) or Update(Wyy_D039) or Update(Wyy_D040)
    or Update(Wyy_W001) or Update(Wyy_W002) or Update(Wyy_W003) or Update(Wyy_W004) or Update(Wyy_W005)
    or Update(Wyy_W006) or Update(Wyy_W007) or Update(Wyy_W008) or Update(Wyy_W009) or Update(Wyy_W010)
    or Update(Wyy_W011) or Update(Wyy_W012) or Update(Wyy_W013) or Update(Wyy_W014) or Update(Wyy_W015)
    or Update(Wyy_W016) or Update(Wyy_W017) or Update(Wyy_W018) or Update(Wyy_W019) or Update(Wyy_W020)
    or Update(Wyy_W021) or Update(Wyy_W022) or Update(Wyy_W023) or Update(Wyy_W024) or Update(Wyy_W025)
    or Update(Wyy_W026) or Update(Wyy_W027) or Update(Wyy_W028) or Update(Wyy_W029) or Update(Wyy_W030)
    or Update(Wyy_W031) or Update(Wyy_W032) or Update(Wyy_W033) or Update(Wyy_W034) or Update(Wyy_W035)
    or Update(Wyy_W036) or Update(Wyy_W037) or Update(Wyy_W038) or Update(Wyy_W039) or Update(Wyy_W040)
    begin
      --update cdn.wymiary set Wyy_aktywny = @aktywny where Wyy_ParentId = @Id;
      WITH Wymiar AS (
        SELECT Wyy_WyyID as ID from CDN.Wymiary where Wyy_WyyID = @ID
        UNION ALL
        SELECT A.Wyy_WyyID from CDN.Wymiary A join Wymiar on (Wymiar.ID = A.Wyy_ParentID)
      )
      update cdn.wymiary set Wyy_Aktywny = @aktywny,
      Wyy_D001=@Wyy_D001,Wyy_D002=@Wyy_D002,Wyy_D003=@Wyy_D003,Wyy_D004=@Wyy_D004,Wyy_D005=@Wyy_D005,
      Wyy_D006=@Wyy_D006,Wyy_D007=@Wyy_D007,Wyy_D008=@Wyy_D008,Wyy_D009=@Wyy_D009,Wyy_D010=@Wyy_D010,
      Wyy_D011=@Wyy_D011,Wyy_D012=@Wyy_D012,Wyy_D013=@Wyy_D013,Wyy_D014=@Wyy_D014,Wyy_D015=@Wyy_D015,
      Wyy_D016=@Wyy_D016,Wyy_D017=@Wyy_D017,Wyy_D018=@Wyy_D018,Wyy_D019=@Wyy_D019,Wyy_D020=@Wyy_D020,
      Wyy_D021=@Wyy_D021,Wyy_D022=@Wyy_D022,Wyy_D023=@Wyy_D023,Wyy_D024=@Wyy_D024,Wyy_D025=@Wyy_D025,
      Wyy_D026=@Wyy_D026,Wyy_D027=@Wyy_D027,Wyy_D028=@Wyy_D028,Wyy_D029=@Wyy_D029,Wyy_D030=@Wyy_D030,
      Wyy_D031=@Wyy_D031,Wyy_D032=@Wyy_D032,Wyy_D033=@Wyy_D033,Wyy_D034=@Wyy_D034,Wyy_D035=@Wyy_D035,
      Wyy_D036=@Wyy_D036,Wyy_D037=@Wyy_D037,Wyy_D038=@Wyy_D038,Wyy_D039=@Wyy_D039,Wyy_D040=@Wyy_D040,
      Wyy_W001=@Wyy_W001,Wyy_W002=@Wyy_W002,Wyy_W003=@Wyy_W003,Wyy_W004=@Wyy_W004,Wyy_W005=@Wyy_W005,
      Wyy_W006=@Wyy_W006,Wyy_W007=@Wyy_W007,Wyy_W008=@Wyy_W008,Wyy_W009=@Wyy_W009,Wyy_W010=@Wyy_W010,
      Wyy_W011=@Wyy_W011,Wyy_W012=@Wyy_W012,Wyy_W013=@Wyy_W013,Wyy_W014=@Wyy_W014,Wyy_W015=@Wyy_W015,
      Wyy_W016=@Wyy_W016,Wyy_W017=@Wyy_W017,Wyy_W018=@Wyy_W018,Wyy_W019=@Wyy_W019,Wyy_W020=@Wyy_W020,
      Wyy_W021=@Wyy_W021,Wyy_W022=@Wyy_W022,Wyy_W023=@Wyy_W023,Wyy_W024=@Wyy_W024,Wyy_W025=@Wyy_W025,
      Wyy_W026=@Wyy_W026,Wyy_W027=@Wyy_W027,Wyy_W028=@Wyy_W028,Wyy_W029=@Wyy_W029,Wyy_W030=@Wyy_W030,
      Wyy_W031=@Wyy_W031,Wyy_W032=@Wyy_W032,Wyy_W033=@Wyy_W033,Wyy_W034=@Wyy_W034,Wyy_W035=@Wyy_W035,
      Wyy_W036=@Wyy_W036,Wyy_W037=@Wyy_W037,Wyy_W038=@Wyy_W038,Wyy_W039=@Wyy_W039,Wyy_W040=@Wyy_W040
      from cdn.wymiary join Wymiar on (ID = Wyy_WyyID)
      where ID <> @ID;
    end
  end
 Close Dodane
 Deallocate Dodane
  SET NOCOUNT OFF

GO
CREATE TRIGGER CDN.Wymiary_InsertUpdate_Trigger
  ON CDN.Wymiary
  FOR INSERT, UPDATE
AS
  SET NOCOUNT ON
  declare @kod varchar(255);
  declare @id int;
  declare @parentId int;
  declare @rootId int;
  if exists(select * from inserted D join CDN.WymiaryWartosci on (D.Wyy_WyyID = WyW_WyyId))
  begin
    if Update(Wyy_Kod)
    begin
   exec CDN.RiseOptimaException 32655
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    end
    if Update(Wyy_TypWymiaru)
    begin
   exec CDN.RiseOptimaException 32650
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    end
    if Update(Wyy_SlownikTyp)
    begin
   exec CDN.RiseOptimaException 32651
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    end
    if Update(Wyy_SlownikId)
    begin
   exec CDN.RiseOptimaException 32652
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    end
  end
  DECLARE Dodane CURSOR LOCAL FAST_FORWARD FOR
  SELECT Wyy_WyyId, Wyy_Kod, Wyy_ParentId, Wyy_RootId FROM inserted
  OPEN Dodane
  WHILE 1=1
  begin
    FETCH NEXT FROM Dodane INTO @id, @kod, @parentId, @rootId
    IF @@FETCH_STATUS <> 0 BREAK
    if IsNull(@parentId, 0) = 0 and (@kod = 'PROJEKT' or @kod = 'WYDZIAŁ' or @kod = 'LOKALIZACJA')
    begin
   exec CDN.RiseOptimaException 32653, 's', @kod
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    end
    IF EXISTS (SELECT * FROM CDN.Wymiary where Wyy_Kod = @kod and Wyy_WyyId <> @id and IsNUll(Wyy_ParentId, 0)=@parentId)
    BEGIN
   exec CDN.RiseOptimaException 32654, 's', @kod
      ROLLBACK TRAN
      SET NOCOUNT OFF
      RETURN
    END
    if @rootId is null
      update cdn.wymiary set Wyy_RootId = CDN.WymiarRootId(@id) where Wyy_WyyId = @id;
  end
 Close Dodane
 Deallocate Dodane
  SET NOCOUNT OFF
