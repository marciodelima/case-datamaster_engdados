import { Component, Input } from '@angular/core';
import { ChatService } from '../../services/chat.service';

@Component({
  selector: 'app-chat',
  templateUrl: './chat.component.html',
  styleUrls: ['./chat.component.css']
})
export class ChatComponent {
  @Input() cpf: string = '';
  pergunta: string = '';
  resposta: string = '';

  constructor(private chatService: ChatService) {}

  enviar(): void {
    this.chatService.enviarPergunta(this.cpf, this.pergunta).subscribe(resp => this.resposta = resp);
  }
}

