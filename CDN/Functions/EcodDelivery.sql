-- funkcja zwraca oznaczenie kodowe stawki VAT dla systemu ECOD
CREATE FUNCTION CDN.EcodDelivery ( @mode INT, @faId INT )
RETURNS     nvarchar(35)
AS
BEGIN
 DECLARE @wynik nvarchar(35), @wzID INT
    SELECT TOP 1 @wzID = TrR_FaId  FROM CDN.TraNagRelacje WHERE TrR_TrNTyp=302 AND TrR_TrNId = @faId AND TrR_FaTyp = 306
 IF @wzID is NULL  RETURN N''
 IF @mode = 1   -- @DespatchNumber
  SELECT TOP 1 @wynik = TrN_NumerPelny FROM cdn.TraNag WHERE TrN_TrNId = @wzID
 IF @mode = 2   --@DeliveryDate
  SELECT TOP 1 @wynik = Convert(NVARCHAR(10), TrN_DataOpe, 120) FROM cdn.TraNag WHERE TrN_TrNId = @wzID
 IF @mode = 3   --@DeliveryLocationNumber
  SELECT TOP 1 @wynik = IsNull(Knt_GLN, '')
    FROM  cdn.TraNag  As wz
    JOIN  cdn.Kontrahenci On wz.TrN_OdbiorcaTyp=Knt_PodmiotTyp And wz.TrN_OdbId=Knt_KntId
    WHERE wz.TrN_TypDokumentu=306 And wz.TrN_TrNId = @wzID
 IF @mode = 4   --@OdbiorcaTyp
  SELECT TOP 1 @wynik = Str(IsNull(TrN_PodmiotTyp, 0)) FROM cdn.TraNag WHERE TrN_TrNId = @wzID
 IF @mode = 5   --@OdbiorcaId
  SELECT TOP 1 @wynik = Str(IsNull(TrN_PodId, 0)) FROM cdn.TraNag WHERE TrN_TrNId = @wzID
 IF @mode = 6   -- @DespatchDate
  SELECT TOP 1 @wynik = Convert(NVARCHAR(10), TrN_DataDok, 120)  FROM cdn.TraNag WHERE TrN_TrNId = @wzID
 IF @wynik IS NULL
 BEGIN
  SET @wynik = ''
 END
 RETURN RTRIM(@wynik)
END
