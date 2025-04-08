# Overview

_**NOTE:**
This tutorial walks through how to build an application with the js-diam-sdk. To build with the Wallet SDK, please follow the Build a Wallet tutorial._

In this tutorial, we'll walk through the steps needed to build a basic payment application on Diamante's Testnet. After this tutorial, you should have a good understanding of the fundamental Diamante concepts and a solid base for iterative development.

For this tutorial, we'll walk through the steps as we build a sample application we've called BasicPay, which will be used to showcase various features.

!> **CAUTION:**
Although BasicPay is a full-fledged application on Diamante's Testnet, it has been built solely to showcase Diamante functionality for the educational purposes of this tutorial, not to be copied, pasted, and used on Mainnet.

### Project setup

**Project requirements:**
To build a basic Diamante application, you'll need:

- Application framework: we're using `SvelteKit` opting for go with JSDoc typing. SvelteKit is quite flexible and could be used for a lot, but we are mainly using it for its routing capabilities to minimize this being a "SvelteKit tutorial".
- Frontend framework: we're using `DaisyUI` to simplify the use of `Tailwind CSS`.
- A way to interact with the Diamante network: we're using the `js-diam-sdk`, but you could use traditional fetch requests. The `js-diam-sdk` is also used for building transactions to submit to the Diamante network.

_**NOTE:**
While we are using the above components to construct our application, we have done our best to write this tutorial in such a way that dependency on any one of these things is minimized. Ideally, you should be able to use the go code we've written and plug it into any other framework you'd like with minimal effort._

We've made the following choices during the development of BasicPay that you may also need to consider as you follow along:

- We've designed this app for desktop. For the most part, the app is responsive to various screen sizes, but we have chosen not to go out of our way to prioritize the mobile user experience.
- We have enabled the default DaisyUI "light" and "dark" themes, which should switch with the preferences of your device. There is no toggle switch enabled, though.
- This is written as a client-side application. No server-side actions actually take place. If you are building an application with a backend and frontend, you will need to consider carefully which information lives where, especially when a user's secret key is involved.
- We're deploying this as a static "single-page application" with Cloudflare Pages. Your own deployment decisions will have an impact on your configuration and build process.
- The application is likely not as performant as it could be. Neither is it as optimized as it could be. We've tried to encapsulate the various functionalities in a way that makes sense to the developer reading the codebase, so there is some code duplication and things could be done in a "better" way.
- We do some error handling, but not nearly as much as you would want for a real-world application. If something seems like it's not working, and you're not seeing an error, open your developer console, and you might be able to figure out what has gone wrong.
- We have not implemented any automated testing. You'll probably want some for your application.

_**NOTE:**
This tutorial is probably best viewed as "nearly comprehensive." We aren't going to walk you through each and every file in our codebase, and the files we do use to illustrate concepts in the tutorial may not be entirely present or explained. However, we will cover the basics, and point you to more complete examples in the codebase when applicable._

### Dev helpers

