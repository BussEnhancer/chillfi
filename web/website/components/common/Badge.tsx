import React from 'react';

interface BadgeProps {
  text: string;
  className?: string;
  type?: 'discount' | 'new' | 'hot';
}

const Badge: React.FC<BadgeProps> = ({ text, className = '', type = 'discount' }) => {
  const types = {
    discount: 'bg-[#FF5252] text-white',
    new: 'bg-[#00C853] text-white',
    hot: 'bg-[#FF6B2C] text-white',
  };

  return (
    <div className={`px-2 py-1 rounded-md text-[10px] font-bold uppercase tracking-wider ${types[type]} ${className}`}>
      {text}
    </div>
  );
};

export default Badge;
