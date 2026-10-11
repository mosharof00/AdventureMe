# AdventuresMe: Developer Account Setup

Hi Ryan,

Below is what we need from the mobile side: Apple, Google Play, and Google Cloud (for Google Maps). The backend developer will share separate instructions for the server, storage, and domain.

All access invites should go to **mosharof5khan@gmail.com** with **Admin** access. Once we're in, our team will handle the store setup, app configuration, and Google Maps key.

---

## First, a quick question

We believe you may already have **Apple Developer** and **Google Play Console** accounts. Could you please confirm?

- **If you already have them:** no need to create anything new. Just follow the **"Give us access"** step in each section below.
- **If you don't:** follow the full **"Create the account"** steps in each section.

We'd also like to know whether your company already has a **Google Cloud** account. If it does, we can reuse it for Google Maps.

---

## What's needed for Spain and what can wait

| Item | Needed for Spain testing? | Cost |
|---|---|---|
| Apple Developer account | **Yes.** Needed to install the iPhone app through TestFlight | $99 per year |
| Google Cloud account for the Maps key | **Yes.** The app's map features need it | Pay as you go, with a free monthly allowance. We expect $0 or close to it during testing |
| Google Play Console account | **Not strictly.** We can share the Android app as a direct install file for testing. It's needed for public launch | $25 one time |
| D-U-N-S number | Only if you're creating a **new** organization account | Free |

---

## 1. Apple Developer account

### Create the account (only if you don't have one)

**Get a D-U-N-S number first.** Apple asks for one when you enroll as an organization. It's a free company ID from Dun & Bradstreet.
1. Check whether your company already has one, or request one, here: https://developer.apple.com/enroll/duns-lookup/
2. Issuing one can take anywhere from a few business days to a couple of weeks, so please start as soon as you can.

> If the D-U-N-S number won't arrive in time for Spain, an individual Apple account can be approved much faster. The downside is that your personal name would show as the seller on the App Store instead of the company name. Let us know if you'd prefer that.

**Enroll:**
1. Go to https://developer.apple.com/programs/enroll/. Or use the **Apple Developer** app on an iPhone, which is usually quicker.
2. Sign in with an Apple Account that has two-factor authentication turned on, ideally using a company email.
3. Choose **Enroll as an Organization**.
4. Enter the company's legal name, address, D-U-N-S number, and public website.
5. Pay the $99 yearly fee. Apple may call you to verify, and approval usually takes a few days.

### Give us access

1. Go to https://appstoreconnect.apple.com and open **Users and Access**.
2. Click **+** and enter our name and email (shown at the top of this document).
3. Choose the **Admin** role and click **Invite**.

---

## 2. Google Play Console account

### Create the account (only if you don't have one)

1. Go to https://play.google.com/console/signup and sign in with the company Google account.
2. Choose **An organisation or business**.
3. Enter the organization name, D-U-N-S number, website, phone number, and contact email.
4. Pay the $25 one-time fee and complete identity verification. This can take a few days.

> An organization account has a real advantage. New personal accounts have to run a 14-day test with at least 12 testers before they can publish, and organization accounts don't.

### Give us access

1. Open Play Console and go to **Users and permissions**.
2. Click **Invite new users** and enter our email.
3. On the **Account permissions** tab, tick **Admin (all permissions)**.
4. Click **Invite user**.

---

## 3. Google Cloud account (for the Google Maps key)

You only need to create the account, a project, and billing. We'll turn on the right map services, create the key, and lock it down so it only works in our app.

### Create the account and project (skip any part you already have)

1. Go to https://console.cloud.google.com, sign in with the company Google account (ideally the same one used for Google Play), and accept the terms.
2. Click the project selector at the top, choose **New Project**, name it **AdventuresMe**, and click **Create**.
3. Go to **Billing**, create a billing account, add a payment card, and link it to the **AdventuresMe** project. Google requires billing to be set up for Maps, even when usage stays within the free allowance.

### Give us access

**Project access:**
1. Go to **IAM & Admin**, then **IAM**, then **Grant access**.
2. Enter our email and choose the role **Owner**.
3. Click **Save**.

**Billing access:**
1. Go to **Billing**, then **Account management**, then **Add principal**.
2. Enter our email.
3. Choose **Billing Account User** so we can link projects and see usage, while payment control stays with you. Choose **Billing Account Administrator** instead if you'd like us to manage it fully.

We'll also set up budget alerts so you get an email if costs ever start to rise.

---

## What we need back from you

1. Confirmation of which accounts you already have.
2. Admin invites for **App Store Connect**, **Google Play Console**, and the **Google Cloud project**.
3. Your company's legal name and website, as they should appear on the stores. This is only needed if you're creating new accounts.

Once the invites arrive, we'll accept them right away and take care of the rest.

Thanks,
Mosharof
