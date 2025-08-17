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
            <button className="group relative bg-gradient-to-r from-blue-600 to-blue-700 text-white px-8 py-4 rounded-full text-lg font-semibold transition-all duration-300 hover:-translate-y-1 hover:shadow-xl hover:shadow-blue-500/25 overflow-hidden">
              <span className="relative z-10">ログイン</span>
              <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-500"></div>
            </button>
            
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

      {/* Features Section */}
      <section className="bg-blue-500/5 backdrop-blur-sm border-t border-blue-500/10 py-16">
        <div className="max-w-6xl mx-auto px-8">
          <h2 className="text-4xl font-bold text-center mb-12 text-slate-200">
            3つの特徴
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {/* Feature 1 */}
            <div className="group bg-gradient-to-br from-slate-800 to-slate-700 p-8 rounded-3xl border border-blue-500/10 transition-all duration-300 hover:-translate-y-2 hover:shadow-xl hover:shadow-blue-500/10 hover:border-blue-500/30 relative overflow-hidden">
              <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-600 to-blue-700"></div>
              
              <div className="w-15 h-15 bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl flex items-center justify-center text-2xl mb-6 shadow-lg shadow-blue-500/30">
                📚
              </div>
              
              <h3 className="text-xl font-semibold mb-4 text-slate-200">
                過去10年分の<br />理学療法士工国家試験対応
              </h3>
              
              <p className="text-slate-400 leading-relaxed">
                豊富な過去問データベースで実戦的な学習が可能
              </p>
            </div>

            {/* Feature 2 */}
            <div className="group bg-gradient-to-br from-slate-800 to-slate-700 p-8 rounded-3xl border border-blue-500/10 transition-all duration-300 hover:-translate-y-2 hover:shadow-xl hover:shadow-blue-500/10 hover:border-blue-500/30 relative overflow-hidden">
              <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-600 to-blue-700"></div>
              
              <div className="w-15 h-15 bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl flex items-center justify-center text-2xl mb-6 shadow-lg shadow-blue-500/30">
                📱
              </div>
              
              <h3 className="text-xl font-semibold mb-4 text-slate-200">
                インターネット環境が<br />なくても学習可能
              </h3>
              
              <p className="text-slate-400 leading-relaxed">
                オフライン機能で場所を選ばず学習を継続
              </p>
            </div>

            {/* Feature 3 */}
            <div className="group bg-gradient-to-br from-slate-800 to-slate-700 p-8 rounded-3xl border border-blue-500/10 transition-all duration-300 hover:-translate-y-2 hover:shadow-xl hover:shadow-blue-500/10 hover:border-blue-500/30 relative overflow-hidden">
              <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-600 to-blue-700"></div>
              
              <div className="w-15 h-15 bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl flex items-center justify-center text-2xl mb-6 shadow-lg shadow-blue-500/30">
                📊
              </div>
              
              <h3 className="text-xl font-semibold mb-4 text-slate-200">
                豊富な学習データと<br />進捗の可視化
              </h3>
              
              <p className="text-slate-400 leading-relaxed">
                詳細な分析データで効率的な学習戦略を立案
              </p>
            </div>
          </div>
        </div>
      </section>

    </div>
  );
}