# -*- coding: utf-8 -*-
"""Second wave of AEONFALL art: more of everything."""
from manifest import a, CHAR, CREATURE, PANEL, ICON, CARDART, PRO, DEV, FAST

EXTRA = []

# ------------------------------------------------------- more storyboard events
EVENTS2 = [
    ("ash_caravan", "a caravan of hooded pilgrims dragging sledges across an endless ash plain at twilight"),
    ("weeping_well", "a stone well in a dead courtyard, a face rising out of the black water inside"),
    ("bargain_shade", "a shadow detaching from a wall and offering a handshake to a startled traveller"),
    ("frozen_orchard", "an orchard of glass trees hung with frozen fruit, one fruit glowing warm"),
    ("bone_bridge", "a narrow bridge built from fused vertebrae spanning a bottomless fog-filled chasm"),
    ("clock_surgeon", "a surgeon of clockwork replacing a patient's beating heart with a ticking mechanism"),
    ("hall_of_masks", "a corridor lined with hundreds of hanging masks, one turning to follow the viewer"),
    ("last_letter", "a wax-sealed letter left on a battlefield of ash, still warm, hand reaching for it"),
    ("burning_library", "a vast library on fire, a lone figure choosing one book to save"),
    ("thief_of_faces", "a thin figure peeling a face off a sleeping victim like a mask"),
    ("iron_confessional", "a sealed iron confessional booth in a ruin, something scratching from inside"),
    ("stormsong", "a woman standing on a cliff singing into an oncoming storm, lightning answering"),
    ("sunken_crown", "a golden crown resting on the seabed under shafts of pale green light"),
    ("watcher_hill", "a hill crowded with silent watchers all facing the same distant black sun"),
    ("marrow_market", "a night market selling bones, teeth, and jars of memory under bone lanterns"),
    ("silver_hound", "a great silver hound blocking a mountain pass, eyes like moons, not hostile yet"),
    ("empty_armour", "a full suit of armour standing alone in a field, slowly turning its helm"),
    ("weight_of_names", "a figure carrying a sack overflowing with engraved nameplates up a slope"),
    ("mirror_duel", "two identical duellists facing off with a mirror standing between them"),
    ("candle_vigil", "a hundred candles arranged in a spiral in a dark hall, one being lit"),
    ("prisoner_ice", "a warrior sealed inside a pillar of clear ice, eyes open and aware"),
    ("gilded_cage", "an enormous golden birdcage in a ruin containing a seated human figure"),
    ("river_of_ink", "travellers crossing a slow black river of ink on a raft of manuscript pages"),
    ("child_of_ash", "a small child made of compacted ash offering a flower to the traveller"),
    ("throne_thorns", "an empty throne wrapped in living black thorns in a shattered hall"),
    ("second_moon", "a second moon rising, wrong colour, casting two shadows from one traveller"),
    ("collector_eyes", "a merchant whose coat is lined with hundreds of glass eyes, all blinking"),
    ("wound_in_world", "a jagged tear in reality hovering above a field, white light pouring out"),
    ("banquet_ghosts", "a table of translucent ghosts raising glasses in silent toast to the traveller"),
    ("nameless_grave", "a fresh grave with a blank headstone, a shovel still standing in the soil"),
    ("puppet_theatre", "a marionette theatre performing the traveller's own life to an empty audience"),
    ("furnace_heart", "a titanic furnace with a human silhouette suspended burning at its centre, unharmed"),
    ("owl_of_hours", "an enormous owl with clock faces for eyes perched on a ruined arch"),
    ("salt_pilgrims", "pilgrims crawling across a cracked salt flat toward a distant black spire"),
    ("blade_garden", "a garden where thousands of swords are planted like flowers, one still gleaming"),
    ("drowning_dream", "a figure sinking peacefully through deep dark water toward a distant light"),
    ("court_of_crows", "a ruined courtroom filled with crows sitting in the jury boxes"),
    ("last_sunrise", "two silhouettes watching a final sunrise from a broken rooftop, ash falling"),
    ("stitcher", "a hunched stitcher sewing a wounded shadow back onto its owner's heels"),
    ("echo_chamber", "a spherical chamber of polished bronze where a whisper becomes a roar of many voices"),
]
for k, d in EVENTS2:
    EXTRA.append(a(f"event/{k}", "event", d, "16:9", PRO, PANEL))

