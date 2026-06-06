import React from 'react';
import CartItem from './CartItem';
import CartActionBar from './CartActionBar';

const cartData = [
  {
    image: 'https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&q=80&w=400',
    name: "Nike Air Max Excee Men's Sneakers",
    size: '8 UK',
    color: 'Black/White',
    price: 5999,
    oldPrice: 7999,
    discount: '25%',
    quantity: 1,
    subtotal: 5999
  },
  {
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
    name: 'Fastrack Men Black Analog Watch',
    size: 'Free',
    color: 'Black/Brown',
    price: 2495,
    oldPrice: 3995,
    discount: '38%',
    quantity: 1,
    subtotal: 2495
  },
  {
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=400',
    name: 'Puma Smashic Unisex Sneakers',
    size: '7 UK',
    color: 'White',
    price: 2299,
    oldPrice: 3299,
    discount: '25%',
    quantity: 1,
    subtotal: 2299
  },
  {
    image: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&q=80&w=400',
    name: 'Lavie Women Green Satchel Bag',
    size: 'Free',
    color: 'Green',
    price: 1799,
    oldPrice: 2999,
    discount: '25%',
    quantity: 1,
    subtotal: 1799
  }
];

const CartTable: React.FC = () => {
  return (
    <div className="bg-white rounded-[24px] border border-[#ECECEC] p-6 shadow-sm overflow-hidden">
      {/* Header */}
      <div className="flex items-center pb-6 border-b border-[#F8F7FC] text-[10px] font-black text-gray-400 uppercase tracking-[0.1em]">
        <div className="w-12"></div>
        <div className="flex-1">Product</div>
        <div className="w-40">Price</div>
        <div className="w-40">Quantity</div>
        <div className="w-32">Subtotal</div>
        <div className="w-12"></div>
      </div>

      {/* Rows */}
      <div className="divide-y divide-[#F8F7FC]">
        {cartData.map((item, i) => (
          <CartItem key={i} {...item} />
        ))}
      </div>

      {/* Global Actions */}
      <CartActionBar />
    </div>
  );
};

export default CartTable;
