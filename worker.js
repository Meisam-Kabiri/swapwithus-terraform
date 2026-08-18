// ------------------------------------------------------------------------------
// Cloudflare Worker: Authenticated Private GCS Proxy + Referer Protection
// Serves private GCS objects securely to swapwithus.com while blocking direct scrapers
// ------------------------------------------------------------------------------

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // 1. Health check endpoint
    if (url.pathname === '/healthz') {
      return new Response('OK', { status: 200 });
    }

    // 2. Referer / Origin Check
    const referer = request.headers.get('Referer') || '';
    const origin = request.headers.get('Origin') || '';
    const userAgent = (request.headers.get('User-Agent') || '').toLowerCase();

    // Allowed domains & social media preview bots
    const allowedDomains = ['swapwithus.com', 'www.swapwithus.com', 'localhost'];
    const isAllowedDomain = allowedDomains.some(d => referer.includes(d) || origin.includes(d));

    // Handle OPTIONS CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: {
          'Access-Control-Allow-Origin': isAllowedDomain && origin ? origin : '*',
          'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Max-Age': '86400',
        }
      });
    }

    // Allow social preview bots (WhatsApp, Twitter, Facebook, Slack, Telegram, LinkedIn)
    const isSocialBot = ['whatsapp', 'twitterbot', 'facebookexternalhit', 'linkedinbot', 'slackbot', 'telegrambot'].some(bot => userAgent.includes(bot));

    // If request has a Referer from an unauthorized domain, block it
    if (referer && !isAllowedDomain && !isSocialBot) {
      return new Response('403 Forbidden: Image access restricted to swapwithus.com', { status: 403 });
    }

    // 3. Target Object in Private Cloud Storage Bucket
    const bucketName = env.GCS_BUCKET_NAME || 'swapwithus-listing-images';
    const objectPath = url.pathname.slice(1);

    if (!objectPath) {
      return new Response('Not Found', { status: 404 });
    }

    const gcsHost = `${bucketName}.storage.googleapis.com`;
    const targetUrl = `https://${gcsHost}/${objectPath}`;

    // 4. Retrieve GCS HMAC Credentials
    const accessKey = env.GCS_ACCESS_KEY;
    const secretKey = env.GCS_SECRET_KEY;

    if (!accessKey || !secretKey) {
      return new Response('Server Configuration Error: Missing GCS HMAC Credentials', { status: 500 });
    }

    const method = request.method === 'HEAD' ? 'HEAD' : 'GET';
    const now = new Date();
    const amzDate = now.toISOString().replace(/[:-]|\.\d{3}/g, '');
    const dateStamp = amzDate.substring(0, 8);
    const region = 'auto';
    const service = 's3';

    // Sign request using Web Crypto API
    const signedRequest = await signGcsRequest({
      targetUrl,
      method,
      accessKey,
      secretKey,
      amzDate,
      dateStamp,
      region,
      service,
      host: gcsHost
    });

    // 5. Fetch from GCS with Cloudflare Edge Caching
    const cache = caches.default;
    let response = await cache.match(request);

    if (!response) {
      response = await fetch(signedRequest);

      // Set Cache-Control and CORS headers on successful fetch
      if (response.status === 200) {
        const newHeaders = new Headers(response.headers);
        newHeaders.set('Cache-Control', 'public, max-age=604800, immutable');
        
        // Dynamically set CORS header for both swapwithus.com and www.swapwithus.com
        const corsHeader = origin ? origin : (referer ? new URL(referer).origin : '*');
        newHeaders.set('Access-Control-Allow-Origin', corsHeader);

        response = new Response(response.body, {
          status: response.status,
          statusText: response.statusText,
          headers: newHeaders
        });

        ctx.waitUntil(cache.put(request, response.clone()));
      }
    } else {
      // Ensure CORS header is set even on cache hit
      const newHeaders = new Headers(response.headers);
      const corsHeader = origin ? origin : (referer ? new URL(referer).origin : '*');
      newHeaders.set('Access-Control-Allow-Origin', corsHeader);

      response = new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: newHeaders
      });
    }

    return response;
  }
};

// ------------------------------------------------------------------------------
// Helper Functions: AWS SigV4 HMAC Signature Calculation
// ------------------------------------------------------------------------------

const encoder = new TextEncoder();

async function signGcsRequest({ targetUrl, method, accessKey, secretKey, amzDate, dateStamp, region, service, host }) {
  const url = new URL(targetUrl);
  const credentialScope = `${dateStamp}/${region}/${service}/aws4_request`;

  const canonicalHeaders = `host:${host}\nx-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\nx-amz-date:${amzDate}\n`;
  const signedHeaders = 'host;x-amz-content-sha256;x-amz-date';

  const canonicalRequest = [
    method,
    url.pathname,
    '',
    canonicalHeaders,
    signedHeaders,
    'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  ].join('\n');

  const canonicalRequestHash = await sha256Hex(canonicalRequest);

  const stringToSign = [
    'AWS4-HMAC-SHA256',
    amzDate,
    credentialScope,
    canonicalRequestHash
  ].join('\n');

  const kDate = await hmacSha256(encoder.encode('AWS4' + secretKey), dateStamp);
  const kRegion = await hmacSha256(kDate, region);
  const kService = await hmacSha256(kRegion, service);
  const kSigning = await hmacSha256(kService, 'aws4_request');
  const signature = await bufferToHex(await hmacSha256(kSigning, stringToSign));

  const authorizationHeader = `AWS4-HMAC-SHA256 Credential=${accessKey}/${credentialScope}, SignedHeaders=${signedHeaders}, Signature=${signature}`;

  return new Request(targetUrl, {
    method,
    headers: {
      'Host': host,
      'x-amz-date': amzDate,
      'x-amz-content-sha256': 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      'Authorization': authorizationHeader
    }
  });
}

async function sha256Hex(message) {
  const msgBuffer = encoder.encode(message);
  const hashBuffer = await crypto.subtle.digest('SHA-256', msgBuffer);
  return bufferToHex(hashBuffer);
}

async function hmacSha256(key, data) {
  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    typeof key === 'string' ? encoder.encode(key) : key,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  return await crypto.subtle.sign('HMAC', cryptoKey, typeof data === 'string' ? encoder.encode(data) : data);
}

function bufferToHex(buffer) {
  return Array.from(new Uint8Array(buffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}
