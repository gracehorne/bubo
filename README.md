[![Netlify Status](https://api.netlify.com/api/v1/badges/81dd219c-51cb-4418-a18c-42c8b104c689/deploy-status)](https://app.netlify.com/sites/bubo-rss-demo/deploys)

# 🦉 Bubo Reader

Bubo Reader is a hyper-minimalist feed reader (RSS, Atom, JSON) you can deploy on your own server or [Netlify](https://netlify.com) in a few steps. The goal of the project is to generate a webpage that shows a list of links from a collection of feeds organized by category and website. That's it.

It is named after this [silly robot owl](https://www.youtube.com/watch?v=MYSeCfo9-NI) from Clash of the Titans (1981).

You can read more about this project on my blog:

- [Introducing Bubo RSS: An Absurdly Minimalist RSS Feed Reader](https://george.mand.is/2019/11/introducing-bubo-rss-an-absurdly-minimalist-rss-feed-reader/).
- [Publishing Bubos RSS to Netlify with GitHub Actions](https://george.mand.is/2020/02/publishing-bubos-rss-to-netlify-with-github-actions/)

## Get Started

- Clone or fork the repo and run `npm install` to install the dependencies.
- Update `config/feeds.json` to include categories and links to feeds you would like to see.
- Run `npm run build:bubo`

That's it! You should now have a static page with links to the latest content from your feeds in the `public` folder, ready to serve.

## Self-hosting

The simplest server-side path is Docker.

Build the image:

```bash
docker build -t bubo-reader .
```

Run it:

```bash
docker run --rm -p 8080:80 bubo-reader
```

Open `http://localhost:8080`.

When you change `config/feeds.json`, rebuild the image so the generated `public/index.html` stays current.

## cPanel Git Deploy (No Terminal Access)

If you deploy by pulling this repository from cPanel's Git UI, keep the generated file in git:

- `public/index.html` should be committed to the repo.
- `public/style.css` can be edited and committed normally.

Recommended update flow:

```bash
npm install
npm run build:bubo
git add public/index.html config/feeds.json public/style.css
git commit -m "Update Bubo feeds output"
git push
```

Then use cPanel's Git pull/deploy action to refresh the live site from remote.

This repo includes a root `.htaccess` so Apache can serve the generated output at `/bubo` (clean URL) while files remain in `public/`.

### Optional: Automatic Generated Output via GitHub Actions

This repo can automatically rebuild and commit `public/index.html` when feed/config/source files change on `main`.

- Workflow file: `.github/workflows/update-bubo-output.yml`
- Triggered by changes to `config/feeds.json`, template, source, or build config files.
- The workflow commits only when `public/index.html` actually changes.

After it runs, you only need to use cPanel Git pull/deploy to publish the new output.

## Keeping Up With Upstream

This is a real clone of `georgemandis/bubo-rss`, so you can pull upstream changes normally:

```bash
git pull origin main
```

If you have local changes, commit or stash them first.

<details>
  <summary>
    <strong>Anatomy of Bubo Reader</strong>
  </summary>

The static pieces:

- `conf/feeds.json` - a JSON file containing your feed URLS separated into categories.
- `config/template.html` - a [Nunjucks](https://mozilla.github.io/nunjucks/) template that lets you change how the feeds are displayed. This can be changed to anything else you like— see below.
- `public/style.css` - a CSS file to stylize your feed output.
- `public/index.html` - The HTML file that gets automatically generated when Bubo is run.

The engine:

- `src/index.ts` - The primary script you run when you want to build a new version of Bubo. It will automatically fetch the latest content from your feeds and build a new static file at `public/index.html`.
- `src/renderer.ts` — The renderer that loads Nunjucks, the template and understands how to process the incoming feed data. Prefer something else? This is the place to change it!
- `src/utilities.ts` — A variety of parsing and normalization utilities for Bubo, hidden away to try and keep things clean.

</details>

<details>
  <summary>
    <strong>Throttling</strong>
  </summary>

In the main `index.ts` file you will find two values that allow you to batch and throttle your feed requests:

- `MAX_CONNECTIONS` dictates the maximum number of requests a batch can have going at once.
- `DELAY_MS` dictates the amount of delay time between each batch.

The default configuration is **no batching or throttling** because `MAX_CONNECTIONS` is set to `Infinity`. If you wanted to change Bubo to only fetch one feed at a time every second you could set these values to:

```javascript
const MAX_CONNECTIONS = 1;
const DELAY_MS = 1000;
```

If you wanted to limit things to 10 simultaneous requests every 2.5 seconds you could set it like so:

```javascript
const MAX_CONNECTIONS = 10;
const DELAY_MS = 2500;
```

In practice, I've never _really_ run into an issue leaving `MAX_CONNECTIONS` set to `Infinity` but this feels like a sensible safeguard to design.

</details>

<details>
  <summary>
    <strong>Getting Started</strong>
  </summary>

- [Deploying to Netlify](#netlify)
- [Keeping feeds updated](#updated)

<a id="netlify"></a>

## Deploying to Netlify

- [Fork the repository](https://github.com/georgemandis/bubo-rss/fork)
- From your forked repository edit `config/feeds.json` to manage your feeds and categories
- [Create a new site](https://app.netlify.com/start) on Netlify from GitHub

The deploy settings should automatically import from the `netlify.toml` file. All you'll need to do is confirm and you're ready to go!

<a id="updated"></a>

### Keeping Feeds Updated

#### Using Netlify Webhooks

To keep your feeds up to date you'll want to [setup a Build Hook](https://www.netlify.com/docs/webhooks/#incoming-webhooks) for your Netlify site and use another service to ping it every so often to trigger a rebuild. I'd suggest looking into:

- [IFTTT](https://ifttt.com/)
- [Zapier](https://zapier.com/)
- [EasyCron](https://www.easycron.com/)

#### Rolling Your Own

If you already have a server running Linux and some command-line experience it might be simpler to setup a [cron job](https://en.wikipedia.org/wiki/Cron).

</details>

## Demos

You can view live demos here:

- [https://bubo-rss-demo.netlify.app/](https://bubo-rss-demo.netlify.app/)

## Support

If you found this useful please consider [sponsoring me or this project](https://github.com/sponsors/georgemandis).

If you'd rather run this on your own server please consider using one of these affiliate links to setup a micro instance on [Linode](https://www.linode.com/?r=8729957ab02b50a695dcea12a5ca55570979d8b9), [Digital Ocean](https://m.do.co/c/31f58d367777) or [Vultr](https://www.vultr.com/?ref=8403978).

## Showcase

Here are some websites using Bubo Reader:

- [Kevin Fiol](https://kevinfiol.com/reader/) ([repo](https://github.com/kevinfiol/reader))

Please share if you would like to be featured!
