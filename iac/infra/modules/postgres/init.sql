-- Tabelas normalizadas
CREATE TABLE clientes (
  id SERIAL PRIMARY KEY,
  cpf TEXT UNIQUE NOT NULL,
  nome TEXT NOT NULL,
  renda NUMERIC NOT NULL,
  email TEXT NOT NULL,
  data_nascimento DATE NOT NULL,
  perfil_risco TEXT CHECK (perfil_risco IN ('conservador', 'moderado', 'arrojado'))
);

CREATE TABLE acoes (
  id SERIAL PRIMARY KEY,
  ticker TEXT UNIQUE NOT NULL,
  empresa TEXT NOT NULL,
  setor TEXT,
  link_relatorio TEXT NOT NULL
);

CREATE TABLE carteiras (
  id SERIAL PRIMARY KEY,
  cliente_id INTEGER REFERENCES clientes(id),
  acao_id INTEGER REFERENCES acoes(id),
  preco_teto NUMERIC NOT NULL,
  recomendacao TEXT CHECK (recomendacao IN ('Compra', 'Venda', 'Neutro')),
  nota NUMERIC NOT NULL CHECK (nota BETWEEN 0 AND 10),
  analise_sentimento TEXT NOT NULL
);

CREATE TABLE relatorios_ri (
  id SERIAL PRIMARY KEY,
  acao_id INTEGER REFERENCES acoes(id),
  trimestre TEXT,
  json_resultado JSONB
);

-- Clientes
INSERT INTO clientes (cpf, nome, renda, email, data_nascimento, perfil_risco) VALUES
('11111111111', 'João Silva', 4500.00, 'joao@email.com', '1980-05-10', 'conservador'),
('22222222222', 'Maria Souza', 12000.00, 'maria@email.com', '1985-08-22', 'arrojado'),
('33333333333', 'Carlos Lima', 7000.00, 'carlos@email.com', '1990-03-15', 'moderado'),
('44444444444', 'Fernanda Rocha', 5000.00, 'fernanda@email.com', '1978-11-30', 'conservador'),
('55555555555', 'Bruno Costa', 15000.00, 'bruno@email.com', '1982-07-05', 'arrojado'),
('66666666666', 'Patrícia Mendes', 8000.00, 'patricia@email.com', '1993-02-18', 'moderado'),
('77777777777', 'Eduardo Tavares', 4800.00, 'eduardo@email.com', '1987-06-12', 'conservador'),
('88888888888', 'Juliana Freitas', 9000.00, 'juliana@email.com', '1991-09-25', 'moderado'),
('99999999999', 'Rafael Martins', 13000.00, 'rafael@email.com', '1984-04-03', 'arrojado'),
('00000000000', 'Aline Nogueira', 5200.00, 'aline@email.com', '1989-12-19', 'conservador');

-- Ações
INSERT INTO acoes (ticker, empresa, setor, link_relatorio) VALUES
('TAEE11', 'Taesa', 'Energia', 'https://ri.taesa.com.br/relatorio-q2.pdf'),
('BBAS3', 'Banco do Brasil', 'Financeiro', 'https://bb.com.br/ri/relatorio-q2.pdf'),
('ITSA4', 'Itaúsa', 'Financeiro', 'https://ri.itausa.com.br/relatorio-q2.pdf'),
('EGIE3', 'Engie Brasil', 'Energia', 'https://engie.com.br/ri/relatorio-q2.pdf'),
('CPLE6', 'Copel', 'Energia', 'https://copel.com/ri/relatorio-q2.pdf'),
('PETR4', 'Petrobras', 'Petróleo', 'https://petrobras.com.br/ri/relatorio-q2.pdf'),
('VALE3', 'Vale', 'Mineração', 'https://vale.com/ri/relatorio-q2.pdf'),
('BBSE3', 'BB Seguridade', 'Seguros', 'https://bbseguridade.com.br/ri/relatorio-q2.pdf'),
('ALUP11', 'Alupar', 'Energia', 'https://alupar.com.br/ri/relatorio-q2.pdf'),
('GRND3', 'Grendene', 'Consumo', 'https://grendene.com.br/ri/relatorio-q2.pdf');

