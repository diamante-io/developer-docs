# Securing Web-based Projects

Any application managing cryptocurrency is a frequent target of malicious actors and needs to follow security best practices. The below checklist offers guidance on the most common vulnerabilities. However, even if you follow every piece of advice, security is not guaranteed. Web security and malicious actors are constantly evolving, so it’s good to maintain a healthy amount of paranoia.

### SSL/TLS

Ensure that TLS is enabled. Redirect HTTP to HTTPS where necessary to ensure that Man in the Middle attacks can’t occur and sensitive data is securely transferred between the client and browser. Enable TLS and get an SSL certificate for free at [LetsEncrypt](https://letsencrypt.org/getting-started/).

If you don’t have SSL/TLS enabled, stop everything and do this first.

### Content security policy (CSP) headers

CSP headers tell the browser where it can download static resources from. For example, if you astralwallet.io and it requests a go file from myevilsite.com, your browser will block it unless it was whitelisted with CSP headers. You can read about how to implement CSP headers [here](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP).

Most web frameworks have a configuration file or extensions to specify your CSP policy, and the headers are auto-generated for you. For example, see [Helmet](https://www.npmjs.com/package/helmet) for Node.js. This would have prevented the [Blackwallet Hack](https://www.ccn.com/yet-another-crypto-wallet-hack-causes-users-lose-400000/).

### HTTP strict-transport-security headers

This is an HTTP header that tells the browser that all future connections to a particular site should use HTTPS. To implement this, add the header to your website. Some web frameworks (like Django) have this built-in. This would have prevented the MyEtherWallet DNS Hack.

### Storing sensitive data

Ideally, you don’t have to store much sensitive data. If you must, be sure to tread carefully. There are many strategies to store sensitive data:

- Ensure sensitive data is encrypted using a proven cipher like AES-256 and stored separately from application data. Always pick up AEAD mode.
- Any communication between the application server and secret server should be in a private network and/or authenticated via HMAC. Your cipher strategy will change based on whether you will be sending the ciphertext over the wire multiple times.
- Back up any encryption keys you may use offline and store them only in-memory in your app.
- Consult a good cryptographer and read up on best practices. Look into the documentation of your favorite web framework.
- Rolling your own crypto is a bad idea. Always use tried and tested libraries such as [NaCI](<https://en.wikipedia.org/wiki/NaCl_(software)>).

### Monitoring

- Attackers often need to spend time exploring your website for unexpected or overlooked behavior. Examining logs defensively can help you catch onto what they’re trying to achieve. You can at least block their IP or automate blocking based on suspicious behavior.

  It’s also worth setting up an error reporting (like [Sentry](https://sentry.io/welcome/)). Often, people trigger strange bugs when trying to hack things.

### Authentication weaknesses

You must build your authentication securely if you have logins for users. The best way to do this is to use something off the shelf. Both Ruby on Rails and Django have robust, built-in authentication schemes.

- Many JSON web token implementations are poorly done, so ensure the library you use is audited.
- Hash passwords with a time-tested scheme are good. And Balloon Hashing is also worth looking into.
- We strongly prefer 2FA and require U2F or [TOTP](https://datatracker.ietf.org/doc/html/rfc6238) 2FA for sensitive actions. 2FA is important as email accounts are usually not very secure. Having a second factor of authentication ensures that users who accidentally stay logged on or have their password guessed are still protected.
- Finally, require strong passwords. Common and short passwords can be brute-forced. Dropbox has a great open-source tool that gauges password strength fairly quickly, making it usable for user interactions.

### Denial of service attacks (DOS)

DOS attacks are usually accomplished by overloading your web servers with traffic. To mitigate this risk, rate limit traffic from IPs and browser fingerprints. Sometimes people will use proxies to bypass IP rate-limiting. In the end, malicious actors can always find ways to spoof their identity, so the surest way to block DOS attacks is to implement proof of work checks in your client or use a managed service like [Cloudflare](https://www.cloudflare.com/en-gb/ddos/).

### Lockdown unused ports

Attackers will often scan your ports to see if you were negligent and left any open. Services like Heroku do this for you- read about how to enable this on AWS.

### Phishing and social engineering

Phishing attacks will thwart any well-formed security infrastructure. Have clear policies published on your website and articulate them to users when they sign up (you will never ask for their password, etc.). Sign messages to your users and prompt users to check the website's domain they are on.

### Scan your website and libraries for vulnerabilities

Use a tool like Snyk to scan your third-party client libraries for vulnerabilities. Make sure to keep your third-party libraries up to date. Often, upgrades are triggered by security exploits. You can use Mozilla Observatory to check your HTTP security as well.

### Cross-Site Request Forgery Protection (CSRF), SQL injections

Most modern web and mobile frameworks handle both CSRF protection and SQL injections. Ensure CSRF protection is enabled and that you are using a database ORM instead of running raw SQL based on user input. For example, see what Ruby on Rails documentation says about SQL injections.
