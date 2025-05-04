# ContAct 詳細設計書

## 1. フロントエンド詳細設計

### 1.1 PDFビューアコンポーネント
```typescript
// PDFViewer.tsx
interface PDFViewerProps {
  pdfUrl: string;
  onPageChange: (pageNumber: number) => void;
  onViewTime: (duration: number) => void;
}

const PDFViewer: React.FC<PDFViewerProps> = ({
  pdfUrl,
  onPageChange,
  onViewTime
}) => {
  // PDF.jsを使用した実装
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(0);
  const [viewStartTime, setViewStartTime] = useState<Date | null>(null);

  useEffect(() => {
    // PDFの読み込みと表示
    const loadPDF = async () => {
      const pdf = await pdfjsLib.getDocument(pdfUrl).promise;
      setTotalPages(pdf.numPages);
    };
    loadPDF();
  }, [pdfUrl]);

  // ページ変更時の処理
  const handlePageChange = (page: number) => {
    if (viewStartTime) {
      const duration = new Date().getTime() - viewStartTime.getTime();
      onViewTime(duration);
    }
    setCurrentPage(page);
    setViewStartTime(new Date());
    onPageChange(page);
  };

  return (
    <div className="pdf-viewer">
      {/* PDF表示エリア */}
      <canvas id="pdf-canvas" />
      {/* ページナビゲーション */}
      <div className="page-navigation">
        <button onClick={() => handlePageChange(currentPage - 1)} disabled={currentPage === 1}>
          前へ
        </button>
        <span>{currentPage} / {totalPages}</span>
        <button onClick={() => handlePageChange(currentPage + 1)} disabled={currentPage === totalPages}>
          次へ
        </button>
      </div>
    </div>
  );
};
```

### 1.2 トラッキングシステム
```typescript
// TrackingSystem.ts
class TrackingSystem {
  private viewLinkId: string;
  private currentPage: number;
  private viewStartTime: Date | null;

  constructor(viewLinkId: string) {
    this.viewLinkId = viewLinkId;
    this.currentPage = 1;
    this.viewStartTime = null;
  }

  startTracking(page: number) {
    this.currentPage = page;
    this.viewStartTime = new Date();
  }

  async endTracking() {
    if (!this.viewStartTime) return;

    const duration = new Date().getTime() - this.viewStartTime.getTime();
    await this.sendViewLog(duration);
  }

  private async sendViewLog(duration: number) {
    const response = await fetch('/api/view-logs', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        view_link_id: this.viewLinkId,
        page_number: this.currentPage,
        duration_sec: Math.floor(duration / 1000),
      }),
    });

    if (!response.ok) {
      console.error('Failed to send view log');
    }
  }
}
```

### 1.3 予約モーダル
```typescript
// ReservationModal.tsx
interface ReservationModalProps {
  isOpen: boolean;
  onClose: () => void;
  onReserve: () => void;
  score: number;
}

const ReservationModal: React.FC<ReservationModalProps> = ({
  isOpen,
  onClose,
  onReserve,
  score
}) => {
  if (!isOpen) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <h2>商談予約のお誘い</h2>
        <p>この資料に高い関心をお持ちのようです。</p>
        <p>商談のご予約はいかがでしょうか？</p>
        
        <div className="score-indicator">
          <span>関心度スコア: {score}</span>
        </div>

        <div className="modal-actions">
          <button onClick={onClose}>後で</button>
          <button onClick={onReserve} className="primary">
            予約する
          </button>
        </div>
      </div>
    </div>
  );
};
```

## 2. バックエンド詳細設計

### 2.1 スコアリングロジック
```php
// ScoringService.php
class ScoringService
{
    private const SCORE_WEIGHTS = [
        'page_view' => 30,
        'total_time' => 20,
        'page_time' => 10,
        'multiple_views' => 20,
        'last_page' => 20
    ];

    public function calculateScore(ViewLink $viewLink): int
    {
        $logs = $viewLink->viewLogs;
        $totalPages = $viewLink->pdf->page_count;
        
        $scores = [
            'page_view' => $this->calculatePageViewScore($logs, $totalPages),
            'total_time' => $this->calculateTotalTimeScore($logs),
            'page_time' => $this->calculatePageTimeScore($logs),
            'multiple_views' => $this->calculateMultipleViewsScore($viewLink),
            'last_page' => $this->calculateLastPageScore($logs, $totalPages)
        ];

        return $this->sumScores($scores);
    }

    private function calculatePageViewScore($logs, $totalPages): int
    {
        $viewedPages = $logs->pluck('page_number')->unique()->count();
        $percentage = ($viewedPages / $totalPages) * 100;
        return $percentage >= 80 ? self::SCORE_WEIGHTS['page_view'] : 0;
    }

    private function calculateTotalTimeScore($logs): int
    {
        $totalTime = $logs->sum('duration_sec');
        return $totalTime >= 60 ? self::SCORE_WEIGHTS['total_time'] : 0;
    }

    // その他のスコア計算メソッド...
}
```

### 2.2 PDFファイル管理
```php
// PDFService.php
class PDFService
{
    private $storage;
    private $validator;

    public function __construct()
    {
        $this->storage = Storage::disk('pdfs');
        $this->validator = new PDFValidator();
    }

    public function uploadPDF($file, $title): PDF
    {
        $this->validator->validate($file);

        $path = $this->storage->putFile('', $file);
        $pageCount = $this->getPageCount($file);

        return PDF::create([
            'title' => $title,
            'path' => $path,
            'page_count' => $pageCount
        ]);
    }

    private function getPageCount($file): int
    {
        $pdf = new \Smalot\PdfParser\Parser();
        $document = $pdf->parseFile($file->path());
        return count($document->getPages());
    }
}
```

