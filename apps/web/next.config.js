/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    // Enable App Router features
    appDir: true,
  },
  // Configure API proxy to Rails backend
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'http://localhost:3000/:path*',
      },
    ];
  },
}

module.exports = nextConfig

