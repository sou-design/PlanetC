as yet unclassified
gmPageHtml
	^ '<!DOCTYPE html>
<html>
<head><title>Game Master</title></head>
<body>
<h1>Game Master Control</h1>
<form id="auth">
  <input type="password" id="secret" placeholder="Secret key" />
  <button type="submit">Enter</button>
</form>
<div id="controls" style="display:none">
  <p>Authenticated. Controls coming soon.</p>
</div>
<script src="/gm.js"></script>
</body>
</html>'