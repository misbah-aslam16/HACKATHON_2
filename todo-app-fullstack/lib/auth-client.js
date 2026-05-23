import { createAuthClient } from "better-auth/react"

/**
 * Auth Client Configuration
 * 
 * Points to the Railway backend for authentication
 * - Production: https://hackathon2-production-8e72.up.railway.app
 * - Development: http://localhost:8000
 * 
 * The backend must expose /api/auth/* endpoints
 */
export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:8000',
  // Enable credentials for cross-origin requests
  fetchOptions: {
    credentials: 'include'
  }
})

export const { useSession, signIn, signOut, signUp } = authClient;
