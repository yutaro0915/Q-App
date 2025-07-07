import dotenv from 'dotenv';

dotenv.config();

interface Config {
  env: string;
  port: number;
  database: {
    url: string;
  };
  redis: {
    url: string;
  };
  jwt: {
    secret: string;
    expiresIn: string;
  };
  email: {
    server: string;
    port: number;
    username: string;
    password: string;
    from: string;
  };
  cors: {
    origins: string[];
  };
  upload: {
    maxSize: number;
    folder: string;
  };
  aws?: {
    accessKeyId: string;
    secretAccessKey: string;
    region: string;
    s3Bucket: string;
  };
}

export const config: Config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '8000', 10),
  
  database: {
    url: process.env.DATABASE_URL || 'mysql://qapp_user:qapp_password@localhost:3306/qapp_db'
  },
  
  redis: {
    url: process.env.REDIS_URL || 'redis://localhost:6379'
  },
  
  jwt: {
    secret: process.env.JWT_SECRET || 'your-jwt-secret-key',
    expiresIn: process.env.JWT_EXPIRE_MINUTES ? `${process.env.JWT_EXPIRE_MINUTES}m` : '24h'
  },
  
  email: {
    server: process.env.MAIL_SERVER || 'smtp.gmail.com',
    port: parseInt(process.env.MAIL_PORT || '587', 10),
    username: process.env.MAIL_USERNAME || '',
    password: process.env.MAIL_PASSWORD || '',
    from: process.env.MAIL_FROM || process.env.MAIL_USERNAME || ''
  },
  
  cors: {
    origins: process.env.CORS_ORIGINS 
      ? JSON.parse(process.env.CORS_ORIGINS)
      : ['http://localhost:3000', 'http://localhost:80']
  },
  
  upload: {
    maxSize: parseInt(process.env.MAX_FILE_SIZE || '10485760', 10), // 10MB
    folder: process.env.UPLOAD_FOLDER || 'uploads/'
  },
  
  // AWS configuration (optional)
  ...(process.env.AWS_ACCESS_KEY_ID && {
    aws: {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
      region: process.env.AWS_REGION || 'ap-northeast-1',
      s3Bucket: process.env.S3_BUCKET || ''
    }
  })
};

// Validate required environment variables
const requiredEnvVars = ['DATABASE_URL'];

for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    throw new Error(`Required environment variable ${envVar} is missing`);
  }
}

export default config;