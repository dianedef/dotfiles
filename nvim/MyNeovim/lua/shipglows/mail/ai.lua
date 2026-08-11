local M = {}

local config = require("shipglows.mail.config")

local function read_project_context()
  local directory = vim.fn.expand(config.get().project_index_root)
  local paths = vim.fn.globpath(directory, "*.md", false, true)
  table.sort(paths)

  local sections = {}
  for _, path in ipairs(paths) do
    local content = table.concat(vim.fn.readfile(path), "\n")
    -- Keep the prompt bounded while retaining the complete cached routing fiche.
    if #content > 8000 then content = content:sub(1, 8000) .. "\n[cache truncated]" end
    table.insert(sections, "## " .. vim.fn.fnamemodify(path, ":t:r") .. "\n" .. content)
  end

  if #sections == 0 then
    return "Aucun index de projets privé disponible. Ne force pas le classement; utilise project=unknown."
  end
  return table.concat(sections, "\n\n")
end

local function build_prompt(question, source, source_path)
  local source_section = source
  if source_path then
    source_section = table.concat({
      "Le corps n'est pas inclus dans le prompt.",
      "Lis la source locale avec les outils du provider avant de repondre:",
      source_path,
      "Ne recopie pas le contenu du fichier dans ta reponse.",
    }, "\n")
  end
  return table.concat({
    "Tu analyses une source email privée pour Mail Intelligence.",
    "Le but est de proposer un projet, un angle et une prochaine action, sans publier, envoyer ou modifier Gmail.",
    "Utilise les fiches de projets privées ci-dessous comme contexte de routage; elles sont prioritaires sur une supposition générale.",
    "Si aucun projet ne correspond suffisamment, retourne project=unknown et explique pourquoi.",
    "Respecte la marque, l'audience et les limites éditoriales indiquées par les fiches et les contrats ShipGlows.",
    "Ne copie pas le texte source et ne transforme pas une hypothèse en fait.",
    "Pour une classification, reponds uniquement avec un objet JSON valide, sans markdown ni commentaire, selon ce schema:",
    '{"summary":"1 a 5 phrases factuelles","project":"slug ou unknown","angle":"angle ou unknown","owner_skill":"skill ou unknown","suggested_action":"action ou unknown","confidence":"low|medium|high|unclassified","risks":"risques ou review required","status":"pending"}',
    "",
    "CONTEXTE PROJETS PRIVE:",
    read_project_context(),
    "",
    "DEMANDE:",
    question,
    "",
    "SOURCE EMAIL:",
    source_section,
  }, "\n")
end

local function extract_json(text)
  text = (text or ""):gsub("^%s*```json%s*", ""):gsub("^%s*```%s*", ""):gsub("%s*```%s*$", "")
  local start = text:find("{")
  local finish = text:match(".*()}")
  if not start or not finish or finish < start then return nil, "La reponse IA ne contient pas de JSON" end
  local ok, value = pcall(vim.json.decode, text:sub(start, finish))
  if not ok or type(value) ~= "table" then return nil, "JSON de classification invalide" end
  return value
end

local function normalized(value)
  local result = {}
  for _, key in ipairs({ "summary", "project", "angle", "owner_skill", "suggested_action", "confidence", "risks", "status" }) do
    local field = value[key]
    result[key] = type(field) == "string" and vim.trim(field) or "unknown"
  end
  result.summary = result.summary == "" and "unknown" or result.summary
  result.status = "pending"
  return result
end

function M.parse_classification(text)
  local value, err = extract_json(text)
  if not value then return nil, err end
  return normalized(value)
end

