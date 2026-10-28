CREATE FUNCTION CDN.ZakazDoDziennika(@OpeID int, @DziId int, @DeNId int, @ZakazTyp int)
-- @ZakazTyp = {1,2,3,4,5,6}
-- 1 - Dodawanie
-- 2 - Podglad
-- 3 - Zmiana Wlasnych
-- 4 - Zmiana Cudzych
-- 5 - Usuwanie Własnych
-- 6 - Usuwanie Cudzych
RETURNS INT
AS
BEGIN
 declare @Dodawanie int = 1;
 declare @Podglad int = 2;
 declare @ZmianaWlasnych int = 3;
 declare @ZmianaCudzych int = 4;
 declare @UsuwanieWlasnych int = 5;
 declare @UsuwanieCudzych int = 6;
 declare @Result int = 0;
 if IsNull(@DeNId, 0) <> 0
 begin
  declare @ownerOpeID int;
  select @DziId = DeN_DziId, @ownerOpeID = DeN_OpeZalID from cdn.DekretyNag where DeN_DeNID = @DeNId
  if @ZakazTyp = @Dodawanie
   select @Result = DzZ_Dodawanie from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
  else if @ZakazTyp = @Podglad
   select @Result = DzZ_Podglad from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
  else if @ZakazTyp = @ZmianaWlasnych and @OpeID = @ownerOpeID
   select @Result = DzZ_ZmianaWlas from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
  else if @ZakazTyp = @ZmianaCudzych and @OpeID <> @ownerOpeID
   select @Result = DzZ_ZmianaInne from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
  else if @ZakazTyp = @UsuwanieWlasnych and @OpeID = @ownerOpeID
   select @Result = DzZ_KasowanieWlas from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
  else if @ZakazTyp = @UsuwanieCudzych and @OpeID <> @ownerOpeID
   select @Result = DzZ_KasowanieInne from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
 end
 else
 begin
  if @ZakazTyp = @Dodawanie
   select @Result = DzZ_Dodawanie from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
  else if @ZakazTyp = @Podglad
   select @Result = DzZ_Podglad from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
  else if @ZakazTyp = @ZmianaWlasnych
   select @Result = DzZ_ZmianaWlas from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
  else if @ZakazTyp = @ZmianaCudzych
   select @Result = DzZ_ZmianaInne from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
  else if @ZakazTyp = @UsuwanieWlasnych
   select @Result = DzZ_KasowanieWlas from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
  else if @ZakazTyp = @UsuwanieCudzych
   select @Result = DzZ_KasowanieInne from cdn.DziennikZakazy where DzZ_OpeId = @OpeID and DzZ_DziId = @DziId
 end
 return @Result
END
