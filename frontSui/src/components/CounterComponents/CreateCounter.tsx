import { useState } from "react";

export function CreateCounter({}: { onCreated: (id: string) => void }) {
  const [buyerName, setBuyerName] = useState("");
  const [type, setType] = useState(""); // To track Forward, Option, or Pull Option selection
  const [effectiveDate, setEffectiveDate] = useState("");
  const [dueDate, setDueDate] = useState("");
  const [asset, setAsset] = useState("");
  const [exchangePrice, setExchangePrice] = useState("");
  const [premiumIdentifiant, setPremiumIdentifiant] = useState("");
  const [premiumAmount, setPremiumAmount] = useState("");
  const [paymentDate, setPaymentDate] = useState(""); // Payment date field
  const [error, setError] = useState(""); // To track validation errors

  const [forwardBoolean, setForwardBoolean] = useState(false);
  const [showPaymentDate, setShowPaymentDate] = useState(false);

  const handleSubmit = () => {
    if (
      !buyerName ||
      !type ||
      !effectiveDate ||
      !dueDate ||
      !asset ||
      !exchangePrice ||
      !premiumIdentifiant ||
      !premiumAmount ||
      (forwardBoolean && !paymentDate) // Payment date is mandatory for "Forward"
    ) {
      setError("Please fill in all required fields.");
      return;
    }

    if (type === "Forward" && (!effectiveDate || !dueDate)) {
      setError("Please provide both effective and due dates for Forward type.");
      return;
    }

    create();
  };

  return (
    <div className="max-w-md mx-auto p-4 mt-20">
      {/* Buyer Info */}
      <div className="mb-4">
        <label>Buyer’s account</label>
        <input
          type="text"
          className="input input-primary w-full mb-2"
          placeholder="Buyer’s Address"
          value={buyerName}
          onChange={(e) => setBuyerName(e.target.value)}
        />
      </div>

      {/* Type Selection */}
      <div className="mb-4">
        <label>Choose Type:</label>
        <div className="flex space-x-4">
          <button
            className={`btn ${type === "Forward" ? "btn-primary" : "btn-secondary"}`}
            onClick={() => {
              setType("Forward");
              setShowPaymentDate(true);
              setForwardBoolean(true); // Set forwardBoolean to true when Forward is selected
            }}
          >
            Forward
          </button>
          <button
            className={`btn ${type === "Option" ? "btn-primary" : "btn-secondary"}`}
            onClick={() => {
              setType("Option");
              setShowPaymentDate(false);
              setForwardBoolean(false); // Set forwardBoolean to false when Option is selected
            }}
          >
            Call Option
          </button>
          <button
            className={`btn ${type === "Pull Option" ? "btn-primary" : "btn-secondary"}`}
            onClick={() => {
              setType("Pull Option");
              setShowPaymentDate(false);
              setForwardBoolean(false); // Set forwardBoolean to false when Pull Option is selected
            }}
          >
            Pull Option
          </button>
        </div>
      </div>

      {/* Conditionally show fields for Forward */}
      {forwardBoolean && (
        <div className="mb-4">
          <label>Effective Date :</label>
          <input
            type="text"
            className="input input-primary w-full mb-2"
            placeholder="Enter effective date"
            value={effectiveDate}
            onChange={(e) => setEffectiveDate(e.target.value)}
          />
          <label>Due Date :</label>
          <input
            type="text"
            className="input input-primary w-full mb-2"
            placeholder="Enter due date"
            value={dueDate}
            onChange={(e) => setDueDate(e.target.value)}
          />

          {/* Payment Date Section */}
          {showPaymentDate && (
            <div className="mb-4">
              <label>Payment Date:</label>
              <input
                type="text"
                className="input input-primary w-full"
                placeholder="Enter payment date"
                value={paymentDate}
                onChange={(e) => setPaymentDate(e.target.value)}
              />
            </div>
          )}
        </div>
      )}

      {/* Conditionally show fields for Option or Pull Option */}
      {!forwardBoolean && (type === "Option" || type === "Pull Option") && (
        <div className="mb-4">
          <label>Effective Date:</label>
          <input
            type="text"
            className="input input-primary w-full mb-2"
            placeholder="Enter effective date"
            value={effectiveDate}
            onChange={(e) => setEffectiveDate(e.target.value)}
          />
          <label>Due Date</label>
          <input
            type="text"
            className="input input-primary w-full"
            placeholder="Enter due date"
            value={dueDate}
            onChange={(e) => setDueDate(e.target.value)}
          />
        </div>
      )}

      {/* Underlying Asset */}
      <div className="mb-4">
        <label>Underlying Asset:</label>
        <input
          type="text"
          className="input input-primary w-full"
          placeholder="Specify the asset"
          value={asset}
          onChange={(e) => setAsset(e.target.value)}
        />
      </div>

      {/* Asset Future Exchange Price */}
      <div className="mb-4">
        <label>Asset Price:</label>
        <input
          type="text"
          className="input input-primary w-full"
          placeholder="Set the price"
          value={exchangePrice}
          onChange={(e) => setExchangePrice(e.target.value)}
        />
        <input
          type="text"
          className="input input-primary w-full"
          placeholder="Amount"
          value={premiumAmount}
          onChange={(e) => setPremiumAmount(e.target.value)}
        />
      </div>

      {/* Premium Section */}
      <div className="mb-4">
        <label>Premium:</label>
        <input
          type="text"
          className="input input-primary w-full mb-2"
          placeholder="Price"
          value={premiumIdentifiant}
          onChange={(e) => setPremiumIdentifiant(e.target.value)}
        />
      </div>

      {/* Error Message */}
      {error && <div className="text-red-500 text-sm mb-4">{error}</div>}

      {/* Submit button */}
      <button className="btn btn-primary mt-4" onClick={handleSubmit}>
        Submit
      </button>
    </div>
  );

  function create() {
    document.body.innerHTML =
      '<div class="text-center text-4xl font-bold">Form Submitted</div>';

    history.pushState(null, "", "/form-submitted");

    window.addEventListener("popstate", function () {
      window.location.href = "/";
    });
  }
}
