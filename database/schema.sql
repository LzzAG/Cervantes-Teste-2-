PRAGMA foreign_keys = ON;

CREATE TABLE sala (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE CHECK (length(trim(nome)) > 0)
);

CREATE TABLE agendamento (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sala_id INTEGER NOT NULL REFERENCES sala (id),
    data_inicio TEXT NOT NULL,
    data_fim TEXT NOT NULL,
    CHECK (length(trim(data_inicio)) > 0),
    CHECK (length(trim(data_fim)) > 0),
    CHECK (data_fim > data_inicio)
);

CREATE TABLE log_operacao (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tabela TEXT NOT NULL,
    operacao TEXT NOT NULL,
    data_hora TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE TRIGGER agendamento_sobreposicao_insert
BEFORE INSERT ON agendamento
WHEN EXISTS (
    SELECT 1 FROM agendamento
    WHERE sala_id = NEW.sala_id
      AND NEW.data_inicio < data_fim
      AND NEW.data_fim > data_inicio
)
BEGIN
    SELECT RAISE(ABORT, 'Já existe agendamento para esta sala no período informado');
END;

CREATE TRIGGER agendamento_sobreposicao_update
BEFORE UPDATE ON agendamento
WHEN EXISTS (
    SELECT 1 FROM agendamento
    WHERE sala_id = NEW.sala_id
      AND id <> NEW.id
      AND NEW.data_inicio < data_fim
      AND NEW.data_fim > data_inicio
)
BEGIN
    SELECT RAISE(ABORT, 'Já existe agendamento para esta sala no período informado');
END;

CREATE TRIGGER sala_exclusao_agendamento_futuro
BEFORE DELETE ON sala
WHEN EXISTS (
    SELECT 1 FROM agendamento
    WHERE sala_id = OLD.id
      AND data_fim > datetime('now', 'localtime')
)
BEGIN
    SELECT RAISE(ABORT, 'Não é possível excluir sala com agendamento futuro');
END;

CREATE TRIGGER log_sala_insert
AFTER INSERT ON sala
BEGIN
    INSERT INTO log_operacao (tabela, operacao) VALUES ('sala', 'INSERT');
END;

CREATE TRIGGER log_sala_update
AFTER UPDATE ON sala
BEGIN
    INSERT INTO log_operacao (tabela, operacao) VALUES ('sala', 'UPDATE');
END;

CREATE TRIGGER log_sala_delete
AFTER DELETE ON sala
BEGIN
    INSERT INTO log_operacao (tabela, operacao) VALUES ('sala', 'DELETE');
END;

CREATE TRIGGER log_agendamento_insert
AFTER INSERT ON agendamento
BEGIN
    INSERT INTO log_operacao (tabela, operacao) VALUES ('agendamento', 'INSERT');
END;

CREATE TRIGGER log_agendamento_update
AFTER UPDATE ON agendamento
BEGIN
    INSERT INTO log_operacao (tabela, operacao) VALUES ('agendamento', 'UPDATE');
END;

CREATE TRIGGER log_agendamento_delete
AFTER DELETE ON agendamento
BEGIN
    INSERT INTO log_operacao (tabela, operacao) VALUES ('agendamento', 'DELETE');
END;
