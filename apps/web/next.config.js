/** @type {import('next').NextConfig} */
const nextConfig = {
  // Configure API proxy to Rails backend
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'http://localhost:3000/:path*',
      },
    ];
  },
  // Disable ESLint during production builds (deploy-time only)
  eslint: {
    ignoreDuringBuilds: true,
  },
}

module.exports = nextConfig

