--
-- PostgreSQL database dump
--

-- Dumped from database version 17.3
-- Dumped by pg_dump version 17.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: access_logs; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.access_logs (
    log_id integer NOT NULL,
    user_id integer NOT NULL,
    action_type text NOT NULL,
    target_table text,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.access_logs OWNER TO oscar;

--
-- Name: camera_vision; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.camera_vision (
    object_id integer NOT NULL,
    object_name text NOT NULL,
    object_color text NOT NULL,
    color_code double precision[],
    pos_x real NOT NULL,
    pos_y real NOT NULL,
    pos_z real NOT NULL,
    rot_x real NOT NULL,
    rot_y real NOT NULL,
    rot_z real NOT NULL,
    usd_name text NOT NULL,
    last_detected timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.camera_vision OWNER TO oscar;

--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.camera_vision_object_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.camera_vision_object_id_seq OWNER TO oscar;

--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.camera_vision_object_id_seq OWNED BY public.camera_vision.object_id;


--
-- Name: drop_op_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.drop_op_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    drop_height double precision NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.drop_op_parameters OWNER TO oscar;

--
-- Name: drop_op_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.drop_op_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drop_op_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: drop_op_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.drop_op_parameters_sequence_id_seq OWNED BY public.drop_op_parameters.sequence_id;


--
-- Name: gesture_instructions; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.gesture_instructions (
    id integer NOT NULL,
    session_id text NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    gesture_text text NOT NULL,
    natural_description text,
    confidence real,
    hand_label text,
    processed boolean DEFAULT false
);


ALTER TABLE public.gesture_instructions OWNER TO oscar;

--
-- Name: gesture_instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

ALTER TABLE public.gesture_instructions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.gesture_instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: gesture_library; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.gesture_library (
    id integer NOT NULL,
    gesture_type text NOT NULL,
    gesture_text text NOT NULL,
    natural_description text,
    config jsonb
);


ALTER TABLE public.gesture_library OWNER TO oscar;

--
-- Name: gesture_library_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

ALTER TABLE public.gesture_library ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.gesture_library_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: instruction_operation_sequence; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.instruction_operation_sequence (
    task_id integer NOT NULL,
    instruction_id integer,
    skill_id integer,
    skill_name text,
    sequence_id integer,
    sequence_name text NOT NULL,
    object_id integer,
    object_name text,
    status text DEFAULT 'pending'::text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT instruction_operation_sequence_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'completed'::text, 'failed'::text])))
);


ALTER TABLE public.instruction_operation_sequence OWNER TO oscar;

--
-- Name: instruction_operation_sequence_task_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.instruction_operation_sequence_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.instruction_operation_sequence_task_id_seq OWNER TO oscar;

--
-- Name: instruction_operation_sequence_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.instruction_operation_sequence_task_id_seq OWNED BY public.instruction_operation_sequence.task_id;


--
-- Name: instructions; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.instructions (
    id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    user_id integer,
    modality text,
    language text NOT NULL,
    instruction_type text NOT NULL,
    processed boolean DEFAULT false,
    content text,
    sync_id integer,
    confidence real,
    CONSTRAINT instructions_confidence_check CHECK (((confidence >= (0)::double precision) AND (confidence <= (1)::double precision))),
    CONSTRAINT instructions_modality_check CHECK ((modality = ANY (ARRAY['voice'::text, 'gesture'::text, 'text'::text])))
);


ALTER TABLE public.instructions OWNER TO oscar;

--
-- Name: instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

ALTER TABLE public.instructions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: interaction_memory; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.interaction_memory (
    interaction_id integer NOT NULL,
    user_id integer,
    instruction_id integer,
    interaction_type text,
    data text,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.interaction_memory OWNER TO oscar;

--
-- Name: interaction_memory_interaction_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.interaction_memory_interaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.interaction_memory_interaction_id_seq OWNER TO oscar;

--
-- Name: interaction_memory_interaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.interaction_memory_interaction_id_seq OWNED BY public.interaction_memory.interaction_id;


--
-- Name: isaac_sim_gui; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.isaac_sim_gui (
    sequence_id integer NOT NULL,
    gui_feature text NOT NULL,
    operation_status text NOT NULL
);


ALTER TABLE public.isaac_sim_gui OWNER TO oscar;

--
-- Name: isaac_sim_gui_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.isaac_sim_gui_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.isaac_sim_gui_sequence_id_seq OWNER TO oscar;

--
-- Name: isaac_sim_gui_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.isaac_sim_gui_sequence_id_seq OWNED BY public.isaac_sim_gui.sequence_id;


--
-- Name: lift_state_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.lift_state_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    lift_height double precision NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.lift_state_parameters OWNER TO oscar;

--
-- Name: lift_state_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.lift_state_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lift_state_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: lift_state_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.lift_state_parameters_sequence_id_seq OWNED BY public.lift_state_parameters.sequence_id;


--
-- Name: operation_library; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.operation_library (
    id integer NOT NULL,
    operation_name text,
    task_order text
);


ALTER TABLE public.operation_library OWNER TO oscar;

--
-- Name: operation_library_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.operation_library_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.operation_library_id_seq OWNER TO oscar;

--
-- Name: operation_library_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.operation_library_id_seq OWNED BY public.operation_library.id;


--
-- Name: operation_sequence; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.operation_sequence (
    id integer NOT NULL,
    operation_id integer NOT NULL,
    sequence_id integer NOT NULL,
    sequence_name text NOT NULL,
    object_name text,
    command_id integer,
    processed boolean DEFAULT false,
    execution_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.operation_sequence OWNER TO oscar;

--
-- Name: operation_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.operation_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.operation_sequence_id_seq OWNER TO oscar;

--
-- Name: operation_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.operation_sequence_id_seq OWNED BY public.operation_sequence.id;


--
-- Name: pick_op_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.pick_op_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    slide_state_status boolean NOT NULL,
    slide_direction text NOT NULL,
    distance_travel double precision NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.pick_op_parameters OWNER TO oscar;

--
-- Name: pick_op_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.pick_op_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pick_op_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: pick_op_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.pick_op_parameters_sequence_id_seq OWNED BY public.pick_op_parameters.sequence_id;


--
-- Name: rotate_state_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.rotate_state_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    rotation_angle double precision NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.rotate_state_parameters OWNER TO oscar;

--
-- Name: rotate_state_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.rotate_state_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rotate_state_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: rotate_state_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.rotate_state_parameters_sequence_id_seq OWNED BY public.rotate_state_parameters.sequence_id;


--
-- Name: screw_op_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.screw_op_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    rotation_dir boolean NOT NULL,
    number_of_rotations integer NOT NULL,
    current_rotation integer NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.screw_op_parameters OWNER TO oscar;

--
-- Name: screw_op_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.screw_op_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.screw_op_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: screw_op_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.screw_op_parameters_sequence_id_seq OWNED BY public.screw_op_parameters.sequence_id;


--
-- Name: sequence_library; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.sequence_library (
    sequence_id integer NOT NULL,
    sequence_name text NOT NULL,
    skill_name text,
    node_name text,
    description text,
    conditions text,
    post_conditions text,
    is_runnable_count integer,
    is_runnable_condition text,
    is_runnable_exit boolean
);


ALTER TABLE public.sequence_library OWNER TO oscar;

--
-- Name: sequence_library_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.sequence_library_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sequence_library_sequence_id_seq OWNER TO oscar;

--
-- Name: sequence_library_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.sequence_library_sequence_id_seq OWNED BY public.sequence_library.sequence_id;


--
-- Name: simulation_results; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.simulation_results (
    simulation_id integer NOT NULL,
    instruction_id integer,
    success boolean,
    metrics text,
    error_log text,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.simulation_results OWNER TO oscar;

--
-- Name: simulation_results_simulation_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.simulation_results_simulation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.simulation_results_simulation_id_seq OWNER TO oscar;

--
-- Name: simulation_results_simulation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.simulation_results_simulation_id_seq OWNED BY public.simulation_results.simulation_id;


--
-- Name: skills; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.skills (
    skill_id integer NOT NULL,
    skill_name text NOT NULL,
    description text,
    parameters text,
    required_capabilities text,
    average_duration real
);


ALTER TABLE public.skills OWNER TO oscar;

--
-- Name: skills_skill_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.skills_skill_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.skills_skill_id_seq OWNER TO oscar;

--
-- Name: skills_skill_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.skills_skill_id_seq OWNED BY public.skills.skill_id;


--
-- Name: slide_state_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.slide_state_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    lift_distance double precision NOT NULL,
    pos_x double precision NOT NULL,
    pos_y double precision NOT NULL,
    pos_z double precision NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.slide_state_parameters OWNER TO oscar;

--
-- Name: slide_state_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.slide_state_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slide_state_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: slide_state_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.slide_state_parameters_sequence_id_seq OWNED BY public.slide_state_parameters.sequence_id;


--
-- Name: sort_order; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.sort_order (
    order_id integer NOT NULL,
    object_name text,
    object_color text
);


ALTER TABLE public.sort_order OWNER TO oscar;

--
-- Name: sort_order_order_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.sort_order_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sort_order_order_id_seq OWNER TO oscar;

--
-- Name: sort_order_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.sort_order_order_id_seq OWNED BY public.sort_order.order_id;


--
-- Name: states; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.states (
    task_id integer NOT NULL,
    task_name text NOT NULL,
    description text,
    conditions text,
    post_conditions text,
    sequence_id integer
);


ALTER TABLE public.states OWNER TO oscar;

--
-- Name: states_task_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.states_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.states_task_id_seq OWNER TO oscar;

--
-- Name: states_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.states_task_id_seq OWNED BY public.states.task_id;


--
-- Name: task_history; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.task_history (
    id integer NOT NULL,
    command_text text,
    generated_plan jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.task_history OWNER TO oscar;

--
-- Name: task_history_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.task_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_history_id_seq OWNER TO oscar;

--
-- Name: task_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.task_history_id_seq OWNED BY public.task_history.id;


--
-- Name: task_preferences; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.task_preferences (
    preference_id integer NOT NULL,
    user_id integer,
    task_id text,
    task_name text,
    preference_data text
);


ALTER TABLE public.task_preferences OWNER TO oscar;

--
-- Name: task_preferences_preference_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.task_preferences_preference_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_preferences_preference_id_seq OWNER TO oscar;

--
-- Name: task_preferences_preference_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.task_preferences_preference_id_seq OWNED BY public.task_preferences.preference_id;


--
-- Name: task_templates; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.task_templates (
    task_id integer NOT NULL,
    task_name text NOT NULL,
    description text,
    default_sequence text[]
);


ALTER TABLE public.task_templates OWNER TO oscar;

--
-- Name: task_templates_task_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.task_templates_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_templates_task_id_seq OWNER TO oscar;

--
-- Name: task_templates_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.task_templates_task_id_seq OWNED BY public.task_templates.task_id;


--
-- Name: travel_op_parameters; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.travel_op_parameters (
    sequence_id integer NOT NULL,
    operation_order integer NOT NULL,
    object_id text NOT NULL,
    travel_height double precision NOT NULL,
    gripper_rotation text NOT NULL,
    operation_status boolean NOT NULL
);


ALTER TABLE public.travel_op_parameters OWNER TO oscar;

--
-- Name: travel_op_parameters_sequence_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.travel_op_parameters_sequence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.travel_op_parameters_sequence_id_seq OWNER TO oscar;

--
-- Name: travel_op_parameters_sequence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.travel_op_parameters_sequence_id_seq OWNED BY public.travel_op_parameters.sequence_id;


--
-- Name: unified_instructions; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.unified_instructions (
    id integer NOT NULL,
    session_id text,
    "timestamp" timestamp without time zone,
    liu_id text,
    voice_command text,
    gesture_command text,
    unified_command text,
    confidence double precision,
    processed boolean DEFAULT false,
    CONSTRAINT unified_instructions_confidence_check CHECK (((confidence >= (0)::double precision) AND (confidence <= (1)::double precision)))
);


ALTER TABLE public.unified_instructions OWNER TO oscar;

--
-- Name: unified_instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

ALTER TABLE public.unified_instructions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.unified_instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: usd_data; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.usd_data (
    sequence_id integer NOT NULL,
    usd_name text NOT NULL,
    type_of_usd text NOT NULL,
    repository text NOT NULL,
    scale_x double precision NOT NULL,
    scale_y double precision NOT NULL,
    scale_z double precision NOT NULL,
    prim_path text NOT NULL,
    initial_pos_x double precision NOT NULL,
    initial_pos_y double precision NOT NULL,
    initial_pos_z double precision NOT NULL,
    register_obstacle boolean NOT NULL
);


ALTER TABLE public.usd_data OWNER TO oscar;

--
-- Name: users; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    liu_id text,
    email text,
    preferences text,
    profile_image_path text,
    interaction_memory text,
    face_encoding bytea,
    voice_embedding bytea,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO oscar;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO oscar;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: oscar
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: voice_instructions; Type: TABLE; Schema: public; Owner: oscar
--

CREATE TABLE public.voice_instructions (
    id integer NOT NULL,
    session_id text NOT NULL,
    transcribed_text text NOT NULL,
    confidence real,
    language text NOT NULL,
    processed boolean DEFAULT false,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.voice_instructions OWNER TO oscar;

--
-- Name: voice_instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: oscar
--

ALTER TABLE public.voice_instructions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.voice_instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: camera_vision object_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.camera_vision ALTER COLUMN object_id SET DEFAULT nextval('public.camera_vision_object_id_seq'::regclass);


--
-- Name: drop_op_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.drop_op_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.drop_op_parameters_sequence_id_seq'::regclass);


--
-- Name: instruction_operation_sequence task_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence ALTER COLUMN task_id SET DEFAULT nextval('public.instruction_operation_sequence_task_id_seq'::regclass);


--
-- Name: interaction_memory interaction_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.interaction_memory ALTER COLUMN interaction_id SET DEFAULT nextval('public.interaction_memory_interaction_id_seq'::regclass);


--
-- Name: isaac_sim_gui sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.isaac_sim_gui ALTER COLUMN sequence_id SET DEFAULT nextval('public.isaac_sim_gui_sequence_id_seq'::regclass);


--
-- Name: lift_state_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.lift_state_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.lift_state_parameters_sequence_id_seq'::regclass);


--
-- Name: operation_library id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_library ALTER COLUMN id SET DEFAULT nextval('public.operation_library_id_seq'::regclass);


--
-- Name: operation_sequence id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_sequence ALTER COLUMN id SET DEFAULT nextval('public.operation_sequence_id_seq'::regclass);


--
-- Name: pick_op_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.pick_op_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.pick_op_parameters_sequence_id_seq'::regclass);


--
-- Name: rotate_state_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.rotate_state_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.rotate_state_parameters_sequence_id_seq'::regclass);


--
-- Name: screw_op_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.screw_op_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.screw_op_parameters_sequence_id_seq'::regclass);


--
-- Name: sequence_library sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.sequence_library ALTER COLUMN sequence_id SET DEFAULT nextval('public.sequence_library_sequence_id_seq'::regclass);


--
-- Name: simulation_results simulation_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.simulation_results ALTER COLUMN simulation_id SET DEFAULT nextval('public.simulation_results_simulation_id_seq'::regclass);


--
-- Name: skills skill_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.skills ALTER COLUMN skill_id SET DEFAULT nextval('public.skills_skill_id_seq'::regclass);


--
-- Name: slide_state_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.slide_state_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.slide_state_parameters_sequence_id_seq'::regclass);


--
-- Name: sort_order order_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.sort_order ALTER COLUMN order_id SET DEFAULT nextval('public.sort_order_order_id_seq'::regclass);


--
-- Name: states task_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.states ALTER COLUMN task_id SET DEFAULT nextval('public.states_task_id_seq'::regclass);


--
-- Name: task_history id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_history ALTER COLUMN id SET DEFAULT nextval('public.task_history_id_seq'::regclass);


--
-- Name: task_preferences preference_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_preferences ALTER COLUMN preference_id SET DEFAULT nextval('public.task_preferences_preference_id_seq'::regclass);


--
-- Name: task_templates task_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_templates ALTER COLUMN task_id SET DEFAULT nextval('public.task_templates_task_id_seq'::regclass);


--
-- Name: travel_op_parameters sequence_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.travel_op_parameters ALTER COLUMN sequence_id SET DEFAULT nextval('public.travel_op_parameters_sequence_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: access_logs; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.access_logs (log_id, user_id, action_type, target_table, "timestamp") FROM stdin;
\.


--
-- Data for Name: camera_vision; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.camera_vision (object_id, object_name, object_color, color_code, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, usd_name, last_detected) FROM stdin;
77	Shape_70	green	{0,0,0}	-416.6589	119.0454	0.89000005	0	0	22.619865	Shape.usd	2025-03-29 11:12:03.051356
160	Shape_58	green	{0,0,0}	-271.66885	217.53194	0.89900005	0	0	26.56505	Shape.usd	2025-03-29 13:37:50.476676
53	Shape_135	green	{0.47,0.57,0.45}	579	203	0.924	0	0	90	Shape.usd	2025-03-28 17:16:48.423605
158	Shape_146	green	{0.14,0.19,0.14}	-879.9112	-319.81055	0	0	0	0	Shape.usd	2025-03-29 12:40:09.785469
130	Shape_104	green	{0,0,0}	-292.592	-628.32263	0.882	0	0	90	Shape.usd	2025-03-29 11:26:50.736685
146	Shape_52	green	{0,0,0}	128.44261	291.20197	1.909	0	0	90	Shape.usd	2025-03-29 13:59:53.4521
155	Shape_63	green	{0.03,0.04,0.03}	-141.74026	-25.591993	0.89800006	0	0	90	Shape.usd	2025-03-29 13:37:50.47877
102	Shape_145	green	{0.24,0.29,0.23}	-360.22467	-249.91664	0.93100005	0	0	90	Shape.usd	2025-03-29 11:19:50.388966
57	Shape_46	red	{0,0,0}	31.375294	259.82666	0.924	0	0	38.157227	Shape.usd	2025-03-29 14:23:39.199169
58	Shape_47	green	{0,0,0}	-270.6119	216.68562	0.924	0	0	26.56505	Shape.usd	2025-03-29 14:23:39.200913
80	Shape_131	green	{0.01,0.01,0.01}	-554.90515	-111.36505	0.934	0	0	42.436226	Shape.usd	2025-03-29 11:12:03.054713
81	Shape_143	Unknown	{0,0,0}	-359.05627	-268.8122	0.92700005	0	0	57.094757	Shape.usd	2025-03-29 11:12:03.055816
82	Shape_177	green	{0.11,0.14,0.11}	-391.69775	-458.90082	0.938	0	0	90	Shape.usd	2025-03-29 11:12:03.057096
141	Shape_68	green	{0,0,0}	-519.3716	26.364038	0.91600007	0	0	87.27369	Shape.usd	2025-03-29 13:03:48.220809
127	Shape_114	green	{0.01,0.01,0.01}	-1096.724	-126.03861	0.91700006	0	0	75.96376	Shape.usd	2025-03-29 12:50:26.341388
108	Shape_82	Unknown	{0,0,0}	-674.9194	-34.27325	1.784	0	0	60.524105	Shape.usd	2025-03-29 13:03:48.222594
97	Shape_174	green	{0.02,0.03,0.02}	-237.58455	-580.76227	0.90400004	0	0	90	Shape.usd	2025-03-29 11:18:32.927674
161	Shape_84	green	{0,0,0}	-331.082	-414.7238	1.9480001	0	0	13.706961	Shape.usd	2025-03-29 12:45:26.095787
149	Shape_116	Unknown	{0,0,0}	-1408.646	-363.88458	1.7960001	0	0	20.924503	Shape.usd	2025-03-29 11:58:58.681802
165	Shape_78	green	{0,0,0}	-681.0099	-15.635431	0.95300007	0	0	9.117863	Shape.usd	2025-03-29 12:51:49.268566
73	Shape_6	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:40:39.645108
188	pentagon_1	black	{0,0,0}	-127.46696	518.69244	652	0	0	90	Shape.usd	2025-03-29 14:40:46.491577
111	Shape_88	green	{0,0,0}	-850.27045	-95.80512	1.8310001	0	0	90	Shape.usd	2025-03-29 11:23:19.062763
174	Shape_130	green	{0.28,0.35,0.28}	-392.82416	-122.15337	0.91	0	0	90	Shape.usd	2025-03-29 13:03:48.225235
150	Shape_125	green	{0,0,0}	-1367.3807	-393.8957	1.8180001	0	0	36.869896	Shape.usd	2025-03-29 11:58:58.683968
113	Shape_148	green	{0.21,0.25,0.2}	-371.24484	-289.12616	0.91800004	0	0	90	Shape.usd	2025-03-29 11:23:19.065411
133	Shape_69	green	{0.01,0.02,0.01}	-650.1362	-583.013	0.87500006	0	0	90	Shape.usd	2025-03-29 11:46:30.411425
126	Shape_109	green	{0.01,0.01,0.01}	-414.93365	5.0092597	0.90300006	0	0	40.555897	Shape.usd	2025-03-29 13:05:01.586501
96	Shape_75	green	{0,0.01,0.01}	-1003.5237	-141.14742	0.91400003	0	0	80.90972	Shape.usd	2025-03-29 12:48:01.65996
163	Shape_122	green	{0.13,0.19,0.13}	-865.81885	-475.0815	0	0	0	90	Shape.usd	2025-03-29 12:48:01.6627
116	Shape_105	green	{0,0,0}	-35.82624	-580.76227	0	0	0	9.574227	Shape.usd	2025-03-29 11:23:19.27433
124	Shape_54	green	{0,0,0}	-270.6119	216.68562	0.90200007	0	0	26.56505	Shape.usd	2025-03-29 13:07:50.874003
167	Shape_144	green	{0.19,0.25,0.19}	-877.3214	-350.92856	0.93500006	0	0	90	Shape.usd	2025-03-29 12:51:49.273879
186	Shape_115	green	{0.28,0.34,0.27}	-404.2486	-123.91098	0.93900007	0	0	0	Shape.usd	2025-03-29 13:12:40.240401
109	Shape_85	green	{0.03,0.04,0.03}	-141.19417	-25.493391	0.896	0	0	90	Shape.usd	2025-03-29 13:12:40.702818
156	Shape_92	orange	{0.01,0.01,0}	-140.66403	61.754944	1.9050001	0	0	6.934349	Shape.usd	2025-03-29 13:21:55.75991
78	Shape_94	red	{0,0,0}	-192.1265	10.864296	0.92700005	0	0	37.77568	Shape.usd	2025-03-29 13:21:55.762858
1	Fixture	black	{0,0,0}	73.69697	121.21212	0	180	0	0	Fixture.usd	2025-03-28 14:13:47.982262
2	Holder	black	{0,0,0}	165	440	8.6	180	0	0	Slide_Holder.usd	2025-03-28 14:13:47.98586
125	Shape_100	green	{0,0,0}	-367.67062	-14.866931	0.90000004	0	0	18.43495	Shape.usd	2025-03-29 13:21:55.765744
101	Shape_80	red	{0,0,0}	30.395967	260.81702	0.92200005	0	0	37.69424	Shape.usd	2025-03-29 13:21:56.46765
173	Shape_81	green	{0,0,0}	-270.62216	216.69383	0.934	0	0	21.801407	Shape.usd	2025-03-29 13:21:56.469395
162	Shape_86	Unknown	{0.04,0.04,0.03}	-141.19417	-25.493391	0.9110001	0	0	90	Shape.usd	2025-03-29 13:21:56.471247
99	Shape_41	green	{0.01,0.02,0.01}	-163.8324	33.628754	0.93200004	0	0	5.640549	Shape.usd	2025-03-29 13:13:58.014314
56	Shape_45	green	{0.03,0.04,0.03}	-141.19417	-25.493391	0.90000004	0	0	90	Shape.usd	2025-03-29 13:14:30.420032
59	Shape_48	pink	{0,0,0}	-206.88084	345.12823	0.92100006	0	0	59.03624	Shape.usd	2025-03-29 14:18:20.456453
134	Shape_71	red	{0,0,0}	32.355774	258.8462	0.919	0	0	37.568592	Shape.usd	2025-03-29 14:18:20.459305
86	Shape_65	green	{0,0,0}	-557.1824	-293.39136	0	0	0	43.15239	Shape.usd	2025-03-29 13:13:31.535365
131	Shape_110	green	{0.01,0.01,0.01}	-889.76	43.72752	0.915	0	0	43.058514	Shape.usd	2025-03-29 12:53:22.296805
144	Shape_67	green	{0,0,0}	-271.66885	217.53194	0.92800003	0	0	26.56505	Shape.usd	2025-03-29 14:23:05.098603
147	Shape_74	Unknown	{0,0,0}	-720.676	-41.67765	0.94500005	0	0	45.744057	Shape.usd	2025-03-29 12:08:00.82863
112	Shape_90	green	{0,0,0}	-1337.158	-164.97403	1.7900001	0	0	15.945395	Shape.usd	2025-03-29 12:08:00.830596
166	Shape_126	green	{0.24,0.3,0.23}	-416.29944	-140.56863	0.94500005	0	0	90	Shape.usd	2025-03-29 13:06:31.249357
189	square_1	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:40:46.496856
52	Shape_61	red	{0,0,0}	32.355774	258.8462	0.929	0	0	37.568592	Shape.usd	2025-03-29 13:59:53.4538
117	Shape_106	green	{0,0,0}	-790.08124	-282.29483	0.93000007	0	0	46.684685	Shape.usd	2025-03-29 12:48:01.661156
153	Shape_79	red	{0,0,0}	31.376482	259.8365	0.929	0	0	37.405357	Shape.usd	2025-03-29 13:12:40.699114
118	Shape_108	green	{0,0,0}	-526.0801	-595.847	0.878	0	0	90	Shape.usd	2025-03-29 11:23:19.276637
164	Shape_51	green	{0,0,0}	-491.6627	-60.25706	0.90400004	0	0	46.00509	Shape.usd	2025-03-29 13:07:50.41996
190	circle_1	green	{0,0,0}	127.46696	292.19348	1926.0001	0	0	81.869896	Shape.usd	2025-03-29 14:40:46.499394
191	hexagon_1	red	{0,0,0}	31.376482	259.8365	946.00006	0	0	37.69424	Shape.usd	2025-03-29 14:40:46.501212
192	circle_2	green	{0,0,0}	-270.62216	216.69383	900.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:46.503311
193	pentagon_2	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:40:46.725464
194	square_2	pink	{0,0,0}	-208.68114	346.48944	919	0	0	59.34933	Shape.usd	2025-03-29 14:40:46.727486
195	hexagon_2	red	{0,0,0}	30.514694	260.8514	941.00006	0	0	37.476177	Shape.usd	2025-03-29 14:40:46.729311
196	circle_3	green	{0,0,0}	-272.66354	217.54024	0	0	0	26.56505	Shape.usd	2025-03-29 14:40:46.731192
197	pentagon_3	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:40:46.947267
198	square_3	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:46.949974
199	circle_4	red	{0,0,0}	30.395967	260.81702	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:46.951985
200	circle_5	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:40:46.954084
201	pentagon_4	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:47.179094
202	square_4	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.743565	Shape.usd	2025-03-29 14:40:47.182829
203	hexagon_3	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	Shape.usd	2025-03-29 14:40:47.184756
204	circle_6	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:47.186613
205	pentagon_5	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:47.403369
206	square_5	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:40:47.406019
207	hexagon_4	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:40:47.408481
208	circle_7	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	18.434948	Shape.usd	2025-03-29 14:40:47.41059
209	pentagon_6	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:47.630283
210	square_6	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:47.633916
211	hexagon_5	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:40:47.635743
212	circle_8	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:47.6374
213	pentagon_7	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:40:47.851489
214	square_7	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:40:47.855758
215	hexagon_6	red	{0,0,0}	31.376482	259.8365	933	0	0	37.69424	Shape.usd	2025-03-29 14:40:47.85806
216	circle_9	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:47.859991
217	pentagon_8	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:40:48.081117
218	square_8	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	Shape.usd	2025-03-29 14:40:48.083665
219	hexagon_7	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:48.085512
220	circle_10	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:48.087261
221	pentagon_9	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:40:48.301045
222	square_9	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03624	Shape.usd	2025-03-29 14:40:48.304341
223	pentagon_10	red	{0,0,0}	31.499039	259.86707	917.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:48.306648
224	circle_11	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:48.30922
225	pentagon_11	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:40:48.533134
226	square_10	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.420776	Shape.usd	2025-03-29 14:40:48.536564
227	pentagon_12	red	{0,0,0}	32.357	258.856	919	0	0	37.568592	Shape.usd	2025-03-29 14:40:48.538368
228	circle_12	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:48.540068
229	pentagon_13	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:40:48.766178
230	square_11	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:40:48.769625
231	hexagon_8	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.69424	Shape.usd	2025-03-29 14:40:48.771443
232	circle_13	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:48.773232
233	pentagon_14	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:40:49.003829
234	square_12	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:49.006241
83	Shape_16	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	Shape.usd	2025-03-29 14:36:59.410291
172	Shape_59	pink	{0,0,0}	-206.88867	345.1413	0.92100006	0	0	59.743565	Shape.usd	2025-03-29 13:21:56.465906
65	Shape_13	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:40:39.867946
92	Shape_175	green	{0.09,0.12,0.09}	-955.63605	-489.10507	0	0	0	90	Shape.usd	2025-03-29 12:50:26.343469
140	Shape_66	red	{0,0,0}	31.497837	260.84146	0.924	0	0	37.568592	Shape.usd	2025-03-29 14:23:05.096514
100	Shape_25	pink	{0,0,0}	-206.88867	345.1413	0.924	0	0	59.420776	Shape.usd	2025-03-29 14:14:03.093228
115	Shape_44	green	{0,0,0}	-1055.8131	-135.7474	0.92800003	0	0	26.56505	Shape.usd	2025-03-29 12:58:21.284868
91	Shape_173	green	{0.01,0.02,0.01}	-135.7626	-578.87665	0.88900006	0	0	90	Shape.usd	2025-03-29 11:15:04.174696
129	Shape_103	green	{0,0.01,0}	-1065.6483	-620.1881	0.86600006	0	0	90	Shape.usd	2025-03-29 11:44:01.22385
93	Shape_176	green	{0.01,0.02,0.01}	-758.0079	-576.991	0	0	0	90	Shape.usd	2025-03-29 11:15:04.176802
120	Shape_40	green	{0,0,0}	129.4231	280.4167	1.9300001	0	0	5.194429	Shape.usd	2025-03-29 14:23:39.19732
85	Shape_62	green	{0,0,0}	-270.6119	216.68562	0.92200005	0	0	33.690063	Shape.usd	2025-03-29 13:59:53.455532
94	Shape_42	pink	{0,0,0}	-206.88867	345.1413	0.924	0	0	59.534454	Shape.usd	2025-03-29 14:17:06.187531
138	Shape_97	green	{0.06,0.08,0.06}	-462.3003	-274.98102	0.90700006	0	0	90	Shape.usd	2025-03-29 13:02:17.690746
71	Shape_17	red	{0,0,0}	31.375294	259.82666	0.94500005	0	0	37.568592	Shape.usd	2025-03-29 14:28:42.213887
84	Shape_18	green	{0,0,0}	-270.6119	216.68562	0.91	0	0	18.434948	Shape.usd	2025-03-29 14:28:42.215777
55	Shape_24	pink	{0,0,0}	-206.88084	345.12823	0.929	0	0	59.03625	Shape.usd	2025-03-29 14:23:22.900635
68	Shape_14	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:39.869837
235	hexagon_9	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:40:49.008504
236	circle_14	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	33.690063	Shape.usd	2025-03-29 14:40:49.010642
237	pentagon_15	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:49.224863
238	square_13	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	Shape.usd	2025-03-29 14:40:49.228426
239	hexagon_10	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.405357	Shape.usd	2025-03-29 14:40:49.230217
240	circle_15	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:49.232015
103	Shape_21	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.420776	Shape.usd	2025-03-29 14:29:35.92679
241	pentagon_16	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:49.448948
242	square_14	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.34933	Shape.usd	2025-03-29 14:40:49.451815
243	pentagon_17	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.77568	Shape.usd	2025-03-29 14:40:49.453841
244	circle_16	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:40:49.455668
245	pentagon_18	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:40:49.681873
246	square_15	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:49.684066
247	hexagon_11	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:40:49.685868
248	circle_17	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:40:49.687611
249	pentagon_19	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:49.900393
250	square_16	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.743565	Shape.usd	2025-03-29 14:40:49.903491
251	hexagon_12	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.184704	Shape.usd	2025-03-29 14:40:49.905264
252	circle_18	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:40:49.907035
253	pentagon_20	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:40:50.133503
254	square_17	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03624	Shape.usd	2025-03-29 14:40:50.13587
255	hexagon_13	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	Shape.usd	2025-03-29 14:40:50.137869
256	circle_19	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:50.139637
257	pentagon_21	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:40:50.359311
258	square_18	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:50.363167
259	pentagon_22	red	{0,0,0}	32.357	258.856	929	0	0	36.869896	Shape.usd	2025-03-29 14:40:50.365105
260	circle_20	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:50.366984
261	pentagon_23	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:50.582246
136	Shape_119	green	{0,0,0}	-1412.3082	-593.96136	1.8050001	0	0	35.36246	Shape.usd	2025-03-29 11:59:26.727192
79	Shape_127	green	{0.03,0.03,0.03}	-654.3003	-516.6521	0.90000004	0	0	2.9814613	Shape.usd	2025-03-29 11:59:26.729263
151	Shape_128	green	{0.03,0.03,0.03}	-1138.8973	-601.5037	0.74300003	0	0	90	Shape.usd	2025-03-29 11:59:26.731606
74	Shape_15	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:39:15.351238
64	Shape_12	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.874985	Shape.usd	2025-03-29 14:40:15.458977
76	Shape_19	red	{0,0,0}	30.395967	260.81702	0.924	0	0	37.568592	Shape.usd	2025-03-29 14:15:21.974453
187	Shape_72	green	{0,0,0}	-270.6119	216.68562	0.92100006	0	0	26.56505	Shape.usd	2025-03-29 14:18:20.461324
70	Shape_20	red	{0,0,0}	32.355774	258.8462	0.94500005	0	0	37.568592	Shape.usd	2025-03-29 14:26:31.474739
148	Shape_96	green	{0.05,0.07,0.05}	-423.54602	-270.72012	0.90400004	0	0	90	Shape.usd	2025-03-29 13:07:50.422185
98	Shape_38	orange	{0,0,0}	57.180504	160.10541	2.0600002	0	0	90	Shape.usd	2025-03-29 13:21:55.753777
122	Shape_35	green	{0,0,0}	126.48166	302.96768	1.9160001	0	0	11.309933	Shape.usd	2025-03-29 14:23:39.195624
135	Shape_73	green	{0,0,0}	-1055.9314	-154.61852	0.934	0	0	90	Shape.usd	2025-03-29 11:54:12.802074
137	Shape_120	Unknown	{0,0,0}	-1261.4608	-418.60135	0.92600006	0	0	71.565056	Shape.usd	2025-03-29 11:54:12.80415
262	square_19	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.620872	Shape.usd	2025-03-29 14:40:50.584655
110	Shape_28	pink	{0,0,0}	-417.62222	41.929943	0.933	0	0	59.743565	Shape.usd	2025-03-29 13:34:36.822037
263	hexagon_14	red	{0,0,0}	30.514694	260.8514	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:40:50.586452
123	Shape_34	pink	{0,0,0}	-205.90038	345.12823	0.929	0	0	59.534454	Shape.usd	2025-03-29 13:07:50.869778
89	Shape_27	green	{0,0,0}	122.564384	334.35562	1.9260001	0	0	4.528824	Shape.usd	2025-03-29 14:14:03.095412
264	circle_21	green	{0,0,0}	-272.66354	217.54024	917.00006	0	0	33.690063	Shape.usd	2025-03-29 14:40:50.588185
265	pentagon_24	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:40:50.815924
179	Shape_77	green	{0.02,0.02,0.02}	-172.65541	31.234144	0.94400007	0	0	63.178017	Shape.usd	2025-03-29 13:05:58.618151
180	Shape_95	green	{0,0,0}	-486.7321	-70.276825	0.91800004	0	0	90	Shape.usd	2025-03-29 13:05:58.620257
266	square_20	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:50.81819
181	Shape_124	Unknown	{0,0,0}	-650.7113	-164.84688	1.8210001	0	0	25.346178	Shape.usd	2025-03-29 13:05:58.621997
154	Shape_107	green	{0.18,0.23,0.18}	-859.6015	-329.94806	0.938	0	0	0	Shape.usd	2025-03-29 12:08:00.834914
182	Shape_132	Unknown	{0,0,0}	-629.88855	-178.72871	1.8090001	0	0	33.690063	Shape.usd	2025-03-29 13:05:58.623868
145	Shape_150	green	{0,0,0}	-142.28888	-275.9016	1.937	0	0	60.75117	Shape.usd	2025-03-29 13:05:58.625908
183	Shape_155	green	{0,0,0}	-160.50879	-297.59198	1.9440001	0	0	33.690063	Shape.usd	2025-03-29 13:05:58.628178
184	Shape_157	green	{0,0,0}	-183.9344	-306.26813	0.476	0	0	18.434948	Shape.usd	2025-03-29 13:05:58.630146
185	Shape_159	green	{0.07,0.09,0.07}	-442.4837	-257.6817	0.883	0	0	90	Shape.usd	2025-03-29 13:05:58.632667
267	hexagon_15	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:40:50.820161
268	circle_22	green	{0,0,0}	-270.62216	216.69383	924	0	0	33.690063	Shape.usd	2025-03-29 14:40:50.822006
269	pentagon_25	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:40:51.045104
270	square_21	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:40:51.049535
271	hexagon_16	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:40:51.051456
272	circle_23	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:40:51.053343
95	Shape_55	blue	{0,0,0}	-149.6992	0.91840005	0.93700004	0	0	0.3451511	Shape.usd	2025-03-29 11:54:13.843528
273	pentagon_26	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:51.286674
274	square_22	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	Shape.usd	2025-03-29 14:40:51.290412
275	hexagon_17	red	{0,0,0}	30.394815	260.80713	934	0	0	37.69424	Shape.usd	2025-03-29 14:40:51.292128
143	Shape_43	green	{0,0,0}	-270.6119	216.68562	0.924	0	0	33.690063	Shape.usd	2025-03-29 14:04:42.36021
276	circle_24	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:51.293962
277	pentagon_27	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	Shape.usd	2025-03-29 14:40:51.520491
278	square_23	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.534454	Shape.usd	2025-03-29 14:40:51.522636
279	hexagon_18	red	{0,0,0}	30.514694	260.8514	938	0	0	37.568592	Shape.usd	2025-03-29 14:40:51.524401
88	Shape_26	Unknown	{0.08,0.09,0.08}	-143.1552	23.532362	0.93700004	0	0	90	Shape.usd	2025-03-29 13:09:53.810926
280	circle_25	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:51.526066
281	pentagon_28	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:40:51.754617
282	square_24	pink	{0,0,0}	-207.6968	346.48944	932.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:51.757752
283	pentagon_29	red	{0,0,0}	31.499039	259.86707	929	0	0	37.303947	Shape.usd	2025-03-29 14:40:51.759565
284	circle_26	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:51.761474
285	pentagon_30	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:40:51.983503
286	square_25	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03624	Shape.usd	2025-03-29 14:40:51.987514
287	hexagon_19	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.69424	Shape.usd	2025-03-29 14:40:51.989742
288	circle_27	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:40:51.991543
289	pentagon_31	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:52.221924
90	Shape_33	pink	{0,0,0}	-207.68886	346.4762	0.93100005	0	0	59.03625	Shape.usd	2025-03-29 13:37:50.47207
142	Shape_57	red	{0,0,0}	31.497837	260.84146	0.94600004	0	0	37.568592	Shape.usd	2025-03-29 13:37:50.474782
114	Shape_36	green	{0.01,0.01,0.01}	-149.74277	60.941822	1.9190001	0	0	1.8183031	Shape.usd	2025-03-29 13:13:31.527885
107	Shape_37	orange	{0,0,0}	-222.00235	-20.894339	0.94200003	0	0	37.874985	Shape.usd	2025-03-29 13:13:31.529659
157	Shape_64	green	{0.03,0.05,0.03}	-367.39212	-274.23822	0	0	0	90	Shape.usd	2025-03-29 13:13:31.533402
168	Shape_99	green	{0,0,0}	-800.40375	-43.72752	0.93600005	0	0	61.927513	Shape.usd	2025-03-29 12:53:22.292552
169	Shape_101	green	{0,0,0}	-758.57745	-32.320343	0.938	0	0	46.041622	Shape.usd	2025-03-29 12:53:22.294815
175	Shape_134	orange	{0.19,0.18,0.15}	-270.46378	-72.04743	0	0	0	0	Shape.usd	2025-03-29 13:21:55.769379
170	Shape_129	green	{0,0,0}	-1422.095	-237.64957	1.8180001	0	0	17.525568	Shape.usd	2025-03-29 12:53:22.300661
171	Shape_169	green	{0.13,0.18,0.13}	-922.0803	-481.00272	0.91700006	0	0	0	Shape.usd	2025-03-29 12:53:22.302928
104	Shape_29	green	{0,0,0}	121.57926	332.38202	1.9020001	0	0	3.9182491	Shape.usd	2025-03-29 14:23:22.902496
132	Shape_53	green	{0.03,0.04,0.03}	-141.18883	-25.492426	0.90000004	0	0	90	Shape.usd	2025-03-29 14:03:25.816556
105	Shape_30	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	Shape.usd	2025-03-29 14:29:35.928582
176	Shape_158	green	{0,0.01,0.01}	-483.39355	-88.49692	0.93600005	0	0	37.11686	Shape.usd	2025-03-29 13:05:01.591106
177	Shape_202	green	{0,0,0}	-106.02933	-307.2346	1.9330001	0	0	90	Shape.usd	2025-03-29 13:05:01.593169
178	Shape_204	green	{0.1,0.13,0.1}	-419.10806	-243.78397	0.93000007	0	0	0	Shape.usd	2025-03-29 13:05:01.595465
128	Shape_49	Unknown	{0.04,0.04,0.04}	-141.18883	-25.492426	0.90400004	0	0	90	Shape.usd	2025-03-29 14:04:42.362052
54	Shape_22	red	{0,0,0}	32.355774	258.8462	0.94600004	0	0	37.568592	Shape.usd	2025-03-29 14:25:23.582986
87	Shape_23	green	{0,0,0}	-270.6119	216.68562	0.9110001	0	0	26.56505	Shape.usd	2025-03-29 14:25:23.584895
106	Shape_31	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	Shape.usd	2025-03-29 14:29:35.930291
72	Shape_3	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.874985	Shape.usd	2025-03-29 14:40:37.346743
69	Shape_7	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:38.275012
67	Shape_8	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	Shape.usd	2025-03-29 14:40:38.276821
66	Shape_9	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	Shape.usd	2025-03-29 14:40:38.958562
62	Shape_10	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:38.960561
51	Shape_1	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:40:40.091271
60	Shape_2	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	Shape.usd	2025-03-29 14:40:40.095026
75	Shape_4	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:40:40.097466
61	Shape_5	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:40.099399
290	square_26	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.34933	Shape.usd	2025-03-29 14:40:52.223957
291	hexagon_20	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:40:52.225824
292	circle_28	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:52.227856
293	pentagon_32	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:52.451847
294	square_27	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	Shape.usd	2025-03-29 14:40:52.455755
295	circle_29	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:52.4575
296	circle_30	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:52.459317
297	pentagon_33	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:40:52.688077
298	square_28	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:52.691518
299	circle_31	red	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	Shape.usd	2025-03-29 14:40:52.693267
300	circle_32	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:52.695058
301	pentagon_34	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:52.92131
302	square_29	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.03624	Shape.usd	2025-03-29 14:40:52.924722
303	hexagon_21	red	{0,0,0}	30.514694	260.8514	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:40:52.92643
304	circle_33	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	Shape.usd	2025-03-29 14:40:52.928188
305	pentagon_35	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:40:53.153258
306	square_30	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03625	Shape.usd	2025-03-29 14:40:53.155676
307	hexagon_22	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:40:53.157486
308	circle_34	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:53.159216
309	pentagon_36	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:53.387598
310	square_31	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.743565	Shape.usd	2025-03-29 14:40:53.390833
311	hexagon_23	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.476177	Shape.usd	2025-03-29 14:40:53.392525
312	circle_35	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	Shape.usd	2025-03-29 14:40:53.394318
313	pentagon_37	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:40:53.613581
314	square_32	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03624	Shape.usd	2025-03-29 14:40:53.616053
315	hexagon_24	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:40:53.618161
316	circle_36	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:40:53.620262
63	Shape_11	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:32.944198
152	Shape_91	green	{0.05,0.06,0.05}	-417.84628	-274.18427	0.906	0	0	90	Shape.usd	2025-03-29 13:14:29.970808
119	Shape_39	red	{0,0,0}	31.376482	259.8365	0.94400007	0	0	37.568592	Shape.usd	2025-03-29 13:14:30.416202
121	Shape_32	green	{0,0,0}	122.559746	333.3625	1.9120001	0	0	5.710593	Shape.usd	2025-03-29 14:23:39.193821
317	pentagon_38	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:40:53.83365
159	Shape_60	blue	{0,0,0}	-78.98241	163.4752	0.952	0	0	33.690067	Shape.usd	2025-03-29 12:56:46.861585
139	Shape_50	green	{0,0,0}	-270.6119	216.68562	0.90900004	0	0	26.56505	Shape.usd	2025-03-29 13:03:48.69397
318	square_33	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	Shape.usd	2025-03-29 14:40:53.835769
319	hexagon_25	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.874985	Shape.usd	2025-03-29 14:40:53.838185
320	circle_37	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:40:53.840199
321	pentagon_39	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:40:54.054145
322	square_34	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.34933	Shape.usd	2025-03-29 14:40:54.056201
323	hexagon_26	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:40:54.057956
324	circle_38	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	Shape.usd	2025-03-29 14:40:54.059733
325	pentagon_40	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:40:54.272719
326	square_35	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:54.275726
327	pentagon_41	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:40:54.277911
328	circle_39	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:54.280073
329	pentagon_42	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:40:54.501194
330	square_36	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	Shape.usd	2025-03-29 14:40:54.504781
331	hexagon_27	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:40:54.50675
332	circle_40	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:40:54.508527
333	pentagon_43	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:40:54.722945
334	square_37	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.420776	Shape.usd	2025-03-29 14:40:54.726667
335	hexagon_28	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	Shape.usd	2025-03-29 14:40:54.728448
336	circle_41	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:54.73033
337	pentagon_44	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:54.956706
338	square_38	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:54.960161
339	pentagon_45	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:40:54.961952
340	circle_42	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	Shape.usd	2025-03-29 14:40:54.96398
341	pentagon_46	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:40:55.185893
342	square_39	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	Shape.usd	2025-03-29 14:40:55.187924
343	pentagon_47	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:55.189937
344	circle_43	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:55.191707
345	pentagon_48	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:40:55.404601
346	square_40	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:40:55.407226
347	hexagon_29	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:40:55.408999
348	circle_44	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:55.410647
349	pentagon_49	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:55.636624
350	square_41	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:40:55.640302
351	hexagon_30	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.303947	Shape.usd	2025-03-29 14:40:55.642126
352	circle_45	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	Shape.usd	2025-03-29 14:40:55.643874
353	pentagon_50	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:40:55.873098
354	square_42	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:40:55.876866
355	square_43	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:40:55.878757
356	circle_46	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:55.880756
357	pentagon_51	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:40:56.107058
358	square_44	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:40:56.110775
359	pentagon_52	red	{0,0,0}	32.357	258.856	922.00006	0	0	36.869896	Shape.usd	2025-03-29 14:40:56.112489
360	circle_47	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:56.114476
361	pentagon_53	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:40:56.337502
362	square_45	pink	{0,0,0}	-207.6968	346.48944	909.00006	0	0	59.03624	Shape.usd	2025-03-29 14:40:56.341219
363	hexagon_31	red	{0,0,0}	30.514694	260.8514	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:40:56.34306
364	circle_48	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	Shape.usd	2025-03-29 14:40:56.344863
365	pentagon_54	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:56.579503
366	square_46	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.420776	Shape.usd	2025-03-29 14:40:56.583327
367	circle_49	red	{0,0,0}	30.395967	260.81702	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:56.585134
368	circle_50	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:40:56.586932
369	pentagon_55	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:40:56.808462
370	square_47	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	Shape.usd	2025-03-29 14:40:56.811952
371	hexagon_32	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:56.813975
372	circle_51	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:56.815827
373	pentagon_56	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:57.037664
374	square_48	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:40:57.041434
375	hexagon_33	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:40:57.04321
376	circle_52	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:40:57.044912
377	pentagon_57	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:57.273835
378	square_49	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.534454	Shape.usd	2025-03-29 14:40:57.277105
379	hexagon_34	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:40:57.27891
380	circle_53	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:40:57.280737
381	pentagon_58	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:40:57.506352
382	square_50	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.34933	Shape.usd	2025-03-29 14:40:57.509829
383	hexagon_35	red	{0,0,0}	32.357	258.856	924	0	0	37.694237	Shape.usd	2025-03-29 14:40:57.511692
384	circle_54	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	18.43495	Shape.usd	2025-03-29 14:40:57.513388
385	pentagon_59	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:40:57.736558
386	square_51	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.03624	Shape.usd	2025-03-29 14:40:57.738939
387	hexagon_36	red	{0,0,0}	30.514694	260.8514	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:57.740898
388	circle_55	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	Shape.usd	2025-03-29 14:40:57.74257
389	pentagon_60	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:40:57.955578
390	square_52	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:40:57.958812
391	circle_56	red	{0,0,0}	31.376482	259.8365	916.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:57.960631
392	circle_57	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:57.962349
393	pentagon_61	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:40:58.194189
394	square_53	pink	{0,0,0}	-207.6968	346.48944	930.00006	0	0	59.420776	Shape.usd	2025-03-29 14:40:58.198077
395	hexagon_37	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.234837	Shape.usd	2025-03-29 14:40:58.200198
396	circle_58	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:58.202169
397	pentagon_62	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:58.431705
398	square_54	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.743565	Shape.usd	2025-03-29 14:40:58.435348
399	hexagon_38	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:40:58.437207
400	circle_59	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690067	Shape.usd	2025-03-29 14:40:58.439122
401	pentagon_63	black	{0,0,0}	-128.94919	520.7185	661	0	0	90	Shape.usd	2025-03-29 14:40:58.659443
402	square_55	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.420776	Shape.usd	2025-03-29 14:40:58.66285
403	hexagon_39	red	{0,0,0}	30.514694	260.8514	924	0	0	37.568592	Shape.usd	2025-03-29 14:40:58.66474
404	circle_60	green	{0,0,0}	-272.66354	217.54024	940.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:58.666646
405	pentagon_64	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:58.889598
406	square_56	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	Shape.usd	2025-03-29 14:40:58.893263
407	circle_61	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:58.895112
408	circle_62	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	33.690063	Shape.usd	2025-03-29 14:40:58.896843
409	pentagon_65	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:40:59.120722
410	square_57	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:59.123545
411	hexagon_40	red	{0,0,0}	30.395967	260.81702	938	0	0	37.405357	Shape.usd	2025-03-29 14:40:59.125853
412	circle_63	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:40:59.127995
413	pentagon_66	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:40:59.352098
414	square_58	pink	{0,0,0}	-207.6968	346.48944	934	0	0	59.03625	Shape.usd	2025-03-29 14:40:59.355441
415	pentagon_67	red	{0,0,0}	31.499039	259.86707	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:40:59.357566
416	circle_64	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	21.801407	Shape.usd	2025-03-29 14:40:59.35953
417	pentagon_68	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:40:59.58077
418	square_59	pink	{0,0,0}	-205.90816	345.1413	910	0	0	59.34933	Shape.usd	2025-03-29 14:40:59.583612
419	hexagon_41	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:40:59.585474
420	circle_65	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:40:59.587244
421	pentagon_69	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:40:59.803138
422	square_60	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	Shape.usd	2025-03-29 14:40:59.806748
423	hexagon_42	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:40:59.808685
424	circle_66	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:40:59.810496
425	pentagon_70	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:00.032965
426	square_61	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:00.03503
427	hexagon_43	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:00.036947
428	circle_67	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:00.038769
429	pentagon_71	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:00.266659
430	square_62	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:00.270147
431	hexagon_44	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:00.272252
432	circle_68	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:00.27409
433	pentagon_72	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:00.492849
434	square_63	pink	{0,0,0}	-206.88867	345.1413	916.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:00.495416
435	pentagon_73	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:00.497194
436	circle_69	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:00.49895
437	pentagon_74	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:00.725819
438	square_64	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03624	Shape.usd	2025-03-29 14:41:00.729178
439	hexagon_45	red	{0,0,0}	30.514694	260.8514	932.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:00.731003
440	circle_70	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:00.733011
441	pentagon_75	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:00.96941
442	square_65	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.743565	Shape.usd	2025-03-29 14:41:00.97311
443	pentagon_76	red	{0,0,0}	30.395967	260.81702	920	0	0	37.405357	Shape.usd	2025-03-29 14:41:00.975227
444	circle_71	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:00.977918
445	pentagon_77	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:01.208708
446	square_66	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	Shape.usd	2025-03-29 14:41:01.21254
447	hexagon_46	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:41:01.214413
448	circle_72	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:01.216167
449	pentagon_78	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:01.440267
450	square_67	pink	{0,0,0}	-205.90816	345.1413	907.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:01.443979
451	hexagon_47	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	Shape.usd	2025-03-29 14:41:01.445818
452	circle_73	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	Shape.usd	2025-03-29 14:41:01.447552
453	pentagon_79	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:01.676085
454	square_68	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	Shape.usd	2025-03-29 14:41:01.678405
455	pentagon_80	red	{0,0,0}	32.357	258.856	920	0	0	37.303947	Shape.usd	2025-03-29 14:41:01.680536
456	circle_74	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:01.682292
457	pentagon_81	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:01.909505
458	square_69	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:01.913138
459	pentagon_82	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:01.914951
460	circle_75	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:01.916643
461	pentagon_83	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:02.143348
462	square_70	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	Shape.usd	2025-03-29 14:41:02.146804
463	hexagon_48	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:02.148542
464	circle_76	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:02.150263
465	pentagon_84	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:02.374992
466	square_71	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:02.378431
467	hexagon_49	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:02.380223
468	circle_77	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:02.382012
469	pentagon_85	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:02.610832
470	square_72	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:02.614618
471	pentagon_86	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:02.616493
472	circle_78	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:02.618429
473	pentagon_87	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:02.844228
474	square_73	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:02.847648
475	pentagon_88	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:02.849615
476	circle_79	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:02.85147
477	pentagon_89	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:03.077613
478	square_74	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:03.079676
479	hexagon_50	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:03.081466
480	circle_80	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:03.083203
481	pentagon_90	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:03.31146
482	square_75	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.03625	Shape.usd	2025-03-29 14:41:03.315368
483	hexagon_51	red	{0,0,0}	31.499039	259.86707	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:03.317443
484	circle_81	green	{0,0,0}	-272.66354	217.54024	938	0	0	26.56505	Shape.usd	2025-03-29 14:41:03.31944
485	pentagon_91	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:03.545306
486	square_76	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:03.549595
487	square_77	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:03.551388
488	circle_82	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:03.55329
489	pentagon_92	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:03.776679
490	square_78	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:03.780397
491	hexagon_52	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:03.782296
492	circle_83	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:03.783997
493	pentagon_93	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:41:04.010225
494	square_79	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:41:04.013372
495	pentagon_94	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:04.015518
496	circle_84	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:04.017718
497	pentagon_95	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:04.241995
498	square_80	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:41:04.244483
499	square_81	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:04.246527
500	circle_85	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	Shape.usd	2025-03-29 14:41:04.248288
501	pentagon_96	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:41:04.458683
502	square_82	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:04.460956
503	hexagon_53	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:04.463031
504	circle_86	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:04.464786
505	pentagon_97	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:04.676259
506	square_83	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	Shape.usd	2025-03-29 14:41:04.678609
507	hexagon_54	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:04.680451
508	circle_87	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:04.682163
509	pentagon_98	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:04.892609
510	square_84	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:04.895005
511	hexagon_55	red	{0,0,0}	30.395967	260.81702	934	0	0	37.568592	Shape.usd	2025-03-29 14:41:04.897022
512	circle_88	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:04.898936
513	pentagon_99	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:41:05.111404
514	square_85	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:41:05.114311
515	hexagon_56	red	{0,0,0}	31.376482	259.8365	929	0	0	37.303947	Shape.usd	2025-03-29 14:41:05.116105
516	circle_89	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:05.117922
517	pentagon_100	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:05.34634
518	square_86	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:05.349788
519	hexagon_57	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.874985	Shape.usd	2025-03-29 14:41:05.351634
520	circle_90	green	{0,0,0}	-270.62216	216.69383	920	0	0	18.434948	Shape.usd	2025-03-29 14:41:05.353591
521	pentagon_101	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:05.577279
522	square_87	pink	{0,0,0}	-206.88867	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:05.579836
523	circle_91	red	{0,0,0}	30.395967	260.81702	937.00006	0	0	37.874985	Shape.usd	2025-03-29 14:41:05.58168
524	circle_92	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:05.583339
525	pentagon_102	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:05.797551
526	square_88	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	Shape.usd	2025-03-29 14:41:05.799533
527	pentagon_103	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:05.801453
528	circle_93	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	Shape.usd	2025-03-29 14:41:05.803352
529	pentagon_104	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	Shape.usd	2025-03-29 14:41:06.03044
530	square_89	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:06.034142
531	hexagon_58	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:06.036112
532	circle_94	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:06.038142
533	pentagon_105	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:06.264466
534	square_90	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:06.268394
535	hexagon_59	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:06.270264
536	circle_95	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:06.2721
537	pentagon_106	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:06.501456
538	square_91	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:06.504939
539	hexagon_60	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:06.506727
540	circle_96	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:06.508621
541	pentagon_107	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:06.738917
542	square_92	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:06.743154
543	pentagon_108	red	{0,0,0}	32.357	258.856	929	0	0	37.874985	Shape.usd	2025-03-29 14:41:06.745013
544	circle_97	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:06.746933
545	pentagon_109	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:06.964569
546	square_93	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:06.967487
547	hexagon_61	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:06.969364
548	circle_98	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:06.971247
549	pentagon_110	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:07.199316
550	square_94	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:07.20146
551	hexagon_62	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:07.203262
552	circle_99	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:07.205126
553	pentagon_111	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:07.426811
554	square_95	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.620872	Shape.usd	2025-03-29 14:41:07.430164
555	pentagon_112	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:07.432161
556	circle_100	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:07.433911
557	pentagon_113	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:07.646516
558	square_96	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:41:07.648909
559	hexagon_63	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:41:07.65073
560	circle_101	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:07.652469
561	pentagon_114	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:07.863339
562	square_97	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:07.866292
563	pentagon_115	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.303947	Shape.usd	2025-03-29 14:41:07.868166
564	circle_102	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:07.869929
565	pentagon_116	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:08.095503
566	square_98	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:08.099435
567	hexagon_64	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:08.101417
568	circle_103	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:08.103135
569	pentagon_117	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:08.329293
570	square_99	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:08.331803
571	hexagon_65	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:08.333858
572	circle_104	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:08.335562
573	pentagon_118	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:08.548084
574	square_100	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:08.550267
575	pentagon_119	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:08.552194
576	circle_105	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	Shape.usd	2025-03-29 14:41:08.553936
577	pentagon_120	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:08.781268
578	square_101	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:08.787486
579	square_102	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:08.789928
580	circle_106	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:08.791708
581	pentagon_121	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:09.016913
582	square_103	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:09.019044
583	hexagon_66	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:09.020869
584	circle_107	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:09.022789
585	pentagon_122	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:09.248709
586	square_104	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:09.252238
587	hexagon_67	red	{0,0,0}	30.394815	260.80713	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:09.254012
588	circle_108	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:09.255917
589	pentagon_123	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:09.479077
590	square_105	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:09.481272
591	hexagon_68	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:09.483086
592	circle_109	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:09.484841
593	pentagon_124	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:09.700967
594	square_106	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	Shape.usd	2025-03-29 14:41:09.703616
595	pentagon_125	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:09.705324
596	circle_110	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:09.707316
597	pentagon_126	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:09.931722
598	square_107	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:09.934101
599	pentagon_127	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:09.935916
600	circle_111	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:09.937772
601	pentagon_128	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:10.164048
602	square_108	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:10.168142
603	hexagon_69	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:10.170076
604	circle_112	green	{0,0,0}	-270.62216	216.69383	943	0	0	36.869896	Shape.usd	2025-03-29 14:41:10.171893
605	pentagon_129	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:10.397649
606	square_109	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:10.401047
607	hexagon_70	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:10.40313
608	circle_113	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:10.404944
609	pentagon_130	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:10.636741
610	square_110	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	Shape.usd	2025-03-29 14:41:10.640671
611	hexagon_71	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:10.642818
612	circle_114	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:10.644819
613	pentagon_131	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:10.867915
614	square_111	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:41:10.871452
615	circle_115	red	{0,0,0}	30.395967	260.81702	934	0	0	37.405357	Shape.usd	2025-03-29 14:41:10.873415
616	circle_116	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:41:10.875259
617	pentagon_132	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:11.10187
618	square_112	pink	{0,0,0}	-205.90816	345.1413	936.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:11.105467
619	hexagon_72	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:11.107397
620	circle_117	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:11.10928
621	pentagon_133	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:11.337176
622	square_113	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:11.339761
623	pentagon_134	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:11.342047
624	circle_118	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:11.343735
625	pentagon_135	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:11.56923
626	square_114	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:41:11.571701
627	hexagon_73	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:41:11.573858
628	circle_119	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	Shape.usd	2025-03-29 14:41:11.575781
629	pentagon_136	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:11.801952
630	square_115	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:11.805359
631	hexagon_74	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:41:11.807202
632	circle_120	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:11.809022
633	pentagon_137	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:12.054388
634	square_116	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:12.058108
635	hexagon_75	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	Shape.usd	2025-03-29 14:41:12.060035
636	circle_121	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	Shape.usd	2025-03-29 14:41:12.06188
637	pentagon_138	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:12.291149
638	square_117	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.34933	Shape.usd	2025-03-29 14:41:12.295101
639	pentagon_139	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:12.296923
640	circle_122	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:12.29859
641	pentagon_140	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:12.520721
642	square_118	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:12.523937
643	hexagon_76	red	{0,0,0}	31.376482	259.8365	919	0	0	37.405357	Shape.usd	2025-03-29 14:41:12.525949
644	circle_123	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:12.527834
645	pentagon_141	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:12.748747
646	square_119	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:12.752288
647	hexagon_77	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:41:12.754223
648	circle_124	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	33.690063	Shape.usd	2025-03-29 14:41:12.756021
649	pentagon_142	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:12.969178
650	square_120	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.420776	Shape.usd	2025-03-29 14:41:12.97192
651	hexagon_78	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	Shape.usd	2025-03-29 14:41:12.973788
652	circle_125	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:12.97559
653	pentagon_143	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:13.198118
654	square_121	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:13.201665
655	circle_126	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:13.203696
656	circle_127	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:13.205604
657	pentagon_144	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:13.432188
658	square_122	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:13.436412
659	hexagon_79	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.874985	Shape.usd	2025-03-29 14:41:13.438917
660	circle_128	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	Shape.usd	2025-03-29 14:41:13.441332
661	pentagon_145	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:13.657825
662	square_123	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:13.660385
663	hexagon_80	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:13.662305
664	circle_129	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:13.664114
665	pentagon_146	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:41:13.875968
666	square_124	pink	{0,0,0}	-207.6968	346.48944	928.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:13.878372
667	pentagon_147	red	{0,0,0}	31.499039	259.86707	934	0	0	37.405357	Shape.usd	2025-03-29 14:41:13.880138
668	circle_130	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:13.881853
669	pentagon_148	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:14.100502
670	square_125	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:14.102787
671	hexagon_81	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:14.104818
672	circle_131	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:14.106732
673	pentagon_149	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:14.3362
674	square_126	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:14.338469
675	hexagon_82	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:41:14.340297
676	circle_132	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:14.342025
677	pentagon_150	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:14.572875
678	square_127	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.34933	Shape.usd	2025-03-29 14:41:14.575023
679	hexagon_83	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:14.576834
680	circle_133	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:41:14.57872
681	pentagon_151	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:14.802847
682	square_128	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:14.807529
683	pentagon_152	red	{0,0,0}	31.497837	259.85715	933	0	0	37.405357	Shape.usd	2025-03-29 14:41:14.809906
684	circle_134	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:14.811802
685	pentagon_153	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	Shape.usd	2025-03-29 14:41:15.043223
686	square_129	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	Shape.usd	2025-03-29 14:41:15.047061
687	hexagon_84	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:15.048868
688	circle_135	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:15.050624
689	pentagon_154	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:15.271556
690	square_130	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:41:15.275318
691	hexagon_85	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:15.277314
692	circle_136	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:15.279088
693	pentagon_155	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:15.500757
694	square_131	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:15.504771
695	pentagon_156	red	{0,0,0}	32.357	258.856	924	0	0	37.874985	Shape.usd	2025-03-29 14:41:15.506874
696	circle_137	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:15.508824
697	pentagon_157	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:15.734235
698	square_132	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:15.737862
699	circle_138	orange	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:15.740077
700	circle_139	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	33.690063	Shape.usd	2025-03-29 14:41:15.742005
701	pentagon_158	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:15.966816
702	square_133	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:41:15.970379
703	hexagon_86	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:15.97245
704	circle_140	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:15.974364
705	pentagon_159	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:16.188151
706	square_134	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03625	Shape.usd	2025-03-29 14:41:16.190888
707	pentagon_160	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:16.192661
708	circle_141	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:16.194595
709	pentagon_161	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:16.41724
710	square_135	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:16.420964
711	square_136	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:16.42308
712	circle_142	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:16.424792
713	pentagon_162	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:16.640501
714	square_137	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:16.642491
715	hexagon_87	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.476177	Shape.usd	2025-03-29 14:41:16.64432
716	circle_143	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:16.646131
717	pentagon_163	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:16.871156
718	square_138	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:16.875193
719	hexagon_88	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:16.87712
720	circle_144	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:16.879189
721	pentagon_164	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:17.109248
722	square_139	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:17.11293
723	circle_145	red	{0,0,0}	31.376482	259.8365	933	0	0	37.69424	Shape.usd	2025-03-29 14:41:17.114729
724	circle_146	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:17.116461
725	pentagon_165	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:41:17.333431
726	square_140	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:17.337058
727	square_141	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:17.339186
728	circle_147	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:17.34108
729	pentagon_166	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:17.554939
730	square_142	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:17.557301
731	hexagon_89	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	Shape.usd	2025-03-29 14:41:17.559102
732	circle_148	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:41:17.560825
733	pentagon_167	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:41:17.790287
734	square_143	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:17.793723
735	hexagon_90	red	{0,0,0}	31.499039	259.86707	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:17.795699
736	circle_149	green	{0,0,0}	-272.66354	217.54024	924	0	0	18.434948	Shape.usd	2025-03-29 14:41:17.797535
737	pentagon_168	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:18.021474
738	square_144	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:18.02399
739	hexagon_91	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:18.025944
740	circle_150	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:18.027958
741	pentagon_169	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:18.252822
742	square_145	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:18.25493
743	hexagon_92	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	Shape.usd	2025-03-29 14:41:18.256915
744	circle_151	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:18.258858
745	pentagon_170	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:18.488491
746	square_146	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:18.492299
747	hexagon_93	red	{0,0,0}	31.499039	259.86707	929	0	0	37.568592	Shape.usd	2025-03-29 14:41:18.494092
748	circle_152	green	{0,0,0}	-272.66354	217.54024	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:18.496069
749	pentagon_171	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:18.725272
750	square_147	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:18.72905
751	hexagon_94	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	Shape.usd	2025-03-29 14:41:18.731206
752	circle_153	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:18.733091
753	pentagon_172	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:18.951672
754	square_148	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	Shape.usd	2025-03-29 14:41:18.953592
755	hexagon_95	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:18.955356
756	circle_154	green	{0,0,0}	-270.62216	216.69383	918.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:18.957102
757	pentagon_173	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:41:19.174692
758	square_149	pink	{0,0,0}	-207.6968	346.48944	911.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:19.176927
759	hexagon_96	red	{0,0,0}	31.499039	259.86707	918.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:19.178804
760	circle_155	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:19.180621
761	pentagon_174	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:19.400579
762	square_150	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:19.402951
763	pentagon_175	red	{0,0,0}	32.357	258.856	938	0	0	37.568592	Shape.usd	2025-03-29 14:41:19.404723
764	circle_156	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:19.406612
765	pentagon_176	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:19.626669
766	square_151	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:41:19.629512
767	hexagon_97	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:19.631414
768	circle_157	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:19.633214
769	pentagon_177	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:19.85684
770	square_152	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:19.860705
771	pentagon_178	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:19.862467
772	circle_158	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:19.86464
773	pentagon_179	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:20.097731
774	square_153	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:41:20.10133
775	hexagon_98	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:41:20.103248
776	circle_159	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:20.105005
777	pentagon_180	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:20.327055
778	square_154	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	Shape.usd	2025-03-29 14:41:20.33074
779	hexagon_99	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:20.33267
780	circle_160	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:20.334593
781	pentagon_181	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:20.560179
782	square_155	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:20.563523
783	hexagon_100	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	Shape.usd	2025-03-29 14:41:20.565384
784	circle_161	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:20.567143
785	pentagon_182	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:41:20.791639
786	square_156	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:20.793811
787	hexagon_101	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:20.79566
788	circle_162	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:20.797417
789	pentagon_183	black	{0,0,0}	-127.462135	518.67285	662.00006	0	0	90	Shape.usd	2025-03-29 14:41:21.027811
790	square_157	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:21.031951
791	hexagon_102	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:21.033968
792	circle_163	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:21.035865
793	pentagon_184	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:21.264096
794	square_158	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:41:21.267703
795	hexagon_103	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:21.269552
796	circle_164	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:21.271293
797	pentagon_185	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:21.498046
798	square_159	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:21.500441
799	hexagon_104	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:21.502289
800	circle_165	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:21.504202
801	pentagon_186	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:21.723797
802	square_160	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:21.72755
803	pentagon_187	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:21.729546
804	circle_166	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:21.731708
805	pentagon_188	black	{0,0,0}	-127.46696	518.69244	653.00006	0	0	90	Shape.usd	2025-03-29 14:41:21.95925
806	square_161	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:41:21.962833
807	hexagon_105	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:21.964672
808	circle_167	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	Shape.usd	2025-03-29 14:41:21.966492
809	pentagon_189	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:41:22.193563
810	square_162	pink	{0,0,0}	-207.6968	346.48944	912.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:22.196119
811	hexagon_106	red	{0,0,0}	30.514694	260.8514	932.00006	0	0	37.874985	Shape.usd	2025-03-29 14:41:22.198116
812	circle_168	green	{0,0,0}	-272.66354	217.54024	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:22.199992
813	pentagon_190	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:22.428985
814	square_163	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:22.432867
815	hexagon_107	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	Shape.usd	2025-03-29 14:41:22.43473
816	circle_169	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:22.436609
817	pentagon_191	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:22.658244
818	square_164	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:22.661806
819	hexagon_108	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:41:22.663655
820	circle_170	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:22.665537
821	pentagon_192	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:22.897062
822	square_165	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:22.900755
823	hexagon_109	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	Shape.usd	2025-03-29 14:41:22.902583
824	circle_171	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:22.904258
825	pentagon_193	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:23.120952
826	square_166	pink	{0,0,0}	-206.88867	345.1413	913.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:23.124301
827	square_167	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:23.12642
828	circle_172	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:23.128366
829	pentagon_194	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:23.341994
830	square_168	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:23.345063
831	hexagon_110	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:41:23.347238
832	circle_173	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:23.349272
833	pentagon_195	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:23.583203
834	square_169	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:23.585682
835	hexagon_111	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.874985	Shape.usd	2025-03-29 14:41:23.587506
836	circle_174	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:23.589287
837	pentagon_196	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:23.807549
838	square_170	pink	{0,0,0}	-206.88867	345.1413	907.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:23.810161
839	hexagon_112	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:23.812345
840	circle_175	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:23.814364
841	pentagon_197	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:24.044944
842	square_171	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.534454	Shape.usd	2025-03-29 14:41:24.047241
843	hexagon_113	red	{0,0,0}	30.514694	260.8514	929	0	0	37.69424	Shape.usd	2025-03-29 14:41:24.049435
844	circle_176	green	{0,0,0}	-272.66354	217.54024	924	0	0	33.690063	Shape.usd	2025-03-29 14:41:24.051246
845	pentagon_198	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:24.288216
846	square_172	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:41:24.290587
847	pentagon_199	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:24.292542
848	circle_177	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:24.294345
849	pentagon_200	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:24.512544
850	square_173	pink	{0,0,0}	-205.90816	345.1413	905.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:24.515424
851	pentagon_201	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:41:24.517528
852	circle_178	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:24.519388
853	pentagon_202	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:24.744185
854	square_174	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:24.747992
855	hexagon_114	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.234837	Shape.usd	2025-03-29 14:41:24.750049
856	circle_179	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:24.7519
857	pentagon_203	black	{0,0,0}	-127.46696	518.69244	662.00006	0	0	90	Shape.usd	2025-03-29 14:41:24.97445
858	square_175	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:24.976721
859	hexagon_115	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.874985	Shape.usd	2025-03-29 14:41:24.978519
860	circle_180	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:24.980369
861	pentagon_204	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:25.200711
862	square_176	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	Shape.usd	2025-03-29 14:41:25.203005
863	pentagon_205	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:41:25.204818
864	circle_181	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:25.206599
865	pentagon_206	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:25.432231
866	square_177	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	Shape.usd	2025-03-29 14:41:25.436019
867	hexagon_116	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:25.437961
868	circle_182	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:25.439683
869	pentagon_207	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:25.660701
870	square_178	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:25.664395
871	hexagon_117	red	{0,0,0}	31.376482	259.8365	938	0	0	37.405357	Shape.usd	2025-03-29 14:41:25.666408
872	circle_183	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:25.668519
873	pentagon_208	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:25.895124
874	square_179	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:41:25.898305
875	hexagon_118	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:25.900125
876	circle_184	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	33.690063	Shape.usd	2025-03-29 14:41:25.902136
877	pentagon_209	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:41:26.149138
878	square_180	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:26.154739
879	hexagon_119	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	Shape.usd	2025-03-29 14:41:26.15742
880	circle_185	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:26.16037
881	pentagon_210	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	0	Shape.usd	2025-03-29 14:41:26.378884
882	square_181	pink	{0,0,0}	-206.88867	345.1413	911.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:26.381358
883	hexagon_120	orange	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:26.383222
884	circle_186	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:26.385147
885	pentagon_211	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:26.611961
886	square_182	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03624	Shape.usd	2025-03-29 14:41:26.615666
887	hexagon_121	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:26.61772
888	circle_187	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.43495	Shape.usd	2025-03-29 14:41:26.619549
889	pentagon_212	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:26.845844
890	square_183	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:41:26.849886
891	pentagon_213	red	{0,0,0}	32.357	258.856	929	0	0	36.869896	Shape.usd	2025-03-29 14:41:26.851809
892	circle_188	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:26.853579
893	pentagon_214	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	0	Shape.usd	2025-03-29 14:41:27.081374
894	square_184	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.534454	Shape.usd	2025-03-29 14:41:27.085157
895	hexagon_122	red	{0,0,0}	30.514694	260.8514	929	0	0	37.69424	Shape.usd	2025-03-29 14:41:27.08714
896	circle_189	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:27.088882
897	pentagon_215	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:41:27.310089
898	square_185	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:27.31358
899	pentagon_216	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:27.315478
900	circle_190	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	Shape.usd	2025-03-29 14:41:27.317178
901	pentagon_217	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:27.530281
902	square_186	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:27.53306
903	hexagon_123	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:27.53481
904	circle_191	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:27.53674
905	pentagon_218	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	Shape.usd	2025-03-29 14:41:27.763439
906	square_187	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	Shape.usd	2025-03-29 14:41:27.765862
907	hexagon_124	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:27.767828
908	circle_192	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:27.769809
909	pentagon_219	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:28.001803
910	square_188	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:28.005339
911	hexagon_125	orange	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:28.007194
912	circle_193	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	Shape.usd	2025-03-29 14:41:28.009001
913	pentagon_220	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:28.244271
914	square_189	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:28.246412
915	hexagon_126	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:28.248396
916	circle_194	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:28.250194
917	pentagon_221	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:41:28.467705
918	square_190	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.743565	Shape.usd	2025-03-29 14:41:28.470543
919	pentagon_222	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:28.47233
920	circle_195	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:28.474007
921	pentagon_223	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:28.700517
922	square_191	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:28.704769
923	hexagon_127	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:28.706884
924	circle_196	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:28.708671
925	pentagon_224	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:28.94223
926	square_192	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:28.945117
927	hexagon_128	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:41:28.947752
928	circle_197	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:28.950565
929	pentagon_225	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:29.178532
930	square_193	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:29.18095
931	hexagon_129	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:41:29.182998
932	circle_198	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:29.184727
933	pentagon_226	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:29.404681
934	square_194	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:29.407043
935	square_195	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:29.408816
936	circle_199	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:29.410544
937	pentagon_227	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:29.631753
938	square_196	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	Shape.usd	2025-03-29 14:41:29.635442
939	pentagon_228	red	{0,0,0}	32.357	258.856	920	0	0	37.874985	Shape.usd	2025-03-29 14:41:29.63757
940	circle_200	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:29.639435
941	pentagon_229	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	Shape.usd	2025-03-29 14:41:29.865037
942	square_197	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:29.86758
943	hexagon_130	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	Shape.usd	2025-03-29 14:41:29.869435
944	circle_201	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:29.871323
945	pentagon_230	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:41:30.105293
946	square_198	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:30.109161
947	pentagon_231	red	{0,0,0}	31.499039	259.86707	916.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:30.110978
948	circle_202	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:30.112755
949	pentagon_232	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:41:30.334876
950	square_199	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.03624	Shape.usd	2025-03-29 14:41:30.337063
951	hexagon_131	red	{0,0,0}	30.514694	260.8514	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:30.338875
952	circle_203	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:30.340726
953	pentagon_233	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:30.570336
954	square_200	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:30.573895
955	pentagon_234	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.234837	Shape.usd	2025-03-29 14:41:30.575682
956	circle_204	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:30.577472
957	pentagon_235	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:30.798144
958	square_201	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:30.801794
959	hexagon_132	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:30.804007
960	circle_205	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:30.806078
961	pentagon_236	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:31.026108
962	square_202	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:31.02957
963	hexagon_133	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:31.031442
964	circle_206	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:31.033455
965	pentagon_237	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:31.248746
966	square_203	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	Shape.usd	2025-03-29 14:41:31.251626
967	hexagon_134	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:31.253586
968	circle_207	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:31.255599
969	pentagon_238	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:31.486189
970	square_204	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:31.489742
971	square_205	red	{0,0,0}	32.357	258.856	924	0	0	37.874985	Shape.usd	2025-03-29 14:41:31.491572
972	circle_208	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:31.493316
973	pentagon_239	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:41:31.713144
974	square_206	pink	{0,0,0}	-207.6968	346.48944	928.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:31.715754
975	hexagon_135	red	{0,0,0}	29.53035	261.83575	929	0	0	37.568592	Shape.usd	2025-03-29 14:41:31.717836
976	circle_209	green	{0,0,0}	-272.66354	217.54024	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:31.719668
977	pentagon_240	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:31.934367
978	square_207	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	Shape.usd	2025-03-29 14:41:31.93719
979	pentagon_241	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:31.939198
980	circle_210	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:31.941087
981	pentagon_242	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:32.16864
982	square_208	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:32.172442
983	hexagon_136	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.874985	Shape.usd	2025-03-29 14:41:32.174342
984	circle_211	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:32.176131
985	pentagon_243	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:32.401606
986	square_209	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:32.405208
987	hexagon_137	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:32.40709
988	circle_212	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:41:32.408839
989	pentagon_244	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:32.659207
990	square_210	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:32.661536
991	hexagon_138	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:32.66329
992	circle_213	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:32.665045
993	pentagon_245	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:32.893654
994	square_211	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:41:32.897086
995	circle_214	red	{0,0,0}	31.376482	259.8365	929	0	0	37.234837	Shape.usd	2025-03-29 14:41:32.898911
996	circle_215	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:32.901004
997	pentagon_246	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:33.12102
998	square_212	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:41:33.123316
999	hexagon_139	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:33.12507
1000	circle_216	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:33.126811
1001	pentagon_247	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:33.35316
1002	square_213	pink	{0,0,0}	-206.88867	345.1413	926.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:33.356821
1003	hexagon_140	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.694237	Shape.usd	2025-03-29 14:41:33.358707
1004	circle_217	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:33.36048
1005	pentagon_248	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:33.591025
1006	square_214	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:33.595501
1007	circle_218	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:33.59806
1008	circle_219	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:33.600951
1009	pentagon_249	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:33.817526
1010	square_215	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03625	Shape.usd	2025-03-29 14:41:33.819723
1011	hexagon_141	red	{0,0,0}	30.514694	260.8514	924	0	0	37.303947	Shape.usd	2025-03-29 14:41:33.821681
1012	circle_220	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:33.82368
1013	pentagon_250	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:34.049521
1014	square_216	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:34.05212
1015	hexagon_142	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:34.054455
1016	circle_221	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:34.056465
1017	pentagon_251	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:34.301502
1018	square_217	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:34.303753
1019	hexagon_143	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.184704	Shape.usd	2025-03-29 14:41:34.30556
1020	circle_222	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:34.307507
1021	pentagon_252	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:34.529312
1022	square_218	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:34.531813
1023	pentagon_253	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:41:34.5336
1024	circle_223	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	Shape.usd	2025-03-29 14:41:34.535609
1025	pentagon_254	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	Shape.usd	2025-03-29 14:41:34.756938
1026	square_219	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.420776	Shape.usd	2025-03-29 14:41:34.759244
1027	square_220	red	{0,0,0}	31.499039	259.86707	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:34.760997
1028	circle_224	green	{0,0,0}	-272.66354	217.54024	922.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:34.762703
1029	pentagon_255	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:34.989037
1030	square_221	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:34.992382
1031	hexagon_144	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	Shape.usd	2025-03-29 14:41:34.994285
1032	circle_225	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:34.996091
1033	pentagon_256	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:35.223141
1034	square_222	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	Shape.usd	2025-03-29 14:41:35.227102
1035	square_223	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	Shape.usd	2025-03-29 14:41:35.229181
1036	circle_226	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:35.231232
1037	pentagon_257	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:41:35.450295
1038	square_224	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:35.453947
1039	hexagon_145	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:35.455849
1040	circle_227	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:35.457823
1041	pentagon_258	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:35.685796
1042	square_225	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.743565	Shape.usd	2025-03-29 14:41:35.689268
1043	hexagon_146	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:35.691177
1044	circle_228	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:35.693135
1045	pentagon_259	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:35.914701
1046	square_226	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:35.917357
1047	square_227	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:35.919175
1048	circle_229	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:35.921567
1049	pentagon_260	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:36.147671
1050	square_228	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:36.151155
1051	hexagon_147	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:36.153106
1052	circle_230	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:36.155263
1053	pentagon_261	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:36.368601
1054	square_229	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:36.371577
1055	pentagon_262	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.303947	Shape.usd	2025-03-29 14:41:36.373539
1056	circle_231	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:36.375372
1057	pentagon_263	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:36.604841
1058	square_230	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:36.608557
1059	hexagon_148	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:41:36.610506
1060	circle_232	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:36.612254
1061	pentagon_264	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:41:36.838505
1062	square_231	pink	{0,0,0}	-205.90816	345.1413	948.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:36.842432
1063	hexagon_149	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:36.844466
1064	circle_233	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:36.846259
1065	pentagon_265	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:37.06722
1066	square_232	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	Shape.usd	2025-03-29 14:41:37.070571
1067	hexagon_150	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	Shape.usd	2025-03-29 14:41:37.072581
1068	circle_234	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:37.07444
1069	pentagon_266	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:37.303752
1070	square_233	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.743565	Shape.usd	2025-03-29 14:41:37.307646
1071	hexagon_151	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:37.30965
1072	circle_235	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:37.31152
1073	pentagon_267	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:41:37.548931
1074	square_234	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:37.552316
1075	pentagon_268	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:37.554519
1076	circle_236	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:41:37.556816
1077	pentagon_269	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:37.776625
1078	square_235	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:37.77936
1079	circle_237	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:37.781255
1080	circle_238	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:37.783035
1081	pentagon_270	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	Shape.usd	2025-03-29 14:41:38.020488
1082	square_236	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:38.02416
1083	hexagon_152	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:38.026125
1084	circle_239	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:38.028028
1085	pentagon_271	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:38.252397
1086	square_237	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:41:38.254737
1087	hexagon_153	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:38.256797
1088	circle_240	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:38.258627
1089	pentagon_272	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:38.474853
1090	square_238	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:38.477123
1091	hexagon_154	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:38.478895
1092	circle_241	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:38.480618
1093	pentagon_273	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:38.707721
1094	square_239	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:38.711541
1095	hexagon_155	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	Shape.usd	2025-03-29 14:41:38.713699
1096	circle_242	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:38.715681
1097	pentagon_274	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:38.941119
1098	square_240	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:38.943524
1099	hexagon_156	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:38.945547
1100	circle_243	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:38.947352
1101	pentagon_275	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:39.177747
1102	square_241	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:39.179999
1103	hexagon_157	red	{0,0,0}	31.376482	260.81702	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:39.181837
1104	circle_244	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:39.183557
1105	pentagon_276	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:39.417648
1106	square_242	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:41:39.419651
1107	hexagon_158	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:39.421532
1108	circle_245	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:39.423448
1109	pentagon_277	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:39.641697
1110	square_243	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	Shape.usd	2025-03-29 14:41:39.644788
1111	square_244	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.303947	Shape.usd	2025-03-29 14:41:39.646599
1112	circle_246	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:39.648333
1113	pentagon_278	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:39.87293
1114	square_245	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	Shape.usd	2025-03-29 14:41:39.875396
1115	hexagon_159	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:39.877317
1116	circle_247	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:39.879173
1117	pentagon_279	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:40.099423
1118	square_246	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.620872	Shape.usd	2025-03-29 14:41:40.102945
1119	hexagon_160	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	Shape.usd	2025-03-29 14:41:40.104668
1120	circle_248	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:40.106453
1121	pentagon_280	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:40.326084
1122	square_247	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	Shape.usd	2025-03-29 14:41:40.329655
1123	hexagon_161	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:40.33161
1124	circle_249	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:40.333562
1125	pentagon_281	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:40.551195
1126	square_248	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:40.554556
1127	pentagon_282	red	{0,0,0}	32.357	258.856	919	0	0	37.69424	Shape.usd	2025-03-29 14:41:40.556566
1128	circle_250	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:40.558596
1129	pentagon_283	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:40.771646
1130	square_249	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	Shape.usd	2025-03-29 14:41:40.774548
1131	hexagon_162	red	{0,0,0}	32.357	258.856	913.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:40.776735
1132	circle_251	green	{0,0,0}	-270.62216	216.69383	933	0	0	18.434948	Shape.usd	2025-03-29 14:41:40.778662
1133	pentagon_284	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:41.017404
1134	square_250	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:41:41.02095
1135	hexagon_163	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.874985	Shape.usd	2025-03-29 14:41:41.02279
1136	circle_252	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:41.02479
1137	pentagon_285	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:41.25105
1138	square_251	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	Shape.usd	2025-03-29 14:41:41.253428
1139	pentagon_286	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:41.255395
1140	circle_253	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:41.257236
1141	pentagon_287	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:41.47577
1142	square_252	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:41.47836
1143	pentagon_288	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:41.480235
1144	circle_254	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:41.482114
1145	pentagon_289	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:41.715013
1146	square_253	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:41.718778
1147	circle_255	red	{0,0,0}	30.395967	260.81702	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:41.720608
1148	circle_256	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	Shape.usd	2025-03-29 14:41:41.722356
1149	pentagon_290	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:41.948038
1150	square_254	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:41.950295
1151	hexagon_164	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:41.952223
1152	circle_257	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:41.95401
1153	pentagon_291	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:42.168332
1154	square_255	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	Shape.usd	2025-03-29 14:41:42.17187
1155	pentagon_292	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:41:42.173704
1156	circle_258	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:42.176323
1157	pentagon_293	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:41:42.401882
1158	square_256	pink	{0,0,0}	-207.6968	346.48944	926.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:42.405802
1159	hexagon_165	red	{0,0,0}	31.499039	259.86707	917.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:42.40828
1160	circle_259	green	{0,0,0}	-272.66354	217.54024	933	0	0	18.434948	Shape.usd	2025-03-29 14:41:42.4109
1161	pentagon_294	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:41:42.63088
1162	square_257	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:42.632991
1163	hexagon_166	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:42.634905
1164	circle_260	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:42.637043
1165	pentagon_295	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:42.851959
1166	square_258	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:42.85542
1167	hexagon_167	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:42.857226
1168	circle_261	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:42.859048
1169	pentagon_296	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:43.077135
1170	square_259	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:43.0801
1171	pentagon_297	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:43.081965
1172	circle_262	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:43.083699
1173	pentagon_298	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:43.303942
1174	square_260	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:43.308008
1175	hexagon_168	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:43.309982
1176	circle_263	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.43495	Shape.usd	2025-03-29 14:41:43.311977
1177	pentagon_299	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:43.536046
1178	square_261	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:43.539778
1179	pentagon_300	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:43.541617
1180	circle_264	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:43.543395
1181	pentagon_301	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:43.77726
1182	square_262	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:43.780965
1183	hexagon_169	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.874985	Shape.usd	2025-03-29 14:41:43.783163
1184	circle_265	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:43.785049
1185	pentagon_302	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:44.00094
1186	square_263	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	Shape.usd	2025-03-29 14:41:44.003188
1187	hexagon_170	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:44.005428
1188	circle_266	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:44.008288
1189	pentagon_303	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:44.227648
1190	square_264	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:41:44.229886
1191	pentagon_304	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	Shape.usd	2025-03-29 14:41:44.231963
1192	circle_267	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:41:44.233788
1193	pentagon_305	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	Shape.usd	2025-03-29 14:41:44.46308
1194	square_265	pink	{0,0,0}	-206.88084	345.12823	914.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:44.46536
1195	hexagon_171	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	Shape.usd	2025-03-29 14:41:44.467377
1196	circle_268	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:44.469371
1197	pentagon_306	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:44.683175
1198	square_266	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:44.687098
1199	hexagon_172	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:41:44.689078
1200	circle_269	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:44.691086
1201	pentagon_307	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:44.910141
1202	square_267	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:41:44.912945
1203	hexagon_173	red	{0,0,0}	32.357	258.856	937.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:44.914941
1204	circle_270	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:44.91685
1205	pentagon_308	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:45.150922
1206	square_268	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:45.154378
1207	pentagon_309	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	Shape.usd	2025-03-29 14:41:45.156275
1208	circle_271	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:45.157993
1209	pentagon_310	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:45.377588
1210	square_269	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.34933	Shape.usd	2025-03-29 14:41:45.380137
1211	circle_272	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:45.382007
1212	circle_273	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:45.383799
1213	pentagon_311	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:41:45.61267
1214	square_270	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:41:45.616429
1215	hexagon_174	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:45.618465
1216	circle_274	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:45.620389
1217	pentagon_312	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:41:45.85451
1218	square_271	pink	{0,0,0}	-205.90816	345.1413	906	0	0	59.03624	Shape.usd	2025-03-29 14:41:45.858194
1219	hexagon_175	red	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.303947	Shape.usd	2025-03-29 14:41:45.860245
1220	circle_275	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:45.86245
1221	pentagon_313	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:46.076128
1222	square_272	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:41:46.079725
1223	pentagon_314	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:46.081886
1224	circle_276	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:46.083796
1225	pentagon_315	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:46.314891
1226	square_273	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:46.318585
1227	hexagon_176	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:46.320641
1228	circle_277	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:46.322421
1229	pentagon_316	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:46.543996
1230	square_274	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:41:46.547692
1231	hexagon_177	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:46.549845
1232	circle_278	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:46.551579
1233	pentagon_317	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:46.774385
1234	square_275	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:46.776719
1235	pentagon_318	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:46.778673
1236	circle_279	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:46.781046
1237	pentagon_319	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:47.009718
1238	square_276	pink	{0,0,0}	-206.88867	345.1413	917.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:47.013473
1239	hexagon_178	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.694237	Shape.usd	2025-03-29 14:41:47.015516
1240	circle_280	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:47.017344
1241	pentagon_320	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:47.243742
1242	square_277	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:47.247454
1243	hexagon_179	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:47.249419
1244	circle_281	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	Shape.usd	2025-03-29 14:41:47.251307
1245	pentagon_321	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:47.480119
1246	square_278	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:47.482532
1247	pentagon_322	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:47.484438
1248	circle_282	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	Shape.usd	2025-03-29 14:41:47.486245
1249	pentagon_323	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:47.709166
1250	square_279	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:47.712693
1251	hexagon_180	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:47.71497
1252	circle_283	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:47.717233
1253	pentagon_324	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:47.943924
1254	square_280	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.620872	Shape.usd	2025-03-29 14:41:47.94921
1255	hexagon_181	red	{0,0,0}	31.499039	259.86707	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:47.951525
1256	circle_284	green	{0,0,0}	-272.66354	217.54024	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:47.95334
1257	pentagon_325	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:48.179237
1258	square_281	pink	{0,0,0}	-205.90816	345.1413	909.00006	0	0	59.743565	Shape.usd	2025-03-29 14:41:48.181517
1259	square_282	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:48.183493
1260	circle_285	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:48.18533
1261	pentagon_326	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:48.403822
1262	square_283	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:48.408141
1263	circle_286	red	{0,0,0}	30.395967	260.81702	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:48.409897
1264	circle_287	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:48.412133
1265	pentagon_327	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:48.626525
1266	square_284	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	Shape.usd	2025-03-29 14:41:48.630389
1267	hexagon_182	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	Shape.usd	2025-03-29 14:41:48.63248
1268	circle_288	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:48.634441
1269	pentagon_328	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:48.860643
1270	square_285	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.62088	Shape.usd	2025-03-29 14:41:48.863821
1271	hexagon_183	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:48.866043
1272	circle_289	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:48.868019
1273	pentagon_329	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:49.089159
1274	square_286	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:41:49.091261
1275	circle_290	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:49.093053
1276	circle_291	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	36.869896	Shape.usd	2025-03-29 14:41:49.094879
1277	pentagon_330	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:49.326544
1278	square_287	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:49.330342
1279	hexagon_184	red	{0,0,0}	31.376482	259.8365	938	0	0	37.568592	Shape.usd	2025-03-29 14:41:49.332678
1280	circle_292	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:49.334749
1281	pentagon_331	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	Shape.usd	2025-03-29 14:41:49.569335
1282	square_288	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:49.571673
1283	hexagon_185	red	{0,0,0}	30.51353	260.84146	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:49.573517
1284	circle_293	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:49.575304
1285	pentagon_332	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:49.79792
1286	square_289	pink	{0,0,0}	-207.6968	346.48944	913.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:49.801616
1287	square_290	red	{0,0,0}	31.499039	259.86707	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:49.803429
1288	circle_294	green	{0,0,0}	-272.66354	217.54024	936.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:49.80525
1289	pentagon_333	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:50.032283
1290	square_291	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:50.036138
1291	pentagon_334	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:41:50.038055
1292	circle_295	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:50.039927
1293	pentagon_335	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:50.263684
1294	square_292	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	Shape.usd	2025-03-29 14:41:50.267659
1295	pentagon_336	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	Shape.usd	2025-03-29 14:41:50.269549
1296	circle_296	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:50.271315
1297	pentagon_337	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:41:50.503813
1298	square_293	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.03624	Shape.usd	2025-03-29 14:41:50.505964
1299	hexagon_186	red	{0,0,0}	30.514694	260.8514	932.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:50.507814
1300	circle_297	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:50.509514
1301	pentagon_338	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:50.735048
1302	square_294	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:41:50.737128
1303	hexagon_187	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.303947	Shape.usd	2025-03-29 14:41:50.738987
1304	circle_298	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:50.740754
1305	pentagon_339	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	Shape.usd	2025-03-29 14:41:50.963276
1306	square_295	pink	{0,0,0}	-205.90038	345.12823	910	0	0	59.03624	Shape.usd	2025-03-29 14:41:50.96706
1307	hexagon_188	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:50.969171
1308	circle_299	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:50.970942
1309	pentagon_340	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:51.196065
1310	square_296	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:51.200158
1311	hexagon_189	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:51.202135
1312	circle_300	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:51.203984
1313	pentagon_341	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:41:51.429534
1314	square_297	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:51.43319
1315	hexagon_190	red	{0,0,0}	30.394815	260.80713	929	0	0	37.568592	Shape.usd	2025-03-29 14:41:51.435201
1316	circle_301	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:51.437136
1317	pentagon_342	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:51.648084
1318	square_298	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	Shape.usd	2025-03-29 14:41:51.650679
1319	hexagon_191	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:51.652738
1320	circle_302	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:51.654563
1321	pentagon_343	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:51.884841
1322	square_299	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:41:51.888463
1323	hexagon_192	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:51.890245
1324	circle_303	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:51.891971
1325	pentagon_344	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:52.111886
1326	square_300	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:52.114118
1327	circle_304	red	{0,0,0}	30.395967	260.81702	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:52.116243
1328	circle_305	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:52.11818
1329	pentagon_345	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	Shape.usd	2025-03-29 14:41:52.342965
1330	square_301	pink	{0,0,0}	-207.6968	346.48944	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:52.346206
1331	hexagon_193	red	{0,0,0}	30.514694	260.8514	929	0	0	37.568592	Shape.usd	2025-03-29 14:41:52.348327
1332	circle_306	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:52.351797
1333	pentagon_346	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:52.565923
1334	square_302	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:52.56877
1335	pentagon_347	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:52.570974
1336	circle_307	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:52.573025
1337	pentagon_348	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:41:52.80368
1338	square_303	pink	{0,0,0}	-207.6968	346.48944	931.00006	0	0	59.620872	Shape.usd	2025-03-29 14:41:52.807377
1339	hexagon_194	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:52.809222
1340	circle_308	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:52.810964
1341	pentagon_349	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:53.029429
1342	square_304	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:53.033084
1343	hexagon_195	red	{0,0,0}	31.376482	259.8365	924	0	0	37.746803	Shape.usd	2025-03-29 14:41:53.035681
1344	circle_309	green	{0,0,0}	-270.62216	216.69383	933	0	0	18.434948	Shape.usd	2025-03-29 14:41:53.037693
1345	pentagon_350	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:53.26816
1346	square_305	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:41:53.271808
1347	pentagon_351	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:53.273645
1348	circle_310	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:53.275466
1349	pentagon_352	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:53.497804
1350	square_306	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:53.500472
1351	hexagon_196	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:53.502685
1352	circle_311	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:53.50457
1353	pentagon_353	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:53.726268
1354	square_307	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:53.730027
1355	hexagon_197	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:53.731984
1356	circle_312	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:53.733768
1357	pentagon_354	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	Shape.usd	2025-03-29 14:41:53.95099
1358	square_308	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.34933	Shape.usd	2025-03-29 14:41:53.955341
1359	hexagon_198	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:53.957448
1360	circle_313	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:53.95934
1361	pentagon_355	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:54.182453
1362	square_309	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	Shape.usd	2025-03-29 14:41:54.185044
1363	hexagon_199	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:54.187316
1364	circle_314	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:41:54.189152
1365	pentagon_356	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:41:54.420784
1366	square_310	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:54.42317
1367	hexagon_200	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:54.425057
1368	circle_315	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:54.426889
1369	pentagon_357	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:54.65195
1370	square_311	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	Shape.usd	2025-03-29 14:41:54.654399
1371	hexagon_201	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:54.656356
1372	circle_316	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	Shape.usd	2025-03-29 14:41:54.658097
1373	pentagon_358	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:41:54.891842
1374	square_312	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	Shape.usd	2025-03-29 14:41:54.894033
1375	pentagon_359	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:54.896208
1376	circle_317	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:54.898041
1377	pentagon_360	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:41:55.118367
1378	square_313	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:55.12062
1379	hexagon_202	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:41:55.122873
1380	circle_318	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	Shape.usd	2025-03-29 14:41:55.12472
1381	pentagon_361	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:55.360715
1382	square_314	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:55.364458
1383	hexagon_203	red	{0,0,0}	30.514694	260.8514	934	0	0	37.694237	Shape.usd	2025-03-29 14:41:55.366355
1384	circle_319	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:55.36807
1385	pentagon_362	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:41:55.588769
1386	square_315	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03624	Shape.usd	2025-03-29 14:41:55.591935
1387	pentagon_363	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	Shape.usd	2025-03-29 14:41:55.594034
1388	circle_320	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:41:55.595973
1389	pentagon_364	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:55.822942
1390	square_316	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:55.826596
1391	hexagon_204	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:55.828586
1392	circle_321	green	{0,0,0}	-270.62216	216.69383	918.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:55.830423
1393	pentagon_365	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:56.046733
1394	square_317	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:56.050293
1395	square_318	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.874985	Shape.usd	2025-03-29 14:41:56.052525
1396	circle_322	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:56.05462
1397	pentagon_366	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:56.27439
1398	square_319	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03625	Shape.usd	2025-03-29 14:41:56.2768
1399	hexagon_205	red	{0,0,0}	30.514694	260.8514	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:56.278669
1400	circle_323	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:56.280386
1401	pentagon_367	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:56.509052
1402	square_320	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:41:56.512824
1403	hexagon_206	red	{0,0,0}	31.376482	259.8365	929	0	0	37.303947	Shape.usd	2025-03-29 14:41:56.51478
1404	circle_324	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:56.516878
1405	pentagon_368	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:56.735886
1406	square_321	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:56.739635
1407	hexagon_207	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:56.741488
1408	circle_325	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:56.743207
1409	pentagon_369	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:56.969106
1410	square_322	pink	{0,0,0}	-207.6968	346.48944	928.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:56.972568
1411	hexagon_208	red	{0,0,0}	30.514694	260.8514	934	0	0	37.303947	Shape.usd	2025-03-29 14:41:56.974492
1412	circle_326	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:56.976213
1413	pentagon_370	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:57.204989
1414	square_323	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:57.208627
1415	hexagon_209	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:57.210653
1416	circle_327	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:57.212452
1417	pentagon_371	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:57.432527
1418	square_324	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	Shape.usd	2025-03-29 14:41:57.43609
1419	hexagon_210	red	{0,0,0}	30.395967	260.81702	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:57.438072
1420	circle_328	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:57.439922
1421	pentagon_372	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:41:57.672532
1422	square_325	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	Shape.usd	2025-03-29 14:41:57.674919
1423	pentagon_373	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:41:57.676699
1424	circle_329	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:57.678411
1425	pentagon_374	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:57.904308
1426	square_326	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.420776	Shape.usd	2025-03-29 14:41:57.907069
1427	hexagon_211	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	Shape.usd	2025-03-29 14:41:57.90898
1428	circle_330	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.43495	Shape.usd	2025-03-29 14:41:57.910767
1429	pentagon_375	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:58.139875
1430	square_327	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:58.143643
1431	hexagon_212	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	Shape.usd	2025-03-29 14:41:58.145493
1432	circle_331	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	Shape.usd	2025-03-29 14:41:58.147333
1433	pentagon_376	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:58.374585
1434	square_328	pink	{0,0,0}	-206.88867	345.1413	926.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:58.37805
1435	hexagon_213	red	{0,0,0}	30.395967	260.81702	922.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:58.379902
1436	circle_332	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:58.381677
1437	pentagon_377	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:58.608109
1438	square_329	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.420776	Shape.usd	2025-03-29 14:41:58.612794
1439	hexagon_214	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:41:58.616938
1440	circle_333	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	Shape.usd	2025-03-29 14:41:58.620854
1441	pentagon_378	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:41:58.843049
1442	square_330	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.34933	Shape.usd	2025-03-29 14:41:58.846432
1443	circle_334	red	{0,0,0}	30.514694	260.8514	929	0	0	37.69424	Shape.usd	2025-03-29 14:41:58.848406
1444	circle_335	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:58.850112
1445	pentagon_379	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:59.074148
1446	square_331	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:41:59.076235
1447	pentagon_380	red	{0,0,0}	32.357	258.856	934	0	0	37.69424	Shape.usd	2025-03-29 14:41:59.07795
1448	circle_336	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:41:59.079696
1449	pentagon_381	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:41:59.300237
1450	square_332	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	Shape.usd	2025-03-29 14:41:59.304063
1451	hexagon_215	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:41:59.306459
1452	circle_337	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.43495	Shape.usd	2025-03-29 14:41:59.308367
1453	pentagon_382	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:41:59.524091
1454	square_333	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:59.527069
1455	hexagon_216	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	Shape.usd	2025-03-29 14:41:59.528761
1456	circle_338	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	Shape.usd	2025-03-29 14:41:59.530597
1457	pentagon_383	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:41:59.746769
1458	square_334	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:41:59.752062
1459	hexagon_217	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:41:59.755087
1460	circle_339	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:41:59.75954
1461	pentagon_384	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:41:59.997929
1462	square_335	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:42:00.000138
1463	pentagon_385	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:00.002085
1464	circle_340	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:42:00.004073
1465	pentagon_386	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:00.23036
1466	square_336	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.420776	Shape.usd	2025-03-29 14:42:00.232598
1467	circle_341	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:00.234489
1468	circle_342	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:42:00.236257
1469	pentagon_387	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:00.457066
1470	square_337	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	Shape.usd	2025-03-29 14:42:00.459701
1471	hexagon_218	red	{0,0,0}	31.376482	259.8365	929	0	0	36.869896	Shape.usd	2025-03-29 14:42:00.461613
1472	circle_343	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:00.463452
1473	pentagon_388	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:00.691945
1474	square_338	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.420776	Shape.usd	2025-03-29 14:42:00.695556
1475	hexagon_219	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	Shape.usd	2025-03-29 14:42:00.697384
1476	circle_344	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:00.699148
1477	pentagon_389	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:00.926584
1478	square_339	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.420776	Shape.usd	2025-03-29 14:42:00.930233
1479	hexagon_220	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:00.93222
1480	circle_345	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:00.933989
1481	pentagon_390	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:01.166773
1482	square_340	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	Shape.usd	2025-03-29 14:42:01.170553
1483	hexagon_221	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:01.17277
1484	circle_346	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	Shape.usd	2025-03-29 14:42:01.17511
1485	pentagon_391	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:42:01.401205
1486	square_341	pink	{0,0,0}	-205.90816	345.1413	908.00006	0	0	59.420776	Shape.usd	2025-03-29 14:42:01.404719
1487	pentagon_392	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:01.406603
1488	circle_347	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:01.408683
1489	pentagon_393	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:01.624361
1490	square_342	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:42:01.626919
1491	circle_348	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:01.628887
1492	circle_349	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:01.630667
1493	pentagon_394	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:01.85819
1494	square_343	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:42:01.860706
1495	pentagon_395	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.303947	Shape.usd	2025-03-29 14:42:01.862572
1496	circle_350	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	18.434948	Shape.usd	2025-03-29 14:42:01.86427
1497	pentagon_396	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:02.086825
1498	square_344	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.34933	Shape.usd	2025-03-29 14:42:02.090318
1499	circle_351	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:02.092425
1500	circle_352	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:02.094539
1501	pentagon_397	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:42:02.319074
1502	square_345	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03625	Shape.usd	2025-03-29 14:42:02.32273
1503	hexagon_222	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:02.324763
1504	circle_353	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:02.32713
1505	pentagon_398	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:02.553455
1506	square_346	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:42:02.556134
1507	hexagon_223	red	{0,0,0}	30.514694	260.8514	929	0	0	37.405357	Shape.usd	2025-03-29 14:42:02.558157
1508	circle_354	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	18.434948	Shape.usd	2025-03-29 14:42:02.560084
1509	pentagon_399	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:42:02.787461
1510	square_347	pink	{0,0,0}	-207.6968	346.48944	918.00006	0	0	59.34933	Shape.usd	2025-03-29 14:42:02.791516
1511	hexagon_224	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:02.79394
1512	circle_355	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:02.79598
1513	pentagon_400	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:03.034919
1514	square_348	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.743565	Shape.usd	2025-03-29 14:42:03.037121
1515	hexagon_225	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	Shape.usd	2025-03-29 14:42:03.038895
1516	circle_356	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:03.040636
1517	pentagon_401	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:03.271499
1518	square_349	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:42:03.275199
1519	hexagon_226	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.694237	Shape.usd	2025-03-29 14:42:03.277259
1520	circle_357	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:42:03.27913
1521	pentagon_402	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:03.503182
1522	square_350	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.534454	Shape.usd	2025-03-29 14:42:03.507157
1523	hexagon_227	red	{0,0,0}	30.514694	260.8514	918.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:03.509115
1524	circle_358	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.434948	Shape.usd	2025-03-29 14:42:03.511211
1525	pentagon_403	black	{0,0,0}	-127.46696	518.69244	653.00006	0	0	90	Shape.usd	2025-03-29 14:42:03.734732
1526	square_351	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03625	Shape.usd	2025-03-29 14:42:03.739294
1527	hexagon_228	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:03.74119
1528	circle_359	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:03.74331
1529	pentagon_404	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:03.959472
1530	square_352	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03625	Shape.usd	2025-03-29 14:42:03.962449
1531	hexagon_229	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:03.964382
1532	circle_360	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:42:03.966179
1533	pentagon_405	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:04.189891
1534	square_353	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	Shape.usd	2025-03-29 14:42:04.192325
1535	hexagon_230	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	Shape.usd	2025-03-29 14:42:04.194515
1536	circle_361	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:04.19651
1537	pentagon_406	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:04.423725
1538	square_354	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:42:04.425928
1539	hexagon_231	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:04.428221
1540	circle_362	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:04.430087
1541	pentagon_407	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:42:04.655072
1542	square_355	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.534454	Shape.usd	2025-03-29 14:42:04.6584
1543	hexagon_232	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:42:04.660964
1544	circle_363	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:04.663351
1545	pentagon_408	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:04.905608
1546	square_356	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.34933	Shape.usd	2025-03-29 14:42:04.90915
1547	hexagon_233	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:04.911172
1548	circle_364	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:42:04.913287
1549	pentagon_409	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:05.143929
1550	square_357	pink	{0,0,0}	-208.68114	346.48944	930.00006	0	0	59.34933	Shape.usd	2025-03-29 14:42:05.147634
1551	hexagon_234	red	{0,0,0}	30.514694	260.8514	934	0	0	37.568592	Shape.usd	2025-03-29 14:42:05.149525
1552	circle_365	green	{0,0,0}	-272.66354	217.54024	933	0	0	26.56505	Shape.usd	2025-03-29 14:42:05.151303
1553	pentagon_410	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:05.381576
1554	square_358	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:42:05.385175
1555	pentagon_411	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:05.387123
1556	circle_366	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:42:05.388974
1557	pentagon_412	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:05.608327
1558	square_359	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:42:05.612336
1559	hexagon_235	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:05.61601
1560	circle_367	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:05.618564
1561	pentagon_413	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:05.841287
1562	square_360	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.420776	Shape.usd	2025-03-29 14:42:05.844363
1563	pentagon_414	red	{0,0,0}	31.376482	259.8365	917.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:05.846877
1564	circle_368	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:05.848906
1565	pentagon_415	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:06.082612
1566	square_361	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:42:06.086109
1567	hexagon_236	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	Shape.usd	2025-03-29 14:42:06.087839
1568	circle_369	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:42:06.08965
1569	pentagon_416	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:42:06.309592
1570	square_362	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03624	Shape.usd	2025-03-29 14:42:06.313092
1571	hexagon_237	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:06.315115
1572	circle_370	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:06.316922
1573	pentagon_417	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:06.542392
1574	square_363	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:42:06.546174
1575	hexagon_238	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:42:06.548202
1576	circle_371	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:42:06.549939
1577	pentagon_418	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:06.776233
1578	square_364	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.420776	Shape.usd	2025-03-29 14:42:06.780179
1579	hexagon_239	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:06.782469
1580	circle_372	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:42:06.784404
1581	pentagon_419	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:42:07.006868
1582	square_365	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.743565	Shape.usd	2025-03-29 14:42:07.010402
1583	hexagon_240	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	Shape.usd	2025-03-29 14:42:07.013138
1584	circle_373	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:07.015083
1585	pentagon_420	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:07.229427
1586	square_366	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03625	Shape.usd	2025-03-29 14:42:07.23177
1587	hexagon_241	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	Shape.usd	2025-03-29 14:42:07.233599
1588	circle_374	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:07.235334
1589	pentagon_421	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:07.45413
1590	square_367	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:42:07.457798
1591	hexagon_242	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	Shape.usd	2025-03-29 14:42:07.459915
1592	circle_375	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	Shape.usd	2025-03-29 14:42:07.461863
1593	pentagon_422	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:07.677036
1594	square_368	pink	{0,0,0}	-207.6968	346.48944	932.00006	0	0	59.420776	Shape.usd	2025-03-29 14:42:07.679284
1595	square_369	red	{0,0,0}	31.499039	259.86707	916.00006	0	0	37.303947	Shape.usd	2025-03-29 14:42:07.681358
1596	circle_376	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:07.68318
1597	pentagon_423	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:07.918114
1598	square_370	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	Shape.usd	2025-03-29 14:42:07.920455
1599	hexagon_243	red	{0,0,0}	32.357	258.856	919	0	0	37.568592	Shape.usd	2025-03-29 14:42:07.922346
1600	circle_377	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:42:07.924203
1601	pentagon_424	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:08.143131
1602	square_371	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	Shape.usd	2025-03-29 14:42:08.145894
1603	pentagon_425	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	Shape.usd	2025-03-29 14:42:08.148215
1604	circle_378	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:42:08.15009
1605	pentagon_426	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:08.375439
1606	square_372	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:42:08.3778
1607	hexagon_244	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	Shape.usd	2025-03-29 14:42:08.379902
1608	circle_379	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:42:08.382024
1609	pentagon_427	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:08.617469
1610	square_373	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.420776	Shape.usd	2025-03-29 14:42:08.620296
1611	pentagon_428	red	{0,0,0}	32.357	258.856	936.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:08.622606
1612	circle_380	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	45	Shape.usd	2025-03-29 14:42:08.624668
1613	pentagon_429	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:08.841255
1614	square_374	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:42:08.843304
1615	hexagon_245	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	Shape.usd	2025-03-29 14:42:08.845125
1616	circle_381	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:42:08.848048
1617	polygon_1	black	{0,0,0}	-348.54163	189.73369	653.00006	0	0	90	Shape.usd	2025-03-29 14:42:13.21104
5585	pentagonal_prism_212	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:36.126034
1619	polygon_2	red	{0,0,0}	-213.13696	-30.925756	946.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:13.218755
1621	polygon_3	black	{0,0,0}	-346.6738	188.3372	653.00006	0	0	90	Shape.usd	2025-03-29 14:42:13.439399
1623	polygon_4	red	{0,0,0}	-211.67102	-31.667318	946.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:13.443495
1625	polygon_5	black	{0,0,0}	-127.46696	518.69244	653.00006	0	0	90	Shape.usd	2025-03-29 14:42:13.668853
1627	polygon_6	red	{0,0,0}	31.376482	259.8365	946.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:13.673678
1629	polygon_7	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	Shape.usd	2025-03-29 14:42:13.900192
1631	polygon_8	red	{0,0,0}	30.514694	260.8514	920	0	0	37.568592	Shape.usd	2025-03-29 14:42:13.905674
1633	polygon_9	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:42:14.135364
1635	polygon_10	red	{0,0,0}	30.514694	260.8514	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:14.139596
1637	polygon_11	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:14.370095
1639	polygon_12	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:14.375446
1641	polygon_13	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:14.603461
1643	polygon_14	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:14.608231
1645	polygon_15	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:14.835932
1647	polygon_16	red	{0,0,0}	30.395967	260.81702	929	0	0	37.69424	Shape.usd	2025-03-29 14:42:14.840261
1620	cylinder_1	green	{0,0,0}	-469.02502	-68.312706	900.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:46:53.928841
1622	cube_2	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.620872	cube.usd	2025-03-29 14:46:54.161471
1624	cylinder_2	red	{0,0,0}	30.395967	260.81702	916.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:46:54.163768
1628	cylinder_3	green	{0,0,0}	-270.62216	216.69383	0	0	0	26.56505	cylinder.usd	2025-03-29 14:46:54.166063
1626	cube_3	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:46:54.390546
1632	cylinder_4	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:46:54.395527
1630	cube_4	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.34933	cube.usd	2025-03-29 14:46:54.628752
1636	cylinder_5	green	{0,0,0}	-270.62216	216.69383	919	0	0	36.869896	cylinder.usd	2025-03-29 14:46:54.633454
1634	cube_5	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.420776	cube.usd	2025-03-29 14:46:54.862693
1640	cylinder_6	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:46:54.867271
1638	cube_6	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.420776	cube.usd	2025-03-29 14:46:55.108071
1644	cylinder_7	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:46:55.11313
1646	cube_8	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.743565	cube.usd	2025-03-29 14:46:55.56781
1649	polygon_17	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:42:15.071369
1651	polygon_18	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	Shape.usd	2025-03-29 14:42:15.077218
1653	polygon_19	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	Shape.usd	2025-03-29 14:42:15.308472
1655	polygon_20	red	{0,0,0}	31.497837	259.85715	924	0	0	37.69424	Shape.usd	2025-03-29 14:42:15.312613
1657	polygon_21	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:15.533416
1659	polygon_22	red	{0,0,0}	31.376482	259.8365	929	0	0	36.869896	Shape.usd	2025-03-29 14:42:15.537892
1661	polygon_23	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:15.773961
1663	polygon_24	red	{0,0,0}	31.376482	259.8365	920	0	0	37.303947	Shape.usd	2025-03-29 14:42:15.779186
1665	polygon_25	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:15.999739
1667	polygon_26	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:42:16.005428
1669	polygon_27	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:16.236748
1673	polygon_28	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:16.469113
1675	polygon_29	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:42:16.474501
1677	polygon_30	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:16.701646
1679	polygon_31	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:16.705852
1681	polygon_32	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:16.937374
1683	polygon_33	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.874985	Shape.usd	2025-03-29 14:42:16.942943
1685	polygon_34	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:17.171085
1687	polygon_35	red	{0,0,0}	32.357	258.856	938	0	0	36.869892	Shape.usd	2025-03-29 14:42:17.175219
1689	polygon_36	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:17.404213
1691	polygon_37	red	{0,0,0}	31.499039	259.86707	918.00006	0	0	37.303947	Shape.usd	2025-03-29 14:42:17.409747
1693	polygon_38	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:42:17.634834
1695	polygon_39	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.874985	Shape.usd	2025-03-29 14:42:17.639254
1697	polygon_40	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:17.873773
1699	polygon_41	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:42:17.879155
1701	polygon_42	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:18.112015
1703	polygon_43	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:18.11626
1705	polygon_44	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	Shape.usd	2025-03-29 14:42:18.345992
1652	cylinder_9	red	{0,0,0}	30.395967	260.81702	934	0	0	37.303947	cylinder.usd	2025-03-29 14:46:55.570049
1656	cylinder_10	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690067	cylinder.usd	2025-03-29 14:46:55.572245
1650	cube_9	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.34933	cube.usd	2025-03-29 14:46:55.802726
1660	cylinder_11	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:46:55.807254
1654	cube_10	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:46:56.032365
1664	cylinder_12	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:46:56.036728
1658	cube_11	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:46:56.268608
1668	cylinder_13	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:46:56.273241
1662	cube_12	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:46:56.50183
1666	cube_13	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:46:56.734617
1670	cube_14	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:46:56.97675
1676	cylinder_16	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:46:56.981428
1674	cube_15	pink	{0,0,0}	-207.6968	346.48944	930.00006	0	0	59.534454	cube.usd	2025-03-29 14:46:57.198694
1680	cylinder_17	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:46:57.203722
1678	cube_16	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:46:57.43156
1684	cylinder_18	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:46:57.436292
1682	cube_17	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:46:57.664629
1688	cylinder_19	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:46:57.669371
1686	cube_18	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:46:57.893061
1692	cylinder_20	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:46:57.897756
1690	cube_19	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03625	cube.usd	2025-03-29 14:46:58.119916
1696	cylinder_21	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:46:58.124169
1694	cube_20	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:46:58.348627
1700	cylinder_22	green	{0,0,0}	-270.62216	216.69383	942.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:46:58.353307
1698	cube_21	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.534454	cube.usd	2025-03-29 14:46:58.589917
1704	cylinder_23	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:46:58.595423
1702	cube_22	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:46:58.814782
2368	cylinder_195	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	21.801407	cylinder.usd	2025-03-29 14:47:36.134159
1707	polygon_45	red	{0,0,0}	32.357	258.856	929	0	0	37.694237	Shape.usd	2025-03-29 14:42:18.352671
1709	polygon_46	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:18.571877
1711	polygon_47	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:18.576703
1713	polygon_48	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:18.799742
1715	polygon_49	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:42:18.805837
1717	polygon_50	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:19.031821
1719	polygon_51	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	Shape.usd	2025-03-29 14:42:19.038657
1721	polygon_52	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:19.251846
1723	polygon_53	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	Shape.usd	2025-03-29 14:42:19.2561
1725	polygon_54	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:42:19.472587
1727	polygon_55	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	Shape.usd	2025-03-29 14:42:19.477074
1729	polygon_56	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:42:19.702244
1733	polygon_57	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:19.925019
1735	polygon_58	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.184708	Shape.usd	2025-03-29 14:42:19.929553
1737	polygon_59	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:42:20.157479
1739	polygon_60	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:20.163045
1741	polygon_61	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:20.391105
1743	polygon_62	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:20.397069
1745	polygon_63	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:20.623615
1747	polygon_64	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:20.628889
1749	polygon_65	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:20.856159
1751	polygon_66	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:20.860299
1753	polygon_67	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:21.088213
1755	polygon_68	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:21.093629
1757	polygon_69	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:21.325427
1759	polygon_70	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:21.331618
1761	polygon_71	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:21.560252
1763	polygon_72	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.303947	Shape.usd	2025-03-29 14:42:21.566065
1708	cylinder_24	green	{0,0,0}	-270.62216	216.69383	934	0	0	36.869896	cylinder.usd	2025-03-29 14:46:58.819856
1712	cylinder_25	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:46:59.043426
1710	cube_24	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.743565	cube.usd	2025-03-29 14:46:59.266412
1714	cube_25	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.69424	cube.usd	2025-03-29 14:46:59.268969
1716	cylinder_26	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:46:59.271402
1718	cube_26	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.620872	cube.usd	2025-03-29 14:46:59.497037
1720	cylinder_27	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:46:59.502472
1722	cube_27	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03624	cube.usd	2025-03-29 14:46:59.727799
1726	cube_28	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.34933	cube.usd	2025-03-29 14:46:59.962432
1728	cylinder_29	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:46:59.967335
1731	cylinder_30	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:00.201351
1734	cube_30	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:47:00.433975
1732	cylinder_31	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:00.439102
1738	cube_31	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:00.666608
1736	cylinder_32	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	21.801407	cylinder.usd	2025-03-29 14:47:00.671057
1742	cube_32	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:00.900964
1740	cylinder_33	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:00.905333
1746	cube_33	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:47:01.138864
1744	cylinder_34	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	cylinder.usd	2025-03-29 14:47:01.140982
1748	cylinder_35	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:01.143213
1750	cube_34	pink	{0,0,0}	-205.90816	345.1413	905.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:01.367139
1752	cylinder_36	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:01.371673
1754	cube_35	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.620872	cube.usd	2025-03-29 14:47:01.602728
1756	cylinder_37	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	cylinder.usd	2025-03-29 14:47:01.604981
1758	cube_36	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:01.837046
1762	cube_37	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:47:02.07955
5614	hexagonal_prism_132	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:36.835909
1765	polygon_73	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:21.791192
1767	polygon_74	orange	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:21.79649
1769	polygon_75	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:22.02361
1771	polygon_76	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:22.029704
1773	polygon_77	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:42:22.262132
1775	polygon_78	red	{0,0,0}	31.499039	259.86707	925.00006	0	0	36.869896	Shape.usd	2025-03-29 14:42:22.266273
1777	polygon_79	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:22.492115
1779	polygon_80	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:22.496545
1781	polygon_81	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:22.725899
1783	polygon_82	red	{0,0,0}	31.499039	259.86707	920	0	0	37.69424	Shape.usd	2025-03-29 14:42:22.731392
1785	polygon_83	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:22.959132
1787	polygon_84	red	{0,0,0}	31.376482	259.8365	919	0	0	37.405357	Shape.usd	2025-03-29 14:42:22.964749
1789	polygon_85	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:23.191311
1791	polygon_86	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:23.197037
1793	polygon_87	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:23.423782
1795	polygon_88	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:23.430111
1797	polygon_89	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:23.661437
1799	polygon_90	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:23.667696
1801	polygon_91	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:23.893741
1803	polygon_92	red	{0,0,0}	30.514694	260.8514	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:23.899268
1805	polygon_93	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:24.126284
1807	polygon_94	red	{0,0,0}	31.499039	259.86707	921.00006	0	0	36.869896	Shape.usd	2025-03-29 14:42:24.130055
1809	polygon_95	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:24.356095
1811	polygon_96	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:42:24.360464
1813	polygon_97	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:24.580002
1815	polygon_98	red	{0,0,0}	32.357	258.856	936.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:24.584381
1817	polygon_99	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:24.807526
1819	polygon_100	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:24.81174
1821	polygon_101	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:25.041865
1768	cylinder_40	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:02.084211
1766	cube_38	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.34933	cube.usd	2025-03-29 14:47:02.312299
1772	cylinder_41	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:02.317444
1770	cube_39	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.743565	cube.usd	2025-03-29 14:47:02.535045
1776	cylinder_42	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:02.539553
1774	cube_40	pink	{0,0,0}	-205.90816	345.1413	910	0	0	59.03624	cube.usd	2025-03-29 14:47:02.772431
1780	cylinder_43	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:02.776971
1778	cube_41	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:47:03.010615
1784	cylinder_44	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:03.015138
1788	cylinder_45	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	45	cylinder.usd	2025-03-29 14:47:03.250863
1792	cylinder_46	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:03.480252
1790	cube_44	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03625	cube.usd	2025-03-29 14:47:03.715404
1796	cylinder_47	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:03.720357
1794	cube_45	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:03.949765
1800	cylinder_48	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:47:03.95498
1798	cube_46	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.34933	cube.usd	2025-03-29 14:47:04.173594
1804	cylinder_49	green	{0,0,0}	-270.62216	216.69383	941.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:04.17808
1802	cube_47	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:04.403478
1808	cylinder_50	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:04.40802
1806	cube_48	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03625	cube.usd	2025-03-29 14:47:04.637154
1812	cylinder_51	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:04.641741
1810	cube_49	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:04.864379
1816	cylinder_52	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:04.869078
1814	cube_50	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:47:05.093484
1820	cylinder_53	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:05.098285
1823	polygon_102	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:25.046343
1825	polygon_103	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:42:25.27475
1827	polygon_104	red	{0,0,0}	31.375294	259.82666	919	0	0	37.568592	Shape.usd	2025-03-29 14:42:25.280818
1829	polygon_105	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:25.510333
1831	polygon_106	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	Shape.usd	2025-03-29 14:42:25.516281
1833	polygon_107	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:25.744992
1835	polygon_108	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.694237	Shape.usd	2025-03-29 14:42:25.749132
1837	polygon_109	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:25.97953
1839	polygon_110	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:25.984685
1841	polygon_111	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:26.211061
1843	polygon_112	red	{0,0,0}	31.499039	259.86707	918.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:26.214951
1845	polygon_113	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:26.433017
1847	polygon_114	red	{0,0,0}	32.357	258.856	934	0	0	37.405357	Shape.usd	2025-03-29 14:42:26.437862
1849	polygon_115	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:26.663166
1851	polygon_116	red	{0,0,0}	30.51353	260.84146	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:26.668702
1853	polygon_117	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:42:26.899849
1855	polygon_118	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:26.905214
1857	polygon_119	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:42:27.121897
1861	polygon_120	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:42:27.348647
1863	polygon_121	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	Shape.usd	2025-03-29 14:42:27.353744
1865	polygon_122	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:27.581562
1867	polygon_123	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:42:27.58569
1869	polygon_124	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	Shape.usd	2025-03-29 14:42:27.814966
1871	polygon_125	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	Shape.usd	2025-03-29 14:42:27.819091
1873	polygon_126	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:28.050937
1875	polygon_127	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:42:28.056209
1877	polygon_128	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:28.283655
1879	polygon_129	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	Shape.usd	2025-03-29 14:42:28.289118
1822	cube_52	pink	{0,0,0}	-205.90816	345.1413	908.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:05.561304
1828	cylinder_55	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:05.565804
1826	cube_53	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.420776	cube.usd	2025-03-29 14:47:05.797953
1832	cylinder_56	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:05.802515
1830	cube_54	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:06.023737
1836	cylinder_57	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:06.0281
1834	cube_55	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:47:06.247963
1840	cylinder_58	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 14:47:06.252947
1838	cube_56	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:47:06.470567
1842	cube_57	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.93142	cube.usd	2025-03-29 14:47:06.717305
1848	cylinder_60	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:06.72184
1846	cube_58	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.34933	cube.usd	2025-03-29 14:47:06.938816
1850	cube_59	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:07.187508
1856	cylinder_62	red	{0,0,0}	30.395967	260.81702	937.00006	0	0	37.69424	cylinder.usd	2025-03-29 14:47:07.190313
1860	cylinder_63	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:07.193045
1854	cube_60	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:07.429335
1864	cylinder_64	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	cylinder.usd	2025-03-29 14:47:07.434479
1858	cube_61	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:07.670006
1868	cylinder_65	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:07.675112
1859	cube_62	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:07.892844
1872	cylinder_66	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:07.897202
1862	cube_63	pink	{0,0,0}	-207.6968	346.48944	918.00006	0	0	59.34933	cube.usd	2025-03-29 14:47:08.133933
1876	cylinder_67	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:08.138807
1866	cube_64	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:47:08.35961
1870	cube_65	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:08.588852
1874	cube_66	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:08.825123
1878	cube_67	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:09.06627
1881	polygon_130	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:28.516669
1883	polygon_131	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.303947	Shape.usd	2025-03-29 14:42:28.522302
1885	polygon_132	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:28.747602
1887	polygon_133	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:28.753425
1889	polygon_134	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:28.981381
1891	polygon_135	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:28.985915
1893	polygon_136	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:29.213754
1895	polygon_137	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	Shape.usd	2025-03-29 14:42:29.217982
1897	polygon_138	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:29.448721
1899	polygon_139	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:42:29.454311
1901	polygon_140	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:42:29.674612
1903	polygon_141	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:29.680215
1905	polygon_142	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:29.91241
1907	polygon_143	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:29.918179
1909	polygon_144	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:42:30.15032
1911	polygon_145	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:30.156048
1913	polygon_146	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:30.378152
1915	polygon_147	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:30.383746
1917	polygon_148	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	0	Shape.usd	2025-03-29 14:42:30.614334
1919	polygon_149	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:30.620042
1921	polygon_150	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:30.842736
1923	polygon_151	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:30.848723
1925	polygon_152	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:31.080694
1927	polygon_153	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:31.086594
1929	polygon_154	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:31.312936
1931	polygon_155	red	{0,0,0}	32.357	258.856	933	0	0	37.405357	Shape.usd	2025-03-29 14:42:31.318642
1933	polygon_156	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:31.54818
1935	polygon_157	red	{0,0,0}	32.357	258.856	924	0	0	36.869896	Shape.usd	2025-03-29 14:42:31.554026
1937	polygon_158	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:42:31.781081
1884	cylinder_69	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:08.594366
1888	cylinder_70	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:08.829683
1892	cylinder_71	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:09.073532
1882	cube_68	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:09.314129
1896	cylinder_72	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:09.318857
1886	cube_69	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.420776	cube.usd	2025-03-29 14:47:09.547291
1900	cylinder_73	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:09.551859
1890	cube_70	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:47:09.78493
1894	cube_71	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:10.003598
1908	cylinder_75	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:10.008887
1898	cube_72	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 14:47:10.236148
1902	cube_73	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:47:10.460689
1916	cylinder_77	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:10.46533
1906	cube_74	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:10.712191
1920	cylinder_78	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:10.716553
1910	cube_75	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:10.949763
1914	cube_76	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.69424	cube.usd	2025-03-29 14:47:10.952066
1924	cylinder_79	green	{0,0,0}	-270.62216	216.69383	942.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:10.954212
1918	cube_77	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:47:11.1763
1928	cylinder_80	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:11.180876
1922	cube_78	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:11.419394
1932	cylinder_81	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.874985	cylinder.usd	2025-03-29 14:47:11.421525
1936	cylinder_82	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:11.423921
1926	cube_79	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:11.643326
1930	cube_80	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:47:11.880348
1934	cube_81	red	{0,0,0}	32.357	258.856	914.00006	0	0	37.405357	cube.usd	2025-03-29 14:47:11.88265
1939	polygon_159	red	{0,0,0}	29.53035	261.83575	924	0	0	37.568592	Shape.usd	2025-03-29 14:42:31.78524
1941	polygon_160	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:32.019252
1943	polygon_161	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:42:32.024761
1945	polygon_162	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:32.249218
1947	polygon_163	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.874985	Shape.usd	2025-03-29 14:42:32.254353
1949	polygon_164	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:32.484175
1951	polygon_165	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:42:32.490032
1953	polygon_166	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:32.716139
1955	polygon_167	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:32.722274
1957	polygon_168	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:32.945029
1959	polygon_169	red	{0,0,0}	30.514694	260.8514	932.00006	0	0	37.874985	Shape.usd	2025-03-29 14:42:32.951237
1961	polygon_170	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:33.183272
1963	polygon_171	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:33.188156
1965	polygon_172	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:33.419898
1967	polygon_173	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:33.424713
1969	polygon_174	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:33.651712
1971	polygon_175	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	Shape.usd	2025-03-29 14:42:33.657586
1973	polygon_176	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:33.876889
1975	polygon_177	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:33.882301
1977	polygon_178	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	Shape.usd	2025-03-29 14:42:34.102391
1979	polygon_179	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.874985	Shape.usd	2025-03-29 14:42:34.107091
1981	polygon_180	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:34.335669
1983	polygon_181	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:34.339566
1985	polygon_182	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:34.557095
1987	polygon_183	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:34.562018
1989	polygon_184	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:34.776885
1991	polygon_185	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:34.782359
1993	polygon_186	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:35.003391
1995	polygon_187	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:35.007187
1944	cylinder_84	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:11.884795
1938	cube_82	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:12.120024
1948	cylinder_85	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:12.124446
1942	cube_83	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:12.35891
1952	cylinder_86	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:12.363899
1946	cube_84	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:12.588211
1956	cylinder_87	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:12.592989
1950	cube_85	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:47:12.810987
1960	cylinder_88	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:12.815847
1964	cylinder_89	green	{0,0,0}	-270.62216	216.69383	920	0	0	18.434948	cylinder.usd	2025-03-29 14:47:13.050855
1958	cube_87	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:13.282188
1972	cylinder_91	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:13.287228
1962	cube_88	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:13.511741
1976	cylinder_92	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:13.516642
1966	cube_89	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:13.738007
1980	cylinder_93	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:13.742491
1970	cube_90	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:13.958715
1984	cylinder_94	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:13.963634
1974	cube_91	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:47:14.198556
1988	cylinder_95	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:14.203277
1978	cube_92	pink	{0,0,0}	-205.90816	345.1413	938	0	0	59.534454	cube.usd	2025-03-29 14:47:14.426897
1992	cylinder_96	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:14.431772
1982	cube_93	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:14.658516
1986	cube_94	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.568592	cube.usd	2025-03-29 14:47:14.661072
1990	cube_95	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:14.891755
1994	cube_96	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.03625	cube.usd	2025-03-29 14:47:15.131085
5601	pentagonal_prism_223	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:38.043249
1997	polygon_188	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:35.226742
1999	polygon_189	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:35.232328
2001	polygon_190	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:42:35.455075
2005	polygon_191	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:35.683314
2007	polygon_192	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:35.689879
2009	polygon_193	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:35.911758
2011	polygon_194	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:42:35.917202
2013	polygon_195	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:36.140166
2015	polygon_196	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:42:36.145625
2017	polygon_197	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:36.367215
2019	polygon_198	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:42:36.372689
2021	polygon_199	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:36.601103
2023	polygon_200	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:36.606971
2025	polygon_201	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:36.834467
2027	polygon_202	orange	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:36.840695
2029	polygon_203	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:37.067151
2031	polygon_204	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:37.072791
2033	polygon_205	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:37.294625
2035	polygon_206	orange	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:37.300485
2037	polygon_207	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:37.52056
2039	polygon_208	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:37.526419
2041	polygon_209	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:37.758264
2043	polygon_210	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	Shape.usd	2025-03-29 14:42:37.764357
2045	polygon_211	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:37.989644
2047	polygon_212	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:42:37.995216
2049	polygon_213	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	Shape.usd	2025-03-29 14:42:38.223092
2051	polygon_214	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	Shape.usd	2025-03-29 14:42:38.228867
2053	polygon_215	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:38.458205
2000	cylinder_98	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:14.897348
2003	cylinder_99	green	{0,0,0}	-272.66354	217.54024	924	0	0	18.434948	cylinder.usd	2025-03-29 14:47:15.13613
1998	cube_97	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.420776	cube.usd	2025-03-29 14:47:15.361505
2004	cylinder_100	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.434948	cylinder.usd	2025-03-29 14:47:15.366481
2002	cube_98	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.534454	cube.usd	2025-03-29 14:47:15.599407
2008	cylinder_101	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:15.603921
2006	cube_99	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:47:15.826575
2012	cylinder_102	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:15.831425
2016	cylinder_103	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:16.065469
2014	cube_101	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:16.312509
2018	cube_102	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	cube.usd	2025-03-29 14:47:16.315919
2022	cube_103	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:16.54984
2024	cylinder_105	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:16.554307
2026	cube_104	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.34933	cube.usd	2025-03-29 14:47:16.78298
2028	cylinder_106	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:16.788121
2030	cube_105	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:47:17.012307
2032	cylinder_107	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:17.017056
2034	cube_106	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:17.248541
2036	cylinder_108	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:17.253385
2038	cube_107	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:17.482051
2040	cylinder_109	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:17.487122
2042	cube_108	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.743565	cube.usd	2025-03-29 14:47:17.709903
2044	cylinder_110	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:17.714738
2046	cube_109	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	cube.usd	2025-03-29 14:47:17.942938
2048	cylinder_111	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:47:17.94773
2050	cube_110	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:47:18.18244
5611	pentagonal_prism_228	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:39.199325
2055	polygon_216	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:38.4623
2057	polygon_217	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:38.686151
2059	polygon_218	red	{0,0,0}	30.395967	260.81702	933	0	0	37.694237	Shape.usd	2025-03-29 14:42:38.692298
2061	polygon_219	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	Shape.usd	2025-03-29 14:42:38.929789
2063	polygon_220	red	{0,0,0}	31.499039	259.86707	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:38.934127
2065	polygon_221	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:39.156076
2067	polygon_222	red	{0,0,0}	30.395967	260.81702	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:39.161194
2069	polygon_223	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:39.391145
2071	polygon_224	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	Shape.usd	2025-03-29 14:42:39.395416
2073	polygon_225	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:42:39.621283
2075	polygon_226	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:39.627059
2077	polygon_227	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:39.856422
2079	polygon_228	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:39.860906
2081	polygon_229	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:40.08157
2083	polygon_230	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:40.087179
2085	polygon_231	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:40.304169
2087	polygon_232	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:40.31011
2089	polygon_233	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:40.537662
2091	polygon_234	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:40.544218
2093	polygon_235	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:40.77051
2095	polygon_236	red	{0,0,0}	32.357	258.856	929	0	0	37.69424	Shape.usd	2025-03-29 14:42:40.776169
2097	polygon_237	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:41.010412
2101	polygon_238	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:41.242544
2103	polygon_239	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:42:41.247759
2105	polygon_240	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:41.475
2107	polygon_241	red	{0,0,0}	30.514694	260.8514	918.00006	0	0	37.303947	Shape.usd	2025-03-29 14:42:41.479048
2109	polygon_242	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:41.706702
2111	polygon_243	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	Shape.usd	2025-03-29 14:42:41.712354
2056	cylinder_113	red	{0,0,0}	30.514694	260.8514	927.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:47:18.409026
2060	cylinder_114	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	cylinder.usd	2025-03-29 14:47:18.411135
2058	cube_112	pink	{0,0,0}	-207.6968	346.48944	911.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:18.636048
2064	cylinder_115	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	21.801407	cylinder.usd	2025-03-29 14:47:18.642083
2062	cube_113	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:18.868144
2068	cylinder_116	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:18.872743
2066	cube_114	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:19.105276
2070	cube_115	red	{0,0,0}	32.357	258.856	926.00006	0	0	36.869896	cube.usd	2025-03-29 14:47:19.108074
2076	cylinder_118	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:19.341251
2078	cube_117	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:47:19.566361
2080	cylinder_119	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:19.571093
2082	cube_118	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.534454	cube.usd	2025-03-29 14:47:19.805387
2084	cylinder_120	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:19.809759
2086	cube_119	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:20.032114
2088	cylinder_121	red	{0,0,0}	30.395967	260.81702	924	0	0	37.568592	cylinder.usd	2025-03-29 14:47:20.03464
2092	cylinder_122	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:20.03714
2090	cube_120	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:20.265714
2096	cylinder_123	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:20.27035
2094	cube_121	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:20.50305
2100	cylinder_124	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:20.507651
2098	cube_122	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:20.726927
2104	cylinder_125	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:47:20.73157
2099	cube_123	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.34933	cube.usd	2025-03-29 14:47:20.953752
2108	cylinder_126	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:20.958136
2102	cube_124	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:21.184967
2106	cube_125	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	cube.usd	2025-03-29 14:47:21.416317
5619	pentagonal_prism_233	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:40.341217
2113	polygon_244	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:41.942923
2115	polygon_245	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:41.946872
2117	polygon_246	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:42.176909
2119	polygon_247	red	{0,0,0}	32.357	258.856	920	0	0	37.303947	Shape.usd	2025-03-29 14:42:42.182298
2121	polygon_248	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:42.417524
2123	polygon_249	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:42:42.423008
2125	polygon_250	black	{0,0,0}	-127.46696	518.69244	653.00006	0	0	90	Shape.usd	2025-03-29 14:42:42.645499
2129	polygon_251	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:42.874012
2131	polygon_252	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	Shape.usd	2025-03-29 14:42:42.879527
2133	polygon_253	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:43.111515
2135	polygon_254	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	Shape.usd	2025-03-29 14:42:43.115448
2137	polygon_255	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	Shape.usd	2025-03-29 14:42:43.337198
2139	polygon_256	red	{0,0,0}	31.375294	259.82666	933	0	0	37.694237	Shape.usd	2025-03-29 14:42:43.341674
2141	polygon_257	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	Shape.usd	2025-03-29 14:42:43.573699
2143	polygon_258	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:43.579152
2145	polygon_259	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	Shape.usd	2025-03-29 14:42:43.812129
2149	polygon_260	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:44.065942
2151	polygon_261	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:44.070614
2153	polygon_262	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:42:44.293342
2155	polygon_263	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.694237	Shape.usd	2025-03-29 14:42:44.297474
2157	polygon_264	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:44.524698
2159	polygon_265	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	Shape.usd	2025-03-29 14:42:44.528995
2161	polygon_266	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:44.758282
2163	polygon_267	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:44.762679
2165	polygon_268	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:44.983664
2167	polygon_269	red	{0,0,0}	30.394815	260.80713	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:44.987632
2169	polygon_270	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:45.214596
2116	cylinder_128	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:21.42118
2120	cylinder_129	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:21.656085
2114	cube_127	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:21.885433
2124	cylinder_130	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:21.889925
2118	cube_128	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:22.121996
2128	cylinder_131	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:47:22.126496
2122	cube_129	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:47:22.355389
2126	cube_130	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:22.586604
2136	cylinder_133	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:47:22.591032
2127	cube_131	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:22.819068
2140	cylinder_134	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:22.824867
2144	cylinder_135	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:23.061297
2134	cube_133	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	cube.usd	2025-03-29 14:47:23.286462
2148	cylinder_136	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:47:23.291436
2138	cube_134	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:47:23.532655
2152	cylinder_137	green	{0,0,0}	-270.62216	216.69383	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:23.53792
2142	cube_135	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	cube.usd	2025-03-29 14:47:23.762733
2156	cylinder_138	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:23.768021
2146	cube_136	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:47:23.983489
2160	cylinder_139	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:47:23.988086
2147	cube_137	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:24.220134
2164	cylinder_140	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:24.224666
2150	cube_138	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.34933	cube.usd	2025-03-29 14:47:24.452505
2168	cylinder_141	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:24.457052
2154	cube_139	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:24.692535
2162	cube_141	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:25.154057
2166	cube_142	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:25.389141
2444	cylinder_216	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:40.580591
2171	polygon_271	red	{0,0,0}	31.499039	259.86707	921.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:45.218741
2173	polygon_272	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:45.450336
2175	polygon_273	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:45.454374
2177	polygon_274	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:45.677797
2179	polygon_275	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.303947	Shape.usd	2025-03-29 14:42:45.681738
2181	polygon_276	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:45.91253
2185	polygon_277	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:46.146707
2187	polygon_278	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:46.152881
2189	polygon_279	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:46.37482
2191	polygon_280	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:42:46.380201
2193	polygon_281	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:46.607189
2195	polygon_282	red	{0,0,0}	32.357	258.856	929	0	0	37.303947	Shape.usd	2025-03-29 14:42:46.612947
2197	polygon_283	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:46.851868
2199	polygon_284	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:46.855959
2201	polygon_285	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:47.07608
2203	polygon_286	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:42:47.080952
2205	polygon_287	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:47.312024
2207	polygon_288	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:47.316346
2209	polygon_289	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:47.546663
2211	polygon_290	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.874985	Shape.usd	2025-03-29 14:42:47.552324
2213	polygon_291	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:47.777537
2215	polygon_292	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:47.783109
2217	polygon_293	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:48.011075
2219	polygon_294	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:48.015697
2221	polygon_295	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:48.244046
2225	polygon_296	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:42:48.477329
2227	polygon_297	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:48.481875
2176	cylinder_143	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:47:24.925949
2180	cylinder_144	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:25.158989
2183	cylinder_145	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:25.393824
2170	cube_143	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:25.622695
2184	cylinder_146	green	{0,0,0}	-270.62216	216.69383	944.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:47:25.62723
2174	cube_144	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:25.854954
2188	cylinder_147	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:25.859418
2192	cylinder_148	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:26.092931
2182	cube_146	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:47:26.318288
2196	cylinder_149	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:47:26.323473
2186	cube_147	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:47:26.543056
2200	cylinder_150	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.303947	cylinder.usd	2025-03-29 14:47:26.545261
2204	cylinder_151	green	{0,0,0}	-270.62216	216.69383	933	0	0	18.434948	cylinder.usd	2025-03-29 14:47:26.547573
2208	cylinder_152	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	36.869896	cylinder.usd	2025-03-29 14:47:26.778965
2194	cube_149	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	cube.usd	2025-03-29 14:47:27.009191
2212	cylinder_153	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:27.013696
2198	cube_150	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:47:27.242733
2216	cylinder_154	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:27.247205
2202	cube_151	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.34933	cube.usd	2025-03-29 14:47:27.472864
2220	cylinder_155	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	cylinder.usd	2025-03-29 14:47:27.475197
2224	cylinder_156	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:47:27.477441
2206	cube_152	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.534454	cube.usd	2025-03-29 14:47:27.706559
2210	cube_153	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:27.947854
2218	cube_155	red	{0,0,0}	31.499039	259.86707	925.00006	0	0	37.405357	cube.usd	2025-03-29 14:47:28.177565
2222	cube_156	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:28.409836
2223	cube_157	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.620872	cube.usd	2025-03-29 14:47:28.640374
2226	cube_158	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:28.874902
5654	hexagonal_prism_145	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:41.278059
2229	polygon_298	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:48.716109
2233	polygon_299	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:42:48.947213
2237	polygon_300	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:42:49.173438
2239	polygon_301	red	{0,0,0}	31.499039	259.86707	920	0	0	37.405357	Shape.usd	2025-03-29 14:42:49.177648
2241	polygon_302	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:49.397079
2245	polygon_303	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:49.62812
2247	polygon_304	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:49.633725
2249	polygon_305	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:49.865593
2251	polygon_306	red	{0,0,0}	32.357	258.856	936.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:49.87101
2253	polygon_307	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:50.094518
2257	polygon_308	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:50.337674
2259	polygon_309	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	Shape.usd	2025-03-29 14:42:50.342202
2261	polygon_310	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:50.560563
2263	polygon_311	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:42:50.566137
2265	polygon_312	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:50.807162
2267	polygon_313	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.303947	Shape.usd	2025-03-29 14:42:50.81145
2269	polygon_314	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:51.032937
2271	polygon_315	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:51.037497
2273	polygon_316	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	Shape.usd	2025-03-29 14:42:51.267375
2277	polygon_317	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:51.503912
2279	polygon_318	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.874985	Shape.usd	2025-03-29 14:42:51.509568
2281	polygon_319	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:42:51.728035
2283	polygon_320	red	{0,0,0}	31.376482	259.8365	920	0	0	37.69424	Shape.usd	2025-03-29 14:42:51.734242
2285	polygon_321	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:51.96223
2231	cylinder_158	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:47:27.952797
2232	cylinder_159	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:28.179827
2235	cylinder_160	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:47:28.412084
2236	cylinder_161	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:28.414413
2244	cylinder_163	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:28.879492
2230	cube_159	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:47:29.111596
2248	cylinder_164	green	{0,0,0}	-270.62216	216.69383	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:29.11608
2234	cube_160	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:29.345023
2238	cube_161	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:47:29.57963
2256	cylinder_166	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:29.584248
2242	cube_162	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:29.81167
2260	cylinder_167	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:29.816452
2243	cube_163	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.743565	cube.usd	2025-03-29 14:47:30.041753
2246	cube_164	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.69424	cube.usd	2025-03-29 14:47:30.044029
2264	cylinder_168	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:30.046321
2250	cube_165	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:30.30072
2268	cylinder_169	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:30.306455
2254	cube_166	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	cube.usd	2025-03-29 14:47:30.548496
2272	cylinder_170	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:30.553133
2255	cube_167	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:47:30.780804
2276	cylinder_171	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:30.785462
2258	cube_168	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:47:31.011383
2262	cube_169	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:31.243544
2266	cube_170	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.234837	cube.usd	2025-03-29 14:47:31.245733
2284	cylinder_173	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	cylinder.usd	2025-03-29 14:47:31.247932
2270	cube_171	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:31.476521
2274	cube_172	pink	{0,0,0}	-205.90816	345.1413	909.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:31.717915
2275	cube_173	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:47:31.946735
2278	cube_174	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:47:32.179976
2282	cube_175	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.03624	cube.usd	2025-03-29 14:47:32.408513
2334	cube_188	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:35.434255
2287	polygon_322	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:51.96782
2335	cube_189	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.34933	cube.usd	2025-03-29 14:47:35.670458
2289	polygon_323	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:52.199216
2338	cube_190	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:35.899302
2291	polygon_324	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:52.20371
2342	cube_191	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:47:36.129738
2293	polygon_325	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:52.430782
5628	pentagonal_prism_239	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:41.743314
2295	polygon_326	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:52.435401
2297	polygon_327	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:52.653888
2299	polygon_328	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.874985	Shape.usd	2025-03-29 14:42:52.659475
2301	polygon_329	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:42:52.888033
2303	polygon_330	orange	{0,0,0}	30.514694	260.8514	938	0	0	37.69424	Shape.usd	2025-03-29 14:42:52.893679
2305	polygon_331	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:53.113992
2307	polygon_332	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.874985	Shape.usd	2025-03-29 14:42:53.11932
2309	polygon_333	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:53.347696
2311	polygon_334	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:42:53.35342
2313	polygon_335	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:53.585332
2315	polygon_336	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	Shape.usd	2025-03-29 14:42:53.589513
2317	polygon_337	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:53.816438
2319	polygon_338	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	Shape.usd	2025-03-29 14:42:53.821894
2321	polygon_339	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:54.050386
2323	polygon_340	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	Shape.usd	2025-03-29 14:42:54.056141
2325	polygon_341	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:54.291226
2327	polygon_342	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:54.295995
2329	polygon_343	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:54.517629
2331	polygon_344	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:54.523068
2333	polygon_345	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:54.753197
2337	polygon_346	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:42:54.982996
2339	polygon_347	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:54.987856
2341	polygon_348	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:55.241714
2343	polygon_349	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:55.246037
2292	cylinder_175	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:31.722466
2296	cylinder_176	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:31.951288
2300	cylinder_177	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:32.184678
2304	cylinder_178	green	{0,0,0}	-272.66354	217.54024	934	0	0	18.434948	cylinder.usd	2025-03-29 14:47:32.413111
2286	cube_176	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:32.647174
2308	cylinder_179	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:32.651618
2290	cube_177	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:32.876585
2294	cube_178	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:33.113828
2316	cylinder_181	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:33.118443
2298	cube_179	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:33.338135
2302	cube_180	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:33.56258
2324	cylinder_183	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:33.567049
2306	cube_181	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:47:33.796536
2328	cylinder_184	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:47:33.801152
2310	cube_182	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:34.033359
2332	cylinder_185	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:34.03822
2314	cube_183	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.03624	cube.usd	2025-03-29 14:47:34.263177
2336	cylinder_186	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:34.267507
2318	cube_184	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 14:47:34.49862
2340	cylinder_187	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:34.503376
2322	cube_185	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:47:34.727939
2326	cube_186	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:47:34.960643
2330	cube_187	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.420776	cube.usd	2025-03-29 14:47:35.194618
2359	cylinder_192	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:35.438643
2345	polygon_350	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:55.463944
2360	cylinder_193	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:35.675045
2347	polygon_351	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:42:55.469817
2364	cylinder_194	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:35.904095
2349	polygon_352	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:42:55.690353
2346	cube_192	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:36.367505
2351	polygon_353	red	{0,0,0}	31.376482	259.8365	934	0	0	37.303947	Shape.usd	2025-03-29 14:42:55.696289
2372	cylinder_196	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:36.372135
2353	polygon_354	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:55.916215
2350	cube_193	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:36.600517
2355	polygon_355	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:55.922461
2354	cube_194	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:47:36.833648
2357	polygon_356	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	Shape.usd	2025-03-29 14:42:56.14185
2379	cylinder_198	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:36.838003
2358	cube_195	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:47:37.08071
2380	cylinder_199	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:37.085302
2361	polygon_357	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:56.366578
2362	cube_196	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:47:37.323724
2363	polygon_358	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:56.37217
2384	cylinder_200	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:37.328346
2365	polygon_359	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:56.609619
2366	cube_197	pink	{0,0,0}	-207.6968	346.48944	931.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:37.585832
2367	polygon_360	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:56.61524
2388	cylinder_201	green	{0,0,0}	-272.66354	217.54024	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:37.590471
2369	polygon_361	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:56.840329
2370	cube_198	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.534454	cube.usd	2025-03-29 14:47:37.817009
2371	polygon_362	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:56.844597
2391	cylinder_202	green	{0,0,0}	-272.66354	217.54024	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:37.821368
2373	polygon_363	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:57.082845
2374	cube_199	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:38.047641
2375	polygon_364	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:57.089601
2378	cube_200	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	cube.usd	2025-03-29 14:47:38.050047
2377	polygon_365	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:57.324028
2392	cylinder_203	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:38.052358
2382	cube_201	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:47:38.281996
2396	cylinder_204	red	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	cylinder.usd	2025-03-29 14:47:38.284292
2381	polygon_366	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:57.550298
2400	cylinder_205	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:38.28656
2383	polygon_367	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:57.554524
2386	cube_202	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:38.511555
2385	polygon_368	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:42:57.774245
2390	cube_203	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03625	cube.usd	2025-03-29 14:47:38.730861
2387	polygon_369	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:42:57.778571
2394	cube_204	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:38.968142
2389	polygon_370	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:58.010118
2398	cube_205	pink	{0,0,0}	-207.6968	346.48944	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:39.203452
5666	hexagonal_prism_150	red	{0,0,0}	31.376482	259.8365	939.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:42.452604
2393	polygon_371	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:42:58.238405
2395	polygon_372	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:42:58.24243
2397	polygon_373	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:42:58.470977
2399	polygon_374	orange	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	Shape.usd	2025-03-29 14:42:58.476311
2401	polygon_375	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:42:58.704129
2348	cylinder_189	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.303947	cylinder.usd	2025-03-29 14:47:34.963147
2352	cylinder_190	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:34.965452
2356	cylinder_191	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:35.199333
2408	cylinder_207	green	{0,0,0}	-272.66354	217.54024	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:38.735797
2403	polygon_376	red	{0,0,0}	32.357	258.856	924	0	0	37.303947	Shape.usd	2025-03-29 14:42:58.7084
2412	cylinder_208	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:38.972544
2405	polygon_377	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:58.940117
2416	cylinder_209	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:39.208223
2407	polygon_378	red	{0,0,0}	32.357	258.856	923.00006	0	0	36.869896	Shape.usd	2025-03-29 14:42:58.944159
2402	cube_206	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:39.433789
2409	polygon_379	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	Shape.usd	2025-03-29 14:42:59.17584
2420	cylinder_210	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:39.438439
2411	polygon_380	red	{0,0,0}	31.376482	259.8365	934	0	0	36.869896	Shape.usd	2025-03-29 14:42:59.181011
2406	cube_207	pink	{0,0,0}	-207.6968	346.48944	922.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:39.658554
2413	polygon_381	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:59.409145
2424	cylinder_211	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:39.663225
2415	polygon_382	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:59.413587
2410	cube_208	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:47:39.89624
2417	polygon_383	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:42:59.639859
2428	cylinder_212	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:39.901328
2419	polygon_384	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:42:59.645676
2414	cube_209	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:47:40.122698
2421	polygon_385	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:42:59.878094
2418	cube_210	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	cube.usd	2025-03-29 14:47:40.124857
2423	polygon_386	red	{0,0,0}	31.499039	259.86707	928.00006	0	0	37.874985	Shape.usd	2025-03-29 14:42:59.883768
2422	cube_211	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:40.345432
2425	polygon_387	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:00.135907
2436	cylinder_214	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:40.350523
2427	polygon_388	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:00.140824
2426	cube_212	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:40.575982
2429	polygon_389	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:00.359416
2440	cylinder_215	red	{0,0,0}	30.395967	260.81702	929	0	0	37.405357	cylinder.usd	2025-03-29 14:47:40.578301
2431	polygon_390	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	Shape.usd	2025-03-29 14:43:00.363499
2430	cube_213	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.534454	cube.usd	2025-03-29 14:47:40.812744
2433	polygon_391	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:00.588902
2448	cylinder_217	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:47:40.817805
2435	polygon_392	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:43:00.594659
2434	cube_214	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:47:41.048868
2437	polygon_393	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:00.812558
2452	cylinder_218	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:41.053633
2439	polygon_394	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:00.818093
2438	cube_215	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:41.275701
2441	polygon_395	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:01.041965
2456	cylinder_219	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:41.280301
2442	cube_216	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:41.510082
2443	cube_217	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:41.747432
2445	polygon_396	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:01.276348
2446	cube_218	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:47:41.981377
2447	polygon_397	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:43:01.282024
2450	cube_219	pink	{0,0,0}	-207.6968	346.48944	927.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:42.229819
2449	polygon_398	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:01.509561
2454	cube_220	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:42.450199
2451	polygon_399	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:01.515364
2455	cube_221	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:47:42.68911
2453	polygon_400	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:43:01.737856
2458	cube_222	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:47:42.935062
5638	pentagonal_prism_247	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:43.644912
2457	polygon_401	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:01.966711
2459	polygon_402	red	{0,0,0}	31.375294	259.82666	933	0	0	37.405357	Shape.usd	2025-03-29 14:43:01.972543
2464	cylinder_221	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:41.752422
2461	polygon_403	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:02.192264
2468	cylinder_222	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:41.986207
2463	polygon_404	red	{0,0,0}	32.357	258.856	915	0	0	37.69424	Shape.usd	2025-03-29 14:43:02.196899
2472	cylinder_223	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:42.234808
2465	polygon_405	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:02.426118
2476	cylinder_224	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:42.454966
2467	polygon_406	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:02.434202
2480	cylinder_225	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:42.693445
2469	polygon_407	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:02.665101
2484	cylinder_226	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:42.939977
2471	polygon_408	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:02.670504
2462	cube_223	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:43.167001
2473	polygon_409	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:02.895608
2488	cylinder_227	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:43.171913
2475	polygon_410	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:02.901065
2466	cube_224	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:43.413418
2477	polygon_411	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:03.123518
2492	cylinder_228	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	45	cylinder.usd	2025-03-29 14:47:43.418113
2479	polygon_412	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	Shape.usd	2025-03-29 14:43:03.128278
2470	cube_225	pink	{0,0,0}	-207.6968	346.48944	915	0	0	59.03624	cube.usd	2025-03-29 14:47:43.647525
2481	polygon_413	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:03.360803
2496	cylinder_229	green	{0,0,0}	-272.66354	217.54024	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:43.652112
2483	polygon_414	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	Shape.usd	2025-03-29 14:43:03.366117
2474	cube_226	pink	{0,0,0}	-207.6968	346.48944	918.00006	0	0	59.34933	cube.usd	2025-03-29 14:47:43.886802
2485	polygon_415	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:43:03.595459
2504	cylinder_231	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:44.125082
2487	polygon_416	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:03.60068
2482	cube_228	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:47:44.355554
2489	polygon_417	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:03.825586
2508	cylinder_232	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:44.359897
2491	polygon_418	red	{0,0,0}	31.499039	259.86707	924	0	0	37.568592	Shape.usd	2025-03-29 14:43:03.831261
2486	cube_229	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.34933	cube.usd	2025-03-29 14:47:44.587549
2493	polygon_419	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:04.061442
2512	cylinder_233	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:44.592138
2495	polygon_420	red	{0,0,0}	31.376482	259.8365	938	0	0	37.568592	Shape.usd	2025-03-29 14:43:04.06724
2490	cube_230	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:44.822565
2497	polygon_421	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:04.288295
2516	cylinder_234	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:44.827016
2499	polygon_422	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:04.292858
2494	cube_231	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:45.051711
2501	polygon_423	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:04.513374
2498	cube_232	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:45.286126
2503	polygon_424	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	Shape.usd	2025-03-29 14:43:04.517723
2502	cube_233	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:47:45.530417
2505	polygon_425	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:04.746147
2506	cube_234	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:45.757768
2507	polygon_426	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:04.751548
2510	cube_235	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:45.987957
2509	polygon_427	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:04.975904
2514	cube_236	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:46.219312
2511	polygon_428	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:04.981762
2513	polygon_429	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:05.21198
2515	polygon_430	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:05.216157
2517	polygon_431	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:05.437934
2500	cylinder_230	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	cylinder.usd	2025-03-29 14:47:43.891222
2524	cylinder_237	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:45.535101
2528	cylinder_238	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:45.762169
2521	polygon_432	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:05.686413
2532	cylinder_239	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:45.992434
2523	polygon_433	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:43:05.692264
2536	cylinder_240	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:46.224127
2525	polygon_434	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:05.930116
2518	cube_237	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:46.453314
2527	polygon_435	red	{0,0,0}	31.376482	259.8365	934	0	0	37.234837	Shape.usd	2025-03-29 14:43:05.937786
2540	cylinder_241	green	{0,0,0}	-272.66354	217.54024	933	0	0	26.56505	cylinder.usd	2025-03-29 14:47:46.458296
2529	polygon_436	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:06.166319
2522	cube_238	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:46.685057
2531	polygon_437	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	Shape.usd	2025-03-29 14:43:06.170922
2544	cylinder_242	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:47:46.689796
2533	polygon_438	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:06.395134
2526	cube_239	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:46.919233
2535	polygon_439	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:43:06.401026
2530	cube_240	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.03625	cube.usd	2025-03-29 14:47:47.15656
2537	polygon_440	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:06.615408
2534	cube_241	red	{0,0,0}	31.499039	259.86707	917.00006	0	0	37.405357	cube.usd	2025-03-29 14:47:47.158969
2552	cylinder_244	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.434948	cylinder.usd	2025-03-29 14:47:47.161205
2556	cylinder_245	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:47.391253
2541	polygon_441	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:06.843797
2539	cube_243	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:47.611626
2543	polygon_442	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:06.848869
2560	cylinder_246	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:47.616143
2545	polygon_443	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:07.075232
2542	cube_244	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:47.831219
2547	polygon_444	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:07.07969
2564	cylinder_247	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:47.836009
2549	polygon_445	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:43:07.297436
2546	cube_245	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.420776	cube.usd	2025-03-29 14:47:48.05429
2551	polygon_446	red	{0,0,0}	32.357	258.856	933	0	0	37.405357	Shape.usd	2025-03-29 14:43:07.301349
2568	cylinder_248	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:48.059192
2553	polygon_447	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:07.528989
2550	cube_246	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:47:48.290851
2555	polygon_448	red	{0,0,0}	32.357	258.856	934	0	0	37.568592	Shape.usd	2025-03-29 14:43:07.534044
2572	cylinder_249	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:48.295415
2557	polygon_449	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:07.767189
2554	cube_247	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:47:48.525158
2559	polygon_450	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	Shape.usd	2025-03-29 14:43:07.772862
2558	cube_248	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:48.749777
2561	polygon_451	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:08.002427
2562	cube_249	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:48.975807
2563	polygon_452	red	{0,0,0}	31.499039	259.86707	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:08.008023
2566	cube_250	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:49.214844
2565	polygon_453	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:08.236489
2570	cube_251	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:49.447722
2567	polygon_454	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:43:08.242183
2574	cube_252	pink	{0,0,0}	-205.90816	345.1413	905.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:49.682435
2569	polygon_455	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:08.4804
2571	polygon_456	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:43:08.484995
2573	polygon_457	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:08.712915
2575	polygon_458	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:08.718537
5649	pentagonal_prism_255	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:45.283307
2577	polygon_459	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:08.942598
2584	cylinder_252	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 14:47:48.980328
2579	polygon_460	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:08.948583
2588	cylinder_253	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:49.219364
2581	polygon_461	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:09.18109
2592	cylinder_254	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 14:47:49.452893
2583	polygon_462	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:09.185162
2596	cylinder_255	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:49.687399
2585	polygon_463	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:09.421103
2578	cube_253	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:47:49.927651
2587	polygon_464	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:09.425276
2600	cylinder_256	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:49.932224
2589	polygon_465	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:09.644665
2582	cube_254	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.620872	cube.usd	2025-03-29 14:47:50.15378
2591	polygon_466	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:09.649552
2604	cylinder_257	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:50.158584
2593	polygon_467	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:09.890332
2586	cube_255	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:50.377225
2595	polygon_468	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:09.894581
2608	cylinder_258	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:50.383301
2597	polygon_469	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:10.116506
2590	cube_256	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:47:50.617773
2599	polygon_470	red	{0,0,0}	31.376482	259.8365	929	0	0	37.694237	Shape.usd	2025-03-29 14:43:10.121276
2612	cylinder_259	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:50.622408
2601	polygon_471	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:10.351422
2598	cube_258	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:51.08063
2603	polygon_472	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:43:10.357059
2620	cylinder_261	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:51.084815
2605	polygon_473	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:10.580383
2602	cube_259	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:47:51.305971
2624	cylinder_262	green	{0,0,0}	-270.62216	216.69383	943	0	0	26.56505	cylinder.usd	2025-03-29 14:47:51.310671
2606	cube_260	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:47:51.537755
2609	polygon_474	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:10.813405
2628	cylinder_263	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:51.542254
2611	polygon_475	red	{0,0,0}	32.357	258.856	929	0	0	37.874985	Shape.usd	2025-03-29 14:43:10.819209
2607	cube_261	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:51.762571
2613	polygon_476	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:11.036796
2615	polygon_477	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:11.043158
2632	cylinder_264	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:51.767068
2617	polygon_478	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:11.282292
2619	polygon_479	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:11.288271
2610	cube_262	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.03625	cube.usd	2025-03-29 14:47:52.002789
2621	polygon_480	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:11.513416
2623	polygon_481	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:11.519343
2614	cube_263	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:52.226892
2625	polygon_482	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:43:11.748459
2627	polygon_483	red	{0,0,0}	31.499039	259.86707	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:11.753918
2618	cube_264	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:52.473464
2629	polygon_484	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:11.96857
2631	polygon_485	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.303947	Shape.usd	2025-03-29 14:43:11.973018
2622	cube_265	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:52.700787
2633	polygon_486	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:12.19346
2626	cube_266	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:52.923742
2630	cube_267	pink	{0,0,0}	-207.6968	346.48944	911.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:53.147086
2635	polygon_487	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:12.199206
2520	cylinder_236	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:45.29092
2637	polygon_488	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:12.414899
2639	polygon_489	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:12.419835
2641	polygon_490	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:12.639868
2645	polygon_491	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:12.869808
2647	polygon_492	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.874985	Shape.usd	2025-03-29 14:43:12.875148
2649	polygon_493	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:13.102218
2651	polygon_494	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:13.108123
2653	polygon_495	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:43:13.364572
2655	polygon_496	red	{0,0,0}	30.514694	260.8514	934	0	0	37.568592	Shape.usd	2025-03-29 14:43:13.370819
2657	polygon_497	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:13.604022
2659	polygon_498	red	{0,0,0}	31.376482	259.8365	934	0	0	37.303947	Shape.usd	2025-03-29 14:43:13.609631
2661	polygon_499	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:13.838363
2663	polygon_500	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:43:13.844947
2665	polygon_501	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:14.069056
2669	polygon_502	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:14.304456
2671	polygon_503	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:14.308988
2673	polygon_504	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:14.529789
2675	polygon_505	orange	{0,0,0}	30.514694	260.8514	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:14.535373
2677	polygon_506	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:14.764187
2679	polygon_507	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:14.770027
2681	polygon_508	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:14.994699
2683	polygon_509	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:43:15.00064
2685	polygon_510	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:15.222109
2687	polygon_511	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.234837	Shape.usd	2025-03-29 14:43:15.226798
2689	polygon_512	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	Shape.usd	2025-03-29 14:43:15.446532
2691	polygon_513	red	{0,0,0}	30.514694	260.8514	924	0	0	37.568592	Shape.usd	2025-03-29 14:43:15.451041
2643	cylinder_267	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:52.478295
2644	cylinder_268	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:52.70574
2648	cylinder_269	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:52.928403
2634	cube_268	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:53.379858
2656	cylinder_271	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:53.384159
2638	cube_269	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:53.61153
2660	cylinder_272	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:47:53.61577
2642	cube_270	pink	{0,0,0}	-207.6968	346.48944	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:53.846919
2664	cylinder_273	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:53.851236
2646	cube_271	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:54.082214
2667	cylinder_274	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:54.086639
2650	cube_272	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:54.309355
2668	cylinder_275	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:54.314193
2654	cube_273	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:54.546444
2672	cylinder_276	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:54.551233
2658	cube_274	pink	{0,0,0}	-207.6968	346.48944	915	0	0	59.03624	cube.usd	2025-03-29 14:47:54.779151
2676	cylinder_277	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	cylinder.usd	2025-03-29 14:47:54.783505
2662	cube_275	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:47:55.014583
2680	cylinder_278	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:55.01867
2666	cube_276	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:47:55.249577
2670	cube_277	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.620872	cube.usd	2025-03-29 14:47:55.479954
2688	cylinder_280	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:47:55.48437
2674	cube_278	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.534454	cube.usd	2025-03-29 14:47:55.717007
2678	cube_279	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:47:55.9477
2682	cube_280	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.03624	cube.usd	2025-03-29 14:47:56.184436
2686	cube_281	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:56.415052
2690	cube_282	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:56.648925
2693	polygon_514	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:15.667607
2695	polygon_515	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:15.672005
2697	polygon_516	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:15.905343
2699	polygon_517	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	Shape.usd	2025-03-29 14:43:15.910843
2701	polygon_518	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:43:16.136037
2703	polygon_519	red	{0,0,0}	32.355774	258.8462	934	0	0	37.405357	Shape.usd	2025-03-29 14:43:16.142797
2705	polygon_520	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:16.394082
2707	polygon_521	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:16.402154
2709	polygon_522	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:16.617621
2711	polygon_523	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:16.621831
2713	polygon_524	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:16.852852
2715	polygon_525	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:43:16.858686
2717	polygon_526	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:17.077801
2719	polygon_527	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	Shape.usd	2025-03-29 14:43:17.083324
2721	polygon_528	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:17.300997
2723	polygon_529	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.303947	Shape.usd	2025-03-29 14:43:17.305553
2725	polygon_530	black	{0,0,0}	-127.46696	518.69244	663.00006	0	0	90	Shape.usd	2025-03-29 14:43:17.548976
2727	polygon_531	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:17.553661
2729	polygon_532	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:17.781426
2731	polygon_533	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:17.787175
2733	polygon_534	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:18.025763
2735	polygon_535	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:18.029994
2737	polygon_536	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	Shape.usd	2025-03-29 14:43:18.250339
2741	polygon_537	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:18.488088
2743	polygon_538	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:43:18.49213
2745	polygon_539	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:43:18.721487
2747	polygon_540	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:18.726406
2749	polygon_541	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:18.946225
2696	cylinder_282	red	{0,0,0}	31.376482	259.8365	917.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:47:55.949906
2700	cylinder_283	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:55.952312
2704	cylinder_284	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:56.188958
2708	cylinder_285	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:56.419197
2694	cube_283	pink	{0,0,0}	-206.88867	345.1413	926.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:56.88
2716	cylinder_287	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:56.884281
2698	cube_284	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:47:57.120782
2720	cylinder_288	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:57.124995
2702	cube_285	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:57.348955
2724	cylinder_289	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:57.353509
2706	cube_286	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:57.580255
2728	cylinder_290	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:47:57.584546
2710	cube_287	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:57.814086
2732	cylinder_291	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:47:57.818366
2714	cube_288	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:58.080213
2736	cylinder_292	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:58.084695
2718	cube_289	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:58.315133
2739	cylinder_293	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:47:58.319342
2722	cube_290	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:47:58.549944
2740	cylinder_294	green	{0,0,0}	-270.62216	216.69383	933	0	0	18.434948	cylinder.usd	2025-03-29 14:47:58.554098
2726	cube_291	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:58.785049
2730	cube_292	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:59.018599
2748	cylinder_296	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:59.023045
2734	cube_293	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:59.247317
2738	cube_294	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:47:59.480499
2742	cube_295	pink	{0,0,0}	-205.90816	345.1413	940.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:59.717575
2746	cube_296	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.34933	cube.usd	2025-03-29 14:47:59.948692
2751	polygon_542	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:18.950678
2753	polygon_543	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:19.178107
2755	polygon_544	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:19.182439
2757	polygon_545	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:19.40353
2759	polygon_546	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:19.408103
2761	polygon_547	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:19.640338
2763	polygon_548	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:19.645759
2765	polygon_549	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:19.868693
2769	polygon_550	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:20.098812
2771	polygon_551	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:20.104982
2773	polygon_552	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:20.321895
2777	polygon_553	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:20.552784
2779	polygon_554	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:20.557576
2781	polygon_555	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:20.776323
2783	polygon_556	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:20.780326
2785	polygon_557	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:21.005053
2787	polygon_558	red	{0,0,0}	32.357	258.856	920	0	0	37.874985	Shape.usd	2025-03-29 14:43:21.010444
2789	polygon_559	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:43:21.239283
2791	polygon_560	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:21.244836
2793	polygon_561	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:21.482341
2795	polygon_562	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:21.48835
2797	polygon_563	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:21.705939
2799	polygon_564	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:43:21.709896
2801	polygon_565	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:21.937842
2803	polygon_566	red	{0,0,0}	32.357	258.856	919	0	0	37.303947	Shape.usd	2025-03-29 14:43:21.943474
2805	polygon_567	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:22.189726
2807	polygon_568	red	{0,0,0}	30.514694	260.8514	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:22.194622
2756	cylinder_298	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:47:59.485096
2760	cylinder_299	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:59.721978
2764	cylinder_300	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:59.95332
2750	cube_297	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.743565	cube.usd	2025-03-29 14:48:00.185879
2754	cube_298	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:48:00.421502
2768	cylinder_302	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:00.425899
2758	cube_299	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:48:00.649683
2772	cylinder_303	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:00.654214
2762	cube_300	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03625	cube.usd	2025-03-29 14:48:00.894644
2776	cylinder_304	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:48:00.899071
2766	cube_301	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:48:01.129533
2780	cylinder_305	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:48:01.134061
2770	cube_302	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.620872	cube.usd	2025-03-29 14:48:01.360227
2784	cylinder_306	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:48:01.364566
2774	cube_303	pink	{0,0,0}	-207.6968	346.48944	928.00006	0	0	59.743565	cube.usd	2025-03-29 14:48:01.586655
2788	cylinder_307	red	{0,0,0}	29.53035	261.83575	934	0	0	37.405357	cylinder.usd	2025-03-29 14:48:01.588833
2792	cylinder_308	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:01.590971
2775	cube_304	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:48:01.815644
2796	cylinder_309	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:01.820394
2778	cube_305	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:48:02.053549
2782	cube_306	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.405357	cube.usd	2025-03-29 14:48:02.055907
2800	cylinder_310	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:48:02.058149
2804	cylinder_311	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 14:48:02.281344
2790	cube_308	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.03624	cube.usd	2025-03-29 14:48:02.502105
2794	cube_309	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:48:02.730045
2798	cube_310	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03624	cube.usd	2025-03-29 14:48:02.95185
2802	cube_311	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:48:03.185489
2806	cube_312	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.34933	cube.usd	2025-03-29 14:48:03.423597
2809	polygon_569	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:22.423564
2811	polygon_570	red	{0,0,0}	30.51353	260.84146	931.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:22.429159
2813	polygon_571	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:43:22.6625
2815	polygon_572	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:22.668183
2817	polygon_573	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:22.888008
2819	polygon_574	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:22.892578
2821	polygon_575	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:43:23.12038
2823	polygon_576	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:43:23.126851
2825	polygon_577	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:23.348463
2827	polygon_578	red	{0,0,0}	31.376482	259.8365	917.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:23.352575
2829	polygon_579	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:23.575167
2831	polygon_580	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:23.579296
2833	polygon_581	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:23.809213
2835	polygon_582	red	{0,0,0}	32.357	258.856	926.00006	0	0	36.869896	Shape.usd	2025-03-29 14:43:23.815624
2837	polygon_583	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:24.046988
2839	polygon_584	red	{0,0,0}	31.499039	259.86707	922.00006	0	0	37.874985	Shape.usd	2025-03-29 14:43:24.05372
2841	polygon_585	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:24.277519
2845	polygon_586	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:24.502079
2847	polygon_587	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	Shape.usd	2025-03-29 14:43:24.508475
2849	polygon_588	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:24.732671
2851	polygon_589	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:24.738406
2853	polygon_590	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:43:24.96674
2855	polygon_591	red	{0,0,0}	30.514694	260.8514	937.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:24.972403
2857	polygon_592	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:25.196488
2859	polygon_593	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.234837	Shape.usd	2025-03-29 14:43:25.202215
2861	polygon_594	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:43:25.436716
2863	polygon_595	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:25.4413
2865	polygon_596	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:25.672163
2812	cylinder_313	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:02.734541
2816	cylinder_314	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:02.956172
2820	cylinder_315	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:48:03.189946
2824	cylinder_316	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:03.42824
2828	cylinder_317	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:03.661555
2814	cube_314	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:48:03.884536
2832	cylinder_318	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:48:03.889058
2818	cube_315	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:48:04.123593
2836	cylinder_319	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:04.127988
2822	cube_316	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.34933	cube.usd	2025-03-29 14:48:04.359737
2840	cylinder_320	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:04.364556
2826	cube_317	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03624	cube.usd	2025-03-29 14:48:04.58718
2844	cylinder_321	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:48:04.591577
2830	cube_318	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.743565	cube.usd	2025-03-29 14:48:04.818005
2834	cube_319	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	cube.usd	2025-03-29 14:48:04.820959
2848	cylinder_322	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:04.823372
2838	cube_320	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.743565	cube.usd	2025-03-29 14:48:05.058823
2842	cube_321	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	cube.usd	2025-03-29 14:48:05.061217
2852	cylinder_323	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:05.063784
2843	cube_322	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:48:05.285573
2856	cylinder_324	green	{0,0,0}	-270.62216	216.69383	943	0	0	26.56505	cylinder.usd	2025-03-29 14:48:05.290571
2846	cube_323	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.420776	cube.usd	2025-03-29 14:48:05.51778
2850	cube_324	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:48:05.739603
2864	cylinder_326	green	{0,0,0}	-270.6119	216.68562	920	0	0	38.65981	cylinder.usd	2025-03-29 14:48:05.743845
2854	cube_325	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.620872	cube.usd	2025-03-29 14:48:05.978008
2858	cube_326	pink	{0,0,0}	-205.90816	345.1413	906	0	0	59.03624	cube.usd	2025-03-29 14:48:06.205307
2862	cube_327	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:48:06.440299
2867	polygon_597	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:25.677086
2869	polygon_598	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:43:25.894253
2871	polygon_599	red	{0,0,0}	32.357	258.856	920	0	0	37.874985	Shape.usd	2025-03-29 14:43:25.898921
2873	polygon_600	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:26.12794
2877	polygon_601	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:26.355055
2879	polygon_602	red	{0,0,0}	32.357	258.856	929	0	0	37.694237	Shape.usd	2025-03-29 14:43:26.36176
2881	polygon_603	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:26.600463
2885	polygon_604	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:26.826125
2887	polygon_605	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:26.83255
2889	polygon_606	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:27.072179
2891	polygon_607	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:43:27.078078
2893	polygon_608	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:27.295587
2897	polygon_609	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:27.526924
2901	polygon_610	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:43:27.756737
2903	polygon_611	red	{0,0,0}	32.357	258.856	935.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:27.761346
2905	polygon_612	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:27.983181
2907	polygon_613	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:43:27.989038
2909	polygon_614	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:28.218625
2911	polygon_615	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:28.22285
2913	polygon_616	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:28.448678
2915	polygon_617	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:28.454184
2917	polygon_618	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:28.673199
2919	polygon_619	red	{0,0,0}	31.376482	259.8365	934	0	0	37.874985	Shape.usd	2025-03-29 14:43:28.678837
2921	polygon_620	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:28.919203
2923	polygon_621	red	{0,0,0}	30.395967	260.81702	931.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:28.923658
2872	cylinder_328	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:48:06.20964
2875	cylinder_329	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:06.444818
2866	cube_328	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:48:06.67802
2876	cylinder_330	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:48:06.682467
2870	cube_329	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.534454	cube.usd	2025-03-29 14:48:06.911136
2874	cube_330	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.620872	cube.usd	2025-03-29 14:48:07.142917
2883	cylinder_332	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:07.14726
2878	cube_331	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03624	cube.usd	2025-03-29 14:48:07.37359
2884	cylinder_333	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:07.377758
2882	cube_332	pink	{0,0,0}	-207.6968	346.48944	928.00006	0	0	59.743565	cube.usd	2025-03-29 14:48:07.608272
2888	cylinder_334	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:07.612683
2886	cube_333	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:48:07.838896
2892	cylinder_335	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:07.843096
2890	cube_334	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	cube.usd	2025-03-29 14:48:08.076521
2895	cylinder_336	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:48:08.081046
2894	cube_335	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.534454	cube.usd	2025-03-29 14:48:08.309635
2896	cylinder_337	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:48:08.315869
2898	cube_336	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:48:08.544059
2900	cylinder_338	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:48:08.54825
2899	cube_337	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.620872	cube.usd	2025-03-29 14:48:08.774385
2904	cylinder_339	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:48:08.778588
2902	cube_338	pink	{0,0,0}	-207.6968	346.48944	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:48:09.005665
2906	cube_339	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:48:09.238281
2910	cube_340	red	{0,0,0}	32.357	258.856	929	0	0	37.694237	cube.usd	2025-03-29 14:48:09.240845
2912	cylinder_341	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:09.243104
2914	cube_341	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:48:09.475616
2916	cylinder_342	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	cylinder.usd	2025-03-29 14:48:09.477765
2920	cylinder_343	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:09.479999
2918	cube_342	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:48:09.711464
2922	cube_343	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03624	cube.usd	2025-03-29 14:48:09.942124
2925	polygon_622	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:29.146906
2927	polygon_623	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:29.151222
2929	polygon_624	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:29.373411
2931	polygon_625	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:29.379557
2933	polygon_626	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:43:29.606345
2935	polygon_627	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:29.612248
2937	polygon_628	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:29.844232
2941	polygon_629	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:30.075232
2943	polygon_630	red	{0,0,0}	32.357	258.856	933	0	0	37.568592	Shape.usd	2025-03-29 14:43:30.079749
2945	polygon_631	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	Shape.usd	2025-03-29 14:43:30.302038
2947	polygon_632	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:30.306582
2949	polygon_633	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:30.529476
2951	polygon_634	red	{0,0,0}	30.395967	260.81702	935.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:30.534995
2953	polygon_635	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:30.765973
2955	polygon_636	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:30.771867
2957	polygon_637	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:30.998937
2961	polygon_638	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:31.229671
2963	polygon_639	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:31.235322
2965	polygon_640	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:31.456133
2967	polygon_641	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.303947	Shape.usd	2025-03-29 14:43:31.462148
2969	polygon_642	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:31.676388
2971	polygon_643	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	Shape.usd	2025-03-29 14:43:31.68082
2973	polygon_644	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:31.910381
2975	polygon_645	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:43:31.914907
2977	polygon_646	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:32.144384
2979	polygon_647	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:43:32.148845
2981	polygon_648	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:32.372697
2928	cylinder_345	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:48:09.946593
2926	cube_344	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:48:10.177708
2932	cylinder_346	red	{0,0,0}	30.395967	260.81702	934	0	0	37.69424	cylinder.usd	2025-03-29 14:48:10.179923
2936	cylinder_347	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:48:10.182118
2930	cube_345	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	cube.usd	2025-03-29 14:48:10.414978
2934	cube_346	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:48:10.64304
2944	cylinder_349	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:10.647534
2938	cube_347	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.620872	cube.usd	2025-03-29 14:48:10.87384
2948	cylinder_350	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	cylinder.usd	2025-03-29 14:48:10.878259
2939	cube_348	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:48:11.109165
2952	cylinder_351	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:11.113544
2942	cube_349	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.743565	cube.usd	2025-03-29 14:48:11.345295
2946	cube_350	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	cube.usd	2025-03-29 14:48:11.347856
2956	cylinder_352	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:11.350313
2950	cube_351	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:48:11.579913
2960	cylinder_353	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:11.584588
2954	cube_352	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:48:11.812441
2964	cylinder_354	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	cylinder.usd	2025-03-29 14:48:11.816762
2958	cube_353	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.34933	cube.usd	2025-03-29 14:48:12.052872
2968	cylinder_355	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:12.057366
2959	cube_354	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03624	cube.usd	2025-03-29 14:48:12.278782
2972	cylinder_356	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:12.282834
2962	cube_355	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.743565	cube.usd	2025-03-29 14:48:12.508977
2966	cube_356	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:48:12.745853
2980	cylinder_358	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:12.75011
2970	cube_357	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.420776	cube.usd	2025-03-29 14:48:12.974373
2974	cube_358	pink	{0,0,0}	-207.6968	346.48944	923.00006	0	0	59.743565	cube.usd	2025-03-29 14:48:13.210454
2978	cube_359	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.420776	cube.usd	2025-03-29 14:48:13.446982
2985	polygon_649	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:32.598104
2987	polygon_650	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:32.603092
2989	polygon_651	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:32.829089
2991	polygon_652	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:32.834875
2993	polygon_653	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:43:33.104491
2995	polygon_654	orange	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:33.109105
2997	polygon_655	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:33.328955
2999	polygon_656	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:33.334987
3001	polygon_657	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:33.569687
3003	polygon_658	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:33.575121
3005	polygon_659	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:33.813389
3009	polygon_660	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:34.065696
3010	cube_368	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.743565	Shape.usd	2025-03-29 14:43:34.06923
3011	polygon_661	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:34.071312
3013	polygon_662	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:43:34.308341
3014	cube_369	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.420776	Shape.usd	2025-03-29 14:43:34.310632
3015	polygon_663	red	{0,0,0}	30.514694	260.8514	929	0	0	37.568592	Shape.usd	2025-03-29 14:43:34.312615
3017	polygon_664	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:34.542826
3018	cube_370	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	Shape.usd	2025-03-29 14:43:34.546736
3019	polygon_665	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	Shape.usd	2025-03-29 14:43:34.548794
3020	cylinder_369	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:34.550901
3021	polygon_666	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:34.776405
3022	cube_371	pink	{0,0,0}	-205.90816	345.1413	908.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:34.778696
3023	polygon_667	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:34.780614
3024	cylinder_370	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:34.782695
3025	polygon_668	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:35.000622
3026	cube_372	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:43:35.003862
3027	polygon_669	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:43:35.005933
3028	cylinder_371	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:43:35.007846
3029	polygon_670	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:35.247115
3030	cube_373	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	Shape.usd	2025-03-29 14:43:35.252562
3031	polygon_671	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:43:35.256601
3032	cylinder_372	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:35.260361
3033	polygon_672	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:35.486583
3034	cube_374	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.34933	Shape.usd	2025-03-29 14:43:35.490166
3035	polygon_673	red	{0,0,0}	31.499039	259.86707	934	0	0	37.746803	Shape.usd	2025-03-29 14:43:35.492113
3036	cylinder_373	green	{0,0,0}	-272.66354	217.54024	929	0	0	36.869896	Shape.usd	2025-03-29 14:43:35.494286
3037	polygon_674	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:35.726508
3038	cube_375	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:35.728979
3039	polygon_675	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:35.730877
2984	cylinder_360	green	{0,0,0}	-272.66354	217.54024	924	0	0	18.434948	cylinder.usd	2025-03-29 14:48:13.214922
2988	cylinder_361	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:13.45143
2982	cube_360	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:48:13.676968
2992	cylinder_362	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:48:13.681543
2986	cube_361	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.620872	cube.usd	2025-03-29 14:48:13.911762
2990	cube_362	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.534454	cube.usd	2025-03-29 14:48:14.147956
3000	cylinder_364	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:48:14.152734
2994	cube_363	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:48:14.378868
3004	cylinder_365	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:14.383139
2998	cube_364	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:48:14.613216
3008	cylinder_366	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:48:14.617551
3002	cube_365	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:48:14.847936
3006	cube_366	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	cube.usd	2025-03-29 14:48:14.8502
3012	cylinder_367	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:48:14.852318
3007	cube_367	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.534454	cube.usd	2025-03-29 14:48:15.075419
3016	cylinder_368	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:15.081295
3040	cylinder_374	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:35.732685
3041	polygon_676	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:35.951927
3042	cube_376	pink	{0,0,0}	-206.88867	345.1413	927.00006	0	0	59.34933	Shape.usd	2025-03-29 14:43:35.955567
3043	polygon_677	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	Shape.usd	2025-03-29 14:43:35.957444
3044	cylinder_375	green	{0,0,0}	-270.62216	216.69383	924	0	0	33.690063	Shape.usd	2025-03-29 14:43:35.959271
3045	polygon_678	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:36.186853
3046	cube_377	pink	{0,0,0}	-207.6968	346.48944	922.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:36.190596
3047	polygon_679	red	{0,0,0}	30.514694	260.8514	934	0	0	37.874985	Shape.usd	2025-03-29 14:43:36.192418
3048	cylinder_376	green	{0,0,0}	-272.66354	217.54024	914.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:36.194354
3049	polygon_680	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:36.409848
3050	cube_378	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	Shape.usd	2025-03-29 14:43:36.413782
3051	polygon_681	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:43:36.415895
3052	cylinder_377	green	{0,0,0}	-270.62216	216.69383	920	0	0	33.690063	Shape.usd	2025-03-29 14:43:36.418121
3053	polygon_682	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:36.654807
3054	cube_379	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:36.658746
3055	polygon_683	red	{0,0,0}	31.499039	259.86707	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:36.660755
3056	cylinder_378	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:36.66263
3057	polygon_684	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:36.881578
3058	cube_380	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:36.885121
3059	cylinder_379	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:43:36.887844
3060	cylinder_380	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:36.889879
3061	polygon_685	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:37.106868
3062	cube_381	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:43:37.108956
3063	polygon_686	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	Shape.usd	2025-03-29 14:43:37.110795
3064	cylinder_381	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:37.112749
3065	polygon_687	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:37.328909
3066	cube_382	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:43:37.33258
3067	polygon_688	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:37.33466
3068	cylinder_382	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:37.336842
3069	polygon_689	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	Shape.usd	2025-03-29 14:43:37.558413
3070	cube_383	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:43:37.562003
3071	polygon_690	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	Shape.usd	2025-03-29 14:43:37.563941
3072	cylinder_383	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:43:37.565988
3073	polygon_691	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:37.790529
3074	cube_384	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.620872	Shape.usd	2025-03-29 14:43:37.794304
3075	polygon_692	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.234837	Shape.usd	2025-03-29 14:43:37.796163
3076	cylinder_384	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:37.797975
3077	polygon_693	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	Shape.usd	2025-03-29 14:43:38.01939
3078	cube_385	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:38.023013
3079	polygon_694	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.234837	Shape.usd	2025-03-29 14:43:38.025035
3080	cylinder_385	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	Shape.usd	2025-03-29 14:43:38.026923
3081	polygon_695	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:38.244885
3082	cube_386	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:43:38.248534
3083	polygon_696	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.874985	Shape.usd	2025-03-29 14:43:38.250476
3084	cylinder_386	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:38.252493
3085	polygon_697	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:38.471905
3086	cube_387	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:38.474344
3087	cube_388	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:38.47656
3088	cylinder_387	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:38.478595
3089	polygon_698	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:38.728336
3090	cube_389	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	Shape.usd	2025-03-29 14:43:38.731831
3091	cube_390	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:38.73376
3092	cylinder_388	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:38.735721
3093	polygon_699	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:38.95279
3094	cube_391	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:43:38.954899
3095	polygon_700	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:38.956786
3096	cylinder_389	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:38.958617
3097	polygon_701	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:39.188407
3098	cube_392	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:39.190623
3099	polygon_702	red	{0,0,0}	31.499039	259.86707	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:39.19271
3100	cylinder_390	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	33.690063	Shape.usd	2025-03-29 14:43:39.194628
3101	polygon_703	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:39.420541
3102	cube_393	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:43:39.424874
3103	cube_394	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.874985	Shape.usd	2025-03-29 14:43:39.427603
3104	cylinder_391	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:39.429841
3105	polygon_704	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:39.652461
3106	cube_395	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.420776	Shape.usd	2025-03-29 14:43:39.656282
3107	polygon_705	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:39.658197
3108	cylinder_392	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:43:39.660766
3109	polygon_706	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:39.885735
3110	cube_396	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:39.88823
3111	polygon_707	orange	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:39.890257
3112	cylinder_393	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:43:39.892068
3113	polygon_708	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:40.11923
3114	cube_397	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:40.12163
3115	polygon_709	red	{0,0,0}	32.357	258.856	924	0	0	37.303947	Shape.usd	2025-03-29 14:43:40.124871
3116	cylinder_394	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	Shape.usd	2025-03-29 14:43:40.12708
3117	polygon_710	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:40.349221
3118	cube_398	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:40.35134
3119	polygon_711	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:40.353499
3120	cylinder_395	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:40.355386
3121	polygon_712	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:43:40.57468
3122	cube_399	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:40.577691
3123	polygon_713	red	{0,0,0}	31.499039	259.86707	929	0	0	37.568592	Shape.usd	2025-03-29 14:43:40.579708
3124	cylinder_396	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	33.690063	Shape.usd	2025-03-29 14:43:40.581526
3125	polygon_714	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:40.804617
3126	cube_400	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:40.808903
3127	polygon_715	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:40.8112
3128	cylinder_397	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:40.813104
3129	polygon_716	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:41.039458
3130	cube_401	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.420776	Shape.usd	2025-03-29 14:43:41.042906
3131	polygon_717	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	Shape.usd	2025-03-29 14:43:41.044957
3132	cylinder_398	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:43:41.046937
3133	polygon_718	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:41.270209
3134	cube_402	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:41.272728
3135	polygon_719	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:41.274684
3136	cylinder_399	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:43:41.276703
3137	polygon_720	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	Shape.usd	2025-03-29 14:43:41.515671
3138	cube_403	pink	{0,0,0}	-207.6968	346.48944	914.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:41.520065
3139	cube_404	red	{0,0,0}	31.499039	259.86707	924	0	0	37.69424	Shape.usd	2025-03-29 14:43:41.52247
3140	cylinder_400	green	{0,0,0}	-272.66354	217.54024	938	0	0	26.56505	Shape.usd	2025-03-29 14:43:41.524777
3141	polygon_721	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:41.762356
3142	cube_405	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:43:41.765903
3143	polygon_722	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.874985	Shape.usd	2025-03-29 14:43:41.767805
3144	cylinder_401	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:43:41.769614
3145	polygon_723	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:41.995898
3146	cube_406	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:41.998365
3147	polygon_724	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:42.001372
3148	cylinder_402	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:43:42.004786
3149	polygon_725	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:42.235087
3150	cube_407	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:42.237215
3151	polygon_726	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:42.239289
3152	cylinder_403	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:42.241585
3153	polygon_727	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:42.460554
3154	cube_408	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	Shape.usd	2025-03-29 14:43:42.463207
3155	polygon_728	red	{0,0,0}	32.357	258.856	934	0	0	37.568592	Shape.usd	2025-03-29 14:43:42.465195
3156	cylinder_404	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	Shape.usd	2025-03-29 14:43:42.467036
3157	polygon_729	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:43:42.689631
3158	cube_409	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:42.692696
3159	polygon_730	red	{0,0,0}	30.514694	260.8514	924	0	0	37.874985	Shape.usd	2025-03-29 14:43:42.694896
3160	cylinder_405	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:42.696929
3161	polygon_731	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:43:42.916251
3162	cube_410	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.534454	Shape.usd	2025-03-29 14:43:42.919866
3163	polygon_732	red	{0,0,0}	30.514694	260.8514	919	0	0	37.568592	Shape.usd	2025-03-29 14:43:42.92232
3164	cylinder_406	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	33.690063	Shape.usd	2025-03-29 14:43:42.924283
3165	polygon_733	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:43.152161
3166	cube_411	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:43:43.155929
3167	polygon_734	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:43.158326
3168	cylinder_407	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:43:43.16033
3169	polygon_735	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:43.395874
3170	cube_412	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:43.399234
3171	polygon_736	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:43:43.401108
3172	cylinder_408	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:43:43.403011
3173	polygon_737	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:43.624041
3174	cube_413	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.34933	Shape.usd	2025-03-29 14:43:43.627573
3175	polygon_738	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:43:43.629515
3176	cylinder_409	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:43:43.631441
3177	polygon_739	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:43.85334
3178	cube_414	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	Shape.usd	2025-03-29 14:43:43.857163
3179	polygon_740	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	Shape.usd	2025-03-29 14:43:43.859217
3180	cylinder_410	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:43:43.861395
3181	polygon_741	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:44.090006
3182	cube_415	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	Shape.usd	2025-03-29 14:43:44.093999
3183	polygon_742	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:44.096162
3184	cylinder_411	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:44.098209
3185	polygon_743	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:44.316068
3186	cube_416	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	Shape.usd	2025-03-29 14:43:44.318364
3187	polygon_744	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:44.32054
3188	cylinder_412	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:44.322756
3189	polygon_745	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:44.543954
3190	cube_417	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:44.546725
3191	polygon_746	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:44.548575
3192	cylinder_413	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.434948	Shape.usd	2025-03-29 14:43:44.550431
3193	polygon_747	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:44.776705
3194	cube_418	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	Shape.usd	2025-03-29 14:43:44.780639
3195	cylinder_414	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:44.78266
3196	cylinder_415	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:44.784461
3197	polygon_748	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:43:45.011229
3198	cube_419	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:45.014976
3199	polygon_749	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	Shape.usd	2025-03-29 14:43:45.016971
3200	cylinder_416	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:45.018837
3201	polygon_750	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:45.242068
3202	cube_420	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:45.244537
3203	polygon_751	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:43:45.246521
3204	cylinder_417	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	33.690063	Shape.usd	2025-03-29 14:43:45.248353
3205	polygon_752	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:45.487206
3206	cube_421	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:45.489896
3207	polygon_753	red	{0,0,0}	32.357	258.856	929	0	0	37.69424	Shape.usd	2025-03-29 14:43:45.492036
3208	cylinder_418	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:43:45.493945
3209	polygon_754	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:45.709764
3210	cube_422	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:43:45.712192
3211	polygon_755	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	Shape.usd	2025-03-29 14:43:45.714261
3212	cylinder_419	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:45.716073
3213	polygon_756	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:45.947372
3214	cube_423	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:45.950997
3215	polygon_757	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:45.953049
3216	cylinder_420	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:45.954856
3217	polygon_758	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:46.172017
3218	cube_424	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:46.174275
3219	polygon_759	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	Shape.usd	2025-03-29 14:43:46.176271
3220	cylinder_421	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	Shape.usd	2025-03-29 14:43:46.178258
3221	polygon_760	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:43:46.391858
3222	cube_425	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:46.39472
3223	polygon_761	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:46.397137
3224	cylinder_422	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:46.39913
3225	polygon_762	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:46.633278
3226	cube_426	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:46.635444
3227	polygon_763	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:43:46.637478
3228	cylinder_423	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:43:46.639485
3229	polygon_764	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:46.864853
3230	cube_427	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.420776	Shape.usd	2025-03-29 14:43:46.868133
3231	polygon_765	red	{0,0,0}	32.357	258.856	933	0	0	37.568592	Shape.usd	2025-03-29 14:43:46.869992
3232	cylinder_424	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:46.871862
3233	polygon_766	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:47.104096
3234	cube_428	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:43:47.107996
3235	polygon_767	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:47.110307
3236	cylinder_425	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:47.112619
3237	polygon_768	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:47.32942
3238	cube_429	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:47.332098
3239	polygon_769	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:47.334028
3240	cylinder_426	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	18.434948	Shape.usd	2025-03-29 14:43:47.335767
3241	polygon_770	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:47.558304
3242	cube_430	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:47.562032
3243	polygon_771	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:43:47.564013
3244	cylinder_427	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:47.56595
3245	polygon_772	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:47.797817
3246	cube_431	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:47.80176
3247	polygon_773	red	{0,0,0}	31.376482	259.8365	924	0	0	37.303947	Shape.usd	2025-03-29 14:43:47.804225
3248	cylinder_428	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:47.807218
3249	polygon_774	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:43:48.051497
3250	cube_432	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:43:48.05401
3251	polygon_775	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.303947	Shape.usd	2025-03-29 14:43:48.055883
3252	cylinder_429	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:48.057782
3253	polygon_776	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:48.31289
3254	cube_433	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:48.315748
3255	polygon_777	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	36.869896	Shape.usd	2025-03-29 14:43:48.318328
3256	cylinder_430	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:43:48.320263
3257	polygon_778	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:48.551828
3258	cube_434	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:48.553954
3259	polygon_779	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:48.556045
3260	cylinder_431	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:48.55815
3261	polygon_780	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	Shape.usd	2025-03-29 14:43:48.786088
3262	cube_435	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	Shape.usd	2025-03-29 14:43:48.788521
3263	polygon_781	red	{0,0,0}	30.51353	260.84146	933	0	0	37.568592	Shape.usd	2025-03-29 14:43:48.79034
3264	cylinder_432	green	{0,0,0}	-272.65317	217.53194	936.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:48.792195
3265	polygon_782	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:49.050221
3266	cube_436	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:43:49.052936
3267	polygon_783	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:43:49.054931
3268	cylinder_433	green	{0,0,0}	-270.62216	216.69383	941.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:49.056841
3269	polygon_784	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:49.276646
3270	cube_437	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:49.27923
3271	polygon_785	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:49.281354
3272	cylinder_434	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:43:49.283313
3273	polygon_786	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:49.523963
3274	cube_438	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:49.526712
3275	polygon_787	red	{0,0,0}	32.357	258.856	929	0	0	37.303947	Shape.usd	2025-03-29 14:43:49.528988
3276	cylinder_435	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:49.530965
3277	polygon_788	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:49.743411
3278	cube_439	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.743565	Shape.usd	2025-03-29 14:43:49.747666
3279	polygon_789	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.874985	Shape.usd	2025-03-29 14:43:49.749842
3280	cylinder_436	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:49.751865
3281	polygon_790	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:49.98048
3282	cube_440	pink	{0,0,0}	-205.90816	345.1413	908.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:49.984291
3283	polygon_791	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:49.986482
3284	cylinder_437	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:43:49.988492
3285	polygon_792	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:50.220632
3286	cube_441	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.743565	Shape.usd	2025-03-29 14:43:50.22458
3287	polygon_793	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:50.226466
3288	cylinder_438	green	{0,0,0}	-270.62216	216.69383	917.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:50.22886
3289	polygon_794	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:50.447339
3290	cube_442	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:50.449905
3291	polygon_795	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:50.451797
3292	cylinder_439	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:50.453625
3293	polygon_796	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	Shape.usd	2025-03-29 14:43:50.678764
3294	cube_443	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.34933	Shape.usd	2025-03-29 14:43:50.681201
3295	polygon_797	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:50.683214
3296	cylinder_440	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	Shape.usd	2025-03-29 14:43:50.685093
3297	polygon_798	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:50.907101
3298	cube_444	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.34933	Shape.usd	2025-03-29 14:43:50.909428
3299	cube_445	red	{0,0,0}	32.357	258.856	929	0	0	37.69424	Shape.usd	2025-03-29 14:43:50.911404
3300	cylinder_441	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:50.913537
3301	polygon_799	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:51.129933
3302	cube_446	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.420776	Shape.usd	2025-03-29 14:43:51.132979
3303	polygon_800	red	{0,0,0}	31.376482	259.8365	933	0	0	37.69424	Shape.usd	2025-03-29 14:43:51.134916
3304	cylinder_442	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:51.136753
3305	polygon_801	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:51.365277
3306	cube_447	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:51.36918
3307	polygon_802	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:51.371054
3308	cylinder_443	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:51.372861
3309	polygon_803	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:51.602622
3310	cube_448	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:51.606475
3311	polygon_804	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	Shape.usd	2025-03-29 14:43:51.608399
3312	cylinder_444	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:43:51.610275
3313	polygon_805	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:51.833357
3314	cube_449	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:51.836944
3315	polygon_806	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:43:51.838809
3316	cylinder_445	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:43:51.840627
3317	polygon_807	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:52.059393
3318	cube_450	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:52.062258
3319	polygon_808	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:52.064332
3320	cylinder_446	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	Shape.usd	2025-03-29 14:43:52.06627
3321	polygon_809	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:52.29353
3322	cube_451	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	Shape.usd	2025-03-29 14:43:52.297453
3323	polygon_810	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:52.299465
3324	cylinder_447	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	36.869896	Shape.usd	2025-03-29 14:43:52.301377
3325	polygon_811	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:52.532469
3326	cube_452	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:52.536304
3327	polygon_812	orange	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:52.538284
3328	cylinder_448	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:43:52.540126
3329	polygon_813	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:52.761103
3330	cube_453	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.620872	Shape.usd	2025-03-29 14:43:52.765038
3331	polygon_814	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:43:52.767061
3332	cylinder_449	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:52.768912
3333	polygon_815	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:52.992624
3334	cube_454	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.34933	Shape.usd	2025-03-29 14:43:52.995209
3335	polygon_816	red	{0,0,0}	30.514694	260.8514	921.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:52.997567
3336	cylinder_450	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	Shape.usd	2025-03-29 14:43:52.999715
3337	polygon_817	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:53.22567
3338	cube_455	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.620872	Shape.usd	2025-03-29 14:43:53.229276
3339	polygon_818	red	{0,0,0}	31.376482	259.8365	919	0	0	37.303947	Shape.usd	2025-03-29 14:43:53.231444
3340	cylinder_451	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:53.233471
3341	polygon_819	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:43:53.455549
3342	cube_456	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:53.457777
3343	polygon_820	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.874985	Shape.usd	2025-03-29 14:43:53.459805
3344	cylinder_452	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:43:53.462592
3345	polygon_821	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:43:53.691377
3346	cube_457	pink	{0,0,0}	-207.6968	346.48944	915	0	0	59.420776	Shape.usd	2025-03-29 14:43:53.695381
3347	polygon_822	red	{0,0,0}	30.514694	260.8514	934	0	0	37.568592	Shape.usd	2025-03-29 14:43:53.697335
3348	cylinder_453	green	{0,0,0}	-272.66354	217.54024	934	0	0	18.43495	Shape.usd	2025-03-29 14:43:53.699231
3349	polygon_823	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:53.913489
3350	cube_458	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.534454	Shape.usd	2025-03-29 14:43:53.916324
3351	polygon_824	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	Shape.usd	2025-03-29 14:43:53.918471
3352	cylinder_454	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.43495	Shape.usd	2025-03-29 14:43:53.920355
3353	polygon_825	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:43:54.148373
3354	cube_459	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:54.152615
3355	polygon_826	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:54.154681
3356	cylinder_455	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	45	Shape.usd	2025-03-29 14:43:54.156549
3357	polygon_827	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:54.390879
3358	cube_460	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03624	Shape.usd	2025-03-29 14:43:54.394457
3359	polygon_828	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:54.396344
3360	cylinder_456	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.43495	Shape.usd	2025-03-29 14:43:54.398679
3361	polygon_829	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:54.613847
3362	cube_461	pink	{0,0,0}	-207.6968	346.48944	931.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:54.617411
3363	polygon_830	red	{0,0,0}	31.499039	259.86707	920	0	0	37.568592	Shape.usd	2025-03-29 14:43:54.61933
3364	cylinder_457	green	{0,0,0}	-272.66354	217.54024	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:54.621216
3365	polygon_831	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:54.839658
3366	cube_462	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.743565	Shape.usd	2025-03-29 14:43:54.841733
3367	polygon_832	red	{0,0,0}	32.357	258.856	924	0	0	37.234837	Shape.usd	2025-03-29 14:43:54.843579
3368	cylinder_458	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:54.845408
3369	polygon_833	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:55.061946
3370	cube_463	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.620872	Shape.usd	2025-03-29 14:43:55.066098
3371	polygon_834	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:55.068287
3372	cylinder_459	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:55.07028
3373	polygon_835	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:55.288055
3374	cube_464	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:55.290564
3375	cylinder_460	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	Shape.usd	2025-03-29 14:43:55.292466
3376	cylinder_461	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:55.294473
3377	polygon_836	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:43:55.511822
3378	cube_465	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:43:55.515869
3379	polygon_837	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:43:55.51794
3380	cylinder_462	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	Shape.usd	2025-03-29 14:43:55.520047
3381	polygon_838	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:55.747368
3382	cube_466	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	Shape.usd	2025-03-29 14:43:55.749552
3383	polygon_839	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:55.751649
3384	cylinder_463	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:43:55.753681
3385	polygon_840	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:43:56.005024
3386	cube_467	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:43:56.008893
3387	polygon_841	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:43:56.010995
3388	cylinder_464	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:43:56.013082
3389	polygon_842	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:56.230089
3390	cube_468	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.743565	Shape.usd	2025-03-29 14:43:56.232525
3391	polygon_843	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:56.234473
3392	cylinder_465	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:56.236434
3393	polygon_844	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:43:56.467047
3394	cube_469	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.620872	Shape.usd	2025-03-29 14:43:56.470448
3395	polygon_845	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:43:56.472377
3396	cylinder_466	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:56.474201
3397	polygon_846	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:43:56.699653
3398	cube_470	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03625	Shape.usd	2025-03-29 14:43:56.703728
3399	polygon_847	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:56.705935
3400	cylinder_467	green	{0,0,0}	-270.62216	216.69383	933	0	0	36.869896	Shape.usd	2025-03-29 14:43:56.708212
3401	polygon_848	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:56.937145
3402	cube_471	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03624	Shape.usd	2025-03-29 14:43:56.940717
3403	cube_472	red	{0,0,0}	31.376482	259.8365	924	0	0	37.303947	Shape.usd	2025-03-29 14:43:56.942611
3404	cylinder_468	green	{0,0,0}	-270.62216	216.69383	916.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:56.944626
3405	polygon_849	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:57.166034
3406	cube_473	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.420776	Shape.usd	2025-03-29 14:43:57.169629
3407	cube_474	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:57.171466
3408	cylinder_469	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:57.173278
3409	polygon_850	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:43:57.408988
3410	cube_475	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	Shape.usd	2025-03-29 14:43:57.412971
3411	polygon_851	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:57.415106
3412	cylinder_470	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:57.41754
3413	polygon_852	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	Shape.usd	2025-03-29 14:43:57.633592
3414	cube_476	pink	{0,0,0}	-206.88867	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:57.636674
3415	polygon_853	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:57.638643
3416	cylinder_471	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:57.640609
3417	polygon_854	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	Shape.usd	2025-03-29 14:43:57.878295
3418	cube_477	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.420776	Shape.usd	2025-03-29 14:43:57.880635
3419	polygon_855	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:57.882582
3420	cylinder_472	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	Shape.usd	2025-03-29 14:43:57.884537
3421	polygon_856	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:43:58.103136
3422	cube_478	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:43:58.105237
3423	polygon_857	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	Shape.usd	2025-03-29 14:43:58.107083
3424	cylinder_473	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	Shape.usd	2025-03-29 14:43:58.10887
3425	polygon_858	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:58.334905
3426	cube_479	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.420776	Shape.usd	2025-03-29 14:43:58.338865
3427	polygon_859	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:43:58.340957
3428	cylinder_474	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:43:58.342924
3429	polygon_860	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:58.568004
3430	cube_480	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.620872	Shape.usd	2025-03-29 14:43:58.571585
3431	polygon_861	red	{0,0,0}	32.357	258.856	923.00006	0	0	36.869896	Shape.usd	2025-03-29 14:43:58.573562
3432	cylinder_475	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:58.575424
3433	polygon_862	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:43:58.804287
3434	cube_481	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.743565	Shape.usd	2025-03-29 14:43:58.808289
3435	polygon_863	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.234837	Shape.usd	2025-03-29 14:43:58.810325
3436	cylinder_476	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	18.434948	Shape.usd	2025-03-29 14:43:58.812106
3437	polygon_864	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	Shape.usd	2025-03-29 14:43:59.046326
3438	cube_482	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.420776	Shape.usd	2025-03-29 14:43:59.048673
3439	polygon_865	red	{0,0,0}	31.375294	259.82666	929	0	0	37.303947	Shape.usd	2025-03-29 14:43:59.050812
3440	cylinder_477	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	Shape.usd	2025-03-29 14:43:59.053032
3441	polygon_866	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:43:59.290089
3442	cube_483	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:59.292608
3443	polygon_867	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:43:59.294697
3444	cylinder_478	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:43:59.296589
3445	polygon_868	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:59.521713
3446	cube_484	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	Shape.usd	2025-03-29 14:43:59.524908
3447	polygon_869	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:43:59.526923
3448	cylinder_479	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:43:59.528989
3449	polygon_870	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:43:59.753282
3450	cube_485	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.743565	Shape.usd	2025-03-29 14:43:59.757137
3451	polygon_871	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:43:59.759147
3452	cylinder_480	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	Shape.usd	2025-03-29 14:43:59.761424
3453	polygon_872	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:43:59.981178
3454	cube_486	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.03624	Shape.usd	2025-03-29 14:43:59.98483
3455	polygon_873	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:43:59.987074
3456	cylinder_481	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:43:59.98914
3457	polygon_874	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:00.206298
3458	cube_487	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:44:00.208374
3459	polygon_875	red	{0,0,0}	32.357	258.856	924	0	0	37.874985	Shape.usd	2025-03-29 14:44:00.210272
3460	cylinder_482	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:00.212112
3461	polygon_876	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:00.43608
3462	cube_488	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:00.440099
3463	polygon_877	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:00.442008
3464	cylinder_483	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:00.443843
3465	polygon_878	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:00.663274
3466	cube_489	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	Shape.usd	2025-03-29 14:44:00.66688
3467	polygon_879	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:00.669053
3468	cylinder_484	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:00.671029
3469	polygon_880	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:00.88952
3470	cube_490	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:00.891863
3471	polygon_881	red	{0,0,0}	30.395967	260.81702	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:00.893756
3472	cylinder_485	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:44:00.895654
3473	polygon_882	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:01.117131
3474	cube_491	pink	{0,0,0}	-207.6968	346.48944	922.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:01.119646
3475	polygon_883	red	{0,0,0}	30.514694	260.8514	914.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:01.121553
3476	cylinder_486	green	{0,0,0}	-272.66354	217.54024	924	0	0	33.690063	Shape.usd	2025-03-29 14:44:01.123603
3477	polygon_884	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:44:01.339136
3478	cube_492	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.03624	Shape.usd	2025-03-29 14:44:01.341984
3479	polygon_885	red	{0,0,0}	30.514694	260.8514	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:01.343945
3480	cylinder_487	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:01.345869
3481	polygon_886	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:01.571352
3482	cube_493	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:01.573432
3483	polygon_887	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:01.575591
3484	cylinder_488	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:01.577391
3485	polygon_888	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	Shape.usd	2025-03-29 14:44:01.807493
3486	cube_494	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	Shape.usd	2025-03-29 14:44:01.811104
3487	polygon_889	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:01.812996
3488	cylinder_489	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	Shape.usd	2025-03-29 14:44:01.814846
3489	polygon_890	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:02.037386
3490	cube_495	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03625	Shape.usd	2025-03-29 14:44:02.041218
3491	cube_496	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	Shape.usd	2025-03-29 14:44:02.043353
3492	cylinder_490	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:02.045259
3493	polygon_891	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:02.273931
3494	cube_497	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:44:02.277633
3495	polygon_892	red	{0,0,0}	32.357	258.856	920	0	0	37.874985	Shape.usd	2025-03-29 14:44:02.279546
3496	cylinder_491	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:02.281425
3497	polygon_893	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:02.507807
3498	cube_498	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:02.511542
3499	polygon_894	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:44:02.51373
3500	cylinder_492	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:02.515741
3501	polygon_895	black	{0,0,0}	-127.46696	518.69244	653.00006	0	0	90	Shape.usd	2025-03-29 14:44:02.735873
3502	cube_499	pink	{0,0,0}	-205.90816	345.1413	907.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:02.738041
3503	polygon_896	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:02.739947
3504	cylinder_493	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:02.741792
3505	polygon_897	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:02.956197
3506	cube_500	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:02.958956
3507	polygon_898	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:02.962445
3508	cylinder_494	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:02.96522
3509	polygon_899	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:03.183196
3510	cube_501	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:03.186822
3511	polygon_900	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:03.189121
3512	cylinder_495	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:03.191166
3513	polygon_901	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:03.420046
3514	cube_502	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:03.424095
3515	polygon_902	red	{0,0,0}	32.357	258.856	921.00006	0	0	36.869896	Shape.usd	2025-03-29 14:44:03.426299
3516	cylinder_496	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:03.428461
3517	polygon_903	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:03.657324
3518	cube_503	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.743565	Shape.usd	2025-03-29 14:44:03.66126
3519	polygon_904	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:03.663254
3520	cylinder_497	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:03.665164
3521	polygon_905	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:03.892866
3522	cube_504	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:03.896573
3523	cylinder_498	orange	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:03.898574
3524	cylinder_499	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.43495	Shape.usd	2025-03-29 14:44:03.900463
3525	polygon_906	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:04.120302
3526	cube_505	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	Shape.usd	2025-03-29 14:44:04.124311
3527	polygon_907	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:44:04.126446
3528	cylinder_500	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:04.128546
3529	polygon_908	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:04.355218
3530	cube_506	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:04.357655
3531	polygon_909	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:04.359677
3532	cylinder_501	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:04.361689
3533	polygon_910	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:04.588832
3534	cube_507	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.620872	Shape.usd	2025-03-29 14:44:04.592873
3535	polygon_911	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:04.595019
3536	cylinder_502	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:04.596918
3537	polygon_912	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:04.831048
3538	cube_508	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:44:04.834705
3539	polygon_913	red	{0,0,0}	32.357	258.856	937.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:04.836616
3540	cylinder_503	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:04.838446
3541	polygon_914	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:05.056288
3542	cube_509	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:05.060344
3543	polygon_915	red	{0,0,0}	32.357	258.856	923.00006	0	0	36.869892	Shape.usd	2025-03-29 14:44:05.062647
3544	cylinder_504	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:05.06521
3545	polygon_916	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:05.282649
3546	cube_510	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:05.285628
3547	polygon_917	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:05.287746
3548	cylinder_505	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:05.289778
3549	polygon_918	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:05.506896
3550	cube_511	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.620872	Shape.usd	2025-03-29 14:44:05.509402
3551	polygon_919	red	{0,0,0}	32.357	258.856	940.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:05.511323
3552	cylinder_506	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:05.513381
3553	polygon_920	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:44:05.727438
3554	cube_512	pink	{0,0,0}	-207.6968	346.48944	927.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:05.729938
3555	polygon_921	red	{0,0,0}	31.499039	259.86707	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:05.732114
3556	cylinder_507	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:05.734086
3557	polygon_922	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:05.961267
3558	cube_513	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:05.963879
3559	polygon_923	red	{0,0,0}	31.376482	259.8365	938	0	0	37.69424	Shape.usd	2025-03-29 14:44:05.965802
3560	cylinder_508	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:05.967652
3561	polygon_924	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:44:06.194482
3562	cube_514	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:06.198162
3563	polygon_925	red	{0,0,0}	32.357	258.856	934	0	0	37.874985	Shape.usd	2025-03-29 14:44:06.20013
3564	cylinder_509	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:06.201942
3565	polygon_926	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:06.426797
3566	cube_515	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:06.429789
3567	polygon_927	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.694237	Shape.usd	2025-03-29 14:44:06.431669
3568	cylinder_510	green	{0,0,0}	-270.62216	216.69383	915	0	0	26.56505	Shape.usd	2025-03-29 14:44:06.433635
3569	polygon_928	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:06.66172
3570	cube_516	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:06.666102
3571	polygon_929	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	Shape.usd	2025-03-29 14:44:06.668256
3572	cylinder_511	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:06.670283
3573	polygon_930	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:06.902382
3574	cube_517	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:06.906261
3575	polygon_931	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:06.908418
3576	cylinder_512	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:06.910403
3577	polygon_932	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:07.127432
3578	cube_518	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.620872	Shape.usd	2025-03-29 14:44:07.130039
3579	polygon_933	red	{0,0,0}	30.514694	260.8514	932.00006	0	0	37.694237	Shape.usd	2025-03-29 14:44:07.131978
3580	cylinder_513	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:07.133802
3581	polygon_934	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:07.356092
3582	cube_519	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:07.360236
3583	polygon_935	red	{0,0,0}	32.357	258.856	929	0	0	37.69424	Shape.usd	2025-03-29 14:44:07.362737
3584	cylinder_514	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:07.364836
3585	polygon_936	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:07.597022
3586	cube_520	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:07.60027
3587	cube_521	red	{0,0,0}	32.357	258.856	924	0	0	37.694237	Shape.usd	2025-03-29 14:44:07.602084
3588	cylinder_515	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:07.60393
3589	polygon_937	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:07.832782
3590	cube_522	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:44:07.836605
3591	polygon_938	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:44:07.838679
3592	cylinder_516	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:07.84052
3593	polygon_939	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	Shape.usd	2025-03-29 14:44:08.075822
3594	cube_523	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:08.079389
3595	polygon_940	red	{0,0,0}	30.514694	260.8514	929	0	0	37.568592	Shape.usd	2025-03-29 14:44:08.081481
3596	cylinder_517	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:08.083425
3597	polygon_941	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:08.303261
3598	cube_524	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:08.306831
3599	polygon_942	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:44:08.308868
3600	cylinder_518	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:08.310841
3601	polygon_943	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:08.523509
3602	cube_525	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:08.525815
3603	polygon_944	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	Shape.usd	2025-03-29 14:44:08.527866
3604	cylinder_519	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:08.529832
3605	polygon_945	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:08.762001
3606	cube_526	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	Shape.usd	2025-03-29 14:44:08.76559
3607	polygon_946	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:08.767389
3608	cylinder_520	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:08.76921
3609	polygon_947	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:08.990365
3610	cube_527	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:44:08.992688
3611	cube_528	red	{0,0,0}	32.357	258.856	936.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:08.99499
3612	cylinder_521	green	{0,0,0}	-270.62216	216.69383	918.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:08.997055
3613	polygon_948	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:09.229999
3614	cube_529	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:09.232363
3615	polygon_949	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	Shape.usd	2025-03-29 14:44:09.234241
3616	cylinder_522	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:09.236151
3617	polygon_950	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:44:09.458786
3618	cube_530	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:44:09.462603
3619	polygon_951	orange	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	Shape.usd	2025-03-29 14:44:09.464778
3620	cylinder_523	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	Shape.usd	2025-03-29 14:44:09.466691
3621	polygon_952	black	{0,0,0}	-127.46696	518.69244	653.00006	0	0	90	Shape.usd	2025-03-29 14:44:09.692864
3622	cube_531	pink	{0,0,0}	-205.90816	345.1413	907.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:09.696703
3623	polygon_953	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:09.698757
3624	cylinder_524	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:09.700699
3625	polygon_954	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:09.922735
3626	cube_532	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:44:09.925053
3627	polygon_955	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:09.926985
3628	cylinder_525	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.43495	Shape.usd	2025-03-29 14:44:09.929494
3629	polygon_956	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:10.146101
3630	cube_533	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:10.148768
3631	polygon_957	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.234837	Shape.usd	2025-03-29 14:44:10.150787
3632	cylinder_526	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	Shape.usd	2025-03-29 14:44:10.152585
3633	polygon_958	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:10.374125
3634	cube_534	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:10.377612
3635	polygon_959	red	{0,0,0}	31.375294	259.82666	937.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:10.379581
3636	cylinder_527	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	Shape.usd	2025-03-29 14:44:10.381479
3637	polygon_960	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:10.612302
3638	cube_535	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:44:10.616488
3639	polygon_961	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	Shape.usd	2025-03-29 14:44:10.618481
3640	cylinder_528	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:10.620392
3641	polygon_962	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:10.845805
3642	cube_536	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:10.850551
3643	polygon_963	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:10.852503
3644	cylinder_529	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:10.854355
3645	polygon_964	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:44:11.078292
3646	cube_537	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.420776	Shape.usd	2025-03-29 14:44:11.082084
3647	polygon_965	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:11.083964
3648	cylinder_530	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:11.085815
3649	polygon_966	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:11.309468
3650	cube_538	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:11.312338
3651	polygon_967	red	{0,0,0}	30.514694	260.8514	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:11.314522
3652	cylinder_531	green	{0,0,0}	-272.66354	217.54024	934	0	0	18.434948	Shape.usd	2025-03-29 14:44:11.316417
3653	polygon_968	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:44:11.54395
3654	cube_539	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.620872	Shape.usd	2025-03-29 14:44:11.5478
3655	polygon_969	red	{0,0,0}	30.514694	260.8514	929	0	0	37.568592	Shape.usd	2025-03-29 14:44:11.549764
3656	cylinder_532	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:11.551742
3657	polygon_970	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:11.780539
3658	cube_540	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.420776	Shape.usd	2025-03-29 14:44:11.784747
3659	polygon_971	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:11.786816
3660	cylinder_533	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	Shape.usd	2025-03-29 14:44:11.788693
3661	polygon_972	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:12.014217
3662	cube_541	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:44:12.017879
3663	polygon_973	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.234837	Shape.usd	2025-03-29 14:44:12.019878
3664	cylinder_534	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:12.021718
3665	polygon_974	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:12.249753
3666	cube_542	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:12.253648
3667	cube_543	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:12.255547
3668	cylinder_535	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:44:12.257394
3669	polygon_975	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:12.481005
3670	cube_544	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:12.483519
3671	polygon_976	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:12.485411
3672	cylinder_536	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:12.487192
3673	polygon_977	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:12.715227
3674	cube_545	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:12.718803
3675	polygon_978	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:44:12.720708
3676	cylinder_537	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:12.722614
3677	polygon_979	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:12.941951
3678	cube_546	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.534454	Shape.usd	2025-03-29 14:44:12.945611
3679	polygon_980	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:12.948317
3680	cylinder_538	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:12.95034
3681	polygon_981	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:13.163533
3682	cube_547	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:13.166556
3683	polygon_982	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:13.168624
3684	cylinder_539	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	Shape.usd	2025-03-29 14:44:13.17051
3685	polygon_983	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:13.401981
3686	cube_548	pink	{0,0,0}	-206.88867	345.1413	930.00006	0	0	59.620872	Shape.usd	2025-03-29 14:44:13.405544
3687	polygon_984	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:13.407376
3688	cylinder_540	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:13.409194
3689	polygon_985	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:13.633548
3690	cube_549	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.743565	Shape.usd	2025-03-29 14:44:13.637205
3691	polygon_986	red	{0,0,0}	32.357	258.856	924	0	0	37.746803	Shape.usd	2025-03-29 14:44:13.639074
3692	cylinder_541	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:44:13.640984
3693	polygon_987	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:13.867366
3694	cube_550	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.620872	Shape.usd	2025-03-29 14:44:13.869531
3695	polygon_988	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:13.871431
3696	cylinder_542	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:13.87334
3697	polygon_989	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:14.097615
3698	cube_551	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:14.101394
3699	polygon_990	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:14.103341
3700	cylinder_543	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:14.105287
3701	polygon_991	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:14.335374
3702	cube_552	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:14.337897
3703	cube_553	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:14.339888
3704	cylinder_544	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:14.341865
3705	polygon_992	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:14.561626
3706	cube_554	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:14.565767
3707	polygon_993	red	{0,0,0}	32.357	258.856	938	0	0	37.234837	Shape.usd	2025-03-29 14:44:14.567782
3708	cylinder_545	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:44:14.569724
3709	polygon_994	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:14.784454
3710	cube_555	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:14.787192
3711	cylinder_546	red	{0,0,0}	30.395967	260.81702	920	0	0	37.69424	Shape.usd	2025-03-29 14:44:14.789111
3712	cylinder_547	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:14.790994
3713	polygon_995	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:15.016362
3714	cube_556	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:15.019888
3715	polygon_996	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:15.02181
3716	cylinder_548	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:15.023686
3717	polygon_997	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:15.248949
3718	cube_557	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:15.251302
3719	polygon_998	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:15.253232
3720	cylinder_549	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:15.255052
3721	polygon_999	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:15.46579
3722	cube_558	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:15.468256
3723	polygon_1000	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:15.470208
3724	cylinder_550	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:15.472507
3725	polygon_1001	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:15.708378
3726	cube_559	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	Shape.usd	2025-03-29 14:44:15.7121
3727	polygon_1002	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:44:15.714598
3728	cylinder_551	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:15.71677
3729	polygon_1003	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:15.929281
3730	cube_560	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.03625	Shape.usd	2025-03-29 14:44:15.931657
3731	polygon_1004	red	{0,0,0}	30.395967	260.81702	934	0	0	37.874985	Shape.usd	2025-03-29 14:44:15.933708
3732	cylinder_552	green	{0,0,0}	-270.62216	216.69383	916.00006	0	0	33.690063	Shape.usd	2025-03-29 14:44:15.935662
3733	polygon_1005	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:16.151629
3734	cube_561	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:16.154479
3735	polygon_1006	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:44:16.156418
3736	cylinder_553	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:16.158279
3737	polygon_1007	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:16.377566
3738	cube_562	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:16.381266
3739	cube_563	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:16.383443
3740	cylinder_554	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	Shape.usd	2025-03-29 14:44:16.385382
3741	polygon_1008	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	Shape.usd	2025-03-29 14:44:16.600526
3742	cube_564	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:16.603035
3743	polygon_1009	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:16.604955
3744	cylinder_555	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	Shape.usd	2025-03-29 14:44:16.6068
3745	polygon_1010	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:16.836094
3746	cube_565	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:44:16.839685
3747	polygon_1011	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:16.841588
3748	cylinder_556	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:16.843475
3749	polygon_1012	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:44:17.066321
3750	cube_566	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:17.070099
3751	polygon_1013	red	{0,0,0}	31.499039	259.86707	924	0	0	37.874985	Shape.usd	2025-03-29 14:44:17.072165
3752	cylinder_557	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:17.074117
3753	polygon_1014	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:17.306214
3754	cube_567	pink	{0,0,0}	-206.88867	345.1413	913.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:17.310036
3755	polygon_1015	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:17.312056
3756	cylinder_558	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:17.313993
3757	polygon_1016	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:17.528611
3758	cube_568	pink	{0,0,0}	-207.6968	346.48944	927.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:17.531613
3759	polygon_1017	red	{0,0,0}	30.514694	260.8514	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:17.533567
3760	cylinder_559	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:17.535991
3761	polygon_1018	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:17.76083
3762	cube_569	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:17.763168
3763	polygon_1019	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:17.765115
3764	cylinder_560	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:17.767156
3765	polygon_1020	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:17.985023
3766	cube_570	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:17.987301
3767	polygon_1021	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:44:17.989312
3768	cylinder_561	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:17.991194
3769	polygon_1022	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:44:18.214316
3770	cube_571	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:18.217621
3771	polygon_1023	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:18.219727
3772	cylinder_562	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:18.221619
3773	polygon_1024	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:18.449295
3774	cube_572	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:18.451736
3775	polygon_1025	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:18.453691
3776	cylinder_563	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:18.455601
3777	polygon_1026	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:18.680109
3778	cube_573	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:18.683975
3779	polygon_1027	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:18.686065
3780	cylinder_564	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	36.869896	Shape.usd	2025-03-29 14:44:18.688147
3781	polygon_1028	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:18.911222
3782	cube_574	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:44:18.915122
3783	polygon_1029	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:18.917235
3784	cylinder_565	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:18.919384
3785	polygon_1030	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:19.150757
3786	cube_575	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	Shape.usd	2025-03-29 14:44:19.154638
3787	polygon_1031	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:19.156567
3788	cylinder_566	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:19.158397
3789	polygon_1032	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:19.378475
3790	cube_576	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:19.380963
3791	polygon_1033	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:19.38299
3792	cylinder_567	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:44:19.384856
3793	polygon_1034	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:19.600133
3794	cube_577	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	Shape.usd	2025-03-29 14:44:19.603011
3795	polygon_1035	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:19.605164
3796	cylinder_568	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:19.607077
3797	polygon_1036	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:19.830903
3798	cube_578	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:19.834254
3799	polygon_1037	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:19.836719
3800	cylinder_569	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:19.838712
3801	polygon_1038	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	Shape.usd	2025-03-29 14:44:20.067279
3802	cube_579	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	Shape.usd	2025-03-29 14:44:20.070997
3803	cube_580	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:20.072915
3804	cylinder_570	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:20.074743
3805	polygon_1039	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:20.304817
3806	cube_581	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:20.308438
3807	polygon_1040	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:20.31037
3808	cylinder_571	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:20.312307
3809	polygon_1041	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:20.528269
3810	cube_582	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:44:20.531792
3811	polygon_1042	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:44:20.533776
3812	cylinder_572	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	Shape.usd	2025-03-29 14:44:20.535759
3813	polygon_1043	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:20.752181
3814	cube_583	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:44:20.754602
3815	polygon_1044	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:44:20.756555
3816	cylinder_573	green	{0,0,0}	-270.62216	216.69383	920	0	0	45	Shape.usd	2025-03-29 14:44:20.758483
3817	polygon_1045	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:44:20.982335
3818	cube_584	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.743565	Shape.usd	2025-03-29 14:44:20.985916
3819	polygon_1046	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:44:20.988148
3820	cylinder_574	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:20.990175
3821	polygon_1047	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:21.212531
3822	cube_585	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.34933	Shape.usd	2025-03-29 14:44:21.21665
3823	polygon_1048	red	{0,0,0}	31.499039	259.86707	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:21.218672
3824	cylinder_575	green	{0,0,0}	-272.66354	217.54024	934	0	0	18.434948	Shape.usd	2025-03-29 14:44:21.220917
3825	polygon_1049	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:44:21.442623
3826	cube_586	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.743565	Shape.usd	2025-03-29 14:44:21.445307
3827	polygon_1050	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:21.447387
3828	cylinder_576	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:21.449215
3829	polygon_1051	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:21.67804
3830	cube_587	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:21.681622
3831	polygon_1052	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:44:21.683541
3832	cylinder_577	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:21.685417
3833	polygon_1053	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:21.907588
3834	cube_588	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:21.911177
3835	polygon_1054	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:21.913109
3836	cylinder_578	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:21.914924
3837	polygon_1055	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:22.139102
3838	cube_589	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	Shape.usd	2025-03-29 14:44:22.141628
3839	polygon_1056	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:22.143566
3840	cylinder_579	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:22.145479
3841	polygon_1057	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:22.370859
3842	cube_590	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:44:22.375214
3843	polygon_1058	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.184704	Shape.usd	2025-03-29 14:44:22.377344
3844	cylinder_580	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:22.379289
3845	polygon_1059	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:22.599457
3846	cube_591	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:44:22.603605
3847	polygon_1060	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:22.605975
3848	cylinder_581	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:22.608195
3849	polygon_1061	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:22.831276
3850	cube_592	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:22.833866
3851	polygon_1062	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:22.835757
3852	cylinder_582	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:22.838018
3853	polygon_1063	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:23.056478
3854	cube_593	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:44:23.059524
3855	polygon_1064	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:44:23.061548
3856	cylinder_583	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:44:23.06349
3857	polygon_1065	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:23.289971
3858	cube_594	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	Shape.usd	2025-03-29 14:44:23.293804
3859	polygon_1066	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:23.295893
3860	cylinder_584	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:23.297784
3861	polygon_1067	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:44:23.517628
3862	cube_595	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	Shape.usd	2025-03-29 14:44:23.51999
3863	polygon_1068	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:23.522137
3864	cylinder_585	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:23.52419
3865	polygon_1069	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:23.743963
3866	cube_596	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:23.746546
3867	polygon_1070	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:23.748466
3868	cylinder_586	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:23.75028
3869	polygon_1071	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:44:23.973341
3870	cube_597	pink	{0,0,0}	-205.90038	345.12823	910	0	0	59.534454	Shape.usd	2025-03-29 14:44:23.976965
3871	polygon_1072	red	{0,0,0}	31.375294	259.82666	924	0	0	37.694237	Shape.usd	2025-03-29 14:44:23.978807
3872	cylinder_587	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:23.9807
3873	polygon_1073	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:44:24.206877
3874	cube_598	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:24.210556
3875	polygon_1074	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	Shape.usd	2025-03-29 14:44:24.212485
3876	cylinder_588	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:24.214357
3877	polygon_1075	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:24.441463
3878	cube_599	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.34933	Shape.usd	2025-03-29 14:44:24.443647
3879	polygon_1076	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.694237	Shape.usd	2025-03-29 14:44:24.445687
3880	cylinder_589	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:24.447569
3881	polygon_1077	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:24.673955
3882	cube_600	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:24.676008
3883	polygon_1078	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.234837	Shape.usd	2025-03-29 14:44:24.677837
3884	cylinder_590	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:24.679712
3885	polygon_1079	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:24.896636
3886	cube_601	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:24.900974
3887	polygon_1080	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	Shape.usd	2025-03-29 14:44:24.903111
3888	cylinder_591	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:24.905133
3889	polygon_1081	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:25.129679
3890	cube_602	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:25.133555
3891	polygon_1082	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	Shape.usd	2025-03-29 14:44:25.135587
3892	cylinder_592	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:25.137525
3893	polygon_1083	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:44:25.351821
3894	cube_603	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.03625	Shape.usd	2025-03-29 14:44:25.355288
3895	polygon_1084	red	{0,0,0}	31.499039	259.86707	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:25.357515
3896	cylinder_593	green	{0,0,0}	-272.66354	217.54024	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:25.359532
3897	polygon_1085	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:25.585009
3898	cube_604	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:44:25.588593
3899	polygon_1086	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:25.590991
3900	cylinder_594	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:25.592989
3901	polygon_1087	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:25.816722
3902	cube_605	pink	{0,0,0}	-205.90816	345.1413	909.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:25.820595
3903	polygon_1088	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:44:25.822594
3904	cylinder_595	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:25.825175
3905	polygon_1089	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:26.042616
3906	cube_606	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:26.044712
3907	polygon_1090	red	{0,0,0}	30.395967	260.81702	931.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:26.046666
3908	cylinder_596	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:26.048531
3909	polygon_1091	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:26.270782
3910	cube_607	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:44:26.274923
3911	polygon_1092	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:26.277075
3912	cylinder_597	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:26.278989
3913	polygon_1093	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:26.504772
3914	cube_608	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:44:26.508976
3915	polygon_1094	red	{0,0,0}	32.357	258.856	915	0	0	37.405357	Shape.usd	2025-03-29 14:44:26.511077
3916	cylinder_598	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:26.513131
3917	polygon_1095	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:44:26.730717
3918	cube_609	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:26.733216
3919	cylinder_599	red	{0,0,0}	31.375294	259.82666	934	0	0	37.405357	Shape.usd	2025-03-29 14:44:26.735134
3920	cylinder_600	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:26.736897
3921	polygon_1096	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:26.954069
3922	cube_610	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.743565	Shape.usd	2025-03-29 14:44:26.958085
3923	polygon_1097	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:44:26.960274
3924	cylinder_601	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:26.962303
3925	polygon_1098	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:27.187765
3926	cube_611	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	Shape.usd	2025-03-29 14:44:27.191414
3927	polygon_1099	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:27.193604
3928	cylinder_602	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:27.195441
3929	polygon_1100	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:27.425203
3930	cube_612	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	Shape.usd	2025-03-29 14:44:27.429064
3931	polygon_1101	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:27.431086
3932	cylinder_603	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:27.433101
3933	polygon_1102	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:27.671542
3934	cube_613	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	Shape.usd	2025-03-29 14:44:27.673964
3935	polygon_1103	red	{0,0,0}	32.357	258.856	919	0	0	37.303947	Shape.usd	2025-03-29 14:44:27.676697
3936	cylinder_604	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:27.679662
3937	polygon_1104	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:27.892635
3938	cube_614	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:44:27.895192
3939	cube_615	red	{0,0,0}	32.357	258.856	924	0	0	37.184704	Shape.usd	2025-03-29 14:44:27.897442
3940	cylinder_605	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:27.89934
3941	polygon_1105	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:28.127561
3942	cube_616	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.620872	Shape.usd	2025-03-29 14:44:28.130985
3943	polygon_1106	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.303947	Shape.usd	2025-03-29 14:44:28.132947
3944	cylinder_606	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:28.134827
3945	polygon_1107	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:44:28.366772
3946	cube_617	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:28.370517
3947	polygon_1108	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:28.372538
3948	cylinder_607	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:28.374396
3949	polygon_1109	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:28.593741
3950	cube_618	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:28.596251
3951	polygon_1110	red	{0,0,0}	32.357	258.856	920	0	0	37.234837	Shape.usd	2025-03-29 14:44:28.598232
3952	cylinder_608	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:28.600115
3953	polygon_1111	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:28.826725
3954	cube_619	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:28.830626
3955	polygon_1112	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:28.832779
3956	cylinder_609	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:28.834701
3957	polygon_1113	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	Shape.usd	2025-03-29 14:44:29.059385
3958	cube_620	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:29.063453
3959	polygon_1114	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:29.06547
3960	cylinder_610	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:29.067339
3961	polygon_1115	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:29.293036
3962	cube_621	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:44:29.295425
3963	polygon_1116	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:29.297364
3964	cylinder_611	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:44:29.299276
3965	polygon_1117	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:29.522547
3966	cube_622	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.62088	Shape.usd	2025-03-29 14:44:29.526312
3967	polygon_1118	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:29.528308
3968	cylinder_612	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:29.530262
3969	polygon_1119	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:29.768153
3970	cube_623	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:29.771758
3971	polygon_1120	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:29.773842
3972	cylinder_613	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:29.775803
3973	polygon_1121	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:30.006421
3974	cube_624	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:30.01026
3975	polygon_1122	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.234837	Shape.usd	2025-03-29 14:44:30.012397
3976	cylinder_614	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:44:30.014401
3977	polygon_1123	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:30.247892
3978	cube_625	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:30.251119
3979	polygon_1124	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:30.253992
3980	cylinder_615	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:30.258596
3981	polygon_1125	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:30.476084
3982	cube_626	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:44:30.479733
3983	polygon_1126	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:30.481722
3984	cylinder_616	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:44:30.483654
3985	polygon_1127	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:30.710905
3986	cube_627	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:30.714568
3987	polygon_1128	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:30.716596
3988	cylinder_617	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:30.718482
3989	polygon_1129	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:30.940563
3990	cube_628	pink	{0,0,0}	-207.6968	346.48944	911.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:30.944821
3991	polygon_1130	red	{0,0,0}	30.514694	260.8514	919	0	0	37.405357	Shape.usd	2025-03-29 14:44:30.947055
3992	cylinder_618	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:30.948988
3993	polygon_1131	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:31.185118
3994	cube_629	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:31.188776
3995	polygon_1132	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:31.190613
3996	cylinder_619	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:31.192646
3997	polygon_1133	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	Shape.usd	2025-03-29 14:44:31.408204
3998	cube_630	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:31.412318
3999	polygon_1134	red	{0,0,0}	32.355774	258.8462	920	0	0	37.69424	Shape.usd	2025-03-29 14:44:31.414681
4000	cylinder_620	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	Shape.usd	2025-03-29 14:44:31.416678
4001	polygon_1135	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:31.636679
4002	cube_631	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:31.640527
4003	polygon_1136	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:44:31.642524
4004	cylinder_621	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:31.644612
4005	polygon_1137	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:31.872182
4006	cube_632	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:44:31.875758
4007	polygon_1138	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:31.877914
4008	cylinder_622	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:31.880338
4009	polygon_1139	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	Shape.usd	2025-03-29 14:44:32.093803
4010	cube_633	pink	{0,0,0}	-207.6968	346.48944	918.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:32.097193
4011	polygon_1140	red	{0,0,0}	31.499039	259.86707	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:32.099151
4012	cylinder_623	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:32.101074
4013	polygon_1141	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:32.333107
4014	cube_634	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:44:32.337246
4015	polygon_1142	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:32.339508
4016	cylinder_624	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:32.341428
4017	polygon_1143	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:32.563658
4018	cube_635	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:32.567292
4019	polygon_1144	red	{0,0,0}	32.357	258.856	936.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:32.569276
4020	cylinder_625	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:32.571096
4021	polygon_1145	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:32.794918
4022	cube_636	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.620872	Shape.usd	2025-03-29 14:44:32.798651
4023	polygon_1146	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:32.800656
4024	cylinder_626	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:32.802597
4025	polygon_1147	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:33.029941
4026	cube_637	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:33.032473
4027	polygon_1148	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:33.034416
4028	cylinder_627	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:33.036237
4029	polygon_1149	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:33.269645
4030	cube_638	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.743565	Shape.usd	2025-03-29 14:44:33.273356
4031	polygon_1150	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:44:33.275586
4032	cylinder_628	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.43495	Shape.usd	2025-03-29 14:44:33.277519
4033	polygon_1151	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:33.49506
4034	cube_639	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:33.499211
4035	polygon_1152	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:33.501299
4036	cylinder_629	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:33.503166
4037	polygon_1153	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:33.729236
4038	cube_640	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:33.732757
4039	polygon_1154	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:33.734809
4040	cylinder_630	green	{0,0,0}	-270.62216	216.69383	918.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:33.736828
4041	polygon_1155	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:44:33.971105
4042	cube_641	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	Shape.usd	2025-03-29 14:44:33.974631
4043	polygon_1156	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:33.976751
4044	cylinder_631	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:33.97865
4045	polygon_1157	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:34.19705
4046	cube_642	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:34.201137
4047	polygon_1158	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:34.203425
4048	cylinder_632	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:34.205436
4049	polygon_1159	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:34.435162
4050	cube_643	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	Shape.usd	2025-03-29 14:44:34.437664
4051	polygon_1160	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	Shape.usd	2025-03-29 14:44:34.439748
4052	cylinder_633	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:34.441691
4053	polygon_1161	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:34.663695
4054	cube_644	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:34.666307
4055	polygon_1162	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:44:34.668607
4056	cylinder_634	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	Shape.usd	2025-03-29 14:44:34.670583
4057	polygon_1163	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:34.902585
4058	cube_645	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.03624	Shape.usd	2025-03-29 14:44:34.905959
4059	polygon_1164	red	{0,0,0}	30.514694	260.8514	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:34.907888
4060	cylinder_635	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	Shape.usd	2025-03-29 14:44:34.909719
4061	polygon_1165	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:35.130751
4062	cube_646	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	Shape.usd	2025-03-29 14:44:35.134514
4063	polygon_1166	red	{0,0,0}	32.357	258.856	936.00006	0	0	37.694237	Shape.usd	2025-03-29 14:44:35.136418
4064	cylinder_636	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:35.138259
4065	polygon_1167	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:35.380488
4066	cube_647	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:35.384175
4067	polygon_1168	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:35.386061
4068	cylinder_637	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:35.387906
4069	polygon_1169	black	{0,0,0}	-127.46696	518.69244	661	0	0	0	Shape.usd	2025-03-29 14:44:35.6136
4070	cube_648	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:35.618882
4071	polygon_1170	red	{0,0,0}	32.357	258.856	933	0	0	37.69424	Shape.usd	2025-03-29 14:44:35.620789
4072	cylinder_638	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	Shape.usd	2025-03-29 14:44:35.622686
4073	polygon_1171	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:35.844812
4074	cube_649	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:35.848031
4075	polygon_1172	red	{0,0,0}	31.376482	259.8365	939.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:35.850288
4076	cylinder_639	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:35.852489
4077	polygon_1173	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:36.07815
4078	cube_650	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:36.080318
4079	polygon_1174	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:44:36.082582
4080	cylinder_640	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:36.084482
4081	polygon_1175	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:36.302339
4082	cube_651	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:36.305
4083	polygon_1176	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:44:36.306978
4084	cylinder_641	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:36.308873
4085	polygon_1177	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:44:36.53506
4086	cube_652	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:36.5384
4087	polygon_1178	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:36.540488
4088	cylinder_642	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:36.542408
4089	polygon_1179	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:36.766842
4090	cube_653	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:44:36.77046
4091	polygon_1180	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	Shape.usd	2025-03-29 14:44:36.772354
4092	cylinder_643	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:36.77425
4093	polygon_1181	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:36.997945
4094	cube_654	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:37.001479
4095	polygon_1182	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:37.003466
4096	cylinder_644	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:37.005424
4097	polygon_1183	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:44:37.233781
4098	cube_655	pink	{0,0,0}	-207.6968	346.48944	912.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:37.237632
4099	polygon_1184	red	{0,0,0}	31.499039	259.86707	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:37.239534
4100	cylinder_645	green	{0,0,0}	-272.66354	217.54024	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:37.241412
4101	polygon_1185	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:37.462973
4102	cube_656	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:37.466655
4103	polygon_1186	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:37.468582
4104	cylinder_646	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:37.47055
4105	polygon_1187	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:37.68434
4106	cube_657	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:37.687304
4107	polygon_1188	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.303947	Shape.usd	2025-03-29 14:44:37.689269
4108	cylinder_647	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:37.691159
4109	polygon_1189	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:37.912613
4110	cube_658	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.743565	Shape.usd	2025-03-29 14:44:37.917169
4111	polygon_1190	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:44:37.919597
4112	cylinder_648	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:37.921978
4113	polygon_1191	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:38.148827
4114	cube_659	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.743565	Shape.usd	2025-03-29 14:44:38.152635
4115	polygon_1192	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:38.154644
4116	cylinder_649	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:38.156622
4117	polygon_1193	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:38.383511
4118	cube_660	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:38.385808
4119	polygon_1194	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	Shape.usd	2025-03-29 14:44:38.387857
4120	cylinder_650	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:38.389718
4121	polygon_1195	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:44:38.6273
4122	cube_661	pink	{0,0,0}	-207.6968	346.48944	923.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:38.6297
4123	polygon_1196	red	{0,0,0}	30.514694	260.8514	924	0	0	37.874985	Shape.usd	2025-03-29 14:44:38.631635
4124	cylinder_651	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.434948	Shape.usd	2025-03-29 14:44:38.633693
4125	polygon_1197	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:38.852606
4126	cube_662	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:38.855706
4127	polygon_1198	red	{0,0,0}	31.376482	259.8365	939.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:38.857682
4128	cylinder_652	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:44:38.85957
4129	polygon_1199	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:39.091515
4130	cube_663	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:44:39.094161
4131	polygon_1200	red	{0,0,0}	32.357	258.856	914.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:39.096317
4132	cylinder_653	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:39.09822
4133	polygon_1201	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:39.318906
4134	cube_664	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:39.321289
4135	polygon_1202	red	{0,0,0}	32.357	258.856	936.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:39.323204
4136	cylinder_654	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	18.43495	Shape.usd	2025-03-29 14:44:39.325057
4137	polygon_1203	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:39.555111
4138	cube_665	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:39.558751
4139	polygon_1204	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:39.560726
4140	cylinder_655	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:39.562635
4141	polygon_1205	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:39.780912
4142	cube_666	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03624	Shape.usd	2025-03-29 14:44:39.785097
4143	polygon_1206	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:44:39.787286
4144	cylinder_656	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:39.789298
4145	polygon_1207	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:44:40.015916
4146	cube_667	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	Shape.usd	2025-03-29 14:44:40.018553
4147	polygon_1208	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:44:40.020725
4148	cylinder_657	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:40.022688
4149	polygon_1209	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:40.252106
4150	cube_668	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:40.255408
4151	polygon_1210	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	Shape.usd	2025-03-29 14:44:40.257281
4152	cylinder_658	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:40.25917
4153	polygon_1211	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:40.486093
4154	cube_669	pink	{0,0,0}	-205.90816	345.1413	910	0	0	59.03624	Shape.usd	2025-03-29 14:44:40.488541
4155	polygon_1212	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:40.490508
4156	cylinder_659	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.43495	Shape.usd	2025-03-29 14:44:40.492341
4157	polygon_1213	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:40.729307
4158	cube_670	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:40.732735
4159	polygon_1214	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:40.734533
4160	cylinder_660	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	Shape.usd	2025-03-29 14:44:40.736702
4161	polygon_1215	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:40.950276
4162	cube_671	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:40.954357
4163	polygon_1216	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:40.956407
4164	cylinder_661	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:40.958382
4165	polygon_1217	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:41.183401
4166	cube_672	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:41.186014
4167	polygon_1218	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:41.18803
4168	cylinder_662	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:41.189938
4169	polygon_1219	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:41.420487
4170	cube_673	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:41.424165
4171	polygon_1220	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.303947	Shape.usd	2025-03-29 14:44:41.426185
4172	cylinder_663	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	Shape.usd	2025-03-29 14:44:41.428005
4173	polygon_1221	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:41.679012
4174	cube_674	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:41.682726
4175	polygon_1222	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:41.684796
4176	cylinder_664	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:41.687008
4177	polygon_1223	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:41.904683
4178	cube_675	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:41.907423
4179	cube_676	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.303947	Shape.usd	2025-03-29 14:44:41.909446
4180	cylinder_665	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:41.911384
4181	polygon_1224	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:42.133873
4182	cube_677	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:42.13786
4183	polygon_1225	red	{0,0,0}	32.357	258.856	925.00006	0	0	36.869896	Shape.usd	2025-03-29 14:44:42.139856
4184	cylinder_666	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:44:42.141802
4185	polygon_1226	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:42.370246
4186	cube_678	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:42.372548
4187	polygon_1227	red	{0,0,0}	32.357	258.856	934	0	0	37.568592	Shape.usd	2025-03-29 14:44:42.374514
4188	cylinder_667	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:42.376489
4189	polygon_1228	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:42.603518
4190	cube_679	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:42.606144
4191	polygon_1229	red	{0,0,0}	30.395967	260.81702	929	0	0	37.874985	Shape.usd	2025-03-29 14:44:42.60813
4192	cylinder_668	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:42.610071
4193	polygon_1230	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:42.836474
4194	cube_680	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:42.838992
4195	polygon_1231	red	{0,0,0}	31.499039	259.86707	931.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:42.841224
4196	cylinder_669	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	Shape.usd	2025-03-29 14:44:42.843467
4197	polygon_1232	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:43.073319
4198	cube_681	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:43.076931
4199	polygon_1233	red	{0,0,0}	32.357	258.856	924	0	0	37.874985	Shape.usd	2025-03-29 14:44:43.078813
4200	cylinder_670	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:43.080832
4201	polygon_1234	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:43.302807
4202	cube_682	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	Shape.usd	2025-03-29 14:44:43.306401
4203	polygon_1235	red	{0,0,0}	31.376482	259.8365	919	0	0	37.694237	Shape.usd	2025-03-29 14:44:43.308465
4204	cylinder_671	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:43.310542
4205	polygon_1236	black	{0,0,0}	-128.94919	520.7185	657	0	0	0	Shape.usd	2025-03-29 14:44:43.543233
4206	cube_683	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:43.546644
4207	cylinder_672	red	{0,0,0}	30.514694	260.8514	936.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:43.548598
4208	cylinder_673	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:43.550575
4209	polygon_1237	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:44:43.763081
4210	cube_684	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:44:43.766969
4211	polygon_1238	red	{0,0,0}	32.357	258.856	927.00006	0	0	36.869896	Shape.usd	2025-03-29 14:44:43.768981
4212	cylinder_674	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:43.771183
4213	polygon_1239	black	{0,0,0}	-128.94919	520.7185	656	0	0	0	Shape.usd	2025-03-29 14:44:43.990548
4214	cube_685	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.03624	Shape.usd	2025-03-29 14:44:43.99297
4215	polygon_1240	red	{0,0,0}	31.499039	259.86707	929	0	0	37.568592	Shape.usd	2025-03-29 14:44:43.994889
4216	cylinder_675	green	{0,0,0}	-272.66354	217.54024	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:43.996821
4217	polygon_1241	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:44.221542
4218	cube_686	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:44.22555
4219	polygon_1242	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:44.227454
4220	cylinder_676	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:44.229327
4221	polygon_1243	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:44.457839
4222	cube_687	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	Shape.usd	2025-03-29 14:44:44.460231
4223	polygon_1244	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:44.462222
4224	cylinder_677	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:44.464406
4225	polygon_1245	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:44.688872
4226	cube_688	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:44.692926
4227	polygon_1246	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:44.695002
4228	cylinder_678	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:44.696923
4229	polygon_1247	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:44.926751
4230	cube_689	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:44:44.930796
4231	polygon_1248	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:44.932984
4232	cylinder_679	green	{0,0,0}	-270.62216	216.69383	938	0	0	33.690063	Shape.usd	2025-03-29 14:44:44.934942
4233	polygon_1249	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:44:45.158582
4234	cube_690	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:45.160729
4235	polygon_1250	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:45.162583
4236	cylinder_680	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:45.164526
4237	polygon_1251	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:45.392315
4238	cube_691	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:45.394697
4239	polygon_1252	red	{0,0,0}	32.357	258.856	934	0	0	37.568592	Shape.usd	2025-03-29 14:44:45.396606
4240	cylinder_681	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:44:45.398581
4241	polygon_1253	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:45.614144
4242	cube_692	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.420776	Shape.usd	2025-03-29 14:44:45.618141
4243	polygon_1254	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:45.620423
4244	cylinder_682	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:45.62295
4245	polygon_1255	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:45.852241
4246	cube_693	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:44:45.856151
4247	polygon_1256	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:45.858184
4248	cylinder_683	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:45.860157
4249	polygon_1257	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:46.089856
4250	cube_694	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:46.092257
4251	polygon_1258	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.303947	Shape.usd	2025-03-29 14:44:46.094488
4252	cylinder_684	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:46.096962
4253	polygon_1259	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:46.312051
4254	cube_695	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:46.314415
4255	polygon_1260	red	{0,0,0}	32.357	258.856	919	0	0	37.69424	Shape.usd	2025-03-29 14:44:46.316459
4256	cylinder_685	green	{0,0,0}	-270.62216	216.69383	917.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:46.318344
4257	polygon_1261	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:46.53824
4258	cube_696	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03624	Shape.usd	2025-03-29 14:44:46.54355
4259	polygon_1262	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.77568	Shape.usd	2025-03-29 14:44:46.545871
4260	cylinder_686	green	{0,0,0}	-270.62216	216.69383	933	0	0	18.434948	Shape.usd	2025-03-29 14:44:46.547752
4261	polygon_1263	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:46.770432
4262	cube_697	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:46.773648
4263	polygon_1264	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	Shape.usd	2025-03-29 14:44:46.775812
4264	cylinder_687	green	{0,0,0}	-270.62216	216.69383	924	0	0	21.801407	Shape.usd	2025-03-29 14:44:46.777789
4265	polygon_1265	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:46.990176
4266	cube_698	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:46.993014
4267	polygon_1266	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:46.995009
4268	cylinder_688	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:46.996854
4269	polygon_1267	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	Shape.usd	2025-03-29 14:44:47.217515
4270	cube_699	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.743565	Shape.usd	2025-03-29 14:44:47.221093
4271	cube_700	red	{0,0,0}	32.357	258.856	920	0	0	37.874985	Shape.usd	2025-03-29 14:44:47.223312
4272	cylinder_689	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:47.225675
4273	polygon_1268	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:47.443336
4274	cube_701	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:44:47.446232
4275	polygon_1269	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:47.448362
4276	cylinder_690	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:47.450236
4277	polygon_1270	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:47.676875
4278	cube_702	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:44:47.68068
4279	polygon_1271	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:47.682692
4280	cylinder_691	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:47.684713
4281	polygon_1272	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:47.906971
4282	cube_703	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	Shape.usd	2025-03-29 14:44:47.910566
4283	polygon_1273	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:47.912518
4284	cylinder_692	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:47.914417
4285	polygon_1274	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:48.143073
4286	cube_704	pink	{0,0,0}	-207.6968	346.48944	930.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:48.1468
4287	polygon_1275	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:48.148721
4288	cylinder_693	green	{0,0,0}	-272.66354	217.54024	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:48.150663
4289	polygon_1276	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:48.379757
4290	cube_705	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.620872	Shape.usd	2025-03-29 14:44:48.383691
4291	polygon_1277	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:44:48.385949
4292	cylinder_694	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:48.387814
4293	polygon_1278	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:48.611595
4294	cube_706	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:48.615331
4295	polygon_1279	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	Shape.usd	2025-03-29 14:44:48.617322
4296	cylinder_695	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:44:48.619207
4297	polygon_1280	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:48.840369
4298	cube_707	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.34933	Shape.usd	2025-03-29 14:44:48.844381
4299	polygon_1281	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	Shape.usd	2025-03-29 14:44:48.846587
4300	cylinder_696	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:48.84851
4301	polygon_1282	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:49.079571
4302	cube_708	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.743565	Shape.usd	2025-03-29 14:44:49.083335
4303	polygon_1283	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.234837	Shape.usd	2025-03-29 14:44:49.085288
4304	cylinder_697	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:49.087158
4305	polygon_1284	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:49.316739
4306	cube_709	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.34933	Shape.usd	2025-03-29 14:44:49.318944
4307	polygon_1285	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:49.320953
4308	cylinder_698	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:49.322884
4309	polygon_1286	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	Shape.usd	2025-03-29 14:44:49.543559
4310	cube_710	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:49.545855
4311	polygon_1287	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:49.547974
4312	cylinder_699	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:49.550329
4313	polygon_1288	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	Shape.usd	2025-03-29 14:44:49.780318
4314	cube_711	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:49.784167
4315	polygon_1289	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	Shape.usd	2025-03-29 14:44:49.78613
4316	cylinder_700	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	Shape.usd	2025-03-29 14:44:49.788051
4317	polygon_1290	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:50.012323
4318	cube_712	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:44:50.016028
4319	polygon_1291	red	{0,0,0}	31.376482	259.8365	933	0	0	37.69424	Shape.usd	2025-03-29 14:44:50.017965
4320	cylinder_701	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:50.019786
4321	polygon_1292	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:50.244356
4322	cube_713	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:44:50.247723
4323	polygon_1293	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.303947	Shape.usd	2025-03-29 14:44:50.24971
4324	cylinder_702	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:50.251587
4325	polygon_1294	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:50.472706
4326	cube_714	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.620872	Shape.usd	2025-03-29 14:44:50.476309
4327	cylinder_703	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:50.478505
4328	cylinder_704	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:50.480471
4329	polygon_1295	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:50.708147
4330	cube_715	pink	{0,0,0}	-207.6968	346.48944	909.00006	0	0	59.743565	Shape.usd	2025-03-29 14:44:50.710619
4331	polygon_1296	red	{0,0,0}	30.514694	260.8514	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:50.713162
4332	cylinder_705	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	Shape.usd	2025-03-29 14:44:50.715212
4333	polygon_1297	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:50.944718
4334	cube_716	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:50.948442
4335	polygon_1298	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.874985	Shape.usd	2025-03-29 14:44:50.95044
4336	cylinder_706	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:50.952326
4337	polygon_1299	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:51.172344
4338	cube_717	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	Shape.usd	2025-03-29 14:44:51.175062
4339	polygon_1300	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	Shape.usd	2025-03-29 14:44:51.177316
4340	cylinder_707	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:51.179466
4341	polygon_1301	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:51.397047
4342	cube_718	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:51.39953
4343	polygon_1302	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:51.4015
4344	cylinder_708	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:51.403413
4345	polygon_1303	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:51.633244
4346	cube_719	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	Shape.usd	2025-03-29 14:44:51.637049
4347	polygon_1304	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:51.63904
4348	cylinder_709	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:51.640933
4349	polygon_1305	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:51.858356
4350	cube_720	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:51.861871
4351	polygon_1306	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:51.864042
4352	cylinder_710	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:51.865982
4353	polygon_1307	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:52.100258
4354	cube_721	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:52.102559
4355	cube_722	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:52.10447
4356	cylinder_711	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:52.106332
4357	polygon_1308	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	Shape.usd	2025-03-29 14:44:52.325131
4358	cube_723	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:52.329001
4359	polygon_1309	red	{0,0,0}	30.514694	260.8514	923.00006	0	0	37.184704	Shape.usd	2025-03-29 14:44:52.331315
4360	cylinder_712	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:52.333374
4361	polygon_1310	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:52.562099
4362	cube_724	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.743565	Shape.usd	2025-03-29 14:44:52.566111
4363	polygon_1311	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	Shape.usd	2025-03-29 14:44:52.568144
4364	cylinder_713	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:52.570132
4365	polygon_1312	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:52.795549
4366	cube_725	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:52.799483
4367	polygon_1313	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:44:52.801435
4368	cylinder_714	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:52.80324
4369	polygon_1314	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:53.034424
4370	cube_726	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:53.038137
4371	cube_727	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:53.040108
4372	cylinder_715	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:53.041964
4373	polygon_1315	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:53.261448
4374	cube_728	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:53.265461
4375	polygon_1316	red	{0,0,0}	32.357	258.856	929	0	0	37.184704	Shape.usd	2025-03-29 14:44:53.267522
4376	cylinder_716	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	Shape.usd	2025-03-29 14:44:53.269486
4377	polygon_1317	black	{0,0,0}	-128.94919	520.7185	661	0	0	90	Shape.usd	2025-03-29 14:44:53.500078
4378	cube_729	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:53.502373
4379	polygon_1318	red	{0,0,0}	30.514694	260.8514	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:53.504445
4380	cylinder_717	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:53.506372
4381	polygon_1319	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:53.720113
4382	cube_730	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:44:53.722917
4383	polygon_1320	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:44:53.724851
4384	cylinder_718	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.43495	Shape.usd	2025-03-29 14:44:53.726769
4385	polygon_1321	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:53.95138
4386	cube_731	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:53.95531
4387	polygon_1322	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:53.957884
4388	cylinder_719	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:53.959986
4389	polygon_1323	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:54.215225
4390	cube_732	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	Shape.usd	2025-03-29 14:44:54.218589
4391	polygon_1324	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.694237	Shape.usd	2025-03-29 14:44:54.220496
4392	cylinder_720	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:54.222357
4393	polygon_1325	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:44:54.452986
4394	cube_733	pink	{0,0,0}	-207.6968	346.48944	915	0	0	59.03625	Shape.usd	2025-03-29 14:44:54.456823
4395	polygon_1326	red	{0,0,0}	31.499039	259.86707	934	0	0	37.405357	Shape.usd	2025-03-29 14:44:54.459443
4396	cylinder_721	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:54.462129
4397	polygon_1327	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:44:54.6807
4398	cube_734	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	Shape.usd	2025-03-29 14:44:54.683437
4399	polygon_1328	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	Shape.usd	2025-03-29 14:44:54.68529
4400	cylinder_722	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:54.6871
4401	polygon_1329	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:54.914614
4402	cube_735	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:44:54.917128
4403	polygon_1330	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:54.919064
4404	cylinder_723	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:54.920909
4405	polygon_1331	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:55.154084
4406	cube_736	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:55.156245
4407	polygon_1332	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.303947	Shape.usd	2025-03-29 14:44:55.158159
4408	cylinder_724	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:55.160113
4409	polygon_1333	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:55.379381
4410	cube_737	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:55.38311
4411	polygon_1334	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:55.385045
4412	cylinder_725	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:55.38699
4413	polygon_1335	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:55.617786
4414	cube_738	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:44:55.62143
4415	polygon_1336	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	Shape.usd	2025-03-29 14:44:55.623386
4416	cylinder_726	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:55.625318
4417	polygon_1337	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	Shape.usd	2025-03-29 14:44:55.848366
4418	cube_739	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	Shape.usd	2025-03-29 14:44:55.851922
4419	polygon_1338	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:55.853937
4420	cylinder_727	green	{0,0,0}	-270.6119	216.68562	941.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:55.855903
4421	polygon_1339	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	Shape.usd	2025-03-29 14:44:56.084584
4422	cube_740	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.420776	Shape.usd	2025-03-29 14:44:56.088456
4423	polygon_1340	red	{0,0,0}	31.499039	259.86707	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:56.090367
4424	cylinder_728	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:56.092339
4425	polygon_1341	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:56.319318
4426	cube_741	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03624	Shape.usd	2025-03-29 14:44:56.321451
4427	polygon_1342	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	Shape.usd	2025-03-29 14:44:56.323373
4428	cylinder_729	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	18.434948	Shape.usd	2025-03-29 14:44:56.325367
4429	polygon_1343	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:56.547445
4430	cube_742	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:44:56.550743
4431	polygon_1344	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:56.55267
4432	cylinder_730	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:56.554502
4433	polygon_1345	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:56.805196
4434	cube_743	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:56.809257
4435	polygon_1346	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:56.811243
4436	cylinder_731	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:44:56.813295
4437	polygon_1347	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:57.031512
4438	cube_744	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:57.034676
4439	polygon_1348	red	{0,0,0}	32.357	258.856	929	0	0	37.874985	Shape.usd	2025-03-29 14:44:57.036643
4440	cylinder_732	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:57.038562
4441	polygon_1349	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:44:57.264386
4442	cube_745	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.534454	Shape.usd	2025-03-29 14:44:57.26831
4443	polygon_1350	red	{0,0,0}	31.499039	259.86707	920	0	0	37.405357	Shape.usd	2025-03-29 14:44:57.270343
4444	cylinder_733	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:57.272201
4445	polygon_1351	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:57.498795
4446	cube_746	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.34933	Shape.usd	2025-03-29 14:44:57.501059
4447	polygon_1352	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:44:57.503076
4448	cylinder_734	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:57.50504
4449	polygon_1353	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:44:57.734783
4450	cube_747	pink	{0,0,0}	-207.6968	346.48944	922.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:57.738293
4451	cylinder_735	orange	{0,0,0}	30.514694	260.8514	932.00006	0	0	37.234837	Shape.usd	2025-03-29 14:44:57.741049
4452	cylinder_736	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	Shape.usd	2025-03-29 14:44:57.743291
4453	polygon_1354	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:57.965168
4454	cube_748	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:44:57.968915
4455	polygon_1355	red	{0,0,0}	30.395967	260.81702	924	0	0	37.405357	Shape.usd	2025-03-29 14:44:57.970889
4456	cylinder_737	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:57.972706
4457	polygon_1356	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:58.202023
4458	cube_749	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	Shape.usd	2025-03-29 14:44:58.205708
4459	polygon_1357	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	Shape.usd	2025-03-29 14:44:58.20771
4460	cylinder_738	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:58.209706
4461	polygon_1358	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:58.424117
4462	cube_750	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:58.428603
4463	polygon_1359	red	{0,0,0}	30.395967	260.81702	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:58.43075
4464	cylinder_739	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:58.433387
4465	polygon_1360	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:58.650901
4466	cube_751	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:44:58.653765
4467	polygon_1361	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.303947	Shape.usd	2025-03-29 14:44:58.655723
4468	cylinder_740	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:44:58.657691
4469	polygon_1362	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:58.881978
4470	cube_752	pink	{0,0,0}	-207.6968	346.48944	907.00006	0	0	59.620872	Shape.usd	2025-03-29 14:44:58.885963
4471	polygon_1363	orange	{0,0,0}	30.514694	260.8514	924	0	0	37.69424	Shape.usd	2025-03-29 14:44:58.888098
4472	cylinder_741	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:58.890051
4473	polygon_1364	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:44:59.126357
4474	cube_753	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.34933	Shape.usd	2025-03-29 14:44:59.128591
4475	polygon_1365	red	{0,0,0}	32.357	258.856	935.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:59.130563
4476	cylinder_742	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:59.132844
4477	polygon_1366	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:59.356558
4478	cube_754	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:59.359181
4479	polygon_1367	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	Shape.usd	2025-03-29 14:44:59.361261
4480	cylinder_743	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:59.363194
4481	polygon_1368	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:44:59.588626
4482	cube_755	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	Shape.usd	2025-03-29 14:44:59.592555
4483	polygon_1369	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:44:59.594609
4484	cylinder_744	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	Shape.usd	2025-03-29 14:44:59.596892
4485	polygon_1370	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:44:59.817152
4486	cube_756	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.03624	Shape.usd	2025-03-29 14:44:59.821065
4487	polygon_1371	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:44:59.823074
4488	cylinder_745	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:44:59.82492
4489	polygon_1372	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:00.055194
4490	cube_757	pink	{0,0,0}	-205.90816	345.1413	939.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:00.057486
4491	polygon_1373	red	{0,0,0}	32.357	258.856	919	0	0	37.69424	Shape.usd	2025-03-29 14:45:00.059453
4492	cylinder_746	green	{0,0,0}	-270.62216	216.69383	916.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:00.06129
4493	polygon_1374	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:00.282127
4494	cube_758	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.620872	Shape.usd	2025-03-29 14:45:00.284697
4495	polygon_1375	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.303947	Shape.usd	2025-03-29 14:45:00.286704
4496	cylinder_747	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:45:00.288777
4497	polygon_1376	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:00.504912
4498	cube_759	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:45:00.50779
4499	polygon_1377	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:00.5097
4500	cylinder_748	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:00.511978
4501	polygon_1378	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:00.738171
4502	cube_760	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:00.741738
4503	polygon_1379	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:00.743713
4504	cylinder_749	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:00.745609
4505	polygon_1380	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:00.964406
4506	cube_761	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:00.968319
4507	polygon_1381	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:45:00.97056
4508	cylinder_750	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:45:00.972532
4509	polygon_1382	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:01.187302
4510	cube_762	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.534454	Shape.usd	2025-03-29 14:45:01.190144
4511	polygon_1383	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:01.192065
4512	cylinder_751	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	21.801407	Shape.usd	2025-03-29 14:45:01.193982
4513	polygon_1384	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:45:01.415011
4514	cube_763	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.743565	Shape.usd	2025-03-29 14:45:01.419073
4515	polygon_1385	red	{0,0,0}	30.514694	260.8514	927.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:01.421459
4516	cylinder_752	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:01.423381
4517	polygon_1386	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:01.638793
4518	cube_764	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:45:01.641243
4519	polygon_1387	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:01.644503
4520	cylinder_753	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:01.647613
4521	polygon_1388	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:01.872617
4522	cube_765	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:45:01.87655
4523	polygon_1389	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:01.878562
4524	cylinder_754	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:45:01.880534
4525	polygon_1390	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:02.112872
4526	cube_766	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:45:02.115109
4527	polygon_1391	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	Shape.usd	2025-03-29 14:45:02.117071
4528	cylinder_755	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:02.119182
4529	polygon_1392	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:02.338585
4530	cube_767	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:02.342315
4531	polygon_1393	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	Shape.usd	2025-03-29 14:45:02.344364
4532	cylinder_756	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:02.346278
4533	polygon_1394	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:02.573694
4534	cube_768	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.420776	Shape.usd	2025-03-29 14:45:02.577688
4535	polygon_1395	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:02.579612
4536	cylinder_757	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:02.581559
4537	polygon_1396	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:02.806094
4538	cube_769	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:02.808731
4539	polygon_1397	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.234837	Shape.usd	2025-03-29 14:45:02.810739
4540	cylinder_758	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:02.812609
4541	polygon_1398	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:03.039355
4542	cube_770	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:45:03.041928
4543	polygon_1399	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	Shape.usd	2025-03-29 14:45:03.043878
4544	cylinder_759	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:03.045869
4545	polygon_1400	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:03.26961
4546	cube_771	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	Shape.usd	2025-03-29 14:45:03.27215
4547	polygon_1401	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:03.274128
4548	cylinder_760	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:03.276027
4549	polygon_1402	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:03.502579
4550	cube_772	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:03.505019
4551	polygon_1403	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:03.507011
4552	cylinder_761	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:03.508885
4553	polygon_1404	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:03.714769
4554	cube_773	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:03.717267
4555	polygon_1405	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	Shape.usd	2025-03-29 14:45:03.719221
4556	cylinder_762	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:45:03.72122
4557	polygon_1406	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:03.928381
4558	cube_774	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.34933	Shape.usd	2025-03-29 14:45:03.930853
4559	cylinder_763	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:03.932902
4560	cylinder_764	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:03.934932
4561	polygon_1407	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:45:04.141064
4562	cube_775	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:04.143833
4563	polygon_1408	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	Shape.usd	2025-03-29 14:45:04.145829
4564	cylinder_765	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:04.147571
4565	polygon_1409	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:04.35707
4566	cube_776	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.420776	Shape.usd	2025-03-29 14:45:04.359514
4567	polygon_1410	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:04.361529
4568	cylinder_766	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:04.363545
4569	polygon_1411	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:45:04.577226
4570	cube_777	pink	{0,0,0}	-206.88867	345.1413	927.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:04.579508
4571	polygon_1412	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:04.581414
4572	cylinder_767	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:04.583214
4573	polygon_1413	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	Shape.usd	2025-03-29 14:45:04.791022
4574	cube_778	pink	{0,0,0}	-208.68114	346.48944	924	0	0	59.03624	Shape.usd	2025-03-29 14:45:04.79373
4575	cylinder_768	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:04.795725
4576	cylinder_769	green	{0,0,0}	-272.66354	217.54024	934	0	0	33.690063	Shape.usd	2025-03-29 14:45:04.797828
4577	polygon_1414	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	Shape.usd	2025-03-29 14:45:05.006249
4578	cube_779	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:45:05.009095
4579	polygon_1415	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:05.01143
4580	cylinder_770	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:05.013385
4581	polygon_1416	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:05.221978
4582	cube_780	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:45:05.224824
4583	polygon_1417	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:05.226871
4584	cylinder_771	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:05.228779
4585	polygon_1418	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:45:05.43996
4586	cube_781	pink	{0,0,0}	-206.88867	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:05.444502
4587	polygon_1419	red	{0,0,0}	31.376482	259.8365	934	0	0	37.874985	Shape.usd	2025-03-29 14:45:05.446503
4588	cylinder_772	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:05.448433
4589	polygon_1420	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	Shape.usd	2025-03-29 14:45:05.861039
4590	cube_782	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:05.864923
4591	polygon_1421	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:05.866875
4592	cylinder_773	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	16.699244	Shape.usd	2025-03-29 14:45:05.868814
4593	polygon_1422	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:45:06.292945
4594	cube_783	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.743565	Shape.usd	2025-03-29 14:45:06.295187
4595	polygon_1423	red	{0,0,0}	31.376482	259.8365	920	0	0	37.874985	Shape.usd	2025-03-29 14:45:06.297111
4596	cylinder_774	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:06.299151
4597	polygon_1424	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:45:06.504954
4598	cube_784	pink	{0,0,0}	-206.88867	345.1413	915	0	0	59.743565	Shape.usd	2025-03-29 14:45:06.507635
4599	polygon_1425	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:45:06.509636
4600	cylinder_775	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:45:06.511476
4601	polygon_1426	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:45:06.722828
4602	cube_785	pink	{0,0,0}	-206.88867	345.1413	928.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:06.72606
4603	polygon_1427	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.694237	Shape.usd	2025-03-29 14:45:06.72795
4604	cylinder_776	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:06.729936
4605	polygon_1428	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:07.146337
4606	cube_786	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:07.148672
4607	polygon_1429	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	Shape.usd	2025-03-29 14:45:07.150618
4608	cylinder_777	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	45	Shape.usd	2025-03-29 14:45:07.152563
4609	polygon_1430	black	{0,0,0}	-127.46985	517.7237	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:07.360295
4610	cube_787	pink	{0,0,0}	-206.89337	344.1686	920	0	0	59.03624	Shape.usd	2025-03-29 14:45:07.362925
4611	polygon_1431	red	{0,0,0}	31.377193	258.86185	924	0	0	37.568592	Shape.usd	2025-03-29 14:45:07.364967
4612	cylinder_778	green	{0,0,0}	-270.6283	215.71822	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:07.367106
4613	polygon_1432	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:07.570196
4614	cube_788	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	Shape.usd	2025-03-29 14:45:07.572501
4615	polygon_1433	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:07.574546
4616	cylinder_779	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:07.576548
4617	polygon_1434	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:07.778669
4618	cube_789	pink	{0,0,0}	-206.88867	345.1413	933	0	0	59.03624	Shape.usd	2025-03-29 14:45:07.780998
4619	cube_790	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:07.782945
4620	cylinder_780	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.43495	Shape.usd	2025-03-29 14:45:07.784818
4621	polygon_1435	black	{0,0,0}	-128.94919	520.7185	656	0	0	0	Shape.usd	2025-03-29 14:45:07.996169
4622	cube_791	pink	{0,0,0}	-207.6968	346.48944	931.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:07.998866
4623	cube_792	red	{0,0,0}	30.514694	260.8514	924	0	0	37.874985	Shape.usd	2025-03-29 14:45:08.000885
4624	cylinder_781	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:08.002812
4625	polygon_1436	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:08.215181
4626	polygon_1437	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:08.218817
4627	polygon_1438	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:08.220839
4628	cylinder_782	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:08.222756
4629	polygon_1439	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:08.422987
4630	cube_793	pink	{0,0,0}	-206.88867	345.1413	931.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:08.425497
4631	polygon_1440	red	{0,0,0}	32.357	258.856	919	0	0	37.34935	Shape.usd	2025-03-29 14:45:08.427499
4632	cylinder_783	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:08.429448
4633	polygon_1441	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:08.63407
4634	cube_794	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.743565	Shape.usd	2025-03-29 14:45:08.636805
4635	polygon_1442	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:08.638973
4636	cylinder_784	green	{0,0,0}	-270.62216	216.69383	929	0	0	15.945395	Shape.usd	2025-03-29 14:45:08.640972
4637	polygon_1443	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:08.85233
4638	cube_795	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:08.855562
4639	polygon_1444	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	Shape.usd	2025-03-29 14:45:08.857828
4640	cylinder_785	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.43495	Shape.usd	2025-03-29 14:45:08.859994
4641	polygon_1445	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:09.062145
4642	polygon_1446	pink	{0,0,0}	-206.88867	345.1413	914.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:09.064619
4643	polygon_1447	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:09.066618
4644	cylinder_786	green	{0,0,0}	-271.60266	216.69383	929	0	0	36.869896	Shape.usd	2025-03-29 14:45:09.068509
4645	polygon_1448	black	{0,0,0}	-127.46985	517.7237	657	0	0	90	Shape.usd	2025-03-29 14:45:09.278643
4646	cube_796	pink	{0,0,0}	-206.89337	344.1686	925.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:09.281151
4647	cube_797	red	{0,0,0}	32.35773	257.88132	925.00006	0	0	36.869896	Shape.usd	2025-03-29 14:45:09.283097
4648	cylinder_787	green	{0,0,0}	-270.6283	215.71822	935.00006	0	0	15.945395	Shape.usd	2025-03-29 14:45:09.285158
4649	polygon_1449	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:09.494116
4650	cube_798	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.34933	Shape.usd	2025-03-29 14:45:09.49738
4651	polygon_1450	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:09.499439
4652	cylinder_788	green	{0,0,0}	-270.62216	216.69383	934	0	0	36.8699	Shape.usd	2025-03-29 14:45:09.501265
4653	polygon_1451	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:45:09.712888
4654	cube_799	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	61.18921	Shape.usd	2025-03-29 14:45:09.715618
4655	polygon_1452	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	Shape.usd	2025-03-29 14:45:09.71761
4656	cylinder_789	green	{0,0,0}	-270.6119	216.68562	933	0	0	14.036244	Shape.usd	2025-03-29 14:45:09.719494
4657	polygon_1453	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:09.929276
4658	cube_800	pink	{0,0,0}	-206.88867	345.1413	920	0	0	60.255116	Shape.usd	2025-03-29 14:45:09.932084
4659	polygon_1454	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	Shape.usd	2025-03-29 14:45:09.934169
4660	cylinder_790	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	33.690063	Shape.usd	2025-03-29 14:45:09.936081
4661	polygon_1455	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:10.15331
4662	polygon_1456	pink	{0,0,0}	-208.68114	346.48944	935.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:10.157276
4663	polygon_1457	red	{0,0,0}	31.499039	259.86707	917.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:10.159529
4664	cylinder_791	green	{0,0,0}	-273.6479	217.54024	930.00006	0	0	45	Shape.usd	2025-03-29 14:45:10.161541
4665	polygon_1458	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:10.362723
4666	cylinder_792	pink	{0,0,0}	-206.88867	346.12183	927.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:10.365702
4667	polygon_1459	red	{0,0,0}	32.357	258.856	920	0	0	36.869892	Shape.usd	2025-03-29 14:45:10.367677
4668	cylinder_793	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:10.369497
4669	polygon_1460	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:10.586262
4670	cube_801	pink	{0,0,0}	-207.86919	346.12183	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:10.589823
4671	polygon_1461	red	{0,0,0}	32.357	258.856	929	0	0	37.69424	Shape.usd	2025-03-29 14:45:10.591862
4672	cylinder_794	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	18.43495	Shape.usd	2025-03-29 14:45:10.593948
4673	polygon_1462	black	{0,0,0}	-127.46985	517.7237	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:10.798703
4674	cylinder_795	pink	{0,0,0}	-207.87392	345.14914	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:10.801284
4675	polygon_1463	red	{0,0,0}	32.35773	257.88132	920	0	0	37.746803	Shape.usd	2025-03-29 14:45:10.80387
4676	cylinder_796	green	{0,0,0}	-270.6283	215.71822	940.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:10.806205
4677	polygon_1464	black	{0,0,0}	-128.94919	520.7185	654.00006	0	0	90	Shape.usd	2025-03-29 14:45:11.015409
4678	cube_802	pink	{0,0,0}	-209.66548	347.4738	918.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:11.017918
4679	polygon_1465	red	{0,0,0}	31.499039	259.86707	915	0	0	37.405357	Shape.usd	2025-03-29 14:45:11.01986
4680	cylinder_797	green	{0,0,0}	-272.66354	217.54024	920	0	0	18.43495	Shape.usd	2025-03-29 14:45:11.021785
4681	polygon_1466	black	{0,0,0}	-128.94919	520.7185	653.00006	0	0	0	Shape.usd	2025-03-29 14:45:11.23791
4682	cylinder_798	pink	{0,0,0}	-210.64983	347.4738	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:11.24078
4683	polygon_1467	red	{0,0,0}	31.499039	259.86707	920	0	0	37.69424	Shape.usd	2025-03-29 14:45:11.242797
4684	cylinder_799	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.43495	Shape.usd	2025-03-29 14:45:11.244905
4685	polygon_1468	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	Shape.usd	2025-03-29 14:45:11.452671
4686	polygon_1469	pink	{0,0,0}	-209.66548	348.45813	926.00006	0	0	59.743565	Shape.usd	2025-03-29 14:45:11.455007
4687	polygon_1470	red	{0,0,0}	31.499039	259.86707	920	0	0	37.568592	Shape.usd	2025-03-29 14:45:11.457001
4688	cylinder_800	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	45	Shape.usd	2025-03-29 14:45:11.458911
4689	polygon_1471	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:12.522734
4690	cube_803	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:12.525114
4691	polygon_1472	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:12.527174
4692	cylinder_801	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.43495	Shape.usd	2025-03-29 14:45:12.529275
4693	polygon_1473	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:12.744329
4694	cube_804	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:12.747172
4695	cylinder_802	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:12.74906
4696	cylinder_803	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:12.750894
4697	polygon_1474	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	Shape.usd	2025-03-29 14:45:12.97491
4698	cube_805	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.743565	Shape.usd	2025-03-29 14:45:12.97885
4699	polygon_1475	red	{0,0,0}	29.53035	261.83575	929	0	0	37.568592	Shape.usd	2025-03-29 14:45:12.980901
4700	cylinder_804	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:12.982786
4701	polygon_1476	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:13.210687
4702	cube_806	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:13.214814
4703	polygon_1477	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:45:13.21723
4704	cylinder_805	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:13.21909
4705	polygon_1478	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:13.446055
4706	cube_807	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:13.449609
4707	polygon_1479	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:13.451528
4708	cylinder_806	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	Shape.usd	2025-03-29 14:45:13.453442
4709	polygon_1480	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:13.677121
4710	cube_808	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:13.681
4711	polygon_1481	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	Shape.usd	2025-03-29 14:45:13.682984
4712	cylinder_807	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:13.684865
4713	polygon_1482	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:13.907319
4714	cube_809	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	Shape.usd	2025-03-29 14:45:13.911087
4715	polygon_1483	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:13.913191
4716	cylinder_808	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:13.91508
4717	polygon_1484	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:14.128158
4718	cube_810	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:45:14.131564
4719	polygon_1485	orange	{0,0,0}	31.376482	259.8365	924	0	0	37.694237	Shape.usd	2025-03-29 14:45:14.133621
4720	cylinder_809	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:14.135531
4721	polygon_1486	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:14.365865
4722	cube_811	pink	{0,0,0}	-205.90816	345.1413	937.00006	0	0	59.743565	Shape.usd	2025-03-29 14:45:14.369523
4723	polygon_1487	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:14.371616
4724	cylinder_810	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:14.373506
4725	polygon_1488	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:14.593389
4726	cube_812	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:14.597022
4727	polygon_1489	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:14.599183
4728	cylinder_811	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:14.601288
4729	polygon_1490	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	Shape.usd	2025-03-29 14:45:14.828755
4730	cube_813	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:14.83278
4731	polygon_1491	red	{0,0,0}	31.376482	259.8365	924	0	0	37.694237	Shape.usd	2025-03-29 14:45:14.835014
4732	cylinder_812	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:14.837231
4733	polygon_1492	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:15.059524
4734	cube_814	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	Shape.usd	2025-03-29 14:45:15.06349
4735	polygon_1493	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:15.065681
4736	cylinder_813	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:15.067643
4737	polygon_1494	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:45:15.29462
4738	cube_815	pink	{0,0,0}	-208.68114	346.48944	920	0	0	59.03625	Shape.usd	2025-03-29 14:45:15.297331
4739	polygon_1495	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:15.299305
4740	cylinder_814	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:15.301283
4741	polygon_1496	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:15.512738
4742	cube_816	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:15.515532
4743	cube_817	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:15.517443
4744	cylinder_815	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:15.519394
4745	polygon_1497	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:15.745477
4746	cube_818	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:15.749093
4747	polygon_1498	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	Shape.usd	2025-03-29 14:45:15.751099
4748	cylinder_816	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:15.753057
4749	polygon_1499	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:15.971836
4750	cube_819	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:15.974004
4751	cylinder_817	red	{0,0,0}	30.395967	260.81702	924	0	0	37.405357	Shape.usd	2025-03-29 14:45:15.976128
4752	cylinder_818	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:15.978255
4753	polygon_1500	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:16.196052
4754	cube_820	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:16.199965
4755	polygon_1501	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:16.201998
4756	cylinder_819	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:16.203928
4757	polygon_1502	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:16.427428
4758	cube_821	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:16.429845
4759	polygon_1503	red	{0,0,0}	31.376482	260.81702	936.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:16.431918
4760	cylinder_820	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:16.433878
4761	polygon_1504	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:45:16.643534
4762	cube_822	pink	{0,0,0}	-207.6968	346.48944	937.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:16.646459
4763	polygon_1505	red	{0,0,0}	30.514694	260.8514	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:16.648815
4764	cylinder_821	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	Shape.usd	2025-03-29 14:45:16.650844
4765	polygon_1506	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:16.861276
4766	cube_823	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:45:16.865383
4767	polygon_1507	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.694237	Shape.usd	2025-03-29 14:45:16.867569
4768	cylinder_822	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:16.86966
4769	polygon_1508	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:17.091741
4770	cube_824	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.743565	Shape.usd	2025-03-29 14:45:17.095315
4771	polygon_1509	red	{0,0,0}	31.376482	259.8365	920	0	0	37.69424	Shape.usd	2025-03-29 14:45:17.097441
4772	cylinder_823	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:17.099867
4773	polygon_1510	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:17.316831
4774	cube_825	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:45:17.319631
4775	polygon_1511	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:17.321553
4776	cylinder_824	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:17.323388
4777	polygon_1512	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:17.546754
4778	cube_826	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	Shape.usd	2025-03-29 14:45:17.551008
4779	polygon_1513	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:17.553001
4780	cylinder_825	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:45:17.554944
4781	polygon_1514	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:17.799246
4782	cube_827	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:17.803085
4783	polygon_1515	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	Shape.usd	2025-03-29 14:45:17.805876
4784	cylinder_826	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:45:17.808034
4785	polygon_1516	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:18.02942
4786	cube_828	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:45:18.032232
4787	polygon_1517	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:18.034289
4788	cylinder_827	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:18.036225
4789	polygon_1518	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:18.271193
4790	cube_829	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:18.274868
4791	polygon_1519	red	{0,0,0}	31.376482	259.8365	934	0	0	37.69424	Shape.usd	2025-03-29 14:45:18.276931
4792	cylinder_828	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:18.278985
4793	polygon_1520	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:18.490859
4794	cube_830	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:18.493369
4795	polygon_1521	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.303947	Shape.usd	2025-03-29 14:45:18.495512
4796	cylinder_829	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:18.497356
4797	polygon_1522	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	Shape.usd	2025-03-29 14:45:18.725461
4798	cube_831	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.03624	Shape.usd	2025-03-29 14:45:18.729061
4799	polygon_1523	red	{0,0,0}	30.514694	260.8514	934	0	0	37.405357	Shape.usd	2025-03-29 14:45:18.731067
4800	cylinder_830	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.434948	Shape.usd	2025-03-29 14:45:18.733315
4801	polygon_1524	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:18.946384
4802	cube_832	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:18.949034
4803	polygon_1525	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	Shape.usd	2025-03-29 14:45:18.951526
4804	cylinder_831	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	Shape.usd	2025-03-29 14:45:18.953508
4805	polygon_1526	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:19.185579
4806	cube_833	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:45:19.189305
4807	polygon_1527	red	{0,0,0}	30.395967	260.81702	940.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:19.191259
4808	cylinder_832	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:19.193141
4809	polygon_1528	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	Shape.usd	2025-03-29 14:45:19.416176
4810	cube_834	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:45:19.41851
4811	polygon_1529	red	{0,0,0}	30.395967	260.81702	929	0	0	37.405357	Shape.usd	2025-03-29 14:45:19.420482
4812	cylinder_833	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:19.422408
4813	polygon_1530	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:19.656344
4814	cube_835	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:45:19.660142
4815	polygon_1531	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	Shape.usd	2025-03-29 14:45:19.662217
4816	cylinder_834	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:19.664189
4817	polygon_1532	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:45:19.879891
4818	cube_836	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.34933	Shape.usd	2025-03-29 14:45:19.883793
4819	polygon_1533	red	{0,0,0}	31.499039	259.86707	923.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:19.886065
4820	cylinder_835	green	{0,0,0}	-272.66354	217.54024	933	0	0	18.434948	Shape.usd	2025-03-29 14:45:19.888058
4821	polygon_1534	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:20.119933
4822	cube_837	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.743565	Shape.usd	2025-03-29 14:45:20.123192
4823	polygon_1535	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.234837	Shape.usd	2025-03-29 14:45:20.125118
4824	cylinder_836	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.43495	Shape.usd	2025-03-29 14:45:20.127085
4825	polygon_1536	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:20.348805
4826	cube_838	pink	{0,0,0}	-207.6968	346.48944	912.00006	0	0	59.743565	Shape.usd	2025-03-29 14:45:20.352806
4827	polygon_1537	red	{0,0,0}	30.514694	260.8514	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:20.354933
4828	cylinder_837	green	{0,0,0}	-272.66354	217.54024	935.00006	0	0	45	Shape.usd	2025-03-29 14:45:20.356842
4829	polygon_1538	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:20.583139
4830	cube_839	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:45:20.585907
4831	polygon_1539	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:20.588167
4832	cylinder_838	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:20.590144
4833	polygon_1540	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:20.81458
4834	cube_840	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:45:20.817022
4835	polygon_1541	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.303947	Shape.usd	2025-03-29 14:45:20.819265
4836	cylinder_839	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:20.821143
4837	polygon_1542	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	Shape.usd	2025-03-29 14:45:21.051889
4838	cube_841	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	Shape.usd	2025-03-29 14:45:21.054069
4839	polygon_1543	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:21.056089
4840	cylinder_840	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:21.057986
4841	polygon_1544	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:21.285429
4842	cube_842	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:21.289188
4843	polygon_1545	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:21.291194
4844	cylinder_841	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:21.293187
4845	polygon_1546	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:21.523695
4846	cube_843	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:21.527307
4847	polygon_1547	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:21.529352
4848	cylinder_842	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:21.531302
4849	polygon_1548	black	{0,0,0}	-127.46696	518.69244	653.00006	0	0	90	Shape.usd	2025-03-29 14:45:21.756595
4850	cube_844	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:21.760625
4851	polygon_1549	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.234837	Shape.usd	2025-03-29 14:45:21.762862
4852	cylinder_843	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	Shape.usd	2025-03-29 14:45:21.765008
4853	polygon_1550	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:21.992914
4854	cube_845	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.620872	Shape.usd	2025-03-29 14:45:21.996169
4855	polygon_1551	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:21.998138
4856	cylinder_844	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:22.000231
4857	polygon_1552	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:22.218213
4858	cube_846	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:22.221958
4859	cylinder_845	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:22.223927
4860	cylinder_846	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:22.225977
4861	polygon_1553	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:22.450959
4862	cube_847	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	Shape.usd	2025-03-29 14:45:22.454866
4863	polygon_1554	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:22.456843
4864	cylinder_847	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:22.45876
4865	polygon_1555	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:22.68671
4866	cube_848	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03624	Shape.usd	2025-03-29 14:45:22.690826
4867	polygon_1556	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:22.692961
4868	cylinder_848	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:22.695264
4869	polygon_1557	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:22.922128
4870	cube_849	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	Shape.usd	2025-03-29 14:45:22.924902
4871	polygon_1558	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:22.926986
4872	cylinder_849	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:22.929096
4873	polygon_1559	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	Shape.usd	2025-03-29 14:45:23.151759
4874	cube_850	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	Shape.usd	2025-03-29 14:45:23.155482
4875	polygon_1560	red	{0,0,0}	32.357	258.856	929	0	0	37.476177	Shape.usd	2025-03-29 14:45:23.157544
4876	cylinder_850	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	18.43495	Shape.usd	2025-03-29 14:45:23.15965
4877	polygon_1561	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:23.385754
4878	cube_851	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:23.38844
4879	polygon_1562	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	Shape.usd	2025-03-29 14:45:23.390488
4880	cylinder_851	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:23.392459
4881	polygon_1563	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:23.6177
4882	cube_852	pink	{0,0,0}	-205.90816	345.1413	909.00006	0	0	59.34933	Shape.usd	2025-03-29 14:45:23.621658
4883	polygon_1564	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:23.623938
4884	cylinder_852	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:23.626087
4885	polygon_1565	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:23.846127
4886	cube_853	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:23.850065
4887	polygon_1566	red	{0,0,0}	32.357	258.856	924	0	0	37.694237	Shape.usd	2025-03-29 14:45:23.85219
4888	cylinder_853	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:23.854437
4889	polygon_1567	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:24.082515
4890	cube_854	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:24.085988
4891	polygon_1568	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	Shape.usd	2025-03-29 14:45:24.088186
4892	cylinder_854	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:24.090341
4893	polygon_1569	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:24.321625
4894	cube_855	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:45:24.325539
4895	polygon_1570	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:24.327529
4896	cylinder_855	green	{0,0,0}	-270.62216	216.69383	929	0	0	21.801407	Shape.usd	2025-03-29 14:45:24.329505
4897	polygon_1571	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:24.553495
4898	cube_856	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:45:24.557553
4899	polygon_1572	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:24.55939
4900	cylinder_856	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:45:24.561129
4901	polygon_1573	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:24.794665
4902	cube_857	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:24.796926
4903	cylinder_857	red	{0,0,0}	30.395967	260.81702	931.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:24.799435
4904	cylinder_858	green	{0,0,0}	-270.62216	216.69383	944.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:24.801429
4905	polygon_1574	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:25.015464
4906	cube_858	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	Shape.usd	2025-03-29 14:45:25.018924
4907	polygon_1575	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:25.021127
4908	cylinder_859	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:45:25.023298
4909	polygon_1576	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:45:25.242136
4910	cube_859	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:25.244903
4911	polygon_1577	red	{0,0,0}	31.499039	259.86707	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:25.246801
4912	cylinder_860	green	{0,0,0}	-272.66354	217.54024	935.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:25.248799
4913	polygon_1578	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:25.474154
4914	cube_860	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.34933	Shape.usd	2025-03-29 14:45:25.477975
4915	polygon_1579	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:25.480081
4916	cylinder_861	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:25.481953
4917	polygon_1580	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	Shape.usd	2025-03-29 14:45:25.712352
4918	cube_861	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.420776	Shape.usd	2025-03-29 14:45:25.715774
4919	polygon_1581	red	{0,0,0}	31.499039	259.86707	920	0	0	37.69424	Shape.usd	2025-03-29 14:45:25.718116
4920	cylinder_862	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.434948	Shape.usd	2025-03-29 14:45:25.720219
4921	polygon_1582	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:25.934838
4922	cube_862	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:25.938896
4923	cube_863	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:25.941004
4924	cylinder_863	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	Shape.usd	2025-03-29 14:45:25.942867
4925	polygon_1583	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:26.156784
4926	cube_864	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.534454	Shape.usd	2025-03-29 14:45:26.159434
4927	polygon_1584	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:26.161577
4928	cylinder_864	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:26.163627
4929	polygon_1585	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:26.390532
4930	cube_865	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.34933	Shape.usd	2025-03-29 14:45:26.394202
4931	polygon_1586	red	{0,0,0}	31.376482	259.8365	924	0	0	37.234837	Shape.usd	2025-03-29 14:45:26.396164
4932	cylinder_865	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:26.398115
4933	polygon_1587	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:26.623392
4934	cube_866	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:45:26.625786
4935	polygon_1588	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:26.627714
4936	cylinder_866	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:26.629689
4937	polygon_1589	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:26.85921
4938	cube_867	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:26.863325
4939	polygon_1590	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:26.865733
4940	cylinder_867	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:26.867869
4941	polygon_1591	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:27.094186
4942	cube_868	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:27.098308
4943	polygon_1592	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	Shape.usd	2025-03-29 14:45:27.100457
4944	cylinder_868	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:27.102556
4945	polygon_1593	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:27.325364
4946	cube_869	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:27.329003
4947	polygon_1594	red	{0,0,0}	32.357	258.856	920	0	0	36.869896	Shape.usd	2025-03-29 14:45:27.330862
4948	cylinder_869	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:27.332962
4949	polygon_1595	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:27.554194
4950	cube_870	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:27.557161
4951	polygon_1596	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:27.559177
4952	cylinder_870	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:27.561198
4953	polygon_1597	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:27.7766
4954	cube_871	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:27.778864
4955	polygon_1598	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.303947	Shape.usd	2025-03-29 14:45:27.780785
4956	cylinder_871	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:27.782678
4957	polygon_1599	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:28.012046
4958	cube_872	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:28.016192
4959	polygon_1600	red	{0,0,0}	31.376482	259.8365	920	0	0	37.69424	Shape.usd	2025-03-29 14:45:28.018231
4960	cylinder_872	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:28.020509
4961	polygon_1601	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:28.246006
4962	cube_873	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:45:28.249845
4963	polygon_1602	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:28.251762
4964	cylinder_873	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:28.253941
4965	polygon_1603	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:28.47534
4966	cube_874	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:45:28.479273
4967	polygon_1604	red	{0,0,0}	31.376482	259.8365	916.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:28.481298
4968	cylinder_874	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	33.690063	Shape.usd	2025-03-29 14:45:28.483379
4969	polygon_1605	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:28.724894
4970	cube_875	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:28.728666
4971	polygon_1606	red	{0,0,0}	32.357	258.856	936.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:28.730697
4972	cylinder_875	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.43495	Shape.usd	2025-03-29 14:45:28.732735
4973	polygon_1607	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:28.961175
4974	cube_876	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.743565	Shape.usd	2025-03-29 14:45:28.964469
4975	polygon_1608	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	Shape.usd	2025-03-29 14:45:28.966672
4976	cylinder_876	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	Shape.usd	2025-03-29 14:45:28.968673
4977	polygon_1609	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:29.194731
4978	cube_877	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:29.198473
4979	polygon_1610	red	{0,0,0}	32.357	258.856	924	0	0	37.303947	Shape.usd	2025-03-29 14:45:29.20066
4980	cylinder_877	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:29.202902
4981	polygon_1611	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:29.418809
4982	cube_878	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:29.422394
4983	polygon_1612	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	Shape.usd	2025-03-29 14:45:29.424598
4984	cylinder_878	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:29.426893
4985	polygon_1613	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:45:29.658746
4986	cube_879	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.620872	Shape.usd	2025-03-29 14:45:29.662826
4987	polygon_1614	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:45:29.664924
4988	cylinder_879	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:29.667051
4989	polygon_1615	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:29.901511
4990	cube_880	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	Shape.usd	2025-03-29 14:45:29.903961
4991	polygon_1616	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:29.90592
4992	cylinder_880	green	{0,0,0}	-270.62216	216.69383	933	0	0	18.434948	Shape.usd	2025-03-29 14:45:29.907901
4993	polygon_1617	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	Shape.usd	2025-03-29 14:45:30.129223
4994	cube_881	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.620872	Shape.usd	2025-03-29 14:45:30.13147
4995	polygon_1618	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	36.869896	Shape.usd	2025-03-29 14:45:30.134611
4996	cylinder_881	green	{0,0,0}	-272.65317	217.53194	936.00006	0	0	33.690067	Shape.usd	2025-03-29 14:45:30.137956
4997	polygon_1619	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:30.368993
4998	cube_882	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	Shape.usd	2025-03-29 14:45:30.371649
4999	polygon_1620	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:30.373906
5000	cylinder_882	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:45:30.376041
5001	polygon_1621	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:30.600932
5002	cube_883	pink	{0,0,0}	-205.90816	345.1413	910	0	0	59.420776	Shape.usd	2025-03-29 14:45:30.604623
5003	polygon_1622	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:30.606763
5004	cylinder_883	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:30.608916
5005	polygon_1623	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:30.835643
5006	cube_884	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:30.839215
5007	polygon_1624	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:30.84141
5008	cylinder_884	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:30.843571
5009	polygon_1625	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:31.06243
5010	cube_885	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:31.065159
5011	polygon_1626	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:31.067322
5012	cylinder_885	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:31.069243
5013	polygon_1627	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:31.311701
5014	cube_886	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.743565	Shape.usd	2025-03-29 14:45:31.315316
5015	polygon_1628	red	{0,0,0}	32.357	258.856	929	0	0	37.69424	Shape.usd	2025-03-29 14:45:31.317391
5016	cylinder_886	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:31.319396
5017	polygon_1629	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:31.535885
5018	cube_887	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:31.539217
5019	polygon_1630	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:45:31.541145
5020	cylinder_887	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:45:31.543272
5021	polygon_1631	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:31.759509
5022	cube_888	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:31.762337
5023	polygon_1632	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:31.764346
5024	cylinder_888	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:45:31.766356
5025	polygon_1633	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:32.027015
5026	cube_889	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.03624	Shape.usd	2025-03-29 14:45:32.029659
5027	polygon_1634	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:32.031682
5028	cylinder_889	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:45:32.033813
5029	polygon_1635	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:32.262909
5030	cube_890	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:45:32.266682
5031	cube_891	red	{0,0,0}	32.357	258.856	934	0	0	37.69424	Shape.usd	2025-03-29 14:45:32.268635
5032	cylinder_890	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:45:32.270587
5033	polygon_1636	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:32.493514
5034	cube_892	pink	{0,0,0}	-205.90816	345.1413	937.00006	0	0	59.743565	Shape.usd	2025-03-29 14:45:32.497734
5035	polygon_1637	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:32.499921
5036	cylinder_891	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:32.502181
5037	polygon_1638	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:32.72907
5038	cube_893	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:32.732705
5039	polygon_1639	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:32.734842
5040	cylinder_892	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:32.736786
5041	polygon_1640	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:32.964325
5042	cube_894	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:32.966754
5043	cube_895	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:32.968793
5044	cylinder_893	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:45:32.97073
5045	polygon_1641	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:33.196477
5046	cube_896	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:33.200827
5047	polygon_1642	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:33.202869
5048	cylinder_894	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:33.204811
5049	polygon_1643	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	Shape.usd	2025-03-29 14:45:33.429387
5050	cube_897	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	Shape.usd	2025-03-29 14:45:33.433442
5051	polygon_1644	red	{0,0,0}	32.357	258.856	919	0	0	37.568592	Shape.usd	2025-03-29 14:45:33.435553
5052	cylinder_895	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:33.437575
5053	polygon_1645	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:33.66055
5054	cube_898	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:33.665008
5055	polygon_1646	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:33.667368
5056	cylinder_896	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:33.66943
5057	polygon_1647	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:33.892939
5058	cube_899	pink	{0,0,0}	-205.90816	345.1413	910	0	0	59.743565	Shape.usd	2025-03-29 14:45:33.896716
5059	polygon_1648	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	Shape.usd	2025-03-29 14:45:33.89883
5060	cylinder_897	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:33.901138
5061	polygon_1649	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:34.135592
5062	cube_900	pink	{0,0,0}	-205.90816	345.1413	909.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:34.139182
5063	polygon_1650	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	Shape.usd	2025-03-29 14:45:34.141114
5064	cylinder_898	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:45:34.143012
5065	polygon_1651	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:34.362407
5066	cube_901	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.743565	Shape.usd	2025-03-29 14:45:34.365384
5067	polygon_1652	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	Shape.usd	2025-03-29 14:45:34.367394
5068	cylinder_899	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:34.369439
5069	polygon_1653	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:34.588382
5070	cube_902	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	Shape.usd	2025-03-29 14:45:34.590593
5071	polygon_1654	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	Shape.usd	2025-03-29 14:45:34.592723
5072	cylinder_900	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:34.594837
5073	polygon_1655	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:34.810977
5074	cube_903	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.620872	Shape.usd	2025-03-29 14:45:34.815125
5075	polygon_1656	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	Shape.usd	2025-03-29 14:45:34.817083
5076	cylinder_901	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:34.819011
5077	polygon_1657	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	Shape.usd	2025-03-29 14:45:35.042648
5078	cube_904	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	Shape.usd	2025-03-29 14:45:35.045089
5079	polygon_1658	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:35.047289
5080	cylinder_902	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:35.049374
5081	polygon_1659	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:35.273401
5082	cube_905	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	Shape.usd	2025-03-29 14:45:35.277106
5083	polygon_1660	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	Shape.usd	2025-03-29 14:45:35.279529
5084	cylinder_903	green	{0,0,0}	-270.6119	216.68562	924	0	0	21.801407	Shape.usd	2025-03-29 14:45:35.281628
5085	polygon_1661	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:35.49615
5086	cube_906	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	Shape.usd	2025-03-29 14:45:35.50004
5087	cylinder_904	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.694237	Shape.usd	2025-03-29 14:45:35.502186
5088	cylinder_905	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:35.504303
5089	polygon_1662	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:35.73405
5090	cube_907	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:45:35.73691
5091	polygon_1663	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:35.739117
5092	cylinder_906	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:35.741227
5093	polygon_1664	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:35.968368
5094	cube_908	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.34933	Shape.usd	2025-03-29 14:45:35.971893
5095	polygon_1665	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:35.974058
5096	cylinder_907	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:35.976215
5097	polygon_1666	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:36.202252
5098	cube_909	pink	{0,0,0}	-205.90816	345.1413	910	0	0	59.03624	Shape.usd	2025-03-29 14:45:36.206004
5099	polygon_1667	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	Shape.usd	2025-03-29 14:45:36.208371
5100	cylinder_908	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:36.210384
5101	polygon_1668	black	{0,0,0}	-127.46696	518.69244	661	0	0	0	Shape.usd	2025-03-29 14:45:36.425212
5102	cube_910	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:36.429427
5103	polygon_1669	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:36.431598
5104	cylinder_909	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:36.433725
5105	polygon_1670	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:36.649634
5106	cube_911	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:36.651971
5107	polygon_1671	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:36.653896
5108	cylinder_910	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:36.65586
5109	polygon_1672	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:36.885986
5110	cube_912	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.743565	Shape.usd	2025-03-29 14:45:36.89008
5111	polygon_1673	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:45:36.892419
5112	cylinder_911	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:36.894468
5113	polygon_1674	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	Shape.usd	2025-03-29 14:45:37.117925
5114	cube_913	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:37.1205
5115	polygon_1675	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:37.122585
5116	cylinder_912	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:37.124763
5117	polygon_1676	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:37.343184
5118	cube_914	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:37.347252
5119	polygon_1677	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:45:37.349453
5120	cylinder_913	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:37.351431
5121	polygon_1678	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:37.577444
5122	cube_915	pink	{0,0,0}	-205.90816	345.1413	937.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:37.581175
5123	polygon_1679	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:37.583534
5124	cylinder_914	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:37.585501
5125	polygon_1680	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:37.817105
5126	cube_916	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:37.820679
5127	polygon_1681	red	{0,0,0}	31.376482	259.8365	920	0	0	37.69424	Shape.usd	2025-03-29 14:45:37.822757
5128	cylinder_915	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:37.824869
5129	polygon_1682	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:38.052719
5130	cube_917	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:38.056434
5131	polygon_1683	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:38.058459
5132	cylinder_916	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:38.060706
5133	polygon_1684	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:38.273017
5134	cube_918	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	Shape.usd	2025-03-29 14:45:38.276607
5135	polygon_1685	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	Shape.usd	2025-03-29 14:45:38.278521
5136	cylinder_917	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:38.280492
5137	polygon_1686	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:45:38.533315
5138	cube_919	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.620872	Shape.usd	2025-03-29 14:45:38.535475
5139	polygon_1687	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:38.537458
5140	cylinder_918	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:38.539402
5141	polygon_1688	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:38.768981
5142	cube_920	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	Shape.usd	2025-03-29 14:45:38.772553
5143	polygon_1689	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	Shape.usd	2025-03-29 14:45:38.774517
5144	cylinder_919	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:45:38.776492
5145	polygon_1690	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	Shape.usd	2025-03-29 14:45:39.003705
5146	cube_921	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:39.006061
5147	polygon_1691	red	{0,0,0}	32.355774	258.8462	929	0	0	37.303947	Shape.usd	2025-03-29 14:45:39.008105
5148	cylinder_920	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:39.010038
5149	polygon_1692	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:39.241427
5150	cube_922	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.34933	Shape.usd	2025-03-29 14:45:39.245183
5151	polygon_1693	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:39.247424
5152	cylinder_921	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:39.249499
5153	polygon_1694	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	Shape.usd	2025-03-29 14:45:39.473111
5154	cube_923	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:39.476834
5155	polygon_1695	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:39.478952
5156	cylinder_922	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:39.480936
5157	polygon_1696	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:39.69636
5158	cube_924	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:39.700204
5159	polygon_1697	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	Shape.usd	2025-03-29 14:45:39.702394
5160	cylinder_923	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.43495	Shape.usd	2025-03-29 14:45:39.704426
5161	polygon_1698	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	Shape.usd	2025-03-29 14:45:39.937398
5162	cube_925	pink	{0,0,0}	-207.68886	346.4762	911.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:39.941103
5163	polygon_1699	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:39.943178
5164	cylinder_924	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:39.945123
5165	polygon_1700	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	Shape.usd	2025-03-29 14:45:40.164933
5166	cube_926	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	Shape.usd	2025-03-29 14:45:40.169174
5167	polygon_1701	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:40.171218
5168	cylinder_925	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:40.173197
5169	polygon_1702	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:40.402515
5170	cube_927	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:40.404939
5171	polygon_1703	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:40.4071
5172	cylinder_926	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:40.409045
5173	polygon_1704	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:40.635816
5174	cube_928	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:40.639701
5175	polygon_1705	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.694237	Shape.usd	2025-03-29 14:45:40.641745
5176	cylinder_927	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.434948	Shape.usd	2025-03-29 14:45:40.643689
5177	polygon_1706	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:40.871144
5178	cube_929	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:40.875148
5179	polygon_1707	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:40.87746
5180	cylinder_928	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:40.87968
5181	polygon_1708	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:41.098246
5182	cube_930	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.34933	Shape.usd	2025-03-29 14:45:41.100473
5183	polygon_1709	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	Shape.usd	2025-03-29 14:45:41.102721
5184	cylinder_929	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:41.10473
5185	polygon_1710	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:41.328017
5186	cube_931	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	Shape.usd	2025-03-29 14:45:41.33163
5187	polygon_1711	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:41.333849
5188	cylinder_930	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	Shape.usd	2025-03-29 14:45:41.336177
5189	polygon_1712	black	{0,0,0}	-127.46696	518.69244	663.00006	0	0	90	Shape.usd	2025-03-29 14:45:41.548783
5190	cube_932	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:45:41.552197
5191	polygon_1713	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.184708	Shape.usd	2025-03-29 14:45:41.554312
5192	cylinder_931	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	Shape.usd	2025-03-29 14:45:41.556307
5193	polygon_1714	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:41.78473
5194	cube_933	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	Shape.usd	2025-03-29 14:45:41.788759
5195	polygon_1715	red	{0,0,0}	32.357	258.856	929	0	0	36.869896	Shape.usd	2025-03-29 14:45:41.790757
5196	cylinder_932	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:41.792675
5197	polygon_1716	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:42.018923
5198	cube_934	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	Shape.usd	2025-03-29 14:45:42.022402
5199	cylinder_933	red	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	Shape.usd	2025-03-29 14:45:42.024461
5200	cylinder_934	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	Shape.usd	2025-03-29 14:45:42.026321
5201	polygon_1717	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:42.252748
5202	cube_935	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:42.256913
5203	polygon_1718	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:45:42.258911
5204	cylinder_935	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	Shape.usd	2025-03-29 14:45:42.260769
5205	polygon_1719	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:42.485101
5206	cube_936	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.743565	Shape.usd	2025-03-29 14:45:42.487634
5207	polygon_1720	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	Shape.usd	2025-03-29 14:45:42.489816
5208	cylinder_936	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:42.491782
5209	polygon_1721	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:42.719573
5210	cube_937	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:42.722494
5211	cube_938	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	Shape.usd	2025-03-29 14:45:42.724555
5212	cylinder_937	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:42.726644
5213	polygon_1722	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:42.950781
5214	cube_939	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:42.954626
5215	polygon_1723	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	Shape.usd	2025-03-29 14:45:42.956642
5216	cylinder_938	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:45:42.958692
5217	polygon_1724	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	Shape.usd	2025-03-29 14:45:43.188057
5218	cube_940	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	Shape.usd	2025-03-29 14:45:43.191737
5219	cylinder_939	red	{0,0,0}	30.395967	260.81702	920	0	0	37.568592	Shape.usd	2025-03-29 14:45:43.193707
5220	cylinder_940	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:43.195617
5221	polygon_1725	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	Shape.usd	2025-03-29 14:45:43.416689
5222	cube_941	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:43.421161
5223	polygon_1726	red	{0,0,0}	31.499039	259.86707	926.00006	0	0	37.69424	Shape.usd	2025-03-29 14:45:43.423366
5224	cylinder_941	green	{0,0,0}	-272.66354	217.54024	937.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:43.425287
5225	polygon_1727	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:43.661266
5226	cube_942	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	Shape.usd	2025-03-29 14:45:43.66523
5227	polygon_1728	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	Shape.usd	2025-03-29 14:45:43.667281
5228	cylinder_942	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	Shape.usd	2025-03-29 14:45:43.669277
5229	polygon_1729	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:43.899591
5230	cube_943	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.743565	Shape.usd	2025-03-29 14:45:43.901772
5231	polygon_1730	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:43.904145
5232	cylinder_943	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:43.90628
5233	polygon_1731	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	Shape.usd	2025-03-29 14:45:44.121423
5234	cube_944	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	Shape.usd	2025-03-29 14:45:44.124754
5235	cube_945	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:44.126916
5236	cylinder_944	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:44.128891
5237	polygon_1732	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:44.355339
5238	cube_946	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.420776	Shape.usd	2025-03-29 14:45:44.359183
5239	polygon_1733	red	{0,0,0}	32.357	258.856	933	0	0	37.874985	Shape.usd	2025-03-29 14:45:44.361381
5240	cylinder_945	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:44.363264
5241	polygon_1734	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:44.590161
5242	cube_947	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:44.59389
5243	polygon_1735	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.568592	Shape.usd	2025-03-29 14:45:44.595798
5244	cylinder_946	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	Shape.usd	2025-03-29 14:45:44.598034
5245	polygon_1736	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	Shape.usd	2025-03-29 14:45:44.828737
5246	cube_948	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.34933	Shape.usd	2025-03-29 14:45:44.832442
5247	polygon_1737	red	{0,0,0}	31.499039	259.86707	920	0	0	37.303947	Shape.usd	2025-03-29 14:45:44.834754
5248	cylinder_947	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	26.56505	Shape.usd	2025-03-29 14:45:44.836892
5249	polygon_1738	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	Shape.usd	2025-03-29 14:45:45.054631
5250	cube_949	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	Shape.usd	2025-03-29 14:45:45.058388
5251	polygon_1739	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.874985	Shape.usd	2025-03-29 14:45:45.060298
5252	cylinder_948	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	Shape.usd	2025-03-29 14:45:45.063375
5653	pentagonal_prism_257	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:45.526503
1618	cube_1	pink	{0,0,0}	-414.87473	40.821007	934	0	0	59.534454	cube.usd	2025-03-29 14:46:53.923908
5254	hexagonal_prism_1	red	{0,0,0}	-212.43585	-31.657106	946.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:46:53.926231
5255	pentagonal_prism_2	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:54.157992
5256	pentagonal_prism_3	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:54.386631
5258	hexagonal_prism_2	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:46:54.392961
5257	pentagonal_prism_4	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:54.624536
5260	hexagonal_prism_3	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:46:54.63123
5259	pentagonal_prism_5	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:54.859218
5262	hexagonal_prism_4	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:46:54.865084
5265	hexagonal_prism_5	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:46:55.110427
5263	pentagonal_prism_7	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:55.328723
1642	cube_7	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.534454	cube.usd	2025-03-29 14:46:55.332245
5267	hexagonal_prism_6	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:46:55.334553
1648	cylinder_8	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:46:55.336765
5264	pentagonal_prism_8	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:55.563694
5266	pentagonal_prism_9	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:55.798789
5273	hexagonal_prism_7	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:46:55.805036
5268	pentagonal_prism_10	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:56.029691
5275	hexagonal_prism_8	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:46:56.034539
5270	pentagonal_prism_12	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:46:56.270988
5271	pentagonal_prism_13	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:56.49781
5281	hexagonal_prism_9	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:46:56.504048
5272	pentagonal_prism_14	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:56.729912
5283	hexagonal_prism_10	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.77569	hexagonal_prism.usd	2025-03-29 14:46:56.737068
1672	cylinder_15	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:46:56.739334
5274	pentagonal_prism_15	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:56.972865
5286	hexagonal_prism_11	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:46:56.978896
5276	pentagonal_prism_16	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:57.195947
5278	pentagonal_prism_18	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:57.428729
5288	hexagonal_prism_12	red	{0,0,0}	31.376482	259.8365	920	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:46:57.433954
5279	pentagonal_prism_19	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:57.660564
5291	hexagonal_prism_13	orange	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:46:57.667039
5280	pentagonal_prism_20	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:57.890387
5282	pentagonal_prism_21	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:58.116763
5284	pentagonal_prism_22	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:58.345395
5285	pentagonal_prism_23	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:58.585406
5289	pentagonal_prism_25	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:58.812076
5290	pentagonal_prism_26	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:59.036662
1706	cube_23	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:46:59.039281
5292	pentagonal_prism_27	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:59.263503
5293	pentagonal_prism_28	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:59.494147
5297	hexagonal_prism_15	red	{0,0,0}	30.514694	260.8514	933	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:46:58.122091
5299	hexagonal_prism_16	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:46:58.35108
5305	hexagonal_prism_17	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:46:58.817429
5307	hexagonal_prism_18	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:46:59.041426
5296	pentagonal_prism_30	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:59.723893
5309	hexagonal_prism_19	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:46:59.73009
5298	pentagonal_prism_31	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:59.960048
5300	pentagonal_prism_32	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.694237	pentagonal_prism.usd	2025-03-29 14:46:59.964653
5301	pentagonal_prism_33	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:00.194025
1730	cube_29	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:00.19652
5311	hexagonal_prism_20	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:00.19883
5302	pentagonal_prism_34	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:00.429788
5315	hexagonal_prism_21	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.746803	hexagonal_prism.usd	2025-03-29 14:47:00.436741
5317	hexagonal_prism_22	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:00.668866
5304	pentagonal_prism_36	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:00.897178
5321	hexagonal_prism_23	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:00.903226
5306	pentagonal_prism_37	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:01.13642
5308	pentagonal_prism_38	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:01.362463
5323	hexagonal_prism_24	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:01.369394
5310	pentagonal_prism_39	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:01.598499
5312	pentagonal_prism_40	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:01.832768
5325	hexagonal_prism_25	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:01.839531
1764	cylinder_39	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:01.841751
5314	pentagonal_prism_42	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:47:02.081808
5316	pentagonal_prism_43	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:02.308413
5328	hexagonal_prism_26	red	{0,0,0}	31.499039	259.86707	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:02.314445
5318	pentagonal_prism_44	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:02.531069
5330	hexagonal_prism_27	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:02.537282
5319	pentagonal_prism_45	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:02.768398
5332	hexagonal_prism_28	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:02.774701
5320	pentagonal_prism_46	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:03.006481
5324	pentagonal_prism_48	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:03.24234
5334	hexagonal_prism_29	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:03.248507
5326	pentagonal_prism_49	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:03.471678
1786	cube_43	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:47:03.475601
5336	hexagonal_prism_30	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:03.477985
5327	pentagonal_prism_50	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:03.711666
5329	pentagonal_prism_51	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:03.717711
5331	pentagonal_prism_52	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:03.94588
5338	hexagonal_prism_31	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:03.952558
5340	hexagonal_prism_32	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:04.17591
5335	pentagonal_prism_54	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:04.400716
5337	pentagonal_prism_55	red	{0,0,0}	31.499039	259.86707	923.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:47:04.405742
5339	pentagonal_prism_56	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:04.634016
5342	hexagonal_prism_33	red	{0,0,0}	29.53035	261.83575	931.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:04.639461
5341	pentagonal_prism_57	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:04.86071
5344	hexagonal_prism_34	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:04.866792
5343	pentagonal_prism_58	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:05.08941
1824	cylinder_54	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:05.333502
5665	pentagonal_prism_264	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:46.682392
5345	pentagonal_prism_59	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:05.325156
5347	pentagonal_prism_60	red	{0,0,0}	31.499039	259.86707	924	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:47:05.331338
5348	hexagonal_prism_36	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:05.563595
5351	pentagonal_prism_62	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:05.795269
5350	hexagonal_prism_37	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:05.800148
5352	pentagonal_prism_63	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:06.020762
5353	pentagonal_prism_64	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.184704	pentagonal_prism.usd	2025-03-29 14:47:06.025889
5355	pentagonal_prism_65	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:06.244958
5354	hexagonal_prism_38	orange	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:06.250537
5356	pentagonal_prism_66	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:06.466635
5358	hexagonal_prism_39	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:06.473172
5360	hexagonal_prism_40	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:06.719391
5359	pentagonal_prism_68	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:06.935198
5362	hexagonal_prism_41	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:06.941247
1852	cylinder_61	green	{0,0,0}	-272.66354	217.54024	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:06.943449
5361	pentagonal_prism_69	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:07.183286
5363	pentagonal_prism_70	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:07.426435
5364	hexagonal_prism_42	red	{0,0,0}	30.395967	260.81702	933	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:07.43195
5365	pentagonal_prism_71	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:07.667113
5366	hexagonal_prism_43	red	{0,0,0}	30.514694	260.8514	919	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:07.672486
5368	hexagonal_prism_44	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:07.895019
5369	pentagonal_prism_73	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:08.129753
5370	hexagonal_prism_45	red	{0,0,0}	30.514694	260.8514	923.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:08.136305
5371	pentagonal_prism_74	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:08.35685
5373	pentagonal_prism_75	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:08.361852
1880	cylinder_68	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:08.364044
5375	pentagonal_prism_76	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:08.584825
5376	pentagonal_prism_77	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:08.591953
5377	pentagonal_prism_78	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:08.821932
5379	pentagonal_prism_79	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:09.062598
5374	hexagonal_prism_47	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:09.069366
5381	pentagonal_prism_80	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:09.311201
5383	pentagonal_prism_81	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.184704	pentagonal_prism.usd	2025-03-29 14:47:09.316536
5385	pentagonal_prism_82	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:09.543616
5378	hexagonal_prism_48	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:09.549573
5387	pentagonal_prism_83	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:09.782212
5380	hexagonal_prism_49	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:09.787149
5391	pentagonal_prism_85	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:47:10.006201
5393	pentagonal_prism_86	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:10.231971
5382	hexagonal_prism_50	red	{0,0,0}	30.51353	260.84146	930.00006	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:47:10.238345
1912	cylinder_76	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:10.240805
5395	pentagonal_prism_87	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:10.457927
5384	hexagonal_prism_51	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:47:10.463087
5396	pentagonal_prism_88	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:10.707262
5386	hexagonal_prism_52	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.234837	hexagonal_prism.usd	2025-03-29 14:47:10.7144
5388	hexagonal_prism_53	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:11.645558
5390	hexagonal_prism_54	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:12.122271
5394	hexagonal_prism_56	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:12.590548
2548	cylinder_243	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:46.925137
5399	pentagonal_prism_90	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:11.173432
5401	pentagonal_prism_91	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:11.178691
5403	pentagonal_prism_92	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:11.415221
1940	cylinder_83	green	{0,0,0}	-270.62216	216.69383	934	0	0	21.801407	cylinder.usd	2025-03-29 14:47:11.647809
5405	pentagonal_prism_94	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:47:11.875921
5406	pentagonal_prism_95	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:12.115985
5408	pentagonal_prism_96	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:12.354718
5410	pentagonal_prism_97	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:12.585639
5412	pentagonal_prism_98	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:12.808123
5413	pentagonal_prism_99	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:47:12.813524
5398	hexagonal_prism_57	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:13.048444
5415	pentagonal_prism_101	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:13.278166
1968	cylinder_90	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	cylinder.usd	2025-03-29 14:47:13.284719
5416	pentagonal_prism_102	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:47:13.507357
5418	pentagonal_prism_103	red	{0,0,0}	32.357	258.856	929	0	0	37.303947	pentagonal_prism.usd	2025-03-29 14:47:13.51444
5420	pentagonal_prism_104	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:13.733096
5400	hexagonal_prism_58	orange	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:13.740157
5421	pentagonal_prism_105	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:13.95576
5402	hexagonal_prism_59	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:13.961164
5407	hexagonal_prism_60	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:14.201058
5423	pentagonal_prism_107	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:14.422721
5409	hexagonal_prism_61	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.694237	hexagonal_prism.usd	2025-03-29 14:47:14.429485
5425	pentagonal_prism_108	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:14.65456
1996	cylinder_97	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:14.663839
5427	pentagonal_prism_109	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:14.887735
5411	hexagonal_prism_62	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:14.894373
5429	pentagonal_prism_110	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:15.126515
5417	hexagonal_prism_63	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:15.133626
5419	hexagonal_prism_64	red	{0,0,0}	30.514694	260.8514	929	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:15.364245
5433	pentagonal_prism_112	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:15.595104
5424	hexagonal_prism_65	red	{0,0,0}	31.499039	259.86707	929	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:15.601675
5434	pentagonal_prism_113	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:15.822548
5435	pentagonal_prism_114	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:15.828988
5437	pentagonal_prism_115	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:16.056551
5426	hexagonal_prism_66	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:16.063079
5438	pentagonal_prism_116	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:16.309049
2020	cylinder_104	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:16.32038
5428	hexagonal_prism_67	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:16.552095
5441	pentagonal_prism_118	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:16.778426
5430	hexagonal_prism_68	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:16.785718
5443	pentagonal_prism_119	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:17.009828
5432	hexagonal_prism_69	red	{0,0,0}	31.376482	259.8365	934	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:17.014817
5444	pentagonal_prism_120	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:17.24459
5436	hexagonal_prism_70	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:17.251001
5445	pentagonal_prism_121	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:17.477644
5447	pentagonal_prism_122	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:47:17.484611
5442	hexagonal_prism_72	red	{0,0,0}	31.376482	259.8365	917.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:17.945198
5446	hexagonal_prism_73	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:18.184802
5708	hexagonal_prism_164	red	{0,0,0}	31.376482	259.8365	933	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:47.388927
5450	pentagonal_prism_124	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:17.940314
5451	pentagonal_prism_125	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:18.1785
5453	pentagonal_prism_126	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:18.40259
2054	cube_111	pink	{0,0,0}	-207.6968	346.48944	922.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:18.406737
5448	hexagonal_prism_74	red	{0,0,0}	30.514694	260.8514	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:18.638438
5456	pentagonal_prism_128	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:18.863885
5452	hexagonal_prism_75	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:18.870439
5457	pentagonal_prism_129	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:19.101057
5459	pentagonal_prism_130	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:19.334432
2074	cube_116	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.420776	cube.usd	2025-03-29 14:47:19.336977
5454	hexagonal_prism_76	red	{0,0,0}	30.514694	260.8514	935.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:19.339183
5460	pentagonal_prism_131	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:19.563308
5458	hexagonal_prism_77	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:19.568874
5463	hexagonal_prism_78	red	{0,0,0}	30.514694	260.8514	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:19.807603
5462	pentagonal_prism_133	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:20.027859
5464	pentagonal_prism_134	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:20.261604
5465	hexagonal_prism_79	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:20.268018
5466	pentagonal_prism_135	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:20.498927
5467	hexagonal_prism_80	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:20.505392
5468	pentagonal_prism_136	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:20.724073
5469	hexagonal_prism_81	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:20.72917
5470	pentagonal_prism_137	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:20.949697
5472	pentagonal_prism_138	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:21.182269
5473	pentagonal_prism_139	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:21.187185
2112	cylinder_127	green	{0,0,0}	-270.62216	216.69383	933	0	0	18.434948	cylinder.usd	2025-03-29 14:47:21.189257
5474	pentagonal_prism_140	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:21.412092
5477	hexagonal_prism_83	red	{0,0,0}	31.376482	259.8365	920	0	0	36.869896	hexagonal_prism.usd	2025-03-29 14:47:21.418889
5475	pentagonal_prism_141	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:21.64819
5476	pentagonal_prism_142	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:47:21.653609
5478	pentagonal_prism_143	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:21.881226
5479	pentagonal_prism_144	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:22.118668
5484	hexagonal_prism_85	red	{0,0,0}	32.357	258.856	924	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:22.124305
5481	pentagonal_prism_145	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:22.351446
5486	hexagonal_prism_86	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.694237	hexagonal_prism.usd	2025-03-29 14:47:22.357727
5482	pentagonal_prism_146	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:22.583459
5489	hexagonal_prism_87	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:22.588815
5483	pentagonal_prism_147	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:22.816353
5493	hexagonal_prism_88	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:22.821902
5485	pentagonal_prism_148	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:23.052601
2130	cube_132	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:47:23.056975
5487	pentagonal_prism_149	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:23.283288
5488	pentagonal_prism_150	red	{0,0,0}	32.357	258.856	925.00006	0	0	36.869892	pentagonal_prism.usd	2025-03-29 14:47:23.288792
5490	pentagonal_prism_151	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:23.529778
5491	pentagonal_prism_152	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:23.760174
5492	pentagonal_prism_153	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:23.980477
5494	pentagonal_prism_154	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:24.21556
5496	pentagonal_prism_155	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:24.44929
5498	pentagonal_prism_157	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:24.91876
5677	pentagonal_prism_272	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:48.051374
5503	hexagonal_prism_91	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:23.765015
5507	hexagonal_prism_92	red	{0,0,0}	31.376482	259.8365	934	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:23.985774
5509	hexagonal_prism_93	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:24.222393
5511	hexagonal_prism_94	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:24.454856
5515	hexagonal_prism_95	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:24.694744
5517	hexagonal_prism_96	orange	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:24.923675
5499	pentagonal_prism_158	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:25.151061
5519	hexagonal_prism_97	red	{0,0,0}	31.376482	259.8365	933	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:25.15662
5500	pentagonal_prism_159	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:25.386125
5522	hexagonal_prism_98	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:25.391418
5502	pentagonal_prism_160	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:25.618374
5525	hexagonal_prism_99	orange	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:25.624984
5504	pentagonal_prism_161	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:25.85202
5505	pentagonal_prism_162	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:26.085728
5531	hexagonal_prism_101	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:26.09065
5506	pentagonal_prism_163	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:26.315366
5508	pentagonal_prism_164	red	{0,0,0}	30.395967	260.81702	934	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:26.320809
5510	pentagonal_prism_165	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:26.539762
5512	pentagonal_prism_166	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:26.770241
2190	cube_148	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:26.774539
5533	hexagonal_prism_102	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:26.776809
5513	pentagonal_prism_167	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:27.005299
5514	pentagonal_prism_168	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:27.238689
5539	hexagonal_prism_104	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:27.244986
5516	pentagonal_prism_169	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:27.470101
5518	pentagonal_prism_170	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:27.703901
5541	hexagonal_prism_105	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:27.708829
2228	cylinder_157	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:47:27.711059
5520	pentagonal_prism_171	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:27.944959
5543	hexagonal_prism_106	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:27.950119
5521	pentagonal_prism_172	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:28.170862
5524	pentagonal_prism_174	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:28.637348
5526	pentagonal_prism_175	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.874985	pentagonal_prism.usd	2025-03-29 14:47:28.642672
5528	pentagonal_prism_176	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:28.871531
5547	hexagonal_prism_107	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:28.877249
5529	pentagonal_prism_177	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:29.107109
5530	pentagonal_prism_178	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:29.341029
5532	pentagonal_prism_179	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:29.347247
2252	cylinder_165	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:29.349361
5536	pentagonal_prism_181	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:29.807527
5537	pentagonal_prism_182	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:30.03749
5538	pentagonal_prism_183	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:30.297402
5540	pentagonal_prism_184	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:30.303859
5542	pentagonal_prism_185	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:30.544265
5544	pentagonal_prism_186	black	{0,0,0}	-127.46696	518.69244	662.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:30.778195
5545	pentagonal_prism_187	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:30.783175
5548	pentagonal_prism_189	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:31.2405
5549	pentagonal_prism_190	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:31.473596
5575	pentagonal_prism_207	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:35.429196
5577	pentagonal_prism_208	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:35.667361
5579	pentagonal_prism_209	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:47:35.672691
5581	pentagonal_prism_210	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:35.894897
5583	pentagonal_prism_211	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:47:35.9018
5587	pentagonal_prism_213	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.184704	pentagonal_prism.usd	2025-03-29 14:47:36.132035
5588	pentagonal_prism_214	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:36.364715
5589	pentagonal_prism_215	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:36.596629
5591	pentagonal_prism_216	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:36.831072
5593	pentagonal_prism_217	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:37.077851
5595	pentagonal_prism_218	red	{0,0,0}	32.357	258.856	937.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:37.083043
5597	pentagonal_prism_219	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:37.319784
5598	pentagonal_prism_220	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:37.581673
5599	pentagonal_prism_221	red	{0,0,0}	31.499039	259.86707	920	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:37.588181
5600	pentagonal_prism_222	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:37.814502
2580	cylinder_251	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:48.754297
5552	hexagonal_prism_109	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:29.581982
5554	hexagonal_prism_110	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:29.814224
5556	hexagonal_prism_111	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:30.550864
5566	hexagonal_prism_113	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:31.479045
2288	cylinder_174	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:31.481319
5551	pentagonal_prism_191	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:31.713938
5568	hexagonal_prism_114	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:31.720095
5553	pentagonal_prism_192	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:31.942622
5570	hexagonal_prism_115	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:31.949018
5555	pentagonal_prism_193	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:32.175705
5572	hexagonal_prism_116	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:47:32.18224
5557	pentagonal_prism_194	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:32.404471
5576	hexagonal_prism_117	red	{0,0,0}	30.514694	260.8514	921.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:32.410879
5578	hexagonal_prism_118	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:32.649521
5560	pentagonal_prism_196	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:32.874048
5580	hexagonal_prism_119	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:32.8789
5561	pentagonal_prism_197	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:33.109695
5582	hexagonal_prism_120	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:33.11613
5562	pentagonal_prism_198	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:33.334055
5584	hexagonal_prism_121	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:33.340569
2320	cylinder_182	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:33.342771
5563	pentagonal_prism_199	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:33.558726
5564	pentagonal_prism_200	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:33.79224
5590	hexagonal_prism_123	red	{0,0,0}	32.357	258.856	919	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:33.798924
5565	pentagonal_prism_201	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:34.029297
5592	hexagonal_prism_124	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:34.035856
5567	pentagonal_prism_202	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:34.260694
5594	hexagonal_prism_125	red	{0,0,0}	31.499039	259.86707	925.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:34.265411
5569	pentagonal_prism_203	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:34.494677
5596	hexagonal_prism_126	red	{0,0,0}	32.355774	258.8462	924	0	0	36.869896	hexagonal_prism.usd	2025-03-29 14:47:34.50081
5571	pentagonal_prism_204	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:34.725052
5573	pentagonal_prism_205	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:34.956165
5574	pentagonal_prism_206	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:35.190417
5606	hexagonal_prism_129	red	{0,0,0}	32.357	258.856	934	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:35.436517
5608	hexagonal_prism_130	red	{0,0,0}	31.499039	259.86707	924	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:36.369926
5604	hexagonal_prism_128	red	{0,0,0}	30.514694	260.8514	932.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:35.197023
5610	hexagonal_prism_131	orange	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:36.602744
2376	cylinder_197	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:36.604907
5616	hexagonal_prism_133	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:37.326124
5618	hexagonal_prism_134	red	{0,0,0}	29.53035	261.83575	922.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:37.819131
5603	pentagonal_prism_224	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:38.279141
5605	pentagonal_prism_225	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:38.508697
5620	hexagonal_prism_135	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:38.513893
2404	cylinder_206	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	21.801407	cylinder.usd	2025-03-29 14:47:38.516509
5607	pentagonal_prism_226	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:38.728165
5624	hexagonal_prism_136	red	{0,0,0}	31.499039	259.86707	919	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:47:38.733443
5609	pentagonal_prism_227	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:38.96565
5626	hexagonal_prism_137	red	{0,0,0}	30.395967	260.81702	921.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:38.970316
5630	hexagonal_prism_138	red	{0,0,0}	30.514694	260.8514	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:39.205806
5612	pentagonal_prism_229	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:39.429639
5635	hexagonal_prism_139	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:39.436215
5613	pentagonal_prism_230	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:39.655862
5642	hexagonal_prism_140	red	{0,0,0}	30.514694	260.8514	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:39.66087
5615	pentagonal_prism_231	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:39.893013
5644	hexagonal_prism_141	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:39.898867
5617	pentagonal_prism_232	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:40.12025
2432	cylinder_213	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:40.127001
5646	hexagonal_prism_142	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:40.347743
5621	pentagonal_prism_234	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:40.572061
5622	pentagonal_prism_235	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:40.808066
5650	hexagonal_prism_143	red	{0,0,0}	30.514694	260.8514	924	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:40.815234
5623	pentagonal_prism_236	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:41.046313
5652	hexagonal_prism_144	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:41.051304
5625	pentagonal_prism_237	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:41.273101
5627	pentagonal_prism_238	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:41.507401
2460	cylinder_220	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:41.514885
5629	pentagonal_prism_240	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:41.977115
5631	pentagonal_prism_241	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:42.225631
5632	pentagonal_prism_242	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:42.447293
5633	pentagonal_prism_243	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:42.685478
5634	pentagonal_prism_244	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:42.931738
5636	pentagonal_prism_245	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:43.164306
5637	pentagonal_prism_246	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:43.408995
5639	pentagonal_prism_248	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:43.8825
5640	pentagonal_prism_249	red	{0,0,0}	31.499039	259.86707	929	0	0	36.869896	pentagonal_prism.usd	2025-03-29 14:47:43.889086
5641	pentagonal_prism_250	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:44.115907
5643	pentagonal_prism_251	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:44.3512
5645	pentagonal_prism_252	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:44.583415
5647	pentagonal_prism_253	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:44.818705
5648	pentagonal_prism_254	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:45.04763
5651	pentagonal_prism_256	red	{0,0,0}	30.395967	260.81702	921.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:45.288611
5690	pentagonal_prism_280	red	{0,0,0}	30.395967	260.81702	929	0	0	37.303947	pentagonal_prism.usd	2025-03-29 14:47:49.217067
5656	hexagonal_prism_146	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:41.512577
5659	hexagonal_prism_147	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:41.749894
5661	hexagonal_prism_148	red	{0,0,0}	31.376482	260.81702	928.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:41.983876
5663	hexagonal_prism_149	red	{0,0,0}	31.499039	259.86707	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:42.232408
5668	hexagonal_prism_151	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:42.691292
5670	hexagonal_prism_152	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:42.937543
5674	hexagonal_prism_153	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:43.169638
5678	hexagonal_prism_154	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:43.415872
5680	hexagonal_prism_155	red	{0,0,0}	30.514694	260.8514	916.00006	0	0	37.694237	hexagonal_prism.usd	2025-03-29 14:47:43.649834
2478	cube_227	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03624	cube.usd	2025-03-29 14:47:44.120373
5682	hexagonal_prism_156	red	{0,0,0}	30.514694	260.8514	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:44.122761
5684	hexagonal_prism_157	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:44.357777
5688	hexagonal_prism_158	red	{0,0,0}	31.376482	259.8365	939.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:44.589922
5691	hexagonal_prism_159	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:44.824837
5695	hexagonal_prism_160	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:45.054558
2519	cylinder_235	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:45.056846
5655	pentagonal_prism_258	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:45.532771
5657	pentagonal_prism_259	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:45.753888
5658	pentagonal_prism_260	red	{0,0,0}	32.357	258.856	935.00006	0	0	37.303947	pentagonal_prism.usd	2025-03-29 14:47:45.760013
5660	pentagonal_prism_261	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:45.983975
5697	hexagonal_prism_161	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:45.99026
5662	pentagonal_prism_262	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:46.216904
5699	hexagonal_prism_162	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:46.22191
5664	pentagonal_prism_263	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:46.450283
5704	hexagonal_prism_163	red	{0,0,0}	30.514694	260.8514	922.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:46.456026
5667	pentagonal_prism_265	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:46.687548
5669	pentagonal_prism_266	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:46.915055
5671	pentagonal_prism_267	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:47:46.922303
5672	pentagonal_prism_268	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:47.152914
5673	pentagonal_prism_269	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:47.382541
2538	cube_242	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:47.38649
5675	pentagonal_prism_270	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:47.607573
5676	pentagonal_prism_271	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:47.828575
5679	pentagonal_prism_273	red	{0,0,0}	31.499039	259.86707	926.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:48.056941
5681	pentagonal_prism_274	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:48.286484
5683	pentagonal_prism_275	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:48.521148
5685	pentagonal_prism_276	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:48.746216
5686	pentagonal_prism_277	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:48.972303
5687	pentagonal_prism_278	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:48.978119
5689	pentagonal_prism_279	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:49.21242
5692	pentagonal_prism_281	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:49.444692
5693	pentagonal_prism_282	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:47:49.450143
5694	pentagonal_prism_283	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:49.678411
5696	pentagonal_prism_284	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:49.923931
5698	pentagonal_prism_285	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:50.150009
5700	pentagonal_prism_286	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:50.373777
5701	pentagonal_prism_287	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:50.615215
5703	pentagonal_prism_289	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:50.858313
5253	pentagonal_prism_1	black	{0,0,0}	-347.39508	188.27647	654.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:53.917285
5261	pentagonal_prism_6	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:55.104123
5269	pentagonal_prism_11	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:46:56.265341
1671	cylinder_14	green	{0,0,0}	-270.62216	216.69383	916.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:46:56.506148
5277	pentagonal_prism_17	red	{0,0,0}	31.499039	259.86707	924	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:46:57.201119
5295	hexagonal_prism_14	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.234837	hexagonal_prism.usd	2025-03-29 14:46:57.895554
5287	pentagonal_prism_24	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.694237	pentagonal_prism.usd	2025-03-29 14:46:58.592526
5294	pentagonal_prism_29	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:46:59.499951
1724	cylinder_28	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:46:59.732384
5303	pentagonal_prism_35	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:00.662573
1760	cylinder_38	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	21.801407	cylinder.usd	2025-03-29 14:47:01.607187
5313	pentagonal_prism_41	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:02.074921
5322	pentagonal_prism_47	orange	{0,0,0}	31.376482	259.8365	917.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:03.01288
1782	cube_42	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:03.246261
5333	pentagonal_prism_53	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:04.170558
5346	hexagonal_prism_35	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:05.095968
1818	cube_51	pink	{0,0,0}	-207.6968	346.48944	915	0	0	60.255116	cube.usd	2025-03-29 14:47:05.329116
5349	pentagonal_prism_61	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:05.556507
1844	cylinder_59	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:06.475562
5357	pentagonal_prism_67	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:06.713413
5367	pentagonal_prism_72	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:07.889695
5710	hexagonal_prism_165	red	{0,0,0}	31.376482	259.8365	920	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:47.613901
5712	hexagonal_prism_166	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:47.833574
5718	hexagonal_prism_167	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:48.293128
5724	hexagonal_prism_168	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:48.527524
2576	cylinder_250	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:48.5299
5729	hexagonal_prism_169	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:48.752114
5731	hexagonal_prism_170	orange	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:47:49.684876
5733	hexagonal_prism_171	orange	{0,0,0}	31.376482	259.8365	924	0	0	36.869896	hexagonal_prism.usd	2025-03-29 14:47:49.929887
2594	cube_257	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:47:50.855759
5705	pentagonal_prism_290	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:51.077811
5706	pentagonal_prism_291	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:51.303218
5709	pentagonal_prism_293	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:51.759476
5711	pentagonal_prism_294	orange	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:51.764885
5713	pentagonal_prism_295	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:51.998404
2636	cylinder_265	green	{0,0,0}	-272.66354	217.54024	935.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:47:52.007239
5714	pentagonal_prism_296	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:52.223702
5715	pentagonal_prism_297	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:52.469391
5716	pentagonal_prism_298	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:52.69724
5719	pentagonal_prism_300	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:53.144019
5720	pentagonal_prism_301	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:53.37742
5721	pentagonal_prism_302	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:53.6072
5722	pentagonal_prism_303	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:53.842765
5723	pentagonal_prism_304	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:54.078278
5725	pentagonal_prism_305	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:54.305404
5726	pentagonal_prism_306	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:54.543558
5728	pentagonal_prism_308	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:54.775468
5730	pentagonal_prism_309	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:55.010177
5732	pentagonal_prism_310	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:55.245706
5372	hexagonal_prism_46	red	{0,0,0}	32.357	258.856	933	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:08.82734
1904	cylinder_74	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:09.789676
5389	pentagonal_prism_84	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:10.000614
5397	pentagonal_prism_89	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:10.945665
5404	pentagonal_prism_93	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:11.640061
5392	hexagonal_prism_55	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:12.361492
5414	pentagonal_prism_100	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:13.041839
1954	cube_86	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:47:13.046043
5422	pentagonal_prism_106	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:14.194394
5431	pentagonal_prism_111	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:15.357067
2010	cube_100	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:47:16.060371
5439	pentagonal_prism_117	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:16.547143
5449	pentagonal_prism_123	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:17.707112
5440	hexagonal_prism_71	red	{0,0,0}	31.375294	259.82666	934	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:17.712331
2052	cylinder_112	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:18.187258
5455	pentagonal_prism_127	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:18.631891
2072	cylinder_117	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:19.110313
5461	pentagonal_prism_132	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:19.801527
5471	hexagonal_prism_82	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:20.956004
2110	cube_126	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.743565	cube.usd	2025-03-29 14:47:21.651219
5480	hexagonal_prism_84	orange	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:21.887702
2132	cylinder_132	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:47:22.360002
5495	hexagonal_prism_89	red	{0,0,0}	31.376482	259.8365	934	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:47:23.059192
5501	hexagonal_prism_90	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:23.535158
5497	pentagonal_prism_156	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:24.689734
2172	cylinder_142	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:47:24.697075
2158	cube_140	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.420776	cube.usd	2025-03-29 14:47:24.921372
5527	hexagonal_prism_100	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:25.857243
2178	cube_145	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:47:26.088418
5535	hexagonal_prism_103	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:27.011444
2214	cube_154	pink	{0,0,0}	-207.6968	346.48944	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:47:28.175256
5523	pentagonal_prism_173	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:28.405679
2240	cylinder_162	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:28.645092
5550	hexagonal_prism_108	red	{0,0,0}	31.376482	259.8365	934	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:29.113974
5534	pentagonal_prism_180	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:29.575494
5546	pentagonal_prism_188	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:31.007592
5558	hexagonal_prism_112	orange	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:31.013821
2280	cylinder_172	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:31.015991
5559	pentagonal_prism_195	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:32.642968
2312	cylinder_180	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:47:32.881159
5586	hexagonal_prism_122	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:33.564822
5602	hexagonal_prism_127	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:34.730263
2344	cylinder_188	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:34.73247
5734	hexagonal_prism_172	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:50.15609
5735	hexagonal_prism_173	red	{0,0,0}	32.357	258.856	920	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:50.379919
5736	hexagonal_prism_174	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:50.620307
5702	pentagonal_prism_288	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:50.852083
2616	cylinder_260	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	cylinder.usd	2025-03-29 14:47:50.860992
5737	hexagonal_prism_175	red	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:51.082922
5738	hexagonal_prism_176	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:51.30843
5707	pentagonal_prism_292	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:51.53383
5739	hexagonal_prism_177	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:51.540073
5740	hexagonal_prism_178	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:52.005097
5741	hexagonal_prism_179	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:52.229136
2640	cylinder_266	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:47:52.231235
5742	hexagonal_prism_180	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:52.476007
5743	hexagonal_prism_181	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:52.703726
5717	pentagonal_prism_299	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:52.920885
5744	hexagonal_prism_182	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.234837	hexagonal_prism.usd	2025-03-29 14:47:52.926146
5745	hexagonal_prism_183	red	{0,0,0}	30.514694	260.8514	930.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:53.149219
2652	cylinder_270	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:53.151225
5746	hexagonal_prism_184	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:53.382128
5747	hexagonal_prism_185	red	{0,0,0}	31.376482	259.8365	924	0	0	37.694237	hexagonal_prism.usd	2025-03-29 14:47:53.613737
5748	hexagonal_prism_186	red	{0,0,0}	30.514694	260.8514	930.00006	0	0	37.234837	hexagonal_prism.usd	2025-03-29 14:47:53.849157
5749	hexagonal_prism_187	red	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:54.084562
5750	hexagonal_prism_188	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:54.312104
5727	pentagonal_prism_307	red	{0,0,0}	32.357	258.856	933	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:54.548776
5751	hexagonal_prism_189	orange	{0,0,0}	30.514694	260.8514	929	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:54.781441
5752	hexagonal_prism_190	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:55.016766
5753	hexagonal_prism_191	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:55.251913
2684	cylinder_279	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:55.253921
5754	pentagonal_prism_311	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:55.475937
5755	hexagonal_prism_192	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:55.482371
5756	pentagonal_prism_312	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:55.713055
5757	hexagonal_prism_193	red	{0,0,0}	31.499039	259.86707	934	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:55.719281
2692	cylinder_281	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:55.721182
5758	pentagonal_prism_313	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:55.943778
5759	pentagonal_prism_314	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:56.182253
5760	hexagonal_prism_194	red	{0,0,0}	31.499039	259.86707	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:56.186862
5761	pentagonal_prism_315	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:56.411117
5762	hexagonal_prism_195	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:56.417311
5763	pentagonal_prism_316	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:56.644876
5764	hexagonal_prism_196	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:56.651371
2712	cylinder_286	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:47:56.653336
5765	pentagonal_prism_317	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:56.87618
5766	hexagonal_prism_197	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:56.882363
5767	pentagonal_prism_318	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:57.116917
5768	hexagonal_prism_198	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:57.12297
5769	pentagonal_prism_319	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:57.34488
5770	hexagonal_prism_199	red	{0,0,0}	30.395967	260.81702	931.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:57.351234
5771	pentagonal_prism_320	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:57.577514
5772	hexagonal_prism_200	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:57.58264
5773	pentagonal_prism_321	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:57.811718
5774	pentagonal_prism_322	red	{0,0,0}	31.376482	260.81702	928.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:47:57.816414
5775	pentagonal_prism_323	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:58.076934
5776	hexagonal_prism_201	red	{0,0,0}	30.395967	260.81702	926.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:47:58.082702
5777	pentagonal_prism_324	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:58.31157
5778	pentagonal_prism_325	red	{0,0,0}	31.499039	259.86707	929	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:47:58.317388
5779	pentagonal_prism_326	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:58.546511
5780	hexagonal_prism_202	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:47:58.552196
5781	pentagonal_prism_327	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:58.78098
5782	hexagonal_prism_203	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:58.787569
2744	cylinder_295	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:47:58.789479
5783	pentagonal_prism_328	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:59.014853
5784	hexagonal_prism_204	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:59.020949
5785	pentagonal_prism_329	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:59.244915
5786	hexagonal_prism_205	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:59.249829
2752	cylinder_297	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:47:59.251879
5787	pentagonal_prism_330	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:59.476579
5788	hexagonal_prism_206	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:47:59.482998
5789	pentagonal_prism_331	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:59.713478
5790	hexagonal_prism_207	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:47:59.71995
5791	pentagonal_prism_332	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:47:59.944752
5792	hexagonal_prism_208	orange	{0,0,0}	31.376482	259.8365	934	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:47:59.951177
5793	pentagonal_prism_333	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:00.18346
5794	pentagonal_prism_334	red	{0,0,0}	32.357	258.856	924	0	0	36.869896	pentagonal_prism.usd	2025-03-29 14:48:00.188034
2767	cylinder_301	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:48:00.189947
5795	pentagonal_prism_335	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:00.41755
5796	hexagonal_prism_209	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.694237	hexagonal_prism.usd	2025-03-29 14:48:00.423901
5797	pentagonal_prism_336	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:00.645093
5798	hexagonal_prism_210	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:00.652216
5799	pentagonal_prism_337	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:00.890629
5800	hexagonal_prism_211	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:48:00.89702
5801	pentagonal_prism_338	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:01.125874
5802	hexagonal_prism_212	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:01.131955
5803	pentagonal_prism_339	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:01.357726
5804	hexagonal_prism_213	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:01.362569
5805	pentagonal_prism_340	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:01.584043
5806	pentagonal_prism_341	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:01.811902
5807	hexagonal_prism_214	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:01.818302
5808	pentagonal_prism_342	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:02.049483
5809	pentagonal_prism_343	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:02.274276
2786	cube_307	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:48:02.276941
5810	hexagonal_prism_215	red	{0,0,0}	30.395967	260.81702	935.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:02.279354
5811	pentagonal_prism_344	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:02.498165
5812	hexagonal_prism_216	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:02.50444
2808	cylinder_312	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:02.506677
5813	pentagonal_prism_345	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:02.726312
5814	hexagonal_prism_217	red	{0,0,0}	31.376482	259.8365	929	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:48:02.732286
5815	pentagonal_prism_346	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:02.948784
5816	hexagonal_prism_218	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:02.954274
5817	pentagonal_prism_347	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:03.181306
5818	hexagonal_prism_219	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:48:03.187992
5819	pentagonal_prism_348	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:03.419508
5820	hexagonal_prism_220	red	{0,0,0}	31.376482	259.8365	933	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:48:03.426093
5821	pentagonal_prism_349	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:03.653663
2810	cube_313	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:48:03.657213
5822	pentagonal_prism_350	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:48:03.659387
5823	pentagonal_prism_351	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:03.880562
5824	hexagonal_prism_221	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:03.887065
5825	pentagonal_prism_352	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:04.119839
5826	pentagonal_prism_353	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:48:04.125813
5827	pentagonal_prism_354	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:04.357286
5828	pentagonal_prism_355	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:48:04.362293
5829	pentagonal_prism_356	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:04.584432
5830	hexagonal_prism_222	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:04.589455
5831	pentagonal_prism_357	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:04.814311
5832	pentagonal_prism_358	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:05.055213
5833	pentagonal_prism_359	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:05.281687
5834	hexagonal_prism_223	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:05.288387
5835	pentagonal_prism_360	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:05.514018
5836	hexagonal_prism_224	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:05.520341
2860	cylinder_325	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:48:05.5225
5837	pentagonal_prism_361	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:05.737192
5838	hexagonal_prism_225	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:05.741795
5839	pentagonal_prism_362	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:05.974189
5840	pentagonal_prism_363	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:48:05.980516
2868	cylinder_327	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:05.982613
5841	pentagonal_prism_364	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:06.202787
5842	hexagonal_prism_226	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:06.207644
5843	pentagonal_prism_365	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:06.436571
5844	hexagonal_prism_227	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:48:06.442658
5845	pentagonal_prism_366	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:06.6742
5846	hexagonal_prism_228	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:48:06.680331
5847	pentagonal_prism_367	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:06.907544
5848	hexagonal_prism_229	red	{0,0,0}	31.499039	259.86707	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:06.913629
2880	cylinder_331	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:48:06.915794
5849	pentagonal_prism_368	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:07.140136
5850	hexagonal_prism_230	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:07.145189
5851	pentagonal_prism_369	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:07.369849
5852	hexagonal_prism_231	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:07.375852
5853	pentagonal_prism_370	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:07.604497
5854	hexagonal_prism_232	red	{0,0,0}	30.514694	260.8514	922.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:07.610574
5855	pentagonal_prism_371	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:07.834324
5856	hexagonal_prism_233	red	{0,0,0}	31.376482	259.8365	934	0	0	37.694237	hexagonal_prism.usd	2025-03-29 14:48:07.841116
5857	pentagonal_prism_372	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:08.07404
5858	hexagonal_prism_234	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:48:08.078955
5859	pentagonal_prism_373	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:08.306701
5860	hexagonal_prism_235	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:48:08.313091
5861	pentagonal_prism_374	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:08.540257
5862	hexagonal_prism_236	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:08.546288
5863	pentagonal_prism_375	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:08.771881
5864	pentagonal_prism_376	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:48:08.776568
5865	pentagonal_prism_377	black	{0,0,0}	-128.94919	520.7185	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:09.001679
5866	hexagonal_prism_237	red	{0,0,0}	30.514694	260.8514	925.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:48:09.008188
2908	cylinder_340	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:48:09.010247
5867	pentagonal_prism_378	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:09.234535
5868	pentagonal_prism_379	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:09.473137
5869	pentagonal_prism_380	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:09.708593
5870	hexagonal_prism_238	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:09.713771
2924	cylinder_344	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:09.715824
5871	pentagonal_prism_381	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:09.937985
5872	hexagonal_prism_239	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:09.944603
5873	pentagonal_prism_382	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:10.173874
5874	pentagonal_prism_383	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:10.411092
5875	hexagonal_prism_240	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:48:10.417431
2940	cylinder_348	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:10.419552
5876	pentagonal_prism_384	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:10.639124
5877	hexagonal_prism_241	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:48:10.645473
5878	pentagonal_prism_385	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:10.871405
5879	hexagonal_prism_242	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:10.876279
5880	pentagonal_prism_386	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:11.106427
5881	hexagonal_prism_243	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:11.111545
5882	pentagonal_prism_387	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:11.340655
5883	pentagonal_prism_388	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:11.576252
5884	hexagonal_prism_244	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:11.582248
5885	pentagonal_prism_389	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:11.808511
5886	hexagonal_prism_245	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:11.814799
5887	pentagonal_prism_390	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:12.049174
5888	hexagonal_prism_246	red	{0,0,0}	30.514694	260.8514	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:12.055262
5889	pentagonal_prism_391	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:12.274888
5890	hexagonal_prism_247	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:12.280943
5891	pentagonal_prism_392	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:12.506218
5892	hexagonal_prism_248	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:12.511517
2976	cylinder_357	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	cylinder.usd	2025-03-29 14:48:12.513573
5893	pentagonal_prism_393	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:12.741941
5894	hexagonal_prism_249	red	{0,0,0}	32.355774	258.8462	937.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:12.748148
5895	pentagonal_prism_394	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:12.970472
5896	hexagonal_prism_250	red	{0,0,0}	31.376482	260.81702	938	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:12.977251
2983	cylinder_359	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:48:12.979526
5897	pentagonal_prism_395	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:13.206137
5898	hexagonal_prism_251	red	{0,0,0}	30.514694	260.8514	917.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:13.212835
5899	pentagonal_prism_396	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:13.442663
5900	hexagonal_prism_252	red	{0,0,0}	30.395967	260.81702	922.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:13.449298
5901	pentagonal_prism_397	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:13.674343
5902	hexagonal_prism_253	red	{0,0,0}	30.395967	260.81702	923.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:48:13.679525
5903	pentagonal_prism_398	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:13.907609
5904	hexagonal_prism_254	red	{0,0,0}	30.514694	260.8514	930.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:48:13.914087
2996	cylinder_363	green	{0,0,0}	-272.66354	217.54024	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:48:13.916212
5905	pentagonal_prism_399	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:14.144094
5906	pentagonal_prism_400	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.303947	pentagonal_prism.usd	2025-03-29 14:48:14.150365
5907	pentagonal_prism_401	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:14.374913
5908	pentagonal_prism_402	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:48:14.381191
5909	pentagonal_prism_403	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:48:14.609224
5910	hexagonal_prism_255	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:48:14.61558
5911	pentagonal_prism_404	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:14.844247
5912	pentagonal_prism_405	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:48:15.072163
5913	hexagonal_prism_256	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:48:15.078213
\.


--
-- Data for Name: drop_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.drop_op_parameters (sequence_id, operation_order, object_id, drop_height, operation_status) FROM stdin;
13	1	Slide_1	0	t
14	2	Slide_2	0	t
\.


--
-- Data for Name: gesture_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.gesture_instructions (id, session_id, "timestamp", gesture_text, natural_description, confidence, hand_label, processed) FROM stdin;
\.


--
-- Data for Name: gesture_library; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.gesture_library (id, gesture_type, gesture_text, natural_description, config) FROM stdin;
\.


--
-- Data for Name: instruction_operation_sequence; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.instruction_operation_sequence (task_id, instruction_id, skill_id, skill_name, sequence_id, sequence_name, object_id, object_name, status, created_at) FROM stdin;
\.


--
-- Data for Name: instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.instructions (id, "timestamp", user_id, modality, language, instruction_type, processed, content, sync_id, confidence) FROM stdin;
1	2025-03-28 13:01:34.310472	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-03-28 13:01:34.310472	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-28 13:01:34.310472
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-28 13:01:34.310472
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-03-28 13:01:34.310472
\.


--
-- Data for Name: isaac_sim_gui; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.isaac_sim_gui (sequence_id, gui_feature, operation_status) FROM stdin;
1	Start	false
2	Reset	false
3	Load	false
\.


--
-- Data for Name: lift_state_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.lift_state_parameters (sequence_id, operation_order, object_id, lift_height, operation_status) FROM stdin;
\.


--
-- Data for Name: operation_library; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.operation_library (id, operation_name, task_order) FROM stdin;
1	slide_sorting	pick, travel, drop
2	cube_sorting	pick, travel, drop
\.


--
-- Data for Name: operation_sequence; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.operation_sequence (id, operation_id, sequence_id, sequence_name, object_name, command_id, processed, execution_time) FROM stdin;
42	1	1	pick	Slide_1	6	f	2025-03-28 14:00:09.771762
43	2	2	travel	Slide_1	6	f	2025-03-28 14:00:09.771762
44	3	3	drop	Slide_1	6	f	2025-03-28 14:00:09.771762
45	4	1	pick	Slide_2	6	f	2025-03-28 14:00:09.771762
46	5	2	travel	Slide_2	6	f	2025-03-28 14:00:09.771762
47	6	3	drop	Slide_2	6	f	2025-03-28 14:00:09.771762
48	7	6	go_home		6	f	2025-03-28 14:00:09.771762
\.


--
-- Data for Name: pick_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.pick_op_parameters (sequence_id, operation_order, object_id, slide_state_status, slide_direction, distance_travel, operation_status) FROM stdin;
13	1	Slide_1	t	y	0.01	t
14	2	Slide_2	t	y	0.01	t
\.


--
-- Data for Name: rotate_state_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.rotate_state_parameters (sequence_id, operation_order, object_id, rotation_angle, operation_status) FROM stdin;
\.


--
-- Data for Name: screw_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.screw_op_parameters (sequence_id, operation_order, object_id, rotation_dir, number_of_rotations, current_rotation, operation_status) FROM stdin;
\.


--
-- Data for Name: sequence_library; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.sequence_library (sequence_id, sequence_name, skill_name, node_name, description, conditions, post_conditions, is_runnable_count, is_runnable_condition, is_runnable_exit) FROM stdin;
1	pick	\N	PickBlockRd	Pick up an object	gripper is clear	object in gripper	1	aaa	f
2	travel	\N	ReachToPlacementRd	Move to the target location	object in gripper	at target location	1	aaa	f
3	drop	\N	DropRd	Drop the object	at target location	object dropped	1	aaa	f
4	screw	\N	ScrewRd	Screw the object two times	task complete	robot at home position	1	thresh_met and self.context.gripper_has_block	t
5	rotate	\N	RotateRd	Rotate the object once	task complete	robot at home position	1	thresh_met and self.context.gripper_has_block	t
6	go_home	\N	GoHome	Return to the home position	task complete	robot at home position	1	aaa	f
\.


--
-- Data for Name: simulation_results; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.simulation_results (simulation_id, instruction_id, success, metrics, error_log, "timestamp") FROM stdin;
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-03-28 13:01:34.310472
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-03-28 13:01:34.310472
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.skills (skill_id, skill_name, description, parameters, required_capabilities, average_duration) FROM stdin;
1	pick	Pick up object	{"gripper_force": 0.5}	{"gripper": true}	2.5
2	place	Place object	{"precision": 0.01}	{"vision": true}	3
\.


--
-- Data for Name: slide_state_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.slide_state_parameters (sequence_id, operation_order, object_id, lift_distance, pos_x, pos_y, pos_z, operation_status) FROM stdin;
\.


--
-- Data for Name: sort_order; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.sort_order (order_id, object_name, object_color) FROM stdin;
13	Slide_1	green
14	Slide_2	pink
\.


--
-- Data for Name: states; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.states (task_id, task_name, description, conditions, post_conditions, sequence_id) FROM stdin;
1	LiftState	Lift an object vertically	gripper is clear	object in gripper	1
2	SlideState	Slide an object along X-axis	object in gripper	at target location	1
\.


--
-- Data for Name: task_history; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.task_history (id, command_text, generated_plan, created_at) FROM stdin;
\.


--
-- Data for Name: task_preferences; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.task_preferences (preference_id, user_id, task_id, task_name, preference_data) FROM stdin;
1	1	\N	Pick Object	{"time": "morning", "location": "shelf"}
2	2	\N	Place Object	{"time": "afternoon", "location": "table"}
3	1	\N	Inspect Object	{"tools": ["camera", "gripper"]}
\.


--
-- Data for Name: task_templates; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.task_templates (task_id, task_name, description, default_sequence) FROM stdin;
1	sort	Default sorting task: pick, move, drop	{pick,travel,drop}
2	assemble	Assembly involves pick and screw	{pick,travel,screw,go_home}
3	inspect	Inspect task involves scan and return	{travel,inspect,go_home}
4	cleanup	Cleanup task involves pick, rotate, drop	{pick,rotate,drop}
\.


--
-- Data for Name: travel_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.travel_op_parameters (sequence_id, operation_order, object_id, travel_height, gripper_rotation, operation_status) FROM stdin;
13	1	Slide_1	0.085	y-axis	t
14	2	Slide_2	0.085	y-axis	t
\.


--
-- Data for Name: unified_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.unified_instructions (id, session_id, "timestamp", liu_id, voice_command, gesture_command, unified_command, confidence, processed) FROM stdin;
1	session_voice_001	2025-03-28 13:03:25.019311	oscik559	 Could you sort the slides in the order of green, pink and pink?		 Could you sort the slides in the order of green, pink and pink?	0.95	t
2	session_voice_001	2025-03-28 13:19:28.346091	oscik559	 Could you sort the slides in the order of green, pink and pink?		 Could you sort the slides in the order of green, pink and pink?	0.95	t
3	session_voice_001	2025-03-28 13:30:37.0437	oscik559	 Could you sort the slides in order of green, pink and pink?		 Could you sort the slides in order of green, pink and pink?	0.95	t
4	session_voice_001	2025-03-28 13:40:01.780159	oscik559	 Could you sort the slides in order of green, pink and pink?		 Could you sort the slides in order of green, pink and pink?	0.95	t
5	session_voice_001	2025-03-28 13:53:22.848338	oscik559	 Could you sort the slides in the order green and pink?		 Could you sort the slides in the order green and pink?	0.95	t
6	session_voice_001	2025-03-28 14:00:09.737684	oscik559	 Could you help me sort the slides in the order green and pink?		 Could you help me sort the slides in the order green and pink?	0.95	t
\.


--
-- Data for Name: usd_data; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.usd_data (sequence_id, usd_name, type_of_usd, repository, scale_x, scale_y, scale_z, prim_path, initial_pos_x, initial_pos_y, initial_pos_z, register_obstacle) FROM stdin;
1	Fixture.usd	GeometryPrim	/fixture_description/Slide_Fixture.usd	0.1	0.1	0.1	/World/fixtureprim	0.2	-0.07	0.094	f
2	Slide_Holder.usd	GeometryPrim	/fixture_description/Slide_Holder.usd	0.1	0.1	0.1	/World/fixtureprim	40	17	8	f
3	Cuboid.usd	DynamicCuboid	/basicshapes/cuboid.usd	0.0825	0.0825	0.0825	/World/fixtureprim/Fixture	0	0	0	f
4	Cylinder.usd	DynamicCuboid	/basicshapes/cylinder.usd	0.0825	0.0825	0.0825	/World/fixtureprim/Fixture	0	0	0	f
5	Slide.usd	DynamicCuboid	aaa	75	24.4	2	/World/fixtureprim/Fixture	0	0	0	t
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.users (user_id, first_name, last_name, liu_id, email, preferences, profile_image_path, interaction_memory, face_encoding, voice_embedding, created_at, last_updated) FROM stdin;
1	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscar.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	2025-03-28 13:01:34.310472	2025-03-28 13:01:34.310472
2	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahul.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\N	\N	2025-03-28 13:01:34.310472	2025-03-28 13:01:34.310472
3	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanjay.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	2025-03-28 13:01:34.310472	2025-03-28 13:01:34.310472
4	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehdi.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	2025-03-28 13:01:34.310472	2025-03-28 13:01:34.310472
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
1	4099d140-2d98-473f-94ab-cf0f052be36d	 Could you sort the slides in the order of green, pink and pink?	\N	english	f	2025-03-28 13:03:24.953618
2	8ed6df33-f969-42d2-baaf-58a2efaf4f7b	 Could you sort the slides in order of green, pink and pink?	\N	english	f	2025-03-28 13:30:36.858882
3	5f61fdfc-d012-4608-9944-7dd3ba6b8298	 Could you sort the slides in the order green and pink?	\N	english	f	2025-03-28 13:53:22.784267
4	81cd6246-9526-43a2-89ee-20e889fab7a8	 Could you help me sort the slides in the order green and pink?	\N	english	f	2025-03-28 14:00:09.672379
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 5913, true);


--
-- Name: drop_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.drop_op_parameters_sequence_id_seq', 14, true);


--
-- Name: gesture_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.gesture_instructions_id_seq', 1, false);


--
-- Name: gesture_library_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.gesture_library_id_seq', 1, false);


--
-- Name: instruction_operation_sequence_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.instruction_operation_sequence_task_id_seq', 1, false);


--
-- Name: instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.instructions_id_seq', 2, true);


--
-- Name: interaction_memory_interaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.interaction_memory_interaction_id_seq', 3, true);


--
-- Name: isaac_sim_gui_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.isaac_sim_gui_sequence_id_seq', 3, true);


--
-- Name: lift_state_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.lift_state_parameters_sequence_id_seq', 1, false);


--
-- Name: operation_library_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.operation_library_id_seq', 2, true);


--
-- Name: operation_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.operation_sequence_id_seq', 48, true);


--
-- Name: pick_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.pick_op_parameters_sequence_id_seq', 14, true);


--
-- Name: rotate_state_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.rotate_state_parameters_sequence_id_seq', 1, false);


--
-- Name: screw_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.screw_op_parameters_sequence_id_seq', 1, false);


--
-- Name: sequence_library_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.sequence_library_sequence_id_seq', 6, true);


--
-- Name: simulation_results_simulation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.simulation_results_simulation_id_seq', 2, true);


--
-- Name: skills_skill_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.skills_skill_id_seq', 2, true);


--
-- Name: slide_state_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.slide_state_parameters_sequence_id_seq', 1, false);


--
-- Name: sort_order_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.sort_order_order_id_seq', 14, true);


--
-- Name: states_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.states_task_id_seq', 2, true);


--
-- Name: task_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.task_history_id_seq', 1, false);


--
-- Name: task_preferences_preference_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.task_preferences_preference_id_seq', 3, true);


--
-- Name: task_templates_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.task_templates_task_id_seq', 4, true);


--
-- Name: travel_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.travel_op_parameters_sequence_id_seq', 14, true);


--
-- Name: unified_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.unified_instructions_id_seq', 6, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.users_user_id_seq', 4, true);


--
-- Name: voice_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.voice_instructions_id_seq', 4, true);


--
-- Name: access_logs access_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT access_logs_pkey PRIMARY KEY (log_id);


--
-- Name: camera_vision camera_vision_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.camera_vision
    ADD CONSTRAINT camera_vision_pkey PRIMARY KEY (object_id);


--
-- Name: drop_op_parameters drop_op_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.drop_op_parameters
    ADD CONSTRAINT drop_op_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: gesture_instructions gesture_instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.gesture_instructions
    ADD CONSTRAINT gesture_instructions_pkey PRIMARY KEY (id);


--
-- Name: gesture_library gesture_library_gesture_type_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.gesture_library
    ADD CONSTRAINT gesture_library_gesture_type_key UNIQUE (gesture_type);


--
-- Name: gesture_library gesture_library_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.gesture_library
    ADD CONSTRAINT gesture_library_pkey PRIMARY KEY (id);


--
-- Name: instruction_operation_sequence instruction_operation_sequence_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence
    ADD CONSTRAINT instruction_operation_sequence_pkey PRIMARY KEY (task_id);


--
-- Name: instructions instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instructions
    ADD CONSTRAINT instructions_pkey PRIMARY KEY (id);


--
-- Name: instructions instructions_sync_id_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instructions
    ADD CONSTRAINT instructions_sync_id_key UNIQUE (sync_id);


--
-- Name: interaction_memory interaction_memory_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.interaction_memory
    ADD CONSTRAINT interaction_memory_pkey PRIMARY KEY (interaction_id);


--
-- Name: isaac_sim_gui isaac_sim_gui_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.isaac_sim_gui
    ADD CONSTRAINT isaac_sim_gui_pkey PRIMARY KEY (sequence_id);


--
-- Name: lift_state_parameters lift_state_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.lift_state_parameters
    ADD CONSTRAINT lift_state_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: operation_library operation_library_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_library
    ADD CONSTRAINT operation_library_pkey PRIMARY KEY (id);


--
-- Name: operation_sequence operation_sequence_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_sequence
    ADD CONSTRAINT operation_sequence_pkey PRIMARY KEY (id);


--
-- Name: pick_op_parameters pick_op_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.pick_op_parameters
    ADD CONSTRAINT pick_op_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: rotate_state_parameters rotate_state_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.rotate_state_parameters
    ADD CONSTRAINT rotate_state_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: screw_op_parameters screw_op_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.screw_op_parameters
    ADD CONSTRAINT screw_op_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: sequence_library sequence_library_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.sequence_library
    ADD CONSTRAINT sequence_library_pkey PRIMARY KEY (sequence_id);


--
-- Name: simulation_results simulation_results_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.simulation_results
    ADD CONSTRAINT simulation_results_pkey PRIMARY KEY (simulation_id);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (skill_id);


--
-- Name: skills skills_skill_name_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_skill_name_key UNIQUE (skill_name);


--
-- Name: slide_state_parameters slide_state_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.slide_state_parameters
    ADD CONSTRAINT slide_state_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: sort_order sort_order_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.sort_order
    ADD CONSTRAINT sort_order_pkey PRIMARY KEY (order_id);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (task_id);


--
-- Name: task_history task_history_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_history
    ADD CONSTRAINT task_history_pkey PRIMARY KEY (id);


--
-- Name: task_preferences task_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_preferences
    ADD CONSTRAINT task_preferences_pkey PRIMARY KEY (preference_id);


--
-- Name: task_templates task_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_templates
    ADD CONSTRAINT task_templates_pkey PRIMARY KEY (task_id);


--
-- Name: task_templates task_templates_task_name_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_templates
    ADD CONSTRAINT task_templates_task_name_key UNIQUE (task_name);


--
-- Name: travel_op_parameters travel_op_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.travel_op_parameters
    ADD CONSTRAINT travel_op_parameters_pkey PRIMARY KEY (sequence_id);


--
-- Name: unified_instructions unified_instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.unified_instructions
    ADD CONSTRAINT unified_instructions_pkey PRIMARY KEY (id);


--
-- Name: usd_data usd_data_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.usd_data
    ADD CONSTRAINT usd_data_pkey PRIMARY KEY (sequence_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_liu_id_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_liu_id_key UNIQUE (liu_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: voice_instructions voice_instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.voice_instructions
    ADD CONSTRAINT voice_instructions_pkey PRIMARY KEY (id);


--
-- Name: idx_camera_vision_last_detected; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_camera_vision_last_detected ON public.camera_vision USING btree (last_detected);


--
-- Name: idx_conv_memory_instruction; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_conv_memory_instruction ON public.interaction_memory USING btree (instruction_id);


--
-- Name: idx_interaction_memory_user_id; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_interaction_memory_user_id ON public.interaction_memory USING btree (user_id);


--
-- Name: idx_operation_sequence_object; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_operation_sequence_object ON public.instruction_operation_sequence USING btree (object_id);


--
-- Name: idx_simulation_instruction; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_simulation_instruction ON public.simulation_results USING btree (instruction_id);


--
-- Name: idx_skills_name; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_skills_name ON public.skills USING btree (skill_name);


--
-- Name: idx_task_preferences_user_id; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_task_preferences_user_id ON public.task_preferences USING btree (user_id);


--
-- Name: idx_task_templates_name; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_task_templates_name ON public.task_templates USING btree (task_name);


--
-- Name: idx_task_templates_sequence; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_task_templates_sequence ON public.task_templates USING btree (default_sequence);


--
-- Name: idx_unified_instructions_session_id; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_unified_instructions_session_id ON public.unified_instructions USING btree (session_id);


--
-- Name: idx_user_prefs_task; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_user_prefs_task ON public.task_preferences USING btree (user_id, task_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_liu_id; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_users_liu_id ON public.users USING btree (liu_id);


--
-- Name: idx_voice_processed; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_voice_processed ON public.voice_instructions USING btree (processed);


--
-- Name: idx_voice_session_id; Type: INDEX; Schema: public; Owner: oscar
--

CREATE INDEX idx_voice_session_id ON public.voice_instructions USING btree (session_id);


--
-- Name: access_logs access_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT access_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: instruction_operation_sequence instruction_operation_sequence_instruction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence
    ADD CONSTRAINT instruction_operation_sequence_instruction_id_fkey FOREIGN KEY (instruction_id) REFERENCES public.instructions(id) ON DELETE CASCADE;


--
-- Name: instruction_operation_sequence instruction_operation_sequence_object_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence
    ADD CONSTRAINT instruction_operation_sequence_object_id_fkey FOREIGN KEY (object_id) REFERENCES public.camera_vision(object_id);


--
-- Name: instruction_operation_sequence instruction_operation_sequence_sequence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence
    ADD CONSTRAINT instruction_operation_sequence_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES public.sequence_library(sequence_id);


--
-- Name: instruction_operation_sequence instruction_operation_sequence_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instruction_operation_sequence
    ADD CONSTRAINT instruction_operation_sequence_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(skill_id);


--
-- Name: instructions instructions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.instructions
    ADD CONSTRAINT instructions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: interaction_memory interaction_memory_instruction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.interaction_memory
    ADD CONSTRAINT interaction_memory_instruction_id_fkey FOREIGN KEY (instruction_id) REFERENCES public.instructions(id) ON DELETE CASCADE;


--
-- Name: interaction_memory interaction_memory_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.interaction_memory
    ADD CONSTRAINT interaction_memory_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: operation_sequence operation_sequence_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_sequence
    ADD CONSTRAINT operation_sequence_command_id_fkey FOREIGN KEY (command_id) REFERENCES public.unified_instructions(id);


--
-- Name: operation_sequence operation_sequence_sequence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_sequence
    ADD CONSTRAINT operation_sequence_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES public.sequence_library(sequence_id);


--
-- Name: simulation_results simulation_results_instruction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.simulation_results
    ADD CONSTRAINT simulation_results_instruction_id_fkey FOREIGN KEY (instruction_id) REFERENCES public.instructions(id) ON DELETE CASCADE;


--
-- Name: states states_sequence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES public.sequence_library(sequence_id) ON DELETE CASCADE;


--
-- Name: task_preferences task_preferences_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.task_preferences
    ADD CONSTRAINT task_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: unified_instructions unified_instructions_liu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.unified_instructions
    ADD CONSTRAINT unified_instructions_liu_id_fkey FOREIGN KEY (liu_id) REFERENCES public.users(liu_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

