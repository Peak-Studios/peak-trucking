import { useCallback, useEffect, useMemo, useState } from 'react'
import type { JobInfo, KeyBinds, Language, Mission, Page, PlayerData, Route, Truck, XpTable } from './types/trucking'
import { useNuiEvent } from './hooks/useNuiEvent'
import { fetchNui, isFiveM } from './utils/nui'
import { mockKeyBinds, mockLanguage, mockMissions, mockPlayerData, mockTrucks, mockXp } from './utils/mockData'
import { DispatchView } from './components/DispatchView'
import { CompaniesView } from './components/CompaniesView'
import { ProfileView } from './components/ProfileView'
import { LeaderboardView } from './components/LeaderboardView'
import { JobHud } from './components/JobHud'
import { NotificationStack } from './components/NotificationStack'
import { PhoneCall } from './components/PhoneCall'
import { TruckIcon } from './components/Icons'

type SyncPayload = {
  key: keyof PlayerData
  value: PlayerData[keyof PlayerData]
}

type JobPayload = {
  key: keyof JobInfo
  value: JobInfo[keyof JobInfo]
}

const initialOpen = !isFiveM()

export default function App() {
  const [isOpen, setIsOpen] = useState(initialOpen)
  const [activePage, setActivePage] = useState<Page>('main')
  const [missions, setMissions] = useState<Mission[]>(isFiveM() ? [] : mockMissions)
  const [trucks, setTrucks] = useState<Truck[]>(isFiveM() ? [] : mockTrucks)
  const [trucksCopy, setTrucksCopy] = useState<Truck[]>(isFiveM() ? [] : mockTrucks)
  const [playerData, setPlayerData] = useState<PlayerData>(isFiveM() ? {} : mockPlayerData)
  const [jobInfo, setJobInfo] = useState<JobInfo>({})
  const [language, setLanguage] = useState<Language>(isFiveM() ? {} : mockLanguage)
  const [xp, setXp] = useState<XpTable>(isFiveM() ? [] : mockXp)
  const [keybinds, setKeybinds] = useState<KeyBinds>(isFiveM() ? {} : mockKeyBinds)
  const [notifications, setNotifications] = useState<string[]>([])
  const [showPhone, setShowPhone] = useState(false)
  const [selectedMission, setSelectedMission] = useState<Mission | undefined>()
  const [selectedRoute, setSelectedRoute] = useState<Route | undefined>()
  const [selectedTruck, setSelectedTruck] = useState<Truck | undefined>()
  const [selectedCompany, setSelectedCompany] = useState(0)

  const notify = useCallback((message: string) => {
    setNotifications((current) => [...current, message])
    window.setTimeout(() => {
      setNotifications((current) => current.slice(1))
    }, 3200)
  }, [])

  useNuiEvent<void>('open', useCallback(() => setIsOpen(true), []))
  useNuiEvent<void>('close', useCallback(() => setIsOpen(false), []))
  useNuiEvent<void>('checknui', useCallback(() => void fetchNui('ready'), []))
  useNuiEvent<Mission[]>('set_missions', useCallback((payload) => setMissions(payload ?? []), []))
  useNuiEvent<Truck[]>('setTrucks', useCallback((payload) => setTrucks(payload ?? []), []))
  useNuiEvent<Truck[]>('setTrucksCopy', useCallback((payload) => setTrucksCopy(payload ?? []), []))
  useNuiEvent<XpTable>('setXP', useCallback((payload) => setXp(payload ?? []), []))
  useNuiEvent<Language>('setLanguage', useCallback((payload) => setLanguage(payload ?? {}), []))
  useNuiEvent<KeyBinds>('setKeyBinds', useCallback((payload) => setKeybinds(payload ?? {}), []))
  useNuiEvent<string>('createNotification', useCallback((payload) => payload && notify(payload), [notify]))
  useNuiEvent<SyncPayload>('SyncPlayerDataByKey', useCallback((payload) => {
    if (!payload?.key) return
    setPlayerData((current) => ({ ...current, [payload.key]: payload.value }))
  }, []))
  useNuiEvent<JobPayload>('setJobInfo', useCallback((payload) => {
    if (!payload?.key) return
    setJobInfo((current) => ({ ...current, [payload.key]: payload.value }))
  }, []))
  useNuiEvent<void>('callillegal', useCallback(() => {
    setShowPhone(true)
    void playSound('./mTruckerjob-Ringtone.mp3', 0.4)
  }, []))
  useNuiEvent<void>('acceptillegal', useCallback(() => {
    void playSound('./trevor-phonecall.mp3', 0.4)
  }, []))
  useNuiEvent<void>('declineillegal', useCallback(() => setShowPhone(false), []))

  useEffect(() => {
    const keyHandler = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setIsOpen(false)
        void fetchNui('close')
      }
    }

    window.addEventListener('keyup', keyHandler)
    void fetchNui('ready')
    return () => window.removeEventListener('keyup', keyHandler)
  }, [])

  const visibleTrucks = useMemo(() => trucks.length ? trucks : trucksCopy, [trucks, trucksCopy])

  const nav = [
    ['main', language.nts_main ?? 'NTS Main'],
    ['companies', language.companies ?? 'Companies'],
    ['leaderboard', language.leaderboard ?? 'Leaderboard'],
    ['profile', language.profile ?? 'Profile'],
  ] as const

  return (
    <>
      <NotificationStack notifications={notifications} menuOpen={isOpen} />
      <JobHud jobInfo={jobInfo} language={language} keybinds={keybinds} />
      <PhoneCall visible={showPhone} />

      {isOpen && (
        <main className="app-shell">
          <header className="app-header">
            <div className="brand">
              <TruckIcon />
              <div>
                <span>Peak Trucking</span>
                <strong>Freight operations</strong>
              </div>
            </div>
            <nav>
              {nav.map(([page, label]) => (
                <button className={activePage === page ? 'is-active' : ''} key={page} onClick={() => setActivePage(page)}>
                  {label}
                </button>
              ))}
            </nav>
            <div className="driver-mini">
              <div>
                <strong>{playerData.name ?? 'Driver'}</strong>
                <span>Lv. {playerData.level ?? 1}</span>
              </div>
              <img src={playerData.avatar ?? './assets/images/test-pp.png'} alt="" />
            </div>
          </header>

          <section className="app-body">
            {activePage === 'main' && (
              <DispatchView
                missions={missions}
                trucks={visibleTrucks}
                playerData={playerData}
                language={language}
                jobInfo={jobInfo}
                selectedMission={selectedMission}
                selectedRoute={selectedRoute}
                selectedTruck={selectedTruck}
                onMissionChange={(mission) => {
                  setSelectedMission(mission)
                  setSelectedRoute(undefined)
                }}
                onRouteChange={setSelectedRoute}
                onTruckChange={setSelectedTruck}
                notify={notify}
              />
            )}
            {activePage === 'companies' && (
              <CompaniesView
                missions={missions}
                playerData={playerData}
                language={language}
                selectedCompany={selectedCompany}
                onCompanyChange={setSelectedCompany}
              />
            )}
            {activePage === 'profile' && <ProfileView playerData={playerData} language={language} xp={xp} />}
            {activePage === 'leaderboard' && <LeaderboardView />}
          </section>
        </main>
      )}
    </>
  )
}

async function playSound(src: string, volume: number) {
  const audio = new Audio(src)
  audio.volume = volume
  try {
    await audio.play()
  } catch {
    // Browser autoplay rules can block sounds outside FiveM.
  }
}
