import type { APIRoute } from "astro";

import content from "./_install.txt";

export const GET: APIRoute = () => {
	return new Response(content, {
		headers: {
			"Content-Type": "text/plain;charset=UTF-8",
		},
	});
};
