export enum AppStatus {
  ACTIVE = 'ACTIVE',
  MAINTENANCE = 'MAINTENANCE',
  DISABLED = 'DISABLED'
}

export enum AppType {
  URL = 'URL',
  EXE = 'EXE',
  INTERNAL_VIEW = 'INTERNAL_VIEW'
}

export interface AppDefinition {
  id: string;
  name: string;
  description: string;
  iconName: string; // Key to map to Lucide icons
  url?: string;
  status: AppStatus;
  type: AppType;
  sourceCode?: string;
  backendLocation?: string;
  author?: string;
  position?: number; // For ordering/sorting apps
}

export interface SystemSettings {
  lastBackup?: string; // ISO date string of last backup
  autoBackup?: boolean; // Whether to auto-backup on app start
  backupFilePath?: string; // Path where backups are stored
}

export interface ChatMessage {
  role: 'user' | 'model';
  text: string;
  timestamp: number;
}
