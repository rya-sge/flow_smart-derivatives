import { Transaction } from "@mysten/sui/transactions";
import { useSuiClient } from "@mysten/dapp-kit";

// Service pour créer un trade sur la blockchain Sui
export async function createTrade(
  suiClient,
  signAndExecute,
  {
    buyerName,
    type,
    effectiveDate,
    dueDate,
    asset,
    exchangePrice,
    premiumAmount,
  },
) {
  const tx = new Transaction();

  // Construire la transaction avec les arguments du formulaire
  tx.moveCall({
    target: 0xf4c93f962fdf24a9212e08e412a6eaad92076bd928c82b427db162445efc5b12
      ::counter::createTrade,
    arguments: [
      buyerName,
      asset,
      exchangePrice,
      premiumAmount,
      forwardBoolean,
      effectiveDate,
      dueDate,
      "@0x6",
    ],
  });

  // Exécuter la transaction
  return await signAndExecute(
    { transaction: tx },
    {
      onSuccess: (result) => {
        const objectId = result.effects?.created?.[0]?.reference?.objectId;
        console.log("Transaction succeeded", objectId);
        return objectId;
      },
      onError: (error) => {
        console.error("Transaction failed", error);
        throw error;
      },
    },
  );
}
