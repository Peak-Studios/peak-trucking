type Props = {
  notifications: string[]
  menuOpen: boolean
}

export function NotificationStack({ notifications, menuOpen }: Props) {
  return (
    <div className={`notifications ${menuOpen ? 'notifications--inside' : 'notifications--top'}`}>
      {notifications.map((notification, index) => (
        <div className="notification" key={`${notification}-${index}`}>
          <span className="notification__dot" />
          <p>{notification}</p>
        </div>
      ))}
    </div>
  )
}
