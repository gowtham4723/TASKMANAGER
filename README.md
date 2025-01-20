<<<<<<< HEAD
<<<<<<< HEAD
# TASKMANAGER
Sample script
=======
PERSONAL DETAILS:
=======
#!/bin/bash
>>>>>>> 1abc355 (Updated app, containerized and orchestrated as well)

# Script metadata
SCRIPT_TIMESTAMP="2025-01-19 12:18:13 UTC"
SCRIPT_USER="sohelmohammed007"

# Exit on error
set -e

<<<<<<< HEAD
    Bachelor of Science in Computer Science
    ABV GOVT DEGREE AND PG COLLEGE, JANGAON
    Year of Graduation : 2024 (awaiting results)
>>>>>>> a3def9d (Fixing merge conflicts)
=======
# Print script information
echo "Task Manager Setup Script"
echo "Executed by: $SCRIPT_USER"
echo "Timestamp: $SCRIPT_TIMESTAMP"
echo "----------------------------------------"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Check if required commands exist
command -v java >/dev/null 2>&1 || { echo "java is required but not installed. Aborting." >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl is required but not installed. Aborting." >&2; exit 1; }

# Update system packages
echo "Updating system packages..."
sudo apt update -y

# Install required dependencies
echo "Installing dependencies..."
sudo apt install -y openjdk-17-jdk maven unzip curl git

# Set JAVA_HOME
echo "Configuring JAVA_HOME..."
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> ~/.bashrc
echo "export PATH=$JAVA_HOME/bin:$PATH" >> ~/.bashrc
source ~/.bashrc

# Verify Java and Maven installation
echo "Verifying installations..."
java -version
mvn -version

# Create Spring Boot project directory
echo "Setting up Spring Boot project..."
PROJECT_NAME="taskmanager"
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Download Spring Boot project from Spring Initializr
echo "Downloading Spring Boot project template..."
curl https://start.spring.io/starter.zip \
-d dependencies=web,data-jpa,thymeleaf,h2 \
-d type=maven-project \
-d javaVersion=17 \
-d groupId=com.example \
-d artifactId=taskmanager \
-d name=TaskManager \
-d description="Task Manager Application" \
-d packageName=com.example.taskmanager \
-o starter.zip

# Unzip and clean up
unzip starter.zip -d .
rm starter.zip

# Add Maven Wrapper
echo "Adding Maven Wrapper..."
mvn wrapper:wrapper

# Configure application.properties
echo "Configuring application.properties..."
mkdir -p src/main/resources
cat <<EOL > src/main/resources/application.properties
spring.datasource.url=jdbc:h2:mem:taskdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.h2.console.enabled=true
spring.jpa.hibernate.ddl-auto=update
server.port=8080
EOL

# Create necessary directories
echo "Creating project structure..."
mkdir -p src/main/java/com/example/taskmanager
mkdir -p src/main/resources/static

# Create Task Entity
echo "Creating Task entity..."
cat <<EOL > src/main/java/com/example/taskmanager/Task.java
package com.example.taskmanager;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import java.time.LocalDate;

@Entity
public class Task {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    private String description;
    private LocalDate deadline;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDate getDeadline() { return deadline; }
    public void setDeadline(LocalDate deadline) { this.deadline = deadline; }
}
EOL

# Create Task Repository
echo "Creating Task repository..."
cat <<EOL > src/main/java/com/example/taskmanager/TaskRepository.java
package com.example.taskmanager;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskRepository extends JpaRepository<Task, Long> {
}
EOL

# Create Task Controller with improved error handling
echo "Creating Task controller..."
cat <<EOL > src/main/java/com/example/taskmanager/TaskController.java
package com.example.taskmanager;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tasks")
@CrossOrigin(origins = "*")
public class TaskController {
    @Autowired
    private TaskRepository taskRepository;

    @GetMapping
    public List<Task> getAllTasks() {
        return taskRepository.findAll();
    }

    @PostMapping
    public ResponseEntity<Task> createTask(@RequestBody Task task) {
        return ResponseEntity.ok(taskRepository.save(task));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Task> updateTask(@PathVariable Long id, @RequestBody Task taskDetails) {
        return taskRepository.findById(id)
            .map(task -> {
                task.setTitle(taskDetails.getTitle());
                task.setDescription(taskDetails.getDescription());
                task.setDeadline(taskDetails.getDeadline());
                return ResponseEntity.ok(taskRepository.save(task));
            })
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTask(@PathVariable Long id) {
        return taskRepository.findById(id)
            .map(task -> {
                taskRepository.delete(task);
                return ResponseEntity.ok().build();
            })
            .orElse(ResponseEntity.notFound().build());
    }
}
EOL

# Create main application class
echo "Creating main application class..."
cat <<EOL > src/main/java/com/example/taskmanager/TaskManagerApplication.java
package com.example.taskmanager;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TaskManagerApplication {
    public static void main(String[] args) {
        SpringApplication.run(TaskManagerApplication.class, args);
    }
}
EOL

# Create frontend
echo "Creating frontend..."
cat <<EOL > src/main/resources/static/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Manager</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
        }
        .circle-progress {
            transition: stroke-dashoffset 0.5s ease;
        }
        .card {
            background: rgba(255, 255, 255, 0.1);
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .card:hover {
            transform: scale(1.05);
            box-shadow: 0 0 20px rgba(0, 255, 255, 1);
        }
    </style>
</head>
<body class="bg-gray-900 text-white min-h-screen flex flex-col items-center p-6 relative">
    <header class="text-center mb-8">
        <h1 class="text-4xl font-bold text-cyan-400">Task Manager</h1>
        <p class="text-gray-300 mt-2">Manage your tasks effectively and stay organized</p>
    </header>

    <div class="absolute top-4 right-4 text-white">
        <div class="text-center">
            <h1 class="text-4xl font-bold mb-4">Clock</h1>
            <div class="flex space-x-4">
                <div class="flex flex-col items-center">
                    <div class="relative w-16 h-16">
                        <svg class="w-full h-full transform -rotate-90">
                            <circle class="text-gray-700" stroke="currentColor" stroke-width="4" fill="transparent" r="30" cx="50%" cy="50%"></circle>
                            <circle id="hoursCircle" class="text-pink-500 circle-progress" stroke="currentColor" stroke-width="4" fill="transparent" r="30" cx="50%" cy="50%" stroke-dasharray="188" stroke-dashoffset="188"></circle>
                        </svg>
                        <div class="absolute inset-0 flex items-center justify-center text-xl font-bold" id="hours">00</div>
                    </div>
                    <p class="mt-2 text-sm">Hours</p>
                </div>
                <div class="flex flex-col items-center">
                    <div class="relative w-16 h-16">
                        <svg class="w-full h-full transform -rotate-90">
                            <circle class="text-gray-700" stroke="currentColor" stroke-width="4" fill="transparent" r="30" cx="50%" cy="50%"></circle>
                            <circle id="minutesCircle" class="text-yellow-400 circle-progress" stroke="currentColor" stroke-width="4" fill="transparent" r="30" cx="50%" cy="50%" stroke-dasharray="188" stroke-dashoffset="188"></circle>
                        </svg>
                        <div class="absolute inset-0 flex items-center justify-center text-xl font-bold" id="minutes">00</div>
                    </div>
                    <p class="mt-2 text-sm">Minutes</p>
                </div>
                <div class="flex flex-col items-center">
                    <div class="relative w-16 h-16">
                        <svg class="w-full h-full transform -rotate-90">
                            <circle class="text-gray-700" stroke="currentColor" stroke-width="4" fill="transparent" r="30" cx="50%" cy="50%"></circle>
                            <circle id="secondsCircle" class="text-green-500 circle-progress" stroke="currentColor" stroke-width="4" fill="transparent" r="30" cx="50%" cy="50%" stroke-dasharray="188" stroke-dashoffset="188"></circle>
                        </svg>
                        <div class="absolute inset-0 flex items-center justify-center text-xl font-bold" id="seconds">00</div>
                    </div>
                    <p class="mt-2 text-sm">Seconds</p>
                </div>
            </div>
        </div>
    </div>

    <main class="w-full max-w-2xl">
        <div class="bg-gray-800 p-6 rounded-lg card mb-6">
            <form id="taskForm" class="flex flex-col gap-4">
                <div>
                    <label for="taskName" class="block text-sm font-medium">Task Name</label>
                    <input type="text" id="taskName" class="w-full p-2 rounded-lg bg-gray-700 text-white" required>
                </div>
                <div>
                    <label for="taskDescription" class="block text-sm font-medium">Description</label>
                    <textarea id="taskDescription" class="w-full p-2 rounded-lg bg-gray-700 text-white" required></textarea>
                </div>
                <div>
                    <label for="taskDeadline" class="block text-sm font-medium">Deadline</label>
                    <input type="date" id="taskDeadline" class="w-full p-2 rounded-lg bg-gray-700 text-white" required>
                </div>
                <button type="submit" class="bg-cyan-500 text-white py-2 px-4 rounded-lg hover:bg-cyan-600 transition">Add Task</button>
            </form>
        </div>

        <ul id="taskList" class="space-y-4">
            <!-- Task items will be dynamically added here -->
        </ul>
    </main>

    <script>
        function updateClock() {
            const now = new Date();
            const hours = now.getHours();
            const minutes = now.getMinutes();
            const seconds = now.getSeconds();

            document.getElementById("hours").textContent = String(hours % 12 || 12).padStart(2, '0');
            document.getElementById("minutes").textContent = String(minutes).padStart(2, '0');
            document.getElementById("seconds").textContent = String(seconds).padStart(2, '0');

            const secondsCircle = document.getElementById("secondsCircle");
            const minutesCircle = document.getElementById("minutesCircle");
            const hoursCircle = document.getElementById("hoursCircle");

            const secondsOffset = 188 - (188 * seconds) / 60;
            const minutesOffset = 188 - (188 * minutes) / 60;
            const hoursOffset = 188 - (188 * (hours % 12)) / 12;

            secondsCircle.style.strokeDashoffset = secondsOffset;
            minutesCircle.style.strokeDashoffset = minutesOffset;
            hoursCircle.style.strokeDashoffset = hoursOffset;
        }

        setInterval(updateClock, 1000);
        updateClock();

        const taskForm = document.getElementById('taskForm');
        const taskList = document.getElementById('taskList');

        taskForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const taskName = document.getElementById('taskName').value;
            const taskDescription = document.getElementById('taskDescription').value;
            const taskDeadline = document.getElementById('taskDeadline').value;

            try {
                const response = await fetch('/tasks', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        title: taskName,
                        description: taskDescription,
                        deadline: taskDeadline
                    })
                });

                if (!response.ok) throw new Error('Failed to create task');

                const task = await response.json();
                const taskItem = createTaskElement(task);
                taskList.appendChild(taskItem);
                taskForm.reset();
            } catch (error) {
                console.error('Error:', error);
                alert('Failed to create task');
            }
        });

        function createTaskElement(task) {
            const taskItem = document.createElement('li');
            taskItem.className = 'bg-gray-800 p-4 rounded-lg card flex justify-between items-center';
            taskItem.innerHTML = \`
                <div>
                    <h3 class="text-lg font-medium">\${task.title}</h3>
                    <p class="text-sm text-gray-400">Description: \${task.description}</p>
                    <p class="text-sm text-gray-400">Deadline: \${task.deadline}</p>
                </div>
                <div class="flex items-center gap-2">
                    <button class="mark-completed bg-green-500 text-white py-1 px-3 rounded-lg hover:bg-green-600 transition">Mark Completed</button>
                    <button class="delete-task bg-red-500 text-white py-1 px-3 rounded-lg hover:bg-red-600 transition">Delete</button>
                </div>
            \`;

            taskList.appendChild(taskItem);

            taskItem.querySelector('.mark-completed').addEventListener('click', () => {
                taskItem.classList.toggle('opacity-50');
            });

            taskItem.querySelector('.delete-task').addEventListener('click', () => {
                taskItem.remove();
            });

            return taskItem;
        }
    </script>
</body>
</html>
EOL

# Build the project
echo "Building the project..."
./mvnw clean package

# Run the project
echo "Starting the application..."
./mvnw spring-boot:run
>>>>>>> 1abc355 (Updated app, containerized and orchestrated as well)
