# App Store Submission Checklist

## Pre-Submission Requirements ✅

### 1. App Store Connect Setup
- [ ] Create app listing in App Store Connect
- [ ] Set app name: "Puchi - Love Journal for Couples"
- [ ] Set bundle identifier (must match Xcode project)
- [ ] Choose category: Lifestyle
- [ ] Set age rating: 4+
- [ ] Set pricing: Free

### 2. App Information
- [ ] Upload app icon (1024x1024 PNG, no transparency)
- [ ] Add app description (use app-store-description.md)
- [ ] Add keywords for search optimization
- [ ] Set privacy policy URL (upload privacy-policy.html to web hosting)
- [ ] Add support URL (same as privacy policy)

### 3. Screenshots Required
Create screenshots for:
- [ ] iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max) - Required
- [ ] iPhone 6.5" (iPhone 11 Pro Max, XS Max) - Required  
- [ ] iPhone 5.5" (iPhone 8 Plus) - Optional but recommended

Screenshot content suggestions:
1. Welcome screen with app name and tagline
2. Main note writing interface
3. Timeline view showing multiple notes
4. Note with photo attachment
5. Settings/profile screen

### 4. App Review Information
- [ ] Add demo account info (if needed - not required for this app)
- [ ] Add review notes explaining core functionality
- [ ] Mention that all data stays local on device

### 5. Build Upload
- [ ] Archive app in Xcode (Product → Archive)
- [ ] Upload to App Store Connect via Organizer
- [ ] Select uploaded build in App Store Connect
- [ ] Submit for review

## Technical Verification ✅

### Code Quality
- [ ] No compiler warnings
- [ ] No crashes during basic usage
- [ ] Comprehensive error handling implemented
- [ ] Memory management for media files
- [ ] Graceful handling of denied permissions
- [ ] Data validation on all user inputs
- [ ] Proper cleanup of resources
- [ ] Error recovery mechanisms in place

### Functionality Testing
- [ ] Welcome flow works correctly
- [ ] Note creation and saving works with validation
- [ ] Photo/video attachment works with size limits
- [ ] Location tagging works (with permission and timeout)
- [ ] Timeline browsing works with error handling
- [ ] Settings persistence works with data recovery
- [ ] App launches without crashes
- [ ] Error alerts show appropriate messages
- [ ] Permission requests work correctly
- [ ] Data corruption recovery works
- [ ] Media size validation prevents crashes
- [ ] Location timeout prevents hanging

### Error Handling Verification
- [ ] Camera permission denied handled gracefully
- [ ] Location permission denied handled gracefully
- [ ] Photo library permission denied handled gracefully
- [ ] Invalid media files handled properly
- [ ] Storage quota exceeded handled properly
- [ ] Network unavailable handled properly
- [ ] Data corruption recovery works
- [ ] Location timeout works (30 seconds)
- [ ] Media size validation works (50MB limit)
- [ ] Image optimization works properly

### Privacy Compliance
- [ ] Privacy policy created and hosted
- [ ] All data stays local (no network requests)
- [ ] Proper permission request descriptions in Info.plist
- [ ] No tracking or analytics

## Estimated Timeline
- App Store Connect setup: 30 minutes
- Screenshot creation: 45 minutes  
- Build upload: 15 minutes
- Review submission: 15 minutes
- **Total: ~2 hours**

## Review Process
- Initial review: Usually 24-48 hours
- Expedited review: Can be requested for critical issues
- Most apps approved on first submission if following guidelines

## Post-Approval
- App goes live immediately after approval
- Monitor for user feedback and reviews
- Prepare for potential updates based on user feedback