# Setup-to-PLANK drawing handoff

## Operator flow

Use PLANK AVP Relay Setup to discover, authorize and configure a relay. Test the
pen, stop the test, then choose **Use in PLANK**. Setup stops and awaits any
remaining preview before opening PLANK, releasing the shared capture lease.

For a new drawing identity, PLANK offers **Continue in Relay Setup**. Choose
**Allow PLANK** in Setup; PLANK then verifies the drawing connection and saves
its own approval. This requires no tablet-specific ExpressKey gesture. An
already approved relay can be selected without repeating registration.

PLANK Vision offers Automatic, Bluetooth or Network for each registered relay.
Automatic tries saved network routes and then Bluetooth. Explicit Bluetooth
and Network selections do not fall back to the other transport. To add a
Bluetooth route, open the relay over Bluetooth in Setup and choose Use in PLANK.
A Bluetooth-only handoff can work without a relay network address.

The labels distinguish three links:

- Setup connection: the verified Bluetooth or network management connection.
- Tablet connection: USB or Bluetooth between the Wacom and Linux.
- Drawing connection: authenticated Bluetooth or network between the relay and
  PLANK Vision, carrying raw HID and reverse workstation controls.

## Matching components and installation

PLANK AVP Relay 0.6.8 installs both services in one `.deb`; see
[complete installation](complete-relay-installation.md). The managed service
bridges opaque L2CAP channel 3 traffic to the raw daemon, which owns drawing
authentication, tablet capture and reverse controls. Both services use the
shared exclusive capture lease. Setup and PLANK cannot capture the tablet
simultaneously; stop drawing before changing tablet configuration.

The raw source is pinned in `packaging/drawing-source.json` to
`029721f9b60833d36aa31f4da558cf8325e111ca` from
[raw Relay PR #4](https://github.com/cnoellert/plank-tablet-relay/pull/4).
The package verifies the archive hash before building it.

The matching PLANK Vision implementation is
[Client PR #4](https://github.com/cnoellert/plank-client/pull/4), build 46:
publication `5f2d28a10a0a1a113b7618bcf4e7b1e521f00725`, runtime
`d0056978e823a7f9a999efe9336cdb155aa61f35`. Its tablet-outage recovery is required
for disappearance/return without a desktop reconnect. Development-device
acceptance and App Store delivery are separate; verify the Client's actual
availability before planning a user test. Releasing Setup does not release
the separate Vision Client.

Both signed apps need the same permitted
`la.instinctual.PLANK.DrawingRegistration` Keychain access group. Setup retains
`la.instinctual.PLANK.AVPrelay` and its existing private pairing namespace.
The shared group contains public registration receipts only. Private keys
remain in the original app-local groups. Updates do not reset current approvals.

## Trust and transport boundaries

Public identities, radio identifiers and addresses are route hints, not approval.
Setup verifies its saved management identity and fresh drawing status before
preparing a short-lived grant bound to the intended Client key and drawing
identity. PLANK requires the exact approved receipt and proves possession of its
private key before the raw service commits enrollment. Only then does PLANK
store the verified drawing pin. Canceled, expired, replayed or mismatched grants
are refused; an ambiguous proof is not automatically replayed. Cancellation
cannot undo a grant already durably committed by the raw service.

The public status socket `plank-tablet-drawing-status-v1` remains read-only.
The separate root-only mutation socket is `plank-tablet-drawing-enrollment-v1`;
management requests require the authenticated current owner. Enrollment does
not acquire tablet capture or open pairing windows. Missing or invalid drawing
metadata reports unavailable while normal Setup management remains usable.

The frozen `plank-drawing-handoff-v1+r3` contract remains TCP-only for V1 callers.
Current Setup opts into V2 to include verified Bluetooth capability and a
peripheral route. The pinned raw source describes the extensions in
`docs/setup-drawing-enrollment.md` and `docs/registered-relay-transports.md`.

## Verification and remaining qualification

Run Apple Setup tests, macOS/simulator/device builds, bundle/signing validation,
and both native Linux package and independent installation jobs. Regression
checks cover identity/receipt validation, grant handling, bounded bridges,
status failures, exclusive capture, transport selection and package provenance.

Chris reports successful development-device registration, explicit Bluetooth
and Network drawing with pen controls/reconnect, package migration, sleep/wake,
USB/Bluetooth tablet switching, tablet disappearance/return and service restart
recovery. These results are recorded in the Client build 46 preflight notes.

The Bluetooth drawing test with every relay non-loopback network interface
disabled used a USB tablet. The fully wireless Wacom → relay → Bluetooth AVP
chain still needs separate confirmation, including drawing, pen controls and
reconnect with no TCP fallback. Preserve identities and pairing when deploying
for that test. Periodic video stutters and Host input-queue overflow are separate
Client/Host issues and are not claimed fixed by this release.
