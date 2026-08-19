as yet unclassified
gmScript
	^ 'document.getElementById("auth").addEventListener("submit", (e) => {
  e.preventDefault();
  console.log("secret entered:", document.getElementById("secret").value);
});'