import React from 'react';
import { ChevronRight, Home } from 'lucide-react';
import Container from './Container';

interface BreadcrumbProps {
  items?: { label: string; href?: string }[];
}

const defaultItems: { label: string; href?: string }[] = [{ label: 'Categories' }];

const Breadcrumb: React.FC<BreadcrumbProps> = ({ items = defaultItems }) => {
  return (
    <div className="py-4 bg-[#F8F7FC]">
      <Container>
        <div className="flex items-center gap-2 text-[13px] font-medium text-[#6B7280]">
          <a href="/" className="flex items-center gap-1.5 hover:text-[#FF6B2C] transition-colors">
            <Home size={14} />
            <span>Home</span>
          </a>

          {items.map((item, index) => (
            <React.Fragment key={index}>
              <ChevronRight size={14} className="text-[#ECECEC]" />
              {item.href ? (
                <a href={item.href} className="hover:text-[#FF6B2C] transition-colors">
                  {item.label}
                </a>
              ) : (
                <span className={`font-semibold ${index === items.length - 1 ? 'text-[#111827]' : ''}`}>
                  {item.label}
                </span>
              )}
            </React.Fragment>
          ))}
        </div>
      </Container>
    </div>
  );
};

export default Breadcrumb;
