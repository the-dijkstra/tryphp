import type { APIRoute } from "astro";

import preset from "../../presets/php.sh?raw";

export function getStaticPaths() {
  return [
    { params: { version: "7.4" } },
    { params: { version: "8.1" } },
    { params: { version: "8.2" } },
    { params: { version: "8.3" } },
    { params: { version: "8.4" } },
  ];
}

export const GET: APIRoute = async ({ params }) => {
  const content = preset.replace("8.4", params.version as string);
  return new Response(content, {
    headers: {
      "Content-Type": "text/plain;charset=UTF-8",
    },
  });
};
