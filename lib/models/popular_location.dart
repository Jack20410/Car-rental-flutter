class PopularLocation {
  final int id;
  final String name;
  final String image;
  final String description;
  String carCount;

  PopularLocation({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    this.carCount = 'Loading...',
  });

  static List<PopularLocation> getSampleLocations() {
    return [
      PopularLocation(
        id: 1,
        name: 'Ho Chi Minh City',
        image:
            'https://nld.mediacdn.vn/291774122806476800/2024/8/16/tp-65-1723817004792851519414.jpg',
        description: 'Vietnam\'s largest city with diverse vehicle options',
      ),
      PopularLocation(
        id: 2,
        name: 'Ha Noi',
        image:
            'https://images.contentstack.io/v3/assets/blt1306150c2c4003bc/bltd403157dcd0ef9a3/660caf8a6c4a3972dfe468d3/00-what-to-see-and-do-in-hanoi-getty-cropped.jpg',
        description: 'The capital city with extensive car rental services',
      ),
      PopularLocation(
        id: 3,
        name: 'Da Nang',
        image:
            'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?ixlib=rb-4.0.3',
        description: 'Coastal city with modern rental fleet',
      ),
      PopularLocation(
        id: 4,
        name: 'Nha Trang',
        image:
            'https://baokhanhhoa.vn/file/e7837c02857c8ca30185a8c39b582c03/012025/z6223362576777_15a21ef00a73b25851a3972d86795475_20250113104122.jpg',
        description: 'Beach resort city with convenient rental options',
      ),
      PopularLocation(
        id: 5,
        name: 'Quy Nhon',
        image:
            'https://benhvienquynhon.gov.vn/wp-content/uploads/2023/05/bai-tam-quy-nhon.jpg',
        description: 'Emerging coastal destination with quality vehicles',
      ),
    ];
  }
}
