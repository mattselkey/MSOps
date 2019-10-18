/* -- https://sqlperformance.com/2014/10/sql-performance/knee-jerk-page-life-expectancy -- */

SELECT [object_name],
[counter_name],
[cntr_value] FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Manager%'
AND [counter_name] = 'Page life expectancy'