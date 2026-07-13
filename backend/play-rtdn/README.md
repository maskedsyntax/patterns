# play-rtdn

A Cloud Function that acknowledges Google Play purchases via **Real-time Developer
Notifications (RTDN)**.

## Why this exists

Google Play requires every purchase to be *acknowledged* (client or server-side)
within 72 hours, or it auto-refunds the buyer and revokes the entitlement. The app
(`lib/services/pro_service.dart`) already acknowledges purchases client-side when
it's open, but that's not guaranteed to happen in time — the buyer might not reopen
the app, might be offline, or the app might get killed mid-purchase.

This function is the backstop: Google Play pushes a Pub/Sub notification the instant
a purchase happens, independent of the buyer's device, and this function calls the
Play Developer API to acknowledge it. It only acts on one-time product purchases for
`com.maskedsyntax.patterns.pro`; everything else is ignored.

The client-side path is unchanged and remains the fast path — this only kicks in when
that path didn't run in time.

## One-time setup (manual, via Google Cloud / Play Console)

These steps only need to be done once, by whoever owns the GCP + Play Console
accounts.

1. **Create (or pick) a Google Cloud project.**
   ```
   gcloud projects create patterns-play-rtdn --name="Patterns Play RTDN"
   gcloud config set project patterns-play-rtdn
   gcloud billing projects link patterns-play-rtdn --billing-account=<BILLING_ACCOUNT_ID>
   ```
   Cloud Functions/Pub/Sub have a generous free tier — at this app's purchase volume
   this should stay at $0, but billing must be enabled to use the APIs at all.

2. **Enable the required APIs.**
   ```
   gcloud services enable \
     cloudfunctions.googleapis.com \
     cloudbuild.googleapis.com \
     pubsub.googleapis.com \
     androidpublisher.googleapis.com \
     run.googleapis.com
   ```

3. **Create the Pub/Sub topic** Play will publish notifications to.
   ```
   gcloud pubsub topics create play-rtdn
   ```

4. **Let Google Play publish to that topic.** Grant the well-known Play publisher
   service account the Pub/Sub Publisher role on the topic:
   ```
   gcloud pubsub topics add-iam-policy-binding play-rtdn \
     --member="serviceAccount:google-play-developer-notifications@system.gserviceaccount.com" \
     --role="roles/pubsub.publisher"
   ```

5. **Create a service account** for the function to run as, and grant it access in
   Play Console (not via GCP IAM — the Play Developer API authorizes based on Play
   Console's own permission grants):
   ```
   gcloud iam service-accounts create play-rtdn-runner \
     --display-name="play-rtdn Cloud Function runtime"
   ```
   Then in [Play Console](https://play.google.com/console) → **Users and
   permissions** (this used to be called "Setup → API access" in older Play
   Console versions) → **Invite new users**:
   - Enter `play-rtdn-runner@<PROJECT_ID>.iam.gserviceaccount.com` as the email.
   - Under **App permissions**, add this app and grant:
     - **"View app information (read only)"**
     - **"View financial data"** ← required to actually call the purchases API
       (`purchases.products.get`/`acknowledge`). Without this, calls fail with
       *"The current user has insufficient permissions to perform the requested
       operation"* even with "Manage orders and subscriptions" checked — this is
       easy to miss since that permission's own description doesn't mention it.
     - **"Manage orders and subscriptions"** ← required to acknowledge/refund/cancel.
   - Permission changes can take several minutes (observed ~7 minutes in practice)
     to actually take effect on the API, even though the Play Console UI shows them
     as saved immediately.

   No JSON key needs to be downloaded — the function runs *as* this service account
   on Cloud Functions, so it authenticates via Application Default Credentials.

6. **Configure RTDN** in Play Console → **Monetize → Monetization setup** →
   Real-time developer notifications → set the topic name to:
   `projects/patterns-play-rtdn/topics/play-rtdn` (adjust the project ID to match
   step 1).

## Deploy

```
npm install
gcloud functions deploy acknowledgePurchase \
  --gen2 \
  --runtime=nodejs22 \
  --region=asia-south1 \
  --source=. \
  --entry-point=acknowledgePurchase \
  --trigger-topic=play-rtdn \
  --retry \
  --service-account=play-rtdn-runner@patterns-play-rtdn.iam.gserviceaccount.com \
  --no-allow-unauthenticated \
  --set-env-vars=PLAY_PACKAGE_NAME=com.maskedsyntax.patterns
```

(`npm run gcp-build` runs automatically during the Cloud Build step to compile
TypeScript — no need to commit the `build/` output. `--retry` is what makes Pub/Sub
redeliver on a transient failure instead of dropping the message.)

**Newly created GCP projects need a few extra grants before the first deploy
succeeds** — as of April 2024 Google stopped auto-granting the Editor role to
default service accounts, so Cloud Build can't fetch/build/push without being told
to explicitly:
```
PROJECT_NUMBER=$(gcloud projects describe patterns-play-rtdn --format='value(projectNumber)')
for role in roles/storage.objectViewer roles/logging.logWriter roles/artifactregistry.writer; do
  gcloud projects add-iam-policy-binding patterns-play-rtdn \
    --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
    --role="$role" --condition=None
done
gcloud projects add-iam-policy-binding patterns-play-rtdn \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.builder"
```
One-time setup; not needed again on redeploys.

Pub/Sub's default retry/redelivery (message retention: 7 days) means a transient
failure — a network blip, a momentary API outage — gets retried automatically,
comfortably inside the 72-hour acknowledgment window.

## Local development

```
npm install
npm test    # unit tests for notification decoding/decision logic, no GCP needed
npm start   # runs the function locally via the Functions Framework
```

## Verifying end-to-end

1. In Play Console's Monetization setup page, use **"Send test notification"** and
   check the function's logs (`gcloud functions logs read acknowledgePurchase`) for
   `Received a Play Console test notification.`
2. Using a [license-testing account](https://play.google.com/console) in Play
   Console, buy Pro and immediately force-quit the app before it can call
   `completePurchase()` client-side. Check Play Console's order management page —
   the order should show as acknowledged well before the 72-hour mark, without the
   app ever reopening.
