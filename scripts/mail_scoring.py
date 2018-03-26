'''
Quick scoring engine test for mail servers
'''
import smtplib, time, imaplib, random

def checkIMAP(host, user, password, domain, flag):
    serv = imaplib.IMAP4(host, 143)
    # try to connect...
    serv.login(user, password)
    
    serv.select("INBOX")
    status, ids = serv.search(None, "UNSEEN")
    ids = [int(i) for i in ids[0].split()]

    for i in ids:
        status, emails = serv.fetch(i, "(RFC822)")
        for em in emails:
            try:
                if flag in em[1]:
                    return True
            except:
                continue
    raise Exception("Flag not found in inbox")

def checkSMTP(host, user, password, domain, flag):
    smtp = smtplib.SMTP()
    # try to connect...
    smtp.connect(host, 25)
    # try to lgin
    smtp.login(user, password)
    mfrom = "root@{}".format(domain)
    mto = "{}@{}".format(user, domain)
    msg = "From: {}\nTo: {}\nSubject: EMAIL CHECK: {}\n This should be the body!".format(mfrom, mto, flag)
    smtp.sendmail(mfrom, mto, msg)
    smtp.quit()

def pass_check(msg):
    print('\033[92m'+msg)

def fail_check(msg):
    print('\033[91m'+msg)

def main():
    hosts = ["10.80.100.5", "10.80.100.3"]
    user = "student"
    password = "cseclabs"
    domain = "rit.ccdc"
    words = open("/usr/share/dict/words").read().splitlines()
    round_num = 0
    while True:
        flag = random.choice(words)
        print("Started round {} - {}".format(round_num, flag))
        round_num += 1
        with open("log.txt", 'a') as fil:
            for host in hosts:
                try:
                    checkSMTP(host, user, password, domain, flag)
                    msg="Passed SMTP for {}".format(host)
                    pass_check(msg)
                except Exception as E:
                    msg="Failed SMTP for {}: {}".format(host, E)
                    fail_check(msg)
                time.sleep(2)
                try:
                    checkIMAP(host, user, password, domain, flag)
                    msg="Passed IMAP for {}".format(host)
                    pass_check(msg)
                except Exception as E:
                    msg="Failed IMAP for {}: {}".format(host, E)
                    fail_check(msg)
            print("Sleeping for 30")
        time.sleep(30)

if __name__ == '__main__':
    main()
