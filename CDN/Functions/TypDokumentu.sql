CREATE FUNCTION CDN.TypDokumentu ( @TypDokumentu   INT )
  RETURNS    NVARCHAR(3)
 AS
  BEGIN
  -- zmienne pomocnicze
  DECLARE
    @TypStr      NVARCHAR(3)
  SET @TypStr =
    CASE
      WHEN @TypDokumentu = 301 THEN 'FZ'
      WHEN @TypDokumentu = 302 THEN 'FS'
      WHEN @TypDokumentu = 303 THEN 'PW'
      WHEN @TypDokumentu = 304 THEN 'RW'
      WHEN @TypDokumentu = 305 THEN 'PA'
      WHEN @TypDokumentu = 306 THEN 'WZ'
      WHEN @TypDokumentu = 307 THEN 'PZ'
      WHEN @TypDokumentu = 308 THEN 'RO'
      WHEN @TypDokumentu = 309 THEN 'ZD'
      WHEN @TypDokumentu = 310 THEN 'BOM'
      WHEN @TypDokumentu = 311 THEN 'AI'
      WHEN @TypDokumentu = 312 THEN 'MM'
      WHEN @TypDokumentu = 313 THEN 'PKA'
      WHEN @TypDokumentu = 314 THEN 'WKA'
      WHEN @TypDokumentu = 317 THEN 'PWP'
      WHEN @TypDokumentu = 318 THEN 'RWS'
      WHEN @TypDokumentu = 320 THEN 'FPF'
      WHEN @TypDokumentu = 321 THEN 'FWZ'
      WHEN @TypDokumentu = 322 THEN 'FWS'
      WHEN @TypDokumentu = 345 THEN 'TF'
      WHEN @TypDokumentu = 350 THEN 'FRR'
      WHEN @TypDokumentu = 700 THEN 'CRM'
      WHEN @TypDokumentu = 710 THEN 'ANK'
      WHEN @TypDokumentu = 714 THEN 'WZ-ANK'
      WHEN @TypDokumentu = 750 THEN 'OBD'
      WHEN @TypDokumentu = 752 THEN 'RPT'
      WHEN @TypDokumentu = 900 THEN 'SRW'
      ELSE ''
    END
  RETURN @TypStr
END
