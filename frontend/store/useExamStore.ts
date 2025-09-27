import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface Question {
  id: string;
  content: string;
  choices: Choice[];
  image?: string;
  correctChoiceId: string;
}

interface Choice {
  id: string;
  content: string;
  optionNumber: number;
}

interface ExamSession {
  id: string;
  testId: string;
  questions: Question[];
  timeLimit: number; // in minutes
  startedAt: Date | null;
  completedAt: Date | null;
}

interface ExamState {
  // Current exam session
  currentExam: ExamSession | null;
  
  // Navigation
  currentQuestionIndex: number;
  
  // Answers
  answers: Map<string, string>; // questionId -> choiceId
  
  // Timer
  timeRemaining: number; // in seconds
  isTimerRunning: boolean;
  
  // Status
  status: 'idle' | 'ready' | 'in_progress' | 'paused' | 'completed' | 'submitted';
  
  // Review mode
  isReviewMode: boolean;
  flaggedQuestions: Set<string>;
  
  // Actions
  startExam: (exam: ExamSession) => void;
  pauseExam: () => void;
  resumeExam: () => void;
  completeExam: () => void;
  submitExam: () => void;
  
  // Navigation actions
  goToQuestion: (index: number) => void;
  nextQuestion: () => void;
  previousQuestion: () => void;
  
  // Answer actions
  setAnswer: (questionId: string, choiceId: string) => void;
  clearAnswer: (questionId: string) => void;
  
  // Timer actions
  updateTimeRemaining: (seconds: number) => void;
  startTimer: () => void;
  stopTimer: () => void;
  
  // Review actions
  toggleReviewMode: () => void;
  flagQuestion: (questionId: string) => void;
  unflagQuestion: (questionId: string) => void;
  
  // Reset
  resetExam: () => void;
}

export const useExamStore = create<ExamState>()(
  devtools(
    (set, get) => ({
      // Initial states
      currentExam: null,
      currentQuestionIndex: 0,
      answers: new Map(),
      timeRemaining: 0,
      isTimerRunning: false,
      status: 'idle',
      isReviewMode: false,
      flaggedQuestions: new Set(),
      
      // Exam control actions
      startExam: (exam) => 
        set({
          currentExam: { ...exam, startedAt: new Date() },
          currentQuestionIndex: 0,
          answers: new Map(),
          timeRemaining: exam.timeLimit * 60,
          status: 'in_progress',
          isTimerRunning: true,
          flaggedQuestions: new Set(),
        }),
      
      pauseExam: () => 
        set({ status: 'paused', isTimerRunning: false }),
      
      resumeExam: () => 
        set({ status: 'in_progress', isTimerRunning: true }),
      
      completeExam: () => 
        set((state) => ({
          currentExam: state.currentExam
            ? { ...state.currentExam, completedAt: new Date() }
            : null,
          status: 'completed',
          isTimerRunning: false,
        })),
      
      submitExam: () => 
        set({ status: 'submitted', isTimerRunning: false }),
      
      // Navigation actions
      goToQuestion: (index) => {
        const { currentExam } = get();
        if (currentExam && index >= 0 && index < currentExam.questions.length) {
          set({ currentQuestionIndex: index });
        }
      },
      
      nextQuestion: () => {
        const { currentQuestionIndex, currentExam } = get();
        if (currentExam && currentQuestionIndex < currentExam.questions.length - 1) {
          set({ currentQuestionIndex: currentQuestionIndex + 1 });
        }
      },
      
      previousQuestion: () => {
        const { currentQuestionIndex } = get();
        if (currentQuestionIndex > 0) {
          set({ currentQuestionIndex: currentQuestionIndex - 1 });
        }
      },
      
      // Answer actions
      setAnswer: (questionId, choiceId) => 
        set((state) => {
          const newAnswers = new Map(state.answers);
          newAnswers.set(questionId, choiceId);
          return { answers: newAnswers };
        }),
      
      clearAnswer: (questionId) => 
        set((state) => {
          const newAnswers = new Map(state.answers);
          newAnswers.delete(questionId);
          return { answers: newAnswers };
        }),
      
      // Timer actions
      updateTimeRemaining: (seconds) => 
        set({ timeRemaining: seconds }),
      
      startTimer: () => 
        set({ isTimerRunning: true }),
      
      stopTimer: () => 
        set({ isTimerRunning: false }),
      
      // Review actions
      toggleReviewMode: () => 
        set((state) => ({ isReviewMode: !state.isReviewMode })),
      
      flagQuestion: (questionId) => 
        set((state) => {
          const newFlagged = new Set(state.flaggedQuestions);
          newFlagged.add(questionId);
          return { flaggedQuestions: newFlagged };
        }),
      
      unflagQuestion: (questionId) => 
        set((state) => {
          const newFlagged = new Set(state.flaggedQuestions);
          newFlagged.delete(questionId);
          return { flaggedQuestions: newFlagged };
        }),
      
      // Reset
      resetExam: () => 
        set({
          currentExam: null,
          currentQuestionIndex: 0,
          answers: new Map(),
          timeRemaining: 0,
          isTimerRunning: false,
          status: 'idle',
          isReviewMode: false,
          flaggedQuestions: new Set(),
        }),
    }),
    {
      name: 'exam-store',
    }
  )
);