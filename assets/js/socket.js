// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

//var player_id = window.sessionStorage.getItem('player_id');
//console.log("player id fetched: ", player_id);
//if (player_id === null)
//{
//  player_id = 3;
//  console.log("player id updated: ", player_id);
//}


var player_id;
var weapon_id;
//window.onbeforeunload = function () {
//  leave(channel);
//};

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {})
//let channel = socket.channel("room:lobby", {"player_id": player_id})

//
//window.addEventListener('beforeunload', (event) => {
//  leave(channel);
//});



channel.join().receive("error", resp => { console.log("Unable to join", resp) })
              .receive("ok", response => { handleSuccessfulJoin( channel); });

//channel.join()
//  .receive("ok", resp => { console.log("Joined successfully", resp) })
//  .receive("error", resp => { console.log("Unable to join", resp) })


let handleSuccessfulJoin = function( channel) {
  console.log("joined successfully");

  //if (player_id == 3)
  //{
    channel.push("get_id", {}).receive("ok", (reply) => set_player(reply.player_id));

    //window.sessionStorage.setItem('player_id', player_id))
  //}

  channel.on("result_found", payload => {
      if (payload.message == 0)
      {
        document.getElementsByTagName('p')[0].innerHTML = "It's a draw!!";
      }
      else {
        if (payload.message == player_id)
        {
          document.getElementsByTagName('p')[0].innerHTML = "You won!!";
        }
        else {

          document.getElementsByTagName('p')[0].innerHTML = "You lost!!";
        }
      }


      document.getElementById("replay").style.display = "block";
      document.getElementById("replay").addEventListener('click', replay);
  });

  channel.on("waiting_for_player", payload => {

      document.getElementsByTagName('p')[0].innerHTML = "Waiting for the second player..";

   });

  channel.on("ready_for_match", payload => {

      set_on_click();

      document.getElementsByTagName('p')[0].innerHTML = "Choose your weapon.";

   });

   channel.on("replay", payload => {
       document.getElementById("replay").style.display = "none";
       document.getElementsByTagName('p')[0].innerHTML = "Choose your weapon.";
       document.getElementById(weapon_id).className = "w3-grayscale-max";
       set_on_click();
    });
};

Window.onunload = function(){
  leave(channel);
 }


function set_player(player) {
  player_id = player;
  };

function set_on_click () {

  var matches = document.querySelectorAll(".w3-grayscale-max");
  matches.forEach(function(userItem) {
    userItem.addEventListener('click', choose_weapon);
  });

}

function replay (){
  //clean choen weapons
  channel.push("replay", {});
  //restore images and text
}

function remove_click() {

  var matches = document.querySelectorAll(".w3-grayscale-max");
  matches.forEach(function(userItem) {
    userItem.removeEventListener('click', choose_weapon);
  });

}

function choose_weapon(event) {
    weapon_id = event.target.getAttribute("id");
    var weapon = event.target.getAttribute("value");
    event.target.setAttribute("class", "");
    channel.push("choose_weapon", { weapon: weapon});
    event.target.removeEventListener('click', choose_weapon);
    remove_click();
  };

let handleFailedJoin = function(response) {
};

function leave (channel) {
  channel.push("leave");
}

export default socket
