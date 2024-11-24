const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/frontend/components/**/*.vue',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      colors: {
        'brand-primary': '#3B82F6',
        'brand-secondary': '#2563EB'
      },
      fontFamily: {
        sans: ['Inter var', 'ui-sans-serif', 'system-ui']
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries')
  ]
}
