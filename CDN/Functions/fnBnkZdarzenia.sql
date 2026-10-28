Create Function CDN.fnBnkZdarzenia (@DokumentTyp SmallInt, @DokumentId Int)
Returns Table
As
 Return
 Select BZd_BZdId
   From CDN.BnkZdarzenia
   Where BZd_DokumentTyp = @DokumentTyp And BZd_DokumentId = @DokumentId
 Union
 Select BZd_BZdId
   From CDN.BnkZdarzenia
   Join CDN.TraNag On BZd_DokumentTyp = 1 And BZd_DokumentId = TrN_TrNId
   Where @DokumentTyp = 2 And TrN_VaNId = @DokumentId
 Union
 Select BZd_BZdId
   From CDN.BnkZdarzenia
   Join CDN.TraNag On BZd_DokumentTyp = 1 And BZd_DokumentId = TrN_TrNId
   JOIN cdn.TraNagRelacje on TrN_TrNId = TrR_TrNId
   Where @DokumentTyp = 1 And TrR_FaId = @DokumentId
