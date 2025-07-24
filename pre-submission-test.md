# Pre-Submission Test Protocol

## Critical Test Cases (Must Pass)

### 1. App Launch & Welcome Flow
- [ ] App launches without crashes on first install
- [ ] Welcome screen displays correctly
- [ ] Partner name input works and persists
- [ ] Photo selection works (optional)
- [ ] Transition to main app works

### 2. Core Note Functionality
- [ ] Can create and save a basic text note
- [ ] Note appears in timeline immediately
- [ ] Note persists after app restart
- [ ] Empty notes are rejected with proper error
- [ ] Very long notes (1000+ chars) work properly

### 3. Media Handling
- [ ] Can attach photos from camera (if available)
- [ ] Can attach photos from photo library
- [ ] Can attach videos from photo library
- [ ] Large media files are optimized properly
- [ ] Media size limit (50MB) is enforced
- [ ] Invalid media files show error message
- [ ] Media displays correctly in timeline

### 4. Location Services
- [ ] Location permission request works
- [ ] Location capture works when permitted
- [ ] Location denial handled gracefully
- [ ] Location timeout (30s) works properly
- [ ] Location display in notes works
- [ ] App works normally without location

### 5. Permission Handling
- [ ] Camera permission request works
- [ ] Camera denial handled gracefully
- [ ] Photo library permission request works
- [ ] Photo library denial handled gracefully
- [ ] Location permission request works
- [ ] Location denial handled gracefully
- [ ] Settings redirect works from error alerts

### 6. Data Persistence & Recovery
- [ ] Notes persist after app restart
- [ ] Settings persist after app restart
- [ ] Corrupted data recovery works
- [ ] App handles missing data gracefully
- [ ] Streak calculation works correctly
- [ ] Data migration works (if applicable)

### 7. Error Scenarios
- [ ] Network unavailable handled properly
- [ ] Storage full scenario handled
- [ ] Memory warnings handled
- [ ] Background/foreground transitions work
- [ ] Interruptions (calls, notifications) handled
- [ ] Low battery scenarios work

### 8. UI/UX Validation
- [ ] All text is readable and properly sized
- [ ] Navigation works on all screen sizes
- [ ] Animations don't cause performance issues
- [ ] Loading states show appropriately
- [ ] Error messages are user-friendly
- [ ] App follows iOS design guidelines

### 9. Performance Testing
- [ ] App launches quickly (< 3 seconds)
- [ ] Scrolling timeline is smooth
- [ ] Media loading is responsive
- [ ] Memory usage stays reasonable
- [ ] No memory leaks detected
- [ ] Battery usage is reasonable

### 10. Device Compatibility
- [ ] Works on iPhone SE (smallest screen)
- [ ] Works on iPhone 15 Pro Max (largest screen)
- [ ] Works on iOS 15.0+ (minimum supported)
- [ ] Works in both light and dark mode
- [ ] Works with accessibility features enabled

## Test Data Scenarios

### Small Dataset
- 5 notes with text only
- 3 notes with single photos
- 2 notes with location data

### Medium Dataset
- 50 notes with mixed content
- 20 photos attached
- 5 videos attached
- Various locations

### Large Dataset
- 200+ notes
- 100+ media items
- Test performance and memory usage

## Automated Checks

Run these commands before submission:

```bash
# Build for release
xcodebuild -scheme Puchi -configuration Release clean build

# Run tests
xcodebuild test -scheme Puchi -destination 'platform=iOS Simulator,name=iPhone 15'

# Check for warnings
xcodebuild -scheme Puchi -configuration Release clean build | grep warning

# Archive for App Store
xcodebuild -scheme Puchi -configuration Release archive -archivePath ./build/Puchi.xcarchive
```

## Final Checklist Before Upload

- [ ] All critical tests pass
- [ ] No compiler warnings
- [ ] No crashes in testing
- [ ] Error handling works properly
- [ ] Performance is acceptable
- [ ] UI looks good on all devices
- [ ] Privacy policy is accessible
- [ ] App Store metadata is complete
- [ ] Screenshots are current and accurate
- [ ] Version number is incremented
- [ ] Build number is incremented

## Post-Upload Verification

- [ ] Build processes successfully in App Store Connect
- [ ] No processing errors reported
- [ ] TestFlight build works correctly
- [ ] All app information is complete
- [ ] Review submission is successful

## Emergency Rollback Plan

If critical issues are found after submission:
1. Reject the current build in App Store Connect
2. Fix the critical issues
3. Increment build number
4. Re-upload and re-submit
5. Request expedited review if necessary

## Success Criteria

The app is ready for submission when:
- All critical test cases pass
- No crashes occur during normal usage
- Error handling provides good user experience
- Performance meets iOS standards
- App Store guidelines are followed
- All required metadata is complete