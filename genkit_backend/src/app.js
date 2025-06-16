import { startFlowServer } from '@genkit-ai/express';
import { groupingHelperFlow } from './flows/groupingHelper.js';

startFlowServer({
    port: 2222,
    cors: {
        origin: "*",
    },
    flows: [groupingHelperFlow],
});