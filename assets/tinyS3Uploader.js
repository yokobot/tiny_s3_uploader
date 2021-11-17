const docsBucketName = "dev-tiny-s3-uploader-docs";
const bucketRegion = "ap-northeast-1";
const IdentityPoolId = "ap-northeast-1:5e9821ce-f4bb-4d9a-a770-8a4bff4ca65e";

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
  s3.listObjects( function(err, data) {
    if (err) {
      return alert("There was an error viewing your documents: " + err.message);
    }
    // 'this' references the AWS.Response instance that represents the response
    const href = this.request.httpRequest.endpoint.href;
    const bucketUrl = href + docsBucketName + "/";

    const docs = data.Contents.map(function(doc) {
      const docKey = doc.Key;
      // const docUrl = bucketUrl + encodeURIComponent(docKey);
      return getHtml([
        "<span>",
        "<div>",
        "<p>",
        doc.Key,
        "</p>",
        "</div>",
        "<div>",
        "<span onclick=\"deleteDoc('" +
          docKey +
          "')\">",
        "X",
        "</span>",
        "</div>",
        "</span>"
      ]);
    });
    const message = docs.length
      ? "<p>削除する場合はファイル名の下のXをクリックしてください。</p>"
      : "<p>ファイルが存在しません。ファイルをアップロードしてください。</p>";
    const htmlTemplate = [
      message,
      "<div>",
      getHtml(docs),
      "</div>",
      "<div>",
      '<label for="docupload">アップロードするファイルを選択してください</label>',
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
    return alert("Please choose a file to upload first.");
  }
  const file = files[0];
  const fileName = file.name;

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
    function(data) {
      alert("Successfully uploaded doc.");
      listDocs();
    },
    function(err) {
      return alert("There was an error uploading your doc: ", err.message);
    }
  );
}

function deleteDoc(fileName) {
  s3.deleteObject({ Key: fileName }, function(err, data) {
    if (err) {
      return alert("There was an error deleting your doc: ", err.message);
    }
    alert("Successfully deleted doc.");
    listDocs();
  });
}
