// This function defines what to show.
function show(data) {
        // If not defined (not available?)
        if(available_bands[data.band] === undefined) {
                return 0;
        }
        // If not available
        if(!available_bands[data.band]) {
                return 0;
        }
        if(worked[data.prefix] === undefined) {
                return 3;
        }
        if(worked[data.prefix][data.band] === undefined) {
                return 2;
        }
        if(worked[data.prefix][data.band]['qsl'] !== undefined) {
                return 0;
        }
        if(worked[data.prefix][data.band]['qsl_lotw'] !== undefined) {
                return 0;
        }
        if(worked[data.prefix][data.band]['qsl_eqsl'] !== undefined) {
                return 0;
        }
        return 1;
}
