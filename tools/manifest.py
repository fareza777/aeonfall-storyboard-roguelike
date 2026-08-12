# -*- coding: utf-8 -*-
"""AEONFALL art manifest. Every asset the game ships with, as a prompt."""

# ---------------------------------------------------------------- style bible
STYLE = (
    "dark fantasy storyboard illustration, painterly gouache and ink wash, "
    "dramatic chiaroscuro lighting, volumetric haze, cinematic film-still framing, "
    "deep indigo and ember-gold and bone-white palette, ornate arcane detail, "
    "AAA game concept art, highly detailed, masterpiece"
)
NEG = "text, letters, words, watermark, signature, logo, ui, frame border, blurry, low quality"

CHAR = "full body character concept sheet, centered, heroic silhouette, dramatic rim light, plain dark vignette background"
CREATURE = "creature concept art, single subject, centered, isolated on flat near-black void background, strong rim light, menacing silhouette"
PANEL = "wide cinematic storyboard panel, strong staging, atmospheric depth, moody"
ICON = "ornate arcane relic icon, single centered object, symmetrical, glowing runic accents, flat near-black background, crisp game inventory icon"
CARDART = "arcane ability illustration, dynamic energy motion, centered focal burst, painterly"

PRO = "flux-1.1-pro"      # hero art
DEV = "flux-dev"          # bulk quality
FAST = "flux-schnell"     # icons


def a(key, group, prompt, ar="1:1", model=DEV, extra=""):
    return {
        "key": key, "group": group, "ar": ar, "model": model,
        "prompt": f"{prompt}, {extra + ', ' if extra else ''}{STYLE}",
    }


ASSETS = []

# ------------------------------------------------------------------ branding
ASSETS += [
    a("brand/splash", "brand",
      "AEONFALL key art: a masked wanderer in a tattered ember-lit cloak stands on a cliff of broken storyboard "
      "panels that float and shatter into gold embers, an enormous ruined cathedral of clockwork falling upward "
      "into a black sun above, endless spiral staircase of light",
      "9:16", PRO),
    a("brand/title_bg", "brand",
      "vast obsidian amphitheatre of floating illustrated panels drifting in a starless void, gold embers rising, "
      "a single throne of fused quills and swords at the centre, epic scale",
      "9:16", PRO),
    a("brand/hub_bg", "brand",
      "the Sanctum Between Falls: a quiet vaulted observatory carved from bone-white stone, a great orrery of "
      "burning glass rings turning slowly, six empty pedestals waiting, warm ember hearth light, motes of dust",
      "9:16", PRO),
    a("brand/icon", "brand",
      "a single heraldic emblem: an hourglass whose falling sand becomes a cascade of tiny illustrated panels, "
      "wrapped in a broken ouroboros of gold, on deep indigo, bold readable silhouette, app icon crest",
      "1:1", PRO),
    a("brand/onboard_1", "brand",
      "a storyteller's hand laying down a burning storyboard panel onto a dark table, other panels around it "
      "showing battles and betrayals, ember sparks drifting upward",
      "9:16", PRO),
    a("brand/onboard_2", "brand",
      "a duel frozen mid-frame: two elemental sigils colliding, frost shattering against fire in a bloom of steam, "
      "cards of light suspended in the air around the fighters",
      "9:16", PRO),
    a("brand/onboard_3", "brand",
      "a hooded figure discovers a mirror showing itself as the villain, the reflection reaching out, "
      "the room behind dissolving into blank unwritten paper",
      "9:16", PRO),
    a("brand/defeat", "brand",
      "a shattered mask lying on black water, gold embers dying out, reflections of a whole life story rippling away",
      "9:16", PRO),
    a("brand/victory", "brand",
      "dawn breaking over an infinite library of floating panels, a lone silhouette walking into white light, "
      "the black sun finally setting",
      "9:16", PRO),
]

