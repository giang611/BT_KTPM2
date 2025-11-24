package socialMediaApp.api;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import socialMediaApp.models.User;
import socialMediaApp.repositories.UserRepository;
import socialMediaApp.requests.LoginRequest;
import socialMediaApp.requests.RegisterRequest;
import socialMediaApp.security.JwtUtil;


@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;

    public AuthController(AuthenticationManager authenticationManager,  JwtUtil jwtUtil, PasswordEncoder passwordEncoder, UserRepository userRepository) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.passwordEncoder = passwordEncoder;
        this.userRepository = userRepository;
    }
    @GetMapping("/ping")
    public ResponseEntity<String> ping() {
        return ResponseEntity.ok("auth ok");
    }

    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody LoginRequest loginRequest)  {

          try {
              authenticationManager.authenticate(
                      new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword())
              );
              return new ResponseEntity<>(jwtUtil.generateToken(
                      loginRequest.getEmail(),
                      userRepository.findByEmail(loginRequest.getEmail()).getId(),
                      userRepository.findByEmail(loginRequest.getEmail()).getName()+
                              " "+ userRepository.findByEmail(loginRequest.getEmail()).getLastName()
                        )
                      ,HttpStatus.OK
              );
          }catch (Exception e){
              return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
          }
    }

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterRequest registerRequest){

        if (userRepository.findByEmail(registerRequest.getEmail())!=null){
            return new ResponseEntity<>("Email already exist",HttpStatus.BAD_REQUEST);
        }
        User user = new User();
        user.setEmail(registerRequest.getEmail());
        user.setName(registerRequest.getName());
        user.setLastName(registerRequest.getLastName());
        user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));

        // Lưu user VÀO MỘT BIẾN để lấy ID
        User savedUser = userRepository.save(user);

        // KHÔNG GỌI authenticationManager.authenticate(...) ở đây

        return new ResponseEntity<>(jwtUtil.generateToken(
                savedUser.getEmail(),
                savedUser.getId(), // Dùng ID từ user vừa lưu
                savedUser.getName() +" "+savedUser.getLastName()
        )
                ,HttpStatus.OK
        );
    }


}
