import { apiInitializer } from "discourse/lib/api";

export default apiInitializer(() => {
  // This mirrors the official component's public marker for the test contract.
  document.body.classList.add("full-width-enabled");
});