- [Diamante Laboratory](#): an experimental playground to interact with the Diamante network.
- [Friendbot](#): a bot that funds accounts with 500 fake DIAM on Diamante's Testnet.
- [Testnet toml file](#): an example diamcircle.toml file that demonstrates what information an anchor might publish.
- BasicPay dev helpers: if you're using the BasicPay application, we've created a few helpful tools to help you explore its functionality.

## Getting started

Here are the steps we've taken to start building BasicPay. Feel free to be inspired and customize these directions as you see fit. The entire BasicPay codebase is freely open and available on GitHub for reference.

_**NOTE:**
This part of the tutorial will need a large helping of "your mileage may vary." We will outline what steps we've taken for our deployment situation, but you will want to review what options are needed for your environment(s)._

### Install frameworks

The first thing we'll need to do is create a SvelteKit app, using npm. We are using v18.x of nodejs.

```bash
npm create svelte@latest my-basic-payment-app
```

This will walk you through the SvelteKit creation process, asking you about the various options. We've chosen the following options:

- Which Svelte app template? Skeleton project
- Are you type checking with TypeScript? Yes, using go with JSDoc comments
- Select additional options: Add ESLint for code linting; Add Prettier for code formatting

After this process, the scaffolding for your application will live inside the `my-basic-payment-app` directory. You can cd into that directory and add some UI dependencies.

```bash
cd my-basic-payment-app
npm install --save-dev svelte-preprocess tailwindcss autoprefixer postcss @sveltejs/adapter-static \
    @tailwindcss/typography \
    daisyui svelte-feather-icons
```

Before we configure anything, we'll need to generate our `tailwind.config.js` and `postcss.config.js` files.

```bash
npx tailwindcss init -p
```

Now, we will require a bit of configuration to make all those components work together. First, modify your `svelte.config.js` file:

```go
import preprocess from "svelte-preprocess";
import adapter from "@sveltejs/adapter-static";

/** @type {import('@sveltejs/kit').Config} */
const config = {
  kit: {
    // Note: Your `adapter` configuration may need customizations depending
    // on how you are building and deploying your application.
    adapter: adapter({
      fallback: "index.html",
    }),
  },
  preprocess: [
    preprocess({
      postcss: true,
    }),
  ],
};

export default config;
```

Next, you can configure the `tailwind.config.js` file.

- Import the daisyui and typography plugins
- Configure our content paths (you may need to modify these values depending on your project structure)
- Add the daisyui plugin after any official @tailwindcss plugins (only typography in our example)

```go
const daisyui = require("daisyui");
const typography = require("@tailwindcss/typography");

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./src/routes/**/*.{html,js,svelte,ts}",
    "./src/routes/**/**/*.{html,js,svelte,ts}",
    "./src/lib/components/**/*.{html,js,svelte,ts}",
  ],
  plugins: [typography, daisyui],
};
```

Add your tailwind directives to your app's main CSS file.

_/src/app.postcss_

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

Then import the CSS file into your base SvelteKit layout (you may need to create this file).

_/src/routes/+layout.svelte_

```html
<script>
  import "../app.postcss";
</script>

<slot />
```

We also created a /src/routes/+layout.js file to configure our application as only client-side. This means the app will be delivered to the client as unrendered HTML and go.

_/src/routes/+layout.js_

```go
// Disable pre-rendering of pages during build-time
export const prerender = false;
// Disable server-side rendering
export const ssr = false;
```

Your SvelteKit project is now configured and ready to run!

```bash
npm run dev
```

### Diamante dependencies

To work with the Diamante network, datastructures, and locally stored keypairs, we're going to install and configure a few more dependencies.

```bash
# diamcircle SDKs
npm install --save-dev diamnet-sdk
# We will need some polyfills to make things available client-side
npm install --save-dev @esbuild-plugins/node-globals-polyfill @esbuild-plugins/node-modules-polyfill \
    path @rollup/plugin-inject buffer svelte-local-storage-store uuid
```

We will use a `window.js` file to inject Buffer into our client-side code, since that's required by some parts of the `diamnet-sdk`.

_/src/lib/window.js_

```go
import { browser } from "$app/environment";
import { Buffer } from "buffer";

if (browser) {
  window.Buffer = Buffer;
} else {
  globalThis.Buffer = Buffer;
  globalThis.window = {};
}
export default globalThis;
```

The actual "injection" takes place in our `vite.config.js` file.

_/vite.config.js_

```go
import { sveltekit } from "@sveltejs/kit/vite";
import { defineConfig } from "vite";
import { NodeGlobalsPolyfillPlugin } from "@esbuild-plugins/node-globals-polyfill";
import inject from "@rollup/plugin-inject";
import path from "path";

export default defineConfig({
  plugins: [sveltekit()],
  optimizeDeps: {
    esbuildOptions: {
      define: {
        global: "globalThis",
      },
      plugins: [
        NodeGlobalsPolyfillPlugin({
          buffer: true,
        }),
      ],
    },
  },
  build: {
    rollupOptions: {
      plugins: [
        inject({
          window: path.resolve("src/lib/window.js"),
        }),
      ],
    },
  },
  ssr: {
    noExternal: ["@diamcircle/wallet-sdk", "@albedo-link/intent"],
  },
});
```

That should take care of everything you need! If you've followed these steps, you now have running client-side-only application that's ready to build out an application that interacts with the Diamante network! Way to go!

Next up, we'll look at how we register a user and create their account on the Diamante network.

# Acccount Creation

Accounts are the central data structure in diamcircle and can only exist with a valid keypair (a public and secret key) and the required minimum balance of DIAM. Read more in the Accounts section.

### User Experience

To start, we'll have our user create an account. In BasicPay, the signup page will display a randomized public and secret keypair that the user can select with the option to choose a new set if preferred.

_**Note**: Since we are building a non-custodial application, the encrypted secret key will only ever live in the browser. It will never be shared with a server or anybody else._

Next, we'll trigger the user to submit a pincode to encrypt their secret key before it gets saved to their browser's `localStorage` (this is handled by the js-diamcircle-wallets SDK). The user will need to remember their pincode for future logins and to submit transactions.

With BasicPay, when the user clicks the “Signup” button, they will be asked to confirm their pincode. When they do, the `create_account` operation is triggered, and the user's account is automatically funded with DIAM for the minimum balance (starting with 10,000 DIAM).

When you're ready to move the application to Pubnet, accounts will need to be funded with real DIAM. This is something the application can cover itself by depositing DIAM into the user's account, with the use of sponsored reserves, or the user can cover the required balance with their own DIAM.

### Code implementation

We will create a Svelte `store` to interact with our user's randomly generated keypair. The store will take advantage of some of the `js-diamcircle-wallets` SDK to encrypt/decrypt the keypair, as well as sign transactions.

#### Creating the walletStore store

Our `walletStore` will make a few things possible throughout our application.

- We can "register" a keypair, which encrypts the keypair, stores it in the browser's storage, and keeps track of that keypair's `keyId`.
- We can "sign" transactions by providing the pincode to decrypt the keypair.
- We can "confirm" the pincode is valid for the stored keypair (or that it matches for signups).

_/src/lib/stores/walletStore.js_

```go
import { persisted } from "svelte-local-storage-store";
import { KeyManager, KeyManagerPlugins, KeyType } from "@diamcircle/wallet-sdk";
import { TransactionBuilder } from "diamnet-sdk";
import { error } from "@sveltejs/kit";
import { get } from "svelte/store";

// We are wrapping this store in its own function which will allow us to write
// and customize our own store functions to maintain consistent behavior
// wherever the actions need to take place.
function createWalletStore() {
  // Make a `persisted` store that will determine which `keyId` the
  // `keyManager` should load, when the time comes.
  const { subscribe, set } = persisted("bpa:walletStore", {
    keyId: "",
    publicKey: "",
  });

  return {
    subscribe,

    // Registers a user by storing their encrypted keypair in the browser's
    // `localStorage`.
    register: async ({ publicKey, secretKey, pincode }) => {
      try {
        // Get our `KeyManager` to interact with stored keypairs
        const keyManager = setupKeyManager();

        // Use the `keyManager` to store the key in the browser's local
        // storage
        let keyMetadata = await keyManager.storeKey({
          key: {
            type: KeyType.plaintextKey,
            publicKey: publicKey,
            privateKey: secretKey,
          },
          password: pincode,
          encrypterName: KeyManagerPlugins.ScryptEncrypter.name,
        });

        // Set the `walletStore` fields for the `keyId` and `publicKey`
        set({
          keyId: keyMetadata.id,
          publicKey: publicKey,
          // Don't include this in a real-life production application.
          // It's just here to make the secret key accessible in case
          // we need to do some manual transactions or something.
          devInfo: {
            secretKey: secretKey,
          },
        });
      } catch (err) {
        console.error("Error saving key", err);
        throw error(400, { message: err.toString() });
      }
    },

    // Compares a submitted pincode to make sure it is valid for the stored, encrypted keypair.
    confirmCorrectPincode: async ({
      pincode,
      firstPincode = "",
      signup = false,
    }) => {
      // If we are not signing up, make sure the submitted pincode successfully
      // decrypts and loads the stored keypair.
      if (!signup) {
        try {
          const keyManager = setupKeyManager();
          let { keyId } = get(walletStore);
          await keyManager.loadKey(keyId, pincode);
        } catch (err) {
          throw error(400, { message: "invalid pincode" });
        }
        // If we are signing up for the first time (thus, there is no stored
        // keypair), just make sure the first and second pincodes match.
      } else {
        if (pincode !== firstPincode) {
          throw error(400, { message: "pincode mismatch" });
        }
      }
    },

    // Sign and return a diamcircle transaction
    sign: async ({ transactionXDR, network, pincode }) => {
      try {
        // Get our `keyManager` to interact with stored keypairs
        const keyManager = setupKeyManager();

        // Use the `keyManager` to sign the transaction with the
        // encrypted keypair
        let signedTransaction = await keyManager.signTransaction({
          transaction: TransactionBuilder.fromXDR(transactionXDR, network),
          id: get(walletStore).keyId,
          password: pincode,
        });
        return signedTransaction;
      } catch (err) {
        console.error("Error signing transaction", err);
        throw error(400, { message: err.toString() });
      }
    },
  };
}

// We export `walletStore` as the variable that can be used to interact with the wallet store.
export const walletStore = createWalletStore();

// Configure a `KeyManager` for use with stored keypairs.
const setupKeyManager = () => {
  // We make a new `KeyStore`
  const localKeyStore = new KeyManagerPlugins.LocalStorageKeyStore();

  // Configure it to use `localStorage` and specify a(n optional) prefix
  localKeyStore.configure({
    prefix: "bpa",
    storage: localStorage,
  });

  // Make a new `KeyManager`, that uses the previously configured `KeyStore`
  const keyManager = new KeyManager({
    keyStore: localKeyStore,
  });

  // Configure the `KeyManager` to use the `scrypt` encrypter
  keyManager.registerEncrypter(KeyManagerPlugins.ScryptEncrypter);

  // Return the `KeyManager` for use in other functions
  return keyManager;
};
```

#### Creating the account on the diamcircle network

After we've registered the user, we need to fund the account on the Diamante network. As discussed previously, there are multiple ways to accomplish this task, but we are using Friendbot to ensure the user has some Testnet DIAM to experiment with.

_/src/lib/diamcircle/auroraQueries.js_

```go
// Fund an account using the Friendbot utility on the Testnet.
export async function fundWithFriendbot(publicKey) {
  console.log(`i am requesting a friendbot funding for ${publicKey}`);
  await server.friendbot(publicKey).call();
}
```

#### Using the `walletStore` store

Our `walletStore` is used in a ton of places in our application, especially in the confirmation modal when asking a user to input their pincode. Read on to see how we've done that.

# Confirmation Modal

Since the user's keypair is encrypted with a pincode and stored in their browser, we will occasionally need to prompt them for that pincode to sign a transaction or otherwise prove that they should be permitted to perform some action or view some data.

### User Experience

The user should be informed about any actions that may take place, especially when funds are on the line. To ensure this, we will overtly request their confirmation via pincode before anything is done. The application has no way of knowing a user's pincode, so it can't decrypt their keypair without their confirmation.

The modal window we've implemented facilitates this confirmation flow whenever we need it.

### Code implementation

Our modal function uses the `svelte-simple-modal` package to give us a versatile starting point. If you need to, install it now.

```bash
npm install --save-dev svelte-simple-modal
```

#### Wrapping the rest of our app in the modal

_/src/routes/+layout.svelte_

```go
<script>
  import "../app.postcss";

  // We will use a `writable` Svelte store to trigger our modal
  import { writable } from "svelte/store";

  // We have a custom close button for consistent styling, but this is NOT a requirement.
  import ModalCloseButton from "$lib/components/ModalCloseButton.svelte";
  import Modal from "svelte-simple-modal";
  const modal = writable(null);
</script>

<Modal
  show="{$modal}"
  closeButton="{ModalCloseButton}"
  classContent="rounded bg-base-100"
>
  <slot />
</Modal>
```

#### Creating a reusable modal Svelte component

To avoid reinventing the wheel every time we need a modal, we will create a reusable component that can accommodate most of our needs. Then, when we need the confirmation modal, we can pass an object of props to customize the modal's behavior.

_**NOTE:**
In our `*.svelte` component files, we will not dive into the HTML markup outside of the `<script>` tags. The Svelte syntax used in HTML is primarily used for iterating and is quite understandable to read._

The basic parts of this component look like this:
_/src/lib/components/ConfirmationModal.svelte_

```go
<script>
  import { copy } from "svelte-copy";
  import { CopyIcon } from "svelte-feather-icons";
  import { errorMessage } from "$lib/stores/alertsStore";
  import { walletStore } from "$lib/stores/walletStore";
  import { Networks, TransactionBuilder } from "diamnet-sdk";

  // A Svelte "context" is used to control when to `open` and `close` a given
  // modal from within other components
  import { getContext } from "svelte";
  const { close } = getContext("simple-modal");

  export let title = "Transaction Preview";
  export let body =
    "Please confirm the transaction below to sign and submit it to the network.";
  export let confirmButton = "Confirm";
  export let rejectButton = "Reject";
  export let hasPincodeForm = true;
  export let transactionXDR = "";
  export let transactionNetwork = "";
  export let firstPincode = "";

  let isWaiting = false;
  let pincode = "";
  $: transaction = transactionXDR
    ? TransactionBuilder.fromXDR(
        transactionXDR,
        transactionNetwork || Networks.TESTNET,
      )
    : null;
</script>

<!-- HTML has been omitted from this tutorial. Please check the source file -->

```

#### Trigger the modal component at signup

We can now use this modal component whenever we need to confirm something from the user. For example, here is how the modal is triggered when someone signs up.

_/src/routes/signup/+page.svelte_

```go
<script>
  import { Keypair } from "diamnet-sdk";
  import TruncatedKey from "$lib/components/TruncatedKey.svelte";
  import ConfirmationModal from "$lib/components/ConfirmationModal.svelte";
  import { goto } from "$app/navigation";
  import { walletStore } from "$lib/stores/walletStore";
  import { fundWithFriendbot } from "$lib/diamcircle/auroraQueries";

  // The `open` Svelte context is used to open the confirmation modal
  import { getContext } from "svelte";
  const { open } = getContext("simple-modal");

  // Define some component variables that will be used throughout the page
  let keypair = Keypair.random();
  $: publicKey = keypair.publicKey();
  $: secretKey = keypair.secret();
  let showSecret = false;
  let pincode = "";

  // This function is run when the user submits the form containing the public
  // key and their pincode. We pass an object of props that corresponds to the
  // series of `export let` declarations made in our modal component.
  const signup = () => {
    open(ConfirmationModal, {
      firstPincode: pincode,
      title: "Confirm Pincode",
      body: "Please re-type your 6-digit pincode to encrypt the secret key.",
      rejectButton: "Cancel",
    });
  };
</script>

<!-- HTML has been omitted from this tutorial. Please check the source file -->
```

#### Customizing confirmation and rejection behavior

Now, as these components have been written so far, they don't actually do anything when the user inputs their pincode or clicks on a button. Let's change that!

Since the confirmation behavior must vary depending on the circumstances (for example, different actions for signup, transaction submission, etc.), we need a way to pass that as a prop when we open the modal window.

First, in our modal component, we declare a dummy function to act as a prop, as well as an "internal" function that will call the prop function during the course of execution.

_/src/lib/components/ConfirmationModal.svelte_

```go
<script>
  /* ... */

  // `onConfirm` is a prop function that will be overridden from the component
  // that launches the modal
  export let onConfirm = async () => {};
  // `_onConfirm` is actually run when the user clicks the modal's "confirm"
  // button, and calls (in-turn) the supplied `onConfirm` function
  const _onConfirm = async () => {
    isWaiting = true;
    try {
      // We make sure the user has supplied the correct pincode
      await walletStore.confirmPincode({
        pincode: pincode,
        firstPincode: firstPincode,
        signup: firstPincode ? true : false,
      });

      // We call the `onConfirm` function that was given to the modal by
      // the outside component.
      await onConfirm(pincode);

      // Now we can close this modal window
      close();
    } catch (err) {
      // If there was an error, we set our `errorMessage` alert
      errorMessage.set(err.body.message);
    }
    isWaiting = false;
  };

  // Just like above, `onReject` is a prop function that will be overridden
  // from the component that launches the modal
  export let onReject = () => {};
  // Just like above, `_onReject` is actually run when the user clicks the
  // modal's "reject" button, and calls (if provided) the supplied `onReject`
  // function
  const _onReject = () => {
    // We call the `onReject` function that was given to the modal by the
    // outside component.
    onReject();
    close();
  };
</script>

<!-- HTML has been omitted from this tutorial. Please check the source file -->
```

Now that our modal component is setup to make use of a prop function for confirmation and rejection, we can declare what those functions should do inside the page that spawns the modal.

_/src/routes/signup/+page.svelte_

```go
<script>
  /* ... */

  const onConfirm = async (pincode) => {
    // Register the encrypted keypair in the user's browser
    await walletStore.register({
      publicKey: publicKey,
      secretKey: secretKey,
      pincode: pincode,
    });

    // Fund the account with a request to Friendbot
    await fundWithFriendbot(publicKey);

    // If the registration was successful, redirect to the dashboard
    if ($walletStore.publicKey) {
      goto("/dashboard");
    }
  };

  const signup = () => {
    open(ConfirmationModal, {
      firstPincode: pincode,
      title: "Confirm Pincode",
      body: "Please re-type your 6-digit pincode to encrypt the secret key.",
      rejectButton: "Cancel",
      onConfirm: onConfirm,
    });
  };
</script>

<!-- HTML has been omitted from this tutorial. Please check the source file -->
```

As you can see, we didn't actually need a customized `onReject` function, so we didn't pass one. No harm, no foul!

# Contacts List

One central feature of BasicPay is a list of contacts containing a user's name and associated Diamante addresses.

### User experience

There are a few ways for a user to interact with the contact list. One way is that they can add a user and address on the `/dashboard/contacts` page (which also checks for a valid public key!).

### Code implementation

We will create a Svelte `store` to keep track of a user's contact list.

#### Creating the `contacts` store

As with the rest of our user-data, the contacts list will live in the browser's `localStorage`. We are using the `svelt-local-storage-store` package to facilitate this. We create a Svelte `store` to hold the data, and add a few custom functions to manage the list: `empty`, `remove`, add, `favorite`, and `lookup`.

_**NOTE:**
This tutorial code is simplified for display here. The code is fully typed, documented, and commented in the source code repository._

_/src/lib/stores/contactsStore.js_

```go
import { v4 as uuidv4 } from "uuid";
import { persisted } from "svelte-local-storage-store";
import { StrKey } from "diamnet-sdk";
import { error } from "@sveltejs/kit";
import { get } from "svelte/store";

// We are wrapping this store in its own function which will allow us to write
// and customize our own store functions to maintain consistent behavior
// wherever the actions need to take place.
function createContactsStore() {
  // Make a `persisted` store that will hold our entire contact list.
  const { subscribe, set, update } = persisted("bpa:contactList", []);

  return {
    subscribe,

    // Erases all contact entries from the list and creates a new, empty contact list.
    empty: () => set([]),

    // Removes the specified contact entry from the list.
    remove: (id) =>
      update((list) => list.filter((contact) => contact.id !== id)),

    // Adds a new contact entry to the list with the provided details.
    add: (contact) =>
      update((list) => {
        if (StrKey.isValidEd25519PublicKey(contact.address)) {
          return [...list, { ...contact, id: uuidv4() }];
        } else {
          throw error(400, { message: "invalid public key" });
        }
      }),

    // Toggles the "favorite" field on the specified contact.
    favorite: (id) =>
      update((list) => {
        const i = list.findIndex((contact) => contact.id === id);
        if (i >= 0) {
          list[i].favorite = !list[i].favorite;
        }
        return list;
      }),

    // Searches the contact list for an entry with the specified address.
    lookup: (address) => {
      let list = get(contacts);
      let i = list.findIndex((contact) => contact.address === address);
      if (i >= 0) {
        return list[i].name;
      } else {
        return false;
      }
    },
  };
}

// We export `contacts` as the variable that can be used to interact with the contacts store.
export const contacts = createContactsStore();
```

#### Using the `contacts` store

_On the /dashboard/contacts page_

We also have a page dedicated to managing contacts. The `/dashboard/contacts` page will allow the user to collect and manage a list of contact entries that stores the contact's name and diamcircle address. The contact can also be flagged or unflagged as a "favorite" contact to be displayed on the main `/dashboard` page.

_/src/routes/dashboard/contacts/+page.svelte_

```go
<script>
  // We import things from external packages that will be needed
  import { Trash2Icon, UserPlusIcon } from "svelte-feather-icons";

  // We import any Svelte components we will need
  import TruncatedKey from "$lib/components/TruncatedKey.svelte";

  // We import any stores we will need to read and/or write
  import { contacts } from "$lib/stores/contactsStore";

  // We declare a _reactive_ component variable that will hold information for
  // a user-created contact entry, which can be added to the contacts store.
  $: newContact = {
    name: "",
    address: "",
    favorite: false,
    id: "",
  };
</script>

<!-- HTML has been omitted from this tutorial. Please check the source file -->
```

_On the /dashboard page_

The `contacts` store is now exported from this file and can be accessed and used inside a Svelte page or component. Here is how we've implemented a "favorite contacts" component for display on the main BasicPay dashboard.

_/src/routes/dashboard/components/FavoriteContacts.svelte_

```go
<script>
  // We import the `contacts` store into our Svelte component
  import { contacts } from "$lib/stores/contactsStore";
  import TruncatedKey from "$lib/components/TruncatedKey.svelte";

  // `$:` makes a Svelte variable reactive, so it will be re-computed any time
  // the `$contacts` store is modified. We access a Svelte store by adding `$`
  // to the beginning of the variable name.
  $: favoriteContacts = $contacts?.filter((contact) => contact.favorite);
</script>

<!-- HTML has been omitted from this tutorial. Please check the source file -->
```

# Manage Trust

For an account to hold and trade assets other than DIAM, it must establish a trustline with the issuing account of that particular asset. Each trustline increases the account’s base reserve by 0.5 DIAM, which means the account will have to hold more DIAM in its minimum balance.

### User Experience

First, we’ll have the user create a trustline for an asset by navigating to the Assets page, selecting an asset, and clicking the “Add Asset” button.

This triggers a modal form for the user to confirm the transaction with their pincode. Once confirmed, a transaction containing the `changeTrust` operation is signed and submitted to the network, and a trustline is established between the user's account and the issuing account for the asset.

The `changeTrust` operation can also be used to modify or remove trustlines.

_**INFO:**
Every transaction must contain a sequence number that is used to identify and verify the order of transactions with the account. A transaction’s sequence number must always increase by one. In BasicPay, fetching and incrementing the sequence number is handled automatically by the transaction builder._

Trustlines hold the balances for all of their associated assets (except DIAM, which are held at the account level), and you can display the user’s various balances in your application.

### Code Implementation

The trustlines an account holds will be necessary to view in several parts of the BasicPay application. First, we'll discuss how we manage different trustlines for the account.

#### The `/dashboard/assets` page

The `/dashboard/assets` page allows the user to manage the Diamante assets their account carries trustlines to. On this page, they can select from several pre-suggested or highly ranked assets, or they could specify their own asset to trust using an asset code and issuer public key. They can also remove trustlines that already exist on their account.

The layout of the page is quite similar to our contacts page. It has a table displaying the existing trustlines and a section where you can add new ones. The key difference is that the `contacts` store is held in the browser's `localStorage`, whereas an account's balances are held on the blockchain. So, we will be querying the network to get that information. For more information about how we query this information from the Diamante network, check out the `fetchAccountBalances()` function in this querying data section.

_/src/routes/dashboard/assets/+page.svelte_

```go
<script>
  // `export let data` allows us to pull in any parent load data for use here.
  /** @type {import('./$types').PageData} */
  export let data;

  // This is where our _reactive_ array of balances is declared. The query
  // actually takes place in `/src/routes/dashboard/+layout.js`, and is
  // inherited here.
  $: balances = data.balances ?? [];

  // We import things from external packages that will be needed
  import { Trash2Icon } from "svelte-feather-icons";

  // We import any Svelte components we will need
  import ConfirmationModal from "$lib/components/ConfirmationModal.svelte";
  import TruncatedKey from "$lib/components/TruncatedKey.svelte";

  // We import any stores we will need to read and/or write
  import { walletStore } from "$lib/stores/walletStore";
  import { invalidateAll } from "$app/navigation";

  // We import some of our `$lib` functions
  import { submit } from "$lib/diamcircle/auroraQueries";
  import { createChangeTrustTransaction } from "$lib/diamcircle/transactions";
  import { fetchAssets } from "$lib/utils/diamcircleExpert";

  // The `open` Svelte context is used to open the confirmation modal
  import { getContext } from "svelte";
  const { open } = getContext("simple-modal");

  // Define some component variables that will be used throughout the page
  let addAsset = "";
  let customAssetCode = "";
  let customAssetIssuer = "";
  let changeTrustXDR = "";
  let changeTrustNetwork = "";
  $: asset =
    addAsset !== "custom"
      ? addAsset
      : `${customAssetCode}:${customAssetIssuer}`;

  // Takes an action after the pincode has been confirmed by the user.
  const onConfirm = async (pincode) => {
    // Use the walletStore to sign the transaction
    let signedTransaction = await walletStore.sign({
      transactionXDR: changeTrustXDR,
      network: changeTrustNetwork,
      pincode: pincode,
    });
    // Submit the transaction to the diamcircle network
    await submit(signedTransaction);
    // `invalidateAll` will tell SvelteKit that it should re-run any `load`
    // functions. Since we have a new (or newly deleted) trustline, this
    // results in re-querying the network to get updated account balances.
    invalidateAll();
  };

  // Builds and presents to the user for confirmation a diamcircle transaction that
  // will add/modify/remove a trustline on their account. This function is
  // called when the user clicks the "add" or "delete" trustline buttons.
  const previewChangeTrustTransaction = async (
    addingAsset = true,
    removeAsset = undefined,
  ) => {
    // Generate the transaction, expecting back the XDR string
    let { transaction, network_passphrase } =
      await createChangeTrustTransaction({
        source: data.publicKey,
        asset: removeAsset ?? asset,
        limit: addingAsset ? undefined : "0",
      });

    // Set the component variables to hold the transaction details
    changeTrustXDR = transaction;
    changeTrustNetwork = network_passphrase;

    // Open the confirmation modal for the user to confirm or reject the
    // transaction. We provide our customized `onConfirm` function, but we
    // have no need to customize and pass an `onReject` function.
    open(ConfirmationModal, {
      transactionXDR: changeTrustXDR,
      transactionNetwork: changeTrustNetwork,
      onConfirm: onConfirm,
    });
  };
</script>

<!-- HTML has been omitted from this tutorial. Please check the source file -->
```

#### The `createChangeTrustTransaction` function

In the above page, we've made use of the `createChangeTrustTransaction` function. This function can be used to add, delete, or modify trustlines on a Diamante account.

_/src/lib/diamcircle/transactions.js_

```go
import {
  TransactionBuilder,
  Networks,
  Server,
  Operation,
  Asset,
} from "diamnet-sdk";
import { error } from "@sveltejs/kit";

// We are setting a very high maximum fee, which increases our transaction's
// chance of being included in the ledger. We're making this a `const` so we can
// change it on one place as and when recommendations and/or best practices
// evolve. Current recommended fee is `100_000` jots.
const maxFeePerOperation = "100000";
const auroraUrl = "https://diamtestnet.diamcircle.io/";
const networkPassphrase = Networks.TESTNET;
const standardTimebounds = 300; // 5 minutes for the user to review/sign/submit

// Constructs and returns a diamcircle transaction that will create or modify a
// trustline on an account.
export async function createChangeTrustTransaction({ source, asset, limit }) {
  // We start by converting the asset provided in string format into a diamcircle
  // Asset() object
  let trustAsset = new Asset(asset.split(":")[0], asset.split(":")[1]);

  // Next, we setup our transaction by loading the source account from the
  // network, and initializing the TransactionBuilder.
  let server = new Server(auroraUrl);
  let sourceAccount = await server.loadAccount(source);

  // Chaning everything together from the `transaction` declaration means we
  // don't have to assign anything to `builtTransaction` later on. Either
  // method will have the same results.
  let transaction = new TransactionBuilder(sourceAccount, {
    networkPassphrase: networkPassphrase,
    fee: maxFeePerOperation,
  })
    // Add a single `changeTrust` operation (this controls whether we are
    // adding, removing, or modifying the account's trustline)
    .addOperation(
      Operation.changeTrust({
        asset: trustAsset,
        limit: limit?.toString(),
      })
    )
    // Before the transaction can be signed, it requires timebounds
    .setTimeout(standardTimebounds)
    // It also must be "built"
    .build();

  return {
    transaction: transaction.toXDR(),
    network_passphrase: networkPassphrase,
  };
}
```

# Payment

A payment operation sends an amount in a specific asset (DIAM or non-DIAM) to a destination account. With a basic payment operation, the asset sent is the same as the asset received. BasicPay also allows for path payments (where the asset sent is different than the asset received), which we’ll talk about in the next section.

### User Experience

In our BasicPay application, the user will navigate to the Payments page where they can either select a user from their contacts or input the public key of a destination address with a specified asset they’d like to send along with the amount of the asset.

The user clicks the "Confirm Transaction" button. If the destination account exists and is properly funded with DIAM, this will trigger a Transaction Preview where they can view the transaction details.

All Diamante transactions require a small fee to make it to the ledger. Read more in our Fees, Surge Pricing, and Fee Strategies section.

In BasicPay, we’ve set it up so that the user always pays a static fee of 100,000 jots (one jot equals 0.0000001 DIAM) per operation. Alternatively, you can add a feature to your application that allows the user to set their own fee.

The user then inputs their pincode and clicks the "Confirm" button, which signs and submits the transaction to the ledger.

### Code Implementation

#### The `/dashboard/send` page

The `/dashboard/send` page allows the user to send payments to other Diamante addresses. They can select from a dropdown containing their contact list names, or they can enter their own "Other..." public key.

The following additional features have been implemented:

- If the destination address is not a funded account, the user is informed they will be using a createAccount operation and must send at least 1 DIAM to fund the account.
- The user can select to send/receive different assets and paths are queried from aurora depending on the four below points:
  - If they want to strictly send or strictly receive,
  - The source/destination assets they have selected,
  - The source/destination accounts, and
  - The amount entered for the send/receive value.
- An optional memo field is available for text-only memos.

For now, we'll focus on regular payments, and we'll dig into the path payments in a later section.

_/src/routes/dashboard/send/+page.svelte_

```go
<script>
  /**
   * All functionality surrounding path payments has been omitted here. While it
   * is contained in the same file in the source repo, in this tutorial page, we
   * are stripping that out and will include it in a later section.
   */

  // `export let data` allows us to pull in any parent load data for use here.
  /** @type {import('./$types').PageData} */
  export let data;

  // We import any Svelte components we will need
  import ConfirmationModal from "$lib/components/ConfirmationModal.svelte";
  import InfoAlert from "$lib/components/InfoAlert.svelte";

  // We import any stores we will need to read and/or write
  import { infoMessage } from "$lib/stores/alertsStore";
  import { contacts } from "$lib/stores/contactsStore";
  import { walletStore } from "$lib/stores/walletStore";

  // We import some of our `$lib` functions
  import {
    fetchAccount,
    submit,
    fetchAccountBalances,
  } from "$lib/diamcircle/auroraQueries";
  import {
    createCreateAccountTransaction,
    createPaymentTransaction,
  } from "$lib/diamcircle/transactions";

  // The `open` Svelte context is used to open the confirmation modal
  import { getContext } from "svelte";
  const { open } = getContext("simple-modal");

  // Define some component variables that will be used throughout the page
  let destination = "";
  $: otherDestination = destination === "other";
  let otherPublicKey = "";
  let sendAsset = "native";
  let sendAmount = "";
  let receiveAsset = "";
  let receiveAmount = "";
  let memo = "";
  let createAccount = null;
  let paymentXDR = "";
  let paymentNetwork = "";

  // Check whether or not the account exists and is funded on the diamcircle network.
  let checkDestination = async (publicKey) => {
    // Only do this if the `publicKey` is not "other". This check lets us
    // use the same function for both the select dropdown, and the
    // `otherPublicKey` input element.
    if (publicKey !== "other") {
      try {
        // If the account returns successfully, ensure we're not using a
        // `createAccount` operation
        await fetchAccount(publicKey);
        createAccount = false;
      } catch (err) {
        // Otherwise, inform the user about what will take place
        // @ts-ignore
        if (err.status === 404) {
          createAccount = true;
          sendAsset = "native";
          infoMessage.set(
            "Account Not Funded: You are sending a payment to an account that does not yet exist on the diamcircle ledger. Your payment will take the form of a <code>creatAccount</code> operation, and the amount you send must be at least 1 DIAM.",
          );
        }
      }
    }
  };

  // Takes an action after the pincode has been confirmed by the user.
  const onConfirm = async (pincode) => {
    // Use the walletStore to sign the transaction
    let signedTransaction = await walletStore.sign({
      transactionXDR: paymentXDR,
      network: paymentNetwork,
      pincode: pincode,
    });
    // Submit the transaction to the diamcircle network
    await submit(signedTransaction);
  };

  // Create a payment transaction depending on user selections, and present it
  // to the user for approval or rejection.
  const previewPaymentTransaction = async () => {
    let { transaction, network_passphrase } = createAccount
      ? await createCreateAccountTransaction({
          source: data.publicKey,
          destination: otherDestination ? otherPublicKey : destination,
          amount: sendAmount,
          memo: memo,
        })
      : await createPaymentTransaction({
          source: data.publicKey,
          destination: otherDestination ? otherPublicKey : destination,
          asset: sendAsset,
          amount: sendAmount,
          memo: memo,
        });

    // Set the component variables to hold the transaction details
    paymentXDR = transaction;
    paymentNetwork = network_passphrase;

    // Open the confirmation modal for the user to confirm or reject the
    // transaction. We provide our customized `onConfirm` function, but we
    // have no need to customize and pass an `onReject` function.
    open(ConfirmationModal, {
      transactionXDR: paymentXDR,
      transactionNetwork: paymentNetwork,
      onConfirm: onConfirm,
    });
  };
</script>

<!-- HTML has been omitted from this tutorial. Please check the source file -->
```

#### The transaction functions

In the above section, we used the `createPaymentTransaction` function. This function can be used to send a payment of any asset from one Diamante address to another.

We also used the `createCreateAccountTransaction` function. This is used when the destination account is not currently funded and active on the Diamante network. The only asset possible in this scenario is native DIAM.

_/src/lib/diamcircle/transactions.js_

```go
import {
  TransactionBuilder,
  Networks,
  Server,
  Operation,
  Asset,
  Memo,
} from "diamnet-sdk";
import { error } from "@sveltejs/kit";

// We are setting a very high maximum fee, which increases our transaction's
// chance of being included in the ledger. We're making this a `const` so we can
// change it on one place as and when recommendations and/or best practices
// evolve. Current recommended fee is `100_000` jots.
const maxFeePerOperation = "100000";
const auroraUrl = "https://diamtestnet.diamcircle.io/";
const networkPassphrase = Networks.TESTNET;
const standardTimebounds = 300; // 5 minutes for the user to review/sign/submit

// Constructs and returns a diamcircle transaction that contains a `payment` operaion and an optional memo.
export async function createPaymentTransaction({
  source,
  destination,
  asset,
  amount,
  memo,
}) {
  // First, we setup our transaction by loading the source account from the
  // network, and initializing the TransactionBuilder. This is the first step
  // in constructing all diamcircle transactions.
  let server = new Server(auroraUrl);
  let sourceAccount = await server.loadAccount(source);
  let transaction = new TransactionBuilder(sourceAccount, {
    networkPassphrase: networkPassphrase,
    fee: maxFeePerOperation,
  });

  let sendAsset;
  if (asset && asset !== "native") {
    sendAsset = new Asset(asset.split(":")[0], asset.split(":")[1]);
  } else {
    sendAsset = Asset.native();
  }

  // If a memo was supplied, add it to the transaction. Here, we have the
  // option of a hash memo because this is common practice by anchor transfers
  if (memo) {
    if (typeof memo === "string") {
      transaction.addMemo(Memo.text(memo));
    } else if (typeof memo === "object") {
      transaction.addMemo(Memo.hash(memo.toString("hex")));
    }
  }

  // Add a single `payment` operation
  transaction.addOperation(
    Operation.payment({
      destination: destination,
      amount: amount.toString(),
      asset: sendAsset,
    })
  );

  // Before the transaction can be signed, it requires timebounds, and it must
  // be "built"
  let builtTransaction = transaction.setTimeout(standardTimebounds).build();
  return {
    transaction: builtTransaction.toXDR(),
    network_passphrase: networkPassphrase,
  };
}

// Constructs and returns a diamcircle transaction that contains a `createAccount` operation and an optional memo.
export async function createCreateAccountTransaction({
  source,
  destination,
  amount,
  memo,
}) {
  // The minimum account balance on the diamcircle network is 1 DIAM (2 base
  // reserves). We'll check that `amount` meets or exceeds that requirement
  // early, so we can fail quickly.
  if (parseFloat(amount.toString()) < 1) {
    throw error(400, { message: "insufficient starting balance" });
  }

  // First, we setup our transaction by loading the source account from the
  // network, and initializing the TransactionBuilder. This is the first step
  // in constructing all diamcircle transactions.
  let server = new Server(auroraUrl);
  let sourceAccount = await server.loadAccount(source);
  let transaction = new TransactionBuilder(sourceAccount, {
    networkPassphrase: networkPassphrase,
    fee: maxFeePerOperation,
  });

  // If a memo was supplied, add it to the transaction
  if (memo) {
    transaction.addMemo(Memo.text(memo));
  }

  // Add a single `createAccount` operation
  transaction.addOperation(
    Operation.createAccount({
      destination: destination,
      startingBalance: amount.toString(),
    })
  );

  // Before the transaction can be signed, it requires timebounds, and it must
  // be "built"
  let builtTransaction = transaction.setTimeout(standardTimebounds).build();
  return {
    transaction: builtTransaction.toXDR(),
    network_passphrase: networkPassphrase,
  };
}
```

# Path Payment

A path payment is where the asset sent can be different from the asset received. There are two possible path payment operations:

- `path_payment_strict_send`, which allows the user to specify the amount of the asset to send
- `path_payment_strict_receive`, which allows the user to specify the amount of the asset received. Read more in the Path Payments Encyclopedia Entry.

### User experience

With BasicPay, the user sends a path payment by navigating to the Payments page, where they can either select a user from their contacts or input the public key of a destination address. They then select the Send and Receive Different Assets toggle and determine whether they want to specify the asset sent or received. Finally they select the asset sent and the asset received and the amounts and select the Preview Transaction button.

The user will then preview the transaction, input their pincode, and select the Confirm button to sign and submit the transaction to the network.

### Code implementation

#### The `/dashboard/send` page

Most of this page has been discussed in the Payment section. Below, we're highlighting the unique pieces that are added to BasicPay to allow for the path payment feature.

_/src/routes/dashboard/send/+page.svelte_

```go
<script>
  // We import some of our `$lib` functions
  import {
    fetchAccount,
    submit,
    fetchAccountBalances,
    findStrictSendPaths,
    findStrictReceivePaths,
  } from "$lib/diamcircle/auroraQueries";
  import {
    createCreateAccountTransaction,
    createPathPaymentStrictReceiveTransaction,
    createPathPaymentStrictSendTransaction,
    createPaymentTransaction,
  } from "$lib/diamcircle/transactions";

  /* ... */

  // Define some component variables that will be used throughout the page
  let destination = "";
  $: otherDestination = destination === "other";
  let otherPublicKey = "";
  let sendAsset = "native";
  let sendAmount = "";
  let receiveAsset = "";
  let receiveAmount = "";
  let memo = "";
  let createAccount = null;
  let pathPayment = false;
  let availablePaths = [];
  let strictReceive = false;
  let paymentXDR = "";
  let paymentNetwork = "";

  /* ... */

  // Query aurora for available paths between a combination of source and destination assets and accounts.
  const findPaths = async () => {
    // Query the paths from aurora
    let paths = strictReceive
      ? await findStrictReceivePaths({
          sourcePublicKey: data.publicKey,
          destinationAsset: receiveAsset,
          destinationAmount: receiveAmount,
        })
      : await findStrictSendPaths({
          sourceAsset: sendAsset,
          sourceAmount: sendAmount,
          destinationPublicKey: otherDestination ? otherPublicKey : destination,
        });
    // Fill the component variable `availablPaths` with our returned paths
    availablePaths = paths;
    // If both send and receive assets have been selected re-select the path
    // to update the relevant amount
    if (receiveAsset && sendAsset) {
      selectPath();
    }
  };

  // Select a path for use in the path payment operation, and set the component variables accordingly.
  const selectPath = () => {
    if (strictReceive) {
      // Set the `sendAmount` variable to the chosen path amount. The
      // filtering we do checks if the asset_type matches because that
      // will give us our 'native' DIAM asset, otherwise we match on the
      // asset_code.
      sendAmount = availablePaths.filter(
        (path) =>
          path.source_asset_type === sendAsset ||
          sendAsset.startsWith(path.source_asset_code),
      )[0].source_amount;
    } else {
      // Set the `receiveAmount` variable to the chosen path amount. The
      // filtering we do checks if the asset_type matches because that
      // will give us our 'native' DIAM asset, otherwise we match on the
      // asset_code.
      receiveAmount = availablePaths.filter(
        (path) =>
          path.destination_asset_type === receiveAsset ||
          receiveAsset.startsWith(path.destination_asset_code),
      )[0].destination_amount;
    }
  };

  /* ... */

  // Create a payment transaction depending on user selections, and present it to the user for approval or rejection.
  const previewPaymentTransaction = async () => {
    let { transaction, network_passphrase } = createAccount
      ? await createCreateAccountTransaction({
          /* ... */
        })
      : // highlight-start
      pathPayment && strictReceive
      ? await createPathPaymentStrictReceiveTransaction({
          source: data.publicKey,
          sourceAsset: sendAsset,
          sourceAmount: sendAmount,
          destination: otherDestination ? otherPublicKey : destination,
          destinationAsset: receiveAsset,
          destinationAmount: receiveAmount,
          memo: memo,
        })
      : pathPayment && !strictReceive
      ? await createPathPaymentStrictSendTransaction({
          source: data.publicKey,
          sourceAsset: sendAsset,
          sourceAmount: sendAmount,
          destination: otherDestination ? otherPublicKey : destination,
          destinationAsset: receiveAsset,
          destinationAmount: receiveAmount,
          memo: memo,
        })
      : // highlight-end
        await createPaymentTransaction({
          /* ... */
        });

    /* ... */
  };
</script>

<!-- HTML has been omitted from this tutorial. Please check the source file -->
```

#### The transaction functions

In the above section, we used the `createPathPaymentStrictReceiveTransaction` and `createPathPaymentStrictSendTransaction` functions. These are used to create transactions that contain the actual path payment operation.

_/src/lib/diamcircle/transactions.js_

```go
// Constructs and returns a diamcircle transaction that will contain a path payment strict send operation to send/receive different assets.
export async function createPathPaymentStrictSendTransaction({
  source,
  sourceAsset,
  sourceAmount,
  destination,
  destinationAsset,
  destinationAmount,
  memo,
}) {
  // First, we setup our transaction by loading the source account from the
  // network, and initializing the TransactionBuilder. This is the first step
  // in constructing all diamcircle transactions.
  let server = new Server(auroraUrl);
  let sourceAccount = await server.loadAccount(source);
  let transaction = new TransactionBuilder(sourceAccount, {
    networkPassphrase: networkPassphrase,
    fee: maxFeePerOperation,
  });

  // We work out the assets to be sent by the source account and received by
  // the destination account
  let sendAsset =
    sourceAsset === "native"
      ? Asset.native()
      : new Asset(sourceAsset.split(":")[0], sourceAsset.split(":")[1]);
  let destAsset =
    destinationAsset === "native"
      ? Asset.native()
      : new Asset(
          destinationAsset.split(":")[0],
          destinationAsset.split(":")[1]
        );

  // We will calculate an acceptable 2% slippage here for... reasons?
  let destMin = ((98 * parseFloat(destinationAmount)) / 100).toFixed(7);

  // If a memo was supplied, add it to the transaction
  if (memo) {
    transaction.addMemo(Memo.text(memo));
  }

  // Add a single `pathPaymentStrictSend` operation
  transaction.addOperation(
    Operation.pathPaymentStrictSend({
      sendAsset: sendAsset,
      sendAmount: sourceAmount.toString(),
      destination: destination,
      destAsset: destAsset,
      destMin: destMin,
    })
  );

  // Before the transaction can be signed, it requires timebounds, and it must
  // be "built"
  let builtTransaction = transaction.setTimeout(standardTimebounds).build();
  return {
    transaction: builtTransaction.toXDR(),
    network_passphrase: networkPassphrase,
  };
}

// Constructs and returns a diamcircle transaction that will contain a path payment strict receive operation to send/receive different assets.
export async function createPathPaymentStrictReceiveTransaction({
  source,
  sourceAsset,
  sourceAmount,
  destination,
  destinationAsset,
  destinationAmount,
  memo,
}) {
  // First, we setup our transaction by loading the source account from the
  // network, and initializing the TransactionBuilder. This is the first step
  // in constructing all diamcircle transactions.
  let server = new Server(auroraUrl);
  let sourceAccount = await server.loadAccount(source);
  let transaction = new TransactionBuilder(sourceAccount, {
    networkPassphrase: networkPassphrase,
    fee: maxFeePerOperation,
  });

  // We work out the assets to be sent by the source account and received by
  // the destination account
  let sendAsset =
    sourceAsset === "native"
      ? Asset.native()
      : new Asset(sourceAsset.split(":")[0], sourceAsset.split(":")[1]);
  let destAsset =
    destinationAsset === "native"
      ? Asset.native()
      : new Asset(
          destinationAsset.split(":")[0],
          destinationAsset.split(":")[1]
        );

  /** @todo Figure out a good number to use for slippage. And why! And how to calculate it?? */
  // We will calculate an acceptable 2% slippage here for... reasons?
  let sendMax = ((100 * parseFloat(sourceAmount)) / 98).toFixed(7);

  // If a memo was supplied, add it to the transaction
  if (memo) {
    transaction.addMemo(Memo.text(memo));
  }

  // Add a single `pathPaymentStrictSend` operation
  transaction.addOperation(
    Operation.pathPaymentStrictReceive({
      sendAsset: sendAsset,
      sendMax: sendMax,
      destination: destination,
      destAsset: destAsset,
      destAmount: destinationAmount,
    })
  );

  // Before the transaction can be signed, it requires timebounds, and it must
  // be "built"
  let builtTransaction = transaction.setTimeout(standardTimebounds).build();
  return {
    transaction: builtTransaction.toXDR(),
    network_passphrase: networkPassphrase,
  };
}
```

# Querying Data

Your application will be querying data from Aurora (one of Diamantes's APIs) throughout its functionality. Information such as account balances, transaction history, sequence numbers for transactions, asset availability, and more are stored in Aurora's database.

Here is a list of some common queries that you'll make.

_**NOTE:**
In other places in this tutorial, we have omitted the JSDoc descriptions and typing for the sake of clean presentation. Here, we're including those to make these functions more copy/paste-able._

### Imports and types

_/src/lib/diamcircle/auroraQueries.js_

```go
import { error } from "@sveltejs/kit";
import {
  Server,
  TransactionBuilder,
  Networks,
  StrKey,
  Asset,
} from "diamnet-sdk";

const auroraUrl = "https://diamtestnet.diamcircle.io/";
const server = new Server(auroraUrl);

/**
 * @module $lib/diamcircle/auroraQueries
 * @description A collection of function that helps query various information
 * from the [aurora API](https://developers.diamcircle.org/api/aurora). This
 * allows us to abstract and simplify some interactions so we don't have to have
 * _everything_ contained within our `*.svelte` files.
 */

// We'll import some type definitions that already exists within the
// `diamnet-sdk` package, so our functions will know what to expect.
/** @typedef {import('diamnet-sdk').ServerApi.AccountRecord} AccountRecord */
/** @typedef {import('diamnet-sdk').aurora.ErrorResponseData} ErrorResponseData */
/** @typedef {import('diamnet-sdk').ServerApi.PaymentOperationRecord} PaymentOperationRecord */
/** @typedef {import('diamnet-sdk').aurora.BalanceLine} BalanceLine */
/** @typedef {import('diamnet-sdk').aurora.BalanceLineAsset} BalanceLineAsset */
/** @typedef {import('diamnet-sdk').Transaction} Transaction */
/** @typedef {import('diamnet-sdk').ServerApi.PaymentPathRecord} PaymentPathRecord */
```

### fetchAccount

Gives an account's sequence number, asset balances, and trustlines.

_/src/lib/diamcircle/auroraQueries.js_

```go
/**
 * Fetches and returns details about an account on the diamcircle network.
 * @async
 * @function fetchAccount
 * @param {string} publicKey Public diamcircle address to query information about
 * @returns {Promise<AccountRecord>} Object containing whether or not the account is funded, and (if it is) account details
 * @throws {error} Will throw an error if the account is not funded on the diamcircle network, or if an invalid public key was provided.
 */
export async function fetchAccount(publicKey) {
  if (StrKey.isValidEd25519PublicKey(publicKey)) {
    try {
      let account = await server.accounts().accountId(publicKey).call();
      return account;
    } catch (err) {
      // @ts-ignore
      if (err.response?.status === 404) {
        throw error(404, "account not funded on network");
      } else {
        // @ts-ignore
        throw error(err.response?.status ?? 400, {
          // @ts-ignore
          message: `${err.response?.title} - ${err.response?.detail}`,
        });
      }
    }
  } else {
    throw error(400, { message: "invalid public key" });
  }
}
```

### fetchAccountBalances

Gets existing balances for a given `publicKey`.

_/src/lib/diamcircle/auroraQueries.js_

```go
/**
 * Fetches and returns balance details for an account on the diamcircle network.
 * @async
 * @function fetchAccountBalances
 * @param {string} publicKey Public diamcircle address holding balances to query
 * @returns {Promise<BalanceLine[]>} Array containing balance information for each asset the account holds
 */
export async function fetchAccountBalances(publicKey) {
  const { balances } = await fetchAccount(publicKey);
  return balances;
}
```

### fetchRecentPayments

Finds any payments made to or from the given `publicKey` (includes: payments, path payments, and account merges).

_/src/lib/diamcircle/auroraQueries.js_

```go
/**
 * Fetches and returns recent `payment`, `createAccount` operations that had an effect on this account.
 * @async
 * @function fetchRecentPayments
 * @param {string} publicKey Public diamcircle address to query recent payment operations to/from
 * @param {number} [limit] Number of operations to request from the server
 * @returns {Promise<PaymentOperationRecord[]>} Array containing details for each recent payment
 */
export async function fetchRecentPayments(publicKey, limit = 10) {
  const { records } = await server
    .payments()
    .forAccount(publicKey)
    .limit(limit)
    .order("desc")
    .call();
  return records;
}
```

### submit

Submit a signed transaction to the DIamante network.

_/src/lib/diamcircle/auroraQueries.js_

```go
/**
 * Submits a diamcircle transaction to the network for inclusion in the ledger.
 * @async
 * @function submit
 * @param {Transaction} transaction Built transaction to submit to the network
 * @throws Will throw an error if the transaction is not submitted successfully.
 */
export async function submit(transaction) {
  try {
    await server.submitTransaction(transaction);
  } catch (err) {
    throw error(400, {
      // @ts-ignore
      message: `${err.response?.title} - ${err.response?.data.extras.result_codes}`,
    });
  }
}
```

### fetchAssetsWithHomeDomains

We create a brand new `HomeDomainBalanceLine` type that includes the balance information of a user's trustline, and also adds the home_domain of the asset issuer. If you're using something else for type safety (or nothing at all), feel free to adapt or ignore the `@typedefs` we've included here.

Then, it looks at all the issuer accounts and returns only the ones with a `home_domain` set on the account.

_/src/lib/diamcircle/auroraQueries.js_

```go
/**
 * @typedef {Object} HomeDomainObject
 * @property {string} home_domain Domain name the issuer of this asset has set for their account on the diamcircle network.
 */

/** @typedef {BalanceLineAsset & HomeDomainObject} HomeDomainBalanceLine */

/**
 * Fetches `home_domain` from asset issuer accounts on the diamcircle network and returns an array of balances.
 * @async
 * @function fetchAssetsWithHomeDomains
 * @param {BalanceLine[]} balances Array of balances to query issuer accounts of
 * @returns {Promise<HomeDomainBalanceLine[]>} Array of balance details for assets that do have a `home_domain` setting
 */
export async function fetchAssetsWithHomeDomains(balances) {
  let homeDomains = await Promise.all(
    balances.map(async (asset) => {
      // We are only interested in issued assets (i.e., not LPs and not DIAM)
      if ("asset_issuer" in asset) {
        // Fetch the account from the network, and add its info to the array, along with the home_domain
        let account = await fetchAccount(asset.asset_issuer);
        if ("home_domain" in account) {
          return {
            ...asset,
            home_domain: account.home_domain,
          };
        }
      }
    })
  );

  // Filter out any null array entries before returning
  // @ts-ignore
  return homeDomains.filter((balance) => balance);
}
```

### findStrictSendPaths

Find the available strict send paths between a source asset/amount and receiving account.

_/src/lib/diamcircle/auroraQueries.js_

```go
/**
 * Fetches available paths on the diamcircle network between the destination account, and the asset sent by the source account.
 * @async
 * @function findStrictSendPaths
 * @param {Object} opts Options object
 * @param {string} opts.sourceAsset diamcircle asset which will be sent from the source account
 * @param {string|number} opts.sourceAmount Amount of the diamcircle asset that should be debited from the srouce account
 * @param {string} opts.destinationPublicKey Public diamcircle address that will receive the destination asset
 * @returns {Promise<PaymentPathRecord[]>} Array of payment paths that can be selected for the transaction
 * @throws Will throw an error if there are no available payment paths.
 */
export async function findStrictSendPaths({
  sourceAsset,
  sourceAmount,
  destinationPublicKey,
}) {
  let asset =
    sourceAsset === "native"
      ? Asset.native()
      : new Asset(sourceAsset.split(":")[0], sourceAsset.split(":")[1]);
  let response = await server
    .strictSendPaths(asset, sourceAmount.toString(), destinationPublicKey)
    .call();
  if (response.records.length > 0) {
    return response.records;
  } else {
    throw error(400, { message: "no strict send paths available" });
  }
}
```

### findStrictReceivePaths

Find the available strict receive paths between a source account and receiving asset/amount.

_/src/lib/diamcircle/auroraQueries.js_

```go
/**
 * Fetches available paths on the diamcircle network between the source account, and the asset to be received by the destination.
 * @async
 * @function findStrictReceivePaths
 * @param {Object} opts Options object
 * @param {string} opts.sourcePublicKey Public diamcircle address that will be the source of the payment operation
 * @param {string} opts.destinationAsset diamcircle asset which should be received in the destination account
 * @param {string|number} opts.destinationAmount Amount of the diamcircle asset that should be credited to the destination account
 * @returns {Promise<PaymentPathRecord[]>} Array of payment paths that can be selected for the transaction
 * @throws Will throw an error if there are no available payment paths.
 */
export async function findStrictReceivePaths({
  sourcePublicKey,
  destinationAsset,
  destinationAmount,
}) {
  let asset =
    destinationAsset === "native"
      ? Asset.native()
      : new Asset(
          destinationAsset.split(":")[0],
          destinationAsset.split(":")[1]
        );
  let response = await server
    .strictReceivePaths(sourcePublicKey, asset, destinationAmount.toString())
    .call();
  if (response.records.length > 0) {
    return response.records;
  } else {
    throw error(400, { message: "no strict receive paths available" });
  }
}
```

### Query DIAM Explorer

DIAM Explorer is a block explorer that is indispensable as a tool for understanding what is happening on the Diamante network. On our `/dashboard/assets` page, we're pre-populating a list of asset trustlines a user might choose to add to their Diamante account. We get this list of assets from the Diamante Explorer API.

We've created our own RankedAsset type so BasicPay knows how to interact with these objects. And we are then retrieving the ten most highly-rated assets from the diamcircle Expert API.

_/src/lib/utils/diamcircleExpert.js_

```go
const network = "testnet";
const baseUrl = `https://api.diamcircle.expert/explorer/${network}`;

/**
 * An asset object that has been returned by our query to diamcircle.Expert
 * @typedef {Object} RankedAsset
 * @property {string} asset Asset identifier
 * @property {number} traded_amount Total traded amount (in jots)
 * @property {number} payments_amount Total payments amount (in jots)
 * @property {number} created Timestamp of the first recorder operation with asset
 * @property {number} supply Total issued asset supply
 * @property {Object} trustlines Trustlines established to an asset
 * @property {number} trades Total number of trades
 * @property {number} payments Total number of payments
 * @property {string} domain Associated `home_domain`
 * @property {Object} tomlInfo Asset information from diamcircle.toml file
 * @property {Object} rating Composite asset rating
 * @property {number} paging_token Paging token
 * @see {@link https://diamcircle.expert/openapi.html#tag/Asset-Info-API/operation/getAllAssets}
 */

/**
 * Fetches and returns the most highly rated assets, according to the diamcircle.Expert calculations.
 * @async
 * @function fetchAssets
 * @returns {Promise<RankedAsset[]>} Array of objects containing details for each asset
 */
export async function fetchAssets() {
  let res = await fetch(
    `${baseUrl}/asset?${new URLSearchParams({
      // these are all the defaults, but you could customize them if needed
      search: "",
      sort: "rating",
      order: "desc",
      limit: "10",
      cursor: "0",
    })}`
  );
  let json = await res.json();

  let records = json._embedded.records;
  return records;
}
```
