#include <sys/time.h>
#include <sys/event.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    struct kevent event;
    struct kevent change;
    int fd, kq, nev;
    if ((fd = open(argv[1], O_RDONLY)) == -1) return 1;
    EV_SET(&change, fd, EVFILT_VNODE , EV_ADD
                                     | EV_ENABLE
                                     | EV_DISABLE
                                     | EV_CLEAR
                                     | EV_DELETE
                                     | EV_EOF
                                     | EV_RECEIPT
                                     | EV_DISPATCH
                                     | EV_ONESHOT,
                                       NOTE_DELETE
                                     | NOTE_RENAME
                                     | NOTE_EXTEND
                                     | NOTE_ATTRIB
                                     | NOTE_LINK
                                     | NOTE_REVOKE
                                     | NOTE_WRITE, 0, 0);
    if ((kq = kqueue()) == -1) return 1;
    nev = kevent(kq, &change, 1, &event, 1, NULL);
    if (nev < 0) { return 1; } else if (nev > 0) { if (event.flags & EV_ERROR) { return 1; } }
    close(kq);
    return 0;
}
