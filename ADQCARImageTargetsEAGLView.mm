/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <sys/time.h>

#import <QCAR/QCAR.h>
#import <QCAR/State.h>
#import <QCAR/Tool.h>
#import <QCAR/Renderer.h>
#import <QCAR/TrackableResult.h>
#import <QCAR/VideoBackgroundConfig.h>
#import <QCAR/ImageTarget.h>

#import "ADQCARImageTargetsEAGLView.h"
#import "Texture.h"
#import "ADQCARUtils.h"
#import "ADQCARShaderUtils.h"
#import "Teapot.h"

NSString *const kADQCARRecognitionEvent = @"ADQCARRecognitionEvent";

#define VERBOSE_DEBUG NO

//******************************************************************************
// *** OpenGL ES thread safety ***
//
// OpenGL ES on iOS is not thread safe.  We ensure thread safety by following
// this procedure:
// 1) Create the OpenGL ES context on the main thread.
// 2) Start the QCAR camera, which causes QCAR to locate our EAGLView and start
//    the render thread.
// 3) QCAR calls our renderFrameQCAR method periodically on the render thread.
//    The first time this happens, the defaultFramebuffer does not exist, so it
//    is created with a call to createFramebuffer.  createFramebuffer is called
//    on the main thread in order to safely allocate the OpenGL ES storage,
//    which is shared with the drawable layer.  The render (background) thread
//    is blocked during the call to createFramebuffer, thus ensuring no
//    concurrent use of the OpenGL ES context.
//
//******************************************************************************


namespace {
    // --- Data private to this unit ---

    /*
    // Teapot texture filenames
    const char* textureFilenames[] = {
        "TextureTeapotNeon.png",
        "berttexture.jpeg",
        "TextureTeapotRed.png",
        "building_texture.jpeg",
        "berttexture.jpg"
    };
     */
    
    // Model scale factor
    const float kObjectScaleNormal = 3.0f;
    const float kObjectScaleOffTargetTracking = 12.0f;
    
    
    // Flat plane added by Mitch
    
    static const float planeVertices[] =
    {
        -0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.5, 0.5, 0.0, -0.5, 0.5, 0.0,
    };
    static const float planeTexcoords[] =
    {
        0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0
    };
    static const float planeNormals[] =
    {
        0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0
    };
    static const unsigned short planeIndices[] =
    {
        0, 1, 2, 0, 2, 3
    };
}


@interface ADQCARImageTargetsEAGLView (PrivateMethods)

- (void)initShaders;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;

@end


@implementation ADQCARImageTargetsEAGLView


// You must implement this method, which ensures the view's underlying layer is
// of type CAEAGLLayer
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


//------------------------------------------------------------------------------
#pragma mark - Lifecycle

-(void)commonInit {
    
    self.augmentationType = AUGMENT_PLANE;
    
    // Create the OpenGL ES context
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // The EAGLContext must be set for each thread that wishes to use it.
    // Set it the first time this method is called (on the main thread)
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    
    offTargetTrackingEnabled = NO;
    
    //[self loadBuildingsModel];
    [self initShaders];
    
    /*
    if (!self.debugLabel){
        self.debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 500, 30)];
        self.debugLabel.text = @"DEBUG";
        self.debugLabel.textColor = [UIColor yellowColor];
        [self addSubview:self.debugLabel];
    }
     */

    
}

- (id)initWithFrame:(CGRect)aRect
{
    if ((self = [super initWithFrame:aRect])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame appSession:(ADQCARApplicationSession *) app
           delegate:(id<ADQCARImageTargetsEAGLViewDelegate>)myDelegate
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
        self.delegate = myDelegate;
        self.arSession = app;
        
    }
    
    return self;
}

-(void)setDelegate:(id<ADQCARImageTargetsEAGLViewDelegate>)delegate{
    
    _delegate = delegate;
    
    // !!!: I'm torn as to whether this should be here or in the view controller
    if ([self.delegate respondsToSelector:@selector(loadTextures)]) {
        
        self.augmentationTexturesArray = [self.delegate loadTextures];
        
        for (int i = 0; i < [self.augmentationTexturesArray count]; ++i) {
            Texture * tex= (Texture *)[self.augmentationTexturesArray objectAtIndex:i];
            GLuint textureID;
            glGenTextures(1, &textureID);
            [tex setTextureID:textureID];
            glBindTexture(GL_TEXTURE_2D, textureID);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            // ???: why is this here twice
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [tex width], [tex height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[tex pngData]);
        }
        
    }
    
}

-(void)setArSession:(ADQCARApplicationSession *)arSession {
    
    _arSession = arSession;
    // Enable retina mode if available on this device
    if (YES == [_arSession isRetinaDisplay]) {
        [self setContentScaleFactor:2.0f];
    }

}


