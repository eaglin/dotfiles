import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const baseUrl = "https://api.klia.tech/v1";

async function resolveApiKey(): Promise<string | undefined> {
  if (process.env.KLIA_API_KEY) return process.env.KLIA_API_KEY;

  try {
    const auth = JSON.parse(
      await readFile(`${homedir()}/.pi/agent/auth.json`, "utf8"),
    ) as { klia?: { type?: string; key?: string } };
    return auth.klia?.type === "api_key" ? auth.klia.key : undefined;
  } catch {
    return undefined;
  }
}

type KliaModel = {
  id: string;
  owned_by?: string;
};

// Curated whitelist of worthwhile models on KLIA.
// Only these are surfaced; everything else returned by /models is ignored.
// Override fields (contextWindow, maxTokens, reasoning, thinkingLevelMap,
// thinkingFormat) are merged onto the registered model entry.
type Overrides = {
  contextWindow?: number;
  maxTokens?: number;
  reasoning?: boolean;
  thinkingLevelMap?: Record<string, string | null>;
  thinkingFormat?: string;
};

const WHITELIST: Record<string, Overrides> = {
  "GLM-5.2": {
    contextWindow: 1000000,
    maxTokens: 131072,
    reasoning: true,
    thinkingLevelMap: {
      off: null,
      minimal: null,
      low: null,
      medium: null,
      high: "high",
      xhigh: null,
      max: "max",
    },
  },
  "minimax-m3": {
    contextWindow: 1000000,
    maxTokens: 131072,
    reasoning: true,
  },
  "kimi-k2.7-code": {
    contextWindow: 262144,
    maxTokens: 262144,
    reasoning: true,
  },
  "deepseek-v4-pro": {
    contextWindow: 1000000,
    maxTokens: 384000,
    reasoning: true,
    thinkingFormat: "deepseek",
    thinkingLevelMap: {
      minimal: null,
      low: null,
      medium: null,
      high: "high",
      max: "max",
    },
  },
  "deepseek-v4-flash": {
    contextWindow: 1000000,
    maxTokens: 384000,
    reasoning: true,
    thinkingFormat: "deepseek",
  },
  "Cosmos3-Super-Reasoner": {
    contextWindow: 128000,
    maxTokens: 16384,
    reasoning: true,
  },
};

const defaults: Overrides = {
  contextWindow: 128000,
  maxTokens: 16384,
};

export default async function (pi: ExtensionAPI) {
  const apiKey = await resolveApiKey();
  let models: KliaModel[] = [];

  if (apiKey) {
    const response = await fetch(`${baseUrl}/models`, {
      headers: { Authorization: `Bearer ${apiKey}` },
    });

    if (!response.ok) {
      throw new Error(`KLIA model discovery failed: ${response.status} ${response.statusText}`);
    }

    const payload = (await response.json()) as { data?: KliaModel[] };
    models = (payload.data ?? []).filter((m) => m.id in WHITELIST);
  }

  pi.registerProvider("klia", {
    name: "KLIA",
    baseUrl,
    apiKey: apiKey ?? "$KLIA_API_KEY",
    api: "openai-completions",
    models: models.map((model) => {
      const o = WHITELIST[model.id] ?? defaults;
      return {
        id: model.id,
        name: model.id,
        reasoning: o.reasoning ?? false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: o.contextWindow ?? 128000,
        maxTokens: o.maxTokens ?? 16384,
        ...(o.thinkingLevelMap ? { thinkingLevelMap: o.thinkingLevelMap } : {}),
        ...(o.thinkingFormat
          ? { compat: { thinkingFormat: o.thinkingFormat } }
          : {}),
      };
    }),
  });
}