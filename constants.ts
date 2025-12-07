import { AppDefinition, AppStatus, AppType } from './types';

// Removed chat app as LLM functionality was not needed
export const INITIAL_APPS: AppDefinition[] = [
  {
    id: 'agent',
    name: 'Agent',
    description: 'Field Agent Portal',
    iconName: 'UserCheck',
    url: 'https://agent.tallman.com',
    status: AppStatus.ACTIVE,
    type: AppType.URL,
    sourceCode: 'https://github.com/tallman/agent-portal',
    backendLocation: 'https://api.tallman.com/agent',
    author: 'Development Team'
  },
  {
    id: 'project',
    name: 'Project',
    description: 'Project Management Suite',
    iconName: 'Briefcase',
    url: 'https://project.tallman.com',
    status: AppStatus.ACTIVE,
    type: AppType.URL,
    sourceCode: 'https://github.com/tallman/project-suite',
    backendLocation: 'https://api.tallman.com/project',
    author: 'Project Team'
  },
  {
    id: 'dashboard',
    name: 'Dashboard',
    description: 'Executive KPI Overview',
    iconName: 'LayoutDashboard',
    url: 'https://dash.tallman.com',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL,
    sourceCode: 'https://github.com/tallman/dashboard',
    backendLocation: 'https://api.tallman.com/dashboard',
    author: 'Dashboard Team'
  },
  {
    id: 'datahub',
    name: 'DataHub',
    description: 'Central Data Warehouse',
    iconName: 'Database',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL,
    sourceCode: 'https://github.com/tallman/datahub',
    backendLocation: 'https://api.tallman.com/datahub',
    author: 'Data Engineering Team'
  },
  {
    id: 'engineering',
    name: 'Engineering',
    description: 'CAD & Specs Library',
    iconName: 'DraftingCompass',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL,
    sourceCode: 'https://github.com/tallman/engineering',
    backendLocation: 'https://api.tallman.com/engineering',
    author: 'Engineering Team'
  },
  {
    id: 'buckettruck',
    name: 'BucketTruck',
    description: 'Fleet Management',
    iconName: 'Truck',
    url: 'C:\\Apps\\BucketTruck\\launcher.exe',
    status: AppStatus.MAINTENANCE,
    type: AppType.EXE,
    sourceCode: 'https://github.com/tallman/buckettruck',
    backendLocation: '192.168.1.100:3001',
    author: 'Fleet Operations'
  },
  {
    id: 'cascade',
    name: 'Cascade',
    description: 'Workflow Automation',
    iconName: 'Workflow',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL,
    sourceCode: 'https://github.com/tallman/cascade',
    backendLocation: 'https://api.tallman.com/cascade',
    author: 'Automation Team'
  },
  {
    id: 'testing',
    name: 'Testing',
    description: 'QA & Safety Checks',
    iconName: 'TestTube',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL,
    sourceCode: 'https://github.com/tallman/testing',
    backendLocation: 'https://api.tallman.com/testing',
    author: 'QA Team'
  },
  {
    id: 'picklist',
    name: 'PickList',
    description: 'Warehouse Picking',
    iconName: 'ClipboardList',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL,
    sourceCode: 'https://github.com/tallman/picklist',
    backendLocation: 'https://api.tallman.com/picklist',
    author: 'Warehouse Team'
  },
  {
    id: 'rubber',
    name: 'Rubber',
    description: 'Insulation Goods',
    iconName: 'Shield',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL,
    sourceCode: 'https://github.com/tallman/rubber',
    backendLocation: 'https://api.tallman.com/rubber',
    author: 'Procurement Team'
  },
  {
    id: 'rental',
    name: 'Rental',
    description: 'Equipment Rental Sys',
    iconName: 'CalendarClock',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL,
    sourceCode: 'https://github.com/tallman/rental',
    backendLocation: 'https://api.tallman.com/rental',
    author: 'Rental Department'
  }
];