# ------------------------------------------------------------------- companions
COMPANIONS = [
    ("brann", "BRANN THE UNBURNT, a scarred veteran mercenary in mismatched plate, greying beard, warm eyes"),
    ("lira", "LIRA OF THE QUIET, a young scout in a grey hooded cloak with a bone-carved bow"),
    ("mordwen", "MORDWEN, an elderly ash-priest in charred vestments leaning on a censer staff"),
    ("vessa", "VESSA, a duellist noblewoman in a high-collared coat with a rapier and a cruel smile"),
    ("tock", "TOCK, a small clockwork automaton companion with a single glass eye and brass fingers"),
    ("silvane", "SILVANE, a blindfolded oracle in trailing white silks, hands wrapped in prayer cord"),
    ("harrow", "HARROW, a hulking silent executioner in a leather hood carrying an enormous cleaver"),
    ("nim", "NIM, a street thief child in oversized boots and a fox-fur scarf, quick grin"),
    ("calder", "CALDER, a storm-scarred sailor with a lightning-branded face and a harpoon"),
    ("orrin", "ORRIN, a disgraced scholar in cracked spectacles clutching an overstuffed satchel of notes"),
    ("thessa", "THESSA, a frost-witch with white braids and a mantle of hanging icicles"),
    ("the_stranger", "THE STRANGER, a featureless figure in a perfect black coat and wide hat, face in shadow"),
]
for k, d in COMPANIONS:
    EXTRA.append(a(f"comp/{k}", "vessel", d, "3:4", PRO, CHAR))

# ------------------------------------------------------------- chronicle plates
CHRONICLES = [
    ("ashen_crown", "a crown of blackened iron resting on a mound of ash, embers glowing beneath"),
    ("drowned_choir", "a submerged choir of statues singing, bubbles rising through green water"),
    ("hollow_saint", "a saint's reliquary opened to reveal it is empty inside, light spilling out"),
    ("clockwork_heresy", "a cathedral rebuilt from gears, priests replaced by automatons at prayer"),
    ("mirror_war", "two armies of identical mirrored soldiers charging at each other across glass"),
    ("stormbound", "a chained titan of thunder held down by a hundred lightning rods"),
    ("unwritten_name", "a page where a name has been violently scratched out, ink bleeding"),
    ("the_long_return", "a spiral of footprints in ash returning endlessly to the same doorway"),
    ("gilded_lie", "a beautiful golden mask cracking to show rot beneath"),
    ("last_cartographer", "a map of the world with the centre burned away, hands pinning it down"),
    ("chorus_of_falls", "countless falling figures rendered as descending storyboard panels"),
    ("author_unmade", "a quill snapping in half, ink exploding outward into a starfield"),
]
for k, d in CHRONICLES:
    EXTRA.append(a(f"chron/{k}", "event", d, "16:9", PRO, PANEL))

# --------------------------------------------------------------------- endings
ENDINGS = [
    ("end_ascend", "the hero crowned in light above a rebuilt world, panels reassembling into a whole sky"),
    ("end_burn", "the hero standing in the centre of a world entirely consumed by gold fire, arms open"),
    ("end_freeze", "everything held perfectly still in clear ice, the hero the only moving figure"),
    ("end_erase", "the hero calmly erasing themselves with an eraser, leaving a clean white page"),
    ("end_become", "the hero seated at the Author's desk, taking up the quill, face unreadable"),
    ("end_loop", "the hero walking back through the very first doorway, the story restarting"),
    ("end_free", "a door opening onto an ordinary sunlit field, the hero stepping out of the story"),
    ("end_sacrifice", "the hero dissolving into embers to hold a collapsing world together"),
    ("end_tyrant", "the hero enthroned atop a mountain of masks, ruling a silent kingdom"),
    ("end_companion", "two silhouettes walking away together down an ash road at dawn"),
    ("end_hollow", "an empty suit of the hero's armour standing in a blank white void"),
    ("end_true", "the black sun finally cracking open to reveal an ordinary blue sky behind it"),
]
for k, d in ENDINGS:
    EXTRA.append(a(f"ending/{k}", "event", d, "9:16", PRO, PANEL))

