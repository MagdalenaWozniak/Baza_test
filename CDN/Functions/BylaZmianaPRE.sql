create function cdn.BylaZmianaPRE(@PreId int, @prevPreId int)
returns int
as
begin
 declare @BylaZmiana int
 select top 1 @BylaZmiana =
  isnull((select A.PRE_PreId from cdn.PracEtaty A join cdn.PracEtaty B on B.PRE_PreId = @prevPreId
   where (A.PRE_PreId = @PreId and A.PRE_PreId = @prevPreId)
   or
   (
    A.PRE_PreId = @PreId and A.PRE_PreId > @prevPreId
    and
    (
     A.PRE_Imie1 <> B.PRE_Imie1
     or A.PRE_Nazwisko <> B.PRE_Nazwisko
     or A.PRE_Imie2 <> B.PRE_Imie2
     or A.PRE_NipE <> B.PRE_NipE
     or A.PRE_Pesel <> B.PRE_Pesel
     or A.PRE_DataUr <> B.PRE_DataUr
     or A.PRE_MiejsceUr <> B.PRE_MiejsceUr
     or A.PRE_ImieOjca <> B.PRE_ImieOjca
     or A.PRE_ImieMatki <> B.PRE_ImieMatki
     or A.PRE_NazwRodowe <> B.PRE_NazwRodowe
     or A.PRE_NazwRodoweM <> B.PRE_NazwRodoweM
     or A.PRE_DowOsobisty <> B.PRE_DowOsobisty
     or A.PRE_Paszport <> B.PRE_Paszport
     or A.PRE_Obywatelstwo <> B.PRE_Obywatelstwo
     or A.PRE_StanCywilny <> B.PRE_StanCywilny
    )
   )), 0)
 return @BylaZmiana
end
