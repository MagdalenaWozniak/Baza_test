CREATE PROCEDURE CDN.CreateDokNagItemWithFile(@fromMode INT, @opeId INT, @dokTitle NVARCHAR(50), @linkedDokTyp INT, @linkedDokId INT,
            @fileName NVARCHAR(254), @DAB_Rozmiar INT, @DAB_Wartosc NVARCHAR(MAX))
AS
BEGIN
--@fromMode = 1 HRM
DECLARE
 @DokId int,
 @OnlyNew smallint,
 @ConfigDBName nvarchar(50),
 @ServerName nvarchar(50),
 @AdditionalIntParam INT, -- TypeForOBD
 @DoN_ImportRowID nvarchar(36),
 @DDf_ImportRowID nvarchar(36),
 @DDf_Symbol nvarchar(5),
 @DDf_Numeracja nvarchar(50),
 @DoN_NumerString nvarchar(50),
 @DoN_NumerNr int,
 @DoN_NumerPelny nvarchar(50),
 @DoN_NumerObcy nvarchar(256),
 @DoN_DataDok nvarchar(10),
 @DoN_Tytul nvarchar(50),
 @DoN_Dotyczy nvarchar(1024),
 @DoN_Typ int,
 @DoN_Katalog nvarchar(20),
 @DoN_Status int,
 @DnP_WBazie smallint,
 @DnP_NazwaPliku nvarchar(256),
 @DnP_Sciezka nvarchar(256),
 @DnP_Wersja smallint,
 @DnP_FileMode smallint,
 @DnP_DataDok nvarchar(10),
 @DnP_Typ int,
 @DnP_Archiwalny int,
 @DnPID int,
 --@DAB_ImportRowID nvarchar(36),
 @DAB_MagazynDanych int,
 @DAB_MagazynDanychID int,
 @DAB_Typ int,
 @DAB_Flaga int,
 --@DAB_Wartosc nvarchar(max),
 --@DAB_Rozmiar INT,
 @DAB_NazwaPliku nvarchar(254),
 @DAB_Nazwa nvarchar(128),
 @DAB_Rozszerzenie nvarchar(4),
 @DAB_Sciezka nvarchar(255),
 @DAB_Wersja nvarchar(20),
 @DAB_IBard24ID bigint,
 @DAB_IBard24LinkPrywatny nvarchar(512),
 @ZrdId nvarchar(5),
 @IdParam int,
 @Warnings nvarchar(1000)
 --IF @ServerName = NULL SELECT @ServerName = @@servername
 SET @AdditionalIntParam = @linkedDokTyp
 SET @DokId = @linkedDokId
 SET @DoN_Tytul = @dokTitle
 SET @DoN_Typ = 1
 SET @DnP_NazwaPliku =  @fileName
 SET @DnP_Sciezka = N''
 SET @DnP_WBazie = 1
 SET @DnP_FileMode = 2
 SET @DnP_Typ = 1
 SET @DnP_Wersja = 1
 SET @DnP_Archiwalny = 0
 SET @DAB_Typ = 2 -- OBD
 SET @DnP_NazwaPliku = @fileName
 SET @DAB_MagazynDanych = 1
 EXEC CDN.ImportujDokumentOBD
      @DokId,
      @OnlyNew,
      @ConfigDBName,
      @ServerName,
      @AdditionalIntParam,
      @DoN_ImportRowID,
      @DDf_ImportRowID,
      @DDf_Symbol,
      @DDf_Numeracja,
      @DoN_NumerString,
      @DoN_NumerNr,
      @DoN_NumerPelny,
      @DoN_NumerObcy,
      @DoN_DataDok,
      @DoN_Tytul,
      @DoN_Dotyczy,
      @DoN_Typ,
      @DoN_Katalog,
      @DoN_Status,
      @fromMode,
      @DnP_WBazie,
      @DnP_NazwaPliku,
      @DnP_Sciezka,
      @DnP_Wersja,
      @DnP_FileMode,
      @DnP_DataDok,
      @DnP_Typ,
      @DnP_Archiwalny,
      @DnPID,
      @DAB_MagazynDanych,
      @DAB_MagazynDanychID,
      @DAB_Typ,
      @DAB_Flaga,
      @DAB_Wartosc,
      @DAB_Rozmiar,
      @DAB_NazwaPliku,
      @DAB_Nazwa,
      @DAB_Rozszerzenie,
      @DAB_Sciezka,
      @DAB_Wersja,
      @DAB_IBard24ID,
      @DAB_IBard24LinkPrywatny,
      @ZrdId,
      @opeId,
      @IdParam OUTPUT,
      @Warnings OUTPUT
 IF @fromMode = 1  AND @IdParam IS NOT NULL AND @linkedDokTyp > 0 AND @linkedDokId > 0
 BEGIN
  UPDATE CDN.DokRelacje SET DoR_HRM = 1 WHERE DoR_ParentTyp = 750 AND DoR_ParentId = @IdParam AND DoR_DokumentTyp = @linkedDokTyp AND DoR_DokumentId = @linkedDokId
 END
END
