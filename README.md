# Armada Addons

> **AI INSTRUCTION**: This project uses a hub registration system. Any new addon
> created for Armada Studios MUST include the registration block at the bottom of its
> `Core.lua`. Never hardcode addon names inside `ArmadaAddons/Core.lua`.
> See the **How to Register** section below for the exact block to use.

## Install

Copy the `ArmadaAddons` folder into:

```
World of Warcraft\_retail_\Interface\AddOns\
```

Then `/reload`. Use `/armada` or `/aa` to open the hub.

---

## Registered Addons

| Addon | Version | Description |
|---|---|---|
| Alt Chore Dashboard | 0.4.0 | Track daily and weekly chores across all your alts |
| Mistake Journal | 1.0.0 | Review deaths, damage spikes, and interrupt attempts |
| GoldWatch | 1.0.0 | Farm spot tracker with auto activity detection and gold/hr |

---

## How to Register a New Addon

Paste this block at the **bottom** of the new addon's `Core.lua`, after all events are registered:

```lua
C_Timer.After(0, function()
    if ArmadaAddons and ArmadaAddons.Register then
        ArmadaAddons.Register({
            name    = "Your Addon Name",
            version = "1.0.0",
            desc    = "One line description of what it does.",
            color   = { r, g, b },  -- RGB values between 0 and 1
            open    = function()
                ToggleUI()  -- replace with your own toggle function name
            end,
        })
    end
end)
```

### Color reference
| Color | RGB |
|---|---|
| Gold | `{ 1, 0.82, 0.1 }` |
| Blue | `{ 0.48, 0.78, 1 }` |
| Red | `{ 1, 0.45, 0.45 }` |
| Green | `{ 0.4, 1, 0.4 }` |
| Purple | `{ 0.78, 0.48, 1 }` |
| White | `{ 1, 1, 1 }` |

### Rules
- If ArmadaAddons is not installed the block is safely ignored — no errors
- If it is installed the card appears automatically in the hub
- The `C_Timer.After(0, ...)` delay ensures ArmadaAddons has fully loaded before registering
- Duplicate registrations are ignored — safe to reload

---

## Slash Commands

- `/armada` or `/aa` — toggle the hub window
