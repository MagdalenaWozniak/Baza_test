CREATE PROCEDURE CDN.ORozsynchronizujKlaseAtrybutow (@_OptimaID INT)
AS
BEGIN
if exists (select * from sysobjects where name = 'Synch2015 ' And xtype = 'p')
 begin
 declare @set int
 exec cdn.Synch2015 @pWynik = @set OUTPUT
 if @set = 1
  return
 end
else
 return
        UPDATE CDN.OAtrybutyKlasy SET ATK_SynchronizowanyXL = 0 WHERE Atk_AtkId = @_OptimaID
END
