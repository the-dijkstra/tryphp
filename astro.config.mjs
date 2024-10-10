// @ts-check
import { defineConfig } from "astro/config";

import cloudflare from "@astrojs/cloudflare";

import tailwind from "@astrojs/tailwind";

// https://astro.build/config
export default defineConfig({
	output: "hybrid",
	adapter: cloudflare(),
	integrations: [tailwind()],
});
