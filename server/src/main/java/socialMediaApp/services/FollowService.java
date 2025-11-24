package socialMediaApp.services;

import org.springframework.stereotype.Service;
import socialMediaApp.mappers.FollowMapper;
import socialMediaApp.models.Follow;
import socialMediaApp.models.User;
import socialMediaApp.repositories.FollowRepository;
import socialMediaApp.requests.FollowRequest;


@Service
public class FollowService {
    private final FollowRepository followRepository;
    private final FollowMapper followMapper;
    private final UserService userService;

    public FollowService(FollowRepository followRepository, FollowMapper followMapper, UserService userService) {
        this.followRepository = followRepository;
        this.followMapper = followMapper;
        this.userService = userService;
    }

    public void add(FollowRequest followAddRequest){
        if (userService.isFollowing(followAddRequest.getUserId(), followAddRequest.getFollowingId())){
            return;
        }

        User follower = userService.getById(followAddRequest.getUserId());
        User following = userService.getById(followAddRequest.getFollowingId());

        Follow follow = new Follow();
        follow.setUser(follower);
        follow.setFollowing(following);

        followRepository.save(follow);
    }

    public  void delete(FollowRequest followRequest){
      Follow follow
                = followRepository.findByUser_IdAndFollowing_Id(followRequest.getUserId(), followRequest.getFollowingId()).orElse(null);
        followRepository.delete(follow);
    }


}