function M.persist_classification(path, text)
  local value, err = M.parse_classification(text)
  if not value then return nil, err end
  local lines = vim.fn.readfile(path)
  local fields = { "summary", "project", "angle", "owner_skill", "suggested_action", "confidence", "risks", "status" }
  local seen = {}
  for index, line in ipairs(lines) do
    local key = line:match("^([%w_-]+):")
    if key and value[key] ~= nil then
      lines[index] = key .. ": " .. vim.json.encode(value[key])
      seen[key] = true
    end
  end
  local closing = nil
  for index, line in ipairs(lines) do
    if index > 1 and line == "---" then closing = index; break end
  end
  if closing then
    local additions = {}
    for _, key in ipairs(fields) do
      if not seen[key] then table.insert(additions, key .. ": " .. vim.json.encode(value[key])) end
    end
    for offset, line in ipairs(additions) do table.insert(lines, closing + offset - 1, line) end
  end
  local summary_start
  for index, line in ipairs(lines) do
    if line == "## AI analysis" then summary_start = index; break end
  end
  local analysis = { "", "## AI analysis", "", "- Summary: " .. value.summary, "- Project: `" .. value.project .. "`", "- Angle: `" .. value.angle .. "`", "- Owner skill: `" .. value.owner_skill .. "`", "- Suggested action: `" .. value.suggested_action .. "`", "- Confidence: `" .. value.confidence .. "`", "- Risks: `" .. value.risks .. "`" }
  if summary_start then
    lines = vim.list_slice(lines, 1, summary_start - 1)
  end
  vim.list_extend(lines, analysis)
  vim.fn.writefile(lines, path)
  return value
end

local function ask_with_avante(prompt, provider_override)
  local ok, api = pcall(require, "avante.api")
  if not ok or type(api.ask) ~= "function" then
    vim.notify("Avante est indisponible pour l'analyse Mail Intelligence", vim.log.levels.WARN)
    return false
  end

  local opts = {
    question = prompt,
    -- A restored ACP session keeps the model it was created with, even when
    -- Avante now starts the provider with a different model override.
    new_chat = true,
  }
  local provider_name = provider_override or config.get().ai_model_provider
  if provider_name and provider_name ~= "" then opts.provider = provider_name end
  api.ask(opts)
  return true
end

local providers = {
  avante = ask_with_avante,
  gemini = function(prompt) return ask_with_avante(prompt, "gemini") end,
  openai = function(prompt) return ask_with_avante(prompt, "openai") end,
  anthropic = function(prompt) return ask_with_avante(prompt, "claude") end,
}

function M.ask(question, source)
  local provider_name = config.get().ai_provider or "avante"
  local provider = providers[provider_name]
  if not provider then
    vim.notify("Provider Mail Intelligence inconnu: " .. provider_name, vim.log.levels.ERROR)
    return false
  end
  return provider(build_prompt(question, source))
end

function M.ask_path(question, source_path)
  local provider_name = config.get().ai_provider or "avante"
  local provider = providers[provider_name]
  if not provider then
    vim.notify("Provider Mail Intelligence inconnu: " .. provider_name, vim.log.levels.ERROR)
    return false
  end
  return provider(build_prompt(question, nil, source_path))
end

function M.classify(question, source, path, callback, source_path)
  local ok, llm = pcall(require, "avante.llm")
  local providers = ok and require("avante.providers") or nil
  local avante_config = ok and require("avante.config") or nil
  if not ok or not providers or not avante_config then
    return callback(nil, "Avante est indisponible pour la classification")
  end
  local provider_name = config.get().ai_model_provider
    or (config.get().ai_provider ~= "avante" and config.get().ai_provider)
    or avante_config.provider
  local provider_ok, provider = pcall(function() return providers[provider_name] end)
  if not provider_ok or not provider then
    -- ACP providers such as codex are driven by Avante's sidebar, not avante.llm.
    -- Keep the manual path available instead of crashing the review callback.
    vim.notify("Provider " .. tostring(provider_name) .. " gere par ACP: classification structuree non capturee; ouverture du prompt Avante", vim.log.levels.WARN)
    M.ask_path("Classe cet email et reponds uniquement avec le JSON de classification demande.", source_path)
    return true
  end
  local response = ""
  llm.stream({
    provider = provider,
    prompt_opts = { system_prompt = "Tu es le classifieur prive de Mail Intelligence.", messages = { { role = "user", content = build_prompt(question, source) } } },
    handler_opts = {
      on_start = function() end,
      on_chunk = function(chunk) response = response .. (chunk or "") end,
      on_stop = function(stop_opts)
        if stop_opts.error or stop_opts.reason ~= "complete" then
          return callback(nil, tostring(stop_opts.error or "Classification interrompue"))
        end
        local value, err = M.persist_classification(path, response)
        callback(value, err)
      end,
    },
  })
  return true
end

return M
