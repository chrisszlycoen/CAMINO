/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      colors: {
        primary: { DEFAULT: '#0A3D2F', light: '#1B6A56', dark: '#06291F' },
        accent: '#10B981',
        surface: { light: '#FFFFFF', dark: '#1C1C1E', elevated: '#2C2C2E' },
        border: { light: '#E5E5EA', dark: '#38383A' },
        text: { primary: '#000000', secondary: '#8E8E93', dark: '#FFFFFF' },
      },
      fontFamily: { sans: ['Inter', 'system-ui', 'sans-serif'] },
    },
  },
  plugins: [],
};
