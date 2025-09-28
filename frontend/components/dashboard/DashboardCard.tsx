import React from 'react';

interface DashboardCardProps {
  title: string;
  value?: string | number;
  subtitle?: string;
  icon?: React.ReactNode;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  children?: React.ReactNode;
  className?: string;
}

export function DashboardCard({
  title,
  value,
  subtitle,
  icon,
  trend,
  children,
  className = '',
}: DashboardCardProps) {
  return (
    <div
      className={`bg-slate-800 rounded-lg p-6 border border-slate-700 hover:border-slate-600 transition-colors ${className}`}
    >
      <div className="flex items-start justify-between mb-4">
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-slate-200">{title}</h3>
          {subtitle && (
            <p className="text-sm text-slate-400 mt-1">{subtitle}</p>
          )}
        </div>
        {icon && (
          <div className="text-slate-400 ml-4">
            {icon}
          </div>
        )}
      </div>

      {value !== undefined && (
        <div className="mb-4">
          <p className="text-3xl font-bold text-slate-100">{value}</p>
          {trend && (
            <div className="flex items-center mt-2">
              <span
                className={`text-sm font-medium ${
                  trend.isPositive ? 'text-green-400' : 'text-red-400'
                }`}
              >
                {trend.isPositive ? '↑' : '↓'} {Math.abs(trend.value)}%
              </span>
              <span className="text-sm text-slate-400 ml-2">前回比</span>
            </div>
          )}
        </div>
      )}

      {children && (
        <div className="mt-4">
          {children}
        </div>
      )}
    </div>
  );
}