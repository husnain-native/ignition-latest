class WorkspaceItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String type; // 'chair', 'table', 'room', etc.
  final bool isAvailable;
  final List<String> amenities;
  final int
  capacity; // For rooms: number of people, for tables: number of seats

  WorkspaceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.type,
    required this.isAvailable,
    required this.amenities,
    required this.capacity,
  });

  // Dummy data generator
  static List<WorkspaceItem> getDummyItems() {
    return [
      // Rooms
      WorkspaceItem(
        id: 'r1',
        name: 'Executive Suite',
        description: 'Luxurious meeting room with panoramic city view',
        price: 100.0,
        image: 'assets/images/room1.jpg',
        type: 'room',
        isAvailable: true,
        amenities: [
          'Projector',
          'Whiteboard',
          'Video Conference',
          'Coffee Machine',
        ],
        capacity: 8,
      ),
      WorkspaceItem(
        id: 'r2',
        name: 'Focus Room',
        description: 'Private room perfect for concentrated work',
        price: 50.0,
        image: 'assets/images/room2.jpg',
        type: 'room',
        isAvailable: true,
        amenities: ['Soundproof', 'Ergonomic Chair', 'Desk', 'High-Speed WiFi'],
        capacity: 2,
      ),

      // Tables
      WorkspaceItem(
        id: 't1',
        name: 'Collaborative Table',
        description: 'Large table perfect for team collaboration',
        price: 30.0,
        image: 'assets/images/table1.jpg',
        type: 'table',
        isAvailable: true,
        amenities: ['Power Outlets', 'USB Ports', 'Adjustable Height'],
        capacity: 6,
      ),
      WorkspaceItem(
        id: 't2',
        name: 'Window Desk',
        description: 'Individual desk with natural lighting',
        price: 15.0,
        image: 'assets/images/table2.jpg',
        type: 'table',
        isAvailable: false,
        amenities: ['Power Outlet', 'Task Light', 'Storage'],
        capacity: 1,
      ),

      // Chairs
      WorkspaceItem(
        id: 'c1',
        name: 'Ergonomic Chair',
        description: 'Premium ergonomic chair with lumbar support',
        price: 10.0,
        image: 'assets/images/chair1.jpg',
        type: 'chair',
        isAvailable: true,
        amenities: ['Adjustable Height', 'Lumbar Support', 'Armrests'],
        capacity: 1,
      ),
      WorkspaceItem(
        id: 'c2',
        name: 'Standing Desk Setup',
        description: 'Complete standing desk with ergonomic stool',
        price: 25.0,
        image: 'assets/images/chair2.jpg',
        type: 'chair',
        isAvailable: true,
        amenities: ['Height Adjustable', 'Anti-Fatigue Mat', 'Monitor Stand'],
        capacity: 1,
      ),
    ];
  }
}
