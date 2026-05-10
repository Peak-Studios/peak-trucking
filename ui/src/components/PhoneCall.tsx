type Props = {
  visible: boolean
}

export function PhoneCall({ visible }: Props) {
  if (!visible) return null

  return (
    <div className="phone-call">
      <div className="phone-call__shell">
        <span className="phone-call__speaker" />
        <div>
          <p>Unknown Caller</p>
          <h2>Special freight request</h2>
          <span>Y accept / N decline</span>
        </div>
      </div>
    </div>
  )
}
