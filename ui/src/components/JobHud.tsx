import type { JobInfo, KeyBinds, Language } from '../types/trucking'
import { TruckIcon } from './Icons'

type Props = {
  jobInfo: JobInfo
  language: Language
  keybinds: KeyBinds
}

export function JobHud({ jobInfo, language, keybinds }: Props) {
  if (!jobInfo.started) return null

  const health = Math.max(0, Math.min(100, jobInfo.bodyHealth ?? 0))
  const fuel = Math.max(0, Math.min(100, jobInfo.fuel ?? 0))

  return (
    <aside className="job-hud">
      <div className="job-hud__media">
        <TruckIcon />
        <span>{jobInfo.attachedTrailer ? 'Loaded' : 'Trailer pending'}</span>
      </div>
      <div className="job-hud__content">
        <p className="eyebrow">{language.transportation_stage ?? 'Transportation Stage'}</p>
        <h2>{jobInfo.routeHeader ?? 'Active Route'}</h2>
        <div className="metric-row">
          <Meter label={language.trailer_quality ?? 'Trailer Quality'} value={health} />
          <Meter label={language.truck_fuel ?? 'Truck Fuel'} value={fuel} />
        </div>
        <div className="key-row">
          <kbd>H</kbd><span>{language.detach_trailer ?? 'Detach Trailer'}</span>
          <kbd>{keybinds.mark_location?.label ?? 'G'}</kbd><span>{language.mark_location ?? 'Mark Location'}</span>
        </div>
      </div>
    </aside>
  )
}

function Meter({ label, value }: { label: string; value: number }) {
  return (
    <div className="meter">
      <div>
        <span>{label}</span>
        <strong>{value.toFixed(0)}%</strong>
      </div>
      <div className="meter__track">
        <span style={{ width: `${value}%` }} />
      </div>
    </div>
  )
}
