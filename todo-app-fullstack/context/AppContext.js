'use client'

import { createContext, useContext, useState, useEffect } from 'react'
import { useRouter } from 'next/router'
import { useSession, signIn, signOut, signUp } from '../lib/auth-client'

const AppContext = createContext(null)

export function AppProvider({ children }) {
  const router = useRouter()
  const { data: session, isPending } = useSession()
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [notifications, setNotifications] = useState([])

  useEffect(() => {
    if (!isPending) {
      setUser(session?.user || null)
      setLoading(false)
      
      // Auto-redirect to dashboard if user is logged in and on auth page
      if (session?.user && router.pathname === '/auth') {
        router.push('/dashboard')
      }
    }
  }, [session, isPending, router])

  const login = async (email, password) => {
    try {
      const result = await signIn.email({
        email,
        password,
        callbackURL: '/dashboard' // Redirect after login
      })
      if (result?.error) {
        throw new Error(result.error.message || 'Login failed')
      }
      // Manual redirect if callbackURL doesn't work
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
        callbackURL: '/dashboard' // Redirect after signup
      })
      if (result?.error) {
        throw new Error(result.error.message || 'Signup failed')
      }
      // Manual redirect if callbackURL doesn't work
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