# ------------------------------------------------------------------- vessels
VESSELS = [
    ("ashcaller", "The Ashcaller, a barefoot pyromancer wrapped in scorched funeral silks, cracked porcelain mask "
                  "leaking firelight, forearms wound with molten chain, carrying a censer of living cinders"),
    ("saintcoralis", "The Glacier Saint, a tall armoured cleric in frost-rimed white plate and a torn choir mantle, "
                     "halo of suspended ice shards, carries a frozen reliquary shield"),
    ("voltborn", "The Voltborn, a lean storm duelist in a conductive coat of copper thread and stitched leather, "
                 "one arm replaced by a crackling arc-blade, hair lifted by static"),
    ("umbralnyx", "The Umbral Weaver, a marionette-witch in layered black lace and silver thread, four shadow-arms "
                  "unfolding behind her, faceless doll-mask, strings of darkness in her fingers"),
    ("lumenherald", "The Lumen Herald, a radiant paladin in bone-white ceremonial armour with stained-glass wings of "
                    "light, blindfolded, carrying a spear of solid dawn"),
    ("paradox", "The Paradox Scribe, a scholar half-erased from reality, robes made of drifting manuscript pages, "
                "one half of the body rendered as unfinished ink sketch, quill dripping liquid time"),
]
for k, d in VESSELS:
    ASSETS.append(a(f"vessel/{k}", "vessel", d, "3:4", PRO, CHAR))
    ASSETS.append(a(f"crest/{k}", "crest", f"heraldic crest emblem representing {d.split(',')[0]}", "1:1", FAST, ICON))

# ------------------------------------------------------------------- biomes
BIOMES = [
    ("ashfall", "the Ashfall Wastes: a grey desert of drifted ash under a bruised sky, half-buried bronze bells, "
                "columns of slow-falling embers"),
    ("drowned", "the Drowned Cathedral: a flooded gothic nave, black water to the waist, drowned choir statues, "
                "shafts of green light through broken rose windows"),
    ("ossuary", "the Verdant Ossuary: a forest grown entirely from bone, luminous moss and pale flowers blooming "
                "from ribcages, fog between femur trees"),
    ("clockwork", "the Clockwork Abyss: an infinite descending shaft of turning brass gears and hanging chains, "
                  "sparks raining, catwalks over darkness"),
    ("bazaar", "the Mirror Bazaar: a night market of hanging mirrors and silk canopies, every reflection showing a "
               "different version of the scene, lantern glow"),
    ("stormspire", "the Stormspire: a lightning-lashed black tower above the clouds, rings of floating stone, "
                   "arcs of violet electricity"),
    ("unwritten", "the Unwritten: a landscape that fades into blank white paper at the edges, half-drawn mountains, "
                  "ink bleeding upward into the sky"),
    ("vault", "the Aeon Vault: a colossal circular archive of golden hourglasses stacked to infinity, "
              "a beam of light down the centre"),
    ("thefall", "the Fall: a collapsing world of shattering panels tumbling into a black sun, gravity broken, "
                "debris of entire cities suspended mid-shatter"),
]
for k, d in BIOMES:
    ASSETS.append(a(f"biome/{k}", "biome", d, "9:16", PRO, PANEL))

