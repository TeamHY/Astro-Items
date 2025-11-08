Astro.Enums = {}

Astro.GRID_SIZE = 40

Astro.MINUTE = 30 * 60

Astro.GOLDEN_TRINKET_OFFSET = 32768

Astro.MAX_ORIGINAL_COLLECTIBLE_ID = 732

Astro.SetsTagList = {
    ItemConfig.TAG_SYRINGE,
    ItemConfig.TAG_MOM,
    ItemConfig.TAG_GUPPY,
    ItemConfig.TAG_FLY,
    ItemConfig.TAG_BOB,
    ItemConfig.TAG_MUSHROOM,
    ItemConfig.TAG_BABY,
    ItemConfig.TAG_ANGEL,
    ItemConfig.TAG_DEVIL,
    ItemConfig.TAG_POOP,
    ItemConfig.TAG_BOOK,
    ItemConfig.TAG_SPIDER,
}

Astro.CallbackPriority = {
    MULTIPLY = CallbackPriority.LATE + 2000,
    ROCK_BOTTOM = CallbackPriority.LATE + 4000,
    POST_PENALTY = 999999999999
}

Astro.SoundEffect = {
    MAPLE = Isaac.GetSoundIdByName("Maple"),
    PISCES_EX = Isaac.GetSoundIdByName("PiscesEX"),
    STAFF_OF_AINZ_OOAL_GOWN = Isaac.GetSoundIdByName("StaffOfAinzOoalGown"),
    MAYUSHIIS_POCKET_WATCH_APPEAR = Isaac.GetSoundIdByName("MayushiisPocketWatchAppear"),
    SCALES_OF_OBEDIENCE_APPEAR = Isaac.GetSoundIdByName("ScalesOfObedienceAppear"),
    LEGACY_APPEAR = Isaac.GetSoundIdByName("LegacyAppear"),
    LEGACY_USE = Isaac.GetSoundIdByName("LegacyUse")
}
