const docsBucketName = "BUCKET_NAME";
const bucketRegion = "REGION";
const IdentityPoolId = "IDENTITY_POOL_ID";

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
      const docUrl = bucketUrl + encodeURIComponent(docKey);
      return getHtml([
        "<span>",
        "<div>",
        '<img style="width:128px;height:128px;" src="' + docUrl + '"/>',
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
      ? "<p>Click on the X to delete the doc.</p>"
      : "<p>You do not have any docs. Please add docs.</p>";
    const htmlTemplate = [
      message,
      "<div>",
      getHtml(docs),
      "</div>",
      '<input id="docupload" type="file" accept="image/*">',
      '<button id="adddoc" onclick="addDoc()">',
      "Add Doc",
      "</button>"
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
