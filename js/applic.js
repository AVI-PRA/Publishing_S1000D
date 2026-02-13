/**
 * S1000D Applicability Filter (for S1000D Issue 4.2+)
 * Handles client-side filtering of content based on data-applic attributes.
 */
document.addEventListener('DOMContentLoaded', () => {

    const selector = document.getElementById('applic-selector');
    const contentContainer = document.getElementById('s1000d-content');
    const globalApplicBody = document.querySelector('body[data-applic-global]');

    // If there's no selector or content area, do nothing.
    if (!selector || !contentContainer) {
        console.log('Applicability filter not initialized: selector or content container not found.');
        return;
    }

    // Get all elements that have inline or global applicability rules.
    const filterableElements = document.querySelectorAll('[data-applic]');

    /**
     * Checks if a single element should be visible based on the selected filter.
     * @param {string} elementApplicStr - The data-applic attribute string (e.g., 'and;model=X;status=Y').
     * @param {Object} selectedFilter - The parsed filter from the dropdown (e.g., {model: 'X', status: 'Y'}).
     * @returns {boolean} - True if the element is applicable, false otherwise.
     */
    function isElementApplicable(elementApplicStr, selectedFilter) {
        // Elements without a data-applic attribute are universally applicable within the current view.
        if (!elementApplicStr) return true;

        const parts = elementApplicStr.split(';');
        const operator = parts.shift().toLowerCase(); // 'and' or 'or'
        const asserts = parts.map(p => {
            const [ident, values] = p.split('=');
            // An assert is valid only if it has an ident and values.
            return (ident && values) ? { ident, values: values.split('|') } : null;
        }).filter(Boolean); // Remove any nulls from invalid assert strings.

        // If there are no valid asserts, the element is considered universally applicable.
        if (asserts.length === 0) return true;

        if (operator === 'and') {
            // For AND, every assert must be satisfied by the selected filter.
            return asserts.every(assert =>
                selectedFilter.hasOwnProperty(assert.ident) &&
                assert.values.includes(selectedFilter[assert.ident])
            );
        }

        if (operator === 'or') {
            // For OR, at least one assert must be satisfied.
            return asserts.some(assert =>
                selectedFilter.hasOwnProperty(assert.ident) &&
                assert.values.includes(selectedFilter[assert.ident])
            );
        }

        return true; // Default to visible if the operator is unknown or missing.
    }

    /**
     * Main function to filter all content on the page based on the dropdown selection.
     */
    function filterContent() {
        const selectedValue = selector.value;

        // Case 1: "Show All" is selected.
        if (selectedValue === 'all') {
            // Make the entire content area visible.
            contentContainer.classList.remove('hidden-by-applic');
            // Make all individual filterable elements visible.
            filterableElements.forEach(el => el.classList.remove('hidden-by-applic'));
            return;
        }

        // Case 2: A specific product is selected.
        // Parse the selected filter into a key-value object.
        // e.g., 'and;aircraftModel=MODELX1;modStatus=POSTMOD_Y' -> { aircraftModel: 'MODELX1', modStatus: 'POSTMOD_Y' }
        const selectedFilter = selectedValue.split(';')
            .slice(1) // Skip the 'and'/'or' operator at the beginning.
            .reduce((acc, part) => {
                const [key, value] = part.split('=');
                if (key && value) acc[key] = value;
                return acc;
            }, {});

        // First, check the DM's global applicability against the selected product.
        const globalApplicStr = globalApplicBody ? globalApplicBody.dataset.applicGlobal : null;
        const isDmApplicable = isElementApplicable(globalApplicStr, selectedFilter);

        // If the entire DM is not applicable, hide the main content and we're done.
        if (!isDmApplicable) {
            contentContainer.classList.add('hidden-by-applic');
            return;
        }

        // If the DM is applicable, ensure the content area is visible and filter its children.
        contentContainer.classList.remove('hidden-by-applic');

        filterableElements.forEach(el => {
            const elementApplicStr = el.dataset.applic;
            if (isElementApplicable(elementApplicStr, selectedFilter)) {
                el.classList.remove('hidden-by-applic');
            } else {
                el.classList.add('hidden-by-applic');
            }
        });
    }

    // Attach the event listener to the dropdown.
    selector.addEventListener('change', filterContent);

    // Run the filter once on page load to set the initial state.
    filterContent();
});