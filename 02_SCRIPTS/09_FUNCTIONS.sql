
-- Remove as funções caso já existam para permitir a recriação limpa
DROP FUNCTION IF EXISTS fn_calcular_faturamento_evento;
DROP FUNCTION IF EXISTS fn_listar_palestras_por_evento;
GO

-- ------------------------------------------------------------------------------
-- FUNCTION 1 (Escalar): Cálculo Automatizado de Receita por Evento
-- Objetivo: Receber o código identificador de um evento e retornar a soma
-- exata de todos os valores arrecadados através de pagamentos 'Confirmados'.
-- ------------------------------------------------------------------------------
CREATE FUNCTION fn_calcular_faturamento_evento
(
    @id_evento INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total_arrecadado DECIMAL(10,2);

    -- Calcula a soma dos pagamentos confirmados vinculados às inscrições do evento
    SELECT @total_arrecadado = ISNULL(SUM(P.valor), 0.00)
    FROM Pagamento P
    INNER JOIN Inscricao I ON P.id_inscricao = I.id_inscricao
    WHERE I.id_evento = @id_evento 
      AND P.status = 'Confirmado';

    RETURN @total_arrecadado;
END;
GO

-- ------------------------------------------------------------------------------
-- FUNCTION 2 (Table-Valued): Listagem Dinâmica de Grade Horária
-- Objetivo: Retornar uma tabela estruturada contendo o título da palestra, 
-- o palestrante convidado e o horário de início com base no ID do evento fornecido.
-- ------------------------------------------------------------------------------
CREATE FUNCTION fn_listar_palestras_por_evento
(
    @id_evento INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        titulo AS [Título da Palestra],
        palestrante AS [Palestrante Responsável],
        horario AS [Horário de Início]
    FROM Palestra
    WHERE id_evento = @id_evento
);
GO
