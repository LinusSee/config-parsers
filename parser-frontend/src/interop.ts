import "./styles.css";

export function flags({ env }) {
    // Called before our Elm application starts
    return {
        token: JSON.parse(window.localStorage.token || null)
    }
}

export function onReady({ env, app }): void {
    // Called after our Elm application starts
    if (app.ports && app.ports.sendToLocalStorage) {
        app.ports.sendToLocalStorage.subscribe(({ key, value }) => {
            window.localStorage[key] = JSON.stringify(value)
        })
    }
}