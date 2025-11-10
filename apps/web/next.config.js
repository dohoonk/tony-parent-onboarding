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
}

module.exports = nextConfig

