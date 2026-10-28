CREATE FUNCTION CDN.UstalRodzajDokumentu (@TrNTypDokumentu INT, @TrNRodzaj INT, @TrNKorekta INT)
RETURNS INT
AS
BEGIN
  DECLARE @Rodzaj       INT
          SET @Rodzaj =
            CASE
              WHEN @TrNRodzaj=306010                      THEN 306010     --wzpf nie można zmieniać rodzaju
              WHEN @TrNRodzaj=308011                      THEN 308011
              WHEN @TrNTypDokumentu=301 AND @TrNKorekta=0 THEN 301000     --fz
              WHEN @TrNTypDokumentu=301 AND @TrNKorekta=1 THEN 301001     --fzki
              WHEN @TrNTypDokumentu=301 AND @TrNKorekta=2 THEN 301002     --fzkw
     WHEN @TrNTypDokumentu=301 AND @TrNKorekta=3 THEN 301003     --fzkv
              WHEN @TrNTypDokumentu=302 AND @TrNKorekta=0 AND @TrNRodzaj=302200 THEN 302200     --fa zaliczkowa bez zmiany rodzaju
              WHEN @TrNTypDokumentu=302 AND @TrNKorekta=0 THEN 302000     --fs
              WHEN @TrNTypDokumentu=302 AND @TrNKorekta=1 THEN 302001     --fski
              WHEN @TrNTypDokumentu=302 AND @TrNKorekta=2 AND @TrNRodzaj=302202 THEN 302202     --fa zaliczkowa bez zmiany rodzaju
              WHEN @TrNTypDokumentu=302 AND @TrNKorekta=2 THEN 302002     --fski
     WHEN @TrNTypDokumentu=302 AND @TrNKorekta=3 THEN 302003     --fskv
              WHEN @TrNTypDokumentu=305 AND @TrNKorekta=0 THEN 305000     --pa
              WHEN @TrNTypDokumentu=305 AND @TrNKorekta=1 THEN 305001     --paki
              WHEN @TrNTypDokumentu=306 AND @TrNKorekta=0 THEN 306000     --wz
              WHEN @TrNTypDokumentu=306 AND @TrNKorekta=1 THEN 306001     --wzki
              WHEN @TrNTypDokumentu=306 AND @TrNKorekta=2 THEN 306002     --wzki
              WHEN @TrNTypDokumentu=307 AND @TrNKorekta=0 THEN 307000     --pz
              WHEN @TrNTypDokumentu=307 AND @TrNKorekta=1 THEN 307001     --pzki
              WHEN @TrNTypDokumentu=307 AND @TrNKorekta=2 THEN 307002     --pzkw
     WHEN @TrNTypDokumentu=307 AND @TrNKorekta=3 THEN 307003     --pzkv
     WHEN @TrNTypDokumentu=307 AND @TrNKorekta=8 THEN 307002     --pzkw
              WHEN @TrNTypDokumentu=305                   THEN 305000     --pa
              WHEN @TrNTypDokumentu=313 AND @TrNKorekta=0 THEN 313000     --pka
              WHEN @TrNTypDokumentu=313 AND @TrNKorekta=1 THEN 313001     --pkaki
              WHEN @TrNTypDokumentu=313 AND @TrNKorekta=2 THEN 313002     --pkakw
              WHEN @TrNTypDokumentu=314 AND @TrNKorekta=0 THEN 314000     --wka
              WHEN @TrNTypDokumentu=314 AND @TrNKorekta=1 THEN 314001     --wkaki
              WHEN @TrNTypDokumentu=314 AND @TrNKorekta=2 THEN 314002     --wkakw
              WHEN @TrNTypDokumentu=308                   THEN 308000     --ro
              WHEN @TrNTypDokumentu=309                   THEN 309000     --zd
              WHEN @TrNTypDokumentu=321                   THEN 321000     --FWZ
              WHEN @TrNTypDokumentu=322                   THEN 322021     --FWS
              WHEN @TrNTypDokumentu=350                   THEN 350000     --FRR
              WHEN @TrNRodzaj=301050                      THEN 301000     --FZ z FRR
              WHEN @TrNRodzaj=301090                      THEN 301000     --FZ z PKA
              WHEN @TrNRodzaj=302090                      THEN 302000     --FA z WKA
              WHEN @TrNRodzaj=302200                      THEN 302200     -- fa zal bez zmiany rodzaju
              WHEN @TrNRodzaj=302202                      THEN 302202     -- fa zal bez zmiany rodzaju
              WHEN @TrNRodzaj=305009                      THEN 305000
              WHEN @TrNRodzaj=306004                      THEN 306000
              WHEN @TrNRodzaj=306005                      THEN 306001
              WHEN @TrNRodzaj=306009                      THEN 306002
     WHEN @TrNRodzaj=306011                      THEN 306003
              WHEN @TrNRodzaj=307004                      THEN 307000
              WHEN @TrNRodzaj=307005                      THEN 307001
              WHEN @TrNRodzaj=307009                      THEN 307002
     WHEN @TrNRodzaj=307011                      THEN 307003
              WHEN @TrNRodzaj=308008                      THEN 308000     --ropa
              WHEN @TrNRodzaj=308009                      THEN 308000
              WHEN @TrNRodzaj=308010                      THEN 308000
              WHEN @TrNRodzaj=309000                      THEN 309000
              WHEN @TrNRodzaj=309008                      THEN 309000
              WHEN @TrNRodzaj=309009                      THEN 309000
              WHEN @TrNRodzaj=313004                      THEN 313000
              WHEN @TrNRodzaj=314004                      THEN 314000
              WHEN @TrNRodzaj=320008                      THEN 320000
              WHEN @TrNRodzaj=320009                      THEN 320009     --pfro
              WHEN @TrNRodzaj=320000                      THEN 320000     --pf
              WHEN @TrNRodzaj=350008                      THEN 350000
     WHEN @TrNRodzaj=304008                      THEN 304000
              ELSE @TrNRodzaj
            END
  RETURN @Rodzaj
END
