// Security-rules tests. They run against the Firestore emulator, so they
// need Java and the Firebase CLI:
//
//   cd rules_test && npm install
//   npm run test:emulator        (firebase-tools must be installed)
//
// These are the tests that prove a stranger cannot read someone's phone
// number or write junk into the directory. Jenkins runs them on every push.

import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-blood-donation',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

// ---- helpers -------------------------------------------------------------

const verified = (uid) =>
  env.authenticatedContext(uid, {
    email: `${uid}@example.com`,
    email_verified: true,
  }).firestore();

const unverified = (uid) =>
  env.authenticatedContext(uid, {
    email: `${uid}@example.com`,
    email_verified: false,
  }).firestore();

const signedOut = () => env.unauthenticatedContext().firestore();

const CREATED_AT = Timestamp.fromDate(new Date('2026-02-03T04:05:00Z'));

const privateProfile = (overrides = {}) => ({
  name: 'Taha Tahir',
  phone: '+923001234567',
  bloodGroup: 'bPositive',
  locationId: 'g9_islamabad',
  latitude: 33.694,
  longitude: 73.033,
  geohash: 'tttttttt1',
  lastDonationDate: null,
  isAvailable: true,
  isVisible: true,
  createdAt: CREATED_AT,
  ...overrides,
});

const donorEntry = (overrides = {}) => ({
  name: 'Taha Tahir',
  bloodGroup: 'bPositive',
  locationId: 'g9_islamabad',
  latitude: 33.694,
  longitude: 73.033,
  geohash: 'tttttttt1',
  isAvailable: true,
  ...overrides,
});

const seed = (path, data) =>
  env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));

const remove = (path) =>
  env.withSecurityRulesDisabled((ctx) => deleteDoc(doc(ctx.firestore(), path)));

const ts = (date) => Timestamp.fromDate(date);
const hoursFromNow = (hours) => new Date(Date.now() + hours * 3_600_000);
const daysAgo = (days) => new Date(Date.now() - days * 86_400_000);

// A valid blood request posted by 'alice' for a B+ patient.
const bloodRequest = (overrides = {}) => ({
  requesterUid: 'alice',
  requesterName: 'Taha Tahir',
  bloodGroup: 'bPositive',
  units: 2,
  urgency: 'urgent',
  hospitalId: 'pims_islamabad',
  latitude: 33.708,
  longitude: 73.055,
  geohash: 'tttttttt1',
  note: 'Ward 4, ask for Dr. Ahmed',
  status: 'open',
  createdAt: ts(new Date()),
  expiresAt: ts(hoursFromNow(72)),
  ...overrides,
});

// A valid response from 'bob' (an O- donor) to alice's request.
const donorResponse = (overrides = {}) => ({
  donorUid: 'bob',
  donorName: 'Bilal Khan',
  phone: '+923011234567',
  bloodGroup: 'oNegative',
  locationId: 'g9_islamabad',
  respondedAt: ts(new Date()),
  ...overrides,
});

const bobProfile = (overrides = {}) =>
  privateProfile({
    name: 'Bilal Khan',
    phone: '+923011234567',
    bloodGroup: 'oNegative',
    ...overrides,
  });

// Independent model of blood compatibility, written from the antigens so a
// typo in the rules' lists cannot be copied here.
const GROUPS = {
  aPositive: { a: true, b: false, rh: true },
  aNegative: { a: true, b: false, rh: false },
  bPositive: { a: false, b: true, rh: true },
  bNegative: { a: false, b: true, rh: false },
  abPositive: { a: true, b: true, rh: true },
  abNegative: { a: true, b: true, rh: false },
  oPositive: { a: false, b: false, rh: true },
  oNegative: { a: false, b: false, rh: false },
};
const canDonate = (donor, recipient) => {
  const d = GROUPS[donor];
  const r = GROUPS[recipient];
  return (!d.a || r.a) && (!d.b || r.b) && (!d.rh || r.rh);
};

// ---- users/{uid} ---------------------------------------------------------

