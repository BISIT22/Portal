import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { supabase } from '../lib/supabaseClient';
import { Presence, PresenceType } from '../types';
import { Calendar as CalendarIcon, Clock, MapPin, Briefcase, Plane, Stethoscope, Users } from 'lucide-react';

export function Calendar() {
  const { user } = useAuth();
  const [presences, setPresences] = useState<Presence[]>([]);
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      fetchPresences();
    }
  }, [user, selectedDate]);

  const fetchPresences = async () => {
    try {
      const startOfDay = new Date(selectedDate);
      startOfDay.setHours(0, 0, 0, 0);
      
      const endOfDay = new Date(selectedDate);
      endOfDay.setHours(23, 59, 59, 999);

      const { data, error } = await supabase
        .from('presences')
        .select('*')
        .eq('employeeId', user?.id)
        .gte('startTime', startOfDay.toISOString())
        .lte('endTime', endOfDay.toISOString())
        .order('startTime', { ascending: true });

      if (error) throw error;
      setPresences(data || []);
    } catch (error) {
      console.error('Error fetching presences:', error);
    } finally {
      setLoading(false);
    }
  };

  const getPresenceIcon = (type: PresenceType) => {
    switch (type) {
      case 'office':
        return <MapPin className="h-5 w-5 text-blue-500" />;
      case 'remote':
        return <Briefcase className="h-5 w-5 text-green-500" />;
      case 'vacation':
        return <Plane className="h-5 w-5 text-yellow-500" />;
      case 'sick':
        return <Stethoscope className="h-5 w-5 text-red-500" />;
      case 'business_trip':
        return <Briefcase className="h-5 w-5 text-purple-500" />;
      case 'meeting':
        return <Users className="h-5 w-5 text-indigo-500" />;
      default:
        return null;
    }
  };

  const getPresenceLabel = (type: PresenceType) => {
    switch (type) {
      case 'office':
        return 'В офисе';
      case 'remote':
        return 'Удалённо';
      case 'vacation':
        return 'Отпуск';
      case 'sick':
        return 'Больничный';
      case 'business_trip':
        return 'Командировка';
      case 'meeting':
        return 'Встреча';
      default:
        return type;
    }
  };

  if (loading) {
    return <div className="p-4">Загрузка...</div>;
  }

  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="bg-white rounded-lg shadow-lg overflow-hidden">
        <div className="bg-gradient-to-r from-blue-500 to-blue-600 px-6 py-4">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-white">Календарь</h1>
            <div className="flex items-center space-x-2">
              <CalendarIcon className="h-6 w-6 text-white" />
              <input
                type="date"
                value={selectedDate.toISOString().split('T')[0]}
                onChange={(e) => setSelectedDate(new Date(e.target.value))}
                className="bg-transparent border-none text-white focus:outline-none"
              />
            </div>
          </div>
        </div>

        <div className="p-6">
          {presences.length === 0 ? (
            <div className="text-center text-gray-500 py-8">
              Нет записей на выбранную дату
            </div>
          ) : (
            <div className="space-y-4">
              {presences.map((presence) => (
                <div
                  key={presence.id}
                  className="flex items-center p-4 bg-gray-50 rounded-lg"
                >
                  <div className="flex-shrink-0">
                    {getPresenceIcon(presence.type)}
                  </div>
                  <div className="ml-4 flex-1">
                    <div className="flex items-center justify-between">
                      <h3 className="text-lg font-medium">
                        {getPresenceLabel(presence.type)}
                      </h3>
                      <div className="flex items-center text-sm text-gray-500">
                        <Clock className="h-4 w-4 mr-1" />
                        {new Date(presence.startTime).toLocaleTimeString()} -{' '}
                        {new Date(presence.endTime).toLocaleTimeString()}
                      </div>
                    </div>
                    {presence.note && (
                      <p className="mt-1 text-sm text-gray-500">{presence.note}</p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}