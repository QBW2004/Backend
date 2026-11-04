// Keep the existing validation entry point; exercise both real redesigned pages.
process.argv.push('--test');
require('./preview-rabbit-config.cjs');
