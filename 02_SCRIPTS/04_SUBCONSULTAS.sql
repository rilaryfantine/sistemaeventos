
-- ------------------------------------------------------------------------------
-- CONSULTA 1 (Obrigatória do Enunciado): Análise de dados acima da média.
-- Objetivo: Listar os eventos cuja capacidade de público é MAIOR que a média 
-- de capacidade de todos os eventos cadastrados no sistema.
-- ------------------------------------------------------------------------------
SELECT id_evento, nome_evento, capacidade, local_evento
FROM Evento
WHERE capacidade > (SELECT AVG(capacidade) FROM Evento)
ORDER BY capacidade DESC;


-- ------------------------------------------------------------------------------
-- CONSULTA 2: Subconsulta Simples no WHERE (Filtro por ID dinâmico)
-- Objetivo: Buscar todos os dados do participante que realizou a inscrição 
-- de número 1, sem utilizar JOIN na instrução principal.
-- ------------------------------------------------------------------------------
SELECT id_participante, nome, email 
FROM Participante
WHERE id_participante = (SELECT id_participante FROM Inscricao WHERE id_inscricao = 1);


-- ------------------------------------------------------------------------------
-- CONSULTA 3: Subconsulta com agregação no SELECT (Contagem correlacionada)
-- Objetivo: Listar os eventos cadastrados e trazer em uma coluna calculada a 
-- quantidade total de palestras vinculadas a cada um deles.
-- ------------------------------------------------------------------------------
SELECT 
    E.id_evento, 
    E.nome_evento,
    (SELECT COUNT(*) FROM Palestra P WHERE P.id_evento = E.id_evento) AS Total_Palestras
FROM Evento E;


-- ------------------------------------------------------------------------------
-- CONSULTA 4: Subconsulta Correlacionada no WHERE
-- Objetivo: Encontrar os pagamentos cujo valor é superior à média de valores
-- cadastrados para aquele mesmo status (ex: acima da média dos 'Confirmados').
-- ------------------------------------------------------------------------------
SELECT id_pagamento, id_inscricao, valor, status
FROM Pagamento P1
WHERE valor > (
    SELECT AVG(valor) 
    FROM Pagamento P2 
    WHERE P2.status = P1.status
);


-- ------------------------------------------------------------------------------
-- CONSULTA 5: Subconsulta no FROM (Tabela Derivada)
-- Objetivo: Calcular o faturamento total por evento e filtrar externamente 
-- apenas as conferências que arrecadaram mais de R$ 200,00.
-- ------------------------------------------------------------------------------
SELECT Faturamento.id_evento, Faturamento.Total_Arrecadado
FROM (
    SELECT I.id_evento, SUM(Pag.valor) AS Total_Arrecadado
    FROM Inscricao I
    INNER JOIN Pagamento Pag ON I.id_inscricao = Pag.id_inscricao
    WHERE Pag.status = 'Confirmado'
    GROUP BY I.id_evento
) AS Faturamento
WHERE Faturamento.Total_Arrecadado > 200.00;


-- ------------------------------------------------------------------------------
-- CONSULTA 6: Subconsulta aninhada para identificação de pendências
-- Objetivo: Listar o nome e o e-mail dos participantes que possuem inscrições 
-- ativas mas com pagamentos ainda no status 'Pendente'.
-- ------------------------------------------------------------------------------
SELECT nome, email 
FROM Participante
WHERE id_participante IN (
    SELECT id_participante 
    FROM Inscricao 
    WHERE id_inscricao IN (SELECT id_inscricao FROM Pagamento WHERE status = 'Pendente')
);


-- ------------------------------------------------------------------------------
-- CONSULTA 7: Subconsulta com limite de dados (TOP 1)
-- Objetivo: Listar as palestras agendadas para o evento mais distante no futuro 
-- (com a maior data cadastrada).
-- ------------------------------------------------------------------------------
SELECT titulo, palestrante, horario
FROM Palestra
WHERE id_evento = (SELECT TOP 1 id_evento FROM Evento ORDER BY data_evento DESC);


-- ------------------------------------------------------------------------------
-- CONSULTA 8: Subconsulta para controle de capacidade mínima
-- Objetivo: Selecionar os detalhes dos eventos que possuem a menor capacidade 
-- de público registrada na base de dados para fins de planejamento de equipe.
-- ------------------------------------------------------------------------------
SELECT nome_evento, local_evento, capacidade
FROM Evento
WHERE capacidade = (SELECT MIN(capacidade) FROM Evento);


-- ------------------------------------------------------------------------------
-- CONSULTA 9: Subconsulta para auditoria financeira de teto
-- Objetivo: Listar detalhes dos pagamentos que receberam o maior valor único 
-- registrado na tabela transacional.
-- ------------------------------------------------------------------------------
SELECT id_pagamento, id_inscricao, valor, data_pagamento
FROM Pagamento
WHERE valor = (SELECT MAX(valor) FROM Pagamento);


-- ------------------------------------------------------------------------------
-- CONSULTA 10: Subconsulta com Filtro Geográfico Estático
-- Objetivo: Listar palestras associadas a eventos que acontecem especificamente 
-- na cidade de 'São Paulo', isolando o filtro de texto na busca interna.
-- ------------------------------------------------------------------------------
SELECT titulo, palestrante
FROM Palestra
WHERE id_evento IN (SELECT id_evento FROM Evento WHERE local_evento = 'São Paulo');
