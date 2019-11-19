/**: See https://www.sqlshack.com/sql-server-memory-performance-metrics-part-6-memory-metrics/ **/

/*1:    */
SELECT (physical_memory_in_use_kb/1024)/1024 AS [PhysicalMemInUseGB]
FROM sys.dm_os_process_memory;
GO


/*2: from performance counters   */
SELECT counter_name, instance_name, mb = cntr_value/1024.0
  FROM sys.dm_os_performance_counters 
  WHERE (counter_name = N'Cursor memory usage' and instance_name <> N'_Total')
  OR (instance_name = N'' AND counter_name IN 
       (N'Connection Memory (KB)', N'Granted Workspace Memory (KB)', 
        N'Lock Memory (KB)', N'Optimizer Memory (KB)', N'Stolen Server Memory (KB)', 
        N'Log Pool Memory (KB)', N'Free Memory (KB)')
  ) ORDER BY mb DESC;

/*3:   */
  SELECT TOP (20) * FROM sys.dm_os_memory_clerks ORDER BY pages_kb DESC