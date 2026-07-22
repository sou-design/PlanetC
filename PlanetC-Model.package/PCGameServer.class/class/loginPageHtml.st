as yet unclassified
loginPageHtml
	^ '<!doctype html>
<html lang="en">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>PlanetC Player</title>
<link rel="stylesheet" href="/style.css">

<h1>Choose your name to join</h1>
<form id="login">
  <input id="name" type="text" placeholder="e.g. alice" required minlength="2" maxlength="24" />
  <button type="submit">Join</button>
</form>
<div id="msg"></div>
<pre id="log" hidden></pre>

<script src="/app.js"></script>
</html>'