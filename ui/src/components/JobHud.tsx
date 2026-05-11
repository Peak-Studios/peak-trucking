import { useState, useEffect, useRef } from 'react'
import type { JobInfo, KeyBinds, Language } from '../types/trucking'
import { TruckIcon } from './Icons'
import { fetchNui } from '../utils/nui'

type Props = {
  jobInfo: JobInfo
  language: Language
  keybinds: KeyBinds
  isEditing?: boolean
}

export function JobHud({ jobInfo, language, keybinds, isEditing }: Props) {
  const [pos, setPos] = useState({ x: 0, y: 0 })
  const [isDragging, setIsDragging] = useState(false)
  const dragStart = useRef({ x: 0, y: 0 })
  const hudRef = useRef<HTMLElement>(null)

  useEffect(() => {
    const saved = localStorage.getItem('peak_trucking_hud_pos')
    if (saved) {
      try {
        setPos(JSON.parse(saved))
      } catch (e) {
        console.error('Failed to load HUD position', e)
      }
    }
  }, [])

  const handleMouseDown = (e: React.MouseEvent) => {
    if (!isEditing) return
    setIsDragging(true)
    dragStart.current = {
      x: e.clientX - pos.x,
      y: e.clientY - pos.y
    }
  }

  useEffect(() => {
    if (!isDragging) return

    const handleMouseMove = (e: MouseEvent) => {
      setPos({
        x: e.clientX - dragStart.current.x,
        y: e.clientY - dragStart.current.y
      })
    }

    const handleMouseUp = () => {
      setIsDragging(false)
      localStorage.setItem('peak_trucking_hud_pos', JSON.stringify(pos))
    }

    window.addEventListener('mousemove', handleMouseMove)
    window.addEventListener('mouseup', handleMouseUp)
    return () => {
      window.removeEventListener('mousemove', handleMouseMove)
      window.removeEventListener('mouseup', handleMouseUp)
    }
  }, [isDragging, pos])

  const handleSave = () => {
    void fetchNui('save_hud_pos')
  }

  if (!jobInfo.started && !isEditing) return null

  return (
    <aside 
      ref={hudRef}
      className={`job-hud ${isEditing ? 'is-editing' : ''}`}
      style={{ transform: `translate(${pos.x}px, ${pos.y}px)` }}
      onMouseDown={handleMouseDown}
    >
      <div className="job-hud__media">
        <TruckIcon />
        <span>{jobInfo.attachedTrailer ? 'Loaded' : 'Trailer pending'}</span>
      </div>
      <div className="job-hud__content">
        <p className="eyebrow">{language.transportation_stage ?? 'Transportation Stage'}</p>
        <h2>{jobInfo.routeHeader ?? (isEditing ? 'HUD Edit Mode' : 'Active Route')}</h2>
        
        {isEditing ? (
          <button className="primary-action" onClick={handleSave} style={{ height: '36px', fontSize: '11px' }}>
            Save Position
          </button>
        ) : (
          <>
            <div className="metric-row">
              <Meter label={language.trailer_quality ?? 'Trailer Quality'} value={Math.max(0, Math.min(100, jobInfo.bodyHealth ?? 0))} />
              <Meter label={language.truck_fuel ?? 'Truck Fuel'} value={Math.max(0, Math.min(100, jobInfo.fuel ?? 0))} />
            </div>
            <div className="key-row">
              <kbd>H</kbd><span>{language.detach_trailer ?? 'Detach Trailer'}</span>
              <kbd>{keybinds.mark_location?.label ?? 'G'}</kbd><span>{language.mark_location ?? 'Mark Location'}</span>
            </div>
          </>
        )}
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
