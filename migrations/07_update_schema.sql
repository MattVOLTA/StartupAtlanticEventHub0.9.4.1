-- Add detailed_summary column to events table if it doesn't exist
ALTER TABLE events
ADD COLUMN IF NOT EXISTS detailed_summary text;

-- Drop and recreate interests table with proper constraints
DROP TABLE IF EXISTS event_interests;
DROP TABLE IF EXISTS interests;

CREATE TABLE interests (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,  -- Added UNIQUE constraint explicitly
    description text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_interests_updated_at
    BEFORE UPDATE ON interests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create junction table for events and interests
CREATE TABLE event_interests (
    event_id text REFERENCES events(id) ON DELETE CASCADE,
    interest_id uuid REFERENCES interests(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, interest_id)
);

-- Insert predefined interests
INSERT INTO interests (name, description)
VALUES
    ('Fundraising & Investor Readiness', 
     'Master the basics of securing startup funding and building investor relationships. Includes venture capital, angel investing, and alternative funding sources.'),
    ('Customer Discovery & Growth',
     'Identify and understand your target audience to drive meaningful growth. Focuses on product-market fit, customer personas, and retention strategies.'),
    ('Product & MVP Development',
     'Turn ideas into tested products with a streamlined approach to MVPs. Covers ideation, prototyping, user feedback, and iterative improvement.'),
    ('Marketing & Brand Strategy',
     'Craft a lean marketing plan that boosts brand awareness and drives engagement. Encompasses digital marketing, growth hacking, and brand positioning.'),
    ('Technology & Innovation',
     'Stay ahead with insights on emerging technologies and business innovation. Topics include automation, digital transformation, and AI applications.'),
    ('Talent & Culture Building',
     'Attract and retain a mission-aligned team with a strong startup culture. Involves talent acquisition, remote culture, and team dynamics.'),
    ('Operational Efficiency & Scaling',
     'Build a solid operational foundation to support sustainable growth. Includes lean operations, process automation, and systems setup.'),
    ('Legal Essentials & Compliance',
     'Safeguard your startup with a foundational understanding of legal requirements. Covers intellectual property, contracts, and regulatory basics.'),
    ('Pitching & Storytelling',
     'Refine your pitch to convey your startup''s vision powerfully and effectively. Focuses on storytelling, public speaking, and pitch deck essentials.'),
    ('Community Building & Partnerships',
     'Forge valuable connections in the startup ecosystem for growth and support. Includes networking, partnerships, and collaborative ventures.'),
    ('Diversity, Equity & Inclusion (DEI) in Startups',
     'Build an inclusive and diverse team from the ground up. Encompasses DEI best practices, inclusive hiring, and equity initiatives.'),
    ('Data-Driven Decision Making',
     'Use data insights to guide business strategies and product improvements. Topics include analytics, performance metrics, and user behavior insights.'),
    ('Intellectual Property & Patents',
     'Protect your innovations with a clear IP strategy from the start. Covers patents, trademarks, copyrights, and IP management.'),
    ('Cybersecurity & Data Protection',
     'Keep customer trust intact with strong data protection and security practices. Focuses on cybersecurity fundamentals, data protection, and compliance.'),
    ('Life Science & Health Innovation',
     'Navigate unique challenges in life science and health tech ventures. Includes healthcare regulations, medical device standards, and HIPAA compliance.'),
    ('Hardware & IoT Development',
     'Develop physical products with a focus on prototyping and manufacturing. Topics include hardware prototyping, supply chain logistics, and IoT security.'),
    ('Networking & Social Events',
     'Connect with the community through events for learning, mentorship, and fun. Encompasses mixers, founder meetups, pitch nights, and industry-specific gatherings.')
ON CONFLICT (name) DO UPDATE SET 
    description = EXCLUDED.description;

-- Refresh the schema cache
SELECT pg_notify('pgrst', 'reload schema');