# ------------------------------------------------------------------ enemies
ENEMIES = [
    ("cinder_wretch", "a stooped humanoid husk of packed ash, fire glowing through the cracks of its body"),
    ("ash_hound", "a lean skinless hound made of smouldering charcoal, embers trailing from its ribs"),
    ("drowned_choirboy", "a bloated choirboy in soaked robes, mouth impossibly wide, singing black water"),
    ("bell_wraith", "a spirit shaped like a cracked bronze bell with hanging chain arms and a hollow ringing face"),
    ("bone_florist", "a hunched figure wearing a mask of flowers grown through a skull, carrying a bouquet of ribs"),
    ("marrow_sprout", "a small hopping creature of bone and pale fungus with a single glowing eye socket"),
    ("soot_moth", "an enormous moth of grey ash with burning eye-patterns on its wings"),
    ("kiln_golem", "a squat furnace golem of fired clay with an open roaring firebox in its chest"),
    ("tidecaller_husk", "a drowned priest silhouette overgrown with barnacles, arms raised, water pouring upward"),
    ("gravebloom", "a carnivorous flower the size of a man, petals of pale skin, teeth in the centre"),
    ("gear_parasite", "a many-legged brass insect that burrows into machinery, spinning saw mandibles"),
    ("mainspring_knight", "an armoured knight whose torso is an exposed wound clockwork mainspring, greatsword"),
    ("mirror_twin", "a perfect silver reflection of a hooded adventurer, seams of glass across its skin"),
    ("glass_merchant", "a tall thin merchant in a coat of hanging mirror shards, no face, only reflections"),
    ("static_djinn", "a torso of violet lightning rising from a shattered lamp, arms of arcing electricity"),
    ("storm_vane", "an animated weather vane colossus of black iron, spinning blades, storm clouds at its feet"),
    ("cog_swarm", "a swirling swarm of tiny brass cogs forming a rough humanoid shape"),
    ("reflection_eater", "an eyeless predator with a mirror embedded in its open chest, licking a long silver tongue"),
    ("voltaic_monk", "a meditating monk levitating in a cage of orbiting lightning rods"),
    ("chrome_serpent", "a segmented chrome serpent of interlocking plates with a lens for an eye"),
    ("blank_effigy", "a featureless white paper mannequin, half sketched, ink running down its blank face"),
    ("ink_devourer", "a low quadruped made of pouring black ink with a mouth full of nib-teeth"),
    ("unwritten_chorus", "three faceless robed figures fused at the shoulder, mouths sewn with gold thread"),
    ("aeon_sentinel", "a towering guardian of golden hourglass armour, sand pouring from its joints"),
    ("vault_custodian", "a hunched archivist with a lantern head and too many arms holding keys"),
    ("paradox_echo", "a flickering duplicate of a warrior, rendered as three overlapping time-offset afterimages"),
    ("the_erased", "a humanoid shape cut out of reality, only a white silhouette hole with stars inside"),
    ("null_seraph", "a six-winged seraph whose wings are blank paper and whose face is a burning void"),
    ("timeworn_colossus", "a mountain-sized ruined statue reanimating, hourglass sand bleeding from its cracks"),
    ("endling", "a small pitiful creature holding the last ember of a dead world, huge sad eyes"),
]
for k, d in ENEMIES:
    ASSETS.append(a(f"enemy/{k}", "enemy", d, "1:1", DEV, CREATURE))

ELITES = [
    ("ashen_inquisitor", "an inquisitor in a burning iron mask and brand-scarred vestments wielding twin hooked censers"),
    ("cathedral_leviathan", "an immense pale eel-leviathan coiled through a flooded cathedral, stained glass in its hide"),
    ("ossuary_matron", "a towering matron of fused skeletons in a bridal veil of moss, cradling a bone infant"),
    ("the_clocksmith", "a gaunt artisan with jeweller's lenses for eyes and six mechanical arms holding tools"),
    ("mirrorlord_vane", "a duellist lord in a mirrored porcelain mask and a coat that reflects the viewer"),
    ("stormspire_warden", "a colossal warden of black iron and captive lightning chained inside its chest cavity"),
    ("editor_of_names", "a scribe in judge's robes holding a red quill that erases people, pages orbiting"),
    ("warden_of_the_fall", "a knight of shattered panels held together by gold repair seams, kintsugi armour"),
]
for k, d in ELITES:
    ASSETS.append(a(f"elite/{k}", "elite", d, "1:1", PRO, CREATURE))

