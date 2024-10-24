// @ts-check
import { defineConfig } from "astro/config";

import tailwind from "@astrojs/tailwind";

import sitemap from "@astrojs/sitemap";

const base = "https://tryphp.dev";

// https://astro.build/config
export default defineConfig({
  output: "static",
  site: base,
  integrations: [
    tailwind(),
    sitemap({
      customPages: [
        `${base}/install.sh`,
        `${base}/7.4/install.sh`,
        `${base}/8.1/install.sh`,
        `${base}/8.2/install.sh`,
        `${base}/8.3/install.sh`,
      ],
    }),
  ],
});
