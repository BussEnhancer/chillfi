import React from 'react';
import { ChevronDown, ChevronRight } from 'lucide-react';

interface CategoryNode {
  label: string;
  count?: number;
  children?: CategoryNode[];
  isActive?: boolean;
}

const treeData: CategoryNode[] = [
  {
    label: 'Men',
    isActive: true,
    children: [
      { label: 'Topwear' },
      { label: 'Bottomwear' },
      {
        label: 'Footwear',
        isActive: true,
        children: [
          { label: 'Casual Shoes' },
          { label: 'Sports Shoes' },
          { label: 'Sneakers', isActive: true },
          { label: 'Sandals & Floaters' },
          { label: 'Formal Shoes' },
        ],
      },
    ],
  },
  { label: 'Watches' },
  { label: 'Bags & Backpacks' },
  { label: 'Sunglasses & Frames' },
  { label: 'Personal Care' },
];

const CategoryTree: React.FC = () => {
  const renderTree = (nodes: CategoryNode[], level = 0) => {
    return (
      <ul className={`${level > 0 ? 'ml-4 mt-2 space-y-2' : 'space-y-3'}`}>
        {nodes.map((node, i) => (
          <li key={i}>
            <div className={`flex items-center justify-between group cursor-pointer`}>
              <div className="flex items-center gap-2">
                {node.children && (
                  <ChevronDown size={14} className={node.isActive ? 'text-[#6C2BFF]' : 'text-gray-400'} />
                )}
                <span className={`text-sm font-bold transition-colors ${
                  node.isActive && !node.children ? 'text-[#6C2BFF]' : 'text-gray-700 hover:text-[#6C2BFF]'
                }`}>
                  {node.label}
                </span>
              </div>
              {node.isActive && !node.children && (
                <div className="w-1.5 h-1.5 rounded-full bg-[#6C2BFF]"></div>
              )}
            </div>
            {node.children && node.isActive && renderTree(node.children, level + 1)}
          </li>
        ))}
      </ul>
    );
  };

  return (
    <div className="mb-8">
      <h3 className="text-sm font-black text-[#111827] uppercase tracking-wider mb-6">Categories</h3>
      {renderTree(treeData)}
    </div>
  );
};

export default CategoryTree;
