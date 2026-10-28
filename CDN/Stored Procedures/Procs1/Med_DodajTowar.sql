CREATE PROCEDURE CDN.Med_DodajTowar
  @OptimaId int ,   -- Id optimy jeli nowy 0
 @Twr_Typ tinyint, -- typ towaru 0 - usługa, 1- towar
 @Twr_Kod NVARCHAR(50), -- Kod Towaru
 @Twr_Nazwa NVARCHAR(255), -- Nazwa towaru
 @Twr_NieAktywny tinyint, -- czy towar nieaktywny 0 - aktywny -1 nieaktywny
 @Twr_Stawka decimal(5,2), -- stawka VAT
 @Twr_JMCalkowite tinyint, -- czy towar sprzedawany w jednostkach całkowitych
 @Twr_JM NVARCHAR(20),  -- nazwa jednostki miary
 @Twr_Opis NVARCHAR(1024),  -- opis
 @Twr_SWW NVARCHAR(20), -- SWW/PKWiU
 @Twr_EAN NVARCHAR(40), -- EAN
 @Twr_Cena decimal(15,2), -- cena
 @Twr_Zlozony  tinyint = 0, -- czy towar jest usługą złożoną
 @KodGrupyTwr NVARCHAR(50) ='',
 @NazwaGrupyTwr NVARCHAR(255) ='',
 @GrupaTwrId INT = 0,
 @StanDetalID int = 0
AS
SET NOCOUNT ON
DECLARE
@Twr_TwCNumer int,
@Twr_TwrId  int
select top 1 @Twr_TwCNumer = DfC_Lp from cdn.defceny where DfC_Typ = 2
if @GrupaTwrId = 0 and (@KodGrupyTwr ! = '' or @NazwaGrupyTwr != '')
begin
if not exists(select * from cdn.TwrGrupy where Twg_GIDTyp = -16 and (TwG_Kod = @KodGrupyTwr))
begin
 INSERT INTO [CDN].[TwrGrupy]
           ([TwG_GIDTyp]
           ,[TwG_GIDFirma]
           ,[TwG_GIDNumer]
           ,[TwG_GIDLp]
           ,[TwG_GrOTyp]
           ,[TwG_GrOFirma]
           ,[TwG_GrONumer]
           ,[TwG_GrOLp]
           ,[TwG_Kod]
           ,[TwG_Nazwa])
     select
           -16
           ,0
           , MAX(TwG_GIDNumer)+1
           ,0
           ,-16
           ,0
           ,0
           ,0
           ,@KodGrupyTwr
           ,@NazwaGrupyTwr
           FROM CDN.TwrGrupy
     select @GrupaTwrId = TwG_GIDNumer from cdn.TwrGrupy where TwG_Kod = @KodGrupyTwr
end
else
begin
 select top 1 @GrupaTwrId = TwG_GIDNumer from cdn.TwrGrupy where TwG_Kod = @KodGrupyTwr
end
end
else
 select @GrupaTwrId = ISNULL(DSta_TwGGIDNumer,'') from CDN.DetalStanowiska where  DSta_DStaId = @StanDetalID
