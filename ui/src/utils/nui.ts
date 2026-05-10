export function isFiveM(): boolean {
  return typeof window !== 'undefined' && typeof window.GetParentResourceName === 'function'
}

export async function fetchNui<T = unknown>(eventName: string, data: unknown = {}): Promise<T | undefined> {
  if (!isFiveM()) return undefined

  const resourceName = window.GetParentResourceName!()
  const response = await fetch(`https://${resourceName}/${eventName}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data),
  })

  return response.json() as Promise<T>
}

declare global {
  interface Window {
    GetParentResourceName?: () => string
  }
}
