import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { SidebarComponent } from '../shared/components/sidebar.component';

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [RouterOutlet, SidebarComponent],
  template: `
    <div class="ds-layout">
      <app-sidebar />
      <div class="main">
        <router-outlet />
      </div>
    </div>
  `,
})
export class ShellComponent {}
