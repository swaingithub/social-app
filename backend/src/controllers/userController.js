const User = require('../models/user');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
  const { username, email, password } = req.body;

  try {
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ msg: 'User already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    user = new User({
      username,
      email,
      password: hashedPassword,
    });

    await user.save();

    const payload = {
      user: {
        id: user.id,
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: 360000 },
      (err, token) => {
        if (err) throw err;
        res.json({ token });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

exports.getBookmarkedPosts = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).populate({
      path: 'bookmarks',
      populate: {
        path: 'author',
        select: 'username profileImageUrl'
      }
    });
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }
    res.json({ success: true, data: user.bookmarks });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body;

  try {
    let user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(400).json({ msg: 'Invalid Credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid Credentials' });
    }

    const payload = {
      user: {
        id: user.id,
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: 360000 },
      (err, token) => {
        if (err) throw err;
        res.json({ token });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

exports.getMe = async (req, res) => {
  try {
    console.log('Fetching current user with ID:', req.user.id);
    
    const user = await User.findById(req.user.id)
      .select('-password -__v')
      .populate('followers', 'username profileImage')
      .populate('following', 'username profileImage');

    if (!user) {
      console.log('Current user not found with ID:', req.user.id);
      return res.status(404).json({
        success: false,
        msg: 'User not found. Your account may have been deleted.'
      });
    }

    console.log('Successfully fetched current user:', user.username);
    res.json({
      success: true,
      data: user
    });
  } catch (err) {
    console.error('Error in getMe:', err.message);
    console.error(err.stack);
    res.status(500).json({
      success: false,
      msg: 'Server error while fetching your profile',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

exports.getUserById = async (req, res) => {
    try {
        console.log('Fetching user with ID:', req.params.id);
        
        if (!req.params.id.match(/^[0-9a-fA-F]{24}$/)) {
            console.log('Invalid user ID format');
            return res.status(400).json({ msg: 'Invalid user ID format' });
        }

        const user = await User.findById(req.params.id)
            .select('-password -__v')
            .populate('followers', 'username profileImage')
            .populate('following', 'username profileImage');

        if (!user) {
            console.log('User not found with ID:', req.params.id);
            return res.status(404).json({ 
                success: false,
                msg: 'User not found' 
            });
        }

        console.log('Successfully fetched user:', user.username);
        res.json({
            success: true,
            data: user
        });
    } catch (err) {
        console.error('Error in getUserById:', err.message);
        console.error(err.stack);
        res.status(500).json({ 
            success: false,
            msg: 'Server error',
            error: process.env.NODE_ENV === 'development' ? err.message : undefined
        });
    }
};

exports.followUser = async (req, res) => {
  try {
    const { id: targetUserId } = req.params;
    const currentUserId = req.user.id;

    // Prevent self-follow
    if (targetUserId === currentUserId.toString()) {
      return res.status(400).json({
        success: false,
        msg: 'You cannot follow yourself'
      });
    }

    const [currentUser, userToFollow] = await Promise.all([
      User.findById(currentUserId),
      User.findById(targetUserId)
    ]);

    if (!userToFollow) {
      return res.status(404).json({
        success: false,
        msg: 'User to follow not found'
      });
    }

    // Check if already following
    if (currentUser.following.some(id => id.toString() === targetUserId)) {
      return res.status(400).json({
        success: false,
        msg: 'You are already following this user'
      });
    }

    // Add to following list
    currentUser.following.push(userToFollow._id);
    
    // Add to followers list of the user being followed
    userToFollow.followers.push(currentUser._id);

    // Save both operations in parallel
    await Promise.all([currentUser.save(), userToFollow.save()]);

    // Populate the response with updated user data
    const updatedUser = await User.findById(currentUserId)
      .select('-password -__v')
      .populate('followers', 'username profileImage')
      .populate('following', 'username profileImage');

    res.json({
      success: true,
      msg: `You are now following ${userToFollow.username}`,
      data: updatedUser
    });
  } catch (err) {
    console.error('Error in followUser:', err.message);
    console.error(err.stack);
    res.status(500).json({
      success: false,
      msg: 'Server error while processing follow request',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

exports.unfollowUser = async (req, res) => {
  try {
    const { id: targetUserId } = req.params;
    const currentUserId = req.user.id;

    // Prevent self-unfollow check (though it's not harmful, just unnecessary)
    if (targetUserId === currentUserId.toString()) {
      return res.status(400).json({
        success: false,
        msg: 'Invalid operation'
      });
    }

    const [currentUser, userToUnfollow] = await Promise.all([
      User.findById(currentUserId),
      User.findById(targetUserId)
    ]);

    if (!userToUnfollow) {
      return res.status(404).json({
        success: false,
        msg: 'User to unfollow not found'
      });
    }

    // Check if actually following
    const isFollowing = currentUser.following.some(id => id.toString() === targetUserId);
    if (!isFollowing) {
      return res.status(400).json({
        success: false,
        msg: 'You are not following this user'
      });
    }

    // Remove from following list
    currentUser.following = currentUser.following.filter(
      id => id.toString() !== targetUserId
    );
    
    // Remove from followers list of the user being unfollowed
    userToUnfollow.followers = userToUnfollow.followers.filter(
      id => id.toString() !== currentUserId.toString()
    );

    // Save both operations in parallel
    await Promise.all([currentUser.save(), userToUnfollow.save()]);

    // Populate the response with updated user data
    const updatedUser = await User.findById(currentUserId)
      .select('-password -__v')
      .populate('followers', 'username profileImage')
      .populate('following', 'username profileImage');

    res.json({
      success: true,
      msg: `You have unfollowed ${userToUnfollow.username}`,
      data: updatedUser
    });
  } catch (err) {
    console.error('Error in unfollowUser:', err.message);
    console.error(err.stack);
    res.status(500).json({
      success: false,
      msg: 'Server error while processing unfollow request',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const updates = {};
    const allowedUpdates = [
      'username', 'email', 'bio', 'fullName', 
      'website', 'location', 'profileImageUrl', 'isPrivate'
    ];

    console.log('Updating profile for user ID:', userId);
    console.log('Request body:', req.body);

    // Validate and build updates object
    Object.keys(req.body).forEach(key => {
      if (allowedUpdates.includes(key) && req.body[key] !== undefined) {
        updates[key] = req.body[key];
      }
    });

    // If no valid updates
    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        msg: 'No valid fields to update'
      });
    }

    // Check if username or email already exists if they're being updated
    if (updates.username || updates.email) {
      const existingUser = await User.findOne({
        $or: [
          ...(updates.username ? [{ username: updates.username }] : []),
          ...(updates.email ? [{ email: updates.email }] : [])
        ],
        _id: { $ne: userId }
      });

      if (existingUser) {
        const field = existingUser.username === updates.username ? 'username' : 'email';
        return res.status(400).json({
          success: false,
          msg: `${field} is already taken`,
          field
        });
      }
    }

    // Apply updates
    const user = await User.findByIdAndUpdate(
      userId,
      { $set: updates },
      { 
        new: true,
        runValidators: true,
        context: 'query'
      }
    )
    .select('-password -__v')
    .populate('followers', 'username profileImage')
    .populate('following', 'username profileImage');

    if (!user) {
      console.log('User not found with ID:', userId);
      return res.status(404).json({
        success: false,
        msg: 'User not found'
      });
    }

    console.log('Successfully updated profile for user:', user.username);
    res.json({
      success: true,
      msg: 'Profile updated successfully',
      data: user
    });
  } catch (err) {
    console.error('Error in updateProfile:', err.message);
    console.error(err.stack);
    
    // Handle validation errors
    if (err.name === 'ValidationError') {
      const errors = Object.values(err.errors).map(e => e.message);
      return res.status(400).json({
        success: false,
        msg: 'Validation error',
        errors
      });
    }

    // Handle duplicate key error
    if (err.code === 11000) {
      const field = Object.keys(err.keyValue)[0];
      return res.status(400).json({
        success: false,
        msg: `${field} is already taken`,
        field
      });
    }

    res.status(500).json({
      success: false,
      msg: 'Server error while updating profile',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};
