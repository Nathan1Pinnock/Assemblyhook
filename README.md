# Assemblyhook

Sends a message to a Discord webhook from x86-64 assembly on Linux. No libc — the socket, connect and HTTP request are all done with raw syscalls.

I wrote it to see what actually happens underneath an HTTP library: opening a TCP socket, filling in a `sockaddr_in` by hand, and formatting the request bytes yourself.

## Build and run

    nasm -f elf64 discord_webhook_bot.asm -o webhook.o
    ld webhook.o -o webhook
    ./webhook

It asks for the webhook URL and the message.

## What I learnt

- Registers, the stack and heap, and the x86-64 syscall calling convention
- Creating and connecting sockets at the syscall level
- HTTP request formatting — headers and body have to be exact or the server rejects it
- `.data` vs `.bss`, `db` for strings and `resb` for buffers
- Handling null-terminated strings by hand

Caveat: it's plain HTTP with fixed-size buffers and no bounds checks. Discord webhooks need HTTPS, so treat it as a learning exercise rather than a working bot.
