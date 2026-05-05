import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { promises as fs } from "node:fs";
import path from "node:path";
import os from "node:os";

interface TunnelManifest {
  ports?: Record<string, number>;
  urls?: Record<string, string>;
}

async function exists(file: string) {
  try {
    await fs.access(file);
    return true;
  } catch {
    return false;
  }
}

function shellQuote(s: string) {
  return `'${s.replace(/'/g, `'"'"'`)}'`;
}

async function findManifest(cwd: string, explicit?: string) {
  const candidates = explicit
    ? [path.resolve(cwd, explicit)]
    : [
        path.join(cwd, ".fundlaunch/tunnels.json"),
        path.join(cwd, ".fundlaunch/manifest.json"),
        path.join(cwd, ".devkit/tunnels.json"),
        path.join(cwd, "tunnels.json"),
      ];
  for (const candidate of candidates) {
    if (await exists(candidate)) return candidate;
  }
  return undefined;
}

function projectRootForManifest(file: string) {
  const dir = path.dirname(file);
  const base = path.basename(dir);
  return base.startsWith(".") ? path.dirname(dir) : dir;
}

function renderManifest(file: string, manifest: TunnelManifest) {
  const ports = manifest.ports ?? {};
  const urls = manifest.urls ?? {};
  const host = process.env.DEVKIT_TUNNEL_HOST ?? os.hostname().split(".")[0];
  const projectRoot = projectRootForManifest(file);
  const lines: string[] = [];

  lines.push(`Tunnel manifest: ${file}`);
  lines.push("");
  lines.push("Run this on your client machine:");
  lines.push("");
  lines.push(`  devkit attach --keep --open ${host} ${shellQuote(projectRoot)}`);
  lines.push("");
  lines.push("Or directly:");
  lines.push("");
  lines.push(`  tunnel --keep ${host} --remote-manifest ${shellQuote(file)}`);
  lines.push("");

  const portEntries = Object.entries(ports);
  if (portEntries.length > 0) {
    lines.push("Ports:");
    for (const [name, port] of portEntries) lines.push(`  ${name}: ${port}`);
    lines.push("");
  }

  const urlEntries = Object.entries(urls);
  if (urlEntries.length > 0) {
    lines.push("URLs after tunnel is open:");
    for (const [name, url] of urlEntries) lines.push(`  ${name}: ${url}`);
  }

  return lines.join("\n");
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("tunnels", {
    description: "Show devkit tunnel manifest and client-side tunnel command",
    handler: async (args, ctx) => {
      const file = await findManifest(ctx.cwd, args.trim() || undefined);
      if (!file) {
        ctx.ui.notify("No tunnel manifest found. Expected .fundlaunch/manifest.json or .devkit/tunnels.json", "warn");
        return;
      }

      try {
        const manifest = JSON.parse(await fs.readFile(file, "utf8")) as TunnelManifest;
        pi.sendMessage({
          customType: "devkit-tunnels",
          content: renderManifest(file, manifest),
          display: true,
        });
      } catch (error) {
        ctx.ui.notify(`Failed to read tunnel manifest: ${error instanceof Error ? error.message : String(error)}`, "error");
      }
    },
  });
}
