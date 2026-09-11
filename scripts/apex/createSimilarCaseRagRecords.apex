String originValue = 'Web';
List<Schema.PicklistEntry> originEntries = Case.Origin.getDescribe().getPicklistValues();
Set<String> activeOrigins = new Set<String>();
for (Schema.PicklistEntry entry : originEntries) {
    if (entry.isActive()) {
        activeOrigins.add(entry.getValue());
    }
}
if (!activeOrigins.contains(originValue) && !originEntries.isEmpty()) {
    for (Schema.PicklistEntry entry : originEntries) {
        if (entry.isActive()) {
            originValue = entry.getValue();
            break;
        }
    }
}

String closedStatus;
List<CaseStatus> closedStatuses = [
    SELECT MasterLabel
    FROM CaseStatus
    WHERE IsClosed = true
    ORDER BY SortOrder
    LIMIT 1
];
if (!closedStatuses.isEmpty()) {
    closedStatus = closedStatuses[0].MasterLabel;
}

List<Case> existingSeeds = [
    SELECT Id
    FROM Case
    WHERE Subject LIKE '[RAG-DEMO]%'
];
if (!existingSeeds.isEmpty()) {
    Database.delete(existingSeeds, false);
}

List<Case> seeds = new List<Case>();

seeds.add(new Case(
    Subject = '[RAG-DEMO] Toaster oven will not start',
    Description = 'The toaster oven is plugged in but when I push the power button, nothing happens. Nothing lights up. There is no power.',
    Origin = originValue,
    Resolution__c = 'Confirmed the wall outlet had no power. Customer moved the toaster oven to a working outlet and the unit started immediately. If a working outlet still shows no lights, unplug the unit, inspect the power cord for melt marks, and replace the thermal fuse per SOP-TO-12.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Toaster oven shuts off after 15 minutes',
    Description = 'If I am cooking anything for more than 15 minutes, the toaster oven shuts off automatically. It does this even when the timer is set longer.',
    Origin = originValue,
    Resolution__c = 'Thermal cutoff was tripping because the crumb tray was packed and airflow was blocked. Customer emptied the crumb tray, gave the unit 20 minutes to cool, then cooked again on Bake 350 F. The unit stayed on for the full timer. If it still cuts off empty, replace the thermal cutoff switch.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Toaster oven has no lights when plugged in',
    Description = 'I plugged in the toaster oven and selected Toast. No display lights came on and the fan never started.',
    Origin = originValue,
    Resolution__c = 'Power cord insulation was cracked at the strain relief. Replaced the power cord assembly and verified the outlet with a lamp. Unit powered on and completed a 5-minute empty bake. Advised customer not to use a damaged cord.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Toaster oven not heating on broil',
    Description = 'I turned the toaster oven to the broil setting but the temperature does not go above lukewarm even after 10 minutes.',
    Origin = originValue,
    Resolution__c = 'Top heating element was open-circuit. Replaced the broil element, ran a 10-minute Broil cycle, and confirmed the rack area reached cooking temperature. If a new element still stays lukewarm, check the temperature selector switch.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Toast burns on the lowest setting',
    Description = 'The toaster oven always burns my toast, even when I select the Light setting. This happens with white bread and bagels.',
    Origin = originValue,
    Resolution__c = 'Rack was in the top slot, which sits too close to the broil element on Light. Moved the rack to the center slot and reduced the Toast shade by one. Test slice came out light brown. If toast still burns on center rack, recalibrate the toast thermostat.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Toaster oven heats unevenly',
    Description = 'The left side of my pizza is pale and the right side is overcooked. Bake setting at 400 F for 12 minutes.',
    Origin = originValue,
    Resolution__c = 'One bake element had a cold spot. Replaced the lower heating element and rotated the pan halfway during a test bake. Heat was even across the stone. Advised customer to use the center rack and avoid covering the rear vent.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Power cord caught fire',
    Description = 'The power cord caught fire the first time I tried to use my toaster oven to cook a pizza.',
    Origin = originValue,
    Resolution__c = 'Instructed customer to unplug immediately and not use the unit. Inspected photos: cord jacket was blistered at the plug. Issued a replacement toaster oven and arranged pickup of the damaged unit. Do not repair a cord that has ignited. File product safety follow-up.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Crumbs in toaster oven caught fire',
    Description = 'Crumbs from my bagel dropped to the bottom of the toaster oven and caught fire while toasting.',
    Origin = originValue,
    Resolution__c = 'Told customer to unplug, keep the door closed until flames are out, then wait for the unit to cool. Removed and washed the crumb tray. Residual grease on the floor of the cavity was cleaned. After a dry empty cycle, toasting worked without smoke. Advised emptying the crumb tray after every few uses.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Toaster oven smoked on first use',
    Description = 'Brand new toaster oven smoked the first time I turned it on. I thought it was on fire.',
    Origin = originValue,
    Resolution__c = 'First-use smoke came from manufacturing oils on the elements, not an active fire. Ran two empty Bake cycles at 400 F with the kitchen vent on. Smoke stopped after the second cycle. Shared the first-use burn-off steps from the quick-start guide. No parts replaced.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Glass window broken on arrival',
    Description = 'The glass window was broken when I opened the package. I have not used the toaster oven.',
    Origin = originValue,
    Resolution__c = 'Unit was dead-on-arrival with a shattered door glass. Do not operate. Issued an advance replacement and emailed a prepaid return label for the damaged unit. No in-home glass replacement for this model.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Toaster oven package arrived crushed',
    Description = 'The toaster oven was visibly damaged when I opened the crushed delivery package. The corner of the housing is dented.',
    Origin = originValue,
    Resolution__c = 'Carrier damage. Photographed the carton and dented housing, opened a freight claim, and shipped a replacement toaster oven the same day. Customer was told not to power on a unit with a deformed body or door.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Toaster oven missing bake rack',
    Description = 'The box was intact but the bake rack and crumb tray were not in the package.',
    Origin = originValue,
    Resolution__c = 'Shipped the missing bake rack and crumb tray from accessory stock. No full-unit replacement needed. Customer confirmed both parts arrived and the oven completed a test toast cycle.'
));
seeds.add(new Case(
    Subject = '[RAG-DEMO] Toaster oven heat issue still under investigation',
    Description = 'My toaster oven is warm but never reaches the set temperature. I have not tried any troubleshooting yet.',
    Origin = originValue,
    Resolution__c = null
));

