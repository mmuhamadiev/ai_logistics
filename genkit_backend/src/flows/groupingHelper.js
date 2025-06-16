import { z } from 'genkit';
import { ai } from "../ai.js";
import { gemini20Flash } from '@genkit-ai/googleai';

// Single order schema
export const OrderSchema = z.object({
  orderID: z.string(),
  orderName: z.string(),
  pickupPlace: z.object({
    countryCode: z.string(),
    postalCode: z.string(),
    name: z.string(),
    code: z.string(),
    latitude: z.number(),
    longitude: z.number()
  }),
  deliveryPlace: z.object({
    countryCode: z.string(),
    postalCode: z.string(),
    name: z.string(),
    code: z.string(),
    latitude: z.number(),
    longitude: z.number()
  }),
  pickupTimeWindow: z.object({
    start: z.string(),
    end: z.string()
  }),
  deliveryTimeWindow: z.object({
    start: z.string(),
    end: z.string()
  }),
  ldm: z.number(),
  weight: z.number(),
  price: z.number(),
  carTypeName: z.string(),
  isAdrOrder: z.boolean(),
  canGroupWithAdr: z.boolean()
});

// Full input
export const GroupInputSchema = z.object({
  groupID: z.string(),
  totalDistance: z.number(),
  pricePerKm: z.number(),
  totalPrice: z.number(),
  totalLDM: z.number(),
  totalWeight: z.number(),
  orders: z.array(OrderSchema),
});

// Output
export const GroupSuggestionSchema = z.object({
  isGoodGroup: z.boolean(),
  issues: z.array(z.string()),
  recommendations: z.array(z.string()),
  reasoning: z.string()
});

export const groupingHelperFlow = ai.defineFlow(
  {
    name: 'groupingHelperFlow',
    inputSchema: GroupInputSchema,
    outputSchema: GroupSuggestionSchema,
  },
  async (input) => {
    const prompt = `
You are a logistics grouping expert. Review the following group of orders and determine whether they are efficiently grouped. Perform the following steps:

1. **Validate Time Windows**:
   - Check compatibility of pickupTimeWindow and deliveryTimeWindow for all orders with a potential route.
   - Estimate travel time between locations using the provided totalDistance and an average speed of 60 km/h (distance ÷ 60 = hours).
   - Assume pickups and deliveries occur at the start of their respective time windows unless overlap prevents this, then suggest adjustments to the sequence if needed.
   - **Reasoning Requirements**: List each order’s pickup and delivery time windows, estimate travel times between stops based on the provided totalDistance, and explain if the sequence satisfies all time constraints or where conflicts arise.

2. **Calculate Optimal Route Distance**:
   - Use the pickupPlace and deliveryPlace coordinates (latitude, longitude) for each order.
   - Compute the total distance by optimizing the route: start at the first order's pickup, visit all pickups and deliveries in an efficient sequence (e.g., pickup of first order, pickup of second order, then deliveries, or pickup then delivery then next pickup then next delivery), and end at the last delivery.
   - If possible, recalculate route distance from coordinates; otherwise use totalDistance.
   - If you cannot calculate the distance accurately, use the provided totalDistance as a fallback (it is 90% correct).
   - Compare the calculated or fallback distance with the provided totalDistance.
   - Validate the route sequence for feasibility:
   - Ensure the sequence minimizes backtracking (e.g., pickups should generally precede deliveries unless time windows dictate otherwise).
   - Confirm cross-country transitions (e.g., DE to FR) are logical and align with the route sequence.
   - Verify that the route respects time windows (e.g., travel time between stops fits within the windows).
   - **Reasoning Requirements**: Reference the time window validation from Step 1, explain the time-based sequence chosen, refine with geographic optimization, describe the chosen route (e.g., Creuzburg -> Oelsnitz -> Martign-sur-Mayenne -> Simpl), and validate the route for backtracking, cross-country transitions.

3. **Calculate Price Per Km**:
   - Compute pricePerKm as totalPrice / totalDistance (using the calculated or fallback distance).
   - If you used the fallback totalDistance, use the provided pricePerKm as it is also 90% correct.
   - Ensure pricePerKm is within 1.5 €/km or above.
   - **Reasoning Requirements**: State the provided pricePerKm, confirm if it is within the acceptable range (1.5 €/km or above), and flag any issues if outside this range.

4. **Select and Validate Car Type Based on Load**:
   - Evaluate the total LDM and total weight to select the most appropriate car type from the available options, prioritizing the smallest suitable car type.
   - Available car types and their constraints:
     - **MEGA**: height: 3.0m, length: 13.6m, width: 2.48m, maxWeight: 25.0t, capacity: 34 pallets, loadingMethods: ["Rear", "Side", "Top"]
     - **TAUTLINER_PLANA**: height: 2.62m, length: 13.6m, width: 2.46m, maxWeight: 24.0t, capacity: 34 pallets, loadingMethods: ["Rear", "Side", "Top"]
     - **Frigo**: height: 2.6m, length: 13.4m, width: 2.46m, maxWeight: 22.0t, capacity: 33 pallets, loadingMethods: ["Rear"]
   - Ensure total LDM is less than the car type’s length (e.g., 13.6m for MEGA/TAUTLINER_PLANA, 13.4m for Frigo) and total weight is within the car type’s maxWeight.
   - If no single car type meets the requirements, flag an issue and recommend splitting the group or using multiple vehicles.
   - **Reasoning Requirements**: Provide the calculated total LDM (e.g., 13.5) and total weight (e.g., 16.5) from the input, compare these values against each car type’s length and maxWeight, select the smallest suitable car type (e.g., Frigo if LDM < 13.4 and weight < 22.0t, otherwise TAUTLINER_PLANA or MEGA), and confirm compatibility or identify issues.

Return a JSON object in this exact format:
{
  "isGoodGroup": true | false,
  "issues": ["issue 1", "issue 2"],
  "recommendations": ["recommendation 1", "recommendation 2"],
  "reasoning": "Step 1: Time-Windows...\nStep 2: Route...\nStep 3: Price/km...\nStep 4: Truck selection...",
  "totalDistance": number,
  "pricePerKm": number
}

Input:
${JSON.stringify(input, null, 2)}
`;

    const result = await ai.generate({
      model: gemini20Flash,
      prompt,
      output: {
        schema: GroupSuggestionSchema,
      },
      config: {
        temperature: 0.7,
      },
    });

    return result.output; // Directly return the schema-validated output
  }
);