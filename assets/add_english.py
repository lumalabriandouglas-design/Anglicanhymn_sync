import json

# 1. Load your existing JSON
with open('assets/hymns-full.json', 'r', encoding='utf-8') as f:
    hymns = json.load(f)

# 2. English data mapped by hymn number (n)
# Add more as we find them
english_data = {
    1: {
        "titleEnglish": "Awake, my soul, and with the sun",
        "lyricsEnglish": "Awake, my soul, and with the sun\nThy daily stage of duty run;\nShake off dull sloth, and joyful rise\nTo pay thy morning sacrifice.\n\nWake, and lift up thyself, my heart,\nAnd with the angels bear thy part,\nWho all night long unwearied sing\nHigh praise to the eternal King.\n\nAll praise to Thee, who safe hast kept\nAnd hast refreshed me while I slept;\nGrant, Lord, when I from death shall wake,\nI may of endless light partake.\n\nLord, I my vows to Thee renew;\nDisperse my sins as morning dew;\nGuard my first springs of thought and will,\nAnd with Thyself my spirit fill."
    },
    8: {
        "titleEnglish": "Christ, whose glory fills the skies",
        "lyricsEnglish": "Christ, whose glory fills the skies,\nChrist, the true, the only Light,\nSun of Righteousness, arise,\nTriumph o'er the shades of night;\nDayspring from on high, be near;\nDaystar, in my heart appear.\n\nDark and cheerless is the morn\nUnaccompanied by Thee;\nJoyless is the day's return\nTill Thy mercy's beams I see;\nTill they inward light impart,\nGlad my eyes, and warm my heart.\n\nVisit then this soul of mine,\nPierce the gloom of sin and grief;\nFill me, Radiancy divine,\nScatter all my unbelief;\nMore and more Thyself display,\nShining to the perfect day."
    },
    18: {
        "titleEnglish": "Abide with me",
        "lyricsEnglish": "Abide with me; fast falls the eventide;\nThe darkness deepens; Lord, with me abide.\nWhen other helpers fail and comforts flee,\nHelp of the helpless, O abide with me.\n\nSwift to its close ebbs out life's little day;\nEarth's joys grow dim; its glories pass away;\nChange and decay in all around I see;\nO Thou who changest not, abide with me.\n\nI need Thy presence every passing hour.\nWhat but Thy grace can foil the tempter's power?\nWho, like Thyself, my guide and stay can be?\nThrough cloud and sunshine, Lord, abide with me.\n\nI fear no foe, with Thee at hand to bless;\nIlls have no weight, and tears no bitterness.\nWhere is death's sting? Where, grave, thy victory?\nI triumph still, if Thou abide with me.\n\nHold Thou Thy cross before my closing eyes;\nShine through the gloom and point me to the skies.\nHeaven's morning breaks, and earth's vain shadows flee;\nIn life, in death, O Lord, abide with me."
    },
    77: {
        "titleEnglish": "When I survey the wondrous cross",
        "lyricsEnglish": "When I survey the wondrous cross\nOn which the Prince of glory died,\nMy richest gain I count but loss,\nAnd pour contempt on all my pride.\n\nForbid it, Lord, that I should boast,\nSave in the death of Christ my God!\nAll the vain things that charm me most,\nI sacrifice them to His blood.\n\nSee from His head, His hands, His feet,\nSorrow and love flow mingled down!\nDid e'er such love and sorrow meet,\nOr thorns compose so rich a crown?\n\nWere the whole realm of nature mine,\nThat were a present far too small;\nLove so amazing, so divine,\nDemands my soul, my life, my all."
    },
    115: {
        "titleEnglish": "The King of love my Shepherd is",
        "lyricsEnglish": "The King of love my Shepherd is,\nWhose goodness faileth never;\nI nothing lack if I am His\nAnd He is mine forever.\n\nWhere streams of living water flow\nMy ransomed soul He leadeth,\nAnd where the verdant pastures grow,\nWith food celestial feedeth.\n\nPerverse and foolish oft I strayed,\nBut yet in love He sought me,\nAnd on His shoulder gently laid,\nAnd home, rejoicing, brought me.\n\nIn death's dark vale I fear no ill\nWith Thee, dear Lord, beside me;\nThy rod and staff my comfort still,\nThy cross before to guide me.\n\nAnd so through all the length of days\nThy goodness faileth never;\nGood Shepherd, may I sing Thy praise\nWithin Thy house forever."
    },
    139: {
        "titleEnglish": "Hark! the herald angels sing",
        "lyricsEnglish": "Hark! the herald angels sing,\n\"Glory to the newborn King;\nPeace on earth, and mercy mild,\nGod and sinners reconciled!\"\nJoyful, all ye nations rise,\nJoin the triumph of the skies;\nWith th'angelic host proclaim,\n\"Christ is born in Bethlehem!\"\nHark! the herald angels sing,\n\"Glory to the newborn King!\"\n\nChrist, by highest heaven adored;\nChrist, the everlasting Lord!\nLate in time behold Him come,\nOffspring of a Virgin's womb.\nVeiled in flesh the Godhead see;\nHail th'incarnate Deity,\nPleased as man with man to dwell,\nJesus, our Emmanuel.\nHark! the herald angels sing,\n\"Glory to the newborn King!\"\n\nHail the heaven-born Prince of Peace!\nHail the Sun of Righteousness!\nLight and life to all He brings,\nRis'n with healing in His wings.\nMild He lays His glory by,\nBorn that man no more may die,\nBorn to raise the sons of earth,\nBorn to give them second birth.\nHark! the herald angels sing,\n\"Glory to the newborn King!\""
    },
    165: {
        "titleEnglish": "How sweet the name of Jesus sounds",
        "lyricsEnglish": "How sweet the name of Jesus sounds\nIn a believer's ear!\nIt soothes his sorrows, heals his wounds,\nAnd drives away his fear.\n\nIt makes the wounded spirit whole\nAnd calms the troubled breast;\n'Tis manna to the hungry soul,\nAnd to the weary, rest.\n\nDear name! the rock on which I build,\nMy shield and hiding place;\nMy never-failing treasury, filled\nWith boundless stores of grace.\n\nJesus, my Shepherd, Brother, Friend,\nMy Prophet, Priest, and King,\nMy Lord, my life, my way, my end,\nAccept the praise I bring.\n\nWeak is the effort of my heart,\nAnd cold my warmest thought;\nBut when I see Thee as Thou art,\nI'll praise Thee as I ought."
    },
    176: {
        "titleEnglish": "Rock of Ages",
        "lyricsEnglish": "Rock of Ages, cleft for me,\nLet me hide myself in Thee;\nLet the water and the blood,\nFrom Thy wounded side which flowed,\nBe of sin the double cure;\nSave from wrath and make me pure.\n\nNot the labors of my hands\nCan fulfill Thy law's demands;\nCould my zeal no respite know,\nCould my tears forever flow,\nAll for sin could not atone;\nThou must save, and Thou alone.\n\nNothing in my hand I bring,\nSimply to the cross I cling;\nNaked, come to Thee for dress;\nHelpless, look to Thee for grace;\nFoul, I to the fountain fly;\nWash me, Savior, or I die.\n\nWhile I draw this fleeting breath,\nWhen mine eyes shall close in death,\nWhen I soar to worlds unknown,\nSee Thee on Thy judgment throne,\nRock of Ages, cleft for me,\nLet me hide myself in Thee."
    },
    193: {
        "titleEnglish": "Rock of Ages",
        "lyricsEnglish": "Rock of Ages, cleft for me,\nLet me hide myself in Thee;\nLet the water and the blood,\nFrom Thy wounded side which flowed,\nBe of sin the double cure;\nSave from wrath and make me pure.\n\nNot the labors of my hands\nCan fulfill Thy law's demands;\nCould my zeal no respite know,\nCould my tears forever flow,\nAll for sin could not atone;\nThou must save, and Thou alone.\n\nNothing in my hand I bring,\nSimply to the cross I cling;\nNaked, come to Thee for dress;\nHelpless, look to Thee for grace;\nFoul, I to the fountain fly;\nWash me, Savior, or I die.\n\nWhile I draw this fleeting breath,\nWhen mine eyes shall close in death,\nWhen I soar to worlds unknown,\nSee Thee on Thy judgment throne,\nRock of Ages, cleft for me,\nLet me hide myself in Thee."
    },
    317: {
        "titleEnglish": "Through the night of doubt and sorrow",
        "lyricsEnglish": "Through the night of doubt and sorrow\nOnward goes the pilgrim band,\nSinging songs of expectation,\nMarching to the promised land.\nClear before us through the darkness\nGleams and burns the guiding light;\nBrother clasps the hand of brother,\nStepping fearless through the night.\n\nOne the light of God's own presence\nO'er His ransomed people shed,\nChasing far the gloom and terror,\nBrightening all the path we tread:\nOne the object of our journey,\nOne the faith which never tires,\nOne the earnest looking forward,\nOne the hope our God inspires.\n\nOne the strain that lips of thousands\nLift as from the heart of one;\nOne the conflict, one the peril,\nOne the march in God begun:\nOne the gladness of rejoicing\nOn the far eternal shore,\nWhere the one almighty Father\nReigns in love for evermore.\n\nOnward, therefore, pilgrim brothers,\nOnward, with the cross our aid!\nBear its shame, and fight its battle,\nTill we rest beneath its shade.\nSoon shall come the great awaking,\nSoon the rending of the tomb;\nThen the scattering of all shadows,\nAnd the end of toil and gloom."
    }
}

# 3. Inject the English fields
updated_count = 0
for hymn in hymns:
    n = hymn.get('n')
    if n in english_data:
        hymn['titleEnglish'] = english_data[n]['titleEnglish']
        hymn['lyricsEnglish'] = english_data[n]['lyricsEnglish']
        updated_count += 1

# 4. Save the updated file
with open('assets/hymns-full.json', 'w', encoding='utf-8') as f:
    json.dump(hymns, f, indent=2, ensure_ascii=False)

print(f"Successfully updated {updated_count} hymns with English lyrics!")