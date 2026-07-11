import React from 'react';

const tabs = [
  { label: 'All Coupons', count: 28, active: true },
  { label: 'Sitewide Offers', count: 6 },
  { label: 'Category Offers', count: 12 },
  { label: 'Bank Offers', count: 8 },
  { label: 'Partner Offers', count: 2 },
];

const OfferTabs: React.FC = () => {
  return (
    <div className="border-b border-[#ECECEC] mb-8 overflow-x-auto scrollbar-hide">
      <ul className="flex items-center gap-10 whitespace-nowrap min-w-max">
        {tabs.map((tab, i) => (
          <li key={i} className="relative pb-4">
            <button className="flex items-center gap-2 group">
              <span className={`text-sm font-black transition-colors ${
                tab.active ? 'text-[#FF6B2C]' : 'text-gray-400 group-hover:text-gray-600'
              }`}>
                {tab.label}
              </span>
              <span className={`text-[10px] font-bold px-2 py-0.5 rounded-md ${
                tab.active ? 'bg-[#FF6B2C]/10 text-[#FF6B2C]' : 'bg-gray-100 text-gray-400'
              }`}>
                ({tab.count})
              </span>
            </button>
            {tab.active && (
              <div className="absolute bottom-0 left-0 right-0 h-1 bg-[#FF6B2C] rounded-t-full"></div>
            )}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default OfferTabs;
