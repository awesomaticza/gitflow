import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    'intro',
    'getting-started',
    {
      type: 'category',
      label: 'Workflows',
      items: ['workflows/release', 'workflows/hotfix'],
    },
    {
      type: 'category',
      label: 'Guides',
      items: ['guides/maven-enforcer'],
    },
  ],
};

export default sidebars;
