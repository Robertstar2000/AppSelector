import React, { useState, useEffect } from 'react';
import { X, Save, Trash2, HelpCircle } from 'lucide-react';
import { AppDefinition, AppStatus, AppType } from '../types';
import * as LucideIcons from 'lucide-react';

interface AdminModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (app: AppDefinition) => void;
  onDelete: (id: string) => void;
  app: AppDefinition | null; // If null, we are creating
}

const AdminModal: React.FC<AdminModalProps> = ({ isOpen, onClose, onSave, onDelete, app }) => {
  const [formData, setFormData] = useState<AppDefinition>({
    id: '',
    name: '',
    description: '',
    iconName: 'Box',
    status: AppStatus.ACTIVE,
    type: AppType.URL,
    url: ''
  });

  useEffect(() => {
    if (app) {
      setFormData(app);
    } else {
      setFormData({
        id: crypto.randomUUID(),
        name: '',
        description: '',
        iconName: 'Box',
        status: AppStatus.ACTIVE,
        type: AppType.URL,
        url: ''
      });
    }
  }, [app, isOpen]);

  if (!isOpen) return null;

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(formData);
    onClose();
  };

  // Get a list of valid icon names from Lucide to show in a helper or dropdown (simplified here)
  const IconPreview = (LucideIcons as any)[formData.iconName] || LucideIcons.Box;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden">
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100 bg-gray-50">
          <h2 className="text-lg font-bold text-slate-800">
            {app ? 'Edit Application' : 'Add New Application'}
          </h2>
          <button onClick={onClose} className="p-1 rounded-full hover:bg-gray-200 transition-colors">
            <X className="w-5 h-5 text-gray-500" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Application Name</label>
            <input 
              required
              name="name"
              value={formData.name}
              onChange={handleChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-tallman-blue focus:border-transparent outline-none transition-all"
              placeholder="e.g. Dashboard"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <input 
              name="description"
              value={formData.description}
              onChange={handleChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-tallman-blue outline-none"
              placeholder="Short description"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
             <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
                <select 
                  name="type"
                  value={formData.type}
                  onChange={handleChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-tallman-blue outline-none"
                >
                  <option value={AppType.URL}>Web Link (URL)</option>
                  <option value={AppType.EXE}>Local Executable (.exe)</option>
                  <option value={AppType.INTERNAL_VIEW}>Internal View</option>
                </select>
             </div>
             <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
                <select 
                  name="status"
                  value={formData.status}
                  onChange={handleChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-tallman-blue outline-none"
                >
                  <option value={AppStatus.ACTIVE}>Active</option>
                  <option value={AppStatus.MAINTENANCE}>Maintenance</option>
                  <option value={AppStatus.DISABLED}>Disabled</option>
                </select>
             </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
                {formData.type === AppType.EXE ? 'File Path' : 'URL / Action'}
            </label>
            <input 
              name="url"
              value={formData.url || ''}
              onChange={handleChange}
              disabled={formData.type === AppType.INTERNAL_VIEW}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-tallman-blue outline-none disabled:bg-gray-100 disabled:text-gray-400"
              placeholder={formData.type === AppType.EXE ? 'C:\\Program Files\\...' : 'https://...'}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1 flex items-center gap-2">
                Icon Name (Lucide React)
                <a href="https://lucide.dev/icons" target="_blank" rel="noreferrer" className="text-blue-500 hover:underline text-xs"><HelpCircle className="w-3 h-3 inline"/></a>
            </label>
            <div className="flex gap-2">
                <input 
                name="iconName"
                value={formData.iconName}
                onChange={handleChange}
                className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-tallman-blue outline-none"
                placeholder="e.g. Activity"
                />
                <div className="w-10 h-10 flex items-center justify-center bg-gray-100 rounded-lg border border-gray-200">
                    <IconPreview className="w-5 h-5 text-gray-600" />
                </div>
            </div>
          </div>

          <div className="flex gap-3 pt-4 border-t border-gray-100">
             {app && (
                 <button 
                    type="button" 
                    onClick={() => onDelete(app.id)}
                    className="px-4 py-2 text-red-600 bg-red-50 hover:bg-red-100 rounded-lg font-medium transition-colors"
                 >
                    <Trash2 className="w-5 h-5" />
                 </button>
             )}
             <button 
                type="button" 
                onClick={onClose}
                className="flex-1 px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg font-medium transition-colors"
             >
                Cancel
             </button>
             <button 
                type="submit" 
                className="flex-1 px-4 py-2 text-white bg-tallman-blue hover:bg-blue-800 rounded-lg font-medium shadow-lg shadow-blue-900/20 transition-all flex items-center justify-center gap-2"
             >
                <Save className="w-4 h-4" /> Save
             </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AdminModal;
