create procedure cdn.OAktualizujBank
@BankID int,
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
  update cdn.BnkNazwy
     set
      BNa_Akronim = @Akronim,
      BNa_Numer = @Numer,
      BNa_IBAN = @IBAN,
      BNa_Nazwa1 = @Nazwa1,
      BNa_Nazwa2 = @Nazwa2,
      BNa_Swift = @Swift,
      BNa_Miasto = @Miasto,
      BNa_KodPocztowy = @KodPocztowy,
      BNa_Ulica = @Ulica,
      BNa_Kraj = @Kraj,
      BNa_Wojewodztwo = @Wojewodztwo,
      BNa_Telefon = @Telefon,
      BNa_Fax = @Fax,
      BNa_OpeModId = @OpeId,
      BNa_OpeModKod = @OpeModKod,
      BNa_OpeModNazwisko = @OpeModNazwisko,
      BNa_TS_Mod = getdate()
     where
      BNa_BNaId = @BankID
 end try
    begin catch
        set @s = '##OPT32399##'
        raiserror(@s, 16, 1)
    end catch
end
