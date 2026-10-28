CREATE PROCEDURE CDN.OFF_SprawdzDokDoAnulowania
@TrN_TrNId    INT
  AS
  SET NOCOUNT ON
    DECLARE
    @FAzPA        INT,
    @FAzWZ        INT,
    @FZzPZ        INT,
    @Eksport      DATETIME,
    @Seria        nvarchar(5)
 SELECT @FAzPA=1 FROM CDN.TraNagRelacje N
       WHERE TrR_FATyp=305
       And N.TrR_TrNId =@TrN_TrNId
 --WiNi
 SELECT @FAzWZ=1 FROM CDN.TraNag N
       JOIN CDN.TraNagRelacje  ON N.TrN_TrNId = TrR_TrNId
       WHERE   N.TrN_TypDokumentu=306
    And TrR_FaId=@TrN_TrNId
    And N.TrN_ZwrId Is  Null
    And N.TrN_OFFExportMag=1
 SELECT @FZzPZ=1 FROM CDN.TraNag N
       JOIN CDN.TraNagRelacje  ON N.TrN_TrNId = TrR_TrNId
       WHERE   N.TrN_TypDokumentu=307
    And TrR_FaId=@TrN_TrNId
    And N.TrN_ZwrId Is  Null
    And N.TrN_OFFExportMag=1
 SET NOCOUNT OFF
 SELECT   @FAzPA as FAzPA , @FAzWZ as FAzWZ, @FZzPZ as FZzPZ