BOSSES = [
    ("vaskir", "PYRE MARSHAL VASKIR: a giant general in molten plate armour astride a burning bell, "
               "his cape a curtain of fire, commanding an army of ash"),
    ("drowned_bell", "THE DROWNED BELL: a cathedral bell the size of a house, risen from black water on tendrils, "
                     "a drowned face pressing outward from inside the bronze"),
    ("ossuary_queen", "OSSUARY QUEEN THAL: a monarch grown from a thousand skeletons and pale blossoms, "
                      "throne of ribs, crown of vertebrae, terrible beauty"),
    ("clocksmith_prime", "THE CLOCKSMITH PRIME: a cathedral-sized clockwork body suspended in chains, "
                         "its face a clock with living hands, gears grinding open"),
    ("mirrorlord_ascendant", "MIRRORLORD VANE ASCENDANT: a duellist multiplied into seven mirrored copies "
                             "converging, shards of a broken hall of mirrors swirling"),
    ("stormfather", "STORMFATHER ZELL: a titan of living thunderhead and iron ribs, lightning pouring from "
                    "the hollow where a heart should be, standing above the clouds"),
    ("the_author", "THE AUTHOR: a faceless figure in an ink-black coat holding a quill like a blade, "
                   "seated at a desk floating in a void, drawing the player into being"),
    ("first_vessel", "THE FIRST VESSEL: the player's own silhouette rendered in gold kintsugi cracks and "
                     "black ink, mirrored, wielding every weapon at once"),
    ("aeonfall", "AEONFALL: the apocalypse itself given form, a collapsing black sun with a cathedral inside it, "
                 "endless panels of every story ever told tearing into its gravity, cosmic horror finale"),
]
for k, d in BOSSES:
    ASSETS.append(a(f"boss/{k}", "boss", d, "1:1", PRO, CREATURE))

# ----------------------------------------------------------- event panels
EVENTS = [
    ("merchant_hours", "a hooded merchant whose cart is filled with ticking clocks and jars of stolen hours, "
                       "meeting a traveller on an ash road at dusk"),
    ("two_doors", "two identical doors standing free in a fog-filled void, one bleeding light, one bleeding ink, "
                  "a figure hesitating between them"),
    ("bleeding_statue", "a marble saint statue weeping dark blood in an abandoned shrine, offerings piled at its feet"),
    ("child_remembers", "a small child in a ruined street calmly holding up a drawing of the hero's own death"),
    ("auction_names", "a candlelit auction house where masked bidders raise numbered paddles to buy people's names"),
    ("campfire", "three travellers around a small fire under a vast starless sky, one of them looking away, hiding "
                 "something behind their back"),
    ("aging_mirror", "a tall cracked mirror in a dusty room reflecting the viewer decades older and afraid"),
    ("debt_collector", "a towering collector of ash in a tax-official's coat, ledger chained to his wrist, "
                       "standing in a doorway"),
    ("loom_fates", "an enormous loom weaving threads of light into a tapestry of a person's life, "
                   "a blind weaver at the pedals"),
    ("reliquary", "an ornate cursed reliquary box opened slightly, unnatural light and grasping shadow leaking out"),
    ("wounded_companion", "a wounded companion slumped against a broken wall, reaching up, blood on gold armour"),
    ("feast_ruins", "a long banquet table set with rich food in a collapsed hall, every chair occupied by a "
                    "silent hooded guest"),
    ("cartographer", "a cartographer's tent full of impossible maps that redraw themselves, "
                     "the mapmaker offering a rolled scroll"),
    ("under_ice", "a figure kneeling on a frozen lake looking down at hundreds of pale hands pressed to the ice "
                  "from below"),
    ("gallows_tree", "a lone black tree hung with empty nooses swinging in the wind on a hill of ash"),
    ("forge_second", "an underground forge where a smith hammers a broken weapon back together with molten gold"),
    ("sleeping_titan", "explorers standing on the chest of a sleeping mountain-sized titan, its eye beginning to open"),
    ("ink_contract", "a quill and a contract written in blood on a stone altar, a shadowed hand offering the pen"),
    ("lighthouse", "a lighthouse standing in an endless desert of ash, its beam sweeping over nothing, "
                   "a light still burning"),
    ("door_knocks", "a simple wooden door set in a rock face, something enormous knocking from the other side, "
                    "dust shaking loose"),
    ("missing_faces", "a cathedral whose every statue and painting has had the face removed, "
                      "one blank face turning to look"),
    ("trial_storm", "a lone figure on a spire platform raising a blade to a descending column of lightning"),
    ("beggar_king", "a filthy beggar sitting on a golden throne in a ruined plaza, crown tilted, laughing"),
    ("unspent_lives", "a vault of glowing glass jars each containing a small sleeping figure, shelves to infinity"),
    ("betrayal", "a companion driving a blade into the hero's back mid-embrace, gold blood, "
                 "shock and firelight, dramatic"),
    ("authors_study", "a cluttered study floating in blank space, the desk covered in drawings of the hero's entire "
                      "journey, an empty chair still rocking"),
    ("first_fall", "a memory rendered in bleached colour: the very first hero falling from a great height, "
                   "arms spread, into a black sun"),
    ("loop_revealed", "the hero standing in a circular corridor lined with hundreds of identical corpses of "
                      "themselves, each in a different pose"),
    ("coronation", "a coronation in a burning cathedral, ash falling like snow, "
                   "a crown of thorned quills being lowered"),
    ("unwritten_dawn", "a blank white world at sunrise with a single figure holding a brush, "
                       "beginning to paint a new horizon"),
]
for k, d in EVENTS:
    ASSETS.append(a(f"event/{k}", "event", d, "16:9", PRO, PANEL))