-- Carteiras por perfil
-- Conservadores: clientes 1, 4, 7, 10
INSERT INTO carteiras (cliente_id, acao_id, preco_teto, recomendacao, nota, analise_sentimento) VALUES
(1,1,38.00,'Compra',8.5,'positivo'),
(1,2,45.00,'Compra',9.0,'positivo'),
(1,3,12.00,'Compra',8.0,'neutro'),
(1,4,40.00,'Compra',8.2,'positivo'),
(1,5,32.00,'Compra',7.8,'neutro'),

(4,1,38.00,'Compra',8.5,'positivo'),
(4,2,45.00,'Compra',9.0,'positivo'),
(4,4,40.00,'Compra',8.2,'positivo'),
(4,5,32.00,'Compra',7.8,'neutro'),
(4,8,25.00,'Compra',7.9,'positivo'),

(7,1,38.00,'Compra',8.5,'positivo'),
(7,2,45.00,'Compra',9.0,'positivo'),
(7,3,12.00,'Compra',8.0,'neutro'),
(7,4,40.00,'Compra',8.2,'positivo'),
(7,9,28.00,'Compra',7.5,'neutro'),

(10,1,38.00,'Compra',8.5,'positivo'),
(10,2,45.00,'Compra',9.0,'positivo'),
(10,4,40.00,'Compra',8.2,'positivo'),
(10,5,32.00,'Compra',7.8,'neutro'),
(10,8,25.00,'Compra',7.9,'positivo');

-- Moderados: clientes 3, 6, 8
INSERT INTO carteiras (cliente_id, acao_id, preco_teto, recomendacao, nota, analise_sentimento) VALUES
(3,2,45.00,'Compra',8.5,'positivo'),
(3,3,12.00,'Compra',8.0,'neutro'),
(3,6,28.00,'Compra',7.5,'neutro'),
(3,7,70.00,'Compra',8.8,'positivo'),
(3,8,25.00,'Compra',7.9,'positivo'),

(6,2,45.00,'Compra',8.5,'positivo'),
(6,3,12.00,'Compra',8.0,'neutro'),
(6,5,32.00,'Compra',7.8,'neutro'),
(6,7,70.00,'Compra',8.8,'positivo'),
(6,10,9.00,'Compra',7.2,'neutro'),

(8,3,12.00,'Compra',8.0,'neutro'),
(8,4,40.00,'Compra',8.2,'positivo'),
(8,6,28.00,'Compra',7.5,'neutro'),
(8,8,25.00,'Compra',7.9,'positivo'),
(8,10,9.00,'Compra',7.2,'neutro');

-- Arrojados: clientes 2, 5, 9
INSERT INTO carteiras (cliente_id, acao_id, preco_teto, recomendacao, nota, analise_sentimento) VALUES
(2,6,28.00,'Compra',9.0,'positivo'),
(2,7,70.00,'Compra',8.5,'positivo'),
(2,10,9.00,'Compra',7.2,'neutro'),
(2,3,12.00,'Compra',8.0,'neutro'),
(2,5,32.00,'Venda',6.5,'negativo'),

(5,6,28.00,'Compra',9.0,'positivo'),
(5,7,70.00,'Compra',8.5,'positivo'),
(5,10,9.00,'Compra',7.2,'neutro'),
(5,3,12.00,'Compra',8.0,'neutro'),
(5,9,28.00,'Compra',7.5,'neutro'),

(9,6,28.00,'Compra',9.0,'positivo'),
(9,7,70.00,'Compra',8.5,'positivo'),
(9,10,9.00,'Compra',7.2,'neutro'),
(9,5,32.00,'Venda',6.5,'negativo'),
(9,8,25.00,'Compra',7.9,'positivo');


