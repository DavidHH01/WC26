import type { Config } from 'tailwindcss'

export default {
  content: [],
  theme: {
    extend: {
      fontFamily: {
        display: ['"Barlow Condensed"', 'sans-serif'],
        sans: ['Outfit', 'sans-serif'],
      },
      colors: {
        wc: {
          red:   '#E61D25',
          navy:  '#2A398D',
          green: '#3CAC3B',
          gray:  '#D1D4D1',
          gold:  '#C9A84C',
        },
        dark: {
          900: '#080C1A',
          800: '#0E1428',
          700: '#141C35',
          600: '#1A2440',
          500: '#1F2D52',
          400: '#2A3D6E',
          300: '#3D5490',
        },
      },
    },
  },
  plugins: [],
} satisfies Config
