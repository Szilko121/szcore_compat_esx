# szcore_compat_esx API reference

Generated from the 1.4.0-rc1 source tree.

## Exports

- `getSharedObject`

## Network events

- `esx:showNotification`

## Local/event handlers

- `playerDropped`
- `szcore:client:onPlayerData`
- `szcore:client:onPlayerLoaded`
- `szcore:client:onPlayerUnloaded`
- `szcore:server:jobChanged`
- `szcore:server:playerLoaded`
- `szcore:server:playerUnloaded`

## Commands

- No direct `RegisterCommand` entry detected.

## Integration guidance

Use exports for stable cross-resource integration. Treat raw net events as internal unless explicitly documented in the central framework docs. Compatibility adapters may expose additional ESX/QB/Qbox-shaped APIs that forward into native SzCore services.
