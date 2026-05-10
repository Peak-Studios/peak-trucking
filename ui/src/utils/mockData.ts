import type { KeyBinds, Language, Mission, PlayerData, Truck, XpTable } from '../types/trucking'

export const mockLanguage: Language = {
  transportation_stage: 'Transportation Stage',
  trailer_quality: 'Trailer Quality',
  truck_fuel: 'Truck Fuel',
  detach_trailer: 'Detach Trailer',
  mark_location: 'Mark Location',
  nts_main: 'NTS Main',
  companies: 'Companies',
  leaderboard: 'Leaderboard',
  profile: 'Profile',
  unlocked: 'Unlocked',
  locked: 'Locked',
  trust_point: 'Trust Point',
  select_route: 'Select a Route',
  select_mission: 'Select Mission',
  daily_missions: 'Daily Missions',
  hour: 'hr',
  completed: 'Completed',
  not_completed: 'Not Completed',
  select_truck: 'Select a Truck',
  get_ready: 'Get Ready for Transport',
  select_your_truck: 'Select your truck',
  select_mission_and_route: 'Select a mission and route',
  start_the_job: 'Start the job',
  stop_job: 'Cancel Job',
  start_job: 'Start Job',
  completed_jobs: 'Completed Jobs',
  total_missions_completed: 'Total missions completed for National Transfer & Storage.',
  total_earnings: 'Total Earnings',
  total_earnings_desc: 'Total cash earned from completed trucking routes.',
  current_level: 'Current Level',
  latest_works: 'Latest Works',
  earned: 'Earned',
}

export const mockKeyBinds: KeyBinds = {
  mark_location: { label: 'G', key: 133 },
}

export const mockXp: XpTable = Array.from({ length: 100 }, (_, index) => (index + 1) * 1000)

export const mockTrucks: Truck[] = [
  { name: 'packer', image: 'truck-1.png', label: 'Packer', level: 1 },
  { name: 'hauler', image: 'truck-2.png', label: 'Hauler', level: 5 },
  { name: 'phantom3', image: 'truck-3.png', label: 'Phantom Classic', level: 10 },
  { name: 'mule3', image: 'truck-4.png', label: 'Armored Mule', level: 15 },
]

export const mockMissions: Mission[] = [
  {
    id: 1,
    image: 'map_1.png',
    small_image: 'map_1_small.png',
    header: 'Paleto Forest Samwill Woods',
    companyIndex: 0,
    payment: 2500,
    reqPoint: 10,
    routes: [
      { label: 'LS Dock - Paleto Route', vehicle: ['hauler', 'packer', 'phantom3'], extraPayment: 0 },
      { label: 'Grapeseed - Paleto Route', vehicle: ['hauler', 'packer'], reqPoint: 5, extraPayment: 250 },
    ],
    requirementsLabel: [
      { label: 'Wood Supply', icon: 'supply-icon.svg' },
      { label: '$2,500 Profit', icon: 'profit-icon.svg' },
      { label: '2 Routes', icon: 'route-icon.svg' },
      { label: '+1 Trust', icon: 'trust-icon.svg' },
    ],
  },
  {
    id: 2,
    image: 'map_2.png',
    small_image: 'map_2_small.png',
    header: 'Sandy Shores Freight Transfer',
    companyIndex: 1,
    payment: 4200,
    reqPoint: 12,
    routes: [
      { label: 'Dockyard - Sandy Route', vehicle: ['packer', 'phantom3'], extraPayment: 350 },
      { label: 'Grapeseed - Sandy Route', vehicle: ['mule3', 'packer'], reqPoint: 3 },
    ],
    requirementsLabel: [
      { label: 'Grain Supply', icon: 'supply-icon.svg' },
      { label: '$4,200 Profit', icon: 'profit-icon.svg' },
      { label: '2 Routes', icon: 'route-icon.svg' },
      { label: '+1 Trust', icon: 'trust-icon.svg' },
    ],
  },
]

export const mockPlayerData: PlayerData = {
  name: 'Alex Morgan',
  avatar: './assets/images/test-pp.png',
  level: 12,
  xp: 3200,
  totalEarnings: 85600,
  completedJobs: 28,
  unlockedMissions: { '1': true, '2': true },
  points: { '0': 14, '1': 7, '2': 3, '3': 5, '4': 1, '5': 0, '6': 0, '7': 0 },
  dailymissions: {
    resetAt: Math.floor(Date.now() / 1000) + 21600,
    data: {
      complete_mission: { header: 'Complete One Mission', label: 'Finish one delivery.', max: 1, process: 0, xp: 2500 },
      on_the_roads: { header: 'On The Roads', label: 'Transport goods for 30 minutes.', max: 30, process: 18, xp: 2500 },
    },
  },
  history: [
    { label: 'Paleto Forest Samwill Woods', supply: 'Wood Supply', earn: 2500, date: Math.floor(Date.now() / 1000) - 86400 },
    { label: 'Sandy Shores Freight Transfer', supply: 'Grain Supply', earn: 4200, date: Math.floor(Date.now() / 1000) - 172800 },
  ],
}
