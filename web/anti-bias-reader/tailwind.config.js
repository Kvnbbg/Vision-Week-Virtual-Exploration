/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./pages/**/*.{js,jsx,ts,tsx}",
    "./components/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        display: ["Gotham", "Arial", "sans-serif"],
        body: ["Times New Roman", "Times", "serif"],
        ui: ["Calibri", "Arial", "sans-serif"],
      },
      colors: {
        ink: {
          900: "#0b0b0f",
          700: "#2a2a33",
        },
        paper: {
          50: "#f8f7f4",
          100: "#f2f0eb",
          0: "#ffffff",
        },
        accent: {
          500: "#1f2937",
          600: "#111827",
        },
        focus: {
          500: "#0f172a",
        },
      },
      fontSize: {
        base: ["16px", { lineHeight: "1.5" }],
        prose: ["18px", { lineHeight: "1.6" }],
        hero: ["clamp(1.5rem, 3.2vw, 2rem)", { lineHeight: "1.2" }],
      },
      boxShadow: {
        card: "0 6px 20px -18px rgba(15, 23, 42, 0.35)",
      },
      keyframes: {
        "tab-pop": {
          "0%": { transform: "scale(1)" },
          "40%": { transform: "scale(1.12)" },
          "100%": { transform: "scale(1)" },
        },
      },
      animation: {
        "tab-pop": "tab-pop 180ms ease-out",
      },
    },
  },
  plugins: [],
};
