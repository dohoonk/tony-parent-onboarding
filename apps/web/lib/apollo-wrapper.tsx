"use client"

import { ApolloClient, InMemoryCache, HttpLink, ApolloProvider } from "@apollo/client"
import { useMemo } from "react"

function makeClient() {
  const httpLink = new HttpLink({
    uri: process.env.NEXT_PUBLIC_GRAPHQL_URL || "http://localhost:3000/graphql",
    fetchOptions: { cache: "no-store" },
  })

  return new ApolloClient({
    cache: new InMemoryCache(),
    link: httpLink,
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

