import React from 'react';
import { Wrench } from 'lucide-react';

interface MaintenancePageProps {
  message: string;
}

const MaintenancePage: React.FC<MaintenancePageProps> = ({ message }) => (
  <div className="min-h-screen bg-white flex items-center justify-center px-6 font-['Poppins']">
    <div className="max-w-md text-center">
      <div className="w-20 h-20 rounded-full bg-[#FFF1E9] flex items-center justify-center mx-auto mb-6">
        <Wrench size={36} className="text-[#FF6B2C]" />
      </div>
      <h1 className="text-2xl font-black text-[#111827] mb-3">We'll be right back</h1>
      <p className="text-gray-500 font-medium">{message}</p>
    </div>
  </div>
);

export default MaintenancePage;
