import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface LoginResponse {
  access: string;
  refresh?: string;
  user?: { email: string; role: string; nom?: string };
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly api = `${environment.apiUrl}/auth`;

  constructor(private http: HttpClient) {}

  login(email: string, password: string): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(`${this.api}/login/`, { email, password }).pipe(
      tap(res => {
        localStorage.setItem('access', res.access);
        if (res.user) localStorage.setItem('user', JSON.stringify(res.user));
      })
    );
  }

  logout(): void {
    localStorage.removeItem('access');
    localStorage.removeItem('user');
  }

  isLoggedIn(): boolean {
    return !!localStorage.getItem('access');
  }

  getUserName(): string {
    try {
      const u = JSON.parse(localStorage.getItem('user') || '{}');
      return u.nom || u.email || 'Admin';
    } catch {
      return 'Admin';
    }
  }
}
