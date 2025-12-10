CREATE TABLE employees_audit (
    employee_id INT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    old_title VARCHAR(100),
    new_title VARCHAR(100),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION fun_register_employee_title_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    BEGIN
        INSERT INTO employees_audit(employee_id, first_name, last_name, old_title, new_title)
        VALUES (NEW.employee_id, NEW.first_name, NEW.last_name, OLD.title, NEW.title);
        RETURN NEW;
    END;
$$;


CREATE OR REPLACE TRIGGER trg_register_new_title_employee
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION fun_register_employee_title_change();


-- Teste de Verificação
UPDATE employees SET title = 'Senior Sales Representative' WHERE employee_id = 5;

-- Consulta para verificar se a Tabela foi atualizada
SELECT * FROM employees_audit
