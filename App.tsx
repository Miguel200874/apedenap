
import React, { useState, useEffect } from 'react';
import { HashRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout.tsx';
import HomeScreen from './components/HomeScreen.tsx';
import ChatScreen from './components/ChatScreen.tsx';
import BibleScreen from './components/BibleScreen.tsx';
import ProfileScreen from './components/ProfileScreen.tsx';
import FavoritesScreen from './components/FavoritesScreen.tsx';
import AuthScreen from './components/AuthScreen.tsx';
import { ICON_EDEM } from './constants';
import { supabase } from './services/supabaseClient';

const SplashScreen: React.FC<{ onComplete: () => void }> = ({ onComplete }) => {
  useEffect(() => {
    const timer = setTimeout(onComplete, 3000);
    return () => clearTimeout(timer);
  }, [onComplete]);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-edem-offwhite text-center p-6">
      <div className="mb-8 animate-bounce duration-[2000ms]">
        {ICON_EDEM}
      </div>
      <h1 className="text-4xl font-serif text-gray-800 mb-2">EDEM</h1>
      <p className="text-edem-gold font-serif italic mb-12">"No princípio, Deus..."</p>
      
      <div className="absolute bottom-16 text-gray-400 text-sm animate-pulse">
        No Éden, tudo começou.
      </div>
    </div>
  );
};

const App: React.FC = () => {
  const [showSplash, setShowSplash] = useState(true);
  const [session, setSession] = useState<any>(null);
  const [checkingAuth, setCheckingAuth] = useState(true);

  useEffect(() => {
    // Verificar sessão inicial
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setCheckingAuth(false);
    });

    // Ouvir mudanças na autenticação
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  // Efeito para garantir que o app sempre inicie na home quando aberto/recarregado
  useEffect(() => {
    if (!showSplash && session) {
      // Força o roteamento para a raiz caso o usuário entre em uma URL profunda
      if (window.location.hash !== '#/') {
        window.location.hash = '#/';
      }
    }
  }, [showSplash, session]);

  if (showSplash) {
    return <SplashScreen onComplete={() => setShowSplash(false)} />;
  }

  if (checkingAuth) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-edem-offwhite">
        <div className="animate-spin text-edem-olive">
          {ICON_EDEM}
        </div>
      </div>
    );
  }

  if (!session) {
    return <AuthScreen />;
  }

  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<HomeScreen />} />
          <Route path="/chat" element={<ChatScreen />} />
          <Route path="/bible" element={<BibleScreen />} />
          <Route path="/favorites" element={<FavoritesScreen />} />
          <Route path="/profile" element={<ProfileScreen />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Layout>
    </Router>
  );
};

export default App;
