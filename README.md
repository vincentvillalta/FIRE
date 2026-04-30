# FIRE Tracker

A private, local-first iOS retirement portfolio tracker built with SwiftUI, SwiftData, and XcodeGen.

## FIRE planner

The Plan tab combines your current portfolio value with age, income, monthly investment, investment rate, target yearly spend, expected return, withdrawal rate, and tracking start date. It estimates:

- FIRE number
- FIRE month and age
- Monthly investment habit
- Monthly gap to close
- Amount invested since the tracking start date
- Progress toward financial independence

## Entries

Use the Add tab to create a holding entry with:

- Ticker
- Name
- Invested amount in EUR
- Bought-at price
- Amount of stocks
- Date

Entries can be deleted from the Holdings tab, but there is no edit flow.

## Privacy model

Holdings, cost basis, FIRE inputs, and performance calculations are stored only in SwiftData on the device. Price refreshes call the quote provider with ticker symbols so current prices can be fetched; portfolio amounts and share counts are not sent.

## Build

```sh
xcodegen generate
xcodebuild -scheme FIRETracker -destination 'platform=iOS Simulator,name=iPhone 17' build
```
