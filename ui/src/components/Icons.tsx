import type { PropsWithChildren } from 'react'

type IconProps = {
  className?: string
}

export function Icon({ children, className }: PropsWithChildren<IconProps>) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" aria-hidden="true">
      {children}
    </svg>
  )
}

export function TruckIcon({ className }: IconProps) {
  return (
    <Icon className={className}>
      <path d="M3 7h11v9H3V7Z" stroke="currentColor" strokeWidth="1.8" />
      <path d="M14 10h3.7l2.3 2.7V16h-6v-6Z" stroke="currentColor" strokeWidth="1.8" />
      <path d="M6.5 18.5a1.8 1.8 0 1 0 0-3.6 1.8 1.8 0 0 0 0 3.6ZM17.5 18.5a1.8 1.8 0 1 0 0-3.6 1.8 1.8 0 0 0 0 3.6Z" stroke="currentColor" strokeWidth="1.8" />
    </Icon>
  )
}

export function RouteIcon({ className }: IconProps) {
  return (
    <Icon className={className}>
      <path d="M6 18c3.2-7.8 8.8-.2 12-12" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
      <circle cx="6" cy="18" r="2" stroke="currentColor" strokeWidth="1.8" />
      <circle cx="18" cy="6" r="2" stroke="currentColor" strokeWidth="1.8" />
    </Icon>
  )
}

export function ShieldIcon({ className }: IconProps) {
  return (
    <Icon className={className}>
      <path d="M12 3 19 6v5.5c0 4.2-2.8 7.5-7 9.5-4.2-2-7-5.3-7-9.5V6l7-3Z" stroke="currentColor" strokeWidth="1.8" />
      <path d="m9 12 2 2 4-5" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </Icon>
  )
}

export function ChevronIcon({ className }: IconProps) {
  return (
    <Icon className={className}>
      <path d="m9 5 7 7-7 7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
    </Icon>
  )
}
