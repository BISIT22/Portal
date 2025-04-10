import React, { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { supabase } from '../lib/supabaseClient';
import { Building2, Clock, Users, Briefcase } from 'lucide-react';
import { Employee, DepartmentAllocation, ProjectAllocation, TeamAllocation, WorkSchedule } from '../types';

export function Profile() {
  const { user } = useAuth();
  const [profile, setProfile] = useState<Employee | null>(null);
  const [departments, setDepartments] = useState<DepartmentAllocation[]>([]);
  const [teams, setTeams] = useState<TeamAllocation[]>([]);
  const [projects, setProjects] = useState<ProjectAllocation[]>([]);
  const [workSchedule, setWorkSchedule] = useState<WorkSchedule | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState<Partial<Employee>>({});

  useEffect(() => {
    if (user) {
      fetchProfile();
    }
  }, [user]);

  const fetchProfile = async () => {
    try {
      const { data: employee, error } = await supabase
        .from('employees')
        .select(`
          *,
          departments:employee_departments(department_id, department_name, is_main),
          teams:employee_teams(team_id, team_name, is_main),
          projects:employee_projects(project_id, project_name, allocation),
          work_schedule:work_schedules(*)
        `)
        .eq('id', user?.id)
        .single();

      if (error) throw error;

      setProfile(employee);
      setFormData(employee);
      setDepartments(employee.departments || []);
      setTeams(employee.teams || []);
      setProjects(employee.projects || []);
      setWorkSchedule(employee.work_schedule || null);
    } catch (error) {
      console.error('Error fetching profile:', error);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const { error } = await supabase
        .from('employees')
        .update({
          fullName: formData.fullName,
          workMode: formData.workMode,
          workSchedule: formData.workSchedule,
        })
        .eq('id', user?.id);

      if (error) throw error;

      setIsEditing(false);
      fetchProfile();
    } catch (error) {
      console.error('Error updating profile:', error);
    }
  };

  if (!profile) {
    return <div className="p-4">Loading...</div>;
  }

  const mainDepartment = departments.find(d => d.isMain);
  const mainTeam = teams.find(t => t.isMain);

  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="bg-white rounded-lg shadow-lg overflow-hidden">
        <div className="bg-gradient-to-r from-blue-500 to-blue-600 px-6 py-4">
          <h1 className="text-2xl font-bold text-white">Мой профиль</h1>
        </div>

        <div className="p-6">
          {!isEditing ? (
            <div className="space-y-6">
              <div className="flex items-center space-x-4">
                <div className="h-20 w-20 rounded-full bg-blue-100 flex items-center justify-center">
                  <span className="text-2xl font-bold text-blue-600">
                    {profile.fullName.split(' ').map(n => n[0]).join('')}
                  </span>
                </div>
                <div>
                  <h2 className="text-xl font-semibold">{profile.fullName}</h2>
                  <p className="text-gray-600">{profile.position}</p>
                  <p className="text-gray-500">{profile.email}</p>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
                <div className="space-y-4">
                  <div className="flex items-center space-x-3">
                    <Building2 className="h-5 w-5 text-blue-500" />
                    <div>
                      <p className="text-sm text-gray-500">Основной отдел</p>
                      <p className="font-medium">{mainDepartment?.departmentName || 'Не назначен'}</p>
                    </div>
                  </div>

                  <div className="flex items-center space-x-3">
                    <Users className="h-5 w-5 text-blue-500" />
                    <div>
                      <p className="text-sm text-gray-500">Основная команда</p>
                      <p className="font-medium">{mainTeam?.teamName || 'Не назначена'}</p>
                    </div>
                  </div>

                  <div className="flex items-center space-x-3">
                    <Clock className="h-5 w-5 text-blue-500" />
                    <div>
                      <p className="text-sm text-gray-500">График работы</p>
                      <p className="font-medium">{workSchedule?.name || 'Не назначен'}</p>
                    </div>
                  </div>
                </div>

                <div className="space-y-4">
                  <div>
                    <p className="text-sm text-gray-500 mb-2">Проекты</p>
                    <div className="space-y-2">
                      {projects.map(project => (
                        <div key={project.projectId} className="flex items-center space-x-3">
                          <Briefcase className="h-5 w-5 text-blue-500" />
                          <div>
                            <p className="font-medium">{project.projectName}</p>
                            <p className="text-sm text-gray-500">Участие: {project.allocation}%</p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              <div className="mt-6">
                <button
                  onClick={() => setIsEditing(true)}
                  className="bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600 transition-colors"
                >
                  Редактировать профиль
                </button>
              </div>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">ФИО</label>
                <input
                  type="text"
                  value={formData.fullName || ''}
                  onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Режим работы</label>
                <select
                  value={formData.workMode || ''}
                  onChange={(e) => setFormData({ ...formData, workMode: e.target.value as any })}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                >
                  <option value="office">Офис</option>
                  <option value="remote">Удалённо</option>
                  <option value="hybrid">Гибрид</option>
                </select>
              </div>

              <div className="flex space-x-4">
                <button
                  type="submit"
                  className="bg-blue-500 text-white px-4 py-2 rounded-md hover:bg-blue-600 transition-colors"
                >
                  Сохранить изменения
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setIsEditing(false);
                    setFormData(profile);
                  }}
                  className="bg-gray-200 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-300 transition-colors"
                >
                  Отмена
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}