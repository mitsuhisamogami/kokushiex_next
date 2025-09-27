import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface Modal {
  id: string;
  title?: string;
  content?: React.ReactNode;
  onClose?: () => void;
  onConfirm?: () => void;
}

interface Toast {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
  duration?: number;
}

interface UIState {
  // Loading states
  isGlobalLoading: boolean;
  loadingMessage: string | null;
  
  // Modal states
  modals: Modal[];
  
  // Toast notifications
  toasts: Toast[];
  
  // Sidebar
  isSidebarOpen: boolean;
  
  // Theme
  theme: 'light' | 'dark' | 'system';
  
  // Actions
  setGlobalLoading: (isLoading: boolean, message?: string | null) => void;
  openModal: (modal: Omit<Modal, 'id'>) => void;
  closeModal: (id: string) => void;
  showToast: (toast: Omit<Toast, 'id'>) => void;
  removeToast: (id: string) => void;
  toggleSidebar: () => void;
  setSidebarOpen: (isOpen: boolean) => void;
  setTheme: (theme: 'light' | 'dark' | 'system') => void;
}

export const useUIStore = create<UIState>()(
  devtools(
    (set) => ({
      // Initial states
      isGlobalLoading: false,
      loadingMessage: null,
      modals: [],
      toasts: [],
      isSidebarOpen: true,
      theme: 'system',
      
      // Actions
      setGlobalLoading: (isLoading, message = null) => 
        set({ isGlobalLoading: isLoading, loadingMessage: message }),
      
      openModal: (modal) => 
        set((state) => ({
          modals: [...state.modals, { ...modal, id: Date.now().toString() }],
        })),
      
      closeModal: (id) => 
        set((state) => ({
          modals: state.modals.filter((modal) => modal.id !== id),
        })),
      
      showToast: (toast) => {
        const id = Date.now().toString();
        const duration = toast.duration ?? 5000;
        
        set((state) => ({
          toasts: [...state.toasts, { ...toast, id }],
        }));
        
        // Auto-remove toast after duration
        if (duration > 0) {
          setTimeout(() => {
            set((state) => ({
              toasts: state.toasts.filter((t) => t.id !== id),
            }));
          }, duration);
        }
      },
      
      removeToast: (id) => 
        set((state) => ({
          toasts: state.toasts.filter((toast) => toast.id !== id),
        })),
      
      toggleSidebar: () => 
        set((state) => ({ isSidebarOpen: !state.isSidebarOpen })),
      
      setSidebarOpen: (isOpen) => 
        set({ isSidebarOpen: isOpen }),
      
      setTheme: (theme) => 
        set({ theme }),
    }),
    {
      name: 'ui-store',
    }
  )
);