CREATE PROCEDURE CDN.ZmienDziennikKsiegowy
@DeNId    int,
@destDziId  int,
@AutoIdKsiegowy int,
@OperatorId  int,
@SprawdzajZakazy int
AS
 SET NOCOUNT ON
  if @SprawdzajZakazy <> 0
  begin
    declare @Dodawanie int = 1;
    declare @Podglad int = 2;
    declare @ZmianaWlasnych int = 3;
    declare @ZmianaCudzych int = 4;
    declare @UsuwanieWlasnych int = 5;
    declare @UsuwanieCudzych int = 6;
    declare @zakaz int = 0;
    select @zakaz = CDN.ZakazDoDziennika(@OperatorId, @destDziId, NULL, @Dodawanie);
    if @zakaz = 1
    begin
      SET NOCOUNT OFF
      exec CDN.RiseOptimaException 32477
      return
    end
    select @zakaz = CDN.ZakazDoDziennika(@OperatorId, NULL, @DeNId, @ZmianaWlasnych);
    if @zakaz = 1
    begin
      SET NOCOUNT OFF
      exec CDN.RiseOptimaException 32480
      return
    end
    select @zakaz = CDN.ZakazDoDziennika(@OperatorId, NULL, @DeNId, @ZmianaCudzych);
    if @zakaz = 1
    begin
      SET NOCOUNT OFF
      exec CDN.RiseOptimaException 32480
      return
    end
    select @zakaz = CDN.ZakazDoDziennika(@OperatorId, NULL, @DeNId, @UsuwanieWlasnych);
    if @zakaz = 1
    begin
      SET NOCOUNT OFF
      exec CDN.RiseOptimaException 32481
      return
    end
    select @zakaz = CDN.ZakazDoDziennika(@OperatorId, NULL, @DeNId, @UsuwanieCudzych);
    if @zakaz = 1
    begin
      SET NOCOUNT OFF
      exec CDN.RiseOptimaException 32481
      return
    end
  end
 if exists(select * from cdn.Dzienniki join cdn.dekretyNag on (Dzi_OObId = DeN_OObId) where DeN_DeNId = @DeNId and Dzi_DziId = @destDziId)
 begin
  declare @destDziSymbol varchar(20);
  declare @zmieniono int = 0;
  select @destDziSymbol = Dzi_Symbol from cdn.dzienniki where dzi_dziid = @destDziId
  if @AutoIdKsiegowy <> 0
  begin
   if exists (select * from cdn.DekretyNag where IsNull(DeN_WzorzecTyp, 0) in (0,22) and den_denid = @DeNId)
   begin
    update cdn.DekretyNag set
                      DeN_IdentKsieg='',
                      Den_DziId = @destDziId,
                      DeN_NrDziennika = 0,
                      DeN_Dziennik = @destDziSymbol
       --DeN_TS_MOD = GETDATE(),
       --DeN_TS_MODB = GETDATE(),
       --DeN_OpeModID=@OperatorId
    where den_denid = @DeNId;
    set @zmieniono = 1;
   end
   else
   begin
    update cdn.DekretyNag set
                      Den_DziId = @destDziId,
                      DeN_NrDziennika = 0,
                      DeN_Dziennik = @destDziSymbol
       --DeN_TS_MOD = GETDATE(),
       --DeN_TS_MODB = GETDATE(),
       --DeN_OpeModID=@OperatorId
    where den_denid = @DeNId;
    set @zmieniono = 1;
   end
  end
  else
  begin
   update cdn.DekretyNag set
                    Den_DziId = @destDziId,
                    DeN_NrDziennika = 0,
                    DeN_Dziennik = @destDziSymbol
     --DeN_TS_MOD = GETDATE(),
     --DeN_TS_MODB = GETDATE(),
     --DeN_OpeModID=@OperatorId
   where den_denid = @DeNId;
   set @zmieniono = 1;
  end
  if @zmieniono <> 0
  begin
   declare @numer nvarchar(255);
   declare @opisOperacji nvarchar(255);
   set @opisOperacji = 'Zmieniono dziennik księgowy na ['+@destDziSymbol+']';
   select @numer = DeN_Dokument from CDN.DekretyNag where den_denid = @DeNId;
   exec [CDN].[RejestrOperacjiDodaj] @ObiektTyp = 1006, @ObiektSubTyp = 0, @ObiektID = @DeNId, @ObiektNazwa = @numer, @OperacjaTyp = 2, @Opis=@opisOperacji;
  end
 end
 SET NOCOUNT OFF
