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
1	pentagonal prism 2	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:22.619157
2	cube 2	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:32:22.624111
3	hexagonal prism 2	red	{0,0,0}	31.375294	259.82666	919	0	0	37.476177	hexagonal prism.usd	2025-03-29 15:32:22.626277
4	cylinder 2	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:22.628252
5	pentagonal prism 3	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:22.859478
6	cube 3	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:32:22.863061
7	cube 5	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:22.86494
8	cylinder 3	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:32:22.866974
9	pentagonal prism 4	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:23.082519
10	cube 6	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.34933	cube.usd	2025-03-29 15:32:23.086324
11	pentagonal prism 6	red	{0,0,0}	31.497837	259.85715	919	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:32:23.088162
12	cylinder 4	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:32:23.090013
13	pentagonal prism 7	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:23.31638
14	cube 7	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:23.318766
15	cube 8	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cube.usd	2025-03-29 15:32:23.32065
16	cylinder 5	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:23.322425
17	pentagonal prism 8	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:23.545671
18	cube 9	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.62088	cube.usd	2025-03-29 15:32:23.549275
19	pentagonal prism 9	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:23.551578
20	cylinder 6	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:23.553519
21	pentagonal prism 10	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:23.772468
22	cube 10	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:23.774729
23	pentagonal prism 11	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:23.776785
24	cylinder 7	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:23.778577
25	pentagonal prism 12	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:24.006401
26	cube 11	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:24.010298
27	pentagonal prism 13	red	{0,0,0}	32.355774	258.8462	924	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:32:24.012438
28	cylinder 8	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:24.014541
29	pentagonal prism 14	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:24.240985
30	cube 12	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:32:24.245213
31	cube 13	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.874985	cube.usd	2025-03-29 15:32:24.247094
32	cylinder 9	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:32:24.249035
33	pentagonal prism 15	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:24.471118
34	cube 14	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:24.474933
35	cube 15	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:32:24.477282
36	cylinder 10	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:24.47926
37	pentagonal prism 16	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:32:24.711204
38	cube 16	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:24.713809
39	pentagonal prism 17	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:24.71564
40	cylinder 11	green	{0,0,0}	-270.6119	216.68562	919	0	0	36.869896	cylinder.usd	2025-03-29 15:32:24.717608
41	pentagonal prism 18	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:24.937891
42	cube 17	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:24.942183
43	pentagonal prism 19	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:24.944718
44	cylinder 12	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:24.946937
45	pentagonal prism 20	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:25.174123
46	cube 18	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:32:25.178136
47	cuboid 2	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:25.180502
48	cylinder 13	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:32:25.182629
49	pentagonal prism 21	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:32:25.410723
50	cube 19	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:32:25.414949
51	pentagonal prism 22	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:25.416932
52	cylinder 14	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:25.41928
53	pentagonal prism 23	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:25.644192
54	cube 20	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:25.648135
55	cube 21	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:32:25.650036
56	cylinder 15	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:25.652725
57	pentagonal prism 24	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 15:32:25.876559
58	cube 22	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:25.880838
59	pentagonal prism 25	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:32:25.882918
60	cylinder 16	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:32:25.885043
61	pentagonal prism 26	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:26.111323
62	cube 23	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:26.115445
63	pentagonal prism 27	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:26.117392
64	cylinder 17	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:32:26.119573
65	pentagonal prism 28	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:26.345137
66	cube 24	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:26.347818
67	pentagonal prism 29	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:26.349828
68	cylinder 18	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:26.351717
69	pentagonal prism 30	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:26.572083
70	cube 25	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:32:26.576167
71	cube 26	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:26.578274
72	cylinder 19	green	{0,0,0}	-270.6119	216.68562	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:26.58022
73	pentagonal prism 31	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:26.795181
74	cube 27	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:26.798099
75	cuboid 3	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:32:26.799928
76	cylinder 20	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:26.80175
77	pentagonal prism 32	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:27.023812
78	cube 28	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:27.026204
79	pentagonal prism 33	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:27.028527
80	cylinder 21	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:32:27.030761
81	pentagonal prism 34	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:32:27.257784
82	cube 29	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:32:27.260342
83	hexagonal prism 3	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:32:27.262479
84	cylinder 22	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:32:27.264501
85	pentagonal prism 35	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:27.477388
86	cube 30	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:27.480778
87	cube 31	red	{0,0,0}	31.497837	259.85715	924	0	0	37.746803	cube.usd	2025-03-29 15:32:27.482582
88	cylinder 23	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:27.484539
89	pentagonal prism 36	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:27.709285
90	cube 32	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:32:27.711628
91	pentagonal prism 37	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:27.713842
92	cylinder 24	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:32:27.715765
93	pentagonal prism 38	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:27.945051
94	cube 33	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:27.949124
95	cuboid 4	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:27.950959
96	cylinder 25	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:32:27.95316
97	pentagonal prism 39	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:32:28.175582
98	cube 34	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.03625	cube.usd	2025-03-29 15:32:28.177965
99	pentagonal prism 40	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:28.180155
100	cylinder 26	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:32:28.182039
101	hexagonal prism 5	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:32:28.414156
102	cube 35	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:28.417864
103	pentagonal prism 41	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:28.419964
104	cylinder 27	green	{0,0,0}	-272.65317	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:28.422178
105	pentagonal prism 42	black	{0,0,0}	-128.94427	520.6986	652	0	0	0	pentagonal prism.usd	2025-03-29 15:32:28.650465
106	cube 36	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:32:28.653292
107	cube 37	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:28.65564
108	cylinder 28	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:28.657646
109	pentagonal prism 43	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:28.87964
110	cube 38	pink	{0,0,0}	-206.70456	346.4762	923.00006	0	0	59.743565	cube.usd	2025-03-29 15:32:28.883735
111	pentagonal prism 44	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:28.885818
112	cylinder 29	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:28.887999
113	pentagonal prism 45	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:29.112001
114	cube 39	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:29.114598
115	cube 40	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cube.usd	2025-03-29 15:32:29.116604
116	cylinder 30	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:29.118449
117	pentagonal prism 46	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:29.341011
118	cube 41	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.62088	cube.usd	2025-03-29 15:32:29.344953
119	pentagonal prism 47	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:29.347085
120	cylinder 31	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:29.349221
121	pentagonal prism 48	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:29.563423
122	cube 42	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:29.565657
123	pentagonal prism 49	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:29.567556
124	cylinder 32	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:29.569376
125	pentagonal prism 50	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:29.798446
126	cube 43	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:32:29.80254
127	cuboid 5	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:32:29.804518
128	cylinder 33	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:29.806683
129	pentagonal prism 51	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:30.032374
130	cube 44	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:30.03614
131	cube 45	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.746803	cube.usd	2025-03-29 15:32:30.038762
132	cylinder 34	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:30.040903
133	pentagonal prism 52	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:30.260841
134	cube 46	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 15:32:30.264955
135	pentagonal prism 53	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:30.267059
136	cylinder 35	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:30.269179
137	pentagonal prism 54	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:30.499855
138	cube 47	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:32:30.50281
139	cuboid 6	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:32:30.504791
140	cylinder 36	green	{0,0,0}	-270.6119	216.68562	938	0	0	33.690063	cylinder.usd	2025-03-29 15:32:30.507313
141	pentagonal prism 55	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:30.728757
142	cube 48	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:30.732649
143	cube 49	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:30.734816
144	cylinder 37	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:30.736787
145	pentagonal prism 56	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:30.96448
146	cube 50	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:32:30.968089
147	cube 51	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cube.usd	2025-03-29 15:32:30.969935
148	cylinder 38	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:30.972163
149	pentagonal prism 57	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:31.193022
150	cube 52	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:32:31.195664
151	cuboid 7	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:32:31.197599
152	cylinder 39	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:31.199524
153	hexagonal prism 6	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:32:31.414586
154	cube 53	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:31.41763
155	cube 54	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:31.41969
156	cylinder 40	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:31.421645
157	pentagonal prism 58	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:31.643196
158	cube 55	pink	{0,0,0}	-207.68886	346.4762	936.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:31.646586
159	cube 56	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:31.648728
160	cylinder 41	green	{0,0,0}	-272.65317	217.53194	929	0	0	33.690063	cylinder.usd	2025-03-29 15:32:31.650858
161	pentagonal prism 59	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:32:31.865827
162	cube 57	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:32:31.868728
163	cube 58	red	{0,0,0}	31.497837	259.85715	929	0	0	37.405357	cube.usd	2025-03-29 15:32:31.870665
164	cylinder 42	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:32:31.872797
165	pentagonal prism 60	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:32.094705
166	cube 59	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:32:32.098653
167	cube 60	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:32.100998
168	cylinder 43	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:32:32.103188
169	pentagonal prism 61	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:32.334792
170	cube 61	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:32.337324
171	pentagonal prism 62	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:32.339257
172	cylinder 44	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:32.341767
173	pentagonal prism 63	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:32.568592
174	cube 62	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:32.572608
175	cuboid 8	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:32.575195
176	cylinder 45	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:32.577602
177	pentagonal prism 64	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:32.794807
178	cube 63	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:32.798517
179	pentagonal prism 65	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:32.80077
180	cylinder 46	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:32.80276
181	pentagonal prism 66	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:33.017759
182	cube 64	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.62088	cube.usd	2025-03-29 15:32:33.021592
183	cube 65	red	{0,0,0}	31.497837	259.85715	920	0	0	37.746803	cube.usd	2025-03-29 15:32:33.023766
184	cylinder 47	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:33.025984
185	pentagonal prism 67	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:33.250436
186	cube 66	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:32:33.252976
187	cube 67	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.69424	cube.usd	2025-03-29 15:32:33.254878
188	cylinder 48	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:33.256927
189	hexagonal prism 7	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:32:33.480891
190	cube 68	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:32:33.48478
191	pentagonal prism 68	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:33.486808
192	cylinder 49	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:33.488823
193	pentagonal prism 69	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:33.718196
194	cube 69	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:33.720885
195	pentagonal prism 70	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:32:33.72309
196	cylinder 50	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:32:33.725475
197	pentagonal prism 71	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:32:33.947739
198	cube 70	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:32:33.950589
199	cube 71	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:33.95251
200	cylinder 51	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:33.95432
201	pentagonal prism 72	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:34.165144
202	cube 72	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:34.168613
203	cube 73	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:34.170634
204	cylinder 52	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:34.172601
205	pentagonal prism 73	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:34.398282
206	cube 74	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.34933	cube.usd	2025-03-29 15:32:34.400885
207	hexagonal prism 8	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:32:34.402854
208	cylinder 53	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:34.404729
209	pentagonal prism 74	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:34.629585
210	cube 75	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:34.632458
211	pentagonal prism 75	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:34.634619
212	cylinder 54	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:32:34.636707
213	pentagonal prism 76	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:34.848675
214	cube 76	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:32:34.851838
215	cuboid 9	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:32:34.853955
216	cylinder 55	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:34.856
217	pentagonal prism 77	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:35.081295
218	cube 77	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.743565	cube.usd	2025-03-29 15:32:35.083764
219	pentagonal prism 78	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.647625	pentagonal prism.usd	2025-03-29 15:32:35.086035
220	cylinder 56	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:35.087968
221	pentagonal prism 79	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:35.317844
222	cube 78	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:32:35.320655
223	cube 79	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:32:35.322788
224	cylinder 57	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:35.324635
225	pentagonal prism 80	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:35.540299
226	cube 80	pink	{0,0,0}	-208.67317	346.4762	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:35.544369
227	cube 81	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:32:35.546421
228	cylinder 58	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:35.548446
229	pentagonal prism 81	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:35.767546
230	cube 82	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:32:35.771607
231	cube 83	red	{0,0,0}	31.497837	259.85715	929	0	0	37.746803	cube.usd	2025-03-29 15:32:35.773691
232	cylinder 59	green	{0,0,0}	-272.65317	217.53194	915	0	0	26.56505	cylinder.usd	2025-03-29 15:32:35.775656
233	pentagonal prism 82	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:35.998711
234	cube 84	pink	{0,0,0}	-208.67317	346.4762	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:36.001257
235	cuboid 10	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:36.003496
236	cylinder 60	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:36.00541
237	pentagonal prism 83	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:36.225979
238	cube 85	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:36.23051
239	cube 86	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:36.232613
240	cylinder 61	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:32:36.234649
241	pentagonal prism 84	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:36.446069
242	cube 87	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.743565	cube.usd	2025-03-29 15:32:36.448611
243	cuboid 11	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:32:36.450667
244	cylinder 62	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:36.452633
245	pentagonal prism 85	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:36.668822
246	cube 88	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:36.671944
247	cuboid 12	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:32:36.67395
248	cylinder 63	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:36.675967
249	pentagonal prism 86	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:36.900033
250	cube 89	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:32:36.904015
251	cube 90	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:36.906037
252	cylinder 64	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:36.908461
253	pentagonal prism 87	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:37.133047
254	cube 91	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.743565	cube.usd	2025-03-29 15:32:37.137193
255	cuboid 13	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:37.139083
256	cylinder 65	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:37.141004
257	pentagonal prism 88	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:37.368111
258	cube 92	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:32:37.370995
259	cuboid 14	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:37.373348
260	cylinder 66	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:37.375783
261	pentagonal prism 89	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:37.596466
262	cube 93	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:37.598783
263	pentagonal prism 90	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:37.600759
264	cylinder 67	green	{0,0,0}	-272.65317	217.53194	919	0	0	38.65981	cylinder.usd	2025-03-29 15:32:37.602559
265	pentagonal prism 91	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:37.824959
266	cube 94	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:37.827524
267	cuboid 15	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:37.829462
268	cylinder 68	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:37.831274
269	pentagonal prism 92	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:38.064132
270	cube 95	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:38.066519
271	hexagonal prism 9	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:32:38.068621
272	cylinder 69	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:32:38.070693
273	pentagonal prism 93	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:38.28764
274	cube 96	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:32:38.290633
275	pentagonal prism 94	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:38.292905
276	cylinder 70	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:32:38.295596
277	pentagonal prism 95	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:38.51887
278	cube 97	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:38.522767
279	cuboid 16	red	{0,0,0}	31.497837	259.85715	924	0	0	37.647617	cuboid.usd	2025-03-29 15:32:38.524778
280	cylinder 71	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:38.526721
281	pentagonal prism 96	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:38.758114
282	cube 98	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:38.760444
283	cuboid 17	red	{0,0,0}	31.497837	259.85715	915	0	0	37.568592	cuboid.usd	2025-03-29 15:32:38.762621
284	cylinder 72	green	{0,0,0}	-272.65317	217.53194	917.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:32:38.764642
285	pentagonal prism 97	black	{0,0,0}	-127.95996	520.6986	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:38.979309
286	cube 99	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.420776	cube.usd	2025-03-29 15:32:38.981853
287	cube 100	red	{0,0,0}	32.482143	259.85715	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:38.98384
288	cylinder 73	green	{0,0,0}	-271.66885	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:32:38.985681
289	pentagonal prism 98	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:39.211891
290	cube 101	pink	{0,0,0}	-208.67317	346.4762	912.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:39.215718
291	cube 102	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.69424	cube.usd	2025-03-29 15:32:39.217971
292	cylinder 74	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	20.556046	cylinder.usd	2025-03-29 15:32:39.219914
293	pentagonal prism 99	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:39.437125
294	cube 103	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 15:32:39.440212
295	cube 104	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	cube.usd	2025-03-29 15:32:39.442368
296	cylinder 75	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:39.444469
297	pentagonal prism 100	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:39.659397
298	cube 105	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:39.661787
299	cuboid 18	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:32:39.66386
300	cylinder 76	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:39.665699
301	pentagonal prism 101	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:39.88184
302	cube 106	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 15:32:39.885468
303	pentagonal prism 102	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:39.887444
304	cylinder 77	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:39.889578
305	pentagonal prism 103	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:40.103419
306	cube 107	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:40.106237
307	pentagonal prism 104	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:40.108452
308	cylinder 78	green	{0,0,0}	-272.65317	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:40.110439
309	pentagonal prism 105	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:40.340142
310	cube 108	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 15:32:40.343966
311	cube 109	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:40.345814
312	cylinder 79	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:40.347837
313	pentagonal prism 106	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:40.572297
314	cube 110	pink	{0,0,0}	-206.70456	346.4762	926.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:40.576115
315	hexagonal prism 10	red	{0,0,0}	32.482143	259.85715	915	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:32:40.578094
316	cylinder 80	green	{0,0,0}	-271.66885	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:32:40.580143
317	pentagonal prism 107	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:40.802065
318	cube 111	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:40.804478
319	cube 112	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:40.806543
320	cylinder 81	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:40.80917
321	pentagonal prism 108	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:41.026298
322	cube 113	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:41.028771
323	cuboid 19	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:41.030849
324	cylinder 82	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:32:41.032804
325	pentagonal prism 109	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:41.251047
326	cube 114	pink	{0,0,0}	-207.68886	346.4762	940.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:41.254914
327	pentagonal prism 110	red	{0,0,0}	31.497837	259.85715	920	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:32:41.256956
328	cylinder 83	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:41.259298
329	pentagonal prism 111	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:41.473721
330	cube 115	pink	{0,0,0}	-205.90038	345.12823	908.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:41.47625
331	pentagonal prism 112	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:32:41.478082
332	cylinder 84	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:41.479813
333	pentagonal prism 113	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:41.704884
334	cube 116	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.743565	cube.usd	2025-03-29 15:32:41.708862
335	pentagonal prism 114	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:41.712169
336	cylinder 85	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:32:41.714466
337	pentagonal prism 115	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:41.937999
338	cube 117	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:41.940843
339	pentagonal prism 116	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:32:41.942843
340	cylinder 86	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:41.944838
341	pentagonal prism 117	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:42.168006
342	cube 118	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:32:42.171692
343	pentagonal prism 118	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:32:42.173594
344	cylinder 87	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:42.176021
345	pentagonal prism 119	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:42.414284
346	cube 119	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:32:42.418122
347	pentagonal prism 120	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:42.420162
348	cylinder 88	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:42.422162
349	pentagonal prism 121	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:42.639768
350	cube 120	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:42.643867
351	cube 121	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.746803	cube.usd	2025-03-29 15:32:42.645898
352	cylinder 89	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:42.648306
353	pentagonal prism 122	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:42.873613
354	cube 122	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:32:42.877828
355	pentagonal prism 123	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:42.87988
356	cylinder 90	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:42.882161
357	pentagonal prism 124	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:43.102631
358	cube 123	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:32:43.106186
359	cuboid 20	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	cuboid.usd	2025-03-29 15:32:43.10815
360	cylinder 91	green	{0,0,0}	-272.65317	217.53194	924	0	0	33.690063	cylinder.usd	2025-03-29 15:32:43.11045
361	pentagonal prism 125	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 15:32:43.326439
362	cube 124	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.03624	cube.usd	2025-03-29 15:32:43.329346
363	cube 125	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:43.331409
364	cylinder 92	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:32:43.333418
365	pentagonal prism 126	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:43.556585
366	cube 126	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:32:43.560429
367	cuboid 21	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:43.562589
368	cylinder 93	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:32:43.56469
369	pentagonal prism 127	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:43.79826
370	cube 127	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:32:43.802018
371	cube 128	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cube.usd	2025-03-29 15:32:43.80396
372	cylinder 94	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:32:43.805964
373	hexagonal prism 11	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:32:44.025974
374	cube 129	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:44.028357
375	cuboid 22	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:32:44.0302
376	cylinder 95	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:32:44.03206
377	pentagonal prism 128	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:44.262723
378	cube 130	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:44.266521
379	cube 131	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.303947	cube.usd	2025-03-29 15:32:44.268355
380	cylinder 96	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:32:44.270309
381	pentagonal prism 129	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:44.499958
382	cube 132	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:44.503253
383	pentagonal prism 130	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:44.505043
384	cylinder 97	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:44.507056
385	pentagonal prism 131	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:44.727287
386	cube 133	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:44.730386
387	cube 134	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	cube.usd	2025-03-29 15:32:44.732412
388	cylinder 98	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:44.734518
389	pentagonal prism 132	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:44.95808
390	cube 135	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:44.961788
391	pentagonal prism 133	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:44.963768
392	cylinder 99	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:44.965859
393	pentagonal prism 134	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:32:45.184254
394	cube 136	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:45.186797
395	cube 137	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:45.188788
396	cylinder 100	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:45.190679
397	hexagonal prism 12	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:32:45.409203
398	cube 138	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:45.411743
399	cuboid 23	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:32:45.413647
400	cylinder 101	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:32:45.415364
401	pentagonal prism 135	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:45.640965
402	cube 139	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:45.644892
403	cube 140	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	cube.usd	2025-03-29 15:32:45.646919
404	cylinder 102	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:45.648868
405	pentagonal prism 136	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:45.887415
406	cube 141	pink	{0,0,0}	-205.90038	345.12823	907.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:45.891148
407	cuboid 24	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:45.893293
408	cylinder 103	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:45.895813
409	pentagonal prism 137	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:46.118947
410	cube 142	pink	{0,0,0}	-205.90038	345.12823	937.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:46.122477
411	pentagonal prism 138	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:46.124373
412	cylinder 104	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:46.126267
413	pentagonal prism 139	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:46.349309
414	cube 143	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:32:46.353205
415	cube 144	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	cube.usd	2025-03-29 15:32:46.355086
416	cylinder 105	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:46.357106
417	pentagonal prism 140	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:32:46.57279
418	cube 145	pink	{0,0,0}	-208.67317	346.4762	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:46.576717
419	cube 146	red	{0,0,0}	31.497837	259.85715	924	0	0	37.746803	cube.usd	2025-03-29 15:32:46.579073
420	cylinder 106	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:32:46.581158
421	pentagonal prism 141	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:46.806939
422	cube 147	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:46.809512
423	cube 148	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	cube.usd	2025-03-29 15:32:46.811494
424	cylinder 107	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:46.813698
425	pentagonal prism 142	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:47.036192
426	cube 149	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:32:47.039827
427	pentagonal prism 143	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:47.041716
428	cylinder 108	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:47.04365
429	hexagonal prism 13	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:32:47.27236
430	cube 150	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.03624	cube.usd	2025-03-29 15:32:47.275934
431	cube 151	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:32:47.278045
432	cylinder 109	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:47.280312
433	pentagonal prism 144	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:47.494999
434	cube 152	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:32:47.498195
435	pentagonal prism 145	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:47.500295
436	cylinder 110	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:32:47.50239
437	pentagonal prism 146	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:47.725872
438	cube 153	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:47.72997
439	cube 154	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	cube.usd	2025-03-29 15:32:47.731979
440	cylinder 111	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 15:32:47.733997
441	pentagonal prism 147	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:47.967455
442	cube 155	pink	{0,0,0}	-205.90038	345.12823	936.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:47.971235
443	cuboid 25	red	{0,0,0}	32.355774	258.8462	919	0	0	37.746803	cuboid.usd	2025-03-29 15:32:47.973111
444	cylinder 112	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:32:47.975121
445	pentagonal prism 148	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:48.220191
446	cube 156	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:48.222475
447	cuboid 26	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:32:48.224299
448	cylinder 113	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:48.226134
449	pentagonal prism 149	black	{0,0,0}	-127.95996	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:48.442209
450	cube 157	pink	{0,0,0}	-206.70456	346.4762	931.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:48.446108
451	pentagonal prism 150	red	{0,0,0}	32.482143	259.85715	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:48.448419
452	cylinder 114	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:48.450407
453	pentagonal prism 151	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:48.679688
454	cube 158	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.743565	cube.usd	2025-03-29 15:32:48.683267
455	cube 159	red	{0,0,0}	31.499039	259.86707	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:48.685215
456	cylinder 115	green	{0,0,0}	-272.66354	217.54024	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:48.687419
457	hexagonal prism 14	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:32:48.920194
458	cube 160	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.743565	cube.usd	2025-03-29 15:32:48.924103
459	cuboid 27	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:48.925931
460	cylinder 116	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:32:48.92796
461	pentagonal prism 152	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:49.144453
462	cube 161	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:32:49.14816
463	cuboid 28	red	{0,0,0}	31.497837	259.85715	915	0	0	37.568592	cuboid.usd	2025-03-29 15:32:49.150168
464	cylinder 117	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:49.152195
465	pentagonal prism 153	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:49.374335
466	cube 162	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:32:49.37792
467	hexagonal prism 15	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:32:49.37989
468	cylinder 118	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:49.382412
469	pentagonal prism 154	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:49.602351
470	cube 163	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:32:49.604702
471	pentagonal prism 155	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:49.606553
472	cylinder 119	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:49.608573
473	pentagonal prism 156	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:49.828699
474	cube 164	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:49.832463
475	cuboid 29	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:49.834475
476	cylinder 120	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:49.83652
477	pentagonal prism 157	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:50.059945
478	cube 165	pink	{0,0,0}	-208.67317	346.4762	915	0	0	59.03625	cube.usd	2025-03-29 15:32:50.063809
479	cuboid 30	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:50.066237
480	cylinder 121	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:32:50.068407
481	pentagonal prism 158	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:50.282789
482	cube 166	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:50.285833
483	pentagonal prism 159	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:32:50.288014
484	cylinder 122	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:32:50.290137
485	pentagonal prism 160	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:50.512525
486	cube 167	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:32:50.516251
487	cube 168	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:32:50.51834
488	cylinder 123	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:50.520514
489	pentagonal prism 161	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:50.742887
490	cube 169	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:50.746697
491	pentagonal prism 162	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:50.749105
492	cylinder 124	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:50.751337
493	pentagonal prism 163	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:50.981663
494	cube 170	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:50.984225
495	pentagonal prism 164	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:50.986365
496	cylinder 125	green	{0,0,0}	-272.65317	217.53194	929	0	0	18.434948	cylinder.usd	2025-03-29 15:32:50.988463
497	pentagonal prism 165	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:51.212664
498	cube 171	pink	{0,0,0}	-208.67317	346.4762	913.00006	0	0	59.34933	cube.usd	2025-03-29 15:32:51.216856
499	pentagonal prism 166	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:51.219212
500	cylinder 126	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:51.22144
501	pentagonal prism 167	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:51.451255
502	cube 172	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:32:51.455064
503	cuboid 31	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:32:51.456949
504	cylinder 127	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:51.458913
505	pentagonal prism 168	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:51.679614
506	cube 173	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:32:51.68354
507	hexagonal prism 16	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:32:51.685611
508	cylinder 128	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:51.68858
509	pentagonal prism 169	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:51.913566
510	cube 174	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03624	cube.usd	2025-03-29 15:32:51.918201
511	cube 175	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.874985	cube.usd	2025-03-29 15:32:51.921055
512	cylinder 129	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:51.923229
513	pentagonal prism 170	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:32:52.153949
514	cube 176	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:52.157761
515	cube 177	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.874985	cube.usd	2025-03-29 15:32:52.159703
516	cylinder 130	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:52.161955
517	pentagonal prism 171	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:52.376562
518	cube 178	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:32:52.379355
519	cube 179	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:32:52.381405
520	cylinder 131	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:52.384289
521	pentagonal prism 172	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:52.611379
522	cube 180	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:32:52.61367
523	cube 181	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:52.615677
524	cylinder 132	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:52.618204
525	pentagonal prism 173	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:32:52.842271
526	cube 182	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:32:52.844983
527	pentagonal prism 174	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:52.846891
528	cylinder 133	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:52.848864
529	pentagonal prism 175	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:53.062272
530	cube 183	pink	{0,0,0}	-205.90038	345.12823	907.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:53.06487
531	cube 184	red	{0,0,0}	32.355774	258.8462	920	0	0	37.746803	cube.usd	2025-03-29 15:32:53.066929
532	cylinder 134	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:32:53.069095
533	pentagonal prism 176	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:53.29421
534	cube 185	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:53.29809
535	pentagonal prism 177	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:53.300062
536	cylinder 135	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:53.302262
537	pentagonal prism 178	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:53.525021
538	cube 186	pink	{0,0,0}	-205.90038	345.12823	939.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:53.529189
539	cube 187	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:32:53.531565
540	cylinder 136	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:53.533517
541	pentagonal prism 179	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:53.761284
542	cube 188	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:53.76445
543	hexagonal prism 17	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:32:53.766349
544	cylinder 137	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:53.768907
545	pentagonal prism 180	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:53.996557
546	cube 189	pink	{0,0,0}	-208.67317	346.4762	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:53.998816
547	cube 190	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:54.000826
548	cylinder 138	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:54.003848
549	pentagonal prism 181	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:54.216431
550	cube 191	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:54.219264
551	pentagonal prism 182	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:32:54.221413
552	cylinder 139	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:54.223539
553	pentagonal prism 183	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:54.45671
554	cube 192	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:54.460537
555	pentagonal prism 184	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:54.462658
556	cylinder 140	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:54.465029
557	pentagonal prism 185	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:54.676321
558	cube 193	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:54.678631
559	pentagonal prism 186	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:54.680559
560	cylinder 141	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:32:54.682417
561	pentagonal prism 187	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:54.911222
562	cube 194	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:54.915171
563	cube 195	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:54.917425
564	cylinder 142	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:54.919575
565	pentagonal prism 188	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:55.131141
566	cube 196	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.420776	cube.usd	2025-03-29 15:32:55.133577
567	cube 197	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:55.135879
568	cylinder 143	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:32:55.138123
569	pentagonal prism 189	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:55.358272
570	cube 198	pink	{0,0,0}	-208.67317	346.4762	915	0	0	59.420776	cube.usd	2025-03-29 15:32:55.36085
571	pentagonal prism 190	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:32:55.362657
572	cylinder 144	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:32:55.364716
573	pentagonal prism 191	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:55.588994
574	cube 199	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:55.592828
575	pentagonal prism 192	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:55.594785
576	cylinder 145	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:32:55.597206
577	pentagonal prism 193	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:55.815229
578	cube 200	pink	{0,0,0}	-206.88084	345.12823	913.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:55.81926
579	pentagonal prism 194	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:55.821591
580	cylinder 146	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:55.823866
581	pentagonal prism 195	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:32:56.054993
582	cube 201	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:56.058839
583	hexagonal prism 18	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:32:56.060803
584	cylinder 147	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:56.062755
585	pentagonal prism 196	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:56.292626
586	cube 202	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:32:56.296295
587	cube 203	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.874985	cube.usd	2025-03-29 15:32:56.298212
588	cylinder 148	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:32:56.300084
589	pentagonal prism 197	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:56.517638
590	cube 204	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.420776	cube.usd	2025-03-29 15:32:56.520754
591	pentagonal prism 198	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:32:56.52282
592	cylinder 149	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:56.52484
593	pentagonal prism 199	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:56.744118
594	cube 205	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:56.747752
595	hexagonal prism 19	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:32:56.749666
596	cylinder 150	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:56.751878
597	pentagonal prism 200	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:56.977652
598	cube 206	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:56.981373
599	cuboid 32	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:32:56.983248
600	cylinder 151	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:56.985202
601	pentagonal prism 201	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:57.207477
602	cube 207	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:57.20989
603	cuboid 33	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:57.211796
604	cylinder 152	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:57.213579
605	pentagonal prism 202	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:57.4402
606	cube 208	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:57.44367
607	cube 209	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	cube.usd	2025-03-29 15:32:57.445645
608	cylinder 153	green	{0,0,0}	-272.65317	217.53194	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:57.447759
609	pentagonal prism 203	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:57.664431
610	cube 210	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:32:57.668236
611	cuboid 34	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:32:57.670548
612	cylinder 154	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:57.672914
613	pentagonal prism 204	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:57.897957
614	cube 211	pink	{0,0,0}	-208.67317	346.4762	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:32:57.901703
615	pentagonal prism 205	red	{0,0,0}	31.497837	259.85715	924	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:32:57.903747
616	cylinder 155	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:57.906151
617	pentagonal prism 206	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:58.128894
618	cube 212	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:32:58.132726
619	cuboid 35	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:32:58.134698
620	cylinder 156	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:58.136677
621	pentagonal prism 207	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:58.354014
622	cube 213	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:32:58.358281
623	cube 214	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:58.362303
624	cylinder 157	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:32:58.3665
625	pentagonal prism 208	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:32:58.585985
626	cube 215	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:32:58.588783
627	cube 216	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:32:58.591273
628	cylinder 158	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:58.593655
629	hexagonal prism 20	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:32:58.828673
630	cube 217	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:32:58.832411
631	cuboid 36	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:58.834308
632	cylinder 159	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:58.83623
633	pentagonal prism 209	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:59.057908
634	cube 218	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:32:59.061754
635	cylinder 161	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cylinder.usd	2025-03-29 15:32:59.063679
636	cylinder 162	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:32:59.065615
637	pentagonal prism 210	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:32:59.286395
638	cube 219	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.62088	cube.usd	2025-03-29 15:32:59.290539
639	cuboid 37	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:32:59.292748
640	cylinder 163	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:32:59.294932
641	pentagonal prism 211	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:32:59.520175
642	cube 220	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:32:59.523773
643	pentagonal prism 212	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:32:59.525886
644	cylinder 164	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:32:59.528292
645	pentagonal prism 213	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:59.753476
646	cube 221	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:32:59.757095
647	cube 222	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:32:59.759114
648	cylinder 165	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:32:59.761191
649	pentagonal prism 214	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:32:59.986658
650	cube 223	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:32:59.990605
651	cube 224	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	cube.usd	2025-03-29 15:32:59.992714
652	cylinder 166	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:32:59.99475
653	pentagonal prism 215	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:00.222661
654	cube 225	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:00.225752
655	cuboid 38	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:00.227995
656	cylinder 167	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:33:00.229932
657	pentagonal prism 216	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:00.466417
658	cube 226	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.34933	cube.usd	2025-03-29 15:33:00.468565
659	cuboid 39	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	cuboid.usd	2025-03-29 15:33:00.470377
660	cylinder 168	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:00.473053
661	pentagonal prism 217	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:00.699352
662	cube 227	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:00.70299
663	hexagonal prism 21	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:33:00.704948
664	cylinder 169	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:00.706906
665	pentagonal prism 218	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:00.926745
666	cube 228	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:33:00.930807
667	pentagonal prism 219	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:00.93264
668	cylinder 170	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:33:00.935778
669	pentagonal prism 220	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:01.152081
670	cube 229	pink	{0,0,0}	-208.67317	346.4762	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:01.154913
671	cube 230	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:33:01.156916
672	cylinder 171	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:01.159121
673	pentagonal prism 221	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:01.384826
674	cube 231	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.620872	cube.usd	2025-03-29 15:33:01.388535
675	cuboid 40	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:01.39092
676	cylinder 172	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:01.393219
677	pentagonal prism 222	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:01.617547
678	cube 232	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:01.620863
679	pentagonal prism 223	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:33:01.622751
680	cylinder 173	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:01.625664
681	pentagonal prism 224	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:01.839263
682	cube 233	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:33:01.842668
683	hexagonal prism 22	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:33:01.844672
684	cylinder 174	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:01.846849
685	pentagonal prism 225	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:02.077572
686	cube 234	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:02.081366
687	hexagonal prism 23	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:33:02.083437
688	cylinder 175	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:33:02.085611
689	pentagonal prism 226	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:02.31374
690	cube 235	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:02.31609
691	pentagonal prism 227	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:02.318054
692	cylinder 176	green	{0,0,0}	-270.6119	216.68562	938	0	0	26.56505	cylinder.usd	2025-03-29 15:33:02.319946
693	pentagonal prism 228	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:02.538533
694	cube 236	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:33:02.541402
695	cuboid 41	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:33:02.543727
696	cylinder 177	green	{0,0,0}	-270.6119	216.68562	929	0	0	36.869896	cylinder.usd	2025-03-29 15:33:02.545892
697	pentagonal prism 229	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:33:02.759974
698	cube 237	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:33:02.763783
699	pentagonal prism 230	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:02.765697
700	cylinder 178	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:33:02.767903
701	pentagonal prism 231	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:02.990826
702	cube 238	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:02.994554
703	cube 239	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:02.996816
704	cylinder 179	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:02.998893
705	pentagonal prism 232	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:03.218942
706	cube 240	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:03.221183
707	pentagonal prism 233	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:33:03.223152
708	cylinder 180	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:03.225386
709	pentagonal prism 234	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:03.445146
710	cube 241	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.620872	cube.usd	2025-03-29 15:33:03.448773
711	cuboid 42	red	{0,0,0}	31.497837	259.85715	924	0	0	37.874985	cuboid.usd	2025-03-29 15:33:03.450748
712	cylinder 181	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:03.452611
713	pentagonal prism 235	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:03.677599
714	cube 242	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:03.681305
715	pentagonal prism 236	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:03.683164
716	cylinder 182	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:33:03.685119
717	pentagonal prism 237	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:03.911589
718	cube 243	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:33:03.915456
719	cube 244	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:03.917341
720	cylinder 183	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:03.91936
721	pentagonal prism 238	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:04.140509
722	cube 245	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:33:04.143278
723	cylinder 184	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cylinder.usd	2025-03-29 15:33:04.14539
724	cylinder 185	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:04.147311
725	pentagonal prism 239	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:04.37759
726	cube 246	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:04.381523
727	pentagonal prism 240	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:04.3834
728	cylinder 186	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:04.385414
729	pentagonal prism 241	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:04.61196
730	cube 247	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:33:04.614535
731	cuboid 43	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:33:04.616341
732	cylinder 187	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:33:04.618155
733	pentagonal prism 242	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:04.839559
734	cube 248	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.420776	cube.usd	2025-03-29 15:33:04.84411
735	cube 249	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	cube.usd	2025-03-29 15:33:04.846417
736	cylinder 188	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:04.84848
737	pentagonal prism 243	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:05.077129
738	cube 250	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:33:05.081032
739	pentagonal prism 244	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:05.08297
740	cylinder 189	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:05.084911
741	pentagonal prism 245	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:33:05.312988
742	cube 251	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:33:05.315465
743	cuboid 44	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cuboid.usd	2025-03-29 15:33:05.317414
744	cylinder 190	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:05.319319
745	pentagonal prism 246	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:05.550554
746	cube 252	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:05.554643
747	pentagonal prism 247	red	{0,0,0}	31.497837	259.85715	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:33:05.556906
748	cylinder 191	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:05.558945
749	hexagonal prism 24	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:33:05.77794
750	cube 253	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:05.781714
751	hexagonal prism 25	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:33:05.783872
752	cylinder 192	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:05.785842
753	pentagonal prism 248	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:06.007824
754	cube 254	pink	{0,0,0}	-208.67317	346.4762	933	0	0	59.03624	cube.usd	2025-03-29 15:33:06.01062
755	pentagonal prism 249	red	{0,0,0}	31.497837	259.85715	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:06.013039
756	cylinder 193	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:06.015083
757	pentagonal prism 250	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:06.246936
758	cube 255	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:06.250706
759	pentagonal prism 251	red	{0,0,0}	32.355774	258.8462	929	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:33:06.252558
760	cylinder 194	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:33:06.254598
761	pentagonal prism 252	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:06.480938
762	cube 256	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:33:06.484543
763	cuboid 45	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:06.486614
764	cylinder 195	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:06.488722
765	pentagonal prism 253	black	{0,0,0}	-127.45538	519.6258	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:06.712151
766	cube 257	pink	{0,0,0}	-206.86989	346.0904	913.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:06.715667
767	cube 258	red	{0,0,0}	32.354057	259.8129	921.00006	0	0	37.746803	cube.usd	2025-03-29 15:33:06.717585
768	cylinder 196	green	{0,0,0}	-270.59756	217.65457	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:06.71955
769	pentagonal prism 254	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:06.946391
770	cube 259	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:06.950346
771	cuboid 46	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:33:06.952397
772	cylinder 197	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:06.954423
773	pentagonal prism 255	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:07.178487
774	cube 260	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:07.182522
775	cube 261	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:07.184855
776	cylinder 198	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:07.18681
777	pentagonal prism 256	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:07.426871
778	cube 262	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.03624	cube.usd	2025-03-29 15:33:07.430931
779	cube 263	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.69424	cube.usd	2025-03-29 15:33:07.433286
780	cylinder 199	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:07.435368
781	pentagonal prism 257	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:07.661245
782	cube 264	pink	{0,0,0}	-206.88084	345.12823	932.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:07.665353
783	pentagonal prism 258	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:07.66767
784	cylinder 200	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:07.669573
785	pentagonal prism 259	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:07.890309
786	cube 265	pink	{0,0,0}	-208.67317	346.4762	915	0	0	59.34933	cube.usd	2025-03-29 15:33:07.894005
787	cuboid 47	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:07.89639
788	cylinder 201	green	{0,0,0}	-272.65317	217.53194	934	0	0	18.434948	cylinder.usd	2025-03-29 15:33:07.898683
789	pentagonal prism 260	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:08.110767
790	cube 266	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:33:08.113378
791	cube 267	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:33:08.115594
792	cylinder 202	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:08.11778
793	pentagonal prism 261	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:08.332689
794	cube 268	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:08.335442
795	cuboid 48	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:08.337368
796	cylinder 203	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:33:08.339247
797	pentagonal prism 262	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:08.594667
798	cube 269	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 15:33:08.598618
799	pentagonal prism 263	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:33:08.60339
800	cylinder 204	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:08.605844
801	pentagonal prism 264	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:08.822066
802	cube 270	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.03624	cube.usd	2025-03-29 15:33:08.825834
803	pentagonal prism 265	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:08.828033
804	cylinder 205	green	{0,0,0}	-270.6119	216.68562	933	0	0	38.65981	cylinder.usd	2025-03-29 15:33:08.83038
805	pentagonal prism 266	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:09.055728
806	cube 271	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:09.06089
807	hexagonal prism 26	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.234837	hexagonal prism.usd	2025-03-29 15:33:09.063622
808	cylinder 206	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:09.066001
809	pentagonal prism 267	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:09.285341
810	cube 272	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:09.287931
811	cube 273	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:33:09.289882
812	cylinder 207	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:09.291634
813	pentagonal prism 268	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:09.502627
814	cube 274	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:09.505331
815	cuboid 49	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:33:09.507232
816	cylinder 208	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:33:09.509108
817	pentagonal prism 269	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:09.748406
818	cube 275	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.34933	cube.usd	2025-03-29 15:33:09.75135
819	cube 276	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:09.753282
820	cylinder 209	green	{0,0,0}	-272.65317	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:09.755124
821	pentagonal prism 270	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:09.992677
822	cube 277	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 15:33:09.994834
823	pentagonal prism 271	red	{0,0,0}	32.355774	258.8462	933	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:09.996705
824	cylinder 210	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:09.999231
825	pentagonal prism 272	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:10.215894
826	cube 278	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:33:10.218654
827	cuboid 50	red	{0,0,0}	32.355774	258.8462	929	0	0	37.23483	cuboid.usd	2025-03-29 15:33:10.220486
828	cylinder 211	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:10.222331
829	pentagonal prism 273	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:10.448055
830	cube 279	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:10.452252
831	cuboid 51	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:33:10.454426
832	cylinder 212	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:33:10.456779
833	pentagonal prism 274	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:10.670758
834	cube 280	pink	{0,0,0}	-207.68886	346.4762	933	0	0	59.420776	cube.usd	2025-03-29 15:33:10.673327
835	pentagonal prism 275	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:10.675176
836	cylinder 213	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:10.67696
837	pentagonal prism 276	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:10.902021
838	cube 281	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:10.906062
839	cuboid 52	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:10.908189
840	cylinder 214	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:10.9101
841	pentagonal prism 277	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:11.141108
842	cube 282	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:11.144928
843	pentagonal prism 278	red	{0,0,0}	32.355774	258.8462	924	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:33:11.147038
844	cylinder 215	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:33:11.149573
845	pentagonal prism 279	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:11.36346
846	cube 283	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.743565	cube.usd	2025-03-29 15:33:11.366004
847	cube 284	red	{0,0,0}	31.497837	259.85715	939.00006	0	0	37.69424	cube.usd	2025-03-29 15:33:11.368228
848	cylinder 216	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:11.370409
849	pentagonal prism 280	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:11.607518
850	cube 285	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:11.610934
851	cuboid 53	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:11.612818
852	cylinder 217	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:33:11.614894
853	pentagonal prism 281	black	{0,0,0}	-127.95996	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:33:11.83573
854	cube 286	pink	{0,0,0}	-206.70456	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:11.838122
855	cuboid 54	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:33:11.840014
856	cylinder 218	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:11.841924
857	pentagonal prism 282	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:12.064776
858	cube 287	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:33:12.068713
859	cube 288	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:12.071006
860	cylinder 219	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:12.073032
861	pentagonal prism 283	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:12.292007
862	cube 289	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03624	cube.usd	2025-03-29 15:33:12.295978
863	cube 290	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	cube.usd	2025-03-29 15:33:12.297924
864	cylinder 220	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:12.299887
865	pentagonal prism 284	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:12.522652
866	cube 291	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:12.525076
867	cuboid 55	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:33:12.527109
868	cylinder 221	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:12.529055
869	hexagonal prism 27	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:33:12.746101
870	cube 292	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:33:12.748452
871	pentagonal prism 285	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:33:12.750505
872	cylinder 222	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:12.752816
873	pentagonal prism 286	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:12.976739
874	cube 293	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.34933	cube.usd	2025-03-29 15:33:12.98014
875	cuboid 56	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:33:12.982303
876	cylinder 223	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:12.984896
877	pentagonal prism 287	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:13.198796
878	cube 294	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:33:13.202369
879	hexagonal prism 28	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:33:13.204646
880	cylinder 224	green	{0,0,0}	-270.6119	216.68562	934	0	0	18.434948	cylinder.usd	2025-03-29 15:33:13.206563
881	pentagonal prism 288	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:13.426433
882	cube 295	pink	{0,0,0}	-206.88084	345.12823	909.00006	0	0	59.34933	cube.usd	2025-03-29 15:33:13.429208
883	cube 296	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:13.4311
884	cylinder 225	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:13.433202
885	pentagonal prism 289	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:13.653414
886	cube 297	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:13.657458
887	pentagonal prism 290	red	{0,0,0}	32.482143	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:13.659291
888	cylinder 226	green	{0,0,0}	-271.66885	217.53194	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:13.661322
889	pentagonal prism 291	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:13.898988
890	cube 298	pink	{0,0,0}	-205.90038	345.12823	942.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:13.902861
891	pentagonal prism 292	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:33:13.904966
892	cylinder 227	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:13.90705
893	hexagonal prism 29	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	hexagonal prism.usd	2025-03-29 15:33:14.14403
894	cube 299	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:14.146727
895	cuboid 57	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:14.149208
896	cylinder 228	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:14.151712
897	pentagonal prism 293	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:14.390064
898	cube 300	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.34933	cube.usd	2025-03-29 15:33:14.392419
899	hexagonal prism 30	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:33:14.394244
900	cylinder 229	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:33:14.395958
901	pentagonal prism 294	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:14.627246
902	cube 301	pink	{0,0,0}	-208.67317	346.4762	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:14.629346
903	pentagonal prism 295	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:33:14.631082
904	cylinder 230	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:33:14.634182
905	pentagonal prism 296	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:14.864378
906	cube 302	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:14.866905
907	pentagonal prism 297	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:14.869614
908	cylinder 231	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:33:14.87228
909	pentagonal prism 298	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:15.119502
910	cube 303	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:33:15.122531
911	cube 304	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	cube.usd	2025-03-29 15:33:15.124579
912	cylinder 232	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:33:15.126753
913	pentagonal prism 299	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:15.359624
914	cube 305	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.420776	cube.usd	2025-03-29 15:33:15.363307
915	cube 306	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:15.365392
916	cylinder 233	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:15.367335
917	pentagonal prism 300	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:15.597115
918	cube 307	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:33:15.601057
919	cuboid 58	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:33:15.603441
920	cylinder 234	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:33:15.60568
921	pentagonal prism 301	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:15.826067
922	cube 308	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:15.830478
923	cuboid 59	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:15.832493
924	cylinder 235	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:15.834447
925	pentagonal prism 302	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:33:16.054473
926	cube 309	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.420776	cube.usd	2025-03-29 15:33:16.059773
927	cuboid 60	red	{0,0,0}	31.497837	259.85715	929	0	0	37.405357	cuboid.usd	2025-03-29 15:33:16.062104
928	cylinder 236	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:16.064377
929	pentagonal prism 303	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:33:16.281816
930	cube 310	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:16.285398
931	pentagonal prism 304	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:16.287853
932	cylinder 237	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:16.290001
933	pentagonal prism 305	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:16.522412
934	cube 311	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.743565	cube.usd	2025-03-29 15:33:16.525933
935	pentagonal prism 306	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:16.527949
936	cylinder 238	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:16.529937
937	pentagonal prism 307	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:16.770569
938	cube 312	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:33:16.773115
939	cube 313	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:33:16.775206
940	cylinder 239	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 15:33:16.777507
941	pentagonal prism 308	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:17.005116
942	cube 314	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.62088	cube.usd	2025-03-29 15:33:17.008631
943	cuboid 61	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:33:17.010534
944	cylinder 240	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:17.012416
945	pentagonal prism 309	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:17.23414
946	cube 315	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:17.23914
947	cube 316	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:17.241661
948	cylinder 241	green	{0,0,0}	-270.6119	216.68562	915	0	0	26.56505	cylinder.usd	2025-03-29 15:33:17.243742
949	pentagonal prism 310	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:17.488826
950	cube 317	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:33:17.491809
951	hexagonal prism 31	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:33:17.493877
952	cylinder 242	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:17.495924
953	pentagonal prism 311	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:17.722322
954	cube 318	pink	{0,0,0}	-208.67317	346.4762	928.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:17.726097
955	pentagonal prism 312	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:17.728035
956	cylinder 243	green	{0,0,0}	-272.65317	217.53194	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:17.729989
957	pentagonal prism 313	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:17.951891
958	cube 319	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.743565	cube.usd	2025-03-29 15:33:17.956004
959	cuboid 62	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:33:17.958412
960	cylinder 244	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:33:17.960427
961	pentagonal prism 314	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:18.192253
962	cube 320	pink	{0,0,0}	-208.50322	347.83475	920	0	0	59.03625	cube.usd	2025-03-29 15:33:18.195707
963	pentagonal prism 315	red	{0,0,0}	31.621342	260.87607	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:18.198498
964	cylinder 245	green	{0,0,0}	-273.72223	218.38489	919	0	0	26.56505	cylinder.usd	2025-03-29 15:33:18.201341
965	pentagonal prism 316	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:18.422478
966	cube 321	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.743565	cube.usd	2025-03-29 15:33:18.42496
967	pentagonal prism 317	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:33:18.426862
968	cylinder 246	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:18.428692
969	pentagonal prism 318	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:18.652928
970	cube 322	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:18.656845
971	pentagonal prism 319	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:18.65908
972	cylinder 247	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:18.661031
973	pentagonal prism 320	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:18.892285
974	cube 323	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.743565	cube.usd	2025-03-29 15:33:18.896119
975	cuboid 63	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:33:18.898081
976	cylinder 248	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:18.900063
977	pentagonal prism 321	black	{0,0,0}	-129.44986	522.7403	660	0	0	90	pentagonal prism.usd	2025-03-29 15:33:19.136326
978	cube 324	pink	{0,0,0}	-208.50322	347.83475	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:19.140341
979	cuboid 64	red	{0,0,0}	31.621342	260.87607	915	0	0	37.568592	cuboid.usd	2025-03-29 15:33:19.14253
980	cylinder 249	green	{0,0,0}	-273.72223	218.38489	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:19.144995
981	pentagonal prism 322	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:19.364845
982	cube 325	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:33:19.367207
983	cuboid 65	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:19.369448
984	cylinder 250	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:19.371334
985	pentagonal prism 323	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:19.601509
986	cube 326	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:19.603786
987	pentagonal prism 324	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:33:19.605772
988	cylinder 251	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:19.607967
989	pentagonal prism 325	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:19.851189
990	cube 327	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:19.855026
991	cube 328	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:19.857632
992	cylinder 252	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:19.860041
993	pentagonal prism 326	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:20.09131
994	cube 329	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:20.095222
995	cube 330	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:20.097327
996	cylinder 253	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:20.099291
997	pentagonal prism 327	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:20.321347
998	cube 331	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:33:20.324188
999	cube 332	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.874985	cube.usd	2025-03-29 15:33:20.326636
1000	cylinder 254	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:20.32888
1001	pentagonal prism 328	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:33:20.551613
1002	cube 333	pink	{0,0,0}	-206.88084	345.12823	934	0	0	59.03625	cube.usd	2025-03-29 15:33:20.555561
1003	cube 334	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.69424	cube.usd	2025-03-29 15:33:20.557861
1004	cylinder 255	green	{0,0,0}	-270.6119	216.68562	934	0	0	33.690063	cylinder.usd	2025-03-29 15:33:20.560096
1005	pentagonal prism 329	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:20.780597
1006	cube 335	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.743565	cube.usd	2025-03-29 15:33:20.784253
1007	cube 336	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	cube.usd	2025-03-29 15:33:20.786185
1008	cylinder 256	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:20.788117
1009	pentagonal prism 330	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:21.036787
1010	cube 337	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:21.041161
1011	cuboid 66	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:21.043581
1012	cylinder 257	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:21.045651
1013	pentagonal prism 331	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 15:33:21.2787
1014	cube 338	pink	{0,0,0}	-206.88867	345.1413	924	0	0	59.62088	cube.usd	2025-03-29 15:33:21.282434
1015	cube 339	red	{0,0,0}	32.357	258.856	929	0	0	37.568592	cube.usd	2025-03-29 15:33:21.28428
1016	cylinder 258	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:21.286163
1017	pentagonal prism 332	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:21.508186
1018	cube 340	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:21.510716
1019	cuboid 67	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:33:21.512777
1020	cylinder 259	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:21.514719
1021	pentagonal prism 333	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:21.747725
1022	cube 341	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.420776	cube.usd	2025-03-29 15:33:21.75143
1023	cube 342	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.874985	cube.usd	2025-03-29 15:33:21.753249
1024	cylinder 260	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:21.755236
1025	pentagonal prism 334	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:21.977826
1026	cube 343	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:33:21.981854
1027	pentagonal prism 335	red	{0,0,0}	31.497837	259.85715	912.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:21.983864
1028	cylinder 261	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:33:21.985883
1029	pentagonal prism 336	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:22.224725
1030	cube 344	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:33:22.227116
1031	pentagonal prism 337	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:22.229141
1032	cylinder 262	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:33:22.23106
1033	pentagonal prism 338	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:22.467059
1034	cube 345	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:33:22.470724
1035	pentagonal prism 339	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:33:22.472647
1036	cylinder 263	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:22.474903
1037	pentagonal prism 340	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:22.694002
1038	cube 346	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:33:22.697234
1039	cube 347	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:22.699191
1040	cylinder 264	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:22.701127
1041	pentagonal prism 341	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:22.926223
1042	cube 348	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:22.930216
1043	cube 349	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.874985	cube.usd	2025-03-29 15:33:22.932129
1044	cylinder 265	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:22.934167
1045	pentagonal prism 342	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:23.161089
1046	cube 350	pink	{0,0,0}	-206.70456	346.4762	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:33:23.165601
1047	pentagonal prism 343	red	{0,0,0}	32.482143	259.85715	914.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:23.167938
1048	cylinder 266	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:33:23.17007
1049	pentagonal prism 344	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:23.392667
1050	cube 351	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:33:23.396462
1051	cuboid 68	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:23.398372
1052	cylinder 267	green	{0,0,0}	-270.6119	216.68562	943	0	0	33.690063	cylinder.usd	2025-03-29 15:33:23.400373
1053	pentagonal prism 345	black	{0,0,0}	-127.45538	519.6258	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:23.628773
1054	cube 352	pink	{0,0,0}	-206.86989	346.0904	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:23.631051
1055	cube 353	red	{0,0,0}	32.354057	259.8129	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:23.63293
1056	cylinder 268	green	{0,0,0}	-270.59756	217.65457	933	0	0	26.56505	cylinder.usd	2025-03-29 15:33:23.634829
1057	pentagonal prism 346	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:23.85904
1058	cube 354	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.03624	cube.usd	2025-03-29 15:33:23.863449
1059	pentagonal prism 347	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:23.865469
1060	cylinder 269	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:23.867472
1061	pentagonal prism 348	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:24.103762
1062	cube 355	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:33:24.107437
1063	cube 356	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:33:24.109501
1064	cylinder 270	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:24.112055
1065	pentagonal prism 349	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:24.366235
1066	cube 357	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03625	cube.usd	2025-03-29 15:33:24.368425
1067	cube 358	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:33:24.370296
1068	cylinder 271	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:24.372072
1069	pentagonal prism 350	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:24.59228
1070	cube 359	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:33:24.595472
1071	cuboid 69	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:33:24.597492
1072	cylinder 272	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:24.599518
1073	pentagonal prism 351	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:24.827658
1074	cube 360	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:33:24.831256
1075	cube 361	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:33:24.833153
1076	cylinder 273	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:24.835085
1077	pentagonal prism 352	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:25.06283
1078	cube 362	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:25.066565
1079	cuboid 70	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:33:25.068549
1080	cylinder 274	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:33:25.070616
1081	pentagonal prism 353	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:25.29392
1082	cube 363	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.420776	cube.usd	2025-03-29 15:33:25.297726
1083	pentagonal prism 354	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:25.299557
1084	cylinder 275	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:25.301502
1085	pentagonal prism 355	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:25.532714
1086	cube 364	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.03624	cube.usd	2025-03-29 15:33:25.536558
1087	cube 365	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:25.538738
1088	cylinder 276	green	{0,0,0}	-270.6119	216.68562	941.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:25.540969
1089	pentagonal prism 356	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:25.757961
1090	cube 366	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:33:25.761925
1091	pentagonal prism 357	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:25.764284
1092	cylinder 277	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:25.766326
1093	pentagonal prism 358	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:25.999237
1094	cube 367	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 15:33:26.003213
1095	cube 368	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:33:26.005183
1096	cylinder 278	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:26.007157
1097	pentagonal prism 359	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:26.238996
1098	cube 369	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:33:26.242917
1099	pentagonal prism 360	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:26.245154
1100	cylinder 279	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:26.247598
1101	pentagonal prism 361	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:26.460379
1102	cube 370	pink	{0,0,0}	-208.67317	346.4762	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:26.463933
1103	cube 371	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:26.466369
1104	cylinder 280	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:33:26.468289
1105	pentagonal prism 362	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:26.696735
1106	cube 372	pink	{0,0,0}	-208.67317	346.4762	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:26.700568
1107	pentagonal prism 363	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:26.702565
1108	cylinder 281	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:26.70456
1109	pentagonal prism 364	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:26.931754
1110	cube 373	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:26.935588
1111	cube 374	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:26.937433
1112	cylinder 282	green	{0,0,0}	-270.6119	216.68562	941.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:26.939388
1113	pentagonal prism 365	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:27.15969
1114	cube 375	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03625	cube.usd	2025-03-29 15:33:27.163917
1115	cube 376	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:27.166328
1116	cylinder 283	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:33:27.168363
1117	pentagonal prism 366	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:27.393308
1118	cube 377	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:33:27.395976
1119	cube 378	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:33:27.398829
1120	cylinder 284	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:33:27.401078
1121	pentagonal prism 367	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:27.627301
1122	cube 379	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.34933	cube.usd	2025-03-29 15:33:27.631186
1123	pentagonal prism 368	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:33:27.633353
1124	cylinder 285	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:27.635262
1125	pentagonal prism 369	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:27.861444
1126	cube 380	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:27.864924
1127	cube 381	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:33:27.867121
1128	cylinder 286	green	{0,0,0}	-270.6119	216.68562	933	0	0	33.690063	cylinder.usd	2025-03-29 15:33:27.869143
1129	pentagonal prism 370	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:28.098083
1130	cube 382	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:28.101429
1131	pentagonal prism 371	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:28.103248
1132	cylinder 287	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:28.105137
1133	pentagonal prism 372	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:28.326814
1134	cube 383	pink	{0,0,0}	-209.49138	347.83475	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:28.330992
1135	cube 384	red	{0,0,0}	31.621342	260.87607	924	0	0	37.568592	cube.usd	2025-03-29 15:33:28.333385
1136	cylinder 288	green	{0,0,0}	-273.72223	218.38489	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:28.335332
1137	pentagonal prism 373	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:28.553787
1138	cube 385	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.620872	cube.usd	2025-03-29 15:33:28.556151
1139	cube 386	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:33:28.558086
1140	cylinder 289	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:28.560046
1141	pentagonal prism 374	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:28.776769
1142	cube 387	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.03625	cube.usd	2025-03-29 15:33:28.780538
1143	cuboid 71	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:33:28.783124
1144	cylinder 290	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:28.785267
1145	pentagonal prism 375	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:28.999768
1146	cube 388	pink	{0,0,0}	-207.68886	346.4762	941.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:29.002282
1147	pentagonal prism 376	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:33:29.004231
1148	cylinder 291	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:29.006038
1149	pentagonal prism 377	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:29.231902
1150	cube 389	pink	{0,0,0}	-205.90816	345.1413	925.00006	0	0	59.62088	cube.usd	2025-03-29 15:33:29.235658
1151	cube 390	red	{0,0,0}	32.357	258.856	924	0	0	37.405357	cube.usd	2025-03-29 15:33:29.237555
1152	cylinder 292	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:29.239478
1153	pentagonal prism 378	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:29.461164
1154	cube 391	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:29.465311
1155	hexagonal prism 32	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:33:29.467887
1156	cylinder 293	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:29.46991
1157	pentagonal prism 379	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:33:29.701301
1158	cube 392	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:29.703774
1159	cuboid 72	red	{0,0,0}	32.355774	258.8462	924	0	0	37.647617	cuboid.usd	2025-03-29 15:33:29.705838
1160	cylinder 294	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:33:29.707688
1161	pentagonal prism 380	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:29.931433
1162	cube 393	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:29.935411
1163	pentagonal prism 381	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:29.93747
1164	cylinder 295	green	{0,0,0}	-272.65317	217.53194	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:29.939597
1165	pentagonal prism 382	black	{0,0,0}	-128.94919	520.7185	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:30.169394
1166	cube 394	pink	{0,0,0}	-207.6968	346.48944	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:30.172745
1167	pentagonal prism 383	red	{0,0,0}	31.499039	259.86707	921.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:33:30.174551
1168	cylinder 296	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	cylinder.usd	2025-03-29 15:33:30.176484
1169	pentagonal prism 384	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:30.402455
1170	cube 395	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:33:30.406313
1171	hexagonal prism 33	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:33:30.408222
1172	cylinder 297	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:30.410153
1173	pentagonal prism 385	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:30.637449
1174	cube 396	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:33:30.641426
1175	hexagonal prism 34	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:33:30.64359
1176	cylinder 298	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:30.645497
1177	pentagonal prism 386	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:30.882858
1178	cube 397	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:33:30.886354
1179	cube 398	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:30.888166
1180	cylinder 299	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:30.890092
1181	pentagonal prism 387	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:31.112969
1182	cube 399	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:31.117378
1183	cuboid 73	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:33:31.119564
1184	cylinder 300	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:31.121506
1185	hexagonal prism 35	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:33:31.352093
1186	cube 400	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:33:31.355775
1187	cube 401	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:31.357583
1188	cylinder 301	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:33:31.359529
1189	pentagonal prism 388	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:31.589116
1190	cube 402	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 15:33:31.592926
1191	cube 403	red	{0,0,0}	31.497837	259.85715	924	0	0	37.746803	cube.usd	2025-03-29 15:33:31.594905
1192	cylinder 302	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:31.59684
1193	pentagonal prism 389	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:31.814751
1194	cube 404	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:31.817752
1195	cube 405	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:31.820156
1196	cylinder 303	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:33:31.822103
1197	pentagonal prism 390	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:32.074965
1198	cube 406	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:33:32.078559
1199	pentagonal prism 391	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:32.080395
1200	cylinder 304	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:32.082426
1201	pentagonal prism 392	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:32.330744
1202	cube 407	pink	{0,0,0}	-207.68886	346.4762	913.00006	0	0	59.34933	cube.usd	2025-03-29 15:33:32.334901
1203	hexagonal prism 36	red	{0,0,0}	31.497837	259.85715	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:33:32.337181
1204	cylinder 305	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:32.339118
1205	pentagonal prism 393	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:32.575337
1206	cube 408	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:32.579029
1207	pentagonal prism 394	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:32.581061
1208	cylinder 306	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:33:32.582999
1209	pentagonal prism 395	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:32.809943
1210	cube 409	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:33:32.813876
1211	cuboid 74	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:33:32.816074
1212	cylinder 307	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:32.8187
1213	pentagonal prism 396	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:33.036595
1214	cube 410	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	60.255116	cube.usd	2025-03-29 15:33:33.039728
1215	pentagonal prism 397	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:33.041869
1216	cylinder 308	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:33.043923
1217	pentagonal prism 398	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:33.271208
1218	cube 411	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:33.273452
1219	cube 412	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:33.275416
1220	cylinder 309	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:33.277228
1221	pentagonal prism 399	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:33.500998
1222	cube 413	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:33:33.504999
1223	cuboid 75	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:33.507318
1224	cylinder 310	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:33.509316
1225	pentagonal prism 400	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:33.7275
1226	cube 414	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:33:33.731325
1227	cube 415	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:33.733325
1228	cylinder 311	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:33.73548
1229	pentagonal prism 401	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:33.959746
1230	cube 416	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:33.963369
1231	pentagonal prism 402	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:33.965357
1232	cylinder 312	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:33:33.967279
1233	pentagonal prism 403	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:33:34.194557
1234	cube 417	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:34.197889
1235	hexagonal prism 37	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:33:34.199888
1236	cylinder 313	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:34.202174
1237	pentagonal prism 404	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:34.426662
1238	cube 418	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:33:34.428812
1239	pentagonal prism 405	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:33:34.430605
1240	cylinder 314	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 15:33:34.432549
1241	pentagonal prism 406	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:34.650283
1242	cube 419	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:33:34.652496
1243	cuboid 76	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:33:34.65524
1244	cylinder 315	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:33:34.658549
1245	pentagonal prism 407	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:34.887613
1246	cube 420	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:33:34.891342
1247	cuboid 77	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:34.893163
1248	cylinder 316	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:34.895118
1249	pentagonal prism 408	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:33:35.119359
1250	cube 421	pink	{0,0,0}	-207.68886	346.4762	903.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:35.123274
1251	cuboid 78	red	{0,0,0}	31.497837	259.85715	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:35.125229
1252	cylinder 317	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:35.127127
1253	pentagonal prism 409	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:35.352077
1254	cube 422	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:33:35.354683
1255	pentagonal prism 410	red	{0,0,0}	32.357	258.856	920	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:33:35.356947
1256	cylinder 318	green	{0,0,0}	-270.62216	216.69383	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:35.359035
1257	pentagonal prism 411	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:35.594361
1258	cube 423	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:35.596831
1259	cube 424	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.874985	cube.usd	2025-03-29 15:33:35.598839
1260	cylinder 319	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:35.600679
1261	pentagonal prism 412	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:35.821657
1262	cube 425	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:33:35.825409
1263	cube 426	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:35.827492
1264	cylinder 320	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:35.830403
1265	pentagonal prism 413	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:36.059996
1266	cube 427	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.743565	cube.usd	2025-03-29 15:33:36.064368
1267	cuboid 79	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:36.066301
1268	cylinder 321	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:36.068161
1269	pentagonal prism 414	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:36.299494
1270	cube 428	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:36.303242
1271	cuboid 80	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:36.305758
1272	cylinder 322	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:33:36.307814
1273	pentagonal prism 415	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:36.530991
1274	cube 429	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03624	cube.usd	2025-03-29 15:33:36.53457
1275	cube 430	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:36.536565
1276	cylinder 323	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:36.539029
1277	hexagonal prism 38	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:33:36.752339
1278	cube 431	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:36.755626
1279	cube 432	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:33:36.75786
1280	cylinder 324	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:36.759812
1281	pentagonal prism 416	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:36.985041
1282	cube 433	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.420776	cube.usd	2025-03-29 15:33:36.989502
1283	cuboid 81	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:36.992256
1284	cylinder 325	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:36.994593
1285	pentagonal prism 417	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:33:37.217799
1286	cube 434	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:33:37.220332
1287	cuboid 82	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:37.22317
1288	cylinder 326	green	{0,0,0}	-270.6119	216.68562	920	0	0	36.869896	cylinder.usd	2025-03-29 15:33:37.225411
1289	pentagonal prism 418	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:33:37.436128
1290	cube 435	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:33:37.439092
1291	cuboid 83	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:33:37.44122
1292	cylinder 327	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:37.443295
1293	pentagonal prism 419	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:33:37.676564
1294	cube 436	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:33:37.680208
1295	cuboid 84	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:33:37.682023
1296	cylinder 328	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:37.683859
1297	pentagonal prism 420	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:33:37.91661
1298	cube 437	pink	{0,0,0}	-206.88084	345.12823	933	0	0	59.03625	cube.usd	2025-03-29 15:33:37.920318
1299	pentagonal prism 421	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:33:37.923091
1300	cylinder 329	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:33:37.925301
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
1	2025-03-29 15:32:12.811632	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-03-29 15:32:12.811632	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 15:32:12.811632
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 15:32:12.811632
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-03-29 15:32:12.811632
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
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-03-29 15:32:12.811632
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-03-29 15:32:12.811632
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
1	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscar.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	2025-03-29 15:32:12.811632	2025-03-29 15:32:12.811632
2	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahul.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\N	\N	2025-03-29 15:32:12.811632	2025-03-29 15:32:12.811632
3	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanjay.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	2025-03-29 15:32:12.811632	2025-03-29 15:32:12.811632
4	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehdi.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	2025-03-29 15:32:12.811632	2025-03-29 15:32:12.811632
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 1300, true);


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

