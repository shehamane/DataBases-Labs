USE LAB9_DB;
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION
SELECT *
FROM Users

SELECT resource_type, resource_subtype, request_mode, request_type
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID

COMMIT TRANSACTION
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
SELECT *
FROM Users
WAITFOR DELAY '00:00:05'
SELECT *
FROM Users

SELECT resource_type, resource_subtype, request_mode, request_type
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID

COMMIT TRANSACTION
GO


SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION
SELECT *
FROM Users
WAITFOR DELAY '00:00:10'
SELECT *
FROM Users

SELECT resource_type, resource_subtype, request_mode, request_type
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID

COMMIT TRANSACTION
GO


SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION
SELECT *
FROM Users
WAITFOR DELAY '00:00:10'
SELECT *
FROM Users

SELECT resource_type, resource_subtype, request_mode, request_type
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID

COMMIT TRANSACTION
GO
