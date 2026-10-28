CREATE FUNCTION CDN.SrsZlecenieStatus ( @SrsZlecenieId Int )
  RETURNS    NVARCHAR(30)
  AS
BEGIN
  DECLARE @wynik NVARCHAR(30), @autoItem INT
  SET @autoItem = 255
  SET @wynik = ''
  IF @SrsZlecenieId = 0
  BEGIN
 GOTO KONIEC
  END
  DECLARE @fa NVARCHAR(3), @wz NVARCHAR(3), @pa NVARCHAR(3), @rw NVARCHAR(3), @mm NVARCHAR(3), @zd NVARCHAR(3)
  SELECT @fa = 'FS ' FROM  cdn.DokRelacje WHERE DoR_ParentTyp = 900 AND DoR_ParentId = @SrsZlecenieId AND DoR_DokumentTyp = 302 AND DoR_Flaga = @autoItem
  SELECT @rw = 'RW ' FROM  cdn.DokRelacje WHERE DoR_ParentTyp = 900 AND DoR_ParentId = @SrsZlecenieId AND DoR_DokumentTyp = 304 AND DoR_Flaga = @autoItem
  SELECT @pa = 'PA ' FROM  cdn.DokRelacje WHERE DoR_ParentTyp = 900 AND DoR_ParentId = @SrsZlecenieId AND DoR_DokumentTyp = 305 AND DoR_Flaga = @autoItem
  SELECT @wz = 'WZ ' FROM  cdn.DokRelacje WHERE DoR_ParentTyp = 900 AND DoR_ParentId = @SrsZlecenieId AND DoR_DokumentTyp = 306 AND DoR_Flaga = @autoItem
  SELECT @mm = 'ZD ' FROM  cdn.DokRelacje WHERE DoR_ParentTyp = 900 AND DoR_ParentId = @SrsZlecenieId AND DoR_DokumentTyp = 309 AND DoR_Flaga = @autoItem
  SELECT @zd = 'MM ' FROM  cdn.DokRelacje WHERE DoR_ParentTyp = 900 AND DoR_ParentId = @SrsZlecenieId AND DoR_DokumentTyp = 312 AND DoR_Flaga = @autoItem
  SET @wynik = IsNull(@fa,'') + IsNull(@pa,'') + IsNull(@wz,'') + IsNull(@rw,'') + IsNull(@mm,'') + IsNull(@zd,'')
KONIEC:
  RETURN  LTRIM(@wynik)
END
