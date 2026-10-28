CREATE procedure CDN.epDelegacjeElementy_Insert
@DelegacjaId int,
@KatId int,
@Kategoria nvarchar(50),
@DataOd DateTime,
@DataDo DateTime,
@Kraj nvarchar(255),
@Waluta nvarchar(3),
@KursNumer int,
@KursL decimal(15,4),
@KursM decimal(5,0),
@KwotaSys decimal(15,2),
@KwotaWal decimal(15,2),
@FPlId int,
@TerminPlatnosci DateTime,
@GenerujPlatnoscKB smallint,
@IloscGodzinDelegacji DateTime,
@DietyIlosc decimal(15,2),
@DietyKwota decimal(15,2),
@RyczaltDojazdyIlosc int,
@RyczaltDojazdyKwota decimal(15,2),
@RyczaltNoclegiIlosc int,
@RyczaltNoclegiKwota decimal(15,2),
@RyczaltNoclegiAuto smallint,
@RyczaltDojazdyAuto smallint,
@NumerRejestracyjny varchar(20),
@TypPojazdu smallint,
@PojazdStawkaZaKilometr decimal(15,4),
@PojazdIloscKilometrow int,
@PojazdKoszt decimal(15,2),
@IloscSniadan int,
@IloscObiadow int,
@IloscKolacji int,
@RazemRyczaltDojazdy decimal(15,2),
@RazemRyczaltNoclegi decimal(15,2),
@RazemRyczaltDiety decimal(15,2),
@RazemInneWydatki decimal(15,2),
@RazemWydatki decimal(15,2),
@RazemZaliczka decimal(15,2),
@RazemWydatkiBilety decimal(15,2),
@RazemWydatkiNoclegi decimal(15,2),
@RazemWydatkiInne int,
@RazemWydatkiBiletyIlosc int,
@RazemWydatkiNoclegiIlosc int,
@RazemWydatkiInneIlosc int,
@Opis nvarchar(255)
As
 declare @sql nvarchar(2048)
 Set @sql =  'insert into CDN.DlgElem('
    + 'DLE_DLNId,'
    + 'DLE_KatId,'
    + 'DLE_Kategoria,'
    + 'DLE_Zrodlo,'
    + 'DLE_DataOd,'
    + 'DLE_DataDo,'
    + 'DLE_Kraj,'
    + 'DLE_Waluta,'
    + 'DLE_KsiWaluta,'
    + 'DLE_KursNumer,'
    + 'DLE_KsiKursNumer,'
    + 'DLE_KursL,'
    + 'DLE_KsiKursL,'
    + 'DLE_KursM,'
    + 'DLE_KsiKursM,'
    + 'DLE_KwotaSys,'
    + 'DLE_KwotaWal,'
    + 'DLE_FPlId,'
    + 'DLE_TerminPlatnosci,'
    + 'DLE_GenerujPlatnoscKB,'
    + 'DLE_GenerujZapisKB,'
    + 'DLE_ZapisKbBRaAkronim,'
    + 'DLE_IloscGodzinDelegacji,'
    + 'DLE_DietyIlosc,'
    + 'DLE_DietyKwota,'
    + 'DLE_RyczaltDojazdyIlosc,'
    + 'DLE_RyczaltDojazdyKwota,'
    + 'DLE_RyczaltNoclegiIlosc,'
    + 'DLE_RyczaltNoclegiKwota,'
    + 'DLE_RyczaltNoclegiAuto,'
    + 'DLE_RyczaltDojazdyAuto,'
    + 'DLE_NumerRejestracyjny,'
    + 'DLE_TypPojazdu,'
    + 'DLE_PojazdStawkaZaKilometr,'
    + 'DLE_PojazdIloscKilometrow,'
    + 'DLE_PojazdKoszt,'
    + 'DLE_IloscSniadan,'
    + 'DLE_IloscObiadow,'
    + 'DLE_IloscKolacji,'
    + 'DLE_RazemRyczaltDojazdy,'
    + 'DLE_RazemRyczaltNoclegi,'
    + 'DLE_RazemRyczaltDiety,'
    + 'DLE_RazemInneWydatki,'
    + 'DLE_RazemWydatki,'
    + 'DLE_RazemZaliczka,'
    + 'DLE_RazemWydatkiBilety,'
    + 'DLE_RazemWydatkiNoclegi,'
    + 'DLE_RazemWydatkiInne,'
    + 'DLE_RazemWydatkiBiletyIlosc,'
    + 'DLE_RazemWydatkiNoclegiIlosc,'
    + 'DLE_RazemWydatkiInneIlosc,'
    + 'DLE_Opis'
    + ')'
    + ' values('
    + convert(nvarchar, @DelegacjaId) + ','
        + ISNULL(convert(nvarchar, @KatId), 'NULL') + ','
        + '''' + ISNULL(@Kategoria, '') + ''','
    + '10'  + ','
    + CDN.Date2String(@DataOd, 120, 0) + ',' -- +   '''' + convert(nvarchar, @DataOd, 120) + ''','
    + CDN.Date2String(@DataDo, 120, 0) + ',' -- +   '''' + convert(nvarchar, @DataDo, 120) + ''','
    + '''' + @Kraj + ''','
    + '''' + @Waluta + ''','
    + '''' + @Waluta + ''','
    + convert(nvarchar, @KursNumer) + ','
    + convert(nvarchar, @KursNumer) + ','
    + convert(nvarchar, @KursL) + ','
    + convert(nvarchar, @KursL) + ','
    + convert(nvarchar, @KursM) + ','
    + convert(nvarchar, @KursM) + ','
    + convert(nvarchar, @KwotaSys) + ','
    + convert(nvarchar, @KwotaWal) + ','
    + convert(nvarchar, @FPlId) + ','
    + CDN.Date2String(@TerminPlatnosci, 120, 0) + ',' -- +   '''' + convert(nvarchar, @TerminPlatnosci, 120) + ''','
    + convert(nvarchar, @GenerujPlatnoscKB) + ','
    + convert(nvarchar, @GenerujPlatnoscKB) + ','
    + '''-domyślna-'','
    + CDN.Date2String(@IloscGodzinDelegacji, 120, 0) + ',' -- +   '''' + convert(nvarchar, @IloscGodzinDelegacji, 108) + ''','
    + convert(nvarchar, @DietyIlosc) + ','
    + convert(nvarchar, @DietyKwota) + ','
    + convert(nvarchar, @RyczaltDojazdyIlosc) + ','
    + convert(nvarchar, @RyczaltDojazdyKwota) + ','
    + convert(nvarchar, @RyczaltNoclegiIlosc) + ','
    + convert(nvarchar, @RyczaltNoclegiKwota) + ','
    + convert(nvarchar, @RyczaltNoclegiAuto) + ','
    + convert(nvarchar, @RyczaltDojazdyAuto) + ','
    + '''' + @NumerRejestracyjny + ''','
    + convert(nvarchar, @TypPojazdu) + ','
    + convert(nvarchar, @PojazdStawkaZaKilometr) + ','
    + convert(nvarchar, @PojazdIloscKilometrow) + ','
    + convert(nvarchar, @PojazdKoszt) + ','
    + convert(nvarchar, @IloscSniadan) + ','
    + convert(nvarchar, @IloscObiadow) + ','
    + convert(nvarchar, @IloscKolacji) + ','
    + convert(nvarchar, @RazemRyczaltDojazdy) + ','
    + convert(nvarchar, @RazemRyczaltNoclegi) + ','
    + convert(nvarchar, @RazemRyczaltDiety) + ','
    + convert(nvarchar, @RazemInneWydatki) + ','
    + convert(nvarchar, @RazemWydatki) + ','
    + convert(nvarchar, @RazemZaliczka) + ','
    + convert(nvarchar, @RazemWydatkiBilety) + ','
    + convert(nvarchar, @RazemWydatkiNoclegi) + ','
    + convert(nvarchar, @RazemWydatkiInne) + ','
    + convert(nvarchar, @RazemWydatkiBiletyIlosc) + ','
    + convert(nvarchar, @RazemWydatkiNoclegiIlosc) + ','
    + convert(nvarchar, @RazemWydatkiInneIlosc) + ','
    + '''' + @Opis + ''''
    + ')'
 Execute dbo.sp_executesql @sql
