import { useEffect } from 'react'

type NuiMessage<T> = {
  action: string
  payload?: T
}

export function useNuiEvent<T>(action: string, handler: (payload: T, message: NuiMessage<T>) => void) {
  useEffect(() => {
    const listener = (event: MessageEvent<NuiMessage<T> | string>) => {
      let data: NuiMessage<T> | undefined

      if (typeof event.data === 'string') {
        try {
          data = JSON.parse(event.data) as NuiMessage<T>
        } catch {
          return
        }
      } else {
        data = event.data
      }

      if (data?.action === action) {
        handler(data.payload as T, data)
      }
    }

    window.addEventListener('message', listener)
    return () => window.removeEventListener('message', listener)
  }, [action, handler])
}
