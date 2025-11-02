(function () {
  const btn = document.getElementById('btn');
  const out = document.getElementById('out');
  const nameInput = document.getElementById('name');

  btn.addEventListener('click', async () => {
    const name = encodeURIComponent(nameInput.value || 'World');
    const apiUrl = (window.APP_CONFIG && window.APP_CONFIG.apiUrl) || '';
    try {
      const res = await fetch(`${apiUrl}/hello?name=${name}`, { method: 'GET' });
      const data = await res.json();
      out.textContent = JSON.stringify(data, null, 2);
    } catch (e) {
      out.textContent = 'Request failed: ' + e;
    }
  });
})();