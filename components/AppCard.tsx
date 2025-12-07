import React from 'react';
import * as LucideIcons from 'lucide-react';
import { AppDefinition, AppStatus, AppType } from '../types';

interface AppCardProps {
  app: AppDefinition;
  onClick: (app: AppDefinition) => void;
  isAdmin: boolean;
  onEdit: (app: AppDefinition) => void;
}

const AppCard: React.FC<AppCardProps> = ({ app, onClick, isAdmin, onEdit }) => {
  // Dynamically resolve icon
  const IconComponent = (LucideIcons as any)[app.iconName] || LucideIcons.Box;
  
  const isMaintenance = app.status === AppStatus.MAINTENANCE;
  const isDisabled = app.status === AppStatus.DISABLED;
  
  // Combine visual states for "greyed out" look
  const isGreyedOut = isDisabled || isMaintenance;

  const handleCardClick = () => {
    if (isAdmin) {
        onEdit(app);
        return;
    }

    // Normal mode - don't allow clicking disabled or maintenance apps
    if (isDisabled || isMaintenance) return;
    onClick(app);
  };

  return (
    <div
      onClick={handleCardClick}
      className={`
        relative group overflow-hidden rounded-xl border p-3 transition-all duration-300
        ${isAdmin ? 'cursor-context-menu border-dashed border-tallman-blue/50' : 'cursor-pointer border-gray-200'}
        ${isGreyedOut ? 'bg-gray-50' : 'bg-white hover:shadow-xl hover:-translate-y-1 hover:border-tallman-blue/30'}
      `}
    >
      {/* Admin Indicator */}
      {isAdmin && (
        <div className="absolute top-0 right-0 z-20">
          <LucideIcons.Settings2 className="w-2 h-2 text-gray-400" />
        </div>
      )}

      {/* Maintenance Badge (Non-obtrusive) */}
      {isMaintenance && !isAdmin && (
        <div className="absolute top-1 left-1/2 -translate-x-1/2 z-10 w-full flex justify-center pointer-events-none">
           <div className="bg-yellow-100 border border-yellow-200 text-yellow-800 px-0 py-0 rounded-full flex items-center gap-0 shadow-xs">
             <LucideIcons.HardHat className="w-1.5 h-1.5" />
             <span className="text-[4px] font-bold uppercase tracking-wider">Under Construction</span>
           </div>
        </div>
      )}

      <div className="flex flex-col items-center text-center space-y-2 pt-0">
        <div className={`
            p-2 rounded-full transition-colors duration-300 relative
            ${isGreyedOut ? 'bg-gray-200/50' : 'bg-blue-50 group-hover:bg-tallman-blue/10'}
        `}>
          <IconComponent
            className={`
                w-3.5 h-3.5 transition-colors duration-300
                ${isGreyedOut ? 'text-gray-500' : 'text-tallman-blue'}
            `}
          />
        </div>

        <div className="w-full">
          {/* Explicitly darker grey text for maintenance/disabled state to ensure visibility */}
          <h3 className={`text-sm font-bold tracking-tight ${isGreyedOut ? 'text-gray-700' : 'text-slate-800'}`}>
            {app.name}
          </h3>
          <p className={`text-[7px] mt-0.5 line-clamp-2 font-medium ${isGreyedOut ? 'text-gray-500' : 'text-gray-500'}`}>
            {app.description}
          </p>
        </div>

        {/* Type Badge */}
        <div className={`absolute bottom-0 right-0 transition-opacity ${isGreyedOut ? 'opacity-0' : 'opacity-0 group-hover:opacity-100'}`}>
            <span className="text-[5px] uppercase font-bold text-gray-300">
                {app.type === AppType.EXE ? '.EXE' : app.type === AppType.INTERNAL_VIEW ? 'APP' : 'WEB'}
            </span>
        </div>
      </div>
    </div>
  );
};

export default AppCard;
