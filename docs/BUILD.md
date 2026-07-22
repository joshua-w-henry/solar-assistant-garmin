# Build and installation

## 1. Prepare the local configuration

```bash
./scripts/create-config.sh
nano source/SolarConfig.mc
```

Use the token accepted by your HTTPS bridge—not a Solar Assistant UI or administrator token unless your bridge explicitly uses that credential model.

## 2. Open the correct folder

Open the repository root in VS Code. The Explorer should show these at top level:

```text
manifest.xml
monkey.jungle
resources/
source/
```

Opening the parent directory causes the Garmin extension to report that the folder is not a Connect IQ project.

## 3. Select a target

Run **Monkey C: Edit Products**. The repository currently includes `epix2pro51mm`, the device on which this version was proven.

Add other products cautiously and test layout, memory, background execution, and complication support on each device.

## 4. Run in the simulator

Run **Monkey C: Run Project**. After the app retrieves data:

1. Confirm the live screen updates.
2. Open the daily-totals page.
3. Open **Simulation → Complications**.
4. Confirm `Current Load`, `Current PV`, `PV Produced Today`, and `Battery Voltage` are active.

## 5. Install for normal app testing

A development `.prg` may be sideloaded for app testing. Do not distribute it; it contains the configured token.

## 6. Test Face It complications

In project testing, Face It did not discover custom complications from a raw sideload. They became available after the app was exported and installed through a private Connect IQ beta listing.

Recommended flow:

1. Give the beta build its own application UUID if required by Garmin's beta workflow.
2. Run **Monkey C: Export Project**.
3. Upload the `.iq` to a private Connect IQ beta listing.
4. Install the beta through Connect IQ and sync the watch.
5. Open the app once to publish current values and register the background event.
6. Create or edit a Face It face and select the custom complications.

## 7. Background refresh test

1. Leave the Garmin app closed.
2. Change a recognizable electrical load.
3. Wait at least five to six minutes.
4. Verify that the complication value updates.

Garmin controls background scheduling, so the five-minute request is not a promise of second-exact execution.

## Before public distribution

Do not publicly distribute a binary with a personal bridge URL or token compiled into it. A broadly distributed store build needs a secure user-configuration design rather than a shared build-time credential.
