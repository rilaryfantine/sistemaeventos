
-- Remove os procedimentos caso já existam para permitir a recriação limpa
DROP PROCEDURE IF EXISTS sp_registrar_inscricao;
DROP PROCEDURE IF EXISTS sp_confirmar_pagamento;
DROP PROCEDURE IF EXISTS sp_cancelar_inscricao;
GO

-- ------------------------------------------------------------------------------
-- PROCEDURE 1: Automação de Processo de Inscrição com Transação Segura
-- Objetivo: Registrar uma nova inscrição para um participante em um evento e,
-- na mesma operação, gerar automaticamente o registro financeiro na tabela Pagamento.
-- ------------------------------------------------------------------------------
CREATE PROCEDURE sp_registrar_inscricao
    @id_evento INT,
    @id_participante INT,
    @valor_ingresso DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Inicia uma transação para garantir que ambas as inserções ocorram juntas
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- 1. Insere a nova inscrição com status 'Ativa'
        INSERT INTO Inscricao (id_evento, id_participante, status, data_inscricao)
        VALUES (@id_evento, @id_participante, 'Ativa', GETDATE());
        
        -- Captura o ID gerado automaticamente para a inscrição criada acima
        DECLARE @novo_id_inscricao INT = SCOPE_IDENTITY();
        
        -- 2. Insere automaticamente o registro de pagamento como 'Pendente'
        INSERT INTO Pagamento (id_inscricao, valor, status, data_pagamento)
        VALUES (@novo_id_inscricao, @valor_ingresso, 'Pendente', NULL);
        
        -- Se tudo deu certo, confirma as alterações no banco de dados
        COMMIT TRANSACTION;
        PRINT 'Inscrição e registro de pagamento gerados com sucesso!';
    END TRY
    BEGIN CATCH
        -- Se ocorrer qualquer erro, desfaz todas as alterações operadas
        ROLLBACK TRANSACTION;
        PRINT 'Erro ao registrar inscrição. Operação cancelada.';
        THROW;
    END CATCH
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDURE 2: Automação de Fluxo de Caixa (Confirmação de Pagamento)
-- Objetivo: Atualizar o status de um pagamento pendente para 'Confirmado' e 
-- registrar a data exata em que o pagamento foi liquidado no sistema.
-- ------------------------------------------------------------------------------
CREATE PROCEDURE sp_confirmar_pagamento
    @id_pagamento INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Verifica se o pagamento informado existe na base de dados
    IF EXISTS (SELECT 1 FROM Pagamento WHERE id_pagamento = @id_pagamento)
    BEGIN
        UPDATE Pagamento
        SET status = 'Confirmado',
            data_pagamento = GETDATE()
        WHERE id_pagamento = @id_pagamento;
        
        PRINT 'Pagamento confirmado e atualizado no sistema com sucesso.';
    END
    ELSE
    BEGIN
        PRINT 'Aviso: Código de pagamento não encontrado.';
    END
END;
GO

-- ------------------------------------------------------------------------------
-- PROCEDURE 3: Atualização Operacional (Cancelamento de Inscrição)
-- Objetivo: Modificar o status de uma inscrição específica para 'Cancelada', 
-- permitindo liberar o controle de ocupação de vagas do evento.
-- ------------------------------------------------------------------------------
CREATE PROCEDURE sp_cancelar_inscricao
    @id_inscricao INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM Inscricao WHERE id_inscricao = @id_inscricao)
    BEGIN
        UPDATE Inscricao
        SET status = 'Cancelada'
        WHERE id_inscricao = @id_inscricao;
        
        PRINT 'Inscrição cancelada com sucesso no sistema de eventos.';
    END
    ELSE
    BEGIN
        PRINT 'Aviso: Código de inscrição inválido.';
    END
END;
GO