# ------------------------------------------------------------------ more biomes
BIOMES2 = [
    ("emberreach", "Emberreach: a canyon of glowing lava veins beneath basalt bridges, heat shimmer"),
    ("saltcourt", "the Salt Court: a cracked white salt flat with a ruined palace half-swallowed"),
    ("gloamwood", "the Gloamwood: a black forest lit only by floating pale lanterns and eyes"),
    ("brasslung", "the Brass Lung: an enormous mechanical lung chamber breathing steam, catwalks"),
    ("nullshore", "the Nullshore: a beach where the sea is made of static and blank paper foam"),
    ("crownfall", "Crownfall: a shattered capital city tilted at 40 degrees, towers hanging sideways"),
]
for k, d in BIOMES2:
    EXTRA.append(a(f"biome/{k}", "biome", d, "9:16", PRO, PANEL))

# ------------------------------------------------------------------ more foes
ENEMIES2 = [
    ("emberling", "a knee-high imp of living flame with coal eyes and a grin of fire"),
    ("slagbeast", "a lumbering quadruped of cooled lava and iron slag, cracks glowing"),
    ("pyre_acolyte", "a robed acolyte with a burning brazier for a head"),
    ("cinder_crow", "a large crow made of drifting ash and ember with a burning beak"),
    ("hoarfrost_stag", "a skeletal stag with antlers of clear ice and frost breath"),
    ("icebound_knight", "a knight fully encased in a shell of blue ice, sword frozen mid-swing"),
    ("frost_leech", "a translucent segmented leech of ice with a needle mouth"),
    ("winter_widow", "a pale spider-woman with a mantle of frozen web"),
    ("arc_hound", "a hound of pure electricity with an unstable flickering body"),
    ("tesla_effigy", "a scarecrow strung with copper coils crackling with charge"),
    ("thunder_moth", "a moth with wings of sheet lightning, thunder in its wingbeat"),
    ("conduit_thrall", "an enslaved humanoid with cables driven into its spine, sparking"),
    ("shade_stalker", "a long-limbed shadow predator that walks on walls"),
    ("grief_mask", "a floating porcelain mask trailing a body of black smoke"),
    ("nightbrood", "a nest-cluster of small chittering shadow-things with too many eyes"),
    ("silence_priest", "a priest with a stitched-shut mouth and hands raised to hush"),
    ("dawn_sentry", "a golden armoured sentry with a lantern for a head, blinding beam"),
    ("halo_wretch", "a broken angelic figure with a crooked halo and dragging wings"),
    ("gloryhound", "a lion of solid light with a mane of burning rays"),
    ("choir_seraph", "a wheel of eyes and wings rotating slowly, singing"),
    ("panel_wraith", "a wraith made of torn storyboard panels flapping in wind"),
    ("edit_scar", "a wound in the air with red correction marks bleeding out of it"),
    ("footnote", "a tiny scuttling creature made of dense annotated text and pins"),
    ("draft_titan", "a rough unfinished sketch of a giant, lines still moving and correcting"),
]
for k, d in ENEMIES2:
    EXTRA.append(a(f"enemy/{k}", "enemy", d, "1:1", DEV, CREATURE))

ELITES2 = [
    ("furnace_abbot", "an abbot fused to a walking furnace, chained censers swinging"),
    ("hoar_marshal", "a marshal in frost-fused plate riding a skeletal ice-stag"),
    ("arc_duelist", "a duellist with twin lightning sabres and a mirrored visor"),
    ("gloom_matron", "a towering matron of layered shadow-veils with a hundred hands"),
    ("dawn_executor", "an executioner of light in white ceremonial armour with a sun-axe"),
    ("redline_editor", "a critic in a red coat wielding an enormous red pen like a halberd"),
]
for k, d in ELITES2:
    EXTRA.append(a(f"elite/{k}", "elite", d, "1:1", PRO, CREATURE))

