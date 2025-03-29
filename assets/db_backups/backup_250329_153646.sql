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
1	pentagonal prism 2	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:34:58.319367
2	cube 2	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	60.255116	cube.usd	2025-03-29 15:34:58.32485
3	wedge 2	green	{0.01,0.01,0.01}	118.63783	355.91348	1941.0001	0	0	5.640549	wedge.usd	2025-03-29 15:34:58.327119
4	hexagonal prism 2	red	{0,0,0}	31.375294	259.82666	945.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:34:58.328993
5	cylinder 2	green	{0,0,0}	-270.6119	216.68562	898.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:34:58.330859
6	pentagonal prism 3	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:34:58.551933
7	cube 3	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.62088	cube.usd	2025-03-29 15:34:58.554483
8	hexagonal prism 3	red	{0,0,0}	31.375294	259.82666	945.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 15:34:58.55659
9	cylinder 3	green	{0,0,0}	-270.6119	216.68562	898.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:34:58.558683
10	pentagonal prism 4	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:34:58.776273
11	cube 4	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:34:58.778907
12	cube 6	red	{0,0,0}	32.355774	258.8462	945.00006	0	0	37.568592	cube.usd	2025-03-29 15:34:58.780785
13	cylinder 4	green	{0,0,0}	-270.6119	216.68562	898.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:34:58.782556
14	pentagonal prism 5	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:34:59.000366
15	cube 7	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:34:59.003057
16	cube 9	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.568592	cube.usd	2025-03-29 15:34:59.005104
17	cylinder 6	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:34:59.00711
18	pentagonal prism 6	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:34:59.216031
19	cube 10	pink	{0,0,0}	-207.68886	346.4762	915	0	0	59.34933	cube.usd	2025-03-29 15:34:59.219362
20	pentagonal prism 8	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:34:59.221226
21	cylinder 7	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:34:59.223221
22	pentagonal prism 9	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:34:59.448262
23	cube 11	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.62088	cube.usd	2025-03-29 15:34:59.450959
24	pentagonal prism 10	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:34:59.453107
25	cylinder 8	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:34:59.455133
26	pentagonal prism 11	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:34:59.672282
27	cube 12	pink	{0,0,0}	-205.90038	345.12823	935.00006	0	0	59.620872	cube.usd	2025-03-29 15:34:59.676316
28	cube 13	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	cube.usd	2025-03-29 15:34:59.678254
29	cylinder 9	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:34:59.680249
30	pentagonal prism 12	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:34:59.902221
31	cube 14	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:34:59.905643
32	cube 15	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:34:59.90792
33	cylinder 10	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:34:59.910099
34	pentagonal prism 13	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:00.124546
35	cube 16	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:00.126947
36	hexagonal prism 4	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:35:00.128766
37	cylinder 11	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:00.130675
38	pentagonal prism 14	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:00.357131
39	cube 17	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:00.359698
40	pentagonal prism 15	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:35:00.361897
41	cylinder 12	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:00.363944
42	pentagonal prism 16	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:00.585832
43	cube 18	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:00.589517
44	cube 19	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:35:00.592025
45	cylinder 13	green	{0,0,0}	-272.65317	217.53194	924	0	0	45	cylinder.usd	2025-03-29 15:35:00.594145
46	pentagonal prism 17	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:00.81845
47	cube 20	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:00.820699
48	cube 21	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:00.822711
49	cylinder 14	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:35:00.824955
50	pentagonal prism 18	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:01.039574
51	cube 22	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:01.042376
52	pentagonal prism 19	red	{0,0,0}	31.497837	259.85715	915	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:01.044386
53	cylinder 15	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:01.046451
54	pentagonal prism 20	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:01.273364
55	cube 23	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:35:01.27693
56	pentagonal prism 21	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:01.279265
57	cylinder 16	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:01.281304
58	pentagonal prism 22	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:01.503774
59	cube 24	pink	{0,0,0}	-207.68886	346.4762	936.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:01.507778
60	pentagonal prism 23	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:01.509891
61	cylinder 17	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:35:01.511846
62	pentagonal prism 24	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:01.738028
63	cube 25	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:01.741194
64	cube 26	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:01.744398
65	cylinder 18	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:01.747244
66	pentagonal prism 25	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:01.978101
67	cube 27	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:01.981518
68	cube 28	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:01.983689
69	cylinder 19	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:01.985917
70	pentagonal prism 26	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:02.209458
71	cube 29	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:02.213209
72	cube 30	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	cube.usd	2025-03-29 15:35:02.215181
73	cylinder 20	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:35:02.217149
74	pentagonal prism 27	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:02.440133
75	cube 31	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.62088	cube.usd	2025-03-29 15:35:02.444989
76	cuboid 2	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:35:02.447478
77	cylinder 21	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	45	cylinder.usd	2025-03-29 15:35:02.44955
78	pentagonal prism 28	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:02.671435
79	cube 32	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:35:02.675225
80	cuboid 3	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:35:02.677389
81	cylinder 22	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	45	cylinder.usd	2025-03-29 15:35:02.679708
82	pentagonal prism 29	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:02.890976
83	cube 33	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:35:02.8942
84	pentagonal prism 30	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:02.896394
85	cylinder 23	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:02.898504
86	pentagonal prism 31	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:03.125168
87	cube 34	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:03.12758
88	cube 35	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:03.129771
89	cylinder 24	green	{0,0,0}	-272.65317	217.53194	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:03.131614
90	pentagonal prism 32	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:03.353061
91	cube 36	pink	{0,0,0}	-207.68886	346.4762	913.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:03.355808
92	pentagonal prism 33	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:03.357774
93	cylinder 25	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:03.359901
94	pentagonal prism 34	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:03.570612
95	cube 37	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:35:03.573188
96	cuboid 4	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	cuboid.usd	2025-03-29 15:35:03.575089
97	cylinder 26	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:03.577453
98	pentagonal prism 35	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:03.790043
99	cube 38	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:03.792663
100	cube 39	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	cube.usd	2025-03-29 15:35:03.794887
101	cylinder 27	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:03.796936
102	pentagonal prism 36	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:04.022568
103	cube 40	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:04.026061
104	cuboid 5	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:35:04.027919
105	cylinder 28	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:04.030157
106	pentagonal prism 37	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:04.243715
107	cube 41	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:04.246791
108	pentagonal prism 38	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:04.248611
109	cylinder 29	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:04.250425
110	pentagonal prism 39	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:04.478302
111	cube 42	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:04.48056
112	cuboid 6	red	{0,0,0}	31.497837	259.85715	919	0	0	37.746803	cuboid.usd	2025-03-29 15:35:04.4824
113	cylinder 30	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:04.484188
114	pentagonal prism 40	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:04.706913
115	cube 43	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:35:04.710489
116	cube 44	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	cube.usd	2025-03-29 15:35:04.71273
117	cylinder 31	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:04.714747
118	pentagonal prism 41	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:04.940065
119	cube 45	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:04.943781
120	pentagonal prism 42	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:04.945983
121	cylinder 32	green	{0,0,0}	-272.65317	217.53194	934	0	0	36.869896	cylinder.usd	2025-03-29 15:35:04.94806
122	pentagonal prism 43	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:05.175102
123	cube 46	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:35:05.178867
124	cube 47	red	{0,0,0}	31.497837	259.85715	932.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:05.18101
125	cylinder 33	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:05.184327
126	pentagonal prism 44	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:05.408096
127	cube 48	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:35:05.410469
128	hexagonal prism 5	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:35:05.412523
129	cylinder 34	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:05.414409
130	pentagonal prism 45	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:05.627918
131	cube 49	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.620872	cube.usd	2025-03-29 15:35:05.630478
132	pentagonal prism 46	red	{0,0,0}	32.355774	258.8462	924	0	0	37.647617	pentagonal prism.usd	2025-03-29 15:35:05.632553
133	cylinder 35	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:05.634403
134	pentagonal prism 47	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:05.84414
135	cube 50	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:35:05.846447
136	pentagonal prism 48	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:05.848352
137	cylinder 36	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:05.85019
138	pentagonal prism 49	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:06.073753
139	cube 51	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.620872	cube.usd	2025-03-29 15:35:06.077769
140	pentagonal prism 50	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:06.079772
141	cylinder 37	green	{0,0,0}	-272.65317	217.53194	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:06.08221
142	pentagonal prism 51	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:06.296
143	cube 52	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.743565	cube.usd	2025-03-29 15:35:06.298771
144	cuboid 7	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:06.301099
145	cylinder 38	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:06.303096
146	pentagonal prism 52	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:06.531132
147	cube 53	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:06.535181
148	cuboid 8	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:06.537281
149	cylinder 39	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:06.53965
150	pentagonal prism 53	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:06.760984
151	cube 54	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:06.764932
152	cuboid 9	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:35:06.766966
153	cylinder 40	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:06.769069
154	pentagonal prism 54	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:06.983623
155	cube 55	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:06.986595
156	hexagonal prism 6	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:35:06.988824
157	cylinder 41	green	{0,0,0}	-272.65317	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:06.990996
158	pentagonal prism 55	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:07.206849
159	cube 56	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:35:07.209838
160	pentagonal prism 56	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:07.212069
161	cylinder 42	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:07.214361
162	pentagonal prism 57	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:07.43181
163	cube 57	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:07.434629
164	pentagonal prism 58	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:07.436859
165	cylinder 43	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:07.438746
166	hexagonal prism 8	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:07.654995
167	cube 58	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:07.65901
168	cube 59	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:07.660917
169	cylinder 44	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:07.662796
170	pentagonal prism 59	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:07.878084
171	cube 60	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:35:07.881198
172	pentagonal prism 60	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:07.88323
173	cylinder 45	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:07.885212
174	pentagonal prism 61	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:08.111197
175	cube 61	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:08.113941
176	cube 62	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:35:08.116165
177	cylinder 46	green	{0,0,0}	-270.6119	216.68562	920	0	0	38.65981	cylinder.usd	2025-03-29 15:35:08.118257
178	pentagonal prism 62	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:08.33363
179	cube 63	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:08.336354
180	cuboid 10	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:08.33831
181	cylinder 47	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:08.340311
182	pentagonal prism 63	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:08.559609
183	cube 64	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:08.562007
184	cuboid 11	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:08.564249
185	cylinder 48	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:08.566308
186	pentagonal prism 64	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:08.792864
187	cube 65	pink	{0,0,0}	-208.50322	347.83475	913.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:08.795095
188	cube 66	red	{0,0,0}	31.621342	260.87607	920	0	0	37.874985	cube.usd	2025-03-29 15:35:08.797038
189	cylinder 49	green	{0,0,0}	-273.72223	218.38489	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:08.798963
190	pentagonal prism 65	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:09.031758
191	cube 67	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:09.035001
192	pentagonal prism 66	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:09.037039
193	cylinder 50	green	{0,0,0}	-272.65317	217.53194	939.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:09.039271
194	pentagonal prism 67	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:09.261337
195	cube 68	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:09.265272
196	pentagonal prism 68	red	{0,0,0}	31.497837	259.85715	913.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:35:09.267383
197	cylinder 51	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:09.269316
198	pentagonal prism 69	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:09.496448
199	cube 69	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:35:09.500601
200	cuboid 12	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:09.502716
201	cylinder 52	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:09.504994
202	pentagonal prism 70	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:09.729103
203	cube 70	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:09.733294
204	cube 71	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	cube.usd	2025-03-29 15:35:09.735518
205	cylinder 53	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:09.737543
206	pentagonal prism 71	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:09.960112
207	cube 72	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:09.962277
208	pentagonal prism 72	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:09.96412
209	cylinder 54	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	20.556046	cylinder.usd	2025-03-29 15:35:09.966043
210	pentagonal prism 73	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:10.179168
211	cube 73	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:35:10.18128
212	cuboid 13	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:35:10.183384
213	cylinder 55	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:35:10.185342
214	hexagonal prism 9	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:35:10.398518
215	cube 74	pink	{0,0,0}	-206.88084	345.12823	919	0	0	60.255116	cube.usd	2025-03-29 15:35:10.402012
216	cuboid 14	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:35:10.404158
217	cylinder 56	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:10.406224
218	pentagonal prism 74	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:10.628198
219	cube 75	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:35:10.630883
220	pentagonal prism 75	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:10.633068
221	cylinder 57	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:35:10.635543
222	pentagonal prism 76	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:10.848025
223	cube 76	pink	{0,0,0}	-207.68886	346.4762	936.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:10.850717
224	pentagonal prism 77	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:10.852702
225	cylinder 58	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:10.854629
226	hexagonal prism 10	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:35:11.079253
227	cube 77	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:11.081354
228	pentagonal prism 78	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.647617	pentagonal prism.usd	2025-03-29 15:35:11.083445
229	cylinder 59	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:11.085328
230	pentagonal prism 79	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:11.296471
231	cube 78	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.62088	cube.usd	2025-03-29 15:35:11.298751
232	hexagonal prism 11	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:35:11.300707
233	cylinder 60	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:11.302664
234	hexagonal prism 12	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:35:11.514232
235	cube 79	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:35:11.516689
236	cuboid 15	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:35:11.518931
237	cylinder 61	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:11.520867
238	pentagonal prism 80	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:11.730978
239	cube 80	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:11.733573
240	cuboid 16	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:11.735582
241	cylinder 62	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:11.73761
242	pentagonal prism 81	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:11.961787
243	cube 81	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:11.964067
244	cube 82	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:35:11.965953
245	cylinder 63	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:11.968043
246	pentagonal prism 82	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:12.185484
247	cube 83	pink	{0,0,0}	-208.50322	347.83475	939.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:12.188951
248	cube 84	red	{0,0,0}	31.621342	260.87607	926.00006	0	0	37.405357	cube.usd	2025-03-29 15:35:12.19093
249	cylinder 64	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:12.192928
250	pentagonal prism 83	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:12.418186
251	cube 85	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:12.422422
252	pentagonal prism 84	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:12.424325
253	cylinder 65	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:12.426285
254	hexagonal prism 13	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:12.644522
255	cube 86	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:35:12.647216
256	cuboid 17	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:12.64944
257	cylinder 66	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:12.651428
258	pentagonal prism 85	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:12.865867
259	cube 87	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03625	cube.usd	2025-03-29 15:35:12.868473
260	cube 88	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:12.871003
261	cylinder 67	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:12.87302
262	pentagonal prism 86	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:13.097804
263	cube 89	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:35:13.101897
264	cuboid 18	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:35:13.103861
265	cylinder 68	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:13.105838
266	pentagonal prism 87	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:13.333017
267	cube 90	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:35:13.335613
268	cuboid 19	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:13.338172
269	cylinder 69	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:13.340519
270	pentagonal prism 88	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:13.552697
271	cube 91	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:13.555007
272	cuboid 20	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:13.556906
273	cylinder 70	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:35:13.558637
274	pentagonal prism 89	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:13.78478
275	cube 92	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 15:35:13.788617
276	cuboid 21	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:13.790567
277	cylinder 71	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:35:13.792588
278	hexagonal prism 14	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:35:14.028662
279	cube 93	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:14.031352
280	cube 94	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cube.usd	2025-03-29 15:35:14.033443
281	cylinder 72	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:35:14.035317
282	hexagonal prism 15	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:35:14.250237
283	cube 95	pink	{0,0,0}	-208.50322	347.83475	920	0	0	59.620872	cube.usd	2025-03-29 15:35:14.2527
284	cube 96	red	{0,0,0}	31.621342	260.87607	923.00006	0	0	37.647617	cube.usd	2025-03-29 15:35:14.254636
285	cylinder 73	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:14.256447
286	pentagonal prism 90	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:14.486368
287	cube 97	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:14.490109
288	cuboid 22	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cuboid.usd	2025-03-29 15:35:14.492029
289	cylinder 74	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:14.494
290	pentagonal prism 91	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:14.722406
291	cube 98	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:14.726207
292	cuboid 23	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:14.728026
293	cylinder 75	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:35:14.730053
294	pentagonal prism 92	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:14.950352
295	cube 99	pink	{0,0,0}	-207.68886	346.4762	935.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:14.953296
296	cuboid 24	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:35:14.955379
297	cylinder 76	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:14.957362
298	pentagonal prism 93	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:15.19183
299	cube 100	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 15:35:15.194896
300	cube 101	red	{0,0,0}	31.497837	259.85715	929	0	0	36.869896	cube.usd	2025-03-29 15:35:15.196708
301	cylinder 77	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:15.198789
302	hexagonal prism 16	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:15.414878
303	cube 102	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:15.417188
304	pentagonal prism 94	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:15.419127
305	cylinder 78	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:15.421196
306	hexagonal prism 17	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:15.644081
307	cube 103	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:15.646846
308	pentagonal prism 95	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:15.648958
309	cylinder 79	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:15.650924
310	pentagonal prism 96	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:15.87566
311	cube 104	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.420776	cube.usd	2025-03-29 15:35:15.879428
312	pentagonal prism 97	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:15.881758
313	cylinder 80	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:35:15.883913
314	pentagonal prism 98	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:16.098504
315	cube 105	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:16.102149
316	cube 106	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:16.104116
317	cylinder 81	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:35:16.106229
318	pentagonal prism 99	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:16.321679
319	cube 107	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:35:16.324547
320	cube 108	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:35:16.326418
321	cylinder 82	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:16.328371
322	pentagonal prism 100	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:16.546126
323	cube 109	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:16.550063
324	pentagonal prism 101	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:35:16.552069
325	cylinder 83	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:35:16.553959
326	pentagonal prism 102	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:16.766571
327	cube 110	pink	{0,0,0}	-207.68886	346.4762	935.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:16.768796
328	pentagonal prism 103	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:16.770895
329	cylinder 84	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:16.773373
330	pentagonal prism 104	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:16.985866
331	cube 111	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:16.988087
332	cube 112	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:16.990064
333	cylinder 85	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:35:16.99186
334	pentagonal prism 105	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:17.216471
335	cube 113	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:17.220355
336	pentagonal prism 106	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:17.222289
337	cylinder 86	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:17.224487
338	pentagonal prism 107	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:17.444684
339	cube 114	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:17.447408
340	cuboid 25	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:35:17.449344
341	cylinder 87	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:17.451294
342	pentagonal prism 108	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:17.669125
343	cube 115	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:17.67269
344	pentagonal prism 109	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:17.674632
345	cylinder 88	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:17.676612
346	pentagonal prism 110	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:17.895905
347	cube 116	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:35:17.900144
348	cube 117	red	{0,0,0}	32.355774	258.8462	915	0	0	37.405357	cube.usd	2025-03-29 15:35:17.902126
349	cylinder 89	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:17.90419
350	hexagonal prism 18	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:35:18.122485
351	cube 118	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:18.124699
352	cube 119	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:18.126536
353	cylinder 90	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:18.128326
354	hexagonal prism 19	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:35:18.359158
355	cube 120	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:18.36319
356	cuboid 26	red	{0,0,0}	31.497837	259.85715	924	0	0	37.874985	cuboid.usd	2025-03-29 15:35:18.365428
357	cylinder 91	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:18.367611
358	pentagonal prism 111	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:18.588382
359	cube 121	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:18.592068
360	cube 122	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:18.594007
361	cylinder 92	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:18.596055
362	pentagonal prism 112	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:18.820913
363	cube 123	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.620872	cube.usd	2025-03-29 15:35:18.824963
364	pentagonal prism 113	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:18.826943
365	cylinder 93	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:18.829128
366	pentagonal prism 114	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:19.063238
367	cube 124	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:35:19.0659
368	cube 125	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:35:19.067861
369	cylinder 94	green	{0,0,0}	-272.65317	217.53194	924	0	0	33.690063	cylinder.usd	2025-03-29 15:35:19.069789
370	pentagonal prism 115	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:19.28852
371	cube 126	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:19.292172
372	cube 127	red	{0,0,0}	31.497837	259.85715	920	0	0	37.874985	cube.usd	2025-03-29 15:35:19.294149
373	cylinder 95	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:19.296265
374	pentagonal prism 116	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:19.514868
375	cube 128	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:19.51704
376	pentagonal prism 117	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:19.519083
377	cylinder 96	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:19.52104
378	pentagonal prism 118	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:19.734608
379	cube 129	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 15:35:19.738661
380	pentagonal prism 119	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:35:19.741004
381	cylinder 97	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:19.74327
382	pentagonal prism 120	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:19.964151
383	cube 130	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:19.966853
384	pentagonal prism 121	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:19.969299
385	cylinder 98	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:19.971438
386	pentagonal prism 122	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:20.188996
387	cube 131	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:20.19382
388	cuboid 27	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:20.197951
389	cylinder 99	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:20.201028
390	pentagonal prism 123	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:20.420812
391	cube 132	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:20.423083
392	pentagonal prism 124	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:20.425228
393	cylinder 100	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:20.427246
394	pentagonal prism 125	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:20.639261
395	cube 133	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:35:20.64206
396	cuboid 28	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:20.644319
397	cylinder 101	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:20.646226
398	pentagonal prism 126	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:20.900515
399	cube 134	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.534454	cube.usd	2025-03-29 15:35:20.9033
400	pentagonal prism 127	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:20.905101
401	cylinder 102	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:20.906945
402	pentagonal prism 128	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:21.128444
403	cube 135	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.62088	cube.usd	2025-03-29 15:35:21.13235
404	cuboid 29	red	{0,0,0}	31.497837	259.85715	920	0	0	37.874985	cuboid.usd	2025-03-29 15:35:21.134287
405	cylinder 103	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:21.136402
406	pentagonal prism 129	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:21.371178
407	cube 136	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 15:35:21.37475
408	cuboid 30	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:21.377254
409	cylinder 104	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:21.379453
410	pentagonal prism 130	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:21.614349
411	cube 137	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:21.618072
412	pentagonal prism 131	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:21.620356
413	cylinder 105	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:21.622394
414	hexagonal prism 20	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:35:21.843973
415	cube 138	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:35:21.847597
416	pentagonal prism 132	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:21.849889
417	cylinder 106	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:21.85232
418	pentagonal prism 133	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:22.083141
419	cube 139	pink	{0,0,0}	-207.68886	346.4762	938	0	0	59.03624	cube.usd	2025-03-29 15:35:22.087072
420	cube 140	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:35:22.089102
421	cylinder 107	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:22.09111
422	hexagonal prism 21	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:35:22.309714
423	cube 141	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.420776	cube.usd	2025-03-29 15:35:22.312599
424	cube 142	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:35:22.31495
425	cylinder 108	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:22.316989
426	hexagonal prism 22	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:35:22.548549
427	cube 143	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.93142	cube.usd	2025-03-29 15:35:22.552435
428	cuboid 31	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:22.554437
429	cylinder 109	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:22.55641
430	hexagonal prism 23	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:35:22.777784
431	cube 144	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:22.781747
432	cube 145	red	{0,0,0}	32.355774	258.8462	920	0	0	37.746803	cube.usd	2025-03-29 15:35:22.783592
433	cylinder 110	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:22.785607
434	pentagonal prism 134	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:23.001986
435	cube 146	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:23.004778
436	cuboid 32	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	cuboid.usd	2025-03-29 15:35:23.006709
437	cylinder 111	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:23.008766
438	hexagonal prism 24	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:35:23.223716
439	cube 147	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:23.226385
440	cube 148	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:35:23.228587
441	cylinder 112	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:23.230656
442	hexagonal prism 25	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:35:23.465103
443	cube 149	pink	{0,0,0}	-208.50322	347.83475	934	0	0	59.34933	cube.usd	2025-03-29 15:35:23.469334
444	pentagonal prism 135	red	{0,0,0}	31.621342	260.87607	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:23.471537
445	cylinder 113	green	{0,0,0}	-273.72223	218.38489	930.00006	0	0	20.556046	cylinder.usd	2025-03-29 15:35:23.47367
446	pentagonal prism 136	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:23.693886
447	cube 150	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:23.696625
448	pentagonal prism 137	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:23.698943
449	cylinder 114	green	{0,0,0}	-271.66885	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:23.701075
450	pentagonal prism 138	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:23.929375
451	cube 151	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:23.933196
452	cube 152	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:35:23.935097
453	cylinder 115	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:23.937156
454	hexagonal prism 26	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:24.173877
455	cube 153	pink	{0,0,0}	-205.90038	345.12823	939.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:24.178178
456	cuboid 33	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:24.180423
457	cylinder 116	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:24.182592
458	pentagonal prism 139	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:24.394855
459	cube 154	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.534454	cube.usd	2025-03-29 15:35:24.399604
460	pentagonal prism 140	red	{0,0,0}	32.355774	258.8462	924	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:35:24.40177
461	cylinder 117	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:24.404134
462	pentagonal prism 141	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:24.615719
463	cube 155	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.743565	cube.usd	2025-03-29 15:35:24.618351
464	cuboid 34	red	{0,0,0}	32.355774	258.8462	924	0	0	37.69424	cuboid.usd	2025-03-29 15:35:24.620295
465	cylinder 118	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:35:24.62289
466	pentagonal prism 142	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:24.844203
467	cube 156	pink	{0,0,0}	-205.90038	345.12823	910	0	0	59.420776	cube.usd	2025-03-29 15:35:24.84829
468	pentagonal prism 143	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:35:24.850382
469	cylinder 119	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:24.852446
470	pentagonal prism 144	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:25.087214
471	cube 157	pink	{0,0,0}	-207.68886	346.4762	908.00006	0	0	59.420776	cube.usd	2025-03-29 15:35:25.092142
472	cuboid 35	red	{0,0,0}	31.497837	259.85715	919	0	0	37.69424	cuboid.usd	2025-03-29 15:35:25.094385
473	cylinder 120	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:25.096976
474	pentagonal prism 145	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:25.312836
475	cube 158	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.420776	cube.usd	2025-03-29 15:35:25.315989
476	cuboid 36	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:25.318049
477	cylinder 121	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:25.320106
478	pentagonal prism 146	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:25.553411
479	cube 159	pink	{0,0,0}	-206.70456	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:35:25.556061
480	cuboid 37	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:35:25.558061
481	cylinder 122	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:25.559867
482	hexagonal prism 27	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	hexagonal prism.usd	2025-03-29 15:35:25.773547
483	cube 160	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.34933	cube.usd	2025-03-29 15:35:25.777706
484	cube 161	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.69424	cube.usd	2025-03-29 15:35:25.779897
485	cylinder 123	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:25.78218
486	hexagonal prism 28	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:35:25.996147
487	cube 162	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:25.99853
488	cuboid 38	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:35:26.000367
489	cylinder 124	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:26.00227
490	hexagonal prism 29	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:35:26.217999
491	cube 163	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:26.221768
492	cuboid 39	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:26.224114
493	cylinder 125	green	{0,0,0}	-272.65317	217.53194	934	0	0	36.869896	cylinder.usd	2025-03-29 15:35:26.226192
494	pentagonal prism 147	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:26.449391
495	cube 164	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:26.452569
496	cube 165	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:35:26.454673
497	cylinder 126	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:26.456945
498	pentagonal prism 148	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:26.688264
499	cube 166	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:26.692418
500	cube 167	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:26.694528
501	cylinder 127	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:26.696803
502	pentagonal prism 149	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:26.914834
503	cube 168	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	58.671303	cube.usd	2025-03-29 15:35:26.918311
504	cuboid 40	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:35:26.920281
505	cylinder 128	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:26.922537
506	pentagonal prism 150	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:27.147046
507	cube 169	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.420776	cube.usd	2025-03-29 15:35:27.151044
508	pentagonal prism 151	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:27.15317
509	cylinder 129	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:27.155468
510	hexagonal prism 30	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:35:27.386522
511	cube 170	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:27.389058
512	cuboid 41	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:35:27.391126
513	cylinder 130	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:27.393234
514	pentagonal prism 152	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:27.609739
515	cube 171	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:27.614382
516	cube 172	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	cube.usd	2025-03-29 15:35:27.616896
517	cylinder 131	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:27.618903
518	pentagonal prism 153	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:27.844568
519	cube 173	pink	{0,0,0}	-206.88084	345.12823	906	0	0	59.534454	cube.usd	2025-03-29 15:35:27.848237
520	hexagonal prism 31	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:35:27.850268
521	cylinder 132	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:27.852227
522	pentagonal prism 154	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:28.081119
523	cube 174	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:28.084793
524	cube 175	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:28.086711
525	cylinder 133	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:28.088737
526	hexagonal prism 32	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:28.307177
527	cube 176	pink	{0,0,0}	-206.88084	345.12823	936.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:28.310785
528	cube 177	red	{0,0,0}	32.355774	258.8462	924	0	0	37.746803	cube.usd	2025-03-29 15:35:28.312552
529	cylinder 134	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:28.314484
530	pentagonal prism 155	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:28.535075
531	cube 178	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:28.537236
532	pentagonal prism 156	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:28.539151
533	cylinder 135	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:28.541098
534	hexagonal prism 33	black	{0,0,0}	-129.44986	522.7403	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:28.782759
535	cube 179	pink	{0,0,0}	-208.50322	347.83475	936.00006	0	0	59.420776	cube.usd	2025-03-29 15:35:28.786922
536	pentagonal prism 157	red	{0,0,0}	31.621342	260.87607	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:28.788877
537	cylinder 136	green	{0,0,0}	-273.72223	218.38489	929	0	0	33.690063	cylinder.usd	2025-03-29 15:35:28.791227
538	hexagonal prism 34	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:35:29.005951
539	cube 180	pink	{0,0,0}	-208.50322	347.83475	920	0	0	59.743565	cube.usd	2025-03-29 15:35:29.008559
540	cuboid 42	red	{0,0,0}	31.621342	260.87607	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:29.010489
541	cylinder 137	green	{0,0,0}	-273.72223	218.38489	919	0	0	26.56505	cylinder.usd	2025-03-29 15:35:29.012401
542	pentagonal prism 158	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:29.232115
543	cube 181	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:29.234979
544	hexagonal prism 35	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:35:29.237044
545	cylinder 138	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:29.239737
546	pentagonal prism 159	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:29.456562
547	cube 182	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:29.459423
548	cuboid 43	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:35:29.461727
549	cylinder 139	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:29.465001
550	pentagonal prism 160	black	{0,0,0}	-129.44986	522.7403	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:29.680519
551	cube 183	pink	{0,0,0}	-208.50322	347.83475	917.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:29.68301
552	cuboid 44	red	{0,0,0}	31.621342	260.87607	929	0	0	37.568592	cuboid.usd	2025-03-29 15:35:29.685029
553	cylinder 140	green	{0,0,0}	-273.72223	218.38489	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:29.687204
554	pentagonal prism 161	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:29.911503
555	cube 184	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:29.914309
556	cuboid 45	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:29.916818
557	cylinder 141	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:35:29.918939
558	hexagonal prism 36	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:30.150482
559	cube 185	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:30.153759
560	cube 186	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:35:30.156645
561	cylinder 142	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:30.158862
562	pentagonal prism 162	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:30.378211
563	cube 187	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:30.380625
564	cuboid 46	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:30.382524
565	cylinder 143	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:30.384924
566	pentagonal prism 163	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:30.601873
567	cube 188	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.420776	cube.usd	2025-03-29 15:35:30.605097
568	cuboid 47	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:35:30.607203
569	cylinder 144	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:30.610105
570	hexagonal prism 37	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:35:30.825384
571	cube 189	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:35:30.82956
572	cuboid 48	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:30.831519
573	cylinder 145	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:30.833634
574	pentagonal prism 164	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:31.047964
575	cube 190	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:31.050931
576	cube 191	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:35:31.053112
577	cylinder 146	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.43495	cylinder.usd	2025-03-29 15:35:31.055739
578	hexagonal prism 38	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:35:31.285577
579	cube 192	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:31.289361
580	pentagonal prism 165	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:31.291495
581	cylinder 147	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:31.29375
582	pentagonal prism 166	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:31.516389
583	cube 193	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03624	cube.usd	2025-03-29 15:35:31.520192
584	pentagonal prism 167	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:31.522118
585	cylinder 148	green	{0,0,0}	-270.6119	216.68562	924	0	0	36.869896	cylinder.usd	2025-03-29 15:35:31.524196
586	pentagonal prism 168	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:31.745882
587	cube 194	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:35:31.748461
588	cube 195	red	{0,0,0}	31.497837	259.85715	929	0	0	37.303947	cube.usd	2025-03-29 15:35:31.750408
589	cylinder 149	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:35:31.752569
590	pentagonal prism 169	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:31.969655
591	cube 196	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:35:31.972329
592	pentagonal prism 170	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:31.974225
593	cylinder 150	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:35:31.976185
594	pentagonal prism 171	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:32.194558
595	cube 197	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 15:35:32.19822
596	cuboid 49	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:35:32.200196
597	cylinder 151	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:32.202714
598	hexagonal prism 39	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	hexagonal prism.usd	2025-03-29 15:35:32.419661
599	cube 198	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:32.422388
600	cuboid 50	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:32.424239
601	cylinder 152	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:32.426109
602	pentagonal prism 172	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:32.640603
603	cube 199	pink	{0,0,0}	-206.70456	346.4762	923.00006	0	0	59.62088	cube.usd	2025-03-29 15:35:32.645494
604	cuboid 51	red	{0,0,0}	32.482143	259.85715	929	0	0	37.405357	cuboid.usd	2025-03-29 15:35:32.647572
605	cylinder 153	green	{0,0,0}	-271.66885	217.53194	929	0	0	33.690063	cylinder.usd	2025-03-29 15:35:32.649561
606	pentagonal prism 173	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:32.875672
607	cube 200	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:35:32.879732
608	cube 201	red	{0,0,0}	32.355774	258.8462	919	0	0	37.69424	cube.usd	2025-03-29 15:35:32.881706
609	cylinder 154	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:32.883981
610	hexagonal prism 40	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:35:33.109954
611	cube 202	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:33.112375
612	cube 203	red	{0,0,0}	32.355774	258.8462	920	0	0	37.746803	cube.usd	2025-03-29 15:35:33.114256
613	cylinder 155	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:35:33.116281
614	pentagonal prism 174	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:33.330211
615	cube 204	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:35:33.332814
616	pentagonal prism 175	red	{0,0,0}	32.355774	258.8462	915	0	0	37.647617	pentagonal prism.usd	2025-03-29 15:35:33.334703
617	cylinder 156	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:33.337372
618	pentagonal prism 176	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:33.562674
619	cube 205	pink	{0,0,0}	-208.50322	347.83475	910	0	0	59.743565	cube.usd	2025-03-29 15:35:33.566505
620	cuboid 52	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:33.568659
621	cylinder 157	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:33.570963
622	hexagonal prism 41	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:33.782121
623	cube 206	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:33.785347
624	cuboid 53	red	{0,0,0}	32.355774	258.8462	919	0	0	37.746803	cuboid.usd	2025-03-29 15:35:33.787776
625	cylinder 158	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:33.790158
626	hexagonal prism 42	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:35:34.000363
627	cube 207	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:34.003346
628	cuboid 54	red	{0,0,0}	32.482143	259.85715	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:34.00532
629	cylinder 159	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:34.007311
630	pentagonal prism 177	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:34.23025
631	cube 208	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:34.234042
632	pentagonal prism 178	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:34.236213
633	cylinder 160	green	{0,0,0}	-270.6119	216.68562	915	0	0	26.56505	cylinder.usd	2025-03-29 15:35:34.238451
634	pentagonal prism 179	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:34.459673
635	cube 209	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:34.462595
636	cuboid 55	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:34.464597
637	cylinder 161	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:34.466782
638	pentagonal prism 180	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:34.684088
639	cube 210	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.420776	cube.usd	2025-03-29 15:35:34.686557
640	cuboid 56	red	{0,0,0}	31.497837	259.85715	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:34.688592
641	cylinder 162	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:34.690487
642	pentagonal prism 181	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:34.920663
643	cube 211	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:34.923125
644	hexagonal prism 43	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:35:34.925097
645	cylinder 163	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:34.926961
646	pentagonal prism 182	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:35.145685
647	cube 212	pink	{0,0,0}	-208.67317	346.4762	933	0	0	59.03624	cube.usd	2025-03-29 15:35:35.149301
648	cuboid 57	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:35.151344
649	cylinder 164	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:35.153368
650	pentagonal prism 183	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:35.363274
651	cube 213	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:35:35.367225
652	cuboid 58	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:35:35.36922
653	cylinder 165	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:35.371767
654	hexagonal prism 44	black	{0,0,0}	-127.95996	520.6986	655.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:35:35.618676
655	cube 214	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:35:35.621045
656	pentagonal prism 184	red	{0,0,0}	32.482143	259.85715	920	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:35:35.623024
657	cylinder 166	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:35.624844
658	pentagonal prism 185	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:35.852949
659	cube 215	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:35.855602
660	cube 216	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:35.857794
661	cylinder 167	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:35.85979
662	hexagonal prism 45	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:35:36.100594
663	cube 217	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:35:36.10344
664	cuboid 59	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:36.106026
665	cylinder 168	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:36.10835
666	pentagonal prism 186	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:36.336047
667	cube 218	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.420776	cube.usd	2025-03-29 15:35:36.338741
668	cube 219	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:36.340824
669	cylinder 169	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:36.34273
670	hexagonal prism 46	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:36.571231
671	cube 220	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03624	cube.usd	2025-03-29 15:35:36.575113
672	pentagonal prism 187	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:36.577016
673	cylinder 170	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:35:36.578993
674	pentagonal prism 188	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:36.799358
675	cube 221	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:35:36.802983
676	cube 222	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	cube.usd	2025-03-29 15:35:36.804957
677	cylinder 171	green	{0,0,0}	-272.65317	217.53194	924	0	0	18.434948	cylinder.usd	2025-03-29 15:35:36.807395
678	pentagonal prism 189	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:37.025076
679	cube 223	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:37.028224
680	cube 224	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:35:37.030825
681	cylinder 172	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:37.033134
682	pentagonal prism 190	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:37.253406
683	cube 225	pink	{0,0,0}	-208.67317	346.4762	923.00006	0	0	59.420776	cube.usd	2025-03-29 15:35:37.256033
684	cuboid 60	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:37.258102
685	cylinder 173	green	{0,0,0}	-272.65317	217.53194	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:37.260115
686	pentagonal prism 191	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:37.490016
687	cube 226	pink	{0,0,0}	-206.70456	346.4762	931.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:37.492685
688	cuboid 61	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:37.494516
689	cylinder 174	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:37.496297
690	pentagonal prism 192	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:37.718787
691	cube 227	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:37.722878
692	pentagonal prism 193	red	{0,0,0}	31.497837	259.85715	919	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:35:37.724993
693	cylinder 175	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:35:37.727017
694	pentagonal prism 194	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:37.954282
695	cube 228	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:37.958124
696	cuboid 62	red	{0,0,0}	32.355774	258.8462	933	0	0	37.405357	cuboid.usd	2025-03-29 15:35:37.960005
697	cylinder 176	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:35:37.962031
698	pentagonal prism 195	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:38.186548
699	cube 229	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.93142	cube.usd	2025-03-29 15:35:38.19035
700	pentagonal prism 196	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:38.192744
701	cylinder 177	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:38.194752
702	pentagonal prism 197	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:38.432511
703	cube 230	pink	{0,0,0}	-206.70456	346.4762	911.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:38.436035
704	cylinder 179	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.874985	cylinder.usd	2025-03-29 15:35:38.438122
705	cylinder 180	green	{0,0,0}	-271.66885	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:38.440224
706	pentagonal prism 198	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:38.650827
707	cube 231	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:35:38.653167
708	cube 232	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cube.usd	2025-03-29 15:35:38.655133
709	cylinder 181	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:38.657019
710	pentagonal prism 199	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:38.87343
711	cube 233	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.62088	cube.usd	2025-03-29 15:35:38.876662
712	pentagonal prism 200	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:38.878586
713	cylinder 182	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:38.880684
714	hexagonal prism 47	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:39.105177
715	cube 234	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:35:39.108957
716	cuboid 63	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:35:39.110902
717	cylinder 183	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:39.112906
718	pentagonal prism 201	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:39.330655
719	cube 235	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:39.333453
720	cuboid 64	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:35:39.335411
721	cylinder 184	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:39.337344
722	pentagonal prism 202	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:39.556486
723	cube 236	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:39.560189
724	cube 237	red	{0,0,0}	32.482143	259.85715	919	0	0	37.874985	cube.usd	2025-03-29 15:35:39.562477
725	cylinder 185	green	{0,0,0}	-271.66885	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:35:39.56476
726	pentagonal prism 203	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:39.785847
727	cube 238	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:39.789748
728	cube 239	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:35:39.791834
729	cylinder 186	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:39.793854
730	pentagonal prism 204	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:40.00763
731	cube 240	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.62088	cube.usd	2025-03-29 15:35:40.010683
732	cube 241	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:35:40.012776
733	cylinder 187	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:40.014725
734	hexagonal prism 48	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:35:40.235729
735	cube 242	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:40.239878
736	cuboid 65	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:40.242617
737	cylinder 188	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:40.245054
738	pentagonal prism 205	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:40.45787
739	cube 243	pink	{0,0,0}	-206.70456	346.4762	916.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:40.460343
740	cuboid 66	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:40.462247
741	cylinder 189	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:40.464038
742	pentagonal prism 206	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:40.691447
743	cube 244	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:40.695631
744	cuboid 67	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	cuboid.usd	2025-03-29 15:35:40.697727
745	cylinder 190	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:40.699949
746	pentagonal prism 207	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:40.929078
747	cube 245	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:35:40.931454
748	pentagonal prism 208	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:40.933468
749	cylinder 191	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:40.935513
750	pentagonal prism 209	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:41.153661
751	cube 246	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:41.157655
752	cube 247	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	cube.usd	2025-03-29 15:35:41.159982
753	cylinder 192	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:41.162306
754	pentagonal prism 210	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:41.391492
755	cube 248	pink	{0,0,0}	-207.68886	346.4762	913.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:41.394436
756	cube 249	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.405357	cube.usd	2025-03-29 15:35:41.396417
757	cylinder 193	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:41.398306
758	pentagonal prism 211	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:41.626584
759	cube 250	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.62088	cube.usd	2025-03-29 15:35:41.630398
760	cuboid 68	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cuboid.usd	2025-03-29 15:35:41.632352
761	cylinder 194	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:35:41.634651
762	hexagonal prism 49	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	hexagonal prism.usd	2025-03-29 15:35:41.856456
763	cube 251	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.620872	cube.usd	2025-03-29 15:35:41.860349
764	cuboid 69	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:41.862492
765	cylinder 195	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:41.86458
766	pentagonal prism 212	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:42.097573
767	cube 252	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:42.100799
768	cuboid 70	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:35:42.103192
769	cylinder 196	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:42.105486
770	pentagonal prism 213	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:42.322583
771	cube 253	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:42.326917
772	cuboid 71	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:42.329008
773	cylinder 197	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:42.331077
774	pentagonal prism 214	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:42.558212
775	cube 254	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:35:42.562327
776	cube 255	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:35:42.564336
777	cylinder 198	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:42.566418
778	pentagonal prism 215	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:42.778033
779	cube 256	pink	{0,0,0}	-206.70456	346.4762	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:42.780806
780	cube 257	red	{0,0,0}	32.482143	259.85715	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:42.782967
781	cylinder 199	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:42.785084
782	pentagonal prism 216	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:43.010995
783	cube 258	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:35:43.014553
784	cube 259	red	{0,0,0}	32.355774	258.8462	929	0	0	36.869892	cube.usd	2025-03-29 15:35:43.016489
785	cylinder 200	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:43.018835
786	hexagonal prism 50	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:35:43.243624
787	cube 260	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:43.247623
788	pentagonal prism 217	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:43.249576
789	cylinder 201	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:43.25213
790	pentagonal prism 218	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:43.47876
791	cube 261	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:35:43.482326
792	pentagonal prism 219	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:35:43.484147
793	cylinder 202	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:43.486412
794	pentagonal prism 220	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:43.708276
795	cube 262	pink	{0,0,0}	-206.70456	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:43.712394
796	pentagonal prism 221	red	{0,0,0}	32.482143	259.85715	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:43.714699
797	cylinder 203	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:43.716791
798	pentagonal prism 222	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:43.941995
799	cube 263	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:43.945997
800	cuboid 72	red	{0,0,0}	32.355774	258.8462	919	0	0	37.874985	cuboid.usd	2025-03-29 15:35:43.948011
801	cylinder 204	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:43.950053
802	pentagonal prism 223	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:44.177659
803	cube 264	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:44.181566
804	pentagonal prism 224	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:44.183465
805	cylinder 205	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:44.185695
806	pentagonal prism 225	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:44.419589
807	cube 265	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:44.423214
808	cuboid 73	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:44.425246
809	cylinder 206	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:44.427301
810	hexagonal prism 51	black	{0,0,0}	-129.44986	522.7403	656	0	0	0	hexagonal prism.usd	2025-03-29 15:35:44.643989
811	cube 266	pink	{0,0,0}	-208.50322	347.83475	931.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:44.648113
812	pentagonal prism 226	red	{0,0,0}	31.621342	260.87607	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:44.650128
813	cylinder 207	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:44.652471
814	pentagonal prism 227	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:44.877697
815	cube 267	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:44.881674
816	cube 268	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:35:44.883976
817	cylinder 208	green	{0,0,0}	-272.65317	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:44.886165
818	pentagonal prism 228	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:45.112199
819	cube 269	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:35:45.114654
820	cuboid 74	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:35:45.116612
821	cylinder 209	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:45.118474
822	pentagonal prism 229	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:45.344673
823	cube 270	pink	{0,0,0}	-208.67317	346.4762	919	0	0	59.93142	cube.usd	2025-03-29 15:35:45.347404
824	cube 271	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:45.349557
825	cylinder 210	green	{0,0,0}	-272.65317	217.53194	934	0	0	36.869896	cylinder.usd	2025-03-29 15:35:45.351585
826	hexagonal prism 52	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:35:45.580705
827	cube 272	pink	{0,0,0}	-208.50322	347.83475	927.00006	0	0	59.62088	cube.usd	2025-03-29 15:35:45.583081
828	cube 273	red	{0,0,0}	31.621342	260.87607	929	0	0	37.568592	cube.usd	2025-03-29 15:35:45.585298
829	cylinder 211	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:45.587849
830	pentagonal prism 230	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:45.811418
831	cube 274	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:35:45.814334
832	cuboid 75	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:45.816365
833	cylinder 212	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:45.818554
834	pentagonal prism 231	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:46.042424
835	cube 275	pink	{0,0,0}	-207.68886	346.4762	911.00006	0	0	59.420776	cube.usd	2025-03-29 15:35:46.045384
836	cube 276	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.647617	cube.usd	2025-03-29 15:35:46.047779
837	cylinder 213	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:46.049842
838	pentagonal prism 232	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:46.282329
839	cube 277	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:46.286478
840	cuboid 76	red	{0,0,0}	32.355774	258.8462	924	0	0	37.69424	cuboid.usd	2025-03-29 15:35:46.288623
841	cylinder 214	green	{0,0,0}	-270.6119	216.68562	933	0	0	18.434948	cylinder.usd	2025-03-29 15:35:46.290705
842	pentagonal prism 233	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:46.508091
843	cube 278	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:46.512125
844	cube 279	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.69424	cube.usd	2025-03-29 15:35:46.514917
845	cylinder 215	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:46.517157
846	pentagonal prism 234	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:46.745015
847	cube 280	pink	{0,0,0}	-206.70456	346.4762	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:46.748908
848	cuboid 77	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:35:46.750779
849	cylinder 216	green	{0,0,0}	-271.66885	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:35:46.752837
850	pentagonal prism 235	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:46.977145
851	cube 281	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:46.979578
852	cube 282	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.874985	cube.usd	2025-03-29 15:35:46.98172
853	cylinder 217	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:35:46.983742
854	hexagonal prism 53	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	hexagonal prism.usd	2025-03-29 15:35:47.196868
855	cube 283	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.743565	cube.usd	2025-03-29 15:35:47.200128
856	cuboid 78	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	cuboid.usd	2025-03-29 15:35:47.202131
857	cylinder 218	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:47.204437
858	pentagonal prism 236	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:47.424004
859	cube 284	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03624	cube.usd	2025-03-29 15:35:47.42784
860	cuboid 79	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:47.429998
861	cylinder 219	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:35:47.432552
862	pentagonal prism 237	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:47.645259
863	cube 285	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.743565	cube.usd	2025-03-29 15:35:47.648011
864	cube 286	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:35:47.65001
865	cylinder 220	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:47.651988
866	pentagonal prism 238	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:47.884855
867	cube 287	pink	{0,0,0}	-207.68886	346.4762	907.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:47.888804
868	cube 288	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.874985	cube.usd	2025-03-29 15:35:47.890926
869	cylinder 221	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:47.893004
870	pentagonal prism 239	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:48.114501
871	cube 289	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:48.11754
872	pentagonal prism 240	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:48.119694
873	cylinder 222	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:48.121762
874	pentagonal prism 241	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:48.347017
875	cube 290	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:35:48.35099
876	cuboid 80	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:48.353032
877	cylinder 223	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:35:48.355028
878	pentagonal prism 242	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:48.578169
879	cube 291	pink	{0,0,0}	-208.67317	346.4762	936.00006	0	0	59.420776	cube.usd	2025-03-29 15:35:48.581598
880	hexagonal prism 54	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:35:48.583608
881	cylinder 224	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:48.58562
882	hexagonal prism 55	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:48.797331
883	cube 292	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:48.800243
884	cuboid 81	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:48.802243
885	cylinder 225	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:35:48.804386
886	pentagonal prism 243	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:49.030195
887	cube 293	pink	{0,0,0}	-207.68886	346.4762	931.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:49.033751
888	cuboid 82	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:35:49.035674
889	cylinder 226	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:49.037616
890	pentagonal prism 244	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:49.268669
891	cube 294	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:49.272406
892	cube 295	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:49.274587
893	cylinder 227	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:49.276559
894	pentagonal prism 245	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:49.49994
895	cube 296	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:49.502455
896	cube 297	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:35:49.504385
897	cylinder 228	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:49.506269
898	hexagonal prism 56	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:49.73085
899	cube 298	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.62088	cube.usd	2025-03-29 15:35:49.733148
900	cuboid 83	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:49.735162
901	cylinder 229	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:49.737036
902	pentagonal prism 246	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:49.969223
903	cube 299	pink	{0,0,0}	-206.88084	345.12823	931.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:49.973407
904	cuboid 84	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:49.975668
905	cylinder 230	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:35:49.977792
906	pentagonal prism 247	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:50.1953
907	cube 300	pink	{0,0,0}	-207.68886	346.4762	915	0	0	59.743565	cube.usd	2025-03-29 15:35:50.199247
908	cuboid 85	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:50.201577
909	cylinder 231	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:50.203688
910	hexagonal prism 57	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:50.416889
911	cube 301	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:50.419282
912	pentagonal prism 248	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:50.421163
913	cylinder 232	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:50.423038
914	hexagonal prism 58	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:50.648399
915	cube 302	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 15:35:50.652076
916	cuboid 86	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:35:50.654107
917	cylinder 233	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:50.656158
918	pentagonal prism 249	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:50.884964
919	cube 303	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:50.888752
920	cuboid 87	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:50.891048
921	cylinder 234	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:50.893077
922	pentagonal prism 250	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:51.118593
923	cube 304	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.620872	cube.usd	2025-03-29 15:35:51.121795
924	cuboid 88	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:35:51.123907
925	cylinder 235	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:51.126173
926	pentagonal prism 251	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:51.351587
927	cube 305	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:51.355254
928	cuboid 89	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:35:51.357201
929	cylinder 236	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:51.359367
930	pentagonal prism 252	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:51.585095
931	cube 306	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 15:35:51.588741
932	cube 307	red	{0,0,0}	31.497837	259.85715	929	0	0	37.405357	cube.usd	2025-03-29 15:35:51.59077
933	cylinder 237	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:35:51.592969
934	pentagonal prism 253	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:51.827614
935	cube 308	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:51.83124
936	hexagonal prism 59	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:35:51.83338
937	cylinder 238	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:51.83642
938	hexagonal prism 60	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:52.063512
939	cube 309	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:52.067686
940	cuboid 90	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:52.070263
941	cylinder 239	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	33.690067	cylinder.usd	2025-03-29 15:35:52.07237
942	pentagonal prism 254	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:52.297129
943	cube 310	pink	{0,0,0}	-206.70456	346.4762	928.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:52.29988
944	cuboid 91	red	{0,0,0}	32.482143	259.85715	934	0	0	37.568592	cuboid.usd	2025-03-29 15:35:52.301918
945	cylinder 240	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:52.304275
946	pentagonal prism 255	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:52.517487
947	cube 311	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:35:52.520661
948	cube 312	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:52.522818
949	cylinder 241	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:35:52.524812
950	hexagonal prism 61	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:35:52.752693
951	cube 313	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.93142	cube.usd	2025-03-29 15:35:52.756422
952	pentagonal prism 256	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:52.758335
953	cylinder 242	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:52.760695
954	pentagonal prism 257	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:52.987144
955	cube 314	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:35:52.990757
956	cuboid 92	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	cuboid.usd	2025-03-29 15:35:52.992803
957	cylinder 243	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:52.994838
958	pentagonal prism 258	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:53.218036
959	cube 315	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:35:53.222428
960	cuboid 93	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:35:53.225022
961	cylinder 244	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:53.227287
962	pentagonal prism 259	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:53.450734
963	cube 316	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:53.453558
964	cuboid 94	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:53.455549
965	cylinder 245	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:53.45743
966	pentagonal prism 260	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:53.682059
967	cube 317	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:35:53.684893
968	cuboid 95	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:53.687458
969	cylinder 246	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:53.689612
970	hexagonal prism 62	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:35:53.916901
971	cube 318	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:35:53.920848
972	cube 319	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cube.usd	2025-03-29 15:35:53.922908
973	cylinder 247	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:35:53.925042
974	pentagonal prism 261	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:54.151273
975	cube 320	pink	{0,0,0}	-207.68886	346.4762	905.00006	0	0	59.03624	cube.usd	2025-03-29 15:35:54.155244
976	cuboid 96	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:54.157322
977	cylinder 248	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:54.159374
978	pentagonal prism 262	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:54.381064
979	cube 321	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:35:54.384487
980	hexagonal prism 63	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:35:54.386474
981	cylinder 249	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:54.388737
982	pentagonal prism 263	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:54.601822
983	cube 322	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03624	cube.usd	2025-03-29 15:35:54.604798
984	cuboid 97	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:35:54.606901
985	cylinder 250	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:54.608927
986	pentagonal prism 264	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:54.834705
987	cube 323	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:54.838928
988	cube 324	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:54.84099
989	cylinder 251	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:54.843453
990	pentagonal prism 265	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:55.069472
991	cube 325	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:35:55.072862
992	cube 326	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:35:55.075233
993	cylinder 252	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:35:55.077677
994	pentagonal prism 266	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:55.290195
995	cube 327	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:35:55.293238
996	pentagonal prism 267	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:55.295408
997	cylinder 253	green	{0,0,0}	-270.6119	216.68562	919	0	0	18.434948	cylinder.usd	2025-03-29 15:35:55.297404
998	pentagonal prism 268	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:55.526735
999	cube 328	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:35:55.531532
1000	pentagonal prism 269	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:35:55.534558
1001	cylinder 254	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:55.538073
1002	pentagonal prism 270	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:55.7679
1003	cube 329	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:35:55.770524
1004	hexagonal prism 64	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:35:55.772744
1005	cylinder 255	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:55.774678
1006	pentagonal prism 271	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:55.999797
1007	cube 330	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:56.002192
1008	cuboid 98	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:56.004305
1009	cylinder 256	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:56.006415
1010	hexagonal prism 65	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:56.218992
1011	cube 331	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:56.221732
1012	cuboid 99	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:35:56.224151
1013	cylinder 257	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:56.226201
1014	pentagonal prism 272	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:56.456856
1015	cube 332	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.03625	cube.usd	2025-03-29 15:35:56.46069
1016	cube 333	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:35:56.46277
1017	cylinder 258	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:56.464748
1018	pentagonal prism 273	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:56.692228
1019	cube 334	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:56.696295
1020	cuboid 100	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:56.698199
1021	cylinder 259	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:35:56.700261
1022	pentagonal prism 274	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:56.920125
1023	cube 335	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:56.924244
1024	cuboid 101	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:56.926367
1025	cylinder 260	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:56.928621
1026	pentagonal prism 275	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:57.163605
1027	cube 336	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:35:57.167287
1028	pentagonal prism 276	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:57.169256
1029	cylinder 261	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:57.171958
1030	pentagonal prism 277	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:35:57.387362
1031	cube 337	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:57.390515
1032	cube 338	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:35:57.392649
1033	cylinder 262	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:57.394709
1034	hexagonal prism 66	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:35:57.623198
1035	cube 339	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:35:57.625858
1036	cuboid 102	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:35:57.628029
1037	cylinder 263	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:57.630353
1038	pentagonal prism 278	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:57.845307
1039	cube 340	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:35:57.848277
1040	pentagonal prism 279	red	{0,0,0}	32.355774	258.8462	920	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:35:57.85037
1041	cylinder 264	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:57.852346
1042	pentagonal prism 280	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:35:58.071735
1043	cube 341	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.743565	cube.usd	2025-03-29 15:35:58.075753
1044	cuboid 103	red	{0,0,0}	31.497837	259.85715	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:35:58.077849
1045	cylinder 265	green	{0,0,0}	-272.65317	217.53194	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:58.080029
1046	pentagonal prism 281	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:35:58.307803
1047	cube 342	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:58.311403
1048	cube 343	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:58.313497
1049	cylinder 266	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:58.315562
1050	pentagonal prism 282	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:58.541188
1051	cube 344	pink	{0,0,0}	-206.70456	346.4762	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:58.543702
1052	cuboid 104	red	{0,0,0}	32.482143	259.85715	929	0	0	37.647617	cuboid.usd	2025-03-29 15:35:58.545552
1053	cylinder 267	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:58.547876
1054	pentagonal prism 283	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:58.768093
1055	cube 345	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:35:58.772201
1056	pentagonal prism 284	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:58.7743
1057	cylinder 268	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:35:58.776431
1058	pentagonal prism 285	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:58.989684
1059	cube 346	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:35:58.993093
1060	cube 347	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:35:58.994975
1061	cylinder 269	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:58.997074
1062	hexagonal prism 67	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	hexagonal prism.usd	2025-03-29 15:35:59.236902
1063	cube 348	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:59.239481
1064	cuboid 105	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:35:59.242135
1065	cylinder 270	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:59.244252
1066	pentagonal prism 286	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:35:59.469897
1067	cube 349	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:35:59.474261
1068	cuboid 106	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:35:59.476568
1069	cylinder 271	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:35:59.479036
1070	pentagonal prism 287	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:35:59.70502
1071	cube 350	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:59.707689
1072	cube 351	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	cube.usd	2025-03-29 15:35:59.710363
1073	cylinder 272	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:35:59.712545
1074	pentagonal prism 288	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:35:59.934186
1075	cube 352	pink	{0,0,0}	-208.67317	346.4762	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:35:59.938341
1076	pentagonal prism 289	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:35:59.940278
1077	cylinder 273	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:35:59.942871
1078	hexagonal prism 68	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:36:00.15779
1079	cube 353	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:00.160329
1080	cuboid 107	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:36:00.1622
1081	cylinder 274	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:36:00.16418
1082	pentagonal prism 290	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:00.389144
1083	cube 354	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:00.391891
1084	cuboid 108	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:00.393955
1085	cylinder 275	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:00.395986
1086	pentagonal prism 291	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:00.623695
1087	cube 355	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:00.627551
1088	pentagonal prism 292	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:00.629559
1089	cylinder 276	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:00.631582
1090	hexagonal prism 69	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:36:00.856125
1091	cube 356	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 15:36:00.859951
1092	cube 357	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.405357	cube.usd	2025-03-29 15:36:00.861947
1093	cylinder 277	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	38.65981	cylinder.usd	2025-03-29 15:36:00.864037
1094	pentagonal prism 293	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal prism.usd	2025-03-29 15:36:01.098703
1095	cube 358	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:01.102914
1096	pentagonal prism 294	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:36:01.105262
1097	cylinder 278	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:36:01.107459
1098	pentagonal prism 295	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:01.319498
1099	cube 359	pink	{0,0,0}	-206.70456	346.4762	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:01.323148
1100	cuboid 109	red	{0,0,0}	32.482143	259.85715	927.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:36:01.325472
1101	cylinder 279	green	{0,0,0}	-271.66885	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:36:01.328583
1102	pentagonal prism 296	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:01.548704
1103	cube 360	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:36:01.551447
1104	cuboid 110	red	{0,0,0}	31.497837	259.85715	931.00006	0	0	36.869896	cuboid.usd	2025-03-29 15:36:01.553564
1105	cylinder 280	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:01.555681
1106	hexagonal prism 70	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:36:01.773783
1107	cube 361	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:01.776556
1108	cuboid 111	red	{0,0,0}	32.355774	258.8462	920	0	0	37.69424	cuboid.usd	2025-03-29 15:36:01.778696
1109	cylinder 281	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:01.78069
1110	pentagonal prism 297	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal prism.usd	2025-03-29 15:36:02.008317
1111	cube 362	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:36:02.012274
1112	hexagonal prism 71	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 15:36:02.014404
1113	cylinder 282	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:36:02.016647
1114	pentagonal prism 298	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:02.240957
1115	cube 363	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:02.244894
1116	hexagonal prism 72	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:36:02.246962
1117	cylinder 283	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:02.249133
1118	pentagonal prism 299	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:02.47732
1119	cube 364	pink	{0,0,0}	-205.90038	345.12823	946.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:02.48094
1120	cuboid 112	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:36:02.482931
1121	cylinder 284	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:36:02.485122
1122	pentagonal prism 300	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:02.706005
1123	cube 365	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:02.709826
1124	cuboid 113	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:02.712322
1125	cylinder 285	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:36:02.714504
1126	hexagonal prism 73	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:36:02.942356
1127	cube 366	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:02.945898
1128	cube 367	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:36:02.947879
1129	cylinder 286	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:02.949966
1130	hexagonal prism 74	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:36:03.182278
1131	cube 368	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.62088	cube.usd	2025-03-29 15:36:03.185089
1132	cube 369	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.647617	cube.usd	2025-03-29 15:36:03.187147
1133	cylinder 287	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:36:03.189126
1134	hexagonal prism 75	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:36:03.408078
1135	cube 370	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.93142	cube.usd	2025-03-29 15:36:03.410583
1136	hexagonal prism 76	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:36:03.412716
1137	cylinder 288	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:03.414649
1138	pentagonal prism 301	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:03.639506
1139	cube 371	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:03.642979
1140	cube 372	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:36:03.645037
1141	cylinder 289	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:36:03.647217
1142	pentagonal prism 302	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:03.864363
1143	cube 373	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:03.868157
1144	cuboid 114	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:36:03.870245
1145	cylinder 290	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:03.872241
1146	hexagonal prism 77	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:36:04.091156
1147	cube 374	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:36:04.094071
1148	cube 375	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	cube.usd	2025-03-29 15:36:04.096582
1149	cylinder 291	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:36:04.098655
1150	pentagonal prism 303	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:04.328681
1151	cube 376	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:36:04.332577
1152	cuboid 115	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:04.334663
1153	cylinder 292	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:36:04.336888
1154	pentagonal prism 304	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:36:04.583597
1155	cube 377	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:04.586325
1156	cube 378	red	{0,0,0}	31.497837	259.85715	931.00006	0	0	37.568592	cube.usd	2025-03-29 15:36:04.588328
1157	cylinder 293	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:04.590571
1158	pentagonal prism 305	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:04.815017
1159	cube 379	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:36:04.819238
1160	pentagonal prism 306	red	{0,0,0}	32.482143	259.85715	931.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:36:04.821632
1161	cylinder 294	green	{0,0,0}	-271.66885	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:36:04.823993
1162	hexagonal prism 78	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:36:05.044363
1163	cube 380	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.743565	cube.usd	2025-03-29 15:36:05.048377
1164	pentagonal prism 307	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:36:05.050401
1165	cylinder 295	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:05.052693
1166	pentagonal prism 308	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:05.271032
1167	cube 381	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:05.274713
1168	cuboid 116	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:05.276848
1169	cylinder 296	green	{0,0,0}	-272.65317	217.53194	913.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:05.279288
1170	pentagonal prism 309	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:05.491257
1171	cube 382	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:36:05.494098
1172	cube 383	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cube.usd	2025-03-29 15:36:05.496344
1173	cylinder 297	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:05.498282
1174	pentagonal prism 310	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:05.717531
1175	cube 384	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:36:05.721968
1176	cuboid 117	red	{0,0,0}	32.355774	258.8462	929	0	0	37.69424	cuboid.usd	2025-03-29 15:36:05.723936
1177	cylinder 298	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:36:05.726006
1178	pentagonal prism 311	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:36:05.937326
1179	cube 385	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.420776	cube.usd	2025-03-29 15:36:05.939904
1180	pentagonal prism 312	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:05.941964
1181	cylinder 299	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:05.94379
1182	pentagonal prism 313	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:06.158357
1183	cube 386	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:36:06.161875
1184	cuboid 118	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:36:06.164125
1185	cylinder 300	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:36:06.166421
1186	pentagonal prism 314	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:06.397752
1187	cube 387	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.03625	cube.usd	2025-03-29 15:36:06.40023
1188	pentagonal prism 315	red	{0,0,0}	31.499039	259.86707	914.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:06.402156
1189	cylinder 301	green	{0,0,0}	-272.66354	217.54024	920	0	0	39.80557	cylinder.usd	2025-03-29 15:36:06.404309
1190	pentagonal prism 316	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 15:36:06.62453
1191	cube 388	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:36:06.629322
1192	cuboid 119	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:36:06.631975
1193	cylinder 302	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:06.634032
1194	pentagonal prism 317	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:36:06.845504
1195	cube 389	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.93142	cube.usd	2025-03-29 15:36:06.848699
1196	cube 390	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	cube.usd	2025-03-29 15:36:06.850769
1197	cylinder 303	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:06.852686
1198	hexagonal prism 79	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:36:07.076141
1199	cube 391	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:07.080227
1200	cube 392	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	cube.usd	2025-03-29 15:36:07.082735
1201	cylinder 304	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:36:07.084683
1202	pentagonal prism 318	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:07.298495
1203	cube 393	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:07.301209
1204	cuboid 120	red	{0,0,0}	32.355774	258.8462	920	0	0	37.746803	cuboid.usd	2025-03-29 15:36:07.303681
1205	cylinder 305	green	{0,0,0}	-270.6119	216.68562	938	0	0	26.56505	cylinder.usd	2025-03-29 15:36:07.305776
1206	pentagonal prism 319	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:07.521875
1207	cube 394	pink	{0,0,0}	-208.67317	346.4762	932.00006	0	0	59.743565	cube.usd	2025-03-29 15:36:07.526303
1208	cuboid 121	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:36:07.528253
1209	cylinder 306	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:07.530108
1210	pentagonal prism 320	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:36:07.75079
1211	cube 395	pink	{0,0,0}	-206.88084	345.12823	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:07.753863
1212	pentagonal prism 321	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:36:07.75587
1213	cylinder 307	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:07.75779
1214	pentagonal prism 322	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:07.979584
1215	cube 396	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:07.983214
1216	pentagonal prism 323	red	{0,0,0}	32.355774	258.8462	940.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:07.985325
1217	cylinder 308	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:07.987518
1218	pentagonal prism 324	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:08.208597
1219	cube 397	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:08.211068
1220	hexagonal prism 81	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:36:08.21327
1221	cylinder 309	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:08.215358
1222	pentagonal prism 325	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:08.425321
1223	cube 398	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.743565	cube.usd	2025-03-29 15:36:08.428143
1224	cuboid 122	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:08.430384
1225	cylinder 310	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:08.432403
1226	pentagonal prism 326	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:08.654931
1227	cube 399	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:08.657356
1228	cuboid 123	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:36:08.659944
1229	cylinder 311	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:08.662759
1230	pentagonal prism 327	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:08.881465
1231	cube 400	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.34933	cube.usd	2025-03-29 15:36:08.884296
1232	hexagonal prism 82	red	{0,0,0}	32.355774	258.8462	920	0	0	37.69424	hexagonal prism.usd	2025-03-29 15:36:08.886558
1233	cylinder 312	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:08.888698
1234	pentagonal prism 328	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:09.109312
1235	cube 401	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:36:09.113445
1236	cuboid 124	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:36:09.115464
1237	cylinder 313	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:36:09.117906
1238	pentagonal prism 329	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:09.341743
1239	cube 402	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.620872	cube.usd	2025-03-29 15:36:09.344282
1240	cube 403	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:36:09.346281
1241	cylinder 314	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:36:09.348265
1242	pentagonal prism 330	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:09.56959
1243	cube 404	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:09.573522
1244	cuboid 125	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cuboid.usd	2025-03-29 15:36:09.575549
1245	cylinder 315	green	{0,0,0}	-272.65317	217.53194	912.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:09.577456
1246	pentagonal prism 331	black	{0,0,0}	-129.44986	522.7403	657	0	0	0	pentagonal prism.usd	2025-03-29 15:36:09.812819
1247	cube 405	pink	{0,0,0}	-208.50322	347.83475	926.00006	0	0	59.62088	cube.usd	2025-03-29 15:36:09.81691
1248	cuboid 126	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.23483	cuboid.usd	2025-03-29 15:36:09.819089
1249	cylinder 316	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:09.821374
1250	pentagonal prism 332	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:10.044853
1251	cube 406	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:10.047527
1252	cuboid 127	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:36:10.049618
1253	cylinder 317	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:10.052404
1254	pentagonal prism 333	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:10.267428
1255	cube 407	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.620872	cube.usd	2025-03-29 15:36:10.27068
1256	cuboid 128	red	{0,0,0}	31.497837	259.85715	929	0	0	37.746803	cuboid.usd	2025-03-29 15:36:10.273182
1257	cylinder 318	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:10.275937
1258	pentagonal prism 334	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:10.502596
1259	cube 408	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.34933	cube.usd	2025-03-29 15:36:10.504809
1260	pentagonal prism 335	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:36:10.506815
1261	cylinder 319	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:10.508747
1262	pentagonal prism 336	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:10.722649
1263	cube 409	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:36:10.726136
1264	hexagonal prism 83	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:36:10.728143
1265	cylinder 320	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:10.730204
1266	pentagonal prism 337	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:10.95366
1267	cube 410	pink	{0,0,0}	-206.70456	346.4762	917.00006	0	0	59.34933	cube.usd	2025-03-29 15:36:10.956084
1268	cuboid 129	red	{0,0,0}	32.482143	259.85715	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:10.958125
1269	cylinder 321	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:10.959962
1270	pentagonal prism 338	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:11.191695
1271	cube 411	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:36:11.195687
1272	cuboid 130	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:36:11.197611
1273	cylinder 322	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:11.199711
1274	pentagonal prism 339	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:36:11.411743
1275	cube 412	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:11.414912
1276	cuboid 131	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:36:11.416884
1277	cylinder 323	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:11.419574
1278	hexagonal prism 84	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:36:11.633946
1279	cube 413	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:36:11.637234
1280	pentagonal prism 340	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:11.63934
1281	cylinder 324	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:11.641421
1282	pentagonal prism 341	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:11.865843
1283	cube 414	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:11.869932
1284	cuboid 132	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:11.872006
1285	cylinder 325	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:11.87412
1286	pentagonal prism 342	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:12.102578
1287	cube 415	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:12.105661
1288	pentagonal prism 343	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:12.108169
1289	cylinder 326	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:12.11055
1290	pentagonal prism 344	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:12.32852
1291	cube 416	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:12.332335
1292	cube 417	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:36:12.334339
1293	cylinder 327	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:12.337606
1294	pentagonal prism 345	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:12.555104
1295	cube 418	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.420776	cube.usd	2025-03-29 15:36:12.558638
1296	pentagonal prism 346	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:36:12.561141
1297	cylinder 328	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:12.563102
1298	pentagonal prism 347	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:12.786831
1299	cube 419	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:36:12.789593
1300	cube 420	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:36:12.7918
1301	cylinder 329	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	38.659805	cylinder.usd	2025-03-29 15:36:12.794019
1302	hexagonal prism 85	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:36:13.018631
1303	cube 421	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:36:13.022496
1304	pentagonal prism 348	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:13.02465
1305	cylinder 330	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:13.026798
1306	pentagonal prism 349	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:13.251397
1307	cube 422	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:13.255138
1308	cuboid 133	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:13.257222
1309	cylinder 331	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:13.259429
1310	pentagonal prism 350	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:13.493979
1311	cube 423	pink	{0,0,0}	-206.70456	346.4762	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:13.49741
1312	pentagonal prism 351	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:36:13.499472
1313	cylinder 332	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:13.501478
1314	pentagonal prism 352	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:13.717777
1315	cube 424	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:13.720913
1316	cube 425	red	{0,0,0}	31.497837	259.85715	915	0	0	37.568592	cube.usd	2025-03-29 15:36:13.722912
1317	cylinder 333	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:36:13.724904
1318	pentagonal prism 353	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:13.944138
1319	cube 426	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:13.946437
1320	hexagonal prism 86	red	{0,0,0}	32.355774	258.8462	929	0	0	37.69424	hexagonal prism.usd	2025-03-29 15:36:13.948484
1321	cylinder 334	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:13.950484
1322	pentagonal prism 354	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:14.165094
1323	cube 427	pink	{0,0,0}	-207.68886	346.4762	933	0	0	59.743565	cube.usd	2025-03-29 15:36:14.167667
1324	pentagonal prism 355	red	{0,0,0}	31.497837	259.85715	933	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:14.169675
1325	cylinder 335	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:14.171817
1326	pentagonal prism 356	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:14.394632
1327	cube 428	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.743565	cube.usd	2025-03-29 15:36:14.398437
1328	cuboid 134	red	{0,0,0}	32.355774	258.8462	919	0	0	37.746803	cuboid.usd	2025-03-29 15:36:14.400703
1329	cylinder 336	green	{0,0,0}	-270.6119	216.68562	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:14.402896
1330	pentagonal prism 357	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:36:14.627659
1331	cube 429	pink	{0,0,0}	-205.90038	345.12823	908.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:14.631505
1332	pentagonal prism 358	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:14.633422
1333	cylinder 337	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:14.635707
1334	pentagonal prism 359	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:14.848847
1335	cube 430	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:36:14.8526
1336	cuboid 135	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:36:14.85505
1337	cylinder 338	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:14.857294
1338	pentagonal prism 360	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:15.081273
1339	cube 431	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:15.084865
1340	pentagonal prism 361	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:36:15.086732
1341	cylinder 339	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:36:15.089045
1342	pentagonal prism 362	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:15.309851
1343	cube 432	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:15.3121
1344	cuboid 136	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:36:15.314245
1345	cylinder 340	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:15.316339
1346	pentagonal prism 363	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:15.547163
1347	cube 433	pink	{0,0,0}	-207.68886	346.4762	912.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:15.551147
1348	pentagonal prism 364	red	{0,0,0}	32.482143	259.85715	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:15.553463
1349	cylinder 341	green	{0,0,0}	-271.66885	217.53194	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:15.555986
1350	pentagonal prism 365	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:15.76969
1351	cube 434	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.620872	cube.usd	2025-03-29 15:36:15.772261
1352	pentagonal prism 366	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:36:15.775312
1353	cylinder 342	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:15.778463
1354	pentagonal prism 367	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:16.051498
1355	cube 435	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:16.054529
1356	pentagonal prism 368	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:16.056589
1357	cylinder 343	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:36:16.059379
1358	pentagonal prism 369	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:36:16.285522
1359	cube 436	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:16.289775
1360	cylinder 344	red	{0,0,0}	32.355774	258.8462	920	0	0	37.647617	cylinder.usd	2025-03-29 15:36:16.291959
1361	cylinder 345	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:16.294235
1362	pentagonal prism 370	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:16.517327
1363	cube 437	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.34933	cube.usd	2025-03-29 15:36:16.521091
1364	cuboid 137	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:36:16.523347
1365	cylinder 346	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:16.52541
1366	pentagonal prism 371	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:16.752629
1367	cube 438	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:16.755398
1368	pentagonal prism 372	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:16.757724
1369	cylinder 347	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:16.760087
1370	pentagonal prism 373	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:16.988011
1371	cube 439	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:36:16.992295
1372	cuboid 138	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:36:16.99511
1373	cylinder 348	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:36:16.997815
1374	hexagonal prism 87	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:36:17.256248
1375	cube 440	pink	{0,0,0}	-208.67317	346.4762	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:17.259669
1376	pentagonal prism 374	red	{0,0,0}	31.497837	259.85715	932.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:17.263222
1377	cylinder 349	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:17.266793
1378	hexagonal prism 88	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:36:17.49088
1379	cube 441	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.420776	cube.usd	2025-03-29 15:36:17.494752
1380	cuboid 139	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:36:17.496751
1381	cylinder 350	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:17.498666
1382	pentagonal prism 375	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:17.712335
1383	cube 442	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.743565	cube.usd	2025-03-29 15:36:17.71631
1384	pentagonal prism 376	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:17.718418
1385	cylinder 351	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:17.720628
1386	pentagonal prism 377	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:17.94706
1387	cube 443	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:17.951714
1388	cuboid 140	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:36:17.953774
1389	cylinder 352	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:17.956608
1390	pentagonal prism 378	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:18.16898
1391	cube 444	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.743565	cube.usd	2025-03-29 15:36:18.171398
1392	cuboid 141	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:18.173563
1393	cylinder 353	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:18.175726
1394	pentagonal prism 379	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:18.397485
1395	cube 445	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.93142	cube.usd	2025-03-29 15:36:18.399844
1396	cuboid 142	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:36:18.401763
1397	cylinder 354	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:36:18.403637
1398	pentagonal prism 380	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:18.629667
1399	cube 446	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:36:18.633338
1400	cube 447	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.647617	cube.usd	2025-03-29 15:36:18.635332
1401	cylinder 355	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 15:36:18.63749
1402	pentagonal prism 381	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:18.862947
1403	cube 448	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:18.866877
1404	cuboid 143	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:36:18.869104
1405	cylinder 356	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:18.87121
1406	pentagonal prism 382	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:19.086739
1407	cube 449	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 15:36:19.089554
1408	cuboid 144	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:36:19.091705
1409	cylinder 357	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:19.09428
1410	pentagonal prism 383	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:19.319649
1411	cube 450	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:36:19.32313
1412	hexagonal prism 89	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:36:19.325316
1413	cylinder 358	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:19.327581
1414	pentagonal prism 384	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:19.553799
1415	cube 451	pink	{0,0,0}	-208.50322	347.83475	913.00006	0	0	59.03624	cube.usd	2025-03-29 15:36:19.556489
1416	cuboid 145	red	{0,0,0}	31.621342	260.87607	924	0	0	37.568592	cuboid.usd	2025-03-29 15:36:19.558704
1417	cylinder 359	green	{0,0,0}	-273.72223	218.38489	920	0	0	18.434948	cylinder.usd	2025-03-29 15:36:19.5608
1418	hexagonal prism 90	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	hexagonal prism.usd	2025-03-29 15:36:19.77342
1419	cube 452	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.62088	cube.usd	2025-03-29 15:36:19.776741
1420	cuboid 146	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:36:19.778842
1421	cylinder 360	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:36:19.781199
1422	pentagonal prism 385	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:20.012009
1423	cube 453	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.34933	cube.usd	2025-03-29 15:36:20.015824
1424	pentagonal prism 386	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:36:20.017718
1425	cylinder 361	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:36:20.01965
1426	pentagonal prism 387	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:20.245667
1427	cube 454	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:36:20.249561
1428	cube 455	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:36:20.251877
1429	cylinder 362	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:20.253893
1430	pentagonal prism 388	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:20.47393
1431	cube 456	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:20.476461
1432	cube 457	red	{0,0,0}	32.355774	258.8462	920	0	0	37.647617	cube.usd	2025-03-29 15:36:20.478703
1433	cylinder 363	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:20.480682
1434	hexagonal prism 91	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:36:20.705468
1435	cube 458	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:36:20.709256
1436	cuboid 147	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:20.711745
1437	cylinder 364	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:36:20.714127
1438	pentagonal prism 389	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:20.953075
1439	cube 459	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:36:20.955406
1440	cuboid 148	red	{0,0,0}	32.355774	258.8462	920	0	0	37.647617	cuboid.usd	2025-03-29 15:36:20.957359
1441	cylinder 365	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:20.959639
1442	pentagonal prism 390	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:21.179841
1443	cube 460	pink	{0,0,0}	-206.88084	345.12823	939.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:21.182625
1444	cuboid 149	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:21.184627
1445	cylinder 366	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:21.186587
1446	pentagonal prism 391	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:21.423118
1447	cube 461	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:21.427095
1448	pentagonal prism 392	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:21.429327
1449	cylinder 367	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:36:21.431351
1450	hexagonal prism 92	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:36:21.660007
1451	cube 462	pink	{0,0,0}	-206.70456	346.4762	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:21.663766
1452	cuboid 150	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:21.66597
1453	cylinder 368	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:21.66803
1454	pentagonal prism 393	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:21.890392
1455	cube 463	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:36:21.894173
1456	cuboid 151	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:36:21.896278
1457	cylinder 369	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:21.898519
1458	hexagonal prism 93	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:36:22.1259
1459	cube 464	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:22.1298
1460	pentagonal prism 394	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:36:22.13193
1461	cylinder 370	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:22.134236
1462	pentagonal prism 395	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:22.357466
1463	cube 465	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:22.361435
1464	cube 466	red	{0,0,0}	32.482143	259.85715	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:36:22.363745
1465	cylinder 371	green	{0,0,0}	-271.66885	217.53194	924	0	0	33.690063	cylinder.usd	2025-03-29 15:36:22.366065
1466	pentagonal prism 396	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:22.590914
1467	cube 467	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:22.594876
1468	cuboid 152	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:22.597125
1469	cylinder 372	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:22.600257
1470	hexagonal prism 94	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:36:22.820314
1471	cube 468	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:22.823613
1472	cube 469	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.746803	cube.usd	2025-03-29 15:36:22.825649
1473	cylinder 373	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:22.827756
1474	pentagonal prism 397	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:23.045051
1475	cube 470	pink	{0,0,0}	-208.67317	346.4762	928.00006	0	0	59.420776	cube.usd	2025-03-29 15:36:23.048296
1476	cube 471	red	{0,0,0}	31.497837	259.85715	915	0	0	37.568592	cube.usd	2025-03-29 15:36:23.050267
1477	cylinder 374	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	38.65981	cylinder.usd	2025-03-29 15:36:23.052147
1478	pentagonal prism 398	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:23.27984
1479	cube 472	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:23.284065
1480	cube 473	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:36:23.2866
1481	cylinder 375	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:36:23.290104
1482	hexagonal prism 95	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	hexagonal prism.usd	2025-03-29 15:36:23.509672
1483	cube 474	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.620872	cube.usd	2025-03-29 15:36:23.512014
1484	hexagonal prism 96	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:36:23.51425
1485	cylinder 376	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:36:23.516631
1486	pentagonal prism 399	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:23.772028
1487	cube 475	pink	{0,0,0}	-208.67317	346.4762	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:23.774427
1488	cuboid 153	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:23.776933
1489	cylinder 377	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:23.779141
1490	hexagonal prism 97	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:36:24.005541
1491	cube 476	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:24.009384
1492	pentagonal prism 400	red	{0,0,0}	32.355774	258.8462	910	0	0	36.869892	pentagonal prism.usd	2025-03-29 15:36:24.012227
1493	cylinder 378	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:24.0144
1494	pentagonal prism 401	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:24.242647
1495	cube 477	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:24.245059
1496	cube 478	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	cube.usd	2025-03-29 15:36:24.247444
1497	cylinder 379	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:24.249488
1498	pentagonal prism 402	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:24.480212
1499	cube 479	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.743565	cube.usd	2025-03-29 15:36:24.48365
1500	cube 480	red	{0,0,0}	31.497837	259.85715	924	0	0	37.746803	cube.usd	2025-03-29 15:36:24.485654
1501	cylinder 380	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:36:24.487558
1502	pentagonal prism 403	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:24.71935
1503	cube 481	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:36:24.723323
1504	cuboid 154	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:24.725457
1505	cylinder 381	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:24.727505
1506	pentagonal prism 404	black	{0,0,0}	-129.44986	522.7403	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:24.948042
1507	cube 482	pink	{0,0,0}	-208.50322	347.83475	924	0	0	59.03625	cube.usd	2025-03-29 15:36:24.951987
1508	cuboid 155	red	{0,0,0}	31.621342	260.87607	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:24.953949
1509	cylinder 382	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:24.95607
1510	hexagonal prism 98	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:36:25.168204
1511	cube 483	pink	{0,0,0}	-206.88084	345.12823	907.00006	0	0	59.743565	cube.usd	2025-03-29 15:36:25.172205
1512	pentagonal prism 405	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:25.174345
1513	cylinder 383	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:25.176279
1514	pentagonal prism 406	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:25.404764
1515	cube 484	pink	{0,0,0}	-208.67317	346.4762	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:25.40881
1516	cuboid 156	red	{0,0,0}	31.497837	259.85715	919	0	0	37.874985	cuboid.usd	2025-03-29 15:36:25.410888
1517	cylinder 384	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:25.413074
1518	hexagonal prism 99	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:36:25.640038
1519	cube 485	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:25.644095
1520	pentagonal prism 407	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:36:25.646191
1521	cylinder 385	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:25.64873
1522	pentagonal prism 408	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:25.865217
1523	cube 486	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:36:25.868517
1524	cuboid 157	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:36:25.870822
1525	cylinder 386	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:36:25.872834
1526	hexagonal prism 100	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:36:26.091034
1527	cube 487	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:26.094335
1528	cuboid 158	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:36:26.096984
1529	cylinder 387	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:26.099268
1530	pentagonal prism 409	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:26.322287
1531	cube 488	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:26.324727
1532	cuboid 159	red	{0,0,0}	31.497837	259.85715	929	0	0	37.405357	cuboid.usd	2025-03-29 15:36:26.326687
1533	cylinder 388	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:36:26.32869
1534	pentagonal prism 410	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:26.547537
1535	cube 489	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:36:26.551818
1536	cube 490	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:36:26.553971
1537	cylinder 389	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:26.555989
1538	pentagonal prism 411	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:26.778232
1539	cube 491	pink	{0,0,0}	-208.67317	346.4762	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:26.782043
1540	pentagonal prism 412	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:36:26.784235
1541	cylinder 390	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:26.786223
1542	pentagonal prism 413	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:27.009027
1543	cube 492	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:36:27.013001
1544	cuboid 160	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:27.015357
1545	cylinder 391	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:27.017592
1546	pentagonal prism 414	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:27.23348
1547	cube 493	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:36:27.236071
1548	pentagonal prism 415	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:27.238966
1549	cylinder 392	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:36:27.241782
1550	pentagonal prism 416	black	{0,0,0}	-129.44986	522.7403	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:27.463065
1551	cube 494	pink	{0,0,0}	-209.49138	347.83475	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:36:27.465917
1552	cube 495	red	{0,0,0}	31.621342	260.87607	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:36:27.468264
1553	cylinder 393	green	{0,0,0}	-273.72223	218.38489	921.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:36:27.470327
1554	hexagonal prism 101	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	hexagonal prism.usd	2025-03-29 15:36:27.702356
1555	cube 496	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:27.705039
1556	cuboid 161	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:36:27.707052
1557	cylinder 394	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:27.709056
1558	pentagonal prism 417	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:27.933295
1559	cube 497	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:36:27.938153
1560	cuboid 162	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:27.940275
1561	cylinder 395	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:36:27.942492
1562	pentagonal prism 418	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:28.161673
1563	cube 498	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:28.165529
1564	cube 499	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	cube.usd	2025-03-29 15:36:28.167879
1565	cylinder 396	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:36:28.170035
1566	pentagonal prism 419	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:36:28.398712
1567	cube 500	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 15:36:28.402617
1568	pentagonal prism 420	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:36:28.404811
1569	cylinder 397	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:28.406839
1570	pentagonal prism 421	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:36:28.646513
1571	cube 501	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:28.650106
1572	hexagonal prism 102	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:36:28.654214
1573	cylinder 398	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:28.657934
1574	pentagonal prism 422	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:28.893902
1575	cube 502	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:36:28.896244
1576	hexagonal prism 103	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:36:28.898238
1577	cylinder 399	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:36:28.900428
1578	pentagonal prism 423	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:29.132188
1579	cube 503	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.03625	cube.usd	2025-03-29 15:36:29.13658
1580	hexagonal prism 104	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:36:29.140429
1581	cylinder 400	green	{0,0,0}	-270.6119	216.68562	933	0	0	18.434948	cylinder.usd	2025-03-29 15:36:29.143532
1582	hexagonal prism 105	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:36:29.372486
1583	cube 504	pink	{0,0,0}	-208.67317	346.4762	914.00006	0	0	59.420776	cube.usd	2025-03-29 15:36:29.375194
1584	cube 505	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.405357	cube.usd	2025-03-29 15:36:29.377195
1585	cylinder 401	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:36:29.379211
1586	pentagonal prism 424	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:36:29.606618
1587	cube 506	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:36:29.6103
1588	pentagonal prism 425	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:36:29.612309
1589	cylinder 402	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:36:29.614234
1590	pentagonal prism 426	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:29.841218
1591	cube 507	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:36:29.845186
1592	pentagonal prism 427	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:36:29.847281
1593	cylinder 403	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:36:29.849165
1594	pentagonal prism 428	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:30.074415
1595	cube 508	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:30.078093
1596	pentagonal prism 429	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:36:30.080283
1597	cylinder 404	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:30.082458
1598	pentagonal prism 430	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:30.298552
1599	cube 509	pink	{0,0,0}	-207.68886	346.4762	915	0	0	59.34933	cube.usd	2025-03-29 15:36:30.301758
1600	cuboid 163	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:36:30.303896
1601	cylinder 405	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:36:30.305887
1602	pentagonal prism 431	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:36:30.525718
1603	cube 510	pink	{0,0,0}	-206.88084	345.12823	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:36:30.529486
1604	cube 511	red	{0,0,0}	32.355774	258.8462	910	0	0	37.568592	cube.usd	2025-03-29 15:36:30.531573
1605	cylinder 406	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:30.534094
1606	pentagonal prism 432	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:36:30.752525
1607	cube 512	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:36:30.755353
1608	cuboid 164	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:36:30.75742
1609	cylinder 407	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:36:30.75937
1610	pentagonal prism 433	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:36:30.9761
1611	cube 513	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.420776	cube.usd	2025-03-29 15:36:30.978414
1612	pentagonal prism 434	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:36:30.980487
1613	cylinder 408	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:36:30.982421
1614	pentagonal prism 435	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:36:31.196795
1615	cube 514	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:36:31.200866
1616	cuboid 165	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:36:31.203284
1617	cylinder 409	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:31.205759
1618	pentagonal prism 436	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:36:31.41801
1619	cube 515	pink	{0,0,0}	-207.68886	346.4762	906	0	0	59.03625	cube.usd	2025-03-29 15:36:31.420953
1620	cube 516	red	{0,0,0}	31.497837	259.85715	934	0	0	37.568592	cube.usd	2025-03-29 15:36:31.422986
1621	cylinder 410	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:36:31.424883
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
1	2025-03-29 15:33:42.214048	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-03-29 15:33:42.214048	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 15:33:42.214048
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 15:33:42.214048
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-03-29 15:33:42.214048
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
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-03-29 15:33:42.214048
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-03-29 15:33:42.214048
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
1	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscar.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	2025-03-29 15:33:42.214048	2025-03-29 15:33:42.214048
2	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahul.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\N	\N	2025-03-29 15:33:42.214048	2025-03-29 15:33:42.214048
3	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanjay.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	2025-03-29 15:33:42.214048	2025-03-29 15:33:42.214048
4	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehdi.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	2025-03-29 15:33:42.214048	2025-03-29 15:33:42.214048
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 1621, true);


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

