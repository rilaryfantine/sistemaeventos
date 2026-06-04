

-- ------------------------------------------------------------------------------
-- VIEW 1: Relatório Gerencial de Inscrições (VIEW Complexa com Múltiplos JOINs)
-- Objetivo: Consolidar em uma única visão o nome do participante, o evento que
-- ele escolheu, a data da inscrição e o status atual, unificando os dados.
-- ------------------------------------------------------------------------------
CREATE VIEW vw_relatorio_geral_inscricoes AS
SELECT 
    I.id_inscricao AS [Código Inscrição],
    P.nome AS [Nome Participante],
    P.email AS [E-mail],
    E.nome_evento AS [Nome do Evento],
    E.data_evento AS [Data do Evento],
    I.status AS [Status Inscrição],
    I.data_inscricao AS [Data Cadastro]
FROM Inscricao I
INNER JOIN Participante P ON I.id_participante = P.id_participante
INNER JOIN Evento E ON I.id_evento = E.id_evento;
GO

-- ------------------------------------------------------------------------------
-- VIEW 2: Relatório Financeiro de Faturamento por Evento (VIEW com Agregação)
-- Objetivo: Exibir o total financeiro arrecadado por cada evento com base apenas
-- nos pagamentos que já foram devidamente 'Confirmados' no sistema.
-- ------------------------------------------------------------------------------
CREATE VIEW vw_faturamento_por_evento AS
SELECT 
    E.id_evento AS [Código Evento],
    E.nome_evento AS [Nome do Evento],
    COUNT(I.id_inscricao) AS [Total Inscrições Confirmadas],
    SUM(Pag.valor) AS [Total Arrecadado (R$)]
FROM Evento E
INNER JOIN Inscricao I ON E.id_evento = I.id_evento
INNER JOIN Pagamento Pag ON I.id_inscricao = Pag.id_inscricao
WHERE Pag.status = 'Confirmado'
GROUP BY E.id_evento, E.nome_evento;
GO

-- ------------------------------------------------------------------------------
-- VIEW 3: Cronograma Geral de Palestras (VIEW de Consulta Operacional)
-- Objetivo: Facilitar a visualização da grade horária, listando quais palestras
-- pertencem a qual evento, o palestrante responsável e o horário agendado.
-- ------------------------------------------------------------------------------
CREATE VIEW vw_cronograma_palestras AS
SELECT 
    E.nome_evento AS [Evento],
    P.titulo AS [Título da Palestra],
    P.palestrante AS [Palestrante],
    P.horario AS [Horário de Início]
FROM Palestra P
INNER JOIN Evento E ON P.id_evento = E.id_evento;
GO

-- ------------------------------------------------------------------------------
-- VIEW 4: Painel de Participantes Inadimplentes (VIEW de Segurança/Auditoria)
-- Objetivo: Filtrar e listar de forma rápida os participantes que possuem 
-- inscrições ativas mas cujo pagamento correspondente ainda consta como 'Pendente'.
-- ------------------------------------------------------------------------------
CREATE VIEW vw_participantes_inadimplentes AS
SELECT 
    P.nome AS [Nome],
    P.email AS [E-mail Contato],
    P.telefone AS [Telefone],
    E.nome_evento AS [Evento Inscrito],
    Pag.valor AS [Valor Devido]
FROM Participante P
INNER JOIN Inscricao I ON P.id_participante = I.id_participante
INNER JOIN Evento E ON I.id_evento = E.id_evento
INNER JOIN Pagamento Pag ON I.id_inscricao = Pag.id_inscricao
WHERE Pag.status = 'Pendente' AND I.status = 'Ativa';
GO

-- ------------------------------------------------------------------------------
-- VIEW 5: Resumo Estatístico de Ocupação (VIEW Gerencial Complexa)
-- Objetivo: Trazer métricas de inteligência para os organizadores, comparando a
-- capacidade máxima de cada local com o total de inscritos atuais daquele evento.
-- ------------------------------------------------------------------------------
CREATE VIEW vw_resumo_estatistico_eventos AS
SELECT 
    E.id_evento AS [Código],
    E.nome_evento AS [Nome do Evento],
    E.capacidade AS [Capacidade Máxima],
    COUNT(I.id_inscricao) AS [Total Inscritos],
    (E.capacidade - COUNT(I.id_inscricao)) AS [Vagas Restantes]
FROM Evento E
LEFT JOIN Inscricao I ON E.id_evento = I.id_evento
GROUP BY E.id_evento, E.nome_evento, E.capacidade;
GO
