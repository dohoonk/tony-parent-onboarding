# Parent Onboarding AI - Web App

Next.js 15 frontend with App Router, React 18, Tailwind CSS, and shadcn/ui.

## Setup

### Prerequisites
- Node.js 18+
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Run development server
npm run dev
```

The app will be available at [http://localhost:3001](http://localhost:3001)

### Environment Variables

Create a `.env.local` file:

```
NEXT_PUBLIC_GRAPHQL_URL=http://localhost:3000/graphql
NEXT_PUBLIC_API_URL=http://localhost:3000
```

## Project Structure

```
apps/web/
├── app/                # Next.js 15 App Router
│   ├── layout.tsx     # Root layout
│   ├── page.tsx       # Home page
│   └── globals.css    # Global styles
├── components/
│   └── ui/            # shadcn/ui components
├── lib/               # Utility functions
│   ├── apollo-wrapper.tsx  # GraphQL client setup
│   └── utils.ts       # Helper functions
└── public/            # Static assets
```

## Features

- **Next.js 15 App Router**: Modern routing with React Server Components
- **TypeScript**: Full type safety
- **Tailwind CSS**: Utility-first CSS framework
- **shadcn/ui**: Accessible, customizable UI components
- **Apollo Client**: GraphQL client for API communication
- **Mobile-First**: Responsive design optimized for mobile devices

## Development

```bash
# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run linter
npm run lint

# Type check
npm run type-check
```

## GraphQL Integration

The app connects to the Rails API GraphQL endpoint at `http://localhost:3000/graphql`.

Apollo Client is configured in `lib/apollo-wrapper.tsx` and provides GraphQL query/mutation capabilities throughout the app.

## UI Components

shadcn/ui components are located in `components/ui/` and can be customized via Tailwind CSS.

Current components:
- Button
- Card
- (More to be added as needed)

## Styling

Global styles are defined in `app/globals.css` using Tailwind CSS and CSS variables for theming.

The app supports both light and dark modes out of the box.

