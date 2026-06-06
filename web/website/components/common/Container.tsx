import React from 'react';

interface ContainerProps {
  children: React.ReactNode;
  className?: string;
}

const Container: React.FC<ContainerProps> = ({ children, className = '' }) => {
  return (
    <div className={`max-w-[1440px] mx-auto px-4 md:px-6 lg:px-10 ${className}`}>
      {children}
    </div>
  );
};

export default Container;
