# ------------------------------------------------------------------------------
# Google Maps API key (used by the frontend as NEXT_PUBLIC_SWAPWITHUS_MAPS_API_KEY)
#
# This key already existed and was configured by hand in the Cloud Console. The
# import block below adopts it into Terraform as-is, so the first apply changes
# only what this file adds (localhost:3000). The key string stays the same.
# ------------------------------------------------------------------------------

import {
  to = google_apikeys_key.maps
  id = "projects/swapwithus-project/locations/global/keys/aee08839-f940-4517-9f14-faa2bcde6da3"
}

resource "google_apikeys_key" "maps" {
  name         = "aee08839-f940-4517-9f14-faa2bcde6da3"
  display_name = "SWAPWITHUS_MAPS_API_KEY"
  project      = var.project_id

  restrictions {
    # Only pages on these sites may use the key. It is visible in the browser,
    # so these restrictions are what protect it.
    browser_key_restrictions {
      allowed_referrers = [
        "*.swapwithus.com/*",
        "swapwithus.com/*",
        "localhost:8080/*",
        "localhost:3000/*", # Next.js default dev port
      ]
    }

    # Only the Maps APIs the site uses
    api_targets {
      service = "maps-backend.googleapis.com" # Maps JavaScript API
    }
    api_targets {
      service = "geocoding-backend.googleapis.com" # Geocoding API
    }
    api_targets {
      service = "places-backend.googleapis.com" # Places API (address search)
    }
  }

  lifecycle {
    # Replacing the key would change its value and break the site until Vercel is updated
    prevent_destroy = true
  }
}
