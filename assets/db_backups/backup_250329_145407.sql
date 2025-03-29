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
1	pentagonal_prism_1	black	{0,0,0}	-346.6738	187.50386	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:13.248485
1271	pentagonal prism_37	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:35.627279
3	hexagonal_prism_1	red	{0,0,0}	-212.50436	-31.667318	928.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:50:13.256261
5	pentagonal_prism_2	black	{0,0,0}	-127.46696	517.712	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:13.483639
7	hexagonal_prism_2	red	{0,0,0}	31.376482	258.856	923.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:13.489459
9	pentagonal_prism_3	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:13.704611
13	pentagonal_prism_4	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:13.923112
15	hexagonal_prism_3	red	{0,0,0}	31.375294	259.82666	933	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:13.927408
17	pentagonal_prism_5	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:14.138435
19	hexagonal_prism_4	red	{0,0,0}	30.51353	260.84146	922.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:14.142628
21	pentagonal_prism_6	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:14.369645
23	hexagonal_prism_5	red	{0,0,0}	30.51353	260.84146	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:14.375067
25	pentagonal_prism_7	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:14.593787
27	hexagonal_prism_6	red	{0,0,0}	30.51353	260.84146	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:14.597762
29	pentagonal_prism_8	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:14.822361
31	hexagonal_prism_7	red	{0,0,0}	30.51353	260.84146	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:14.828326
33	pentagonal_prism_9	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:15.05453
35	pentagonal_prism_10	red	{0,0,0}	32.355774	258.8462	911.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:15.05902
37	pentagonal_prism_11	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:15.284797
39	pentagonal_prism_12	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:15.288978
41	pentagonal_prism_13	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:15.503259
43	pentagonal_prism_14	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:15.507751
45	pentagonal_prism_15	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:15.731846
47	pentagonal_prism_16	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:15.737429
49	pentagonal_prism_17	black	{0,0,0}	-127.462135	518.67285	661	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:15.957252
51	hexagonal_prism_8	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:15.962528
53	pentagonal_prism_18	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:16.17698
2	cube_1	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.743565	cube.usd	2025-03-29 14:51:28.508091
8	cylinder_2	green	{0,0,0}	126.48644	290.23245	1930.0001	0	0	90	cylinder.usd	2025-03-29 14:51:28.510147
11	cylinder_3	green	{0,0,0}	-270.62216	216.69383	907.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:28.51401
6	cube_2	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.743565	cube.usd	2025-03-29 14:51:28.733596
12	cylinder_4	green	{0,0,0}	-270.6119	216.68562	0	0	0	26.56505	cylinder.usd	2025-03-29 14:51:28.737399
10	cube_3	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:51:28.953793
16	cylinder_5	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:28.959363
14	cube_4	pink	{0,0,0}	-206.88867	345.1413	928.00006	0	0	59.620872	cube.usd	2025-03-29 14:51:29.183236
20	cylinder_6	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:29.187097
18	cube_5	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:51:29.40965
24	cylinder_7	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:29.413244
22	cube_6	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:29.640204
28	cylinder_8	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:51:29.644044
26	cube_7	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:29.871145
32	cylinder_9	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:29.875925
30	cube_8	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:51:30.092407
36	cylinder_10	green	{0,0,0}	-270.6119	216.68562	941.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:30.096237
34	cube_9	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:30.323724
40	cylinder_11	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 14:51:30.327878
38	cube_10	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.620872	cube.usd	2025-03-29 14:51:30.559858
42	cube_11	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:51:30.785814
48	cylinder_13	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:30.790046
46	cube_12	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 14:51:31.009185
50	cube_13	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	cube.usd	2025-03-29 14:51:31.011477
52	cylinder_14	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:31.013409
55	pentagonal_prism_19	red	{0,0,0}	32.355774	258.8462	924	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:50:16.181825
57	pentagonal_prism_20	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:16.39503
59	hexagonal_prism_9	red	{0,0,0}	30.51353	260.84146	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:16.399245
61	pentagonal_prism_21	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:16.627071
63	pentagonal_prism_22	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:16.631437
65	pentagonal_prism_23	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:16.852639
67	hexagonal_prism_10	red	{0,0,0}	30.51353	260.84146	927.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:16.856297
69	pentagonal_prism_24	black	{0,0,0}	-128.94919	520.7185	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:17.077163
71	hexagonal_prism_11	red	{0,0,0}	30.514694	260.8514	929	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:17.08316
73	pentagonal_prism_25	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:17.310439
75	hexagonal_prism_12	red	{0,0,0}	30.51353	260.84146	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:17.315732
77	pentagonal_prism_26	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:17.541212
79	hexagonal_prism_13	red	{0,0,0}	31.375294	259.82666	920	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:50:17.54547
81	pentagonal_prism_27	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:17.777542
85	pentagonal_prism_28	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:18.009447
87	hexagonal_prism_14	red	{0,0,0}	30.51353	260.84146	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:18.014923
89	pentagonal_prism_29	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:18.241737
91	hexagonal_prism_15	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:18.247281
93	pentagonal_prism_30	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:18.460802
95	pentagonal_prism_31	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.303947	pentagonal_prism.usd	2025-03-29 14:50:18.465729
97	pentagonal_prism_32	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:18.69732
101	pentagonal_prism_33	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:18.929344
103	hexagonal_prism_16	red	{0,0,0}	31.375294	259.82666	929	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:50:18.934776
105	pentagonal_prism_34	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:19.158721
56	cylinder_15	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:51:31.246406
58	cube_15	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 14:51:31.469622
62	cube_16	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	cube.usd	2025-03-29 14:51:31.471621
60	cylinder_16	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:51:31.473611
66	cube_17	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.62088	cube.usd	2025-03-29 14:51:31.690159
64	cylinder_17	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:31.694527
70	cube_18	pink	{0,0,0}	-205.90038	345.12823	935.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:31.929706
68	cylinder_18	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:31.933638
74	cube_19	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.420776	cube.usd	2025-03-29 14:51:32.153891
72	cylinder_19	green	{0,0,0}	-272.65317	217.53194	929	0	0	18.434948	cylinder.usd	2025-03-29 14:51:32.15781
78	cube_20	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 14:51:32.380587
76	cylinder_20	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:32.384429
82	cube_21	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:32.611987
80	cylinder_21	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:32.615689
83	cube_22	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.620872	cube.usd	2025-03-29 14:51:32.846111
84	cylinder_22	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:32.849644
86	cube_23	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:33.081107
88	cylinder_23	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:51:33.084748
90	cube_24	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:33.31468
92	cylinder_24	green	{0,0,0}	-270.62216	216.69383	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:33.318373
94	cube_25	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:33.550024
96	cylinder_25	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:33.553949
98	cube_26	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:51:33.782525
99	cube_27	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	cube.usd	2025-03-29 14:51:33.784576
100	cylinder_26	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:33.7865
102	cube_28	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:34.010925
106	cube_29	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	cube.usd	2025-03-29 14:51:34.01319
104	cylinder_27	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:34.015248
107	hexagonal_prism_17	red	{0,0,0}	31.375294	259.82666	933	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:50:19.16299
134	cube_36	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.534454	cube.usd	2025-03-29 14:51:35.630757
109	pentagonal_prism_35	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:19.393275
1272	pentagonal prism_38	red	{0,0,0}	32.357	258.856	933	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:35.63269
111	pentagonal_prism_36	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:19.397948
138	cube_37	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:35.870973
113	pentagonal_prism_37	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:19.642386
136	cylinder_35	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:51:35.874994
115	hexagonal_prism_18	red	{0,0,0}	30.51353	260.84146	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:19.648
142	cube_38	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 14:51:36.10317
117	pentagonal_prism_38	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:19.867431
140	cylinder_36	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:36.106777
119	hexagonal_prism_19	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:19.871558
146	cube_39	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.743565	cube.usd	2025-03-29 14:51:36.333904
121	pentagonal_prism_39	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:20.092434
144	cylinder_37	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:36.337922
123	hexagonal_prism_20	red	{0,0,0}	31.375294	259.82666	917.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:20.098109
150	cube_40	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:36.553898
125	pentagonal_prism_40	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:20.312601
148	cylinder_38	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:36.557772
127	hexagonal_prism_21	red	{0,0,0}	30.514694	260.8514	924	0	0	37.184704	hexagonal_prism.usd	2025-03-29 14:50:20.31749
154	cube_41	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:36.778718
129	pentagonal_prism_41	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:20.546408
152	cylinder_39	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:51:36.782687
131	hexagonal_prism_22	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:20.550941
133	pentagonal_prism_42	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:20.776527
135	hexagonal_prism_23	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:20.782603
137	pentagonal_prism_43	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:21.006612
139	pentagonal_prism_44	red	{0,0,0}	32.355774	258.8462	915	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:21.012082
141	pentagonal_prism_45	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:21.240569
143	pentagonal_prism_46	red	{0,0,0}	31.497837	259.85715	929	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:21.24603
145	pentagonal_prism_47	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:21.47452
147	hexagonal_prism_24	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.694237	hexagonal_prism.usd	2025-03-29 14:50:21.478836
149	pentagonal_prism_48	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:21.702456
151	hexagonal_prism_25	red	{0,0,0}	30.51353	260.84146	934	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:21.708057
153	pentagonal_prism_49	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:21.924188
155	hexagonal_prism_26	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:21.928259
157	pentagonal_prism_50	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:22.15238
159	pentagonal_prism_51	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:22.157707
108	cylinder_28	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 14:51:34.251029
114	cube_31	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:51:34.483717
112	cylinder_29	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:34.487792
118	cube_32	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.420776	cube.usd	2025-03-29 14:51:34.715178
116	cylinder_30	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:34.718894
122	cube_33	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:34.940597
120	cylinder_31	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:51:34.944851
126	cube_34	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:35.163842
124	cylinder_32	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:35.16758
130	cube_35	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:35.394536
128	cylinder_33	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:35.398656
158	cube_42	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.420776	cube.usd	2025-03-29 14:51:37.011235
156	cylinder_40	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:37.015671
161	pentagonal_prism_52	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:22.389971
163	hexagonal_prism_27	red	{0,0,0}	30.51353	260.84146	934	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:22.395656
165	pentagonal_prism_53	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:22.625462
169	pentagonal_prism_54	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:22.851286
171	pentagonal_prism_55	red	{0,0,0}	30.394815	260.80713	928.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:22.85519
173	pentagonal_prism_56	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:23.074899
175	hexagonal_prism_28	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:23.079924
177	pentagonal_prism_57	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:23.299871
179	hexagonal_prism_29	red	{0,0,0}	30.394815	260.80713	927.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:23.303915
181	pentagonal_prism_58	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:23.53546
183	hexagonal_prism_30	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:23.540994
185	pentagonal_prism_59	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:23.756993
187	pentagonal_prism_60	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.746803	pentagonal_prism.usd	2025-03-29 14:50:23.762588
189	pentagonal_prism_61	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:23.976224
191	hexagonal_prism_31	red	{0,0,0}	30.51353	260.84146	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:23.981697
193	pentagonal_prism_62	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:24.198935
195	pentagonal_prism_63	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:24.204488
197	pentagonal_prism_64	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:24.429441
199	hexagonal_prism_32	red	{0,0,0}	31.375294	259.82666	920	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:24.434529
201	pentagonal_prism_65	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:24.657745
203	hexagonal_prism_33	red	{0,0,0}	30.51353	260.84146	934	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:24.661506
205	pentagonal_prism_66	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:24.878743
207	hexagonal_prism_34	red	{0,0,0}	30.51353	260.84146	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:24.884017
209	pentagonal_prism_67	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:25.100948
166	cube_44	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	cube.usd	2025-03-29 14:51:37.247112
160	cylinder_41	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:37.24912
167	cube_45	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:37.467142
164	cylinder_42	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:37.470786
170	cube_46	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:37.703977
168	cylinder_43	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:37.707595
174	cube_47	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.743565	cube.usd	2025-03-29 14:51:37.928042
172	cylinder_44	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:37.932411
178	cube_48	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:38.148917
176	cylinder_45	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:38.152766
182	cube_49	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:38.370516
180	cylinder_46	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:51:38.374352
186	cube_50	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:38.59762
184	cylinder_47	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:38.601745
190	cube_51	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:38.838459
188	cylinder_48	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:51:38.842282
194	cube_52	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:39.080677
198	cube_53	red	{0,0,0}	32.355774	258.8462	924	0	0	37.303947	cube.usd	2025-03-29 14:51:39.08286
192	cylinder_49	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:39.08467
202	cube_54	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:51:39.319515
206	cube_55	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cube.usd	2025-03-29 14:51:39.321468
196	cylinder_50	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:39.32338
210	cube_56	pink	{0,0,0}	-207.68886	346.4762	910	0	0	59.03624	cube.usd	2025-03-29 14:51:39.543878
200	cylinder_51	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:51:39.548116
211	cube_57	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:39.77316
204	cylinder_52	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:39.776811
208	cylinder_53	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 14:51:40.004713
212	cylinder_54	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:40.241831
213	pentagonal_prism_68	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:25.333133
1767	hexagonal prism_193	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:35.605297
215	hexagonal_prism_35	red	{0,0,0}	30.51353	260.84146	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:25.339388
217	pentagonal_prism_69	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:25.567877
219	pentagonal_prism_70	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:25.573716
221	pentagonal_prism_71	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:25.79894
223	hexagonal_prism_36	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:25.803454
225	pentagonal_prism_72	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:26.016226
227	hexagonal_prism_37	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:50:26.020655
229	pentagonal_prism_73	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:26.253859
231	hexagonal_prism_38	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:26.258986
233	pentagonal_prism_74	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:26.488236
235	hexagonal_prism_39	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:26.492738
237	pentagonal_prism_75	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:26.719328
239	hexagonal_prism_40	red	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:26.723763
241	pentagonal_prism_76	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:26.956008
243	hexagonal_prism_41	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:26.961751
245	pentagonal_prism_77	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:27.182434
247	pentagonal_prism_78	red	{0,0,0}	31.497837	259.85715	933	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:27.187405
249	pentagonal_prism_79	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:27.402776
251	pentagonal_prism_80	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:27.407455
253	pentagonal_prism_81	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:27.633068
255	hexagonal_prism_42	orange	{0,0,0}	30.51353	260.84146	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:27.639158
257	pentagonal_prism_82	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:27.853861
259	pentagonal_prism_83	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:27.85818
261	pentagonal_prism_84	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:28.091765
263	hexagonal_prism_43	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:28.097052
265	pentagonal_prism_85	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:28.319687
218	cube_59	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.34933	cube.usd	2025-03-29 14:51:40.238056
222	cube_60	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:40.490474
216	cylinder_55	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:40.494116
226	cube_61	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 14:51:40.720441
220	cylinder_56	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:40.724285
230	cube_62	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:40.954946
224	cylinder_57	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:40.958668
234	cube_63	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:41.19087
228	cylinder_58	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:41.194664
238	cube_64	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:51:41.423469
232	cylinder_59	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:51:41.42725
242	cube_65	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 14:51:41.652529
236	cylinder_60	green	{0,0,0}	-270.6119	216.68562	929	0	0	45	cylinder.usd	2025-03-29 14:51:41.656185
246	cube_66	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.620872	cube.usd	2025-03-29 14:51:41.889944
240	cylinder_61	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:51:41.893712
250	cube_67	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 14:51:42.118942
254	cube_68	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:42.355076
248	cylinder_63	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:42.358926
258	cube_69	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:42.589537
252	cylinder_64	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:51:42.593178
262	cube_70	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:51:42.820206
256	cylinder_65	green	{0,0,0}	-270.62216	216.69383	911.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:42.823891
260	cylinder_66	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:51:43.062225
264	cylinder_67	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:51:43.286415
267	hexagonal_prism_44	red	{0,0,0}	31.375294	259.82666	934	0	0	37.40536	hexagonal_prism.usd	2025-03-29 14:50:28.325231
269	pentagonal_prism_86	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:28.551618
271	hexagonal_prism_45	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:28.556832
273	pentagonal_prism_87	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:28.787053
275	pentagonal_prism_88	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:28.79156
277	pentagonal_prism_89	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:29.021867
281	pentagonal_prism_90	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:29.265314
283	hexagonal_prism_46	red	{0,0,0}	31.375294	259.82666	934	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:29.269588
285	pentagonal_prism_91	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:29.484892
287	hexagonal_prism_47	red	{0,0,0}	30.514694	260.8514	927.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:29.489291
289	hexagonal_prism_48	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal_prism.usd	2025-03-29 14:50:29.705065
291	hexagonal_prism_49	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:29.709486
293	pentagonal_prism_92	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:29.940655
295	hexagonal_prism_50	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:29.945917
297	pentagonal_prism_93	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:30.171697
299	hexagonal_prism_51	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:50:30.177009
301	pentagonal_prism_94	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:30.408595
303	pentagonal_prism_95	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:30.413707
305	pentagonal_prism_96	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:30.645371
307	pentagonal_prism_97	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:30.651339
309	pentagonal_prism_98	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:30.877879
311	hexagonal_prism_52	red	{0,0,0}	30.51353	260.84146	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:30.883208
313	pentagonal_prism_99	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:31.104604
315	hexagonal_prism_53	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.746803	hexagonal_prism.usd	2025-03-29 14:50:31.110374
317	pentagonal_prism_100	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:31.339331
270	cube_72	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:43.282243
274	cube_73	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:43.516996
268	cylinder_68	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:43.521027
278	cube_74	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:51:43.762814
279	cube_75	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	cube.usd	2025-03-29 14:51:43.764679
272	cylinder_69	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:43.766714
282	cube_76	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 14:51:44.000356
276	cylinder_70	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:44.004567
286	cube_77	pink	{0,0,0}	-205.90038	345.12823	905.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:44.237302
280	cylinder_71	green	{0,0,0}	-270.6119	216.68562	920	0	0	18.43495	cylinder.usd	2025-03-29 14:51:44.240956
290	cube_78	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:51:44.484481
284	cylinder_72	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:44.488693
294	cube_79	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:51:44.731886
288	cylinder_73	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:44.735934
298	cube_80	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 14:51:44.957569
292	cylinder_74	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:44.9613
302	cube_81	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.420776	cube.usd	2025-03-29 14:51:45.190492
296	cylinder_75	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:45.194723
306	cube_82	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:45.428504
300	cylinder_76	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:45.431952
310	cube_83	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:51:45.653902
304	cylinder_77	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:51:45.657813
314	cube_84	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:45.891117
308	cylinder_78	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:45.894912
318	cube_85	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 14:51:46.119194
312	cylinder_79	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:46.123485
316	cylinder_80	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:46.348394
319	hexagonal_prism_54	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:31.345016
321	pentagonal_prism_101	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:31.575953
323	hexagonal_prism_55	red	{0,0,0}	31.376482	259.8365	917.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:31.580126
325	pentagonal_prism_102	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:31.809986
327	hexagonal_prism_56	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:31.816075
329	pentagonal_prism_103	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:32.03604
331	hexagonal_prism_57	red	{0,0,0}	31.375294	259.82666	920	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:32.042161
333	pentagonal_prism_104	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:32.273758
337	pentagonal_prism_105	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:32.506536
339	hexagonal_prism_58	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:32.512184
341	pentagonal_prism_106	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:32.750799
343	hexagonal_prism_59	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:32.756498
345	pentagonal_prism_107	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:32.975283
347	pentagonal_prism_108	red	{0,0,0}	32.355774	258.8462	934	0	0	37.303947	pentagonal_prism.usd	2025-03-29 14:50:32.979902
349	pentagonal_prism_109	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:33.218
351	hexagonal_prism_60	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:33.223577
353	pentagonal_prism_110	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:33.442702
355	hexagonal_prism_61	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:50:33.447227
357	pentagonal_prism_111	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:33.676757
359	hexagonal_prism_62	red	{0,0,0}	30.514694	260.8514	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:33.682292
361	pentagonal_prism_112	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:33.909885
363	hexagonal_prism_63	red	{0,0,0}	31.375294	259.82666	936.00006	0	0	37.746803	hexagonal_prism.usd	2025-03-29 14:50:33.915308
365	pentagonal_prism_113	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:34.147723
367	hexagonal_prism_64	red	{0,0,0}	30.51353	260.84146	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:34.151606
369	pentagonal_prism_114	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:34.376811
371	hexagonal_prism_65	red	{0,0,0}	30.514694	260.8514	934	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:34.383223
326	cube_87	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03624	cube.usd	2025-03-29 14:51:46.562451
320	cylinder_81	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:46.566056
330	cube_88	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:46.787946
324	cylinder_82	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:46.792008
334	cube_89	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:47.027451
328	cylinder_83	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:47.031386
335	cube_90	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:47.260276
332	cylinder_84	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:47.264521
338	cube_91	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 14:51:47.498973
336	cylinder_85	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:47.502877
342	cube_92	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:47.73713
346	cube_93	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	cube.usd	2025-03-29 14:51:47.739452
340	cylinder_86	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:47.74144
350	cube_94	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:47.957225
344	cylinder_87	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:47.960962
354	cube_95	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 14:51:48.1912
348	cylinder_88	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:51:48.195271
358	cube_96	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 14:51:48.43689
352	cylinder_89	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:48.44103
362	cube_97	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.534454	cube.usd	2025-03-29 14:51:48.660678
356	cylinder_90	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:51:48.664367
366	cube_98	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:51:48.888665
360	cylinder_91	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:51:48.892491
370	cube_99	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:49.128741
364	cylinder_92	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:49.132407
368	cylinder_93	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:49.359946
1768	pentagonal prism_363	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:35.829581
373	pentagonal_prism_115	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:34.610745
375	hexagonal_prism_66	red	{0,0,0}	30.51353	260.84146	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:34.61467
377	pentagonal_prism_116	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:34.84993
379	pentagonal_prism_117	red	{0,0,0}	32.355774	258.8462	929	0	0	37.874985	pentagonal_prism.usd	2025-03-29 14:50:34.855261
381	pentagonal_prism_118	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:35.073026
383	hexagonal_prism_67	red	{0,0,0}	31.375294	259.82666	938	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:35.077349
385	pentagonal_prism_119	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:35.307454
387	hexagonal_prism_68	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:35.311812
389	hexagonal_prism_69	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal_prism.usd	2025-03-29 14:50:35.542172
391	pentagonal_prism_120	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:35.547222
393	pentagonal_prism_121	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:35.783764
395	hexagonal_prism_70	red	{0,0,0}	31.375294	259.82666	939.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:35.789011
397	pentagonal_prism_122	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:36.021368
399	hexagonal_prism_71	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:36.027199
401	pentagonal_prism_123	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:36.243067
403	pentagonal_prism_124	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:36.247634
405	pentagonal_prism_125	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:36.480562
407	hexagonal_prism_72	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:36.485
409	pentagonal_prism_126	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:36.70987
411	hexagonal_prism_73	red	{0,0,0}	30.51353	260.84146	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:36.715606
413	pentagonal_prism_127	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:36.943662
415	hexagonal_prism_74	red	{0,0,0}	30.51353	260.84146	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:36.94848
417	pentagonal_prism_128	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:37.177409
419	pentagonal_prism_129	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:37.183669
421	pentagonal_prism_130	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:37.413041
423	hexagonal_prism_75	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:37.41876
378	cube_101	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	cube.usd	2025-03-29 14:51:49.358064
382	cube_102	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:49.596618
372	cylinder_94	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:49.600329
386	cube_103	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:49.828381
390	cube_104	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cube.usd	2025-03-29 14:51:49.830212
376	cylinder_95	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:49.832001
394	cube_105	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:51:50.055092
380	cylinder_96	green	{0,0,0}	-270.6119	216.68562	933	0	0	18.434948	cylinder.usd	2025-03-29 14:51:50.059242
398	cube_106	pink	{0,0,0}	-206.88084	345.12823	932.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:50.272807
384	cylinder_97	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:50.276809
402	cube_107	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:51:50.509751
388	cylinder_98	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 14:51:50.513595
406	cube_108	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:50.75045
392	cylinder_99	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:50.754772
410	cube_109	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:51:50.980387
396	cylinder_100	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:50.984661
414	cube_110	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:51:51.211872
400	cylinder_101	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:51.215591
418	cube_111	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.420776	cube.usd	2025-03-29 14:51:51.44801
404	cylinder_102	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	cylinder.usd	2025-03-29 14:51:51.452056
422	cube_112	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:51:51.679241
412	cylinder_104	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:51.914082
416	cylinder_105	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:52.151828
420	cylinder_106	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:52.374389
424	cylinder_107	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:52.61562
425	pentagonal_prism_131	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:37.657731
1769	hexagonal prism_194	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:35.835199
427	hexagonal_prism_76	red	{0,0,0}	31.375294	259.82666	916.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:37.664015
429	pentagonal_prism_132	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:37.882108
431	hexagonal_prism_77	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:37.886608
433	pentagonal_prism_133	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:38.111465
435	hexagonal_prism_78	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:38.117655
437	pentagonal_prism_134	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:38.358326
439	hexagonal_prism_79	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:38.363563
441	pentagonal_prism_135	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:38.579726
443	pentagonal_prism_136	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:38.584366
445	pentagonal_prism_137	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:38.814945
447	hexagonal_prism_80	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:38.818987
449	pentagonal_prism_138	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:39.056645
451	hexagonal_prism_81	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:39.06105
453	pentagonal_prism_139	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:39.280737
455	pentagonal_prism_140	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:39.284915
457	pentagonal_prism_141	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:39.520423
459	hexagonal_prism_82	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:39.524627
461	pentagonal_prism_142	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:39.746455
463	hexagonal_prism_83	red	{0,0,0}	30.51353	260.84146	920	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:39.752261
465	hexagonal_prism_84	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal_prism.usd	2025-03-29 14:50:39.983024
467	hexagonal_prism_85	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:39.988447
469	hexagonal_prism_86	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal_prism.usd	2025-03-29 14:50:40.21956
471	hexagonal_prism_87	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:40.224999
473	pentagonal_prism_143	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:40.445965
475	hexagonal_prism_88	red	{0,0,0}	30.51353	260.84146	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:40.451307
477	pentagonal_prism_144	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:40.68519
430	cube_114	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.743565	cube.usd	2025-03-29 14:51:52.147774
434	cube_115	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:52.370075
438	cube_116	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:52.611757
442	cube_117	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:52.839548
428	cylinder_108	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:52.843712
446	cube_118	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:51:53.06137
432	cylinder_109	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:53.064939
450	cube_119	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.743565	cube.usd	2025-03-29 14:51:53.299921
436	cylinder_110	green	{0,0,0}	-272.66354	217.54024	933	0	0	26.56505	cylinder.usd	2025-03-29 14:51:53.303752
454	cube_120	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.420776	cube.usd	2025-03-29 14:51:53.526949
440	cylinder_111	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:53.530887
458	cube_121	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:53.768362
444	cylinder_112	green	{0,0,0}	-270.6119	216.68562	929	0	0	45	cylinder.usd	2025-03-29 14:51:53.772333
462	cube_122	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:53.99008
448	cylinder_113	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:53.994334
466	cube_123	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:54.220388
452	cylinder_114	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:51:54.224296
470	cube_124	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 14:51:54.449681
456	cylinder_115	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:51:54.453272
474	cube_125	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:51:54.677124
460	cylinder_116	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 14:51:54.681028
464	cylinder_117	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:51:54.90991
468	cylinder_118	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:51:55.133957
476	cylinder_120	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:51:55.598976
1770	pentagonal prism_364	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:36.065806
479	hexagonal_prism_89	red	{0,0,0}	30.394815	260.80713	920	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:40.690558
481	pentagonal_prism_145	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:40.911965
483	hexagonal_prism_90	red	{0,0,0}	30.51353	260.84146	927.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:40.916278
485	pentagonal_prism_146	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:41.131775
487	pentagonal_prism_147	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:41.135895
489	pentagonal_prism_148	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:41.386112
491	hexagonal_prism_91	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:41.390248
493	pentagonal_prism_149	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:41.611456
495	hexagonal_prism_92	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:41.617395
497	pentagonal_prism_150	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:41.837531
499	pentagonal_prism_151	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:50:41.841474
501	pentagonal_prism_152	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:42.069381
503	hexagonal_prism_93	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.746803	hexagonal_prism.usd	2025-03-29 14:50:42.075121
505	pentagonal_prism_153	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:42.303133
507	hexagonal_prism_94	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:42.308501
509	pentagonal_prism_154	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:42.530211
511	hexagonal_prism_95	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:42.536387
513	pentagonal_prism_155	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:42.765531
515	pentagonal_prism_156	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:42.771267
517	pentagonal_prism_157	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:43.006447
519	hexagonal_prism_96	red	{0,0,0}	31.375294	259.82666	939.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:43.011433
521	pentagonal_prism_158	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:43.236218
523	hexagonal_prism_97	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:43.241694
525	pentagonal_prism_159	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:43.487702
527	hexagonal_prism_98	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:43.491556
529	pentagonal_prism_160	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:43.734188
482	cube_127	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.743565	cube.usd	2025-03-29 14:51:55.130276
486	cube_128	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:55.370491
490	cube_129	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 14:51:55.595207
494	cube_130	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	cube.usd	2025-03-29 14:51:55.827226
498	cube_131	red	{0,0,0}	32.357	258.856	934	0	0	37.568592	cube.usd	2025-03-29 14:51:55.829588
480	cylinder_121	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:55.831535
502	cube_132	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 14:51:56.061804
484	cylinder_122	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:56.065735
506	cube_133	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:51:56.284665
488	cylinder_123	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:51:56.288459
510	cube_134	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.743565	cube.usd	2025-03-29 14:51:56.514198
492	cylinder_124	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:56.517772
514	cube_135	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:56.751115
496	cylinder_125	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:56.754811
518	cube_136	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:56.982352
500	cylinder_126	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:56.986496
522	cube_137	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.03624	cube.usd	2025-03-29 14:51:57.21794
504	cylinder_127	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:51:57.221646
526	cube_138	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:51:57.445442
508	cylinder_128	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:51:57.449554
530	cube_139	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 14:51:57.690199
512	cylinder_129	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:51:57.694243
516	cylinder_130	green	{0,0,0}	-270.62216	216.69383	941.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:57.917397
524	cylinder_132	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:58.377807
528	cylinder_133	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:58.602187
1771	pentagonal prism_365	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:36.0702
533	pentagonal_prism_161	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:43.96673
535	hexagonal_prism_99	red	{0,0,0}	30.51353	260.84146	927.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:43.972552
537	pentagonal_prism_162	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:44.200314
539	hexagonal_prism_100	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:44.206483
541	hexagonal_prism_101	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal_prism.usd	2025-03-29 14:50:44.43335
543	hexagonal_prism_102	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:50:44.439205
545	pentagonal_prism_163	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:44.667789
547	hexagonal_prism_103	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:44.673681
549	pentagonal_prism_164	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:44.927591
551	hexagonal_prism_104	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:44.932965
553	pentagonal_prism_165	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:45.152914
555	hexagonal_prism_105	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:45.157063
557	pentagonal_prism_166	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:45.392363
559	hexagonal_prism_106	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:45.396332
561	pentagonal_prism_167	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:45.617444
563	hexagonal_prism_107	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:45.621663
565	pentagonal_prism_168	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:45.854661
567	hexagonal_prism_108	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:45.858624
569	pentagonal_prism_169	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:46.080371
571	hexagonal_prism_109	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:46.085721
573	pentagonal_prism_170	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:46.313902
575	hexagonal_prism_110	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.746803	hexagonal_prism.usd	2025-03-29 14:50:46.317765
577	pentagonal_prism_171	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:46.545772
579	hexagonal_prism_111	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:46.550113
581	hexagonal_prism_112	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	hexagonal_prism.usd	2025-03-29 14:50:46.777378
542	cube_142	red	{0,0,0}	32.357	258.856	924	0	0	37.303947	cube.usd	2025-03-29 14:51:58.151968
546	cube_143	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:51:58.37349
550	cube_144	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:58.598327
554	cube_145	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:58.819801
531	cylinder_134	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:58.823745
558	cube_146	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:51:59.051959
532	cylinder_135	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:51:59.056557
562	cube_147	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:59.286296
536	cylinder_136	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:59.290069
566	cube_148	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03624	cube.usd	2025-03-29 14:51:59.526349
540	cylinder_137	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:59.530322
570	cube_149	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:59.752163
544	cylinder_138	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:59.756612
574	cube_150	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:51:59.987751
548	cylinder_139	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:51:59.991499
578	cube_151	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:00.244859
552	cylinder_140	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:00.249454
582	cube_152	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:00.469071
556	cylinder_141	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 14:52:00.472612
583	cube_153	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:00.706389
560	cylinder_142	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:00.710272
564	cylinder_143	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	cylinder.usd	2025-03-29 14:52:00.939372
568	cylinder_144	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:01.184079
572	cylinder_145	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:01.41493
576	cylinder_146	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 14:52:01.640916
580	cylinder_147	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:01.875417
584	cylinder_148	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:02.109556
585	pentagonal_prism_172	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:47.005018
1772	pentagonal prism_366	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:36.301095
587	hexagonal_prism_113	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:47.010647
589	hexagonal_prism_114	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	hexagonal_prism.usd	2025-03-29 14:50:47.247939
591	pentagonal_prism_173	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:47.254437
593	pentagonal_prism_174	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:47.469488
595	hexagonal_prism_115	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:47.474293
597	pentagonal_prism_175	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:47.709098
599	hexagonal_prism_116	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:47.714618
601	pentagonal_prism_176	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:47.936614
603	hexagonal_prism_117	red	{0,0,0}	30.51353	260.84146	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:47.941174
605	pentagonal_prism_177	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:48.184876
607	hexagonal_prism_118	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:48.190958
609	pentagonal_prism_178	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:48.420597
611	hexagonal_prism_119	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:48.426528
613	pentagonal_prism_179	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:48.657262
615	hexagonal_prism_120	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:48.662882
617	pentagonal_prism_180	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:48.893221
619	hexagonal_prism_121	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:48.89898
621	pentagonal_prism_181	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:49.122239
623	hexagonal_prism_122	orange	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:49.127481
625	pentagonal_prism_182	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:49.35365
627	pentagonal_prism_183	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:49.358079
629	pentagonal_prism_184	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:49.58593
633	pentagonal_prism_185	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:49.807039
635	pentagonal_prism_186	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	36.869896	pentagonal_prism.usd	2025-03-29 14:50:49.81188
637	pentagonal_prism_187	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:50.049239
590	cube_155	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.743565	cube.usd	2025-03-29 14:52:01.179479
594	cube_156	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:01.410861
598	cube_157	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 14:52:01.63716
602	cube_158	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.420776	cube.usd	2025-03-29 14:52:01.871355
606	cube_159	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:02.105866
610	cube_160	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 14:52:02.338449
588	cylinder_149	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:02.342112
614	cube_161	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:02.566894
592	cylinder_150	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:02.570828
618	cube_162	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:02.803372
622	cube_163	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cube.usd	2025-03-29 14:52:02.80548
596	cylinder_151	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 14:52:02.807343
626	cube_164	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 14:52:03.040056
600	cylinder_152	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 14:52:03.044213
630	cube_165	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:03.26941
604	cylinder_153	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:03.273127
634	cube_166	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:52:03.511425
608	cylinder_154	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:03.515403
612	cylinder_155	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:03.743013
616	cylinder_156	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:03.980865
620	cylinder_157	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:04.206573
628	cylinder_159	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:04.674662
631	cylinder_160	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:04.911117
632	cylinder_161	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:52:05.146787
636	cylinder_162	green	{0,0,0}	-270.6119	216.68562	924	0	0	38.65981	cylinder.usd	2025-03-29 14:52:05.376413
1773	hexagonal prism_195	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:36.306472
639	hexagonal_prism_123	red	{0,0,0}	31.376482	259.8365	929	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:50:50.055027
641	pentagonal_prism_188	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:50.272994
643	hexagonal_prism_124	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.694237	hexagonal_prism.usd	2025-03-29 14:50:50.277313
645	pentagonal_prism_189	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:50.514157
649	pentagonal_prism_190	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:50.742096
651	hexagonal_prism_125	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:50.747662
653	pentagonal_prism_191	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:50.977025
655	pentagonal_prism_192	red	{0,0,0}	30.394815	260.80713	927.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:50.982488
657	pentagonal_prism_193	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:51.211914
659	pentagonal_prism_194	red	{0,0,0}	30.394815	260.80713	935.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:51.217561
661	pentagonal_prism_195	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:51.445663
663	hexagonal_prism_126	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:50:51.449555
665	pentagonal_prism_196	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:51.671274
667	pentagonal_prism_197	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.874985	pentagonal_prism.usd	2025-03-29 14:50:51.677389
669	pentagonal_prism_198	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:51.911954
671	hexagonal_prism_127	red	{0,0,0}	30.51353	260.84146	926.00006	0	0	37.746803	hexagonal_prism.usd	2025-03-29 14:50:51.916226
673	pentagonal_prism_199	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:52.140234
675	hexagonal_prism_128	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.746803	hexagonal_prism.usd	2025-03-29 14:50:52.146071
677	pentagonal_prism_200	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:52.3758
679	pentagonal_prism_201	red	{0,0,0}	30.394815	260.80713	920	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:52.381227
681	pentagonal_prism_202	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:52.616642
683	pentagonal_prism_203	red	{0,0,0}	32.355774	258.8462	920	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:50:52.621882
685	pentagonal_prism_204	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:52.843684
687	hexagonal_prism_129	red	{0,0,0}	31.376482	259.8365	934	0	0	37.234837	hexagonal_prism.usd	2025-03-29 14:50:52.848303
689	pentagonal_prism_205	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:53.081654
642	cube_168	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:03.97642
646	cube_169	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:52:04.202849
647	cube_170	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:04.436779
650	cube_171	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 14:52:04.670921
654	cube_172	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:52:04.907376
658	cube_173	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	cube.usd	2025-03-29 14:52:04.909298
662	cube_174	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:05.142644
666	cube_175	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:52:05.372639
670	cube_176	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:52:05.613669
640	cylinder_163	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:05.617551
674	cube_177	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:52:05.845963
644	cylinder_164	green	{0,0,0}	-270.6119	216.68562	933	0	0	33.690067	cylinder.usd	2025-03-29 14:52:05.849832
678	cube_178	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.34933	cube.usd	2025-03-29 14:52:06.073765
648	cylinder_165	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:06.077813
682	cube_179	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 14:52:06.317431
652	cylinder_166	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 14:52:06.321659
686	cube_180	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:06.554927
656	cylinder_167	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:06.558908
690	cube_181	pink	{0,0,0}	-206.70456	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:06.79223
660	cylinder_168	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 14:52:06.796262
664	cylinder_169	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:07.03433
668	cylinder_170	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:52:07.263241
672	cylinder_171	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:07.491214
680	cylinder_173	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:07.947072
684	cylinder_174	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:52:08.182853
688	cylinder_175	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	cylinder.usd	2025-03-29 14:52:08.410643
691	pentagonal_prism_206	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:53.08741
1774	pentagonal prism_367	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:36.523542
693	pentagonal_prism_207	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:53.311237
695	pentagonal_prism_208	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:53.315307
697	pentagonal_prism_209	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:53.544869
699	hexagonal_prism_130	red	{0,0,0}	30.51353	260.84146	928.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:53.550057
701	pentagonal_prism_210	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:53.781398
705	pentagonal_prism_211	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:54.014046
707	hexagonal_prism_131	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:54.019363
709	pentagonal_prism_212	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:54.248346
711	pentagonal_prism_213	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:54.25391
713	pentagonal_prism_214	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:54.473131
715	hexagonal_prism_132	red	{0,0,0}	31.375294	259.82666	920	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:54.479329
717	pentagonal_prism_215	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:54.692782
719	hexagonal_prism_133	red	{0,0,0}	30.514694	260.8514	928.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:54.697543
721	pentagonal_prism_216	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:54.931377
723	hexagonal_prism_134	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:54.936803
725	pentagonal_prism_217	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:55.154797
727	hexagonal_prism_135	red	{0,0,0}	30.51353	260.84146	917.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:55.161191
729	pentagonal_prism_218	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:55.378049
731	pentagonal_prism_219	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:50:55.382379
733	pentagonal_prism_220	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:55.618376
735	hexagonal_prism_136	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.746803	hexagonal_prism.usd	2025-03-29 14:50:55.623577
737	pentagonal_prism_221	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:55.846976
739	hexagonal_prism_137	red	{0,0,0}	31.375294	259.82666	939.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:55.852358
741	pentagonal_prism_222	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:56.067009
698	cube_183	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:07.259502
702	cube_184	pink	{0,0,0}	-205.90816	345.1413	905.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:07.487162
703	cube_185	pink	{0,0,0}	-206.88084	345.12823	931.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:07.709874
706	cube_186	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:07.943235
710	cube_187	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.534454	cube.usd	2025-03-29 14:52:08.178956
714	cube_188	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:08.408635
692	cylinder_176	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:08.412682
718	cube_189	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:08.644554
696	cylinder_177	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:08.648197
722	cube_190	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 14:52:08.875829
700	cylinder_178	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:08.879384
726	cube_191	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 14:52:09.104299
704	cylinder_179	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:09.108245
730	cube_192	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 14:52:09.324919
708	cylinder_180	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:09.328723
734	cube_193	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:09.564775
712	cylinder_181	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:09.569003
738	cube_194	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:09.789707
716	cylinder_182	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:52:09.79398
742	cube_195	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:52:10.026041
720	cylinder_183	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.874985	cylinder.usd	2025-03-29 14:52:10.028003
724	cylinder_184	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:10.029858
743	cube_196	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:10.273731
728	cylinder_185	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:10.277984
732	cylinder_186	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:10.514564
740	cylinder_188	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:10.978024
1775	pentagonal prism_368	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:36.749402
745	pentagonal_prism_223	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:56.29914
747	hexagonal_prism_138	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:56.306963
749	pentagonal_prism_224	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:56.538512
751	pentagonal_prism_225	red	{0,0,0}	31.497837	260.84146	925.00006	0	0	37.69424	pentagonal_prism.usd	2025-03-29 14:50:56.542965
753	pentagonal_prism_226	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:56.769981
755	hexagonal_prism_139	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:56.775531
757	pentagonal_prism_227	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:56.992339
759	hexagonal_prism_140	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:56.998429
761	pentagonal_prism_228	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:57.214596
763	pentagonal_prism_229	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:57.219117
765	pentagonal_prism_230	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:57.44018
767	hexagonal_prism_141	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:57.444588
769	pentagonal_prism_231	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:57.662661
771	hexagonal_prism_142	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:57.66825
773	pentagonal_prism_232	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:57.889528
775	hexagonal_prism_143	red	{0,0,0}	30.394815	260.80713	931.00006	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:50:57.893517
777	pentagonal_prism_233	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:58.120346
779	hexagonal_prism_144	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:58.125814
781	pentagonal_prism_234	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:58.351382
783	hexagonal_prism_145	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:50:58.358269
785	pentagonal_prism_235	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:58.582115
787	pentagonal_prism_236	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:50:58.587856
789	pentagonal_prism_237	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:58.824488
791	hexagonal_prism_146	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:58.829181
793	pentagonal_prism_238	black	{0,0,0}	-129.45485	522.7604	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:59.047185
795	hexagonal_prism_147	red	{0,0,0}	30.634352	261.8743	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:59.051826
750	cube_198	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:10.746595
754	cube_199	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:10.974182
758	cube_200	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:11.213165
744	cylinder_189	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:11.216822
762	cube_201	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:11.441023
748	cylinder_190	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:11.444848
766	cube_202	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:11.676568
752	cylinder_191	red	{0,0,0}	31.375294	259.82666	933	0	0	37.405357	cylinder.usd	2025-03-29 14:52:11.678613
756	cylinder_192	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:11.680461
770	cube_203	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:11.91131
760	cylinder_193	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:11.915084
774	cube_204	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:12.143587
764	cylinder_194	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:12.147669
778	cube_205	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 14:52:12.379987
768	cylinder_195	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:12.383766
782	cube_206	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:12.62211
772	cylinder_196	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:12.626325
786	cube_207	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:12.843711
776	cylinder_197	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 14:52:12.847672
790	cube_208	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:13.087493
780	cylinder_198	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:13.091582
794	cube_209	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:52:13.310248
788	cylinder_200	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:52:13.55229
792	cylinder_201	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	33.690067	cylinder.usd	2025-03-29 14:52:13.785914
796	cylinder_202	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:14.017577
797	pentagonal_prism_239	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:59.280664
801	pentagonal_prism_240	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:50:59.513944
803	hexagonal_prism_148	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:59.518113
805	pentagonal_prism_241	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:59.754996
807	hexagonal_prism_149	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:50:59.758963
809	pentagonal_prism_242	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:50:59.97998
811	hexagonal_prism_150	red	{0,0,0}	30.394815	260.80713	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:50:59.985824
813	pentagonal_prism_243	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:00.221701
815	hexagonal_prism_151	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:00.226033
817	pentagonal_prism_244	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:00.450565
819	pentagonal_prism_245	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:00.455869
821	pentagonal_prism_246	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:00.677288
823	hexagonal_prism_152	red	{0,0,0}	31.375294	259.82666	920	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:51:00.683047
825	pentagonal_prism_247	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:00.909965
829	pentagonal_prism_248	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:01.14404
831	hexagonal_prism_153	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:01.149749
833	pentagonal_prism_249	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:01.364456
837	pentagonal_prism_250	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:01.605466
839	hexagonal_prism_154	red	{0,0,0}	30.394815	260.80713	916.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:01.612384
841	pentagonal_prism_251	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:01.83228
843	hexagonal_prism_155	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:01.836969
845	pentagonal_prism_252	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:02.063339
847	pentagonal_prism_253	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:51:02.069225
849	pentagonal_prism_254	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:02.300158
799	cube_211	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:13.781339
802	cube_212	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:14.013985
806	cube_213	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:14.25115
800	cylinder_203	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:14.254895
810	cube_214	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.743565	cube.usd	2025-03-29 14:52:14.476777
804	cylinder_204	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:14.480906
814	cube_215	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:14.700554
808	cylinder_205	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:14.704374
818	cube_216	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.743565	cube.usd	2025-03-29 14:52:14.929945
812	cylinder_206	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:14.933736
822	cube_217	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.620872	cube.usd	2025-03-29 14:52:15.163182
816	cylinder_207	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:15.166999
826	cube_218	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 14:52:15.396108
820	cylinder_208	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:15.399924
827	cube_219	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.743565	cube.usd	2025-03-29 14:52:15.635337
824	cylinder_209	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:15.638987
830	cube_220	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:52:15.862656
828	cylinder_210	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:15.866464
834	cube_221	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:16.101367
832	cylinder_211	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:16.105258
835	cube_222	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:16.329009
836	cylinder_212	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:16.333248
838	cube_223	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:16.564441
840	cylinder_213	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:16.568265
842	cube_224	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:16.805521
846	cube_225	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	cube.usd	2025-03-29 14:52:16.807509
844	cylinder_214	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:16.809431
848	cylinder_215	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:17.033757
1776	hexagonal prism_196	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:36.753733
851	hexagonal_prism_156	red	{0,0,0}	30.51353	260.84146	924	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:51:02.305597
853	pentagonal_prism_255	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:02.553412
855	hexagonal_prism_157	red	{0,0,0}	31.376482	259.8365	920	0	0	37.69424	hexagonal_prism.usd	2025-03-29 14:51:02.55749
857	pentagonal_prism_256	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:02.777047
859	hexagonal_prism_158	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:02.781198
861	pentagonal_prism_257	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:03.008664
863	hexagonal_prism_159	red	{0,0,0}	30.51353	260.84146	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:03.014339
865	pentagonal_prism_258	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:03.235399
867	hexagonal_prism_160	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:03.240693
869	pentagonal_prism_259	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:03.464391
871	pentagonal_prism_260	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:03.470351
873	pentagonal_prism_261	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:03.698546
877	pentagonal_prism_262	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:03.930811
879	pentagonal_prism_263	red	{0,0,0}	30.394815	260.80713	936.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:03.936971
881	hexagonal_prism_161	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal_prism.usd	2025-03-29 14:51:04.174314
883	hexagonal_prism_162	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:04.178482
885	pentagonal_prism_264	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:04.402017
887	hexagonal_prism_163	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:04.407563
889	pentagonal_prism_265	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:04.631077
893	pentagonal_prism_266	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:04.872148
895	hexagonal_prism_164	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:04.87761
897	pentagonal_prism_267	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:05.111499
899	hexagonal_prism_165	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:05.117063
901	pentagonal_prism_268	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:05.339029
850	cube_226	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:17.02992
854	cube_227	pink	{0,0,0}	-205.90038	345.12823	910	0	0	59.620872	cube.usd	2025-03-29 14:52:17.264304
858	cube_228	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:17.489485
856	cylinder_217	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:17.493553
862	cube_229	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.743565	cube.usd	2025-03-29 14:52:17.713165
860	cylinder_218	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:17.717362
866	cube_230	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:17.946349
864	cylinder_219	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:17.950175
870	cube_231	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:52:18.182979
868	cylinder_220	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	45	cylinder.usd	2025-03-29 14:52:18.186948
874	cube_232	pink	{0,0,0}	-206.88867	345.1413	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:18.411677
872	cylinder_221	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:18.415981
875	cube_233	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:18.652003
876	cylinder_222	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:18.655943
878	cube_234	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.743565	cube.usd	2025-03-29 14:52:18.883766
880	cylinder_223	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:18.887522
882	cube_235	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:19.113222
884	cylinder_224	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:19.117195
886	cube_236	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:19.354642
888	cylinder_225	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:19.358493
890	cube_237	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:19.581828
892	cylinder_226	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:19.585804
891	cube_238	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:19.817156
896	cylinder_227	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:19.821068
894	cube_239	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:20.058187
900	cylinder_228	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:20.063879
898	cube_240	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:20.285685
902	cube_241	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:20.519344
903	hexagonal_prism_166	red	{0,0,0}	30.51353	260.84146	930.00006	0	0	37.746803	hexagonal_prism.usd	2025-03-29 14:51:05.344559
1777	pentagonal prism_369	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:36.976699
905	pentagonal_prism_269	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:05.572007
907	hexagonal_prism_167	red	{0,0,0}	30.51353	260.84146	927.00006	0	0	37.746803	hexagonal_prism.usd	2025-03-29 14:51:05.576267
909	pentagonal_prism_270	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:05.806084
911	hexagonal_prism_168	red	{0,0,0}	30.514694	260.8514	913.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:05.811832
913	hexagonal_prism_169	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal_prism.usd	2025-03-29 14:51:06.037177
915	hexagonal_prism_170	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:06.043134
917	pentagonal_prism_271	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:06.270288
919	hexagonal_prism_171	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:51:06.275687
921	hexagonal_prism_172	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal_prism.usd	2025-03-29 14:51:06.5109
923	hexagonal_prism_173	red	{0,0,0}	30.51353	260.84146	928.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:06.515298
925	pentagonal_prism_272	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:06.733487
927	hexagonal_prism_174	red	{0,0,0}	31.375294	259.82666	920	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:06.739367
929	pentagonal_prism_273	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:06.974644
931	pentagonal_prism_274	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:06.979006
933	pentagonal_prism_275	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:07.205824
935	hexagonal_prism_175	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:07.211253
937	pentagonal_prism_276	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:07.438982
939	hexagonal_prism_176	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:07.442848
941	hexagonal_prism_177	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	hexagonal_prism.usd	2025-03-29 14:51:07.670965
943	pentagonal_prism_277	red	{0,0,0}	31.497837	259.85715	935.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:07.676317
945	pentagonal_prism_278	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:07.906999
949	pentagonal_prism_279	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:08.127619
953	pentagonal_prism_280	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:08.363322
955	hexagonal_prism_178	red	{0,0,0}	31.375294	259.82666	914.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:08.367775
906	cube_242	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 14:52:20.756958
912	cylinder_231	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:20.761976
910	cube_243	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.03624	cube.usd	2025-03-29 14:52:20.99448
916	cylinder_232	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:20.998751
914	cube_244	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:21.220566
920	cylinder_233	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:52:21.224168
918	cube_245	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.743565	cube.usd	2025-03-29 14:52:21.451846
924	cylinder_234	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:21.455657
922	cube_246	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.620872	cube.usd	2025-03-29 14:52:21.686346
928	cylinder_235	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:21.690234
926	cube_247	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:21.919634
932	cylinder_236	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:21.923286
930	cube_248	pink	{0,0,0}	-206.88867	345.1413	914.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:22.153836
936	cylinder_237	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:52:22.157615
934	cube_249	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:22.378828
940	cylinder_238	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:22.38302
938	cube_250	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:22.60413
944	cylinder_239	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:22.608303
942	cube_251	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:52:22.836914
946	cube_252	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	cube.usd	2025-03-29 14:52:22.839136
948	cylinder_240	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:22.841202
947	cube_253	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:23.058459
950	cube_254	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	cube.usd	2025-03-29 14:52:23.060418
952	cylinder_241	green	{0,0,0}	-270.62216	216.69383	920	0	0	33.690063	cylinder.usd	2025-03-29 14:52:23.062474
951	cube_255	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03624	cube.usd	2025-03-29 14:52:23.301966
956	cylinder_242	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:23.305878
954	cube_256	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	cube.usd	2025-03-29 14:52:23.530326
957	pentagonal_prism_281	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:08.586001
959	hexagonal_prism_179	red	{0,0,0}	31.375294	259.82666	935.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:08.591031
961	pentagonal_prism_282	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:08.814939
963	hexagonal_prism_180	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:08.820553
965	pentagonal_prism_283	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:09.046638
967	pentagonal_prism_284	red	{0,0,0}	30.394815	260.80713	931.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:09.05107
969	pentagonal_prism_285	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:09.275873
971	hexagonal_prism_181	red	{0,0,0}	31.376482	259.8365	929	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:51:09.282333
973	pentagonal_prism_286	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:09.497967
975	hexagonal_prism_182	red	{0,0,0}	31.376482	259.8365	929	0	0	37.647625	hexagonal_prism.usd	2025-03-29 14:51:09.501903
977	pentagonal_prism_287	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:09.715947
981	pentagonal_prism_288	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:09.935261
983	hexagonal_prism_183	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:09.940142
985	pentagonal_prism_289	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:10.158368
987	hexagonal_prism_184	red	{0,0,0}	31.375294	259.82666	919	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:10.163376
989	pentagonal_prism_290	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:10.379435
991	pentagonal_prism_291	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:10.384076
993	pentagonal_prism_292	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:10.602737
995	hexagonal_prism_185	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:10.607791
997	hexagonal_prism_186	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal_prism.usd	2025-03-29 14:51:10.821844
1001	pentagonal_prism_293	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:11.05334
1003	pentagonal_prism_294	red	{0,0,0}	30.395967	260.81702	920	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:11.05825
1005	pentagonal_prism_295	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:11.28776
1007	hexagonal_prism_187	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.647617	hexagonal_prism.usd	2025-03-29 14:51:11.293923
1009	pentagonal_prism_296	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:11.52751
958	cube_257	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03624	cube.usd	2025-03-29 14:52:23.754023
964	cylinder_244	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:23.758607
962	cube_258	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:52:23.98912
968	cylinder_245	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:23.993005
966	cube_259	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:24.232672
972	cylinder_246	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:24.237044
970	cube_260	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:24.471954
974	cube_261	red	{0,0,0}	32.357	258.856	924	0	0	37.476177	cube.usd	2025-03-29 14:52:24.473931
976	cylinder_247	green	{0,0,0}	-270.62216	216.69383	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:24.475869
978	cube_262	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 14:52:24.704595
980	cylinder_248	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 14:52:24.709055
979	cube_263	pink	{0,0,0}	-207.68886	346.4762	915	0	0	59.534454	cube.usd	2025-03-29 14:52:24.947825
984	cylinder_249	green	{0,0,0}	-272.65317	217.53194	929	0	0	18.43495	cylinder.usd	2025-03-29 14:52:24.951798
982	cube_264	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:52:25.177654
988	cylinder_250	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:25.182009
986	cube_265	pink	{0,0,0}	-205.90816	345.1413	907.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:25.39905
992	cylinder_251	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:25.403257
990	cube_266	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:25.622606
996	cylinder_252	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 14:52:25.62625
994	cube_267	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.743565	cube.usd	2025-03-29 14:52:25.864956
1000	cylinder_253	green	{0,0,0}	-270.6119	216.68562	919	0	0	18.434948	cylinder.usd	2025-03-29 14:52:25.869084
998	cube_268	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 14:52:26.087727
1004	cylinder_254	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:26.091554
999	cube_269	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:26.311273
1008	cylinder_255	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:26.315314
1002	cube_270	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	58.392494	cube.usd	2025-03-29 14:52:26.547195
1006	cube_271	pink	{0,0,0}	-206.70456	346.4762	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:26.768243
1011	hexagonal_prism_188	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.746803	hexagonal_prism.usd	2025-03-29 14:51:11.531905
1013	pentagonal_prism_297	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:11.753517
1015	pentagonal_prism_298	red	{0,0,0}	30.394815	260.80713	927.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:11.758379
1017	pentagonal_prism_299	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:11.979132
1019	hexagonal_prism_189	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:11.983369
1021	hexagonal_prism_190	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	0	hexagonal_prism.usd	2025-03-29 14:51:12.212903
1023	pentagonal_prism_300	red	{0,0,0}	30.394815	260.80713	934	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:12.218207
1025	pentagonal_prism_301	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:12.441618
1027	hexagonal_prism_191	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:12.445789
1029	pentagonal_prism_302	black	{0,0,0}	-127.462135	518.67285	652	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:12.675691
1033	pentagonal_prism_303	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:12.90149
1035	hexagonal_prism_192	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:12.907476
1037	pentagonal_prism_304	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:13.12505
1039	hexagonal_prism_193	red	{0,0,0}	31.375294	259.82666	929	0	0	37.874985	hexagonal_prism.usd	2025-03-29 14:51:13.129845
1041	pentagonal_prism_305	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:13.377604
1043	hexagonal_prism_194	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:13.383437
1045	pentagonal_prism_306	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:13.609587
1047	hexagonal_prism_195	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:13.615267
1049	pentagonal_prism_307	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:13.847164
1051	hexagonal_prism_196	orange	{0,0,0}	30.51353	260.84146	931.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:13.852508
1053	pentagonal_prism_308	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:14.078752
1055	pentagonal_prism_309	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.746803	pentagonal_prism.usd	2025-03-29 14:51:14.084351
1057	pentagonal_prism_310	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:14.308937
1059	hexagonal_prism_197	red	{0,0,0}	29.529222	261.82578	929	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:14.314902
1061	pentagonal_prism_311	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:14.543555
1016	cylinder_257	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:26.772673
1010	cube_272	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:26.992115
1014	cube_273	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 14:52:26.994161
1020	cylinder_258	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:26.996114
1018	cube_274	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:27.236542
1024	cylinder_259	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:27.24068
1022	cube_275	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:27.49507
1028	cylinder_260	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:27.500134
1026	cube_276	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:27.722576
1031	cylinder_261	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:27.726346
1030	cube_277	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:27.945058
1032	cylinder_262	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:27.949043
1034	cube_278	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 14:52:28.17479
1036	cylinder_263	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:28.178585
1038	cube_279	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:52:28.40771
1040	cylinder_264	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:28.411513
1042	cube_280	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.743565	cube.usd	2025-03-29 14:52:28.644599
1044	cylinder_265	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:28.64812
1046	cube_281	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:28.877273
1048	cylinder_266	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:52:28.881083
1050	cube_282	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:29.107972
1052	cylinder_267	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:29.112629
1054	cube_283	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 14:52:29.341375
1056	cylinder_268	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:29.345117
1058	cube_284	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:52:29.574326
1060	cylinder_269	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:29.578322
1062	cube_285	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:29.80162
1063	hexagonal_prism_198	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:14.548185
1778	pentagonal prism_370	red	{0,0,0}	32.357	258.856	934	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:36.981376
1065	pentagonal_prism_312	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:14.770257
1067	hexagonal_prism_199	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:14.77757
1069	pentagonal_prism_313	black	{0,0,0}	-127.46985	517.7237	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:15.006458
1073	pentagonal_prism_314	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:15.243293
1075	hexagonal_prism_200	red	{0,0,0}	30.394815	260.80713	929	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:15.247977
1077	pentagonal_prism_315	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:15.464403
1079	hexagonal_prism_201	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:15.47039
1081	pentagonal_prism_316	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:15.698745
1083	hexagonal_prism_202	red	{0,0,0}	30.394815	260.80713	934	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:15.703979
1085	pentagonal_prism_317	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:15.917051
1087	hexagonal_prism_203	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:15.921671
1089	pentagonal_prism_318	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:16.146222
1091	pentagonal_prism_319	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:51:16.150414
1093	pentagonal_prism_320	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:16.376494
1095	hexagonal_prism_204	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:16.382139
1097	pentagonal_prism_321	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:16.605896
1099	hexagonal_prism_205	red	{0,0,0}	30.51353	261.82578	933	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:16.610972
1101	pentagonal_prism_322	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:16.838243
1103	hexagonal_prism_206	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:16.843524
1105	pentagonal_prism_323	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:17.064139
1107	hexagonal_prism_207	red	{0,0,0}	31.375294	259.82666	933	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:17.06909
1109	pentagonal_prism_324	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:17.295511
1111	hexagonal_prism_208	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:17.300086
1113	pentagonal_prism_325	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:17.542051
1115	pentagonal_prism_326	red	{0,0,0}	29.529222	261.82578	920	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:17.546832
1064	cylinder_270	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:29.805978
1070	cube_287	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:30.024838
1068	cylinder_271	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:30.028529
1074	cube_288	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:30.25804
1071	cylinder_272	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 14:52:30.261792
1078	cube_289	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03624	cube.usd	2025-03-29 14:52:30.493718
1072	cylinder_273	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:30.497607
1082	cube_290	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:30.72198
1076	cylinder_274	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:30.726347
1086	cube_291	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:30.962955
1080	cylinder_275	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:30.967036
1090	cube_292	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03625	cube.usd	2025-03-29 14:52:31.193219
1084	cylinder_276	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:31.19696
1094	cube_293	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:52:31.429873
1088	cylinder_277	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:31.433545
1098	cube_294	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:31.668301
1092	cylinder_278	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:31.672482
1102	cube_295	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:52:31.895486
1096	cylinder_279	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:31.899265
1106	cube_296	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 14:52:32.121773
1100	cylinder_280	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:32.126104
1110	cube_297	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:52:32.356728
1104	cylinder_281	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:32.36123
1114	cube_298	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:32.598391
1112	cylinder_283	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:32.838053
1160	cylinder_295	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:35.608693
1117	pentagonal_prism_327	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:17.763218
1164	cylinder_296	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:35.837093
1119	pentagonal_prism_328	red	{0,0,0}	31.497837	259.85715	934	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:17.767299
1168	cylinder_297	green	{0,0,0}	-270.6119	216.68562	942.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:36.072163
1121	pentagonal_prism_329	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:17.994405
1779	pentagonal prism_371	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:37.216332
1123	hexagonal_prism_209	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:18.000099
1125	pentagonal_prism_330	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:18.219424
1127	pentagonal_prism_331	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:51:18.224796
1129	hexagonal_prism_210	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal_prism.usd	2025-03-29 14:51:18.458813
1131	pentagonal_prism_332	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal_prism.usd	2025-03-29 14:51:18.46277
1133	pentagonal_prism_333	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:18.692429
1135	hexagonal_prism_211	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.303947	hexagonal_prism.usd	2025-03-29 14:51:18.698139
1137	pentagonal_prism_334	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:18.926056
1139	pentagonal_prism_335	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:18.931877
1141	pentagonal_prism_336	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:19.167162
1143	hexagonal_prism_212	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.405357	hexagonal_prism.usd	2025-03-29 14:51:19.171001
1145	pentagonal_prism_337	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:19.397402
1147	hexagonal_prism_213	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:19.403076
1149	pentagonal_prism_338	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:19.629065
1151	hexagonal_prism_214	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:19.6339
1153	pentagonal_prism_339	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:19.863429
1155	pentagonal_prism_340	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:19.868088
1157	pentagonal_prism_341	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:20.105484
1159	pentagonal_prism_342	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:20.109705
1161	pentagonal_prism_343	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:20.337404
1163	hexagonal_prism_215	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:20.342705
1165	pentagonal_prism_344	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:20.567406
1167	hexagonal_prism_216	red	{0,0,0}	30.51353	260.84146	923.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:20.571728
1122	cube_300	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:33.056909
1116	cylinder_284	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:33.061277
1126	cube_301	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:52:33.289988
1120	cylinder_285	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:33.294279
1130	cube_302	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.931416	cube.usd	2025-03-29 14:52:33.523041
1124	cylinder_286	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:33.527179
1134	cube_303	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	60.255116	cube.usd	2025-03-29 14:52:33.757345
1128	cylinder_287	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:33.761424
1138	cube_304	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:33.992198
1132	cylinder_288	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:33.996236
1142	cube_305	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:34.213781
1136	cylinder_289	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:34.217473
1146	cube_306	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:52:34.448999
1150	cube_307	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.303947	cube.usd	2025-03-29 14:52:34.451113
1140	cylinder_290	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:34.453107
1154	cube_308	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:34.680389
1144	cylinder_291	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:34.684155
1158	cube_309	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:34.906491
1162	cube_310	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 14:52:35.139258
1152	cylinder_293	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:35.143059
1166	cube_311	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:35.364946
1156	cylinder_294	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:35.369059
1169	pentagonal_prism_345	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:20.795307
1174	cube_313	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:52:35.833086
1171	pentagonal_prism_346	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:20.801223
1173	pentagonal_prism_347	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:21.035601
1175	hexagonal_prism_217	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:21.040849
1177	pentagonal_prism_348	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:21.285496
1179	hexagonal_prism_218	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:21.290923
1181	pentagonal_prism_349	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:21.518102
1183	hexagonal_prism_219	red	{0,0,0}	31.375294	259.82666	933	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:21.522189
1185	pentagonal_prism_350	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:21.753997
1189	pentagonal_prism_351	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:21.981979
1193	pentagonal_prism_352	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:22.212513
1195	hexagonal_prism_220	red	{0,0,0}	31.375294	259.82666	933	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:22.218466
1197	pentagonal_prism_353	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:22.452185
1199	hexagonal_prism_221	red	{0,0,0}	30.51353	260.84146	928.00006	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:22.457583
1201	pentagonal_prism_354	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:22.691102
1203	pentagonal_prism_355	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:22.696779
1205	pentagonal_prism_356	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal_prism.usd	2025-03-29 14:51:22.919097
1207	hexagonal_prism_222	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal_prism.usd	2025-03-29 14:51:22.92323
1209	pentagonal_prism_357	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal_prism.usd	2025-03-29 14:51:23.148791
1211	pentagonal_prism_358	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal_prism.usd	2025-03-29 14:51:23.154681
1213	pentagonal prism_1	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:28.499482
4	cylinder_1	Unknown	{0,0,0}	119.62283	385.3424	1916.0001	0	0	90	cylinder.usd	2025-03-29 14:51:28.505633
1214	hexagonal prism_1	red	{0,0,0}	30.395967	260.81702	946.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:28.512077
1215	pentagonal prism_2	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:28.73133
1216	hexagonal prism_2	red	{0,0,0}	31.375294	259.82666	920	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:51:28.735489
1217	pentagonal prism_3	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:28.950422
1218	hexagonal prism_3	red	{0,0,0}	30.394815	260.80713	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:28.9568
1219	pentagonal prism_4	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:29.179618
1220	hexagonal prism_4	red	{0,0,0}	31.376482	259.8365	919	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:29.18529
1178	cube_314	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.743565	cube.usd	2025-03-29 14:52:36.068252
1182	cube_315	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03624	cube.usd	2025-03-29 14:52:36.304597
1172	cylinder_298	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:36.308373
1186	cube_316	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 14:52:36.525771
1187	cube_317	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 14:52:36.527771
1176	cylinder_299	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:36.52992
1190	cube_318	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 14:52:36.751824
1180	cylinder_300	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:52:36.75589
1191	cube_319	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:52:36.979318
1184	cylinder_301	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:36.983162
1194	cube_320	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.03625	cube.usd	2025-03-29 14:52:37.219796
1188	cylinder_302	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:37.223818
1198	cube_321	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:37.451585
1202	cube_322	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:37.69127
1196	cylinder_304	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:37.695524
1206	cube_323	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:52:37.918108
1200	cylinder_305	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:37.922316
1210	cube_324	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:52:38.151846
1204	cylinder_306	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:38.155653
1208	cylinder_307	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:38.382875
1212	cylinder_308	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:38.625427
1221	pentagonal prism_5	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:29.407326
1222	pentagonal prism_6	red	{0,0,0}	30.394815	260.80713	930.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:29.411479
1223	pentagonal prism_7	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:29.637592
1224	hexagonal prism_5	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:29.642252
1225	pentagonal prism_8	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:29.869083
1226	hexagonal prism_6	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:29.873917
1227	pentagonal prism_9	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:30.090206
1228	hexagonal prism_7	red	{0,0,0}	31.375294	259.82666	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:30.094361
1229	pentagonal prism_10	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:30.321305
1230	hexagonal prism_8	red	{0,0,0}	30.51353	260.84146	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:30.325946
1231	pentagonal prism_11	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:30.556111
1232	pentagonal prism_12	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:30.561932
44	cylinder_12	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:30.56372
1233	pentagonal prism_13	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:30.782287
1234	hexagonal prism_9	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:30.787729
1235	pentagonal prism_14	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:31.005591
1236	pentagonal prism_15	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:31.238662
54	cube_14	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:31.24234
1237	pentagonal prism_16	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:31.244554
1238	pentagonal prism_17	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:31.467436
1239	pentagonal prism_18	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:31.687322
1240	hexagonal prism_10	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:31.692631
1241	pentagonal prism_19	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:31.926175
1242	hexagonal prism_11	red	{0,0,0}	30.394815	260.80713	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:31.931777
1243	pentagonal prism_20	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:32.151643
1244	hexagonal prism_12	red	{0,0,0}	30.51353	260.84146	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:32.155808
1245	pentagonal prism_21	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:32.378306
1246	hexagonal prism_13	red	{0,0,0}	30.51353	260.84146	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:32.382613
1247	pentagonal prism_22	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:32.609476
1248	hexagonal prism_14	red	{0,0,0}	31.375294	259.82666	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:32.613938
1249	pentagonal prism_23	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:32.843873
1250	hexagonal prism_15	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:32.847923
1251	pentagonal prism_24	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:33.07777
1252	pentagonal prism_25	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:33.082981
1253	pentagonal prism_26	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:51:33.311184
1254	pentagonal prism_27	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:33.316548
1255	pentagonal prism_28	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:51:33.54636
1256	hexagonal prism_16	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:33.552078
1257	pentagonal prism_29	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:33.778345
1258	pentagonal prism_30	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:34.008062
1259	pentagonal prism_31	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:51:34.244779
110	cube_30	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:34.247206
1260	hexagonal prism_17	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:34.249344
1261	pentagonal prism_32	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:34.481143
1262	hexagonal prism_18	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:34.485839
1263	pentagonal prism_33	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:34.712955
1264	hexagonal prism_19	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:34.717071
1265	pentagonal prism_34	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:34.937109
1266	hexagonal prism_20	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:34.942756
1267	pentagonal prism_35	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:35.16172
1268	hexagonal prism_21	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:51:35.16574
1269	pentagonal prism_36	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:35.390334
1270	hexagonal prism_22	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:35.396775
132	cylinder_34	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:35.63447
1273	pentagonal prism_39	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:35.86693
1274	pentagonal prism_40	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:35.873217
1275	pentagonal prism_41	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:36.099407
1276	hexagonal prism_23	red	{0,0,0}	30.51353	260.84146	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:36.105112
1277	pentagonal prism_42	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:36.330378
1278	hexagonal prism_24	red	{0,0,0}	30.51353	260.84146	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:36.336061
1279	pentagonal prism_43	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:36.551446
1280	hexagonal prism_25	red	{0,0,0}	30.394815	260.80713	925.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:51:36.555899
1281	pentagonal prism_44	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:36.775769
1282	pentagonal prism_45	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 14:51:36.78081
1283	pentagonal prism_46	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:37.008832
1284	hexagonal prism_26	red	{0,0,0}	31.375294	259.82666	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:37.013458
1285	pentagonal prism_47	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:37.239537
162	cube_43	pink	{0,0,0}	-206.88867	345.1413	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:51:37.244584
1286	hexagonal prism_27	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 14:51:37.464773
1287	pentagonal prism_48	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:37.468932
1288	pentagonal prism_49	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal prism.usd	2025-03-29 14:51:37.700329
1289	hexagonal prism_28	red	{0,0,0}	31.375294	259.82666	929	0	0	37.746803	hexagonal prism.usd	2025-03-29 14:51:37.705886
1290	pentagonal prism_50	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:37.924877
1291	hexagonal prism_29	red	{0,0,0}	31.499039	259.86707	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:37.930346
1292	pentagonal prism_51	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:38.144801
1293	hexagonal prism_30	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:38.150949
1294	pentagonal prism_52	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:38.36811
1295	hexagonal prism_31	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:38.372487
1296	pentagonal prism_53	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:38.5936
1297	pentagonal prism_54	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:51:38.599839
1298	pentagonal prism_55	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:38.834152
1299	hexagonal prism_32	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:38.840501
1300	pentagonal prism_56	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:39.077626
1301	pentagonal prism_57	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:39.315976
1302	pentagonal prism_58	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:39.540355
1303	hexagonal prism_33	red	{0,0,0}	30.51353	260.84146	934	0	0	37.746803	hexagonal prism.usd	2025-03-29 14:51:39.546026
1304	pentagonal prism_59	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:39.77098
1305	pentagonal prism_60	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:39.77506
1306	pentagonal prism_61	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:39.998119
214	cube_58	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 14:51:40.000363
1307	pentagonal prism_62	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 14:51:40.002649
1308	pentagonal prism_63	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:40.235732
1309	hexagonal prism_34	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:40.240068
1310	pentagonal prism_64	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:40.48693
1311	hexagonal prism_35	red	{0,0,0}	31.375294	259.82666	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:51:40.492323
1312	pentagonal prism_65	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:40.717023
1313	hexagonal prism_36	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:40.722424
1314	pentagonal prism_66	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:40.95283
1315	hexagonal prism_37	red	{0,0,0}	31.375294	259.82666	924	0	0	37.746803	hexagonal prism.usd	2025-03-29 14:51:40.956913
1316	pentagonal prism_67	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:41.187138
1317	pentagonal prism_68	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:41.192845
1318	pentagonal prism_69	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:41.42005
1319	hexagonal prism_38	red	{0,0,0}	31.376482	259.8365	920	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:51:41.425465
1320	pentagonal prism_70	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:41.650113
1321	hexagonal prism_39	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:41.654417
1322	pentagonal prism_71	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:41.886411
1323	hexagonal prism_40	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:41.891938
1324	pentagonal prism_72	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:42.115071
1325	pentagonal prism_73	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:42.120868
244	cylinder_62	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:42.1226
1326	pentagonal prism_74	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:42.352767
1327	hexagonal prism_41	red	{0,0,0}	31.375294	259.82666	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:51:42.357051
1328	pentagonal prism_75	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:42.586086
1329	pentagonal prism_76	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:42.59143
1330	pentagonal prism_77	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:42.818007
1331	hexagonal prism_42	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:42.822066
1332	pentagonal prism_78	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:43.054703
266	cube_71	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:43.058398
1333	hexagonal prism_43	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:43.060386
1334	pentagonal prism_79	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:43.27979
1335	hexagonal prism_44	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:43.284351
1336	pentagonal prism_80	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:43.513281
1337	hexagonal prism_45	red	{0,0,0}	30.51353	260.84146	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:43.519136
1338	pentagonal prism_81	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:43.760398
1339	pentagonal prism_82	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:43.997747
1340	hexagonal prism_46	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:44.002636
1341	pentagonal prism_83	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:44.233421
1342	pentagonal prism_84	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:44.239242
1343	pentagonal prism_85	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:44.480544
1344	hexagonal prism_47	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:44.486792
1345	pentagonal prism_86	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:44.728022
1346	hexagonal prism_48	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:44.733827
1347	pentagonal prism_87	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:44.954924
1348	hexagonal prism_49	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:44.959475
1349	pentagonal prism_88	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:45.188199
1350	hexagonal prism_50	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:45.192701
1351	pentagonal prism_89	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:45.42637
1352	hexagonal prism_51	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:45.430309
1353	pentagonal prism_90	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:45.649831
1354	hexagonal prism_52	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:45.655922
1355	hexagonal prism_53	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 14:51:45.889012
1356	hexagonal prism_54	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:45.893118
1357	pentagonal prism_91	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:46.115563
1358	hexagonal prism_55	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:46.121537
1359	pentagonal prism_92	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:46.342317
322	cube_86	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:46.344435
1360	hexagonal prism_56	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:46.34626
1361	pentagonal prism_93	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:46.560213
1362	pentagonal prism_94	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:46.564292
1363	pentagonal prism_95	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:46.784171
1364	hexagonal prism_57	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:46.790198
1365	pentagonal prism_96	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:47.023944
1366	pentagonal prism_97	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:47.029379
1367	pentagonal prism_98	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:47.256592
1368	hexagonal prism_58	red	{0,0,0}	31.375294	259.82666	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:47.26236
1369	pentagonal prism_99	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:47.496521
1370	hexagonal prism_59	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:47.500833
1371	pentagonal prism_100	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:47.733377
1372	pentagonal prism_101	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:47.954862
1373	hexagonal prism_60	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:47.959151
1374	pentagonal prism_102	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:51:48.187805
1375	hexagonal prism_61	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:48.193362
1376	pentagonal prism_103	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:48.43421
1377	hexagonal prism_62	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:48.439166
1378	pentagonal prism_104	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:48.657729
1379	hexagonal prism_63	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:48.66261
1380	pentagonal prism_105	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:48.884819
1381	pentagonal prism_106	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:48.890679
1382	pentagonal prism_107	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:49.126527
1383	hexagonal prism_64	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:49.130685
1384	pentagonal prism_108	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:49.351902
374	cube_100	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.34933	cube.usd	2025-03-29 14:51:49.355866
1385	pentagonal prism_109	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:51:49.593148
1386	hexagonal prism_65	red	{0,0,0}	31.375294	259.82666	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:51:49.598544
1387	pentagonal prism_110	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:49.824589
1388	pentagonal prism_111	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:50.052677
1389	pentagonal prism_112	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:50.057342
1390	pentagonal prism_113	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:50.27062
1391	hexagonal prism_66	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:51:50.275007
1392	pentagonal prism_114	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:50.507588
1393	hexagonal prism_67	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:50.511793
1394	pentagonal prism_115	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:50.747171
1395	pentagonal prism_116	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.184704	pentagonal prism.usd	2025-03-29 14:51:50.752469
1396	pentagonal prism_117	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:50.976645
1397	pentagonal prism_118	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:50.982518
1398	pentagonal prism_119	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:51.208358
1399	hexagonal prism_68	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:51.21386
1400	pentagonal prism_120	black	{0,0,0}	-128.94919	520.7185	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:51.445549
1401	hexagonal prism_69	red	{0,0,0}	30.514694	260.8514	934	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:51:51.450135
1402	pentagonal prism_121	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:51.676223
1403	hexagonal prism_70	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:51.681324
408	cylinder_103	green	{0,0,0}	-270.6119	217.6661	924	0	0	18.434948	cylinder.usd	2025-03-29 14:51:51.683194
1404	pentagonal prism_122	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:51.907736
426	cube_113	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:51:51.910245
1405	pentagonal prism_123	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:51.912262
1406	pentagonal prism_124	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:52.144056
1407	hexagonal prism_71	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:52.14996
1408	pentagonal prism_125	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:52.366405
1409	pentagonal prism_126	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:52.372056
1410	pentagonal prism_127	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:52.608207
1411	hexagonal prism_72	red	{0,0,0}	31.375294	259.82666	920	0	0	37.746803	hexagonal prism.usd	2025-03-29 14:51:52.613749
1412	pentagonal prism_128	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:52.835668
1413	hexagonal prism_73	red	{0,0,0}	31.375294	259.82666	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:52.84163
1414	pentagonal prism_129	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:53.058747
1415	hexagonal prism_74	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:53.063254
1416	pentagonal prism_130	black	{0,0,0}	-128.94919	520.7185	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:53.297793
1417	hexagonal prism_75	red	{0,0,0}	31.499039	259.86707	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:53.301933
1418	pentagonal prism_131	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:53.523298
1419	hexagonal prism_76	red	{0,0,0}	30.51353	260.84146	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:53.528992
1420	pentagonal prism_132	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:53.764654
1421	hexagonal prism_77	red	{0,0,0}	31.375294	259.82666	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:53.770378
1422	pentagonal prism_133	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:53.9871
1423	hexagonal prism_78	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:53.992246
1424	pentagonal prism_134	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:51:54.215797
1425	hexagonal prism_79	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:54.222305
1426	pentagonal prism_135	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:51:54.446235
1427	hexagonal prism_80	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:54.451502
1428	pentagonal prism_136	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:54.674725
1429	hexagonal prism_81	red	{0,0,0}	31.375294	259.82666	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:54.679233
1430	pentagonal prism_137	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:54.901774
478	cube_126	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:51:54.905355
1431	hexagonal prism_82	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:54.907576
1432	pentagonal prism_138	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:55.127838
1433	hexagonal prism_83	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:55.132134
1434	pentagonal prism_139	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:55.366948
1435	hexagonal prism_84	red	{0,0,0}	31.375294	259.82666	935.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:55.372344
472	cylinder_119	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:55.374208
1436	pentagonal prism_140	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:55.591508
1437	pentagonal prism_141	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 14:51:55.597159
1438	pentagonal prism_142	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:55.823521
1439	pentagonal prism_143	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:56.059007
1440	hexagonal prism_85	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:56.063959
1441	pentagonal prism_144	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:56.282318
1442	hexagonal prism_86	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:56.286646
1443	pentagonal prism_145	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:56.51208
1444	pentagonal prism_146	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:56.516022
1445	pentagonal prism_147	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:56.747358
1446	hexagonal prism_87	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:56.753111
1447	pentagonal prism_148	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:56.979025
1448	pentagonal prism_149	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:56.984448
1449	pentagonal prism_150	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:57.214186
1450	pentagonal prism_151	red	{0,0,0}	30.394815	260.80713	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:57.219865
1451	hexagonal prism_88	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 14:51:57.442976
1452	hexagonal prism_89	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:57.447611
1453	pentagonal prism_152	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:57.686658
1454	pentagonal prism_153	red	{0,0,0}	30.394815	260.80713	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:57.692082
1455	pentagonal prism_154	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:51:57.910876
534	cube_140	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:51:57.913631
1456	hexagonal prism_90	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:57.915601
1457	pentagonal prism_155	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:58.146419
538	cube_141	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.620872	cube.usd	2025-03-29 14:51:58.150002
520	cylinder_131	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:51:58.153751
1458	pentagonal prism_156	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:58.369425
1459	hexagonal prism_91	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:58.375647
1460	pentagonal prism_157	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:58.595523
1461	pentagonal prism_158	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:58.600337
1462	pentagonal prism_159	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:58.817563
1463	hexagonal prism_92	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:51:58.821695
1464	pentagonal prism_160	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:59.048285
1465	pentagonal prism_161	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:51:59.054316
1466	pentagonal prism_162	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:51:59.283107
1467	pentagonal prism_163	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:59.288283
1468	pentagonal prism_164	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 14:51:59.522932
1469	pentagonal prism_165	red	{0,0,0}	32.355774	258.8462	924	0	0	37.234837	pentagonal prism.usd	2025-03-29 14:51:59.528397
1470	pentagonal prism_166	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:51:59.748932
1471	hexagonal prism_93	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:51:59.754428
1472	pentagonal prism_167	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:51:59.984108
1473	pentagonal prism_168	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:51:59.98969
1474	pentagonal prism_169	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:00.242654
1475	pentagonal prism_170	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:00.247116
1476	pentagonal prism_171	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:00.466861
1477	pentagonal prism_172	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:00.470961
1478	pentagonal prism_173	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:00.702881
1479	hexagonal prism_94	red	{0,0,0}	31.375294	259.82666	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:00.708546
1480	pentagonal prism_174	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:00.933541
586	cube_154	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:00.9357
1481	hexagonal prism_95	red	{0,0,0}	30.514694	260.8514	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:00.937593
1482	pentagonal prism_175	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:01.175631
1483	pentagonal prism_176	red	{0,0,0}	30.395967	260.81702	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:01.181873
1484	pentagonal prism_177	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:01.406248
1485	hexagonal prism_96	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:01.412959
1486	pentagonal prism_178	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:01.634852
1487	hexagonal prism_97	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:01.639141
1488	pentagonal prism_179	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:01.867733
1489	hexagonal prism_98	red	{0,0,0}	30.51353	260.84146	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:01.873395
1490	pentagonal prism_180	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:02.102613
1491	hexagonal prism_99	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:02.107783
1492	pentagonal prism_181	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:02.33487
1493	hexagonal prism_100	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:02.340347
1494	pentagonal prism_182	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:02.563291
1495	hexagonal prism_101	red	{0,0,0}	31.375294	259.82666	937.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:02.568974
1496	pentagonal prism_183	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:02.801239
1497	pentagonal prism_184	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:03.03639
1498	hexagonal prism_102	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.746803	hexagonal prism.usd	2025-03-29 14:52:03.042321
1499	pentagonal prism_185	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:03.265489
1500	hexagonal prism_103	red	{0,0,0}	30.394815	260.80713	934	0	0	37.746803	hexagonal prism.usd	2025-03-29 14:52:03.271375
1501	pentagonal prism_186	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:03.507894
1502	hexagonal prism_104	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:03.513449
1503	pentagonal prism_187	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:03.735913
638	cube_167	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:03.739365
1504	hexagonal prism_105	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:03.741224
1505	pentagonal prism_188	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:03.972819
1506	hexagonal prism_106	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:03.978569
1507	pentagonal prism_189	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:04.200262
1508	pentagonal prism_190	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:04.204794
1509	pentagonal prism_191	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:04.433189
1510	hexagonal prism_107	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:04.438798
624	cylinder_158	green	{0,0,0}	-270.62216	216.69383	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:04.440595
1511	pentagonal prism_192	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:04.667268
1512	hexagonal prism_108	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:04.672884
1513	pentagonal prism_193	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:04.903896
1514	pentagonal prism_194	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:05.138694
1515	pentagonal prism_195	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:05.14479
1516	pentagonal prism_196	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:05.368826
1517	hexagonal prism_109	red	{0,0,0}	31.375294	259.82666	937.00006	0	0	37.746803	hexagonal prism.usd	2025-03-29 14:52:05.374662
1518	pentagonal prism_197	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:05.611439
1519	hexagonal prism_110	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:05.615633
1520	pentagonal prism_198	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:05.842258
1521	hexagonal prism_111	red	{0,0,0}	31.375294	259.82666	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:05.84789
1522	pentagonal prism_199	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:06.071515
1523	hexagonal prism_112	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:06.075973
1524	pentagonal prism_200	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:06.313892
1525	hexagonal prism_113	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:06.319684
1526	pentagonal prism_201	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:06.552532
1527	pentagonal prism_202	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:06.557009
1528	pentagonal prism_203	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:06.788709
1529	hexagonal prism_114	red	{0,0,0}	31.497837	260.84146	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:06.79421
1530	pentagonal prism_204	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:07.027077
694	cube_182	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:07.029541
1531	hexagonal prism_115	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:07.031819
1532	pentagonal prism_205	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:07.256065
1533	hexagonal prism_116	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:07.261529
1534	pentagonal prism_206	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:07.484922
1535	hexagonal prism_117	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:07.489437
1536	pentagonal prism_207	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:07.707218
1537	hexagonal prism_118	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:07.712133
676	cylinder_172	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 14:52:07.714014
1538	pentagonal prism_208	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:07.939622
1539	pentagonal prism_209	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:52:07.945225
1540	pentagonal prism_210	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:08.175195
1541	pentagonal prism_211	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:08.18105
1542	pentagonal prism_212	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:08.404774
1543	pentagonal prism_213	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:08.641051
1544	hexagonal prism_119	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:08.646476
1545	pentagonal prism_214	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:08.872308
1546	pentagonal prism_215	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:08.877671
1547	pentagonal prism_216	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:09.101599
1548	hexagonal prism_120	red	{0,0,0}	31.375294	259.82666	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:09.106472
1549	pentagonal prism_217	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:09.322167
1550	pentagonal prism_218	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:09.326932
1551	pentagonal prism_219	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:09.561258
1552	hexagonal prism_121	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:09.566749
1553	pentagonal prism_220	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:09.787114
1554	hexagonal prism_122	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:09.791852
1555	pentagonal prism_221	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:10.022315
1556	pentagonal prism_222	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:10.271097
1557	hexagonal prism_123	red	{0,0,0}	30.51353	260.84146	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:10.276062
1558	pentagonal prism_223	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:10.508474
746	cube_197	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:10.510584
1559	hexagonal prism_124	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:10.512707
1560	pentagonal prism_224	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:10.74275
1561	pentagonal prism_225	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:10.74849
736	cylinder_187	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:10.750353
1562	pentagonal prism_226	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:10.971677
1563	pentagonal prism_227	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:10.976175
1564	pentagonal prism_228	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:11.209634
1565	hexagonal prism_125	orange	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:11.21507
1566	pentagonal prism_229	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:11.437162
1567	hexagonal prism_126	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:11.443098
1568	pentagonal prism_230	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:11.673944
1569	pentagonal prism_231	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:11.907754
1570	hexagonal prism_127	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:11.913282
1571	pentagonal prism_232	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:12.139618
1572	hexagonal prism_128	red	{0,0,0}	31.375294	259.82666	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:12.145617
1573	pentagonal prism_233	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:12.377729
1574	hexagonal prism_129	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:12.382013
1575	pentagonal prism_234	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:12.618653
1576	hexagonal prism_130	red	{0,0,0}	30.51353	260.84146	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:12.62423
1577	pentagonal prism_235	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:12.841475
1578	pentagonal prism_236	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:12.845768
1579	pentagonal prism_237	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:13.085243
1580	pentagonal prism_238	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:13.0895
1581	pentagonal prism_239	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:13.307128
1582	hexagonal prism_131	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:13.312225
784	cylinder_199	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:13.314035
1583	pentagonal prism_240	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:13.54493
798	cube_210	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 14:52:13.54857
1584	pentagonal prism_241	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:13.550461
1585	pentagonal prism_242	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:13.777298
1586	pentagonal prism_243	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:13.783697
1587	pentagonal prism_244	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:14.010451
1588	hexagonal prism_132	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:14.015876
1589	pentagonal prism_245	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:14.247655
1590	hexagonal prism_133	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:14.253041
1591	pentagonal prism_246	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:14.472936
1592	pentagonal prism_247	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:14.478988
1593	pentagonal prism_248	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:14.697944
1594	pentagonal prism_249	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:14.702515
1595	pentagonal prism_250	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:14.926085
1596	hexagonal prism_134	red	{0,0,0}	30.51353	260.84146	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:14.931907
1597	pentagonal prism_251	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:15.159025
1598	hexagonal prism_135	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:52:15.165211
1599	pentagonal prism_252	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:15.392436
1600	hexagonal prism_136	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:52:15.398092
1601	pentagonal prism_253	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:15.631826
1602	pentagonal prism_254	red	{0,0,0}	32.357	258.856	920	0	0	37.746803	pentagonal prism.usd	2025-03-29 14:52:15.637189
1603	pentagonal prism_255	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:15.858814
1604	hexagonal prism_137	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:15.864648
1605	pentagonal prism_256	black	{0,0,0}	-127.46696	518.69244	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:16.09775
1606	hexagonal prism_138	orange	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:16.103405
1607	pentagonal prism_257	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:16.325053
1608	hexagonal prism_139	red	{0,0,0}	31.376482	259.8365	915	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:16.331111
1609	pentagonal prism_258	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:16.562193
1610	pentagonal prism_259	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:52:16.566476
1611	pentagonal prism_260	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:16.802077
1612	pentagonal prism_261	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:17.027016
1613	pentagonal prism_262	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:17.031998
1614	pentagonal prism_263	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:17.260388
1615	hexagonal prism_140	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:17.266259
852	cylinder_216	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:17.268141
1616	pentagonal prism_264	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:17.487367
1617	pentagonal prism_265	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:17.491688
1618	pentagonal prism_266	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:17.71007
1619	pentagonal prism_267	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 14:52:17.715441
1620	pentagonal prism_268	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:17.943461
1621	hexagonal prism_141	red	{0,0,0}	30.394815	260.80713	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:17.948413
1622	pentagonal prism_269	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:18.179363
1623	pentagonal prism_270	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:18.185032
1624	pentagonal prism_271	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:18.407801
1625	hexagonal prism_142	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:18.413959
1626	pentagonal prism_272	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:18.648674
1627	hexagonal prism_143	red	{0,0,0}	31.375294	259.82666	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:18.654138
1628	pentagonal prism_273	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:18.880278
1629	hexagonal prism_144	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:52:18.885723
1630	pentagonal prism_274	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:19.11105
1631	hexagonal prism_145	red	{0,0,0}	30.51353	260.84146	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:19.115298
1632	pentagonal prism_275	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:19.351083
1633	hexagonal prism_146	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:19.356574
1634	pentagonal prism_276	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:19.577995
1635	hexagonal prism_147	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:19.583865
1636	pentagonal prism_277	black	{0,0,0}	-127.462135	518.67285	652	0	0	90	pentagonal prism.usd	2025-03-29 14:52:19.813707
1637	hexagonal prism_148	red	{0,0,0}	31.375294	259.82666	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:52:19.819186
1638	pentagonal prism_278	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:20.053299
1639	hexagonal prism_149	red	{0,0,0}	30.394815	260.80713	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:20.061484
1640	pentagonal prism_279	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:20.283508
1641	hexagonal prism_150	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:20.287879
904	cylinder_229	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:20.289801
1642	pentagonal prism_280	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:20.517056
1643	hexagonal prism_151	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:20.521659
908	cylinder_230	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:20.523742
1644	pentagonal prism_281	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:20.753391
1645	hexagonal prism_152	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:20.759429
1646	pentagonal prism_282	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:20.990877
1647	pentagonal prism_283	red	{0,0,0}	30.394815	260.80713	934	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:20.996526
1648	pentagonal prism_284	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:21.217768
1649	hexagonal prism_153	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:21.222413
1650	pentagonal prism_285	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:21.449526
1651	pentagonal prism_286	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:21.453796
1652	pentagonal prism_287	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:21.683577
1653	hexagonal prism_154	red	{0,0,0}	31.376482	259.8365	934	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:52:21.688354
1654	pentagonal prism_288	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:21.917307
1655	hexagonal prism_155	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:21.921525
1656	pentagonal prism_289	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:22.150233
1657	pentagonal prism_290	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:22.155827
1658	pentagonal prism_291	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:22.375538
1659	pentagonal prism_292	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:22.380697
1660	pentagonal prism_293	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:22.601419
1661	hexagonal prism_156	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:22.606078
1662	pentagonal prism_294	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:22.833275
1663	pentagonal prism_295	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:23.056065
1664	pentagonal prism_296	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:23.299157
1665	pentagonal prism_297	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:23.304027
1666	pentagonal prism_298	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:23.526578
1667	hexagonal prism_157	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:23.532328
960	cylinder_243	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:23.534762
1668	pentagonal prism_299	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:23.751165
1669	hexagonal prism_158	red	{0,0,0}	31.375294	259.82666	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:23.756474
1670	pentagonal prism_300	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:23.985501
1671	hexagonal prism_159	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:52:23.991175
1672	pentagonal prism_301	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:52:24.229066
1673	hexagonal prism_160	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:24.234872
1674	pentagonal prism_302	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:24.468115
1675	pentagonal prism_303	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:24.700689
1676	hexagonal prism_161	red	{0,0,0}	30.51353	260.84146	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:24.707036
1677	pentagonal prism_304	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:24.944142
1678	hexagonal prism_162	red	{0,0,0}	30.51353	260.84146	922.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:52:24.949754
1679	pentagonal prism_305	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:25.174089
1680	pentagonal prism_306	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:25.179896
1681	pentagonal prism_307	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:25.395386
1682	hexagonal prism_163	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:52:25.401027
1683	pentagonal prism_308	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:25.61966
1684	hexagonal prism_164	red	{0,0,0}	31.375294	259.82666	929	0	0	37.746803	hexagonal prism.usd	2025-03-29 14:52:25.624469
1685	pentagonal prism_309	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:25.861109
1686	hexagonal prism_165	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:25.867139
1687	pentagonal prism_310	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:52:26.084919
1688	hexagonal prism_166	red	{0,0,0}	31.375294	259.82666	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:52:26.089773
1689	pentagonal prism_311	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:26.309001
1690	pentagonal prism_312	red	{0,0,0}	30.395967	260.81702	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:26.313341
1691	pentagonal prism_313	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:26.54514
1692	hexagonal prism_167	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:26.549266
1012	cylinder_256	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:26.551278
1693	pentagonal prism_314	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:26.764477
1694	hexagonal prism_168	red	{0,0,0}	31.497837	260.84146	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:26.770574
1695	pentagonal prism_315	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:26.988947
1696	pentagonal prism_316	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:27.232475
1697	pentagonal prism_317	red	{0,0,0}	32.355774	258.8462	934	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:52:27.238835
1698	pentagonal prism_318	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:27.492673
1699	hexagonal prism_169	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:27.498235
1700	pentagonal prism_319	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:27.720014
1701	hexagonal prism_170	red	{0,0,0}	30.394815	260.80713	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:27.724499
1702	pentagonal prism_320	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:27.942389
1703	hexagonal prism_171	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:27.947087
1704	pentagonal prism_321	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:28.171248
1705	hexagonal prism_172	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:28.17677
1706	pentagonal prism_322	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:28.40403
1707	hexagonal prism_173	red	{0,0,0}	30.395967	260.81702	935.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:28.409663
1708	pentagonal prism_323	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:28.642402
1709	pentagonal prism_324	red	{0,0,0}	32.357	258.856	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:28.646444
1710	pentagonal prism_325	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:28.873752
1711	hexagonal prism_174	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:28.879224
1712	pentagonal prism_326	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:29.104165
1713	hexagonal prism_175	red	{0,0,0}	30.51353	260.84146	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:29.110804
1714	pentagonal prism_327	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:29.337577
1715	hexagonal prism_176	red	{0,0,0}	31.375294	259.82666	938	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:29.343349
1716	pentagonal prism_328	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:29.570413
1717	hexagonal prism_177	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:29.576462
1718	pentagonal prism_329	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:29.797968
1066	cube_286	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	cube.usd	2025-03-29 14:52:29.803762
1719	pentagonal prism_330	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:30.022026
1720	pentagonal prism_331	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:30.026759
1721	pentagonal prism_332	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:30.255775
1722	hexagonal prism_178	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:30.259985
1723	pentagonal prism_333	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:30.491487
1724	hexagonal prism_179	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:30.495769
1725	pentagonal prism_334	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:30.719623
1726	hexagonal prism_180	red	{0,0,0}	31.375294	259.82666	936.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:30.724409
1727	pentagonal prism_335	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:30.95924
1728	hexagonal prism_181	red	{0,0,0}	30.395967	260.81702	917.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:30.965075
1729	pentagonal prism_336	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:31.189448
1730	hexagonal prism_182	red	{0,0,0}	30.51353	260.84146	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:31.195215
1731	pentagonal prism_337	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:31.42664
1732	pentagonal prism_338	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:31.431775
1733	pentagonal prism_339	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:31.665673
1734	hexagonal prism_183	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:52:31.670555
1735	pentagonal prism_340	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:31.892954
1736	hexagonal prism_184	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:31.897492
1737	pentagonal prism_341	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:32.118273
1738	pentagonal prism_342	red	{0,0,0}	30.394815	260.80713	937.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:32.12395
1739	pentagonal prism_343	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:32.353074
1740	hexagonal prism_185	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:32.35926
1741	pentagonal prism_344	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:32.594942
1742	hexagonal prism_186	red	{0,0,0}	31.375294	259.82666	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:52:32.600437
1108	cylinder_282	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:32.602255
1743	pentagonal prism_345	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:32.831525
1118	cube_299	pink	{0,0,0}	-205.90816	345.1413	908.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:32.834048
1744	pentagonal prism_346	red	{0,0,0}	30.395967	260.81702	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:32.83617
1745	pentagonal prism_347	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:33.054605
1746	pentagonal prism_348	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 14:52:33.059321
1747	pentagonal prism_349	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:33.286451
1748	hexagonal prism_187	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:52:33.291985
1749	pentagonal prism_350	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:33.519279
1750	pentagonal prism_351	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:52:33.525185
1751	pentagonal prism_352	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:33.753882
1752	hexagonal prism_188	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:33.759424
1753	pentagonal prism_353	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:33.988757
1754	pentagonal prism_354	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:33.99435
1755	pentagonal prism_355	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:34.211438
1756	hexagonal prism_189	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:34.215667
1757	pentagonal prism_356	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:34.445577
1758	pentagonal prism_357	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:34.678328
1759	hexagonal prism_190	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:34.682315
1760	pentagonal prism_358	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:34.902684
1761	hexagonal prism_191	red	{0,0,0}	30.51353	260.84146	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:34.908483
1148	cylinder_292	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 14:52:34.911215
1762	pentagonal prism_359	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:35.135698
1763	pentagonal prism_360	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:35.141169
1764	pentagonal prism_361	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:35.362474
1765	hexagonal prism_192	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:52:35.367149
1766	pentagonal prism_362	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:35.600794
1170	cube_312	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:35.603117
1780	pentagonal prism_372	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:37.221854
1781	pentagonal prism_373	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:37.447996
1782	pentagonal prism_374	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:37.453638
1192	cylinder_303	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:37.455381
1783	pentagonal prism_375	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:37.687595
1784	hexagonal prism_197	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:37.693458
1785	pentagonal prism_376	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:37.915137
1786	hexagonal prism_198	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:37.920339
1787	pentagonal prism_377	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:38.147911
1788	cube_325	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cube.usd	2025-03-29 14:52:38.153872
1789	pentagonal prism_378	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:38.375964
1790	cube_326	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 14:52:38.37854
1791	hexagonal prism_199	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:38.380987
1792	pentagonal prism_379	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:38.617733
1793	cube_327	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:38.621439
1794	hexagonal prism_200	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:38.623467
1795	pentagonal prism_380	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:38.842692
1796	cube_328	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:38.846269
1797	hexagonal prism_201	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:38.848219
1798	cylinder_309	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:38.850112
1799	pentagonal prism_381	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:39.090738
1800	cube_329	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:39.093138
1801	pentagonal prism_382	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:39.094934
1802	cylinder_310	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:52:39.097028
1803	pentagonal prism_383	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:39.313747
1804	cube_330	pink	{0,0,0}	-207.6968	346.48944	932.00006	0	0	59.743565	cube.usd	2025-03-29 14:52:39.316525
1805	hexagonal prism_202	red	{0,0,0}	30.514694	260.8514	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:39.318341
1806	cylinder_311	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:39.320252
1807	pentagonal prism_384	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:39.549194
1808	cube_331	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 14:52:39.551397
1809	hexagonal prism_203	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:39.553383
1810	cylinder_312	green	{0,0,0}	-270.6119	216.68562	938	0	0	26.56505	cylinder.usd	2025-03-29 14:52:39.555118
1811	pentagonal prism_385	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:39.785333
1812	cube_332	pink	{0,0,0}	-207.68886	346.4762	934	0	0	59.03624	cube.usd	2025-03-29 14:52:39.788871
1813	pentagonal prism_386	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:39.790888
1814	cylinder_313	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	45	cylinder.usd	2025-03-29 14:52:39.792848
1815	pentagonal prism_387	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:40.012488
1816	cube_333	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:40.016399
1817	pentagonal prism_388	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:40.018474
1818	cylinder_314	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:40.020391
1819	pentagonal prism_389	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:40.24801
1820	cube_334	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 14:52:40.251578
1821	hexagonal prism_204	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:40.25346
1822	cylinder_315	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:40.255257
1823	pentagonal prism_390	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:40.481711
1824	cube_335	pink	{0,0,0}	-205.90816	345.1413	909.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:40.484028
1825	pentagonal prism_391	red	{0,0,0}	32.357	258.856	922.00006	0	0	36.869892	pentagonal prism.usd	2025-03-29 14:52:40.486058
1826	cylinder_316	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:52:40.487948
1827	pentagonal prism_392	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:40.712803
1828	cube_336	pink	{0,0,0}	-205.90816	345.1413	906	0	0	59.03625	cube.usd	2025-03-29 14:52:40.715327
1829	hexagonal prism_205	red	{0,0,0}	30.395967	260.81702	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:40.71737
1830	cylinder_317	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:40.719208
1831	pentagonal prism_393	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:40.951455
1832	cube_337	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.34933	cube.usd	2025-03-29 14:52:40.955
1833	hexagonal prism_206	red	{0,0,0}	32.357	258.856	934	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:52:40.956945
1834	cylinder_318	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:40.958942
1835	pentagonal prism_394	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:41.183763
1836	cube_338	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:41.187497
1837	hexagonal prism_207	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:41.189926
1838	cylinder_319	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:41.191964
1839	pentagonal prism_395	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:41.417336
1840	cube_339	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:41.421054
1841	pentagonal prism_396	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:52:41.423262
1842	cylinder_320	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.43495	cylinder.usd	2025-03-29 14:52:41.425476
1843	pentagonal prism_397	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:41.652104
1844	cube_340	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:52:41.655494
1845	hexagonal prism_208	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:41.657358
1846	cylinder_321	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:52:41.65926
1847	pentagonal prism_398	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:41.878151
1848	cube_341	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:41.880923
1849	hexagonal prism_209	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:41.883302
1850	cylinder_322	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:41.885284
1851	pentagonal prism_399	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:42.107852
1852	cube_342	pink	{0,0,0}	-206.88867	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:42.111421
1853	pentagonal prism_400	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:42.113353
1854	cylinder_323	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:42.115213
1855	pentagonal prism_401	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:42.330051
1856	cube_343	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:52:42.332821
1857	pentagonal prism_402	red	{0,0,0}	32.357	258.856	913.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:42.334945
1858	cylinder_324	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.43495	cylinder.usd	2025-03-29 14:52:42.336853
1859	hexagonal prism_210	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 14:52:42.556188
1860	cube_344	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:52:42.558625
1861	pentagonal prism_403	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:42.560509
1862	cylinder_325	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:42.562293
1863	pentagonal prism_404	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:42.785223
1864	cube_345	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:42.788793
1865	hexagonal prism_211	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:52:42.790793
1866	cylinder_326	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:42.792696
1867	pentagonal prism_405	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:43.019441
1868	cube_346	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	cube.usd	2025-03-29 14:52:43.022866
1869	hexagonal prism_212	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:43.024645
1870	cylinder_327	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:43.026593
1871	pentagonal prism_406	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:43.252251
1872	cube_347	pink	{0,0,0}	-207.6968	346.48944	914.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:43.255727
1873	hexagonal prism_213	red	{0,0,0}	30.514694	260.8514	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:43.257737
1874	cylinder_328	green	{0,0,0}	-272.66354	217.54024	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:43.259571
1875	pentagonal prism_407	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:43.483519
1876	cube_348	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:43.487427
1877	hexagonal prism_214	orange	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:43.489556
1878	cylinder_329	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:43.491536
1879	pentagonal prism_408	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:43.71095
1880	cube_349	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:43.713186
1881	cube_350	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.303947	cube.usd	2025-03-29 14:52:43.715024
1882	cylinder_330	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:43.716909
1883	pentagonal prism_409	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:43.946745
1884	cube_351	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:43.948752
1885	hexagonal prism_215	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:43.950864
1886	cylinder_331	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:43.952962
1887	pentagonal prism_410	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:44.206664
1888	cube_352	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:52:44.208996
1889	hexagonal prism_216	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:44.210931
1890	cylinder_332	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:44.212687
1891	pentagonal prism_411	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:44.431912
1892	cube_353	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:44.435854
1893	hexagonal prism_217	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:44.437848
1894	cylinder_333	green	{0,0,0}	-270.6119	216.68562	942.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:44.43983
1895	pentagonal prism_412	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:44.660207
1896	cube_354	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	cube.usd	2025-03-29 14:52:44.663717
1897	hexagonal prism_218	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:44.665514
1898	cylinder_334	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:44.667408
1899	pentagonal prism_413	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:44.896187
1900	cube_355	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:44.899765
1901	pentagonal prism_414	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:44.901957
1902	cylinder_335	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 14:52:44.904029
1903	pentagonal prism_415	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:45.119656
1904	cube_356	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:45.122513
1905	hexagonal prism_219	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:45.124943
1906	cylinder_336	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:45.127653
1907	pentagonal prism_416	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:45.379062
1908	cube_357	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:45.381385
1909	hexagonal prism_220	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:45.38314
1910	cylinder_337	green	{0,0,0}	-270.6119	216.68562	946.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:45.385094
1911	pentagonal prism_417	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:45.604481
1912	cube_358	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:52:45.607288
1913	hexagonal prism_221	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:45.609024
1914	cylinder_338	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:45.610824
1915	pentagonal prism_418	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:45.841099
1916	cube_359	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:45.843401
1917	pentagonal prism_419	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:45.845599
1918	cylinder_339	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:45.847444
1919	pentagonal prism_420	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:46.075596
1920	cube_360	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:52:46.077796
1921	hexagonal prism_222	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:46.079677
1922	cylinder_340	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:46.08153
1923	pentagonal prism_421	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:46.30916
1924	cube_361	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03624	cube.usd	2025-03-29 14:52:46.314481
1925	hexagonal prism_223	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:46.316352
1926	cylinder_341	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:46.31817
1927	pentagonal prism_422	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:46.541514
1928	cube_362	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:52:46.543748
1929	hexagonal prism_224	red	{0,0,0}	30.394815	260.80713	928.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:52:46.545617
1930	cylinder_342	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:46.547511
1931	pentagonal prism_423	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:46.773115
1932	cube_363	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:46.77695
1933	hexagonal prism_225	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:46.779125
1934	cylinder_343	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:46.780933
1935	pentagonal prism_424	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:47.003416
1936	cube_364	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:47.006891
1937	hexagonal prism_226	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:47.008826
1938	cylinder_344	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:47.010695
1939	pentagonal prism_425	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:47.24459
1940	cube_365	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:52:47.248292
1941	pentagonal prism_426	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:47.250182
1942	cylinder_345	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:47.252078
1943	pentagonal prism_427	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:47.468765
1944	cube_366	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 14:52:47.471389
1945	hexagonal prism_227	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:47.473383
1946	cylinder_346	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:47.475118
1947	pentagonal prism_428	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:47.685935
1948	cube_367	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:47.688808
1949	pentagonal prism_429	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:47.690786
1950	cylinder_347	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:47.692607
1951	pentagonal prism_430	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:52:47.924907
1952	cube_368	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:47.927367
1953	pentagonal prism_431	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:47.92924
1954	cylinder_348	green	{0,0,0}	-270.62216	216.69383	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:47.931173
1955	pentagonal prism_432	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal prism.usd	2025-03-29 14:52:48.156576
1956	cube_369	pink	{0,0,0}	-205.90816	345.1413	942.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:48.160079
1957	hexagonal prism_228	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:48.162217
1958	cylinder_349	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:48.164244
1959	pentagonal prism_433	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:48.395836
1960	cube_370	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:48.398182
1961	hexagonal prism_229	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:48.400057
1962	cylinder_350	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:48.401812
1963	pentagonal prism_434	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:48.617996
1964	cube_371	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.620872	cube.usd	2025-03-29 14:52:48.621903
1965	hexagonal prism_230	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:48.624138
1966	cylinder_351	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:52:48.625934
1967	pentagonal prism_435	black	{0,0,0}	-128.94919	520.7185	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:48.862588
1968	cube_372	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:48.866327
1969	hexagonal prism_231	red	{0,0,0}	30.514694	260.8514	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:52:48.868469
1970	cylinder_352	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:48.870399
1971	pentagonal prism_436	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:49.087783
1972	cube_373	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:49.090289
1973	hexagonal prism_232	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:49.092311
1974	cylinder_353	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:49.094048
1975	pentagonal prism_437	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:52:49.319022
1976	cube_374	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.420776	cube.usd	2025-03-29 14:52:49.325553
1977	pentagonal prism_438	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:49.327536
1978	cylinder_354	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:49.329426
1979	pentagonal prism_439	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:52:49.562534
1980	cube_375	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:49.566312
1981	hexagonal prism_233	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:49.568337
1982	cylinder_355	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:49.570167
1983	pentagonal prism_440	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:49.791397
1984	cube_376	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03625	cube.usd	2025-03-29 14:52:49.794692
1985	hexagonal prism_234	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:49.796545
1986	cylinder_356	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:52:49.798345
1987	hexagonal prism_235	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 14:52:50.024659
1988	cube_377	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.420776	cube.usd	2025-03-29 14:52:50.028629
1989	pentagonal prism_441	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:50.03052
1990	cylinder_357	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:50.032554
1991	pentagonal prism_442	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:52:50.260003
1992	cube_378	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:50.263663
1993	hexagonal prism_236	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:50.265857
1994	cylinder_358	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:50.267756
1995	pentagonal prism_443	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:50.490884
1996	cube_379	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:50.493106
1997	hexagonal prism_237	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:50.495033
1998	cylinder_359	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:50.496956
1999	pentagonal prism_444	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:50.720373
2000	cube_380	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:50.722611
2001	hexagonal prism_238	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:50.724921
2002	cylinder_360	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:50.726853
2003	pentagonal prism_445	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 14:52:50.939213
2004	cube_381	pink	{0,0,0}	-207.68886	346.4762	911.00006	0	0	59.620872	cube.usd	2025-03-29 14:52:50.942096
2005	hexagonal prism_239	red	{0,0,0}	31.497837	259.85715	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:50.943977
2006	cylinder_361	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:50.945933
2007	pentagonal prism_446	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:51.172576
2008	cube_382	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 14:52:51.176417
2009	hexagonal prism_240	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:51.178618
2010	cylinder_362	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:51.180641
2011	pentagonal prism_447	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:51.403949
2012	cube_383	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:51.406174
2013	hexagonal prism_241	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:51.408425
2014	cylinder_363	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:51.410338
2015	pentagonal prism_448	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:51.656968
2016	cube_384	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:51.659632
2017	pentagonal prism_449	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:52:51.661662
2018	cylinder_364	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:51.66352
2019	pentagonal prism_450	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:51.89554
2020	cube_385	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:51.897623
2021	pentagonal prism_451	red	{0,0,0}	31.499039	259.86707	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:51.899473
2022	cylinder_365	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:51.901313
2023	pentagonal prism_452	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:52.125862
2024	cube_386	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.620872	cube.usd	2025-03-29 14:52:52.128082
2025	hexagonal prism_242	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:52.129969
2026	cylinder_366	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:52.131734
2027	pentagonal prism_453	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:52.359426
2028	cube_387	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 14:52:52.361629
2029	hexagonal prism_243	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:52.36344
2030	cylinder_367	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:52:52.365354
2031	pentagonal prism_454	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:52.592558
2032	cube_388	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:52.595895
2033	pentagonal prism_455	red	{0,0,0}	30.395967	260.81702	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:52.597865
2034	cylinder_368	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:52.599794
2035	pentagonal prism_456	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:52.822628
2036	cube_389	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.420776	cube.usd	2025-03-29 14:52:52.826603
2037	hexagonal prism_244	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:52.828474
2038	cylinder_369	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:52.830344
2039	pentagonal prism_457	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:53.060704
2040	cube_390	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:53.064188
2041	cube_391	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	cube.usd	2025-03-29 14:52:53.066056
2042	cylinder_370	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:53.067981
2043	pentagonal prism_458	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:53.289264
2044	cube_392	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:53.292202
2045	hexagonal prism_245	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:53.294759
2046	cylinder_371	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:53.297265
2047	pentagonal prism_459	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:53.537452
2048	cube_393	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:53.5417
2049	hexagonal prism_246	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:53.543681
2050	cylinder_372	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:53.545603
2051	pentagonal prism_460	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:53.781798
2052	cube_394	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	cube.usd	2025-03-29 14:52:53.785733
2053	hexagonal prism_247	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:53.787587
2054	cylinder_373	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:53.789525
2055	pentagonal prism_461	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:54.004085
2056	cube_395	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:54.007946
2057	pentagonal prism_462	red	{0,0,0}	32.357	258.856	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:52:54.010427
2058	cylinder_374	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:54.012546
2059	pentagonal prism_463	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:54.24107
2060	cube_396	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:54.244929
2061	pentagonal prism_464	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:54.246859
2062	cylinder_375	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:54.24865
2063	pentagonal prism_465	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:54.480543
2064	cube_397	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.743565	cube.usd	2025-03-29 14:52:54.483969
2065	hexagonal prism_248	red	{0,0,0}	30.395967	260.81702	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:54.486097
2066	cylinder_376	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	33.690067	cylinder.usd	2025-03-29 14:52:54.487915
2067	pentagonal prism_466	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:54.704618
2068	cube_398	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:54.707024
2069	pentagonal prism_467	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:54.709367
2070	cylinder_377	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:54.711636
2071	pentagonal prism_468	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:54.925825
2072	cube_399	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:54.928953
2073	hexagonal prism_249	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:54.930936
2074	cylinder_378	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:52:54.932797
2075	pentagonal prism_469	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:55.16166
2076	cube_400	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:55.165147
2077	hexagonal prism_250	red	{0,0,0}	30.51353	260.84146	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:55.166997
2078	cylinder_379	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:55.168839
2079	pentagonal prism_470	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:55.395824
2080	cube_401	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:55.39936
2081	hexagonal prism_251	red	{0,0,0}	30.51353	260.84146	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:55.401219
2082	cylinder_380	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:55.403201
2083	pentagonal prism_471	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:55.62527
2084	cube_402	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:52:55.629086
2085	hexagonal prism_252	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:55.631082
2086	cylinder_381	green	{0,0,0}	-270.6119	216.68562	938	0	0	26.56505	cylinder.usd	2025-03-29 14:52:55.633282
2087	pentagonal prism_472	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:55.866311
2088	cube_403	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03624	cube.usd	2025-03-29 14:52:55.869676
2089	hexagonal prism_253	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:52:55.871483
2090	cylinder_382	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:55.873586
2091	pentagonal prism_473	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:56.096988
2092	cube_404	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:56.099271
2093	hexagonal prism_254	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:56.101196
2094	cylinder_383	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:56.103114
2095	pentagonal prism_474	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:56.333499
2096	cube_405	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:56.33704
2097	hexagonal prism_255	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:56.338996
2098	cylinder_384	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:56.34081
2099	pentagonal prism_475	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:56.568919
2100	cube_406	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:56.57111
2101	hexagonal prism_256	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:56.572934
2102	cylinder_385	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:56.575004
2103	pentagonal prism_476	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:56.790259
2104	cube_407	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:56.793992
2105	pentagonal prism_477	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:52:56.796083
2106	cylinder_386	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:52:56.797939
2107	pentagonal prism_478	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:52:57.026517
2108	cube_408	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:57.030703
2109	hexagonal prism_257	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:57.032718
2110	cylinder_387	green	{0,0,0}	-272.65317	217.53194	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:57.034596
2111	pentagonal prism_479	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:57.250427
2112	cube_409	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:52:57.253884
2113	cube_410	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 14:52:57.255775
2114	cylinder_388	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:57.257585
2115	pentagonal prism_480	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:57.472529
2116	cube_411	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:52:57.474842
2117	hexagonal prism_258	red	{0,0,0}	30.394815	260.80713	937.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:57.47674
2118	cylinder_389	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 14:52:57.478926
2119	pentagonal prism_481	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:57.697473
2120	cube_412	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:57.701559
2121	hexagonal prism_259	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:57.703484
2122	cylinder_390	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:57.705463
2123	pentagonal prism_482	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:57.934289
2124	cube_413	pink	{0,0,0}	-206.88867	345.1413	913.00006	0	0	59.534454	cube.usd	2025-03-29 14:52:57.936761
2125	pentagonal prism_483	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:57.938654
2126	cylinder_391	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:52:57.940502
2127	pentagonal prism_484	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:52:58.161358
2128	cube_414	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:52:58.165212
2129	pentagonal prism_485	red	{0,0,0}	32.357	258.856	934	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:52:58.167125
2130	cylinder_392	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:58.168941
2131	pentagonal prism_486	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:52:58.395037
2132	cube_415	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:58.39879
2133	hexagonal prism_260	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:58.400781
2134	cylinder_393	green	{0,0,0}	-270.6119	216.68562	944.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:58.402684
2135	pentagonal prism_487	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:58.625145
2136	cube_416	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:52:58.629067
2137	hexagonal prism_261	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:58.631446
2138	cylinder_394	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:52:58.633495
2139	pentagonal prism_488	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:58.860476
2140	cube_417	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:58.86429
2141	hexagonal prism_262	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:58.866284
2142	cylinder_395	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:52:58.868114
2143	pentagonal prism_489	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:59.09118
2144	cube_418	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.34933	cube.usd	2025-03-29 14:52:59.094774
2145	hexagonal prism_263	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:59.096688
2146	cylinder_396	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:59.098727
2147	pentagonal prism_490	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:59.32617
2148	cube_419	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 14:52:59.328821
2149	hexagonal prism_264	red	{0,0,0}	31.375294	259.82666	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:59.331496
2150	cylinder_397	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:52:59.333615
2151	pentagonal prism_491	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:52:59.561126
2152	cube_420	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 14:52:59.565007
2153	cube_421	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 14:52:59.567022
2154	cylinder_398	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 14:52:59.568933
2155	pentagonal prism_492	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:52:59.791187
2156	cube_422	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:52:59.794674
2157	hexagonal prism_265	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:52:59.796613
2158	cylinder_399	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:52:59.798658
2159	pentagonal prism_493	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:00.016738
2160	cube_423	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 14:53:00.019108
2161	hexagonal prism_266	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:00.021021
2162	cylinder_400	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:00.023089
2163	pentagonal prism_494	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:00.249898
2164	cube_424	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:00.253456
2165	pentagonal prism_495	red	{0,0,0}	32.355774	258.8462	940.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:53:00.255391
2166	cylinder_401	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 14:53:00.257264
2167	pentagonal prism_496	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:00.476289
2168	cube_425	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 14:53:00.479936
2169	pentagonal prism_497	red	{0,0,0}	30.394815	260.80713	934	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:00.482086
2170	cylinder_402	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:53:00.484192
2171	pentagonal prism_498	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:00.708463
2172	cube_426	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:00.710705
2173	hexagonal prism_267	red	{0,0,0}	30.394815	260.80713	933	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:00.712881
2174	cylinder_403	green	{0,0,0}	-270.6119	216.68562	941.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:00.714964
2175	pentagonal prism_499	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:00.930299
2176	cube_427	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:00.932763
2177	hexagonal prism_268	red	{0,0,0}	31.375294	259.82666	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:00.934713
2178	cylinder_404	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:00.936419
2179	pentagonal prism_500	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:53:01.174913
2180	cube_428	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:01.17873
2181	cube_429	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	cube.usd	2025-03-29 14:53:01.18067
2182	cylinder_405	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 14:53:01.182766
2183	pentagonal prism_501	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:01.408549
2184	cube_430	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:53:01.410785
2185	hexagonal prism_269	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:01.412784
2186	cylinder_406	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:01.414722
2187	pentagonal prism_502	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:01.63296
2188	cube_431	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:01.635181
2189	hexagonal prism_270	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:01.637038
2190	cylinder_407	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:01.638848
2191	pentagonal prism_503	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:01.866177
2192	cube_432	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:01.869822
2193	hexagonal prism_271	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:01.8718
2194	cylinder_408	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:01.873778
2195	pentagonal prism_504	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:53:02.097417
2196	cube_433	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:02.101186
2197	pentagonal prism_505	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:02.103108
2198	cylinder_409	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:02.104924
2199	pentagonal prism_506	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:02.328743
2200	cube_434	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:53:02.332084
2201	hexagonal prism_272	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:02.334284
2202	cylinder_410	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:02.336194
2203	pentagonal prism_507	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:02.565511
2204	cube_435	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:02.569742
2205	hexagonal prism_273	red	{0,0,0}	31.375294	259.82666	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:02.571831
2206	cylinder_411	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:53:02.573625
2207	pentagonal prism_508	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:02.801385
2208	cube_436	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:53:02.803626
2209	hexagonal prism_274	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:02.805434
2210	cylinder_412	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 14:53:02.807293
2211	pentagonal prism_509	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:03.034335
2212	cube_437	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:53:03.037794
2213	hexagonal prism_275	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:03.039802
2214	cylinder_413	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:03.041673
2215	pentagonal prism_510	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:03.267404
2216	cube_438	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 14:53:03.271272
2217	hexagonal prism_276	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:03.27318
2218	cylinder_414	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:03.27506
2219	pentagonal prism_511	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:03.497433
2220	cube_439	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:03.501206
2221	hexagonal prism_277	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:03.503171
2222	cylinder_415	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:03.505043
2223	pentagonal prism_512	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:03.728074
2224	cube_440	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:03.731817
2225	pentagonal prism_513	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:03.733985
2226	cylinder_416	green	{0,0,0}	-270.6119	216.68562	934	0	0	18.434948	cylinder.usd	2025-03-29 14:53:03.736087
2227	pentagonal prism_514	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:53:03.954599
2228	cube_441	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:03.95731
2229	hexagonal prism_278	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:03.959374
2230	cylinder_417	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:03.961257
2231	pentagonal prism_515	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:04.178181
2232	cube_442	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:04.180215
2233	hexagonal prism_279	red	{0,0,0}	30.51353	260.84146	937.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:04.182335
2234	cylinder_418	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:04.184266
2235	pentagonal prism_516	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:04.397815
2236	cube_443	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:04.400716
2237	hexagonal prism_280	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:04.402916
2238	cylinder_419	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:04.404832
2239	pentagonal prism_517	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:04.631553
2240	cube_444	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:04.635404
2241	cube_445	red	{0,0,0}	32.357	258.856	919	0	0	37.69424	cube.usd	2025-03-29 14:53:04.637395
2242	cylinder_420	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:04.639256
2243	pentagonal prism_518	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:04.866587
2244	cube_446	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:04.870648
2245	pentagonal prism_519	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:04.872674
2246	cylinder_421	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:04.874579
2247	pentagonal prism_520	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:05.099973
2248	cube_447	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:05.10398
2249	hexagonal prism_281	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:05.106085
2250	cylinder_422	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:05.107991
2251	pentagonal prism_521	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:05.339191
2252	cube_448	pink	{0,0,0}	-205.90038	345.12823	938	0	0	59.534454	cube.usd	2025-03-29 14:53:05.34285
2253	hexagonal prism_282	red	{0,0,0}	31.375294	259.82666	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:05.344721
2254	cylinder_423	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:05.346456
2255	pentagonal prism_522	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:05.570688
2256	cube_449	pink	{0,0,0}	-205.90816	345.1413	938	0	0	59.03625	cube.usd	2025-03-29 14:53:05.572993
2257	pentagonal prism_523	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:53:05.575265
2258	cylinder_424	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:05.57729
2259	pentagonal prism_524	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:05.803798
2260	cube_450	pink	{0,0,0}	-205.90816	345.1413	909.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:05.807517
2261	hexagonal prism_283	red	{0,0,0}	31.376482	259.8365	938	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:05.809455
2262	cylinder_425	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:05.811446
2263	pentagonal prism_525	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:06.034369
2264	cube_451	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:06.038564
2265	hexagonal prism_284	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:06.040568
2266	cylinder_426	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:06.042315
2267	pentagonal prism_526	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:06.272498
2268	cube_452	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	cube.usd	2025-03-29 14:53:06.274948
2269	pentagonal prism_527	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:06.276873
2270	cylinder_427	green	{0,0,0}	-270.62216	216.69383	924	0	0	33.690063	cylinder.usd	2025-03-29 14:53:06.278867
2271	pentagonal prism_528	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:06.500439
2272	cube_453	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.34933	cube.usd	2025-03-29 14:53:06.504305
2273	hexagonal prism_285	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:06.506248
2274	cylinder_428	green	{0,0,0}	-270.62216	216.69383	943	0	0	26.56505	cylinder.usd	2025-03-29 14:53:06.50811
2275	pentagonal prism_529	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:06.749095
2276	cube_454	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:53:06.751395
2277	hexagonal prism_286	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:06.753964
2278	cylinder_429	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:06.75603
2279	pentagonal prism_530	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:53:06.988037
2280	cube_455	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	cube.usd	2025-03-29 14:53:06.990496
2281	hexagonal prism_287	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:06.992443
2282	cylinder_430	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:06.994345
2283	pentagonal prism_531	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:07.221339
2284	cube_456	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.420776	cube.usd	2025-03-29 14:53:07.225028
2285	hexagonal prism_288	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:07.226873
2286	cylinder_431	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:07.228713
2287	pentagonal prism_532	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:07.456134
2288	cube_457	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:07.45959
2289	pentagonal prism_533	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:07.461573
2290	cylinder_432	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:07.463423
2291	pentagonal prism_534	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:07.68381
2292	cube_458	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:07.688164
2293	hexagonal prism_289	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:07.690281
2294	cylinder_433	green	{0,0,0}	-270.6119	216.68562	938	0	0	33.690063	cylinder.usd	2025-03-29 14:53:07.692145
2295	pentagonal prism_535	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:07.921505
2296	cube_459	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:07.924748
2297	hexagonal prism_290	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:07.926578
2298	cylinder_434	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:07.928702
2299	pentagonal prism_536	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:08.156227
2300	cube_460	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 14:53:08.159746
2301	pentagonal prism_537	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:08.161627
2302	cylinder_435	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:08.163498
2303	pentagonal prism_538	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:08.386236
2304	cube_461	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.93142	cube.usd	2025-03-29 14:53:08.389274
2305	hexagonal prism_291	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:08.391147
2306	cylinder_436	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:08.393014
2307	pentagonal prism_539	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:08.625841
2308	cube_462	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:08.629792
2309	hexagonal prism_292	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:08.631733
2310	cylinder_437	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:08.633578
2311	pentagonal prism_540	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:08.856915
2312	cube_463	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:08.860586
2313	hexagonal prism_293	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:08.86286
2314	cylinder_438	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	45	cylinder.usd	2025-03-29 14:53:08.864811
2315	pentagonal prism_541	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:09.093325
2316	cube_464	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:09.095622
2317	hexagonal prism_294	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:09.097524
2318	cylinder_439	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:09.099332
2319	pentagonal prism_542	black	{0,0,0}	-127.46696	518.69244	661	0	0	0	pentagonal prism.usd	2025-03-29 14:53:09.323841
2320	cube_465	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:09.327736
2321	hexagonal prism_295	red	{0,0,0}	31.376482	259.8365	940.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:09.329693
2322	cylinder_440	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:09.331549
2323	pentagonal prism_543	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:09.571107
2324	cube_466	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:09.574903
2325	hexagonal prism_296	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:09.576781
2326	cylinder_441	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:09.578606
2327	pentagonal prism_544	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:09.806696
2328	cube_467	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:53:09.810468
2329	hexagonal prism_297	red	{0,0,0}	31.376482	259.8365	919	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:09.812904
2330	cylinder_442	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:09.814953
2331	pentagonal prism_545	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:10.038975
2332	cube_468	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:10.042817
2333	cube_469	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	36.869892	cube.usd	2025-03-29 14:53:10.044777
2334	cylinder_443	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:10.046654
2335	pentagonal prism_546	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:53:10.275945
2336	cube_470	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:10.280501
2337	pentagonal prism_547	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:53:10.282477
2338	cylinder_444	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:10.28432
2339	pentagonal prism_548	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:10.508228
2340	cube_471	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:10.511798
2341	hexagonal prism_298	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:10.513987
2342	cylinder_445	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:53:10.515877
2343	pentagonal prism_549	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:10.743421
2344	cube_472	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:53:10.745706
2345	pentagonal prism_550	red	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:10.74788
2346	cylinder_446	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:10.749886
2347	pentagonal prism_551	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:10.975664
2348	cube_473	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:10.978057
2349	hexagonal prism_299	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:10.980222
2350	cylinder_447	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:10.982188
2351	pentagonal prism_552	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:53:11.204378
2352	cube_474	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 14:53:11.207018
2353	hexagonal prism_300	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:11.209061
2354	cylinder_448	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:11.210869
2355	pentagonal prism_553	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:11.443032
2356	cube_475	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:11.446818
2357	hexagonal prism_301	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:11.448886
2358	cylinder_449	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:11.450653
2359	pentagonal prism_554	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:11.676542
2360	cube_476	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:11.678841
2361	cube_477	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	cube.usd	2025-03-29 14:53:11.680955
2362	cylinder_450	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:11.682897
2363	pentagonal prism_555	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:11.909762
2364	cube_478	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 14:53:11.913381
2365	pentagonal prism_556	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:11.915476
2366	cylinder_451	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:11.917395
2367	pentagonal prism_557	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:12.148026
2368	cube_479	pink	{0,0,0}	-206.88867	345.1413	931.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:12.153156
2369	hexagonal prism_302	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:12.155059
2370	cylinder_452	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:12.156805
2371	pentagonal prism_558	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:12.37564
2372	cube_480	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:12.377744
2373	pentagonal prism_559	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:12.379527
2374	cylinder_453	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:12.381479
2375	pentagonal prism_560	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:12.610098
2376	cube_481	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:53:12.614194
2377	pentagonal prism_561	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:12.616057
2378	cylinder_454	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:12.617965
2379	pentagonal prism_562	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:12.845572
2380	cube_482	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:53:12.849466
2381	hexagonal prism_303	red	{0,0,0}	31.376482	259.8365	920	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:12.851515
2382	cylinder_455	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:12.853499
2383	pentagonal prism_563	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:53:13.082567
2384	cube_483	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:13.086127
2385	hexagonal prism_304	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:13.088046
2386	cylinder_456	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:13.090376
2387	pentagonal prism_564	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:13.306005
2388	cube_484	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:13.309951
2389	hexagonal prism_305	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:13.312028
2390	cylinder_457	green	{0,0,0}	-270.62216	216.69383	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:13.313857
2391	pentagonal prism_565	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:13.54105
2392	cube_485	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:13.544729
2393	hexagonal prism_306	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:13.546644
2394	cylinder_458	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:13.548449
2395	pentagonal prism_566	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:13.777585
2396	cube_486	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:53:13.780047
2397	hexagonal prism_307	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:13.781917
2398	cylinder_459	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:53:13.783894
2399	pentagonal prism_567	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:14.009406
2400	cube_487	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:53:14.012965
2401	hexagonal prism_308	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:14.014782
2402	cylinder_460	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:14.016699
2403	pentagonal prism_568	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:14.236197
2404	cube_488	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.743565	cube.usd	2025-03-29 14:53:14.239747
2405	hexagonal prism_309	red	{0,0,0}	31.375294	259.82666	940.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:14.241587
2406	cylinder_461	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:14.243837
2407	pentagonal prism_569	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:14.456449
2408	cube_489	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 14:53:14.45925
2409	pentagonal prism_570	red	{0,0,0}	29.529222	261.82578	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:14.461562
2410	cylinder_462	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:14.463491
2411	pentagonal prism_571	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:14.69499
2412	cube_490	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:53:14.698766
2413	hexagonal prism_310	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:14.70079
2414	cylinder_463	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:14.702634
2415	pentagonal prism_572	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:14.92898
2416	cube_491	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:14.932238
2417	pentagonal prism_573	red	{0,0,0}	32.357	258.856	919	0	0	37.234837	pentagonal prism.usd	2025-03-29 14:53:14.934152
2418	cylinder_464	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:14.935984
2419	pentagonal prism_574	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:15.158816
2420	cube_492	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:15.162472
2421	hexagonal prism_311	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:15.16445
2422	cylinder_465	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:15.166268
2423	pentagonal prism_575	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:15.402948
2424	cube_493	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.620872	cube.usd	2025-03-29 14:53:15.405376
2425	hexagonal prism_312	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:15.407544
2426	cylinder_466	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:15.409763
2427	pentagonal prism_576	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:15.624627
2428	cube_494	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:15.627604
2429	hexagonal prism_313	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:15.629676
2430	cylinder_467	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:15.631512
2431	pentagonal prism_577	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:15.857426
2432	cube_495	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:15.861312
2433	hexagonal prism_314	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:15.863428
2434	cylinder_468	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:15.86523
2435	pentagonal prism_578	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:16.099018
2436	cube_496	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.743565	cube.usd	2025-03-29 14:53:16.102566
2437	hexagonal prism_315	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:16.104471
2438	cylinder_469	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:16.106299
2439	pentagonal prism_579	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:16.323301
2440	cube_497	pink	{0,0,0}	-207.6968	346.48944	914.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:16.327
2441	hexagonal prism_316	red	{0,0,0}	30.514694	260.8514	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:16.329325
2442	cylinder_470	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:16.331331
2443	pentagonal prism_580	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:16.560268
2444	cube_498	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.420776	cube.usd	2025-03-29 14:53:16.56282
2445	hexagonal prism_317	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:16.564836
2446	cylinder_471	green	{0,0,0}	-270.6119	216.68562	934	0	0	33.690063	cylinder.usd	2025-03-29 14:53:16.566664
2447	pentagonal prism_581	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:53:16.794272
2448	cube_499	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:53:16.797687
2449	hexagonal prism_318	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:16.799589
2450	cylinder_472	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:16.801468
2451	pentagonal prism_582	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:17.029061
2452	cube_500	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:53:17.032617
2453	hexagonal prism_319	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:17.034543
2454	cylinder_473	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	cylinder.usd	2025-03-29 14:53:17.036482
2455	pentagonal prism_583	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:17.263528
2456	cube_501	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:53:17.2671
2457	hexagonal prism_320	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:17.269109
2458	cylinder_474	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:17.27101
2459	pentagonal prism_584	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:17.501468
2460	cube_502	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:17.503917
2461	hexagonal prism_321	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:17.505777
2462	cylinder_475	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:17.50753
2463	pentagonal prism_585	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:17.72778
2464	cube_503	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:53:17.73059
2465	hexagonal prism_322	red	{0,0,0}	31.375294	259.82666	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:17.732599
2466	cylinder_476	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:17.734638
2467	pentagonal prism_586	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:17.961963
2468	cube_504	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:17.965924
2469	hexagonal prism_323	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:17.967872
2470	cylinder_477	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:17.969983
2471	pentagonal prism_587	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:18.195854
2472	cube_505	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:53:18.199323
2473	hexagonal prism_324	red	{0,0,0}	31.375294	259.82666	938	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:18.201207
2474	cylinder_478	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:18.203128
2475	pentagonal prism_588	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:18.440463
2476	cube_506	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:18.442874
2477	hexagonal prism_325	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:18.445202
2478	cylinder_479	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:18.447496
2479	pentagonal prism_589	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:18.663157
2480	cube_507	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:18.666296
2481	pentagonal prism_590	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:18.66824
2482	cylinder_480	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:18.670205
2483	pentagonal prism_591	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:18.897607
2484	cube_508	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:18.901402
2485	hexagonal prism_326	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:18.903646
2486	cylinder_481	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:18.905644
2487	pentagonal prism_592	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:19.122084
2488	cube_509	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:19.1243
2489	cylinder_482	red	{0,0,0}	30.395967	260.81702	935.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:53:19.126295
2490	cylinder_483	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:19.128105
2491	pentagonal prism_593	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:53:19.355422
2492	cube_510	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:53:19.359067
2493	pentagonal prism_594	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:19.361067
2494	cylinder_484	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:19.362996
2495	pentagonal prism_595	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:19.582248
2496	cube_511	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:19.585785
2497	hexagonal prism_327	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:19.587962
2498	cylinder_485	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 14:53:19.589838
2499	pentagonal prism_596	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:19.805782
2500	cube_512	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:19.809344
2501	pentagonal prism_597	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:19.811366
2502	cylinder_486	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:19.813299
2503	pentagonal prism_598	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:53:20.040542
2504	cube_513	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:20.044362
2505	hexagonal prism_328	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:20.046343
2506	cylinder_487	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:20.048906
2507	pentagonal prism_599	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:20.272207
2508	cube_514	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:20.275721
2509	hexagonal prism_329	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:20.277569
2510	cylinder_488	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:20.279398
2511	pentagonal prism_600	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:20.496563
2512	cube_515	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:20.499275
2513	pentagonal prism_601	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:20.501586
2514	cylinder_489	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:20.503909
2515	pentagonal prism_602	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:20.728876
2516	cube_516	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:20.732724
2517	hexagonal prism_330	red	{0,0,0}	31.375294	259.82666	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:20.734823
2518	cylinder_490	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 14:53:20.736945
2519	pentagonal prism_603	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:20.95994
2520	cube_517	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 14:53:20.962077
2521	cylinder_491	red	{0,0,0}	30.394815	260.80713	929	0	0	37.568592	cylinder.usd	2025-03-29 14:53:20.964134
2522	cylinder_492	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:20.966441
2523	pentagonal prism_604	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:21.183414
2524	cube_518	pink	{0,0,0}	-207.68886	346.4762	934	0	0	59.534454	cube.usd	2025-03-29 14:53:21.185523
2525	hexagonal prism_331	red	{0,0,0}	30.51353	260.84146	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:21.187413
2526	cylinder_493	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:21.189401
2527	pentagonal prism_605	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:21.411553
2528	cube_519	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:53:21.413981
2529	pentagonal prism_606	red	{0,0,0}	32.355774	258.8462	919	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:53:21.416328
2530	cylinder_494	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:21.418417
2531	pentagonal prism_607	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:21.641663
2532	cube_520	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:53:21.643726
2533	pentagonal prism_608	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:53:21.645667
2534	cylinder_495	green	{0,0,0}	-270.62216	216.69383	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:21.64764
2535	pentagonal prism_609	black	{0,0,0}	-128.94919	520.7185	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:21.865016
2536	cube_521	pink	{0,0,0}	-207.6968	346.48944	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:21.86739
2537	pentagonal prism_610	red	{0,0,0}	31.499039	259.86707	920	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:53:21.869374
2538	cylinder_496	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:21.871269
2539	pentagonal prism_611	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:22.108999
2540	cube_522	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 14:53:22.111272
2541	hexagonal prism_332	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:53:22.113304
2542	cylinder_497	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:22.115093
2543	pentagonal prism_612	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:22.328247
2544	cube_523	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 14:53:22.330979
2545	hexagonal prism_333	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:22.333307
2546	cylinder_498	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:22.335345
2547	pentagonal prism_613	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:22.559911
2548	cube_524	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:22.563423
2549	hexagonal prism_334	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:22.565513
2550	cylinder_499	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:22.568163
2551	pentagonal prism_614	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:22.787769
2552	cube_525	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:53:22.790401
2553	hexagonal prism_335	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:22.792343
2554	cylinder_500	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:22.794151
2555	pentagonal prism_615	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:23.017545
2556	cube_526	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:23.019911
2557	hexagonal prism_336	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:23.022035
2558	cylinder_501	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:23.024124
2559	pentagonal prism_616	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:23.261872
2560	cube_527	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:23.264511
2561	cylinder_502	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.746803	cylinder.usd	2025-03-29 14:53:23.266515
2562	cylinder_503	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:23.268591
2563	pentagonal prism_617	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:23.494498
2564	cube_528	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:23.498009
2565	cube_529	red	{0,0,0}	31.376482	258.856	924	0	0	37.568592	cube.usd	2025-03-29 14:53:23.500162
2566	cylinder_504	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:23.502568
2567	pentagonal prism_618	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:23.718523
2568	cube_530	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:23.721233
2569	hexagonal prism_337	red	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:23.723121
2570	cylinder_505	green	{0,0,0}	-270.62216	216.69383	920	0	0	33.690063	cylinder.usd	2025-03-29 14:53:23.724973
2571	pentagonal prism_619	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:23.948368
2572	cube_531	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:23.952087
2573	pentagonal prism_620	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:23.954116
2574	cylinder_506	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:23.956162
2575	pentagonal prism_621	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:24.178514
2576	cube_532	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:24.181982
2577	hexagonal prism_338	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:24.183912
2578	cylinder_507	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:24.186216
2579	pentagonal prism_622	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:24.406244
2580	cube_533	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 14:53:24.408723
2581	hexagonal prism_339	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:24.410616
2582	cylinder_508	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:24.412474
2583	pentagonal prism_623	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:24.630699
2584	cube_534	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:24.633315
2585	hexagonal prism_340	red	{0,0,0}	31.375294	259.82666	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:24.635708
2586	cylinder_509	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:24.637674
2587	pentagonal prism_624	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:24.858652
2588	cube_535	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:24.862926
2589	hexagonal prism_341	red	{0,0,0}	30.51353	260.84146	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:24.864802
2590	cylinder_510	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 14:53:24.866668
2591	pentagonal prism_625	black	{0,0,0}	-128.94919	520.7185	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:25.084535
2592	cube_536	pink	{0,0,0}	-207.6968	346.48944	930.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:25.088369
2593	hexagonal prism_342	red	{0,0,0}	30.514694	260.8514	922.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:25.090437
2594	cylinder_511	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:25.092381
2595	pentagonal prism_626	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:25.318512
2596	cube_537	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:25.322122
2597	pentagonal prism_627	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:25.324226
2598	cylinder_512	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:25.32612
2599	pentagonal prism_628	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:25.549221
2600	cube_538	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.743565	cube.usd	2025-03-29 14:53:25.553193
2601	cylinder_513	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	cylinder.usd	2025-03-29 14:53:25.555441
2602	cylinder_514	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:25.55742
2603	pentagonal prism_629	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:25.783875
2604	cube_539	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:25.787631
2605	pentagonal prism_630	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:25.789684
2606	cylinder_515	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:53:25.791781
2607	pentagonal prism_631	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:26.012015
2608	cube_540	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:26.014237
2609	hexagonal prism_343	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:26.015985
2610	cylinder_516	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:26.018126
2611	pentagonal prism_632	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:26.233893
2612	cube_541	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03624	cube.usd	2025-03-29 14:53:26.236391
2613	cylinder_517	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:53:26.238437
2614	cylinder_518	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:26.240331
2615	pentagonal prism_633	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:26.471578
2616	cube_542	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:26.473819
2617	hexagonal prism_344	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:26.476065
2618	cylinder_519	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:26.478035
2619	pentagonal prism_634	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:26.702867
2620	cube_543	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:53:26.705182
2621	hexagonal prism_345	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:53:26.707176
2622	cylinder_520	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:26.709277
2623	pentagonal prism_635	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:26.943222
2624	cube_544	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.743565	cube.usd	2025-03-29 14:53:26.947211
2625	hexagonal prism_346	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:26.949138
2626	cylinder_521	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:53:26.951007
2627	pentagonal prism_636	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:27.17666
2628	cube_545	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:27.180525
2629	hexagonal prism_347	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:53:27.182509
2630	cylinder_522	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:27.184344
2631	pentagonal prism_637	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:27.401291
2632	cube_546	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:53:27.403721
2633	hexagonal prism_348	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:27.405831
2634	cylinder_523	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:27.407881
2635	pentagonal prism_638	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:27.626915
2636	cube_547	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:27.629195
2637	hexagonal prism_349	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:27.631126
2638	cylinder_524	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:53:27.633059
2639	pentagonal prism_639	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:53:27.856996
2640	cube_548	pink	{0,0,0}	-205.90816	345.1413	910	0	0	59.62088	cube.usd	2025-03-29 14:53:27.859214
2641	hexagonal prism_350	red	{0,0,0}	30.395967	260.81702	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:27.861358
2642	cylinder_525	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:27.863374
2643	pentagonal prism_640	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:53:28.094711
2644	cube_549	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.620872	cube.usd	2025-03-29 14:53:28.098285
2645	hexagonal prism_351	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:28.100108
2646	cylinder_526	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:28.101911
2647	pentagonal prism_641	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:28.322022
2648	cube_550	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:28.325589
2649	cube_551	red	{0,0,0}	31.375294	258.8462	928.00006	0	0	37.405357	cube.usd	2025-03-29 14:53:28.327719
2650	cylinder_527	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 14:53:28.329666
2651	pentagonal prism_642	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:28.555905
2652	cube_552	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:53:28.559443
2653	hexagonal prism_352	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:28.561412
2654	cylinder_528	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:28.563176
2655	pentagonal prism_643	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:28.790001
2656	cube_553	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:28.792414
2657	hexagonal prism_353	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:28.794384
2658	cylinder_529	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:28.796259
2659	pentagonal prism_644	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:53:29.010589
2660	cube_554	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03624	cube.usd	2025-03-29 14:53:29.014564
2661	hexagonal prism_354	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:29.016537
2662	cylinder_530	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:29.018447
2663	pentagonal prism_645	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:29.242772
2664	cube_555	pink	{0,0,0}	-206.88084	345.12823	913.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:29.246498
2665	hexagonal prism_355	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:29.248441
2666	cylinder_531	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:29.250236
2667	pentagonal prism_646	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:29.472477
2668	cube_556	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:29.476144
2669	hexagonal prism_356	red	{0,0,0}	31.375294	259.82666	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:29.478364
2670	cylinder_532	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:29.480255
2671	pentagonal prism_647	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:29.693998
2672	cube_557	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.620872	cube.usd	2025-03-29 14:53:29.697759
2673	hexagonal prism_357	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:29.699644
2674	cylinder_533	green	{0,0,0}	-272.66354	217.54024	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:29.70147
2675	pentagonal prism_648	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:29.928582
2676	cube_558	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:29.932269
2677	hexagonal prism_358	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:29.934342
2678	cylinder_534	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	cylinder.usd	2025-03-29 14:53:29.936265
2679	pentagonal prism_649	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:30.157037
2680	cube_559	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:53:30.161153
2681	hexagonal prism_359	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:30.163217
2682	cylinder_535	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:30.165094
2683	pentagonal prism_650	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:30.395702
2684	cube_560	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:30.399334
2685	hexagonal prism_360	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:30.401226
2686	cylinder_536	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:30.403169
2687	pentagonal prism_651	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:30.622174
2688	cube_561	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:53:30.625951
2689	hexagonal prism_361	red	{0,0,0}	31.375294	259.82666	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:30.627959
2690	cylinder_537	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 14:53:30.630044
2691	pentagonal prism_652	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:30.857321
2692	cube_562	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:30.861114
2693	cube_563	red	{0,0,0}	32.355774	258.8462	934	0	0	37.405357	cube.usd	2025-03-29 14:53:30.863026
2694	cylinder_538	green	{0,0,0}	-270.6119	216.68562	934	0	0	18.434948	cylinder.usd	2025-03-29 14:53:30.864964
2695	pentagonal prism_653	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:31.119037
2696	cube_564	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.420776	cube.usd	2025-03-29 14:53:31.121388
2697	hexagonal prism_362	red	{0,0,0}	30.394815	260.80713	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:31.123415
2698	cylinder_539	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:31.1256
2699	pentagonal prism_654	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 14:53:31.354383
2700	cube_565	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:31.357118
2701	hexagonal prism_363	red	{0,0,0}	31.375294	259.82666	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:53:31.359215
2702	cylinder_540	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:53:31.361351
2703	pentagonal prism_655	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:31.595051
2704	cube_566	pink	{0,0,0}	-205.90816	345.1413	938	0	0	59.03624	cube.usd	2025-03-29 14:53:31.597412
2705	cylinder_541	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	cylinder.usd	2025-03-29 14:53:31.599509
2706	cylinder_542	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	cylinder.usd	2025-03-29 14:53:31.601382
2707	pentagonal prism_656	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:31.823119
2708	cube_567	pink	{0,0,0}	-205.90816	345.1413	936.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:31.826609
2709	hexagonal prism_364	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:31.828545
2710	cylinder_543	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:31.830555
2711	pentagonal prism_657	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:32.063978
2712	cube_568	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:53:32.06772
2713	pentagonal prism_658	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:32.069849
2714	cylinder_544	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 14:53:32.071753
2715	pentagonal prism_659	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:32.284274
2716	cube_569	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:32.287119
2717	hexagonal prism_365	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:32.28901
2718	cylinder_545	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:32.290908
2719	pentagonal prism_660	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:32.514758
2720	cube_570	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:32.518628
2721	pentagonal prism_661	red	{0,0,0}	30.394815	260.80713	931.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:32.520566
2722	cylinder_546	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:32.522401
2723	pentagonal prism_662	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 14:53:32.748311
2724	cube_571	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 14:53:32.750484
2725	hexagonal prism_366	red	{0,0,0}	30.51353	260.84146	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:32.752355
2726	cylinder_547	green	{0,0,0}	-272.65317	217.53194	934	0	0	38.65981	cylinder.usd	2025-03-29 14:53:32.754128
2727	pentagonal prism_663	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:32.980606
2728	cube_572	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:32.984276
2729	cylinder_548	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:53:32.986243
2730	cylinder_549	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:53:32.988087
2731	pentagonal prism_664	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:33.216567
2732	cube_573	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.534454	cube.usd	2025-03-29 14:53:33.220337
2733	hexagonal prism_367	red	{0,0,0}	30.514694	260.8514	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:33.222497
2734	cylinder_550	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:33.224559
2735	pentagonal prism_665	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:33.446929
2736	cube_574	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:33.449381
2737	hexagonal prism_368	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:33.451599
2738	cylinder_551	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:33.453434
2739	pentagonal prism_666	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:33.67581
2740	cube_575	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.620872	cube.usd	2025-03-29 14:53:33.679379
2741	hexagonal prism_369	red	{0,0,0}	30.394815	260.80713	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:33.681365
2742	cylinder_552	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:33.683195
2743	pentagonal prism_667	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:33.91803
2744	cube_576	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:33.92134
2745	hexagonal prism_370	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:33.923467
2746	cylinder_553	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:33.925547
2747	pentagonal prism_668	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:34.151906
2748	cube_577	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:34.155317
2749	cylinder_554	red	{0,0,0}	30.395967	260.81702	933	0	0	37.405357	cylinder.usd	2025-03-29 14:53:34.157266
2750	cylinder_555	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:34.159508
2751	pentagonal prism_669	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:34.375875
2752	cube_578	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:34.3789
2753	cube_579	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 14:53:34.38103
2754	cylinder_556	green	{0,0,0}	-270.6119	216.68562	934	0	0	18.434948	cylinder.usd	2025-03-29 14:53:34.382899
2755	pentagonal prism_670	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:34.612444
2756	cube_580	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.620872	cube.usd	2025-03-29 14:53:34.614661
2757	hexagonal prism_371	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:34.616611
2758	cylinder_557	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:34.618436
2759	pentagonal prism_671	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:34.845491
2760	cube_581	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:53:34.849241
2761	pentagonal prism_672	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:53:34.851222
2762	cylinder_558	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:34.853104
2763	pentagonal prism_673	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:35.078684
2764	cube_582	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:53:35.082308
2765	cylinder_559	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:53:35.084429
2766	cylinder_560	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:35.086225
2767	pentagonal prism_674	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:35.314389
2768	cube_583	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:35.318423
2769	hexagonal prism_372	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:35.320453
2770	cylinder_561	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:35.322259
2771	pentagonal prism_675	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:35.540467
2772	cube_584	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.743565	cube.usd	2025-03-29 14:53:35.542929
2773	hexagonal prism_373	red	{0,0,0}	30.514694	260.8514	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:53:35.545272
2774	cylinder_562	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:35.547153
2775	pentagonal prism_676	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:35.77764
2776	cube_585	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:35.78176
2777	hexagonal prism_374	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:35.783658
2778	cylinder_563	green	{0,0,0}	-270.6119	216.68562	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:35.785497
2779	pentagonal prism_677	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:36.013822
2780	cube_586	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03624	cube.usd	2025-03-29 14:53:36.017522
2781	hexagonal prism_375	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:36.019413
2782	cylinder_564	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:53:36.021245
2783	pentagonal prism_678	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:36.261071
2784	cube_587	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 14:53:36.265015
2785	hexagonal prism_376	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:36.266961
2786	cylinder_565	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:36.268826
2787	pentagonal prism_679	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:36.496443
2788	cube_588	pink	{0,0,0}	-205.90038	345.12823	907.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:36.499046
2789	pentagonal prism_680	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:36.501001
2790	cylinder_566	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:53:36.502901
2791	pentagonal prism_681	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:36.726206
2792	cube_589	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:36.729368
2793	hexagonal prism_377	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:36.731717
2794	cylinder_567	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.43495	cylinder.usd	2025-03-29 14:53:36.734219
2795	pentagonal prism_682	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:36.971696
2796	cube_590	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:53:36.974065
2797	hexagonal prism_378	red	{0,0,0}	31.376482	259.8365	924	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:53:36.976151
2798	cylinder_568	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:36.978356
2799	pentagonal prism_683	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:37.225823
2800	cube_591	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:37.228754
2801	hexagonal prism_379	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:37.230994
2802	cylinder_569	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:37.233455
2803	pentagonal prism_684	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:37.466528
2804	cube_592	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:37.470205
2805	hexagonal prism_380	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:37.472054
2806	cylinder_570	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:53:37.473873
2807	pentagonal prism_685	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:37.697163
2808	cube_593	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.620872	cube.usd	2025-03-29 14:53:37.700973
2809	hexagonal prism_381	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:37.702957
2810	cylinder_571	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:37.704802
2811	pentagonal prism_686	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:53:37.927233
2812	cube_594	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:37.931583
2813	pentagonal prism_687	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:37.933696
2814	cylinder_572	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:37.935727
2815	pentagonal prism_688	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:38.166221
2816	cube_595	pink	{0,0,0}	-207.68886	346.4762	915	0	0	59.03625	cube.usd	2025-03-29 14:53:38.168526
2817	cube_596	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.234837	cube.usd	2025-03-29 14:53:38.170488
2818	cylinder_573	green	{0,0,0}	-272.65317	217.53194	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:38.172277
2819	pentagonal prism_689	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:38.403899
2820	cube_597	pink	{0,0,0}	-207.6968	346.48944	926.00006	0	0	59.620872	cube.usd	2025-03-29 14:53:38.407735
2821	hexagonal prism_382	red	{0,0,0}	30.514694	260.8514	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:38.409613
2822	cylinder_574	green	{0,0,0}	-272.66354	217.54024	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:38.411758
2823	pentagonal prism_690	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:38.631676
2824	cube_598	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:38.63474
2825	hexagonal prism_383	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:38.636706
2826	cylinder_575	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:38.638623
2827	pentagonal prism_691	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:38.864544
2828	cube_599	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:38.868387
2829	hexagonal prism_384	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:38.870294
2830	cylinder_576	green	{0,0,0}	-270.62216	216.69383	938	0	0	18.434948	cylinder.usd	2025-03-29 14:53:38.872145
2831	pentagonal prism_692	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:39.0974
2832	cube_600	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:39.099696
2833	hexagonal prism_385	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:39.101879
2834	cylinder_577	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:53:39.103781
2835	pentagonal prism_693	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:39.336489
2836	cube_601	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:39.340164
2837	hexagonal prism_386	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:39.342204
2838	cylinder_578	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:39.344084
2839	pentagonal prism_694	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:53:39.566591
2840	cube_602	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:53:39.570235
2841	hexagonal prism_387	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:39.572203
2842	cylinder_579	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:39.574331
2843	pentagonal prism_695	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:39.804367
2844	cube_603	pink	{0,0,0}	-206.88867	345.1413	911.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:39.808134
2845	hexagonal prism_388	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:39.810174
2846	cylinder_580	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:39.812068
2847	pentagonal prism_696	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:40.035794
2848	cube_604	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 14:53:40.039602
2849	pentagonal prism_697	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:40.041507
2850	cylinder_581	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:40.043458
2851	pentagonal prism_698	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:40.26286
2852	cube_605	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.743565	cube.usd	2025-03-29 14:53:40.267117
2853	hexagonal prism_389	red	{0,0,0}	31.376482	259.8365	934	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:53:40.269469
2854	cylinder_582	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:40.271544
2855	pentagonal prism_699	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:40.500997
2856	cube_606	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:53:40.503313
2857	pentagonal prism_700	red	{0,0,0}	30.395967	260.81702	933	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:53:40.505309
2858	cylinder_583	green	{0,0,0}	-270.62216	216.69383	942.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:40.507166
2859	pentagonal prism_701	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:40.730532
2860	cube_607	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:40.734273
2861	pentagonal prism_702	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:40.736433
2862	cylinder_584	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:40.738349
2863	pentagonal prism_703	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:40.988548
2864	cube_608	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:40.990991
2865	cube_609	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	cube.usd	2025-03-29 14:53:40.994361
2866	cylinder_585	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:40.996381
2867	pentagonal prism_704	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:41.222044
2868	cube_610	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.620872	cube.usd	2025-03-29 14:53:41.224543
2869	hexagonal prism_390	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:53:41.226484
2870	cylinder_586	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:41.228353
2871	pentagonal prism_705	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:41.457723
2872	cube_611	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:41.459938
2873	hexagonal prism_391	red	{0,0,0}	30.394815	260.80713	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:41.462075
2874	cylinder_587	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:53:41.464028
2875	pentagonal prism_706	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:41.697598
2876	cube_612	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:53:41.700301
2877	cube_613	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	cube.usd	2025-03-29 14:53:41.702625
2878	cylinder_588	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:41.704585
2879	pentagonal prism_707	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:41.925235
2880	cube_614	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:41.928968
2881	pentagonal prism_708	red	{0,0,0}	32.357	258.856	920	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:53:41.931103
2882	cylinder_589	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:41.933273
2883	pentagonal prism_709	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:42.148652
2884	cube_615	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:53:42.151536
2885	hexagonal prism_392	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:42.153593
2886	cylinder_590	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:42.155403
2887	pentagonal prism_710	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:42.381418
2888	cube_616	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:42.384189
2889	hexagonal prism_393	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.746803	hexagonal prism.usd	2025-03-29 14:53:42.386833
2890	cylinder_591	green	{0,0,0}	-270.6119	216.68562	934	0	0	18.434948	cylinder.usd	2025-03-29 14:53:42.388766
2891	pentagonal prism_711	black	{0,0,0}	-127.46696	518.69244	661	0	0	0	pentagonal prism.usd	2025-03-29 14:53:42.615466
2892	cube_617	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:53:42.619306
2893	pentagonal prism_712	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:42.621386
2894	cylinder_592	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:53:42.623304
2895	pentagonal prism_713	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:53:42.850635
2896	cube_618	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.743565	cube.usd	2025-03-29 14:53:42.854462
2897	hexagonal prism_394	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:42.856528
2898	cylinder_593	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:53:42.858313
2899	pentagonal prism_714	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:43.086679
2900	cube_619	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:53:43.090365
2901	pentagonal prism_715	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 14:53:43.092285
2902	cylinder_594	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:43.094064
2903	pentagonal prism_716	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:43.322406
2904	cube_620	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:53:43.325723
2905	hexagonal prism_395	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:43.327594
2906	cylinder_595	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:43.329792
2907	pentagonal prism_717	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:43.554729
2908	cube_621	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.34933	cube.usd	2025-03-29 14:53:43.558432
2909	hexagonal prism_396	red	{0,0,0}	31.375294	259.82666	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:43.560312
2910	cylinder_596	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:43.562121
2911	pentagonal prism_718	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:43.785717
2912	cube_622	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:43.789446
2913	pentagonal prism_719	red	{0,0,0}	32.357	258.856	934	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:43.79149
2914	cylinder_597	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:43.793398
2915	pentagonal prism_720	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:53:44.033037
2916	cube_623	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 14:53:44.035556
2917	hexagonal prism_397	red	{0,0,0}	31.375294	259.82666	920	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:53:44.037932
2918	cylinder_598	green	{0,0,0}	-270.6119	216.68562	933	0	0	18.434948	cylinder.usd	2025-03-29 14:53:44.040229
2919	pentagonal prism_721	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:44.283658
2920	cube_624	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	cube.usd	2025-03-29 14:53:44.286132
2921	hexagonal prism_398	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:44.288356
2922	cylinder_599	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	45	cylinder.usd	2025-03-29 14:53:44.290246
2923	pentagonal prism_722	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:44.510301
2924	cube_625	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.34933	cube.usd	2025-03-29 14:53:44.512527
2925	pentagonal prism_723	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:53:44.514422
2926	cylinder_600	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:44.516495
2927	pentagonal prism_724	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:44.731614
2928	cube_626	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:44.73548
2929	hexagonal prism_399	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:44.737562
2930	cylinder_601	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:44.739695
2931	pentagonal prism_725	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:44.966268
2932	cube_627	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 14:53:44.970224
2933	hexagonal prism_400	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:44.97253
2934	cylinder_602	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:44.974513
2935	pentagonal prism_726	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:45.199218
2936	cube_628	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03625	cube.usd	2025-03-29 14:53:45.201637
2937	hexagonal prism_401	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:45.203987
2938	cylinder_603	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:45.206228
2939	pentagonal prism_727	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:45.433949
2940	cube_629	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:53:45.437764
2941	pentagonal prism_728	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:45.439981
2942	cylinder_604	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:45.441975
2943	hexagonal prism 1	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 14:53:51.176931
2944	cube 1	pink	{0,0,0}	-206.88867	345.1413	932.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:51.180994
2945	hexagonal prism 2	red	{0,0,0}	30.395967	260.81702	946.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:51.182866
2946	cylinder 1	green	{0,0,0}	-270.62216	216.69383	903.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:51.184711
2947	pentagonal prism 1	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:51.407427
2948	cube 2	pink	{0,0,0}	-206.88867	345.1413	932.00006	0	0	59.620872	cube.usd	2025-03-29 14:53:51.409812
2949	hexagonal prism 3	red	{0,0,0}	31.376482	259.8365	946.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:51.411675
2950	cylinder 2	green	{0,0,0}	-270.62216	216.69383	903.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:51.413562
2951	pentagonal prism 2	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:51.637027
2952	cube 3	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03625	cube.usd	2025-03-29 14:53:51.639462
2953	hexagonal prism 4	red	{0,0,0}	31.376482	259.8365	946.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:51.641802
2954	cylinder 3	green	{0,0,0}	-270.62216	216.69383	903.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:51.643692
2955	pentagonal prism 3	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:51.853961
2956	cube 4	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.420776	cube.usd	2025-03-29 14:53:51.856229
2957	hexagonal prism 5	red	{0,0,0}	31.375294	259.82666	946.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:51.858714
2958	cylinder 4	green	{0,0,0}	-270.6119	216.68562	903.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:51.86068
2959	pentagonal prism 4	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:52.071102
2960	cube 5	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03624	cube.usd	2025-03-29 14:53:52.073707
2961	hexagonal prism 6	red	{0,0,0}	31.376482	259.8365	946.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:52.075983
2962	cylinder 5	green	{0,0,0}	-270.62216	216.69383	903.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:52.077847
2963	pentagonal prism 5	black	{0,0,0}	-128.94919	520.7185	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:52.290818
2964	cube 6	pink	{0,0,0}	-207.6968	346.48944	933	0	0	59.534454	cube.usd	2025-03-29 14:53:52.293865
2965	pentagonal prism 6	red	{0,0,0}	29.53035	261.83575	946.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:52.295824
2966	cylinder 6	green	{0,0,0}	-272.66354	217.54024	903.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:53:52.297711
2967	pentagonal prism 7	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:52.529972
2968	cube 7	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.420776	cube.usd	2025-03-29 14:53:52.533951
2969	hexagonal prism 7	red	{0,0,0}	30.394815	260.80713	946.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:52.535804
2970	cylinder 7	green	{0,0,0}	-270.6119	216.68562	903.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:52.537757
2971	pentagonal prism 8	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:52.759854
2972	cube 8	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03625	cube.usd	2025-03-29 14:53:52.763617
2973	hexagonal prism 8	red	{0,0,0}	31.376482	259.8365	946.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:52.765481
2974	cylinder 8	green	{0,0,0}	-270.62216	216.69383	903.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:52.767249
2975	pentagonal prism 9	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:52.994671
2976	cube 9	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.620872	cube.usd	2025-03-29 14:53:52.997035
2977	hexagonal prism 9	red	{0,0,0}	31.375294	259.82666	946.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:52.998972
2978	cylinder 9	green	{0,0,0}	-270.6119	216.68562	903.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:53.00088
2979	pentagonal prism 10	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:53.224047
2980	cube 10	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.534454	cube.usd	2025-03-29 14:53:53.226784
2981	pentagonal prism 11	red	{0,0,0}	32.355774	258.8462	946.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:53.228881
2982	cylinder 10	green	{0,0,0}	-270.6119	216.68562	903.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:53.230762
2983	pentagonal prism 12	black	{0,0,0}	-128.94919	520.7185	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:53.462455
2984	cube 11	pink	{0,0,0}	-207.6968	346.48944	933	0	0	59.03625	cube.usd	2025-03-29 14:53:53.466038
2985	cube 12	red	{0,0,0}	31.499039	259.86707	946.00006	0	0	37.184704	cube.usd	2025-03-29 14:53:53.467863
2986	cylinder 11	green	{0,0,0}	-272.66354	217.54024	903.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:53.469606
2987	pentagonal prism 13	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:53.68459
2988	cube 13	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03625	cube.usd	2025-03-29 14:53:53.686739
2989	hexagonal prism 10	red	{0,0,0}	30.395967	260.81702	946.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:53.688558
2990	cylinder 12	green	{0,0,0}	-270.62216	216.69383	903.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:53.690505
2991	pentagonal prism 14	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:53.905136
2992	cube 14	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:53.907257
2993	hexagonal prism 11	red	{0,0,0}	31.376482	259.8365	924	0	0	37.234837	hexagonal prism.usd	2025-03-29 14:53:53.909262
2994	cylinder 13	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:53.911496
2995	pentagonal prism 15	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:54.13808
2996	cube 15	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:53:54.141769
2997	hexagonal prism 12	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:54.144487
2998	cylinder 14	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:54.146479
2999	pentagonal prism 16	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:54.391466
3000	cube 16	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:54.394428
3001	hexagonal prism 13	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:54.396513
3002	cylinder 15	green	{0,0,0}	-270.62216	216.69383	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:54.399426
3003	pentagonal prism 17	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:54.62527
3004	cube 17	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:54.628429
3005	cylinder 16	red	{0,0,0}	30.394815	260.80713	924	0	0	37.405357	cylinder.usd	2025-03-29 14:53:54.630455
3006	cylinder 17	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:54.632382
3007	pentagonal prism 18	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:54.868344
3008	cube 18	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:54.871835
3009	hexagonal prism 14	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:54.874031
3010	cylinder 18	green	{0,0,0}	-270.62216	216.69383	924	0	0	36.869896	cylinder.usd	2025-03-29 14:53:54.876108
3011	pentagonal prism 19	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:55.107521
3012	cube 19	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:55.110212
3013	hexagonal prism 15	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:55.112405
3014	cylinder 19	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:55.114302
3015	pentagonal prism 20	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:55.344158
3016	cube 20	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:55.347529
3017	hexagonal prism 16	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:53:55.349429
3018	cylinder 20	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:53:55.351329
3019	pentagonal prism 21	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:55.57931
3020	cube 21	pink	{0,0,0}	-205.90038	345.12823	910	0	0	59.03624	cube.usd	2025-03-29 14:53:55.581612
3021	hexagonal prism 17	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:55.58357
3022	cylinder 21	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:55.58556
3023	pentagonal prism 22	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:55.80267
3024	cube 22	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03625	cube.usd	2025-03-29 14:53:55.806468
3025	hexagonal prism 18	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:55.808524
3026	cylinder 22	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:55.810693
3027	pentagonal prism 23	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:56.033118
3028	cube 23	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:53:56.035697
3029	hexagonal prism 19	red	{0,0,0}	31.375294	259.82666	914.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:56.037773
3030	cylinder 23	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:56.039835
3031	pentagonal prism 24	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:56.269401
3032	cube 24	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:53:56.272975
3033	hexagonal prism 20	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:56.274919
3034	cylinder 24	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:53:56.276892
3035	pentagonal prism 25	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:56.513478
3036	cube 25	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:56.515692
3037	hexagonal prism 21	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:56.517578
3038	cylinder 25	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:56.519378
3039	pentagonal prism 26	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:56.745731
3040	cube 26	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:53:56.748449
3041	hexagonal prism 22	red	{0,0,0}	30.395967	260.81702	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:56.75046
3042	cylinder 26	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:56.752349
3043	pentagonal prism 27	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal prism.usd	2025-03-29 14:53:56.972463
3044	cube 27	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.620872	cube.usd	2025-03-29 14:53:56.976058
3045	hexagonal prism 23	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:56.978349
3046	cylinder 27	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:53:56.980402
3047	pentagonal prism 28	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:57.194234
3048	cube 28	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.743565	cube.usd	2025-03-29 14:53:57.197169
3049	hexagonal prism 24	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:57.19918
3050	cylinder 28	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:53:57.200989
3051	pentagonal prism 29	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:57.428831
3052	cube 29	pink	{0,0,0}	-207.6968	346.48944	926.00006	0	0	59.420776	cube.usd	2025-03-29 14:53:57.431529
3053	hexagonal prism 25	red	{0,0,0}	30.514694	260.8514	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:57.433426
3054	cylinder 29	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:57.435216
3055	pentagonal prism 30	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:57.658234
3056	cube 30	pink	{0,0,0}	-207.68886	346.4762	911.00006	0	0	59.743565	cube.usd	2025-03-29 14:53:57.662029
3057	hexagonal prism 26	red	{0,0,0}	30.51353	260.84146	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:57.664442
3058	cylinder 30	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:57.666472
3059	pentagonal prism 31	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:57.904175
3060	cube 31	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:57.906359
3061	hexagonal prism 27	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:57.908473
3062	cylinder 31	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:57.910506
3063	pentagonal prism 32	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:58.133671
3064	cube 32	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:58.135952
3065	hexagonal prism 28	red	{0,0,0}	30.51353	260.84146	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:58.137793
3066	cylinder 32	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 14:53:58.139586
3067	pentagonal prism 33	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 14:53:58.355158
3068	cube 33	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 14:53:58.359056
3069	hexagonal prism 29	red	{0,0,0}	30.51353	260.84146	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:53:58.360963
3070	cylinder 33	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:53:58.363047
3071	pentagonal prism 34	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:58.582928
3072	cube 34	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.743565	cube.usd	2025-03-29 14:53:58.585438
3073	hexagonal prism 30	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:58.587659
3074	cylinder 34	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:58.589537
3075	pentagonal prism 35	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:53:58.809651
3076	cube 35	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:53:58.812021
3077	pentagonal prism 36	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:53:58.814397
3078	cylinder 35	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:58.81637
3079	pentagonal prism 37	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:59.045589
3080	cube 36	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.620872	cube.usd	2025-03-29 14:53:59.049571
3081	pentagonal prism 38	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:53:59.051577
3082	cylinder 36	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:53:59.053348
3083	pentagonal prism 39	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:59.277632
3084	cube 37	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:53:59.281764
3085	hexagonal prism 31	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:59.283958
3086	cylinder 37	green	{0,0,0}	-270.62216	216.69383	919	0	0	33.690063	cylinder.usd	2025-03-29 14:53:59.285848
3087	pentagonal prism 40	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:53:59.51757
3088	cube 38	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:53:59.521464
3089	hexagonal prism 32	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:59.523513
3090	cylinder 38	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:53:59.525485
3091	pentagonal prism 41	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:53:59.756504
3092	cube 39	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:53:59.760121
3093	hexagonal prism 33	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:59.762009
3094	cylinder 39	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:53:59.764012
3095	pentagonal prism 42	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:53:59.980111
3096	cube 40	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:53:59.982657
3097	hexagonal prism 34	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:53:59.984607
3098	cylinder 40	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:53:59.98641
3099	pentagonal prism 43	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:54:00.221177
3100	cube 41	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:54:00.223789
3101	hexagonal prism 35	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:00.22624
3102	cylinder 41	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:00.228547
3103	pentagonal prism 44	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:00.446813
3104	cube 42	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 14:54:00.449619
3105	hexagonal prism 36	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:54:00.451632
3106	cylinder 42	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:00.45345
3107	pentagonal prism 45	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:00.671063
3108	cube 43	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:54:00.673642
3109	hexagonal prism 37	red	{0,0,0}	31.376482	259.8365	929	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:54:00.675678
3110	cylinder 43	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:00.677781
3111	pentagonal prism 46	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:00.895337
3112	cube 44	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.34933	cube.usd	2025-03-29 14:54:00.89745
3113	hexagonal prism 38	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:00.899846
3114	cylinder 44	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:00.901961
3115	pentagonal prism 47	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:54:01.126799
3116	cube 45	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03625	cube.usd	2025-03-29 14:54:01.130777
3117	hexagonal prism 39	red	{0,0,0}	30.514694	260.8514	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:01.133003
3118	cylinder 45	green	{0,0,0}	-272.66354	217.54024	935.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:54:01.134998
3119	pentagonal prism 48	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:01.37887
3120	cube 46	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.03624	cube.usd	2025-03-29 14:54:01.381577
3121	hexagonal prism 40	red	{0,0,0}	30.394815	260.80713	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:01.383713
3122	cylinder 46	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:01.385552
3123	pentagonal prism 49	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:01.599925
3124	cube 47	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.743565	cube.usd	2025-03-29 14:54:01.602381
3125	hexagonal prism 41	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:54:01.604378
3126	cylinder 47	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:01.606339
3127	pentagonal prism 50	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:54:01.832625
3128	cube 48	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.34933	cube.usd	2025-03-29 14:54:01.836446
3129	hexagonal prism 42	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:54:01.838538
3130	cylinder 48	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:54:01.840456
3131	pentagonal prism 51	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:02.060115
3132	cube 49	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:54:02.063633
3133	hexagonal prism 43	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:54:02.065704
3134	cylinder 49	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:02.068148
3135	pentagonal prism 52	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal prism.usd	2025-03-29 14:54:02.284658
3136	cube 50	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03625	cube.usd	2025-03-29 14:54:02.287775
3137	hexagonal prism 44	red	{0,0,0}	30.514694	260.8514	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:02.289661
3138	cylinder 50	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	cylinder.usd	2025-03-29 14:54:02.292384
3139	pentagonal prism 53	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:54:02.519119
3140	cube 51	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.03624	cube.usd	2025-03-29 14:54:02.523008
3141	hexagonal prism 45	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:02.526616
3142	cylinder 51	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:54:02.529153
3143	pentagonal prism 54	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:54:02.756587
3144	cube 52	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:54:02.758776
3145	hexagonal prism 46	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.746803	hexagonal prism.usd	2025-03-29 14:54:02.760758
3146	cylinder 52	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:02.762559
3147	pentagonal prism 55	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:02.980979
3148	cube 53	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:54:02.984478
3149	hexagonal prism 47	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:54:02.987134
3150	cylinder 53	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:02.989821
3151	pentagonal prism 56	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:54:03.21639
3152	cube 54	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:54:03.220501
3153	pentagonal prism 57	red	{0,0,0}	30.394815	260.80713	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:54:03.222555
3154	cylinder 54	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:03.224483
3155	pentagonal prism 58	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:03.445742
3156	cube 55	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 14:54:03.449844
3157	hexagonal prism 48	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:54:03.452256
3158	cylinder 55	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:54:03.454227
3159	pentagonal prism 59	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:54:03.685664
3160	cube 56	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.03624	cube.usd	2025-03-29 14:54:03.689418
3161	pentagonal prism 60	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:54:03.691412
3162	cylinder 56	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 14:54:03.69339
3163	pentagonal prism 61	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:54:03.912854
3164	cube 57	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:54:03.916484
3165	cube 58	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	cube.usd	2025-03-29 14:54:03.918978
3166	cylinder 57	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:03.920984
3167	pentagonal prism 62	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:04.182
3168	cube 59	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:54:04.185035
3169	hexagonal prism 49	orange	{0,0,0}	30.514694	260.8514	928.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:54:04.187127
3170	cylinder 58	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:04.189089
3171	pentagonal prism 63	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:04.411389
3172	cube 60	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:54:04.41538
3173	hexagonal prism 50	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:04.417689
3174	cylinder 59	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:04.419739
3175	pentagonal prism 64	black	{0,0,0}	-128.94919	520.7185	656	0	0	0	pentagonal prism.usd	2025-03-29 14:54:04.643042
3176	cube 61	pink	{0,0,0}	-207.6968	346.48944	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:54:04.646553
3177	pentagonal prism 65	red	{0,0,0}	30.514694	260.8514	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:54:04.648364
3178	cylinder 60	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:04.650258
3179	pentagonal prism 66	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:04.870745
3180	cube 62	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 14:54:04.873297
3181	hexagonal prism 51	red	{0,0,0}	30.394815	260.80713	937.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:04.875184
3182	cylinder 61	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:54:04.877006
3183	pentagonal prism 67	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:54:05.107146
3184	cube 63	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.620872	cube.usd	2025-03-29 14:54:05.110946
3185	hexagonal prism 52	red	{0,0,0}	31.375294	259.82666	936.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:05.112838
3186	cylinder 62	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:05.114607
3187	pentagonal prism 68	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:05.331062
3188	cube 64	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.743565	cube.usd	2025-03-29 14:54:05.333677
3189	pentagonal prism 69	red	{0,0,0}	30.394815	260.80713	930.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:54:05.335943
3190	cylinder 63	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 14:54:05.338234
3191	pentagonal prism 70	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:54:05.5518
3192	cube 65	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 14:54:05.554494
3193	hexagonal prism 53	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:05.556437
3194	cylinder 64	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:05.558351
3195	pentagonal prism 71	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:05.794764
3196	cube 66	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:54:05.796851
3197	hexagonal prism 54	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:05.798875
3198	cylinder 65	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:54:05.80089
3199	pentagonal prism 72	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:06.031075
3200	cube 67	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03625	cube.usd	2025-03-29 14:54:06.036162
3201	pentagonal prism 73	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:54:06.039837
3202	cylinder 66	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:54:06.043044
3203	pentagonal prism 74	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:54:06.265502
3204	cube 68	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.743565	cube.usd	2025-03-29 14:54:06.267866
3205	pentagonal prism 75	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:54:06.270404
3206	cylinder 67	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:06.272489
3207	pentagonal prism 76	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:54:06.496815
3208	cube 69	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:54:06.500525
3209	hexagonal prism 55	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:06.50249
3210	cylinder 68	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:06.505012
3211	pentagonal prism 77	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:54:06.740256
3212	cube 70	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 14:54:06.742588
3213	hexagonal prism 56	red	{0,0,0}	30.51353	260.84146	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:06.744575
3214	cylinder 69	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:06.746468
3215	pentagonal prism 78	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:06.963752
3216	cube 71	pink	{0,0,0}	-205.90038	345.12823	935.00006	0	0	59.534454	cube.usd	2025-03-29 14:54:06.966088
3217	hexagonal prism 57	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:06.968204
3218	cylinder 70	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:06.970892
3219	pentagonal prism 79	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:07.217904
3220	cube 72	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:54:07.220543
3221	pentagonal prism 80	red	{0,0,0}	32.357	258.856	919	0	0	37.746803	pentagonal prism.usd	2025-03-29 14:54:07.223256
3222	cylinder 71	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:07.225381
3223	pentagonal prism 81	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:07.460873
3224	cube 73	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	cube.usd	2025-03-29 14:54:07.463291
3225	hexagonal prism 58	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:54:07.465249
3226	cylinder 72	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:07.467939
3227	pentagonal prism 82	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:54:07.699408
3228	cube 74	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.743565	cube.usd	2025-03-29 14:54:07.703188
3229	hexagonal prism 59	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:54:07.705724
3230	cylinder 73	green	{0,0,0}	-270.6119	216.68562	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:54:07.70772
\.


