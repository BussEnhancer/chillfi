# Draft email to Delhivery (not sent)

**To:** your Delhivery account manager / lastmile-integration@delhivery.com
**Subject:** API integration — staging token + scan push webhook for CHILLFI

Hello team,

We are integrating our store (client: **CHILLFI**, registered email chill2026@gmail.com) with the Delhivery
B2C Express API (order creation, tracking pull API, cancellation).

Please help with:

1. **Staging (test) API token** and the name of a staging pickup location for our account, so we can
   complete UAT before using our live token.
2. **Scan push (webhook) enablement** for our production account:
   - Endpoint: `https://chillfi.in/api/shipping/delhivery/webhook`
   - Method: POST, Content-Type: application/json
   - Header: `Authorization: Bearer <we will share this secret over a secure channel>`
   - Payload: your default scan-push format (Shipment.AWB, Shipment.Status.{Status, StatusType,
     StatusDateTime, StatusLocation, Instructions}, ReferenceNo, NSLCode)
   If a staging push can be enabled as well, we would like to test it first.

Our production pickup locations: Sairam Mobile (Bemetara) and VBINFOTECH (Surat).

Thank you,
ChillFi
