"use client"

import { ApolloLink, HttpLink } from "@apollo/client"
import {
  ApolloNextAppProvider,
  ApolloClient,
  InMemoryCache,
} from "@apollo/experimental-nextjs-app-support"

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
  return (
    <ApolloNextAppProvider makeClient={makeClient}>
      {children}
    </ApolloNextAppProvider>
  )
}

