import type { JobInfo, Language, Mission, PlayerData, Route, Truck } from '../types/trucking'
import { ChevronIcon, RouteIcon, ShieldIcon, TruckIcon } from './Icons'
import { fetchNui } from '../utils/nui'

type Props = {
  missions: Mission[]
  trucks: Truck[]
  playerData: PlayerData
  language: Language
  jobInfo: JobInfo
  selectedMission?: Mission
  selectedRoute?: Route
  selectedTruck?: Truck
  onMissionChange: (mission: Mission) => void
  onRouteChange: (route: Route) => void
  onTruckChange: (truck: Truck) => void
  notify: (message: string) => void
}

export function DispatchView({
  missions,
  trucks,
  playerData,
  language,
  jobInfo,
  selectedMission,
  selectedRoute,
  selectedTruck,
  onMissionChange,
  onRouteChange,
  onTruckChange,
  notify,
}: Props) {
  const unlockedMissions = playerData.unlockedMissions ?? {}
  const visibleMissions = missions.filter((mission) => unlockedMissions[String(mission.id)])
  const activeMission = selectedMission ?? visibleMissions[0] ?? missions[0]
  const compatibleTrucks = selectedRoute ? trucks.filter((truck) => selectedRoute.vehicle.includes(truck.name)) : trucks
  const activeTruck = selectedTruck ?? compatibleTrucks[0]

  const selectRoute = (route: Route) => {
    const points = playerData.points?.[String(activeMission.companyIndex)] ?? 0
    if (route.reqPoint && points < route.reqPoint) {
      notify("You don't have enough points!")
      return
    }
    onRouteChange(route)
    const firstAllowedTruck = trucks.find((truck) => route.vehicle.includes(truck.name))
    if (firstAllowedTruck) onTruckChange(firstAllowedTruck)
  }

  const selectTruck = (truck: Truck) => {
    if ((playerData.level ?? 1) < truck.level) {
      notify(`Level ${truck.level} required`)
      return
    }
    onTruckChange(truck)
  }

  const startJob = () => {
    if (!activeMission || !selectedRoute || !activeTruck) {
      notify('Select a mission, route, and truck first.')
      return
    }

    void fetchNui('startJob', {
      mission: activeMission,
      route: selectedRoute,
      truck: activeTruck,
    })
  }

  return (
    <div className="dispatch-grid">
      <section className="mission-panel">
        <div className="section-heading">
          <div>
            <p>Dispatch board</p>
            <h2>{activeMission?.header ?? 'No route selected'}</h2>
          </div>
          <span>{visibleMissions.length || missions.length} routes</span>
        </div>
        <div className="mission-hero" style={{ backgroundImage: `url(./assets/images/${activeMission?.image ?? 'map_1.png'})` }}>
          <div className="mission-hero__shade" />
          <div className="mission-hero__content">
            <p>National Transfer & Storage</p>
            <h1>{activeMission?.header ?? 'Available Freight'}</h1>
            <div className="requirement-strip">
              {activeMission?.requirementsLabel?.slice(0, 4).map((item) => (
                <span key={`${activeMission.id}-${item.label}`}>{item.label}</span>
              ))}
            </div>
          </div>
        </div>
        <div className="mission-list">
          {(visibleMissions.length ? visibleMissions : missions).map((mission) => (
            <button
              className={`mission-row ${mission.id === activeMission?.id ? 'is-active' : ''}`}
              key={mission.id}
              onClick={() => onMissionChange(mission)}
            >
              <img src={`./assets/images/${mission.small_image ?? mission.image}`} alt="" />
              <span>{mission.header}</span>
              <strong>${mission.payment.toLocaleString()}</strong>
            </button>
          ))}
        </div>
      </section>

      <section className="routes-panel">
        <div className="section-heading">
          <div>
            <p>{language.select_route ?? 'Select a Route'}</p>
            <h2>Route options</h2>
          </div>
          <RouteIcon />
        </div>
        <div className="route-list">
          {activeMission?.routes.map((route) => (
            <button
              className={`route-card ${selectedRoute?.label === route.label ? 'is-active' : ''}`}
              key={route.label}
              onClick={() => selectRoute(route)}
            >
              <div>
                <h3>{route.label}</h3>
                <p>{route.extraPayment ? `+$${route.extraPayment.toLocaleString()} extra payment` : 'Standard payment'}</p>
              </div>
              {route.reqPoint ? <span>{route.reqPoint} trust</span> : <ChevronIcon />}
            </button>
          ))}
        </div>

        <div className="truck-selector">
          <div className="section-heading section-heading--compact">
            <div>
              <p>{language.select_truck ?? 'Select a Truck'}</p>
              <h2>{activeTruck?.label ?? 'Choose equipment'}</h2>
            </div>
            <TruckIcon />
          </div>
          <div className="truck-rail">
            {compatibleTrucks.map((truck) => (
              <button
                className={`truck-card ${activeTruck?.name === truck.name ? 'is-active' : ''} ${(playerData.level ?? 1) < truck.level ? 'is-locked' : ''}`}
                key={truck.name}
                onClick={() => selectTruck(truck)}
              >
                <img src={`./assets/images/${truck.image}`} alt="" />
                <span>{truck.label}</span>
                <small>Lv. {truck.level}</small>
              </button>
            ))}
          </div>
        </div>
      </section>

      <aside className="start-panel">
        <div className="driver-card">
          <img src={playerData.avatar ?? './assets/images/test-pp.png'} alt="" />
          <div>
            <p>{playerData.name ?? 'Driver'}</p>
            <span>Level {playerData.level ?? 1}</span>
          </div>
        </div>
        <div className="step-list">
          <Step done={Boolean(activeTruck)} label={language.select_your_truck ?? 'Select your truck'} />
          <Step done={Boolean(selectedRoute)} label={language.select_mission_and_route ?? 'Select mission and route'} />
          <Step done={Boolean(selectedRoute && activeTruck)} label={language.start_the_job ?? 'Start the job'} />
        </div>
        <button className="primary-action" onClick={jobInfo.started ? () => void fetchNui('stopJob') : startJob}>
          {jobInfo.started ? language.stop_job ?? 'Cancel Job' : language.start_job ?? 'Start Job'}
        </button>
        <DailyMissions playerData={playerData} language={language} />
      </aside>
    </div>
  )
}

function Step({ done, label }: { done: boolean; label: string }) {
  return (
    <div className={`step ${done ? 'is-done' : ''}`}>
      <ShieldIcon />
      <span>{label}</span>
    </div>
  )
}

function DailyMissions({ playerData, language }: { playerData: PlayerData; language: Language }) {
  const resetAt = playerData.dailymissions?.resetAt
  const remaining = resetAt ? Math.max(0, Math.ceil((resetAt * 1000 - Date.now()) / 3600000)) : 0
  const missions = Object.values(playerData.dailymissions?.data ?? {})

  return (
    <div className="daily-panel">
      <div className="daily-panel__head">
        <h3>{language.daily_missions ?? 'Daily Missions'}</h3>
        <span>{remaining}{language.hour ?? 'hr'}</span>
      </div>
      {missions.map((mission) => (
        <div className="daily-row" key={mission.header}>
          <div>
            <strong>{mission.header}</strong>
            <p>{mission.label}</p>
          </div>
          <span>{mission.process >= mission.max ? language.completed ?? 'Completed' : `${mission.process}/${mission.max}`}</span>
        </div>
      ))}
    </div>
  )
}
