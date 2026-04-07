import { useEffect, useState } from "react";
import axios from "axios";

function App() {

  const [books,setBooks] = useState([]);

  useEffect(()=>{

    loadBooks();

  },[]);

  const loadBooks = async () => {

    try{

      const res = await axios.get("http://localhost:3000/books");
      setBooks(res.data);

    }catch(err){

      console.log(err);

    }

  };

  return (

    <div style={{padding:"40px"}}>

      <h1>Admin Perpustakaan</h1>

      <h2>Daftar Buku</h2>

      <table border="1" cellPadding="10">

        <thead>
          <tr>
            <th>ID</th>
            <th>Judul</th>
            <th>Stok</th>
          </tr>
        </thead>

        <tbody>

          {books.map((b)=>(
            <tr key={b.id}>
              <td>{b.id}</td>
              <td>{b.judul}</td>
              <td>{b.stok}</td>
            </tr>
          ))}

        </tbody>

      </table>

    </div>

  );

}

export default App;