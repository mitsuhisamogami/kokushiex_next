'use client';

import { useRouter } from 'next/navigation';

interface QuickAction {
  label: string;
  description: string;
  href: string;
  icon?: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'outline';
}

interface QuickActionButtonsProps {
  actions: QuickAction[];
}

export function QuickActionButtons({ actions }: QuickActionButtonsProps) {
  const router = useRouter();

  const getButtonClasses = (variant: QuickAction['variant'] = 'secondary') => {
    const baseClasses = 'flex flex-col items-center justify-center p-6 rounded-lg transition-all hover:scale-105';

    const variantClasses = {
      primary: 'bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white border border-blue-600',
      secondary: 'bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700',
      outline: 'bg-transparent hover:bg-slate-800/50 text-slate-300 border border-slate-600',
    };

    return `${baseClasses} ${variantClasses[variant]}`;
  };

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
      {actions.map((action, index) => (
        <button
          key={index}
          onClick={() => router.push(action.href)}
          className={getButtonClasses(action.variant)}
        >
          {action.icon && (
            <div className="mb-3 text-3xl">
              {action.icon}
            </div>
          )}
          <h3 className="font-semibold text-lg mb-1">{action.label}</h3>
          <p className="text-sm opacity-80 text-center">{action.description}</p>
        </button>
      ))}
    </div>
  );
}