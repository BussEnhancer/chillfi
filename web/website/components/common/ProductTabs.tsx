import React from 'react';

const tabs = [
  { label: 'Description', active: true },
  { label: 'Specifications' },
  { label: 'Reviews (980)' },
  { label: 'FAQs' },
  { label: 'Delivery & Returns' },
];

const ProductTabs: React.FC = () => {
  return (
    <div className="border-b border-[#ECECEC] mb-8">
      <ul className="flex flex-wrap gap-8">
        {tabs.map((tab, i) => (
          <li key={i} className="relative pb-4">
            <button
              className={`text-sm font-bold transition-colors hover:text-[#6C2BFF] ${
                tab.active ? 'text-[#6C2BFF]' : 'text-gray-500'
              }`}
            >
              {tab.label}
            </button>
            {tab.active && (
              <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#6C2BFF]"></div>
            )}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default ProductTabs;
