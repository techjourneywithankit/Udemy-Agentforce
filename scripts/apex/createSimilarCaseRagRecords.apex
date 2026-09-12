delete [SELECT Id FROM Case WHERE Subject LIKE '[RAG-DEMO]%'];

String closedStatus = [
    SELECT MasterLabel
    FROM CaseStatus
    WHERE IsClosed = true
    ORDER BY SortOrder
    LIMIT 1
]
.MasterLabel;

List<Case> seeds = new List<Case>{
    new Case(
        Subject = '[RAG-DEMO] Toaster oven will not start',
        Description = 'The toaster oven is plugged in but when I push the power button, nothing happens. Nothing lights up. There is no power.',
        Origin = 'Web',
        Resolution__c = 'Outlet had no power. Customer used a working outlet and the unit started. If still dead, replace the thermal fuse.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Toaster oven shuts off after 15 minutes',
        Description = 'If I cook anything longer than 15 minutes, the toaster oven shuts off even when the timer is set longer.',
        Origin = 'Web',
        Resolution__c = 'Thermal cutoff tripped because the crumb tray was packed. Empty the tray, cool 20 minutes, then bake again. If it still cuts off empty, replace the thermal cutoff switch.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Toaster oven has no lights when plugged in',
        Description = 'I plugged in the toaster oven and selected Toast. No display lights came on and the fan never started.',
        Origin = 'Web',
        Resolution__c = 'Power cord was cracked at the strain relief. Replaced the cord, verified the outlet, and the unit completed a 5-minute empty bake.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Toaster oven not heating on broil',
        Description = 'I turned the toaster oven to broil but it stays lukewarm even after 10 minutes.',
        Origin = 'Web',
        Resolution__c = 'Top heating element was open-circuit. Replaced the broil element and confirmed the rack area reached cooking temperature.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Toast burns on the lowest setting',
        Description = 'The toaster oven burns toast even on the Light setting, for white bread and bagels.',
        Origin = 'Web',
        Resolution__c = 'Rack was in the top slot. Moved it to center and reduced Toast shade by one. Toast came out light brown.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Toaster oven heats unevenly',
        Description = 'The left side of my pizza is pale and the right side is overcooked at Bake 400 F for 12 minutes.',
        Origin = 'Web',
        Resolution__c = 'Lower bake element had a cold spot. Replaced it and used the center rack. Heat was even on the test bake.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Power cord caught fire',
        Description = 'The power cord caught fire the first time I used the toaster oven to cook a pizza.',
        Origin = 'Web',
        Resolution__c = 'Unplug immediately and do not use the unit. Cord jacket was blistered at the plug. Issued a replacement. Do not repair a cord that has ignited.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Crumbs caught fire',
        Description = 'Bagel crumbs in the bottom of the toaster oven caught fire while toasting.',
        Origin = 'Web',
        Resolution__c = 'Unplug and keep the door closed until flames are out. Empty and wash the crumb tray. Empty it after every few uses.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Toaster oven smoked on first use',
        Description = 'Brand new toaster oven smoked the first time I turned it on. I thought it was on fire.',
        Origin = 'Web',
        Resolution__c = 'First-use smoke from manufacturing oils, not a fire. Two empty Bake cycles at 400 F cleared it. No parts replaced.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Glass window broken on arrival',
        Description = 'The glass window was broken when I opened the package. I have not used the toaster oven.',
        Origin = 'Web',
        Resolution__c = 'Dead on arrival. Do not operate. Issued an advance replacement and a prepaid return label. No in-home glass replacement for this model.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Package arrived crushed',
        Description = 'The toaster oven was damaged in a crushed delivery box. The housing corner is dented.',
        Origin = 'Web',
        Resolution__c = 'Carrier damage. Issued a replacement and told the customer not to power on a dented unit.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Toaster oven missing bake rack',
        Description = 'The box was intact but the bake rack and crumb tray were not in the package.',
        Origin = 'Web',
        Resolution__c = 'Shipped the missing bake rack and crumb tray from accessory stock. No full-unit replacement needed.'
    ),
    new Case(
        Subject = '[RAG-DEMO] Toaster oven heat issue still under investigation',
        Description = 'My toaster oven is warm but never reaches the set temperature. I have not tried troubleshooting yet.',
        Origin = 'Web'
    )
};
insert seeds;

List<Case> toClose = new List<Case>();
for (Case seed : seeds) {
    if (String.isNotBlank(seed.Resolution__c)) {
        seed.Status = closedStatus;
        toClose.add(seed);
    }
}
update toClose;
