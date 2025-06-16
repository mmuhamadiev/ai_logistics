const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// List of all possible order statuses
const ORDER_STATUSES = [
    "Pending",
    "Confirmed",
    "Assigned",
    "OnTheWay",
    "Complete",
    "Canceled",
    "ClientCanceled",
    "Loaded",
    "Unloaded",
    "Problematic"
];

// Firestore Trigger: Updates metrics whenever an order is created, updated, or deleted
exports.updateOrderMetrics = functions.firestore
    .onDocumentWritten("orders/{orderId}", async (event) => {
        try {
            // Fetch all orders from Firestore
            const ordersSnapshot = await db.collection("orders").get();

            // Initialize counters
            let totalOrders = ordersSnapshot.size;
            let statusCounts = {};

            // Set all statuses to zero initially
            ORDER_STATUSES.forEach(status => {
                statusCounts[status] = 0;
            });

            // Count occurrences of each status
            ordersSnapshot.forEach((doc) => {
                const order = doc.data();

                // Ensure the `status` field exists and is a valid string
                if (order.status && typeof order.status === "string") {
                    let normalizedStatus = order.status.trim(); // Remove spaces if any

                    // Only count valid statuses
                    if (ORDER_STATUSES.includes(normalizedStatus)) {
                        statusCounts[normalizedStatus]++;
                    }
                }
            });

            // Save counts in Firestore
            await db.collection("metrics").doc("orders_count").set({
                totalOrders,
                statusCounts,
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            }, { merge: true });

            console.log("Updated order metrics successfully!");

        } catch (error) {
            console.error("Error updating order metrics:", error);
        }
    });

// Firestore Trigger: Updates metrics for orderGroups whenever an orderGroup is created, updated, or deleted
exports.updateOrderGroupMetrics = functions.firestore
    .onDocumentWritten("orderGroups/{groupID}", async (event) => {
        try {
            // Fetch all orderGroups from Firestore
            const orderGroupsSnapshot = await db.collection("orderGroups").get();

            // Initialize counters
            let totalOrderGroups = orderGroupsSnapshot.size;
            let statusCounts = {};

            // Set all statuses to zero initially
            ORDER_STATUSES.forEach(status => {
                statusCounts[status] = 0;
            });

            // Count occurrences of each status
            orderGroupsSnapshot.forEach((doc) => {
                const orderGroup = doc.data();

                // Ensure the `status` field exists and is a valid string
                if (orderGroup.status && typeof orderGroup.status === "string") {
                    let normalizedStatus = orderGroup.status.trim(); // Remove spaces if any

                    // Only count valid statuses
                    if (ORDER_STATUSES.includes(normalizedStatus)) {
                        statusCounts[normalizedStatus]++;
                    }
                }
            });

            // Save counts in Firestore under group_orders_count
            await db.collection("metrics").doc("group_orders_count").set({
                totalOrderGroups,
                statusCounts,
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            }, { merge: true });

            console.log("Updated order group metrics successfully!");

        } catch (error) {
            console.error("Error updating order group metrics:", error);
        }
    });
