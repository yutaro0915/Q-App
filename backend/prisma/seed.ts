import { PrismaClient, Faculty, PostCategory } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Seeding database...')

  // Create test users
  const hashedPassword = await bcrypt.hash('password123', 10)
  
  const user1 = await prisma.user.create({
    data: {
      username: 'testuser1',
      email: 'test1@s.kyushu-u.ac.jp',
      passwordHash: hashedPassword,
      displayName: 'テストユーザー1',
      faculty: Faculty.ENGINEERING,
      grade: 3,
      circle: 'テニス部',
      emailVerified: true,
    },
  })

  const user2 = await prisma.user.create({
    data: {
      username: 'testuser2', 
      email: 'test2@s.kyushu-u.ac.jp',
      passwordHash: hashedPassword,
      displayName: 'テストユーザー2',
      faculty: Faculty.SCIENCE,
      grade: 2,
      circle: 'サッカー部',
      emailVerified: true,
    },
  })

  // Create test posts
  await prisma.post.createMany({
    data: [
      {
        userId: user1.userId,
        category: PostCategory.CLASS,
        content: '線形代数の授業についての質問があります。どなたか教えてください！',
        isAnonymous: false,
      },
      {
        userId: user2.userId,
        category: PostCategory.CLUB,
        content: '新歓イベントの告知です。皆さんお気軽にご参加ください！',
        isAnonymous: false,
      },
    ],
  })

  console.log('✅ Database seeded successfully!')
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })