import { useEffect,useState } from "react";
import axios from "axios";

export default function Books(){

  const [books,setBooks] = useState([]);

  const loadBooks = async()=>{
    const res = await axios.get("http://localhost:3000/books");
    setBooks(res.data);
  };

  useEffect(()=>{
    loadBooks();
  },[]);

  return(
    <div>

      <h2>Daftar Buku</h2>

      {books.map(b=>(
        <div key={b.id}>
          {b.judul} - Stok {b.stok}
        </div>
      ))}

    </div>
  );
}