# --------------------------------------------------------------- card art
CARDS = [
    ("ember_strike", "a fist of compressed flame punching forward, sparks trailing"),
    ("ember_wave", "a crescent wall of fire sweeping outward"),
    ("ember_brand", "a glowing brand-iron sigil burning into dark flesh"),
    ("ember_pyre", "a towering funeral pyre erupting upward into a column of fire"),
    ("ember_censer", "a swinging censer scattering burning cinders in an arc"),
    ("ember_immolate", "a silhouette wreathed entirely in white-hot flame, arms spread"),
    ("ember_cinderstorm", "a whirling storm of orange cinders filling the frame"),
    ("ember_ashblade", "a blade forged of packed ash crumbling as it cuts"),
    ("frost_lance", "a spear of clear ice piercing forward, frost cracking outward"),
    ("frost_bulwark", "a curved shield wall of blue-white ice rising from the ground"),
    ("frost_rime", "creeping hoarfrost crystals spreading across dark stone"),
    ("frost_glacier", "an enormous glacier calving down onto the frame"),
    ("frost_still", "a moment frozen mid-air, droplets and debris suspended in ice"),
    ("frost_shatter", "a frozen figure exploding into thousands of glittering shards"),
    ("frost_reliquary", "a frozen reliquary radiating a protective aura of cold light"),
    ("frost_whiteout", "a total whiteout blizzard, only a faint silhouette visible"),
    ("volt_arc", "a jagged bolt of violet lightning arcing between two points"),
    ("volt_chain", "chain lightning branching to multiple targets"),
    ("volt_overcharge", "a body crackling with excess electricity, veins glowing"),
    ("volt_railshot", "a hyper-accelerated projectile leaving a straight ionised trail"),
    ("volt_stormcall", "hands raised summoning a swirling thundercloud overhead"),
    ("volt_flicker", "a figure blinking between three positions in a streak of sparks"),
    ("volt_coil", "a great copper coil discharging rings of energy"),
    ("volt_judgment", "a single vertical pillar of white lightning striking down"),
    ("umbra_grasp", "shadow hands rising from the floor to seize an ankle"),
    ("umbra_veil", "a figure dissolving into a swirl of black smoke and lace"),
    ("umbra_curse", "a floating black sigil dripping tar onto a victim"),
    ("umbra_drain", "a tether of dark energy pulling glowing life from one shape to another"),
    ("umbra_puppet", "strings of shadow attached to a struggling marionette body"),
    ("umbra_eclipse", "a black disc devouring a sun, corona of purple flame"),
    ("umbra_echo", "an afterimage repeating an attack a half-second behind"),
    ("umbra_doom", "a black hourglass hovering above a kneeling silhouette"),
    ("lumen_ray", "a narrow beam of dawn-gold light lancing through darkness"),
    ("lumen_ward", "a dome of stained-glass light forming protectively"),
    ("lumen_mend", "warm golden motes knitting a wound closed"),
    ("lumen_nova", "a blinding omnidirectional detonation of white-gold light"),
    ("lumen_halo", "a crown of suspended light rings above a bowed head"),
    ("lumen_verdict", "an enormous scale of light weighing a shadow"),
    ("lumen_dawnspear", "a spear made of solid sunrise thrown mid-flight"),
    ("lumen_sanctuary", "a circle of standing light pillars forming a safe ground"),
    ("neutral_guard", "a battered shield raised, impact sparks"),
    ("neutral_dagger", "a thrown dagger spinning through smoky air"),
    ("neutral_focus", "an open palm holding a slowly rotating geometric sigil"),
    ("neutral_scavenge", "gauntleted hands digging treasure out of ash"),
    ("neutral_rewrite", "a page being violently erased and redrawn by an invisible quill"),
    ("neutral_paradox", "two identical figures walking into each other and merging"),
    ("neutral_gambit", "a coin flipping in mid-air over a chasm"),
    ("neutral_finale", "an explosive final storyboard panel cracking apart, all elements at once"),
]
for k, d in CARDS:
    ASSETS.append(a(f"card/{k}", "card", d, "1:1", DEV, CARDART))

