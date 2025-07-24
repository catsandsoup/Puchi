# Error Handling & Root Cause Analysis

## Critical Error Prevention
- Always validate user input before processing
- Check for nil/empty values in all user-facing operations
- Implement proper bounds checking for arrays and collections
- Handle permission denials gracefully (camera, location)
- Validate media file sizes and formats before storage

## Memory Management
- Optimize images before storage (max 1024px, 50% JPEG quality)
- Implement size limits for media collections (50MB total)
- Clean up temporary files after video compression
- Monitor UserDefaults storage size for note persistence

## Location Services
- Handle all CLLocationManager authorization states
- Provide fallback behavior when location denied
- Stop location updates after successful capture
- Handle geocoding failures gracefully

## Media Handling
- Validate image/video data before creating MediaItem
- Handle UIImagePickerController cancellation
- Implement proper error messages for media failures
- Check available storage before saving large files

## Data Persistence
- Handle JSONEncoder/JSONDecoder failures
- Implement backward compatibility for model changes
- Validate note data before saving to UserDefaults
- Provide recovery for corrupted saved data

## Root Cause Analysis Checklist
When debugging issues:
1. Check console logs for specific error messages
2. Verify user permissions are properly requested
3. Validate data models match expected structure
4. Test memory usage with large media files
5. Confirm UserDefaults keys are consistent
6. Test edge cases (empty strings, nil values)
7. Verify proper cleanup of resources

## User Experience
- Show loading states during async operations
- Provide clear error messages to users
- Implement retry mechanisms where appropriate
- Graceful degradation when features unavailable
- Prevent data loss through proper validation