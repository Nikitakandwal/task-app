from sqlalchemy import Column, Integer, String, ForeignKey
from database import Base

class Task(Base):
    __tablename__ = "tasks"

    id          = Column(Integer, primary_key=True, index=True)
    title       = Column(String, nullable=False)
    description = Column(String, default="")
    due_date    = Column(String, nullable=False)   # stored as "YYYY-MM-DD"
    status      = Column(String, default="To-Do")  # "To-Do" | "In Progress" | "Done"
    blocked_by  = Column(Integer, ForeignKey("tasks.id"), nullable=True)