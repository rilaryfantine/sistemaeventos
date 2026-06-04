
-- ------------------------------------------------------------------------------
-- CTE 1: Análise Operacional de Ocupação de Espaços
-- Objetivo: Criar uma tabela temporária com o volume de inscrições ativas por evento 
-- e cruzar com a capacidade máxima para monitorar a lotação dos locais.
-- ------------------------------------------------------------------------------
WITH cte_total_inscritos AS (
    SELECT id_evento, COUNT(*) AS qtd_inscritos
    FROM Inscricao
    WHERE status = 'Ativa'
    GROUP BY id_evento
)
SELECT 
    E.nome_evento,
    E.capacidade AS Capacidade_Maxima,
    ISNULL(C.qtd_inscritos, 0) AS Inscritos_Atuais,
    (E.capacidade - ISNULL(C.qtd_inscritos, 0)) AS Vagas_Restantes
FROM Evento E
LEFT JOIN cte_total_inscritos C ON E.id_evento = C.id_evento;


-- ------------------------------------------------------------------------------
-- CTE 2: Consolidação Financeira Dinâmica (Uso de múltiplas CTEs encadeadas)
-- Objetivo: Isolar os cálculos de valores pagos e pendentes por participante, 
-- gerando um balanço financeiro individual transparente.
-- ------------------------------------------------------------------------------
WITH cte_pagamentos_confirmados AS (
    SELECT I.id_participante, SUM(P.valor) AS total_pago
    FROM Inscricao I
    INNER JOIN Pagamento P ON I.id_inscricao = P.id_inscricao
    WHERE P.status = 'Confirmado'
    GROUP BY I.id_participante
),
cte_pagamentos_pendentes AS (
    SELECT I.id_participante, SUM(P.valor) AS total_pendente
    FROM Inscricao I
    INNER JOIN Pagamento P ON I.id_inscricao = P.id_inscricao
    WHERE P.status = 'Pendente'
    GROUP BY I.id_participante
)
SELECT 
    Part.nome AS Nome_Participante,
    ISNULL(Conf.total_pago, 0.00) AS Valor_Pago_R$,
    ISNULL(Pend.total_pendente, 0.00) AS Valor_Pendente_R$
FROM Participante Part
LEFT JOIN cte_pagamentos_confirmados Conf ON Part.id_participante = Conf.id_participante
LEFT JOIN cte_pagamentos_pendentes Pend ON Part.id_participante = Pend.id_participante;


-- ------------------------------------------------------------------------------
-- CTE 3: Segmentação de Calendário Comercial
-- Objetivo: Mapear e isolar os eventos que ocorrerão apenas no primeiro semestre 
-- de 2026 para fins de auditoria de marketing e liberação de verbas.
-- ------------------------------------------------------------------------------
WITH cte_primeiro_semestre AS (
    SELECT id_evento, nome_evento, data_evento, local_evento
    FROM Evento
    WHERE data_evento BETWEEN '2026-01-01' AND '2026-06-30'
)
SELECT 
    nome_evento AS Evento_Semestre_1,
    DATENAME(month, data_evento) AS Mes_Realizacao,
    local_evento
FROM cte_primeiro_semestre;


-- ------------------------------------------------------------------------------
-- CTE 4: Monitoramento de Alocação de Palestrantes
-- Objetivo: Agrupar e identificar palestrantes que possuem apresentações alocadas 
-- na base, garantindo que a grade horária está distribuída corretamente.
-- ------------------------------------------------------------------------------
WITH cte_contagem_palestras AS (
    SELECT palestrante, COUNT(*) AS total_palestras
    FROM Palestra
    GROUP BY palestrante
)
SELECT palestrante, total_palestras
FROM cte_contagem_palestras
WHERE total_palestras >= 1;


-- ------------------------------------------------------------------------------
-- CTE 5 (Obrigatória do Enunciado): Relatório Hierárquico / Recursivo
-- Objetivo: Demonstrar o uso de uma CTE Recursiva simulando a árvore estrutural 
-- de dependência das equipes organizadoras de salas e suporte técnico do evento.
-- ------------------------------------------------------------------------------
WITH cte_organograma_suporte AS (
    -- Membro âncora (O Diretor Geral do Evento)
    SELECT 1 AS id_membro, CAST('Diretor Geral' AS VARCHAR(50)) AS cargo, CAST(NULL AS INT) AS id_superior, 1 AS nivel
    UNION ALL
    -- Membros filhos (Gerentes e Supervisores que respondem ao nível superior)
    SELECT 
        R.id_membro + 1,
        CAST(CASE 
            WHEN R.nivel = 1 THEN 'Gerente de Operações'
            WHEN R.nivel = 2 THEN 'Supervisor de Sala'
            ELSE 'Staff / Apoio Técnico'
        END AS VARCHAR(50)),
        R.id_membro,
        R.nivel + 1
    FROM cte_organograma_suporte R
    WHERE R.nivel < 4 -- Critério de parada obrigatório da recursividade
)
SELECT nivel, cargo, id_superior AS ID_Superior_Direto
FROM cte_organograma_suporte;
