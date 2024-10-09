import type { APIRoute } from "astro";

export const GET: APIRoute = ({ request }) => {
	return new Response(
		JSON.stringify({
			path: new URL(request.url).pathname,
		}),
		{
			headers: {
				"Content-Type": "text/plain",
			},
		},
	);
};
