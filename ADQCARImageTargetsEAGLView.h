/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

#import <UIKit/UIKit.h>

#import <QCAR/UIGLViewProtocol.h>

#import "Texture.h"
#import "ADQCARApplicationSession.h"
#import "ADQCAR3DModel.h"


#define NUM_AUGMENTATION_TEXTURES 5


FOUNDATION_EXPORT NSString *const kADQCARRecognitionEvent;

typedef enum {
    AUGMENT_NONE,
    AUGMENT_PLANE,
    AUGMENT_MODEL
} ADQCARAugmentationType;



@protocol ADQCARImageTargetsEAGLViewDelegate <NSObject>
@optional
-(void)renderFor:(const QCAR::TrackableResult*)result;
-(NSMutableArray *)loadTextures;

@end

// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface ADQCARImageTargetsEAGLView : UIView <UIGLViewProtocol> {
    

@private
    // OpenGL ES context
    EAGLContext *context;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;

    // Shader handles
    GLuint shaderProgramID;
    GLint vertexHandle;
    GLint normalHandle;
    GLint textureCoordHandle;
    GLint mvpMatrixHandle;
    GLint texSampler2DHandle;
    
    // Texture used when rendering augmentation
    Texture* augmentationTexture[NUM_AUGMENTATION_TEXTURES];
    
    
    BOOL offTargetTrackingEnabled;
    ADQCAR3DModel * buildingModel;

    //ADQCARApplicationSession * vapp;
    
    
}

/*
            SCOTT: I messed around with changing these to non-ARC weak (they were retain, except delegate.
                    MADE NO DIFF. Mitch
 
 */

@property (nonatomic, unsafe_unretained) UILabel *debugLabel;
@property (nonatomic) BOOL debugMode;
// FIXME: What is the right non-ARC delegate type??
@property (nonatomic, unsafe_unretained) id<ADQCARImageTargetsEAGLViewDelegate> delegate;
@property (nonatomic, unsafe_unretained) NSMutableArray *augmentationTexturesArray;
@property (nonatomic) ADQCARAugmentationType augmentationType;
@property (nonatomic, unsafe_unretained) ADQCARApplicationSession *arSession;




- (id)initWithFrame:(CGRect)frame appSession:(ADQCARApplicationSession *) app
           delegate:(id<ADQCARImageTargetsEAGLViewDelegate>)myDelegate;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

- (void) setOffTargetTrackingMode:(BOOL) enabled;
@end
