CREATE PROCEDURE cdn.CzyscCdnFirmaDanePieczatki
AS
BEGIN
 EXEC cdn.CzyscWpisCdnFirma 1167
 EXEC cdn.CzyscWpisCdnFirma 1101
 EXEC cdn.CzyscWpisCdnFirma 1118
 EXEC cdn.CzyscWpisCdnFirma 1156
 EXEC cdn.CzyscWpisCdnFirma 1157
 EXEC cdn.CzyscWpisCdnFirma 2166
 EXEC cdn.CzyscWpisCdnFirma 1145
 EXEC cdn.CzyscWpisCdnFirma 1169
 EXEC cdn.CzyscWpisCdnFirma 1146
 EXEC cdn.CzyscWpisCdnFirma 1147
 EXEC cdn.CzyscWpisCdnFirma 1148
 EXEC cdn.CzyscWpisCdnFirma 1168
 EXEC cdn.CzyscWpisCdnFirma 1152
 EXEC cdn.CzyscWpisCdnFirma 1149
 EXEC cdn.CzyscWpisCdnFirma 1150
 EXEC cdn.CzyscWpisCdnFirma 1151
 EXEC cdn.CzyscWpisCdnFirma 1153
 EXEC cdn.CzyscWpisCdnFirma 1154
 EXEC cdn.CzyscWpisCdnFirma 1155
 EXEC cdn.CzyscWpisCdnFirma 2221
 EXEC cdn.CzyscWpisCdnFirma 3087
 EXEC cdn.CzyscWpisCdnFirma 1171
 EXEC cdn.CzyscWpisCdnFirma 1172
 EXEC cdn.CzyscWpisCdnFirma 1173
 EXEC cdn.CzyscWpisCdnFirma 1174
 EXEC cdn.CzyscWpisCdnFirma 1158
 EXEC cdn.CzyscWpisCdnFirma 1165
 EXEC cdn.CzyscWpisCdnFirma 1166
 EXEC cdn.CzyscWpisCdnFirma 3080
 EXEC cdn.CzyscWpisCdnFirma 1881
 IF (SELECT Fir_Wartosc FROM cdn.Firma WHERE Fir_Numer = 3126) = 1
 BEGIN
  EXEC cdn.CzyscWpisCdnFirma 3127
  EXEC cdn.CzyscWpisCdnFirma 3128
  EXEC cdn.CzyscWpisCdnFirma 3129
  EXEC cdn.CzyscWpisCdnFirma 3130
  EXEC cdn.CzyscWpisCdnFirma 3131
  EXEC cdn.CzyscWpisCdnFirma 3132
  EXEC cdn.CzyscWpisCdnFirma 3133
  EXEC cdn.CzyscWpisCdnFirma 3134
  EXEC cdn.CzyscWpisCdnFirma 3135
  EXEC cdn.CzyscWpisCdnFirma 3136
 END
END
