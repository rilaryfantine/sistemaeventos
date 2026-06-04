
-- 2. CRIAR A TABELA DE LOG DO ZERO (GARANTINDO A COLUNA DESCRICAO)
IF OBJECT_ID('Log_Auditoria', 'U') IS NOT NULL
BEGIN
    DROP TABLE Log_Auditoria;
END;
GO

CREATE TABLE Log_Auditoria (
    id_log INT IDENTITY(1,1) PRIMARY KEY,
    tabela_afetada NVARCHAR(50) NOT NULL,
    acao NVARCHAR(20) NOT NULL,
    descricao NVARCHAR(MAX) NOT NULL,
    data_acao DATETIME DEFAULT GETDATE(),
    usuario NVARCHAR(100) DEFAULT CURRENT_USER
);
GO


-- 3. CRIAR A TRIGGER 1: AFTER INSERT (Auditoria de Novas Inscrições)
CREATE TRIGGER trg_auditoria_inscricao
ON Inscricao
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Log_Auditoria (tabela_afetada, acao, descricao)
    SELECT 
        'Inscricao',
        'INSERT',
        CONCAT('Nova inscrição gerada! Código: ', id_inscricao, ' | ID Participante: ', id_participante, ' | Status: ', status)
    FROM inserted;
END;
GO


-- 4. CRIAR A TRIGGER 2: AFTER UPDATE (Auditoria Financeira)
CREATE TRIGGER trg_historico_pagamento
ON Pagamento
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(status)
    BEGIN
        INSERT INTO Log_Auditoria (tabela_afetada, acao, descricao)
        SELECT 
            'Pagamento',
            'UPDATE',
            CONCAT('Alteração financeira! Pagamento ID: ', i.id_pagamento, ' mudou de ', d.status, ' para ', i.status, ' | Valor: R$', i.valor)
        FROM inserted i
        INNER JOIN deleted d ON i.id_pagamento = d.id_pagamento;
    END
END;
GO


-- 5. CRIAR A TRIGGER 3: INSTEAD OF INSERT (Validação de Lotação Máxima)
CREATE TRIGGER trg_bloqueio_capacidade_evento
ON Inscricao
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_evento INT, @id_participante INT, @status NVARCHAR(20);
    SELECT @id_evento = id_evento, @id_participante = id_participante, @status = status FROM inserted;

    DECLARE @capacidade_maxima INT;
    DECLARE @total_inscritos_atual INT;

    SELECT @capacidade_maxima = capacidade FROM Evento WHERE id_evento = @id_evento;
    SELECT @total_inscritos_atual = COUNT(*) FROM Inscricao WHERE id_evento = @id_evento AND status = 'Ativa';

    IF (@total_inscritos_atual >= @capacidade_maxima)
    BEGIN
        RAISERROR('Erro operacional: Inscrição negada. O evento selecionado já atingiu sua capacidade máxima de público!', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Inscricao (id_evento, id_participante, status, data_inscricao)
        VALUES (@id_evento, @id_participante, @status, GETDATE());
    END
END;
GO
