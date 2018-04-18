//
//  OCAnnotation.m
//  openClusterMapView
//
//  Created by Botond Kis on 14.07.11.
//

#import "OCAnnotation.h"

@interface OCAnnotation ()
@property (nonatomic, strong) NSMutableSet *annotationsSetInCluster;
@property (nonatomic, assign) CLLocationCoordinate2D cachedCoordinate;
@end

@implementation OCAnnotation

- (id)init
{
    self = [super init];
    if (self) {
        _annotationsSetInCluster = [[NSMutableSet alloc] init];
        _cachedCoordinate = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;
{
    self = [self init];
    if (self) {
        _coordinate = [annotation coordinate];
        [_annotationsSetInCluster addObject:annotation];
        _cachedCoordinate = kCLLocationCoordinate2DInvalid;

        if ([annotation respondsToSelector:@selector(title)]) {
            self.title = [annotation title];
        }
        if ([annotation respondsToSelector:@selector(subtitle)]) {
            self.subtitle = [annotation subtitle];
        }
    }

    return self;
}

//
// List of annotations in the cluster
// read only
- (NSArray*)annotationsInCluster;
{
    return [_annotationsSetInCluster allObjects];
}

#pragma mark add / remove annotations

- (void)addAnnotation:(id<MKAnnotation>)annotation;
{
    // Add annotation to the cluster
    [_annotationsSetInCluster addObject:annotation];
    _cachedCoordinate = kCLLocationCoordinate2DInvalid;
}

- (void)addAnnotations:(NSArray *)annotations;
{
    for (id<MKAnnotation> annotation in annotations) {
        [self addAnnotation: annotation];
    }
}

- (void)removeAnnotation:(id<MKAnnotation>)annotation;
{
    // Remove annotation from cluster
    [_annotationsSetInCluster removeObject:annotation];
    _cachedCoordinate = kCLLocationCoordinate2DInvalid;
}

- (void)removeAnnotations:(NSArray*)annotations;
{
    for (id<MKAnnotation> annotation in annotations) {
        [self removeAnnotation: annotation];
    }
}

#pragma mark center coordinate

- (CLLocationCoordinate2D)coordinate;
{
    if (self.annotationsSetInCluster.count == 0) return CLLocationCoordinate2DMake(0, 0);

    if (CLLocationCoordinate2DIsValid(self.cachedCoordinate)) {
        return self.cachedCoordinate;
    }

    // find max/min coords
    CLLocationCoordinate2D min = [self.annotationsSetInCluster.anyObject coordinate];
    CLLocationCoordinate2D max = [self.annotationsSetInCluster.anyObject coordinate];
    for (id<MKAnnotation> annotation in self.annotationsSetInCluster) {
        min.latitude = MIN(min.latitude, annotation.coordinate.latitude);
        min.longitude = MIN(min.longitude, annotation.coordinate.longitude);
        max.latitude = MAX(max.latitude, annotation.coordinate.latitude);
        max.longitude = MAX(max.longitude, annotation.coordinate.longitude);
    }

    // calc center
    CLLocationCoordinate2D center = min;
    center.latitude += (max.latitude-min.latitude)/2.0;
    center.longitude += (max.longitude-min.longitude)/2.0;

    self.cachedCoordinate = center;
    return center;
}

#pragma mark equality

- (BOOL)isEqual:(OCAnnotation*)annotation;
{
    if (annotation == self) {
        return YES;
    }

    if (![annotation isKindOfClass:[OCAnnotation class]]) {
        return NO;
    }

    return ([self.groupTag isEqualToString:annotation.groupTag] &&
            [self.title isEqualToString:annotation.title] &&
            [self.subtitle isEqualToString:annotation.subtitle] &&
            [self.annotationsSetInCluster isEqual:annotation.annotationsSetInCluster]);
}

@end