BOSS_PHASE2 = [
    ("vaskir2", "PYRE MARSHAL VASKIR UNBOUND: armour blown off, a screaming skeleton of white fire riding a molten bell"),
    ("drowned_bell2", "THE DROWNED BELL AWAKENED: the bronze split open, a drowned colossus climbing out of it"),
    ("ossuary_queen2", "OSSUARY QUEEN THAL REBORN: the bone throne merged into her, a cathedral of skeletons walking"),
    ("clocksmith_prime2", "THE CLOCKSMITH UNWOUND: gears flying apart in a sphere, a raw ticking singularity inside"),
    ("mirrorlord_ascendant2", "MIRRORLORD SHATTERED: a thousand shards each holding a different reflection, converging"),
    ("stormfather2", "STORMFATHER DESCENDED: the titan touching down, the whole sky funneling into it"),
    ("the_author2", "THE AUTHOR REVEALED: the coat empty, the quill writing by itself, an eye where the desk was"),
    ("first_vessel2", "THE FIRST VESSEL UNMASKED: the mask falls away to show the player's own blank face"),
    ("aeonfall2", "AEONFALL TRUE FORM: an infinite spiral of collapsing storyboard panels forming an eye, cosmic"),
]
for k, d in BOSS_PHASE2:
    EXTRA.append(a(f"boss/{k}", "boss", d, "1:1", PRO, CREATURE))

VESSEL_AWAKE = [
    ("ashcaller", "wreathed in a corona of white fire, mask fully shattered, eyes pouring flame"),
    ("saintcoralis", "risen in a cathedral of ice, wings of frozen glass, halo complete"),
    ("voltborn", "body dissolving into a standing bolt of lightning, coat torn away"),
    ("umbralnyx", "eight shadow-arms fully unfurled, the doll-mask cracked showing void"),
    ("lumenherald", "blindfold burned away, eyes of pure dawn, wings of stained glass fully spread"),
    ("paradox", "fully redrawn in gold ink, every version of themselves overlapping at once"),
]
for k, d in VESSEL_AWAKE:
    EXTRA.append(a(f"awake/{k}", "vessel", f"an awakened ascended hero: {d}", "3:4", PRO, CHAR))

# ---------------------------------------------------------------- node icons
NODES = [
    ("battle", "two crossed notched swords"),
    ("elite", "a horned skull over crossed swords"),
    ("boss", "a cracked crown above a black sun"),
    ("event", "an open book with a question mark of smoke rising"),
    ("shop", "a merchant's hanging scale with a coin"),
    ("rest", "a small campfire in a stone ring"),
    ("treasure", "an ornate locked chest with light at the seams"),
    ("mystery", "a spiral eye inside a diamond"),
]
for k, d in NODES:
    EXTRA.append(a(f"node/{k}", "relic", f"{d}, engraved gold on obsidian, bold clear silhouette", "1:1", FAST, ICON))

SITES = [
    ("shopkeep", "a hooded merchant behind a stall of glowing wares in a ruin, welcoming gesture"),
    ("restsite", "a small campfire between two broken statues at night, bedroll laid out"),
    ("treasure_room", "a vault chamber with a single ornate chest lit by a shaft of gold light"),
    ("forge_site", "an ancient forge with a glowing anvil and floating hammer"),
    ("shrine_site", "a small shrine of stacked stones with offerings and a burning taper"),
    ("gate_site", "an enormous sealed gate covered in shifting runes at the end of a hall"),
]
for k, d in SITES:
    EXTRA.append(a(f"site/{k}", "event", d, "16:9", PRO, PANEL))

