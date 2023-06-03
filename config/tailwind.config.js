const defaultTheme = require("tailwindcss/defaultTheme");
const colors = require("tailwindcss/colors");
const myColors = {
  ...colors,
  caper: {
    50: "#f5fbea",
    100: "#e8f6d1",
    200: "#d3eea9",
    300: "#b4e175",
    400: "#98d14a",
    500: "#79b62c",
    600: "#5d911f",
    700: "#476f1c",
    800: "#3b581c",
    900: "#334b1c",
    950: "#19290a",
  },
  "new-york-pink": {
    50: "#fcf5f4",
    100: "#f8ebe8",
    200: "#f3dad5",
    300: "#eac0b7",
    400: "#d88f80",
    500: "#cc7867",
    600: "#b65e4c",
    700: "#984d3d",
    800: "#7f4235",
    900: "#6b3b31",
    950: "#391c16",
  }
};

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      colors: myColors,
      backgroundImage: {
        "green-striped-pattern": `repeating-linear-gradient(-60deg, ${myColors.white}, ${myColors.white} 3px,  ${myColors.caper["300"]} 3px, ${myColors.caper["300"]} 10px);`,
        "green-light-striped-pattern": `repeating-linear-gradient(-60deg, ${myColors.white}, ${myColors.white} 3px,  ${myColors.caper["100"]} 3px, ${myColors.caper["100"]} 10px);`,
        "red-striped-pattern": `repeating-linear-gradient(-60deg, ${myColors.white}, ${myColors.white} 3px,  ${myColors["new-york-pink"]["300"]} 3px, ${myColors["new-york-pink"]["300"]} 10px);`,
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
  ],
};
