local HANGUL_START = 0xAC00
local HANGUL_END = 0xD7A3
local NUMBER_OF_JONGSEONG = 28
local JONGSEONG_RIEUL = 8

local RO_JOSA = {
    ["으로/로"] = true,
    ["으로서/로서"] = true,
    ["으로써/로써"] = true,
    ["으로부터/로부터"] = true,
}

---@param word string
---@return integer?
local function GetJongseong(word)
    local lastCode

    for _, code in utf8.codes(word) do
        lastCode = code
    end

    if not lastCode or lastCode < HANGUL_START or lastCode > HANGUL_END then
        return nil
    end

    return (lastCode - HANGUL_START) % NUMBER_OF_JONGSEONG
end

---@param word string
---@param josa string
---@return string
function Astro:PickJosa(word, josa)
    local withBatchim, withoutBatchim = josa:match("^(.-)/(.+)$")
    local jongseong = GetJongseong(word)

    if word == "" then
        return withBatchim
    end

    local hasBatchim = jongseong ~= nil and jongseong > 0
    local useFirst = hasBatchim

    if josa == "와/과" or (hasBatchim and jongseong == JONGSEONG_RIEUL and RO_JOSA[josa]) then
        useFirst = not useFirst
    end

    return useFirst and withBatchim or withoutBatchim
end

---@param word string
---@param josa string
---@return string
function Astro:Josa(word, josa)
    if word == "" then
        return word
    end

    return word .. Astro:PickJosa(word, josa)
end
