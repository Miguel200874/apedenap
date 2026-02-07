
export type MessageRole = 'user' | 'model';

export interface Message {
  id: string;
  role: MessageRole;
  text: string;
  timestamp: number;
}

export interface Devotional {
  id: string;
  title: string;
  verse: string;
  text: string;
  category: string;
}

export interface UserProfile {
  name: string;
  daysStreak: number;
  totalDevotionals: number;
  savedVerses: string[];
}