- (void)dealloc
{
    
    NSLog(@"ADQCARView dealloc");
    [self deleteFramebuffer];
    
    // Tear down context
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];
    [buildingModel release];

    for (int i = 0; i < NUM_AUGMENTATION_TEXTURES; ++i) {
        [augmentationTexture[i] release];
    }

    //[self.delegate release];
    [super dealloc];
}


- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  The render loop has
    // been stopped, so we now make sure all OpenGL ES commands complete before
    // we (potentially) go into the background
    if (context) {
        [EAGLContext setCurrentContext:context];
        glFinish();
    }
}


- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Free easily
    // recreated OpenGL ES resources
    [self deleteFramebuffer];
    glFinish();
}

- (void) setOffTargetTrackingMode:(BOOL) enabled {
    offTargetTrackingEnabled = enabled;
}

- (void) loadBuildingsModel {
    buildingModel = [[ADQCAR3DModel alloc] initWithTxtResourceName:@"buildings"];
    [buildingModel read];
}


//------------------------------------------------------------------------------
#pragma mark - UIGLViewProtocol methods

// Draw the current frame using OpenGL
//
// This method is called by QCAR when it wishes to render the current frame to
// the screen.
//
// *** QCAR will call this method periodically on a background thread ***
- (void)renderFrameQCAR
{
    [self setFramebuffer];
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render video background and retrieve tracking state
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    QCAR::Renderer::getInstance().drawVideoBackground();
    
    glEnable(GL_DEPTH_TEST);
    // We must detect if background reflection is active and adjust the culling direction.
    // If the reflection is active, this means the pose matrix has been reflected as well,
    // therefore standard counter clockwise face culling will result in "inside out" models.
    if (offTargetTrackingEnabled) {
        glDisable(GL_CULL_FACE);
    } else {
        glEnable(GL_CULL_FACE);
    }
    glCullFace(GL_BACK);
    if(QCAR::Renderer::getInstance().getVideoBackgroundConfig().mReflection == QCAR::VIDEO_BACKGROUND_REFLECTION_ON)
        glFrontFace(GL_CW);  //Front camera
    else
        glFrontFace(GL_CCW);   //Back camera
    
    
    for (int i = 0; i < state.getNumTrackableResults(); ++i) {
        // Get the trackable
        const QCAR::TrackableResult* result = state.getTrackableResult(i);
        const QCAR::Trackable& trackable = result->getTrackable();

        //QCAR::Vec2F targetSize = ((QCAR::ImageTarget &) trackable).getSize();
        
        //NSLog(@"Tracking: %s", trackable.getName());
        
        QCAR::Matrix44F matrix = QCAR::Tool::convertPose2GLMatrix(result->getPose());

        [[NSNotificationCenter defaultCenter] postNotificationName:kADQCARRecognitionEvent
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [NSString stringWithCString:trackable.getName() encoding:NSASCIIStringEncoding],
                                                                    @"targetName",
                                                                    [NSNumber numberWithFloat:matrix.data[12]],
                                                                    @"x-ingl",
                                                                    [NSNumber numberWithFloat:matrix.data[13] ],
                                                                     @"y-ingl",
                                                                     [NSNumber numberWithFloat:matrix.data[14] ],
                                                                      @"z-ingl", nil]];
        
        NSString *lt = [NSString stringWithUTF8String:trackable.getName()];
        
        if (VERBOSE_DEBUG)
            [self performSelectorOnMainThread:@selector(updateDebugLabel:) withObject:lt waitUntilDone:NO];
        
        switch (self.augmentationType) {
            case AUGMENT_MODEL:
            {
                /***************************
                 
                 This is the original TEAPOT drawing
                 
                 ***************************/
                //const QCAR::Trackable& trackable = result->getTrackable();
                QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(result->getPose());
                
                
                // [mak] had this here just to see what the pose matrix looked like
                //const QCAR::Matrix34F& pose = result->getPose();
                
                // OpenGL 2
                QCAR::Matrix44F modelViewProjection;
                
                if (offTargetTrackingEnabled) {
                    ADQCARUtils::rotatePoseMatrix(90, 1, 0, 0,&modelViewMatrix.data[0]);
                    ADQCARUtils::scalePoseMatrix(kObjectScaleOffTargetTracking, kObjectScaleOffTargetTracking, kObjectScaleOffTargetTracking, &modelViewMatrix.data[0]);
                } else {
                    ADQCARUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScaleNormal, &modelViewMatrix.data[0]);
                    ADQCARUtils::scalePoseMatrix(kObjectScaleNormal, kObjectScaleNormal, kObjectScaleNormal, &modelViewMatrix.data[0]);
                }
                
                ADQCARUtils::multiplyMatrix(&_arSession.projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
                
                glUseProgram(shaderProgramID);
                
                if (offTargetTrackingEnabled) {
                    glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)buildingModel.vertices);
                    glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)buildingModel.normals);
                    glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)buildingModel.texCoords);
                } else {
                    glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)teapotVertices);
                    glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)teapotNormals);
                    glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)teapotTexCoords);
                }
                
                glEnableVertexAttribArray(vertexHandle);
                glEnableVertexAttribArray(normalHandle);
                glEnableVertexAttribArray(textureCoordHandle);
                
                // Choose the texture based on the target name
                int targetIndex = 0; // "stones"
                if (!strcmp(trackable.getName(), "chips"))
                    targetIndex = 1;
                else if (!strcmp(trackable.getName(), "tarmac"))
                    targetIndex = 2;
                
                glActiveTexture(GL_TEXTURE0);
                
                if (offTargetTrackingEnabled) {
                    glBindTexture(GL_TEXTURE_2D, augmentationTexture[3].textureID);
                } else {
                    glBindTexture(GL_TEXTURE_2D, augmentationTexture[targetIndex].textureID);
                }
                glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (const GLfloat*)&modelViewProjection.data[0]);
                glUniform1i(texSampler2DHandle, 0 /*GL_TEXTURE0*/);
                
                if (offTargetTrackingEnabled) {
                    glDrawArrays(GL_TRIANGLES, 0, buildingModel.numVertices);
                } else {
                    glDrawElements(GL_TRIANGLES, NUM_TEAPOT_OBJECT_INDEX, GL_UNSIGNED_SHORT, (const GLvoid*)teapotIndices);
                }
                
                ADQCARUtils::checkGlError("EAGLView renderFrameQCAR");
            }
                
                break;
                
            case AUGMENT_PLANE:{
                
                QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(result->getPose());

                QCAR::Matrix44F modelViewProjection;
                
                QCAR::Vec2F targetSize = ((QCAR::ImageTarget &) trackable).getSize();
                
                ADQCARUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScaleNormal, &modelViewMatrix.data[0]);
                ADQCARUtils::scalePoseMatrix(targetSize.data[0], targetSize.data[1], 1.0f,
                                                        &modelViewMatrix.data[0]);
                
                ADQCARUtils::multiplyMatrix(&_arSession.projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);

                
                glUseProgram(shaderProgramID);
                glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0,
                                      (const GLvoid*) &planeVertices[0]);
                glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0,
                                      (const GLvoid*) &planeNormals[0]);
                glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0,
                                      (const GLvoid*) &planeTexcoords[0]);
                glEnableVertexAttribArray(vertexHandle);
                glEnableVertexAttribArray(normalHandle);
                glEnableVertexAttribArray(textureCoordHandle);
                glActiveTexture(GL_TEXTURE0);
                
                // Added by Mitch, should draw texture 0
                Texture *tt = self.augmentationTexturesArray[0];
                glBindTexture(GL_TEXTURE_2D, tt.textureID);
                //glBindTexture(GL_TEXTURE_2D, thisTexture->mTextureID);
                glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE,
                                   (GLfloat*)&modelViewProjection.data[0] );
                
                glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
                glEnable(GL_BLEND);
                
                glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT,
                               (const GLvoid*) &planeIndices[0]);

                
                
                
            }
                break;
                
            default:
                break;
        }
        

        
    }
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    glDisableVertexAttribArray(vertexHandle);
    glDisableVertexAttribArray(normalHandle);
    glDisableVertexAttribArray(textureCoordHandle);
    
    QCAR::Renderer::getInstance().end();
    [self presentFramebuffer];
}