### 2.3 閲覧ログ管理
```php
// ViewLogService.php
class ViewLogService
{
    public function recordViewLog($viewLinkId, $pageNumber, $duration)
    {
        DB::transaction(function () use ($viewLinkId, $pageNumber, $duration) {
            ViewLog::create([
                'view_link_id' => $viewLinkId,
                'page_number' => $pageNumber,
                'duration_sec' => $duration
            ]);

            $this->updateViewLinkStats($viewLinkId);
        });
    }

    private function updateViewLinkStats($viewLinkId)
    {
        $viewLink = ViewLink::find($viewLinkId);
        $logs = $viewLink->viewLogs;

        $stats = [
            'total_view_time' => $logs->sum('duration_sec'),
            'last_viewed_at' => now(),
            'view_count' => $logs->count()
        ];

        $viewLink->update($stats);
    }
}
```

## 3. データベース詳細設計

### 3.1 マイグレーション
```php
// 2024_03_20_000001_create_customers_table.php
class CreateCustomersTable extends Migration
{
    public function up()
    {
        Schema::create('customers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamps();
            $table->softDeletes();
        });
    }
}

// 2024_03_20_000002_create_pdfs_table.php
class CreatePdfsTable extends Migration
{
    public function up()
    {
        Schema::create('pdfs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('title');
            $table->string('path');
            $table->integer('page_count');
            $table->timestamps();
            $table->softDeletes();
        });
    }
}
```

### 3.2 モデル定義
```php
// Customer.php
class Customer extends Model
{
    use HasUuids;

    protected $fillable = ['name', 'email'];

    public function viewLinks()
    {
        return $this->hasMany(ViewLink::class);
    }
}

// PDF.php
class PDF extends Model
{
    use HasUuids;

    protected $fillable = ['title', 'path', 'page_count'];

    public function viewLinks()
    {
        return $this->hasMany(ViewLink::class);
    }
}
```

## 4. API詳細設計

### 4.1 コントローラー
```php
// ViewLogController.php
class ViewLogController extends Controller
{
    public function store(ViewLogRequest $request)
    {
        $validated = $request->validated();
        
        $viewLog = ViewLogService::recordViewLog(
            $validated['view_link_id'],
            $validated['page_number'],
            $validated['duration_sec']
        );

        return response()->json($viewLog, 201);
    }
}

// ViewLogRequest.php
class ViewLogRequest extends FormRequest
{
    public function rules()
    {
        return [
            'view_link_id' => 'required|uuid|exists:view_links,id',
            'page_number' => 'required|integer|min:1',
            'duration_sec' => 'required|integer|min:0'
        ];
    }
}
```

### 4.2 ミドルウェア
```php
// TrackView.php
class TrackView
{
    public function handle($request, Closure $next)
    {
        $response = $next($request);

        if ($request->is('api/view-logs')) {
            $this->updateViewStats($request);
        }

        return $response;
    }

    private function updateViewStats($request)
    {
        $viewLinkId = $request->input('view_link_id');
        Cache::tags(['view_stats'])->increment("view_link:{$viewLinkId}:total_views");
    }
}
```

## 5. セキュリティ詳細設計

### 5.1 認証ミドルウェア
```php
// JwtAuth.php
class JwtAuth
{
    public function handle($request, Closure $next)
    {
        $token = $request->bearerToken();
        
        if (!$token) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        try {
            $payload = JWT::decode($token, config('jwt.secret'), ['HS256']);
            $request->merge(['user' => $payload->user]);
        } catch (Exception $e) {
            return response()->json(['error' => 'Invalid token'], 401);
        }

        return $next($request);
    }
}
```

### 5.2 レート制限
```php
// RateLimit.php
class RateLimit
{
    public function handle($request, Closure $next)
    {
        $key = $request->ip();
        $maxAttempts = 60;
        $decayMinutes = 1;

        if (RateLimiter::tooManyAttempts($key, $maxAttempts)) {
            return response()->json([
                'error' => 'Too many attempts'
            ], 429);
        }

        RateLimiter::hit($key, $decayMinutes * 60);

        return $next($request);
    }
}
```

## 6. テスト詳細設計

### 6.1 ユニットテスト
```php
// ScoringServiceTest.php
class ScoringServiceTest extends TestCase
{
    public function test_calculate_score()
    {
        $viewLink = ViewLink::factory()->create();
        $logs = ViewLog::factory()->count(5)->create([
            'view_link_id' => $viewLink->id
        ]);

        $score = (new ScoringService())->calculateScore($viewLink);

        $this->assertGreaterThanOrEqual(0, $score);
        $this->assertLessThanOrEqual(100, $score);
    }
}
```

### 6.2 統合テスト
```php
// ViewLogControllerTest.php
class ViewLogControllerTest extends TestCase
{
    public function test_store_view_log()
    {
        $viewLink = ViewLink::factory()->create();
        
        $response = $this->postJson('/api/view-logs', [
            'view_link_id' => $viewLink->id,
            'page_number' => 1,
            'duration_sec' => 30
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('view_logs', [
            'view_link_id' => $viewLink->id,
            'page_number' => 1
        ]);
    }
}
``` 