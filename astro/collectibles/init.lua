local isc = require("astro.lib.isaacscript-common")

Astro.Collectible = {}

---@type {Init: fun()}[]
local items = {}

table.insert(items, require "astro.collectibles.customs.abortion")
require "astro.collectibles.customs.absolut-conjoined"
require "astro.collectibles.customs.acute-sinusitis"
require "astro.collectibles.customs.akashic-records"
table.insert(items, require "astro.collectibles.customs.albireo")
require "astro.collectibles.customs.altair"
require "astro.collectibles.customs.amazing-chaos-scroll"
require "astro.collectibles.customs.amazing-chaos-scroll-of-goodness"
require "astro.collectibles.customs.angry-onion"
require "astro.collectibles.customs.aquarius-ex"
require "astro.collectibles.customs.aries-ex"
require "astro.collectibles.customs.artifact-sanctum"
require "astro.collectibles.customs.bachelors-degree"
require "astro.collectibles.customs.birthright-eden"
require "astro.collectibles.customs.birthright-isaac"
require "astro.collectibles.customs.birthright-judas"
require "astro.collectibles.customs.birthright-the-lost"
require "astro.collectibles.customs.blood-of-hatred"
require "astro.collectibles.customs.blood-trail"
require "astro.collectibles.customs.bomb-is-power"
require "astro.collectibles.customs.bonfire"
require "astro.collectibles.customs.bunny-hop"
require "astro.collectibles.customs.cains-secret-bag"
require "astro.collectibles.customs.cancer-ex"
require "astro.collectibles.customs.capricorn-ex"
require "astro.collectibles.customs.casiopea"
require "astro.collectibles.customs.chaos-dice"
require "astro.collectibles.customs.chubby-sets"
require "astro.collectibles.customs.cleaner"
require "astro.collectibles.customs.clover"
require "astro.collectibles.customs.comet"
table.insert(items, require "astro.collectibles.customs.copernicus")
require "astro.collectibles.customs.corvus"
require "astro.collectibles.customs.curse-of-aramatir"
require "astro.collectibles.customs.cursed-heart"
require "astro.collectibles.customs.cygnus"
require "astro.collectibles.customs.dads-box"
require "astro.collectibles.customs.deaths-eyes"
require "astro.collectibles.customs.deneb"
require "astro.collectibles.customs.divine-light"
require "astro.collectibles.customs.dracoback"
require "astro.collectibles.customs.dunnell-the-noble-arms-of-light"
require "astro.collectibles.customs.extra-guppy-sets"
require "astro.collectibles.customs.ez-mode"
require "astro.collectibles.customs.fallen-orb"
require "astro.collectibles.customs.duality-light-and-darkness" -- fallen orb보다 아래 있어야 함
require "astro.collectibles.customs.forbidden-dice"
require "astro.collectibles.customs.fortune-coin"
require "astro.collectibles.customs.galactic-medal-of-valor"
require "astro.collectibles.customs.gemini-ex"
require "astro.collectibles.customs.go-home"
require "astro.collectibles.customs.greed"
require "astro.collectibles.customs.happy-onion"
require "astro.collectibles.customs.heart-bloom"
require "astro.collectibles.customs.key-is-power"
require "astro.collectibles.customs.laniakea-supercluster"
require "astro.collectibles.customs.leo-ex"
require "astro.collectibles.customs.libra-ex"
require "astro.collectibles.customs.lucky-rock-bottom"
require "astro.collectibles.customs.maple-cube"
require "astro.collectibles.customs.masters-degree"
require "astro.collectibles.customs.mind-series"
require "astro.collectibles.customs.mirror-dice"
require "astro.collectibles.customs.morphine"
require "astro.collectibles.customs.my-moon-my-man"
require "astro.collectibles.customs.oblivion"
require "astro.collectibles.customs.omega-321"
require "astro.collectibles.customs.original-sinful-spoils-snake-eye"
require "astro.collectibles.customs.overwhelming-sinful-spoils"
require "astro.collectibles.customs.pavo"
require "astro.collectibles.customs.pirate-map"
require "astro.collectibles.customs.pisces-ex"
require "astro.collectibles.customs.platinum-bullet"
require "astro.collectibles.customs.power-rock-bottom"
require "astro.collectibles.customs.prometheus"
require "astro.collectibles.customs.ptolemaeus"
require "astro.collectibles.customs.pure-love"
require "astro.collectibles.customs.pure-white-heart"
require "astro.collectibles.customs.quasar"
require "astro.collectibles.customs.rapid-rock-bottom"
require "astro.collectibles.customs.restock-dice"
table.insert(items, require "astro.collectibles.customs.rgb")
require "astro.collectibles.customs.rhongomyniad"
require "astro.collectibles.customs.rite-of-aramesir"
require "astro.collectibles.customs.sacred-dice"
require "astro.collectibles.customs.sagittarius-ex"
require "astro.collectibles.customs.sandevistan"
require "astro.collectibles.customs.scorpio-ex"
require "astro.collectibles.customs.sinful-spoils-of-subversion-snake-eye"
require "astro.collectibles.customs.sinful-spoils-struggle"
require "astro.collectibles.customs.solar-system"
require "astro.collectibles.customs.spinup-dice"
require "astro.collectibles.customs.starlit-papillon"
require "astro.collectibles.customs.stew-series"
require "astro.collectibles.customs.super-magneto"
require "astro.collectibles.customs.super-nova"
require "astro.collectibles.customs.taurus-ex"
require "astro.collectibles.customs.technology-omicron-ex"
require "astro.collectibles.customs.terraspark-boots"
require "astro.collectibles.customs.the-holy-blood-and-the-holy-grail"
require "astro.collectibles.customs.three-body-problem"
require "astro.collectibles.customs.trinity"
require "astro.collectibles.customs.vega"
require "astro.collectibles.customs.very-ez-mode"
require "astro.collectibles.customs.virgo-ex"
require "astro.collectibles.customs.wanted-seeker-of-sinful-spoil"
require "astro.collectibles.customs.ward"
require "astro.collectibles.customs.rebirth-sets"

require "astro.collectibles.customs.sol-ex"
require "astro.collectibles.customs.luna-ex"
require "astro.collectibles.customs.mercurius-ex"
require "astro.collectibles.customs.venus-ex"
require "astro.collectibles.customs.terra-ex"
require "astro.collectibles.customs.mars-ex"
require "astro.collectibles.customs.jupiter-ex"
require "astro.collectibles.customs.saturnus-ex"
require "astro.collectibles.customs.uranus-ex"
require "astro.collectibles.customs.neptunus-ex"
require "astro.collectibles.customs.pluto-ex"

require "astro.collectibles.ex-upgrade"

---@type ItemConfigItem[]
Astro.CollectableConfigs = {}

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        local itemConfig = Isaac.GetItemConfig()

        local id = 1

        while true do
            local itemConfigItem = itemConfig:GetCollectible(id)

            if id > 732 and itemConfigItem == nil then
                break
            end

            if itemConfigItem ~= nil then
                table.insert(Astro.CollectableConfigs, itemConfigItem)
            end

            id = id + 1
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        for _, item in ipairs(items) do
            item.Init()
        end
    end
)
