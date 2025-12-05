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
}

export interface ChatMessage {
  role: 'user' | 'model';
  text: string;
  timestamp: number;
}