describe('users/{uid}', () => {
  it('lets the verified owner create a valid profile', async () => {
    await assertSucceeds(setDoc(doc(verified('alice'), 'users/alice'), privateProfile()));
  });

  it('lets the owner read their own profile', async () => {
    await seed('users/alice', privateProfile());
    await assertSucceeds(getDoc(doc(verified('alice'), 'users/alice')));
  });

  it('blocks other users from reading a profile (phone number is private)', async () => {
    await seed('users/alice', privateProfile());
    await assertFails(getDoc(doc(verified('mallory'), 'users/alice')));
  });

  it('blocks signed-out access entirely', async () => {
    await assertFails(getDoc(doc(signedOut(), 'users/alice')));
    await assertFails(setDoc(doc(signedOut(), 'users/alice'), privateProfile()));
  });

  it('blocks accounts whose email is not verified', async () => {
    await assertFails(setDoc(doc(unverified('alice'), 'users/alice'), privateProfile()));
  });

  it('blocks writing to someone else\'s profile', async () => {
    await assertFails(setDoc(doc(verified('mallory'), 'users/alice'), privateProfile()));
  });

  it('blocks listing the users collection', async () => {
    await seed('users/alice', privateProfile());
    await assertFails(getDocs(collection(verified('alice'), 'users')));
  });

  it('rejects unknown fields', async () => {
    await assertFails(
      setDoc(doc(verified('alice'), 'users/alice'), privateProfile({ isAdmin: true })),
    );
  });

  it('rejects a malformed phone number', async () => {
    await assertFails(
      setDoc(doc(verified('alice'), 'users/alice'), privateProfile({ phone: '03001234567' })),
    );
  });

  it('rejects an unknown blood group', async () => {
    await assertFails(
      setDoc(doc(verified('alice'), 'users/alice'), privateProfile({ bloodGroup: 'zNegative' })),
    );
  });

  it('rejects coordinates outside the twin cities', async () => {
    await assertFails(
      setDoc(doc(verified('alice'), 'users/alice'), privateProfile({ latitude: 24.86, longitude: 67.0 })),
    );
  });

  it('rejects a last-donation date in the future', async () => {
    const nextWeek = Timestamp.fromDate(new Date(Date.now() + 7 * 86_400_000));
    await assertFails(
      setDoc(doc(verified('alice'), 'users/alice'), privateProfile({ lastDonationDate: nextWeek })),
    );
  });

  it('allows editing a field but not changing createdAt', async () => {
    await seed('users/alice', privateProfile());
    const ref = doc(verified('alice'), 'users/alice');
    await assertSucceeds(setDoc(ref, privateProfile({ name: 'Taha T.' })));
    await assertFails(
      setDoc(ref, privateProfile({ createdAt: Timestamp.fromDate(new Date('2030-01-01T00:00:00Z')) })),
    );
  });

  it('never allows deleting a profile', async () => {
    await seed('users/alice', privateProfile());
    await assertFails(deleteDoc(doc(verified('alice'), 'users/alice')));
  });
});

// ---- donors/{uid} --------------------------------------------------------

describe('donors/{uid}', () => {
  it('lets a verified user read a donor entry', async () => {
    await seed('donors/alice', donorEntry());
    await assertSucceeds(getDoc(doc(verified('bob'), 'donors/alice')));
  });

  it('blocks signed-out reads', async () => {
    await seed('donors/alice', donorEntry());
    await assertFails(getDoc(doc(signedOut(), 'donors/alice')));
  });

  it('allows a list query with limit <= 50 and denies the rest', async () => {
    const donors = (db) => collection(db, 'donors');
    await assertSucceeds(getDocs(query(donors(verified('bob')), limit(50))));
    await assertFails(getDocs(query(donors(verified('bob')), limit(51))));
    await assertFails(getDocs(donors(verified('bob'))));
  });

  it('lets the owner publish a valid entry, with and without eligibleFrom', async () => {
    const ref = doc(verified('alice'), 'donors/alice');
    await assertSucceeds(setDoc(ref, donorEntry()));
    await assertSucceeds(
      setDoc(ref, donorEntry({ eligibleFrom: Timestamp.fromDate(new Date('2026-04-10T00:00:00Z')) })),
    );
  });

  it('blocks publishing under someone else\'s uid', async () => {
    await assertFails(setDoc(doc(verified('mallory'), 'donors/alice'), donorEntry()));
  });

  it('rejects a phone number leaking into the public entry', async () => {
    await assertFails(
      setDoc(doc(verified('alice'), 'donors/alice'), donorEntry({ phone: '+923001234567' })),
    );
  });

  it('lets the owner, and only the owner, remove their entry', async () => {
    await seed('donors/alice', donorEntry());
    await assertFails(deleteDoc(doc(verified('mallory'), 'donors/alice')));
    await assertSucceeds(deleteDoc(doc(verified('alice'), 'donors/alice')));
  });

  it('does not let others edit an entry', async () => {
    await seed('donors/alice', donorEntry());
    await assertFails(updateDoc(doc(verified('mallory'), 'donors/alice'), { isAvailable: false }));
  });
});