Database.SaveResult[] insertResults = Database.insert(seeds, false);
Integer insertedCount = 0;
for (Integer i = 0; i < insertResults.size(); i++) {
    if (insertResults[i].isSuccess()) {
        insertedCount++;
    } else {
        System.debug(LoggingLevel.ERROR, 'Insert failed for ' + seeds[i].Subject + ': ' + insertResults[i].getErrors()[0].getMessage());
    }
}
System.assert(insertedCount > 0, 'No Case records were inserted.');

if (closedStatus != null) {
    List<Case> toClose = new List<Case>();
    for (Case seed : seeds) {
        if (seed.Id == null) {
            continue;
        }
        if (String.isBlank(seed.Resolution__c)) {
            continue;
        }
        seed.Status = closedStatus;
        toClose.add(seed);
    }
    Database.SaveResult[] closeResults = Database.update(toClose, false);
    Integer closedCount = 0;
    Integer closeFailures = 0;
    for (Integer i = 0; i < closeResults.size(); i++) {
        if (closeResults[i].isSuccess()) {
            closedCount++;
        } else {
            closeFailures++;
            System.debug(LoggingLevel.ERROR, 'Close failed for ' + toClose[i].Subject + ': ' + closeResults[i].getErrors()[0].getMessage());
        }
    }
    System.debug('Closed ' + closedCount + ' Cases using status ' + closedStatus + '. Close failures: ' + closeFailures);
} else {
    System.debug(LoggingLevel.WARN, 'No closed Case status found. Records were left in the default open status. Close them manually before indexing.');
}

List<Case> verifyRows = [
    SELECT CaseNumber, Subject, Status, IsClosed, Resolution__c
    FROM Case
    WHERE Subject LIKE '[RAG-DEMO]%'
    ORDER BY Subject
];
System.debug('Seeded ' + verifyRows.size() + ' [RAG-DEMO] Cases. Inserted this run: ' + insertedCount);
for (Case row : verifyRows) {
    Boolean hasResolution = !String.isBlank(row.Resolution__c);
    System.debug(row.CaseNumber + ' | closed=' + row.IsClosed + ' | resolution=' + hasResolution + ' | ' + row.Subject);
}