# ------------------------------------------------------------- more card art
CARDS2 = [
    ("ember_scorch", "a wide cone of roaring flame"), ("ember_flarepike", "a spear of white fire thrust forward"),
    ("ember_ashcloak", "a cloak of swirling hot ash forming a shield"),
    ("ember_detonate", "a delayed charge exploding in a ring of fire"),
    ("ember_kindle", "cupped hands sheltering a growing flame"),
    ("ember_wildfire", "a wall of fire racing across dry ground"),
    ("ember_slagfist", "a fist coated in molten metal mid-punch"),
    ("ember_lastspark", "a single dying ember flaring back to life"),
    ("ember_bellows", "great bellows blasting a firestorm forward"),
    ("ember_soottrail", "a streaking comet of soot and flame"),
    ("frost_needle", "a hail of thin ice needles in flight"),
    ("frost_mirrorice", "a polished ice mirror reflecting an attack back"),
    ("frost_hibernate", "a figure curled inside a protective cocoon of frost"),
    ("frost_avalanche", "a mountainside of snow collapsing forward"),
    ("frost_permafrost", "ground turning to blue permafrost in a spreading ring"),
    ("frost_icebrand", "a sword sheathed in a jagged blade of ice"),
    ("frost_snowveil", "a curtain of falling snow obscuring a silhouette"),
    ("frost_coldsnap", "a violent instant flash-freeze, droplets caught in air"),
    ("frost_glacierheart", "a heart of blue glacial ice pulsing"),
    ("frost_frostbite", "blackened frostbitten claw marks on pale skin"),
    ("volt_sparkstep", "a dashing figure leaving a trail of sparks"),
    ("volt_capacitor", "a glowing capacitor charging to bursting"),
    ("volt_ionlance", "a thin ionised lance of blue-white energy"),
    ("volt_shockwave", "a circular electric shockwave rolling outward"),
    ("volt_grounding", "a lightning rod driving current into the earth"),
    ("volt_relay", "energy leaping between three floating relay nodes"),
    ("volt_stormheart", "a heart of crackling storm energy"),
    ("volt_blitz", "a blur of afterimages in a rapid multi-strike"),
    ("volt_static_field", "a dome of humming static electricity"),
    ("volt_thunderclap", "two palms clapping together with a sonic burst"),
    ("umbra_shroud", "a figure wrapped in coiling black smoke, features gone"),
    ("umbra_nightmare", "a sleeping figure with a black shape crouched on its chest"),
    ("umbra_leech", "black tendrils drinking glowing light from a body"),
    ("umbra_severance", "a shadow being cut away from its owner with a knife"),
    ("umbra_hollow", "a hollowed-out silhouette with stars inside it"),
    ("umbra_mirrorstep", "a figure stepping into its own shadow and vanishing"),
    ("umbra_gravebind", "chains of shadow pinning a figure to the ground"),
    ("umbra_lastrites", "a shrouded body surrounded by black candles"),
    ("umbra_whisper", "a mouth of shadow whispering into an ear"),
    ("umbra_devour", "a black maw opening in the floor beneath a figure"),
    ("lumen_benediction", "a hand of light resting on a bowed head"),
    ("lumen_pillar", "a vertical pillar of golden light striking down"),
    ("lumen_reflect", "a shield of light bending an incoming beam back"),
    ("lumen_ascension", "a figure lifted into the air on beams of dawn"),
    ("lumen_purify", "black smoke burning away from a body in golden motes"),
    ("lumen_martyr", "a figure taking a blow meant for another, glowing"),
    ("lumen_daybreak", "the first line of sunrise cracking a black horizon"),
    ("lumen_gospel", "an open book of light with pages turning by themselves"),
    ("lumen_crown", "a halo crown settling onto a head"),
    ("lumen_lastlight", "a single candle flame refusing to go out in a gale"),
    ("neutral_stancecut", "a clean single sword cut through smoke"),
    ("neutral_riposte", "a parry sparking into an instant counterthrust"),
    ("neutral_scrapshield", "a shield hastily assembled from battlefield scrap"),
    ("neutral_secondwind", "a kneeling fighter rising, breath steaming"),
    ("neutral_marked", "a red target sigil burning onto an enemy's chest"),
    ("neutral_plunder", "a hand snatching a glowing coin mid-air"),
    ("neutral_recall", "a discarded card flying back into a hand"),
    ("neutral_overdraw", "five cards fanning out in a rush of light"),
    ("neutral_sacrifice", "a hand pressing a blade into its own palm"),
    ("neutral_reversal", "an hourglass flipping violently"),
    ("neutral_stalemate", "two blades locked hilt to hilt, immovable"),
    ("neutral_encore", "a spotlight hitting an empty stage, a bow being taken"),
    ("neutral_montage", "four small action panels arranged in a rushing sequence"),
    ("neutral_cliffhanger", "a hand gripping the edge of a crumbling cliff"),
    ("neutral_flashback", "a bleached memory image bleeding into the present"),
    ("neutral_deusex", "a hand descending from a tear in the sky"),
    ("curse_regret", "a heavy black chain wrapped around a wrist"),
    ("curse_doubt", "a fogged mirror with a question scratched into it"),
    ("curse_wound", "a bandaged wound seeping dark light"),
    ("curse_burden", "a figure bent double under an enormous formless weight"),
    ("curse_silence", "a mouth sewn shut with gold thread"),
    ("curse_blank", "a completely blank white card with a hole burnt in it"),
    ("status_ash", "a drifting clump of grey ash"),
    ("status_slag", "a lump of cooling slag metal"),
    ("status_static", "a burst of visual static"),
    ("status_void", "a small perfectly black sphere"),
    ("status_glare", "an overexposed white flare"),
    ("status_ink", "a spreading blot of black ink"),
]
for k, d in CARDS2:
    EXTRA.append(a(f"card/{k}", "card", d, "1:1", DEV, CARDART))

