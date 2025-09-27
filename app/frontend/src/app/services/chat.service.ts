import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class ChatService {
  constructor(private http: HttpClient) {}

  enviarPergunta(cpf: string, pergunta: string): Observable<string> {
    return this.http.post<string>(`/api/clientes/${cpf}/chat`, { pergunta });
  }
}

