# szcore_compat_esx configuration

## Dependencies

`szcore`

## Files

Review `config.lua`, `config/`, `shared/` and resource-specific configuration files when present. The resource intentionally keeps its configuration close to the feature instead of centralizing all settings in the core.

## Startup order

Start `oxmysql` first, then `szcore`, then shared SzCore infrastructure such as `szcore_ui`, followed by feature modules. The complete tested order is maintained by `SzCore-Recipe`.

## Performance

Do not lower wait intervals or add per-frame loops without profiling. Prefer event-driven updates, indexed lookups, dirty-state persistence and server-side batching.
