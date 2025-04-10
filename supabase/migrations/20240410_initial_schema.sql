-- Create departments table
CREATE TABLE departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create teams table
CREATE TABLE teams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create projects table
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create work schedules table
CREATE TABLE work_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  working_days TEXT[] NOT NULL,
  working_hours JSONB NOT NULL,
  breaks JSONB[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create production calendar table
CREATE TABLE production_calendar (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  year INTEGER NOT NULL,
  holidays DATE[] NOT NULL,
  working_days DATE[] NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create employees table
CREATE TABLE employees (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  full_name TEXT NOT NULL,
  position TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'user')),
  work_mode TEXT NOT NULL CHECK (work_mode IN ('office', 'remote', 'hybrid')),
  work_schedule_id UUID REFERENCES work_schedules(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create employee_departments table
CREATE TABLE employee_departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id UUID NOT NULL REFERENCES employees(id),
  department_id UUID NOT NULL REFERENCES departments(id),
  is_main BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(employee_id, department_id)
);

-- Create employee_teams table
CREATE TABLE employee_teams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id UUID NOT NULL REFERENCES employees(id),
  team_id UUID NOT NULL REFERENCES teams(id),
  is_main BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(employee_id, team_id)
);

-- Create employee_projects table
CREATE TABLE employee_projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id UUID NOT NULL REFERENCES employees(id),
  project_id UUID NOT NULL REFERENCES projects(id),
  allocation INTEGER NOT NULL CHECK (allocation >= 0 AND allocation <= 100 AND allocation % 10 = 0),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(employee_id, project_id)
);

-- Create presences table
CREATE TABLE presences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id UUID NOT NULL REFERENCES employees(id),
  type TEXT NOT NULL CHECK (type IN ('office', 'remote', 'vacation', 'sick', 'business_trip', 'meeting')),
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create RLS policies
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE presences ENABLE ROW LEVEL SECURITY;

-- Employees policies
CREATE POLICY "Employees can view their own data"
  ON employees FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all employee data"
  ON employees FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM employees
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Employee departments policies
CREATE POLICY "Employees can view their own department data"
  ON employee_departments FOR SELECT
  USING (employee_id = auth.uid());

CREATE POLICY "Admins can view all department data"
  ON employee_departments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM employees
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Employee teams policies
CREATE POLICY "Employees can view their own team data"
  ON employee_teams FOR SELECT
  USING (employee_id = auth.uid());

CREATE POLICY "Admins can view all team data"
  ON employee_teams FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM employees
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Employee projects policies
CREATE POLICY "Employees can view their own project data"
  ON employee_projects FOR SELECT
  USING (employee_id = auth.uid());

CREATE POLICY "Admins can view all project data"
  ON employee_projects FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM employees
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Presences policies
CREATE POLICY "Employees can view their own presence data"
  ON presences FOR SELECT
  USING (employee_id = auth.uid());

CREATE POLICY "Admins can view all presence data"
  ON presences FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM employees
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Create indexes
CREATE INDEX idx_employee_departments_employee_id ON employee_departments(employee_id);
CREATE INDEX idx_employee_departments_department_id ON employee_departments(department_id);
CREATE INDEX idx_employee_teams_employee_id ON employee_teams(employee_id);
CREATE INDEX idx_employee_teams_team_id ON employee_teams(team_id);
CREATE INDEX idx_employee_projects_employee_id ON employee_projects(employee_id);
CREATE INDEX idx_employee_projects_project_id ON employee_projects(project_id);
CREATE INDEX idx_presences_employee_id ON presences(employee_id);
CREATE INDEX idx_presences_start_time ON presences(start_time);
CREATE INDEX idx_presences_end_time ON presences(end_time); 