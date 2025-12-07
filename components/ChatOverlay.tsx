import React, { useState, useRef, useEffect } from 'react';
import { X, Send, Bot, User, Sparkles } from 'lucide-react';
import { ChatMessage } from '../types';
import { sendMessageToGemini } from '../services/geminiService';

interface ChatOverlayProps {
  isOpen: boolean;
  onClose: () => void;
}

const ChatOverlay: React.FC<ChatOverlayProps> = ({ isOpen, onClose }) => {
  const [messages, setMessages] = useState<ChatMessage[]>([
    { role: 'model', text: 'Hello! I am the Tallman Corporate Assistant. How can I help you with our applications today?', timestamp: Date.now() }
  ]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen) {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages, isOpen]);

  const handleSend = async () => {
    if (!input.trim() || isLoading) return;

    const userMsg: ChatMessage = { role: 'user', text: input, timestamp: Date.now() };
    setMessages(prev => [...prev, userMsg]);
    setInput('');
    setIsLoading(true);

    // Prepare history for API
    const history = messages.map(m => ({
        role: m.role,
        parts: [{ text: m.text }]
    }));

    try {
        const responseText = await sendMessageToGemini(userMsg.text, history);
        const botMsg: ChatMessage = { role: 'model', text: responseText, timestamp: Date.now() };
        setMessages(prev => [...prev, botMsg]);
    } catch (e) {
        setMessages(prev => [...prev, { role: 'model', text: 'I apologize, but I am having trouble connecting to the network.', timestamp: Date.now() }]);
    } finally {
        setIsLoading(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        handleSend();
    }
  };

  return (
    <div 
        className={`fixed inset-y-0 right-0 z-40 w-full sm:w-[450px] bg-white shadow-2xl transform transition-transform duration-300 ease-in-out border-l border-gray-200 flex flex-col ${isOpen ? 'translate-x-0' : 'translate-x-full'}`}
    >
      {/* Header */}
      <div className="flex items-center justify-between p-4 border-b bg-gradient-to-r from-tallman-blue to-blue-800 text-white">
        <div className="flex items-center gap-3">
            <div className="p-2 bg-white/20 rounded-full">
                <Sparkles className="w-5 h-5 text-yellow-300" />
            </div>
            <div>
                <h2 className="font-bold text-lg leading-tight">Tallman Chat</h2>
                <p className="text-xs text-blue-200">Powered by Gemini 2.5</p>
            </div>
        </div>
        <button onClick={onClose} className="p-2 hover:bg-white/10 rounded-full transition-colors">
            <X className="w-6 h-6" />
        </button>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-6 bg-slate-50">
        {messages.map((msg, idx) => {
            const isModel = msg.role === 'model';
            return (
                <div key={idx} className={`flex gap-3 ${isModel ? 'flex-row' : 'flex-row-reverse'}`}>
                    <div className={`
                        w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0
                        ${isModel ? 'bg-tallman-blue text-white' : 'bg-gray-300 text-gray-700'}
                    `}>
                        {isModel ? <Bot className="w-5 h-5" /> : <User className="w-5 h-5" />}
                    </div>
                    <div className={`
                        max-w-[80%] p-3 rounded-2xl text-sm leading-relaxed shadow-sm
                        ${isModel ? 'bg-white text-gray-800 rounded-tl-none border border-gray-200' : 'bg-tallman-blue text-white rounded-tr-none'}
                    `}>
                        {msg.text}
                    </div>
                </div>
            )
        })}
        {isLoading && (
            <div className="flex gap-3">
                <div className="w-8 h-8 rounded-full bg-tallman-blue text-white flex items-center justify-center">
                    <Bot className="w-5 h-5" />
                </div>
                <div className="bg-white p-3 rounded-2xl rounded-tl-none border border-gray-200 shadow-sm flex items-center gap-2">
                    <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></span>
                    <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-100"></span>
                    <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-200"></span>
                </div>
            </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="p-4 border-t bg-white">
        <div className="relative">
            <input 
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={handleKeyPress}
                placeholder="Ask about applications, safety protocols..."
                className="w-full pl-4 pr-12 py-3 bg-gray-100 border-none rounded-xl focus:ring-2 focus:ring-tallman-blue/50 outline-none transition-all"
            />
            <button 
                onClick={handleSend}
                disabled={!input.trim() || isLoading}
                className="absolute right-2 top-1/2 -translate-y-1/2 p-2 bg-tallman-blue text-white rounded-lg hover:bg-blue-800 disabled:opacity-50 disabled:hover:bg-tallman-blue transition-all"
            >
                <Send className="w-4 h-4" />
            </button>
        </div>
        <div className="mt-2 text-center">
            <p className="text-[10px] text-gray-400">
                Tallman Internal AI can make mistakes. Verify important information.
            </p>
        </div>
      </div>
    </div>
  );
};

export default ChatOverlay;