# ------------------------------------------------------------- more relics
RELICS2 = [
    ("ember_shackle", "a shackle glowing red hot"), ("frost_bell", "a small bell coated in frost"),
    ("volt_fang", "a tooth wrapped in sparking wire"), ("umbra_veilpin", "a black lace pin"),
    ("lumen_censer", "a golden censer trailing bright smoke"),
    ("cracked_lens", "a monocle with a crack across it"),
    ("iron_tooth", "a single iron tooth on a cord"),
    ("wax_seal", "a red wax seal stamped with an eye"),
    ("salt_pouch", "a small leather pouch spilling white salt"),
    ("black_feather", "a single glossy black feather"),
    ("clock_hand", "a bent brass clock hand"),
    ("glass_eye", "a glass eye with a gold iris"),
    ("bone_flute", "a small flute carved from a finger bone"),
    ("rusted_ring", "a heavy rusted iron ring"),
    ("silver_thread", "a spool of gleaming silver thread"),
    ("cracked_hourglass", "a tiny hourglass with a hairline crack"),
    ("ember_coin", "a coin that glows like a coal"),
    ("frozen_rose", "a rose flash-frozen in clear ice"),
    ("storm_shard", "a shard of glass fused by lightning"),
    ("shadow_dice", "dice carved from obsidian"),
    ("dawn_bell", "a tiny bell of polished gold"),
    ("nail_of_ending", "a long black iron nail"),
    ("map_fragment", "a torn corner of an old map"),
    ("wolf_sigil", "a wolf head sigil in tarnished silver"),
    ("chalk_stub", "a worn stub of white chalk"),
    ("blood_vial", "a small vial of dark blood"),
    ("moth_lantern", "a lantern with a moth trapped inside"),
    ("keystone", "a small carved keystone block"),
    ("bell_clapper", "a heavy bronze bell clapper"),
    ("spine_charm", "a charm strung with small vertebrae"),
    ("gilded_finger", "a golden mechanical finger"),
    ("null_marble", "a marble of perfect nothing"),
    ("scribes_thumb", "a preserved thumb stained with ink"),
    ("crown_shard", "a broken shard of a golden crown"),
    ("phoenix_ash", "a pinch of ash that glows faintly"),
    ("ouroboros_band", "a ring shaped as a serpent eating its tail"),
    ("witness_stone", "a smooth stone with a painted eye"),
    ("mercy_blade", "a tiny ceremonial dagger with a dull edge"),
    ("hollow_crown", "an open circlet with nothing inside"),
    ("final_page", "a single page marked THE END, burnt at one corner"),
]
for k, d in RELICS2:
    EXTRA.append(a(f"relic/{k}", "relic", d, "1:1", FAST, ICON))

if __name__ == "__main__":
    from collections import Counter
    print(len(EXTRA), "extra assets", Counter(x["group"] for x in EXTRA))
