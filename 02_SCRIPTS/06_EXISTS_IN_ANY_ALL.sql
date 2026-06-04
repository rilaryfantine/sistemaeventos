
-- ------------------------------------------------------------------------------
-- CONSULTA 1: Operador EXISTS (Verificação de registros relacionados)
-- Objetivo: Listar apenas os participantes que possuem pelo menos uma inscrição 
-- ativa cadastrada no sistema, ignorando quem não se vinculou a nenhum evento.
-- ------------------------------------------------------------------------------
SELECT P.id_participante, P.nome, P.email
FROM Participante P
WHERE EXISTS (
    SELECT 1 
    FROM Inscricao I 
    WHERE I.id_participante = P.id_participante AND I.status = 'Ativa'
);


-- ------------------------------------------------------------------------------
-- CONSULTA 2: Operador NOT EXISTS (Auditoria de segurança de dados)
-- Objetivo: Encontrar inscrições que, por algum motivo de processamento, ainda 
-- não possuem nenhum registro financeiro gerado na tabela de Pagamentos.
-- ------------------------------------------------------------------------------
SELECT I.id_inscricao, I.id_evento, I.id_participante, I.status
FROM Inscricao I
WHERE NOT EXISTS (
    SELECT 1 
    FROM Pagamento Pag 
    WHERE Pag.id_inscricao = I.id_inscricao
);


-- ------------------------------------------------------------------------------
-- CONSULTA 3: Operador IN (Filtro múltiplo de registros)
-- Objetivo: Selecionar todas as palestras que pertencem exclusivamente a eventos 
-- sediados nas principais capitais ou polos tecnológicos: 'São Paulo' ou 'Campinas'.
-- ------------------------------------------------------------------------------
SELECT P.id_palestra, P.titulo, P.palestrante, P.id_evento
FROM Palestra P
WHERE P.id_evento IN (
    SELECT E.id_evento 
    FROM Evento E 
    WHERE E.local_evento IN ('São Paulo', 'Campinas')
);


-- ------------------------------------------------------------------------------
-- CONSULTA 4: Operador ANY (Comparação condicional flexível)
-- Objetivo: Buscar pagamentos cujos valores sejam maiores que qualquer um (ANY) 
-- dos valores de pagamentos que ainda estão com o status 'Pendente'.
-- ------------------------------------------------------------------------------
SELECT id_pagamento, id_inscricao, valor, status
FROM Pagamento
WHERE valor > ANY (
    SELECT valor 
    FROM Pagamento 
    WHERE status = 'Pendente'
);


-- ------------------------------------------------------------------------------
-- CONSULTA 5: Operador ALL (Comparação restritiva total)
-- Objetivo: Encontrar eventos cuja capacidade máxima de público seja maior ou 
-- igual à capacidade de TODOS os eventos realizados na cidade de 'Campinas'.
-- ------------------------------------------------------------------------------
SELECT id_evento, nome_evento, capacidade, local_evento
FROM Evento
WHERE capacidade >= ALL (
    SELECT capacidade 
    FROM Evento 
    WHERE local_evento = 'Campinas'
);
