import type { APIRoute } from "astro";

import content from "../../presets/php.sh?raw";

export const GET: APIRoute = () => {
  return new Response(content, {
    headers: {
      "Content-Type": "text/plain;charset=UTF-8",
    },
  });
};
