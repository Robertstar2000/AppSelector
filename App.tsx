import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
  Plus,
  Search,
  Lock,
  Unlock,
  AlertTriangle,
  Download
} from 'lucide-react';
import { INITIAL_APPS } from './constants';
import { AppDefinition, AppType, AppStatus } from './types';
import AppCard from './components/AppCard';
import AdminModal from './components/AdminModal';
// Removed ChatOverlay as LLM functionality was not needed

function App() {
  const [apps, setApps] = useState<AppDefinition[]>([]);
  const [isAdmin, setIsAdmin] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  // Drag and Drop
  const [draggedIndex, setDraggedIndex] = useState<number | null>(null);

  // Admin Mode Triggers
  const [secretCount, setSecretCount] = useState(0);
  
  // Modals
  const [isEditModalOpen, setEditModalOpen] = useState(false);
  const [editingApp, setEditingApp] = useState<AppDefinition | null>(null);
  
  // Toast
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Load apps from API
  useEffect(() => {
    const fetchApps = async () => {
      try {
        const response = await axios.get('http://localhost:3001/api/apps');
        setApps(response.data);
      } catch (error) {
        console.error('Failed to load apps:', error);
        // Fallback to local constants if API fails
        setApps(INITIAL_APPS);
      }
    };
    fetchApps();
  }, []);

  const saveApps = async (newApps: AppDefinition[]) => {
    try {
      await axios.put('http://localhost:3001/api/apps', newApps);
      setApps(newApps);
    } catch (error) {
      console.error('Failed to save apps:', error);
      setApps(newApps); // Update UI anyway
    }
  };

  const handleAppClick = (app: AppDefinition) => {
    if (app.type === AppType.INTERNAL_VIEW) {
      showToast(`Opening internal view: ${app.name}`);
    } else if (app.type === AppType.EXE) {
      // Simulate EXE launch behavior + Warning
      showToast(`Launching ${app.name} (${app.url}). Check your downloads or protocol handlers.`);
      // In a real environment, this might trigger a custom protocol like tallman://launch?app=...
      // For web, we can't do much more than this without a local agent installed.
    } else if (app.url) {
      window.open(app.url, '_blank');
    }
  };

  const handleAdminToggle = () => {
    setSecretCount(prev => prev + 1);
    if (secretCount + 1 >= 5) {
      setIsAdmin(!isAdmin);
      setSecretCount(0);
      showToast(isAdmin ? "Admin Mode Deactivated" : "Admin Mode Activated");
    }
  };

  const handleEdit = (app: AppDefinition) => {
    setEditingApp(app);
    setEditModalOpen(true);
  };

  const handleAddNew = () => {
    setEditingApp(null);
    setEditModalOpen(true);
  };

  const handleSaveApp = async (app: AppDefinition) => {
    console.log('Attempting to save app:', app, 'editing:', !!editingApp);
    try {
      if (editingApp) {
        const response = await axios.put(`http://localhost:3001/api/apps/${app.id}`, app);
        console.log('PUT response:', response);
      } else {
        const response = await axios.post('http://localhost:3001/api/apps', app);
        console.log('POST response:', response);
      }
      // Refetch apps
      const response = await axios.get('http://localhost:3001/api/apps');
      console.log('Refetched apps:', response.data);
      setApps(response.data);
      showToast('App saved successfully');
    } catch (error) {
      console.error('Failed to save app:', error);
      showToast('Failed to save app');
    }
  };

  const handleDeleteApp = async (id: string) => {
    try {
      await axios.delete(`http://localhost:3001/api/apps/${id}`);
      // Refetch apps
      const response = await axios.get('http://localhost:3001/api/apps');
      setApps(response.data);
      setEditModalOpen(false);
      showToast('App deleted successfully');
    } catch (error) {
      console.error('Failed to delete app:', error);
      showToast('Failed to delete app');
    }
  };

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3000);
  };

  // Drag and drop handlers
  const handleDragStart = (e: React.DragEvent, index: number) => {
    if (!isAdmin) return;
    setDraggedIndex(index);
    e.dataTransfer.effectAllowed = 'move';
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  };

  const handleDrop = (e: React.DragEvent, dropIndex: number) => {
    console.log('handleDrop called, draggedIndex:', draggedIndex, 'dropIndex:', dropIndex);
    e.preventDefault();
    if (!isAdmin || draggedIndex === null || draggedIndex === dropIndex) return;

    const newApps = [...apps];
    const draggedApp = filteredApps[draggedIndex];
    const dropApp = filteredApps[dropIndex];

    console.log('draggedApp:', draggedApp, 'dropApp:', dropApp);

    // Get real indices in full apps array
    const realDraggedIndex = apps.findIndex(app => app.id === draggedApp.id);
    const realDropIndex = apps.findIndex(app => app.id === dropApp.id);

    console.log('real indices:', realDraggedIndex, realDropIndex);

    if (realDraggedIndex !== -1 && realDropIndex !== -1) {
      newApps.splice(realDraggedIndex, 1);
      newApps.splice(realDropIndex, 0, draggedApp);
      console.log('new array before save:', newApps.map(a => a.name));
      saveApps(newApps);
    }

    setDraggedIndex(null);
  };

  const handleDragEnd = () => {
    setDraggedIndex(null);
  };

  const filteredApps = apps.filter(app => 
    app.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
    app.description.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="min-h-screen flex flex-col relative bg-gray-50 text-slate-800">

      {/* Navbar */}
      <header className="bg-white border-b border-gray-200 sticky top-0 z-20 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
          
          {/* Brand */}
          <div className="flex items-center gap-3">
             <div className="w-10 h-10 bg-tallman-red rounded flex items-center justify-center text-white font-black text-2xl tracking-tighter">
                T
             </div>
             <div className="flex flex-col">
                <span className="text-2xl font-extrabold text-tallman-blue leading-none tracking-tight">TALLMAN</span>
                <span className="text-xs font-semibold text-gray-500 tracking-widest uppercase">Equipment</span>
             </div>
          </div>

          {/* Search */}
          <div className="hidden md:flex flex-1 max-w-md mx-8 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input 
              type="text"
              placeholder="Find an application..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-gray-100 border-none rounded-full focus:ring-2 focus:ring-tallman-blue/50 focus:bg-white transition-all outline-none"
            />
          </div>

          {/* Right Actions */}
          <div className="flex items-center gap-4">
            {isAdmin && (
              <>
                <div className="hidden sm:flex items-center gap-2 px-3 py-1 bg-red-50 text-red-600 rounded-full border border-red-100 text-xs font-bold uppercase animate-pulse">
                  <Unlock className="w-3 h-3" /> Admin Mode
                </div>
                <button
                  onClick={() => {
                    // Client-side backup to local file
                    const backupData = { timestamp: new Date().toISOString(), apps: apps };
                    const blob = new Blob([JSON.stringify(backupData, null, 2)], { type: 'application/json' });
                    const url = URL.createObjectURL(blob);
                    const link = document.createElement('a');
                    link.href = url;
                    link.download = `apps-backup-${new Date().toISOString().split('T')[0]}.json`;
                    link.click();
                    URL.revokeObjectURL(url);
                  }}
                  className="p-2 text-gray-600 hover:text-tallman-blue hover:bg-blue-50 rounded-full transition-colors"
                  title="Download Backup"
                >
                  <Download className="w-5 h-5" />
                </button>
              </>
            )}

            {/* Date/Time Placeholder for dashboard feel */}
            <div className="text-right hidden sm:block">
                <div className="text-sm font-bold text-gray-700">{new Date().toLocaleDateString()}</div>
                <div className="text-xs text-gray-500">Corporate Portal</div>
            </div>
          </div>
        </div>
      </header>

      {/* Mobile Search Bar (Visible only on small screens) */}
      <div className="md:hidden p-4 bg-white border-b border-gray-200">
        <div className="relative">
             <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input 
              type="text"
              placeholder="Search apps..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-gray-100 rounded-lg outline-none"
            />
        </div>
      </div>

      {/* Main Content */}
      <main className="flex-1 max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-8">
        
        {/* Welcome / Context */}
        <div className="mb-8">
            <h1 className="text-3xl font-light text-slate-800">
                Welcome, <span className="font-bold text-tallman-blue">Team Member</span>
            </h1>
            <p className="text-gray-500 mt-2 max-w-2xl">
                Access your essential tools and services below. System status is currently <span className="text-green-600 font-semibold">Operational</span>.
            </p>
        </div>

        {/* Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 mb-6">
          {filteredApps.map((app, index) => (
            <div
              key={app.id}
              draggable={isAdmin}
              onDragStart={(e) => handleDragStart(e, index)}
              onDragOver={handleDragOver}
              onDrop={(e) => handleDrop(e, index)}
              onDragEnd={handleDragEnd}
              className={`${isAdmin ? 'cursor-move' : ''} ${draggedIndex === index ? 'opacity-50' : ''}`}
            >
              <AppCard
                app={app}
                isAdmin={isAdmin}
                onClick={handleAppClick}
                onEdit={handleEdit}
              />
            </div>
          ))}
        </div>

        {/* Add New Button (Admin Only) */}
        {isAdmin && (
          <div className="flex justify-center">
            <button
                onClick={handleAddNew}
                className="flex flex-col items-center justify-center p-3 border-2 border-dashed border-gray-300 rounded-xl hover:border-tallman-blue hover:bg-blue-50 transition-all group"
            >
                <div className="w-5.5 h-5.5 rounded-full bg-gray-100 flex items-center justify-center mb-2 group-hover:bg-blue-100 transition-colors">
                    <Plus className="w-3 h-3 text-gray-400 group-hover:text-tallman-blue" />
                </div>
                <span className="text-xs font-semibold text-gray-500 group-hover:text-tallman-blue">Add Application</span>
            </button>
          </div>
        )}

        {filteredApps.length === 0 && !isAdmin && (
            <div className="flex flex-col items-center justify-center py-20 text-gray-400">
                <Search className="w-12 h-12 mb-4 opacity-50" />
                <p>No applications found matching "{searchQuery}"</p>
            </div>
        )}

      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200 mt-auto">
        <div className="max-w-7xl mx-auto px-4 py-6 flex flex-col md:flex-row items-center justify-between text-xs text-gray-500">
            <div>
                &copy; {new Date().getFullYear()} Tallman Equipment Company, Inc. All rights reserved.
            </div>
            <div className="flex items-center gap-4 mt-4 md:mt-0">
                <a href="#" className="hover:text-tallman-blue">Privacy Policy</a>
                <a href="#" className="hover:text-tallman-blue">Terms of Service</a>
                {/* Hidden Admin Trigger */}
                <span 
                    onClick={handleAdminToggle} 
                    className="cursor-default select-none hover:text-gray-600 transition-colors"
                    title="Version 1.0.0"
                >
                    v1.0.0
                </span>
            </div>
        </div>
      </footer>

      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 bg-slate-800 text-white px-6 py-3 rounded-full shadow-lg flex items-center gap-2 animate-slide-up">
            <AlertTriangle className="w-4 h-4 text-yellow-400" />
            <span className="text-sm font-medium">{toastMessage}</span>
        </div>
      )}

      {/* Modals */}
      <AdminModal
        isOpen={isEditModalOpen}
        onClose={() => setEditModalOpen(false)}
        onSave={handleSaveApp}
        onDelete={handleDeleteApp}
        app={editingApp}
      />

      {/* Admin Mode Overlay Hint (Optional visual cue when admin is active) */}
      {isAdmin && (
        <div className="fixed top-0 left-0 w-full h-1 bg-red-500 z-50"></div>
      )}
    </div>
  );
}

export default App;
