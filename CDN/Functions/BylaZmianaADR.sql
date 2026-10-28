create function cdn.BylaZmianaADR(@PreId int, @prevPreId int)
returns int
as
begin
 declare @BylaZmiana int
 set @BylaZmiana = 0
 if (
  select 1 from cdn.PracEtaty A join cdn.PracEtaty B on B.PRE_PreId = @prevPreId
   where
   (
    (A.PRE_PreId = @PreId and A.PRE_PreId = @prevPreId)
    or
    (
     A.PRE_PreId = @PreId and A.PRE_PreId > @prevPreId
     and
     (
     A.PRE_MLDUlica <> B.PRE_MLDUlica
     or A.PRE_MLDNrDomu <> B.PRE_MLDNrDomu
     or A.PRE_MLDNrLokalu <> B.PRE_MLDNrLokalu
     or A.PRE_MLDKodPocztowy <> B.PRE_MLDKodPocztowy
     or A.PRE_MLDMiasto <> B.PRE_MLDMiasto
     or A.PRE_MLDKraj <> B.PRE_MLDKraj
     or A.PRE_MLDPoczta <> B.PRE_MLDPoczta
     or A.PRE_MLDGmina <> B.PRE_MLDGmina
     or A.PRE_MLDPowiat <> B.PRE_MLDPowiat
     )
    )
   )
   and
   (
    isnull(A.PRE_MLDUlica, '') <> ''
    or isnull(A.PRE_MLDNrDomu, '') <> ''
    or isnull(A.PRE_MLDNrLokalu, '') <> ''
    or isnull(A.PRE_MLDKodPocztowy, '') <> ''
    or isnull(A.PRE_MLDMiasto, '') <> ''
    --or isnull(A.PRE_MLDKraj, '') <> ''
    or isnull(A.PRE_MLDPoczta, '') <> ''
    or isnull(A.PRE_MLDPowiat, '') <> ''
    or isnull(A.PRE_MLDGmina, '') <> ''
   )
   )
   > 0
   set @BylaZmiana = 1
 if (
  select 1 from cdn.PracEtaty A join cdn.PracEtaty B on B.PRE_PreId = @prevPreId
   where
   (
    (A.PRE_PreId = @PreId and A.PRE_PreId = @prevPreId)
    or
    (
     A.PRE_PreId = @PreId and A.PRE_PreId > @prevPreId
     and
     (
     A.PRE_KORUlica <> B.PRE_KORUlica
     or A.PRE_KORNrDomu <> B.PRE_KORNrDomu
     or A.PRE_KORNrLokalu <> B.PRE_KORNrLokalu
     or A.PRE_KORKodPocztowy <> B.PRE_KORKodPocztowy
     or A.PRE_KORMiasto <> B.PRE_KORMiasto
     or A.PRE_KORKraj <> B.PRE_KORKraj
     or A.PRE_KORPoczta <> B.PRE_KORPoczta
     or A.PRE_KORGmina <> B.PRE_KORGmina
     or A.PRE_KORPowiat <> B.PRE_KORPowiat
     )
    )
   )
   and
   (
    isnull(A.PRE_KORUlica, '') <> ''
    or isnull(A.PRE_KORNrDomu, '') <> ''
    or isnull(A.PRE_KORNrLokalu, '') <> ''
    or isnull(A.PRE_KORKodPocztowy, '') <> ''
    or isnull(A.PRE_KORMiasto, '') <> ''
    --or isnull(A.PRE_KORKraj, '') <> ''
    or isnull(A.PRE_KORPoczta, '') <> ''
    or isnull(A.PRE_KORPowiat, '') <> ''
    or isnull(A.PRE_KORGmina, '') <> ''
   )
   )
   > 0
   set @BylaZmiana = 1
 if (
  select 1 from cdn.PracEtaty A join cdn.PracEtaty B on B.PRE_PreId = @prevPreId
   where (
    (A.PRE_PreId = @PreId and A.PRE_PreId = @prevPreId)
    or
    (
     A.PRE_PreId = @PreId and A.PRE_PreId > @prevPreId
     and
     (
     A.PRE_ZAMUlica <> B.PRE_ZAMUlica
     or A.PRE_ZAMNrDomu <> B.PRE_ZAMNrDomu
     or A.PRE_ZAMNrLokalu <> B.PRE_ZAMNrLokalu
     or A.PRE_ZAMKodPocztowy <> B.PRE_ZAMKodPocztowy
     or A.PRE_ZAMMiasto <> B.PRE_ZAMMiasto
     or A.PRE_ZAMKraj <> B.PRE_ZAMKraj
     or A.PRE_ZAMPoczta <> B.PRE_ZAMPoczta
     or A.PRE_ZAMGmina <> B.PRE_ZAMGmina
     or A.PRE_ZAMPowiat <> B.PRE_ZAMPowiat
     )
    )
   )
   and
   (
    isnull(A.PRE_ZAMUlica, '') <> ''
    or isnull(A.PRE_ZAMNrDomu, '') <> ''
    or isnull(A.PRE_ZAMNrLokalu, '') <> ''
    or isnull(A.PRE_ZAMKodPocztowy, '') <> ''
    or isnull(A.PRE_ZAMMiasto, '') <> ''
    --or isnull(A.PRE_ZAMKraj, '') <> ''
    or isnull(A.PRE_ZAMPoczta, '') <> ''
    or isnull(A.PRE_ZAMPowiat, '') <> ''
    or isnull(A.PRE_ZAMGmina, '') <> ''
   )
   )
   > 0
   set @BylaZmiana = 1
 return @BylaZmiana
end
