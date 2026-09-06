# Assemblyhook

An x86-64 Linux program in NASM that opens a TCP socket and sends an HTTP POST to a Discord webhook, with raw syscalls and no libc.

I wrote it in June 2024 to see what an HTTP library is doing underneath: opening a socket with sys_socket, filling in a sockaddr_in by hand, sys_connect, and sending the request bytes with sys_sendto in a loop until they've all gone. It's 122 lines and seven syscalls: read, write, socket, connect, sendto, close and exit.

## Run it

    nasm -f elf64 discord_webhook_bot.asm -o webhook.o
    ld webhook.o -o webhook
    ./webhook

That's the intended build. As the file stands, nasm stops on two lines; see below.

## What I learnt

- Registers, the stack and heap, and the x86-64 syscall calling convention
- Creating and connecting sockets at the syscall level
- HTTP request formatting: headers and body have to be exact or the server rejects it
- .data against .bss, db for strings and resb for buffers
- Null-terminated strings by hand

## Rough edges

It's a sketch of the bot rather than the bot, and I've left the file as it was in 2024.

- parse_ip doesn't parse. It writes 93.184.216.34 into the ip buffer, which was example.com's address, not Discord's, and prepare_http_request is a bare ret, so what goes down the socket is the bytes of "POST " and a null, six in all.
- read_string sets rdi to 0 for stdin before copying it into rsi, so the buffer pointer is lost and the read goes to address 0. print_string loses its string the same way and never sets a length.
- connect gets the struct's address as the fd and the fd as the address, and nothing checks a return value.
- nasm rejects pusha and popa, which don't exist in 64-bit mode, and mov [rdi+4], dword [rsi], which is memory to memory.
- The buffers are 256 bytes with no bounds checks, and it's plain HTTP on port 80 where Discord needs HTTPS.
