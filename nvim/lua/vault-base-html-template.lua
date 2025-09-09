return [[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Vault</title>
  <style>
  * {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }
  </style>
</head>
<body style="
  background: #282828;
  color: #ebdbb2;
  font-family: 'SF Mono', 'Monaco', 'Cascadia Code', 'Roboto Mono', 'Consolas', 'Courier New', monospace;
  font-size: 14px;
  line-height: 1.4;
  padding: 16px;
  margin: 0;
  min-height: 100vh;
">

<div style="
  max-width: 800px;
  margin: 0 auto;
">

<!-- Navigation -->
<nav style="
  background: #3c3836;
  padding: 12px 16px;
  margin-bottom: 20px;
  border-radius: 4px;
  border-left: 4px solid #b8bb26;
">
  <a href="/Users/niilohlin/Vault/Home.md" style="
    color: #83a598;
    text-decoration: none;
    margin-right: 16px;
    font-weight: bold;
    padding: 8px 12px;
    background: #504945;
    border-radius: 3px;
    display: inline-block;
    transition: background-color 0.2s;
  "
  onmouseover="this.style.backgroundColor='#665c54'"
  onmouseout="this.style.backgroundColor='#504945'">
    📁 Home
  </a>

  <a href="/" style="
    color: #fabd2f;
    text-decoration: none;
    font-weight: bold;
    padding: 8px 12px;
    background: #504945;
    border-radius: 3px;
    display: inline-block;
    transition: background-color 0.2s;
  "
  onmouseover="this.style.backgroundColor='#665c54'"
  onmouseout="this.style.backgroundColor='#504945'">
    ✅ TODOs
  </a>

  <form action="/pull" method="POST">

  <button type="submit" style="
    color: #83a598;
    text-decoration: none;
    margin-right: 16px;
    font-weight: bold;
    padding: 8px 12px;
    background: #504945;
    border-radius: 3px;
    display: inline-block;
    transition: background-color 0.2s;
  "
  onmouseover="this.style.backgroundColor='#665c54'"
  onmouseout="this.style.backgroundColor='#504945'">
    ⬇️Pull
  </button>
  </form>
</nav>

<!-- Content -->
<main style="
  background: #32302f;
  padding: 20px;
  border-radius: 6px;
  border: 1px solid #504945;
  box-shadow: 0 2px 8px rgba(0,0,0,0.3);
">
%s
</main>

</div>

<style>
/* Links */
a {
  color: #83a598 !important;
  text-decoration: underline;
  transition: color 0.2s;
}

a:hover {
  color: #8ec07c !important;
}

a:visited {
  color: #d3869b !important;
}

/* Buttons */
button {
  background: #689d6a !important;
  color: #282828 !important;
  border: none !important;
  padding: 6px 12px !important;
  border-radius: 3px !important;
  font-family: inherit !important;
  font-size: 12px !important;
  font-weight: bold !important;
  cursor: pointer !important;
  margin-left: 8px !important;
  transition: background-color 0.2s !important;
}

button:hover {
  background: #8ec07c !important;
}

button:active {
  background: #b8bb26 !important;
}

/* Forms */
form {
  background: #3c3836 !important;
  padding: 12px !important;
  margin: 8px 0 !important;
  border-radius: 4px !important;
  border-left: 3px solid #fe8019 !important;
  display: flex !important;
  align-items: center !important;
  justify-content: space-between !important;
  flex-wrap: wrap !important;
}

/* Textareas */
textarea {
  background: #1d2021 !important;
  color: #ebdbb2 !important;
  border: 1px solid #504945 !important;
  padding: 12px !important;
  border-radius: 4px !important;
  font-family: inherit !important;
  font-size: 13px !important;
  width: 100%% !important;
  resize: vertical !important;
  margin-bottom: 12px !important;
}

textarea:focus {
  border-color: #83a598 !important;
  outline: none !important;
  box-shadow: 0 0 0 2px rgba(131, 165, 152, 0.2) !important;
}

/* Line breaks for spacing */
br {
  display: block !important;
  margin: 8px 0 !important;
  content: "" !important;
}

/* Mobile responsiveness */
@media (max-width: 600px) {
  body {
    padding: 12px !important;
    font-size: 13px !important;
  }

  nav {
    padding: 10px 12px !important;
  }

  nav a {
    display: block !important;
    margin: 4px 0 !important;
    margin-right: 0 !important;
    text-align: center !important;
  }

  main {
    padding: 16px !important;
  }

  form {
    flex-direction: column !important;
    align-items: stretch !important;
  }

  button {
    margin-left: 0 !important;
    margin-top: 8px !important;
    width: 100%% !important;
  }
}
</style>

</body>
</html>
]]
