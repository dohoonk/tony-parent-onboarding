"use client"

import { ApolloClient, InMemoryCache, HttpLink, ApolloProvider, from } from "@apollo/client"
import { setContext } from "@apollo/client/link/context"
import { useMemo } from "react"

function makeClient() {
  const httpLink = new HttpLink({
    uri: process.env.NEXT_PUBLIC_GRAPHQL_URL || "http://localhost:3000/graphql",
    fetchOptions: { cache: "no-store" },
  })

  // Add authentication header to all requests
  const authLink = setContext((_, { headers }) => {
    // Get token from localStorage (or wherever it's stored)
    const token = typeof window !== 'undefined' ? localStorage.getItem('auth_token') : null
    
    // Log in development to debug
    if (typeof window !== 'undefined' && process.env.NODE_ENV === 'development') {
      console.log('[Apollo] Auth token from localStorage:', token ? `${token.substring(0, 20)}...` : 'NOT FOUND')
    }
    
    const authHeaders = token ? { authorization: `Bearer ${token}` } : {}
    
    // Log in development to verify header is being set
    if (typeof window !== 'undefined' && process.env.NODE_ENV === 'development' && token) {
      console.log('[Apollo] Setting Authorization header:', `Bearer ${token.substring(0, 20)}...`)
    }
    
    return {
      headers: {
        ...headers,
        ...authHeaders,
      }
    }
  })

  return new ApolloClient({
    cache: new InMemoryCache(),
    link: from([authLink, httpLink]),
  })
}

export function ApolloWrapper({ children }: React.PropsWithChildren) {
  const client = useMemo(() => makeClient(), [])
  
  return (
    <ApolloProvider client={client}>
      {children}
    </ApolloProvider>
  )
}

