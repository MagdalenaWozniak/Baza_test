create procedure cdn.ODodajBank
@Akronim varchar(20),
@Numer nvarchar(10),
@IBAN tinyint,
@Nazwa1 nvarchar(50),
@Nazwa2 nvarchar(50),
@Swift nvarchar(20),
@Miasto nvarchar(40),
@KodPocztowy varchar(10),
@Ulica nvarchar(40),
@Kraj nvarchar(40),
@Wojewodztwo nvarchar(40),
@Telefon varchar(20),
@Fax varchar(20)
as
begin
 declare @s nvarchar(128)
if exists (select * from sysobjects where name = 'Synch2015 ' And xtype = 'p')
 begin
 declare @set int
 exec cdn.Synch2015 @pWynik = @set OUTPUT
 if @set = 1
  return
 end
else
 return
 begin try
 declare @OpeId int
 set @OpeId = cdn.GetXLOperatorID()
 declare @OpeModKod varchar(20), @OpeModNazwisko nvarchar(50)
 exec CDN.OpeKodNazwisko @OpeId, @OpeModKod OUT, @OpeModNazwisko OUT
 insert into cdn.BnkNazwy(
 BNa_PodmiotTyp, BNa_Akronim, BNa_KodPocztowy, BNa_Telefon, BNa_Fax, BNa_URL,
 BNa_Format, BNa_CzasRealizacji, BNa_IBAN, BNa_Zagraniczny, BNa_KatID, BNa_NieRozliczac,
 BNa_TS_Export, BNa_ImportAppId, BNa_ImportRowId, BNa_OpeZalId, BNa_OpeZalKod, BNa_OpeZalNazwisko, BNa_StaZalId, BNa_TS_Zal,
 BNa_OpeModId,BNa_OpeModKod, BNa_OpeModNazwisko, BNa_StaModId, BNa_TS_Mod, BNa_GIDTyp, BNa_GIDFirma, BNa_GIDNumer, BNa_GIDLp,
 BNa_FormatUS, BNa_FormatZUS, BNa_Adres2, BNa_Centrala, BNa_Email, BNa_Gmina, BNa_Kraj, BNa_Miasto,
 BNa_Modem, BNa_Nazwa1, BNa_Nazwa2, BNa_NrDomu, BNa_NrLokalu, BNa_Numer, BNa_Poczta, BNa_Powiat,
 BNa_PWD, BNa_Swift, BNa_UID, BNa_Ulica, BNa_Wojewodztwo, BNa_FormatImp, BNa_CDCKontaktOsoba,
 BNa_CDCKontakt, BNa_CDCOplatyPonosi, BNa_TelefonSms)
 values(
 2,@Akronim, @KodPocztowy,@Telefon,@Fax,'',0,0,@IBAN,0,NULL,0,NULL,NULL,NULL,@OpeId, @OpeModKod, @OpeModNazwisko,@OpeId, @OpeModKod, @OpeModNazwisko,getdate(),
 NULL,NULL,getdate(),NULL,NULL,NULL,NULL,0,0,'','','','',@Kraj,@Miasto,'',@Nazwa1,@Nazwa2,'','',@Numer,'','','',@Swift,
 '',@Ulica,@Wojewodztwo,NULL,NULL,NULL,NULL,'')
 end try
    begin catch
        set @s = '##OPT32400##'
        raiserror(@s, 16, 1)
    end catch
end
