# AI Configuration & Setup Prompt

Copy and paste the prompt below into your favorite AI coding assistant (Claude, ChatGPT, Cursor, etc.) to automatically configure this script for your server. This prompt is engineered to handle discovery, framework integration, and custom setup.

---

### Senior Engineer Prompt for `peak-trucking` Integration

**Context:**
You are a Senior FiveM Developer. I have installed the `peak-trucking` resource, a full-featured trucking job with driver progression, company trust, daily missions, leaderboards, optional illegal cargo, and a React-based NUI dispatch tablet. I need you to configure it to match my server's environment perfectly.

**Your Objective:**
Analyze my server files, identify dependencies, and perform all necessary configuration steps to make the script production-ready.

**Step 1: Discovery Phase**
- Scan my server's resource folder to identify the active Framework (e.g., QBCore, ESX, or Custom).
- Identify the Inventory system (e.g., ox_inventory, qb-inventory, qs-inventory, esx_inventory).
- Identify the Interaction system being used (e.g., drawtext, ox_target, qb_target, qb_textui, esx_textui).
- Confirm if `oxmysql` is installed and running.

**Step 2: Configuration Mapping**
- Based on your findings, update `shared/config.lua`. Ensure `Config.Framework`, `Config.SQL`, `Config.Inventory`, and `Config.InteractionHandler` are set correctly.
- Review the NPC spawn coordinates (`Config.NpcLocation`) and vehicle spawn (`Config.VehSpawn`) to confirm they suit my server's map setup.
- Update `Config.JobName` if my server uses a specific job restriction (set to `"all"` to allow anyone).

**Step 3: Vehicle & Key Integration**
- Locate the key system used on my server (e.g., qb-vehiclekeys, qs-vehiclekeys, or a custom export).
- Update `Config.GiveVehicleKey` and `Config.RemoveVehiclekey` functions in `shared/config.lua` to call the correct export or event for my key system.
- Confirm `Config.SetVehicleFuel` is wired to my fuel system export or set it to a no-op if fuel management is not needed.

**Step 4: Database Check**
- Import [install/install.sql](install/install.sql) into my database to create the `peak_trucking` table.
- Ensure the SQL driver in `Config.SQL` matches my setup (`oxmysql`, `ghmattimysql`, or `mysql-async`).

**Step 5: Final Validation**
- Review `fxmanifest.lua` to ensure all script paths are correct.
- Review `server/server-config.lua` and confirm `ServerConfig.DiscordBotToken` is left empty unless I want Discord avatar lookups in the leaderboard.
- Check for any potential conflicts with other trucking or job scripts.
- Perform a final syntax check on all modified files.

**Instructions for the AI:**
- Do not make changes until you have confirmed the framework, inventory, and interaction handler names.
- Ask for clarification if you cannot find a specific dependency.
- Keep all custom integrations inside `shared/config.lua` hooks (`Config.GiveVehicleKey`, `Config.RemoveVehiclekey`, `Config.SetVehicleFuel`) to avoid touching core logic.
