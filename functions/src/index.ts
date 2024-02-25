/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {
  CallableRequest,
  HttpsError,
  onCall,
  onRequest,
} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2";
import * as logger from "firebase-functions/logger";
import {
  GenerateContentRequest,
  HarmBlockThreshold,
  HarmCategory,
  VertexAI,
} from "@google-cloud/vertexai";
import {onSchedule} from "firebase-functions/lib/v2/providers/scheduler";
import {Firestore} from "@google-cloud/firestore";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

setGlobalOptions({maxInstances: 10});

export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase App!");
});

export const anotherHelloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase App!");
});

export const addUserInventory = onRequest((request, response) => {
  logger.info("Adding new item to user inventory", {structuredData: true});
});

interface ReadReceiptGetRequestData {
  base64_image_data: string;
  mime_type: string;
}

export const readReceipt = onCall(
  async (request: CallableRequest<ReadReceiptGetRequestData>) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Must be called while authenticated",
      );
    }

    const vertexAi = new VertexAI({
      project: "sc2024-96b48",
      location: "us-central1",
    });
    const model = "gemini-pro-vision";

    const generativeModel = vertexAi.preview.getGenerativeModel({
      model: model,
      generation_config: {
        max_output_tokens: 2048,
        temperature: 0.1,
        top_p: 1,
        top_k: 32,
      },
      safety_settings: [
        {
          category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
          threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        },
        {
          category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
          threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        },
        {
          category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
          threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        },
        {
          category: HarmCategory.HARM_CATEGORY_HARASSMENT,
          threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        },
      ],
    });

    try {
      const aiRequest: GenerateContentRequest = {
        contents: [
          {
            role: "user",
            parts: [
              {
                // eslint-disable-next-line
                text: "List all food items on this image in JSON format; valid keys are item, amount_count, amount_unit, and category. amount_count shall contain the numeric Extract all food items on this image in JSON format; valid fields are item, amount_count, amount_unit, and category. Valid values for the field category are \"Vegetable\", \"Meat\", \"Fruit\", \"Diaries\", \"Seafood\", \"Egg\", \"Others\". amount_count shall contain the numeric value of the item in terms of amount_unit. Predict the expiry date of each item based on its information and put the information in the field suggested_expiry_date. Extract the data of the buy time of the product by choosing the date of the receipt and place them inside the buy_date field in each item. All dates shall be written in ISO 8601 format. Remove all non-food from the result. Translate all item field to English.",
              },
              {
                inline_data: {
                  mime_type: request.data.mime_type,
                  data: request.data.base64_image_data,
                },
              },
            ],
          },
        ],
      };

      const streamingResponse =
        await generativeModel.generateContent(aiRequest);

      return streamingResponse.response;
    } catch (e: any) {
      logger.error("Error happens when annotating image");
      throw new HttpsError("internal", e.message, e.details);
    }
  },
);

export const checkAndSendExpiringNotification = onSchedule("every hour", async (event) => {
  const firestore = new Firestore();
  const userCollectionSnapshot = await firestore.collection("users").get();

  for (const queryDoc of userCollectionSnapshot.docs) {
    const userId = queryDoc.id;
    const userItems = await firestore.collection(`users/${userId}/items`).get();

    const expiredToday = [];
    const expiredTomorrow = [];

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const tomorrow = new Date(today.getTime() + 86400000);

    for (const itemSnapshot of userItems.docs) {
      const itemObj = itemSnapshot.data();

      if (itemObj && itemObj.expiry_date) {
        const expiryDate = new Date(itemObj.expiry_date);

        if (expiryDate.getTime() >= today.getTime() && expiryDate.getTime() < tomorrow.getTime()) {
          expiredToday.push(itemObj);
        } else if (expiryDate.getTime() >= tomorrow.getTime() && expiryDate.getTime() < tomorrow.getTime() + 86400000) {
          expiredTomorrow.push(itemObj);
        }
      }
    }

    if (expiredToday.length > 0) {

    }

    if (expiredTomorrow.length > 0) {

    }
  }
});
