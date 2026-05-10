import type { Language, PlayerData, XpTable } from '../types/trucking'

type Props = {
  playerData: PlayerData
  language: Language
  xp: XpTable
}

export function ProfileView({ playerData, language, xp }: Props) {
  const level = playerData.level ?? 1
  const currentXp = playerData.xp ?? 0
  const nextXp = Array.isArray(xp) ? xp[level - 1] ?? level * 1000 : xp[level] ?? level * 1000
  const history = [...(playerData.history ?? [])].sort((a, b) => b.date - a.date)

  return (
    <div className="profile-view">
      <section className="profile-stats">
        <Stat label={language.completed_jobs ?? 'Completed Jobs'} value={`${playerData.completedJobs ?? 0}`} helper={language.total_missions_completed ?? ''} />
        <Stat label={language.total_earnings ?? 'Total Earnings'} value={`$${(playerData.totalEarnings ?? 0).toLocaleString()}`} helper={language.total_earnings_desc ?? ''} />
        <Stat label={language.current_level ?? 'Current Level'} value={`${level}`} helper={`${Math.max(0, nextXp - currentXp).toLocaleString()} XP until next level`} />
      </section>
      <section className="history-panel">
        <div className="section-heading">
          <div>
            <p>{language.latest_works ?? 'Latest Works'}</p>
            <h2>Recent deliveries</h2>
          </div>
        </div>
        {history.map((entry) => (
          <div className="history-row" key={`${entry.label}-${entry.date}`}>
            <div>
              <strong>{entry.label}</strong>
              <span>{entry.supply}</span>
            </div>
            <p>${entry.earn.toLocaleString()} {language.earned ?? 'Earned'}</p>
            <time>{new Date(entry.date * 1000).toLocaleDateString()}</time>
          </div>
        ))}
      </section>
    </div>
  )
}

function Stat({ label, value, helper }: { label: string; value: string; helper: string }) {
  return (
    <article className="stat">
      <p>{label}</p>
      <h2>{value}</h2>
      <span>{helper}</span>
    </article>
  )
}