// ---- bloodRequests/{id} --------------------------------------------------

describe('bloodRequests/{id}', () => {
  beforeEach(async () => {
    await seed('users/alice', privateProfile());
  });

  it('lets a verified user with a profile post a valid request', async () => {
    await assertSucceeds(setDoc(doc(verified('alice'), 'bloodRequests/r1'), bloodRequest()));
  });

  it('blocks signed-out and unverified users from posting', async () => {
    await assertFails(setDoc(doc(signedOut(), 'bloodRequests/r1'), bloodRequest()));
    await assertFails(setDoc(doc(unverified('alice'), 'bloodRequests/r1'), bloodRequest()));
  });

  it('blocks posting as someone else', async () => {
    await seed('users/mallory', privateProfile({ name: 'Mallory' }));
    await assertFails(
      setDoc(doc(verified('mallory'), 'bloodRequests/r1'), bloodRequest({ requesterUid: 'alice' })),
    );
  });

  it('blocks posting without a profile', async () => {
    await assertFails(
      setDoc(
        doc(verified('nobody'), 'bloodRequests/r1'),
        bloodRequest({ requesterUid: 'nobody' }),
      ),
    );
  });

  it('rejects a requester name that is not the profile name', async () => {
    await assertFails(
      setDoc(doc(verified('alice'), 'bloodRequests/r1'), bloodRequest({ requesterName: 'Someone Else' })),
    );
  });

  it('rejects a new request that is already closed', async () => {
    await assertFails(
      setDoc(doc(verified('alice'), 'bloodRequests/r1'), bloodRequest({ status: 'fulfilled' })),
    );
  });

  it('rejects units outside 1..10', async () => {
    await assertFails(setDoc(doc(verified('alice'), 'bloodRequests/r1'), bloodRequest({ units: 0 })));
    await assertFails(setDoc(doc(verified('alice'), 'bloodRequests/r2'), bloodRequest({ units: 11 })));
    await assertSucceeds(setDoc(doc(verified('alice'), 'bloodRequests/r3'), bloodRequest({ units: 10 })));
  });

  it('rejects an unknown urgency, blood group or extra field', async () => {
    const db = verified('alice');
    await assertFails(setDoc(doc(db, 'bloodRequests/r1'), bloodRequest({ urgency: 'whenever' })));
    await assertFails(setDoc(doc(db, 'bloodRequests/r2'), bloodRequest({ bloodGroup: 'xNegative' })));
    await assertFails(setDoc(doc(db, 'bloodRequests/r3'), bloodRequest({ phone: '+923001234567' })));
  });

  it('rejects coordinates outside the twin cities', async () => {
    await assertFails(
      setDoc(
        doc(verified('alice'), 'bloodRequests/r1'),
        bloodRequest({ latitude: 24.86, longitude: 67.0 }),
      ),
    );
  });

  it('rejects an over-long note', async () => {
    await assertFails(
      setDoc(doc(verified('alice'), 'bloodRequests/r1'), bloodRequest({ note: 'x'.repeat(201) })),
    );
  });

  it('rejects a creation time far from the server time', async () => {
    await assertFails(
      setDoc(
        doc(verified('alice'), 'bloodRequests/r1'),
        bloodRequest({ createdAt: ts(daysAgo(7)), expiresAt: ts(hoursFromNow(72)) }),
      ),
    );
  });

  it('rejects an expiry more than 8 days after creation, or before it', async () => {
    const db = verified('alice');
    await assertFails(
      setDoc(doc(db, 'bloodRequests/r1'), bloodRequest({ expiresAt: ts(hoursFromNow(24 * 9)) })),
    );
    await assertFails(
      setDoc(doc(db, 'bloodRequests/r2'), bloodRequest({ expiresAt: ts(daysAgo(1)) })),
    );
  });

  it('lets any verified user read a request, and blocks signed-out reads', async () => {
    await seed('bloodRequests/r1', bloodRequest());
    await assertSucceeds(getDoc(doc(verified('bob'), 'bloodRequests/r1')));
    await assertFails(getDoc(doc(signedOut(), 'bloodRequests/r1')));
  });

  it('allows the feed queries with a limit and denies them without one', async () => {
    const requests = (db) => collection(db, 'bloodRequests');
    const feed = (db, n) =>
      query(
        requests(db),
        where('status', '==', 'open'),
        where('bloodGroup', 'in', ['bPositive', 'abPositive']),
        where('expiresAt', '>', ts(new Date())),
        orderBy('expiresAt'),
        limit(n),
      );
    await assertSucceeds(getDocs(feed(verified('bob'), 50)));
    await assertFails(getDocs(feed(verified('bob'), 51)));
    await assertFails(getDocs(query(requests(verified('bob')), where('status', '==', 'open'))));
  });

  it('lets the requester close their open request', async () => {
    await seed('bloodRequests/r1', bloodRequest());
    await assertSucceeds(updateDoc(doc(verified('alice'), 'bloodRequests/r1'), { status: 'fulfilled' }));
    await seed('bloodRequests/r2', bloodRequest());
    await assertSucceeds(updateDoc(doc(verified('alice'), 'bloodRequests/r2'), { status: 'cancelled' }));
  });

  it('does not let anyone else close it', async () => {
    await seed('bloodRequests/r1', bloodRequest());
    await assertFails(updateDoc(doc(verified('mallory'), 'bloodRequests/r1'), { status: 'cancelled' }));
  });

  it('does not let the requester change anything but the status', async () => {
    await seed('bloodRequests/r1', bloodRequest());
    const ref = doc(verified('alice'), 'bloodRequests/r1');
    await assertFails(updateDoc(ref, { status: 'fulfilled', units: 9 }));
    await assertFails(updateDoc(ref, { units: 9 }));
    await assertFails(updateDoc(ref, { requesterUid: 'mallory' }));
  });

  it('never reopens or edits a closed request', async () => {
    await seed('bloodRequests/r1', bloodRequest({ status: 'cancelled' }));
    const ref = doc(verified('alice'), 'bloodRequests/r1');
    await assertFails(updateDoc(ref, { status: 'open' }));
    await assertFails(updateDoc(ref, { status: 'fulfilled' }));
  });

  it('never allows deleting a request', async () => {
    await seed('bloodRequests/r1', bloodRequest());
    await assertFails(deleteDoc(doc(verified('alice'), 'bloodRequests/r1')));
  });
});

