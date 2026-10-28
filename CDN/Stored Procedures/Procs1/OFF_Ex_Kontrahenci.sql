CREATE PROCEDURE CDN.OFF_Ex_Kontrahenci
  AS
DECLARE
 @DataOstatniejSynchroChr nvarchar(20),
 @DataOstatniejSynchro datetime
 SELECT @DataOstatniejSynchroChr=fir_wartosc FROM Cdn.Firma WHERE Fir_Numer = 1744
 if @DataOstatniejSynchroChr = '0' select @DataOstatniejSynchro = getdate()
 else
 select @DataOstatniejSynchro = CONVERT(DATETIME,@DataOstatniejSynchroChr,102)
   SELECT Knt_Kod,
          Knt_GidTyp,
          (CASE WHEN Knt_GidTyp < 1 OR Knt_GidTyp is NULL THEN NULL ELSE Knt_GidNumer END) as Knt_GidNumer,
          ISNULL(Knt_GidLp,0) as Knt_GidLp,
          Knt_KntId,
          Knt_Ts_Mod,
          Knt_Kod,
          Knt_Nazwa1,
          Knt_Nazwa2,
          Knt_Nazwa3,
          Knt_Ulica,
          Knt_Miasto,
          Knt_Wojewodztwo,
          Knt_KodPocztowy,
          Knt_Nipe,
          Knt_NIPKraj,
          Knt_Regon,
          Knt_Pesel,
          Knt_Adres2,
          Knt_Telefon1,
          Knt_Telefon2,
          Knt_Fax,
          Knt_Url,
          Knt_EMail,
          knt_Nieaktywny,
          ISNULL(Rab_Rabat,0.00) as Rab_Rabat,
          Knt_EAN,
          Knt_GLN,
          Knt_PodatekVat,
          Fpl_XlId,
          (CASE WHEN Knt_Ceny = 0  THEN 0 ELSE Knt_Ceny-1 END) as Knt_Ceny,
          Knt_Limitkredytuwal,
          Knt_Limitkredytu,
          Knt_Limitkredytuwykorzystany,
          (CASE WHEN Knt_Rodzaj_Dostawca=1 and Knt_Rodzaj_Odbiorca=1  THEN 24
                ELSE (CASE WHEN Knt_Rodzaj_Dostawca=1 and Knt_Rodzaj_Odbiorca=0  THEN 8
                           ELSE (CASE WHEN Knt_Rodzaj_Dostawca=0 and Knt_Rodzaj_Odbiorca=0 THEN 0
                                 ELSE 16
                           END)
                END)
          END) as Knt_Rodzaj,
          Knt_Termin,
          Knt_NaliczajPlatnosc,
          Knt_TerminZwrotuKaucji,
          Knt_Finalny+1 as Knt_Finalny,
          knt_OpeZalid,
          knt_OpeModid from cdn.kontrahenci
   left join cdn.rabaty on rab_podmiotid = Knt_KntId and rab_typ =2
   left join cdn.formyplatnosci on Fpl_FplId = Knt_FplId
   where Knt_KntId != 1 and Knt_KntId != 2 and
        (knt_GidTyp is NULL or knt_GidTyp =0 or knt_ts_export is NULL or knt_ts_Mod > @DataOstatniejSynchro)
