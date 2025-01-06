use crate::texture::TextureId;

#[derive(Debug)]
pub struct Level {
    width: usize,
    height: usize,
    tiles: Vec<Tile>,
}

#[derive(Debug)]
pub struct Wall {
    pub north: TextureId,
    pub south: TextureId,
    pub east: TextureId,
    pub west: TextureId,
}

#[derive(Debug)]
pub enum Tile {
    Empty {
        floor: TextureId,
        ceiling: TextureId,
    },
    Wall(Wall),
}

impl Tile {
    pub fn new_wall(texture_id: TextureId) -> Self {
        Self::Wall(Wall {
            north: texture_id,
            south: texture_id,
            east: texture_id,
            west: texture_id,
        })
    }
}

impl Level {
    pub fn get_tile(&self, x: usize, y: usize) -> Option<&Tile> {
        if x >= self.width || y >= self.height {
            return None;
        }

        Some(&self.tiles[y * self.width + x])
    }

    pub fn one() -> Self {
        let res = Self {
            width: 10,
            height: 10,
            tiles: vec![
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                //
                Tile::new_wall(TextureId::Green),
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::new_wall(TextureId::Green),
                //
                Tile::new_wall(TextureId::Green),
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::new_wall(TextureId::Green),
                //
                Tile::new_wall(TextureId::Green),
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::new_wall(TextureId::Green),
                //
                Tile::new_wall(TextureId::Green),
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::new_wall(TextureId::Green),
                //
                Tile::new_wall(TextureId::Green),
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::new_wall(TextureId::Green),
                //
                Tile::new_wall(TextureId::Green),
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::new_wall(TextureId::Green),
                //
                Tile::new_wall(TextureId::Green),
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Wall(Wall {
                    north: TextureId::Green,
                    south: TextureId::Blue,
                    east: TextureId::Red,
                    west: TextureId::Pink,
                }),
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::new_wall(TextureId::Green),
                //
                Tile::new_wall(TextureId::Green),
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::Empty {
                    floor: TextureId::Floor2,
                    ceiling: TextureId::Floor1,
                },
                Tile::Empty {
                    floor: TextureId::Floor1,
                    ceiling: TextureId::Floor2,
                },
                Tile::new_wall(TextureId::Green),
                //
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
                Tile::new_wall(TextureId::Green),
            ],
        };
        assert_eq!(res.tiles.len(), 100);
        res
    }
}
