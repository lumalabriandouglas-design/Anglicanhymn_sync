import json

with open('assets/hymns-full.json', 'r', encoding='utf-8') as f:
    hymns = json.load(f)

english_data = {
    1: {
        "titleEnglish": "Awake, my soul, and with the sun",
        "lyricsEnglish": "Awake, my soul, and with the sun\nThy daily stage of duty run;\nShake off dull sloth, and joyful rise\nTo pay thy morning sacrifice.\n\nWake, and lift up thyself, my heart,\nAnd with the angels bear thy part,\nWho all night long unwearied sing\nHigh praise to the eternal King.\n\nAll praise to Thee, who safe hast kept\nAnd hast refreshed me while I slept;\nGrant, Lord, when I from death shall wake,\nI may of endless light partake.\n\nLord, I my vows to Thee renew;\nDisperse my sins as morning dew;\nGuard my first springs of thought and will,\nAnd with Thyself my spirit fill."
    },
    2: {
        "titleEnglish": "Jesus, Lord of heaven",
        "lyricsEnglish": "Jesus, Lord of heaven and earth,\nGlory of the Father,\nSun of peace and righteousness,\nDrive away the darkness.\n\nCome, O Daystar from on high,\nShine upon us with Your grace;\nHoly Spirit, dwell within,\nFill our hearts with peace.\n\nStrengthen faith within us, Lord,\nRule our bodies and our minds;\nGive us joy and lasting peace,\nDrive all falsehood far away."
    },
    5: {
        "titleEnglish": "Come to me when I awake",
        "lyricsEnglish": "Come to me when I awake,\nAs the morning light appears;\nWrite upon my heart, O Lord,\nThoughts that are acceptable.\n\nCome to me in daily work,\nWhen the world would claim my mind;\nLet no earthly care obscure\nThe bright shining of Your face.\n\nCome to me when evening falls,\nAnd when I have turned away;\nCall me back and keep me safe\nFrom the snares of the enemy.\n\nCome to me in darkest night,\nWhen I sleep and when I dream;\nKeep me free from every fear,\nGuarded by the Saviour's power.\n\nStay with me throughout my life,\nStay with me when death draws near;\nLead me safely to Your home,\nThat I may rejoice with You."
    },
    8: {
        "titleEnglish": "Christ, whose glory fills the skies",
        "lyricsEnglish": "Christ, whose glory fills the skies,\nChrist, the true, the only Light,\nSun of Righteousness, arise,\nTriumph o'er the shades of night;\nDayspring from on high, be near;\nDaystar, in my heart appear.\n\nDark and cheerless is the morn\nUnaccompanied by Thee;\nJoyless is the day's return\nTill Thy mercy's beams I see;\nTill they inward light impart,\nGlad my eyes, and warm my heart.\n\nVisit then this soul of mine,\nPierce the gloom of sin and grief;\nFill me, Radiancy divine,\nScatter all my unbelief;\nMore and more Thyself display,\nShining to the perfect day."
    },
    11: {
        "titleEnglish": "My King",
        "lyricsEnglish": "My King, I rejoice\nTo give thanks for Your glory;\nIn the morning I praise Your name,\nAnd declare it through the night.\n\nYour day is holy,\nA day of glory and of joy:\nLet all the nations sing\nWith gladness and with fear.\n\nAll workers of iniquity\nShall be scattered far away;\nThey shall wither like the grass,\nBut the righteous shall endure.\n\nThe saints of the Lord\nStand firm like the cedar;\nNo storm shall break them down,\nFor they are given to remain."
    },
    18: {
        "titleEnglish": "Abide with me",
        "lyricsEnglish": "Abide with me; fast falls the eventide;\nThe darkness deepens; Lord, with me abide.\nWhen other helpers fail and comforts flee,\nHelp of the helpless, O abide with me.\n\nSwift to its close ebbs out life's little day;\nEarth's joys grow dim; its glories pass away;\nChange and decay in all around I see;\nO Thou who changest not, abide with me.\n\nI need Thy presence every passing hour.\nWhat but Thy grace can foil the tempter's power?\nWho, like Thyself, my guide and stay can be?\nThrough cloud and sunshine, Lord, abide with me.\n\nI fear no foe, with Thee at hand to bless;\nIlls have no weight, and tears no bitterness.\nWhere is death's sting? Where, grave, thy victory?\nI triumph still, if Thou abide with me.\n\nHold Thou Thy cross before my closing eyes;\nShine through the gloom and point me to the skies.\nHeaven's morning breaks, and earth's vain shadows flee;\nIn life, in death, O Lord, abide with me."
    },
    34: {
        "titleEnglish": "O come, all ye faithful",
        "lyricsEnglish": "O come, all ye faithful, joyful and triumphant!\nO come ye, O come ye to Bethlehem;\nCome and behold him, born the King of angels:\nO come, let us adore him, Christ the Lord!\n\nGod of God, Light of Light,\nLo, he abhors not the Virgin's womb;\nVery God, begotten, not created:\nO come, let us adore him, Christ the Lord!\n\nSing, choirs of angels, sing in exultation,\nSing, all ye citizens of heaven above!\nGlory to God, glory in the highest:\nO come, let us adore him, Christ the Lord!\n\nYea, Lord, we greet thee, born this happy morning;\nJesus, to thee be glory given!\nWord of the Father, now in flesh appearing:\nO come, let us adore him, Christ the Lord!"
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
    197: {
        "titleEnglish": "Holy, holy, holy! Lord God Almighty",
        "lyricsEnglish": "Holy, holy, holy! Lord God Almighty!\nEarly in the morning our song shall rise to Thee;\nHoly, holy, holy, merciful and mighty!\nGod in three Persons, blessed Trinity!\n\nHoly, holy, holy! All the saints adore Thee,\nCasting down their golden crowns around the glassy sea;\nCherubim and seraphim falling down before Thee,\nWhich wert, and art, and evermore shalt be.\n\nHoly, holy, holy! Though the darkness hide Thee,\nThough the eye of sinful man Thy glory may not see;\nOnly Thou art holy; there is none beside Thee,\nPerfect in power, in love, and purity.\n\nHoly, holy, holy! Lord God Almighty!\nAll Thy works shall praise Thy Name, in earth, and sky, and sea;\nHoly, holy, holy; merciful and mighty!\nGod in three Persons, blessed Trinity!"
    },
    250: {
        "titleEnglish": "Are you washed in the blood",
        "lyricsEnglish": "Have you been to Jesus for the cleansing power?\nAre you washed in the blood of the Lamb?\nAre you fully trusting in His grace this hour?\nAre you washed in the blood of the Lamb?\n\nAre you washed in the blood,\nIn the soul-cleansing blood of the Lamb?\nAre your garments spotless? Are they white as snow?\nAre you washed in the blood of the Lamb?\n\nAre you walking daily by the Savior's side?\nAre you washed in the blood of the Lamb?\nDo you rest each moment in the Crucified?\nAre you washed in the blood of the Lamb?\n\nWhen the Bridegroom cometh will your robes be white?\nAre you washed in the blood of the Lamb?\nWill your soul be ready for the mansions bright,\nAnd be washed in the blood of the Lamb?\n\nLay aside the garments that are stained with sin,\nAnd be washed in the blood of the Lamb;\nThere's a fountain flowing for the soul unclean,\nO be washed in the blood of the Lamb!"
    },
    267: {
        "titleEnglish": "Nearer, my God, to Thee",
        "lyricsEnglish": "Nearer, my God, to Thee, nearer to Thee!\nE'en though it be a cross that raiseth me,\nStill all my song shall be, nearer, my God, to Thee;\nNearer, my God, to Thee, nearer to Thee!\n\nThough like the wanderer, the sun gone down,\nDarkness be over me, my rest a stone;\nYet in my dreams I'd be nearer, my God, to Thee;\nNearer, my God, to Thee, nearer to Thee!\n\nThere let the way appear, steps unto heaven;\nAll that Thou sendest me, in mercy given;\nAngels to beckon me nearer, my God, to Thee;\nNearer, my God, to Thee, nearer to Thee!\n\nThen, with my waking thoughts bright with Thy praise,\nOut of my stony griefs Bethel I'll raise;\nSo by my woes to be nearer, my God, to Thee;\nNearer, my God, to Thee, nearer to Thee!\n\nOr if on joyful wing cleaving the sky,\nSun, moon, and stars forgot, upward I'll fly,\nStill all my song shall be, nearer, my God, to Thee;\nNearer, my God, to Thee, nearer to Thee!"
    },
    317: {
        "titleEnglish": "Through the night of doubt and sorrow",
        "lyricsEnglish": "Through the night of doubt and sorrow\nOnward goes the pilgrim band,\nSinging songs of expectation,\nMarching to the promised land.\nClear before us through the darkness\nGleams and burns the guiding light;\nBrother clasps the hand of brother,\nStepping fearless through the night.\n\nOne the light of God's own presence\nO'er His ransomed people shed,\nChasing far the gloom and terror,\nBrightening all the path we tread:\nOne the object of our journey,\nOne the faith which never tires,\nOne the earnest looking forward,\nOne the hope our God inspires.\n\nOne the strain that lips of thousands\nLift as from the heart of one;\nOne the conflict, one the peril,\nOne the march in God begun:\nOne the gladness of rejoicing\nOn the far eternal shore,\nWhere the one almighty Father\nReigns in love for evermore.\n\nOnward, therefore, pilgrim brothers,\nOnward, with the cross our aid!\nBear its shame, and fight its battle,\nTill we rest beneath its shade.\nSoon shall come the great awaking,\nSoon the rending of the tomb;\nThen the scattering of all shadows,\nAnd the end of toil and gloom."
    },
    332: {
        "titleEnglish": "What a friend we have in Jesus",
        "lyricsEnglish": "What a friend we have in Jesus,\nAll our sins and griefs to bear!\nWhat a privilege to carry\nEverything to God in prayer!\nO what peace we often forfeit,\nO what needless pain we bear,\nAll because we do not carry\nEverything to God in prayer!\n\nHave we trials and temptations?\nIs there trouble anywhere?\nWe should never be discouraged;\nTake it to the Lord in prayer.\nCan we find a friend so faithful\nWho will all our sorrows share?\nJesus knows our every weakness;\nTake it to the Lord in prayer.\n\nAre we weak and heavy laden,\nCumbered with a load of care?\nPrecious Savior, still our refuge;\nTake it to the Lord in prayer.\nDo thy friends despise, forsake thee?\nTake it to the Lord in prayer!\nIn His arms He'll take and shield thee;\nThou wilt find a solace there."
    },
    342: {
        "titleEnglish": "Blessed assurance",
        "lyricsEnglish": "Blessed assurance, Jesus is mine!\nO what a foretaste of glory divine!\nHeir of salvation, purchase of God,\nBorn of His Spirit, washed in His blood.\n\nThis is my story, this is my song,\nPraising my Savior all the day long;\nThis is my story, this is my song,\nPraising my Savior all the day long.\n\nPerfect submission, perfect delight,\nVisions of rapture now burst on my sight;\nAngels descending bring from above\nEchoes of mercy, whispers of love.\n\nPerfect submission, all is at rest,\nI in my Savior am happy and blest,\nWatching and waiting, looking above,\nFilled with His goodness, lost in His love."
    }
}

updated = 0
for hymn in hymns:
    n = hymn.get('n')
    if n in english_data:
        hymn['titleEnglish'] = english_data[n]['titleEnglish']
        hymn['lyricsEnglish'] = english_data[n]['lyricsEnglish']
        updated += 1

with open('assets/hymns-full.json', 'w', encoding='utf-8') as f:
    json.dump(hymns, f, indent=2, ensure_ascii=False)

print(f"Successfully updated {updated} hymns with English lyrics!")