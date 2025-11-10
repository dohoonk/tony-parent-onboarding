import React from 'react'

export interface LogoProps {
  size?: 'sm' | 'md' | 'lg'
  className?: string
}

export default function Logo({ size = 'md', className = '' }: LogoProps) {
  const sizeClasses = {
    sm: 'h-6 w-auto',
    md: 'h-8 w-auto',
    lg: 'h-12 w-auto',
  }

  return (
    <div className={`${sizeClasses[size]} ${className}`}>
      <span className="font-bold text-primary">Daybreak Health</span>
    </div>
  )
}

