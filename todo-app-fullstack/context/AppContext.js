'use client'

import { createContext, useContext, useState, useEffect, useCallback } from 'react'
import { useRouter } from 'next/router'
import { useSession, signIn, signOut, signUp } from '../lib/auth-client'

const AppContext = createContext(null)

export function AppProvider({ children }) {
  const router = useRouter()
  const { data: session, isPending } = useSession()
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [notifications, setNotifications] = useState([])

  // Validate session on mount and periodically
  const validateSession = useCallback(async () => {
    try {
      const backendUrl = process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:8000'
      const response = await fetch(`${backendUrl}/api/auth/get-session`, {
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json'
        }
      })
      
      if (!response.ok) {
        if (response.status === 401) {
          localStorage.removeItem('better-auth-session')
          setUser(null)
          return false
        }
      }
      return true
    } catch (error) {
      console.error('Session validation error:', error)
      return false
    }
  }, [])

  useEffect(() => {
    if (!isPending) {
      setUser(session?.user || null)
      setLoading(false)
      
      // Auto-redirect to dashboard if user is logged in and on auth page
      if (session?.user && router.pathname === '/auth') {
        router.push('/dashboard')
      }
      
      // Validate session every 5 minutes
      const validationInterval = setInterval(validateSession, 5 * 60 * 1000)
      return () => clearInterval(validationInterval)
    }
  }, [session, isPending, router, validateSession])

  const login = async (email, password) => {
    try {
      const result = await signIn.email({
        email,
        password,
        callbackURL: '/dashboard'
      })
      if (result?.error) {
        throw new Error(result.error.message || 'Login failed')
      }
      
      // Store session in localStorage as backup
      if (result?.ok) {
        localStorage.setItem('better-auth-session', JSON.stringify({
          email,
          timestamp: Date.now()
        }))
      }
      
      setTimeout(() => {
        router.push('/dashboard')
      }, 500)
      return result
    } catch (error) {
      throw error
    }
  }

  const signup = async (email, password, name) => {
    try {
      const result = await signUp.email({
        email,
        password,
        name: name || email.split('@')[0],
        callbackURL: '/dashboard'
      })
      if (result?.error) {
        throw new Error(result.error.message || 'Signup failed')
      }
      
      // Store session in localStorage as backup
      if (result?.ok) {
        localStorage.setItem('better-auth-session', JSON.stringify({
          email,
          timestamp: Date.now()
        }))
      }
      
      setTimeout(() => {
        router.push('/dashboard')
      }, 500)
      return result
    } catch (error) {
      throw error
    }
  }

  const logout = async () => {
    try {
      await signOut()
      setUser(null)
      localStorage.removeItem('better-auth-session')
      router.push('/auth')
    } catch (error) {
      console.error('Logout error:', error)
    }
  }

  const addNotification = (notification) => {
    const id = Date.now()
    setNotifications(prev => [...prev, { ...notification, id }])
    setTimeout(() => {
      setNotifications(prev => prev.filter(n => n.id !== id))
    }, 5000)
  }

  return (
    <AppContext.Provider value={{
      user,
      loading,
      login,
      signup,
      logout,
      notifications,
      addNotification
    }}>
      {children}
    </AppContext.Provider>
  )
}

export function useApp() {
  const context = useContext(AppContext)
  if (!context) {
    throw new Error('useApp must be used within AppProvider')
  }
  return context
}
