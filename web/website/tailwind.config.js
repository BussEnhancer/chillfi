/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
    "./pages/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
    "./sections/**/*.{js,ts,jsx,tsx}",
    "./layouts/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      // ChillFi tokens — the values the site already uses (see QA/UI_SYSTEM.md). Prefer these in new/normalised UI.
      colors: {
        brand: { DEFAULT: '#FF6B2C', hover: '#E05520', tint: '#FFF8F5' },
        accent: { DEFAULT: '#7B2CFF', light: '#8B5CFF' },
        ink: '#111827',
        line: '#ECECEC',
        surface: '#F8F7FC',
      },
      keyframes: {
        'page-in': { '0%': { opacity: '0', transform: 'translateY(6px)' }, '100%': { opacity: '1', transform: 'none' } },
        float: { '0%, 100%': { transform: 'translateY(0)' }, '50%': { transform: 'translateY(-10px)' } },
      },
      animation: {
        // Route change: content eases in under a steady header (short — never delays reading)
        'page-in': 'page-in 240ms cubic-bezier(0.22, 1, 0.36, 1) both',
        float: 'float 6s ease-in-out infinite',
        'float-delayed': 'float 6s ease-in-out 3s infinite',
      },
    },
  },
  plugins: [],
}
