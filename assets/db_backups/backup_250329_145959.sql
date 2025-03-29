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
1433	pentagonal prism 507	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:36.031091
4	cylinder 75	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:17.357269
5	pentagonal prism 85	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:17.586778
8	cylinder 76	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:17.59471
7	pentagonal prism 86	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:17.810211
9	pentagonal prism 87	red	{0,0,0}	31.499039	259.86707	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:17.816276
12	cylinder 77	green	{0,0,0}	-272.66354	217.54024	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:17.818293
13	pentagonal prism 88	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:18.045521
16	cylinder 78	red	{0,0,0}	29.53035	261.83575	928.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:58:18.051871
20	cylinder 79	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:18.054147
17	pentagonal prism 89	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:18.291154
24	cylinder 80	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:18.29964
21	pentagonal prism 90	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:18.520935
2	cube 76	pink	{0,0,0}	-207.6968	346.48944	927.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:18.526539
27	cylinder 81	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:18.53046
25	pentagonal prism 91	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:18.769364
6	cube 77	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:18.773184
28	cylinder 82	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:58:18.777131
29	pentagonal prism 92	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:19.00363
10	cube 78	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 14:58:19.005991
32	cylinder 83	green	{0,0,0}	-272.65317	217.53194	924	0	0	18.434948	cylinder.usd	2025-03-29 14:58:19.009937
33	pentagonal prism 93	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:19.233632
14	cube 79	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:58:19.237781
36	cylinder 84	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:19.241942
37	pentagonal prism 94	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:19.476681
18	cube 80	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.34933	cube.usd	2025-03-29 14:58:19.481031
40	cylinder 85	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:19.486052
45	pentagonal prism 96	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:19.707697
22	cube 81	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	cube.usd	2025-03-29 14:58:19.711944
49	pentagonal prism 97	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:19.714012
44	cylinder 86	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:19.716607
53	pentagonal prism 98	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:19.936258
26	cube 82	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:19.938943
30	cube 83	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 14:58:19.941103
48	cylinder 87	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:19.943103
34	cube 84	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:20.18795
52	cylinder 88	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:20.191925
38	cube 85	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:20.422102
42	cube 86	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:20.65616
46	cube 87	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:20.896653
50	cube 88	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:58:21.12854
3	hexagonal prism 61	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:24.410661
11	hexagonal prism 62	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:25.114425
15	hexagonal prism 63	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:25.346212
19	hexagonal prism 64	red	{0,0,0}	30.514694	260.8514	927.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:25.582547
23	hexagonal prism 65	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:25.816814
31	hexagonal prism 66	red	{0,0,0}	30.51353	260.84146	917.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:26.283484
35	hexagonal prism 67	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:26.509478
39	hexagonal prism 68	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:27.228347
43	hexagonal prism 69	red	{0,0,0}	30.395967	260.81702	934	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:58:27.905777
47	hexagonal prism 70	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:58:28.142632
51	hexagonal prism 71	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:28.611896
1485	pentagonal prism 521	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:38.139005
61	pentagonal prism 100	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:20.418914
63	pentagonal prism 101	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:20.424233
56	cylinder 89	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:20.426398
65	pentagonal prism 102	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:20.653345
60	cylinder 90	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:20.660408
69	pentagonal prism 103	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:20.892847
64	cylinder 91	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:20.901724
73	pentagonal prism 104	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:21.124873
75	pentagonal prism 105	red	{0,0,0}	32.357	258.856	924	0	0	37.234837	pentagonal prism.usd	2025-03-29 14:58:21.130848
68	cylinder 92	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:21.133432
77	pentagonal prism 106	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:21.353715
54	cube 89	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.34933	cube.usd	2025-03-29 14:58:21.356473
72	cylinder 93	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.43495	cylinder.usd	2025-03-29 14:58:21.361066
81	pentagonal prism 107	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:21.588358
58	cube 90	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:58:21.592228
85	pentagonal prism 108	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:21.594412
76	cylinder 94	green	{0,0,0}	-270.62216	216.69383	943	0	0	26.56505	cylinder.usd	2025-03-29 14:58:21.596444
89	pentagonal prism 109	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:21.8176
62	cube 91	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:21.820347
93	pentagonal prism 110	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:58:21.822593
80	cylinder 95	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:21.824727
97	pentagonal prism 111	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:22.072394
66	cube 92	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:58:22.074933
84	cylinder 96	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:22.078816
101	pentagonal prism 112	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:22.301447
70	cube 93	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.34933	cube.usd	2025-03-29 14:58:22.305416
88	cylinder 97	green	{0,0,0}	-272.66354	217.54024	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:22.309337
74	cube 94	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:22.540484
105	pentagonal prism 114	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:22.5425
92	cylinder 98	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:22.544585
78	cube 95	pink	{0,0,0}	-207.6968	346.48944	934	0	0	59.03625	cube.usd	2025-03-29 14:58:22.774497
96	cylinder 99	green	{0,0,0}	-272.66354	217.54024	924	0	0	18.434948	cylinder.usd	2025-03-29 14:58:22.778612
82	cube 96	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:58:23.012835
100	cylinder 100	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:23.017009
86	cube 97	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:23.237789
104	cylinder 101	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:58:23.241708
90	cube 98	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:23.47717
94	cube 99	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:58:23.712063
98	cube 100	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	cube.usd	2025-03-29 14:58:23.714295
102	cube 101	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.34933	cube.usd	2025-03-29 14:58:23.948001
106	cube 102	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 14:58:24.170593
55	hexagonal prism 72	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:28.843671
59	hexagonal prism 73	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:29.081374
67	hexagonal prism 74	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:29.330797
71	hexagonal prism 75	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:29.571411
79	hexagonal prism 76	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:29.795887
83	hexagonal prism 77	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:30.265666
87	hexagonal prism 78	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:30.732157
91	hexagonal prism 79	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:30.968959
95	hexagonal prism 80	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:58:31.208777
99	hexagonal prism 81	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:31.684106
1541	pentagonal prism 536	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:40.739183
109	pentagonal prism 116	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:23.008956
113	pentagonal prism 117	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:23.234696
117	pentagonal prism 118	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:23.474381
108	cylinder 102	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	cylinder.usd	2025-03-29 14:58:23.48157
121	pentagonal prism 119	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:23.708323
112	cylinder 103	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:23.716362
125	pentagonal prism 120	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:23.945603
129	pentagonal prism 121	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:58:23.950061
116	cylinder 104	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:58:23.952235
133	pentagonal prism 122	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:24.167325
137	pentagonal prism 123	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:58:24.17303
120	cylinder 105	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:24.175219
139	pentagonal prism 124	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:24.405992
110	cube 103	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:58:24.408525
124	cylinder 106	green	{0,0,0}	-270.6119	216.68562	934	0	0	33.690063	cylinder.usd	2025-03-29 14:58:24.412706
141	pentagonal prism 125	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:24.644237
114	cube 104	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:24.648325
118	cube 105	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	cube.usd	2025-03-29 14:58:24.650695
128	cylinder 107	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 14:58:24.653097
145	pentagonal prism 126	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:24.872021
122	cube 106	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 14:58:24.875031
147	pentagonal prism 127	red	{0,0,0}	32.355774	258.8462	929	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:58:24.877034
132	cylinder 108	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:24.879005
126	cube 107	pink	{0,0,0}	-205.90038	345.12823	907.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:25.112338
136	cylinder 109	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:25.116531
153	pentagonal prism 129	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:25.340343
130	cube 108	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:58:25.344064
140	cylinder 110	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:25.348208
157	pentagonal prism 130	black	{0,0,0}	-128.94919	520.7185	657	0	0	0	pentagonal prism.usd	2025-03-29 14:58:25.576576
134	cube 109	pink	{0,0,0}	-207.6968	346.48944	912.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:25.580433
144	cylinder 111	green	{0,0,0}	-272.66354	217.54024	917.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:25.584776
138	cube 110	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:25.814553
148	cylinder 112	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:25.818826
142	cube 111	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:26.040651
152	cylinder 113	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:26.045677
146	cube 112	pink	{0,0,0}	-207.68886	346.4762	912.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:26.281378
155	cylinder 114	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:26.285539
150	cube 113	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:26.50734
156	cylinder 115	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:26.511633
154	cube 114	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:26.756172
158	cube 115	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:26.997631
111	hexagonal prism 82	red	{0,0,0}	31.376482	259.8365	920	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:31.905012
115	hexagonal prism 83	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:32.387292
119	hexagonal prism 84	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:32.862131
123	hexagonal prism 85	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:33.086392
127	hexagonal prism 86	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:33.319888
131	hexagonal prism 87	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:33.785715
135	hexagonal prism 88	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:34.025501
143	hexagonal prism 89	red	{0,0,0}	31.376482	259.8365	920	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:34.254441
151	hexagonal prism 90	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:34.731532
159	hexagonal prism 91	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:34.967346
1591	pentagonal prism 549	black	{0,0,0}	-128.94919	520.7185	657	0	0	0	pentagonal prism.usd	2025-03-29 14:59:43.607964
165	pentagonal prism 132	black	{0,0,0}	-128.94919	520.7185	657	0	0	0	pentagonal prism.usd	2025-03-29 14:58:26.036826
169	pentagonal prism 133	red	{0,0,0}	31.499039	259.86707	928.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:58:26.042765
173	pentagonal prism 134	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:26.277405
177	pentagonal prism 135	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:26.502926
181	pentagonal prism 136	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:26.751849
185	pentagonal prism 137	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:26.758448
160	cylinder 116	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:26.76063
189	pentagonal prism 138	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:26.995009
193	pentagonal prism 139	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:26.999906
163	cylinder 117	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:27.001952
197	pentagonal prism 140	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:27.223766
162	cube 116	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:27.226149
164	cylinder 118	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:58:27.230355
201	pentagonal prism 141	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:27.448932
166	cube 117	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:58:27.452959
203	pentagonal prism 142	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:58:27.455281
168	cylinder 119	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:27.457974
205	pentagonal prism 143	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:27.6764
170	cube 118	pink	{0,0,0}	-207.6968	346.48944	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:27.68015
209	pentagonal prism 144	red	{0,0,0}	31.499039	259.86707	925.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:58:27.682186
172	cylinder 120	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:27.684432
174	cube 119	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	cube.usd	2025-03-29 14:58:27.903167
176	cylinder 121	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:27.90808
175	cube 120	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:28.140161
180	cylinder 122	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:28.144735
178	cube 121	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:28.381548
184	cylinder 123	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:28.385967
182	cube 122	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 14:58:28.609647
188	cylinder 124	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:28.614004
183	cube 123	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:28.839832
192	cylinder 125	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:28.84687
186	cube 124	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:58:29.079135
196	cylinder 126	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:29.08347
190	cube 125	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:29.328715
200	cylinder 127	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:29.33273
194	cube 126	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:29.569169
204	cylinder 128	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:29.573682
198	cube 127	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:29.793744
207	cylinder 129	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:29.797953
202	cube 128	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.03624	cube.usd	2025-03-29 14:58:30.023728
208	cylinder 130	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.434948	cylinder.usd	2025-03-29 14:58:30.028477
206	cube 129	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:30.263485
212	cylinder 131	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:58:30.267789
210	cube 130	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.620872	cube.usd	2025-03-29 14:58:30.504251
171	hexagonal prism 93	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:35.432845
179	hexagonal prism 94	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:36.139189
187	hexagonal prism 95	red	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:36.61079
191	hexagonal prism 96	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:36.837545
195	hexagonal prism 97	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:37.06889
199	hexagonal prism 98	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:37.317383
211	hexagonal prism 99	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:37.55919
1452	cylinder 449	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:43.616425
217	pentagonal prism 146	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:28.135391
221	pentagonal prism 147	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:28.378934
223	pentagonal prism 148	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:58:28.383825
225	pentagonal prism 149	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:58:28.605746
229	pentagonal prism 150	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:28.834816
231	pentagonal prism 151	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:58:29.075011
233	pentagonal prism 152	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:29.324846
237	pentagonal prism 153	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:29.565417
241	pentagonal prism 154	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:29.790487
245	pentagonal prism 155	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:30.020889
249	pentagonal prism 156	red	{0,0,0}	31.499039	259.86707	923.00006	0	0	36.869892	pentagonal prism.usd	2025-03-29 14:58:30.026156
251	pentagonal prism 157	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:30.26079
253	pentagonal prism 158	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:30.500165
255	pentagonal prism 159	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:30.506493
216	cylinder 132	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:58:30.509553
257	pentagonal prism 160	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:30.726936
214	cube 131	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.620872	cube.usd	2025-03-29 14:58:30.729997
220	cylinder 133	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:30.734093
218	cube 132	pink	{0,0,0}	-205.90038	345.12823	910	0	0	59.34933	cube.usd	2025-03-29 14:58:30.966879
224	cylinder 134	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:30.971069
265	pentagonal prism 162	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:31.202652
222	cube 133	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:31.206489
228	cylinder 135	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:31.211324
226	cube 134	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:58:31.441564
232	cylinder 136	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:31.446305
230	cube 135	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:58:31.681988
236	cylinder 137	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:31.686171
234	cube 136	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:31.902908
240	cylinder 138	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:31.907055
238	cube 137	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:32.141052
244	cylinder 139	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:32.146232
242	cube 138	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:32.385094
248	cylinder 140	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:32.389424
246	cube 139	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:32.612868
252	cylinder 141	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:32.616974
250	cube 140	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:32.859557
256	cylinder 142	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	cylinder.usd	2025-03-29 14:58:32.864454
254	cube 141	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:33.084274
260	cylinder 143	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:33.088445
258	cube 142	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.743565	cube.usd	2025-03-29 14:58:33.31772
264	cylinder 144	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:33.321856
262	cube 143	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:58:33.557863
215	hexagonal prism 100	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:38.022159
219	hexagonal prism 101	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:38.257337
227	hexagonal prism 102	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:38.493363
235	hexagonal prism 103	red	{0,0,0}	31.375294	259.82666	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:38.728568
239	hexagonal prism 104	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:38.955333
243	hexagonal prism 105	red	{0,0,0}	30.514694	260.8514	933	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:39.209635
247	hexagonal prism 106	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:39.682059
259	hexagonal prism 107	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:39.909334
263	hexagonal prism 108	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:40.37302
1645	pentagonal prism 565	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:59:46.458001
273	pentagonal prism 164	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:31.44407
277	pentagonal prism 165	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:31.679407
281	pentagonal prism 166	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:31.900372
283	pentagonal prism 167	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:32.136759
285	pentagonal prism 168	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:32.143831
289	pentagonal prism 169	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:32.380917
293	pentagonal prism 170	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:32.610137
297	pentagonal prism 171	red	{0,0,0}	31.375294	259.82666	934	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:32.614958
301	pentagonal prism 172	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:32.856255
305	pentagonal prism 173	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:33.081537
309	pentagonal prism 174	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:33.315335
313	pentagonal prism 175	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:33.555394
266	cube 144	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.69424	cube.usd	2025-03-29 14:58:33.560305
268	cylinder 145	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:33.563008
317	pentagonal prism 176	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:33.781273
270	cube 145	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.420776	cube.usd	2025-03-29 14:58:33.783624
272	cylinder 146	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:33.787663
274	cube 146	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:34.023036
276	cylinder 147	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:34.028259
278	cube 147	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.420776	cube.usd	2025-03-29 14:58:34.252369
280	cylinder 148	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:34.256359
282	cube 148	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:34.488093
286	cube 149	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.568592	cube.usd	2025-03-29 14:58:34.490264
284	cylinder 149	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:34.492352
290	cube 150	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:58:34.729312
288	cylinder 150	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:34.733552
294	cube 151	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:58:34.965119
292	cylinder 151	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:34.969463
298	cube 152	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:35.206296
296	cylinder 152	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:35.21069
302	cube 153	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:35.430714
300	cylinder 153	green	{0,0,0}	-270.62216	216.69383	924	0	0	33.690063	cylinder.usd	2025-03-29 14:58:35.434803
306	cube 154	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:35.670995
310	cube 155	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:58:35.908323
308	cylinder 155	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:58:35.912957
314	cube 156	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 14:58:36.137123
312	cylinder 156	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:36.141305
318	cube 157	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.34933	cube.usd	2025-03-29 14:58:36.372277
316	cylinder 157	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:36.376785
267	hexagonal prism 109	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:40.618754
271	hexagonal prism 110	red	{0,0,0}	30.514694	260.8514	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:40.867147
275	hexagonal prism 111	red	{0,0,0}	30.51353	260.84146	937.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:41.113052
279	hexagonal prism 112	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:41.341525
287	hexagonal prism 113	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:42.045769
291	hexagonal prism 114	red	{0,0,0}	31.376482	259.8365	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:42.529554
295	hexagonal prism 115	red	{0,0,0}	30.51353	260.84146	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:42.764179
299	hexagonal prism 116	red	{0,0,0}	30.514694	260.8514	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:43.459306
303	hexagonal prism 117	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:43.689259
307	hexagonal prism 118	red	{0,0,0}	31.375294	259.82666	936.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:43.932456
311	hexagonal prism 119	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:44.16083
315	hexagonal prism 120	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:45.106743
1508	cylinder 463	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:46.935509
321	pentagonal prism 178	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:34.249712
325	pentagonal prism 179	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:34.485599
329	pentagonal prism 180	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:34.726322
333	pentagonal prism 181	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:34.960609
337	pentagonal prism 182	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:35.20384
341	pentagonal prism 183	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:35.427993
345	pentagonal prism 184	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:35.667079
349	pentagonal prism 185	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 14:58:35.673105
353	pentagonal prism 186	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:35.90476
355	pentagonal prism 187	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:35.910379
357	pentagonal prism 188	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:36.134483
361	pentagonal prism 189	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:36.369704
365	pentagonal prism 190	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:36.374486
369	pentagonal prism 191	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:36.604679
322	cube 158	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03625	cube.usd	2025-03-29 14:58:36.608539
320	cylinder 158	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:36.613413
323	cube 159	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:36.835451
324	cylinder 159	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:36.839627
326	cube 160	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.620872	cube.usd	2025-03-29 14:58:37.066785
328	cylinder 160	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:37.071036
327	cube 161	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	cube.usd	2025-03-29 14:58:37.314917
332	cylinder 161	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	45	cylinder.usd	2025-03-29 14:58:37.319753
330	cube 162	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:58:37.556615
336	cylinder 162	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:37.561575
334	cube 163	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:37.794137
340	cylinder 163	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:37.799186
338	cube 164	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:58:38.019922
344	cylinder 164	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:38.024481
339	cube 165	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:58:38.255317
348	cylinder 165	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:38.259347
342	cube 166	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:58:38.491227
352	cylinder 166	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:38.495343
346	cube 167	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:38.72636
356	cylinder 167	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:38.731034
350	cube 168	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.620872	cube.usd	2025-03-29 14:58:38.9532
360	cylinder 168	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	36.869896	cylinder.usd	2025-03-29 14:58:38.957417
354	cube 169	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.34933	cube.usd	2025-03-29 14:58:39.206691
364	cylinder 169	green	{0,0,0}	-272.66354	217.54024	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:39.211821
358	cube 170	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:39.44462
362	cube 171	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:39.679637
366	cube 172	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:58:39.906869
370	cube 173	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:40.145787
331	hexagonal prism 121	red	{0,0,0}	31.376482	259.8365	919	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:45.346347
335	hexagonal prism 122	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:45.584184
343	hexagonal prism 123	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:45.810993
347	hexagonal prism 124	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:46.044221
351	hexagonal prism 125	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:46.521691
359	hexagonal prism 126	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:46.782733
363	hexagonal prism 127	red	{0,0,0}	31.376482	259.8365	920	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:47.012862
367	hexagonal prism 128	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:47.253173
371	hexagonal prism 129	red	{0,0,0}	30.514694	260.8514	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:47.480796
1697	pentagonal prism 580	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:49.059642
377	pentagonal prism 193	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:37.064119
381	pentagonal prism 194	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:37.310824
385	pentagonal prism 195	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:58:37.552564
389	pentagonal prism 196	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:37.791751
393	pentagonal prism 197	red	{0,0,0}	32.355774	258.8462	920	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:58:37.796354
397	pentagonal prism 198	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:38.017088
401	pentagonal prism 199	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:38.252917
403	pentagonal prism 200	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:38.488651
405	pentagonal prism 201	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:38.723659
407	pentagonal prism 202	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:38.950739
409	pentagonal prism 203	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:39.203397
413	pentagonal prism 204	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:39.442148
417	pentagonal prism 205	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:39.446774
421	pentagonal prism 206	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:39.675736
372	cylinder 171	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:58:39.684816
376	cylinder 172	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:39.911753
380	cylinder 173	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:40.150418
374	cube 174	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:40.370759
384	cylinder 174	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:40.375365
378	cube 175	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.620872	cube.usd	2025-03-29 14:58:40.616324
388	cylinder 175	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:40.621113
382	cube 176	pink	{0,0,0}	-208.68114	346.48944	915	0	0	59.420776	cube.usd	2025-03-29 14:58:40.864436
392	cylinder 176	green	{0,0,0}	-272.66354	217.54024	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:40.869515
386	cube 177	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:41.11099
396	cylinder 177	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:41.115787
390	cube 178	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:41.339301
400	cylinder 178	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:58:41.343638
394	cube 179	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:58:41.572126
404	cylinder 179	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:41.576343
398	cube 180	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:58:41.808062
408	cylinder 180	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:41.812416
402	cube 181	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:58:42.043732
412	cylinder 181	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:42.04785
406	cube 182	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:58:42.283217
410	cube 183	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.620872	cube.usd	2025-03-29 14:58:42.52745
420	cylinder 183	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:42.531594
414	cube 184	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:42.762018
424	cylinder 184	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:42.766743
418	cube 185	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:42.990956
422	cube 186	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:43.230766
423	cube 187	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:43.457209
375	hexagonal prism 130	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:47.720496
379	hexagonal prism 131	red	{0,0,0}	30.395967	260.81702	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:47.951691
383	hexagonal prism 132	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:48.648502
387	hexagonal prism 133	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:48.888665
391	hexagonal prism 134	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:49.114881
395	hexagonal prism 135	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:49.350364
399	hexagonal prism 136	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:49.592697
411	hexagonal prism 137	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:50.057524
415	hexagonal prism 138	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:50.73375
419	hexagonal prism 139	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:50.969086
429	pentagonal prism 208	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:40.143297
433	pentagonal prism 209	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:40.147876
437	pentagonal prism 210	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:40.368377
441	pentagonal prism 211	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:40.612106
443	pentagonal prism 212	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:40.861996
445	pentagonal prism 213	black	{0,0,0}	-128.94427	520.6986	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:41.108443
449	pentagonal prism 214	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:41.335967
451	pentagonal prism 215	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:41.567969
453	pentagonal prism 216	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:41.574199
457	pentagonal prism 217	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:41.805288
461	pentagonal prism 218	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:41.810173
465	pentagonal prism 219	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:42.041194
467	pentagonal prism 220	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:42.279599
469	pentagonal prism 221	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:42.286297
473	pentagonal prism 222	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:42.523641
477	pentagonal prism 223	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:42.758529
428	cylinder 185	red	{0,0,0}	30.51353	260.84146	924	0	0	37.405357	cylinder.usd	2025-03-29 14:58:42.993045
432	cylinder 186	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:42.995027
436	cylinder 187	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:43.235618
440	cylinder 188	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:43.461357
426	cube 188	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:43.686967
444	cylinder 189	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:43.691554
430	cube 189	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:58:43.930248
448	cylinder 190	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:43.934761
434	cube 190	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:44.15871
452	cylinder 191	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:44.162918
438	cube 191	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:44.392154
442	cube 192	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:44.634418
446	cube 193	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	cube.usd	2025-03-29 14:58:44.636824
460	cylinder 193	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:44.639065
450	cube 194	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.62088	cube.usd	2025-03-29 14:58:44.85856
464	cylinder 194	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:44.862753
454	cube 195	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:58:45.103879
468	cylinder 195	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:45.108904
458	cube 196	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.620872	cube.usd	2025-03-29 14:58:45.344212
472	cylinder 196	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:45.348482
462	cube 197	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:45.58205
476	cylinder 197	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:58:45.586376
466	cube 198	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:45.80893
470	cube 199	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.34933	cube.usd	2025-03-29 14:58:46.042103
474	cube 200	pink	{0,0,0}	-207.6968	346.48944	913.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:46.281842
475	cube 201	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:46.518997
427	hexagonal prism 140	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:51.434709
431	hexagonal prism 141	red	{0,0,0}	30.514694	260.8514	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:51.667341
435	hexagonal prism 142	red	{0,0,0}	31.375294	259.82666	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:51.900843
439	hexagonal prism 143	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:52.370557
447	hexagonal prism 144	red	{0,0,0}	31.376482	259.8365	920	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:52.601462
455	hexagonal prism 145	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:53.081555
459	hexagonal prism 146	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:53.322668
463	hexagonal prism 147	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:58:53.79223
471	hexagonal prism 148	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:54.022055
485	pentagonal prism 225	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:43.227904
489	pentagonal prism 226	red	{0,0,0}	32.357	258.856	929	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:58:43.233189
493	pentagonal prism 227	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:43.454224
497	pentagonal prism 228	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:43.683906
501	pentagonal prism 229	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:43.926441
505	pentagonal prism 230	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:44.156079
509	pentagonal prism 231	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:44.38981
513	pentagonal prism 232	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:44.394254
515	pentagonal prism 233	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:44.632062
517	pentagonal prism 234	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:44.855413
521	pentagonal prism 235	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:44.860764
525	pentagonal prism 236	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:58:45.099712
529	pentagonal prism 237	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:45.341724
480	cylinder 198	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:45.812998
484	cylinder 199	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:46.046179
488	cylinder 200	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:46.286396
492	cylinder 201	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:46.524279
478	cube 202	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	cube.usd	2025-03-29 14:58:46.780649
496	cylinder 202	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:46.784703
482	cube 203	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.62088	cube.usd	2025-03-29 14:58:47.010452
500	cylinder 203	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:58:47.014961
486	cube 204	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	cube.usd	2025-03-29 14:58:47.251116
504	cylinder 204	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:47.255684
490	cube 205	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.743565	cube.usd	2025-03-29 14:58:47.478363
508	cylinder 205	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.434948	cylinder.usd	2025-03-29 14:58:47.483323
494	cube 206	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:47.718182
512	cylinder 206	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:47.722891
498	cube 207	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.620872	cube.usd	2025-03-29 14:58:47.949619
516	cylinder 207	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:58:47.954341
502	cube 208	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:48.176745
506	cube 209	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	cube.usd	2025-03-29 14:58:48.178889
520	cylinder 208	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:48.181093
510	cube 210	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:48.412123
514	cube 211	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:48.646093
528	cylinder 210	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:48.650653
518	cube 212	pink	{0,0,0}	-205.90816	345.1413	940.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:48.886165
522	cube 213	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:49.112783
526	cube 214	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:58:49.348172
530	cube 215	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:58:49.59003
479	hexagonal prism 149	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:54.275844
483	hexagonal prism 150	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:54.50221
487	hexagonal prism 151	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:55.206173
491	hexagonal prism 152	red	{0,0,0}	31.499039	259.86707	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:55.438619
495	hexagonal prism 153	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:55.681114
499	hexagonal prism 154	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:56.14133
503	hexagonal prism 155	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:56.372055
507	hexagonal prism 156	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:57.07794
511	hexagonal prism 157	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:57.316412
519	hexagonal prism 158	red	{0,0,0}	31.376482	259.8365	929	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:58:57.53915
523	hexagonal prism 159	red	{0,0,0}	30.395967	260.81702	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:57.773923
527	hexagonal prism 160	red	{0,0,0}	32.357	258.856	915	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:58.471261
537	pentagonal prism 239	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:45.806541
539	pentagonal prism 240	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:46.038258
541	pentagonal prism 241	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:46.279299
545	pentagonal prism 242	red	{0,0,0}	31.499039	259.86707	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:46.284261
549	pentagonal prism 243	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:46.515173
553	pentagonal prism 244	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:46.777637
555	pentagonal prism 245	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:58:47.00794
557	pentagonal prism 246	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:47.247307
561	pentagonal prism 247	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:47.474907
565	pentagonal prism 248	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:47.715373
567	pentagonal prism 249	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:47.944974
569	pentagonal prism 250	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:48.172826
573	pentagonal prism 251	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:48.408231
577	pentagonal prism 252	red	{0,0,0}	32.357	258.856	929	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:58:48.414236
579	pentagonal prism 253	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:48.641915
581	pentagonal prism 254	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:48.882204
532	cylinder 211	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:48.891543
536	cylinder 212	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:49.117005
540	cylinder 213	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	cylinder.usd	2025-03-29 14:58:49.352397
544	cylinder 214	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:49.595154
534	cube 216	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03625	cube.usd	2025-03-29 14:58:49.816318
548	cylinder 215	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	cylinder.usd	2025-03-29 14:58:49.818418
552	cylinder 216	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:49.820569
538	cube 217	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:50.055102
556	cylinder 217	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:50.060086
542	cube 218	pink	{0,0,0}	-205.90816	345.1413	908.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:50.282654
560	cylinder 218	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:50.28689
546	cube 219	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:50.505907
564	cylinder 219	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:50.511329
550	cube 220	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:50.731446
568	cylinder 220	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:50.735887
554	cube 221	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:50.966927
572	cylinder 221	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:58:50.971624
558	cube 222	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.34933	cube.usd	2025-03-29 14:58:51.201927
562	cube 223	red	{0,0,0}	31.499039	259.86707	932.00006	0	0	37.69424	cube.usd	2025-03-29 14:58:51.204058
576	cylinder 222	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:51.206266
566	cube 224	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:51.4326
580	cylinder 223	green	{0,0,0}	-272.66354	217.54024	924	0	0	18.43495	cylinder.usd	2025-03-29 14:58:51.436809
570	cube 225	pink	{0,0,0}	-207.6968	346.48944	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:51.665106
574	cube 226	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:51.89874
578	cube 227	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:52.132184
582	cube 228	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:58:52.368416
531	hexagonal prism 161	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:58.705132
535	hexagonal prism 162	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:59.877107
543	hexagonal prism 163	red	{0,0,0}	30.514694	260.8514	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:00.345201
547	hexagonal prism 164	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:00.575794
551	hexagonal prism 165	red	{0,0,0}	30.514694	260.8514	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:00.805789
559	hexagonal prism 166	red	{0,0,0}	31.376482	259.8365	924	0	0	37.184704	hexagonal prism.usd	2025-03-29 14:59:01.038753
563	hexagonal prism 167	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:01.280049
571	hexagonal prism 168	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:01.735856
575	hexagonal prism 169	red	{0,0,0}	30.514694	260.8514	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:01.972327
589	pentagonal prism 257	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:49.585845
591	pentagonal prism 258	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:49.813589
593	pentagonal prism 259	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:50.051337
597	pentagonal prism 260	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:50.279728
601	pentagonal prism 261	red	{0,0,0}	32.357	258.856	919	0	0	36.869896	pentagonal prism.usd	2025-03-29 14:58:50.284869
605	pentagonal prism 262	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:50.503282
609	pentagonal prism 263	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:58:50.508886
613	pentagonal prism 264	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:50.728321
617	pentagonal prism 265	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:50.963021
621	pentagonal prism 266	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:51.198088
625	pentagonal prism 267	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:51.42872
627	pentagonal prism 268	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:51.661349
584	cylinder 224	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:51.66977
629	pentagonal prism 269	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:51.896031
588	cylinder 225	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:51.902825
631	pentagonal prism 270	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:52.128021
633	pentagonal prism 271	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:52.134378
592	cylinder 226	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:52.136397
596	cylinder 227	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	cylinder.usd	2025-03-29 14:58:52.372572
586	cube 229	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:52.599396
600	cylinder 228	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:52.603469
590	cube 230	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:52.832984
603	cylinder 229	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:52.837219
594	cube 231	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:53.079434
604	cylinder 230	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:53.083671
598	cube 232	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:53.320065
608	cylinder 231	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:53.325088
602	cube 233	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:53.550107
606	cube 234	red	{0,0,0}	32.357	258.856	920	0	0	37.303947	cube.usd	2025-03-29 14:58:53.552189
610	cube 235	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:58:53.789783
616	cylinder 233	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:53.79448
614	cube 236	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:58:54.019944
620	cylinder 234	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 14:58:54.024106
618	cube 237	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:54.273372
624	cylinder 235	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:54.278293
622	cube 238	pink	{0,0,0}	-205.90816	345.1413	907.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:54.499882
628	cylinder 236	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:54.504576
626	cube 239	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:54.738549
630	cube 240	red	{0,0,0}	32.355774	258.8462	924	0	0	37.303947	cube.usd	2025-03-29 14:58:54.740788
632	cylinder 237	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:54.743047
634	cube 241	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.34933	cube.usd	2025-03-29 14:58:54.962262
636	cylinder 238	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:54.966866
587	hexagonal prism 170	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:02.450914
595	hexagonal prism 171	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:02.678008
599	hexagonal prism 172	red	{0,0,0}	31.376482	259.8365	920	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:59:02.906981
607	hexagonal prism 173	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:03.131527
611	hexagonal prism 174	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:03.357123
615	hexagonal prism 175	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:03.829205
619	hexagonal prism 176	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:04.062292
623	hexagonal prism 177	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:04.295023
635	hexagonal prism 178	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:04.52765
641	pentagonal prism 273	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:52.595616
645	pentagonal prism 274	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:52.830644
649	pentagonal prism 275	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:58:52.835144
653	pentagonal prism 276	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:53.077079
657	pentagonal prism 277	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:53.315617
661	pentagonal prism 278	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:53.547705
665	pentagonal prism 279	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:53.785776
667	pentagonal prism 280	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:54.017189
669	pentagonal prism 281	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:54.270572
671	pentagonal prism 282	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:54.496914
673	pentagonal prism 283	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:54.735634
677	pentagonal prism 284	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:54.959062
638	cube 242	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.303947	cube.usd	2025-03-29 14:58:54.964666
681	pentagonal prism 285	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:55.199963
642	cube 243	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:55.203948
640	cylinder 239	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:58:55.208221
685	pentagonal prism 286	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:55.431817
646	cube 244	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.420776	cube.usd	2025-03-29 14:58:55.436248
644	cylinder 240	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.43495	cylinder.usd	2025-03-29 14:58:55.440818
689	pentagonal prism 287	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:55.674705
650	cube 245	pink	{0,0,0}	-205.90816	345.1413	907.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:55.678481
647	cylinder 241	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:55.683341
654	cube 246	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:55.900293
648	cylinder 242	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:55.904728
658	cube 247	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:56.139013
652	cylinder 243	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:56.143594
662	cube 248	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 14:58:56.369929
666	cube 249	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:58:56.599288
660	cylinder 245	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:56.603639
670	cube 250	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03625	cube.usd	2025-03-29 14:58:56.839274
674	cube 251	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.694237	cube.usd	2025-03-29 14:58:56.841307
664	cylinder 246	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:56.843528
678	cube 252	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:57.075646
668	cylinder 247	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:58:57.080441
682	cube 253	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.62088	cube.usd	2025-03-29 14:58:57.313953
672	cylinder 248	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:57.318529
686	cube 254	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.34933	cube.usd	2025-03-29 14:58:57.536931
676	cylinder 249	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:57.541415
680	cylinder 250	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	cylinder.usd	2025-03-29 14:58:57.776109
684	cylinder 251	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:58.006813
688	cylinder 252	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:58.244284
639	hexagonal prism 179	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:04.996276
643	hexagonal prism 180	red	{0,0,0}	31.499039	259.86707	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:05.234125
651	hexagonal prism 181	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:05.473218
655	hexagonal prism 182	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:05.70999
659	hexagonal prism 183	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:05.963178
663	hexagonal prism 184	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:06.442545
675	hexagonal prism 185	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:07.155949
679	hexagonal prism 186	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:07.864065
683	hexagonal prism 187	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:59:08.100501
687	hexagonal prism 188	red	{0,0,0}	30.514694	260.8514	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:08.343488
697	pentagonal prism 289	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 14:58:55.902495
701	pentagonal prism 290	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:56.134955
705	pentagonal prism 291	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:58:56.367364
709	pentagonal prism 292	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:56.596706
713	pentagonal prism 293	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:56.601556
715	pentagonal prism 294	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:56.835443
717	pentagonal prism 295	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:57.072984
721	pentagonal prism 296	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:57.309948
725	pentagonal prism 297	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:57.533607
727	pentagonal prism 298	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:57.767749
690	cube 255	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:57.771549
729	pentagonal prism 299	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:58.000124
694	cube 256	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:58:58.002505
731	pentagonal prism 300	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:58.004719
733	pentagonal prism 301	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:58.237373
698	cube 257	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.420776	cube.usd	2025-03-29 14:58:58.239965
735	pentagonal prism 302	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:58.242116
737	pentagonal prism 303	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:58.466404
702	cube 258	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:58:58.469006
692	cylinder 253	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:58.473317
739	pentagonal prism 304	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:58.699973
706	cube 259	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:58.703046
696	cylinder 254	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:58.707248
710	cube 260	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:58.939378
700	cylinder 255	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.69424	cylinder.usd	2025-03-29 14:58:58.941461
703	cylinder 256	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:58.943553
714	cube 261	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:58:59.166957
704	cylinder 257	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:58:59.169108
708	cylinder 258	green	{0,0,0}	-270.62216	216.69383	933	0	0	18.434948	cylinder.usd	2025-03-29 14:58:59.171138
718	cube 262	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.34933	cube.usd	2025-03-29 14:58:59.406357
712	cylinder 259	green	{0,0,0}	-272.66354	217.54024	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:59.410532
722	cube 263	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:59.637537
716	cylinder 260	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:59.642182
726	cube 264	pink	{0,0,0}	-205.90816	345.1413	907.00006	0	0	59.34933	cube.usd	2025-03-29 14:58:59.874899
720	cylinder 261	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:59.879226
730	cube 265	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:59:00.110106
724	cylinder 262	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:00.114237
734	cube 266	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.620872	cube.usd	2025-03-29 14:59:00.343099
728	cylinder 263	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	cylinder.usd	2025-03-29 14:59:00.347318
738	cube 267	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:59:00.573534
732	cylinder 264	green	{0,0,0}	-270.62216	216.69383	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:00.578004
742	cube 268	pink	{0,0,0}	-208.68114	346.48944	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:00.803632
736	cylinder 265	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:00.8079
740	cylinder 266	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	36.869896	cylinder.usd	2025-03-29 14:59:01.040788
691	hexagonal prism 189	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:09.515295
695	hexagonal prism 190	red	{0,0,0}	31.499039	259.86707	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:09.753129
699	hexagonal prism 191	red	{0,0,0}	31.375294	259.82666	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:10.460816
707	hexagonal prism 192	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:10.708707
711	hexagonal prism 193	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:10.935041
719	hexagonal prism 194	red	{0,0,0}	31.375294	259.82666	936.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:11.16952
723	hexagonal prism 195	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:11.87336
747	pentagonal prism 307	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:59.402567
749	pentagonal prism 308	red	{0,0,0}	31.499039	259.86707	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:59.408474
753	pentagonal prism 309	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:59.633294
757	pentagonal prism 310	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:59.639859
759	pentagonal prism 311	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:59.871233
761	pentagonal prism 312	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:59:00.10765
765	pentagonal prism 313	red	{0,0,0}	32.357	258.856	920	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:59:00.112174
769	pentagonal prism 314	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:00.339329
773	pentagonal prism 315	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:00.569694
777	pentagonal prism 316	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:00.799356
781	pentagonal prism 317	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:01.034115
746	cube 269	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:01.036714
785	pentagonal prism 318	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:01.275321
750	cube 270	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:59:01.27788
744	cylinder 267	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:59:01.282169
789	pentagonal prism 319	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:01.505177
754	cube 271	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.420776	cube.usd	2025-03-29 14:59:01.50785
791	pentagonal prism 320	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:01.510049
748	cylinder 268	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:01.51212
793	pentagonal prism 321	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:01.729501
758	cube 272	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.620872	cube.usd	2025-03-29 14:59:01.733275
752	cylinder 269	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:01.73803
762	cube 273	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.620872	cube.usd	2025-03-29 14:59:01.970125
756	cylinder 270	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:01.974319
766	cube 274	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:02.205954
760	cylinder 271	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:59:02.210128
770	cube 275	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 14:59:02.448641
764	cylinder 272	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:59:02.453458
774	cube 276	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:59:02.675814
768	cylinder 273	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:59:02.68012
778	cube 277	pink	{0,0,0}	-205.90816	345.1413	936.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:02.904781
772	cylinder 274	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:59:02.909148
782	cube 278	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:03.129439
776	cylinder 275	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:03.133858
786	cube 279	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:03.354944
780	cylinder 276	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:03.359241
790	cube 280	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.534454	cube.usd	2025-03-29 14:59:03.593843
784	cylinder 277	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:03.597941
794	cube 281	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:03.827164
787	cylinder 278	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:03.831199
788	cylinder 279	green	{0,0,0}	-270.62216	216.69383	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:04.064371
792	cylinder 280	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 14:59:04.297064
743	hexagonal prism 196	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:12.592971
751	hexagonal prism 197	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:13.060046
755	hexagonal prism 198	red	{0,0,0}	31.375294	259.82666	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:13.28517
763	hexagonal prism 199	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:13.508201
767	hexagonal prism 200	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:13.733705
771	hexagonal prism 201	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:14.19939
775	hexagonal prism 202	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:14.451238
779	hexagonal prism 203	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:14.701651
783	hexagonal prism 204	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:15.157445
801	pentagonal prism 324	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:02.208087
805	pentagonal prism 325	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:02.444181
809	pentagonal prism 326	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:59:02.673368
813	pentagonal prism 327	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:02.90084
817	pentagonal prism 328	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:03.126816
821	pentagonal prism 329	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:03.351747
823	pentagonal prism 330	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:03.589985
825	pentagonal prism 331	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:03.595934
829	pentagonal prism 332	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:03.823017
831	pentagonal prism 333	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:04.056392
798	cube 282	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:59:04.060264
833	pentagonal prism 334	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:04.290319
802	cube 283	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 14:59:04.292968
837	pentagonal prism 335	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:04.521618
806	cube 284	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:59:04.525529
796	cylinder 281	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:04.529783
841	pentagonal prism 336	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:04.754632
810	cube 285	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:04.757046
845	pentagonal prism 337	red	{0,0,0}	32.357	258.856	929	0	0	36.869896	pentagonal prism.usd	2025-03-29 14:59:04.759191
800	cylinder 282	green	{0,0,0}	-270.62216	216.69383	924	0	0	45	cylinder.usd	2025-03-29 14:59:04.761285
814	cube 286	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:04.993847
804	cylinder 283	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:04.998313
818	cube 287	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03624	cube.usd	2025-03-29 14:59:05.231826
808	cylinder 284	green	{0,0,0}	-272.66354	217.54024	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:05.236205
822	cube 288	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:05.470794
812	cylinder 285	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:05.475422
826	cube 289	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03624	cube.usd	2025-03-29 14:59:05.707796
816	cylinder 286	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:05.712132
830	cube 290	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:05.960404
834	cube 291	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.03625	cube.usd	2025-03-29 14:59:06.202792
838	cube 292	red	{0,0,0}	31.499039	259.86707	928.00006	0	0	37.405357	cube.usd	2025-03-29 14:59:06.205635
824	cylinder 288	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:06.207918
842	cube 293	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 14:59:06.44017
828	cylinder 289	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:06.444714
846	cube 294	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:06.686687
832	cylinder 290	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:06.691824
836	cylinder 291	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:59:06.929768
840	cylinder 292	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:06.932277
844	cylinder 293	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:07.158423
848	cylinder 294	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	33.690067	cylinder.usd	2025-03-29 14:59:07.401853
799	hexagonal prism 205	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:15.630573
803	hexagonal prism 206	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	36.869896	hexagonal prism.usd	2025-03-29 14:59:15.869098
807	hexagonal prism 207	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:16.102333
811	hexagonal prism 208	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:16.57282
815	hexagonal prism 209	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:16.803549
819	hexagonal prism 210	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:17.274993
827	hexagonal prism 211	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:18.062487
835	hexagonal prism 212	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:18.306883
839	hexagonal prism 213	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:18.805158
843	hexagonal prism 214	red	{0,0,0}	31.499039	259.86707	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:19.045254
847	hexagonal prism 215	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:19.282353
853	pentagonal prism 339	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:05.227903
857	pentagonal prism 340	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:05.46733
861	pentagonal prism 341	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:05.70379
865	pentagonal prism 342	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:05.95637
869	pentagonal prism 343	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:06.198603
873	pentagonal prism 344	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:06.435931
877	pentagonal prism 345	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:06.68379
850	cube 295	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.405357	cube.usd	2025-03-29 14:59:06.689507
881	pentagonal prism 346	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:06.924734
854	cube 296	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03624	cube.usd	2025-03-29 14:59:06.927383
885	pentagonal prism 347	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:07.15071
858	cube 297	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:07.153596
887	pentagonal prism 348	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:07.393769
862	cube 298	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:59:07.397649
889	pentagonal prism 349	red	{0,0,0}	32.357	258.856	929	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:59:07.399774
891	pentagonal prism 350	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:07.622517
866	cube 299	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:07.626514
893	pentagonal prism 351	red	{0,0,0}	31.497837	259.85715	932.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:59:07.628675
852	cylinder 295	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:07.630708
897	pentagonal prism 352	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:59:07.859478
870	cube 300	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:07.862055
856	cylinder 296	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:07.86653
901	pentagonal prism 353	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:08.09556
874	cube 301	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:08.098059
860	cylinder 297	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:08.102726
878	cube 302	pink	{0,0,0}	-207.6968	346.48944	913.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:08.341248
864	cylinder 298	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:08.345675
882	cube 303	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:08.580556
868	cylinder 299	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:08.584866
883	cube 304	pink	{0,0,0}	-207.6968	346.48944	912.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:08.812676
886	cube 305	red	{0,0,0}	31.499039	259.86707	930.00006	0	0	37.69424	cube.usd	2025-03-29 14:59:08.814985
890	cube 306	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.620872	cube.usd	2025-03-29 14:59:09.051374
894	cube 307	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	cube.usd	2025-03-29 14:59:09.054286
876	cylinder 301	green	{0,0,0}	-270.62216	216.69383	924	0	0	38.65981	cylinder.usd	2025-03-29 14:59:09.056787
898	cube 308	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:09.288953
880	cylinder 302	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:09.294729
884	cylinder 303	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:09.517428
888	cylinder 304	green	{0,0,0}	-272.66354	217.54024	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:09.755586
892	cylinder 305	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:09.990064
896	cylinder 306	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:10.223375
900	cylinder 307	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:10.463015
851	hexagonal prism 216	red	{0,0,0}	31.376482	259.8365	924	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:59:19.507679
855	hexagonal prism 217	red	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:19.753673
859	hexagonal prism 218	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:19.988096
863	hexagonal prism 219	red	{0,0,0}	31.375294	259.82666	934	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:20.225443
867	hexagonal prism 220	red	{0,0,0}	30.514694	260.8514	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:20.697362
871	hexagonal prism 221	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:20.93387
875	hexagonal prism 222	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:21.169519
879	hexagonal prism 223	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:21.405795
895	hexagonal prism 224	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:21.650798
899	hexagonal prism 225	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:21.879176
909	pentagonal prism 355	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:08.576591
913	pentagonal prism 356	red	{0,0,0}	32.357	258.856	920	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:59:08.582789
915	pentagonal prism 357	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:08.809145
917	pentagonal prism 358	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:09.048251
921	pentagonal prism 359	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:09.285096
925	pentagonal prism 360	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:09.29238
929	pentagonal prism 361	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:09.5104
902	cube 309	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:09.513121
933	pentagonal prism 362	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:09.748165
906	cube 310	pink	{0,0,0}	-208.68114	346.48944	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:09.75069
937	pentagonal prism 363	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:09.982065
910	cube 311	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:09.985101
941	pentagonal prism 364	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:09.987749
945	pentagonal prism 365	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:10.21491
914	cube 312	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:10.219005
949	pentagonal prism 366	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:10.221237
953	pentagonal prism 367	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:10.454057
918	cube 313	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:10.45825
922	cube 314	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:10.706218
904	cylinder 308	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:59:10.711323
926	cube 315	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.620872	cube.usd	2025-03-29 14:59:10.932905
908	cylinder 309	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:10.93709
930	cube 316	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.743565	cube.usd	2025-03-29 14:59:11.167409
912	cylinder 310	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:11.171792
934	cube 317	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:59:11.399432
916	cylinder 311	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:11.403729
938	cube 318	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:11.63744
920	cylinder 312	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:59:11.642304
942	cube 319	pink	{0,0,0}	-206.88867	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:11.871001
924	cylinder 313	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:11.875648
946	cube 320	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:12.105991
928	cylinder 314	green	{0,0,0}	-272.65317	217.53194	934	0	0	33.690063	cylinder.usd	2025-03-29 14:59:12.110607
950	cube 321	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:12.344323
954	cube 322	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:12.590518
936	cylinder 316	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 14:59:12.595474
940	cylinder 317	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:12.820867
944	cylinder 318	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:13.062641
948	cylinder 319	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:13.287232
952	cylinder 320	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	36.869896	cylinder.usd	2025-03-29 14:59:13.510585
903	hexagonal prism 226	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:22.362606
907	hexagonal prism 227	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:22.591685
911	hexagonal prism 228	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:23.061014
919	hexagonal prism 229	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:23.294856
923	hexagonal prism 230	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:23.75726
927	hexagonal prism 231	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:23.993317
931	hexagonal prism 232	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:25.631901
935	hexagonal prism 233	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:25.867748
939	hexagonal prism 234	red	{0,0,0}	32.357	258.856	934	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:26.814984
943	hexagonal prism 235	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:27.048838
947	hexagonal prism 236	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:27.998369
951	hexagonal prism 237	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:28.235582
961	pentagonal prism 369	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal prism.usd	2025-03-29 14:59:10.930161
965	pentagonal prism 370	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:11.163456
969	pentagonal prism 371	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:11.39496
973	pentagonal prism 372	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:11.401614
977	pentagonal prism 373	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:11.634926
981	pentagonal prism 374	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:11.64007
983	pentagonal prism 375	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:11.867117
985	pentagonal prism 376	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:12.103142
989	pentagonal prism 377	red	{0,0,0}	31.497837	259.85715	931.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:12.10821
993	pentagonal prism 378	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:12.340216
997	pentagonal prism 379	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:12.346629
1001	pentagonal prism 380	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:12.586338
1005	pentagonal prism 381	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:12.81378
958	cube 323	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:12.816464
962	cube 324	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:13.057836
966	cube 325	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:59:13.283138
970	cube 326	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:13.505807
974	cube 327	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:59:13.731524
956	cylinder 321	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:13.735852
978	cube 328	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:59:13.96774
960	cylinder 322	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:59:13.972052
982	cube 329	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.620872	cube.usd	2025-03-29 14:59:14.197166
963	cylinder 323	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:14.201581
986	cube 330	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:14.44906
964	cylinder 324	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:14.453407
990	cube 331	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03624	cube.usd	2025-03-29 14:59:14.699452
968	cylinder 325	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:14.703767
994	cube 332	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:14.929909
972	cylinder 326	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:59:14.932172
976	cylinder 327	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:59:14.934276
998	cube 333	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:15.155195
980	cylinder 328	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:15.159523
1002	cube 334	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:15.391707
984	cylinder 329	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:15.396127
1006	cube 335	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:15.627968
991	cylinder 331	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:15.87112
992	cylinder 332	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:16.10432
995	cylinder 333	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:59:16.336146
996	cylinder 334	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:59:16.574867
1000	cylinder 335	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	36.869896	cylinder.usd	2025-03-29 14:59:16.805598
1004	cylinder 336	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:17.041323
955	hexagonal prism 238	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:28.468776
959	hexagonal prism 239	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:28.928519
967	hexagonal prism 240	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:29.164913
971	hexagonal prism 241	red	{0,0,0}	32.355774	258.8462	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:29.403008
975	hexagonal prism 242	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:29.630469
979	hexagonal prism 243	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:29.878872
987	hexagonal prism 244	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:30.12702
999	hexagonal prism 245	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:30.363928
1003	hexagonal prism 246	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:59:30.602005
1007	hexagonal prism 247	red	{0,0,0}	32.357	258.856	919	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:30.833039
1011	pentagonal prism 383	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:13.053722
1013	pentagonal prism 384	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:13.280226
1017	pentagonal prism 385	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:59:13.503317
1021	pentagonal prism 386	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:13.727415
1023	pentagonal prism 387	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:13.964029
1025	pentagonal prism 388	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:13.969909
1027	pentagonal prism 389	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:14.193064
1029	pentagonal prism 390	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:14.446581
1033	pentagonal prism 391	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:14.695501
1035	pentagonal prism 392	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:14.927071
1037	pentagonal prism 393	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:15.151543
1041	pentagonal prism 394	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:15.387829
1045	pentagonal prism 395	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:15.393783
1049	pentagonal prism 396	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:15.624505
1051	pentagonal prism 397	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:59:15.862839
1010	cube 336	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:15.866814
1053	pentagonal prism 398	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:16.096239
1014	cube 337	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:59:16.100174
1057	pentagonal prism 399	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:16.328306
1018	cube 338	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:16.331609
1022	cube 339	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.303947	cube.usd	2025-03-29 14:59:16.333984
1026	cube 340	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:59:16.570715
1030	cube 341	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:16.801349
1034	cube 342	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:59:17.037025
1038	cube 343	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	cube.usd	2025-03-29 14:59:17.039321
1008	cylinder 337	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:17.277137
1046	cube 345	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:17.569603
1012	cylinder 338	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:17.57592
1050	cube 346	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:17.825791
1016	cylinder 339	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:17.829957
1054	cube 347	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:18.060326
1020	cylinder 340	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:18.064579
1058	cube 348	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:18.304669
1024	cylinder 341	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:18.309087
1028	cylinder 342	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:18.569329
1032	cylinder 343	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:18.807193
1036	cylinder 344	green	{0,0,0}	-272.66354	217.54024	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:19.047354
1040	cylinder 345	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:19.284749
1044	cylinder 346	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:19.509761
1048	cylinder 347	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:19.75569
1052	cylinder 348	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:59:19.990196
1056	cylinder 349	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:20.227588
1060	cylinder 350	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:20.459716
1015	hexagonal prism 248	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:31.067504
1019	hexagonal prism 249	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:31.790777
1031	hexagonal prism 250	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:32.018729
1039	hexagonal prism 251	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:33.191238
1043	hexagonal prism 252	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:33.418096
1047	hexagonal prism 253	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:33.655161
1055	hexagonal prism 254	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:34.37063
1059	hexagonal prism 255	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:34.636557
1079	hexagonal prism 258	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:36.275156
1083	hexagonal prism 259	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:37.210351
1087	hexagonal prism 260	red	{0,0,0}	30.514694	260.8514	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:37.911515
1091	hexagonal prism 261	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:38.143843
1095	hexagonal prism 262	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:38.845048
1099	hexagonal prism 263	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:39.084977
1103	hexagonal prism 264	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:39.32913
1111	hexagonal prism 265	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:39.559997
1065	pentagonal prism 401	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:16.797329
1067	pentagonal prism 402	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:17.033308
1069	pentagonal prism 403	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:17.269193
1073	pentagonal prism 404	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 14:59:17.564466
1075	pentagonal prism 405	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:17.572359
1077	pentagonal prism 406	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:17.823441
1081	pentagonal prism 407	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.694237	pentagonal prism.usd	2025-03-29 14:59:17.827938
1085	pentagonal prism 408	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:18.05775
1089	pentagonal prism 409	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:18.300508
1093	pentagonal prism 410	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:18.561233
1062	cube 349	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:18.565024
1097	pentagonal prism 411	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:18.567265
1101	pentagonal prism 412	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:18.799966
1066	cube 350	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.743565	cube.usd	2025-03-29 14:59:18.802922
1105	pentagonal prism 413	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:19.040565
1070	cube 351	pink	{0,0,0}	-208.68114	346.48944	921.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:19.042832
1107	pentagonal prism 414	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:19.276252
1074	cube 352	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:59:19.280177
1109	pentagonal prism 415	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:19.502449
1078	cube 353	pink	{0,0,0}	-206.88867	345.1413	907.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:19.505623
1082	cube 354	pink	{0,0,0}	-205.90816	345.1413	908.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:19.751622
1086	cube 355	pink	{0,0,0}	-206.88084	345.12823	932.00006	0	0	59.620872	cube.usd	2025-03-29 14:59:19.985739
1090	cube 356	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.620872	cube.usd	2025-03-29 14:59:20.223136
1094	cube 357	pink	{0,0,0}	-206.88867	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:20.455457
1098	cube 358	pink	{0,0,0}	-207.6968	346.48944	931.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:20.695217
1064	cylinder 351	green	{0,0,0}	-272.66354	217.54024	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:20.699656
1102	cube 359	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:20.931354
1068	cylinder 352	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:20.936218
1106	cube 360	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 14:59:21.167233
1072	cylinder 353	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:21.171593
1110	cube 361	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:59:21.403732
1076	cylinder 354	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:21.407874
1080	cylinder 355	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:21.653124
1084	cylinder 356	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:21.881494
1088	cylinder 357	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:22.125765
1092	cylinder 358	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:22.364895
1096	cylinder 359	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:22.593701
1100	cylinder 360	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:22.828914
1104	cylinder 361	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:23.06306
1108	cylinder 362	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:23.296893
1112	cylinder 363	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:23.534778
1063	hexagonal prism 256	red	{0,0,0}	32.357	258.856	924	0	0	36.869896	hexagonal prism.usd	2025-03-29 14:59:34.870787
1071	hexagonal prism 257	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:35.809715
1119	hexagonal prism 266	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:40.046336
1123	hexagonal prism 267	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:40.284204
1127	hexagonal prism 268	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:40.744194
1131	hexagonal prism 269	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:40.978745
1135	hexagonal prism 270	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:41.680971
1139	hexagonal prism 271	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:42.143989
1147	hexagonal prism 272	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:42.394361
1151	hexagonal prism 273	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:42.633919
1155	hexagonal prism 274	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:42.866516
1159	hexagonal prism 275	red	{0,0,0}	31.499039	259.86707	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:43.100318
1163	hexagonal prism 276	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:43.349381
1117	pentagonal prism 418	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:20.218951
1121	pentagonal prism 419	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:20.452669
1125	pentagonal prism 420	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:20.457547
1129	pentagonal prism 421	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:20.691195
1133	pentagonal prism 422	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:20.927371
1137	pentagonal prism 423	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:21.16328
1141	pentagonal prism 424	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal prism.usd	2025-03-29 14:59:21.399667
1145	pentagonal prism 425	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:21.644654
1114	cube 362	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:21.648546
1149	pentagonal prism 426	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:21.874616
1118	cube 363	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:21.877146
1153	pentagonal prism 427	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:22.118484
1122	cube 364	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:22.121544
1126	cube 365	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	cube.usd	2025-03-29 14:59:22.123714
1157	pentagonal prism 428	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:22.356379
1130	cube 366	pink	{0,0,0}	-207.6968	346.48944	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:22.360515
1161	pentagonal prism 429	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:22.585738
1134	cube 367	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:59:22.589625
1165	pentagonal prism 430	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:22.820733
1138	cube 368	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:22.824598
1142	cube 369	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:23.058717
1143	cube 370	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.743565	cube.usd	2025-03-29 14:59:23.292677
1146	cube 371	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 14:59:23.52985
1150	cube 372	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:23.754974
1116	cylinder 364	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:23.759363
1154	cube 373	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:23.991208
1120	cylinder 365	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:23.995381
1158	cube 374	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:24.224513
1124	cylinder 366	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:24.228675
1162	cube 375	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:24.457378
1166	cube 376	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	cube.usd	2025-03-29 14:59:24.459424
1128	cylinder 367	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:59:24.461408
1132	cylinder 368	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:24.696396
1136	cylinder 369	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:24.930487
1140	cylinder 370	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:25.169736
1144	cylinder 371	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:25.400688
1148	cylinder 372	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:59:25.634074
1156	cylinder 374	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:26.109559
1160	cylinder 375	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:26.346551
1164	cylinder 376	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:26.584687
1171	hexagonal prism 277	red	{0,0,0}	30.514694	260.8514	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:43.614361
1175	hexagonal prism 278	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:44.08072
1179	hexagonal prism 279	red	{0,0,0}	32.357	258.856	933	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:44.32
1183	hexagonal prism 280	red	{0,0,0}	32.355774	258.8462	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:45.016649
1191	hexagonal prism 281	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:45.262539
1195	hexagonal prism 282	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:59:46.231609
1199	hexagonal prism 283	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:46.70504
1203	hexagonal prism 284	red	{0,0,0}	31.376482	259.8365	934	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:59:47.184326
1207	hexagonal prism 285	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:47.421351
1215	hexagonal prism 286	red	{0,0,0}	31.499039	259.86707	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:59:47.647332
1219	hexagonal prism 287	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:48.143504
1169	pentagonal prism 432	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:23.056225
1173	pentagonal prism 433	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:23.288988
1177	pentagonal prism 434	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:23.527324
1181	pentagonal prism 435	red	{0,0,0}	32.355774	258.8462	929	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:59:23.532127
1185	pentagonal prism 436	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:59:23.752262
1189	pentagonal prism 437	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:59:23.987456
1193	pentagonal prism 438	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:24.220598
1197	pentagonal prism 439	red	{0,0,0}	31.497837	259.85715	913.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:24.226614
1201	pentagonal prism 440	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:24.454857
1205	pentagonal prism 441	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:24.689231
1170	cube 377	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:24.6922
1209	pentagonal prism 442	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:24.694297
1213	pentagonal prism 443	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:24.923612
1174	cube 378	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.620872	cube.usd	2025-03-29 14:59:24.926134
1217	pentagonal prism 444	red	{0,0,0}	32.357	258.856	924	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:59:24.928269
1178	cube 379	pink	{0,0,0}	-207.6968	346.48944	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:25.165505
1182	cube 380	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.620872	cube.usd	2025-03-29 14:59:25.396396
1186	cube 381	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:25.62974
1187	cube 382	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	cube.usd	2025-03-29 14:59:25.864997
1190	cube 383	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:26.105203
1194	cube 384	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:59:26.34228
1198	cube 385	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:26.579964
1202	cube 386	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:59:26.812908
1168	cylinder 377	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:26.817325
1206	cube 387	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:27.0464
1172	cylinder 378	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:27.051062
1210	cube 388	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:27.284335
1176	cylinder 379	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:27.289121
1211	cube 389	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:27.529746
1180	cylinder 380	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:27.534062
1214	cube 390	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:59:27.766045
1184	cylinder 381	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:27.770464
1218	cube 391	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:27.996294
1188	cylinder 382	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	21.801407	cylinder.usd	2025-03-29 14:59:28.000541
1192	cylinder 383	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:28.237714
1196	cylinder 384	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:28.471128
1200	cylinder 385	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:28.704109
1208	cylinder 387	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:29.166971
1212	cylinder 388	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:29.405347
1216	cylinder 389	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:29.632536
1223	hexagonal prism 288	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:48.606049
1227	hexagonal prism 289	red	{0,0,0}	30.514694	260.8514	937.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:59:48.83656
1235	hexagonal prism 290	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:59:49.064414
1239	hexagonal prism 291	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.746803	hexagonal prism.usd	2025-03-29 14:59:49.557413
1243	hexagonal prism 292	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:55:20.036512
1247	hexagonal prism 293	red	{0,0,0}	31.376482	259.8365	934	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:55:20.27086
1251	hexagonal prism 294	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:20.506162
1255	hexagonal prism 295	red	{0,0,0}	30.395967	260.81702	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:20.751411
1259	hexagonal prism 296	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:55:20.985093
1263	hexagonal prism 297	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:21.222926
1267	hexagonal prism 298	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:21.451755
1271	hexagonal prism 299	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:21.697
1225	pentagonal prism 446	red	{0,0,0}	31.499039	259.86707	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:25.167679
1229	pentagonal prism 447	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:59:25.392858
1231	pentagonal prism 448	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:25.398507
1233	pentagonal prism 449	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:59:25.626007
1237	pentagonal prism 450	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:25.860775
1241	pentagonal prism 451	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:26.101096
1245	pentagonal prism 452	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:26.107436
1249	pentagonal prism 453	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:26.339765
1253	pentagonal prism 454	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:26.344392
1257	pentagonal prism 455	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:26.576034
1261	pentagonal prism 456	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:26.582267
1265	pentagonal prism 457	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:26.80915
1269	pentagonal prism 458	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:27.043804
1222	cube 392	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:28.233318
1226	cube 393	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:28.46645
1230	cube 394	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:28.699643
1234	cube 395	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.743565	cube.usd	2025-03-29 14:59:28.926358
1238	cube 396	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:29.162809
1242	cube 397	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:29.400596
1246	cube 398	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:29.628412
1250	cube 399	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:59:29.876656
1220	cylinder 390	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:29.881059
1254	cube 400	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:30.123501
1224	cylinder 391	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:30.129845
1258	cube 401	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:30.361692
1228	cylinder 392	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:59:30.365934
1262	cube 402	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 14:59:30.599722
1232	cylinder 393	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:30.604304
1266	cube 403	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.34933	cube.usd	2025-03-29 14:59:30.830969
1236	cylinder 394	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:30.835254
1270	cube 404	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:59:31.06528
1244	cylinder 396	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:31.315571
1248	cylinder 397	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:31.551784
1252	cylinder 398	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:31.793088
1256	cylinder 399	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:32.020922
1260	cylinder 400	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:32.256164
1264	cylinder 401	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:32.48657
1268	cylinder 402	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.874985	cylinder.usd	2025-03-29 14:59:32.722746
1272	cylinder 403	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:59:32.724856
1275	hexagonal prism 300	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:21.917868
1279	hexagonal prism 301	red	{0,0,0}	31.375294	259.82666	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:22.148558
1283	hexagonal prism 302	red	{0,0,0}	31.375294	259.82666	938	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:22.382218
1287	hexagonal prism 303	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:22.605228
1291	hexagonal prism 304	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:22.837708
1295	hexagonal prism 305	red	{0,0,0}	31.375294	259.82666	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:23.079551
1303	hexagonal prism 306	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:23.524247
1315	hexagonal prism 307	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:24.220974
1319	hexagonal prism 308	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:24.458353
1323	hexagonal prism 309	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:24.684388
1277	pentagonal prism 460	red	{0,0,0}	31.499039	259.86707	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:27.28687
1281	pentagonal prism 461	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:27.525995
1285	pentagonal prism 462	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:27.53194
1289	pentagonal prism 463	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:59:27.762078
1293	pentagonal prism 464	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:27.768365
1297	pentagonal prism 465	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:27.993932
1299	pentagonal prism 466	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:28.229365
1301	pentagonal prism 467	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:28.463784
1305	pentagonal prism 468	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:28.695502
1307	pentagonal prism 469	red	{0,0,0}	31.499039	259.86707	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:28.701939
1309	pentagonal prism 470	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:28.923782
1311	pentagonal prism 471	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal prism.usd	2025-03-29 14:59:29.158843
1313	pentagonal prism 472	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:29.396328
1317	pentagonal prism 473	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:29.624622
1321	pentagonal prism 474	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:29.872556
1325	pentagonal prism 475	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:30.11772
1274	cube 405	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:59:31.311375
1278	cube 406	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:31.547676
1282	cube 407	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	cube.usd	2025-03-29 14:59:31.549779
1286	cube 408	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:31.788617
1290	cube 409	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:32.016691
1294	cube 410	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:59:32.251514
1298	cube 411	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:32.482414
1302	cube 412	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:32.720333
1306	cube 413	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.620872	cube.usd	2025-03-29 14:59:32.956702
1310	cube 414	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:59:33.189023
1280	cylinder 405	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:33.193553
1314	cube 415	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:33.415957
1284	cylinder 406	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:59:33.420453
1318	cube 416	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:59:33.652935
1288	cylinder 407	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:33.657557
1322	cube 417	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:59:33.88417
1292	cylinder 408	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:59:33.88875
1296	cylinder 409	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:59:34.130338
1300	cylinder 410	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:34.372645
1304	cylinder 411	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:34.639703
1308	cylinder 412	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:34.873008
1312	cylinder 413	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:35.106624
1316	cylinder 414	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:35.346911
1320	cylinder 415	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:35.573686
1324	cylinder 416	green	{0,0,0}	-270.62216	216.69383	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:35.812334
1366	cube 428	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:36.035285
1328	cylinder 417	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:36.039469
1370	cube 429	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:36.272973
1332	cylinder 418	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:36.277413
1331	hexagonal prism 310	red	{0,0,0}	30.514694	260.8514	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:25.142222
1374	cube 430	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:59:36.515507
1336	cylinder 419	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:59:36.519671
1335	hexagonal prism 311	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:25.376526
1378	cube 431	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:36.741586
1340	cylinder 420	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:59:36.745969
1339	hexagonal prism 312	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:25.609999
1344	cylinder 421	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:36.979991
1348	cylinder 422	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:37.212556
1352	cylinder 423	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:37.443161
1356	cylinder 424	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:37.677961
1360	cylinder 425	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:37.913979
1347	hexagonal prism 313	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:26.070887
1364	cylinder 426	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:59:38.145902
1368	cylinder 427	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:38.384894
1351	hexagonal prism 314	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:26.290273
1372	cylinder 428	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:38.615999
1376	cylinder 429	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:38.847194
1355	hexagonal prism 315	orange	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:26.52383
1359	hexagonal prism 316	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:26.759093
1363	hexagonal prism 317	red	{0,0,0}	30.514694	260.8514	934	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:55:26.988868
1367	hexagonal prism 318	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:27.223082
1371	hexagonal prism 319	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:27.455198
1375	hexagonal prism 320	red	{0,0,0}	31.375294	259.82666	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:27.676688
1329	pentagonal prism 477	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:30.595756
1333	pentagonal prism 478	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:30.827127
1337	pentagonal prism 479	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:31.061194
1341	pentagonal prism 480	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:31.308121
1343	pentagonal prism 481	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:31.313536
1345	pentagonal prism 482	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal prism.usd	2025-03-29 14:59:31.545144
1349	pentagonal prism 483	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:31.78431
1353	pentagonal prism 484	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:32.014321
1357	pentagonal prism 485	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:32.247339
1361	pentagonal prism 486	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:32.253822
1365	pentagonal prism 487	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:32.478182
1369	pentagonal prism 488	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:32.484534
1373	pentagonal prism 489	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:32.717638
1377	pentagonal prism 490	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:32.952668
1326	cube 418	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.568592	cube.usd	2025-03-29 14:59:33.886341
1330	cube 419	pink	{0,0,0}	-206.88867	345.1413	908.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:34.125754
1334	cube 420	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	cube.usd	2025-03-29 14:59:34.128127
1338	cube 421	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:34.368481
1342	cube 422	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:34.633536
1346	cube 423	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:34.868548
1350	cube 424	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.620872	cube.usd	2025-03-29 14:59:35.102204
1354	cube 425	pink	{0,0,0}	-207.6968	346.48944	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:35.342438
1358	cube 426	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:35.569466
1362	cube 427	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:35.807459
1379	hexagonal prism 321	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:27.90647
1382	cube 432	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:59:36.975709
1383	hexagonal prism 322	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:28.14167
1386	cube 433	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:59:37.20819
1390	cube 434	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:37.438452
1394	cube 435	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.620872	cube.usd	2025-03-29 14:59:37.673555
1391	hexagonal prism 323	red	{0,0,0}	31.375294	259.82666	940.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:28.606592
1398	cube 436	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	cube.usd	2025-03-29 14:59:37.675856
1395	hexagonal prism 324	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:28.842197
1402	cube 437	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.743565	cube.usd	2025-03-29 14:59:37.909224
1406	cube 438	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.743565	cube.usd	2025-03-29 14:59:38.141717
1403	hexagonal prism 325	orange	{0,0,0}	30.394815	260.80713	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:29.310588
1410	cube 439	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:38.380353
1407	hexagonal prism 326	red	{0,0,0}	31.376482	259.8365	924	0	0	37.476177	hexagonal prism.usd	2025-03-29 14:55:29.540358
1414	cube 440	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.743565	cube.usd	2025-03-29 14:59:38.611332
1411	hexagonal prism 327	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:29.758507
1418	cube 441	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.620872	cube.usd	2025-03-29 14:59:38.842924
1422	cube 442	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:59:39.082741
1380	cylinder 430	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:39.087101
1419	hexagonal prism 328	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:30.230562
1426	cube 443	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:39.326892
1423	hexagonal prism 329	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:55:30.459344
1384	cylinder 431	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:59:39.331952
1430	cube 444	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:39.55752
1388	cylinder 432	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:39.562435
1431	hexagonal prism 330	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:55:30.930104
1385	pentagonal prism 492	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:33.184948
1387	pentagonal prism 493	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:33.412465
1389	pentagonal prism 494	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:33.649017
1393	pentagonal prism 495	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:59:33.880424
1397	pentagonal prism 496	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:59:34.123226
1401	pentagonal prism 497	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:59:34.364997
1405	pentagonal prism 498	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:34.630156
1409	pentagonal prism 499	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:34.864534
1413	pentagonal prism 500	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:35.099609
1415	pentagonal prism 501	red	{0,0,0}	32.357	258.856	924	0	0	37.234837	pentagonal prism.usd	2025-03-29 14:59:35.104512
1417	pentagonal prism 502	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:35.339931
1421	pentagonal prism 503	red	{0,0,0}	31.499039	259.86707	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:35.344718
1425	pentagonal prism 504	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:35.566743
1427	pentagonal prism 505	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:35.571568
1429	pentagonal prism 506	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:35.803482
1392	cylinder 433	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:39.796568
1396	cylinder 434	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:40.048493
1399	cylinder 435	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:59:40.286711
1400	cylinder 436	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:59:40.516607
1404	cylinder 437	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:40.746195
1408	cylinder 438	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:40.980788
1412	cylinder 439	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:41.213145
1416	cylinder 440	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:41.454802
1420	cylinder 441	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:41.683215
1424	cylinder 442	green	{0,0,0}	-272.66354	217.54024	920	0	0	33.690063	cylinder.usd	2025-03-29 14:59:41.913639
1428	cylinder 443	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:42.146163
1435	hexagonal prism 331	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:55:31.162046
1439	hexagonal prism 332	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:31.399501
1443	hexagonal prism 333	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:31.631441
1447	hexagonal prism 334	red	{0,0,0}	31.375294	259.82666	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:31.860486
1455	hexagonal prism 335	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:32.343582
1459	hexagonal prism 336	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:32.580927
1463	hexagonal prism 337	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:32.81212
1467	hexagonal prism 338	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:55:33.03944
1471	hexagonal prism 339	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:33.265707
1475	hexagonal prism 340	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:33.488095
1479	hexagonal prism 341	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:33.722457
1483	hexagonal prism 342	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:33.944256
1437	pentagonal prism 508	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:36.037456
1441	pentagonal prism 509	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:59:36.26888
1445	pentagonal prism 510	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:36.511967
1449	pentagonal prism 511	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 14:59:36.51761
1451	pentagonal prism 512	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:59:36.73887
1453	pentagonal prism 513	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:36.743797
1457	pentagonal prism 514	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:59:36.971875
1461	pentagonal prism 515	red	{0,0,0}	32.355774	258.8462	935.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:36.977838
1465	pentagonal prism 516	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:37.205025
1469	pentagonal prism 517	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:37.43574
1473	pentagonal prism 518	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:37.440962
1477	pentagonal prism 519	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:37.669488
1481	pentagonal prism 520	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:37.905181
1434	cube 445	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:39.791948
1438	cube 446	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:59:40.044127
1442	cube 447	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:40.281751
1446	cube 448	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:59:40.512153
1450	cube 449	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:59:40.742101
1454	cube 450	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:59:40.976461
1458	cube 451	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:41.208855
1462	cube 452	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	cube.usd	2025-03-29 14:59:41.211006
1466	cube 453	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:41.450138
1470	cube 454	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:41.678507
1474	cube 455	pink	{0,0,0}	-208.68114	346.48944	917.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:41.909257
1478	cube 456	red	{0,0,0}	31.499039	259.86707	934	0	0	37.568592	cube.usd	2025-03-29 14:59:41.911581
1482	cube 457	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.620872	cube.usd	2025-03-29 14:59:42.141858
1432	cylinder 444	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:42.3968
1436	cylinder 445	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:42.636303
1440	cylinder 446	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:59:42.868667
1444	cylinder 447	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:43.102625
1448	cylinder 448	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:59:43.351394
1456	cylinder 450	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:43.849291
1460	cylinder 451	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.434948	cylinder.usd	2025-03-29 14:59:44.082824
1464	cylinder 452	green	{0,0,0}	-270.62216	216.69383	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:44.322216
1468	cylinder 453	green	{0,0,0}	-270.62216	216.69383	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:44.553749
1472	cylinder 454	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:59:44.789663
1476	cylinder 455	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:59:45.018647
1480	cylinder 456	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:45.26488
1484	cylinder 457	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	cylinder.usd	2025-03-29 14:59:45.515555
1491	hexagonal prism 343	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:34.396014
1495	hexagonal prism 344	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:34.628101
1503	hexagonal prism 345	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:55:35.081833
1507	hexagonal prism 346	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:35.312539
1511	hexagonal prism 347	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:35.550426
1515	hexagonal prism 348	red	{0,0,0}	31.375294	259.82666	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:35.780287
1519	hexagonal prism 349	red	{0,0,0}	31.376482	259.8365	920	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:55:36.01406
1527	hexagonal prism 350	red	{0,0,0}	31.375294	259.82666	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:55:36.482202
1531	hexagonal prism 351	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:36.718433
1535	hexagonal prism 352	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:55:36.951147
1487	pentagonal prism 522	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:38.377548
1489	pentagonal prism 523	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:59:38.382779
1493	pentagonal prism 524	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:38.607305
1497	pentagonal prism 525	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:59:38.613673
1501	pentagonal prism 526	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:38.840012
1505	pentagonal prism 527	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:39.079078
1509	pentagonal prism 528	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:39.323943
1513	pentagonal prism 529	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:39.554422
1517	pentagonal prism 530	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:39.787945
1521	pentagonal prism 531	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:39.794298
1525	pentagonal prism 532	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:40.041731
1529	pentagonal prism 533	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:40.279212
1533	pentagonal prism 534	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:40.509487
1537	pentagonal prism 535	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:40.51426
1486	cube 458	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:42.392083
1490	cube 459	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:59:42.631854
1494	cube 460	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:42.864123
1498	cube 461	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.534454	cube.usd	2025-03-29 14:59:43.097942
1499	cube 462	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.534454	cube.usd	2025-03-29 14:59:43.347197
1502	cube 463	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:43.61209
1506	cube 464	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:43.844775
1510	cube 465	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:44.078347
1514	cube 466	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.620872	cube.usd	2025-03-29 14:59:44.317772
1518	cube 467	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:44.549396
1522	cube 468	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:44.785137
1526	cube 469	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	cube.usd	2025-03-29 14:59:44.787284
1530	cube 470	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:45.014545
1534	cube 471	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:45.260289
1488	cylinder 458	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:45.758613
1492	cylinder 459	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 14:59:45.99794
1496	cylinder 460	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:46.233791
1500	cylinder 461	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:46.466196
1504	cylinder 462	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:46.707426
1512	cylinder 464	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 14:59:47.186431
1516	cylinder 465	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:47.423723
1520	cylinder 466	green	{0,0,0}	-272.66354	217.54024	934	0	0	26.56505	cylinder.usd	2025-03-29 14:59:47.649429
1523	cylinder 467	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:59:47.900433
1524	cylinder 468	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:59:48.145642
1528	cylinder 469	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	cylinder.usd	2025-03-29 14:59:48.373384
1532	cylinder 470	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:48.60863
1536	cylinder 471	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:59:48.83863
1539	hexagonal prism 353	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:37.191829
1543	hexagonal prism 354	red	{0,0,0}	30.395967	260.81702	920	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:55:37.417547
1547	hexagonal prism 355	red	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:37.64691
1551	hexagonal prism 356	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:37.868942
1552	cylinder 475	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:55:37.870788
1555	hexagonal prism 357	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:55:38.107703
1556	cylinder 476	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:55:38.109397
1559	hexagonal prism 358	red	{0,0,0}	31.376482	259.8365	917.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:38.338769
1560	cylinder 477	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:38.340664
1563	hexagonal prism 359	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:38.566138
1564	cylinder 478	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:38.568077
1567	hexagonal prism 360	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:38.807453
1568	cylinder 479	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:38.809241
1571	hexagonal prism 361	red	{0,0,0}	30.394815	260.80713	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:39.031809
1572	cylinder 480	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:39.034084
1575	hexagonal prism 362	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:39.263486
1576	cylinder 481	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:55:39.265878
1579	hexagonal prism 363	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:39.487014
1580	cylinder 482	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:39.488975
1583	hexagonal prism 364	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:55:39.730855
1584	cylinder 483	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:39.732932
1587	hexagonal prism 365	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:39.954445
1588	cylinder 484	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:55:39.95624
1545	pentagonal prism 537	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:40.972421
1549	pentagonal prism 538	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:41.205083
1553	pentagonal prism 539	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:41.447509
1557	pentagonal prism 540	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:41.452731
1561	pentagonal prism 541	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:41.675566
1565	pentagonal prism 542	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:41.905472
1569	pentagonal prism 543	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:42.139423
1573	pentagonal prism 544	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:42.387954
1577	pentagonal prism 545	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:42.627689
1581	pentagonal prism 546	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:42.859862
1585	pentagonal prism 547	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:43.0941
1589	pentagonal prism 548	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:43.343069
1538	cube 472	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:59:45.511308
1542	cube 473	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.420776	cube.usd	2025-03-29 14:59:45.753714
1546	cube 474	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:45.993873
1550	cube 475	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.874985	cube.usd	2025-03-29 14:59:45.995924
1554	cube 476	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:46.229372
1558	cube 477	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:59:46.461837
1562	cube 478	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:46.702738
1566	cube 479	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:46.931014
1570	cube 480	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:59:47.181985
1574	cube 481	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.62088	cube.usd	2025-03-29 14:59:47.419138
1578	cube 482	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03624	cube.usd	2025-03-29 14:59:47.645141
1582	cube 483	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	cube.usd	2025-03-29 14:59:47.895984
1586	cube 484	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.743565	cube.usd	2025-03-29 14:59:48.140726
1590	cube 485	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:59:48.369179
1540	cylinder 472	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:49.066482
1544	cylinder 473	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:59:49.315586
1548	cylinder 474	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:59:49.560229
1592	cylinder 485	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:55:40.187664
1595	hexagonal prism 366	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:40.437617
1596	cylinder 486	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:55:40.439788
1600	cylinder 487	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:40.661745
1603	hexagonal prism 367	red	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:40.887998
1604	cylinder 488	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:55:40.889759
1607	hexagonal prism 368	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:55:41.117804
1608	cylinder 489	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:41.119554
1611	hexagonal prism 369	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:41.352188
1612	cylinder 490	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:55:41.354239
1614	cube 491	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:41.593459
1615	hexagonal prism 370	red	{0,0,0}	32.357	258.856	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:41.595426
1616	cylinder 491	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:55:41.597308
1618	cube 492	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:41.819531
1619	hexagonal prism 371	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:41.821345
1620	cylinder 492	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:41.823035
1622	cube 493	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.62088	cube.usd	2025-03-29 14:55:42.049053
1623	hexagonal prism 372	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:42.051442
1624	cylinder 493	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:42.053437
1626	cube 494	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:42.28841
1627	hexagonal prism 373	red	{0,0,0}	29.529222	261.82578	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:42.290353
1628	cylinder 494	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:42.292176
1630	cube 495	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:55:42.527952
1631	hexagonal prism 374	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:42.529746
1632	cylinder 495	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:42.531651
1634	cube 496	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:55:42.752697
1635	hexagonal prism 375	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:42.75454
1636	cylinder 496	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:42.756245
1638	cube 497	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:42.984956
1640	cylinder 497	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:42.988586
1642	cube 498	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 14:55:43.223715
1643	cylinder 498	red	{0,0,0}	30.394815	260.80713	922.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:55:43.22556
1593	pentagonal prism 550	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:43.840926
1597	pentagonal prism 551	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:59:43.847144
1599	pentagonal prism 552	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:44.074429
1601	pentagonal prism 553	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:44.312111
1605	pentagonal prism 554	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:44.546753
1609	pentagonal prism 555	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:44.551582
1613	pentagonal prism 556	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:44.782538
1617	pentagonal prism 557	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:45.011719
1621	pentagonal prism 558	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:45.257338
1625	pentagonal prism 559	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:45.507399
1629	pentagonal prism 560	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:45.51343
1633	pentagonal prism 561	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:59:45.751008
1637	pentagonal prism 562	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:45.756192
1639	pentagonal prism 563	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:45.991491
1641	pentagonal prism 564	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:46.226895
1594	cube 486	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:59:48.60378
1598	cube 487	pink	{0,0,0}	-207.6968	346.48944	913.00006	0	0	59.03625	cube.usd	2025-03-29 14:59:48.834397
1602	cube 488	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:59:49.062318
1606	cube 489	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:49.311147
1610	cube 490	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:59:49.555124
1644	cylinder 499	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:55:43.2274
1646	cube 499	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:55:43.470278
1647	hexagonal prism 376	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:43.472335
1648	cylinder 500	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:55:43.475745
1650	cube 500	pink	{0,0,0}	-205.90816	345.1413	910	0	0	59.03624	cube.usd	2025-03-29 14:55:43.710131
1651	hexagonal prism 377	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:43.711941
1652	cylinder 501	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:55:43.713684
1654	cube 501	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:55:43.938712
1656	cylinder 502	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:55:43.942394
1658	cube 502	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.62088	cube.usd	2025-03-29 14:55:44.162911
1659	hexagonal prism 378	red	{0,0,0}	30.51353	260.84146	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:44.164786
1660	cylinder 503	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 14:55:44.166579
1662	cube 503	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:55:44.396952
1663	hexagonal prism 379	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:44.398981
1664	cylinder 504	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:44.400966
1666	cube 504	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.420776	cube.usd	2025-03-29 14:55:44.632714
1668	cylinder 505	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:55:44.636931
1670	cube 505	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:55:44.856532
1671	hexagonal prism 380	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:44.858344
1672	cylinder 506	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:55:44.860034
1674	cube 506	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:45.086189
1675	hexagonal prism 381	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:55:45.088029
1676	cylinder 507	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:45.089897
1678	cube 507	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:45.323584
1679	hexagonal prism 382	red	{0,0,0}	30.394815	260.80713	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:45.325374
1680	cylinder 508	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:55:45.327213
1682	cube 508	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03625	cube.usd	2025-03-29 14:55:45.557075
1683	cylinder 509	red	{0,0,0}	31.376482	259.8365	920	0	0	37.69424	cylinder.usd	2025-03-29 14:55:45.558916
1684	cylinder 510	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	35.537678	cylinder.usd	2025-03-29 14:55:45.560777
1686	cube 509	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:55:45.786868
1687	hexagonal prism 383	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:45.788749
1688	cylinder 511	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:55:45.79053
1690	cube 510	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:55:46.019115
1691	hexagonal prism 384	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:46.02108
1692	cylinder 512	green	{0,0,0}	-270.62216	216.69383	915	0	0	26.56505	cylinder.usd	2025-03-29 14:55:46.022856
1694	cube 511	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:55:46.256895
1695	hexagonal prism 385	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:46.258969
1696	cylinder 513	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:55:46.260896
1649	pentagonal prism 566	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:46.464041
1653	pentagonal prism 567	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:46.698887
1655	pentagonal prism 568	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:46.927958
1657	pentagonal prism 569	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:46.933398
1661	pentagonal prism 570	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:47.178083
1665	pentagonal prism 571	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:47.415327
1667	pentagonal prism 572	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:47.642697
1669	pentagonal prism 573	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:59:47.891958
1673	pentagonal prism 574	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:47.898252
1677	pentagonal prism 575	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:48.137819
1681	pentagonal prism 576	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:59:48.365018
1685	pentagonal prism 577	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:48.371263
1689	pentagonal prism 578	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:48.599992
1693	pentagonal prism 579	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:48.831397
1698	cube 512	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:55:46.504277
1699	hexagonal prism 386	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:46.506384
1700	cylinder 514	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:46.508218
1702	cube 513	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:55:46.722562
1703	hexagonal prism 387	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:46.724705
1704	cylinder 515	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:55:46.72655
1706	cube 514	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:46.949253
1707	hexagonal prism 388	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:46.951167
1708	cylinder 516	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:55:46.953052
1710	cube 515	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 14:55:47.174848
1711	hexagonal prism 389	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:47.176685
1712	cylinder 517	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:47.178555
1713	pentagonal prism 584	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:47.404791
1714	cube 516	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:55:47.408635
1715	hexagonal prism 390	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:47.410669
1716	cylinder 518	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:55:47.412628
1717	pentagonal prism 585	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:55:47.632692
1718	cube 517	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	cube.usd	2025-03-29 14:55:47.636326
1719	pentagonal prism 586	red	{0,0,0}	32.357	258.856	924	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:55:47.638477
1720	cylinder 519	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:55:47.640422
1721	pentagonal prism 587	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:55:47.857828
1722	cube 518	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 14:55:47.860648
1723	hexagonal prism 391	red	{0,0,0}	31.375294	259.82666	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:55:47.862463
1724	cylinder 520	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:47.864248
1725	pentagonal prism 588	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:48.079619
1726	cube 519	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:48.082908
1727	pentagonal prism 589	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:55:48.084719
1728	cylinder 521	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:55:48.086512
1729	pentagonal prism 590	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:48.305776
1730	cube 520	pink	{0,0,0}	-208.68114	346.48944	929	0	0	59.03625	cube.usd	2025-03-29 14:55:48.309144
1731	pentagonal prism 591	red	{0,0,0}	29.53035	261.83575	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:55:48.311094
1732	cylinder 522	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:48.313041
1733	pentagonal prism 592	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 14:55:48.538828
1734	cube 521	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.420776	cube.usd	2025-03-29 14:55:48.542353
1735	hexagonal prism 392	red	{0,0,0}	31.375294	259.82666	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:48.544386
1736	cylinder 523	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:55:48.546277
1737	pentagonal prism 593	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:55:48.764712
1738	cube 522	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:48.768418
1739	hexagonal prism 393	red	{0,0,0}	30.394815	260.80713	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:48.770461
1740	cylinder 524	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	45	cylinder.usd	2025-03-29 14:55:48.772563
1741	pentagonal prism 594	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:55:48.977567
1742	cube 523	pink	{0,0,0}	-206.88867	345.1413	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:48.980371
1743	hexagonal prism 394	red	{0,0,0}	30.395967	260.81702	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:55:48.982208
1744	cylinder 525	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	cylinder.usd	2025-03-29 14:55:48.983979
1745	pentagonal prism 595	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:49.197095
1746	cube 524	pink	{0,0,0}	-206.88867	345.1413	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:55:49.200848
1747	hexagonal prism 395	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:49.202745
1748	cylinder 526	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:55:49.204701
1749	hexagonal prism 396	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 14:55:50.030246
1701	pentagonal prism 581	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:49.306813
1705	pentagonal prism 582	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:59:49.313573
1709	pentagonal prism 583	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:49.551309
1750	cube 525	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:50.034122
1751	hexagonal prism 397	red	{0,0,0}	31.375294	259.82666	938	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:50.036154
1752	cylinder 527	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	36.869896	cylinder.usd	2025-03-29 14:55:50.03804
1753	pentagonal prism 596	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:55:50.239858
1754	cube 526	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:55:50.24264
1755	hexagonal prism 398	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:50.244614
1756	cylinder 528	green	{0,0,0}	-270.62216	216.69383	919	0	0	36.869896	cylinder.usd	2025-03-29 14:55:50.246492
1757	pentagonal prism 597	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:50.661623
1758	cube 527	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:55:50.665108
1759	cylinder 529	red	{0,0,0}	30.395967	260.81702	921.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:55:50.666974
1760	cylinder 530	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:50.668834
1761	pentagonal prism 598	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:55:50.875316
1762	cube 528	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:50.878338
1763	hexagonal prism 399	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:50.880527
1764	cylinder 531	green	{0,0,0}	-270.62216	216.69383	911.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:50.882408
1765	pentagonal prism 599	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:51.094318
1766	cube 529	pink	{0,0,0}	-205.90038	345.12823	920	0	0	58.392494	cube.usd	2025-03-29 14:55:51.096755
1767	hexagonal prism 400	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:51.09858
1768	cylinder 532	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:55:51.100372
1769	pentagonal prism 600	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:51.307046
1770	cube 530	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:55:51.310117
1771	cylinder 533	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	cylinder.usd	2025-03-29 14:55:51.311936
1772	cylinder 534	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:51.31369
1773	pentagonal prism 601	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:51.524824
1774	cube 531	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.743565	cube.usd	2025-03-29 14:55:51.527561
1775	hexagonal prism 401	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	38.157227	hexagonal prism.usd	2025-03-29 14:55:51.529437
1776	cylinder 535	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:51.531255
1777	pentagonal prism 602	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:51.748313
1778	cube 532	pink	{0,0,0}	-206.88867	345.1413	917.00006	0	0	59.743565	cube.usd	2025-03-29 14:55:51.750346
1779	hexagonal prism 402	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:51.752141
1780	cylinder 536	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:51.753921
1781	pentagonal prism 603	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:51.963893
1782	cube 533	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:51.966187
1783	hexagonal prism 403	red	{0,0,0}	31.376482	259.8365	917.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:51.968215
1784	cylinder 537	green	{0,0,0}	-270.62216	216.69383	938	0	0	18.434948	cylinder.usd	2025-03-29 14:55:51.970058
1785	pentagonal prism 604	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:55:52.183877
1786	cube 534	pink	{0,0,0}	-206.88867	345.1413	910	0	0	59.03624	cube.usd	2025-03-29 14:55:52.187458
1787	hexagonal prism 404	red	{0,0,0}	31.376482	259.8365	924	0	0	37.34935	hexagonal prism.usd	2025-03-29 14:55:52.189371
1788	cylinder 538	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:52.19124
1789	hexagonal prism 405	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 14:55:52.398171
1790	cube 535	pink	{0,0,0}	-208.68114	346.48944	924	0	0	57.994617	cube.usd	2025-03-29 14:55:52.401263
1791	hexagonal prism 406	red	{0,0,0}	30.514694	260.8514	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:52.40462
1792	cylinder 539	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	16.699244	cylinder.usd	2025-03-29 14:55:52.408101
1793	pentagonal prism 605	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	pentagonal prism.usd	2025-03-29 14:55:52.618936
1794	cube 536	pink	{0,0,0}	-208.68114	346.48944	930.00006	0	0	59.534454	cube.usd	2025-03-29 14:55:52.621515
1795	hexagonal prism 407	red	{0,0,0}	30.514694	260.8514	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:52.623575
1796	cylinder 540	green	{0,0,0}	-272.66354	217.54024	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:52.625584
1797	hexagonal prism 408	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	0	hexagonal prism.usd	2025-03-29 14:55:52.833887
1798	cube 537	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.743565	cube.usd	2025-03-29 14:55:52.83653
1799	cube 538	red	{0,0,0}	31.376482	258.856	929	0	0	37.746803	cube.usd	2025-03-29 14:55:52.838685
1800	cylinder 541	green	{0,0,0}	-270.62216	216.69383	929	0	0	45	cylinder.usd	2025-03-29 14:55:52.84061
1801	hexagonal prism 409	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	hexagonal prism.usd	2025-03-29 14:55:53.051211
1802	cube 539	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:53.05333
1803	hexagonal prism 410	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:55:53.055462
1804	cylinder 542	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:55:53.057448
1805	hexagonal prism 411	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	hexagonal prism.usd	2025-03-29 14:55:53.263706
1806	cube 540	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:55:53.265941
1807	cube 541	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	cube.usd	2025-03-29 14:55:53.267782
1808	cylinder 543	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	35.537674	cylinder.usd	2025-03-29 14:55:53.269734
1809	hexagonal prism 412	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 14:55:53.478782
1810	cube 542	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:55:53.482863
1811	cube 543	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	cube.usd	2025-03-29 14:55:53.485036
1812	cylinder 544	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:55:53.487005
1813	hexagonal prism 413	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	hexagonal prism.usd	2025-03-29 14:55:53.716045
1814	cube 544	pink	{0,0,0}	-206.88867	345.1413	917.00006	0	0	59.743565	cube.usd	2025-03-29 14:55:53.718616
1815	hexagonal prism 414	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:53.720687
1816	cylinder 545	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:55:53.722506
1817	hexagonal prism 415	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	0	hexagonal prism.usd	2025-03-29 14:55:53.931709
1818	cube 545	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:55:53.934436
1819	cube 546	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.405357	cube.usd	2025-03-29 14:55:53.93632
1820	cylinder 546	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 14:55:53.938054
1821	hexagonal prism 416	black	{0,0,0}	-122.564384	519.673	653.00006	0	0	90	hexagonal prism.usd	2025-03-29 14:55:54.155037
1822	cube 547	pink	{0,0,0}	-201.9861	345.1413	905.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:54.158481
1823	cube 548	red	{0,0,0}	37.25957	258.856	916.00006	0	0	37.405357	cube.usd	2025-03-29 14:55:54.160432
1824	cylinder 547	green	{0,0,0}	-265.71957	216.69383	933	0	0	18.434948	cylinder.usd	2025-03-29 14:55:54.162285
1825	wedge 1	blue	{0,0,0}	199.23233	349.42285	1912	0	0	90	wedge.usd	2025-03-29 14:55:55.845875
1826	hexagonal prism 417	black	{0,0,0}	77.240845	335.93637	606	0	0	90	hexagonal prism.usd	2025-03-29 14:55:55.848399
1827	cuboid 1	pink	{0,0,0}	26.972994	217.01	925.00006	0	0	59.03625	cuboid.usd	2025-03-29 14:55:55.85072
1828	pentagonal prism 606	blue	{0,0,0}	-285.05548	171.64632	1854.0001	0	0	90	pentagonal prism.usd	2025-03-29 14:55:55.853182
1829	cylinder 548	blue	{0,0,0}	-167.35516	186.35886	1805.0001	0	0	34.15969	cylinder.usd	2025-03-29 14:55:55.855763
1830	pentagonal prism 607	red	{0,0,0}	177.77655	161.83795	920	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:55:55.858073
1831	cylinder 549	green	{0,0,0}	-12.260451	135.47798	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:55.860611
1832	cylinder 550	blue	{0,0,0}	-223.14021	72.33666	1805.0001	0	0	56.309937	cylinder.usd	2025-03-29 14:55:55.863161
1833	pentagonal prism 608	black	{0,0,0}	-324.46066	86.31878	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:55:56.895336
1834	wedge 2	orange	{0,0,0}	-169.5766	-12.243798	1967.0001	0	0	5.7105937	wedge.usd	2025-03-29 14:55:56.898088
1835	cube 549	pink	{0,0,0}	-374.04803	-22.038836	929	0	0	59.420776	cube.usd	2025-03-29 14:55:56.900174
1836	cylinder 551	red	{0,0,0}	-225.89807	-74.687164	937.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:55:56.902173
1837	cylinder 552	green	{0,0,0}	-413.84036	-102.23571	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:56.904115
1838	pentagonal prism 609	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:55:57.122363
1839	cube 550	pink	{0,0,0}	-206.88867	345.1413	932.00006	0	0	59.03625	cube.usd	2025-03-29 14:55:57.126205
1840	hexagonal prism 418	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:57.12815
1841	cylinder 553	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	cylinder.usd	2025-03-29 14:55:57.130313
1842	pentagonal prism 610	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:55:57.34396
1843	cube 551	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:57.346353
1844	hexagonal prism 419	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:57.348212
1845	cylinder 554	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:55:57.350015
1846	pentagonal prism 611	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:57.574922
1847	cube 552	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:55:57.578576
1848	hexagonal prism 420	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:57.580805
1849	cylinder 555	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:57.582641
1850	hexagonal prism 421	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	hexagonal prism.usd	2025-03-29 14:55:57.804526
1851	cube 553	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.34933	cube.usd	2025-03-29 14:55:57.808062
1852	hexagonal prism 422	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:57.810258
1853	cylinder 556	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:55:57.812043
1854	pentagonal prism 612	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:55:58.023176
1855	cube 554	pink	{0,0,0}	-206.88867	345.1413	930.00006	0	0	59.420776	cube.usd	2025-03-29 14:55:58.025593
1856	hexagonal prism 423	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:58.027429
1857	cylinder 557	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:55:58.029521
1858	pentagonal prism 613	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:55:58.243959
1859	cube 555	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:55:58.246785
1860	hexagonal prism 424	red	{0,0,0}	30.395967	260.81702	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:58.248633
1861	cylinder 558	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:55:58.250412
1862	pentagonal prism 614	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:55:58.474521
1863	cube 556	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:55:58.478752
1864	pentagonal prism 615	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:55:58.481152
1865	cylinder 559	green	{0,0,0}	-270.62216	216.69383	919	0	0	33.690063	cylinder.usd	2025-03-29 14:55:58.483137
1866	pentagonal prism 616	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:58.706975
1867	cube 557	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:55:58.709188
1868	hexagonal prism 425	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:58.711063
1869	cylinder 560	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:58.712958
1870	pentagonal prism 617	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:55:58.934082
1871	cube 558	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:58.936669
1872	hexagonal prism 426	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:58.938463
1873	cylinder 561	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:58.940398
1874	pentagonal prism 618	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:55:59.166058
1875	cube 559	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:55:59.168914
1876	hexagonal prism 427	red	{0,0,0}	30.395967	260.81702	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:55:59.174143
1877	cylinder 562	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:55:59.176192
1878	pentagonal prism 619	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:55:59.414846
1879	cube 560	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.34933	cube.usd	2025-03-29 14:55:59.417089
1880	pentagonal prism 620	red	{0,0,0}	30.395967	260.81702	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:55:59.419181
1881	cylinder 563	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:59.421152
1882	pentagonal prism 621	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:55:59.6434
1883	cube 561	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.420776	cube.usd	2025-03-29 14:55:59.645743
1884	hexagonal prism 428	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:55:59.64768
1885	cylinder 564	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:55:59.649568
1886	pentagonal prism 622	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:55:59.872896
1887	cube 562	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:55:59.876406
1888	pentagonal prism 623	red	{0,0,0}	30.395967	260.81702	931.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:55:59.87824
1889	cylinder 565	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:55:59.879956
1890	pentagonal prism 624	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:00.097123
1891	cube 563	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 14:56:00.099779
1892	hexagonal prism 429	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:00.101754
1893	cylinder 566	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:00.103546
1894	pentagonal prism 625	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:56:00.327577
1895	cube 564	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:00.329807
1896	hexagonal prism 430	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:00.331951
1897	cylinder 567	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:00.333755
1898	pentagonal prism 626	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:00.544258
1899	cube 565	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 14:56:00.547126
1900	hexagonal prism 431	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:00.549269
1901	cylinder 568	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:00.551155
1902	pentagonal prism 627	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:00.766276
1903	cube 566	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.743565	cube.usd	2025-03-29 14:56:00.769062
1904	hexagonal prism 432	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:00.770965
1905	cylinder 569	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:00.772697
1906	pentagonal prism 628	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:00.991309
1907	cube 567	pink	{0,0,0}	-206.88867	345.1413	926.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:00.995082
1908	hexagonal prism 433	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:00.997044
1909	cylinder 570	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:00.999114
1910	pentagonal prism 629	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:01.219112
1911	cube 568	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:56:01.223964
1912	hexagonal prism 434	red	{0,0,0}	31.376482	259.8365	934	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:01.22614
1913	cylinder 571	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:01.228093
1914	pentagonal prism 630	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:01.44526
1915	cube 569	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.420776	cube.usd	2025-03-29 14:56:01.448065
1916	cylinder 572	red	{0,0,0}	29.53035	261.83575	929	0	0	37.568592	cylinder.usd	2025-03-29 14:56:01.450057
1917	cylinder 573	green	{0,0,0}	-272.66354	217.54024	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:01.451946
1918	pentagonal prism 631	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:01.665115
1919	cube 570	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:01.668312
1920	hexagonal prism 435	red	{0,0,0}	30.394815	260.80713	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:01.67023
1921	cylinder 574	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:01.671992
1922	pentagonal prism 632	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:56:01.894929
1923	cube 571	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:01.89733
1924	hexagonal prism 436	red	{0,0,0}	30.394815	260.80713	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:01.899249
1925	cylinder 575	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:01.901272
1926	pentagonal prism 633	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:02.113667
1927	cube 572	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:02.117603
1928	hexagonal prism 437	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:56:02.121586
1929	cylinder 576	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:56:02.125185
1930	pentagonal prism 634	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:02.34596
1931	cube 573	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:02.349519
1932	hexagonal prism 438	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:02.351576
1933	cylinder 577	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:02.353469
1934	pentagonal prism 635	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:02.564448
1935	cube 574	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:56:02.56724
1936	hexagonal prism 439	red	{0,0,0}	30.394815	260.80713	927.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:02.569235
1937	cylinder 578	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	21.801407	cylinder.usd	2025-03-29 14:56:02.570997
1938	pentagonal prism 636	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:02.779648
1939	cube 575	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:02.782371
1940	hexagonal prism 440	red	{0,0,0}	30.394815	260.80713	931.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:56:02.785495
1941	cylinder 579	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:02.787606
1942	pentagonal prism 637	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:03.010942
1943	cube 576	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.62088	cube.usd	2025-03-29 14:56:03.013583
1944	cylinder 580	red	{0,0,0}	30.395967	260.81702	923.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:56:03.015505
1945	cylinder 581	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	cylinder.usd	2025-03-29 14:56:03.017474
1946	pentagonal prism 638	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:03.232385
1947	cube 577	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:56:03.235398
1948	hexagonal prism 441	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:03.237397
1949	cylinder 582	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:03.239236
1950	pentagonal prism 639	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:03.462422
1951	cube 578	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:03.464601
1952	pentagonal prism 640	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:56:03.466656
1953	cylinder 583	green	{0,0,0}	-270.62216	216.69383	920	0	0	18.434948	cylinder.usd	2025-03-29 14:56:03.468781
1954	pentagonal prism 641	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:03.678392
1955	cube 579	pink	{0,0,0}	-207.68886	346.4762	915	0	0	59.03624	cube.usd	2025-03-29 14:56:03.680611
1956	cylinder 584	red	{0,0,0}	29.529222	261.82578	930.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:56:03.682446
1957	cylinder 585	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:03.684355
1958	pentagonal prism 642	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:56:03.89745
1959	cube 580	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:56:03.901381
1960	hexagonal prism 442	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:03.903711
1961	cylinder 586	green	{0,0,0}	-270.62216	216.69383	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:03.905926
1962	pentagonal prism 643	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:04.123567
1963	cube 581	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 14:56:04.12622
1964	hexagonal prism 443	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:04.128097
1965	cylinder 587	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:04.129984
1966	pentagonal prism 644	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:04.345822
1967	cube 582	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:04.349423
1968	hexagonal prism 444	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:04.351359
1969	cylinder 588	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:04.353521
1970	pentagonal prism 645	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:04.586086
1971	cube 583	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:04.589621
1972	hexagonal prism 445	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:04.59166
1973	cylinder 589	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:56:04.59357
1974	pentagonal prism 646	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:04.80642
1975	cube 584	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.743565	cube.usd	2025-03-29 14:56:04.808909
1976	cylinder 590	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	cylinder.usd	2025-03-29 14:56:04.810754
1977	cylinder 591	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:04.81255
1978	pentagonal prism 647	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:05.038415
1979	cube 585	pink	{0,0,0}	-206.88867	345.1413	914.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:05.041838
1980	hexagonal prism 446	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:05.043623
1981	cylinder 592	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:05.04557
1982	pentagonal prism 648	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:05.261265
1983	cube 586	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:05.264898
1984	hexagonal prism 447	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:05.266705
1985	cylinder 593	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:05.268746
1986	pentagonal prism 649	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:05.480717
1987	cube 587	pink	{0,0,0}	-206.88867	345.1413	915	0	0	59.03624	cube.usd	2025-03-29 14:56:05.482869
1988	pentagonal prism 650	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:56:05.484778
1989	cylinder 594	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:05.487326
1990	pentagonal prism 651	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:05.698226
1991	cube 588	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.534454	cube.usd	2025-03-29 14:56:05.700557
1992	hexagonal prism 448	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:05.702866
1993	cylinder 595	green	{0,0,0}	-270.62216	216.69383	943	0	0	26.56505	cylinder.usd	2025-03-29 14:56:05.704941
1994	pentagonal prism 652	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:05.915925
1995	cube 589	pink	{0,0,0}	-206.88867	345.1413	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:05.918666
1996	pentagonal prism 653	red	{0,0,0}	30.395967	260.81702	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:56:05.920921
1997	cylinder 596	green	{0,0,0}	-270.62216	216.69383	920	0	0	36.869896	cylinder.usd	2025-03-29 14:56:05.922758
1998	pentagonal prism 654	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:06.148867
1999	cube 590	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:06.152958
2000	hexagonal prism 449	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:06.154848
2001	cylinder 597	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:06.156602
2002	pentagonal prism 655	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:06.381802
2003	cube 591	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	cube.usd	2025-03-29 14:56:06.385781
2004	hexagonal prism 450	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:06.388036
2005	cylinder 598	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:06.389839
2006	pentagonal prism 656	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:06.617383
2007	cube 592	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.620872	cube.usd	2025-03-29 14:56:06.620994
2008	hexagonal prism 451	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:06.622862
2009	cylinder 599	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:06.624659
2010	pentagonal prism 657	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:06.848514
2011	cube 593	pink	{0,0,0}	-206.88867	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:06.850583
2012	hexagonal prism 452	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:06.852588
2013	cylinder 600	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:06.854797
2014	pentagonal prism 658	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:07.075316
2015	cube 594	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:56:07.078959
2016	hexagonal prism 453	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:56:07.080813
2017	cylinder 601	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:07.082626
2018	pentagonal prism 659	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:56:07.298832
2019	cube 595	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:07.300982
2020	hexagonal prism 454	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:07.303247
2021	cylinder 602	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:07.305238
2022	pentagonal prism 660	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:07.531372
2023	cube 596	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:07.535638
2024	hexagonal prism 455	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:07.537717
2025	cylinder 603	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:07.539819
2026	pentagonal prism 661	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:07.755459
2027	cube 597	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 14:56:07.758163
2028	hexagonal prism 456	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:07.760143
2029	cylinder 604	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:07.762026
2030	pentagonal prism 662	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:07.984535
2031	cube 598	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.620872	cube.usd	2025-03-29 14:56:07.988471
2032	hexagonal prism 457	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:07.990427
2033	cylinder 605	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:07.992264
2034	pentagonal prism 663	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:08.216916
2035	cube 599	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:56:08.219598
2036	hexagonal prism 458	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:08.221543
2037	cylinder 606	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:08.223552
2038	pentagonal prism 664	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:08.453199
2039	cube 600	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:56:08.456768
2040	hexagonal prism 459	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:08.458585
2041	cylinder 607	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:56:08.460443
2042	pentagonal prism 665	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:08.684841
2043	cube 601	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:08.68844
2044	hexagonal prism 460	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:08.690404
2045	cylinder 608	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.43495	cylinder.usd	2025-03-29 14:56:08.692366
2046	pentagonal prism 666	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:08.91813
2047	cube 602	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.03625	cube.usd	2025-03-29 14:56:08.920272
2048	hexagonal prism 461	red	{0,0,0}	30.514694	260.8514	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:08.922086
2049	cylinder 609	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:08.924214
2050	pentagonal prism 667	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:09.137746
2051	cube 603	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:09.140006
2052	hexagonal prism 462	red	{0,0,0}	30.395967	260.81702	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:09.142024
2053	cylinder 610	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:09.143953
2054	pentagonal prism 668	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:09.364757
2055	cube 604	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:09.367121
2056	hexagonal prism 463	red	{0,0,0}	30.394815	260.80713	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:09.369227
2057	cylinder 611	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:56:09.371058
2058	pentagonal prism 669	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:09.591547
2059	cube 605	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03624	cube.usd	2025-03-29 14:56:09.593807
2060	pentagonal prism 670	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:56:09.595801
2061	cylinder 612	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:09.597857
2062	pentagonal prism 671	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:09.811369
2063	cube 606	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:56:09.814158
2064	hexagonal prism 464	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:09.816063
2065	cylinder 613	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:09.817997
2066	pentagonal prism 672	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:10.033115
2067	cube 607	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:10.036737
2068	hexagonal prism 465	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:10.039444
2069	cylinder 614	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:10.041503
2070	pentagonal prism 673	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:10.26714
2071	cube 608	pink	{0,0,0}	-206.88867	345.1413	914.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:10.271168
2072	hexagonal prism 466	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:10.273202
2073	cylinder 615	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:10.275221
2074	pentagonal prism 674	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:10.497214
2075	cube 609	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:10.500703
2076	hexagonal prism 467	red	{0,0,0}	31.376482	259.8365	934	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:10.502635
2077	cylinder 616	green	{0,0,0}	-270.62216	216.69383	917.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:10.504514
2078	pentagonal prism 675	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:10.721963
2079	cube 610	pink	{0,0,0}	-207.6968	346.48944	918.00006	0	0	59.620872	cube.usd	2025-03-29 14:56:10.725579
2080	hexagonal prism 468	red	{0,0,0}	30.514694	260.8514	935.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:10.727432
2081	cylinder 617	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:10.72934
2082	pentagonal prism 676	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:10.954914
2083	cube 611	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:10.957499
2084	hexagonal prism 469	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:10.959477
2085	cylinder 618	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:10.961369
2086	pentagonal prism 677	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:11.189353
2087	cube 612	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:11.193246
2088	hexagonal prism 470	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:11.195354
2089	cylinder 619	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:11.197244
2090	pentagonal prism 678	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:11.418495
2091	cube 613	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:11.422136
2092	hexagonal prism 471	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:11.424124
2093	cylinder 620	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:11.426254
2094	pentagonal prism 679	black	{0,0,0}	-127.46696	518.69244	661	0	0	0	pentagonal prism.usd	2025-03-29 14:56:11.641026
2095	cube 614	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:56:11.645122
2096	cylinder 621	red	{0,0,0}	30.395967	260.81702	924	0	0	37.405357	cylinder.usd	2025-03-29 14:56:11.646999
2097	cylinder 622	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:11.648798
2098	pentagonal prism 680	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:11.872111
2099	cube 615	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:11.875878
2100	hexagonal prism 472	red	{0,0,0}	30.395967	260.81702	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:11.877868
2101	cylinder 623	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:11.879685
2102	pentagonal prism 681	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:56:12.1003
2103	cube 616	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:12.103849
2104	hexagonal prism 473	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:12.105807
2105	cylinder 624	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:12.107983
2106	pentagonal prism 682	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:12.327093
2107	cube 617	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:56:12.329307
2108	hexagonal prism 474	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:12.331276
2109	cylinder 625	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:12.333047
2110	pentagonal prism 683	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:12.555576
2111	cube 618	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:12.558157
2112	pentagonal prism 684	red	{0,0,0}	30.394815	260.80713	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:56:12.560696
2113	cylinder 626	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:12.562953
2114	pentagonal prism 685	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:12.775007
2115	cube 619	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:12.777364
2116	hexagonal prism 475	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:12.779226
2117	cylinder 627	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:12.781019
2118	pentagonal prism 686	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:12.998244
2119	cube 620	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:13.00051
2120	cylinder 628	red	{0,0,0}	30.395967	260.81702	923.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:56:13.002449
2121	cylinder 629	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:13.004279
2122	pentagonal prism 687	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:13.215992
2123	cube 621	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:13.219963
2124	hexagonal prism 476	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:13.22201
2125	cylinder 630	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:13.223806
2126	pentagonal prism 688	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:13.439742
2127	cube 622	pink	{0,0,0}	-206.88867	345.1413	911.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:13.441807
2128	hexagonal prism 477	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:13.444189
2129	cylinder 631	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:13.446097
2130	pentagonal prism 689	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:13.67238
2131	cube 623	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:13.674733
2132	hexagonal prism 478	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:13.676919
2133	cylinder 632	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:13.67876
2134	pentagonal prism 690	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:13.89027
2135	cube 624	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 14:56:13.892539
2136	hexagonal prism 479	red	{0,0,0}	31.375294	259.82666	915	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:13.895137
2137	cylinder 633	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:56:13.897517
2138	pentagonal prism 691	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:14.130907
2139	cube 625	pink	{0,0,0}	-206.88867	345.1413	916.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:14.134739
2140	hexagonal prism 480	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:14.136709
2141	cylinder 634	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:14.138549
2142	pentagonal prism 692	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:14.355009
2143	cube 626	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:14.35862
2144	hexagonal prism 481	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:14.360868
2145	cylinder 635	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:14.363125
2146	pentagonal prism 693	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:56:14.575189
2147	cube 627	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:14.577997
2148	hexagonal prism 482	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:14.579861
2149	cylinder 636	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 14:56:14.581705
2150	pentagonal prism 694	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:14.806528
2151	cube 628	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:56:14.810133
2152	hexagonal prism 483	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:14.812226
2153	cylinder 637	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:56:14.814153
2154	pentagonal prism 695	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:15.025638
2155	cube 629	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:15.028333
2156	hexagonal prism 484	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:15.030188
2157	cylinder 638	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:15.032138
2158	pentagonal prism 696	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:15.274337
2159	cube 630	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.743565	cube.usd	2025-03-29 14:56:15.277907
2160	hexagonal prism 485	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:15.279863
2161	cylinder 639	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:15.28176
2162	pentagonal prism 697	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:15.507397
2163	cube 631	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 14:56:15.511192
2164	hexagonal prism 486	red	{0,0,0}	30.394815	260.80713	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:15.513372
2165	cylinder 640	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:15.515354
2166	pentagonal prism 698	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:15.739434
2167	cube 632	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:15.743381
2168	hexagonal prism 487	red	{0,0,0}	30.395967	260.81702	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:15.745539
2169	cylinder 641	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:15.747386
2170	pentagonal prism 699	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:15.961833
2171	cube 633	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:15.964619
2172	hexagonal prism 488	red	{0,0,0}	30.51353	260.84146	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:15.96656
2173	cylinder 642	green	{0,0,0}	-272.65317	217.53194	942.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:56:15.968459
2174	pentagonal prism 700	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:16.189477
2175	cube 634	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:16.193222
2176	hexagonal prism 489	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:16.195364
2177	cylinder 643	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:16.197322
2178	pentagonal prism 701	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:16.407011
2179	cube 635	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:16.409215
2180	hexagonal prism 490	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:16.411274
2181	cylinder 644	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:16.413212
2182	pentagonal prism 702	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:16.626361
2183	cube 636	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:56:16.629325
2184	hexagonal prism 491	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:16.631505
2185	cylinder 645	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	38.65981	cylinder.usd	2025-03-29 14:56:16.633815
2186	pentagonal prism 703	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:16.858481
2187	cube 637	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:16.861509
2188	hexagonal prism 492	red	{0,0,0}	30.394815	260.80713	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:16.863497
2189	cylinder 646	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:16.865325
2190	pentagonal prism 704	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:17.074731
2191	cube 638	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:56:17.077084
2192	hexagonal prism 493	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:17.078989
2193	cylinder 647	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:17.080865
2194	pentagonal prism 705	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:17.293831
2195	cube 639	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:56:17.29652
2196	cylinder 648	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:56:17.2985
2197	cylinder 649	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:17.300313
2198	pentagonal prism 706	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:17.510153
2199	cube 640	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:17.513324
2200	hexagonal prism 494	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:17.515319
2201	cylinder 650	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:17.51715
2202	pentagonal prism 707	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:17.743464
2203	cube 641	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:17.745957
2204	hexagonal prism 495	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:17.747929
2205	cylinder 651	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:17.749665
2206	pentagonal prism 708	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:17.973827
2207	cube 642	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:17.977388
2208	hexagonal prism 496	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:17.979488
2209	cylinder 652	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:17.981667
2210	pentagonal prism 709	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:18.197413
2211	cube 643	pink	{0,0,0}	-206.88867	345.1413	932.00006	0	0	59.743565	cube.usd	2025-03-29 14:56:18.200054
2212	hexagonal prism 497	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:18.202098
2213	cylinder 653	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:18.204014
2214	pentagonal prism 710	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:18.416288
2215	cube 644	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:18.418935
2216	hexagonal prism 498	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:18.420679
2217	cylinder 654	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:18.422431
2218	pentagonal prism 711	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:18.650512
2219	cube 645	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:56:18.654021
2220	hexagonal prism 499	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:18.655855
2221	cylinder 655	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:18.657834
2222	pentagonal prism 712	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:18.875968
2223	cube 646	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.620872	cube.usd	2025-03-29 14:56:18.879515
2224	hexagonal prism 500	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:18.881864
2225	cylinder 656	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:18.883822
2226	pentagonal prism 713	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:19.093461
2227	cube 647	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	cube.usd	2025-03-29 14:56:19.095635
2228	hexagonal prism 501	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:19.097685
2229	cylinder 657	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:19.099643
2230	pentagonal prism 714	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:19.324724
2231	cube 648	pink	{0,0,0}	-206.88867	345.1413	914.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:19.328593
2232	hexagonal prism 502	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:19.331463
2233	cylinder 658	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:19.334332
2234	pentagonal prism 715	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:19.558663
2235	cube 649	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:19.562507
2236	pentagonal prism 716	red	{0,0,0}	30.394815	260.80713	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:56:19.564521
2237	cylinder 659	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:19.567053
2238	pentagonal prism 717	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:19.777247
2239	cube 650	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:19.78063
2240	hexagonal prism 503	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:19.782751
2241	cylinder 660	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:19.785081
2242	pentagonal prism 718	black	{0,0,0}	-128.94919	520.7185	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:20.009155
2243	cube 651	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03624	cube.usd	2025-03-29 14:56:20.012933
2244	cylinder 661	red	{0,0,0}	29.53035	261.83575	925.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:56:20.015039
2245	cylinder 662	green	{0,0,0}	-272.66354	217.54024	921.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:20.016984
2246	pentagonal prism 719	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:56:20.230753
2247	cube 652	pink	{0,0,0}	-206.88867	345.1413	930.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:20.233903
2248	pentagonal prism 720	red	{0,0,0}	30.395967	260.81702	934	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:56:20.236057
2249	cylinder 663	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	38.659805	cylinder.usd	2025-03-29 14:56:20.237999
2250	pentagonal prism 721	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal prism.usd	2025-03-29 14:56:20.461426
2251	cube 653	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03625	cube.usd	2025-03-29 14:56:20.463921
2252	hexagonal prism 504	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:20.466463
2253	cylinder 664	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:20.468447
2254	pentagonal prism 722	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:20.70114
2255	cube 654	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	cube.usd	2025-03-29 14:56:20.704897
2256	cube 655	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	cube.usd	2025-03-29 14:56:20.706771
2257	cylinder 665	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:20.708852
2258	pentagonal prism 723	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:56:20.927942
2259	cube 656	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:56:20.931845
2260	pentagonal prism 724	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:56:20.933782
2261	cylinder 666	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:20.935589
2262	pentagonal prism 725	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:21.15998
2263	cube 657	pink	{0,0,0}	-205.90816	345.1413	909.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:21.163444
2264	hexagonal prism 505	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:21.165299
2265	cylinder 667	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:56:21.167272
2266	pentagonal prism 726	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:21.391817
2267	cube 658	pink	{0,0,0}	-206.88867	345.1413	927.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:21.395448
2268	hexagonal prism 506	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:21.397312
2269	cylinder 668	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:21.399163
2270	pentagonal prism 727	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:21.625225
2271	cube 659	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:21.629126
2272	hexagonal prism 507	red	{0,0,0}	30.514694	260.8514	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:21.631226
2273	cylinder 669	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:21.633635
2274	pentagonal prism 728	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:21.882313
2275	cube 660	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:21.886087
2276	hexagonal prism 508	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:21.89012
2277	cylinder 670	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:21.894056
2278	pentagonal prism 729	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:22.115581
2279	cube 661	pink	{0,0,0}	-206.88867	345.1413	912.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:22.119694
2280	pentagonal prism 730	red	{0,0,0}	30.395967	260.81702	933	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:56:22.122012
2281	cylinder 671	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:56:22.124093
2282	pentagonal prism 731	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:22.352706
2283	cube 662	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:22.354883
2284	hexagonal prism 509	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:22.356589
2285	cylinder 672	green	{0,0,0}	-270.62216	216.69383	943	0	0	26.56505	cylinder.usd	2025-03-29 14:56:22.358443
2286	pentagonal prism 732	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:22.575593
2287	cube 663	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:56:22.57805
2288	cylinder 673	red	{0,0,0}	30.395967	260.81702	926.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:56:22.579991
2289	cylinder 674	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:22.581732
2290	pentagonal prism 733	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:22.798873
2291	cube 664	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:22.801012
2292	hexagonal prism 510	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:22.803312
2293	cylinder 675	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:56:22.805275
2294	pentagonal prism 734	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:23.025861
2295	cube 665	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.03624	cube.usd	2025-03-29 14:56:23.027945
2296	cylinder 676	red	{0,0,0}	30.394815	260.80713	929	0	0	37.568592	cylinder.usd	2025-03-29 14:56:23.029858
2297	cylinder 677	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 14:56:23.031717
2298	pentagonal prism 735	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:23.254509
2299	cube 666	pink	{0,0,0}	-206.88867	345.1413	933	0	0	59.03624	cube.usd	2025-03-29 14:56:23.25693
2300	hexagonal prism 511	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:23.258918
2301	cylinder 678	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	cylinder.usd	2025-03-29 14:56:23.260696
2302	pentagonal prism 736	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:23.473573
2303	cube 667	pink	{0,0,0}	-206.88867	345.1413	930.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:23.476123
2304	hexagonal prism 512	red	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:23.478008
2305	cylinder 679	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:23.479822
2306	pentagonal prism 737	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:23.69746
2307	cube 668	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:23.701167
2308	pentagonal prism 738	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:56:23.703399
2309	cylinder 680	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:23.705562
2310	pentagonal prism 739	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:23.934177
2311	cube 669	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:56:23.93805
2312	hexagonal prism 513	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:23.941391
2313	cylinder 681	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:23.944104
2314	pentagonal prism 740	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:24.171292
2315	cube 670	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.420776	cube.usd	2025-03-29 14:56:24.174866
2316	hexagonal prism 514	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:24.177106
2317	cylinder 682	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:24.17897
2318	pentagonal prism 741	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:24.388178
2319	cube 671	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:24.390673
2320	hexagonal prism 515	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:24.392777
2321	cylinder 683	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:24.39466
2322	pentagonal prism 742	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:24.612331
2323	cube 672	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 14:56:24.614629
2324	hexagonal prism 516	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:24.616496
2325	cylinder 684	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:24.618493
2326	pentagonal prism 743	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:24.833533
2327	cube 673	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:24.837138
2328	hexagonal prism 517	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:24.839058
2329	cylinder 685	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:24.841041
2330	pentagonal prism 744	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:25.068304
2331	cube 674	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03624	cube.usd	2025-03-29 14:56:25.071841
2332	hexagonal prism 518	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:25.073867
2333	cylinder 686	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:25.075726
2334	pentagonal prism 745	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:25.296749
2335	cube 675	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:25.300381
2336	cylinder 687	red	{0,0,0}	30.395967	260.81702	924	0	0	37.568592	cylinder.usd	2025-03-29 14:56:25.302501
2337	cylinder 688	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:25.30475
2338	pentagonal prism 746	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:25.529731
2339	cube 676	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:25.533103
2340	hexagonal prism 519	red	{0,0,0}	30.51353	260.84146	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:25.535144
2341	cylinder 689	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:25.537203
2342	pentagonal prism 747	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:25.761868
2343	cube 677	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:25.766648
2344	cylinder 690	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:56:25.770061
2345	cylinder 691	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:25.773199
2346	pentagonal prism 748	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:56:25.992248
2347	cube 678	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:25.99472
2348	hexagonal prism 520	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:25.996535
2349	cylinder 692	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:25.998228
2350	pentagonal prism 749	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:26.214668
2351	cube 679	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.743565	cube.usd	2025-03-29 14:56:26.216929
2352	hexagonal prism 521	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:26.219065
2353	cylinder 693	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:26.221745
2354	pentagonal prism 750	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:26.433189
2355	cube 680	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:26.435465
2356	cylinder 694	red	{0,0,0}	30.395967	260.81702	924	0	0	37.405357	cylinder.usd	2025-03-29 14:56:26.438046
2357	cylinder 695	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:26.440158
2358	pentagonal prism 751	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:26.666081
2359	cube 681	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:26.669774
2360	hexagonal prism 522	red	{0,0,0}	29.53035	261.83575	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:26.671775
2361	cylinder 696	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:26.673628
2362	pentagonal prism 752	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:26.892532
2363	cube 682	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:26.89554
2364	hexagonal prism 523	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:26.897409
2365	cylinder 697	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:26.899268
2366	pentagonal prism 753	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:27.118208
2367	cube 683	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:27.120818
2368	hexagonal prism 524	red	{0,0,0}	30.394815	260.80713	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:27.122908
2369	cylinder 698	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:27.124734
2370	pentagonal prism 754	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:27.34863
2371	cube 684	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:27.350717
2372	hexagonal prism 525	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:27.352588
2373	cylinder 699	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:27.354487
2374	pentagonal prism 755	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:27.566287
2375	cube 685	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:27.568706
2376	hexagonal prism 526	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:27.571034
2377	cylinder 700	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:27.573015
2378	pentagonal prism 756	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:27.798039
2379	cube 686	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:56:27.800438
2380	cylinder 701	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:56:27.802419
2381	cylinder 702	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:27.804619
2382	pentagonal prism 757	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:28.017914
2383	cube 687	pink	{0,0,0}	-206.88867	345.1413	934	0	0	59.620872	cube.usd	2025-03-29 14:56:28.020475
2384	pentagonal prism 758	red	{0,0,0}	30.395967	260.81702	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:56:28.022867
2385	cylinder 703	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:28.024954
2386	pentagonal prism 759	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:28.240204
2387	cube 688	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:28.244498
2388	hexagonal prism 527	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:28.24651
2389	cylinder 704	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:56:28.248407
2390	pentagonal prism 760	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:28.461875
2391	cube 689	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.743565	cube.usd	2025-03-29 14:56:28.46407
2392	hexagonal prism 528	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:28.465996
2393	cylinder 705	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:28.467923
2394	pentagonal prism 761	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:28.684429
2395	cube 690	pink	{0,0,0}	-206.88867	345.1413	927.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:28.687004
2396	hexagonal prism 529	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:28.68926
2397	cylinder 706	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:28.691504
2398	pentagonal prism 762	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	pentagonal prism.usd	2025-03-29 14:56:28.917061
2399	cube 691	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03625	cube.usd	2025-03-29 14:56:28.920658
2400	pentagonal prism 763	red	{0,0,0}	29.53035	261.83575	919	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:56:28.922722
2401	cylinder 707	green	{0,0,0}	-272.66354	217.54024	924	0	0	33.690063	cylinder.usd	2025-03-29 14:56:28.925079
2402	pentagonal prism 764	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:29.136697
2403	cube 692	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:29.139506
2404	hexagonal prism 530	red	{0,0,0}	30.394815	260.80713	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:29.141486
2405	cylinder 708	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:29.143459
2406	pentagonal prism 765	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:29.372572
2407	cube 693	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:56:29.377799
2408	hexagonal prism 531	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:29.38123
2409	cylinder 709	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:29.384207
2410	pentagonal prism 766	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:29.629465
2411	cube 694	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:29.633131
2412	hexagonal prism 532	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:29.635135
2413	cylinder 710	green	{0,0,0}	-270.62216	216.69383	929	0	0	45	cylinder.usd	2025-03-29 14:56:29.637184
2414	pentagonal prism 767	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:29.856819
2415	cube 695	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:56:29.860244
2416	hexagonal prism 533	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:29.862031
2417	cylinder 711	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:29.86373
2418	pentagonal prism 768	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:30.079948
2419	cube 696	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 14:56:30.083542
2420	pentagonal prism 769	red	{0,0,0}	30.394815	260.80713	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:56:30.085409
2421	cylinder 712	green	{0,0,0}	-270.6119	216.68562	943	0	0	33.690063	cylinder.usd	2025-03-29 14:56:30.087255
2422	pentagonal prism 770	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:30.307037
2423	cube 697	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:56:30.311211
2424	hexagonal prism 534	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:30.31315
2425	cylinder 713	green	{0,0,0}	-270.62216	216.69383	929	0	0	33.690063	cylinder.usd	2025-03-29 14:56:30.315018
2426	pentagonal prism 771	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:30.527526
2427	cube 698	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:30.529968
2428	cube 699	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.405357	cube.usd	2025-03-29 14:56:30.531824
2429	cylinder 714	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:56:30.533686
2430	pentagonal prism 772	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:30.747822
2431	cube 700	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.420776	cube.usd	2025-03-29 14:56:30.750187
2432	hexagonal prism 535	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:30.752027
2433	cylinder 715	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:30.753816
2434	pentagonal prism 773	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:30.979542
2435	cube 701	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:30.98317
2436	hexagonal prism 536	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:30.985025
2437	cylinder 716	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:30.986897
2438	pentagonal prism 774	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:31.201013
2439	cube 702	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:31.2048
2440	pentagonal prism 775	red	{0,0,0}	30.395967	260.81702	937.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:56:31.207032
2441	cylinder 717	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:31.209079
2442	pentagonal prism 776	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:31.421162
2443	cube 703	pink	{0,0,0}	-205.90038	345.12823	915	0	0	60.255116	cube.usd	2025-03-29 14:56:31.423597
2444	hexagonal prism 537	red	{0,0,0}	31.375294	259.82666	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:31.425703
2445	cylinder 718	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:31.427493
2446	pentagonal prism 777	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:31.65261
2447	cube 704	pink	{0,0,0}	-208.68114	346.48944	919	0	0	59.03624	cube.usd	2025-03-29 14:56:31.656243
2448	hexagonal prism 538	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:31.658474
2449	cylinder 719	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	cylinder.usd	2025-03-29 14:56:31.660427
2450	pentagonal prism 778	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:31.874191
2451	cube 705	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:31.876362
2452	hexagonal prism 539	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:31.878363
2453	cylinder 720	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:31.880264
2454	pentagonal prism 779	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:32.105815
2455	cube 706	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:56:32.109606
2456	hexagonal prism 540	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:32.111621
2457	cylinder 721	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:32.113504
2458	pentagonal prism 780	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:32.336931
2459	cube 707	pink	{0,0,0}	-207.6968	346.48944	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:32.340629
2460	hexagonal prism 541	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:32.342669
2461	cylinder 722	green	{0,0,0}	-272.66354	217.54024	938	0	0	26.56505	cylinder.usd	2025-03-29 14:56:32.344581
2462	pentagonal prism 781	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:32.557666
2463	cube 708	pink	{0,0,0}	-205.90816	345.1413	940.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:32.560848
2464	hexagonal prism 542	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:32.562765
2465	cylinder 723	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:32.564601
2466	pentagonal prism 782	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:32.796353
2467	cube 709	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:56:32.798619
2468	hexagonal prism 543	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:32.801024
2469	cylinder 724	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:32.803429
2470	pentagonal prism 783	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:33.01809
2471	cube 710	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:33.020277
2472	hexagonal prism 544	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:33.022094
2473	cylinder 725	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:33.02399
2474	pentagonal prism 784	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:33.23796
2475	cube 711	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:33.240035
2476	hexagonal prism 545	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:33.242013
2477	cylinder 726	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:56:33.243952
2478	pentagonal prism 785	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:33.455323
2479	cube 712	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.743565	cube.usd	2025-03-29 14:56:33.45795
2480	hexagonal prism 546	red	{0,0,0}	30.394815	260.80713	940.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:33.459972
2481	cylinder 727	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:56:33.461853
2482	pentagonal prism 786	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:33.688217
2483	cube 713	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:33.691792
2484	hexagonal prism 547	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:33.694045
2485	cylinder 728	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:33.695967
2486	pentagonal prism 787	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:33.919727
2487	cube 714	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:33.923376
2488	hexagonal prism 548	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:33.925227
2489	cylinder 729	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:56:33.92733
2490	pentagonal prism 788	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:34.137844
2491	cube 715	pink	{0,0,0}	-208.68114	346.48944	929	0	0	59.420776	cube.usd	2025-03-29 14:56:34.140251
2492	hexagonal prism 549	red	{0,0,0}	30.514694	260.8514	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:34.142129
2493	cylinder 730	green	{0,0,0}	-272.66354	217.54024	933	0	0	26.56505	cylinder.usd	2025-03-29 14:56:34.144215
2494	pentagonal prism 789	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:56:34.357997
2495	cube 716	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:34.360584
2496	hexagonal prism 550	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:34.362554
2497	cylinder 731	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:34.364399
2498	pentagonal prism 790	black	{0,0,0}	-127.96484	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:34.589556
2499	cube 717	pink	{0,0,0}	-206.71245	346.48944	924	0	0	59.03625	cube.usd	2025-03-29 14:56:34.593477
2500	hexagonal prism 551	red	{0,0,0}	31.499039	260.8514	933	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:34.59681
2501	cylinder 732	green	{0,0,0}	-271.6792	217.54024	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:34.599547
2502	pentagonal prism 791	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:34.821808
2503	cube 718	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:34.825407
2504	hexagonal prism 552	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:34.827398
2505	cylinder 733	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:34.829389
2506	pentagonal prism 792	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:35.039519
2507	cube 719	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:35.041855
2508	hexagonal prism 553	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:35.043948
2509	cylinder 734	green	{0,0,0}	-270.62216	216.69383	933	0	0	33.690063	cylinder.usd	2025-03-29 14:56:35.045895
2510	pentagonal prism 793	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:35.257728
2511	cube 720	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:56:35.260204
2512	hexagonal prism 554	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:35.262267
2513	cylinder 735	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:35.264082
2514	pentagonal prism 794	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:35.488255
2515	cube 721	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:35.490744
2516	hexagonal prism 555	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:35.4928
2517	cylinder 736	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:35.494762
2518	pentagonal prism 795	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:35.707103
2519	cube 722	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.620872	cube.usd	2025-03-29 14:56:35.70948
2520	hexagonal prism 556	red	{0,0,0}	30.514694	260.8514	925.00006	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:56:35.711646
2521	cylinder 737	green	{0,0,0}	-272.66354	217.54024	941.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:35.713505
2522	pentagonal prism 796	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:35.937841
2523	cube 723	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.620872	cube.usd	2025-03-29 14:56:35.941139
2524	hexagonal prism 557	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:35.943067
2525	cylinder 738	green	{0,0,0}	-270.62216	216.69383	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:35.945105
2526	pentagonal prism 797	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:36.166304
2527	cube 724	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.743565	cube.usd	2025-03-29 14:56:36.168737
2528	hexagonal prism 558	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:36.170758
2529	cylinder 739	green	{0,0,0}	-270.62216	216.69383	934	0	0	36.869896	cylinder.usd	2025-03-29 14:56:36.172603
2530	pentagonal prism 798	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:36.390443
2531	cube 725	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:56:36.394376
2532	hexagonal prism 559	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:36.396685
2533	cylinder 740	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:36.398597
2534	pentagonal prism 799	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:36.627559
2535	cube 726	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:56:36.631473
2536	hexagonal prism 560	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:36.633617
2537	cylinder 741	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:36.63555
2538	pentagonal prism 800	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:36.860719
2539	cube 727	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:36.863295
2540	hexagonal prism 561	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:36.865289
2541	cylinder 742	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:36.867156
2542	pentagonal prism 801	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:37.091961
2543	cube 728	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:56:37.095346
2544	hexagonal prism 562	red	{0,0,0}	31.376482	259.8365	915	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:37.097324
2545	cylinder 743	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:37.099082
2546	pentagonal prism 802	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:37.32023
2547	cube 729	pink	{0,0,0}	-207.6968	346.48944	918.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:37.323689
2548	hexagonal prism 563	red	{0,0,0}	30.514694	260.8514	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:37.325669
2549	cylinder 744	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:37.327592
2550	pentagonal prism 803	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:37.548281
2551	cube 730	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:56:37.55188
2552	hexagonal prism 564	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:37.553761
2553	cylinder 745	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:37.555518
2554	pentagonal prism 804	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:37.772739
2555	cube 731	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:37.776487
2556	cylinder 746	red	{0,0,0}	30.394815	260.80713	926.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:56:37.77834
2557	cylinder 747	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:37.780393
2558	pentagonal prism 805	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:37.994003
2559	cube 732	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:37.997052
2560	hexagonal prism 565	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:37.99892
2561	cylinder 748	green	{0,0,0}	-270.62216	216.69383	916.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:38.000718
2562	pentagonal prism 806	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:56:38.227367
2563	cube 733	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:38.229787
2564	hexagonal prism 566	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:38.231671
2565	cylinder 749	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:38.23347
2566	pentagonal prism 807	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:38.448275
2567	cube 734	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.931416	cube.usd	2025-03-29 14:56:38.452385
2568	hexagonal prism 567	red	{0,0,0}	30.395967	260.81702	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:38.454499
2569	cylinder 750	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:38.45653
2570	pentagonal prism 808	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:38.679592
2571	cube 735	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:38.684058
2572	cube 736	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 14:56:38.686354
2573	cylinder 751	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:56:38.688414
2574	pentagonal prism 809	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:38.930215
2575	cube 737	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:56:38.932534
2576	cylinder 752	red	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	cylinder.usd	2025-03-29 14:56:38.934512
2577	cylinder 753	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:56:38.93642
2578	pentagonal prism 810	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:39.171539
2579	cube 738	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:39.175963
2580	hexagonal prism 568	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:39.17824
2581	cylinder 754	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:39.181034
2582	pentagonal prism 811	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:39.409977
2583	cube 739	pink	{0,0,0}	-206.88867	345.1413	904.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:39.412385
2584	hexagonal prism 569	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:39.414338
2585	cylinder 755	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	cylinder.usd	2025-03-29 14:56:39.41631
2586	pentagonal prism 812	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:39.629726
2587	cube 740	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:56:39.632687
2588	hexagonal prism 570	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:39.63463
2589	cylinder 756	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:39.63638
2590	pentagonal prism 813	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:39.855928
2591	cube 741	pink	{0,0,0}	-206.88867	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:39.858072
2592	hexagonal prism 571	red	{0,0,0}	30.395967	260.81702	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:39.859943
2593	cylinder 757	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:39.861824
2594	pentagonal prism 814	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:40.074146
2595	cube 742	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:40.07632
2596	hexagonal prism 572	red	{0,0,0}	31.375294	259.82666	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:40.078258
2597	cylinder 758	green	{0,0,0}	-270.6119	216.68562	934	0	0	18.434948	cylinder.usd	2025-03-29 14:56:40.08013
2598	pentagonal prism 815	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:40.291686
2599	cube 743	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:56:40.295445
2600	pentagonal prism 816	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:56:40.297587
2601	cylinder 759	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:40.299727
2602	pentagonal prism 817	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:40.521036
2603	cube 744	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:40.526022
2604	pentagonal prism 818	red	{0,0,0}	30.394815	260.80713	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:56:40.528079
2605	cylinder 760	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:40.530244
2606	pentagonal prism 819	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:40.745287
2607	cube 745	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.620872	cube.usd	2025-03-29 14:56:40.749084
2608	cylinder 761	red	{0,0,0}	30.395967	260.81702	936.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:56:40.75159
2609	cylinder 762	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:40.753702
2610	pentagonal prism 820	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:40.976747
2611	cube 746	pink	{0,0,0}	-205.90816	345.1413	909.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:40.979225
2612	hexagonal prism 573	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:40.981022
2613	cylinder 763	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:40.983194
2614	pentagonal prism 821	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:41.203736
2615	cube 747	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:41.207548
2616	hexagonal prism 574	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:41.20945
2617	cylinder 764	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:41.211265
2618	pentagonal prism 822	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:41.422787
2619	cube 748	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:41.426437
2620	hexagonal prism 575	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:41.428391
2621	cylinder 765	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:41.430227
2622	pentagonal prism 823	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:41.641264
2623	cube 749	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:56:41.645685
2624	hexagonal prism 576	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:41.647799
2625	cylinder 766	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:41.649656
2626	pentagonal prism 824	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:41.880211
2627	cube 750	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:41.88249
2628	hexagonal prism 577	red	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:41.884823
2629	cylinder 767	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:56:41.886966
2630	pentagonal prism 825	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:42.096435
2631	cube 751	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:42.099238
2632	hexagonal prism 578	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:42.101354
2633	cylinder 768	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:42.103296
2634	pentagonal prism 826	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:42.315159
2635	cube 752	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.420776	cube.usd	2025-03-29 14:56:42.318241
2636	cylinder 769	red	{0,0,0}	30.395967	260.81702	924	0	0	37.405357	cylinder.usd	2025-03-29 14:56:42.320531
2637	cylinder 770	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:42.322472
2638	pentagonal prism 827	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:42.54883
2639	cube 753	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:42.552808
2640	hexagonal prism 579	red	{0,0,0}	31.376482	259.8365	915	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:42.554801
2641	cylinder 771	green	{0,0,0}	-270.62216	216.69383	929	0	0	45	cylinder.usd	2025-03-29 14:56:42.556694
2642	pentagonal prism 828	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:42.783922
2643	cube 754	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03625	cube.usd	2025-03-29 14:56:42.787645
2644	hexagonal prism 580	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:42.789518
2645	cylinder 772	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:42.791323
2646	pentagonal prism 829	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:43.015194
2647	cube 755	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03625	cube.usd	2025-03-29 14:56:43.017437
2648	hexagonal prism 581	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:43.01943
2649	cylinder 773	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:43.021446
2650	pentagonal prism 830	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:43.246579
2651	cube 756	pink	{0,0,0}	-208.68114	346.48944	920	0	0	59.03625	cube.usd	2025-03-29 14:56:43.248847
2652	hexagonal prism 582	red	{0,0,0}	30.514694	260.8514	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:43.250848
2653	cylinder 774	green	{0,0,0}	-272.66354	217.54024	924	0	0	18.434948	cylinder.usd	2025-03-29 14:56:43.253361
2654	pentagonal prism 831	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:43.463461
2655	cube 757	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:43.465786
2656	hexagonal prism 583	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:43.468125
2657	cylinder 775	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:43.470024
2658	pentagonal prism 832	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:43.69096
2659	cube 758	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:43.693657
2660	pentagonal prism 833	red	{0,0,0}	30.395967	260.81702	939.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:56:43.695585
2661	cylinder 776	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:43.697431
2662	pentagonal prism 834	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:43.912448
2663	cube 759	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	cube.usd	2025-03-29 14:56:43.916461
2664	pentagonal prism 835	red	{0,0,0}	30.395967	260.81702	934	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:56:43.918758
2665	cylinder 777	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:43.92106
2666	pentagonal prism 836	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:44.14721
2667	cube 760	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:44.151012
2668	hexagonal prism 584	red	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:44.153437
2669	cylinder 778	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:56:44.155414
2670	pentagonal prism 837	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:44.379045
2671	cube 761	pink	{0,0,0}	-206.88867	345.1413	917.00006	0	0	59.620872	cube.usd	2025-03-29 14:56:44.382928
2672	hexagonal prism 585	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:44.38521
2673	cylinder 779	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:44.387149
2674	pentagonal prism 838	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:44.59838
2675	cube 762	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	cube.usd	2025-03-29 14:56:44.600725
2676	hexagonal prism 586	red	{0,0,0}	30.395967	260.81702	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:44.602702
2677	cylinder 780	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:44.604655
2678	pentagonal prism 839	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:44.816844
2679	cube 763	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:44.819767
2680	hexagonal prism 587	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:44.821988
2681	cylinder 781	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:56:44.823963
2682	pentagonal prism 840	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:45.05772
2683	cube 764	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.420776	cube.usd	2025-03-29 14:56:45.060103
2684	hexagonal prism 588	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:45.061912
2685	cylinder 782	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:56:45.063825
2686	pentagonal prism 841	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:45.278751
2687	cube 765	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03625	cube.usd	2025-03-29 14:56:45.281081
2688	hexagonal prism 589	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:45.282965
2689	cylinder 783	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:45.284712
2690	pentagonal prism 842	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:45.511941
2691	cube 766	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:45.517292
2692	hexagonal prism 590	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:45.520421
2693	cylinder 784	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:56:45.523714
2694	pentagonal prism 843	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:45.751447
2695	cube 767	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:56:45.755221
2696	hexagonal prism 591	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:45.757141
2697	cylinder 785	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:45.758932
2698	pentagonal prism 844	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:45.986527
2699	cube 768	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:56:45.990409
2700	hexagonal prism 592	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:45.992251
2701	cylinder 786	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:45.994238
2702	pentagonal prism 845	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:46.219156
2703	cube 769	pink	{0,0,0}	-206.88867	345.1413	913.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:46.223105
2704	hexagonal prism 593	red	{0,0,0}	30.395967	260.81702	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:46.225128
2705	cylinder 787	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:46.227016
2706	pentagonal prism 846	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:46.449331
2707	cube 770	pink	{0,0,0}	-206.88867	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:56:46.451664
2708	hexagonal prism 594	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:46.453794
2709	cylinder 788	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:46.456084
2710	pentagonal prism 847	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:46.670309
2711	cube 771	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:56:46.673959
2712	hexagonal prism 595	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:46.676135
2713	cylinder 789	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:46.678052
2714	pentagonal prism 848	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:46.900163
2715	cube 772	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:46.902659
2716	hexagonal prism 596	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:46.904944
2717	cylinder 790	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:46.906864
2718	pentagonal prism 849	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:47.119637
2719	cube 773	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:47.122324
2720	hexagonal prism 597	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:47.124336
2721	cylinder 791	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:47.126191
2722	pentagonal prism 850	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:47.346765
2723	cube 774	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.03625	cube.usd	2025-03-29 14:56:47.350616
2724	hexagonal prism 598	red	{0,0,0}	30.514694	260.8514	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:47.352686
2725	cylinder 792	green	{0,0,0}	-272.66354	217.54024	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:47.354567
2726	pentagonal prism 851	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:47.565179
2727	cube 775	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:56:47.568487
2728	pentagonal prism 852	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:56:47.570388
2729	cylinder 793	green	{0,0,0}	-270.62216	216.69383	919	0	0	33.690063	cylinder.usd	2025-03-29 14:56:47.572459
2730	pentagonal prism 853	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:47.782809
2731	cube 776	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:47.785205
2732	hexagonal prism 599	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:47.787381
2733	cylinder 794	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:47.789371
2734	pentagonal prism 854	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:47.999747
2735	cube 777	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:48.002135
2736	pentagonal prism 855	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:56:48.004089
2737	cylinder 795	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:48.006645
2738	pentagonal prism 856	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:48.221318
2739	cube 778	pink	{0,0,0}	-207.6968	346.48944	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:48.224592
2740	hexagonal prism 600	red	{0,0,0}	30.514694	260.8514	935.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:48.226454
2741	cylinder 796	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:48.228238
2742	pentagonal prism 857	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:48.45756
2743	cube 779	pink	{0,0,0}	-206.88867	345.1413	934	0	0	59.03624	cube.usd	2025-03-29 14:56:48.460378
2744	hexagonal prism 601	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:48.46257
2745	cylinder 797	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:48.464531
2746	pentagonal prism 858	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:48.691239
2747	cube 780	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.620872	cube.usd	2025-03-29 14:56:48.69508
2748	hexagonal prism 602	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:48.696984
2749	cylinder 798	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:48.69886
2750	pentagonal prism 859	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:48.914672
2751	cube 781	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:48.918482
2752	hexagonal prism 603	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:48.920335
2753	cylinder 799	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:48.922255
2754	pentagonal prism 860	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:49.137423
2755	cube 782	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:56:49.14075
2756	hexagonal prism 604	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:49.143225
2757	cylinder 800	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:49.145464
2758	pentagonal prism 861	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:49.3698
2759	cube 783	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.34933	cube.usd	2025-03-29 14:56:49.372336
2760	cube 784	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	cube.usd	2025-03-29 14:56:49.374617
2761	cylinder 801	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:49.376531
2762	pentagonal prism 862	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:49.608028
2763	cube 785	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:49.611539
2764	hexagonal prism 605	red	{0,0,0}	31.375294	259.82666	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:49.613606
2765	cylinder 802	green	{0,0,0}	-270.6119	216.68562	920	0	0	36.869896	cylinder.usd	2025-03-29 14:56:49.615403
2766	pentagonal prism 863	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:49.835896
2767	cube 786	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:56:49.838936
2768	hexagonal prism 606	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:49.841109
2769	cylinder 803	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:49.843097
2770	pentagonal prism 864	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:50.067965
2771	cube 787	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:50.071527
2772	hexagonal prism 607	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:50.07356
2773	cylinder 804	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:50.075472
2774	pentagonal prism 865	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:50.297279
2775	cube 788	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.743565	cube.usd	2025-03-29 14:56:50.300175
2776	hexagonal prism 608	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:50.302135
2777	cylinder 805	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:50.304009
2778	pentagonal prism 866	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:50.538324
2779	cube 789	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:50.541046
2780	cylinder 806	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.874985	cylinder.usd	2025-03-29 14:56:50.542988
2781	cylinder 807	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:50.544912
2782	pentagonal prism 867	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:50.768
2783	cube 790	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:56:50.771696
2784	hexagonal prism 609	red	{0,0,0}	30.394815	260.80713	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:50.774086
2785	cylinder 808	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:50.776052
2786	pentagonal prism 868	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:51.00327
2787	cube 791	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 14:56:51.007341
2788	hexagonal prism 610	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:51.009485
2789	cylinder 809	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 14:56:51.011262
2790	pentagonal prism 869	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:51.237957
2791	cube 792	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03624	cube.usd	2025-03-29 14:56:51.242281
2792	hexagonal prism 611	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:51.245248
2793	cylinder 810	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:51.248001
2794	pentagonal prism 870	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:51.480442
2795	cube 793	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.34933	cube.usd	2025-03-29 14:56:51.484025
2796	hexagonal prism 612	red	{0,0,0}	30.395967	260.81702	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:51.486667
2797	cylinder 811	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:51.488642
2798	pentagonal prism 871	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:51.698752
2799	cube 794	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.420776	cube.usd	2025-03-29 14:56:51.701418
2800	hexagonal prism 613	red	{0,0,0}	29.53035	261.83575	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:51.703442
2801	cylinder 812	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	cylinder.usd	2025-03-29 14:56:51.705527
2802	pentagonal prism 872	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:51.91731
2803	cube 795	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:51.921493
2804	hexagonal prism 614	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:51.923614
2805	cylinder 813	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:51.925933
2806	pentagonal prism 873	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:52.13593
2807	cube 796	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:56:52.138705
2808	cylinder 814	red	{0,0,0}	30.395967	260.81702	937.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:56:52.140725
2809	cylinder 815	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:52.142735
2810	pentagonal prism 874	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:52.35999
2811	cube 797	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:52.362482
2812	hexagonal prism 615	red	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:52.364379
2813	cylinder 816	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:52.366191
2814	pentagonal prism 875	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:52.585262
2815	cube 798	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:52.588566
2816	hexagonal prism 616	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:52.590389
2817	cylinder 817	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	36.869896	cylinder.usd	2025-03-29 14:56:52.592294
2818	pentagonal prism 876	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:52.806575
2819	cube 799	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03625	cube.usd	2025-03-29 14:56:52.809404
2820	hexagonal prism 617	red	{0,0,0}	30.514694	260.8514	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:52.811545
2821	cylinder 818	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	33.690067	cylinder.usd	2025-03-29 14:56:52.814005
2822	pentagonal prism 877	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal prism.usd	2025-03-29 14:56:53.04151
2823	cube 800	pink	{0,0,0}	-207.6968	346.48944	927.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:53.044011
2824	hexagonal prism 618	red	{0,0,0}	29.53035	261.83575	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:53.046447
2825	cylinder 819	green	{0,0,0}	-272.66354	217.54024	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:53.048422
2826	pentagonal prism 878	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:53.269974
2827	cube 801	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03624	cube.usd	2025-03-29 14:56:53.2724
2828	cylinder 820	red	{0,0,0}	30.395967	260.81702	923.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:56:53.274375
2829	cylinder 821	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:56:53.276463
2830	pentagonal prism 879	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:53.489281
2831	cube 802	pink	{0,0,0}	-205.90816	345.1413	905.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:53.491693
2832	hexagonal prism 619	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:53.494391
2833	cylinder 822	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:56:53.496435
2834	pentagonal prism 880	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:53.722846
2835	cube 803	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:53.726582
2836	hexagonal prism 620	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:53.728813
2837	cylinder 823	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:53.730737
2838	pentagonal prism 881	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:53.951066
2839	cube 804	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:53.955457
2840	hexagonal prism 621	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:53.957346
2841	cylinder 824	green	{0,0,0}	-270.62216	217.67435	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:56:53.959243
2842	pentagonal prism 882	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:54.181449
2843	cube 805	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:56:54.185196
2844	hexagonal prism 622	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:54.187204
2845	cylinder 825	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:56:54.189056
2846	pentagonal prism 883	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:54.413336
2847	cube 806	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:56:54.416575
2848	hexagonal prism 623	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:54.418422
2849	cylinder 826	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:54.420252
2850	pentagonal prism 884	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:54.645433
2851	cube 807	pink	{0,0,0}	-206.88867	345.1413	930.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:54.648827
2852	hexagonal prism 624	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:54.650769
2853	cylinder 827	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:54.652668
2854	pentagonal prism 885	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:54.890058
2855	cube 808	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:54.894015
2856	hexagonal prism 625	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:54.896332
2857	cylinder 828	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:54.898397
2858	pentagonal prism 886	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:55.118908
2859	cube 809	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.743565	cube.usd	2025-03-29 14:56:55.122428
2860	hexagonal prism 626	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:55.124319
2861	cylinder 829	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:55.126116
2862	pentagonal prism 887	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:56:55.343709
2863	cube 810	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.34933	cube.usd	2025-03-29 14:56:55.3474
2864	hexagonal prism 627	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:55.349284
2865	cylinder 830	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:56:55.351101
2866	pentagonal prism 888	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:55.571356
2867	cube 811	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:56:55.575106
2868	hexagonal prism 628	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:55.577089
2869	cylinder 831	green	{0,0,0}	-270.62216	216.69383	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:55.579065
2870	pentagonal prism 889	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:55.792363
2871	cube 812	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.620872	cube.usd	2025-03-29 14:56:55.795078
2872	hexagonal prism 629	red	{0,0,0}	31.376482	259.8365	920	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:55.797262
2873	cylinder 832	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:55.799235
2874	pentagonal prism 890	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:56.026464
2875	cube 813	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:56.030726
2876	hexagonal prism 630	red	{0,0,0}	30.394815	260.80713	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:56.032795
2877	cylinder 833	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:56.034704
2878	pentagonal prism 891	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:56.26291
2879	cube 814	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:56:56.266648
2880	hexagonal prism 631	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:56.268535
2881	cylinder 834	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:56.270319
2882	pentagonal prism 892	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:56.492546
2883	cube 815	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:56.496701
2884	hexagonal prism 632	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:56.498872
2885	cylinder 835	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:56:56.500813
2886	pentagonal prism 893	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:56.725282
2887	cube 816	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:56:56.729058
2888	hexagonal prism 633	red	{0,0,0}	30.395967	260.81702	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:56.731335
2889	cylinder 836	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:56.733396
2890	pentagonal prism 894	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:56.957088
2891	cube 817	pink	{0,0,0}	-206.88867	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:56.95955
2892	hexagonal prism 634	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:56.961663
2893	cylinder 837	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:56.964146
2894	pentagonal prism 895	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:57.17772
2895	cube 818	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:57.180033
2896	hexagonal prism 635	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:56:57.181989
2897	cylinder 838	green	{0,0,0}	-270.62216	216.69383	934	0	0	33.690063	cylinder.usd	2025-03-29 14:56:57.183862
2898	pentagonal prism 896	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:56:57.409936
2899	cube 819	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:57.412168
2900	hexagonal prism 636	red	{0,0,0}	30.395967	260.81702	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:57.414318
2901	cylinder 839	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	33.690067	cylinder.usd	2025-03-29 14:56:57.416156
2902	pentagonal prism 897	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:57.628019
2903	cube 820	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:57.631605
2904	cylinder 840	red	{0,0,0}	30.395967	260.81702	929	0	0	37.874985	cylinder.usd	2025-03-29 14:56:57.633668
2905	cylinder 841	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:57.635555
2906	pentagonal prism 898	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:56:57.857147
2907	cube 821	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:57.860796
2908	hexagonal prism 637	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:57.863014
2909	cylinder 842	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:57.86534
2910	pentagonal prism 899	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:58.089141
2911	cube 822	pink	{0,0,0}	-205.90816	345.1413	909.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:58.091603
2912	hexagonal prism 638	red	{0,0,0}	30.395967	260.81702	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:58.093477
2913	cylinder 843	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:56:58.095285
2914	pentagonal prism 900	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:58.308364
2915	cube 823	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:58.310996
2916	hexagonal prism 639	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:58.313287
2917	cylinder 844	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 14:56:58.315434
2918	pentagonal prism 901	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:56:58.528044
2919	cube 824	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:56:58.530665
2920	hexagonal prism 640	red	{0,0,0}	31.376482	259.8365	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:58.533228
2921	cylinder 845	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:56:58.535376
2922	pentagonal prism 902	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal prism.usd	2025-03-29 14:56:58.767934
2923	cube 825	pink	{0,0,0}	-206.88867	345.1413	906	0	0	59.534454	cube.usd	2025-03-29 14:56:58.771245
2924	hexagonal prism 641	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:58.773277
2925	cylinder 846	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	90	cylinder.usd	2025-03-29 14:56:58.775223
2926	pentagonal prism 903	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:56:58.989785
2927	cube 826	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:56:58.993303
2928	hexagonal prism 642	red	{0,0,0}	31.376482	259.8365	920	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:56:58.995296
2929	cylinder 847	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:56:58.997168
2930	pentagonal prism 904	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:59.214179
2931	cube 827	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:59.216308
2932	pentagonal prism 905	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:56:59.218208
2933	cylinder 848	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 14:56:59.219978
2934	pentagonal prism 906	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:56:59.442899
2935	cube 828	pink	{0,0,0}	-206.88867	345.1413	928.00006	0	0	59.420776	cube.usd	2025-03-29 14:56:59.446463
2936	hexagonal prism 643	red	{0,0,0}	30.395967	260.81702	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:56:59.448597
2937	cylinder 849	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:59.450674
2938	pentagonal prism 907	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:59.665921
2939	cube 829	pink	{0,0,0}	-206.88867	345.1413	939.00006	0	0	59.03624	cube.usd	2025-03-29 14:56:59.669119
2940	pentagonal prism 908	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:56:59.670947
2941	cylinder 850	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:56:59.672951
2942	pentagonal prism 909	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:56:59.894051
2943	cube 830	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:56:59.897738
2944	hexagonal prism 644	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:56:59.901198
2945	cylinder 851	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:56:59.903115
2946	pentagonal prism 910	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:00.129977
2947	cube 831	pink	{0,0,0}	-206.88867	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:00.132738
2948	hexagonal prism 645	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:00.134789
2949	cylinder 852	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:00.136658
2950	pentagonal prism 911	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:00.367425
2951	cube 832	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.420776	cube.usd	2025-03-29 14:57:00.37106
2952	hexagonal prism 646	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:00.373014
2953	cylinder 853	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:00.374885
2954	pentagonal prism 912	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:00.600696
2955	cube 833	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:00.604399
2956	hexagonal prism 647	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:00.606707
2957	cylinder 854	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:57:00.608642
2958	pentagonal prism 913	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:00.831779
2959	cube 834	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.743565	cube.usd	2025-03-29 14:57:00.835143
2960	hexagonal prism 648	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:00.837689
2961	cylinder 855	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:57:00.840538
2962	pentagonal prism 914	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:01.075299
2963	cube 835	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.34933	cube.usd	2025-03-29 14:57:01.078818
2964	hexagonal prism 649	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:01.08079
2965	cylinder 856	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:01.082662
2966	pentagonal prism 915	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:01.29852
2967	cube 836	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:57:01.30096
2968	hexagonal prism 650	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:57:01.302883
2969	cylinder 857	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:01.304659
2970	pentagonal prism 916	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:01.530566
2971	cube 837	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:01.534617
2972	hexagonal prism 651	red	{0,0,0}	30.395967	260.81702	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:57:01.536573
2973	cylinder 858	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:01.538402
2974	pentagonal prism 917	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:01.764534
2975	cube 838	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:01.768533
2976	hexagonal prism 652	red	{0,0,0}	30.395967	260.81702	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:01.770529
2977	cylinder 859	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:01.772544
2978	pentagonal prism 918	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:02.00026
2979	cube 839	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:02.002859
2980	hexagonal prism 653	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:02.004652
2981	cylinder 860	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:57:02.006456
2982	pentagonal prism 919	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:57:02.231361
2983	cube 840	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:57:02.235454
2984	hexagonal prism 654	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:02.237457
2985	cylinder 861	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:02.239408
2986	pentagonal prism 920	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:02.467087
2987	cube 841	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:02.470815
2988	hexagonal prism 655	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:02.472784
2989	cylinder 862	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:02.474744
2990	pentagonal prism 921	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:02.703921
2991	cube 842	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:02.706396
2992	hexagonal prism 656	red	{0,0,0}	31.375294	259.82666	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:02.708314
2993	cylinder 863	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:02.710241
2994	pentagonal prism 922	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:02.929585
2995	cube 843	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:02.933331
2996	hexagonal prism 657	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:02.935624
2997	cylinder 864	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:02.937595
2998	pentagonal prism 923	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:03.164981
2999	cube 844	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:03.167298
3000	hexagonal prism 658	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:03.16933
3001	cylinder 865	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:03.171132
3002	pentagonal prism 924	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:03.38362
3003	cube 845	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:03.386704
3004	hexagonal prism 659	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:03.388605
3005	cylinder 866	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:03.390477
3006	pentagonal prism 925	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:03.611562
3007	cube 846	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.743565	cube.usd	2025-03-29 14:57:03.614085
3008	hexagonal prism 660	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:03.616252
3009	cylinder 867	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:57:03.6181
3010	pentagonal prism 926	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:03.83801
3011	cube 847	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03625	cube.usd	2025-03-29 14:57:03.841339
3012	hexagonal prism 661	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:03.843439
3013	cylinder 868	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	45	cylinder.usd	2025-03-29 14:57:03.84529
3014	pentagonal prism 927	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:04.071858
3015	cube 848	pink	{0,0,0}	-205.90038	345.12823	938	0	0	59.534454	cube.usd	2025-03-29 14:57:04.075566
3016	hexagonal prism 662	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:04.077468
3017	cylinder 869	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 14:57:04.079228
3018	pentagonal prism 928	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:57:04.299416
3019	cube 849	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:57:04.303381
3020	hexagonal prism 663	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:04.305367
3021	cylinder 870	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:04.307305
3022	pentagonal prism 929	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:04.532281
3023	cube 850	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:57:04.536455
3024	hexagonal prism 664	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:04.538515
3025	cylinder 871	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:04.540439
3026	pentagonal prism 930	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:04.775352
3027	cube 851	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.34933	cube.usd	2025-03-29 14:57:04.779039
3028	hexagonal prism 665	red	{0,0,0}	30.395967	260.81702	930.00006	0	0	37.476177	hexagonal prism.usd	2025-03-29 14:57:04.780976
3029	cylinder 872	green	{0,0,0}	-270.62216	216.69383	934	0	0	45	cylinder.usd	2025-03-29 14:57:04.782781
3030	pentagonal prism 931	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal prism.usd	2025-03-29 14:57:05.005103
3031	cube 852	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.620872	cube.usd	2025-03-29 14:57:05.00873
3032	hexagonal prism 666	red	{0,0,0}	30.394815	260.80713	937.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:05.010678
3033	cylinder 873	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:05.012595
3034	pentagonal prism 932	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:05.23423
3035	cube 853	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:57:05.23898
3036	hexagonal prism 667	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:05.241179
3037	cylinder 874	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:05.242989
3038	pentagonal prism 933	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:57:05.469365
3039	cube 854	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:05.471846
3040	hexagonal prism 668	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:05.474026
3041	cylinder 875	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:05.475907
3042	pentagonal prism 934	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:05.703264
3043	cube 855	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.534454	cube.usd	2025-03-29 14:57:05.706982
3044	hexagonal prism 669	red	{0,0,0}	30.514694	260.8514	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:05.708857
3045	cylinder 876	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:05.710795
3046	pentagonal prism 935	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:05.947812
3047	cube 856	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:57:05.951431
3048	hexagonal prism 670	red	{0,0,0}	31.376482	259.8365	933	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:05.953555
3049	cylinder 877	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:05.955468
3050	pentagonal prism 936	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:06.173284
3051	cube 857	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:06.175787
3052	hexagonal prism 671	red	{0,0,0}	30.51353	260.84146	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:06.177707
3053	cylinder 878	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:06.179579
3054	pentagonal prism 937	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:06.399645
3055	cube 858	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:06.403859
3056	hexagonal prism 672	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:06.405928
3057	cylinder 879	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:06.40792
3058	pentagonal prism 938	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:06.633645
3059	cube 859	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:06.638201
3060	hexagonal prism 673	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:06.640467
3061	cylinder 880	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:06.642361
3062	pentagonal prism 939	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:06.873008
3063	cube 860	pink	{0,0,0}	-208.68114	346.48944	920	0	0	59.03624	cube.usd	2025-03-29 14:57:06.875205
3064	hexagonal prism 674	red	{0,0,0}	29.53035	261.83575	921.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:06.877033
3065	cylinder 881	green	{0,0,0}	-272.66354	217.54024	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:06.878899
3066	pentagonal prism 940	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:07.094418
3067	cube 861	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:57:07.09798
3068	hexagonal prism 675	red	{0,0,0}	31.376482	259.8365	915	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:07.0999
3069	cylinder 882	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 14:57:07.101736
3070	pentagonal prism 941	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:07.316248
3071	cube 862	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:07.320089
3072	hexagonal prism 676	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:07.322451
3073	cylinder 883	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:07.32438
3074	pentagonal prism 942	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:07.536957
3075	cube 863	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:07.540283
3076	hexagonal prism 677	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.77569	hexagonal prism.usd	2025-03-29 14:57:07.542323
3077	cylinder 884	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:07.54425
3078	pentagonal prism 943	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:07.771664
3079	cube 864	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:07.776368
3080	hexagonal prism 678	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:07.778219
3081	cylinder 885	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:07.780086
3082	pentagonal prism 944	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:08.006766
3083	cube 865	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:08.010525
3084	hexagonal prism 679	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:08.012628
3085	cylinder 886	green	{0,0,0}	-270.62216	216.69383	934	0	0	33.690063	cylinder.usd	2025-03-29 14:57:08.01493
3086	pentagonal prism 945	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:08.252986
3087	cube 866	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:08.255468
3088	hexagonal prism 680	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:57:08.257364
3089	cylinder 887	green	{0,0,0}	-270.62216	216.69383	929	0	0	36.869896	cylinder.usd	2025-03-29 14:57:08.259249
3090	pentagonal prism 946	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:08.490993
3091	cube 867	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:57:08.494621
3092	hexagonal prism 681	red	{0,0,0}	30.395967	260.81702	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:08.496533
3093	cylinder 888	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:08.498412
3094	pentagonal prism 947	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:08.717643
3095	cube 868	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:57:08.721471
3096	pentagonal prism 948	red	{0,0,0}	30.395967	260.81702	934	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:57:08.723632
3097	cylinder 889	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:08.725516
3098	pentagonal prism 949	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 14:57:08.950957
3099	cube 869	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:57:08.953173
3100	hexagonal prism 682	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:08.955465
3101	cylinder 890	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:08.95752
3102	pentagonal prism 950	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:09.171352
3103	cube 870	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:09.174397
3104	hexagonal prism 683	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:09.176404
3105	cylinder 891	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:09.178295
3106	pentagonal prism 951	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:09.414775
3107	cube 871	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:09.417622
3108	pentagonal prism 952	red	{0,0,0}	30.394815	260.80713	922.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:57:09.419608
3109	cylinder 892	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:09.421458
3110	pentagonal prism 953	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:09.638903
3111	cube 872	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:09.641941
3112	hexagonal prism 684	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:09.64386
3113	cylinder 893	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:09.645735
3114	pentagonal prism 954	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:09.871762
3115	cube 873	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:09.875367
3116	hexagonal prism 685	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:09.877483
3117	cylinder 894	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:09.879441
3118	pentagonal prism 955	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:10.10028
3119	cube 874	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:10.102634
3120	hexagonal prism 686	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:10.104537
3121	cylinder 895	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:57:10.10669
3122	pentagonal prism 956	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:10.319751
3123	cube 875	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:57:10.322194
3124	hexagonal prism 687	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:10.324402
3125	cylinder 896	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:10.326499
3126	pentagonal prism 957	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:10.536609
3127	cube 876	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:57:10.539255
3128	hexagonal prism 688	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:10.54205
3129	cylinder 897	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:10.544172
3130	pentagonal prism 958	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:57:10.767425
3131	cube 877	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:57:10.771184
3132	hexagonal prism 689	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:10.77321
3133	cylinder 898	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:10.775542
3134	pentagonal prism 959	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:10.987409
3135	cube 878	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:57:10.989656
3136	hexagonal prism 690	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:10.991646
3137	cylinder 899	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:10.99363
3138	pentagonal prism 960	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:11.204498
3139	cube 879	pink	{0,0,0}	-205.90816	345.1413	938	0	0	59.03625	cube.usd	2025-03-29 14:57:11.207516
3140	hexagonal prism 691	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:11.209922
3141	cylinder 900	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:11.211884
3142	pentagonal prism 961	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:11.441126
3143	cube 880	pink	{0,0,0}	-206.88867	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:11.445035
3144	hexagonal prism 692	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:11.446972
3145	cylinder 901	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:11.448751
3146	pentagonal prism 962	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:11.674718
3147	cube 881	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03625	cube.usd	2025-03-29 14:57:11.678215
3148	hexagonal prism 693	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:11.680201
3149	cylinder 902	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:11.682036
3150	pentagonal prism 963	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:11.908594
3151	cube 882	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:11.912444
3152	hexagonal prism 694	red	{0,0,0}	31.376482	259.8365	929	0	0	37.476177	hexagonal prism.usd	2025-03-29 14:57:11.914284
3153	cylinder 903	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:11.916125
3154	pentagonal prism 964	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:57:12.142328
3155	cube 883	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:57:12.146149
3156	hexagonal prism 695	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:12.148089
3157	cylinder 904	green	{0,0,0}	-270.62216	216.69383	929	0	0	36.869896	cylinder.usd	2025-03-29 14:57:12.149888
3158	pentagonal prism 965	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:12.371296
3159	cube 884	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:12.375297
3160	pentagonal prism 966	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:57:12.377763
3161	cylinder 905	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:12.379698
3162	pentagonal prism 967	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:12.59207
3163	cube 885	pink	{0,0,0}	-206.88867	345.1413	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:12.594987
3164	hexagonal prism 696	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:12.596861
3165	cylinder 906	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:12.598634
3166	pentagonal prism 968	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:12.823799
3167	cube 886	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:57:12.827735
3168	hexagonal prism 697	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:12.829669
3169	cylinder 907	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:12.83159
3170	pentagonal prism 969	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:13.056654
3171	cube 887	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 14:57:13.059092
3172	hexagonal prism 698	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:13.061135
3173	cylinder 908	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:13.063041
3174	pentagonal prism 970	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:13.292258
3175	cube 888	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.34933	cube.usd	2025-03-29 14:57:13.294723
3176	hexagonal prism 699	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:13.296637
3177	cylinder 909	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:13.298488
3178	pentagonal prism 971	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:13.523622
3179	cube 889	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:57:13.526535
3180	hexagonal prism 700	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:13.528809
3181	cylinder 910	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:13.530857
3182	pentagonal prism 972	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:13.755139
3183	cube 890	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 14:57:13.757795
3184	hexagonal prism 701	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:13.759688
3185	cylinder 911	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:13.761945
3186	pentagonal prism 973	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:13.9769
3187	cube 891	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:57:13.979812
3188	hexagonal prism 702	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:13.981787
3189	cylinder 912	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:13.983708
3190	pentagonal prism 974	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:14.210024
3191	cube 892	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:14.213428
3192	hexagonal prism 703	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:14.215393
3193	cylinder 913	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:14.217226
3194	pentagonal prism 975	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:14.439497
3195	cube 893	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:14.443721
3196	hexagonal prism 704	red	{0,0,0}	30.51353	260.84146	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:14.445809
3197	cylinder 914	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:14.447745
3198	pentagonal prism 976	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:14.660108
3199	cube 894	pink	{0,0,0}	-206.88867	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:14.662864
3200	hexagonal prism 705	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:14.664762
3201	cylinder 915	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:14.666643
3202	pentagonal prism 977	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:14.893667
3203	cube 895	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:14.895953
3204	hexagonal prism 706	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:14.897995
3205	cylinder 916	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:14.900241
3206	pentagonal prism 978	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:15.123107
3207	cube 896	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:15.127422
3208	hexagonal prism 707	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:15.129387
3209	cylinder 917	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:15.131252
3210	pentagonal prism 979	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:15.344499
3211	cube 897	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03625	cube.usd	2025-03-29 14:57:15.347686
3212	hexagonal prism 708	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:15.349629
3213	cylinder 918	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:15.35148
3214	pentagonal prism 980	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:15.580566
3215	cube 898	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:15.584118
3216	hexagonal prism 709	red	{0,0,0}	31.376482	259.8365	938	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:15.586104
3217	cylinder 919	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:15.588051
3218	pentagonal prism 981	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:15.812543
3219	cube 899	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:15.816255
3220	hexagonal prism 710	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:15.818243
3221	cylinder 920	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:15.820096
3222	pentagonal prism 982	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:16.053067
3223	cube 900	pink	{0,0,0}	-206.88867	345.1413	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:16.056728
3224	hexagonal prism 711	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:16.058868
3225	cylinder 921	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:16.060771
3226	pentagonal prism 983	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:16.286295
3227	cube 901	pink	{0,0,0}	-206.88867	345.1413	917.00006	0	0	59.743565	cube.usd	2025-03-29 14:57:16.288844
3228	hexagonal prism 712	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:16.290937
3229	cylinder 922	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:16.292849
3230	pentagonal prism 984	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:16.512146
3231	cube 902	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:16.515958
3232	hexagonal prism 713	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:16.517905
3233	cylinder 923	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:16.519727
3234	pentagonal prism 985	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:16.741176
3235	cube 903	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:16.743877
3236	hexagonal prism 714	red	{0,0,0}	31.375294	259.82666	920	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:57:16.74605
3237	cylinder 924	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	33.690067	cylinder.usd	2025-03-29 14:57:16.748294
3238	pentagonal prism 986	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:16.973393
3239	cube 904	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.534454	cube.usd	2025-03-29 14:57:16.976022
3240	hexagonal prism 715	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:16.978712
3241	cylinder 925	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:16.981244
3242	pentagonal prism 987	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:57:17.203775
3243	cube 905	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:17.207376
3244	hexagonal prism 716	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:17.209437
3245	cylinder 926	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:17.211482
3246	pentagonal prism 988	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:17.426852
3247	cube 906	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:17.429815
3248	hexagonal prism 717	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:17.431791
3249	cylinder 927	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:17.43373
3250	pentagonal prism 989	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:17.660004
3251	cube 907	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.62088	cube.usd	2025-03-29 14:57:17.662172
3252	hexagonal prism 718	red	{0,0,0}	30.395967	260.81702	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:17.664322
3253	cylinder 928	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:17.666294
3254	pentagonal prism 990	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:17.877656
3255	cube 908	pink	{0,0,0}	-207.6968	346.48944	911.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:17.881463
3256	hexagonal prism 719	red	{0,0,0}	30.514694	260.8514	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:17.883488
3257	cylinder 929	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:17.885465
3258	pentagonal prism 991	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:18.111039
3259	cube 909	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:18.11474
3260	hexagonal prism 720	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:18.116725
3261	cylinder 930	green	{0,0,0}	-270.62216	216.69383	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:18.118642
3262	pentagonal prism 992	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:18.345425
3263	cube 910	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:57:18.349307
3264	hexagonal prism 721	red	{0,0,0}	31.376482	259.8365	938	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:18.351356
3265	cylinder 931	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:18.353247
3266	pentagonal prism 993	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:18.585842
3267	cube 911	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:18.588
3268	hexagonal prism 722	red	{0,0,0}	31.375294	259.82666	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:18.589951
3269	cylinder 932	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:18.591841
3270	pentagonal prism 994	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:18.806847
3271	cube 912	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:57:18.809026
3272	hexagonal prism 723	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:18.811091
3273	cylinder 933	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:18.81305
3274	pentagonal prism 995	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:19.040075
3275	cube 913	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:19.042444
3276	hexagonal prism 724	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:19.044485
3277	cylinder 934	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:19.046453
3278	pentagonal prism 996	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:19.260591
3279	cube 914	pink	{0,0,0}	-206.88084	345.12823	913.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:19.263657
3280	hexagonal prism 725	red	{0,0,0}	31.375294	259.82666	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:19.266037
3281	cylinder 935	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:19.268049
3282	pentagonal prism 997	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:19.50372
3283	cube 915	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:19.50647
3284	pentagonal prism 998	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:57:19.508437
3285	cylinder 936	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:19.5103
3286	pentagonal prism 999	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:57:19.726173
3287	cube 916	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:19.729752
3288	hexagonal prism 726	red	{0,0,0}	31.376482	259.8365	934	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:57:19.732262
3289	cylinder 937	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:19.734255
3290	pentagonal prism 1000	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:19.965619
3291	cube 917	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:19.969452
3292	hexagonal prism 727	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:19.971587
3293	cylinder 938	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:19.973507
3294	pentagonal prism 1001	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:20.19659
3295	cube 918	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:57:20.200409
3296	cylinder 939	red	{0,0,0}	30.395967	260.81702	937.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:57:20.202385
3297	cylinder 940	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:20.204317
3298	pentagonal prism 1002	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:57:20.430037
3299	cube 919	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:20.432673
3300	hexagonal prism 728	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:20.434637
3301	cylinder 941	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	33.690067	cylinder.usd	2025-03-29 14:57:20.436484
3302	pentagonal prism 1003	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:20.663278
3303	cube 920	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:20.667423
3304	hexagonal prism 729	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:20.669865
3305	cylinder 942	green	{0,0,0}	-270.62216	216.69383	944.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:20.671907
3306	pentagonal prism 1004	black	{0,0,0}	-127.46696	518.69244	661	0	0	90	pentagonal prism.usd	2025-03-29 14:57:20.895364
3307	cube 921	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:57:20.899247
3308	hexagonal prism 730	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:20.901493
3309	cylinder 943	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:20.903432
3310	pentagonal prism 1005	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:21.129149
3311	cube 922	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:57:21.131595
3312	cylinder 944	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:57:21.133745
3313	cylinder 945	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:21.135664
3314	pentagonal prism 1006	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:21.347493
3315	cube 923	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:21.350363
3316	hexagonal prism 731	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:21.352412
3317	cylinder 946	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:21.354261
3318	pentagonal prism 1007	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:21.580343
3319	cube 924	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:21.584107
3320	hexagonal prism 732	red	{0,0,0}	31.376482	259.8365	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:21.586221
3321	cylinder 947	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:21.588142
3322	pentagonal prism 1008	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:21.797968
3323	cube 925	pink	{0,0,0}	-205.90816	345.1413	911.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:21.800319
3324	hexagonal prism 733	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:21.80223
3325	cylinder 948	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:21.804087
3326	pentagonal prism 1009	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:22.031949
3327	cube 926	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:22.034792
3328	cylinder 949	red	{0,0,0}	30.395967	260.81702	929	0	0	37.405357	cylinder.usd	2025-03-29 14:57:22.037194
3329	cylinder 950	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:22.039178
3330	pentagonal prism 1010	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:22.270418
3331	cube 927	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:57:22.274318
3332	hexagonal prism 734	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:22.276344
3333	cylinder 951	green	{0,0,0}	-270.62216	216.69383	943	0	0	18.434948	cylinder.usd	2025-03-29 14:57:22.27815
3334	pentagonal prism 1011	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:22.498325
3335	cube 928	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.62088	cube.usd	2025-03-29 14:57:22.500721
3336	pentagonal prism 1012	red	{0,0,0}	30.395967	260.81702	929	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:57:22.503148
3337	cylinder 952	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:22.505258
3338	pentagonal prism 1013	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:22.731583
3339	cube 929	pink	{0,0,0}	-206.88867	345.1413	914.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:22.735451
3340	hexagonal prism 735	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:22.737367
3341	cylinder 953	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:22.739178
3342	pentagonal prism 1014	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:22.966254
3343	cube 930	pink	{0,0,0}	-205.90816	345.1413	939.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:22.969942
3344	hexagonal prism 736	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:22.971947
3345	cylinder 954	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:22.973945
3346	pentagonal prism 1015	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:23.199768
3347	cube 931	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:23.202502
3348	hexagonal prism 737	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:23.204391
3349	cylinder 955	green	{0,0,0}	-270.62216	216.69383	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:23.206369
3350	pentagonal prism 1016	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:23.432287
3351	cube 932	pink	{0,0,0}	-206.88867	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:23.434638
3352	hexagonal prism 738	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:23.436683
3353	cylinder 956	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:23.438652
3354	pentagonal prism 1017	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:23.665862
3355	cube 933	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:23.668567
3356	hexagonal prism 739	red	{0,0,0}	31.376482	259.8365	940.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:23.671338
3357	cylinder 957	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:57:23.673582
3358	pentagonal prism 1018	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:23.904874
3359	cube 934	pink	{0,0,0}	-207.6968	346.48944	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:23.907627
3360	hexagonal prism 740	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:57:23.909761
3361	cylinder 958	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:23.911746
3362	pentagonal prism 1019	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:57:24.133016
3363	cube 935	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.743565	cube.usd	2025-03-29 14:57:24.136693
3364	hexagonal prism 741	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:24.138618
3365	cylinder 959	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:24.140543
3366	pentagonal prism 1020	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:24.366981
3367	cube 936	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:24.370793
3368	hexagonal prism 742	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:24.373108
3369	cylinder 960	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.43495	cylinder.usd	2025-03-29 14:57:24.375157
3370	pentagonal prism 1021	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:24.604193
3371	cube 937	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.743565	cube.usd	2025-03-29 14:57:24.606679
3372	hexagonal prism 743	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.647617	hexagonal prism.usd	2025-03-29 14:57:24.608805
3373	cylinder 961	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:24.610742
3374	pentagonal prism 1022	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:24.841183
3375	cube 938	pink	{0,0,0}	-208.68114	346.48944	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:24.844827
3376	hexagonal prism 744	red	{0,0,0}	30.514694	260.8514	935.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:24.847108
3377	cylinder 962	green	{0,0,0}	-272.66354	217.54024	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:24.849219
3378	pentagonal prism 1023	black	{0,0,0}	-127.46696	518.69244	660	0	0	0	pentagonal prism.usd	2025-03-29 14:57:25.06504
3379	cube 939	pink	{0,0,0}	-206.88867	345.1413	917.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:25.069076
3380	hexagonal prism 745	red	{0,0,0}	31.376482	259.8365	924	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:57:25.071151
3381	cylinder 963	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:25.073106
3382	pentagonal prism 1024	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:25.310044
3383	cube 940	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:25.313702
3384	hexagonal prism 746	red	{0,0,0}	31.375294	259.82666	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:25.315602
3385	cylinder 964	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 14:57:25.317505
3386	pentagonal prism 1025	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:25.537636
3387	cube 941	pink	{0,0,0}	-206.88867	345.1413	907.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:25.541205
3388	hexagonal prism 747	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:25.543197
3389	cylinder 965	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:25.545004
3390	pentagonal prism 1026	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:25.766282
3391	cube 942	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:25.769872
3392	hexagonal prism 748	red	{0,0,0}	30.395967	260.81702	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:25.771837
3393	cylinder 966	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:25.773761
3394	pentagonal prism 1027	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:25.998801
3395	cube 943	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.743565	cube.usd	2025-03-29 14:57:26.002426
3396	hexagonal prism 749	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:26.005026
3397	cylinder 967	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:26.007661
3398	pentagonal prism 1028	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:26.24022
3399	cube 944	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03624	cube.usd	2025-03-29 14:57:26.243768
3400	hexagonal prism 750	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:26.245652
3401	cylinder 968	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:26.247471
3402	pentagonal prism 1029	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:26.468627
3403	cube 945	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 14:57:26.472486
3404	hexagonal prism 751	red	{0,0,0}	31.375294	259.82666	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:26.474446
3405	cylinder 969	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:26.476239
3406	pentagonal prism 1030	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:26.704098
3407	cube 946	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:57:26.707793
3408	hexagonal prism 752	red	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:26.709856
3409	cylinder 970	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:26.711684
3410	pentagonal prism 1031	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:57:26.935148
3411	cube 947	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.420776	cube.usd	2025-03-29 14:57:26.937241
3412	hexagonal prism 753	red	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:26.939577
3413	cylinder 971	green	{0,0,0}	-270.62216	216.69383	943	0	0	26.56505	cylinder.usd	2025-03-29 14:57:26.941767
3414	pentagonal prism 1032	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:27.168259
3415	cube 948	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.34933	cube.usd	2025-03-29 14:57:27.17065
3416	hexagonal prism 754	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:27.172733
3417	cylinder 972	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:27.174718
3418	pentagonal prism 1033	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:27.409081
3419	cube 949	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:27.411392
3420	hexagonal prism 755	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:27.413246
3421	cylinder 973	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:57:27.415209
3422	pentagonal prism 1034	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:27.635708
3423	cube 950	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:27.638422
3424	cylinder 974	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:57:27.640429
3425	cylinder 975	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:27.642554
3426	pentagonal prism 1035	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:27.897029
3427	cube 951	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:27.900894
3428	pentagonal prism 1036	red	{0,0,0}	30.395967	260.81702	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:57:27.903115
3429	cylinder 976	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:27.90564
3430	pentagonal prism 1037	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:57:28.119697
3431	cube 952	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:28.122937
3432	hexagonal prism 756	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:28.124813
3433	cylinder 977	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:28.126645
3434	pentagonal prism 1038	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:28.336676
3435	cube 953	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:28.339636
3436	hexagonal prism 757	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:28.341629
3437	cylinder 978	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:28.343548
3438	pentagonal prism 1039	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:28.569431
3439	cube 954	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:28.573272
3440	hexagonal prism 758	red	{0,0,0}	30.395967	260.81702	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:28.575572
3441	cylinder 979	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:28.577608
3442	pentagonal prism 1040	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:28.807546
3443	cube 955	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:57:28.811727
3444	pentagonal prism 1041	red	{0,0,0}	30.395967	260.81702	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:57:28.813743
3445	cylinder 980	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:28.815519
3446	pentagonal prism 1042	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:29.044561
3447	cube 956	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:29.04834
3448	hexagonal prism 759	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:29.050426
3449	cylinder 981	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:29.052355
3450	pentagonal prism 1043	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:29.273247
3451	cube 957	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:29.275737
3452	cylinder 982	red	{0,0,0}	30.395967	260.81702	931.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:57:29.277716
3453	cylinder 983	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:29.2795
3454	pentagonal prism 1044	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:29.504239
3455	cube 958	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:29.507924
3456	hexagonal prism 760	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:29.510283
3457	cylinder 984	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:29.51218
3458	pentagonal prism 1045	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:29.736754
3459	cube 959	pink	{0,0,0}	-206.88867	345.1413	907.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:29.740618
3460	hexagonal prism 761	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:29.742937
3461	cylinder 985	green	{0,0,0}	-270.62216	216.69383	943	0	0	26.56505	cylinder.usd	2025-03-29 14:57:29.744917
3462	pentagonal prism 1046	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:29.96643
3463	cube 960	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:29.968655
3464	hexagonal prism 762	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:29.970951
3465	cylinder 986	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:29.972924
3466	pentagonal prism 1047	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:30.187899
3467	cube 961	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:57:30.191643
3468	hexagonal prism 763	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:30.193653
3469	cylinder 987	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:30.195742
3470	pentagonal prism 1048	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:30.40715
3471	cube 962	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:30.409854
3472	hexagonal prism 764	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:30.412017
3473	cylinder 988	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:30.413884
3474	pentagonal prism 1049	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:30.635997
3475	cube 963	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:30.640083
3476	hexagonal prism 765	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:30.642362
3477	cylinder 989	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:30.644304
3478	pentagonal prism 1050	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:57:30.867478
3479	cube 964	pink	{0,0,0}	-206.88867	345.1413	908.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:30.871163
3480	hexagonal prism 766	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:30.873204
3481	cylinder 990	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:57:30.875586
3482	pentagonal prism 1051	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:31.089748
3483	cube 965	pink	{0,0,0}	-206.88867	345.1413	912.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:31.092865
3484	hexagonal prism 767	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:31.094895
3485	cylinder 991	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:31.096791
3486	pentagonal prism 1052	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:31.32567
3487	cube 966	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:31.328034
3488	hexagonal prism 768	red	{0,0,0}	31.375294	259.82666	937.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:31.329927
3489	cylinder 992	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:31.331772
3490	pentagonal prism 1053	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:31.546023
3491	cube 967	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.420776	cube.usd	2025-03-29 14:57:31.548461
3492	hexagonal prism 769	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:31.550478
3493	cylinder 993	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:31.552372
3494	pentagonal prism 1054	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:31.775129
3495	cube 968	pink	{0,0,0}	-206.88867	345.1413	916.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:31.778761
3496	hexagonal prism 770	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:31.780845
3497	cylinder 994	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	38.65981	cylinder.usd	2025-03-29 14:57:31.782696
3498	pentagonal prism 1055	black	{0,0,0}	-128.94919	520.7185	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:32.01103
3499	cube 969	pink	{0,0,0}	-208.68114	346.48944	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:32.013502
3500	hexagonal prism 771	red	{0,0,0}	29.53035	261.83575	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:32.015502
3501	cylinder 995	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:32.01735
3502	pentagonal prism 1056	black	{0,0,0}	-128.94919	520.7185	657	0	0	0	pentagonal prism.usd	2025-03-29 14:57:32.247159
3503	cube 970	pink	{0,0,0}	-207.6968	346.48944	919	0	0	59.534454	cube.usd	2025-03-29 14:57:32.250948
3504	hexagonal prism 772	red	{0,0,0}	30.514694	260.8514	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:32.252826
3505	cylinder 996	green	{0,0,0}	-272.66354	217.54024	924	0	0	33.690063	cylinder.usd	2025-03-29 14:57:32.25466
3506	pentagonal prism 1057	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:32.488302
3507	cube 971	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:57:32.490494
3508	hexagonal prism 773	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:32.49277
3509	cylinder 997	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:32.494608
3510	pentagonal prism 1058	black	{0,0,0}	-127.46696	518.69244	656	0	0	0	pentagonal prism.usd	2025-03-29 14:57:32.715038
3511	cube 972	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:32.717158
3512	cube 973	red	{0,0,0}	32.357	258.856	924	0	0	37.303947	cube.usd	2025-03-29 14:57:32.718964
3513	cylinder 998	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:32.720877
3514	pentagonal prism 1059	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:32.936026
3515	cube 974	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:32.939957
3516	hexagonal prism 774	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:32.942621
3517	cylinder 999	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:32.944911
3518	pentagonal prism 1060	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:33.159474
3519	cube 975	pink	{0,0,0}	-206.88867	345.1413	929	0	0	59.03625	cube.usd	2025-03-29 14:57:33.162309
3520	hexagonal prism 775	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:57:33.164244
3521	cylinder 1000	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:33.166046
3522	pentagonal prism 1061	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:33.395859
3523	cube 976	pink	{0,0,0}	-206.88084	345.12823	933	0	0	59.534454	cube.usd	2025-03-29 14:57:33.398091
3524	hexagonal prism 776	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:33.400085
3525	cylinder 1001	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:33.402
3526	pentagonal prism 1062	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:33.620073
3527	cube 977	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:33.622742
3528	hexagonal prism 777	red	{0,0,0}	31.375294	259.82666	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:33.62483
3529	cylinder 1002	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:33.626875
3530	pentagonal prism 1063	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:33.843229
3531	cube 978	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:33.845509
3532	hexagonal prism 778	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:33.847392
3533	cylinder 1003	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:33.849214
3534	pentagonal prism 1064	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:34.076389
3535	cube 979	pink	{0,0,0}	-206.88084	345.12823	914.00006	0	0	59.743565	cube.usd	2025-03-29 14:57:34.078886
3536	hexagonal prism 779	red	{0,0,0}	31.375294	259.82666	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:34.081179
3537	cylinder 1004	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:34.083319
3538	pentagonal prism 1065	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:34.309103
3539	cube 980	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.420776	cube.usd	2025-03-29 14:57:34.313303
3540	hexagonal prism 780	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:34.315644
3541	cylinder 1005	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:34.317589
3542	pentagonal prism 1066	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:34.544516
3543	cube 981	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:34.548157
3544	hexagonal prism 781	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:34.550103
3545	cylinder 1006	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:34.551985
3546	pentagonal prism 1067	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:34.773471
3547	cube 982	pink	{0,0,0}	-207.6968	346.48944	927.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:34.776365
3548	cylinder 1007	red	{0,0,0}	29.53035	261.83575	933	0	0	37.874985	cylinder.usd	2025-03-29 14:57:34.77866
3549	cylinder 1008	green	{0,0,0}	-272.66354	217.54024	921.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:34.780583
3550	pentagonal prism 1068	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:35.008663
3551	cube 983	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:35.011052
3552	hexagonal prism 782	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:35.013045
3553	cylinder 1009	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:35.01502
3554	pentagonal prism 1069	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:35.24118
3555	cube 984	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:57:35.245211
3556	hexagonal prism 783	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:35.247311
3557	cylinder 1010	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:35.249242
3558	pentagonal prism 1070	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:35.476014
3559	cube 985	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.620872	cube.usd	2025-03-29 14:57:35.478588
3560	hexagonal prism 784	red	{0,0,0}	30.395967	260.81702	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:35.480694
3561	cylinder 1011	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:35.482613
3562	pentagonal prism 1071	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:35.708751
3563	cube 986	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:35.712352
3564	hexagonal prism 785	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:35.71463
3565	cylinder 1012	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:35.716526
3566	pentagonal prism 1072	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:35.942601
3567	cube 987	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:35.946433
3568	hexagonal prism 786	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:35.948277
3569	cylinder 1013	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:57:35.950121
3570	pentagonal prism 1073	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:36.177546
3571	cube 988	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.34933	cube.usd	2025-03-29 14:57:36.181559
3572	hexagonal prism 787	red	{0,0,0}	31.376482	259.8365	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:36.183625
3573	cylinder 1014	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:57:36.185528
3574	pentagonal prism 1074	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:57:36.433401
3575	cube 989	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 14:57:36.437094
3576	hexagonal prism 788	red	{0,0,0}	30.394815	260.80713	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:36.439087
3577	cylinder 1015	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:36.440899
3578	pentagonal prism 1075	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:36.664307
3579	cube 990	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:57:36.666985
3580	hexagonal prism 789	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.77568	hexagonal prism.usd	2025-03-29 14:57:36.668817
3581	cylinder 1016	green	{0,0,0}	-270.62216	216.69383	920	0	0	36.869896	cylinder.usd	2025-03-29 14:57:36.670655
3582	pentagonal prism 1076	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:36.89584
3583	cube 991	pink	{0,0,0}	-205.90816	345.1413	910	0	0	59.03624	cube.usd	2025-03-29 14:57:36.898107
3584	hexagonal prism 790	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:36.900237
3585	cylinder 1017	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:36.902199
3586	pentagonal prism 1077	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:37.12744
3587	cube 992	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:37.131243
3588	hexagonal prism 791	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:37.133166
3589	cylinder 1018	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:37.13508
3590	pentagonal prism 1078	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:37.364525
3591	cube 993	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:37.368322
3592	hexagonal prism 792	red	{0,0,0}	30.395967	260.81702	934	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:37.370405
3593	cylinder 1019	green	{0,0,0}	-270.62216	216.69383	929	0	0	21.801407	cylinder.usd	2025-03-29 14:57:37.372327
3594	pentagonal prism 1079	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:37.597912
3595	cube 994	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:57:37.601709
3596	hexagonal prism 793	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:37.60379
3597	cylinder 1020	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:37.605613
3598	pentagonal prism 1080	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:37.818999
3599	cube 995	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:37.821508
3600	hexagonal prism 794	red	{0,0,0}	31.375294	259.82666	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:37.823373
3601	cylinder 1021	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:37.825198
3602	pentagonal prism 1081	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:38.047422
3603	cube 996	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.620872	cube.usd	2025-03-29 14:57:38.05103
3604	hexagonal prism 795	red	{0,0,0}	32.357	258.856	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:38.052976
3605	cylinder 1022	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:38.054775
3606	pentagonal prism 1082	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:38.279075
3607	cube 997	pink	{0,0,0}	-207.6968	346.48944	934	0	0	59.620872	cube.usd	2025-03-29 14:57:38.283233
3608	hexagonal prism 796	red	{0,0,0}	30.514694	260.8514	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:38.285463
3609	cylinder 1023	green	{0,0,0}	-272.66354	217.54024	929	0	0	18.434948	cylinder.usd	2025-03-29 14:57:38.287408
3610	pentagonal prism 1083	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:38.512186
3611	cube 998	pink	{0,0,0}	-206.88867	345.1413	915	0	0	59.534454	cube.usd	2025-03-29 14:57:38.515784
3612	hexagonal prism 797	red	{0,0,0}	31.376482	259.8365	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:38.517783
3613	cylinder 1024	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:38.519686
3614	pentagonal prism 1084	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:38.74792
3615	cube 999	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	cube.usd	2025-03-29 14:57:38.751658
3616	cylinder 1025	red	{0,0,0}	30.395967	260.81702	919	0	0	37.568592	cylinder.usd	2025-03-29 14:57:38.753721
3617	cylinder 1026	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:38.755636
3618	pentagonal prism 1085	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:38.983938
3619	cube 1000	pink	{0,0,0}	-206.88867	345.1413	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:38.98625
3620	hexagonal prism 798	red	{0,0,0}	30.395967	260.81702	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:38.988166
3621	cylinder 1027	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:38.990134
3622	pentagonal prism 1086	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:39.227864
3623	cube 1001	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 14:57:39.231669
3624	pentagonal prism 1087	red	{0,0,0}	30.394815	260.80713	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:57:39.233534
3625	cylinder 1028	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:39.235585
3626	pentagonal prism 1088	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:39.457503
3627	cube 1002	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:57:39.459529
3628	hexagonal prism 799	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:39.461681
3629	cylinder 1029	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:39.463798
3630	pentagonal prism 1089	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:39.680479
3631	cube 1003	pink	{0,0,0}	-206.88867	345.1413	934	0	0	59.620872	cube.usd	2025-03-29 14:57:39.684363
3632	hexagonal prism 800	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:39.686331
3633	cylinder 1030	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:39.688255
3634	pentagonal prism 1090	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:39.908423
3635	cube 1004	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:39.912266
3636	hexagonal prism 801	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:39.914489
3637	cylinder 1031	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:39.91658
3638	pentagonal prism 1091	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:40.130372
3639	cube 1005	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 14:57:40.13316
3640	hexagonal prism 802	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:40.13501
3641	cylinder 1032	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	33.690067	cylinder.usd	2025-03-29 14:57:40.136883
3642	pentagonal prism 1092	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:40.354507
3643	cube 1006	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 14:57:40.358073
3644	hexagonal prism 803	red	{0,0,0}	31.375294	259.82666	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:40.360063
3645	cylinder 1033	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:40.362109
3646	pentagonal prism 1093	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:40.577823
3647	cube 1007	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:57:40.581323
3648	hexagonal prism 804	red	{0,0,0}	31.375294	259.82666	932.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:40.583945
3649	cylinder 1034	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:40.585941
3650	pentagonal prism 1094	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:40.814586
3651	cube 1008	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03624	cube.usd	2025-03-29 14:57:40.818311
3652	hexagonal prism 805	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:40.820354
3653	cylinder 1035	green	{0,0,0}	-270.62216	216.69383	924	0	0	18.434948	cylinder.usd	2025-03-29 14:57:40.822201
3654	pentagonal prism 1095	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:41.036965
3655	cube 1009	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:41.04074
3656	hexagonal prism 806	red	{0,0,0}	31.376482	259.8365	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:41.042792
3657	cylinder 1036	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:41.044662
3658	pentagonal prism 1096	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:41.25606
3659	cube 1010	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:41.258368
3660	hexagonal prism 807	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:41.2603
3661	cylinder 1037	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:41.262227
3662	pentagonal prism 1097	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:41.479476
3663	cube 1011	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:57:41.483167
3664	hexagonal prism 808	red	{0,0,0}	30.395967	260.81702	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:41.485242
3665	cylinder 1038	green	{0,0,0}	-270.62216	216.69383	929	0	0	18.434948	cylinder.usd	2025-03-29 14:57:41.487208
3666	pentagonal prism 1098	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:41.699975
3667	cube 1012	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:41.702369
3668	hexagonal prism 809	red	{0,0,0}	31.376482	259.8365	924	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:57:41.704713
3669	cylinder 1039	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:57:41.706658
3670	pentagonal prism 1099	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:41.933956
3671	cube 1013	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:41.936233
3672	hexagonal prism 810	red	{0,0,0}	31.376482	259.8365	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:41.938863
3673	cylinder 1040	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:41.941459
3674	pentagonal prism 1100	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:42.157511
3675	cube 1014	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:42.159885
3676	hexagonal prism 811	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:42.161799
3677	cylinder 1041	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:42.163686
3678	pentagonal prism 1101	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:42.397788
3679	cube 1015	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:42.401653
3680	hexagonal prism 812	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:42.403697
3681	cylinder 1042	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:42.405566
3682	pentagonal prism 1102	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:42.624012
3683	cube 1016	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:42.628038
3684	hexagonal prism 813	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:42.629862
3685	cylinder 1043	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:42.631985
3686	pentagonal prism 1103	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:57:42.84879
3687	cube 1017	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:42.852745
3688	hexagonal prism 814	red	{0,0,0}	31.376482	259.8365	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:42.854915
3689	cylinder 1044	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:42.856975
3690	pentagonal prism 1104	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:57:43.09705
3691	cube 1018	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:43.100826
3692	hexagonal prism 815	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:43.103291
3693	cylinder 1045	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:43.10612
3694	pentagonal prism 1105	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:43.333217
3695	cube 1019	pink	{0,0,0}	-206.88867	345.1413	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:43.336954
3696	hexagonal prism 816	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:43.339164
3697	cylinder 1046	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:43.341176
3698	pentagonal prism 1106	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:43.560884
3699	cube 1020	pink	{0,0,0}	-207.6968	346.48944	933	0	0	59.420776	cube.usd	2025-03-29 14:57:43.563018
3700	cylinder 1047	red	{0,0,0}	29.53035	261.83575	916.00006	0	0	37.568592	cylinder.usd	2025-03-29 14:57:43.5653
3701	cylinder 1048	green	{0,0,0}	-272.66354	217.54024	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:43.567225
3702	pentagonal prism 1107	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:43.785608
3703	cube 1021	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.743565	cube.usd	2025-03-29 14:57:43.788442
3704	hexagonal prism 817	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:43.790522
3705	cylinder 1049	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 14:57:43.792538
3706	pentagonal prism 1108	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:44.011131
3707	cube 1022	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.534454	cube.usd	2025-03-29 14:57:44.013628
3708	hexagonal prism 818	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:44.015803
3709	cylinder 1050	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:44.018647
3710	pentagonal prism 1109	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:44.232849
3711	cube 1023	pink	{0,0,0}	-205.90816	345.1413	927.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:44.235121
3712	hexagonal prism 819	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:44.237438
3713	cylinder 1051	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:57:44.239383
3714	pentagonal prism 1110	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:44.464577
3715	cube 1024	pink	{0,0,0}	-205.90816	345.1413	930.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:44.468623
3716	hexagonal prism 820	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:44.471166
3717	cylinder 1052	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:44.47328
3718	pentagonal prism 1111	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:44.697381
3719	cube 1025	pink	{0,0,0}	-205.90816	345.1413	905.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:44.699579
3720	cylinder 1053	red	{0,0,0}	30.395967	260.81702	934	0	0	37.568592	cylinder.usd	2025-03-29 14:57:44.701684
3721	cylinder 1054	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:44.704272
3722	pentagonal prism 1112	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:44.927186
3723	cube 1026	pink	{0,0,0}	-208.68114	346.48944	915	0	0	59.420776	cube.usd	2025-03-29 14:57:44.929452
3724	hexagonal prism 821	red	{0,0,0}	30.514694	260.8514	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:44.931809
3725	cylinder 1055	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:44.934237
3726	pentagonal prism 1113	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:45.162311
3727	cube 1027	pink	{0,0,0}	-205.90816	345.1413	908.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:45.164584
3728	hexagonal prism 822	red	{0,0,0}	31.376482	259.8365	938	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:45.166685
3729	cylinder 1056	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:57:45.168986
3730	pentagonal prism 1114	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:45.417122
3731	cube 1028	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:45.419712
3732	hexagonal prism 823	red	{0,0,0}	30.394815	260.80713	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:45.421982
3733	cylinder 1057	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:45.424231
3734	pentagonal prism 1115	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:57:45.654598
3735	cube 1029	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:57:45.658149
3736	hexagonal prism 824	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:45.660091
3737	cylinder 1058	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:45.662125
3738	pentagonal prism 1116	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:45.917563
3739	cube 1030	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:57:45.921448
3740	hexagonal prism 825	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:45.923747
3741	cylinder 1059	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	36.869896	cylinder.usd	2025-03-29 14:57:45.925687
3742	pentagonal prism 1117	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:57:46.16132
3743	cube 1031	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:46.163596
3744	pentagonal prism 1118	red	{0,0,0}	30.395967	260.81702	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:57:46.165473
3745	cylinder 1060	green	{0,0,0}	-270.62216	216.69383	933	0	0	18.434948	cylinder.usd	2025-03-29 14:57:46.167603
3746	pentagonal prism 1119	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:46.380585
3747	cube 1032	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:46.382999
3748	hexagonal prism 826	red	{0,0,0}	30.395967	260.81702	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:46.384891
3749	cylinder 1061	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:46.38688
3750	pentagonal prism 1120	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:46.601899
3751	cube 1033	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:46.60445
3752	hexagonal prism 827	red	{0,0,0}	30.395967	260.81702	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:46.606765
3753	cylinder 1062	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:46.608829
3754	pentagonal prism 1121	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:46.832892
3755	cube 1034	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:46.836518
3756	hexagonal prism 828	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.77568	hexagonal prism.usd	2025-03-29 14:57:46.83874
3757	cylinder 1063	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:46.840986
3758	pentagonal prism 1122	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:57:47.060027
3759	cube 1035	pink	{0,0,0}	-205.90816	345.1413	941.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:47.062365
3760	pentagonal prism 1123	red	{0,0,0}	30.395967	260.81702	935.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:57:47.064405
3761	cylinder 1064	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:47.066256
3762	pentagonal prism 1124	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:47.285229
3763	cube 1036	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:47.289238
3764	hexagonal prism 829	red	{0,0,0}	30.395967	260.81702	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:47.291437
3765	cylinder 1065	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:47.293372
3766	pentagonal prism 1125	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:47.517376
3767	cube 1037	pink	{0,0,0}	-205.90816	345.1413	918.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:47.521398
3768	hexagonal prism 830	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:47.523668
3769	cylinder 1066	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:47.525875
3770	pentagonal prism 1126	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:47.750117
3771	cube 1038	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:47.752436
3772	hexagonal prism 831	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:57:47.754318
3773	cylinder 1067	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:47.756443
3774	pentagonal prism 1127	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:47.975147
3775	cube 1039	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:47.978105
3776	hexagonal prism 832	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:47.980121
3777	cylinder 1068	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:47.981933
3778	pentagonal prism 1128	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:48.201386
3779	cube 1040	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.03624	cube.usd	2025-03-29 14:57:48.20536
3780	hexagonal prism 833	red	{0,0,0}	30.395967	260.81702	939.00006	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:57:48.207426
3781	cylinder 1069	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:48.209331
3782	pentagonal prism 1129	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:48.446048
3783	cube 1041	pink	{0,0,0}	-206.88867	345.1413	919	0	0	59.34933	cube.usd	2025-03-29 14:57:48.448484
3784	hexagonal prism 834	red	{0,0,0}	31.376482	259.8365	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:48.450686
3785	cylinder 1070	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 14:57:48.452667
3786	pentagonal prism 1130	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:48.666723
3787	cube 1042	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:57:48.67024
3788	hexagonal prism 835	red	{0,0,0}	31.376482	259.8365	936.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:48.672303
3789	cylinder 1071	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:57:48.674537
3790	pentagonal prism 1131	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:48.903075
3791	cube 1043	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.03624	cube.usd	2025-03-29 14:57:48.907328
3792	hexagonal prism 836	red	{0,0,0}	30.514694	260.8514	923.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:57:48.909524
3793	cylinder 1072	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:48.911559
3794	pentagonal prism 1132	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:49.133886
3795	cube 1044	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:57:49.1364
3796	hexagonal prism 837	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:49.138528
3797	cylinder 1073	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:49.140817
3798	pentagonal prism 1133	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:49.360794
3799	cube 1045	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.03624	cube.usd	2025-03-29 14:57:49.363453
3800	hexagonal prism 838	red	{0,0,0}	30.514694	260.8514	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:49.365409
3801	cylinder 1074	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:57:49.367139
3802	pentagonal prism 1134	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:49.584609
3803	cube 1046	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:49.587032
3804	hexagonal prism 839	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:49.589012
3805	cylinder 1075	green	{0,0,0}	-270.62216	216.69383	933	0	0	33.690063	cylinder.usd	2025-03-29 14:57:49.591299
3806	pentagonal prism 1135	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:57:49.815834
3807	cube 1047	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:57:49.81947
3808	pentagonal prism 1136	red	{0,0,0}	30.395967	260.81702	924	0	0	37.476177	pentagonal prism.usd	2025-03-29 14:57:49.821324
3809	cylinder 1076	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:49.823203
3810	pentagonal prism 1137	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:50.051603
3811	cube 1048	pink	{0,0,0}	-206.88867	345.1413	918.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:50.055383
3812	hexagonal prism 840	red	{0,0,0}	31.376482	259.8365	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:50.05785
3813	cylinder 1077	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:50.05996
3814	pentagonal prism 1138	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:50.285405
3815	cube 1049	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:50.289039
3816	hexagonal prism 841	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:50.291607
3817	cylinder 1078	green	{0,0,0}	-270.62216	216.69383	939.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:50.293878
3818	pentagonal prism 1139	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:50.515232
3819	cube 1050	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.534454	cube.usd	2025-03-29 14:57:50.517691
3820	hexagonal prism 842	red	{0,0,0}	31.376482	259.8365	917.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:50.519693
3821	cylinder 1079	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:50.521868
3822	pentagonal prism 1140	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:50.738931
3823	cube 1051	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.620872	cube.usd	2025-03-29 14:57:50.744436
3824	hexagonal prism 843	red	{0,0,0}	30.394815	260.80713	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:50.748055
3825	cylinder 1080	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:50.751787
3826	pentagonal prism 1141	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:50.968962
3827	cube 1052	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:50.971273
3828	hexagonal prism 844	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:50.97323
3829	cylinder 1081	green	{0,0,0}	-270.6119	216.68562	934	0	0	33.690063	cylinder.usd	2025-03-29 14:57:50.97536
3830	pentagonal prism 1142	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:51.187487
3831	cube 1053	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:51.19015
3832	pentagonal prism 1143	red	{0,0,0}	30.395967	260.81702	938	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:57:51.19225
3833	cylinder 1082	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:51.194123
3834	pentagonal prism 1144	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:51.407079
3835	cube 1054	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:51.409339
3836	pentagonal prism 1145	red	{0,0,0}	30.394815	260.80713	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:57:51.411359
3837	cylinder 1083	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:51.413239
3838	pentagonal prism 1146	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:51.641293
3839	cube 1055	pink	{0,0,0}	-206.88867	345.1413	917.00006	0	0	59.743565	cube.usd	2025-03-29 14:57:51.644962
3840	hexagonal prism 845	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:51.646994
3841	cylinder 1084	green	{0,0,0}	-270.62216	216.69383	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:51.648808
3842	pentagonal prism 1147	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:51.880823
3843	cube 1056	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:51.883074
3844	hexagonal prism 846	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:51.885008
3845	cylinder 1085	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:51.886979
3846	pentagonal prism 1148	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:52.105016
3847	cube 1057	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.420776	cube.usd	2025-03-29 14:57:52.107409
3848	hexagonal prism 847	red	{0,0,0}	30.395967	260.81702	932.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:52.109809
3849	cylinder 1086	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:57:52.112049
3850	pentagonal prism 1149	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:52.339151
3851	cube 1058	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:57:52.341657
3852	hexagonal prism 848	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:57:52.343842
3853	cylinder 1087	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:52.345829
3854	pentagonal prism 1150	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:52.573658
3855	cube 1059	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.620872	cube.usd	2025-03-29 14:57:52.576222
3856	hexagonal prism 849	red	{0,0,0}	31.376482	259.8365	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:52.578502
3857	cylinder 1088	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:52.580423
3858	pentagonal prism 1151	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:52.800598
3859	cube 1060	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 14:57:52.80428
3860	hexagonal prism 850	red	{0,0,0}	30.51353	260.84146	928.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:57:52.806433
3861	cylinder 1089	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:52.808325
3862	pentagonal prism 1152	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:53.022667
3863	cube 1061	pink	{0,0,0}	-206.88867	345.1413	915	0	0	59.03624	cube.usd	2025-03-29 14:57:53.02638
3864	cylinder 1090	red	{0,0,0}	30.395967	260.81702	924	0	0	37.568592	cylinder.usd	2025-03-29 14:57:53.028495
3865	cylinder 1091	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:53.030337
3866	pentagonal prism 1153	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:53.243977
3867	cube 1062	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.420776	cube.usd	2025-03-29 14:57:53.246521
3868	hexagonal prism 851	red	{0,0,0}	30.51353	260.84146	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:53.248433
3869	cylinder 1092	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 14:57:53.250232
3870	pentagonal prism 1154	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:53.477464
3871	cube 1063	pink	{0,0,0}	-207.6968	346.48944	932.00006	0	0	59.03624	cube.usd	2025-03-29 14:57:53.481224
3872	hexagonal prism 852	red	{0,0,0}	30.514694	260.8514	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:53.48312
3873	cylinder 1093	green	{0,0,0}	-272.66354	217.54024	937.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:53.485035
3874	pentagonal prism 1155	black	{0,0,0}	-128.94919	520.7185	656	0	0	0	pentagonal prism.usd	2025-03-29 14:57:53.709519
3875	cube 1064	pink	{0,0,0}	-207.6968	346.48944	927.00006	0	0	59.743565	cube.usd	2025-03-29 14:57:53.711964
3876	pentagonal prism 1156	red	{0,0,0}	29.53035	261.83575	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:57:53.713876
3877	cylinder 1094	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:53.715681
3878	pentagonal prism 1157	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:57:53.942122
3879	cube 1065	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 14:57:53.944851
3880	hexagonal prism 853	red	{0,0,0}	31.375294	259.82666	934	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:53.946927
3881	cylinder 1095	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:53.948784
3882	pentagonal prism 1158	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:54.176334
3883	cube 1066	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.62088	cube.usd	2025-03-29 14:57:54.17905
3884	hexagonal prism 854	red	{0,0,0}	31.375294	259.82666	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:54.181069
3885	cylinder 1096	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:57:54.183234
3886	pentagonal prism 1159	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:54.408445
3887	cube 1067	pink	{0,0,0}	-205.90816	345.1413	917.00006	0	0	59.420776	cube.usd	2025-03-29 14:57:54.412277
3888	hexagonal prism 855	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:54.414235
3889	cylinder 1097	green	{0,0,0}	-270.62216	216.69383	935.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:57:54.416067
3890	pentagonal prism 1160	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:57:54.642129
3891	cube 1068	pink	{0,0,0}	-206.88867	345.1413	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:57:54.645866
3892	hexagonal prism 856	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:57:54.648177
3893	cylinder 1098	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:57:54.650119
3894	pentagonal prism 1161	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:54.871541
3895	cube 1069	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.34933	cube.usd	2025-03-29 14:57:54.875454
3896	hexagonal prism 857	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:54.877935
3897	cylinder 1099	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:57:54.880147
3898	pentagonal prism 1162	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:57:55.093307
3899	cube 1070	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 14:57:55.09612
3900	hexagonal prism 858	red	{0,0,0}	31.375294	259.82666	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:57:55.098384
3901	pentagonal prism 1	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:01.770783
3902	cylinder 1	green	{0,0,0}	122.564384	348.08286	1941.0001	0	0	2.9356732	cylinder.usd	2025-03-29 14:58:01.775121
3903	cube 1	pink	{0,0,0}	-206.88867	345.1413	927.00006	0	0	59.93142	cube.usd	2025-03-29 14:58:01.777041
3904	cylinder 2	green	{0,0,0}	127.46696	292.19348	1944.0001	0	0	3.814075	cylinder.usd	2025-03-29 14:58:01.778864
3905	hexagonal prism 1	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:01.780712
3906	cylinder 3	green	{0,0,0}	-270.62216	216.69383	938	0	0	26.56505	cylinder.usd	2025-03-29 14:58:01.782527
3907	pentagonal prism 2	black	{0,0,0}	-348.54163	189.73369	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:02.000246
3908	cube 2	pink	{0,0,0}	-416.24396	41.79156	920	0	0	59.34933	cube.usd	2025-03-29 14:58:02.003018
3909	cylinder 4	red	{0,0,0}	-213.9728	-30.089924	927.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:58:02.004974
3910	cylinder 5	green	{0,0,0}	-470.573	-67.70233	920	0	0	26.56505	cylinder.usd	2025-03-29 14:58:02.00681
3911	pentagonal prism 3	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:02.237271
3912	cube 3	pink	{0,0,0}	-207.6968	346.48944	925.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:02.240707
3913	hexagonal prism 2	red	{0,0,0}	29.53035	261.83575	927.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:02.24262
3914	cylinder 6	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:02.24449
3915	pentagonal prism 4	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:02.458884
3916	cube 4	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:02.461171
3917	hexagonal prism 3	red	{0,0,0}	31.375294	259.82666	927.00006	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:58:02.463211
3918	cylinder 7	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:02.465151
3919	pentagonal prism 5	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:02.685485
3920	cube 5	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.743565	cube.usd	2025-03-29 14:58:02.687959
3921	hexagonal prism 4	red	{0,0,0}	30.51353	260.84146	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:02.689945
3922	cylinder 8	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:02.691941
3923	pentagonal prism 6	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 14:58:02.916696
3924	cube 6	pink	{0,0,0}	-205.90816	345.1413	914.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:02.920856
3925	cylinder 9	red	{0,0,0}	30.395967	260.81702	926.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:58:02.922813
3926	cylinder 10	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:02.924798
3927	pentagonal prism 7	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:03.148726
3928	cube 7	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:03.152621
3929	hexagonal prism 5	red	{0,0,0}	31.376482	259.8365	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:03.154858
3930	cylinder 11	green	{0,0,0}	-270.62216	216.69383	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:03.156924
3931	pentagonal prism 8	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:03.383782
3932	cube 8	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.420776	cube.usd	2025-03-29 14:58:03.38788
3933	hexagonal prism 6	red	{0,0,0}	30.514694	260.8514	922.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:03.389931
3934	cylinder 12	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:03.391777
3935	pentagonal prism 9	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:03.613538
3936	cube 9	pink	{0,0,0}	-207.6968	346.48944	932.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:03.617124
3937	hexagonal prism 7	red	{0,0,0}	30.514694	260.8514	920	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:03.61969
3938	cylinder 13	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:03.621978
3939	pentagonal prism 10	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:03.851633
3940	cube 10	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:03.854812
3941	hexagonal prism 8	red	{0,0,0}	31.376482	259.8365	937.00006	0	0	36.869892	hexagonal prism.usd	2025-03-29 14:58:03.857066
3942	cylinder 14	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:03.85933
3943	pentagonal prism 11	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:04.082831
3944	cube 11	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:04.084998
3945	hexagonal prism 9	red	{0,0,0}	31.376482	259.8365	929	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:58:04.087616
3946	cylinder 15	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:04.089833
3947	pentagonal prism 12	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:04.31855
3948	cube 12	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.620872	cube.usd	2025-03-29 14:58:04.322627
3949	pentagonal prism 13	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:58:04.324589
3950	cylinder 16	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:58:04.326499
3951	pentagonal prism 14	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:04.561322
3952	cube 13	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:04.564918
3953	hexagonal prism 10	red	{0,0,0}	30.514694	260.8514	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:04.566744
3954	cylinder 17	green	{0,0,0}	-272.66354	217.54024	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:04.568627
3955	pentagonal prism 15	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:04.786983
3956	cube 14	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	58.57044	cube.usd	2025-03-29 14:58:04.790347
3957	pentagonal prism 16	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:58:04.792485
3958	cylinder 18	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:04.794431
3959	pentagonal prism 17	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:05.02056
3960	cube 15	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:58:05.024166
3961	hexagonal prism 11	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:05.026193
3962	cylinder 19	green	{0,0,0}	-270.62216	216.69383	936.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:58:05.027963
3963	pentagonal prism 18	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:05.25638
3964	cube 16	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:58:05.258531
3965	hexagonal prism 12	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:05.260351
3966	cylinder 20	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:05.262153
3967	pentagonal prism 19	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:05.491152
3968	cube 17	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:58:05.494231
3969	pentagonal prism 20	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:05.496521
3970	cylinder 21	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:05.498535
3971	pentagonal prism 21	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:05.722362
3972	cube 18	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:05.72705
3973	cube 19	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.69424	cube.usd	2025-03-29 14:58:05.729465
3974	cylinder 22	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:05.731743
3975	pentagonal prism 22	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:05.955995
3976	cube 20	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.534454	cube.usd	2025-03-29 14:58:05.960176
3977	cylinder 23	red	{0,0,0}	31.376482	259.8365	920	0	0	37.874985	cylinder.usd	2025-03-29 14:58:05.962098
3978	cylinder 24	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:05.964043
3979	pentagonal prism 23	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:06.184135
3980	cube 21	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 14:58:06.187264
3981	hexagonal prism 13	red	{0,0,0}	31.375294	259.82666	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:06.189805
3982	cylinder 25	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:06.191837
3983	pentagonal prism 24	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:06.41296
3984	cube 22	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.03625	cube.usd	2025-03-29 14:58:06.416485
3985	hexagonal prism 14	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:06.418436
3986	cylinder 26	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	45	cylinder.usd	2025-03-29 14:58:06.420472
3987	pentagonal prism 25	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:06.64409
3988	cube 23	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:06.647597
3989	pentagonal prism 26	red	{0,0,0}	32.357	258.856	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:06.649638
3990	cylinder 27	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:06.651567
3991	pentagonal prism 27	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:06.874435
3992	cube 24	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03624	cube.usd	2025-03-29 14:58:06.876735
3993	cylinder 28	red	{0,0,0}	30.395967	260.81702	922.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:58:06.878619
3994	cylinder 29	green	{0,0,0}	-270.62216	216.69383	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:06.880456
3995	pentagonal prism 28	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:07.098578
3996	cube 25	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.03624	cube.usd	2025-03-29 14:58:07.10113
3997	hexagonal prism 15	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:07.103068
3998	cylinder 30	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.43495	cylinder.usd	2025-03-29 14:58:07.105023
3999	pentagonal prism 29	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:07.335949
4000	cube 26	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03624	cube.usd	2025-03-29 14:58:07.339856
4001	hexagonal prism 16	red	{0,0,0}	31.376482	259.8365	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:07.342206
4002	cylinder 31	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:07.3442
4003	pentagonal prism 30	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:07.568995
4004	cube 27	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:07.572992
4005	pentagonal prism 31	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:07.575203
4006	cylinder 32	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:07.577143
4007	pentagonal prism 32	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:07.804909
4008	cube 28	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.03624	cube.usd	2025-03-29 14:58:07.809051
4009	hexagonal prism 17	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:07.811022
4010	cylinder 33	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:07.812881
4011	pentagonal prism 33	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:08.047665
4012	cube 29	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.620872	cube.usd	2025-03-29 14:58:08.051218
4013	hexagonal prism 18	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:08.053628
4014	cylinder 34	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:08.055687
4015	pentagonal prism 34	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:08.28573
4016	cube 30	pink	{0,0,0}	-207.6968	346.48944	918.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:08.287871
4017	hexagonal prism 19	red	{0,0,0}	31.499039	259.86707	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:08.29013
4018	cylinder 35	green	{0,0,0}	-272.66354	217.54024	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 14:58:08.292356
4019	pentagonal prism 35	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:08.515089
4020	cube 31	pink	{0,0,0}	-207.6968	346.48944	922.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:08.518688
4021	cube 32	red	{0,0,0}	31.499039	259.86707	926.00006	0	0	37.405357	cube.usd	2025-03-29 14:58:08.520852
4022	cylinder 36	green	{0,0,0}	-272.66354	217.54024	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:08.522981
4023	pentagonal prism 36	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:08.736252
4024	cube 33	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:08.739006
4025	hexagonal prism 20	red	{0,0,0}	31.376482	259.8365	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:08.741384
4026	cylinder 37	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:08.743404
4027	pentagonal prism 37	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:08.969393
4028	cube 34	pink	{0,0,0}	-205.90816	345.1413	912.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:08.972135
4029	hexagonal prism 21	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:08.974536
4030	cylinder 38	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:08.976587
4031	pentagonal prism 38	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:09.202408
4032	cube 35	pink	{0,0,0}	-207.68886	346.4762	935.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:09.205722
4033	pentagonal prism 39	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:09.207916
4034	cylinder 39	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:09.210256
4035	pentagonal prism 40	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:09.442727
4036	cube 36	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:58:09.444896
4037	pentagonal prism 41	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:09.446754
4038	cylinder 40	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:09.448621
4039	pentagonal prism 42	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:09.668183
4040	cube 37	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:09.671758
4041	hexagonal prism 22	red	{0,0,0}	31.376482	259.8365	919	0	0	37.303947	hexagonal prism.usd	2025-03-29 14:58:09.674233
4042	cylinder 41	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:09.676626
4043	pentagonal prism 43	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:09.895545
4044	cube 38	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.34933	cube.usd	2025-03-29 14:58:09.899243
4045	pentagonal prism 44	red	{0,0,0}	31.499039	259.86707	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:09.901241
4046	cylinder 42	green	{0,0,0}	-272.66354	217.54024	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:09.90313
4047	pentagonal prism 45	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:10.127604
4048	cube 39	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.534454	cube.usd	2025-03-29 14:58:10.131177
4049	pentagonal prism 46	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:58:10.133104
4050	cylinder 43	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 14:58:10.135009
4051	pentagonal prism 47	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:10.365143
4052	cube 40	pink	{0,0,0}	-205.90816	345.1413	932.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:10.368798
4053	hexagonal prism 23	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:10.370813
4054	cylinder 44	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:10.372693
4055	pentagonal prism 48	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:10.591004
4056	cube 41	pink	{0,0,0}	-205.90816	345.1413	933	0	0	59.534454	cube.usd	2025-03-29 14:58:10.594673
4057	cube 42	red	{0,0,0}	32.357	258.856	917.00006	0	0	37.405357	cube.usd	2025-03-29 14:58:10.596586
4058	cylinder 45	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:10.598535
4059	pentagonal prism 49	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:10.828297
4060	cube 43	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 14:58:10.830704
4061	hexagonal prism 24	red	{0,0,0}	31.375294	259.82666	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:10.833076
4062	cylinder 46	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:10.834959
4063	pentagonal prism 50	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:11.062416
4064	cube 44	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.620872	cube.usd	2025-03-29 14:58:11.066009
4065	pentagonal prism 51	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 14:58:11.067933
4066	cylinder 47	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:11.069826
4067	pentagonal prism 52	black	{0,0,0}	-128.94919	520.7185	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:11.301296
4068	cube 45	pink	{0,0,0}	-207.6968	346.48944	920	0	0	59.34933	cube.usd	2025-03-29 14:58:11.30493
4069	hexagonal prism 25	red	{0,0,0}	31.499039	259.86707	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:11.307099
4070	cylinder 48	green	{0,0,0}	-272.66354	217.54024	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:11.309978
4071	pentagonal prism 53	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:11.528157
4072	cube 46	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.534454	cube.usd	2025-03-29 14:58:11.53089
4073	hexagonal prism 26	red	{0,0,0}	32.357	258.856	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:11.532915
4074	cylinder 49	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:11.534798
4075	pentagonal prism 54	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:11.754586
4076	cube 47	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.34933	cube.usd	2025-03-29 14:58:11.75822
4077	hexagonal prism 27	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:11.760645
4078	cylinder 50	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:11.762722
4079	pentagonal prism 55	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:11.976309
4080	cube 48	pink	{0,0,0}	-205.90816	345.1413	935.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:11.97856
4081	pentagonal prism 56	red	{0,0,0}	32.357	258.856	932.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:58:11.980541
4082	cylinder 51	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:11.982368
4083	pentagonal prism 57	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:12.205221
4084	cube 49	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 14:58:12.207594
4085	hexagonal prism 28	red	{0,0,0}	31.375294	259.82666	931.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:12.209768
4086	cylinder 52	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:12.212188
4087	pentagonal prism 58	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:12.426641
4088	cube 50	pink	{0,0,0}	-207.6968	346.48944	927.00006	0	0	59.34933	cube.usd	2025-03-29 14:58:12.429599
4089	hexagonal prism 29	red	{0,0,0}	30.514694	260.8514	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:12.431607
4090	cylinder 53	green	{0,0,0}	-272.66354	217.54024	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:12.433466
4091	pentagonal prism 59	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:12.66788
4092	cube 51	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:58:12.671166
4093	hexagonal prism 30	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:12.673033
4094	cylinder 54	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:12.674911
4095	pentagonal prism 60	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:12.909723
4096	cube 52	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 14:58:12.913409
4097	hexagonal prism 31	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:12.915354
4098	cylinder 55	green	{0,0,0}	-270.62216	216.69383	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:12.917171
4099	pentagonal prism 61	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:13.14941
4100	cube 53	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.743565	cube.usd	2025-03-29 14:58:13.153018
4101	hexagonal prism 32	red	{0,0,0}	31.376482	259.8365	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:13.154936
4102	cylinder 56	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:13.15681
4103	pentagonal prism 62	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:13.381864
4104	cube 54	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:58:13.385693
4105	hexagonal prism 33	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:13.387627
4106	cylinder 57	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:13.389434
4107	pentagonal prism 63	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:13.609384
4108	cube 55	pink	{0,0,0}	-205.90816	345.1413	929	0	0	59.620872	cube.usd	2025-03-29 14:58:13.612303
4109	hexagonal prism 34	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:13.614275
4110	cylinder 58	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:13.616192
4111	pentagonal prism 64	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:13.849877
4112	cube 56	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:13.852217
4113	pentagonal prism 65	red	{0,0,0}	32.357	258.856	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:13.854395
4114	cylinder 59	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:13.856344
4115	pentagonal prism 66	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:14.077936
4116	cube 57	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:14.08167
4117	hexagonal prism 35	red	{0,0,0}	31.375294	259.82666	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:14.083735
4118	cylinder 60	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:14.085626
4119	pentagonal prism 67	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:14.313872
4120	cube 58	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:58:14.31631
4121	hexagonal prism 36	red	{0,0,0}	31.376482	259.8365	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:14.318191
4122	cylinder 61	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:14.320122
4123	pentagonal prism 68	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:14.541427
4124	cube 59	pink	{0,0,0}	-205.90816	345.1413	934	0	0	59.420776	cube.usd	2025-03-29 14:58:14.545517
4125	pentagonal prism 69	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 14:58:14.547914
4126	cylinder 62	green	{0,0,0}	-270.62216	216.69383	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:14.549986
4127	pentagonal prism 70	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:14.771223
4128	cube 60	pink	{0,0,0}	-205.90816	345.1413	931.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:14.77505
4129	pentagonal prism 71	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:14.776959
4130	cylinder 63	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 14:58:14.779421
4131	pentagonal prism 72	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 14:58:14.996848
4132	cube 61	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.743565	cube.usd	2025-03-29 14:58:15.000759
4133	hexagonal prism 37	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:15.002988
4134	cylinder 64	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:15.004974
4135	pentagonal prism 73	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:15.246735
4136	cube 62	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:15.250888
4137	hexagonal prism 38	red	{0,0,0}	31.376482	259.8365	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:15.252817
4138	cylinder 65	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:15.25469
4139	pentagonal prism 74	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:15.483608
4140	cube 63	pink	{0,0,0}	-207.6968	346.48944	924	0	0	59.03625	cube.usd	2025-03-29 14:58:15.487621
4141	hexagonal prism 39	red	{0,0,0}	30.514694	260.8514	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:15.489706
4142	cylinder 66	green	{0,0,0}	-272.66354	217.54024	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 14:58:15.491733
4143	pentagonal prism 75	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:15.715692
4144	cube 64	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:15.719235
4145	hexagonal prism 40	red	{0,0,0}	31.376482	259.8365	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:15.721218
4146	cylinder 67	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 14:58:15.723089
4147	pentagonal prism 76	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:15.954576
4148	cube 65	pink	{0,0,0}	-206.88867	345.1413	930.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:15.958117
4149	hexagonal prism 41	red	{0,0,0}	31.376482	259.8365	925.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:15.9601
4150	cylinder 68	green	{0,0,0}	-270.62216	216.69383	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:15.962011
4151	pentagonal prism 77	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:16.180341
4152	cube 66	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:16.183372
4153	pentagonal prism 78	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:16.185288
4154	cylinder 69	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:16.187187
4155	pentagonal prism 79	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:16.405488
4156	cube 67	pink	{0,0,0}	-205.90816	345.1413	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:16.408097
4157	cylinder 70	red	{0,0,0}	31.376482	259.8365	932.00006	0	0	37.405357	cylinder.usd	2025-03-29 14:58:16.410004
4158	cylinder 71	green	{0,0,0}	-270.62216	216.69383	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:16.412123
4159	pentagonal prism 80	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:16.636497
4160	cube 68	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:16.640379
4161	hexagonal prism 42	red	{0,0,0}	31.375294	259.82666	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:16.642286
4162	cylinder 72	green	{0,0,0}	-270.6119	216.68562	933	0	0	18.434948	cylinder.usd	2025-03-29 14:58:16.644228
4163	pentagonal prism 81	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:16.868856
4164	cube 69	pink	{0,0,0}	-205.90816	345.1413	920	0	0	59.03625	cube.usd	2025-03-29 14:58:16.872436
4165	hexagonal prism 43	red	{0,0,0}	31.376482	259.8365	933	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:16.874355
4166	cylinder 73	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:16.876183
4167	pentagonal prism 82	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:17.102363
4168	cube 70	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03625	cube.usd	2025-03-29 14:58:17.104959
4169	pentagonal prism 83	red	{0,0,0}	32.357	258.856	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:17.107116
4170	cylinder 74	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:17.109082
1	pentagonal prism 84	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 14:58:17.348039
4171	cube 71	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:17.352848
4172	hexagonal prism 44	red	{0,0,0}	31.376482	259.8365	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:17.355123
4173	cube 72	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.420776	cube.usd	2025-03-29 14:58:17.5908
4174	hexagonal prism 45	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:17.592789
4175	cube 73	pink	{0,0,0}	-207.6968	346.48944	913.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:17.814099
4176	cube 74	pink	{0,0,0}	-207.6968	346.48944	921.00006	0	0	59.534454	cube.usd	2025-03-29 14:58:18.049823
4177	cube 75	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.03624	cube.usd	2025-03-29 14:58:18.295042
4178	hexagonal prism 46	red	{0,0,0}	31.376482	259.8365	928.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:18.297133
4179	hexagonal prism 47	red	{0,0,0}	30.514694	260.8514	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:18.528664
4180	hexagonal prism 48	red	{0,0,0}	31.376482	259.8365	929	0	0	37.694237	hexagonal prism.usd	2025-03-29 14:58:18.775252
4181	hexagonal prism 49	red	{0,0,0}	30.51353	260.84146	919	0	0	37.874985	hexagonal prism.usd	2025-03-29 14:58:19.00811
4182	hexagonal prism 50	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:19.239965
41	pentagonal prism 95	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:58:19.483784
57	pentagonal prism 99	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:20.183725
4183	hexagonal prism 51	red	{0,0,0}	31.376482	259.8365	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:20.190042
4184	hexagonal prism 52	red	{0,0,0}	31.376482	259.8365	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:20.658497
4185	hexagonal prism 53	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:20.898994
4186	hexagonal prism 54	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:21.35888
4187	hexagonal prism 55	red	{0,0,0}	31.376482	259.8365	927.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 14:58:22.076997
4188	hexagonal prism 56	red	{0,0,0}	31.499039	259.86707	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:22.307466
103	pentagonal prism 113	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:22.536719
107	pentagonal prism 115	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:22.77059
4189	hexagonal prism 57	red	{0,0,0}	30.514694	260.8514	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:22.776675
4190	hexagonal prism 58	red	{0,0,0}	31.376482	259.8365	931.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:23.015074
4191	hexagonal prism 59	red	{0,0,0}	31.376482	259.8365	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:23.239866
4192	hexagonal prism 60	red	{0,0,0}	31.376482	259.8365	935.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 14:58:23.479434
149	pentagonal prism 128	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:25.108468
161	pentagonal prism 131	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:25.812052
213	pentagonal prism 145	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:27.900697
261	pentagonal prism 161	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:30.963108
269	pentagonal prism 163	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:31.438877
319	pentagonal prism 177	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:34.020461
167	hexagonal prism 92	red	{0,0,0}	31.376482	259.8365	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 14:58:35.208381
304	cylinder 154	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 14:58:35.67522
373	pentagonal prism 192	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:36.832267
368	cylinder 170	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:39.449314
425	pentagonal prism 207	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:39.903988
416	cylinder 182	green	{0,0,0}	-270.62216	216.69383	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:42.288576
481	pentagonal prism 224	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 14:58:42.988125
456	cylinder 192	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:44.3963
533	pentagonal prism 238	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 14:58:45.57964
524	cylinder 209	green	{0,0,0}	-270.62216	216.69383	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:48.416391
583	pentagonal prism 255	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:49.11017
585	pentagonal prism 256	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:49.344259
637	pentagonal prism 272	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:52.36453
612	cylinder 232	green	{0,0,0}	-270.62216	216.69383	934	0	0	26.56505	cylinder.usd	2025-03-29 14:58:53.55429
693	pentagonal prism 288	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:55.897577
656	cylinder 244	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:58:56.374138
741	pentagonal prism 305	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:58:58.93581
745	pentagonal prism 306	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:58:59.163226
795	pentagonal prism 322	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:01.967705
797	pentagonal prism 323	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:02.201769
849	pentagonal prism 338	black	{0,0,0}	-127.46696	518.69244	657	0	0	90	pentagonal prism.usd	2025-03-29 14:59:04.990643
820	cylinder 287	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:05.966195
905	pentagonal prism 354	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:08.338444
872	cylinder 300	green	{0,0,0}	-272.66354	217.54024	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:08.817035
957	pentagonal prism 368	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:10.702381
932	cylinder 315	green	{0,0,0}	-270.62216	216.69383	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:12.348901
1009	pentagonal prism 382	red	{0,0,0}	32.357	258.856	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 14:59:12.81872
988	cylinder 330	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:15.632856
1061	pentagonal prism 400	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:16.567249
1042	cube 344	pink	{0,0,0}	-205.90816	345.1413	923.00006	0	0	59.34933	cube.usd	2025-03-29 14:59:17.272937
1113	pentagonal prism 416	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:19.748453
1115	pentagonal prism 417	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:19.981556
1167	pentagonal prism 431	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 14:59:22.826772
1221	pentagonal prism 445	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:25.161677
1152	cylinder 373	green	{0,0,0}	-270.62216	216.69383	933	0	0	26.56505	cylinder.usd	2025-03-29 14:59:25.870005
1273	pentagonal prism 459	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:27.281342
1204	cylinder 386	green	{0,0,0}	-270.6119	217.6661	924	0	0	33.690063	cylinder.usd	2025-03-29 14:59:28.930477
1327	pentagonal prism 476	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 14:59:30.357793
1240	cylinder 395	green	{0,0,0}	-270.62216	216.69383	942.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:31.069627
1381	pentagonal prism 491	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 14:59:32.958947
1276	cylinder 404	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 14:59:32.961038
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
1	2025-03-29 14:54:08.163302	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-03-29 14:54:08.163302	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 14:54:08.163302
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 14:54:08.163302
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-03-29 14:54:08.163302
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
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-03-29 14:54:08.163302
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-03-29 14:54:08.163302
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
1	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscar.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	2025-03-29 14:54:08.163302	2025-03-29 14:54:08.163302
2	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahul.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\N	\N	2025-03-29 14:54:08.163302	2025-03-29 14:54:08.163302
3	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanjay.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	2025-03-29 14:54:08.163302	2025-03-29 14:54:08.163302
4	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehdi.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	2025-03-29 14:54:08.163302	2025-03-29 14:54:08.163302
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 4192, true);


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

