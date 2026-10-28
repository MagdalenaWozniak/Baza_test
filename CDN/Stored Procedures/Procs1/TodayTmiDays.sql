CREATE PROCEDURE [CDN].[TodayTmiDays]
 (@OPBK NVARCHAR(255), @AnlId int, @SetDaysBefore int output, @DaysBefore int output, @SetDaysAfter int output, @DaysAfter int output)
AS
Begin
 CREATE TABLE #Data (SetDaysBefore int, DaysBefore int, SetDaysAfter int , DaysAfter int)
 declare @strSQL NVARCHAR(3000)
 SET @strSQl =
 'SELECT [Tmi_CzyPrzed], [Tmi_PrzedIloscDni], [Tmi_CzyPo], [Tmi_PoIloscDni]
  FROM ' + @OPBK + '.[CDN].[Terminy] WHERE [Tmi_TmiId] IN (' +
  'SELECT [Inf_TmiId] FROM ' + @OPBK + '.[CDN].[Informacje] WHERE [Inf_WkDId] = ' + Convert(NVARCHAR, @AnlId, 120)
   + ') AND [Tmi_Typ] = 4'
 INSERT #Data(SetDaysBefore, DaysBefore, SetDaysAfter, DaysAfter) exec (@strSQL)
 SELECT @SetDaysBefore = SetDaysBefore ,@DaysBefore = DaysBefore
    ,@SetDaysAfter = SetDaysAfter ,@DaysAfter = DaysAfter
 from #Data
 DROP TABLE #Data
 IF (@SetDaysBefore = 0)
  BEGIN SET @DaysBefore = 1 END
 IF (@DaysAfter = 0)
  BEGIN SET @DaysBefore = 1 END
END
