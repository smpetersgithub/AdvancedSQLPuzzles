USE master;
GO

-- Declare variables to store session IDs
DECLARE @sql NVARCHAR(MAX);
DECLARE @delimiter NVARCHAR(5) = ';';

-- Build the dynamic SQL
SET @sql =  (
    SELECT  STRING_AGG('KILL ' + CAST(s.session_id AS NVARCHAR) + @delimiter, ' ')
    FROM    sys.dm_exec_sessions s LEFT JOIN 
            sys.dm_exec_requests r ON s.session_id = r.session_id
    WHERE   s.is_user_process = 1       -- Only user sessions, not system sessions
            AND s.session_id <> @@SPID  -- Exclude the current session
            AND r.blocking_session_id IS NULL -- Example filter: No blocking session
            );

-- Execute the dynamic SQL to kill sessions
IF @sql IS NOT NULL AND LEN(@sql) > 0
BEGIN
    PRINT @sql; -- Optional: Check the generated SQL before execution
    EXEC sp_executesql @sql;
END
ELSE
BEGIN
    PRINT 'No sessions found to kill.';
END;
GO


/*
USE master;
GO

SELECT
    s.session_id,
    s.host_name,
    s.program_name,
    s.login_name,
    r.status,
    r.command,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.cpu_time,
    r.transaction_isolation_level
FROM sys.dm_exec_sessions s
LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
WHERE s.is_user_process = 1; -- Only user sessions, not system sessions
*/