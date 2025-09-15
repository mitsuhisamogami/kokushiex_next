import React from 'react';

interface BaseButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
  className?: string;
  variant?: 'primary' | 'outline';
  size?: 'sm' | 'md' | 'lg';
  type?: 'button' | 'submit' | 'reset';
}

export function BaseButton({
  children,
  onClick,
  disabled = false,
  className = '',
  variant = 'primary',
  size = 'md',
  type = 'button'
}: BaseButtonProps) {
  const baseClasses = 'group relative font-semibold rounded-full transition-all duration-300 overflow-hidden inline-block text-center focus:outline-none focus:ring-2 focus:ring-offset-2';

  const variantClasses = {
    primary: 'bg-gradient-to-r from-blue-600 to-blue-700 text-white hover:-translate-y-1 hover:shadow-xl hover:shadow-blue-500/25 focus:ring-blue-500',
    outline: 'border-2 border-blue-400 text-blue-400 hover:bg-blue-400/10 hover:-translate-y-1 focus:ring-blue-400'
  };

  const sizeClasses = {
    sm: 'px-4 py-2 text-sm',
    md: 'px-6 py-3 text-base',
    lg: 'px-8 py-4 text-lg'
  };

  const buttonClasses = `${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${className} ${
    disabled ? 'opacity-50 cursor-not-allowed' : ''
  }`;

  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={buttonClasses}
    >
      {variant === 'primary' && (
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-500"></div>
      )}
      <span className="relative z-10">{children}</span>
    </button>
  );
}