# ------------------------------------------------------------ relic icons
RELICS = [
    ("ember_heart", "a still-beating heart made of glowing coal"),
    ("frost_tear", "a single frozen teardrop on a silver chain"),
    ("volt_nail", "an iron nail wrapped in crackling copper wire"),
    ("umbra_thread", "a spool of pure black thread unspooling into smoke"),
    ("lumen_shard", "a shard of stained glass glowing from within"),
    ("broken_hourglass", "an hourglass cracked open with sand frozen mid-fall"),
    ("gilded_mask", "a cracked porcelain mask repaired with gold seams"),
    ("bell_fragment", "a jagged fragment of a bronze cathedral bell"),
    ("marrow_die", "a six-sided die carved from bone"),
    ("quill_of_names", "a red quill with a drop of ink at the nib"),
    ("mainspring", "a tightly coiled brass mainspring"),
    ("mirror_coin", "a coin polished to a perfect mirror finish"),
    ("storm_bottle", "a glass bottle containing captive lightning"),
    ("ash_locket", "an open locket full of grey ash"),
    ("bone_crown", "a small crown made of interlocking vertebrae"),
    ("ink_vial", "a vial of impossibly black ink"),
    ("gear_ring", "a finger ring made of meshed miniature gears"),
    ("moth_wing", "a preserved grey moth wing under glass"),
    ("candle_stub", "a guttering candle stub in a bronze holder"),
    ("iron_chalice", "a dented iron chalice with dark liquid"),
    ("seed_of_dawn", "a golden seed radiating soft light"),
    ("chain_link", "a single heavy broken chain link"),
    ("compass_null", "a brass compass whose needle spins endlessly"),
    ("paper_heart", "an origami heart of manuscript paper"),
    ("scale_weight", "a small brass scale weight stamped with a rune"),
    ("void_pearl", "a matte black pearl absorbing all light"),
    ("blood_ledger", "a small leather ledger clasped with a rusted lock"),
    ("cinder_dice", "a pair of dice carved from smouldering charcoal"),
    ("glacial_lens", "a lens ground from flawless clear ice"),
    ("thorn_band", "an armband of black iron thorns"),
    ("echo_shell", "a spiral shell with darkness inside its opening"),
    ("sun_nail", "a golden spike radiating heat lines"),
    ("hollow_key", "an ornate key with a hole where the bit should be"),
    ("last_ember", "a single ember held in a tiny glass sphere"),
    ("torn_page", "a torn manuscript page with burnt edges"),
    ("aeon_sigil", "an ouroboros of gold biting a falling hourglass"),
]
for k, d in RELICS:
    ASSETS.append(a(f"relic/{k}", "relic", d, "1:1", FAST, ICON))

if __name__ == "__main__":
    from collections import Counter
    print(len(ASSETS), "assets")
    print(Counter(x["group"] for x in ASSETS))
    print(Counter(x["model"] for x in ASSETS))
