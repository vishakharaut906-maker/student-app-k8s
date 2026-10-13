# 🚀 AWS S3 → Lambda Trigger Practical

## 🎯 Objective

Create an AWS Lambda function that is automatically triggered whenever a new object/file is uploaded to an S3 bucket.

### Architecture

```text
User Uploads File
       ↓
   S3 Bucket
       ↓
Object Created Event
       ↓
     Lambda
       ↓
CloudWatch Logs
```

---

# 1️⃣ Create S3 Bucket

Go to:

```text
AWS Console
→ S3
→ Create bucket
```

### Bucket Name

Use a globally unique name:

```text
sourabh-lambda-demo-2026-12345
```

> Bucket names must be globally unique. If this name is already taken, use another name.

### Recommended Settings

Keep the default settings:

```text
Object Ownership: ACLs disabled

Block Public Access: Enabled

Bucket Versioning: Disabled

Encryption: SSE-S3
```

Click:

```text
Create bucket
```

---

# 2️⃣ Create Lambda Function

Go to:

```text
AWS Console
→ Lambda
→ Functions
→ Create function
```

Select:

```text
Author from scratch
```

### Function Name

```text
s3-upload-trigger
```

### Runtime

Select:

```text
Python 3.x
```

### Execution Role

Select:

```text
Create a new role with basic Lambda permissions
```

Click:

```text
Create function
```

---

# 3️⃣ Add Lambda Python Code

Inside the Lambda function:

```text
Code
→ Code source
```

Delete the existing sample code and paste:

```python
import json

def lambda_handler(event, context):

    print("S3 file uploaded!")

    bucket = event['Records'][0]['s3']['bucket']['name']
    file_name = event['Records'][0]['s3']['object']['key']

    print("Bucket:", bucket)
    print("File:", file_name)

    return {
        'statusCode': 200,
        'body': json.dumps('File processed successfully')
    }
```

Click:

```text
Deploy
```

---

# 4️⃣ Configure S3 Trigger

Go to:

```text
S3
→ Your Bucket
→ Properties
```

Scroll down to:

```text
Event notifications
```

Click:

```text
Create event notification
```

### Event Name

```text
s3-upload-event
```

### Event Type

Select:

```text
☑ All object create events
```

This means:

> Whenever an object is uploaded/created in the S3 bucket, Lambda will be triggered.

### Destination

Select:

```text
Lambda Function
```

Choose:

```text
s3-upload-trigger
```

Click:

```text
Save changes
```

---

# 5️⃣ Create Test File

On your local computer, create a file:

```text
test.txt
```

Put some content inside it:

```text
Hello Lambda
```

Save the file.

---

# 6️⃣ Upload Object to S3

Go to:

```text
AWS Console
→ S3
→ Your Bucket
→ Objects
```

Click:

```text
Upload
```

Then:

```text
Add files
```

Select:

```text
test.txt
```

You should see:

```text
Files and folders

test.txt
```

Click:

```text
Upload
```

Wait until you see:

```text
Upload succeeded
```

Then click:

```text
Close
```

You should now see:

```text
Objects

test.txt
```

---

# 7️⃣ What Happens After Upload?

You do **not** need to manually run Lambda.

The process is automatic:

```text
Upload test.txt
       ↓
   S3 Bucket
       ↓
Object Created Event
       ↓
Lambda Trigger
       ↓
Lambda Function Executes
       ↓
CloudWatch Logs
```

---

# 8️⃣ Check Lambda Logs

Go to:

```text
AWS Console
→ Lambda
→ s3-upload-trigger
→ Monitor
```

Click:

```text
View CloudWatch logs
```

Open the latest log stream.

You should see something similar to:

```text
S3 file uploaded!
Bucket: sourabh-lambda-demo-2026-12345
File: test.txt
```

This confirms that the Lambda function was triggered successfully.

---

# 9️⃣ Test With Another File

Create another file:

```text
hello.txt
```

Upload it to the same S3 bucket.

Lambda will automatically execute again.

CloudWatch Logs should show:

```text
S3 file uploaded!
Bucket: sourabh-lambda-demo-2026-12345
File: hello.txt
```

---

# 🔟 Final Architecture

```text
                    Upload File
                         │
                         ▼
                 ┌──────────────┐
                 │  S3 Bucket   │
                 └──────┬───────┘
                        │
                 Object Created
                        │
                        ▼
                 ┌──────────────┐
                 │    Lambda    │
                 │   Python     │
                 └──────┬───────┘
                        │
                        ▼
                 ┌──────────────┐
                 │  CloudWatch  │
                 │     Logs     │
                 └──────────────┘
```

---


### Q
