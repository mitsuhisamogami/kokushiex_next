import { SiBookstack} from 'react-icons/si';
import { FaWifi, FaChartLine } from "react-icons/fa";

export default function FeaturesSection() {
  return (
    <section className="bg-blue-500/5 backdrop-blur-sm border-t border-blue-500/10 py-16">
      <div className="max-w-6xl mx-auto px-8">
        <h2 className="text-4xl font-bold text-center mb-12">
          <span className="bg-gradient-to-r from-blue-400 to-blue-600 bg-clip-text text-transparent">
            3つの特徴
          </span>
        </h2>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {/* Feature 1: 登録不要 */}
          <div className="group bg-gradient-to-br from-slate-800 to-slate-700 p-8 rounded-3xl border border-blue-500/10 transition-all duration-300 hover:-translate-y-2 hover:shadow-xl hover:shadow-blue-500/10 hover:border-blue-500/30 relative overflow-hidden">
            <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-600 to-blue-700"></div>
            
            <div className="w-15 h-15 bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl flex items-center justify-center text-2xl mb-6 shadow-lg shadow-blue-500/30">
              <SiBookstack className="text-white" />
            </div>
            
            <h3 className="text-xl font-semibold mb-4 text-slate-200">
            過去10年分の理学療法士国家試験に対応
            </h3>
          </div>

          {/* Feature 2: インターネット環境があればどこでも学習可能 */}
          <div className="group bg-gradient-to-br from-slate-800 to-slate-700 p-8 rounded-3xl border border-blue-500/10 transition-all duration-300 hover:-translate-y-2 hover:shadow-xl hover:shadow-blue-500/10 hover:border-blue-500/30 relative overflow-hidden">
            <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-600 to-blue-700"></div>
            
            <div className="w-15 h-15 bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl flex items-center justify-center text-2xl mb-6 shadow-lg shadow-blue-500/30">
              <FaWifi className="text-white" />
            </div>
            
            <h3 className="text-xl font-semibold mb-4 text-slate-200">
              インターネット環境があればどこでも学習可能
            </h3>
          </div>

          {/* Feature 3: 豊富な学習データ */}
          <div className="group bg-gradient-to-br from-slate-800 to-slate-700 p-8 rounded-3xl border border-blue-500/10 transition-all duration-300 hover:-translate-y-2 hover:shadow-xl hover:shadow-blue-500/10 hover:border-blue-500/30 relative overflow-hidden">
            <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-600 to-blue-700"></div>
            
            <div className="w-15 h-15 bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl flex items-center justify-center text-2xl mb-6 shadow-lg shadow-blue-500/30">
              <FaChartLine className="text-white" />
            </div>
            
            <h3 className="text-xl font-semibold mb-4 text-slate-200">
              採点の手間が省け、過去問の受験データをもとに学習可能
            </h3>
          </div>
        </div>
      </div>
    </section>
  );
}