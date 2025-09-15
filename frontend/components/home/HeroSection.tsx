import Link from 'next/link';

export default function HeroSection() {
  return (
    <div className="bg-slate-900 text-slate-200 min-h-screen">
      {/* Hero Section */}
      <section className="max-w-6xl mx-auto px-8 py-16 grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
        {/* Hero Content */}
        <div className="hero-content">
          <h1 className="text-5xl lg:text-6xl font-bold leading-tight mb-6">
            <span className="bg-gradient-to-r from-slate-200 to-blue-400 bg-clip-text text-transparent">
              理学療法士
            </span>
            <br />
            国家試験を
            <br />
            スマートに合格
          </h1>
          
          <p className="text-xl text-slate-400 mb-8 leading-relaxed">
            効率的な学習システムで確実な合格をサポート。過去問分析から弱点克服まで、あなたの学習を全面的にバックアップします。
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4">
            <Link href="/signin" className="group relative bg-gradient-to-r from-blue-600 to-blue-700 text-white px-8 py-4 rounded-full text-lg font-semibold transition-all duration-300 hover:-translate-y-1 hover:shadow-xl hover:shadow-blue-500/25 overflow-hidden inline-block text-center">
              <span className="relative z-10">ログイン</span>
              <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-500"></div>
            </Link>
            
            <button className="bg-transparent text-blue-400 border-2 border-blue-400 px-8 py-4 rounded-full text-lg font-semibold transition-all duration-300 hover:bg-blue-400/10 hover:-translate-y-1">
              無料体験開始
            </button>
          </div>
        </div>

        {/* Hero Illustration */}
        <div className="hero-image flex justify-center items-center">
          <div className="relative w-full max-w-md h-80 bg-gradient-to-br from-slate-800 to-slate-700 rounded-3xl flex items-center justify-center overflow-hidden border border-blue-500/20 shadow-2xl">
            {/* Top accent line */}
            <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-600 to-blue-700"></div>
            
            {/* Animated background pattern */}
            <div className="absolute inset-0 opacity-20">
              <div className="absolute inset-0 bg-gradient-to-br from-blue-500/10 via-transparent to-blue-500/5"></div>
              <div className="absolute top-0 left-0 w-full h-full bg-repeat opacity-30 animate-pulse"></div>
            </div>
            
            {/* Placeholder for illustration - currently empty as requested */}
            <div className="relative z-10 w-full h-full p-8 flex items-center justify-center">
              <div className="text-slate-500 text-center">
                <div className="text-4xl mb-4">🏥</div>
                <div className="text-sm">Hero Illustration Area</div>
              </div>
            </div>
          </div>
        </div>
      </section>


    </div>
  );
}