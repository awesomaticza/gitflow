import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'gitflow',
  tagline: 'Automated GitFlow branching and release management',
  favicon: 'img/favicon.ico',

  url: 'https://awesomaticza.github.io',
  baseUrl: '/gitflow/',
  organizationName: 'awesomaticza',
  projectName: 'gitflow',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Serve files from both website/static and the repo-root artifacts/ folder.
  // This means artifacts/images/gitflow.png is available at /images/gitflow.png
  // both locally (npm start) and on GitHub Pages.
  staticDirectories: ['static', '../artifacts'],

  markdown: {
    mermaid: true,
  },

  themes: ['@docusaurus/theme-mermaid'],

  plugins: ['docusaurus-plugin-image-zoom'],

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    navbar: {
      title: 'gitflow',
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          href: 'https://github.com/awesomaticza/gitflow',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      copyright: `Copyright © ${new Date().getFullYear()} gitflow. Built with Docusaurus.`,
    },
    mermaid: {
      theme: {light: 'default', dark: 'dark'},
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
    zoom: {
      selector: '.markdown img',
      background: {
        light: 'rgb(255, 255, 255)',
        dark: 'rgb(50, 50, 50)',
      },
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
