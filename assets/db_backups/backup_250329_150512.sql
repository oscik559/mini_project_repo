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
8	cylinder 3	green	{0,0,0}	-274.62177	216.54764	920	0	0	45	cylinder.usd	2025-03-29 15:04:11.920427
20	cylinder 6	green	{0,0,0}	-274.62177	216.54764	927.00006	0	0	45	cylinder.usd	2025-03-29 15:04:12.760398
23	cube 7	red	{0,0,0}	31.375294	258.8462	926.00006	0	0	37.40536	cube.usd	2025-03-29 15:04:13.049717
27	cube 8	red	{0,0,0}	30.51353	259.85715	937.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:13.338056
31	cube 9	red	{0,0,0}	31.375294	258.8462	928.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:13.617291
35	cube 10	red	{0,0,0}	31.375294	258.8462	931.00006	0	0	37.69424	cube.usd	2025-03-29 15:04:13.901842
38	cube 11	pink	{0,0,0}	-208.67317	346.4762	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:04:14.187887
39	cube 12	red	{0,0,0}	30.51353	259.85715	932.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:14.189852
43	cube 13	red	{0,0,0}	30.51353	259.85715	934	0	0	37.303947	cube.usd	2025-03-29 15:04:14.473223
51	cube 14	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:15.040292
10	hexagonal prism 2	pink	{0,0,0}	-207.86133	347.0892	924	0	0	58.392494	hexagonal prism.usd	2025-03-29 15:04:47.29514
2	cube 2	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:47.297335
4	cylinder 2	green	{0,0,0}	-272.57288	215.70515	920	0	0	45	cylinder.usd	2025-03-29 15:04:47.299177
5	pentagonal prism 3	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:47.610507
12	cylinder 4	pink	{0,0,0}	-207.86133	346.1087	908.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:47.613139
6	pentagonal prism 5	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:47.615201
16	cylinder 5	green	{0,0,0}	-272.57288	215.70515	921.00006	0	0	45	cylinder.usd	2025-03-29 15:04:47.617111
9	pentagonal prism 6	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:48.218346
24	cylinder 7	pink	{0,0,0}	-207.86133	347.0892	929	0	0	59.03625	cylinder.usd	2025-03-29 15:04:48.220781
28	cylinder 8	green	{0,0,0}	-272.57288	215.70515	927.00006	0	0	45	cylinder.usd	2025-03-29 15:04:48.225116
11	pentagonal prism 8	black	{0,0,0}	-128.94427	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:48.522015
18	pentagonal prism 9	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:48.527305
30	cylinder 10	green	{0,0,0}	-274.62177	216.54764	929	0	0	45	cylinder.usd	2025-03-29 15:04:48.530085
19	pentagonal prism 10	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:48.822444
32	cylinder 11	pink	{0,0,0}	-207.86133	346.1087	917.00006	0	0	60.255116	cylinder.usd	2025-03-29 15:04:48.824467
21	pentagonal prism 11	red	{0,0,0}	32.355774	258.8462	933	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:48.826319
36	cylinder 12	green	{0,0,0}	-272.57288	215.70515	928.00006	0	0	45	cylinder.usd	2025-03-29 15:04:48.8286
22	pentagonal prism 12	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:49.126861
40	cylinder 13	pink	{0,0,0}	-207.86133	347.0892	911.00006	0	0	59.534454	cylinder.usd	2025-03-29 15:04:49.131044
25	pentagonal prism 13	red	{0,0,0}	32.355774	258.8462	929	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:04:49.133449
44	cylinder 14	green	{0,0,0}	-272.57288	215.70515	914.00006	0	0	45	cylinder.usd	2025-03-29 15:04:49.135484
33	pentagonal prism 14	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:49.444653
37	pentagonal prism 15	red	{0,0,0}	30.51353	259.85715	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:49.450633
47	cylinder 16	green	{0,0,0}	-274.62177	216.54764	934	0	0	36.869896	cylinder.usd	2025-03-29 15:04:49.452801
41	pentagonal prism 16	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:49.746851
48	cylinder 17	pink	{0,0,0}	-207.86133	347.0892	908.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:49.750564
42	pentagonal prism 17	red	{0,0,0}	31.375294	258.8462	933	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:04:49.752524
52	cylinder 18	green	{0,0,0}	-272.57288	215.70515	921.00006	0	0	45	cylinder.usd	2025-03-29 15:04:49.75435
13	hexagonal prism 4	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	hexagonal prism.usd	2025-03-29 15:04:50.06172
45	pentagonal prism 18	red	{0,0,0}	32.355774	258.8462	934	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:04:50.068483
46	pentagonal prism 19	black	{0,0,0}	-127.95996	519.7143	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:50.375204
49	pentagonal prism 20	red	{0,0,0}	32.482143	259.85715	931.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:50.380015
53	pentagonal prism 21	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:50.677619
15	hexagonal prism 6	black	{0,0,0}	-127.462135	518.67285	652	0	0	90	hexagonal prism.usd	2025-03-29 15:04:52.22236
17	hexagonal prism 7	pink	{0,0,0}	-209.65749	348.44482	923.00006	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:52.533771
3	cube 4	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	36.869896	cube.usd	2025-03-29 15:04:55.710844
29	hexagonal prism 9	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:04:56.023577
34	hexagonal prism 10	pink	{0,0,0}	-207.86133	347.0892	914.00006	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:56.027249
50	hexagonal prism 11	pink	{0,0,0}	-207.86133	347.0892	915	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:56.345414
7	cube 5	red	{0,0,0}	31.375294	258.8462	930.00006	0	0	37.476177	cube.usd	2025-03-29 15:04:56.347269
14	cube 6	red	{0,0,0}	32.355774	258.8462	929	0	0	37.303947	cube.usd	2025-03-29 15:04:56.671931
54	cube 15	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:04:15.32038
55	cube 16	red	{0,0,0}	30.51353	259.85715	932.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:15.322803
59	cube 17	red	{0,0,0}	31.375294	258.8462	938	0	0	37.405357	cube.usd	2025-03-29 15:04:15.611937
63	cube 18	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:04:15.891292
65	hexagonal prism 13	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:16.175574
67	cube 19	red	{0,0,0}	30.51353	259.85715	938	0	0	37.40536	cube.usd	2025-03-29 15:04:16.180449
71	cube 20	red	{0,0,0}	30.633175	260.87607	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:04:16.454337
79	cube 21	red	{0,0,0}	31.375294	258.8462	930.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:17.004984
82	cube 22	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 15:04:17.28882
83	cube 23	red	{0,0,0}	31.375294	258.8462	929	0	0	37.303947	cube.usd	2025-03-29 15:04:17.290775
87	cube 24	red	{0,0,0}	31.375294	258.8462	926.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:17.575083
91	cube 25	red	{0,0,0}	31.375294	258.8462	929	0	0	37.184704	cube.usd	2025-03-29 15:04:17.85849
95	cube 26	red	{0,0,0}	31.375294	258.8462	936.00006	0	0	37.568592	cube.usd	2025-03-29 15:04:18.137991
97	hexagonal prism 18	black	{0,0,0}	-128.94427	519.7143	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:04:18.416541
98	hexagonal prism 19	pink	{0,0,0}	-209.65749	346.4762	919	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:18.420428
99	cube 27	red	{0,0,0}	30.51353	259.85715	927.00006	0	0	37.69424	cube.usd	2025-03-29 15:04:18.42253
101	hexagonal prism 20	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:18.69362
102	cube 28	pink	{0,0,0}	-206.88084	345.12823	909.00006	0	0	59.03624	cube.usd	2025-03-29 15:04:18.69727
103	cube 29	red	{0,0,0}	31.375294	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:04:18.699272
105	hexagonal prism 21	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:18.978512
107	cube 30	red	{0,0,0}	31.375294	258.8462	934	0	0	37.405357	cube.usd	2025-03-29 15:04:18.982898
60	cylinder 20	green	{0,0,0}	-272.57288	215.70515	934	0	0	45	cylinder.usd	2025-03-29 15:04:50.070275
62	cylinder 21	pink	{0,0,0}	-208.67317	348.44482	911.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:50.377521
64	cylinder 22	green	{0,0,0}	-273.63745	216.54764	928.00006	0	0	45	cylinder.usd	2025-03-29 15:04:50.382149
68	cylinder 23	pink	{0,0,0}	-207.86133	347.0892	916.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:50.681279
58	pentagonal prism 22	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:04:50.683519
72	cylinder 24	green	{0,0,0}	-272.57288	215.70515	914.00006	0	0	45	cylinder.usd	2025-03-29 15:04:50.685529
61	pentagonal prism 23	black	{0,0,0}	-127.462135	517.6924	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:50.97723
74	cylinder 25	pink	{0,0,0}	-207.86133	347.0892	902.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:50.981511
66	pentagonal prism 24	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:04:50.98392
76	cylinder 26	green	{0,0,0}	-272.57288	215.70515	926.00006	0	0	45	cylinder.usd	2025-03-29 15:04:50.985989
70	pentagonal prism 25	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:51.283707
78	cylinder 27	pink	{0,0,0}	-207.86133	347.0892	927.00006	0	0	59.03625	cylinder.usd	2025-03-29 15:04:51.287624
80	cylinder 28	green	{0,0,0}	-272.57288	215.70515	928.00006	0	0	45	cylinder.usd	2025-03-29 15:04:51.291923
85	pentagonal prism 27	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:51.586871
84	cylinder 29	pink	{0,0,0}	-207.86133	347.0892	913.00006	0	0	59.03625	cylinder.usd	2025-03-29 15:04:51.589295
86	pentagonal prism 28	red	{0,0,0}	32.355774	258.8462	933	0	0	37.40536	pentagonal prism.usd	2025-03-29 15:04:51.591265
88	cylinder 30	green	{0,0,0}	-272.57288	215.70515	926.00006	0	0	45	cylinder.usd	2025-03-29 15:04:51.593074
89	pentagonal prism 29	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:51.899631
93	pentagonal prism 30	red	{0,0,0}	31.375294	258.8462	934	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:51.905117
90	cylinder 31	green	{0,0,0}	-272.57288	215.70515	923.00006	0	0	45	cylinder.usd	2025-03-29 15:04:51.906846
92	cylinder 32	pink	{0,0,0}	-207.86133	347.0892	923.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:52.225988
94	pentagonal prism 31	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:04:52.2281
96	cylinder 33	green	{0,0,0}	-272.57288	215.70515	914.00006	0	0	45	cylinder.usd	2025-03-29 15:04:52.230594
100	cylinder 34	green	{0,0,0}	-274.62177	216.54764	938	0	0	45	cylinder.usd	2025-03-29 15:04:52.537997
104	cylinder 35	pink	{0,0,0}	-207.86133	347.0892	931.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:55.392382
106	cylinder 36	green	{0,0,0}	-272.57288	215.70515	919	0	0	45	cylinder.usd	2025-03-29 15:04:55.39588
57	hexagonal prism 12	pink	{0,0,0}	-207.86133	347.0892	924	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:56.669864
69	hexagonal prism 14	red	{0,0,0}	30.51353	259.85715	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:04:57.005122
73	hexagonal prism 15	pink	{0,0,0}	-207.86133	347.0892	921.00006	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:57.318589
77	hexagonal prism 16	red	{0,0,0}	30.51353	259.85715	937.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:04:58.285688
81	hexagonal prism 17	red	{0,0,0}	31.497837	259.85715	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:04:58.607606
114	cube 31	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 15:04:19.552599
115	cube 32	red	{0,0,0}	31.375294	258.8462	924	0	0	37.405357	cube.usd	2025-03-29 15:04:19.554909
117	hexagonal prism 22	black	{0,0,0}	-127.95996	519.7143	657	0	0	90	hexagonal prism.usd	2025-03-29 15:04:19.826557
119	cube 33	red	{0,0,0}	31.497837	259.85715	935.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:19.831908
121	hexagonal prism 23	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	hexagonal prism.usd	2025-03-29 15:04:20.103251
122	cube 35	pink	{0,0,0}	-206.88084	345.12823	938	0	0	59.03624	cube.usd	2025-03-29 15:04:20.10714
123	cube 36	red	{0,0,0}	31.375294	258.8462	931.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:20.109066
125	hexagonal prism 24	black	{0,0,0}	-128.94427	519.7143	657	0	0	90	hexagonal prism.usd	2025-03-29 15:04:20.377475
127	cube 37	red	{0,0,0}	30.51353	259.85715	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:04:20.381575
129	hexagonal prism 25	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:20.657517
130	cylinder 46	pink	{0,0,0}	-206.88084	345.12823	907.00006	0	0	60.255116	cylinder.usd	2025-03-29 15:04:20.661181
131	cube 38	red	{0,0,0}	31.375294	258.8462	933	0	0	37.303947	cube.usd	2025-03-29 15:04:20.662958
133	hexagonal prism 26	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:20.942289
134	hexagonal prism 27	pink	{0,0,0}	-208.67317	346.4762	929	0	0	59.03625	hexagonal prism.usd	2025-03-29 15:04:20.945732
135	cube 39	red	{0,0,0}	30.51353	259.85715	929	0	0	37.405357	cube.usd	2025-03-29 15:04:20.947423
137	hexagonal prism 28	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:21.228042
139	cube 40	red	{0,0,0}	31.375294	258.8462	923.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:21.233382
141	hexagonal prism 29	black	{0,0,0}	-127.95996	519.7143	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:21.518843
143	cube 41	red	{0,0,0}	31.497837	259.85715	933	0	0	37.405357	cube.usd	2025-03-29 15:04:21.5254
145	hexagonal prism 30	black	{0,0,0}	-128.94427	519.7143	657	0	0	90	hexagonal prism.usd	2025-03-29 15:04:21.811943
147	cube 42	red	{0,0,0}	30.51353	259.85715	929	0	0	37.405357	cube.usd	2025-03-29 15:04:21.816605
148	cylinder 54	green	{0,0,0}	-274.62177	216.54764	922.00006	0	0	45	cylinder.usd	2025-03-29 15:04:21.818473
150	hexagonal prism 31	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:22.122957
151	cube 43	red	{0,0,0}	31.375294	258.8462	931.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:22.126546
152	cylinder 55	green	{0,0,0}	-272.57288	215.70515	921.00006	0	0	45	cylinder.usd	2025-03-29 15:04:22.128682
156	cylinder 56	green	{0,0,0}	-272.57288	215.70515	928.00006	0	0	45	cylinder.usd	2025-03-29 15:04:22.426998
158	cylinder 57	pink	{0,0,0}	-208.67317	346.4762	923.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:22.698664
159	cube 44	red	{0,0,0}	30.51353	259.85715	933	0	0	37.405357	cube.usd	2025-03-29 15:04:22.700534
160	cylinder 58	green	{0,0,0}	-274.62177	216.54764	934	0	0	45	cylinder.usd	2025-03-29 15:04:22.702295
161	hexagonal prism 32	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:22.979881
110	pentagonal prism 33	red	{0,0,0}	31.375294	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:55.394195
113	pentagonal prism 34	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:55.706886
108	cylinder 37	pink	{0,0,0}	-207.86133	347.0892	908.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:55.708978
111	cylinder 38	green	{0,0,0}	-272.57288	215.70515	917.00006	0	0	45	cylinder.usd	2025-03-29 15:04:55.71263
149	pentagonal prism 35	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:04:56.029142
112	cylinder 39	green	{0,0,0}	-272.57288	215.70515	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:04:56.030886
153	pentagonal prism 36	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:56.341977
116	cylinder 40	green	{0,0,0}	-272.57288	215.70515	920	0	0	45	cylinder.usd	2025-03-29 15:04:56.349098
154	pentagonal prism 37	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:56.666038
118	cylinder 41	green	{0,0,0}	-272.57288	215.70515	918.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:04:56.673883
155	pentagonal prism 38	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:57.000489
120	cylinder 42	pink	{0,0,0}	-209.65749	348.44482	907.00006	0	0	59.03625	cylinder.usd	2025-03-29 15:04:57.002781
124	cylinder 43	green	{0,0,0}	-274.62177	216.54764	918.00006	0	0	45	cylinder.usd	2025-03-29 15:04:57.006997
157	pentagonal prism 39	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	pentagonal prism.usd	2025-03-29 15:04:57.314768
126	cylinder 44	green	{0,0,0}	-272.57288	215.70515	916.00006	0	0	45	cylinder.usd	2025-03-29 15:04:57.32352
128	cylinder 45	pink	{0,0,0}	-209.65749	348.44482	934	0	0	59.03625	cylinder.usd	2025-03-29 15:04:57.646116
132	cylinder 47	green	{0,0,0}	-274.62177	216.54764	0	0	0	26.56505	cylinder.usd	2025-03-29 15:04:57.649926
136	cylinder 48	pink	{0,0,0}	-207.86133	347.0892	928.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:57.966979
138	cylinder 49	green	{0,0,0}	-272.57288	215.70515	0	0	0	18.434948	cylinder.usd	2025-03-29 15:04:57.971571
140	cylinder 50	pink	{0,0,0}	-209.65749	348.44482	912.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:58.283656
144	cylinder 52	pink	{0,0,0}	-209.65749	348.44482	920	0	0	58.392494	cylinder.usd	2025-03-29 15:04:58.605425
146	cylinder 53	green	{0,0,0}	-274.62177	216.54764	0	0	0	45	cylinder.usd	2025-03-29 15:04:58.609629
162	cylinder 59	pink	{0,0,0}	-209.65749	346.4762	931.00006	0	0	59.03625	cylinder.usd	2025-03-29 15:04:22.982093
163	cube 45	red	{0,0,0}	30.51353	259.85715	931.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:22.984097
164	cylinder 60	green	{0,0,0}	-274.62177	216.54764	921.00006	0	0	45	cylinder.usd	2025-03-29 15:04:22.986009
166	cube 46	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:04:23.278014
168	cylinder 61	green	{0,0,0}	-272.57288	215.70515	921.00006	0	0	38.659805	cylinder.usd	2025-03-29 15:04:23.281696
169	hexagonal prism 33	black	{0,0,0}	-127.462135	517.6924	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:04:23.564756
170	cylinder 62	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.03624	cylinder.usd	2025-03-29 15:04:23.568556
172	cylinder 63	green	{0,0,0}	-272.57288	215.70515	926.00006	0	0	45	cylinder.usd	2025-03-29 15:04:23.572453
173	hexagonal prism 34	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:04:23.847049
174	hexagonal prism 35	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:23.850443
175	cube 47	red	{0,0,0}	30.51353	259.85715	938	0	0	37.303947	cube.usd	2025-03-29 15:04:23.85231
176	cylinder 64	green	{0,0,0}	-274.62177	216.54764	929	0	0	45	cylinder.usd	2025-03-29 15:04:23.854147
179	cube 48	red	{0,0,0}	31.375294	258.8462	929	0	0	37.303947	cube.usd	2025-03-29 15:04:24.136712
180	cylinder 65	green	{0,0,0}	-272.57288	215.70515	929	0	0	45	cylinder.usd	2025-03-29 15:04:24.138426
182	pentagonal prism 46	pink	{0,0,0}	-208.67317	346.4762	915	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:24.419839
183	pentagonal prism 47	red	{0,0,0}	30.51353	259.85715	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:24.421842
184	cylinder 66	green	{0,0,0}	-274.62177	216.54764	929	0	0	39.80557	cylinder.usd	2025-03-29 15:04:24.424
185	hexagonal prism 36	black	{0,0,0}	-127.96484	518.7498	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:24.714609
186	pentagonal prism 48	pink	{0,0,0}	-207.6968	345.5051	919	0	0	59.743565	pentagonal prism.usd	2025-03-29 15:04:24.718167
187	pentagonal prism 49	red	{0,0,0}	31.499039	258.88272	938	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:04:24.719956
188	cylinder 67	green	{0,0,0}	-273.6479	215.57155	922.00006	0	0	45	cylinder.usd	2025-03-29 15:04:24.721667
189	hexagonal prism 37	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:25.022087
190	cylinder 68	pink	{0,0,0}	-208.67317	346.4762	915	0	0	59.03624	cylinder.usd	2025-03-29 15:04:25.027759
191	pentagonal prism 50	red	{0,0,0}	30.51353	259.85715	941.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:25.030673
192	cylinder 69	green	{0,0,0}	-274.62177	216.54764	929	0	0	45	cylinder.usd	2025-03-29 15:04:25.032913
193	hexagonal prism 38	black	{0,0,0}	-128.94427	519.7143	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:04:25.331652
194	pentagonal prism 51	pink	{0,0,0}	-208.67317	346.4762	928.00006	0	0	59.743565	pentagonal prism.usd	2025-03-29 15:04:25.335429
195	pentagonal prism 52	red	{0,0,0}	30.51353	259.85715	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:25.338679
196	cylinder 70	green	{0,0,0}	-274.62177	216.54764	921.00006	0	0	45	cylinder.usd	2025-03-29 15:04:25.341135
197	hexagonal prism 39	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:25.649708
198	pentagonal prism 53	pink	{0,0,0}	-208.67317	346.4762	919	0	0	59.534454	pentagonal prism.usd	2025-03-29 15:04:25.651783
199	pentagonal prism 54	red	{0,0,0}	30.51353	259.85715	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:25.653719
200	cylinder 71	green	{0,0,0}	-274.62177	216.54764	920	0	0	45	cylinder.usd	2025-03-29 15:04:25.656858
201	pentagonal prism 55	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	pentagonal prism.usd	2025-03-29 15:04:25.964521
202	cylinder 72	pink	{0,0,0}	-206.88084	345.12823	914.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:25.967984
203	cube 49	red	{0,0,0}	31.375294	258.8462	929	0	0	37.405357	cube.usd	2025-03-29 15:04:25.969736
204	cylinder 73	green	{0,0,0}	-272.57288	215.70515	918.00006	0	0	45	cylinder.usd	2025-03-29 15:04:25.971477
205	pentagonal prism 56	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:26.252872
206	pentagonal prism 57	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:26.256121
207	cube 50	red	{0,0,0}	31.497837	259.85715	934	0	0	37.303947	cube.usd	2025-03-29 15:04:26.258365
208	cylinder 75	green	{0,0,0}	-273.63745	216.54764	911.00006	0	0	45	cylinder.usd	2025-03-29 15:04:26.260887
209	pentagonal prism 58	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:26.562106
210	cube 51	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:04:26.564344
211	cube 52	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	cube.usd	2025-03-29 15:04:26.566315
212	cylinder 76	green	{0,0,0}	-273.63745	216.54764	933	0	0	38.659805	cylinder.usd	2025-03-29 15:04:26.568355
213	pentagonal prism 59	black	{0,0,0}	-129.44986	521.75214	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:26.852907
167	pentagonal prism 41	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:57.644059
171	pentagonal prism 42	black	{0,0,0}	-127.462135	517.6924	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:57.964829
177	pentagonal prism 43	red	{0,0,0}	31.375294	258.8462	933	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:57.969043
178	pentagonal prism 44	black	{0,0,0}	-128.94427	519.7143	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:58.281246
181	pentagonal prism 45	black	{0,0,0}	-128.94427	519.7143	657	0	0	90	pentagonal prism.usd	2025-03-29 15:04:58.601696
214	pentagonal prism 60	pink	{0,0,0}	-209.49138	347.83475	919	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:26.856672
215	pentagonal prism 61	red	{0,0,0}	30.633175	260.87607	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:26.859043
216	cylinder 77	green	{0,0,0}	-275.69858	217.39671	931.00006	0	0	39.80557	cylinder.usd	2025-03-29 15:04:26.861598
217	hexagonal prism 40	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:27.142878
218	cylinder 78	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:27.145458
219	pentagonal prism 62	red	{0,0,0}	31.375294	258.8462	937.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:04:27.147593
220	cylinder 79	green	{0,0,0}	-272.57288	215.70515	924	0	0	36.869896	cylinder.usd	2025-03-29 15:04:27.149404
221	pentagonal prism 63	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	pentagonal prism.usd	2025-03-29 15:04:27.431517
222	pentagonal prism 64	pink	{0,0,0}	-206.88084	345.12823	905.00006	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:27.433756
223	cube 53	red	{0,0,0}	31.375294	258.8462	929	0	0	37.405357	cube.usd	2025-03-29 15:04:27.435698
224	cylinder 80	green	{0,0,0}	-272.57288	215.70515	921.00006	0	0	45	cylinder.usd	2025-03-29 15:04:27.437441
225	pentagonal prism 65	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:27.727932
226	cylinder 81	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cylinder.usd	2025-03-29 15:04:27.731499
227	cube 54	red	{0,0,0}	31.375294	258.8462	934	0	0	36.869896	cube.usd	2025-03-29 15:04:27.73493
228	cylinder 82	green	{0,0,0}	-272.57288	215.70515	938	0	0	45	cylinder.usd	2025-03-29 15:04:27.738094
229	pentagonal prism 66	black	{0,0,0}	-128.94427	519.7143	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:28.019895
230	hexagonal prism 42	pink	{0,0,0}	-208.67317	346.4762	901	0	0	57.994617	hexagonal prism.usd	2025-03-29 15:04:28.022104
231	cube 55	red	{0,0,0}	30.51353	259.85715	932.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:28.02398
232	cylinder 83	green	{0,0,0}	-274.62177	216.54764	931.00006	0	0	45	cylinder.usd	2025-03-29 15:04:28.026022
233	pentagonal prism 67	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:28.304108
234	cylinder 84	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:28.306059
235	cube 56	red	{0,0,0}	31.375294	258.8462	930.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:28.307902
236	cylinder 85	green	{0,0,0}	-272.57288	215.70515	927.00006	0	0	45	cylinder.usd	2025-03-29 15:04:28.309692
237	hexagonal prism 43	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:28.591347
238	cylinder 86	pink	{0,0,0}	-207.86133	345.12823	914.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:28.595314
239	cube 57	red	{0,0,0}	31.375294	258.8462	931.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:28.597341
240	cylinder 87	green	{0,0,0}	-272.57288	215.70515	922.00006	0	0	45	cylinder.usd	2025-03-29 15:04:28.599285
241	hexagonal prism 44	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:28.875829
242	hexagonal prism 45	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	hexagonal prism.usd	2025-03-29 15:04:28.878021
243	cube 58	red	{0,0,0}	31.375294	258.8462	918.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:28.880412
244	cylinder 88	green	{0,0,0}	-272.57288	215.70515	931.00006	0	0	45	cylinder.usd	2025-03-29 15:04:28.882702
245	pentagonal prism 68	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:29.18783
246	cylinder 89	pink	{0,0,0}	-208.67317	346.4762	914.00006	0	0	59.03625	cylinder.usd	2025-03-29 15:04:29.190024
247	cube 59	red	{0,0,0}	30.51353	259.85715	934	0	0	37.405357	cube.usd	2025-03-29 15:04:29.192851
248	cylinder 90	green	{0,0,0}	-274.62177	216.54764	929	0	0	45	cylinder.usd	2025-03-29 15:04:29.194972
249	hexagonal prism 46	black	{0,0,0}	-128.94427	519.7143	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:04:29.489253
250	cylinder 91	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	57.994617	cylinder.usd	2025-03-29 15:04:29.49295
251	pentagonal prism 69	red	{0,0,0}	30.51353	259.85715	937.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:29.495513
252	cylinder 92	green	{0,0,0}	-274.62177	216.54764	924	0	0	45	cylinder.usd	2025-03-29 15:04:29.498281
253	pentagonal prism 70	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	pentagonal prism.usd	2025-03-29 15:04:29.780043
254	cylinder 93	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:29.78384
255	cube 60	red	{0,0,0}	31.375294	258.8462	928.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:29.785921
256	cylinder 94	green	{0,0,0}	-272.57288	215.70515	932.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:04:29.787727
257	pentagonal prism 71	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:30.076577
258	cylinder 95	pink	{0,0,0}	-208.67317	346.4762	914.00006	0	0	59.03625	cylinder.usd	2025-03-29 15:04:30.080534
259	cube 61	red	{0,0,0}	30.51353	259.85715	933	0	0	37.303947	cube.usd	2025-03-29 15:04:30.08272
260	cylinder 96	green	{0,0,0}	-274.62177	216.54764	937.00006	0	0	45	cylinder.usd	2025-03-29 15:04:30.084762
261	hexagonal prism 47	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:04:30.374249
262	cylinder 97	pink	{0,0,0}	-206.88084	345.12823	913.00006	0	0	57.26477	cylinder.usd	2025-03-29 15:04:30.376283
263	cube 62	red	{0,0,0}	31.375294	258.8462	934	0	0	37.146687	cube.usd	2025-03-29 15:04:30.378316
264	cylinder 98	green	{0,0,0}	-272.57288	215.70515	924	0	0	45	cylinder.usd	2025-03-29 15:04:30.380845
265	pentagonal prism 72	black	{0,0,0}	-127.46696	516.73145	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:30.660023
266	cylinder 99	pink	{0,0,0}	-206.88867	344.1608	929	0	0	56.309937	cylinder.usd	2025-03-29 15:04:30.66417
267	cube 63	red	{0,0,0}	31.376482	257.87546	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:04:30.666179
268	cylinder 100	green	{0,0,0}	-272.5832	214.7328	921.00006	0	0	45	cylinder.usd	2025-03-29 15:04:30.668163
269	pentagonal prism 73	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:30.943555
270	pentagonal prism 74	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:30.947625
271	cube 64	red	{0,0,0}	31.375294	258.8462	931.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:30.949802
272	cylinder 101	green	{0,0,0}	-272.57288	215.70515	923.00006	0	0	45	cylinder.usd	2025-03-29 15:04:30.951605
273	pentagonal prism 75	black	{0,0,0}	-128.94427	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:31.224969
274	cylinder 102	pink	{0,0,0}	-208.67317	346.4762	922.00006	0	0	59.03625	cylinder.usd	2025-03-29 15:04:31.227244
275	cube 65	red	{0,0,0}	31.497837	259.85715	934	0	0	37.405357	cube.usd	2025-03-29 15:04:31.229086
276	cylinder 103	green	{0,0,0}	-274.62177	216.54764	928.00006	0	0	45	cylinder.usd	2025-03-29 15:04:31.231244
277	pentagonal prism 76	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:31.510109
278	pentagonal prism 77	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03625	pentagonal prism.usd	2025-03-29 15:04:31.513879
279	cube 66	red	{0,0,0}	31.375294	258.8462	928.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:31.516047
280	cylinder 104	green	{0,0,0}	-272.57288	215.70515	929	0	0	45	cylinder.usd	2025-03-29 15:04:31.51809
281	pentagonal prism 78	black	{0,0,0}	-127.462135	517.6924	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:31.797065
282	cylinder 105	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.03625	cylinder.usd	2025-03-29 15:04:31.801011
283	cube 67	red	{0,0,0}	31.375294	258.8462	928.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:31.803089
284	cylinder 106	green	{0,0,0}	-272.57288	215.70515	922.00006	0	0	45	cylinder.usd	2025-03-29 15:04:31.80491
285	hexagonal prism 48	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	hexagonal prism.usd	2025-03-29 15:04:32.081643
286	hexagonal prism 49	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:32.085245
287	cube 68	red	{0,0,0}	31.375294	258.8462	931.00006	0	0	36.869892	cube.usd	2025-03-29 15:04:32.087055
288	cylinder 107	green	{0,0,0}	-272.57288	215.70515	926.00006	0	0	45	cylinder.usd	2025-03-29 15:04:32.088918
289	pentagonal prism 79	black	{0,0,0}	-127.462135	517.6924	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:32.375478
290	cylinder 108	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.03624	cylinder.usd	2025-03-29 15:04:32.377537
291	cube 69	red	{0,0,0}	31.375294	258.8462	936.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:32.379571
292	cylinder 109	green	{0,0,0}	-272.57288	215.70515	919	0	0	45	cylinder.usd	2025-03-29 15:04:32.382265
293	hexagonal prism 50	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:32.934493
294	pentagonal prism 80	pink	{0,0,0}	-206.88084	345.12823	914.00006	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:32.937948
295	pentagonal prism 81	red	{0,0,0}	31.375294	258.8462	932.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:32.939739
296	cylinder 110	green	{0,0,0}	-272.57288	215.70515	922.00006	0	0	45	cylinder.usd	2025-03-29 15:04:32.941499
297	pentagonal prism 82	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:33.230618
298	cylinder 111	pink	{0,0,0}	-206.88084	345.12823	909.00006	0	0	58.392494	cylinder.usd	2025-03-29 15:04:33.234668
299	cube 70	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:33.236894
300	cylinder 112	green	{0,0,0}	-272.57288	215.70515	930.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:04:33.238713
301	pentagonal prism 83	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:33.513677
302	cylinder 113	pink	{0,0,0}	-208.67317	346.4762	919	0	0	59.03625	cylinder.usd	2025-03-29 15:04:33.516561
303	hexagonal prism 51	red	{0,0,0}	30.51353	259.85715	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:04:33.518734
304	cylinder 114	green	{0,0,0}	-274.62177	216.54764	931.00006	0	0	45	cylinder.usd	2025-03-29 15:04:33.520641
305	pentagonal prism 84	black	{0,0,0}	-129.44986	521.75214	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:33.796918
306	hexagonal prism 52	pink	{0,0,0}	-209.49138	347.83475	918.00006	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:33.800836
307	cube 71	red	{0,0,0}	30.633175	260.87607	927.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:33.802868
308	cylinder 115	green	{0,0,0}	-275.69858	217.39671	922.00006	0	0	45	cylinder.usd	2025-03-29 15:04:33.804794
309	pentagonal prism 85	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:34.097177
310	pentagonal prism 86	pink	{0,0,0}	-206.88084	345.12823	913.00006	0	0	57.528805	pentagonal prism.usd	2025-03-29 15:04:34.10094
311	cube 72	red	{0,0,0}	31.375294	258.8462	940.00006	0	0	37.568592	cube.usd	2025-03-29 15:04:34.103014
312	cylinder 116	green	{0,0,0}	-272.57288	215.70515	921.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:04:34.104831
313	pentagonal prism 87	black	{0,0,0}	-129.44986	521.75214	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:34.418603
314	cylinder 117	pink	{0,0,0}	-209.49138	348.8229	918.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:34.420993
315	cube 73	red	{0,0,0}	30.633175	260.87607	932.00006	0	0	37.568592	cube.usd	2025-03-29 15:04:34.422812
316	cylinder 118	green	{0,0,0}	-275.69858	217.39671	924	0	0	45	cylinder.usd	2025-03-29 15:04:34.424572
317	hexagonal prism 53	black	{0,0,0}	-127.462135	517.6924	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:04:34.713807
318	pentagonal prism 88	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:34.716177
319	cube 74	red	{0,0,0}	31.375294	258.8462	940.00006	0	0	37.568592	cube.usd	2025-03-29 15:04:34.718272
320	cylinder 119	green	{0,0,0}	-272.57288	215.70515	934	0	0	45	cylinder.usd	2025-03-29 15:04:34.720176
321	hexagonal prism 54	black	{0,0,0}	-127.46696	516.73145	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:35.004708
322	hexagonal prism 55	pink	{0,0,0}	-206.88867	344.1608	929	0	0	59.03625	hexagonal prism.usd	2025-03-29 15:04:35.008317
323	cube 75	red	{0,0,0}	31.376482	257.87546	924	0	0	37.405357	cube.usd	2025-03-29 15:04:35.010318
324	cylinder 120	green	{0,0,0}	-272.5832	214.7328	938	0	0	45	cylinder.usd	2025-03-29 15:04:35.012266
325	hexagonal prism 56	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:35.315125
326	cylinder 121	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:35.317512
327	pentagonal prism 89	red	{0,0,0}	31.375294	258.8462	929	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:04:35.319715
328	cylinder 122	green	{0,0,0}	-272.57288	215.70515	925.00006	0	0	45	cylinder.usd	2025-03-29 15:04:35.321725
329	pentagonal prism 90	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:35.600312
330	pentagonal prism 91	pink	{0,0,0}	-208.67317	346.4762	917.00006	0	0	59.03625	pentagonal prism.usd	2025-03-29 15:04:35.602858
331	cube 76	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:35.604869
332	cylinder 123	green	{0,0,0}	-274.62177	216.54764	926.00006	0	0	45	cylinder.usd	2025-03-29 15:04:35.606685
333	hexagonal prism 57	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	hexagonal prism.usd	2025-03-29 15:04:35.930976
334	pentagonal prism 92	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:35.936108
335	pentagonal prism 93	red	{0,0,0}	31.375294	258.8462	934	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:35.938215
336	cylinder 124	green	{0,0,0}	-272.57288	215.70515	930.00006	0	0	45	cylinder.usd	2025-03-29 15:04:35.939965
337	pentagonal prism 94	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:36.219682
338	pentagonal prism 95	pink	{0,0,0}	-206.88084	346.1087	929	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:36.223449
339	cube 77	red	{0,0,0}	31.375294	258.8462	926.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:36.226617
340	cylinder 125	green	{0,0,0}	-272.57288	215.70515	926.00006	0	0	45	cylinder.usd	2025-03-29 15:04:36.22917
341	pentagonal prism 96	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:36.516145
342	pentagonal prism 97	pink	{0,0,0}	-206.88084	345.12823	907.00006	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:36.520204
343	pentagonal prism 98	red	{0,0,0}	31.375294	258.8462	933	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:04:36.522433
344	cylinder 126	green	{0,0,0}	-272.57288	215.70515	929	0	0	45	cylinder.usd	2025-03-29 15:04:36.524331
345	pentagonal prism 99	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	pentagonal prism.usd	2025-03-29 15:04:36.832257
346	cylinder 127	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:36.836416
347	cube 78	red	{0,0,0}	32.355774	258.8462	937.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:36.838469
348	cylinder 128	green	{0,0,0}	-272.57288	215.70515	931.00006	0	0	45	cylinder.usd	2025-03-29 15:04:36.840279
349	pentagonal prism 100	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:37.119386
350	cylinder 129	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cylinder.usd	2025-03-29 15:04:37.12314
351	pentagonal prism 101	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:37.125083
352	cylinder 130	green	{0,0,0}	-272.57288	215.70515	931.00006	0	0	45	cylinder.usd	2025-03-29 15:04:37.126825
353	pentagonal prism 102	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	pentagonal prism.usd	2025-03-29 15:04:37.421659
354	cylinder 131	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03624	cylinder.usd	2025-03-29 15:04:37.423994
355	pentagonal prism 103	red	{0,0,0}	31.375294	258.8462	931.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:04:37.427196
356	cylinder 132	green	{0,0,0}	-272.57288	215.70515	924	0	0	45	cylinder.usd	2025-03-29 15:04:37.429941
357	hexagonal prism 58	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	hexagonal prism.usd	2025-03-29 15:04:37.721789
358	pentagonal prism 104	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:37.725341
359	pentagonal prism 105	red	{0,0,0}	31.375294	258.8462	934	0	0	37.184704	pentagonal prism.usd	2025-03-29 15:04:37.727168
360	cylinder 133	green	{0,0,0}	-272.57288	215.70515	932.00006	0	0	45	cylinder.usd	2025-03-29 15:04:37.728941
361	pentagonal prism 106	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:38.033509
362	cylinder 134	pink	{0,0,0}	-208.67317	346.4762	928.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:38.036122
363	cube 79	red	{0,0,0}	30.51353	259.85715	930.00006	0	0	37.303947	cube.usd	2025-03-29 15:04:38.03842
364	cylinder 135	green	{0,0,0}	-274.62177	216.54764	927.00006	0	0	45	cylinder.usd	2025-03-29 15:04:38.040349
365	pentagonal prism 107	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:38.338636
366	pentagonal prism 108	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03624	pentagonal prism.usd	2025-03-29 15:04:38.34238
367	cube 80	red	{0,0,0}	32.355774	258.8462	924	0	0	37.303947	cube.usd	2025-03-29 15:04:38.344532
368	cylinder 136	green	{0,0,0}	-272.57288	215.70515	929	0	0	36.869896	cylinder.usd	2025-03-29 15:04:38.346366
369	pentagonal prism 109	black	{0,0,0}	-127.462135	517.6924	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:38.655249
370	pentagonal prism 110	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	57.994617	pentagonal prism.usd	2025-03-29 15:04:38.658893
371	cube 81	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cube.usd	2025-03-29 15:04:38.660772
372	cylinder 137	green	{0,0,0}	-272.57288	215.70515	927.00006	0	0	45	cylinder.usd	2025-03-29 15:04:38.662528
373	pentagonal prism 111	black	{0,0,0}	-127.95996	519.7143	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:38.944512
374	cylinder 138	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:38.94682
375	pentagonal prism 112	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:04:38.948734
376	cylinder 139	green	{0,0,0}	-273.63745	216.54764	934	0	0	36.869896	cylinder.usd	2025-03-29 15:04:38.950555
377	hexagonal prism 59	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	hexagonal prism.usd	2025-03-29 15:04:39.271263
378	hexagonal prism 60	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:39.276243
379	cube 82	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.234837	cube.usd	2025-03-29 15:04:39.278145
380	cylinder 140	green	{0,0,0}	-272.57288	215.70515	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:04:39.279957
381	pentagonal prism 113	black	{0,0,0}	-129.44986	521.75214	657	0	0	90	pentagonal prism.usd	2025-03-29 15:04:39.587223
382	cylinder 141	pink	{0,0,0}	-209.49138	348.8229	920	0	0	59.03624	cylinder.usd	2025-03-29 15:04:39.590706
383	cube 83	red	{0,0,0}	31.621342	260.87607	922.00006	0	0	37.405357	cube.usd	2025-03-29 15:04:39.594484
384	cylinder 142	green	{0,0,0}	-275.69858	217.39671	927.00006	0	0	45	cylinder.usd	2025-03-29 15:04:39.596647
385	pentagonal prism 114	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:39.889888
386	hexagonal prism 61	pink	{0,0,0}	-206.88084	346.1087	919	0	0	59.03624	hexagonal prism.usd	2025-03-29 15:04:39.892709
1	pentagonal prism 2	black	{0,0,0}	-127.462135	517.6924	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:04:47.288763
387	pentagonal prism 7	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:04:48.222845
388	cylinder 9	pink	{0,0,0}	-208.67317	347.4605	915	0	0	59.03624	cylinder.usd	2025-03-29 15:04:48.525465
389	cylinder 15	pink	{0,0,0}	-209.65749	348.44482	907.00006	0	0	59.03624	cylinder.usd	2025-03-29 15:04:49.448605
56	cylinder 19	pink	{0,0,0}	-207.86133	347.0892	927.00006	0	0	59.03625	cylinder.usd	2025-03-29 15:04:50.066159
75	pentagonal prism 26	red	{0,0,0}	32.355774	258.8462	924	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:04:51.289764
390	hexagonal prism 5	pink	{0,0,0}	-207.86133	347.0892	926.00006	0	0	59.03625	hexagonal prism.usd	2025-03-29 15:04:51.90331
109	pentagonal prism 32	black	{0,0,0}	-128.94427	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 15:04:52.530254
391	cube 3	red	{0,0,0}	30.51353	259.85715	932.00006	0	0	37.568592	cube.usd	2025-03-29 15:04:52.535828
26	hexagonal prism 8	black	{0,0,0}	-127.462135	517.6924	657	0	0	90	hexagonal prism.usd	2025-03-29 15:04:55.390288
165	pentagonal prism 40	red	{0,0,0}	31.375294	258.8462	929	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:04:57.32147
392	cuboid 2	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.303947	cuboid.usd	2025-03-29 15:04:57.648124
142	cylinder 51	green	{0,0,0}	-274.62177	216.54764	920	0	0	45	cylinder.usd	2025-03-29 15:04:58.288013
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
1	2025-03-29 15:00:00.404212	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-03-29 15:00:00.404212	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 15:00:00.404212
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 15:00:00.404212
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-03-29 15:00:00.404212
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
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-03-29 15:00:00.404212
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-03-29 15:00:00.404212
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
1	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscar.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	2025-03-29 15:00:00.404212	2025-03-29 15:00:00.404212
2	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahul.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\N	\N	2025-03-29 15:00:00.404212	2025-03-29 15:00:00.404212
3	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanjay.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	2025-03-29 15:00:00.404212	2025-03-29 15:00:00.404212
4	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehdi.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	2025-03-29 15:00:00.404212	2025-03-29 15:00:00.404212
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 392, true);


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

