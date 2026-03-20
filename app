// FirebaseのライブラリをCDNから直接インポート
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-app.js";
import { getAuth, signInWithEmailAndPassword, signOut, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-auth.js";
import { getFirestore, collection, getDocs } from "https://www.gstatic.com/firebasejs/10.8.1/firebase-firestore.js";

// ⚠️ ここは後でFirebaseコンソールから取得したあなたの鍵（設定）に書き換えます
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
};

// Firebaseの初期化
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// HTMLの要素を取得
const loginSection = document.getElementById('login-section');
const quotesSection = document.getElementById('quotes-section');
const loginBtn = document.getElementById('login-btn');
const logoutBtn = document.getElementById('logout-btn');
const errorMsg = document.getElementById('error-msg');
const quotesContainer = document.getElementById('quotes-container');

// ログイン状態を監視する（ページを開いた時や、ログイン/ログアウトした時に自動で走る）
onAuthStateChanged(auth, (user) => {
  if (user) {
    // ログインしている場合：画面を切り替えてデータを取得
    loginSection.classList.add('hidden');
    quotesSection.classList.remove('hidden');
    fetchQuotes();
  } else {
    // ログインしていない場合：ログイン画面を表示
    loginSection.classList.remove('hidden');
    quotesSection.classList.add('hidden');
    quotesContainer.innerHTML = ''; // 中身をリセット
  }
});

// ログインボタンの処理
loginBtn.addEventListener('click', () => {
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;

  signInWithEmailAndPassword(auth, email, password)
    .then(() => {
      errorMsg.textContent = ''; // エラーを消す
    })
    .catch((error) => {
      console.error("ログインエラー:", error);
      errorMsg.textContent = "ログインに失敗しました。メアドかパスワードが違います。";
    });
});

// ログアウトボタンの処理
logoutBtn.addEventListener('click', () => {
  signOut(auth);
});

// データベースからネタ発言を取得して画面に表示する処理
async function fetchQuotes() {
  quotesContainer.innerHTML = '<p>読み込み中...</p>';
  try {
    // "quotes"という名前の金庫（コレクション）からデータを全部取ってくる
    const querySnapshot = await getDocs(collection(db, "quotes"));
    quotesContainer.innerHTML = ''; // 読み込み中の文字を消す

    querySnapshot.forEach((doc) => {
      const data = doc.data();
      
      // HTMLのカードを作成して追加
      const div = document.createElement('div');
      div.className = 'quote-card';
      div.innerHTML = `
        <div class="quote-text">「${data.text}」</div>
        <div class="quote-author">ー ${data.member}</div>
      `;
      quotesContainer.appendChild(div);
    });
  } catch (error) {
    console.error("データ取得エラー:", error);
    quotesContainer.innerHTML = '<p>データの取得に失敗しました。</p>';
  }
}
