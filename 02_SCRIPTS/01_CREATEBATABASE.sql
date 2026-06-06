-- =========================================================================
-- FATEC OSASCO - ANÁLISE E DESENVOLVIMENTO DE SISTEMAS / PROGRAMAÇÃO SGBD
-- ESTUDO DE CASO: SISTEMA DE GESTÃO DE EVENTOS
-- SCRIPT 01: CRIAÇÃO DO BANCO DE DADOS (DATABASE ENGINE INDEPENDENT)
-- =========================================================================

-- 1. TRATAMENTO DEFENSIVO: Derruba conexões e exclui a base se ela já existir
-- (Garante que o script possa ser executado múltiplas vezes em ambiente de teste)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'sistemaeventos')
BEGIN
    ALTER DATABASE sistemaeventos SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE sistemaeventos;
END;
GO

-- 2. CRIAÇÃO FÍSICA DA ESTRUTURA DE ARMAZENAMENTO
CREATE DATABASE sistemaeventos;
GO

-- 3. DIRECIONAMENTO DO PONTEIRO DE ESCOPO
-- (Instrui o SQL Server a executar as próximas tabelas e scripts dentro deste banco)
USE sistemaeventos;
GO

PRINT 'Sucesso: Banco de dados [sistemaeventos] inicializado e pronto para estruturação!';
