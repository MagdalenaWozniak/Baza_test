CREATE procedure CDN.AktualizujOpisAnalitycznyNaTowarach
@Id int = NULL,
@Guid nvarchar(255) = NULL
As
 declare @dokumentTypGrupuTowarowe int = 0;
 select @dokumentTypGrupuTowarowe = ID from CDN.ListaDokumentowWymiarowanych() where nazwa = 'Grupy towarowe';
 declare @dokumentTypTowary int = 0;
 select @dokumentTypTowary = ID from CDN.ListaDokumentowWymiarowanych() where nazwa = 'Towary';
 declare @gid int = 0;
 SELECT @gid = TwG_GIDNumer from CDN.TwrGrupy where TwG_GIDTyp = -16 and TwG_TwGId = @Id;
 WITH Slownik AS (
  SELECT TwG_GIDNumer as ID, TwG_TwGId from CDN.TwrGrupy where TwG_GIDTyp = -16 and TwG_GIDNumer = @gid
  UNION ALL
  SELECT A.TwG_GIDNumer as ID, A.TwG_TwGId from CDN.TwrGrupy A join Slownik on (Slownik.ID= A.TwG_GrONumer) where A.TwG_GIDTyp = -16
 )
 delete from CDN.WymiaryWartosci where WyW_DokumentTyp = @dokumentTypTowary and WyW_DokumentId in
 (
  --select TwG_TwGId from Slownik where ID <> @Id
  select distinct T.TwG_GIDNumer as TwRId from CDN.TwrGrupy T join Slownik G on (T.TwG_GrONumer = G.ID)
  where T.TwG_GIDTyp = 16
 );
 WITH SlownikB AS (
  SELECT TwG_GIDNumer as ID,TwG_TwGId from CDN.TwrGrupy where TwG_GIDTyp = -16 and TwG_GIDNumer = @gid
  UNION ALL
  SELECT A.TwG_GIDNumer as ID, A.TwG_TwGId from CDN.TwrGrupy A join SlownikB on (SlownikB.ID= A.TwG_GrONumer) where A.TwG_GIDTyp = -16
 )
 insert into CDN.WymiaryWartosci (WyW_WyyId, WyW_Guid, WyW_Wartosc, WyW_DokumentTyp, WyW_DokumentId, WyW_Procent, WyW_Kwota, WyW_SlownikId)
 select distinct WyW_WyyId, WyW_Guid, WyW_Wartosc, @dokumentTypTowary, T.TwG_GIDNumer, WyW_Procent, WyW_Kwota, WyW_SlownikId from
 SlownikB G
 join CDN.TwrGrupy T on (T.TwG_GrONumer = G.ID)
 join CDN.WymiaryWartosci on (WyW_DokumentTyp = @dokumentTypGrupuTowarowe and WyW_DokumentId = G.TwG_TwGId)
 where T.TwG_GIDTyp = 16
 order by WyW_Guid;
 --where ID <> @gid and T.TwG_GIDTyp = 16
 --order by WyW_WyWId;
