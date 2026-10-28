CREATE procedure CDN.epDelegacje_UstawStatusDoPrzeliczenia
@DelegacjaElementId int
As
 Declare @sql nvarchar(1024)
 Update CDN.DlgNag Set DLN_WymagaPrzeliczenia=1 where DLN_DLNID in (select DlE_DlNId from CDN.DlgElem where DLE_DLEID=@DelegacjaElementId);
 Update CDN.DlgElem Set DLE_WymagaPrzeliczenia=1 where DLE_DLEID=@DelegacjaElementId;
