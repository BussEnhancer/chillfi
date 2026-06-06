import React from 'react';

export type OrderStatus = 'Delivered' | 'Shipped' | 'Processing' | 'Cancelled' | 'Returned';

interface OrderStatusBadgeProps {
  status: OrderStatus;
}

const OrderStatusBadge: React.FC<OrderStatusBadgeProps> = ({ status }) => {
  const styles: Record<OrderStatus, string> = {
    Delivered: 'bg-green-50 text-green-600',
    Shipped: 'bg-blue-50 text-blue-600',
    Processing: 'bg-amber-50 text-amber-600',
    Cancelled: 'bg-red-50 text-red-600',
    Returned: 'bg-gray-50 text-gray-600',
  };

  return (
    <span className={`text-[10px] font-black uppercase tracking-widest px-2.5 py-1 rounded-md inline-block ${styles[status]}`}>
      {status}
    </span>
  );
};

export default OrderStatusBadge;
