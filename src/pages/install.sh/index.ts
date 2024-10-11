import type { APIRoute } from "astro";

import install from "../../presets/php8.3.txt";

export const GET: APIRoute = () => {
	return new Response(install, {
		headers: {
			"Content-Type": "text/plain;charset=UTF-8",
		},
	});
};
