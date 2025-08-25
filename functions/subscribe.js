// Cloudflare Pages Function: POST /api/subscribe
// Zet env vars BREVO_API_KEY en BREVO_LIST_ID in CF Pages Settings.

export async function onRequestOptions() {
  return new Response(null, {
    status: 204,
    headers: {
      "Access-Control-Allow-Origin": "https://earnbasis.com",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
      "Access-Control-Max-Age": "86400",
    },
  });
}

export async function onRequestPost({ request, env }) {
  try {
    const origin = new URL(request.headers.get("origin") || "");
    if (origin.hostname !== "earnbasis.com" && origin.hostname !== "www.earnbasis.com") {
      return new Response("Forbidden", { status: 403 });
    }

    const data = await request.json().catch(() => ({}));
    const email = (data.email || "").trim().toLowerCase();

    // Basic email check
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return json({ ok: false, error: "Invalid email" }, 400);
    }

    // Prepare Brevo payload
    const body = {
      email,
      listIds: [Number(env.BREVO_LIST_ID || 5)],
      updateEnabled: true,
      attributes: { SOURCE: "EarnBasis", TAG: "Daily Drops" },
    };

    const brevoRes = await fetch("https://api.brevo.com/v3/contacts", {
      method: "POST",
      headers: {
        "accept": "application/json",
        "content-type": "application/json",
        "api-key": env.BREVO_API_KEY, // <-- nooit hardcoden!
      },
      body: JSON.stringify(body),
    });

    const text = await brevoRes.text();
    const status = brevoRes.status;

    // 201 Created (new contact) of 204 No Content (updated) zijn beide ok
    if (status === 201 || status === 204) {
      return json({ ok: true }, 200);
    }

    // Als Brevo een conflict of error geeft, stuur ’m door voor debug (geen secrets loggen)
    return json({ ok: false, status, message: safeText(text) }, status);
  } catch (e) {
    return json({ ok: false, error: "Server error" }, 500);
  }
}

function json(payload, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "content-type": "application/json",
      "cache-control": "no-store",
      "Access-Control-Allow-Origin": "https://earnbasis.com",
    },
  });
}

// Verwijder potentieel PII uit logs
function safeText(t) {
  return String(t).slice(0, 300);
}
