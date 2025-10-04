-- Crear tabla de cronogramas
CREATE TABLE IF NOT EXISTS schedules (
  id SERIAL PRIMARY KEY,
  anteproject_id INTEGER NOT NULL REFERENCES anteprojects(id) ON DELETE CASCADE,
  tutor_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  final_date TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Asegurar que un anteproyecto solo tenga un cronograma
  UNIQUE(anteproject_id)
);

-- Crear tabla de fechas de revisión
CREATE TABLE IF NOT EXISTS review_dates (
  id SERIAL PRIMARY KEY,
  schedule_id INTEGER NOT NULL REFERENCES schedules(id) ON DELETE CASCADE,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  description TEXT NOT NULL,
  milestone_reference TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_schedules_anteproject_id ON schedules(anteproject_id);
CREATE INDEX IF NOT EXISTS idx_schedules_tutor_id ON schedules(tutor_id);
CREATE INDEX IF NOT EXISTS idx_review_dates_schedule_id ON review_dates(schedule_id);
CREATE INDEX IF NOT EXISTS idx_review_dates_date ON review_dates(date);

-- Crear función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Crear triggers para actualizar updated_at
CREATE TRIGGER update_schedules_updated_at 
  BEFORE UPDATE ON schedules 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_review_dates_updated_at 
  BEFORE UPDATE ON review_dates 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Comentarios para documentación
COMMENT ON TABLE schedules IS 'Cronogramas de revisión para anteproyectos aprobados';
COMMENT ON TABLE review_dates IS 'Fechas específicas de revisión dentro de un cronograma';

COMMENT ON COLUMN schedules.anteproject_id IS 'ID del anteproyecto al que pertenece el cronograma';
COMMENT ON COLUMN schedules.tutor_id IS 'ID del tutor responsable del cronograma';
COMMENT ON COLUMN schedules.start_date IS 'Fecha de inicio del cronograma';
COMMENT ON COLUMN schedules.final_date IS 'Fecha final del cronograma';

COMMENT ON COLUMN review_dates.schedule_id IS 'ID del cronograma al que pertenece esta fecha';
COMMENT ON COLUMN review_dates.date IS 'Fecha específica de revisión';
COMMENT ON COLUMN review_dates.description IS 'Descripción de lo que se revisará en esta fecha';
COMMENT ON COLUMN review_dates.milestone_reference IS 'Referencia al hito del anteproyecto relacionado';
