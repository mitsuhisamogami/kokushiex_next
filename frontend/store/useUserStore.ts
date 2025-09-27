import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface User {
  id: string;
  email: string;
  name: string;
  role: 'student' | 'admin' | 'guest';
  avatar?: string;
}

interface UserState {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  
  // Actions
  setUser: (user: User | null) => void;
  updateUser: (updates: Partial<User>) => void;
  clearUser: () => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
}

export const useUserStore = create<UserState>()(
  devtools(
    persist(
      (set) => ({
        user: null,
        isLoading: false,
        error: null,
        
        setUser: (user) => set({ user, error: null }),
        
        updateUser: (updates) => 
          set((state) => ({
            user: state.user ? { ...state.user, ...updates } : null,
          })),
        
        clearUser: () => set({ user: null, error: null }),
        
        setLoading: (isLoading) => set({ isLoading }),
        
        setError: (error) => set({ error }),
      }),
      {
        name: 'user-storage',
        partialize: (state) => ({ user: state.user }),
      }
    )
  )
);