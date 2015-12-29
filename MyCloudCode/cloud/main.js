require("cloud/app.js");
var _ = require("underscore");

// layer initialization
var fs = require('fs');
var layer = require('cloud/layer-parse-module/layer-module.js');

//main.js
var layerProviderID = 'layer:///providers/f809bf40-5774-11e5-9dfe-e22600005d8e';  // Should have the format of layer:///providers/<GUID>
var layerKeyID = 'layer:///keys/1a949c06-8240-11e5-9afc-1ce4ee0879ad';   // Should have the format of layer:///keys/<GUID>
var privateKey = fs.readFileSync('cloud/layer-parse-module/keys/layer-key.js');
layer.initialize(layerProviderID, layerKeyID, privateKey);

//main.js
Parse.Cloud.define("generateToken", function(request, response) {
    var currentUser = request.user;
    if (!currentUser) throw new Error('You need to be logged in!');
    var userID = currentUser.id;
    var nonce = request.params.nonce;
    if (!nonce) throw new Error('Missing nonce parameter');
        response.success(layer.layerIdentityToken(userID, nonce));
});

// twilio 
var twilioAccountSid = 'AC239aeeaeb61804c5fb1565cf5d9deb7a';
var twilioAuthToken = '57857f48b87cf218f117518d351fc632';
var twilioPhoneNumber = '+1 415-599-2671';
var secretPasswordToken = 'Something-Random-Here';

var twilio = require('twilio')(twilioAccountSid, twilioAuthToken);

Parse.Cloud.define("sendCode", function(req, res) {
	if (!req.params.phoneNumber || req.params.phoneNumber.length != 10) return res.error('Invalid Parameters');
	Parse.Cloud.useMasterKey();
	var query = new Parse.Query(Parse.User);
	query.equalTo('username', req.params.phoneNumber + "");
	query.first().then(function(result) {
		var min = 1000; var max = 9999;
		var num = Math.floor(Math.random() * (max - min + 1)) + min;

		if (result) {
			result.setPassword(secretPasswordToken + num);
			result.save().then(function() {
				res.success({"code":num});
			}, function(err) {
				res.error(err);
			});
		} else {
			var user = new Parse.User();
			user.setUsername(req.params.phoneNumber);
			user.setPassword(secretPasswordToken + num);
			user.setACL({}); 
			user.save().then(function(a) {
				res.success({"code":num});
			}, function(err) {
				res.error(err);
			});
		}
	}, function (err) {
		res.error(err);
	});
});

Parse.Cloud.define("logIn", function(req, res) {
	Parse.Cloud.useMasterKey();
	if (req.params.phoneNumber && req.params.codeEntry) {
        // todo: check if user exists, if not create
        
		Parse.User.logIn(req.params.phoneNumber, secretPasswordToken + req.params.codeEntry).then(function (user) {
			res.success(user._sessionToken);
		}, function (err) {
			res.error(err);
		});
	} else {
		res.error('Invalid parameters.');
	}
});

Parse.Cloud.define("deleteUser", function(req, res) {
    Parse.Cloud.useMasterKey();
    if (!req.params.userId) {
        res.error('Invalid parameters: userId requred');
        return;
    }

    var userId = req.params.userId;
	console.log("user id: " + userId);
    
	var thisUserQuery = new Parse.Query(Parse.User);
	thisUserQuery.equalTo("objectId", userId);
	thisUserQuery.find().then(function(users){
		
		if (users.length == 0) {
			res.error("ERROR: no user with ID: " + userId);
		} else {

			var user = users[0];
			
			// delete all the ads and favorites associated with a user
			var adQuery = new Parse.Query("Ad");
			adQuery.equalTo("username", user);
			var adsToDelete;
			adQuery.find().then(function(adResults) {
				console.log("querying ads: " + adResults.length);
				if (typeof adResults !== "undefined" && adResults.length > 0) {

					console.log("inside if in querying ads");
					adsToDelete = adResults;
					var adPromises = [];
				
					// cycle through each ad and delete favorites connected with them
					console.log(adResults[0].get("lookingFor"));
					_.each(adResults, function(adResult) {
						var favoriteAdQuery = new Parse.Query("Favorites");
						favoriteAdQuery.equalTo("adPointer", adResult);
						
						favoriteAdQuery.find().then(function(favorites){
							var deleteFavPromise = Parse.Object.destroyAll(favorites);
							adPromises.push(deleteFavPromise);
						});
					});
					
					return Parse.Promise.when(adPromises);
				} else {
					return Parse.Promise.as("No Ads To Delete");
				}
				
			}).then(function(){
				if (typeof adsToDelete !== "undefined" && adsToDelete.length > 0){
					// delete the ads themselves
					return Parse.Object.destroyAll(adsToDelete);
				}

				return Parse.Promise.as("No Ads To Delete");
			}).then(function(){
				
				// delete the user favorites
				var Favorites = Parse.Object.extend("Favorites");
				var favUserQuery = new Parse.Query(Favorites);
				favUserQuery.equalTo("userPointer", user);
				return favUserQuery.find()
				
			}).then(function(favorites){
				if (typeof favorites !== "undefined" && favorites.length > 0) {
					return Parse.Object.destroyAll(favorites);
				}

				return Parse.Promise.as("No favorites to delete");
			}).then(function(){
				return user.destroy()
			}).then(function(){
				res.success("user deleted with id: " + userId);
			}, function(error){
				res.error(error);
			});
		}
	});
});

function sendCodeSms(phoneNumber, code) {
	var promise = new Parse.Promise();
	twilio.sendSms({
		to: '+1' + phoneNumber,
		from: twilioPhoneNumber,
		body: 'Your login code for Matchboard is ' + code
	}, function(err, responseData) {
		if (err) {
			console.log(err);
			promise.reject(err.message);
		} else {
			promise.resolve();
		}
	});
	return promise;
}
