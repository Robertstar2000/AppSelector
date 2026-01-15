import React, { useState, useEffect } from 'react';
import { X, Save, Settings, Users, Brain } from 'lucide-react';

interface AdminSettingsModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const AdminSettingsModal: React.FC<AdminSettingsModalProps> = ({ isOpen, onClose }) => {
  const [endpointUrl, setEndpointUrl] = useState('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent');
  const [modelName, setModelName] = useState('Gemini 2.0 Flash Experimental');

  useEffect(() => {
    if (isOpen) {
      // Load settings from localStorage or defaults
      const savedEndpoint = localStorage.getItem('ai_endpoint_url');
      const savedModel = localStorage.getItem('ai_model_name');

      if (savedEndpoint) setEndpointUrl(savedEndpoint);
      if (savedModel) setModelName(savedModel);
    }
  }, [isOpen]);

  const handleSave = () => {
    // Save to localStorage
    localStorage.setItem('ai_endpoint_url', endpointUrl);
    localStorage.setItem('ai_model_name', modelName);
    alert('AI Settings saved successfully!');
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fade-in">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden">
        <div className="flex items-center justify-between px-4 py-3 border-b border-gray-100 bg-gray-50">
          <h2 className="text-lg font-bold text-slate-800 flex items-center gap-2">
            <Settings className="w-5 h-5" />
            Admin Settings
          </h2>
          <button onClick={onClose} className="p-1 rounded-full hover:bg-gray-200 transition-colors">
            <X className="w-5 h-5 text-gray-500" />
          </button>
        </div>

        <div className="p-6 space-y-8">
          {/* User Management Section */}
          <div className="space-y-4">
            <div className="flex items-center gap-2">
              <Users className="w-5 h-5 text-tallman-blue" />
              <h3 className="text-lg font-semibold text-gray-900">User Management</h3>
            </div>

            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <p className="text-sm text-blue-800">
                Manage users who are approved to use this application. Users must also be Tallman Employees with a .tallmanequipment email to log in.
              </p>
            </div>

            <div className="text-sm text-gray-600">
              <p className="mb-2">Current user access is managed through:</p>
              <ul className="list-disc list-inside space-y-1 ml-4">
                <li>Employee email domain verification (@tallmanequipment.com)</li>
                <li>Active employment status in company systems</li>
                <li>Application-specific access controls</li>
              </ul>
            </div>
          </div>

          {/* AI Settings Section */}
          <div className="space-y-4 border-t border-gray-200 pt-6">
            <div className="flex items-center gap-2">
              <Brain className="w-5 h-5 text-tallman-blue" />
              <h3 className="text-lg font-semibold text-gray-900">AI Settings</h3>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Endpoint URL
                </label>
                <input
                  type="text"
                  value={endpointUrl}
                  onChange={(e) => setEndpointUrl(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-tallman-blue focus:border-transparent outline-none"
                  placeholder="Enter AI endpoint URL"
                />
                <p className="text-xs text-gray-500 mt-1">
                  Current: Gemini 2.0 Flash Experimental API endpoint
                </p>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Model Name
                </label>
                <input
                  type="text"
                  value={modelName}
                  onChange={(e) => setModelName(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-tallman-blue focus:border-transparent outline-none"
                  placeholder="Enter model name"
                />
                <p className="text-xs text-gray-500 mt-1">
                  Current: Gemini 2.0 Flash Experimental
                </p>
              </div>
            </div>
          </div>

          {/* Save Button */}
          <div className="flex justify-end border-t border-gray-200 pt-6">
            <button
              onClick={handleSave}
              className="flex items-center gap-2 px-6 py-2 bg-tallman-blue text-white rounded-lg hover:bg-blue-800 transition-colors"
            >
              <Save className="w-4 h-4" />
              Save Settings
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AdminSettingsModal;
