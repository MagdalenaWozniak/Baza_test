CREATE FUNCTION CDN.ZestawKsieg(@ZestawienieId Int)
Returns @Table Table (RecCount Int, N1 NVARCHAR(255), N2 NVARCHAR(255), N3 NVARCHAR(255), N4 NVARCHAR(255), N5 NVARCHAR(255), N6 NVARCHAR(255), N7 NVARCHAR(255), N8 NVARCHAR(255), N9 NVARCHAR(255), N10 NVARCHAR(255), N11 NVARCHAR(255), N12 NVARCHAR(255), N13 NVARCHAR(255), N14 NVARCHAR(255), N15 NVARCHAR(255), N16 NVARCHAR(255), N17 NVARCHAR(255), N18 NVARCHAR(255), N19 NVARCHAR(255), N20 NVARCHAR(255), N21 NVARCHAR(255), N22 NVARCHAR(255),
N23 NVARCHAR(255))
As
Begin
Insert Into @Table(RecCount, N1, N2, N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16, N17, N18, N19, N20, N21, N22, N23)
Select
(Select Count(*)  From CDN.ZestKsiKol Where ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 1  And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 2  And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 3  And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 4  And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 5  And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 6  And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 7  And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 8  And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 9  And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 10 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 11 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 12 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 13 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 14 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 15 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 16 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 17 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 18 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 19 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 20 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 21 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 22 And  ZKK_ZKNId = @ZestawienieID),
(Select Top 1 ZKK_Nazwa From CDN.ZestKsiKol Where ZKK_Lp = 23 And  ZKK_ZKNId = @ZestawienieID)
Return
End
