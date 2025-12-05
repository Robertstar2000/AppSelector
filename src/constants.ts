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
    type: AppType.URL
  },
  {
    id: 'project',
    name: 'Project',
    description: 'Project Management Suite',
    iconName: 'Briefcase',
    url: 'https://project.tallman.com',
    status: AppStatus.ACTIVE,
    type: AppType.URL
  },
  {
    id: 'dashboard',
    name: 'Dashboard',
    description: 'Executive KPI Overview',
    iconName: 'LayoutDashboard',
    url: 'https://dash.tallman.com',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL
  },
  {
    id: 'datahub',
    name: 'DataHub',
    description: 'Central Data Warehouse',
    iconName: 'Database',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL
  },
  {
    id: 'engineering',
    name: 'Engineering',
    description: 'CAD & Specs Library',
    iconName: 'DraftingCompass',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL
  },
  {
    id: 'buckettruck',
    name: 'BucketTruck',
    description: 'Fleet Management',
    iconName: 'Truck',
    url: 'C:\\Apps\\BucketTruck\\launcher.exe',
    status: AppStatus.MAINTENANCE,
    type: AppType.EXE
  },
  {
    id: 'cascade',
    name: 'Cascade',
    description: 'Workflow Automation',
    iconName: 'Workflow',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL
  },
  {
    id: 'testing',
    name: 'Testing',
    description: 'QA & Safety Checks',
    iconName: 'TestTube',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL
  },
  {
    id: 'picklist',
    name: 'PickList',
    description: 'Warehouse Picking',
    iconName: 'ClipboardList',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL
  },
  {
    id: 'rubber',
    name: 'Rubber',
    description: 'Insulation Goods',
    iconName: 'Shield',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL
  },
  {
    id: 'rental',
    name: 'Rental',
    description: 'Equipment Rental Sys',
    iconName: 'CalendarClock',
    status: AppStatus.MAINTENANCE,
    type: AppType.URL
  }
];
