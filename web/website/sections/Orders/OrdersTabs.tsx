import React from 'react';

const tabs = [
  { label: 'All Orders', count: 24, active: true },
  { label: 'Processing', count: 3 },
  { label: 'Shipped', count: 4 },
  { label: 'Out for Delivery', count: 2 },
  { label: 'Delivered', count: 18 },
  { label: 'Cancelled', count: 3 },
  { label: 'Returned', count: 2 },
];

const OrdersTabs: React.FC = () => {
  return (
    <div className="border-b border-[#ECECEC] mb-8 overflow-x-auto scrollbar-hide">
      <ul className="flex items-center gap-10 whitespace-nowrap min-w-max">
        {tabs.map((tab, i) => (
          <li key={i} className="relative pb-4">
            <button className={`flex flex-col items-center gap-1 group`}>
               <span className={`text-sm font-black transition-colors ${
                 tab.active ? 'text-[#6C2BFF]' : 'text-gray-400 group-hover:text-gray-600'
               }`}>
                 {tab.label}
               </span>
               <span className={`text-[10px] font-bold ${tab.active ? 'text-[#6C2BFF]' : 'text-gray-400'}`}>
                 {tab.count}
               </span>
            </button>
            {tab.active && (
              <div className="absolute bottom-0 left-0 right-0 h-1 bg-[#6C2BFF] rounded-t-full"></div>
            )}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default OrdersTabs;
