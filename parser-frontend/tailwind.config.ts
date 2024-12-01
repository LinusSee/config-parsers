import type { Config } from "tailwindcss";
import daisyui from "daisyui"

export default {
  content: [
    "./src/**/*.{js,elm,ts,css,html}",
    "./.elm-land/**/*.{js,elm,ts,css,html}",
  ],
  theme: {
    extend: {},
  },
  plugins: [
    daisyui
  ],

  daisyui: {
    prefix: 'cp-',
  }
} as Config;

