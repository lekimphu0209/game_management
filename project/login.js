document.getElementById('loginForm').addEventListener('submit', async function (e) {


  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;

  const response = await fetch('/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({ email, password })
  });

  if (response.redirected) {
    window.location.href = response.url;
  } else {
    const text = await response.text();
    document.getElementById('userInfo').innerHTML = text;
  }
});
