const docsBucketName = "S3 BUCKET FOR DOCS";
const bucketRegion = "REGION";
const IdentityPoolId = "COGNITO ID POOL ID";

AWS.config.update({
    region: bucketRegion,
    credentials: new AWS.CognitoIdentityCredentials({
        IdentityPoolId: IdentityPoolId
    })
});

const s3 = new AWS.S3({
    apiVersion: "2006-03-01",
    params: { Bucket: docsBucketName }
});

function listDocs() {
    s3.listObjects(function (err, data) {
        if (err) {
            return alert("There was an error viewing your documents: " + err.message);
        }
        // 'this' references the AWS.Response instance that represents the response
        const href = this.request.httpRequest.endpoint.href;
        const bucketUrl = href + docsBucketName + "/";

        const docs = data.Contents.map(function (doc) {
            const docKey = doc.Key;
            return getHtml([
                "<span>",
                "<div>",
                "<p>",
                doc.Key,
                "</p>",
                "</div>",
                "<div>",
                "<button id=\"deletedoc\" onclick=\"deleteDoc('" +
                docKey +
                "')\">",
                "ファイルを削除",
                "</button>",
                "</div>",
                "</span>"
            ]);
        });
        const message = docs.length
            ? "<p>削除する場合はファイル名の下の「ファイルを削除」ボタンをクリックしてください。</p>"
            : "<p>ファイルが存在しません。ファイルをアップロードしてください。</p>";
        const htmlTemplate = [
            "<div>",
            "<h2>",
            `S3 Bucket: ${docsBucketName}`,
            "</h2>",
            "</div>",
            message,
            "<div>",
            getHtml(docs),
            "</div>",
            "<div>",
            '<label for="docupload">アップロードするファイルを選択してください。</label>',
            "</div>",
            "<div>",
            '<input id="docupload" type="file" accept=".pdf">',
            "</div>",
            "<div>",
            '<button id="adddoc" onclick="addDoc()">',
            "ファイルをアップロード",
            "</button>",
            "</div>"
        ];
        document.getElementById("app").innerHTML = getHtml(htmlTemplate);
    });
}

function addDoc() {
    const files = document.getElementById("docupload").files;

    if (!files.length) {
        return alert("ファイルを選択してください。");
    }

    const file = files[0];
    const fileName = file.name;
    const str_array = fileName.split(".pdf")

    // Reject s3-unsafe filename
    if (str_array[0].match(/[^A-Za-z0-9!\-_.*'()/]/)) {
        const obj = document.getElementById("docupload");
        obj.value = "";
        return alert(fileName + " ファイル名に半角英数字記号以外が含まれています。");
    }

    // Use S3 ManagedUpload class as it supports multipart uploads
    const upload = new AWS.S3.ManagedUpload({
        params: {
            Bucket: docsBucketName,
            Key: fileName,
            Body: file
        }
    });

    const promise = upload.promise();

    promise.then(
        function (data) {
            alert("アップロードに成功しました。");
            listDocs();
        },
        function (err) {
            return alert("アップロード中にエラーが発生しました: ", err.message);
        }
    );
}

function deleteDoc(fileName) {
    window.confirm(fileName + "を削除しますか？");
    s3.deleteObject({ Key: fileName }, function (err, data) {
        if (err) {
            return alert("削除中にエラーが発生しました: ", err.message);
        }
        alert(fileName + "を削除しました。");
        listDocs();
    });
}