//------------------------------------------------------------------------------
#pragma mark - OpenGL ES management

- (void)initShaders
{
    shaderProgramID = [ADQCARShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh"
                                                   fragmentShaderFileName:@"Simple.fragsh"];

    if (0 < shaderProgramID) {
        vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
        normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
        textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
        mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");
        texSampler2DHandle  = glGetUniformLocation(shaderProgramID,"texSampler2D");
    }
    else {
        NSLog(@"Could not initialise augmentation shader");
    }
}


- (void)createFramebuffer
{
    if (context) {
        // Create default framebuffer object
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create colour renderbuffer and allocate backing store
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        // Allocate the renderbuffer's storage (shared with the drawable object)
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
        GLint framebufferWidth;
        GLint framebufferHeight;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        // Create the depth render buffer and allocate storage
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
        
        // Attach colour and depth render buffers to the frame buffer
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        // Leave the colour render buffer bound so future rendering operations will act on it
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    }
}


- (void)deleteFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer) {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}


- (void)setFramebuffer
{
    // The EAGLContext must be set for each thread that wishes to use it.  Set
    // it the first time this method is called (on the render thread)
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    if (!defaultFramebuffer) {
        // Perform on the main thread to ensure safe memory allocation for the
        // shared buffer.  Block until the operation is complete to prevent
        // simultaneous access to the OpenGL context
        [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
}


- (BOOL)presentFramebuffer
{
    // setFramebuffer must have been called before presentFramebuffer, therefore
    // we know the context is valid and has been set for this (render) thread
    
    // Bind the colour render buffer and present it
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    return [context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)updateDebugLabel:(NSString *)newLabel{
    self.debugLabel.text = newLabel;
}


@end
