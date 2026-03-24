function updateClock() {
    const now = new Date();
    document.getElementById('clock').innerText = now.toLocaleTimeString();
}

const hour = new Date().getHours();
const greeting = hour < 12 ? "Morning!" : hour < 18 ? "Afternoon!" : "Evening!";
document.getElementById('greeting').innerText = greeting + " Welcome to cloud server.";

setInterval(updateClock, 1000);
updateClock();