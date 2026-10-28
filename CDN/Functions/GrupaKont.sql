CREATE function CDN.GrupaKont (@AccId int, @OObId int, @GrupaYesNo int)
Returns @Konta Table (
GKE_AccId int,
GKN_Symbol NVARCHAR(50),
GKN_GKNId int)
AS
BEGIN
-- @GrupaYesNo = 0: zwraca wszystkie identyfikatory kont nadrzednych i podrzednych
-- @GrupaYesNo = 1: zwraca konto i symbol grupy do ktorej konto nalezy
 if not exists (SELECT * FROM CDN.GrupyKontNag join CDN.GrupyKontElem on GKN_GKNID = GKE_GKNID WHERE GKN_OObId=@OObId) return;
 declare @parent integer
 declare @par integer
 declare @kontoID integer
 declare @flag integer
 Set @flag = 0
 Set @parent = @AccId
 Set @kontoID = @AccId
 WHILE @parent <> 0
 BEGIN
  select TOP 1 @par = isnull(Acc_ParId,0)
  from CDN.KontaAnalityczne (@parent, 1)
   join cdn.konta on anl_accid=acc_accid
   where isnull(Acc_ParId,0) <> @parent
  Order by acc_Numer
  Set @parent = @par
  if @parent = @kontoID
    break
  if exists (Select GKE_AccId from CDN.GrupyKontNag  join CDN.GrupyKontElem on GKN_GKNID = GKE_GKNID where GKN_OObId = @OObId  and GKE_AccId = @kontoID)
    Set @flag = 1
  if @parent <> 0 and @flag = 0
    Set  @kontoID = @parent
 END
  if not exists (Select GKE_AccId from CDN.GrupyKontNag  join CDN.GrupyKontElem on GKN_GKNID = GKE_GKNID where GKN_OObId = @OObId  and GKE_AccId = @kontoID)
  begin
    Set @kontoID = 0
  end
 if @GrupaYesNo = 1
 begin
  Insert into @Konta
  SELECT TOP 1 GKE_AccId, GKN_Symbol, GKN_GKNId
  FROM CDN.GrupyKontNag
   JOIN CDN.GrupyKontElem ON GKN_GKNId=GKE_GKNId
  WHERE GKE_AccId in (select Anl_AccId from CDN.KontaAnalityczne (@kontoID, 1))
   AND GKN_OObID = @OObId
 end
 else
 begin
  Insert into @Konta
  SELECT Anl_AccId as GKE_AccId, null, null
  from CDN.KontaAnalityczne (@kontoID, 1)
 end
Return
End
