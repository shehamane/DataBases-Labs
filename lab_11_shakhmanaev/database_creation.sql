USE master
GO

CREATE DATABASE LAB11_DB
    ON PRIMARY
    (NAME = LAB11_DB_PrimaryData,
        FILENAME = '/var/opt/mssql/data/lab11_db.mdf',
        SIZE = 10, MAXSIZE = UNLIMITED , FILEGROWTH =5 MB),
    (NAME = LAB11_DB_SenondaryData,
        FILENAME = '/var/opt/mssql/data/lab11_db_1.ndf',
        SIZE = 10, MAXSIZE = 25, FILEGROWTH = 5 MB)
    LOG ON
    ( NAME = LAB11_DB_Log,
        FILENAME = '/var/opt/mssql/data/lab11_db_log.ldf',
        SIZE = 5 MB, MAXSIZE = 25 MB, FILEGROWTH = 5 MB)
GO
