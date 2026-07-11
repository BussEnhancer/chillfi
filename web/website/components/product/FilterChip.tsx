import React from 'react';
import { X } from 'lucide-react';

interface FilterChipProps {
  label: string;
  onRemove?: () => void;
}

const FilterChip: React.FC<FilterChipProps> = ({ label, onRemove }) => {
  return (
    <div className="flex items-center gap-2 bg-[#F8F7FC] border border-[#ECECEC] px-3 py-1.5 rounded-lg group hover:border-[#FF6B2C] transition-all">
      <span className="text-xs font-bold text-gray-700">{label}</span>
      <button
        onClick={onRemove}
        className="text-gray-400 hover:text-[#FF4D4F] transition-colors"
      >
        <X size={14} />
      </button>
    </div>
  );
};

export default FilterChip;
