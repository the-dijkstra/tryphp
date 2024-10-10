import type { APIRoute } from "astro";

import content from "./install.txt";

export const GET: APIRoute = ({ request }) => {
	return new Response(content, {
		headers: {
			"Content-Type": "text/plain;charset=UTF-8",
		},
	});
};
