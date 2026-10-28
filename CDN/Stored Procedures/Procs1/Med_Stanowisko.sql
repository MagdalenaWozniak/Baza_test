CREATE PROCEDURE [CDN].[Med_Stanowisko]
 @Nazwa NVARCHAR(50)  ,  -- nazwa stanowiska
 @GenerujWZ tinyint  ,  -- czy FA/PA ma generować WZ  0- nie 1- tak
 @TypNettoBrutto tinyint  , -- czy dokument od netto czy od brutto 0-
 @DDfIdFS int  ,-- id schematu numeracji w Optimie dla faktury
 @DDfIdFSKor int,-- id schematu numeracji w Optimie dla faktury korekcyjnej(jesli nie przesylane 0)
 @DDfIdPA int  ,-- id schematu numeracji w Optimie dla faktury
 @DDfIdPAKor int,-- id schematu numeracji w Optimie dla faktury korekcyjnej(jesli nie przesylane 0)
 @BRaId int  ,-- id rejestru do ktorego ma trafic zapis płatnosci (cdn.bnkraporty)
 @Seria NVARCHAR(5)  , -- seria
 @MagId int,   -- id magazynu na ktory ma byc wystawiony dokument (cdn.magazyny)
 @TwCNumer int, -- numer ceny ktora będzie wysyłana
 @KodGrupyKnt NVARCHAR(20)= '',
 @KodGrupyTwr NVARCHAR(50) ='',
 @NazwaGrupyTwr NVARCHAR(255) ='',
 @GrupaTwrId INT = 0
AS
BEGIN
SET NOCOUNT ON
if @KodGrupyKnt ! = ''
begin
if not exists(select * from cdn.Grupy where Gru_Nazwa = @KodGrupyKnt)
 INSERT INTO [CDN].[Grupy]
           ([Gru_Typ]
           ,[Gru_Nazwa]
           ,[Gru_Opis]
           ,[Gru_Flaga])
     VALUES
           (31
           ,@KodGrupyKnt
           ,''
           ,NULL)
end
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
update cdn.firma set fir_wartosc = 1 where fir_numer = 1885
insert into CDN.DetalStanowiska
           (DSta_Nazwa
           ,DSta_TwGGIDNumer
           ,DSta_DDfIdPA
           ,DSta_DDfIdFS
           ,DSta_DDfIdPAKor
           ,DSta_DDfIdFSKor
           ,DSta_DDfIdKP
           ,DSta_DDfIdKW
           ,DSta_Seria
           ,DSta_MagId
           ,DSta_TwCNumer
           ,DSta_Nieaktywne
           ,DSta_TS_Synchro
           ,DSta_TS_SynchroTwr
           ,DSta_TS_SynchroKnt
           ,DSta_TS_SynchroTraNag
           ,DSta_TS_SynchroZapisKB
           ,DSta_TS_SynchroImportKnt
           ,DSta_TS_SynchroOpak
           ,DSta_DDfIdPKA
           ,DSta_DDfIdMM
           ,DSta_DDfIdRO
           ,DSta_DDfIdCRM
           ,DSta_Opis
           ,DSta_MagIdZwrotny
           ,DSta_Typ
           ,DSta_TypNettoBrutto
           ,DSta_TS_SynchroTwrPotw
           ,DSta_TS_SynchroKntPotw
           ,DSta_TS_SynchroPotw
           ,DSta_BRaId
           ,DSta_TS_SynchroGrup
           ,DSta_TS_SynchroGrupPotw
           ,DSta_GenerujWZ
           ,DSta_KntGrupa)
select      @Nazwa
           ,@GrupaTwrId
           ,@DDfIdPA
           ,@DDfIdFS
           ,@DDfIdPAKor
           ,@DDfIdFSKor
           ,5
           ,4
           ,@Seria
           ,@MagId
           ,@TwCNumer
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,0
           ,''
           ,0
           ,3
           ,@TypNettoBrutto
           ,0
           ,0
           ,0
           ,@BRaId
           ,0
           ,0
           ,@GenerujWZ
           ,@KodGrupyKnt
           select Dsta_DStaId from CDN.DetalStanowiska where  DSta_Nazwa = @Nazwa
SET NOCOUNT OFF
END
