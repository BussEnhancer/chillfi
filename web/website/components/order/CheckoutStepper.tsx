import React from 'react';
import { Check } from 'lucide-react';

interface Step {
  title: string;
  subtitle: string;
}

const steps: Step[] = [
  { title: 'Address', subtitle: 'Select delivery address' },
  { title: 'Delivery', subtitle: 'Choose delivery method' },
  { title: 'Payment', subtitle: 'Select payment option' },
  { title: 'Review', subtitle: 'Review and place order' },
];

const CheckoutStepper: React.FC = () => {
  const currentStep = 1;

  return (
    <div className="py-10">
      <div className="flex flex-col md:flex-row items-center justify-between gap-6">
        {steps.map((step, index) => {
          const stepNumber = index + 1;
          const isActive = stepNumber === currentStep;
          const isCompleted = stepNumber < currentStep;

          return (
            <React.Fragment key={index}>
              <div className="flex items-center gap-4 flex-1">
                <div
                  className={`w-10 h-10 rounded-full flex items-center justify-center text-sm font-black transition-all ${
                    isActive ? 'bg-[#6C2BFF] text-white shadow-lg shadow-[#6C2BFF]/30' :
                    isCompleted ? 'bg-[#16A34A] text-white' : 'bg-gray-100 text-gray-400'
                  }`}
                >
                  {isCompleted ? <Check size={18} /> : stepNumber}
                </div>
                <div>
                  <h4 className={`text-sm font-black ${isActive ? 'text-[#111827]' : 'text-gray-400'}`}>{step.title}</h4>
                  <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">{step.subtitle}</p>
                </div>
              </div>
              {index < steps.length - 1 && (
                <div className="hidden lg:block w-12 h-[2px] bg-gray-100"></div>
              )}
            </React.Fragment>
          );
        })}
      </div>
    </div>
  );
};

export default CheckoutStepper;
