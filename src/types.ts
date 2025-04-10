export type WorkMode = 'office' | 'remote' | 'hybrid';
export type UserRole = 'admin' | 'user';
export type PresenceType = 'office' | 'remote' | 'vacation' | 'sick' | 'business_trip' | 'meeting';

export interface Employee {
  id: string;
  fullName: string;
  position: string;
  departments: DepartmentAllocation[];
  mainDepartment: string;
  projects: ProjectAllocation[];
  teams: TeamAllocation[];
  mainTeam: string;
  email: string;
  password: string;
  role: UserRole;
  workMode: WorkMode;
  workSchedule: WorkSchedule;
  presence: Presence[];
}

export interface DepartmentAllocation {
  departmentId: string;
  departmentName: string;
  isMain: boolean;
}

export interface ProjectAllocation {
  projectId: string;
  projectName: string;
  allocation: number; // Percentage in multiples of 10
}

export interface TeamAllocation {
  teamId: string;
  teamName: string;
  isMain: boolean;
}

export interface WorkSchedule {
  id: string;
  name: string;
  workingDays: string[]; // ['monday', 'tuesday', ...]
  workingHours: {
    start: string; // '09:00'
    end: string;   // '18:00'
  };
  breaks: {
    start: string;
    end: string;
  }[];
}

export interface ProductionCalendar {
  id: string;
  year: number;
  holidays: Date[];
  workingDays: Date[];
}

export interface Presence {
  id: string;
  employeeId: string;
  type: PresenceType;
  startTime: Date;
  endTime: Date;
  note?: string;
}