import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.component.html',
  styles: [`
    .login-page {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: var(--dark);
      padding: 24px;
    }
    .login-card {
      background: var(--card);
      border-radius: var(--radius-xl);
      padding: 40px;
      width: 100%;
      max-width: 420px;
      box-shadow: 0 24px 64px rgba(0,0,0,.25);
    }
    .login-card__header { text-align: center; margin-bottom: 32px; }
    .login-card__logo {
      width: 64px; height: 64px;
      margin: 0 auto 16px;
      border-radius: 16px;
      background: linear-gradient(135deg, var(--primary), #8BA4FF);
      display: flex; align-items: center; justify-content: center;
      font-size: 28px;
    }
    .login-card__header h1 {
      font-size: 28px; font-weight: 800; color: var(--text);
      letter-spacing: -.5px; margin-bottom: 6px;
    }
    .login-card__header p { font-size: 14px; color: var(--muted); }
    .login-form { display: flex; flex-direction: column; gap: 18px; }
    .login-btn { width: 100%; padding: 14px; font-size: 15px; margin-top: 4px; }
    .login-security {
      text-align: center; margin-top: 24px;
      font-size: 12px; color: var(--muted);
      padding: 10px; background: var(--surface);
      border-radius: var(--radius);
    }
    .login-error {
      color: var(--danger); font-size: 13px; text-align: center;
      padding: 8px; background: var(--danger-light); border-radius: 8px;
    }
  `],
})
export class LoginComponent {
  email = '';
  password = '';
  loading = false;
  error = '';

  constructor(private auth: AuthService, private router: Router) {}

  login(): void {
    this.error = '';
    this.loading = true;
    this.auth.login(this.email, this.password).subscribe({
      next: () => {
        this.loading = false;
        this.router.navigate(['/dashboard']);
      },
      error: () => {
        this.loading = false;
        this.error = 'Identifiants incorrects ou serveur indisponible.';
      },
    });
  }
}