// ---- bloodRequests/{id}/responses/{donorUid} -----------------------------

describe('bloodRequests/{id}/responses/{donorUid}', () => {
  const path = (donor = 'bob') => `bloodRequests/r1/responses/${donor}`;

  beforeEach(async () => {
    await seed('users/alice', privateProfile());
    await seed('users/bob', bobProfile());
    await seed('bloodRequests/r1', bloodRequest());
  });

  it('lets a compatible, available donor respond with their own details', async () => {
    await assertSucceeds(setDoc(doc(verified('bob'), path()), donorResponse()));
  });

  it('blocks signed-out and unverified users', async () => {
    await assertFails(setDoc(doc(signedOut(), path()), donorResponse()));
    await assertFails(setDoc(doc(unverified('bob'), path()), donorResponse()));
  });

  it('blocks responding under someone else\'s uid', async () => {
    await assertFails(setDoc(doc(verified('mallory'), path('bob')), donorResponse()));
  });

  it('rejects a phone number that is not the donor\'s own', async () => {
    await assertFails(
      setDoc(doc(verified('bob'), path()), donorResponse({ phone: '+923331112222' })),
    );
  });

  it('rejects a name, blood group or area that differs from the profile', async () => {
    const db = verified('bob');
    await assertFails(setDoc(doc(db, path()), donorResponse({ donorName: 'Someone Else' })));
    await assertFails(setDoc(doc(db, path()), donorResponse({ bloodGroup: 'bNegative' })));
    await assertFails(setDoc(doc(db, path()), donorResponse({ locationId: 'f7_islamabad' })));
  });

  it('rejects a malformed phone number or extra field', async () => {
    const db = verified('bob');
    await seed('users/bob', bobProfile({ phone: '03011234567' })); // not E.164
    await assertFails(setDoc(doc(db, path()), donorResponse({ phone: '03011234567' })));
    await seed('users/bob', bobProfile());
    await assertFails(setDoc(doc(db, path()), donorResponse({ isAdmin: true })));
  });

  it('blocks responding without a profile', async () => {
    await assertFails(
      setDoc(doc(verified('ghost'), path('ghost')), donorResponse({ donorUid: 'ghost' })),
    );
  });

  it('blocks the requester from responding to their own request', async () => {
    await assertFails(
      setDoc(
        doc(verified('alice'), path('alice')),
        donorResponse({
          donorUid: 'alice',
          donorName: 'Taha Tahir',
          phone: '+923001234567',
          bloodGroup: 'bPositive',
        }),
      ),
    );
  });

  it('blocks responding to a closed request', async () => {
    await seed('bloodRequests/r1', bloodRequest({ status: 'fulfilled' }));
    await assertFails(setDoc(doc(verified('bob'), path()), donorResponse()));
  });

  it('blocks responding to an expired request', async () => {
    await seed('bloodRequests/r1', bloodRequest({ expiresAt: ts(daysAgo(1)), createdAt: ts(daysAgo(4)) }));
    await assertFails(setDoc(doc(verified('bob'), path()), donorResponse()));
  });

  it('blocks a donor who set themselves unavailable', async () => {
    await seed('users/bob', bobProfile({ isAvailable: false }));
    await assertFails(setDoc(doc(verified('bob'), path()), donorResponse()));
  });

  it('enforces the 90-day interval', async () => {
    await seed('users/bob', bobProfile({ lastDonationDate: ts(daysAgo(10)) }));
    await assertFails(setDoc(doc(verified('bob'), path()), donorResponse()));

    await seed('users/bob', bobProfile({ lastDonationDate: ts(daysAgo(91)) }));
    await assertSucceeds(setDoc(doc(verified('bob'), path()), donorResponse()));
  });

  it('allows exactly the compatible blood groups (all 64 pairs)', async () => {
    for (const donor of Object.keys(GROUPS)) {
      for (const recipient of Object.keys(GROUPS)) {
        await seed('users/bob', bobProfile({ bloodGroup: donor }));
        await seed('bloodRequests/r1', bloodRequest({ bloodGroup: recipient }));
        await remove(path());

        const attempt = setDoc(doc(verified('bob'), path()), donorResponse({ bloodGroup: donor }));
        if (canDonate(donor, recipient)) {
          await assertSucceeds(attempt);
        } else {
          await assertFails(attempt);
        }
      }
    }
  });

  it('lets the donor and the requester read the response, and nobody else', async () => {
    await seed(path(), donorResponse());
    await assertSucceeds(getDoc(doc(verified('bob'), path())));
    await assertSucceeds(getDoc(doc(verified('alice'), path())));
    await assertFails(getDoc(doc(verified('mallory'), path())));
    await assertFails(getDoc(doc(signedOut(), path())));
  });

  it('lets the donor check for their own missing response', async () => {
    await assertSucceeds(getDoc(doc(verified('bob'), path())));
  });

  it('lets only the requester list responses, and only with a limit', async () => {
    await seed(path(), donorResponse());
    const responses = (db) => collection(db, 'bloodRequests/r1/responses');

    await assertSucceeds(getDocs(query(responses(verified('alice')), orderBy('respondedAt'), limit(50))));
    await assertFails(getDocs(query(responses(verified('alice')), limit(51))));
    await assertFails(getDocs(responses(verified('alice'))));
    await assertFails(getDocs(query(responses(verified('bob')), limit(10))));
    await assertFails(getDocs(query(responses(verified('mallory')), limit(10))));
  });

  it('does not allow editing a response', async () => {
    await seed(path(), donorResponse());
    await assertFails(updateDoc(doc(verified('bob'), path()), { donorName: 'Changed Name' }));
    await assertFails(setDoc(doc(verified('bob'), path()), donorResponse({ donorName: 'Changed Name' })));
  });

  it('lets only the donor withdraw their response', async () => {
    await seed(path(), donorResponse());
    await assertFails(deleteDoc(doc(verified('alice'), path())));
    await assertFails(deleteDoc(doc(verified('mallory'), path())));
    await assertSucceeds(deleteDoc(doc(verified('bob'), path())));
  });
});

// ---- donors/{uid}: the directory query the app runs ----------------------

describe('donor directory search query', () => {
  it('allows the geohash range query with a limit', async () => {
    const search = (db, n) =>
      query(
        collection(db, 'donors'),
        where('isAvailable', '==', true),
        where('bloodGroup', 'in', ['oNegative', 'bNegative']),
        where('geohash', '>=', 'ttt'),
        where('geohash', '<', 'ttt~'),
        limit(n),
      );
    await assertSucceeds(getDocs(search(verified('bob'), 50)));
    await assertFails(getDocs(search(verified('bob'), 51)));
    await assertFails(getDocs(search(signedOut(), 50)));
  });
});

// ---- everything else -----------------------------------------------------

describe('unknown collections', () => {
  it('are denied by default', async () => {
    await assertFails(setDoc(doc(verified('alice'), 'anything/else'), { x: 1 }));
    await assertFails(getDoc(doc(verified('alice'), 'anything/else')));
  });
});