if @OptimaId = 0
 BEGIN
    if exists (SELECT   Twr_TwrID    FROM CDN.Towary    WHERE Twr_Kod = @Twr_Kod)
    BEGIN
     RAISERROR( 'Taki symbol towaru już istnieje', 16, 1)
     RETURN
    END
  if not exists(select * from cdn.grupy where gru_typ = 32 and gru_nazwa = @Twr_JM)
  insert into cdn.grupy(Gru_Typ,Gru_Nazwa,Gru_Opis,Gru_Flaga) values(32,@Twr_JM,@Twr_JM,NULL)
      -- dodajemy nowego
  INSERT INTO CDN.Towary
           (Twr_Typ
           ,Twr_Produkt
           ,Twr_Kod
           ,Twr_PLU
           ,Twr_NumerKat
           ,Twr_SWW
           ,Twr_EAN
           ,Twr_Nazwa
           ,Twr_NazwaFiskalna
           ,Twr_TwGGIDNumer
           ,Twr_URL
           ,Twr_KatId
           ,Twr_Kategoria
           ,Twr_KatZakId
           ,Twr_KategoriaZak
           ,Twr_Opis
           ,Twr_EdycjaNazwy
           ,Twr_KopiujOpis
           ,Twr_EdycjaOpisu
           ,Twr_JM
           ,Twr_JMCalkowite
           ,Twr_Kaucja
           ,Twr_TwCNumer
           ,Twr_UdostepniajWCenniku
           ,Twr_Waluta
           ,Twr_KursNumer
           ,Twr_KursL
           ,Twr_KursM
           ,Twr_MinCenaMarza
           ,Twr_TypMinimum
           ,Twr_KosztUslugiWal
           ,Twr_KosztUslugi
           ,Twr_KosztUslugiTyp
           ,Twr_KosztKGO
           ,Twr_SONId
           ,Twr_KntId
           ,Twr_KodDostawcy
           ,Twr_IloscMin
           ,Twr_IloscMinJM
           ,Twr_IloscMax
           ,Twr_IloscMaxJM
           ,Twr_IloscZam
           ,Twr_IloscZamJM
           ,Twr_Stawka
           ,Twr_Flaga
           ,Twr_Zrodlowa
           ,Twr_StawkaExport
           ,Twr_FlagaExport
           ,Twr_ZrodlowaExport
           ,Twr_StawkaZak
           ,Twr_FlagaZak
           ,Twr_ZrodlowaZak
           ,Twr_Prog
           ,Twr_Upust
           ,Twr_UpustData
           ,Twr_UpustDataOd
           ,Twr_UpustDataDo
           ,Twr_UpustGodz
           ,Twr_UpustGodzOd
           ,Twr_UpustGodzDo
           ,Twr_BezRabatu
           ,Twr_MarzaMin
           ,Twr_NieAktywny
           ,Twr_ESklep
           ,Twr_KCNId
           ,Twr_Masa
           ,Twr_KrajPochodzenia
           ,Twr_JmPomPrzelicznikL
           ,Twr_JmPomPrzelicznikM
           ,Twr_OpeZalID
           ,Twr_StaZalId
           ,Twr_TS_Zal
           ,Twr_OpeModID
           ,Twr_StaModId
           ,Twr_TS_XL
           ,Twr_TS_Mod
           ,Twr_GIDTyp
           ,Twr_GIDFirma
           ,Twr_GIDNumer
           ,Twr_GIDLp
     ,Twr_PobieranieSkladnikowFSUslugaZlozona)
     VALUES
           (case when @Twr_Zlozony = 1 then 0 else @Twr_Typ end
           ,case when @Twr_Zlozony = 1 then 1 else 0 end
           ,@Twr_Kod
           ,''
           ,''
           ,@Twr_SWW
           ,@Twr_EAN
           ,@Twr_Nazwa
           ,''
           ,@GrupaTwrId
           ,''
           ,NULL
           ,''
           ,NULL
           ,''
           ,@Twr_Opis
           ,0
           ,0
           ,0
           ,@Twr_JM
           ,@Twr_JMCalkowite
           ,0
           ,@Twr_TwCNumer
           ,0
           ,'PLN'
           ,2
           ,1
           ,1
           ,0
           ,0
           ,0
           ,0
           ,1
           ,0
           ,NULL
           ,NULL
           ,''
           ,0
           ,@Twr_JM
           ,0
           ,@Twr_JM
           ,0
           ,@Twr_JM
           ,@Twr_Stawka
           ,2
           ,0
           ,0
           ,0
           ,0
           ,@Twr_Stawka
           ,2
           ,0
           ,0
           ,0
           ,0
           ,NULL
           ,NULL
           ,0
           ,NULL
           ,NULL
           ,0
           ,0
           ,@Twr_NieAktywny
           ,NULL
           ,NULL
           ,0
           ,''
           ,1
           ,1
           ,NULL
           ,NULL
           ,GETDATE()
           ,NULL
           ,NULL
           ,NULL
           ,GETDATE()
           ,16
           ,NULL
           ,NULL
           ,NULL
     ,@Twr_Zlozony)
select @Twr_TwrId = Twr_TwrId from cdn.towary where twr_kod = @Twr_Kod
update cdn.towary set Twr_GIDNumer = twr_twrid where twr_twrid = @Twr_TwrId
insert into cdn.twrceny
select @Twr_TwrId,DfC_LP,DfC_Typ,0,'PLN',0,0.01,0,0,0,NULL,NULL,NULL,NULL,0,0,0 from defceny
update cdn.twrceny set TwC_Wartosc =  @Twr_Cena, TwC_Marza = -100, TwC_MarzaWStu= -100 where TwC_TwrId = @Twr_TwrId and TwC_TwCNumer = @Twr_TwCNumer
 END
else
 BEGIN
    select @Twr_TwrID = @OptimaId
    UPDATE cdn.Towary SET
      Twr_Typ = case when @Twr_Zlozony = 1 then 0 else @Twr_Typ end,
      Twr_Produkt = case when @Twr_Zlozony = 1 then 1 else 0 end,
      Twr_Kod = @Twr_Kod,
      Twr_Nazwa = @Twr_Nazwa,
      Twr_NieAktywny = @Twr_NieAktywny,
      Twr_Stawka = @Twr_Stawka,
      Twr_JMCalkowite = @Twr_JMCalkowite,
      Twr_JM = @Twr_JM,
      Twr_Opis = @Twr_Opis,
      Twr_SWW = @Twr_SWW,
      Twr_EAN = @Twr_EAN,
      Twr_TwCNumer = @Twr_TwCNumer,
      Twr_PobieranieSkladnikowFSUslugaZlozona = @Twr_Zlozony,
      Twr_TwGGIDNumer = @GrupaTwrId
      WHERE Twr_TwrId = @OptimaId
update cdn.twrceny set TwC_Wartosc =  @Twr_Cena, TwC_Marza = -100, TwC_MarzaWStu= -100 where TwC_TwrId = @Twr_TwrId and TwC_TwCNumer = @Twr_TwCNumer
END
if @GrupaTwrId != 0 and not exists (select * from cdn.TwrGrupy where TwG_GrOTyp = -16 and TwG_GIDTyp = 16 and TwG_GIDNumer = @Twr_TwrID and TwG_GrONumer = @GrupaTwrId)
begin
 INSERT INTO [CDN].[TwrGrupy]
           ([TwG_GIDTyp]
           ,[TwG_GIDFirma]
           ,[TwG_GIDNumer]
           ,[TwG_GIDLp]
           ,[TwG_GrOTyp]
           ,[TwG_GrOFirma]
           ,[TwG_GrONumer]
           ,[TwG_GrOLp]
           ,[TwG_Kod]
           ,[TwG_Nazwa])
     select
   16
           ,0
           ,@Twr_TwrID
           ,0
           ,-16
           ,0
           ,@GrupaTwrId
           ,0
           ,Twr_Kod
           ,Twr_Nazwa
           FROM CDN.Towary where Twr_TwrId = @Twr_TwrID
end
select  @Twr_TwrID
  SET NOCOUNT OFF
