import type { APIRoute } from "astro";

export function getStaticPaths() {
  return [{ params: { preset: "laravel" } }];
}

export const GET: APIRoute = async ({ params }) => {
  const content = await import(`../../presets/${params.preset}.sh?raw`);
  return new Response(content.default, {
    headers: {
      "Content-Type": "text/plain;charset=UTF-8",
    },
  });
};
