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
1	pentagonal prism 2	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:37:54.462666
2	cube 2	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.420776	cube.usd	2025-03-29 15:37:54.467789
3	wedge 2	green	{0,0,0}	120.598785	340.22586	1905.0001	0	0	4.398705	wedge.usd	2025-03-29 15:37:54.469834
4	hexagonal prism 2	red	{0,0,0}	31.375294	259.82666	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:37:54.471818
5	cylinder 2	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:37:54.473978
6	pentagonal prism 3	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:37:54.70465
7	cube 3	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:37:54.708067
8	hexagonal prism 3	red	{0,0,0}	30.51353	260.84146	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:37:54.710079
9	cylinder 3	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:54.711987
10	hexagonal prism 5	black	{0,0,0}	-353.92917	194.74571	656	0	0	90	hexagonal prism.usd	2025-03-29 15:37:54.935342
11	cube 5	pink	{0,0,0}	-421.66678	44.876186	935.00006	0	0	59.534454	cube.usd	2025-03-29 15:37:54.938073
12	hexagonal prism 7	red	{0,0,0}	-216.76044	-28.788496	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:37:54.940345
13	cylinder 5	green	{0,0,0}	-477.55035	-66.0442	924	0	0	26.56505	cylinder.usd	2025-03-29 15:37:54.942229
14	pentagonal prism 4	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:37:55.170999
15	cube 6	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:37:55.173264
16	pentagonal prism 6	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:37:55.175216
17	cylinder 6	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:55.177124
18	pentagonal prism 7	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:37:55.403508
19	cube 7	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:37:55.407625
20	hexagonal prism 8	red	{0,0,0}	30.51353	260.84146	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:37:55.409699
21	cylinder 7	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:55.411689
22	pentagonal prism 8	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	pentagonal prism.usd	2025-03-29 15:37:55.635452
23	cube 8	pink	{0,0,0}	-208.50322	347.83475	924	0	0	59.743565	cube.usd	2025-03-29 15:37:55.638307
24	hexagonal prism 9	red	{0,0,0}	30.633175	261.86423	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:37:55.640623
25	cylinder 8	green	{0,0,0}	-273.72223	218.38489	929	0	0	26.56505	cylinder.usd	2025-03-29 15:37:55.642978
26	pentagonal prism 9	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:37:55.853571
27	cube 9	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03625	cube.usd	2025-03-29 15:37:55.855895
28	hexagonal prism 10	red	{0,0,0}	30.51353	260.84146	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:37:55.857844
29	cylinder 9	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:37:55.859661
30	pentagonal prism 10	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:37:56.086005
31	cube 10	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:37:56.088476
32	cube 12	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:37:56.090618
33	cylinder 10	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:37:56.092605
34	pentagonal prism 11	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:37:56.303268
35	cube 13	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:37:56.306665
36	cuboid 2	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:37:56.308846
37	cylinder 11	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:56.31084
38	pentagonal prism 12	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:37:56.540105
39	cube 14	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:37:56.544104
40	cube 15	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:37:56.54597
41	cylinder 12	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:37:56.548167
42	pentagonal prism 13	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:37:56.768835
43	cube 16	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:37:56.771571
44	cube 17	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:37:56.773832
45	cylinder 13	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:56.775869
46	pentagonal prism 14	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:37:56.988519
47	cube 18	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:37:56.991297
48	cuboid 3	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:37:56.993707
49	cylinder 14	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:37:56.995897
50	pentagonal prism 15	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:37:57.222235
51	cube 19	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:37:57.226311
52	cuboid 4	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:37:57.228228
53	cylinder 15	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:37:57.2302
54	pentagonal prism 16	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:37:57.45442
55	cube 20	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:37:57.458652
56	cuboid 5	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	cuboid.usd	2025-03-29 15:37:57.461464
57	cylinder 16	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:37:57.463545
58	pentagonal prism 17	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:37:57.690657
59	cube 21	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.62088	cube.usd	2025-03-29 15:37:57.693202
60	hexagonal prism 11	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:37:57.695038
61	cylinder 17	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:37:57.696899
62	hexagonal prism 13	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:37:57.922652
63	cube 22	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:37:57.926431
64	pentagonal prism 18	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:37:57.928515
65	cylinder 18	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:57.930664
66	pentagonal prism 19	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:37:58.152799
67	cube 23	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.420776	cube.usd	2025-03-29 15:37:58.156475
68	pentagonal prism 20	red	{0,0,0}	31.497837	259.85715	915	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:37:58.158484
69	cylinder 19	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:58.160634
70	pentagonal prism 21	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:37:58.372255
71	cube 24	pink	{0,0,0}	-207.68886	346.4762	912.00006	0	0	59.620872	cube.usd	2025-03-29 15:37:58.374907
72	pentagonal prism 22	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:37:58.37699
73	cylinder 20	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:58.378898
74	pentagonal prism 23	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:37:58.604758
75	cube 25	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:37:58.607407
76	cuboid 6	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:37:58.609547
77	cylinder 21	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:58.611643
78	pentagonal prism 24	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:37:58.824515
79	cube 26	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:37:58.827954
80	cuboid 7	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:37:58.830189
81	cylinder 22	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:58.832265
82	pentagonal prism 25	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:37:59.056414
83	cube 27	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:37:59.060184
84	pentagonal prism 26	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:37:59.062321
85	cylinder 23	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:59.06424
86	pentagonal prism 27	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:37:59.289389
87	cube 28	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:37:59.293238
88	cube 29	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.746803	cube.usd	2025-03-29 15:37:59.295216
89	cylinder 24	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:59.29723
90	pentagonal prism 28	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:37:59.525469
91	cube 30	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:37:59.5287
92	cuboid 8	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:37:59.530661
93	cylinder 25	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:59.532557
94	pentagonal prism 29	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:37:59.759098
95	cube 31	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:37:59.763132
96	cuboid 9	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:37:59.765129
97	cylinder 26	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:37:59.767105
98	pentagonal prism 30	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:37:59.991936
99	cube 32	pink	{0,0,0}	-206.70456	346.4762	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:37:59.995931
100	cube 33	red	{0,0,0}	32.482143	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:37:59.997977
101	cylinder 27	green	{0,0,0}	-271.66885	217.53194	929	0	0	33.690063	cylinder.usd	2025-03-29 15:38:00.000282
102	pentagonal prism 31	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:00.221181
103	cube 34	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:00.22345
104	cuboid 10	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:00.225466
105	cylinder 28	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:00.227496
106	pentagonal prism 32	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:00.441413
107	cube 35	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.03624	cube.usd	2025-03-29 15:38:00.444045
108	hexagonal prism 14	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:38:00.446079
109	cylinder 29	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:00.44792
110	pentagonal prism 33	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:00.673413
111	cube 36	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:38:00.677476
112	cuboid 11	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:00.679333
113	cylinder 30	green	{0,0,0}	-271.66885	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:00.681319
114	pentagonal prism 34	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:00.908588
115	cube 37	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:00.912676
116	cuboid 12	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:00.914642
117	cylinder 31	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:00.916652
118	pentagonal prism 35	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:01.146351
119	cube 38	pink	{0,0,0}	-207.68886	346.4762	908.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:01.148751
120	pentagonal prism 36	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:38:01.150738
121	cylinder 32	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:01.152517
122	pentagonal prism 37	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:01.377722
123	cube 39	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:38:01.381559
124	cube 40	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:38:01.383488
125	cylinder 33	green	{0,0,0}	-272.65317	217.53194	929	0	0	35.537674	cylinder.usd	2025-03-29 15:38:01.385502
126	pentagonal prism 38	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:01.613046
127	cube 41	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:01.616897
128	cuboid 13	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:38:01.618948
129	cylinder 34	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:01.621047
130	pentagonal prism 39	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:01.842806
131	cube 42	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:38:01.846079
132	cube 43	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:38:01.848109
133	cylinder 35	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:38:01.850045
134	pentagonal prism 40	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:02.07484
135	cube 44	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:02.078514
136	hexagonal prism 15	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:38:02.080491
137	cylinder 36	green	{0,0,0}	-272.65317	217.53194	929	0	0	33.690063	cylinder.usd	2025-03-29 15:38:02.082469
138	pentagonal prism 41	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:02.308074
139	cube 45	pink	{0,0,0}	-205.90038	345.12823	910	0	0	59.534454	cube.usd	2025-03-29 15:38:02.310577
140	pentagonal prism 42	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:38:02.312616
141	cylinder 37	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:02.314546
142	pentagonal prism 43	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:02.527462
143	cube 46	pink	{0,0,0}	-208.67317	346.4762	914.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:02.530427
144	cube 47	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.405357	cube.usd	2025-03-29 15:38:02.532467
145	cylinder 38	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:02.534499
146	pentagonal prism 44	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:02.760087
147	cube 48	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:02.764066
148	pentagonal prism 45	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:02.766072
149	cylinder 39	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:02.768145
150	pentagonal prism 46	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:02.992368
151	cube 49	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:02.996058
152	cube 50	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	cube.usd	2025-03-29 15:38:02.998039
153	cylinder 40	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:03.000055
154	hexagonal prism 16	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:38:03.224229
155	cube 51	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.420776	cube.usd	2025-03-29 15:38:03.228081
156	pentagonal prism 47	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:38:03.230156
157	cylinder 41	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:03.232194
158	pentagonal prism 48	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:03.449353
159	cube 52	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:38:03.452494
160	pentagonal prism 49	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:03.454494
161	cylinder 42	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:03.456722
162	pentagonal prism 50	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:03.678584
163	cube 53	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:38:03.682902
164	cube 54	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	cube.usd	2025-03-29 15:38:03.684983
165	cylinder 43	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:03.687013
166	pentagonal prism 51	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:03.912375
167	cube 55	pink	{0,0,0}	-206.88084	345.12823	934	0	0	59.03624	cube.usd	2025-03-29 15:38:03.916979
168	cube 56	red	{0,0,0}	32.355774	258.8462	933	0	0	37.568592	cube.usd	2025-03-29 15:38:03.919306
169	cylinder 44	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:03.921565
170	pentagonal prism 52	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:04.147533
171	cube 57	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.03624	cube.usd	2025-03-29 15:38:04.151174
172	hexagonal prism 17	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:38:04.153092
173	cylinder 45	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:04.155165
174	hexagonal prism 18	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:38:04.378993
175	cube 58	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.420776	cube.usd	2025-03-29 15:38:04.381225
176	cuboid 14	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:38:04.383204
177	cylinder 46	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:04.385092
178	pentagonal prism 53	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:04.614116
179	cube 59	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:38:04.617978
180	cube 60	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:04.619904
181	cylinder 47	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:04.621913
182	pentagonal prism 54	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:04.846157
183	cube 61	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:04.850188
184	cuboid 15	red	{0,0,0}	31.497837	259.85715	934	0	0	37.405357	cuboid.usd	2025-03-29 15:38:04.852197
185	cylinder 48	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:38:04.854221
186	pentagonal prism 55	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:05.078174
187	cube 62	pink	{0,0,0}	-206.70456	346.4762	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:05.082358
188	cuboid 16	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:38:05.084457
189	cylinder 49	green	{0,0,0}	-271.66885	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:05.086409
190	pentagonal prism 56	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:05.311814
191	cube 63	pink	{0,0,0}	-207.68886	346.4762	931.00006	0	0	59.420776	cube.usd	2025-03-29 15:38:05.314585
192	cuboid 17	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:05.316741
193	cylinder 50	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:05.318883
194	pentagonal prism 57	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:05.546209
195	cube 64	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:05.550464
196	cuboid 18	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:38:05.552425
197	cylinder 51	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:05.554501
198	hexagonal prism 19	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:38:05.781578
199	cube 65	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.534454	cube.usd	2025-03-29 15:38:05.78387
200	cuboid 19	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:05.785812
201	cylinder 52	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:05.787852
202	pentagonal prism 58	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:06.013777
203	cube 66	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:38:06.017314
204	cuboid 20	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:38:06.019352
205	cylinder 53	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:06.021625
206	pentagonal prism 59	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:06.245701
207	cube 67	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:06.248302
208	cuboid 21	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:38:06.250708
209	cylinder 54	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:06.252759
210	pentagonal prism 60	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:06.481802
211	cube 68	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:06.485869
212	cuboid 22	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:38:06.488074
213	cylinder 55	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:06.490087
214	pentagonal prism 61	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:06.713695
215	cube 69	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:06.717703
216	pentagonal prism 62	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:38:06.719691
217	cylinder 56	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:06.721683
218	pentagonal prism 63	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:06.943778
219	cube 70	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:06.94749
220	pentagonal prism 64	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:38:06.949525
221	cylinder 57	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:06.951661
222	pentagonal prism 65	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:07.163545
223	cube 71	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.420776	cube.usd	2025-03-29 15:38:07.166196
224	hexagonal prism 20	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:38:07.168247
225	cylinder 58	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:07.170349
226	pentagonal prism 66	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:07.399898
227	cube 72	pink	{0,0,0}	-208.67317	346.4762	932.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:07.402503
228	cuboid 23	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:07.404372
229	cylinder 59	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:07.406237
230	pentagonal prism 67	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:07.629887
231	cube 73	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:07.633959
232	pentagonal prism 68	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:07.636162
233	cylinder 60	green	{0,0,0}	-272.65317	217.53194	919	0	0	33.690063	cylinder.usd	2025-03-29 15:38:07.638096
234	hexagonal prism 21	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:38:07.862031
235	cube 74	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:07.866123
236	cube 75	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.405357	cube.usd	2025-03-29 15:38:07.868394
237	cylinder 61	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:07.870323
238	hexagonal prism 22	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:38:08.099307
239	cube 76	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:08.10334
240	cuboid 24	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:08.105407
241	cylinder 62	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:08.107357
242	pentagonal prism 69	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:08.334784
243	cube 77	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:08.338925
244	cuboid 25	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:38:08.341007
245	cylinder 63	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:38:08.343102
246	pentagonal prism 70	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:08.564692
247	cube 78	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:38:08.567508
248	cuboid 26	red	{0,0,0}	32.355774	258.8462	924	0	0	37.40536	cuboid.usd	2025-03-29 15:38:08.569505
249	cylinder 64	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:08.571331
250	pentagonal prism 71	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:08.783221
251	cube 79	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:08.785688
252	hexagonal prism 23	red	{0,0,0}	32.355774	258.8462	924	0	0	37.69424	hexagonal prism.usd	2025-03-29 15:38:08.787758
253	cylinder 65	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:08.789763
254	pentagonal prism 72	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:09.013996
255	cube 80	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:09.017977
256	cuboid 27	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:38:09.01989
257	cylinder 66	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:09.021855
258	pentagonal prism 73	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:09.244904
259	cube 81	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:09.248802
260	hexagonal prism 24	red	{0,0,0}	32.355774	258.8462	933	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:38:09.250918
261	cylinder 67	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:09.253003
262	hexagonal prism 25	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:38:09.479889
263	cube 82	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:38:09.483425
264	cuboid 28	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:38:09.48576
265	cylinder 68	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:09.487923
266	pentagonal prism 74	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:09.703941
267	cube 83	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03624	cube.usd	2025-03-29 15:38:09.707225
268	pentagonal prism 75	red	{0,0,0}	31.497837	259.85715	920	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:38:09.709139
269	cylinder 69	green	{0,0,0}	-272.65317	217.53194	929	0	0	38.65981	cylinder.usd	2025-03-29 15:38:09.711418
270	hexagonal prism 26	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:38:09.930984
271	cube 84	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:38:09.933488
272	cuboid 29	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:09.935855
273	cylinder 70	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:09.937926
274	pentagonal prism 76	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:10.151795
275	cube 85	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:10.154818
276	cuboid 30	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:38:10.156842
277	cylinder 71	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:10.158806
278	pentagonal prism 77	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:10.382934
279	cube 86	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:10.387141
280	cuboid 31	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:38:10.389168
281	cylinder 72	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:38:10.391107
282	hexagonal prism 27	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:38:10.617018
283	cube 87	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:38:10.620806
284	cuboid 32	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:38:10.622759
285	cylinder 73	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:10.624738
286	pentagonal prism 78	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:10.84797
287	cube 88	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:10.852263
288	cuboid 33	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:10.854378
289	cylinder 74	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:10.856388
290	pentagonal prism 79	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:11.081001
291	cube 89	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:11.08435
292	cuboid 34	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:11.086599
293	cylinder 75	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:11.125372
294	hexagonal prism 28	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:38:11.347318
295	cube 90	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:38:11.349528
296	cuboid 35	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:11.351756
297	cylinder 76	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:11.354053
298	pentagonal prism 80	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:11.578643
299	cube 91	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:11.582466
300	cuboid 36	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:38:11.584685
301	cylinder 77	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:11.586691
302	pentagonal prism 81	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:11.811858
303	cube 92	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:11.815866
304	cuboid 37	red	{0,0,0}	31.497837	259.85715	934	0	0	37.568592	cuboid.usd	2025-03-29 15:38:11.818145
305	cylinder 78	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:11.8202
306	pentagonal prism 82	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:12.035594
307	cube 93	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:12.038585
308	cuboid 38	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:38:12.040556
309	cylinder 79	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:12.042471
310	pentagonal prism 83	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:12.260884
311	cube 94	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.62088	cube.usd	2025-03-29 15:38:12.263317
312	cuboid 39	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:38:12.265244
313	cylinder 80	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:12.267222
314	pentagonal prism 84	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:12.482896
315	cube 95	pink	{0,0,0}	-208.50322	347.83475	916.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:12.486579
316	cuboid 40	red	{0,0,0}	31.621342	260.87607	920	0	0	37.568592	cuboid.usd	2025-03-29 15:38:12.489198
317	cylinder 81	green	{0,0,0}	-273.72223	218.38489	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:12.493157
318	pentagonal prism 85	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:12.716968
319	cube 96	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:12.719439
320	cuboid 41	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:38:12.721777
321	cylinder 82	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:12.723853
322	pentagonal prism 86	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:12.947828
323	cube 97	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:12.951591
324	cube 98	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:12.953725
325	cylinder 83	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:12.95634
326	pentagonal prism 87	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:13.169248
327	cube 99	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:38:13.172267
328	cube 100	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:13.174439
329	cylinder 84	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:13.17631
330	pentagonal prism 88	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:13.40895
331	cube 101	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:13.412471
332	cuboid 42	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:38:13.414543
333	cylinder 85	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:13.416415
334	pentagonal prism 89	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:13.637408
335	cube 102	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:13.639921
336	hexagonal prism 29	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:38:13.642215
337	cylinder 86	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:13.644405
338	pentagonal prism 90	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:13.86151
339	cube 103	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:38:13.864175
340	cube 104	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.746803	cube.usd	2025-03-29 15:38:13.866515
341	cylinder 87	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:38:13.868666
342	pentagonal prism 91	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:14.08056
343	cube 105	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 15:38:14.083036
344	cuboid 43	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cuboid.usd	2025-03-29 15:38:14.085018
345	cylinder 88	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:38:14.086958
346	pentagonal prism 92	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:14.299219
347	cube 106	pink	{0,0,0}	-207.68886	346.4762	913.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:14.301818
348	pentagonal prism 93	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	38.157227	pentagonal prism.usd	2025-03-29 15:38:14.303762
349	cylinder 89	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:14.3059
350	hexagonal prism 30	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:38:14.521667
351	cube 107	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:14.524107
352	cube 108	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:14.526059
353	cylinder 90	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:14.527942
354	pentagonal prism 94	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 15:38:14.750773
355	cube 109	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:14.753446
356	cuboid 44	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:38:14.755453
357	cylinder 91	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:14.75773
358	pentagonal prism 95	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:14.973419
359	cube 110	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:14.976193
360	cube 111	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:38:14.978042
361	cylinder 92	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:38:14.979899
362	pentagonal prism 96	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:15.204409
363	cube 112	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:15.208257
364	cuboid 45	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:38:15.210316
365	cylinder 93	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:15.212128
366	pentagonal prism 97	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:15.436341
367	cube 113	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:15.439122
368	pentagonal prism 98	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:15.441345
369	cylinder 94	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:15.443387
370	pentagonal prism 99	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:15.65671
371	cube 114	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:38:15.659455
372	cube 115	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:15.661335
373	cylinder 95	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:15.66322
374	pentagonal prism 100	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:15.88948
375	cube 116	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.620872	cube.usd	2025-03-29 15:38:15.893342
376	cuboid 46	red	{0,0,0}	31.497837	259.85715	934	0	0	37.568592	cuboid.usd	2025-03-29 15:38:15.895213
377	cylinder 96	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:15.897375
378	pentagonal prism 101	black	{0,0,0}	-128.94427	520.6986	660	0	0	90	pentagonal prism.usd	2025-03-29 15:38:16.120965
379	cube 117	pink	{0,0,0}	-207.68886	346.4762	909.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:16.124564
380	cube 118	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:38:16.126903
381	cylinder 97	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:16.129044
382	pentagonal prism 102	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:16.354464
383	cube 119	pink	{0,0,0}	-207.68886	346.4762	933	0	0	59.534454	cube.usd	2025-03-29 15:38:16.358415
384	cuboid 47	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:38:16.360342
385	cylinder 98	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:16.362328
386	hexagonal prism 31	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:38:16.586829
387	cube 120	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:38:16.591022
388	pentagonal prism 103	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:16.593137
389	cylinder 99	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:38:16.595026
390	pentagonal prism 104	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:16.823969
391	cube 121	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:38:16.826558
392	pentagonal prism 105	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:38:16.828508
393	cylinder 100	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:16.830529
394	pentagonal prism 106	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:17.059714
395	cube 122	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:17.063288
396	cube 123	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:17.065175
397	cylinder 101	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:17.067382
398	pentagonal prism 107	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:17.290112
399	cube 124	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:17.292798
400	cuboid 48	red	{0,0,0}	31.497837	259.85715	932.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:17.294967
401	cylinder 102	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:17.296861
402	hexagonal prism 32	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:38:17.522509
403	cube 125	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:38:17.526307
404	hexagonal prism 33	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:38:17.528276
405	cylinder 103	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:17.530148
406	pentagonal prism 108	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:17.757416
407	cube 126	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:38:17.761446
408	pentagonal prism 109	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:17.763549
409	cylinder 104	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:17.765697
410	hexagonal prism 34	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:38:18.00079
411	cube 127	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:38:18.003084
412	cube 128	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.405357	cube.usd	2025-03-29 15:38:18.004831
413	cylinder 105	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:18.006551
414	pentagonal prism 110	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:18.22567
415	cube 129	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:38:18.229362
416	cuboid 49	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:18.231286
417	cylinder 106	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:18.233693
418	pentagonal prism 111	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:18.454613
419	cube 130	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:38:18.458807
420	cuboid 50	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:18.460989
421	cylinder 107	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:18.463377
422	pentagonal prism 112	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:18.692793
423	cube 131	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:18.696589
424	cuboid 51	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:38:18.698443
425	cylinder 108	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:18.700397
426	pentagonal prism 113	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:18.928274
427	cube 132	pink	{0,0,0}	-206.70456	346.4762	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:18.932372
428	pentagonal prism 114	red	{0,0,0}	32.482143	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:18.934651
429	cylinder 109	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:18.93707
430	pentagonal prism 115	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:19.158545
431	cube 133	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:38:19.162557
432	cube 134	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:19.164381
433	cylinder 110	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:19.166273
434	pentagonal prism 116	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:19.394505
435	cube 135	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:38:19.397055
436	cube 136	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:38:19.399009
437	cylinder 111	green	{0,0,0}	-270.6119	216.68562	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:19.400896
438	pentagonal prism 117	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:19.621492
439	cube 137	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:19.62544
440	cube 138	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.746803	cube.usd	2025-03-29 15:38:19.627929
441	cylinder 112	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:19.63007
442	pentagonal prism 118	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:19.854641
443	cube 139	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:19.858687
444	cuboid 52	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:38:19.86149
445	cylinder 113	green	{0,0,0}	-270.6119	216.68562	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:19.863639
446	pentagonal prism 119	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:20.075194
447	cube 140	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:38:20.078008
448	cuboid 53	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:20.080064
449	cylinder 114	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:20.08205
450	pentagonal prism 120	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:20.311822
451	cube 141	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.420776	cube.usd	2025-03-29 15:38:20.314348
452	cuboid 54	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:20.316209
453	cylinder 115	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:38:20.318039
454	pentagonal prism 121	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:20.543845
455	cube 142	pink	{0,0,0}	-207.68886	346.4762	935.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:20.547875
456	cuboid 55	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:20.550015
457	cylinder 116	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:20.55221
458	pentagonal prism 122	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:20.769134
459	cube 143	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:38:20.771694
460	cuboid 56	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:20.773704
461	cylinder 117	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:20.775656
462	pentagonal prism 123	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:21.006358
463	cube 144	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:38:21.010078
464	cube 145	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:21.012489
465	cylinder 118	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:21.014642
466	pentagonal prism 124	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:21.239649
467	cube 146	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:21.242501
468	pentagonal prism 125	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:21.24456
469	cylinder 119	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:21.24655
470	pentagonal prism 126	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:21.461087
471	cube 147	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:38:21.464332
472	cuboid 57	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:38:21.466078
473	cylinder 120	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:21.468035
474	pentagonal prism 127	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:21.692913
475	cube 148	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 15:38:21.696665
476	cuboid 58	red	{0,0,0}	32.482143	259.85715	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:21.698857
477	cylinder 121	green	{0,0,0}	-271.66885	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:21.700901
478	pentagonal prism 128	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:21.928159
479	cube 149	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:21.932284
480	cuboid 59	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:21.934238
481	cylinder 122	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:21.936301
482	hexagonal prism 35	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:38:22.159667
483	cube 150	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:22.162252
484	cuboid 60	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:38:22.164517
485	cylinder 123	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 15:38:22.166894
486	pentagonal prism 129	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:22.396344
487	cube 151	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:22.400122
488	cuboid 61	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:38:22.40197
489	cylinder 124	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:22.403858
490	pentagonal prism 130	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:22.625351
491	cube 152	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:38:22.629195
492	pentagonal prism 131	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:22.63137
493	cylinder 125	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:22.633446
494	pentagonal prism 132	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:22.861479
495	cube 153	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:38:22.865605
496	cube 154	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	cube.usd	2025-03-29 15:38:22.868083
497	cylinder 126	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	39.80557	cylinder.usd	2025-03-29 15:38:22.870415
498	pentagonal prism 133	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:23.103281
499	cube 155	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:23.106722
500	cuboid 62	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:23.108766
501	cylinder 127	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:23.110803
502	pentagonal prism 134	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:23.325438
503	cube 156	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:38:23.329185
504	cuboid 63	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:23.331303
505	cylinder 128	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:23.33335
506	pentagonal prism 135	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:23.563375
507	cube 157	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:23.56632
508	hexagonal prism 36	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:38:23.569164
509	cylinder 129	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:38:23.571606
510	pentagonal prism 136	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:23.797924
511	cube 158	pink	{0,0,0}	-206.70456	346.4762	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:23.801754
512	cuboid 64	red	{0,0,0}	32.482143	259.85715	915	0	0	37.568592	cuboid.usd	2025-03-29 15:38:23.803615
513	cylinder 130	green	{0,0,0}	-271.66885	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:23.805859
514	pentagonal prism 137	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:24.029897
515	cube 159	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:38:24.033736
516	cube 160	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:24.035775
517	cylinder 131	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:24.037664
518	hexagonal prism 37	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:38:24.264483
519	cube 161	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:24.266707
520	cube 162	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	cube.usd	2025-03-29 15:38:24.268554
521	cylinder 132	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:24.270329
522	pentagonal prism 138	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:24.499797
523	cube 163	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:24.503894
524	cube 164	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:24.505968
525	cylinder 133	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:24.50793
526	pentagonal prism 139	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:24.738932
527	cube 165	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:24.742581
528	pentagonal prism 140	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:24.744519
529	cylinder 134	green	{0,0,0}	-272.65317	217.53194	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:24.746795
530	pentagonal prism 141	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:24.970001
531	cube 166	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:24.972897
532	cuboid 65	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:24.974804
533	cylinder 135	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:38:24.976801
534	pentagonal prism 142	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:25.193479
535	cube 167	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.743565	cube.usd	2025-03-29 15:38:25.197235
536	cube 168	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cube.usd	2025-03-29 15:38:25.199924
537	cylinder 136	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:25.202128
538	pentagonal prism 143	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:25.430302
539	cube 169	pink	{0,0,0}	-207.68886	346.4762	915	0	0	59.534454	cube.usd	2025-03-29 15:38:25.434139
540	pentagonal prism 144	red	{0,0,0}	31.497837	259.85715	920	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:38:25.43623
541	cylinder 137	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:25.438325
542	pentagonal prism 145	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:25.665679
543	cube 170	pink	{0,0,0}	-205.90038	345.12823	936.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:25.668181
544	cuboid 66	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:25.67013
545	cylinder 138	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:25.672108
546	pentagonal prism 146	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:25.891945
547	cube 171	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:25.895932
548	cuboid 67	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:38:25.898138
549	cylinder 139	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:25.900787
550	pentagonal prism 147	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:26.114835
551	cube 172	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:38:26.117787
552	cuboid 68	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	cuboid.usd	2025-03-29 15:38:26.120075
553	cylinder 140	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:38:26.122118
554	pentagonal prism 148	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:26.34543
555	cube 173	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:26.348323
556	pentagonal prism 149	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:26.350736
557	cylinder 141	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:26.352824
558	pentagonal prism 150	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:26.58266
559	cube 174	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:38:26.586624
560	pentagonal prism 151	red	{0,0,0}	31.497837	259.85715	915	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:38:26.58854
561	cylinder 142	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:26.590703
562	pentagonal prism 152	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:26.806516
563	cube 175	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.62088	cube.usd	2025-03-29 15:38:26.811278
564	pentagonal prism 153	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:38:26.813335
565	cylinder 143	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:26.815682
566	pentagonal prism 154	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:27.02915
567	cube 176	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:27.032758
568	cuboid 69	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:27.034958
569	cylinder 144	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:27.036983
570	pentagonal prism 155	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:27.26096
571	cube 177	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.743565	cube.usd	2025-03-29 15:38:27.263683
572	cuboid 70	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:38:27.266019
573	cylinder 145	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:27.268475
574	pentagonal prism 156	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:27.480265
575	cube 178	pink	{0,0,0}	-208.50322	347.83475	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:27.482616
576	cuboid 71	red	{0,0,0}	31.621342	260.87607	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:27.484618
577	cylinder 146	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:27.486734
578	pentagonal prism 157	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:27.717191
579	cube 179	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.420776	cube.usd	2025-03-29 15:38:27.721174
580	cuboid 72	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:38:27.723214
581	cylinder 147	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:27.72528
582	pentagonal prism 158	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:27.947708
583	cube 180	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.03625	cube.usd	2025-03-29 15:38:27.951301
584	cuboid 73	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:38:27.953615
585	cylinder 148	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:27.955802
586	hexagonal prism 38	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:38:28.18336
587	cube 181	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:38:28.187128
588	cube 182	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	cube.usd	2025-03-29 15:38:28.188938
589	cylinder 149	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:28.190876
590	pentagonal prism 159	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:28.411908
591	cube 183	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:28.414244
592	cube 184	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:28.416208
593	cylinder 150	green	{0,0,0}	-270.6119	216.68562	920	0	0	33.690063	cylinder.usd	2025-03-29 15:38:28.418188
594	pentagonal prism 160	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:28.631406
595	cube 185	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:38:28.633651
596	cuboid 74	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:28.636041
597	cylinder 151	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:28.638051
598	pentagonal prism 161	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:28.850831
599	cube 186	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:28.853842
600	cube 187	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:28.8559
601	cylinder 152	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:28.857702
602	pentagonal prism 162	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:29.07979
603	cube 188	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 15:38:29.082291
604	cuboid 75	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:38:29.084488
605	cylinder 153	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:29.086907
606	pentagonal prism 163	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:29.308733
607	cube 189	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:38:29.312855
608	cuboid 76	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:38:29.314806
609	cylinder 154	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:38:29.316767
610	pentagonal prism 164	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:29.538231
611	cube 190	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:29.54223
612	cuboid 77	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:38:29.54482
613	cylinder 155	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:29.546913
614	pentagonal prism 165	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:29.785845
615	cube 191	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:29.789808
616	pentagonal prism 166	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:38:29.791636
617	cylinder 156	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:38:29.793834
618	pentagonal prism 167	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:30.027441
619	cube 192	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:38:30.031422
620	cuboid 78	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:30.033772
621	cylinder 157	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:30.035974
622	pentagonal prism 168	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:30.262203
623	cube 193	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03625	cube.usd	2025-03-29 15:38:30.265063
624	cuboid 79	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:38:30.266964
625	cylinder 158	green	{0,0,0}	-272.65317	217.53194	942.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:30.269452
626	pentagonal prism 169	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:30.48307
627	cube 194	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:30.485634
628	cuboid 80	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:30.487676
629	cylinder 159	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:30.489604
630	pentagonal prism 170	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:30.717404
631	cube 195	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:30.721258
632	cuboid 81	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:30.723194
633	cylinder 160	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:30.725087
634	hexagonal prism 39	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	hexagonal prism.usd	2025-03-29 15:38:30.955497
635	cube 196	pink	{0,0,0}	-208.67317	346.4762	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:30.959389
636	cube 197	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:30.961543
637	cylinder 161	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:30.963504
638	pentagonal prism 171	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:31.181781
639	cube 198	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:31.184164
640	cuboid 82	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:38:31.18613
641	cylinder 162	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:31.188823
642	pentagonal prism 172	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 15:38:31.404996
643	cube 199	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:38:31.408309
644	cuboid 83	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:31.410403
645	cylinder 163	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:31.412443
646	pentagonal prism 173	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:31.643316
647	cube 200	pink	{0,0,0}	-208.67317	346.4762	914.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:31.647
648	cube 201	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:31.649191
649	cylinder 164	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:31.651175
650	pentagonal prism 174	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:31.871315
651	cube 202	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:31.875347
652	cuboid 84	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:31.877327
653	cylinder 165	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:31.879759
654	pentagonal prism 175	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:32.112371
655	cube 203	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.420776	cube.usd	2025-03-29 15:38:32.115981
656	cuboid 85	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:32.118073
657	cylinder 166	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:32.120242
658	pentagonal prism 176	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:32.332515
659	cube 204	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:38:32.336278
660	cuboid 86	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:32.338506
661	cylinder 167	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:38:32.340586
662	pentagonal prism 177	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:32.57389
663	cube 205	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.534454	cube.usd	2025-03-29 15:38:32.57767
664	cuboid 87	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:32.580304
665	cylinder 168	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:32.582238
666	pentagonal prism 178	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:32.817069
667	cube 206	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.420776	cube.usd	2025-03-29 15:38:32.819761
668	hexagonal prism 40	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 15:38:32.822126
669	cylinder 169	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:32.82455
670	pentagonal prism 179	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:33.065996
671	cube 207	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:33.068322
672	pentagonal prism 180	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:33.070645
673	cylinder 170	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:33.073212
674	pentagonal prism 181	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:33.288034
675	cube 208	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:33.291377
676	cube 209	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:38:33.293433
677	cylinder 171	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:33.295363
678	pentagonal prism 182	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:33.517916
679	cube 210	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:33.52134
680	cuboid 88	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:38:33.52391
681	cylinder 172	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:33.525992
682	hexagonal prism 41	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:38:33.73653
683	cube 211	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:33.739631
684	cuboid 89	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:38:33.741658
685	cylinder 173	green	{0,0,0}	-272.65317	217.53194	938	0	0	26.56505	cylinder.usd	2025-03-29 15:38:33.744862
686	pentagonal prism 183	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:33.977607
687	cube 212	pink	{0,0,0}	-206.70456	346.4762	934	0	0	59.03625	cube.usd	2025-03-29 15:38:33.981317
688	pentagonal prism 184	red	{0,0,0}	32.482143	259.85715	929	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:38:33.983244
689	cylinder 174	green	{0,0,0}	-271.66885	217.53194	929	0	0	36.869896	cylinder.usd	2025-03-29 15:38:33.985081
690	pentagonal prism 185	black	{0,0,0}	-128.9374	521.6551	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:34.201282
691	cube 213	pink	{0,0,0}	-207.67778	347.44196	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:34.203771
692	cuboid 90	red	{0,0,0}	31.496155	260.82755	927.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:38:34.206244
693	cylinder 175	green	{0,0,0}	-272.6386	218.50458	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:38:34.208585
694	pentagonal prism 186	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:34.436857
695	cube 214	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:38:34.439526
696	hexagonal prism 42	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:38:34.441463
697	cylinder 176	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:34.443209
698	pentagonal prism 187	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:34.665854
699	cube 215	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:38:34.668201
700	cuboid 91	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:34.670059
701	cylinder 177	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:34.671925
702	pentagonal prism 188	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:34.892841
703	cube 216	pink	{0,0,0}	-207.68886	346.4762	938	0	0	59.03625	cube.usd	2025-03-29 15:38:34.895655
704	cube 217	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cube.usd	2025-03-29 15:38:34.897612
705	cylinder 178	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:34.89952
706	pentagonal prism 189	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:35.133152
707	cube 218	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:35.137061
708	cube 219	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:35.138944
709	cylinder 179	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:35.141356
710	pentagonal prism 190	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:35.365845
711	cube 220	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:35.368242
712	cuboid 92	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	cuboid.usd	2025-03-29 15:38:35.370183
713	cylinder 180	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:35.371965
714	pentagonal prism 191	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:35.591917
715	cube 221	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:35.596637
716	cube 222	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.647617	cube.usd	2025-03-29 15:38:35.599924
717	cylinder 181	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:38:35.603034
718	pentagonal prism 192	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:35.821337
719	cube 223	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:35.82387
720	hexagonal prism 43	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:38:35.826036
721	cylinder 182	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:38:35.828014
722	pentagonal prism 193	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:36.052627
723	cube 224	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:36.056391
724	pentagonal prism 194	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:38:36.058761
725	cylinder 183	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:36.060776
726	pentagonal prism 195	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:36.286391
727	cube 225	pink	{0,0,0}	-206.70456	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:36.288713
728	cuboid 93	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:36.290761
729	cylinder 184	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:36.292898
730	pentagonal prism 196	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:36.53774
731	cube 226	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:36.5404
732	cuboid 94	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cuboid.usd	2025-03-29 15:38:36.542738
733	cylinder 185	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:38:36.544757
734	pentagonal prism 197	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:36.770586
735	cube 227	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:38:36.773204
736	cube 228	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:38:36.775218
737	cylinder 186	green	{0,0,0}	-270.6119	216.68562	929	0	0	36.869896	cylinder.usd	2025-03-29 15:38:36.777211
738	pentagonal prism 198	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:37.002769
739	cube 229	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:38:37.006944
740	pentagonal prism 199	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:37.009319
741	cylinder 187	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:37.011542
742	pentagonal prism 200	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:37.258964
743	cube 230	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:37.262748
744	cuboid 95	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:37.26491
745	cylinder 188	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:37.266809
746	pentagonal prism 201	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:37.5178
747	cube 231	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:37.520077
748	cuboid 96	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:38:37.522058
749	cylinder 189	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:37.524116
750	pentagonal prism 202	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:37.778944
751	cube 232	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:38:37.7831
752	cube 233	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cube.usd	2025-03-29 15:38:37.786969
753	cylinder 190	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:37.79074
754	pentagonal prism 203	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:38.050154
755	cube 234	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:38.054594
756	pentagonal prism 204	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:38.061257
757	cylinder 191	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:38.063882
758	pentagonal prism 205	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:38.30286
759	cube 235	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:38:38.305216
760	pentagonal prism 206	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:38:38.307728
761	cylinder 192	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:38.309898
762	pentagonal prism 207	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:38.537718
763	cube 236	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:38.540071
764	hexagonal prism 44	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:38:38.542798
765	cylinder 193	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:38.545148
766	pentagonal prism 208	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:38.767717
767	cube 237	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:38:38.770124
768	cuboid 97	red	{0,0,0}	31.497837	259.85715	913.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:38:38.772242
769	cylinder 194	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:38.774363
770	pentagonal prism 209	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:39.019955
771	cube 238	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:39.024238
772	cuboid 98	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:38:39.026541
773	cylinder 195	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:39.028612
774	pentagonal prism 210	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:39.250054
775	cube 239	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:38:39.252496
776	cuboid 99	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	cuboid.usd	2025-03-29 15:38:39.254284
777	cylinder 196	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:39.255997
778	pentagonal prism 211	black	{0,0,0}	-129.44986	522.7403	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:39.478418
779	cube 240	pink	{0,0,0}	-208.50322	347.83475	920	0	0	59.743565	cube.usd	2025-03-29 15:38:39.482813
780	cuboid 100	red	{0,0,0}	31.621342	260.87607	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:39.485227
781	cylinder 197	green	{0,0,0}	-273.72223	218.38489	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:39.487713
782	pentagonal prism 212	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:39.727801
783	cube 241	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:38:39.730654
784	cuboid 101	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:38:39.732962
785	cylinder 198	green	{0,0,0}	-272.65317	217.53194	924	0	0	38.65981	cylinder.usd	2025-03-29 15:38:39.734971
786	pentagonal prism 213	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:39.955556
787	cube 242	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:39.958408
788	pentagonal prism 214	red	{0,0,0}	31.497837	259.85715	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:38:39.960823
789	cylinder 199	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:39.963
790	pentagonal prism 215	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:40.206496
791	cube 243	pink	{0,0,0}	-208.67317	346.4762	914.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:40.208691
792	cube 244	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:38:40.210764
793	cylinder 200	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:40.213277
794	pentagonal prism 216	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:40.438278
795	cube 245	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.62088	cube.usd	2025-03-29 15:38:40.44131
796	cube 246	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cube.usd	2025-03-29 15:38:40.443361
797	cylinder 201	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:40.445765
798	pentagonal prism 217	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:40.664827
799	cube 247	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:40.667837
800	cuboid 102	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:38:40.66964
801	cylinder 202	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:40.671366
802	pentagonal prism 218	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:40.958115
803	cube 248	pink	{0,0,0}	-206.70456	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:40.962194
804	hexagonal prism 45	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:38:40.964468
805	cylinder 203	green	{0,0,0}	-271.66885	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:40.966369
806	pentagonal prism 219	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:41.203684
807	cube 249	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:38:41.206904
808	cuboid 103	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:38:41.21011
809	cylinder 204	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:41.213379
810	pentagonal prism 220	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:41.439098
811	cube 250	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:41.441706
812	cuboid 104	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:41.443612
813	cylinder 205	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:41.44565
814	pentagonal prism 221	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:41.65952
815	cube 251	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:41.662479
816	hexagonal prism 46	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:38:41.66556
817	cylinder 206	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:41.668391
818	pentagonal prism 222	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:41.919497
819	cube 252	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:41.921927
820	cuboid 105	red	{0,0,0}	31.497837	259.85715	935.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:41.92389
821	cylinder 207	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:41.925762
822	pentagonal prism 223	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:42.144298
823	cube 253	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:38:42.146694
824	pentagonal prism 224	red	{0,0,0}	32.355774	258.8462	929	0	0	36.869892	pentagonal prism.usd	2025-03-29 15:38:42.148997
825	cylinder 208	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:42.151184
826	pentagonal prism 225	black	{0,0,0}	-127.45538	519.6258	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:42.379134
827	cube 254	pink	{0,0,0}	-205.88947	346.0904	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:42.382526
828	cuboid 106	red	{0,0,0}	32.354057	259.8129	926.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:38:42.385421
829	cylinder 209	green	{0,0,0}	-270.59756	217.65457	933	0	0	26.56505	cylinder.usd	2025-03-29 15:38:42.388391
830	pentagonal prism 226	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:42.603366
831	cube 255	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:42.605531
832	cuboid 107	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:38:42.607443
833	cylinder 210	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:42.609351
834	pentagonal prism 227	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:42.850518
835	cube 256	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:42.852767
836	pentagonal prism 228	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:38:42.854723
837	cylinder 211	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:42.85665
838	pentagonal prism 229	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:43.084472
839	cube 257	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:43.088367
840	cube 258	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:43.090243
841	cylinder 212	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:43.092045
842	pentagonal prism 230	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:43.325908
843	cube 259	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:43.331109
844	cuboid 108	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:43.333868
845	cylinder 213	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:43.335954
846	pentagonal prism 231	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:43.572872
847	cube 260	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:38:43.576628
848	cuboid 109	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	cuboid.usd	2025-03-29 15:38:43.578656
849	cylinder 214	green	{0,0,0}	-272.65317	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:43.581074
850	pentagonal prism 232	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:43.820317
851	cube 261	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:38:43.824131
852	cuboid 110	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:38:43.826026
853	cylinder 215	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:43.827961
854	pentagonal prism 233	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:44.093218
855	cube 262	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.743565	cube.usd	2025-03-29 15:38:44.095859
856	cuboid 111	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:44.097996
857	cylinder 216	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:44.100188
858	pentagonal prism 234	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:38:44.326786
859	cube 263	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 15:38:44.330825
860	cube 264	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:44.333411
861	cylinder 217	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:44.335701
862	pentagonal prism 235	black	{0,0,0}	-127.95996	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:44.565782
863	cube 265	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:38:44.569619
864	pentagonal prism 236	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:44.571893
865	cylinder 218	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:44.573969
866	pentagonal prism 237	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:44.806457
867	cube 266	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:44.810226
868	cube 267	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.874985	cube.usd	2025-03-29 15:38:44.812248
869	cylinder 219	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:44.814486
870	pentagonal prism 238	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:45.030578
871	cube 268	pink	{0,0,0}	-208.67317	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:38:45.033597
872	cuboid 112	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:45.035804
873	cylinder 220	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:45.038048
874	pentagonal prism 239	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:45.262949
875	cube 269	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:45.265448
876	cylinder 222	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.874985	cylinder.usd	2025-03-29 15:38:45.268087
877	cylinder 223	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:45.271896
878	hexagonal prism 47	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:38:45.501266
879	cube 270	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.534454	cube.usd	2025-03-29 15:38:45.503758
880	cuboid 113	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:45.505987
881	cylinder 224	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:45.507996
882	hexagonal prism 48	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:38:45.731251
883	cube 271	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.34933	cube.usd	2025-03-29 15:38:45.733897
884	pentagonal prism 240	red	{0,0,0}	31.497837	259.85715	915	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:38:45.735813
885	cylinder 225	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:38:45.737782
886	pentagonal prism 241	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:45.963241
887	cube 272	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:38:45.965452
888	cuboid 114	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:45.967861
889	cylinder 226	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:45.97083
890	pentagonal prism 242	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:46.206635
891	cube 273	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:38:46.209088
892	cuboid 115	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:46.211008
893	cylinder 227	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:46.2129
894	pentagonal prism 243	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:46.433158
895	cube 274	pink	{0,0,0}	-208.67317	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:46.435617
896	cuboid 116	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:38:46.437458
897	cylinder 228	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:46.43943
898	pentagonal prism 244	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:46.663535
899	cube 275	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:46.666101
900	hexagonal prism 49	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:38:46.668469
901	cylinder 229	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:46.670518
902	pentagonal prism 245	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:46.89417
903	cube 276	pink	{0,0,0}	-209.49138	347.83475	920	0	0	59.93142	cube.usd	2025-03-29 15:38:46.896776
904	cuboid 117	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:46.898665
905	cylinder 230	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:46.900772
906	pentagonal prism 246	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:47.131116
907	cube 277	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03624	cube.usd	2025-03-29 15:38:47.133774
908	hexagonal prism 50	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:38:47.135746
909	cylinder 231	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:38:47.137714
910	pentagonal prism 247	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:47.365307
911	cube 278	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:47.369745
912	pentagonal prism 248	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:47.371778
913	cylinder 232	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:47.374081
914	pentagonal prism 249	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:38:47.595954
915	cube 279	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.743565	cube.usd	2025-03-29 15:38:47.598499
916	cube 280	red	{0,0,0}	32.482143	259.85715	932.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:47.600762
917	cylinder 233	green	{0,0,0}	-271.66885	217.53194	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:47.60272
918	hexagonal prism 51	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:38:47.829076
919	cube 281	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:47.833505
920	pentagonal prism 250	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:38:47.83584
921	cylinder 234	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:47.837924
922	hexagonal prism 52	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:38:48.063452
923	cube 282	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:48.065679
924	cuboid 118	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:48.068032
925	cylinder 235	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:38:48.070508
926	pentagonal prism 251	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:48.291516
927	cube 283	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:38:48.295645
928	cube 284	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:48.297648
929	cylinder 236	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:48.299621
930	pentagonal prism 252	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:48.542804
931	cube 285	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:48.546616
932	cube 286	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:48.548809
933	cylinder 237	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:38:48.550784
934	pentagonal prism 253	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:48.774533
935	cube 287	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:48.778342
936	cuboid 119	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:48.780374
937	cylinder 238	green	{0,0,0}	-272.65317	217.53194	920	0	0	18.434948	cylinder.usd	2025-03-29 15:38:48.782482
938	pentagonal prism 254	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:49.000172
939	cube 288	pink	{0,0,0}	-205.90038	345.12823	937.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:49.003978
940	cuboid 120	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:49.006205
941	cylinder 239	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:38:49.008285
942	pentagonal prism 255	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:49.240738
943	cube 289	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:49.244649
944	pentagonal prism 256	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:49.246604
945	cylinder 240	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:38:49.248627
946	pentagonal prism 257	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:49.468029
947	cube 290	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:49.470954
948	pentagonal prism 258	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:49.473284
949	cylinder 241	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:38:49.475298
950	pentagonal prism 259	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:49.707077
951	cube 291	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:38:49.710539
952	cube 292	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.405357	cube.usd	2025-03-29 15:38:49.712388
953	cylinder 242	green	{0,0,0}	-271.66885	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:49.714534
954	pentagonal prism 260	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:49.944861
955	cube 293	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:38:49.948798
956	hexagonal prism 53	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:38:49.951453
957	cylinder 243	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:49.954341
958	pentagonal prism 261	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:50.183616
959	cube 294	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:50.187315
960	cube 295	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:38:50.18944
961	cylinder 244	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:50.191383
962	pentagonal prism 262	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:50.426118
963	cube 296	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:38:50.428706
964	cuboid 121	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:38:50.430742
965	cylinder 245	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:50.432768
966	hexagonal prism 54	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:38:50.663174
967	cube 297	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:50.666776
968	cuboid 122	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:38:50.668754
969	cylinder 246	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:50.671522
970	pentagonal prism 263	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:50.883237
971	cube 298	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:38:50.885696
972	cuboid 123	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:50.888128
973	cylinder 247	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:50.890318
974	hexagonal prism 55	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:38:51.118109
975	cube 299	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:51.122138
976	pentagonal prism 264	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:38:51.124135
977	cylinder 248	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:51.126252
978	pentagonal prism 265	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:51.359726
979	cube 300	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:51.363623
980	pentagonal prism 266	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:38:51.365538
981	cylinder 249	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:51.367453
982	pentagonal prism 267	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:38:51.587711
983	cube 301	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.420776	cube.usd	2025-03-29 15:38:51.591884
984	cube 302	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.746803	cube.usd	2025-03-29 15:38:51.594109
985	cylinder 250	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:38:51.596113
986	pentagonal prism 268	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:51.828482
987	cube 303	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:38:51.83082
988	pentagonal prism 269	red	{0,0,0}	32.355774	258.8462	929	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:38:51.832676
989	cylinder 251	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:51.834427
990	pentagonal prism 270	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	pentagonal prism.usd	2025-03-29 15:38:52.057389
991	cube 304	pink	{0,0,0}	-209.49138	347.83475	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:38:52.061298
992	cuboid 124	red	{0,0,0}	31.621342	260.87607	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:38:52.063317
993	cylinder 252	green	{0,0,0}	-273.72223	218.38489	929	0	0	26.56505	cylinder.usd	2025-03-29 15:38:52.065242
994	pentagonal prism 271	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:38:52.294627
995	cube 305	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:38:52.299067
996	cube 306	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	cube.usd	2025-03-29 15:38:52.300913
997	cylinder 253	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:52.302787
998	hexagonal prism 56	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:38:52.524183
999	cube 307	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:38:52.528198
1000	pentagonal prism 272	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:38:52.530182
1001	cylinder 254	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:38:52.531985
1002	pentagonal prism 273	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:52.750136
1003	cube 308	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:38:52.752558
1004	pentagonal prism 274	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:38:52.754662
1005	cylinder 255	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:38:52.756686
1006	pentagonal prism 275	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:38:52.968637
1007	cube 309	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:38:52.971499
1008	cuboid 125	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:38:52.973797
1009	cylinder 256	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:38:52.975662
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
1	2025-03-29 15:36:46.950544	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-03-29 15:36:46.950544	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 15:36:46.950544
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 15:36:46.950544
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-03-29 15:36:46.950544
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
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-03-29 15:36:46.950544
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-03-29 15:36:46.950544
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
1	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscar.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	2025-03-29 15:36:46.950544	2025-03-29 15:36:46.950544
2	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahul.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\N	\N	2025-03-29 15:36:46.950544	2025-03-29 15:36:46.950544
3	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanjay.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	2025-03-29 15:36:46.950544	2025-03-29 15:36:46.950544
4	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehdi.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	2025-03-29 15:36:46.950544	2025-03-29 15:36:46.950544
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 1009, true);


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

