'use client'

import { useState } from 'react'

export default function ApiTest() {
  const [status, setStatus] = useState<string>('')
  const [loading, setLoading] = useState(false)

  const testApi = async () => {
    setLoading(true)
    setStatus('テスト中...')
    
    try {
      const response = await fetch('/api/health')
      const responseText = await response.text()
      
      setStatus(`レスポンス: ${response.status}\n内容: ${responseText.substring(0, 200)}...`)
      
      // JSONパースを試す
      try {
        const data = JSON.parse(responseText)
        if (response.ok) {
          setStatus(`✅ API接続成功: ${data.message}`)
        } else {
          setStatus(`❌ API接続失敗: ${response.status}`)
        }
      } catch (parseError) {
        setStatus(`❌ JSONパースエラー: レスポンスがHTMLの可能性があります\n${responseText.substring(0, 300)}`)
      }
    } catch (error) {
      setStatus(`❌ エラー: ${error instanceof Error ? error.message : '不明なエラー'}`)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="p-6 border rounded-lg bg-gray-50">
      <h2 className="text-lg font-semibold mb-4">API接続テスト</h2>
      <button
        onClick={testApi}
        disabled={loading}
        className="bg-blue-500 hover:bg-blue-700 disabled:bg-gray-400 text-white font-bold py-2 px-4 rounded"
      >
        {loading ? '実行中...' : 'APIテスト実行'}
      </button>
      {status && (
        <div className="mt-4 p-3 bg-white border rounded">
          <pre className="text-sm whitespace-pre-wrap">{status}</pre>
        </div>
      )}
    </div>
  )
}