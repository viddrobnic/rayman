use crate::texture::TextureId;

#[derive(Debug)]
pub struct Level {
    width: usize,
    height: usize,
    tiles: Vec<Tile>,
}

#[derive(Debug)]
pub enum Tile {
    Empty {
        floor: TextureId,
        ceiling: TextureId,
    },
    Wall,
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
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                //
                Tile::Wall,
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
                Tile::Wall,
                //
                Tile::Wall,
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
                Tile::Wall,
                //
                Tile::Wall,
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
                Tile::Wall,
                //
                Tile::Wall,
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
                Tile::Wall,
                //
                Tile::Wall,
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
                Tile::Wall,
                //
                Tile::Wall,
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
                Tile::Wall,
                //
                Tile::Wall,
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
                Tile::Wall,
                //
                Tile::Wall,
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
                Tile::Wall,
                //
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
                Tile::Wall,
            ],
        };
        assert_eq!(res.tiles.len(), 100);
        res
    }
}
