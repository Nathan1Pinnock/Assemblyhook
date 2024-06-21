section .data
    prompt_webhook db 'Enter Discord webhook URL: ', 0
    prompt_message db 'Enter message to send: ', 0
    webhook_buffer resb 256
    message_buffer resb 256

    http_request db 'POST ', 0
    http_request_len equ $ - http_request

section .bss
    sock resd 1
    sockaddr_in resb 16
    ip resb 4

section .text
    global _start

_start:
    ; Prompt for webhook URL
    mov rdi, prompt_webhook
    call print_string
    mov rdi, webhook_buffer
    call read_string

    ; Prompt for message
    mov rdi, prompt_message
    call print_string
    mov rdi, message_buffer
    call read_string

    ; Parse IP from webhook URL
    mov rsi, webhook_buffer
    call parse_ip
    ; Assume IP is in 'ip' and port in 'sockaddr_in+2'

    ; Create a socket
    xor rax, rax
    mov al, 41           ; sys_socket
    xor rdi, rdi
    mov dil, 2           ; AF_INET
    mov esi, 1           ; SOCK_STREAM
    xor edx, edx         ; Protocol 0
    syscall
    mov [sock], eax

    ; Set up sockaddr_in structure
    mov rax, [sock]
    xor rdi, rdi
    mov rdi, sockaddr_in
    mov word [rdi], 0x02 ; AF_INET
    mov word [rdi+2], 0x5000 ; Port 80 (0x5000)
    mov rsi, ip
    mov [rdi+4], dword [rsi]
    xor rsi, rsi
    mov rsi, [sock]
    mov rdx, sockaddr_in
    mov dl, 16
    ; Connect to the server
    xor rax, rax
    mov al, 42           ; sys_connect
    syscall

    ; Prepare HTTP POST request
    mov rsi, http_request
    call prepare_http_request

    ; Send HTTP POST request
    mov rsi, http_request
    mov rdx, http_request_len
    call send_all

    ; Close socket
    mov rax, 3           ; sys_close
    mov rdi, [sock]
    syscall

    ; Exit
    mov rax, 60          ; sys_exit
    xor rdi, rdi
    syscall

; Functions
print_string:
    mov rax, 1           ; sys_write
    mov rdi, 1           ; file descriptor (stdout)
    syscall
    ret

read_string:
    mov rax, 0           ; sys_read
    mov rdi, 0           ; file descriptor (stdin)
    mov rsi, rdi         ; buffer
    mov rdx, 256         ; max length
    syscall
    ret

parse_ip:
    ; Implement a simple parser to extract IP and port from URL
    ; Assume a fixed IP and port for demonstration
    ; Replace with proper parsing logic
    mov byte [ip], 93
    mov byte [ip+1], 184
    mov byte [ip+2], 216
    mov byte [ip+3], 34
    ret

prepare_http_request:
    ; Prepare the HTTP POST request with the webhook URL and message
    ; This is a simplified example, replace with proper formatting
    ret

send_all:
    pusha
    .send_loop:
        mov rax, 44       ; sys_sendto
        syscall
        sub rdx, rax
        add rsi, rax
        test rdx, rdx
        jnz .send_loop
    popa
    ret
