CREATE PROCEDURE cdn.PobierzKntWeryfStatHist(@KntID INT)
AS
  BEGIN
 SELECT KWSH_TypWeryfikacji, KWSH_Data, KWSH_Nip, KWSH_Status,
               DAB_Wartosc =
                 (SELECT CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("bin")))', 'NVARCHAR(MAX)') Base64Encoding
                    FROM (SELECT CAST((select B.DAB_Wartosc from CDN.DaneBinarne B where B.DAB_DABID = A.DAB_DABID) AS VARBINARY(MAX)) AS bin) AS myBase64Content
                 )
        FROM CDN.KntWeryfStatHist LEFT OUTER JOIN cdn.DaneBinarne A ON A.DaB_Typ = 11 AND A.DaB_TwAID = KWSH_KWSHID WHERE KWSH_KntID = @KntID
END
