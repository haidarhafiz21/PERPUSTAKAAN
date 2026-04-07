import { useState } from "react";
import axios from "axios";

export default function Login() {

  const [email,setEmail] = useState("");
  const [password,setPassword] = useState("");

  const login = async () => {

    const res = await axios.post("http://localhost:3000/auth/login",{
      email,
      password
    });

    if(res.data.user.role === "admin_website"){
      alert("Login Admin Berhasil");
    }else{
      alert("Bukan admin website");
    }

  };

  return (
    <div>
      <h2>Login Admin</h2>

      <input
        placeholder="Email"
        onChange={(e)=>setEmail(e.target.value)}
      />

      <input
        type="password"
        placeholder="Password"
        onChange={(e)=>setPassword(e.target.value)}
      />

      <button onClick={login}>
        Login
      </button>

    </div>
  );
}