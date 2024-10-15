import type { APIRoute } from "astro";

export function getStaticPaths() {
	return [
		{ params: { version: "7.4" } },
		{ params: { version: "8.1" } },
		{ params: { version: "8.2" } },
		{ params: { version: "8.3" } },
	];
}

export const GET: APIRoute = async ({ params }) => {
	const content = await import(`../../../presets/php${params.version}.sh?raw`);
	return new Response(content.default, {
		headers: {
			"Content-Type": "text/plain;charset=UTF-8",
		},
	});
};