--
-- Data for Name: drop_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.drop_op_parameters (sequence_id, operation_order, object_id, drop_height, operation_status) FROM stdin;
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
1	2025-03-29 14:49:59.971943	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-03-29 14:49:59.971943	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 14:49:59.971943
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 14:49:59.971943
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-03-29 14:49:59.971943
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
\.


--
-- Data for Name: pick_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.pick_op_parameters (sequence_id, operation_order, object_id, slide_state_status, slide_direction, distance_travel, operation_status) FROM stdin;
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
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-03-29 14:49:59.971943
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-03-29 14:49:59.971943
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
\.


--
-- Data for Name: unified_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.unified_instructions (id, session_id, "timestamp", liu_id, voice_command, gesture_command, unified_command, confidence, processed) FROM stdin;
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
1	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscar.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	2025-03-29 14:49:59.971943	2025-03-29 14:49:59.971943
2	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahul.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\N	\N	2025-03-29 14:49:59.971943	2025-03-29 14:49:59.971943
3	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanjay.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	2025-03-29 14:49:59.971943	2025-03-29 14:49:59.971943
4	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehdi.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	2025-03-29 14:49:59.971943	2025-03-29 14:49:59.971943
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 3234, true);


--
-- Name: drop_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.drop_op_parameters_sequence_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.operation_sequence_id_seq', 1, false);


--
-- Name: pick_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.pick_op_parameters_sequence_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.sort_order_order_id_seq', 1, false);


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

SELECT pg_catalog.setval('public.travel_op_parameters_sequence_id_seq', 1, false);


--
-- Name: unified_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.unified_instructions_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.users_user_id_seq', 4, true);


--
-- Name: voice_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.voice_instructions_id_seq', 1, false);


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

