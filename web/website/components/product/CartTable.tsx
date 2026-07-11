import React from 'react';
import CartItem from './CartItem';
import CartActionBar from './CartActionBar';

const cartData = [
  {
    image: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=400',
    name: 'Samsung Galaxy S24 FE 5G (8GB+256GB)',
    size: '256GB',
    color: 'Graphite',
    price: 39999,
    oldPrice: 54999,
    discount: '27%',
    quantity: 1,
    subtotal: 39999
  },
  {
    image: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?auto=format&fit=crop&q=80&w=400',
    name: 'boAt Airdopes 141 TWS Earbuds',
    size: 'One Size',
    color: 'Active Black',
    price: 1299,
    oldPrice: 2990,
    discount: '57%',
    quantity: 1,
    subtotal: 1299
  },
  {
    image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
    name: 'Sony WH-1000XM5 Wireless Headphones',
    size: 'One Size',
    color: 'Midnight Black',
    price: 24990,
    oldPrice: 34990,
    discount: '29%',
    quantity: 1,
    subtotal: 24990
  },
  {
    image: 'https://images.unsplash.com/photo-1508685096489-7aac2715a99a?auto=format&fit=crop&q=80&w=400',
    name: 'Mi Smart Band 8 Pro AMOLED',
    size: 'One Size',
    color: 'Black',
    price: 2499,
    oldPrice: 3999,
    discount: '37%',
    quantity: 1,
    subtotal: 2499
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
