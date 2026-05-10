export type Page = 'main' | 'companies' | 'leaderboard' | 'profile'

export type Requirement = {
  label: string
  icon: string
}

export type Route = {
  label: string
  vehicle: string[]
  reqPoint?: number
  extraPayment?: number
}

export type Mission = {
  id: number
  image: string
  small_image?: string
  header: string
  companyIndex: number
  payment: number
  reqPoint?: number
  reqLevel?: number
  routes: Route[]
  requirementsLabel: Requirement[]
}

export type Truck = {
  name: string
  image: string
  label: string
  level: number
  desc?: string
}

export type DailyMission = {
  header: string
  label: string
  max: number
  xp: number
  process: number
}

export type PlayerData = {
  identifier?: string
  points?: Record<string, number>
  history?: HistoryEntry[]
  unlockedMissions?: Record<string, boolean>
  dailymissions?: {
    data: Record<string, DailyMission>
    resetAt: number
  }
  xp?: number
  name?: string
  totalEarnings?: number
  completedJobs?: number
  level?: number
  avatar?: string
}

export type HistoryEntry = {
  label: string
  supply: string
  earn: number
  date: number
}

export type JobInfo = {
  started?: boolean
  attachedTrailer?: boolean
  bodyHealth?: number
  fuel?: number
  routeHeader?: string
}

export type LeaderboardEntry = {
  name: string
  avatar?: string
  level: number
}

export type Language = Record<string, string>
export type XpTable = Record<number, number> | number[]

export type KeyBinds = {
  mark_location?: {
    label: string
    key: number
  }
}
