-- Insert departments
INSERT INTO departments (name) VALUES
  ('Отдел разработки'),
  ('Отдел тестирования'),
  ('Отдел маркетинга'),
  ('Отдел продаж');

-- Insert teams
INSERT INTO teams (name) VALUES
  ('Команда Frontend'),
  ('Команда Backend'),
  ('Команда QA'),
  ('Команда DevOps');

-- Insert projects
INSERT INTO projects (name) VALUES
  ('Портал сотрудников'),
  ('CRM система'),
  ('Мобильное приложение'),
  ('Веб-сайт');

-- Insert work schedules
INSERT INTO work_schedules (name, working_days, working_hours, breaks) VALUES
  ('Стандартный график', 
   '{"monday", "tuesday", "wednesday", "thursday", "friday"}',
   '{"start": "09:00", "end": "18:00"}',
   '{"{\"start\": \"13:00\", \"end\": \"14:00\"}"}'),
  ('Гибкий график',
   '{"monday", "tuesday", "wednesday", "thursday", "friday"}',
   '{"start": "10:00", "end": "19:00"}',
   '{"{\"start\": \"14:00\", \"end\": \"15:00\"}"}');

-- Insert production calendar for 2024
INSERT INTO production_calendar (year, holidays, working_days) VALUES
  (2024,
   '{"2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04", "2024-01-05", "2024-01-06", "2024-01-07", "2024-01-08",
     "2024-02-23", "2024-03-08", "2024-05-01", "2024-05-09", "2024-06-12", "2024-11-04"}',
   '{"2024-01-09", "2024-01-10", "2024-01-11", "2024-01-12", "2024-01-13", "2024-01-14", "2024-01-15", "2024-01-16",
     "2024-01-17", "2024-01-18", "2024-01-19", "2024-01-20", "2024-01-21", "2024-01-22", "2024-01-23", "2024-01-24",
     "2024-01-25", "2024-01-26", "2024-01-27", "2024-01-28", "2024-01-29", "2024-01-30", "2024-01-31"}');

-- Insert auth users first
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at) VALUES
  ('00000000-0000-0000-0000-000000000000', 'admin@example.com', 
   '$2a$10$X7z3bJwq3Vq3Vq3Vq3Vq3.Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq', NOW(), NOW(), NOW()),
  ('11111111-1111-1111-1111-111111111111', 'user@example.com', 
   '$2a$10$X7z3bJwq3Vq3Vq3Vq3Vq3.Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq', NOW(), NOW(), NOW());

-- Insert test employee (admin)
INSERT INTO employees (id, full_name, position, email, password, role, work_mode, work_schedule_id) VALUES
  ('00000000-0000-0000-0000-000000000000', 'Администратор Системы', 'Администратор', 'admin@example.com', 
   '$2a$10$X7z3bJwq3Vq3Vq3Vq3Vq3.Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq', 'admin', 'office', 
   (SELECT id FROM work_schedules WHERE name = 'Стандартный график'));

-- Insert test employee (user)
INSERT INTO employees (id, full_name, position, email, password, role, work_mode, work_schedule_id) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Иванов Иван Иванович', 'Разработчик', 'user@example.com', 
   '$2a$10$X7z3bJwq3Vq3Vq3Vq3Vq3.Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq3Vq', 'user', 'hybrid', 
   (SELECT id FROM work_schedules WHERE name = 'Гибкий график'));

-- Insert employee departments
INSERT INTO employee_departments (employee_id, department_id, is_main) VALUES
  ('00000000-0000-0000-0000-000000000000', (SELECT id FROM departments WHERE name = 'Отдел разработки'), true),
  ('11111111-1111-1111-1111-111111111111', (SELECT id FROM departments WHERE name = 'Отдел разработки'), true);

-- Insert employee teams
INSERT INTO employee_teams (employee_id, team_id, is_main) VALUES
  ('00000000-0000-0000-0000-000000000000', (SELECT id FROM teams WHERE name = 'Команда DevOps'), true),
  ('11111111-1111-1111-1111-111111111111', (SELECT id FROM teams WHERE name = 'Команда Frontend'), true);

-- Insert employee projects
INSERT INTO employee_projects (employee_id, project_id, allocation) VALUES
  ('00000000-0000-0000-0000-000000000000', (SELECT id FROM projects WHERE name = 'Портал сотрудников'), 100),
  ('11111111-1111-1111-1111-111111111111', (SELECT id FROM projects WHERE name = 'Портал сотрудников'), 50),
  ('11111111-1111-1111-1111-111111111111', (SELECT id FROM projects WHERE name = 'CRM система'), 50);

-- Insert test presences
INSERT INTO presences (employee_id, type, start_time, end_time, note) VALUES
  ('11111111-1111-1111-1111-111111111111', 'office', 
   '2024-04-10 09:00:00+03', '2024-04-10 18:00:00+03', 'Работа в офисе'),
  ('11111111-1111-1111-1111-111111111111', 'remote', 
   '2024-04-11 10:00:00+03', '2024-04-11 19:00:00+03', 'Удалённая работа'),
  ('11111111-1111-1111-1111-111111111111', 'meeting', 
   '2024-04-12 14:00:00+03', '2024-04-12 15:00:00+03', 'Совещание по проекту'); 