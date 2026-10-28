CREATE PROCEDURE CDN.CzyDzienWolny @dzien datetime
AS
declare @month int
declare @day   int
set @month = DATEPART(month, @dzien)
declare @freedays table(data datetime)
insert into @freedays values ( convert (datetime, '2000-04-23 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2000-04-24 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2000-06-22 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2001-04-15 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2001-04-16 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2001-06-14 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2002-03-31 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2002-04-01 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2002-05-30 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2003-04-20 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2003-04-21 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2003-06-19 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2004-04-11 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2004-04-12 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2004-06-10 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2005-03-27 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2005-03-28 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2005-05-26 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2006-04-16 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2006-04-17 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2006-06-15 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2012-04-08 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2012-04-09 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2012-06-07 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2013-03-31 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2013-04-01 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2013-05-30 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2014-04-20 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2014-04-21 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2014-06-19 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2015-04-05 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2015-04-06 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2015-06-04 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2016-03-27 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2016-03-28 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2016-05-26 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2017-04-16 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2017-04-17 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2017-06-15 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2018-04-01 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2018-04-02 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2018-05-31 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2019-04-21 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2019-04-22 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2019-06-20 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2018-11-12 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2020-04-13 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2020-06-11 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2021-04-05 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2021-06-03 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2022-04-18 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2022-06-16 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2020-04-12 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2021-04-04 00:00:00:000' , 120 ) )
insert into @freedays values ( convert (datetime, '2022-04-17 00:00:00:000' , 120 ) )
--kolejne święta uwzględnić także w procedurze DniSwiateczne
set @day = (select 1 from @freedays where data = @dzien)
if @day=1 return 3
set @day = DATEPART(day, @dzien)
IF @day=1 AND @month=1 RETURN 3
IF @day=6 AND @month=1 RETURN 3
IF @day=1 AND @month=5 RETURN 3
IF @day=3 AND @month=5 RETURN 3
IF @day=15 AND @month=8 RETURN 3
IF @day=1 AND @month=11 RETURN 3
IF @day=11 AND @month=11 RETURN 3
IF @day=25 AND @month=12 RETURN 3
IF @day=26 AND @month=12 RETURN 3
SET @dzien = CONVERT (DATETIME, @dzien, 120)
declare @Data0 datetime
declare @l int
SET @Data0      = CONVERT ( DATETIME, '1899-12-30 00:00:00' , 120 )
set @l = DATEDIFF(minute, @Data0, @dzien) % 7
IF @l=0 RETURN 1
IF @l=5 RETURN 2
RETURN 0
