import { useEffect, useState } from 'react'
import type { LeaderboardEntry } from '../types/trucking'
import { fetchNui } from '../utils/nui'

type LeaderboardResponse = {
  data?: LeaderboardEntry[]
}

export function LeaderboardView() {
  const [drivers, setDrivers] = useState<LeaderboardEntry[]>([])

  useEffect(() => {
    let mounted = true
    void fetchNui<LeaderboardResponse>('getLeaderboard').then((response) => {
      if (mounted && response?.data) setDrivers(response.data)
    })
    return () => {
      mounted = false
    }
  }, [])

  const seededDrivers = drivers.length ? drivers : [
    { name: 'Alex Morgan', level: 22, avatar: './assets/images/test-pp.png' },
    { name: 'Jordan Miles', level: 19, avatar: './assets/images/test-pp.png' },
    { name: 'Casey Tran', level: 17, avatar: './assets/images/test-pp.png' },
    { name: 'Sam Rivera', level: 12, avatar: './assets/images/test-pp.png' },
  ]

  return (
    <div className="leaderboard-view">
      <section className="podium">
        {seededDrivers.slice(0, 3).map((driver, index) => (
          <article className={`podium-driver podium-driver--${index + 1}`} key={driver.name}>
            <img src={driver.avatar ?? './assets/images/test-pp.png'} alt="" />
            <span>#{index + 1}</span>
            <h2>{driver.name}</h2>
            <p>Level {driver.level}</p>
          </article>
        ))}
      </section>
      <section className="rank-list">
        {seededDrivers.map((driver, index) => (
          <div className="rank-row" key={`${driver.name}-${index}`}>
            <strong>#{index + 1}</strong>
            <span>{driver.name}</span>
            <p>Lv. {driver.level}</p>
          </div>
        ))}
      </section>
    </div>
  )
}
