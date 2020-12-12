// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// connect if there are any LiveViews on the page
liveSocket.connect()

document.querySelectorAll(".copyable").forEach(element => {
    let hint = document.querySelector(".hint");
    let copyButton = document.querySelector("#copy");

    function copyToClipboard() {
        window.getSelection().selectAllChildren(element);
        document.execCommand("copy");
        hint.textContent = "Copied!";
        hint.className = 'hint success';
        window.getSelection().removeAllRanges();
    }

    if (copyButton) {
        copyButton.addEventListener('click', () => {
            copyToClipboard();
        })
    }

    document.addEventListener('keydown', function(e) {
        if (e.key == 'c' && !e.metaKey && !e.shiftKey && !e.altKey && !e.ctrlKey) {
            copyToClipboard();
        }
    })
});

let secretTextInput = document.getElementById("secret");

if (secretTextInput) {
    secretTextInput.addEventListener('keydown', function(e) {
        if (e.keyCode == 13 && e.metaKey) {
            this.form.submit();
        }
    })
}
