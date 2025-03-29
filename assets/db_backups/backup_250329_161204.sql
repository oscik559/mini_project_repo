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
12	cube 8	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:51:07.06101
2	cube 2	pink	{0,0,0}	-206.71245	344.52072	924	0	0	59.743565	cube.usd	2025-03-29 16:11:21.5961
3	wedge 2	green	{0.01,0.01,0}	119.10574	350.42682	1916.0001	0	0	5.225927	wedge.usd	2025-03-29 16:11:21.598947
6	pentagonal prism 4	red	{0,0,0}	30.514694	260.8514	945.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:21.601456
10	pentagonal prism 5	black	{0,0,0}	-127.96484	518.7498	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:21.815948
8	hexagonal prism 2	red	{0,0,0}	30.514694	259.86707	946.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 16:11:21.822608
14	pentagonal prism 6	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:22.048183
4	cube 4	pink	{0,0,0}	-206.70456	345.4919	919	0	0	59.534454	cube.usd	2025-03-29 16:11:22.052738
18	pentagonal prism 7	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:22.055729
9	cylinder 4	green	{0,0,0}	-271.66885	217.53194	891.00006	0	0	45	cylinder.usd	2025-03-29 16:11:22.058534
22	pentagonal prism 8	black	{0,0,0}	-129.44986	521.75214	656	0	0	90	pentagonal prism.usd	2025-03-29 16:11:22.283146
13	cylinder 5	green	{0,0,0}	-273.72223	218.38489	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:22.291121
7	cube 6	pink	{0,0,0}	-208.50322	346.8466	918.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:22.525541
17	cylinder 6	green	{0,0,0}	-273.72223	218.38489	937.00006	0	0	90	cylinder.usd	2025-03-29 16:11:22.530903
32	pentagonal prism 12	black	{0,0,0}	-129.44986	521.75214	657	0	0	90	pentagonal prism.usd	2025-03-29 16:11:22.75014
11	cube 7	pink	{0,0,0}	-208.50322	346.8466	932.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:22.753262
15	cube 9	red	{0,0,0}	30.633175	260.87607	926.00006	0	0	37.874985	cube.usd	2025-03-29 16:11:22.755929
21	cylinder 7	green	{0,0,0}	-273.72223	218.38489	929	0	0	26.56505	cylinder.usd	2025-03-29 16:11:22.758498
16	hexagonal prism 4	black	{0,0,0}	-129.44986	521.75214	657	0	0	90	hexagonal prism.usd	2025-03-29 16:11:22.968437
19	cube 10	pink	{0,0,0}	-208.50322	346.8466	912.00006	0	0	59.420776	cube.usd	2025-03-29 16:11:22.971576
36	cuboid 2	red	{0,0,0}	31.621342	260.87607	917.00006	0	0	37.69424	cuboid.usd	2025-03-29 16:11:22.974048
25	cylinder 8	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	45	cylinder.usd	2025-03-29 16:11:22.976808
34	pentagonal prism 13	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:23.202269
23	cube 11	pink	{0,0,0}	-208.50322	346.8466	921.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:23.206725
40	cuboid 3	red	{0,0,0}	31.621342	260.87607	915	0	0	37.874985	cuboid.usd	2025-03-29 16:11:23.20965
38	pentagonal prism 14	black	{0,0,0}	-129.44986	521.75214	657	0	0	90	pentagonal prism.usd	2025-03-29 16:11:23.435917
27	cube 12	pink	{0,0,0}	-208.50322	346.8466	913.00006	0	0	59.420776	cube.usd	2025-03-29 16:11:23.440548
42	pentagonal prism 15	red	{0,0,0}	31.621342	260.87607	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:23.443217
28	cylinder 10	green	{0,0,0}	-273.72223	218.38489	923.00006	0	0	45	cylinder.usd	2025-03-29 16:11:23.445632
46	pentagonal prism 16	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:23.669196
31	cube 13	pink	{0,0,0}	-208.50322	346.8466	924	0	0	59.62088	cube.usd	2025-03-29 16:11:23.674131
50	pentagonal prism 17	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:23.676913
29	cylinder 11	green	{0,0,0}	-273.72223	218.38489	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:23.679815
54	pentagonal prism 18	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:23.902695
35	cube 14	pink	{0,0,0}	-208.50322	346.8466	920	0	0	59.34933	cube.usd	2025-03-29 16:11:23.905733
33	cylinder 12	green	{0,0,0}	-273.72223	218.38489	935.00006	0	0	45	cylinder.usd	2025-03-29 16:11:23.910735
39	cube 15	pink	{0,0,0}	-208.50322	346.8466	929	0	0	59.620872	cube.usd	2025-03-29 16:11:24.124308
37	cylinder 13	green	{0,0,0}	-273.72223	218.38489	924	0	0	45	cylinder.usd	2025-03-29 16:11:24.129407
43	cube 16	pink	{0,0,0}	-209.49138	346.8466	923.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:24.356432
41	cylinder 14	green	{0,0,0}	-273.72223	218.38489	926.00006	0	0	90	cylinder.usd	2025-03-29 16:11:24.361715
44	cube 17	pink	{0,0,0}	-208.50322	346.8466	925.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:24.589927
45	cylinder 15	green	{0,0,0}	-273.72223	218.38489	929	0	0	45	cylinder.usd	2025-03-29 16:11:24.595296
47	cube 18	pink	{0,0,0}	-206.70456	345.4919	933	0	0	59.620872	cube.usd	2025-03-29 16:11:24.831229
49	cylinder 16	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	45	cylinder.usd	2025-03-29 16:11:24.837824
48	cube 19	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.534454	cube.usd	2025-03-29 16:11:25.057072
53	cylinder 17	green	{0,0,0}	-271.66885	217.53194	929	0	0	45	cylinder.usd	2025-03-29 16:11:25.062179
51	cube 20	pink	{0,0,0}	-209.49138	346.8466	917.00006	0	0	59.420776	cube.usd	2025-03-29 16:11:25.29049
20	hexagonal prism 5	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	hexagonal prism.usd	2025-03-29 16:11:27.15517
52	cuboid 4	red	{0,0,0}	31.621342	260.87607	924	0	0	37.874985	cuboid.usd	2025-03-29 16:11:28.097437
24	hexagonal prism 6	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	hexagonal prism.usd	2025-03-29 16:11:29.722225
564	hexagonal prism 25	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:51.325198
1190	hexagonal prism 249	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:37.565594
56	pentagonal prism 19	red	{0,0,0}	31.621342	260.87607	915	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:23.908179
58	pentagonal prism 20	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:24.121537
62	pentagonal prism 21	red	{0,0,0}	30.633175	260.87607	925.00006	0	0	37.40536	pentagonal prism.usd	2025-03-29 16:11:24.126728
66	pentagonal prism 23	red	{0,0,0}	31.621342	260.87607	923.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 16:11:24.359037
68	pentagonal prism 24	black	{0,0,0}	-129.44986	521.75214	657	0	0	90	pentagonal prism.usd	2025-03-29 16:11:24.585541
70	pentagonal prism 25	red	{0,0,0}	31.621342	260.87607	913.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:24.592591
74	pentagonal prism 26	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:24.826453
76	pentagonal prism 27	red	{0,0,0}	32.482143	259.85715	910	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:24.834763
78	pentagonal prism 28	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	pentagonal prism.usd	2025-03-29 16:11:25.05375
80	pentagonal prism 29	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 16:11:25.059557
82	pentagonal prism 30	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:25.28707
86	pentagonal prism 31	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:25.29293
57	cylinder 18	green	{0,0,0}	-273.72223	218.38489	934	0	0	45	cylinder.usd	2025-03-29 16:11:25.295501
88	pentagonal prism 32	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:25.521644
90	pentagonal prism 33	red	{0,0,0}	31.621342	260.87607	913.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:25.527469
61	cylinder 19	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:25.530416
92	pentagonal prism 34	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:25.752702
59	cube 22	pink	{0,0,0}	-209.49138	346.8466	918.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:25.757063
94	pentagonal prism 35	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:25.759536
65	cylinder 20	green	{0,0,0}	-273.72223	218.38489	932.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:25.762087
98	pentagonal prism 36	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:25.991206
60	cube 23	pink	{0,0,0}	-206.70456	345.4919	921.00006	0	0	59.34933	cube.usd	2025-03-29 16:11:25.99576
102	pentagonal prism 37	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:25.998612
69	cylinder 21	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:26.001703
104	pentagonal prism 38	black	{0,0,0}	-129.44986	521.75214	656	0	0	90	pentagonal prism.usd	2025-03-29 16:11:26.220678
63	cube 24	pink	{0,0,0}	-209.49138	346.8466	927.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:26.224063
67	cube 25	red	{0,0,0}	30.633175	260.87607	927.00006	0	0	37.69424	cube.usd	2025-03-29 16:11:26.226512
73	cylinder 22	green	{0,0,0}	-273.72223	218.38489	929	0	0	33.690063	cylinder.usd	2025-03-29 16:11:26.229229
106	pentagonal prism 39	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:26.455182
71	cube 26	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.743565	cube.usd	2025-03-29 16:11:26.460128
77	cylinder 23	green	{0,0,0}	-273.72223	218.38489	934	0	0	33.690063	cylinder.usd	2025-03-29 16:11:26.465254
72	cube 27	pink	{0,0,0}	-209.49138	346.8466	921.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:26.693345
81	cylinder 24	green	{0,0,0}	-273.72223	218.38489	930.00006	0	0	45	cylinder.usd	2025-03-29 16:11:26.698467
75	cube 28	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.03625	cube.usd	2025-03-29 16:11:26.925945
85	cylinder 25	green	{0,0,0}	-273.72223	218.38489	929	0	0	90	cylinder.usd	2025-03-29 16:11:26.931118
79	cube 29	pink	{0,0,0}	-207.68886	345.4919	928.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:27.159725
89	cylinder 26	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	45	cylinder.usd	2025-03-29 16:11:27.164892
83	cube 30	pink	{0,0,0}	-208.50322	346.8466	918.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:27.391853
93	cylinder 27	green	{0,0,0}	-273.72223	218.38489	929	0	0	45	cylinder.usd	2025-03-29 16:11:27.397619
87	cube 31	pink	{0,0,0}	-209.49138	346.8466	923.00006	0	0	59.420776	cube.usd	2025-03-29 16:11:27.628102
97	cylinder 28	green	{0,0,0}	-273.72223	218.38489	929	0	0	33.690063	cylinder.usd	2025-03-29 16:11:27.634515
91	cube 32	pink	{0,0,0}	-209.49138	346.8466	929	0	0	59.620872	cube.usd	2025-03-29 16:11:27.859801
101	cylinder 29	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:27.864893
95	cube 33	pink	{0,0,0}	-209.49138	346.8466	929	0	0	59.534454	cube.usd	2025-03-29 16:11:28.094511
99	cube 34	pink	{0,0,0}	-207.68886	345.4919	915	0	0	59.03624	cube.usd	2025-03-29 16:11:28.326359
103	cube 35	pink	{0,0,0}	-209.49138	346.8466	927.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:28.564893
107	cube 36	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.34933	cube.usd	2025-03-29 16:11:28.792345
84	hexagonal prism 7	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:30.425965
1191	cube 355	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:37.570192
110	pentagonal prism 41	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:26.688281
114	pentagonal prism 42	red	{0,0,0}	30.633175	260.87607	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 16:11:26.695952
118	pentagonal prism 43	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:26.922671
122	pentagonal prism 44	red	{0,0,0}	31.621342	260.87607	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:26.928446
124	pentagonal prism 45	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:27.162206
126	pentagonal prism 46	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:27.388383
130	pentagonal prism 47	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:27.394972
134	pentagonal prism 48	black	{0,0,0}	-129.44986	521.75214	656	0	0	90	pentagonal prism.usd	2025-03-29 16:11:27.623326
138	pentagonal prism 50	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:27.855479
142	pentagonal prism 51	red	{0,0,0}	30.633175	260.87607	921.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 16:11:27.862432
146	pentagonal prism 52	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:28.089897
105	cylinder 30	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	45	cylinder.usd	2025-03-29 16:11:28.100127
150	pentagonal prism 53	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:28.323009
154	pentagonal prism 54	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:28.328804
158	pentagonal prism 55	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:28.560334
113	cylinder 32	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	45	cylinder.usd	2025-03-29 16:11:28.570624
117	cylinder 33	green	{0,0,0}	-273.72223	218.38489	923.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:28.797884
121	cylinder 34	green	{0,0,0}	-271.66885	217.53194	920	0	0	45	cylinder.usd	2025-03-29 16:11:29.032331
115	cube 38	pink	{0,0,0}	-209.49138	346.8466	927.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:29.261921
125	cylinder 35	green	{0,0,0}	-273.72223	218.38489	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:29.268335
119	cube 39	pink	{0,0,0}	-209.49138	346.8466	919	0	0	59.534454	cube.usd	2025-03-29 16:11:29.494423
129	cylinder 36	green	{0,0,0}	-273.72223	218.38489	922.00006	0	0	45	cylinder.usd	2025-03-29 16:11:29.499521
123	cube 40	pink	{0,0,0}	-207.68886	345.4919	921.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:29.726212
133	cylinder 37	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:29.731987
127	cube 41	pink	{0,0,0}	-207.68886	345.4919	925.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:29.962357
137	cylinder 38	green	{0,0,0}	-271.66885	217.53194	934	0	0	18.43495	cylinder.usd	2025-03-29 16:11:29.967244
128	cube 42	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.03625	cube.usd	2025-03-29 16:11:30.194912
141	cylinder 39	green	{0,0,0}	-271.66885	217.53194	924	0	0	18.434948	cylinder.usd	2025-03-29 16:11:30.200253
131	cube 43	pink	{0,0,0}	-209.49138	346.8466	933	0	0	59.534454	cube.usd	2025-03-29 16:11:30.430727
145	cylinder 40	green	{0,0,0}	-273.72223	218.38489	928.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:30.436582
132	cube 44	pink	{0,0,0}	-207.68886	345.4919	923.00006	0	0	59.34933	cube.usd	2025-03-29 16:11:30.661722
149	cylinder 41	green	{0,0,0}	-271.66885	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 16:11:30.666939
135	cube 45	pink	{0,0,0}	-209.49138	346.8466	934	0	0	59.03625	cube.usd	2025-03-29 16:11:30.893814
153	cylinder 42	green	{0,0,0}	-273.72223	218.38489	928.00006	0	0	45	cylinder.usd	2025-03-29 16:11:30.898813
139	cube 46	pink	{0,0,0}	-209.49138	346.8466	920	0	0	59.03625	cube.usd	2025-03-29 16:11:31.111849
157	cylinder 43	green	{0,0,0}	-273.72223	218.38489	936.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:31.117127
148	hexagonal prism 9	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:31.341908
140	cube 47	pink	{0,0,0}	-207.68886	345.4919	919	0	0	59.03625	cube.usd	2025-03-29 16:11:31.346645
161	cylinder 44	green	{0,0,0}	-271.66885	217.53194	929	0	0	33.690063	cylinder.usd	2025-03-29 16:11:31.351852
143	cube 48	pink	{0,0,0}	-209.49138	346.8466	926.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:31.578676
144	cube 49	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.34933	cube.usd	2025-03-29 16:11:31.816075
147	cube 50	pink	{0,0,0}	-207.68886	345.4919	917.00006	0	0	59.34933	cube.usd	2025-03-29 16:11:32.049713
151	cube 51	pink	{0,0,0}	-206.70456	345.4919	921.00006	0	0	59.34933	cube.usd	2025-03-29 16:11:32.276789
152	cube 52	pink	{0,0,0}	-209.49138	346.8466	916.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:32.514475
155	cube 53	pink	{0,0,0}	-207.68886	345.4919	920	0	0	59.743565	cube.usd	2025-03-29 16:11:32.749898
159	cube 54	pink	{0,0,0}	-209.49138	346.8466	921.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:32.980842
160	cube 55	pink	{0,0,0}	-209.49138	346.8466	922.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:33.219264
116	cuboid 7	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 16:11:33.448897
120	cuboid 8	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.874985	cuboid.usd	2025-03-29 16:11:52.739748
156	cuboid 9	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.405357	cuboid.usd	2025-03-29 16:11:52.967396
1192	cylinder 288	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:44:37.574426
1193	cube 356	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:44:37.793063
109	cylinder 31	green	{0,0,0}	-271.66885	217.53194	935.00006	0	0	45	cylinder.usd	2025-03-29 16:11:28.331499
166	pentagonal prism 57	black	{0,0,0}	-129.44986	521.75214	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:28.788788
170	pentagonal prism 58	red	{0,0,0}	30.633175	260.87607	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:28.795109
174	pentagonal prism 59	black	{0,0,0}	-127.95996	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 16:11:29.023974
178	pentagonal prism 60	red	{0,0,0}	32.482143	259.85715	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:29.029632
182	pentagonal prism 61	black	{0,0,0}	-129.44986	521.75214	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:29.25732
186	pentagonal prism 62	red	{0,0,0}	31.621342	260.87607	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:29.264959
188	pentagonal prism 63	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:29.489634
190	pentagonal prism 64	red	{0,0,0}	31.621342	260.87607	910	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:29.49702
194	pentagonal prism 65	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:29.729242
198	pentagonal prism 67	red	{0,0,0}	32.482143	259.85715	915	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:29.96478
200	pentagonal prism 68	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:30.190102
202	pentagonal prism 69	red	{0,0,0}	32.482143	259.85715	912.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:30.197723
206	pentagonal prism 70	red	{0,0,0}	31.621342	260.87607	912.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:30.433428
210	pentagonal prism 71	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:30.664373
212	pentagonal prism 72	black	{0,0,0}	-129.44986	521.75214	661	0	0	90	pentagonal prism.usd	2025-03-29 16:11:30.890728
214	pentagonal prism 73	red	{0,0,0}	30.633175	260.87607	921.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 16:11:30.89619
173	cylinder 47	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:32.055262
204	hexagonal prism 10	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 16:11:32.279451
181	cylinder 49	green	{0,0,0}	-273.72223	218.38489	929	0	0	26.56505	cylinder.usd	2025-03-29 16:11:32.519634
185	cylinder 50	green	{0,0,0}	-271.66885	217.53194	929	0	0	90	cylinder.usd	2025-03-29 16:11:32.756068
189	cylinder 51	green	{0,0,0}	-273.72223	218.38489	924	0	0	36.869896	cylinder.usd	2025-03-29 16:11:32.985823
193	cylinder 52	green	{0,0,0}	-273.72223	218.38489	929	0	0	36.869896	cylinder.usd	2025-03-29 16:11:33.225488
163	cube 56	pink	{0,0,0}	-207.68886	345.4919	931.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:33.446514
197	cylinder 53	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:33.451514
167	cube 57	pink	{0,0,0}	-207.68886	345.4919	933	0	0	59.743565	cube.usd	2025-03-29 16:11:33.666992
201	cylinder 54	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 16:11:33.672464
171	cube 58	pink	{0,0,0}	-209.49138	346.8466	922.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:33.897011
205	cylinder 55	green	{0,0,0}	-273.72223	218.38489	934	0	0	36.869896	cylinder.usd	2025-03-29 16:11:33.902637
175	cube 59	pink	{0,0,0}	-207.68886	345.4919	926.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:34.132603
209	cylinder 56	green	{0,0,0}	-271.66885	217.53194	924	0	0	45	cylinder.usd	2025-03-29 16:11:34.137991
179	cube 60	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.420776	cube.usd	2025-03-29 16:11:34.368466
213	cylinder 57	green	{0,0,0}	-273.72223	218.38489	930.00006	0	0	45	cylinder.usd	2025-03-29 16:11:34.374267
180	cube 61	pink	{0,0,0}	-209.49138	346.8466	929	0	0	59.03625	cube.usd	2025-03-29 16:11:34.60163
183	cube 62	pink	{0,0,0}	-207.68886	345.4919	921.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:34.830672
187	cube 63	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 16:11:34.833317
191	cube 64	pink	{0,0,0}	-207.68886	345.4919	922.00006	0	0	59.34933	cube.usd	2025-03-29 16:11:35.051937
195	cube 65	pink	{0,0,0}	-209.49138	346.8466	922.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:35.278427
199	cube 66	pink	{0,0,0}	-207.68886	345.4919	929	0	0	59.534454	cube.usd	2025-03-29 16:11:35.497736
203	cube 67	pink	{0,0,0}	-207.68886	345.4919	929	0	0	59.620872	cube.usd	2025-03-29 16:11:35.733714
207	cube 68	pink	{0,0,0}	-207.68886	345.4919	929	0	0	59.534454	cube.usd	2025-03-29 16:11:35.96683
208	cube 69	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.534454	cube.usd	2025-03-29 16:11:36.202209
211	cube 70	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.620872	cube.usd	2025-03-29 16:11:36.432303
215	cube 71	pink	{0,0,0}	-207.68886	345.4919	919	0	0	59.534454	cube.usd	2025-03-29 16:11:36.668479
168	cuboid 11	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 16:11:57.1126
172	cuboid 12	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.405357	cuboid.usd	2025-03-29 16:11:58.049343
176	cuboid 13	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 16:11:58.503456
192	cuboid 15	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.69424	cuboid.usd	2025-03-29 16:12:02.076819
1194	cylinder 289	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.69424	cylinder.usd	2025-03-29 15:44:37.795056
253	cylinder 67	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:51:20.357246
228	cuboid 17	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:43:46.635209
232	cuboid 18	red	{0,0,0}	31.497837	259.85715	924	0	0	37.874985	cuboid.usd	2025-03-29 15:43:47.103389
240	cuboid 19	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:43:47.562566
256	cuboid 20	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:43:48.233412
264	cuboid 21	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:43:48.469903
268	cuboid 22	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:43:48.93583
220	pentagonal prism 75	red	{0,0,0}	31.621342	260.87607	915	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:31.114328
222	pentagonal prism 76	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:31.349176
226	pentagonal prism 77	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:31.575452
230	pentagonal prism 78	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:31.811954
234	pentagonal prism 79	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:31.818576
236	pentagonal prism 80	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:32.043906
238	pentagonal prism 81	red	{0,0,0}	32.482143	259.85715	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:32.05264
242	pentagonal prism 82	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:32.273645
246	pentagonal prism 83	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:32.509557
250	pentagonal prism 84	red	{0,0,0}	31.621342	260.87607	912.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:32.517146
252	pentagonal prism 85	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	pentagonal prism.usd	2025-03-29 16:11:32.744781
254	pentagonal prism 86	red	{0,0,0}	32.482143	259.85715	915	0	0	37.69424	pentagonal prism.usd	2025-03-29 16:11:32.752795
258	pentagonal prism 87	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:32.976387
262	pentagonal prism 88	black	{0,0,0}	-129.44986	521.75214	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:33.214668
266	pentagonal prism 89	red	{0,0,0}	31.621342	260.87607	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 16:11:33.222357
221	cylinder 59	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 16:11:34.83604
225	cylinder 60	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 16:11:35.057485
229	cylinder 61	green	{0,0,0}	-273.72223	218.38489	934	0	0	36.869896	cylinder.usd	2025-03-29 16:11:35.283691
233	cylinder 62	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:35.502951
241	cylinder 64	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 16:11:35.972161
245	cylinder 65	green	{0,0,0}	-273.72223	218.38489	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:36.20813
249	cylinder 66	green	{0,0,0}	-271.66885	217.53194	929	0	0	18.43495	cylinder.usd	2025-03-29 16:11:36.437352
257	cylinder 68	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	cylinder.usd	2025-03-29 16:11:36.671256
261	cylinder 69	green	{0,0,0}	-271.66885	217.53194	924	0	0	36.869896	cylinder.usd	2025-03-29 16:11:36.674019
265	cylinder 70	green	{0,0,0}	-271.66885	217.53194	929	0	0	33.690063	cylinder.usd	2025-03-29 16:11:36.909343
223	cube 73	pink	{0,0,0}	-207.68886	345.4919	922.00006	0	0	59.34933	cube.usd	2025-03-29 16:11:37.136465
269	cylinder 71	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:37.142056
224	cube 74	pink	{0,0,0}	-207.68886	345.4919	918.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:37.367815
227	cube 75	pink	{0,0,0}	-209.49138	346.8466	932.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:37.604222
231	cube 76	pink	{0,0,0}	-209.49138	346.8466	921.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:37.833561
235	cube 77	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.534454	cube.usd	2025-03-29 16:11:38.07044
239	cube 78	pink	{0,0,0}	-207.68886	345.4919	922.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:38.302129
243	cube 79	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.534454	cube.usd	2025-03-29 16:11:38.540022
247	cube 80	pink	{0,0,0}	-207.68886	345.4919	914.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:38.767276
248	cube 81	pink	{0,0,0}	-209.49138	346.8466	923.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:38.987702
251	cube 82	pink	{0,0,0}	-207.68886	345.4919	923.00006	0	0	59.34933	cube.usd	2025-03-29 16:11:39.223939
255	cube 83	pink	{0,0,0}	-209.49138	346.8466	922.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:39.454015
259	cube 84	pink	{0,0,0}	-209.49138	346.8466	925.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:39.685753
260	cube 85	pink	{0,0,0}	-207.68886	345.4919	919	0	0	59.03625	cube.usd	2025-03-29 16:11:39.92408
263	cube 86	pink	{0,0,0}	-209.49138	346.8466	921.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:40.154106
267	cube 87	pink	{0,0,0}	-207.68886	345.4919	920	0	0	59.743565	cube.usd	2025-03-29 16:11:40.387167
684	hexagonal prism 30	black	{0,0,0}	-127.95996	519.7143	657	0	0	90	hexagonal prism.usd	2025-03-29 16:11:52.960091
216	cuboid 16	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 16:12:03.246146
1195	cylinder 290	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:44:37.797176
272	cuboid 23	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:43:50.10509
288	cuboid 24	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:43:50.567716
292	cuboid 25	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:43:51.470205
296	cuboid 26	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:43:52.60396
304	cuboid 27	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:43:53.071717
312	cuboid 28	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	36.869896	cuboid.usd	2025-03-29 15:43:54.005119
316	cuboid 29	red	{0,0,0}	32.355774	258.8462	919	0	0	37.69424	cuboid.usd	2025-03-29 15:43:54.236657
766	cube 5	pink	{0,0,0}	-209.49138	346.8466	930.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:22.286261
270	pentagonal prism 90	black	{0,0,0}	-127.95996	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 16:11:33.443344
274	pentagonal prism 91	black	{0,0,0}	-127.95996	519.7143	657	0	0	90	pentagonal prism.usd	2025-03-29 16:11:33.66351
278	pentagonal prism 92	red	{0,0,0}	32.482143	259.85715	911.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:33.669595
282	pentagonal prism 93	black	{0,0,0}	-129.44986	521.75214	657	0	0	90	pentagonal prism.usd	2025-03-29 16:11:33.893133
284	pentagonal prism 94	red	{0,0,0}	31.621342	260.87607	915	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:33.899912
290	pentagonal prism 95	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:34.128176
294	pentagonal prism 96	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 16:11:34.135259
298	pentagonal prism 97	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:34.364072
302	pentagonal prism 98	red	{0,0,0}	31.621342	260.87607	923.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:34.604288
306	pentagonal prism 99	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	pentagonal prism.usd	2025-03-29 16:11:34.827514
308	pentagonal prism 100	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:35.048353
310	pentagonal prism 101	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:35.054641
314	pentagonal prism 102	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:35.27547
320	pentagonal prism 104	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:35.494034
322	pentagonal prism 105	red	{0,0,0}	32.482143	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:35.500194
300	hexagonal prism 14	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	hexagonal prism.usd	2025-03-29 16:11:36.899116
277	cylinder 73	green	{0,0,0}	-273.72223	218.38489	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:37.610406
281	cylinder 74	green	{0,0,0}	-273.72223	218.38489	935.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:37.838994
285	cylinder 75	green	{0,0,0}	-273.72223	218.38489	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:38.076338
289	cylinder 76	green	{0,0,0}	-271.66885	217.53194	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:38.308189
293	cylinder 77	green	{0,0,0}	-271.66885	217.53194	929	0	0	36.869896	cylinder.usd	2025-03-29 16:11:38.546076
297	cylinder 78	green	{0,0,0}	-271.66885	217.53194	934	0	0	33.690063	cylinder.usd	2025-03-29 16:11:38.772714
301	cylinder 79	green	{0,0,0}	-273.72223	218.38489	933	0	0	18.434948	cylinder.usd	2025-03-29 16:11:38.993049
309	cylinder 81	green	{0,0,0}	-273.72223	218.38489	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:39.459694
313	cylinder 82	green	{0,0,0}	-273.72223	218.38489	934	0	0	33.690063	cylinder.usd	2025-03-29 16:11:39.690738
317	cylinder 83	green	{0,0,0}	-271.66885	217.53194	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:39.929922
321	cylinder 84	red	{0,0,0}	31.621342	260.87607	922.00006	0	0	37.874985	cylinder.usd	2025-03-29 16:11:40.156781
275	cube 89	pink	{0,0,0}	-207.68886	345.4919	927.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:40.854355
276	cube 90	pink	{0,0,0}	-207.68886	345.4919	930.00006	0	0	59.34933	cube.usd	2025-03-29 16:11:41.088439
279	cube 91	pink	{0,0,0}	-207.68886	345.4919	923.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:41.320915
280	cube 92	pink	{0,0,0}	-207.68886	345.4919	917.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:41.556031
283	cube 93	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.03625	cube.usd	2025-03-29 16:11:41.784634
287	cube 94	pink	{0,0,0}	-209.49138	346.8466	922.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:42.008384
291	cube 95	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.03624	cube.usd	2025-03-29 16:11:42.237642
295	cube 96	pink	{0,0,0}	-209.49138	346.8466	915	0	0	59.534454	cube.usd	2025-03-29 16:11:42.474422
299	cube 97	pink	{0,0,0}	-209.49138	346.8466	916.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:42.705696
303	cube 98	pink	{0,0,0}	-207.68886	345.4919	927.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:42.941745
307	cube 99	pink	{0,0,0}	-207.68886	345.4919	926.00006	0	0	59.93142	cube.usd	2025-03-29 16:11:43.172643
311	cube 100	pink	{0,0,0}	-207.68886	345.4919	920	0	0	59.743565	cube.usd	2025-03-29 16:11:43.405119
315	cube 101	pink	{0,0,0}	-207.68886	345.4919	938	0	0	59.420776	cube.usd	2025-03-29 16:11:43.638365
319	cube 102	pink	{0,0,0}	-207.68886	345.4919	916.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:43.872676
323	cube 103	pink	{0,0,0}	-207.68886	345.4919	923.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:44.110409
1196	cube 357	pink	{0,0,0}	-206.70456	346.4762	931.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:38.017831
55	cube 21	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.03625	cube.usd	2025-03-29 16:11:25.524902
324	pentagonal prism 106	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:35.728919
326	pentagonal prism 107	red	{0,0,0}	32.482143	259.85715	913.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:35.736691
330	pentagonal prism 108	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:35.962254
332	pentagonal prism 109	black	{0,0,0}	-129.44986	521.75214	657	0	0	90	pentagonal prism.usd	2025-03-29 16:11:36.197552
336	cuboid 30	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	cuboid.usd	2025-03-29 15:43:55.152974
344	cuboid 31	red	{0,0,0}	32.482143	259.85715	919	0	0	37.405357	cuboid.usd	2025-03-29 15:43:55.606086
348	cuboid 32	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:43:55.842666
368	cuboid 33	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:43:57.459251
372	cuboid 34	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:43:58.393948
376	cuboid 35	red	{0,0,0}	31.621342	260.87607	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:43:58.625795
334	pentagonal prism 110	red	{0,0,0}	31.621342	260.87607	915	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:36.205124
338	pentagonal prism 111	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:36.429246
342	pentagonal prism 112	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:36.434749
346	pentagonal prism 113	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:36.663657
219	cube 72	pink	{0,0,0}	-207.68886	345.4919	919	0	0	59.534454	cube.usd	2025-03-29 16:11:36.903598
350	pentagonal prism 114	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:36.906227
354	pentagonal prism 115	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:37.132708
356	pentagonal prism 116	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:37.139005
358	pentagonal prism 117	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:37.364674
360	pentagonal prism 118	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:37.599487
362	pentagonal prism 119	red	{0,0,0}	31.621342	260.87607	920	0	0	37.69424	pentagonal prism.usd	2025-03-29 16:11:37.607299
366	pentagonal prism 120	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:37.830008
374	pentagonal prism 122	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:38.065939
329	cylinder 86	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:40.392178
333	cylinder 87	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:40.62981
337	cylinder 88	green	{0,0,0}	-271.66885	217.53194	924	0	0	36.869896	cylinder.usd	2025-03-29 16:11:40.859364
340	cylinder 89	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 16:11:41.093691
341	cylinder 90	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:41.325942
349	cylinder 92	green	{0,0,0}	-273.72223	218.38489	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:41.789827
353	cylinder 93	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:42.014261
357	cylinder 94	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	cylinder.usd	2025-03-29 16:11:42.240015
361	cylinder 95	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	38.65981	cylinder.usd	2025-03-29 16:11:42.242476
365	cylinder 96	green	{0,0,0}	-273.72223	218.38489	929	0	0	33.690063	cylinder.usd	2025-03-29 16:11:42.480148
369	cylinder 97	red	{0,0,0}	31.621342	260.87607	920	0	0	37.874985	cylinder.usd	2025-03-29 16:11:42.708367
373	cylinder 98	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 16:11:42.711462
377	cylinder 99	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:42.947712
328	cube 105	pink	{0,0,0}	-207.68886	345.4919	929	0	0	59.420776	cube.usd	2025-03-29 16:11:44.560278
331	cube 106	pink	{0,0,0}	-207.68886	345.4919	926.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:44.794555
335	cube 107	pink	{0,0,0}	-207.68886	345.4919	919	0	0	59.03625	cube.usd	2025-03-29 16:11:45.029797
339	cube 108	pink	{0,0,0}	-207.68886	345.4919	920	0	0	59.03624	cube.usd	2025-03-29 16:11:45.2523
343	cube 109	pink	{0,0,0}	-207.68886	345.4919	919	0	0	59.03624	cube.usd	2025-03-29 16:11:45.475441
347	cube 110	pink	{0,0,0}	-209.49138	346.8466	920	0	0	59.534454	cube.usd	2025-03-29 16:11:45.711971
351	cube 111	pink	{0,0,0}	-209.49138	346.8466	927.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:45.944079
352	cube 112	pink	{0,0,0}	-209.49138	346.8466	921.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:46.172705
355	cube 113	pink	{0,0,0}	-207.68886	345.4919	925.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:46.411179
359	cube 114	pink	{0,0,0}	-207.68886	345.4919	920	0	0	59.534454	cube.usd	2025-03-29 16:11:46.645464
367	cube 116	pink	{0,0,0}	-207.68886	345.4919	928.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:47.112974
371	cube 117	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.743565	cube.usd	2025-03-29 16:11:47.342037
375	cube 118	pink	{0,0,0}	-209.49138	346.8466	921.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:47.5783
1197	cube 358	red	{0,0,0}	32.482143	259.85715	933	0	0	37.568592	cube.usd	2025-03-29 15:44:38.020024
1198	cylinder 291	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:38.022293
382	pentagonal prism 124	black	{0,0,0}	-127.95996	519.7143	662.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:38.297128
386	pentagonal prism 125	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:38.305237
390	pentagonal prism 126	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:38.536479
394	pentagonal prism 127	red	{0,0,0}	32.482143	259.85715	909.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:38.543333
398	pentagonal prism 128	black	{0,0,0}	-127.95996	519.7143	657	0	0	90	pentagonal prism.usd	2025-03-29 16:11:38.763773
402	pentagonal prism 129	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:38.770081
406	pentagonal prism 130	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:38.982888
410	pentagonal prism 131	red	{0,0,0}	31.621342	260.87607	919	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:38.99025
412	pentagonal prism 132	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:39.220612
414	pentagonal prism 133	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:39.226715
418	pentagonal prism 134	black	{0,0,0}	-129.44986	521.75214	661	0	0	90	pentagonal prism.usd	2025-03-29 16:11:39.450066
420	pentagonal prism 135	red	{0,0,0}	31.621342	260.87607	915	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:39.456815
422	pentagonal prism 136	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:39.681396
424	pentagonal prism 137	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:39.688225
426	pentagonal prism 138	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:39.919493
392	hexagonal prism 17	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:41.083874
430	hexagonal prism 18	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 16:11:41.559109
381	cylinder 100	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:43.178777
385	cylinder 101	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:43.410265
389	cylinder 102	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:43.643143
393	cylinder 103	green	{0,0,0}	-271.66885	217.53194	933	0	0	33.690063	cylinder.usd	2025-03-29 16:11:43.877983
401	cylinder 105	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 16:11:44.344943
405	cylinder 106	green	{0,0,0}	-271.66885	217.53194	934	0	0	19.983107	cylinder.usd	2025-03-29 16:11:44.565755
409	cylinder 107	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:44.799801
413	cylinder 108	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:45.035057
417	cylinder 109	green	{0,0,0}	-271.66885	217.53194	937.00006	0	0	38.65981	cylinder.usd	2025-03-29 16:11:45.25918
421	cylinder 110	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 16:11:45.48064
425	cylinder 111	green	{0,0,0}	-273.72223	218.38489	934	0	0	36.869896	cylinder.usd	2025-03-29 16:11:45.717461
384	cuboid 36	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:44:00.027303
400	cuboid 37	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	36.869896	cuboid.usd	2025-03-29 15:44:00.263549
428	cuboid 38	red	{0,0,0}	32.482143	259.85715	928.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:44:00.491127
429	cylinder 112	green	{0,0,0}	-273.72223	218.38489	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:45.949564
383	cube 120	pink	{0,0,0}	-209.49138	346.8466	928.00006	0	0	59.420776	cube.usd	2025-03-29 16:11:48.044652
387	cube 121	pink	{0,0,0}	-207.68886	345.4919	925.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:48.275467
388	cube 122	pink	{0,0,0}	-207.68886	345.4919	923.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:48.512741
391	cube 123	pink	{0,0,0}	-209.49138	346.8466	929	0	0	59.534454	cube.usd	2025-03-29 16:11:48.746962
395	cube 124	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.534454	cube.usd	2025-03-29 16:11:48.979715
396	cube 125	pink	{0,0,0}	-207.68886	345.4919	927.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:49.216138
399	cube 126	pink	{0,0,0}	-209.49138	346.8466	934	0	0	59.03625	cube.usd	2025-03-29 16:11:49.44334
403	cube 127	pink	{0,0,0}	-207.68886	345.4919	923.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:49.677949
404	cube 128	pink	{0,0,0}	-207.68886	345.4919	930.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:49.91182
407	cube 129	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.743565	cube.usd	2025-03-29 16:11:50.150867
408	cube 130	pink	{0,0,0}	-207.68886	345.4919	926.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:50.386865
411	cube 131	pink	{0,0,0}	-209.49138	346.8466	920	0	0	59.743565	cube.usd	2025-03-29 16:11:50.62987
415	cube 132	pink	{0,0,0}	-209.49138	346.8466	925.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:50.866239
416	cube 133	pink	{0,0,0}	-207.68886	345.4919	930.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:51.101828
419	cube 134	pink	{0,0,0}	-209.49138	346.8466	929	0	0	59.743565	cube.usd	2025-03-29 16:11:51.329218
423	cube 135	pink	{0,0,0}	-207.68886	345.4919	925.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:51.571381
427	cube 136	pink	{0,0,0}	-207.68886	345.4919	928.00006	0	0	59.420776	cube.usd	2025-03-29 16:11:51.798914
431	cube 137	pink	{0,0,0}	-207.68886	345.4919	932.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:52.037015
1199	cube 359	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:44:38.254418
273	cylinder 72	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:37.37294
432	pentagonal prism 139	red	{0,0,0}	32.482143	259.85715	927.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:39.92678
434	pentagonal prism 140	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:40.150303
438	pentagonal prism 141	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:40.389631
442	pentagonal prism 142	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:40.620411
446	pentagonal prism 143	red	{0,0,0}	31.497837	259.85715	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 16:11:40.62704
450	pentagonal prism 144	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:40.850689
454	pentagonal prism 145	red	{0,0,0}	32.482143	259.85715	919	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:40.8568
458	pentagonal prism 146	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:41.09098
462	pentagonal prism 147	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:41.316526
466	pentagonal prism 148	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:41.323368
468	pentagonal prism 149	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:41.551032
474	pentagonal prism 150	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:41.78161
478	pentagonal prism 151	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:42.003112
482	pentagonal prism 152	red	{0,0,0}	30.633175	260.87607	922.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 16:11:42.011287
484	pentagonal prism 153	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:42.234467
470	hexagonal prism 20	red	{0,0,0}	31.497837	259.85715	929	0	0	37.303947	hexagonal prism.usd	2025-03-29 16:11:43.875524
437	cylinder 114	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:46.416396
441	cylinder 115	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 16:11:46.6507
445	cylinder 116	green	{0,0,0}	-271.66885	217.53194	935.00006	0	0	19.653824	cylinder.usd	2025-03-29 16:11:46.884421
449	cylinder 117	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 16:11:47.118034
453	cylinder 118	green	{0,0,0}	-273.72223	218.38489	929	0	0	18.43495	cylinder.usd	2025-03-29 16:11:47.347513
457	cylinder 119	green	{0,0,0}	-273.72223	218.38489	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:47.583471
461	cylinder 120	green	{0,0,0}	-271.66885	217.53194	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:47.814511
469	cylinder 122	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:48.280797
473	cylinder 123	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	cylinder.usd	2025-03-29 16:11:48.515971
477	cylinder 124	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 16:11:48.518653
481	cylinder 125	red	{0,0,0}	31.621342	260.87607	920	0	0	37.874985	cylinder.usd	2025-03-29 16:11:48.749433
485	cylinder 126	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:48.752057
439	cube 139	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.34933	cube.usd	2025-03-29 16:11:52.505762
443	cube 140	pink	{0,0,0}	-209.49138	346.8466	921.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:52.737197
444	cube 141	pink	{0,0,0}	-207.68886	345.4919	920	0	0	59.743565	cube.usd	2025-03-29 16:11:52.964402
447	cube 142	pink	{0,0,0}	-207.68886	345.4919	913.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:53.187572
448	cube 143	pink	{0,0,0}	-207.68886	345.4919	925.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:53.415902
451	cube 144	pink	{0,0,0}	-207.68886	345.4919	920	0	0	59.03625	cube.usd	2025-03-29 16:11:53.634588
455	cube 145	pink	{0,0,0}	-209.49138	346.8466	920	0	0	59.743565	cube.usd	2025-03-29 16:11:53.867824
436	cuboid 39	red	{0,0,0}	31.621342	260.87607	920	0	0	37.568592	cuboid.usd	2025-03-29 15:44:01.426951
452	cuboid 40	red	{0,0,0}	32.355774	258.8462	910	0	0	37.69424	cuboid.usd	2025-03-29 15:44:01.877771
456	cuboid 41	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:44:02.11353
464	cuboid 42	red	{0,0,0}	32.482143	259.85715	914.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:44:02.342572
459	cube 146	pink	{0,0,0}	-209.49138	346.8466	932.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:54.09545
472	cuboid 43	red	{0,0,0}	31.497837	259.85715	915	0	0	37.405357	cuboid.usd	2025-03-29 15:44:02.797601
476	cuboid 44	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:44:03.262705
460	cube 147	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.420776	cube.usd	2025-03-29 16:11:54.319313
463	cube 148	pink	{0,0,0}	-209.49138	346.8466	928.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:54.552991
467	cube 149	pink	{0,0,0}	-207.68886	345.4919	925.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:54.785856
471	cube 150	pink	{0,0,0}	-207.68886	345.4919	922.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:55.022582
475	cube 151	pink	{0,0,0}	-207.68886	345.4919	920	0	0	59.03625	cube.usd	2025-03-29 16:11:55.24979
479	cube 152	pink	{0,0,0}	-207.68886	345.4919	920	0	0	59.620872	cube.usd	2025-03-29 16:11:55.484703
480	cube 153	pink	{0,0,0}	-207.68886	345.4919	921.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:55.719225
483	cube 154	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.93142	cube.usd	2025-03-29 16:11:55.95148
1200	cuboid 89	red	{0,0,0}	32.482143	259.85715	912.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:38.256508
486	pentagonal prism 154	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:42.469591
488	pentagonal prism 155	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:42.477132
490	pentagonal prism 156	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:42.700513
494	pentagonal prism 157	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:42.937034
498	pentagonal prism 158	red	{0,0,0}	31.497837	259.85715	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:42.944462
502	pentagonal prism 159	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:43.167899
506	pentagonal prism 160	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:43.175705
508	pentagonal prism 161	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:43.402093
510	pentagonal prism 162	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:43.407644
518	pentagonal prism 163	black	{0,0,0}	-127.95996	519.7143	657	0	0	90	pentagonal prism.usd	2025-03-29 16:11:43.635554
522	pentagonal prism 164	red	{0,0,0}	32.482143	259.85715	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:43.640755
526	pentagonal prism 165	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:43.869059
534	pentagonal prism 166	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:44.105484
538	pentagonal prism 167	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:44.11334
327	cube 104	pink	{0,0,0}	-209.49138	346.8466	926.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:44.339528
514	hexagonal prism 22	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:46.167934
530	hexagonal prism 23	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:46.640713
493	cylinder 128	green	{0,0,0}	-271.66885	217.53194	934	0	0	33.690063	cylinder.usd	2025-03-29 16:11:49.221404
497	cylinder 129	green	{0,0,0}	-273.72223	218.38489	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:49.448604
501	cylinder 130	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:49.683369
496	cuboid 45	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:05.113966
505	cylinder 131	green	{0,0,0}	-271.66885	217.53194	929	0	0	33.690063	cylinder.usd	2025-03-29 16:11:49.917559
509	cylinder 132	green	{0,0,0}	-273.72223	218.38489	929	0	0	33.690063	cylinder.usd	2025-03-29 16:11:50.155851
513	cylinder 133	green	{0,0,0}	-271.66885	217.53194	937.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:50.392181
517	cylinder 134	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:50.635127
521	cylinder 135	green	{0,0,0}	-273.72223	218.38489	934	0	0	19.983107	cylinder.usd	2025-03-29 16:11:50.871613
525	cylinder 136	green	{0,0,0}	-271.66885	217.53194	942.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:51.107147
533	cylinder 138	green	{0,0,0}	-271.66885	217.53194	929	0	0	18.43495	cylinder.usd	2025-03-29 16:11:51.576603
500	cuboid 46	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:05.582941
512	cuboid 47	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:44:06.047525
516	cuboid 48	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	36.869896	cuboid.usd	2025-03-29 15:44:07.903795
537	cylinder 139	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	35.537674	cylinder.usd	2025-03-29 16:11:51.80415
520	cuboid 49	red	{0,0,0}	32.482143	259.85715	911.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:44:08.368398
491	cube 156	pink	{0,0,0}	-207.68886	345.4919	921.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:56.401103
524	cuboid 50	red	{0,0,0}	31.497837	259.85715	924	0	0	37.69424	cuboid.usd	2025-03-29 15:44:09.986279
492	cube 157	pink	{0,0,0}	-207.68886	345.4919	932.00006	0	0	59.534454	cube.usd	2025-03-29 16:11:56.635804
495	cube 158	pink	{0,0,0}	-207.68886	345.4919	923.00006	0	0	59.420776	cube.usd	2025-03-29 16:11:56.866174
532	cuboid 51	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:10.684643
499	cube 159	pink	{0,0,0}	-207.68886	345.4919	927.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:57.110248
503	cube 160	pink	{0,0,0}	-207.68886	345.4919	927.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:57.344855
507	cube 161	pink	{0,0,0}	-207.68886	345.4919	915	0	0	59.03625	cube.usd	2025-03-29 16:11:57.567757
511	cube 162	pink	{0,0,0}	-207.68886	345.4919	911.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:57.802544
515	cube 163	pink	{0,0,0}	-207.68886	345.4919	927.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:58.046664
519	cube 164	pink	{0,0,0}	-209.49138	346.8466	923.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:58.268796
523	cube 165	pink	{0,0,0}	-207.68886	345.4919	925.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:58.500774
527	cube 166	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.620872	cube.usd	2025-03-29 16:11:58.751035
528	cube 167	pink	{0,0,0}	-209.49138	346.8466	923.00006	0	0	59.93142	cube.usd	2025-03-29 16:11:58.973949
531	cube 168	pink	{0,0,0}	-207.68886	345.4919	929	0	0	59.534454	cube.usd	2025-03-29 16:11:59.207216
535	cube 169	pink	{0,0,0}	-209.49138	346.8466	921.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:59.438141
536	cube 170	pink	{0,0,0}	-207.68886	345.4919	930.00006	0	0	59.743565	cube.usd	2025-03-29 16:11:59.669482
539	cube 171	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.34933	cube.usd	2025-03-29 16:11:59.904224
3215	pentagonal prism 626	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:37.728639
542	pentagonal prism 168	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:44.334622
546	pentagonal prism 169	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 16:11:44.342314
1201	cylinder 292	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:38.258449
550	pentagonal prism 170	black	{0,0,0}	-127.95996	519.7143	657	0	0	90	pentagonal prism.usd	2025-03-29 16:11:44.556838
552	pentagonal prism 171	red	{0,0,0}	32.482143	259.85715	919	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:44.563074
554	pentagonal prism 172	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:44.790289
558	pentagonal prism 173	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:44.797203
562	pentagonal prism 175	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:45.032522
566	pentagonal prism 176	black	{0,0,0}	-127.95996	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 16:11:45.249049
568	pentagonal prism 177	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:45.25611
570	pentagonal prism 178	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:45.472379
574	pentagonal prism 179	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:45.478156
578	pentagonal prism 180	black	{0,0,0}	-129.44986	521.75214	661	0	0	90	pentagonal prism.usd	2025-03-29 16:11:45.707676
580	pentagonal prism 181	red	{0,0,0}	30.633175	260.87607	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:45.714528
582	pentagonal prism 182	red	{0,0,0}	31.621342	260.87607	932.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:45.946656
544	cuboid 52	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:11.362927
586	pentagonal prism 183	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:46.17694
590	pentagonal prism 184	black	{0,0,0}	-127.95996	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 16:11:46.406638
592	hexagonal prism 26	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	hexagonal prism.usd	2025-03-29 16:11:51.795787
541	cylinder 140	green	{0,0,0}	-271.66885	217.53194	942.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:52.042262
545	cylinder 141	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:52.27083
549	cylinder 142	green	{0,0,0}	-271.66885	217.53194	934	0	0	36.869896	cylinder.usd	2025-03-29 16:11:52.511188
553	cylinder 143	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 16:11:52.742271
557	cylinder 144	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:52.970038
565	cylinder 146	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:53.421158
569	cylinder 147	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	cylinder.usd	2025-03-29 16:11:53.637325
573	cylinder 148	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:53.639742
577	cylinder 149	green	{0,0,0}	-273.72223	218.38489	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:53.873734
581	cylinder 150	green	{0,0,0}	-273.72223	218.38489	939.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:54.100875
585	cylinder 151	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	38.65981	cylinder.usd	2025-03-29 16:11:54.324566
589	cylinder 152	green	{0,0,0}	-273.72223	218.38489	936.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:54.558448
593	cylinder 153	green	{0,0,0}	-271.66885	217.53194	933	0	0	36.869896	cylinder.usd	2025-03-29 16:11:54.791127
543	cube 172	pink	{0,0,0}	-207.68886	345.4919	918.00006	0	0	59.03624	cube.usd	2025-03-29 16:12:00.138211
547	cube 173	pink	{0,0,0}	-207.68886	345.4919	931.00006	0	0	59.620872	cube.usd	2025-03-29 16:12:00.367957
551	cube 174	pink	{0,0,0}	-207.68886	345.4919	931.00006	0	0	59.743565	cube.usd	2025-03-29 16:12:00.606683
555	cube 175	pink	{0,0,0}	-207.68886	345.4919	920	0	0	59.03625	cube.usd	2025-03-29 16:12:00.837929
559	cube 176	pink	{0,0,0}	-209.49138	346.8466	932.00006	0	0	59.03624	cube.usd	2025-03-29 16:12:01.089185
563	cube 177	pink	{0,0,0}	-207.68886	345.4919	930.00006	0	0	59.620872	cube.usd	2025-03-29 16:12:01.352198
567	cube 178	pink	{0,0,0}	-207.68886	345.4919	918.00006	0	0	59.534454	cube.usd	2025-03-29 16:12:01.611956
548	cuboid 53	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:44:11.584722
556	cuboid 54	red	{0,0,0}	32.482143	259.85715	920	0	0	36.869896	cuboid.usd	2025-03-29 15:44:11.803938
572	cuboid 55	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	36.869896	cuboid.usd	2025-03-29 15:44:12.269191
584	cuboid 56	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:12.50264
571	cube 179	pink	{0,0,0}	-207.68886	345.4919	917.00006	0	0	59.34933	cube.usd	2025-03-29 16:12:01.844511
575	cube 180	pink	{0,0,0}	-207.68886	345.4919	932.00006	0	0	59.420776	cube.usd	2025-03-29 16:12:02.073977
576	cube 181	pink	{0,0,0}	-207.68886	345.4919	927.00006	0	0	59.62088	cube.usd	2025-03-29 16:12:02.315435
579	cube 182	pink	{0,0,0}	-207.68886	345.4919	922.00006	0	0	59.534454	cube.usd	2025-03-29 16:12:02.539231
583	cube 183	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	cube.usd	2025-03-29 16:12:02.542026
587	cube 184	pink	{0,0,0}	-207.68886	345.4919	922.00006	0	0	59.34933	cube.usd	2025-03-29 16:12:02.774395
588	cube 185	pink	{0,0,0}	-207.68886	345.4919	928.00006	0	0	59.743565	cube.usd	2025-03-29 16:12:02.993129
591	cube 186	red	{0,0,0}	31.497837	259.85715	915	0	0	37.568592	cube.usd	2025-03-29 16:12:02.995829
3216	cube 992	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.743565	cube.usd	2025-03-29 15:46:37.733072
1202	hexagonal prism 250	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:38.491363
602	pentagonal prism 187	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:46.874141
606	pentagonal prism 188	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:46.881657
610	pentagonal prism 189	black	{0,0,0}	-127.95996	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 16:11:47.108738
612	pentagonal prism 190	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:47.115514
614	pentagonal prism 191	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:47.338777
618	pentagonal prism 192	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:47.344657
626	pentagonal prism 193	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:47.574002
630	pentagonal prism 194	red	{0,0,0}	31.621342	260.87607	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:47.580793
634	pentagonal prism 195	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:47.805657
638	pentagonal prism 196	red	{0,0,0}	32.482143	259.85715	913.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:47.81198
642	pentagonal prism 197	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:48.041538
646	pentagonal prism 198	red	{0,0,0}	31.621342	260.87607	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:48.046985
636	hexagonal prism 28	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:52.260923
597	cylinder 154	green	{0,0,0}	-271.66885	217.53194	935.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:55.027608
601	cylinder 155	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:55.25546
605	cylinder 156	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 16:11:55.490147
609	cylinder 157	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 16:11:55.7248
613	cylinder 158	green	{0,0,0}	-273.72223	218.38489	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:55.956728
617	cylinder 159	green	{0,0,0}	-271.66885	217.53194	929	0	0	20.556046	cylinder.usd	2025-03-29 16:11:56.182573
621	cylinder 160	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:56.406376
624	cylinder 161	green	{0,0,0}	-271.66885	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 16:11:56.64142
625	cylinder 162	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 16:11:56.871346
629	cylinder 163	green	{0,0,0}	-271.66885	217.53194	933	0	0	36.869896	cylinder.usd	2025-03-29 16:11:57.116553
633	cylinder 164	green	{0,0,0}	-271.66885	217.53194	929	0	0	35.537674	cylinder.usd	2025-03-29 16:11:57.350692
637	cylinder 165	green	{0,0,0}	-271.66885	217.53194	936.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:57.573094
641	cylinder 166	green	{0,0,0}	-271.66885	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 16:11:57.807852
645	cylinder 167	green	{0,0,0}	-271.66885	217.53194	937.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:58.052371
595	cube 187	pink	{0,0,0}	-207.68886	345.4919	930.00006	0	0	59.03624	cube.usd	2025-03-29 16:12:03.243274
596	cube 188	pink	{0,0,0}	-209.49138	346.8466	925.00006	0	0	59.534454	cube.usd	2025-03-29 16:12:03.47946
599	cube 189	pink	{0,0,0}	-207.68886	345.4919	926.00006	0	0	59.743565	cube.usd	2025-03-29 16:12:03.703997
603	cube 190	pink	{0,0,0}	-207.68886	345.4919	925.00006	0	0	59.534454	cube.usd	2025-03-29 16:12:03.945704
607	cube 191	pink	{0,0,0}	-207.68886	345.4919	929	0	0	59.03624	cube.usd	2025-03-29 16:12:04.183716
611	cube 192	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.34933	cube.usd	2025-03-29 16:12:04.426447
615	cube 193	pink	{0,0,0}	-209.49138	346.8466	924	0	0	59.534454	cube.usd	2025-03-29 16:12:04.661898
616	cube 194	pink	{0,0,0}	-209.49138	346.8466	923.00006	0	0	59.03624	cube.usd	2025-03-29 16:12:04.88446
619	cube 195	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:07.901788
623	cube 196	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:08.135
627	cube 197	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	36.869896	cube.usd	2025-03-29 15:44:08.136965
631	cube 198	pink	{0,0,0}	-206.70456	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:08.366467
635	cube 199	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.420776	cube.usd	2025-03-29 15:44:08.596957
639	cube 200	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:08.833386
643	cube 201	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:44:08.835437
647	cube 202	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:09.062348
600	cuboid 57	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:44:12.736494
604	cuboid 58	red	{0,0,0}	31.621342	260.87607	920	0	0	37.874985	cuboid.usd	2025-03-29 15:44:13.186578
608	cuboid 59	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:13.419695
620	cuboid 60	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:13.65469
628	cuboid 61	red	{0,0,0}	31.621342	260.87607	917.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:44:14.126591
640	cuboid 63	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	cuboid.usd	2025-03-29 15:44:14.805927
644	cuboid 64	red	{0,0,0}	32.482143	259.85715	912.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:15.273885
1203	cube 360	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:38.49392
3217	cuboid 306	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:37.735065
654	pentagonal prism 200	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:48.278261
658	pentagonal prism 201	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:48.50802
662	pentagonal prism 202	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:48.743439
664	pentagonal prism 203	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:48.975216
666	pentagonal prism 204	red	{0,0,0}	32.482143	259.85715	920	0	0	37.69424	pentagonal prism.usd	2025-03-29 16:11:48.982228
668	pentagonal prism 205	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:49.212057
674	pentagonal prism 206	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 16:11:49.218718
678	pentagonal prism 207	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:49.43978
680	pentagonal prism 208	red	{0,0,0}	31.621342	260.87607	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:49.445995
682	pentagonal prism 209	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:49.672953
686	pentagonal prism 210	red	{0,0,0}	31.497837	259.85715	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:49.680628
690	pentagonal prism 211	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	pentagonal prism.usd	2025-03-29 16:11:49.90703
694	pentagonal prism 212	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:49.914766
698	pentagonal prism 213	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:50.147868
688	hexagonal prism 31	red	{0,0,0}	30.633175	260.87607	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 16:11:54.555794
700	hexagonal prism 32	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:56.170152
649	cylinder 168	green	{0,0,0}	-273.72223	218.38489	924	0	0	33.690063	cylinder.usd	2025-03-29 16:11:58.274298
653	cylinder 169	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	33.690067	cylinder.usd	2025-03-29 16:11:58.505993
657	cylinder 170	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:58.756849
661	cylinder 171	green	{0,0,0}	-273.72223	218.38489	920	0	0	26.56505	cylinder.usd	2025-03-29 16:11:58.979093
665	cylinder 172	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	19.983107	cylinder.usd	2025-03-29 16:11:59.212416
669	cylinder 173	green	{0,0,0}	-273.72223	218.38489	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:59.443478
673	cylinder 174	green	{0,0,0}	-271.66885	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:59.674849
681	cylinder 176	green	{0,0,0}	-271.66885	217.53194	935.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:12:00.143813
685	cylinder 177	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:12:00.373311
689	cylinder 178	green	{0,0,0}	-271.66885	217.53194	933	0	0	36.869896	cylinder.usd	2025-03-29 16:12:00.612431
693	cylinder 179	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 16:12:00.843393
697	cylinder 180	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:12:01.094422
701	cylinder 181	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:12:01.357762
648	cube 203	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.743565	cube.usd	2025-03-29 15:44:09.282049
651	cube 204	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:09.516615
655	cube 205	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:44:09.748959
656	cube 206	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:09.984222
659	cube 207	pink	{0,0,0}	-206.70456	346.4762	934	0	0	59.534454	cube.usd	2025-03-29 15:44:10.214879
660	cube 208	red	{0,0,0}	32.482143	259.85715	924	0	0	37.405357	cube.usd	2025-03-29 15:44:10.216889
663	cube 209	pink	{0,0,0}	-206.70456	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:10.449766
667	cube 210	pink	{0,0,0}	-206.70456	346.4762	928.00006	0	0	59.62088	cube.usd	2025-03-29 15:44:10.682529
671	cube 211	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.420776	cube.usd	2025-03-29 15:44:10.913509
675	cube 212	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.405357	cube.usd	2025-03-29 15:44:10.9162
679	cube 213	pink	{0,0,0}	-206.70456	346.4762	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:11.136531
683	cube 214	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:44:11.36096
687	cube 215	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:44:11.582637
691	cube 216	pink	{0,0,0}	-206.70456	346.4762	915	0	0	59.534454	cube.usd	2025-03-29 15:44:11.80168
695	cube 217	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:12.033845
696	cube 218	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:44:12.267053
699	cube 219	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:44:12.500193
652	cuboid 65	red	{0,0,0}	32.482143	259.85715	919	0	0	37.405357	cuboid.usd	2025-03-29 15:44:15.737169
672	cuboid 66	red	{0,0,0}	31.621342	260.87607	920	0	0	37.568592	cuboid.usd	2025-03-29 15:44:16.657627
676	cuboid 67	red	{0,0,0}	32.355774	258.8462	915	0	0	38.65981	cuboid.usd	2025-03-29 15:44:16.888516
692	cuboid 68	red	{0,0,0}	32.482143	259.85715	915	0	0	37.568592	cuboid.usd	2025-03-29 15:44:17.123419
3218	cylinder 809	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:46:37.737094
1204	cube 361	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:44:38.495924
718	hexagonal prism 35	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:40.372794
724	hexagonal prism 41	black	{0,0,0}	-129.44986	522.7403	660	0	0	90	hexagonal prism.usd	2025-03-29 15:43:42.225879
725	hexagonal prism 42	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:42.462336
726	hexagonal prism 43	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:42.687984
714	pentagonal prism 11	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:22.52796
727	hexagonal prism 44	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:43.145106
108	pentagonal prism 40	red	{0,0,0}	31.621342	260.87607	917.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 16:11:26.462776
196	pentagonal prism 66	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:29.958009
218	pentagonal prism 74	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:31.108298
96	cuboid 5	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 16:11:31.581131
177	cylinder 48	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 16:11:32.28205
112	cuboid 6	red	{0,0,0}	31.621342	260.87607	915	0	0	37.568592	cuboid.usd	2025-03-29 16:11:32.983351
244	hexagonal prism 11	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 16:11:34.371134
728	hexagonal prism 45	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:43.377795
715	hexagonal prism 12	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:34.597245
286	hexagonal prism 13	red	{0,0,0}	32.482143	259.85715	915	0	0	37.874985	hexagonal prism.usd	2025-03-29 16:11:35.969564
364	hexagonal prism 15	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 16:11:37.370307
370	pentagonal prism 121	red	{0,0,0}	31.621342	260.87607	917.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:37.83621
305	cylinder 80	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 16:11:39.229586
380	hexagonal prism 16	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:40.383165
345	cylinder 91	green	{0,0,0}	-271.66885	217.53194	933	0	0	36.869896	cylinder.usd	2025-03-29 16:11:41.56212
440	hexagonal prism 19	red	{0,0,0}	31.621342	260.87607	919	0	0	37.874985	hexagonal prism.usd	2025-03-29 16:11:41.787216
504	hexagonal prism 21	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:45.941313
729	hexagonal prism 46	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:43.606369
730	hexagonal prism 47	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:43.841158
465	cylinder 121	green	{0,0,0}	-273.72223	218.38489	937.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:48.049579
540	hexagonal prism 24	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:50.38178
706	pentagonal prism 215	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:50.389527
710	pentagonal prism 216	black	{0,0,0}	-129.44986	521.75214	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:50.625338
622	hexagonal prism 27	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	hexagonal prism.usd	2025-03-29 16:11:52.032438
670	hexagonal prism 29	black	{0,0,0}	-129.44986	521.75214	656	0	0	90	hexagonal prism.usd	2025-03-29 16:11:52.734337
769	hexagonal prism 80	black	{0,0,0}	-129.44986	522.7403	660	0	0	90	hexagonal prism.usd	2025-03-29 15:43:51.694236
703	cube 220	pink	{0,0,0}	-206.70456	346.4762	922.00006	0	0	59.420776	cube.usd	2025-03-29 15:44:12.734093
707	cube 221	pink	{0,0,0}	-208.67317	346.4762	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:12.963987
708	cube 222	pink	{0,0,0}	-208.50322	347.83475	923.00006	0	0	59.62088	cube.usd	2025-03-29 15:44:13.184421
711	cube 223	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:13.417678
712	cube 224	pink	{0,0,0}	-206.70456	346.4762	930.00006	0	0	59.03624	cube.usd	2025-03-29 15:44:13.652611
704	cuboid 69	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:44:18.270268
164	cuboid 10	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.303947	cuboid.usd	2025-03-29 16:11:53.870852
716	hexagonal prism 33	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:56.396398
717	hexagonal prism 34	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:56.863284
719	hexagonal prism 36	orange	{0,0,0}	30.633175	261.86423	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 16:11:58.976581
720	hexagonal prism 37	black	{0,0,0}	-129.44986	521.75214	656	0	0	90	hexagonal prism.usd	2025-03-29 16:11:59.433175
721	hexagonal prism 38	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	hexagonal prism.usd	2025-03-29 16:11:59.899293
705	cylinder 182	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:12:01.616849
709	cylinder 183	green	{0,0,0}	-271.66885	217.53194	924	0	0	33.690063	cylinder.usd	2025-03-29 16:12:01.849287
713	cylinder 184	green	{0,0,0}	-271.66885	217.53194	941.00006	0	0	18.43495	cylinder.usd	2025-03-29 16:12:02.079419
722	hexagonal prism 39	orange	{0,0,0}	31.497837	260.84146	928.00006	0	0	37.476177	hexagonal prism.usd	2025-03-29 16:12:02.317935
723	hexagonal prism 40	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 16:12:04.186381
1205	cylinder 293	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:38.497901
64	pentagonal prism 22	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:24.351889
325	cylinder 85	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:40.159635
271	cube 88	pink	{0,0,0}	-207.68886	345.4919	924	0	0	59.420776	cube.usd	2025-03-29 16:11:40.623969
489	cylinder 127	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	45	cylinder.usd	2025-03-29 16:11:48.984744
529	cylinder 137	green	{0,0,0}	-273.72223	218.38489	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:51.335528
561	cylinder 145	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:53.192851
755	hexagonal prism 72	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:41:18.453825
731	hexagonal prism 48	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:44.541198
732	hexagonal prism 49	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:45.009161
733	hexagonal prism 50	red	{0,0,0}	31.497837	259.85715	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:43:45.015247
734	hexagonal prism 51	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:45.24134
735	hexagonal prism 52	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:45.46301
736	hexagonal prism 53	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:45.694764
737	hexagonal prism 54	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:45.92882
738	hexagonal prism 55	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.746803	hexagonal prism.usd	2025-03-29 15:43:45.935034
739	hexagonal prism 56	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:46.163979
740	hexagonal prism 57	black	{0,0,0}	-129.44986	522.7403	660	0	0	90	hexagonal prism.usd	2025-03-29 15:43:46.397691
741	hexagonal prism 58	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:46.86591
742	hexagonal prism 59	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:47.097704
743	hexagonal prism 60	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:47.329224
744	hexagonal prism 61	red	{0,0,0}	31.497837	260.84146	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:43:47.3342
745	hexagonal prism 62	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:47.556616
746	hexagonal prism 63	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:47.776085
747	hexagonal prism 64	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:43:47.781115
748	hexagonal prism 65	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:48.228791
749	hexagonal prism 66	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:48.463489
750	hexagonal prism 67	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:48.694393
751	hexagonal prism 68	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:48.929534
752	hexagonal prism 69	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:49.162077
753	hexagonal prism 70	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:49.394948
754	hexagonal prism 71	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:49.629668
756	hexagonal prism 73	orange	{0,0,0}	31.497837	260.84146	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:43:49.867754
757	hexagonal prism 74	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:50.099061
758	hexagonal prism 75	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:50.343326
759	hexagonal prism 76	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:50.562025
760	hexagonal prism 77	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:50.782749
761	hexagonal prism 78	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:51.244991
762	hexagonal prism 79	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:51.464962
770	hexagonal prism 81	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:51.915784
771	hexagonal prism 82	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:52.147392
772	hexagonal prism 83	black	{0,0,0}	-127.95996	520.6986	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:52.378279
773	hexagonal prism 84	black	{0,0,0}	-129.44986	522.7403	660	0	0	90	hexagonal prism.usd	2025-03-29 15:43:52.599109
774	hexagonal prism 85	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:52.836346
775	hexagonal prism 86	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:53.065329
776	hexagonal prism 87	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:53.298099
777	hexagonal prism 88	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:43:53.304445
778	hexagonal prism 89	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:53.533938
779	hexagonal prism 90	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	36.869896	hexagonal prism.usd	2025-03-29 15:43:53.540505
780	hexagonal prism 91	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:53.766357
781	hexagonal prism 92	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:53.998913
782	hexagonal prism 93	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:54.452672
783	hexagonal prism 94	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:54.687358
784	hexagonal prism 95	red	{0,0,0}	31.497837	260.84146	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:43:54.922431
785	hexagonal prism 96	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:55.36993
786	hexagonal prism 97	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:55.59997
787	hexagonal prism 98	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:55.836097
788	hexagonal prism 99	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:56.068802
789	hexagonal prism 100	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:56.299835
790	hexagonal prism 101	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:43:56.766128
791	hexagonal prism 102	black	{0,0,0}	-127.95996	520.6986	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:56.997464
792	hexagonal prism 103	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:57.452467
793	hexagonal prism 104	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:57.688835
794	hexagonal prism 105	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:57.920586
795	hexagonal prism 106	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:58.154
796	hexagonal prism 107	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:58.387576
797	hexagonal prism 108	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:58.619576
798	hexagonal prism 109	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:58.856468
799	hexagonal prism 110	red	{0,0,0}	31.375294	259.82666	924	0	0	37.303947	hexagonal prism.usd	2025-03-29 15:43:58.861753
800	hexagonal prism 111	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:59.085031
801	hexagonal prism 112	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:59.323718
802	hexagonal prism 113	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:43:59.553566
803	hexagonal prism 114	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:43:59.785973
804	hexagonal prism 115	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:00.021522
805	hexagonal prism 116	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:00.259408
806	hexagonal prism 117	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:00.486541
807	hexagonal prism 118	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:00.720091
808	hexagonal prism 119	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:00.959763
809	hexagonal prism 120	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:01.18869
810	hexagonal prism 121	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:01.42047
811	hexagonal prism 122	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:01.639191
812	hexagonal prism 123	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:02.107644
813	hexagonal prism 124	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:02.337219
814	hexagonal prism 125	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:02.559081
815	hexagonal prism 126	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:03.02773
816	hexagonal prism 127	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:03.257935
817	hexagonal prism 128	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:03.49454
818	hexagonal prism 129	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:03.727244
819	hexagonal prism 130	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:03.955182
820	hexagonal prism 131	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:04.175382
821	hexagonal prism 132	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:04.406992
822	hexagonal prism 133	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:04.642352
823	hexagonal prism 134	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:04.880574
824	hexagonal prism 135	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:05.107886
825	hexagonal prism 136	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:05.343034
826	hexagonal prism 137	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:05.578079
827	hexagonal prism 138	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	hexagonal prism.usd	2025-03-29 15:44:05.809814
828	hexagonal prism 139	black	{0,0,0}	-127.95996	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:06.276222
433	cylinder 113	green	{0,0,0}	-273.72223	218.38489	924	0	0	33.690063	cylinder.usd	2025-03-29 16:11:46.179579
435	cube 138	pink	{0,0,0}	-207.68886	345.4919	922.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:52.265499
487	cube 155	pink	{0,0,0}	-207.68886	345.4919	926.00006	0	0	59.03624	cube.usd	2025-03-29 16:11:56.175588
829	hexagonal prism 140	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:06.509753
830	hexagonal prism 141	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:06.74536
831	hexagonal prism 142	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:06.974962
832	hexagonal prism 143	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:07.220449
833	hexagonal prism 144	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:07.443046
834	hexagonal prism 145	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:44:07.449487
835	hexagonal prism 146	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:07.67423
836	hexagonal prism 147	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:07.898845
837	hexagonal prism 148	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:08.131225
838	hexagonal prism 149	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:08.363765
839	hexagonal prism 150	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:09.058359
840	hexagonal prism 151	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:09.279246
841	hexagonal prism 152	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:09.512499
842	hexagonal prism 153	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:09.746452
843	hexagonal prism 154	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:09.979934
844	hexagonal prism 155	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:10.212415
845	hexagonal prism 156	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:10.679802
846	hexagonal prism 157	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:10.909573
847	hexagonal prism 158	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:11.579683
848	hexagonal prism 159	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:11.798394
849	hexagonal prism 160	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:12.262944
850	hexagonal prism 161	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:12.730231
851	hexagonal prism 162	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:12.9613
852	hexagonal prism 163	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:13.181217
853	hexagonal prism 164	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:13.648339
855	hexagonal prism 165	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:13.880204
856	cube 225	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:13.884338
857	hexagonal prism 166	red	{0,0,0}	31.375294	259.82666	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:44:13.886464
859	hexagonal prism 167	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:14.120463
860	cube 226	pink	{0,0,0}	-208.50322	347.83475	929	0	0	59.34933	cube.usd	2025-03-29 15:44:14.124426
862	hexagonal prism 168	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:14.342632
863	cube 227	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:44:14.345095
865	hexagonal prism 169	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:14.567777
866	cube 228	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:44:14.571511
632	cuboid 62	red	{0,0,0}	32.355774	258.8462	919	0	0	37.303947	cuboid.usd	2025-03-29 15:44:14.57358
868	hexagonal prism 170	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:14.799973
869	cube 229	pink	{0,0,0}	-205.90038	345.12823	939.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:14.803973
871	hexagonal prism 171	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:15.031257
872	cube 230	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:15.034787
874	hexagonal prism 172	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:15.268914
875	cube 231	pink	{0,0,0}	-207.68886	346.4762	912.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:15.271881
877	hexagonal prism 173	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:15.502031
878	cube 232	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.743565	cube.usd	2025-03-29 15:44:15.505678
879	cube 233	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	cube.usd	2025-03-29 15:44:15.507544
854	cylinder 185	green	{0,0,0}	-271.66885	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:12:02.320753
858	cylinder 186	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:12:02.545288
861	cylinder 187	green	{0,0,0}	-271.66885	217.53194	924	0	0	33.690063	cylinder.usd	2025-03-29 16:12:02.77947
864	cylinder 188	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:12:02.999467
867	cylinder 189	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:12:03.248949
870	cylinder 190	green	{0,0,0}	-273.72223	218.38489	936.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:12:03.484401
873	cylinder 191	green	{0,0,0}	-271.66885	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:12:03.711111
876	cylinder 192	green	{0,0,0}	-271.66885	217.53194	939.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:12:03.950656
881	cube 234	pink	{0,0,0}	-207.68886	346.4762	909.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:15.734799
883	hexagonal prism 174	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:15.964403
884	cube 235	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:44:15.968098
886	hexagonal prism 175	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:16.187295
887	cube 236	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:16.189995
889	hexagonal prism 176	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:16.422071
890	cube 237	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.620872	cube.usd	2025-03-29 15:44:16.426063
891	cube 238	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:44:16.427978
892	cylinder 197	green	{0,0,0}	-271.66885	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:16.42999
893	hexagonal prism 177	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:16.653034
894	cube 239	pink	{0,0,0}	-208.50322	347.83475	920	0	0	59.03625	cube.usd	2025-03-29 15:44:16.655582
895	cylinder 198	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:16.659653
896	hexagonal prism 178	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:16.883713
897	cube 240	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:44:16.886327
898	cylinder 199	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:16.890606
899	hexagonal prism 179	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:17.118626
900	cube 241	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:17.121275
901	cylinder 200	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:17.125677
902	cube 242	pink	{0,0,0}	-209.49138	347.83475	916.00006	0	0	59.62088	cube.usd	2025-03-29 15:44:17.351962
903	cylinder 201	green	{0,0,0}	-273.72223	218.38489	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:17.356377
904	hexagonal prism 180	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:17.572368
905	cube 243	pink	{0,0,0}	-208.50322	347.83475	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:17.575191
906	cube 244	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.874985	cube.usd	2025-03-29 15:44:17.57706
907	cylinder 202	green	{0,0,0}	-273.72223	218.38489	920	0	0	26.56505	cylinder.usd	2025-03-29 15:44:17.578976
908	hexagonal prism 181	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:17.806838
909	cube 245	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.420776	cube.usd	2025-03-29 15:44:17.809064
910	cube 246	red	{0,0,0}	32.355774	258.8462	912.00006	0	0	37.69424	cube.usd	2025-03-29 15:44:17.811117
911	cylinder 203	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:17.813181
912	cube 247	pink	{0,0,0}	-206.70456	346.4762	933	0	0	59.534454	cube.usd	2025-03-29 15:44:18.036105
913	hexagonal prism 182	red	{0,0,0}	31.497837	260.84146	919	0	0	37.69424	hexagonal prism.usd	2025-03-29 15:44:18.038007
914	cylinder 204	green	{0,0,0}	-271.66885	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:44:18.039929
915	cube 248	pink	{0,0,0}	-208.67317	346.4762	913.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:18.268312
916	cylinder 205	green	{0,0,0}	-272.65317	217.53194	938	0	0	18.434948	cylinder.usd	2025-03-29 15:44:18.272479
917	hexagonal prism 183	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:18.485422
918	cube 249	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.420776	cube.usd	2025-03-29 15:44:18.489618
919	cylinder 206	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:18.494188
920	hexagonal prism 184	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:18.713314
921	cube 250	pink	{0,0,0}	-207.68886	346.4762	913.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:18.715465
922	cuboid 70	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:44:18.717313
923	cylinder 207	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:44:18.719198
924	hexagonal prism 185	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:18.936669
925	cube 251	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:44:18.939366
926	hexagonal prism 186	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:44:18.941522
927	cylinder 208	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:18.943442
928	cube 252	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:19.17471
929	cuboid 71	red	{0,0,0}	31.497837	259.85715	909.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:19.176517
930	cylinder 209	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:19.17828
931	cube 253	pink	{0,0,0}	-208.67317	346.4762	919	0	0	59.93142	cube.usd	2025-03-29 15:44:19.398806
932	cylinder 210	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:19.402638
933	cube 254	pink	{0,0,0}	-207.68886	346.4762	915	0	0	59.03625	cube.usd	2025-03-29 15:44:19.629443
934	cylinder 211	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:44:19.633974
882	cylinder 194	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	18.43495	cylinder.usd	2025-03-29 16:12:04.432937
885	cylinder 195	green	{0,0,0}	-273.72223	218.38489	915	0	0	36.869896	cylinder.usd	2025-03-29 16:12:04.667498
888	cylinder 196	green	{0,0,0}	-273.72223	218.38489	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:12:04.890673
935	hexagonal prism 187	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:19.852799
936	cube 255	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:19.856989
937	cylinder 212	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:19.861371
938	hexagonal prism 188	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:20.087419
939	cube 256	pink	{0,0,0}	-205.90038	345.12823	936.00006	0	0	59.62088	cube.usd	2025-03-29 15:44:20.091445
940	cube 257	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	cube.usd	2025-03-29 15:44:20.093909
941	cylinder 213	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:20.095808
942	cube 258	pink	{0,0,0}	-208.67317	346.4762	923.00006	0	0	59.62088	cube.usd	2025-03-29 15:44:20.322686
943	cylinder 214	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:44:20.326921
944	hexagonal prism 189	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:20.554193
945	cube 259	pink	{0,0,0}	-206.70456	346.4762	940.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:20.558042
946	cube 260	red	{0,0,0}	32.482143	259.85715	911.00006	0	0	37.69424	cube.usd	2025-03-29 15:44:20.560296
947	cylinder 215	green	{0,0,0}	-271.66885	217.53194	918.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:44:20.562495
948	hexagonal prism 190	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:20.805088
949	cube 261	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:44:20.807768
950	cube 262	red	{0,0,0}	32.482143	259.85715	919	0	0	37.405357	cube.usd	2025-03-29 15:44:20.809631
951	cylinder 216	green	{0,0,0}	-271.66885	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:20.811404
952	hexagonal prism 191	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:21.035085
953	cube 263	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:21.038888
954	cylinder 217	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:44:21.043309
955	cube 264	pink	{0,0,0}	-209.49138	347.83475	934	0	0	59.620872	cube.usd	2025-03-29 15:44:21.273737
956	cube 265	red	{0,0,0}	31.621342	260.87607	913.00006	0	0	37.69424	cube.usd	2025-03-29 15:44:21.275857
957	cylinder 218	green	{0,0,0}	-273.72223	218.38489	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:21.277795
958	hexagonal prism 192	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:21.504088
959	cube 266	pink	{0,0,0}	-208.67317	346.4762	917.00006	0	0	59.93142	cube.usd	2025-03-29 15:44:21.508095
960	cylinder 219	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:21.512326
961	hexagonal prism 193	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:21.732348
962	cube 267	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:21.736318
963	cube 268	red	{0,0,0}	32.355774	258.8462	919	0	0	37.874985	cube.usd	2025-03-29 15:44:21.738372
964	cylinder 220	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:21.740589
965	hexagonal prism 194	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:21.972299
966	cube 269	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:44:21.974683
967	cylinder 221	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:21.978952
968	hexagonal prism 195	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:22.213141
969	cube 270	pink	{0,0,0}	-206.70456	346.4762	915	0	0	59.743565	cube.usd	2025-03-29 15:44:22.217019
970	cuboid 72	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:22.218912
971	cylinder 222	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	21.801407	cylinder.usd	2025-03-29 15:44:22.220885
972	hexagonal prism 196	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:22.478971
973	cube 271	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:22.482582
974	cube 272	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	36.869896	cube.usd	2025-03-29 15:44:22.48444
975	cylinder 223	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:22.486374
976	hexagonal prism 197	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:22.712044
977	cube 273	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 15:44:22.715992
978	cuboid 73	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:22.717967
979	cylinder 224	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:44:22.719965
980	hexagonal prism 198	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:22.934806
981	cube 274	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:44:22.937544
982	cube 275	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	cube.usd	2025-03-29 15:44:22.939899
983	cylinder 225	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:44:22.942219
984	hexagonal prism 199	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:23.154125
985	cube 276	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:23.156524
986	cube 277	red	{0,0,0}	32.482143	259.85715	915	0	0	37.568592	cube.usd	2025-03-29 15:44:23.158995
987	cylinder 226	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:23.161123
988	hexagonal prism 200	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:23.386376
989	cube 278	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:23.388684
990	cylinder 227	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:44:23.393416
991	cube 279	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:44:23.607994
992	cuboid 74	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	cuboid.usd	2025-03-29 15:44:23.610345
993	cylinder 228	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:23.612436
994	hexagonal prism 201	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:23.834337
995	cube 280	pink	{0,0,0}	-206.70456	346.4762	916.00006	0	0	59.420776	cube.usd	2025-03-29 15:44:23.838172
996	cylinder 229	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:44:23.843196
997	cube 281	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:24.082317
998	cylinder 230	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:24.086596
999	hexagonal prism 202	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:24.319309
1000	cube 282	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:44:24.323502
1001	cylinder 231	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:24.328054
1002	hexagonal prism 203	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:24.540598
1003	cube 283	pink	{0,0,0}	-207.68886	346.4762	933	0	0	59.534454	cube.usd	2025-03-29 15:44:24.54338
1004	cube 284	red	{0,0,0}	32.482143	259.85715	911.00006	0	0	37.69424	cube.usd	2025-03-29 15:44:24.545415
1005	cylinder 232	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:24.547398
1006	cube 285	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:24.775985
1007	cylinder 233	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 15:44:24.780436
1008	hexagonal prism 204	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:25.006534
1009	cube 286	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:25.010428
1010	hexagonal prism 205	red	{0,0,0}	31.375294	259.82666	929	0	0	36.869896	hexagonal prism.usd	2025-03-29 15:44:25.012627
1011	cylinder 234	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:25.01459
1012	cube 287	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:44:25.246958
1013	cylinder 235	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:44:25.250858
1014	hexagonal prism 206	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:25.481678
1015	cube 288	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:44:25.485362
1016	cube 289	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:44:25.487305
1017	cylinder 236	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:44:25.489383
1018	cube 290	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:44:25.709063
1019	cylinder 237	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:25.713601
1020	cube 291	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.743565	cube.usd	2025-03-29 15:44:25.934928
1021	cube 292	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	cube.usd	2025-03-29 15:44:25.937083
1022	cylinder 238	green	{0,0,0}	-272.65317	217.53194	924	0	0	36.869896	cylinder.usd	2025-03-29 15:44:25.939853
1023	hexagonal prism 207	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:26.163001
1024	cube 293	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:26.165884
1025	cuboid 75	red	{0,0,0}	31.497837	259.85715	924	0	0	38.157227	cuboid.usd	2025-03-29 15:44:26.167784
1026	cylinder 239	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:44:26.170011
1027	hexagonal prism 208	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:26.388141
1028	cube 294	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.743565	cube.usd	2025-03-29 15:44:26.392441
1029	cylinder 240	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:26.397266
1030	hexagonal prism 209	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:26.622194
1031	cube 295	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.93142	cube.usd	2025-03-29 15:44:26.62619
1032	cylinder 241	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:26.630879
1033	hexagonal prism 210	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:26.862451
1034	cube 296	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:26.866119
1035	cylinder 242	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:44:26.870098
1036	hexagonal prism 211	black	{0,0,0}	-127.95996	520.6986	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:27.092698
1037	cube 297	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:44:27.096478
1038	cylinder 243	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:44:27.100546
1039	hexagonal prism 212	black	{0,0,0}	-129.44986	522.7403	657	0	0	0	hexagonal prism.usd	2025-03-29 15:44:27.331016
1040	cube 298	pink	{0,0,0}	-208.50322	347.83475	934	0	0	59.534454	cube.usd	2025-03-29 15:44:27.334784
1041	cylinder 244	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:27.338716
1042	hexagonal prism 213	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:27.558599
1043	cube 299	pink	{0,0,0}	-206.70456	346.4762	916.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:27.561653
1044	hexagonal prism 214	red	{0,0,0}	31.497837	260.84146	933	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:44:27.563754
1045	cylinder 245	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:44:27.565956
1046	cube 300	pink	{0,0,0}	-209.49138	347.83475	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:27.796175
1047	cube 301	red	{0,0,0}	31.621342	260.87607	920	0	0	37.568592	cube.usd	2025-03-29 15:44:27.798292
1048	cylinder 246	green	{0,0,0}	-273.72223	218.38489	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:27.800362
1049	hexagonal prism 215	black	{0,0,0}	-129.44986	522.7403	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:28.027353
1050	cube 302	pink	{0,0,0}	-209.49138	347.83475	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:28.031511
1051	cube 303	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	38.157227	cube.usd	2025-03-29 15:44:28.033646
1052	cylinder 247	green	{0,0,0}	-273.72223	218.38489	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:28.035694
1053	hexagonal prism 216	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:28.260597
1054	cube 304	pink	{0,0,0}	-209.49138	347.83475	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:28.264568
1055	cuboid 76	red	{0,0,0}	31.621342	260.87607	919	0	0	37.405357	cuboid.usd	2025-03-29 15:44:28.266986
1056	cylinder 248	green	{0,0,0}	-273.72223	218.38489	920	0	0	18.43495	cylinder.usd	2025-03-29 15:44:28.269104
1057	hexagonal prism 217	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:28.499725
1058	cube 305	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:44:28.503588
1059	cuboid 77	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:28.505723
1060	cylinder 249	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:28.50765
1061	hexagonal prism 218	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:28.728377
1062	cube 306	pink	{0,0,0}	-208.50322	347.83475	931.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:28.730845
1063	cylinder 250	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:28.735096
1064	hexagonal prism 219	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:28.972742
1065	cube 307	pink	{0,0,0}	-206.70456	346.4762	934	0	0	59.420776	cube.usd	2025-03-29 15:44:28.976617
1066	cylinder 251	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:28.981459
1067	hexagonal prism 220	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:29.207161
1068	cube 308	pink	{0,0,0}	-206.70456	346.4762	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:29.211354
1069	cube 309	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.303947	cube.usd	2025-03-29 15:44:29.213401
1070	cylinder 252	green	{0,0,0}	-271.66885	217.53194	934	0	0	33.690063	cylinder.usd	2025-03-29 15:44:29.215655
1071	hexagonal prism 221	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:29.435616
1072	cube 310	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:44:29.438599
1073	cube 311	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.405357	cube.usd	2025-03-29 15:44:29.440576
1074	cylinder 253	green	{0,0,0}	-271.66885	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:29.442872
1075	hexagonal prism 222	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:29.661672
1076	cube 312	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.743565	cube.usd	2025-03-29 15:44:29.665865
1077	cuboid 78	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:44:29.668013
1078	cylinder 254	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:29.670049
1079	cube 313	pink	{0,0,0}	-208.50322	347.83475	929	0	0	59.743565	cube.usd	2025-03-29 15:44:29.894513
1080	cylinder 255	green	{0,0,0}	-273.72223	218.38489	919	0	0	36.869896	cylinder.usd	2025-03-29 15:44:29.898912
1081	hexagonal prism 223	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:30.129173
1082	cube 314	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:30.133042
1083	cylinder 256	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:30.13728
1084	cube 315	pink	{0,0,0}	-206.70456	346.4762	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:30.364631
1085	cylinder 257	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:30.369096
1086	hexagonal prism 224	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:30.594414
1087	cube 316	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:44:30.59863
1088	cylinder 258	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:44:30.602927
1089	hexagonal prism 225	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:30.829694
1090	cube 317	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:44:30.832296
1091	cube 318	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.874985	cube.usd	2025-03-29 15:44:30.834872
1092	cylinder 259	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:44:30.837014
1093	cube 319	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.420776	cube.usd	2025-03-29 15:44:31.066942
1094	cylinder 260	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:31.071175
1095	hexagonal prism 226	black	{0,0,0}	-129.44986	522.7403	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:31.291699
1096	cube 320	pink	{0,0,0}	-209.49138	347.83475	914.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:31.294648
1097	cube 321	red	{0,0,0}	31.621342	260.87607	924	0	0	37.874985	cube.usd	2025-03-29 15:44:31.296687
1098	cylinder 261	green	{0,0,0}	-273.72223	218.38489	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:31.299373
1099	cube 322	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:44:31.533948
1100	cube 323	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	36.869896	cube.usd	2025-03-29 15:44:31.536187
1101	cylinder 262	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:31.538215
1102	hexagonal prism 227	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:31.763744
1103	cube 324	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:31.767968
1104	cuboid 79	red	{0,0,0}	32.482143	259.85715	920	0	0	37.874985	cuboid.usd	2025-03-29 15:44:31.769938
1105	cylinder 263	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:31.771886
1106	hexagonal prism 228	black	{0,0,0}	-129.44986	522.7403	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:32.005243
1107	cube 325	pink	{0,0,0}	-208.50322	347.83475	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:32.007784
1108	cube 326	red	{0,0,0}	31.621342	260.87607	915	0	0	37.568592	cube.usd	2025-03-29 15:44:32.009661
1109	cylinder 264	green	{0,0,0}	-273.72223	218.38489	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:32.011612
1110	hexagonal prism 229	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:32.230093
1111	cube 327	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:32.234275
1112	cube 328	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:44:32.236466
1113	cylinder 265	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:32.238485
1114	hexagonal prism 230	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:32.46367
1115	cube 329	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:32.467543
1116	cuboid 80	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:44:32.469697
1117	cylinder 266	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:32.471795
1118	cube 330	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:32.702893
1119	hexagonal prism 231	red	{0,0,0}	32.482143	259.85715	920	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:44:32.705028
1120	cylinder 267	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:32.707095
1121	hexagonal prism 232	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:32.930506
1122	cube 331	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:32.933149
1123	cylinder 268	green	{0,0,0}	-271.66885	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:32.937209
1124	hexagonal prism 233	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:33.177387
1125	cube 332	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.620872	cube.usd	2025-03-29 15:44:33.181389
1126	cube 333	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.405357	cube.usd	2025-03-29 15:44:33.183638
1127	cylinder 269	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:33.185694
1128	hexagonal prism 234	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:44:33.410716
1129	cube 334	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:44:33.414414
1130	cuboid 81	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:44:33.416731
1131	cylinder 270	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:44:33.418923
1132	hexagonal prism 235	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:33.64534
1133	cube 335	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:44:33.64907
1134	cylinder 271	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:33.653765
1135	hexagonal prism 236	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:33.86627
1136	cube 336	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:44:33.869366
1137	cuboid 82	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:33.871394
1138	cylinder 272	green	{0,0,0}	-271.66885	217.53194	929	0	0	36.869896	cylinder.usd	2025-03-29 15:44:33.873266
1139	hexagonal prism 237	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:34.109361
1140	cube 337	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:44:34.113318
1141	cuboid 83	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:34.115449
1142	cylinder 273	green	{0,0,0}	-271.66885	217.53194	919	0	0	36.869896	cylinder.usd	2025-03-29 15:44:34.11813
1143	hexagonal prism 238	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:34.353559
1144	cube 338	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:34.356444
1145	cuboid 84	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:34.358387
1146	cylinder 274	green	{0,0,0}	-272.65317	217.53194	929	0	0	18.434948	cylinder.usd	2025-03-29 15:44:34.360651
1147	hexagonal prism 239	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:34.580818
1148	cube 339	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:34.584664
1149	cylinder 275	green	{0,0,0}	-272.65317	217.53194	911.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:44:34.588818
1150	hexagonal prism 240	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:34.813447
1151	cube 340	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:34.816177
1152	cylinder 276	green	{0,0,0}	-271.66885	217.53194	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:34.820626
1153	hexagonal prism 241	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:35.032754
1154	cube 341	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:44:35.03588
1155	cuboid 85	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:35.03831
1156	cylinder 277	green	{0,0,0}	-271.66885	217.53194	924	0	0	33.690063	cylinder.usd	2025-03-29 15:44:35.040429
1157	cube 342	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.420776	cube.usd	2025-03-29 15:44:35.268208
1158	cube 343	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.405357	cube.usd	2025-03-29 15:44:35.270825
1159	cylinder 278	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	38.65981	cylinder.usd	2025-03-29 15:44:35.272906
1160	hexagonal prism 242	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:35.499287
1161	cube 344	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:44:35.503353
1162	cylinder 279	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:35.507737
1163	cube 345	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:44:35.738685
1164	cylinder 280	green	{0,0,0}	-270.6119	216.68562	920	0	0	18.434948	cylinder.usd	2025-03-29 15:44:35.742644
1165	cube 346	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:35.987816
1166	cuboid 86	red	{0,0,0}	32.355774	258.8462	937.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:44:35.989674
1167	cylinder 281	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:35.991617
1168	hexagonal prism 243	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:36.215073
1169	cube 347	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:36.219039
1170	hexagonal prism 244	red	{0,0,0}	31.497837	260.84146	920	0	0	37.69424	hexagonal prism.usd	2025-03-29 15:44:36.22131
1171	cylinder 282	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:36.223269
1172	hexagonal prism 245	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:36.447748
1173	cube 348	pink	{0,0,0}	-209.49138	347.83475	929	0	0	59.93142	cube.usd	2025-03-29 15:44:36.451465
1174	hexagonal prism 246	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	36.869896	hexagonal prism.usd	2025-03-29 15:44:36.453611
1175	cylinder 283	green	{0,0,0}	-273.72223	218.38489	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:36.455649
1176	cube 349	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:36.678166
1177	cube 350	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:44:36.680144
1178	cylinder 284	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:36.682212
1179	hexagonal prism 247	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:36.896448
1180	cube 351	pink	{0,0,0}	-209.49138	347.83475	929	0	0	59.743565	cube.usd	2025-03-29 15:44:36.900232
1181	cuboid 87	red	{0,0,0}	31.621342	260.87607	920	0	0	37.568592	cuboid.usd	2025-03-29 15:44:36.902315
1182	cylinder 285	green	{0,0,0}	-273.72223	218.38489	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:36.905219
1183	cube 352	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:44:37.122048
1184	cube 353	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.874985	cube.usd	2025-03-29 15:44:37.123979
1185	cylinder 286	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:44:37.125986
1186	hexagonal prism 248	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:37.347623
1187	cube 354	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:37.350048
1188	cuboid 88	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:44:37.352119
1189	cylinder 287	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.43495	cylinder.usd	2025-03-29 15:44:37.354218
1206	hexagonal prism 251	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:38.718603
1207	cube 362	pink	{0,0,0}	-209.49138	347.83475	924	0	0	59.620872	cube.usd	2025-03-29 15:44:38.721273
1208	cylinder 294	green	{0,0,0}	-273.72223	218.38489	920	0	0	18.434948	cylinder.usd	2025-03-29 15:44:38.725334
1209	hexagonal prism 252	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:38.94623
1210	cube 363	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.420776	cube.usd	2025-03-29 15:44:38.950049
1211	cylinder 295	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:38.954709
1212	hexagonal prism 253	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:39.170528
1213	cube 364	pink	{0,0,0}	-206.70456	346.4762	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:39.174009
1214	cuboid 90	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:39.17604
1215	cylinder 296	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:44:39.178136
1216	hexagonal prism 254	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:39.399713
1217	cube 365	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:39.402711
1218	cuboid 91	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:39.405049
1219	cylinder 297	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:39.407302
1220	cube 366	pink	{0,0,0}	-208.67317	346.4762	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:39.641971
1221	cuboid 92	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:44:39.644129
1222	cylinder 298	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:39.646138
1223	cube 367	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:39.870685
1224	cylinder 299	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:39.8754
1225	hexagonal prism 255	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:40.11933
1226	cube 368	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:44:40.123642
1227	cylinder 300	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:40.128144
1228	hexagonal prism 256	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:40.354648
1229	cube 369	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.34933	cube.usd	2025-03-29 15:44:40.357303
1230	cuboid 93	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.303947	cuboid.usd	2025-03-29 15:44:40.359564
1231	cylinder 301	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:44:40.361693
1232	cube 370	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:44:40.600374
1233	cylinder 302	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:40.604468
1234	hexagonal prism 257	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:40.823069
1235	cube 371	pink	{0,0,0}	-208.67317	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:40.825889
1236	cube 372	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:44:40.828132
1237	cylinder 303	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:40.830395
1238	hexagonal prism 258	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:41.060812
1239	cube 373	pink	{0,0,0}	-206.88084	345.12823	935.00006	0	0	59.62088	cube.usd	2025-03-29 15:44:41.063171
1240	cuboid 94	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:44:41.065158
1241	cylinder 304	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:41.067009
1242	hexagonal prism 259	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:41.287633
1243	cube 374	pink	{0,0,0}	-208.50322	347.83475	930.00006	0	0	59.03624	cube.usd	2025-03-29 15:44:41.291439
1244	cuboid 95	red	{0,0,0}	31.621342	260.87607	924	0	0	37.568592	cuboid.usd	2025-03-29 15:44:41.293585
1245	cylinder 305	green	{0,0,0}	-273.72223	218.38489	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:41.295573
1246	hexagonal prism 260	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:41.520568
1247	cube 375	pink	{0,0,0}	-206.88084	345.12823	912.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:41.523398
1248	cylinder 306	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:41.527978
1249	hexagonal prism 261	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:41.751814
1250	cube 376	pink	{0,0,0}	-208.67317	346.4762	925.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:41.75572
1251	cuboid 96	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:41.757661
1252	cylinder 307	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:41.759923
1253	cube 377	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:41.993989
1254	cube 378	red	{0,0,0}	32.482143	259.85715	919	0	0	36.869896	cube.usd	2025-03-29 15:44:41.995935
1255	cylinder 308	green	{0,0,0}	-271.66885	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:44:41.997846
1256	cube 379	pink	{0,0,0}	-209.49138	347.83475	916.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:42.223885
1257	cylinder 309	green	{0,0,0}	-273.72223	218.38489	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:42.228279
1258	cube 380	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:44:42.450251
1259	cylinder 310	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:42.45401
1260	hexagonal prism 262	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:42.671761
1261	cube 381	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:42.674747
1262	cylinder 311	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:42.679155
1263	cube 382	pink	{0,0,0}	-209.49138	347.83475	920	0	0	59.534454	cube.usd	2025-03-29 15:44:42.906185
1264	hexagonal prism 263	red	{0,0,0}	30.633175	261.86423	926.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:44:42.908766
1265	cylinder 312	green	{0,0,0}	-273.72223	218.38489	934	0	0	33.690063	cylinder.usd	2025-03-29 15:44:42.910936
1266	hexagonal prism 264	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:43.138035
1267	cube 383	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:44:43.14219
1268	cylinder 313	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:43.146843
1269	cube 384	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:43.375073
1270	cylinder 314	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:43.379329
1271	cube 385	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:43.608693
1272	cube 386	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.69424	cube.usd	2025-03-29 15:44:43.611233
1273	cylinder 315	green	{0,0,0}	-271.66885	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:44:43.61336
1274	hexagonal prism 265	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:43.848284
1275	cube 387	pink	{0,0,0}	-209.49138	347.83475	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:43.852094
1276	cylinder 316	green	{0,0,0}	-273.72223	218.38489	929	0	0	33.690063	cylinder.usd	2025-03-29 15:44:43.856244
1277	hexagonal prism 266	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:44.072481
1278	cube 388	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:44:44.076767
1279	cylinder 317	green	{0,0,0}	-272.65317	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:44.081632
1280	hexagonal prism 267	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:44.313601
1281	cube 389	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:44.315811
1282	cuboid 97	red	{0,0,0}	32.355774	258.8462	920	0	0	36.869896	cuboid.usd	2025-03-29 15:44:44.317733
1283	cylinder 318	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:44.319854
1284	hexagonal prism 268	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:44.548503
1285	cube 390	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.620872	cube.usd	2025-03-29 15:44:44.552402
1286	cylinder 319	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:44:44.556468
1287	hexagonal prism 269	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:44.774501
1288	cube 391	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	60.255116	cube.usd	2025-03-29 15:44:44.778434
1289	cube 392	red	{0,0,0}	32.482143	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:44:44.780384
1290	cylinder 320	green	{0,0,0}	-271.66885	217.53194	920	0	0	33.690063	cylinder.usd	2025-03-29 15:44:44.782378
1291	hexagonal prism 270	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:45.015045
1292	cube 393	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:45.017419
1293	cube 394	red	{0,0,0}	32.355774	258.8462	915	0	0	36.869896	cube.usd	2025-03-29 15:44:45.019414
1294	cylinder 321	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:45.021944
1295	hexagonal prism 271	black	{0,0,0}	-127.95996	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:45.237836
1296	cube 395	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:44:45.240199
1297	hexagonal prism 272	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:44:45.242291
1298	cylinder 322	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:45.244832
1299	hexagonal prism 273	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:45.480608
1300	cube 396	pink	{0,0,0}	-208.50322	347.83475	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:44:45.484442
1301	cube 397	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:44:45.486405
1302	cylinder 323	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:45.488505
1303	hexagonal prism 274	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:45.706144
1304	cube 398	pink	{0,0,0}	-209.49138	347.83475	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:45.70942
1305	cuboid 98	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:44:45.711841
1306	cylinder 324	green	{0,0,0}	-273.72223	218.38489	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:45.713892
1307	hexagonal prism 275	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:45.934221
1308	cube 399	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:45.938173
1309	cuboid 99	red	{0,0,0}	31.497837	259.85715	915	0	0	37.405357	cuboid.usd	2025-03-29 15:44:45.940332
1310	cylinder 325	green	{0,0,0}	-272.65317	217.53194	933	0	0	36.869896	cylinder.usd	2025-03-29 15:44:45.942592
1311	hexagonal prism 276	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:46.155227
1312	cube 400	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:46.158603
1313	cylinder 326	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:44:46.163292
1314	cube 401	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.420776	cube.usd	2025-03-29 15:44:46.398513
1315	cube 402	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.405357	cube.usd	2025-03-29 15:44:46.400711
1316	cylinder 327	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:44:46.402759
1317	hexagonal prism 277	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:44:46.624056
1318	cube 403	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 15:44:46.628461
1319	cylinder 328	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:44:46.632785
1320	hexagonal prism 278	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:46.853924
1321	cube 404	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:46.857463
1322	cuboid 100	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:46.860166
1323	cylinder 329	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:44:46.862482
1324	cube 405	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.03624	cube.usd	2025-03-29 15:44:47.079124
1325	cylinder 330	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:47.083676
1326	cube 406	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:44:47.316887
1327	cuboid 101	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:44:47.318979
1328	cylinder 331	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:47.32097
1329	hexagonal prism 279	black	{0,0,0}	-127.95996	520.6986	657	0	0	0	hexagonal prism.usd	2025-03-29 15:44:47.543659
1330	cube 407	pink	{0,0,0}	-207.68886	346.4762	931.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:47.547821
1331	cylinder 332	green	{0,0,0}	-271.66885	217.53194	915	0	0	26.56505	cylinder.usd	2025-03-29 15:44:47.552189
1332	cube 408	pink	{0,0,0}	-208.67317	346.4762	933	0	0	59.03625	cube.usd	2025-03-29 15:44:47.776418
1333	cylinder 333	green	{0,0,0}	-272.65317	217.53194	936.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:44:47.780891
1334	hexagonal prism 280	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:48.006981
1335	cube 409	pink	{0,0,0}	-206.70456	346.4762	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:48.009828
1336	cylinder 334	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:44:48.014655
1337	hexagonal prism 281	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:48.253188
1338	cube 410	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:44:48.256841
1339	cuboid 102	red	{0,0,0}	32.482143	259.85715	920	0	0	37.69424	cuboid.usd	2025-03-29 15:44:48.259256
1340	cylinder 335	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:48.261925
1341	hexagonal prism 282	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:44:48.476193
1342	cube 411	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:44:48.479194
1343	cylinder 336	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:44:48.484138
1344	cube 412	pink	{0,0,0}	-209.49138	347.83475	929	0	0	59.03624	cube.usd	2025-03-29 15:44:48.712569
1345	cylinder 337	green	{0,0,0}	-273.72223	218.38489	938	0	0	26.56505	cylinder.usd	2025-03-29 15:44:48.717061
1346	hexagonal prism 283	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:48.943675
1347	cube 413	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 15:44:48.947547
1348	cuboid 103	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:44:48.949503
1349	cylinder 338	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:48.951598
1350	cube 414	pink	{0,0,0}	-206.88084	345.12823	912.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:49.178527
1351	cylinder 339	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:49.18287
1352	hexagonal prism 284	black	{0,0,0}	-127.95996	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:49.409074
1353	cube 415	pink	{0,0,0}	-207.68886	346.4762	909.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:49.412137
1354	cylinder 340	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:49.416616
1355	hexagonal prism 285	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:49.65285
1356	cube 416	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.62088	cube.usd	2025-03-29 15:44:49.656887
1357	cylinder 341	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:44:49.661246
1358	cube 417	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:44:49.882857
1359	cuboid 104	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:44:49.884946
1360	cylinder 342	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:49.88708
1361	cube 418	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:50.116938
1362	cuboid 105	red	{0,0,0}	32.482143	259.85715	912.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:44:50.118824
1363	cylinder 343	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:50.1209
1364	hexagonal prism 286	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:50.35443
1365	cube 419	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.62088	cube.usd	2025-03-29 15:44:50.356811
1366	cuboid 106	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:44:50.359045
1367	cylinder 344	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:50.361104
1368	hexagonal prism 287	black	{0,0,0}	-129.44986	522.7403	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:50.575885
1369	cube 420	pink	{0,0,0}	-209.49138	347.83475	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:50.578792
1370	cylinder 345	green	{0,0,0}	-273.72223	218.38489	923.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:44:50.583629
1371	hexagonal prism 288	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:44:50.818734
1372	cube 421	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:50.82239
1373	cube 422	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cube.usd	2025-03-29 15:44:50.82431
1374	cylinder 346	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:50.826585
1376	cube 423	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:51.045669
1378	cylinder 347	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:51.049888
1379	hexagonal prism 289	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:51.263646
1380	cube 424	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:51.266442
1382	cylinder 348	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:51.270235
1383	hexagonal prism 290	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:51.497882
1384	cube 425	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:51.501993
1385	cuboid 107	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:44:51.504114
1375	pentagonal prism 217	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:50.632364
1377	pentagonal prism 218	black	{0,0,0}	-129.44986	521.75214	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:50.861789
1381	pentagonal prism 219	red	{0,0,0}	31.621342	260.87607	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:50.869075
1386	cylinder 349	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:44:51.506176
1387	hexagonal prism 291	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:51.726397
1388	cube 426	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:44:51.730196
1389	cuboid 108	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:51.732415
1390	cylinder 350	green	{0,0,0}	-270.6119	216.68562	933	0	0	36.869896	cylinder.usd	2025-03-29 15:44:51.734389
1391	hexagonal prism 292	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:51.973773
1392	cube 427	pink	{0,0,0}	-207.68886	346.4762	934	0	0	59.420776	cube.usd	2025-03-29 15:44:51.976231
1393	cube 428	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.874985	cube.usd	2025-03-29 15:44:51.97861
1394	cylinder 351	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:51.980949
1395	hexagonal prism 293	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:52.196661
1396	cube 429	pink	{0,0,0}	-209.49138	347.83475	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:52.199885
1397	cube 430	red	{0,0,0}	31.621342	260.87607	929	0	0	37.405357	cube.usd	2025-03-29 15:44:52.201854
1398	cylinder 352	green	{0,0,0}	-273.72223	218.38489	934	0	0	26.56505	cylinder.usd	2025-03-29 15:44:52.203821
1399	hexagonal prism 294	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:52.424701
1400	cube 431	pink	{0,0,0}	-206.70456	346.4762	933	0	0	59.03625	cube.usd	2025-03-29 15:44:52.428819
1402	cylinder 353	green	{0,0,0}	-271.66885	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:52.433056
1403	hexagonal prism 295	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:52.645723
1404	cube 432	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.62088	cube.usd	2025-03-29 15:44:52.649014
1405	cuboid 109	red	{0,0,0}	32.355774	258.8462	920	0	0	37.69424	cuboid.usd	2025-03-29 15:44:52.651206
1406	cylinder 354	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:52.653405
1407	hexagonal prism 296	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:52.877931
1408	cube 433	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:52.881176
1409	cuboid 110	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:44:52.884029
1410	cylinder 355	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:52.886173
1412	cube 434	pink	{0,0,0}	-206.70456	346.4762	936.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:53.11422
1414	cylinder 356	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:53.119034
1415	hexagonal prism 297	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:53.345272
1416	cube 435	pink	{0,0,0}	-209.49138	347.83475	919	0	0	59.743565	cube.usd	2025-03-29 15:44:53.347931
1418	cylinder 357	green	{0,0,0}	-273.72223	218.38489	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:53.352579
1420	cube 436	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:53.574274
1421	cuboid 111	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:44:53.576252
1422	cylinder 358	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:53.578233
1423	hexagonal prism 298	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:53.790148
1424	cube 437	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:53.792952
1425	cuboid 112	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:44:53.795189
1426	cylinder 359	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:44:53.797179
1428	cube 438	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:54.033106
1430	cylinder 360	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:54.037259
1432	cube 439	pink	{0,0,0}	-209.49138	347.83475	936.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:54.284379
1433	hexagonal prism 299	red	{0,0,0}	31.621342	260.87607	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:44:54.286542
1434	cylinder 361	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:54.288435
1435	hexagonal prism 300	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:54.516893
1436	cube 440	pink	{0,0,0}	-206.88084	345.12823	931.00006	0	0	59.03624	cube.usd	2025-03-29 15:44:54.520755
1438	cylinder 362	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:54.524516
1439	hexagonal prism 301	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:54.745273
1411	pentagonal prism 221	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:51.104547
1413	pentagonal prism 222	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:51.332271
1417	pentagonal prism 223	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:51.566805
1419	pentagonal prism 224	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:51.573964
1427	pentagonal prism 225	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:51.801555
1429	pentagonal prism 226	red	{0,0,0}	32.482143	259.85715	911.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:52.03963
1431	pentagonal prism 227	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:52.268226
1437	pentagonal prism 228	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:52.501226
1440	cube 441	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.62088	cube.usd	2025-03-29 15:44:54.747658
1441	cuboid 113	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:44:54.75006
1442	cylinder 363	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:44:54.752061
1443	hexagonal prism 302	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:54.966172
1444	cube 442	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:54.968374
1445	cube 443	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	cube.usd	2025-03-29 15:44:54.970211
1446	cylinder 364	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:54.971942
1447	hexagonal prism 303	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:55.200061
1448	cube 444	pink	{0,0,0}	-208.67317	346.4762	928.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:55.203908
1449	cube 445	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.69424	cube.usd	2025-03-29 15:44:55.205807
1450	cylinder 365	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:44:55.207856
1451	hexagonal prism 304	black	{0,0,0}	-129.44986	522.7403	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:55.429521
1452	cube 446	pink	{0,0,0}	-209.49138	347.83475	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:55.432558
1454	cylinder 366	green	{0,0,0}	-273.72223	218.38489	912.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:55.436946
1455	hexagonal prism 305	black	{0,0,0}	-129.44986	522.7403	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:55.676164
1456	cube 447	pink	{0,0,0}	-208.50322	347.83475	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:55.67893
1457	cuboid 114	red	{0,0,0}	31.621342	260.87607	928.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:44:55.681074
1458	cylinder 367	green	{0,0,0}	-273.72223	218.38489	938	0	0	26.56505	cylinder.usd	2025-03-29 15:44:55.683351
1459	hexagonal prism 306	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:55.907964
1460	cube 448	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:55.913849
1461	cuboid 115	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	36.869896	cuboid.usd	2025-03-29 15:44:55.917018
1462	cylinder 368	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:55.920302
1463	hexagonal prism 307	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:44:56.145208
1464	cube 449	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:56.147896
1465	cuboid 116	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:56.149893
1466	cylinder 369	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:56.152484
1467	hexagonal prism 308	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:56.364306
1468	cube 450	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.03624	cube.usd	2025-03-29 15:44:56.367203
1470	cylinder 370	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:44:56.371488
1471	hexagonal prism 309	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:44:56.60761
1472	cube 451	pink	{0,0,0}	-209.49138	347.83475	920	0	0	59.743565	cube.usd	2025-03-29 15:44:56.611445
1474	cylinder 371	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:56.615607
1475	hexagonal prism 310	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:56.844257
1476	cube 452	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:44:56.848112
1477	cuboid 117	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:56.850359
1478	cylinder 372	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:56.852624
1479	hexagonal prism 311	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:57.071221
1480	cube 453	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:57.073608
1482	cylinder 373	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:44:57.077393
1483	hexagonal prism 312	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:57.299524
1484	cube 454	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:44:57.303558
1485	cube 455	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cube.usd	2025-03-29 15:44:57.305643
1486	cylinder 374	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:44:57.307701
1487	hexagonal prism 313	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	hexagonal prism.usd	2025-03-29 15:44:57.537504
1488	cube 456	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:44:57.541762
1490	cylinder 375	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:44:57.548631
1491	hexagonal prism 314	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	hexagonal prism.usd	2025-03-29 15:44:57.765483
1492	cube 457	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:44:57.769343
1493	cube 458	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.69424	cube.usd	2025-03-29 15:44:57.771347
1494	cylinder 376	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:44:57.773295
1469	pentagonal prism 230	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	pentagonal prism.usd	2025-03-29 16:11:53.184245
1473	pentagonal prism 231	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:53.190227
1481	pentagonal prism 232	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:53.412528
1489	pentagonal prism 233	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:53.418345
1495	hexagonal prism 315	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:58.000204
1496	cube 459	pink	{0,0,0}	-208.67317	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:44:58.003119
1497	cylinder 377	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.69424	cylinder.usd	2025-03-29 15:44:58.005108
1498	cylinder 378	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:58.007047
1499	hexagonal prism 316	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:58.234957
1500	cube 460	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:58.238752
1501	cube 461	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.874985	cube.usd	2025-03-29 15:44:58.240743
1502	cylinder 379	green	{0,0,0}	-272.65317	217.53194	941.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:58.242839
1503	hexagonal prism 317	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:58.461868
1504	cube 462	pink	{0,0,0}	-206.88084	345.12823	937.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:58.465916
1505	cuboid 118	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.23483	cuboid.usd	2025-03-29 15:44:58.46812
1506	cylinder 380	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:44:58.470352
1507	hexagonal prism 318	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	hexagonal prism.usd	2025-03-29 15:44:58.692454
1508	cube 463	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:44:58.694967
1509	cuboid 119	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:58.696867
1510	cylinder 381	green	{0,0,0}	-270.6119	216.68562	938	0	0	26.56505	cylinder.usd	2025-03-29 15:44:58.699042
1511	hexagonal prism 319	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:58.915762
1512	cube 464	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:44:58.918574
1513	cuboid 120	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:58.920982
1514	cylinder 382	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:44:58.923051
1515	hexagonal prism 320	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:59.134509
1516	cube 465	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:59.137356
1517	cuboid 121	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:44:59.139452
1518	cylinder 383	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:59.141538
1520	cube 466	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:44:59.369108
1522	cylinder 384	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:44:59.373328
1523	hexagonal prism 321	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:44:59.602438
1524	cube 467	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:44:59.60634
1525	cuboid 122	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:44:59.608269
1526	cylinder 385	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:59.610226
1527	hexagonal prism 322	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:44:59.83207
1528	cube 468	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.620872	cube.usd	2025-03-29 15:44:59.835715
1529	cube 469	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:44:59.837957
1530	cylinder 386	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:44:59.839899
1531	hexagonal prism 323	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:00.067117
1532	cube 470	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:00.069418
1533	cuboid 123	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:00.071431
1534	cylinder 387	green	{0,0,0}	-270.6119	216.68562	943	0	0	26.56505	cylinder.usd	2025-03-29 15:45:00.073229
1536	cube 471	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:00.302836
1537	cube 472	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.69424	cube.usd	2025-03-29 15:45:00.305017
1538	cylinder 388	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:00.307384
1539	hexagonal prism 324	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:00.535785
1540	cube 473	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:45:00.539618
1541	cuboid 124	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:00.541619
1542	cylinder 389	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:45:00.543639
1544	cube 474	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:45:00.771501
1546	cylinder 390	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:00.775568
1548	cube 475	pink	{0,0,0}	-206.88084	345.12823	932.00006	0	0	59.420776	cube.usd	2025-03-29 15:45:00.999779
1549	cube 476	red	{0,0,0}	32.355774	258.8462	924	0	0	37.746803	cube.usd	2025-03-29 15:45:01.001947
1521	pentagonal prism 235	black	{0,0,0}	-129.44986	521.75214	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:53.86435
1535	pentagonal prism 236	black	{0,0,0}	-129.44986	521.75214	661	0	0	90	pentagonal prism.usd	2025-03-29 16:11:54.091758
1543	pentagonal prism 237	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:54.098349
1545	pentagonal prism 238	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:54.316003
1547	pentagonal prism 239	red	{0,0,0}	32.482143	259.85715	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:54.321942
1550	cylinder 391	green	{0,0,0}	-270.6119	216.68562	933	0	0	33.690063	cylinder.usd	2025-03-29 15:45:01.004481
1552	cube 477	pink	{0,0,0}	-206.70456	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:45:01.246396
1553	cuboid 125	red	{0,0,0}	32.482143	259.85715	915	0	0	37.405357	cuboid.usd	2025-03-29 15:45:01.248348
1554	cylinder 392	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:01.250229
1555	hexagonal prism 325	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:01.466767
1556	cube 478	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:01.469591
1557	cuboid 126	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:45:01.471952
1558	cylinder 393	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:01.474109
1559	hexagonal prism 326	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	hexagonal prism.usd	2025-03-29 15:45:01.687819
1560	cube 479	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:01.691226
1561	cuboid 127	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:45:01.693269
1562	cylinder 394	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:45:01.695377
1563	hexagonal prism 327	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	hexagonal prism.usd	2025-03-29 15:45:01.918162
1564	cube 480	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:45:01.922917
1566	cylinder 395	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:01.927268
1567	hexagonal prism 328	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:02.154912
1568	cube 481	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:02.157305
1569	cuboid 128	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:45:02.15963
1570	cylinder 396	green	{0,0,0}	-271.66885	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:02.161809
1572	cube 482	pink	{0,0,0}	-206.70456	346.4762	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:02.388104
1573	cuboid 129	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:02.390429
1574	cylinder 397	green	{0,0,0}	-271.66885	217.53194	920	0	0	33.690063	cylinder.usd	2025-03-29 15:45:02.392469
1575	hexagonal prism 329	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:02.612689
1576	cube 483	pink	{0,0,0}	-209.49138	347.83475	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:02.616798
1577	cuboid 130	red	{0,0,0}	31.621342	260.87607	923.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:45:02.618924
1578	cylinder 398	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:02.62167
1579	hexagonal prism 330	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:02.834035
1580	cube 484	pink	{0,0,0}	-207.68886	346.4762	911.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:02.836686
1581	cuboid 131	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:45:02.839166
1582	cylinder 399	green	{0,0,0}	-271.66885	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:45:02.841468
1584	cube 485	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:03.074447
1585	cube 486	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.405357	cube.usd	2025-03-29 15:45:03.07647
1586	cylinder 400	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:45:03.078426
1587	hexagonal prism 331	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:03.300456
1588	cube 487	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.62088	cube.usd	2025-03-29 15:45:03.304261
1589	cuboid 132	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:45:03.306456
1590	cylinder 401	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:45:03.308551
1592	cube 488	pink	{0,0,0}	-206.70456	346.4762	934	0	0	59.620872	cube.usd	2025-03-29 15:45:03.540328
1593	cube 489	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.40536	cube.usd	2025-03-29 15:45:03.542409
1594	cylinder 402	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:03.544523
1595	hexagonal prism 332	black	{0,0,0}	-127.95996	520.6986	657	0	0	0	hexagonal prism.usd	2025-03-29 15:45:03.771183
1596	cube 490	pink	{0,0,0}	-206.70456	346.4762	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:03.775425
1597	cube 491	red	{0,0,0}	32.482143	259.85715	915	0	0	37.568592	cube.usd	2025-03-29 15:45:03.77745
1598	cylinder 403	green	{0,0,0}	-271.66885	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:45:03.779346
1599	hexagonal prism 333	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:04.011788
1600	cube 492	pink	{0,0,0}	-206.70456	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:04.015436
1602	cylinder 404	green	{0,0,0}	-271.66885	217.53194	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:04.020186
1603	hexagonal prism 334	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:04.237259
1604	cube 493	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:04.241524
1565	pentagonal prism 241	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:54.782714
1571	pentagonal prism 242	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:54.788582
1583	pentagonal prism 243	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:55.018306
1591	pentagonal prism 244	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:55.025072
1601	pentagonal prism 245	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	pentagonal prism.usd	2025-03-29 16:11:55.246038
1606	cylinder 405	green	{0,0,0}	-270.6119	216.68562	933	0	0	33.690063	cylinder.usd	2025-03-29 15:45:04.245753
1608	cube 494	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:45:04.477844
1610	cylinder 406	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:04.482273
1611	hexagonal prism 335	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:04.70005
1612	cube 495	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:45:04.70421
1614	cylinder 407	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:04.70842
1615	hexagonal prism 336	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:04.935034
1616	cube 496	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03625	cube.usd	2025-03-29 15:45:04.939451
1618	cylinder 408	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:04.943706
1620	cube 497	pink	{0,0,0}	-209.49138	347.83475	925.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:05.171318
1621	cuboid 133	red	{0,0,0}	31.621342	260.87607	920	0	0	37.69424	cuboid.usd	2025-03-29 15:45:05.173627
1622	cylinder 409	green	{0,0,0}	-273.72223	218.38489	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:05.176022
1623	hexagonal prism 337	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:05.406955
1624	cube 498	pink	{0,0,0}	-208.67317	346.4762	936.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:05.409846
1625	cube 499	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cube.usd	2025-03-29 15:45:05.411796
1626	cylinder 410	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:45:05.413676
1627	hexagonal prism 338	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:05.64361
1628	cube 500	pink	{0,0,0}	-206.70456	346.4762	940.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:05.64604
1630	cylinder 411	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:05.649968
1632	cube 501	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.93142	cube.usd	2025-03-29 15:45:05.878278
1634	cylinder 412	green	{0,0,0}	-270.6119	216.68562	934	0	0	33.690063	cylinder.usd	2025-03-29 15:45:05.882377
1636	cube 502	pink	{0,0,0}	-206.70456	346.4762	937.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:06.116332
1637	cube 503	red	{0,0,0}	32.482143	259.85715	915	0	0	37.568592	cube.usd	2025-03-29 15:45:06.118236
1638	cylinder 413	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:45:06.120229
1640	cube 504	pink	{0,0,0}	-206.70456	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:45:06.340287
1641	cube 505	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:06.342649
1642	cylinder 414	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:06.344837
1643	hexagonal prism 339	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:06.571494
1644	cube 506	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:45:06.573713
1646	cylinder 415	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:45:06.577988
1648	cube 507	pink	{0,0,0}	-206.88084	345.12823	910	0	0	59.34933	cube.usd	2025-03-29 15:45:06.804625
1649	cube 508	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:45:06.806744
1650	cylinder 416	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:45:06.809072
1651	hexagonal prism 340	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:07.031769
1652	cube 509	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.62088	cube.usd	2025-03-29 15:45:07.03482
1653	cuboid 134	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:45:07.036903
1654	cylinder 417	green	{0,0,0}	-270.6119	216.68562	941.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:07.038824
1655	hexagonal prism 341	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	hexagonal prism.usd	2025-03-29 15:45:07.261085
1656	cube 510	pink	{0,0,0}	-206.70456	346.4762	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:07.263398
1658	cylinder 418	green	{0,0,0}	-271.66885	217.53194	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:07.267225
1607	pentagonal prism 247	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	pentagonal prism.usd	2025-03-29 16:11:55.481788
1609	pentagonal prism 248	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:55.487406
1613	pentagonal prism 249	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:55.714825
1617	pentagonal prism 250	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:55.72219
1619	pentagonal prism 251	black	{0,0,0}	-129.44986	521.75214	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:55.947033
1629	pentagonal prism 252	red	{0,0,0}	31.621342	260.87607	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:55.954091
1631	pentagonal prism 253	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:56.178751
1633	pentagonal prism 254	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:56.403748
1635	pentagonal prism 255	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:56.631085
1639	pentagonal prism 256	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:56.638791
1645	pentagonal prism 257	red	{0,0,0}	32.482143	259.85715	915	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:56.868756
1647	pentagonal prism 258	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:57.105968
1660	cube 511	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:45:07.500997
1661	cuboid 135	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:45:07.502922
1662	cylinder 419	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:07.50486
1663	hexagonal prism 342	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:07.731306
1664	cube 512	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.34933	cube.usd	2025-03-29 15:45:07.734978
1665	cuboid 136	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:45:07.736811
1666	cylinder 420	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:07.738821
1667	hexagonal prism 343	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:07.977349
1668	cube 513	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:45:07.979755
1669	cube 514	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	38.157227	cube.usd	2025-03-29 15:45:07.981623
1670	cylinder 421	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:45:07.983426
1671	hexagonal prism 344	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:08.224005
1672	cube 515	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.420776	cube.usd	2025-03-29 15:45:08.228076
1673	cuboid 137	red	{0,0,0}	32.482143	259.85715	932.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:08.230572
1674	cylinder 422	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:08.232658
1676	cube 516	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:08.456482
1677	cuboid 138	red	{0,0,0}	32.355774	258.8462	919	0	0	37.23483	cuboid.usd	2025-03-29 15:45:08.458822
1678	cylinder 423	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:45:08.461456
1679	hexagonal prism 345	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:08.681087
1680	cube 517	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.420776	cube.usd	2025-03-29 15:45:08.683778
1681	cuboid 139	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:45:08.685718
1682	cylinder 424	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:08.687695
1684	cube 518	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:45:08.908587
1686	cylinder 425	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:08.913075
1688	cube 519	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:09.12875
1690	cylinder 426	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:09.132904
1692	cube 520	pink	{0,0,0}	-206.70456	346.4762	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:09.365222
1694	cylinder 427	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:09.369221
1695	hexagonal prism 346	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:09.590496
1696	cube 521	pink	{0,0,0}	-209.49138	347.83475	920	0	0	59.534454	cube.usd	2025-03-29 15:45:09.594813
1697	cuboid 140	red	{0,0,0}	31.621342	260.87607	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:09.597223
1698	cylinder 428	green	{0,0,0}	-273.72223	218.38489	929	0	0	33.690063	cylinder.usd	2025-03-29 15:45:09.599232
1699	hexagonal prism 347	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:09.831302
1700	cube 522	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.62088	cube.usd	2025-03-29 15:45:09.834257
1701	cuboid 141	red	{0,0,0}	32.482143	259.85715	919	0	0	37.746803	cuboid.usd	2025-03-29 15:45:09.836187
1702	cylinder 429	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:09.839103
1703	hexagonal prism 348	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:10.076369
1704	cube 523	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 15:45:10.08032
1705	cuboid 142	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.303947	cuboid.usd	2025-03-29 15:45:10.082411
1706	cylinder 430	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:10.084466
1708	cube 524	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:10.317109
1710	cylinder 431	green	{0,0,0}	-271.66885	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:45:10.321251
1712	cube 525	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:45:10.545674
1675	pentagonal prism 261	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:57.563126
1683	pentagonal prism 262	red	{0,0,0}	32.482143	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:57.570442
1685	pentagonal prism 263	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:57.798611
1687	pentagonal prism 264	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 16:11:57.805185
1689	pentagonal prism 265	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:58.04234
1691	pentagonal prism 266	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:58.265433
1693	pentagonal prism 267	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 16:11:58.271579
1707	pentagonal prism 268	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:58.496187
1709	pentagonal prism 269	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:58.746239
1711	pentagonal prism 270	red	{0,0,0}	32.482143	259.85715	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:58.753949
1713	cuboid 143	red	{0,0,0}	32.355774	258.8462	920	0	0	37.69424	cuboid.usd	2025-03-29 15:45:10.547739
1714	cylinder 432	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:10.549727
1715	hexagonal prism 349	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:10.773469
1716	cube 526	pink	{0,0,0}	-206.88084	345.12823	912.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:10.777074
1718	cylinder 433	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:10.781379
1720	cube 527	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.34933	cube.usd	2025-03-29 15:45:10.999717
1721	cuboid 144	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:45:11.001757
1722	cylinder 434	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:11.003757
1723	hexagonal prism 350	black	{0,0,0}	-127.95996	520.6986	657	0	0	0	hexagonal prism.usd	2025-03-29 15:45:11.220816
1724	cube 528	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.420776	cube.usd	2025-03-29 15:45:11.223386
1726	cylinder 435	green	{0,0,0}	-271.66885	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:11.227823
1728	cube 529	pink	{0,0,0}	-206.70456	346.4762	915	0	0	59.620872	cube.usd	2025-03-29 15:45:11.446087
1729	cuboid 145	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:11.448304
1730	cylinder 436	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:11.450372
1731	hexagonal prism 351	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:11.670791
1732	cube 530	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:11.67437
1733	cuboid 146	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:45:11.676394
1734	cylinder 437	green	{0,0,0}	-272.65317	217.53194	941.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:45:11.67869
1736	cube 531	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:11.90695
1737	cube 532	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	36.869896	cube.usd	2025-03-29 15:45:11.909388
1738	cylinder 438	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:11.911694
1740	cube 533	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:12.128003
1742	cylinder 439	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:12.132915
1743	hexagonal prism 352	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:12.356879
1744	cube 534	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:45:12.360912
1745	cube 535	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	cube.usd	2025-03-29 15:45:12.363203
1746	cylinder 440	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:45:12.365596
1747	hexagonal prism 353	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:12.587296
1748	cube 536	pink	{0,0,0}	-206.70456	346.4762	909.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:12.589637
1749	cuboid 147	red	{0,0,0}	32.482143	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:12.591722
1750	cylinder 441	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:12.593887
1751	hexagonal prism 354	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:12.811208
1752	cube 537	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03624	cube.usd	2025-03-29 15:45:12.814923
1753	cuboid 148	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:12.816965
1754	cylinder 442	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:45:12.819195
1756	cube 539	pink	{0,0,0}	-208.50322	347.83475	894.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:13.052319
1757	cuboid 149	red	{0,0,0}	31.621342	260.87607	920	0	0	37.568592	cuboid.usd	2025-03-29 15:45:13.054301
1758	cylinder 443	green	{0,0,0}	-273.72223	218.38489	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:13.056185
1759	hexagonal prism 355	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:13.274656
1760	cube 540	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:13.278171
1761	cube 541	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	36.869896	cube.usd	2025-03-29 15:45:13.280521
1762	cylinder 444	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:13.282806
1764	cube 542	pink	{0,0,0}	-206.70456	346.4762	937.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:13.500348
1766	cylinder 445	green	{0,0,0}	-271.66885	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:45:13.504455
1719	pentagonal prism 272	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:59.203949
1725	pentagonal prism 273	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:59.209913
1727	pentagonal prism 274	red	{0,0,0}	31.621342	260.87607	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:59.440864
1735	pentagonal prism 275	black	{0,0,0}	-127.95996	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 16:11:59.665934
1739	pentagonal prism 276	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:59.906852
1741	pentagonal prism 277	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	pentagonal prism.usd	2025-03-29 16:12:00.135103
1755	pentagonal prism 278	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:00.141183
1763	pentagonal prism 279	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:12:00.363302
1765	pentagonal prism 280	red	{0,0,0}	32.482143	259.85715	911.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:12:00.370696
1767	hexagonal prism 356	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:13.727491
1768	cube 543	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.93142	cube.usd	2025-03-29 15:45:13.731672
1769	hexagonal prism 357	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:45:13.733711
1770	cylinder 446	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:13.735535
1771	hexagonal prism 358	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:13.963709
1772	cube 544	pink	{0,0,0}	-206.70456	346.4762	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:13.967223
1773	cuboid 150	red	{0,0,0}	32.482143	259.85715	915	0	0	37.69424	cuboid.usd	2025-03-29 15:45:13.969125
1774	cylinder 447	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:13.971965
1776	cube 545	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:45:14.207415
1777	cuboid 151	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:45:14.209503
1778	cylinder 448	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:14.212835
1779	hexagonal prism 359	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:14.442527
1780	cube 546	pink	{0,0,0}	-206.70456	346.4762	915	0	0	59.03625	cube.usd	2025-03-29 15:45:14.446453
1782	cylinder 449	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:14.45148
1784	cube 547	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:14.675769
1785	cube 548	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:14.678034
1786	cylinder 450	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:14.680088
1787	hexagonal prism 360	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:14.895862
1788	cube 549	pink	{0,0,0}	-208.50322	347.83475	916.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:14.89985
1789	cuboid 152	red	{0,0,0}	31.621342	260.87607	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:14.902013
1790	cylinder 451	green	{0,0,0}	-273.72223	218.38489	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:45:14.904694
1791	hexagonal prism 361	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:15.139113
1792	cube 550	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 15:45:15.141611
1793	cube 551	red	{0,0,0}	31.497837	259.85715	933	0	0	37.405357	cube.usd	2025-03-29 15:45:15.143558
1794	cylinder 452	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:15.145598
1796	cube 552	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:15.366354
1797	cuboid 153	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.40536	cuboid.usd	2025-03-29 15:45:15.368314
1798	cylinder 453	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:15.370333
1799	hexagonal prism 362	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:15.593645
1800	cube 553	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.420776	cube.usd	2025-03-29 15:45:15.597838
1801	cube 554	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:45:15.599929
1802	cylinder 454	green	{0,0,0}	-270.6119	216.68562	933	0	0	33.690063	cylinder.usd	2025-03-29 15:45:15.601963
1803	hexagonal prism 363	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:15.829337
1804	cube 555	pink	{0,0,0}	-209.49138	347.83475	917.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:15.833617
1805	cuboid 154	red	{0,0,0}	31.621342	260.87607	924	0	0	37.568592	cuboid.usd	2025-03-29 15:45:15.836054
1806	cylinder 455	green	{0,0,0}	-273.72223	218.38489	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:15.838118
1807	hexagonal prism 364	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	hexagonal prism.usd	2025-03-29 15:45:16.063441
1808	cube 556	pink	{0,0,0}	-206.88084	345.12823	913.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:16.067449
1809	cube 557	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cube.usd	2025-03-29 15:45:16.069562
1810	cylinder 456	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:16.071516
1811	hexagonal prism 365	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:16.302362
1812	cube 558	pink	{0,0,0}	-206.70456	346.4762	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:16.30603
1813	cuboid 155	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:45:16.308036
1814	cylinder 457	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:16.310125
1815	hexagonal prism 366	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:16.534195
1816	cube 559	pink	{0,0,0}	-209.49138	347.83475	920	0	0	59.534454	cube.usd	2025-03-29 15:45:16.536909
1817	cuboid 156	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	36.869896	cuboid.usd	2025-03-29 15:45:16.539191
1818	cylinder 458	green	{0,0,0}	-273.72223	218.38489	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:16.541243
1819	hexagonal prism 367	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:16.763369
1820	cube 560	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.743565	cube.usd	2025-03-29 15:45:16.767204
1821	cube 561	red	{0,0,0}	32.482143	259.85715	913.00006	0	0	37.405357	cube.usd	2025-03-29 15:45:16.769408
1781	pentagonal prism 282	red	{0,0,0}	32.482143	259.85715	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:00.609813
1783	pentagonal prism 283	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:12:00.833425
1795	pentagonal prism 284	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:00.840669
1822	cylinder 459	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	38.65981	cylinder.usd	2025-03-29 15:45:16.771535
1824	cube 562	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 15:45:16.996608
1825	cube 563	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.874985	cube.usd	2025-03-29 15:45:16.998722
1826	cylinder 460	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:17.001152
1828	cube 564	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:45:17.219545
1829	cuboid 157	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:17.221474
1830	cylinder 461	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:17.223417
1831	hexagonal prism 368	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:17.443638
1832	cube 565	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:17.447587
1833	cuboid 158	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:17.449889
1834	cylinder 462	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:17.452199
1835	hexagonal prism 369	black	{0,0,0}	-129.44986	522.7403	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:17.673537
1836	cube 566	pink	{0,0,0}	-208.50322	347.83475	914.00006	0	0	60.255116	cube.usd	2025-03-29 15:45:17.677216
1838	cylinder 463	green	{0,0,0}	-273.72223	218.38489	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:17.681059
1840	cube 567	pink	{0,0,0}	-208.67317	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:45:17.900417
1841	cuboid 159	red	{0,0,0}	31.497837	259.85715	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:17.90262
1842	cylinder 464	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:17.904743
1843	hexagonal prism 370	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:18.133437
1844	cube 568	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.62088	cube.usd	2025-03-29 15:45:18.13622
1845	cube 569	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.303947	cube.usd	2025-03-29 15:45:18.138176
1846	cylinder 465	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:18.140083
1848	cube 570	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.620872	cube.usd	2025-03-29 15:45:18.367813
1849	cuboid 160	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:18.370033
1850	cylinder 466	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:18.372057
1851	hexagonal prism 371	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:18.600176
1852	cube 571	pink	{0,0,0}	-206.88084	345.12823	913.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:18.602945
1853	cuboid 161	red	{0,0,0}	32.355774	258.8462	911.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:18.605037
1854	cylinder 467	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:18.607004
1855	hexagonal prism 372	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:18.835671
1856	cube 572	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:18.837985
1858	cylinder 468	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:18.843426
1859	hexagonal prism 373	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:19.063651
1860	cube 573	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:45:19.066522
1862	cylinder 469	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:19.071193
1863	hexagonal prism 374	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:19.292096
1864	cube 574	pink	{0,0,0}	-209.49138	347.83475	931.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:19.29471
1865	cube 575	red	{0,0,0}	31.621342	260.87607	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:19.296773
1866	cylinder 470	green	{0,0,0}	-273.72223	218.38489	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:19.298831
1868	cube 576	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:45:19.51677
1869	cuboid 162	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:19.519166
1870	cylinder 471	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:19.522194
1872	cube 577	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:45:19.737831
1873	hexagonal prism 375	red	{0,0,0}	30.51353	260.84146	920	0	0	37.69424	hexagonal prism.usd	2025-03-29 15:45:19.739926
1874	cylinder 472	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:19.74203
1827	pentagonal prism 286	red	{0,0,0}	31.621342	260.87607	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:01.091798
1837	pentagonal prism 287	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	pentagonal prism.usd	2025-03-29 16:12:01.34899
1839	pentagonal prism 288	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:01.355118
1847	pentagonal prism 289	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:12:01.607464
1857	pentagonal prism 290	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:01.61449
1861	pentagonal prism 291	black	{0,0,0}	-127.95996	519.7143	656	0	0	90	pentagonal prism.usd	2025-03-29 16:12:01.841389
1867	pentagonal prism 292	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:01.84686
1871	pentagonal prism 293	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:12:02.069482
1875	pentagonal prism 294	black	{0,0,0}	-127.95996	519.7143	657	0	0	90	pentagonal prism.usd	2025-03-29 16:12:02.312531
1876	cube 578	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:19.970647
1877	cuboid 163	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:45:19.972748
1878	cylinder 473	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:19.974873
1879	hexagonal prism 376	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:20.195488
1880	cube 579	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:20.199609
1882	cylinder 474	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:45:20.20405
1884	cube 580	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:45:20.435735
1885	cuboid 164	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:20.437807
1886	cylinder 475	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:20.439827
1888	cube 581	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.620872	cube.usd	2025-03-29 15:45:20.673078
1889	cuboid 165	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:45:20.67568
1890	cylinder 476	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:20.678954
1892	cube 582	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:20.903433
1893	cuboid 166	red	{0,0,0}	32.355774	258.8462	924	0	0	37.69424	cuboid.usd	2025-03-29 15:45:20.906051
1894	cylinder 477	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:20.908203
1896	cube 583	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:21.136469
1897	cuboid 167	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:21.138731
1898	cylinder 478	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:45:21.140712
1899	hexagonal prism 377	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:21.384183
1900	cube 584	pink	{0,0,0}	-209.49138	347.83475	924	0	0	59.620872	cube.usd	2025-03-29 15:45:21.387028
1901	cuboid 168	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:45:21.389223
1902	cylinder 479	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:21.391656
1904	cube 585	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.93142	cube.usd	2025-03-29 15:45:21.643952
1905	cuboid 169	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:21.645951
1906	cylinder 480	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:21.648007
1907	hexagonal prism 378	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:21.864235
1908	cube 586	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.93142	cube.usd	2025-03-29 15:45:21.866609
1909	cuboid 170	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:45:21.869404
1910	cylinder 481	green	{0,0,0}	-272.65317	217.53194	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:21.872059
1912	cube 587	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:22.085543
1914	cylinder 482	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:45:22.090144
1916	cube 588	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:22.335442
1918	cylinder 483	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:22.340036
1919	hexagonal prism 379	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:22.556964
1920	cube 589	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:22.5605
1921	cuboid 171	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	cuboid.usd	2025-03-29 15:45:22.562559
1922	cylinder 484	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:22.564798
1924	cube 590	pink	{0,0,0}	-207.68886	346.4762	933	0	0	59.420776	cube.usd	2025-03-29 15:45:22.794071
1925	cuboid 172	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:22.796097
1926	cylinder 485	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:45:22.798091
1927	hexagonal prism 380	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:23.019243
1928	cube 591	pink	{0,0,0}	-206.88084	345.12823	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:23.022196
1883	pentagonal prism 296	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:12:02.771306
1887	pentagonal prism 297	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 16:12:02.776999
1891	pentagonal prism 298	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:12:02.990366
1895	pentagonal prism 299	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:12:03.23991
1903	pentagonal prism 300	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:12:03.475425
1911	pentagonal prism 301	red	{0,0,0}	31.621342	260.87607	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:03.481903
1913	pentagonal prism 302	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:12:03.7006
1915	pentagonal prism 303	red	{0,0,0}	32.482143	259.85715	920	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:12:03.707286
1917	pentagonal prism 304	black	{0,0,0}	-127.95996	519.7143	657	0	0	90	pentagonal prism.usd	2025-03-29 16:12:03.942817
1923	pentagonal prism 305	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:03.948218
1929	pentagonal prism 306	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:12:04.180604
1930	cylinder 486	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:23.026709
1931	hexagonal prism 381	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:23.278559
1932	cube 592	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:23.281003
1934	cylinder 487	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:45:23.285043
1936	cube 593	pink	{0,0,0}	-208.50322	347.83475	931.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:23.510924
1938	cylinder 488	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:23.514944
1940	cube 594	pink	{0,0,0}	-208.50322	347.83475	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:23.739555
1941	cuboid 173	red	{0,0,0}	31.621342	260.87607	924	0	0	37.568592	cuboid.usd	2025-03-29 15:45:23.741677
1942	cylinder 489	green	{0,0,0}	-273.72223	218.38489	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:23.743719
1943	hexagonal prism 382	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:23.970317
1944	cube 595	pink	{0,0,0}	-206.88084	345.12823	934	0	0	59.34933	cube.usd	2025-03-29 15:45:23.974363
1945	cube 596	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:23.976381
1946	cylinder 490	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 15:45:23.978573
1948	cube 597	pink	{0,0,0}	-206.88084	345.12823	929	0	0	60.255116	cube.usd	2025-03-29 15:45:24.205008
1949	cuboid 174	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:24.207532
1950	cylinder 491	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:24.211147
1951	hexagonal prism 383	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:24.439938
1952	cube 598	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:24.443976
1953	cuboid 175	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:24.446055
1954	cylinder 492	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:24.447998
1955	hexagonal prism 384	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:24.676705
1956	cube 599	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:24.679459
1957	cuboid 176	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:45:24.681459
1958	cylinder 493	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:24.683476
1959	hexagonal prism 385	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	hexagonal prism.usd	2025-03-29 15:45:24.903706
1960	cube 600	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 15:45:24.907757
1961	cuboid 177	red	{0,0,0}	31.497837	259.85715	920	0	0	37.69424	cuboid.usd	2025-03-29 15:45:24.909824
1962	cylinder 494	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:24.911866
1963	hexagonal prism 386	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:25.134148
1964	cube 601	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:45:25.138344
1966	cylinder 495	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:45:25.142501
1967	pentagonal prism 313	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:25.355718
1968	cube 602	pink	{0,0,0}	-206.70456	346.4762	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:25.358836
1969	pentagonal prism 314	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:45:25.361013
1970	cylinder 496	green	{0,0,0}	-271.66885	217.53194	933	0	0	33.690063	cylinder.usd	2025-03-29 15:45:25.363139
1971	hexagonal prism 387	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:25.58791
1972	cube 603	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:25.592181
1973	pentagonal prism 315	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:25.594694
1974	cylinder 497	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:25.596954
1975	pentagonal prism 316	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:25.822291
1976	cube 604	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:25.826588
1977	cuboid 178	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:45:25.828603
1978	cylinder 498	green	{0,0,0}	-270.6119	216.68562	920	0	0	21.801407	cylinder.usd	2025-03-29 15:45:25.830634
1979	pentagonal prism 317	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:26.051546
1980	cube 605	pink	{0,0,0}	-205.90038	345.12823	936.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:26.053832
1981	cube 606	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:26.056254
1982	cylinder 499	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:26.058443
1983	hexagonal prism 388	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:26.27973
1935	pentagonal prism 308	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:04.42971
1937	pentagonal prism 309	black	{0,0,0}	-129.44986	521.75214	660	0	0	90	pentagonal prism.usd	2025-03-29 16:12:04.658292
1939	pentagonal prism 310	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:04.664683
1947	pentagonal prism 311	black	{0,0,0}	-129.44986	521.75214	660	0	0	90	pentagonal prism.usd	2025-03-29 16:12:04.880085
1965	pentagonal prism 312	red	{0,0,0}	31.621342	260.87607	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:12:04.887721
1984	cube 607	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:26.283951
1985	hexagonal prism 389	red	{0,0,0}	31.497837	259.85715	919	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:45:26.286246
1986	cylinder 500	green	{0,0,0}	-272.65317	217.53194	920	0	0	36.869896	cylinder.usd	2025-03-29 15:45:26.288212
1987	pentagonal prism 318	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:26.508943
1988	cube 608	pink	{0,0,0}	-205.90038	345.12823	936.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:26.512996
1989	cube 609	red	{0,0,0}	32.355774	258.8462	912.00006	0	0	37.746803	cube.usd	2025-03-29 15:45:26.515062
1990	cylinder 501	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:26.516876
1991	pentagonal prism 319	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:26.733636
1992	cube 610	pink	{0,0,0}	-206.70456	346.4762	931.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:26.738436
1993	pentagonal prism 320	red	{0,0,0}	32.482143	259.85715	924	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:45:26.740792
1994	cylinder 502	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:26.742938
1995	hexagonal prism 390	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:26.954796
1996	cube 611	pink	{0,0,0}	-208.50322	347.83475	924	0	0	59.34933	cube.usd	2025-03-29 15:45:26.957434
1997	pentagonal prism 321	red	{0,0,0}	31.621342	260.87607	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:26.959382
1998	cylinder 503	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:26.961507
1999	hexagonal prism 391	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:27.186531
2000	cube 612	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:27.190897
2001	cube 613	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:27.193232
2002	cylinder 504	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:27.195275
2003	pentagonal prism 322	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:27.434351
2004	cube 614	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.620872	cube.usd	2025-03-29 15:45:27.436999
2005	cube 615	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:27.439071
2006	cylinder 505	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 15:45:27.441432
2007	hexagonal prism 392	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:27.661011
2008	cube 616	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:45:27.664139
2009	cube 617	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:45:27.666348
2010	cylinder 506	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:45:27.668413
2011	pentagonal prism 323	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:27.88782
2012	cube 618	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:27.890598
2013	cuboid 179	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:27.893045
2014	cylinder 507	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:45:27.895031
2015	pentagonal prism 324	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:28.121288
2016	cube 619	pink	{0,0,0}	-209.49138	347.83475	910	0	0	59.03624	cube.usd	2025-03-29 15:45:28.125096
2017	cube 620	red	{0,0,0}	31.621342	260.87607	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:28.12716
2018	cylinder 508	green	{0,0,0}	-273.72223	218.38489	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:28.129177
2019	pentagonal prism 325	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:28.358481
2020	cube 621	pink	{0,0,0}	-208.50322	347.83475	934	0	0	59.420776	cube.usd	2025-03-29 15:45:28.362392
2021	pentagonal prism 326	red	{0,0,0}	31.621342	260.87607	920	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:45:28.36441
2022	cylinder 509	green	{0,0,0}	-273.72223	218.38489	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:28.366527
2023	hexagonal prism 393	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:28.588897
2024	cube 622	pink	{0,0,0}	-208.50322	347.83475	929	0	0	59.534454	cube.usd	2025-03-29 15:45:28.59319
2025	pentagonal prism 327	red	{0,0,0}	31.621342	260.87607	929	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:45:28.595477
2026	cylinder 510	green	{0,0,0}	-273.72223	218.38489	934	0	0	26.56505	cylinder.usd	2025-03-29 15:45:28.597762
2027	pentagonal prism 328	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:28.823786
2028	cube 623	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:45:28.826572
2029	pentagonal prism 329	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:45:28.828589
2030	cylinder 511	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:28.830684
2031	pentagonal prism 330	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:29.055485
2032	cube 624	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.62088	cube.usd	2025-03-29 15:45:29.059369
2033	cuboid 180	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:29.061529
2034	cylinder 512	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:29.063532
2035	pentagonal prism 331	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:29.286185
2036	cube 625	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 15:45:29.288721
2037	cube 626	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:29.290709
2038	cylinder 513	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:29.293244
2039	pentagonal prism 332	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:29.507491
2040	cube 627	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:29.510986
2041	cube 628	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:45:29.513061
2042	cylinder 514	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:45:29.515111
2043	pentagonal prism 333	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:29.745218
2044	cube 629	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 15:45:29.749955
2045	cuboid 181	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:29.752013
2046	cylinder 515	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:29.754007
2047	pentagonal prism 334	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:29.976291
2048	cube 630	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:45:29.980026
2049	cuboid 182	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:45:29.981943
2050	cylinder 516	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:29.984054
2051	hexagonal prism 394	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:30.208517
2052	cube 631	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:30.211386
2053	pentagonal prism 335	red	{0,0,0}	32.482143	259.85715	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:45:30.213612
2054	cylinder 517	green	{0,0,0}	-271.66885	217.53194	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:30.216041
2055	hexagonal prism 395	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:30.446996
2056	cube 632	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:30.451106
2057	cuboid 183	red	{0,0,0}	32.355774	258.8462	919	0	0	37.874985	cuboid.usd	2025-03-29 15:45:30.453159
2058	cylinder 518	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:30.455105
2059	pentagonal prism 336	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:30.682049
2060	cube 633	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:30.68614
2061	pentagonal prism 337	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:45:30.688386
2062	cylinder 519	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 15:45:30.690538
2063	hexagonal prism 396	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:30.908675
2064	cube 634	pink	{0,0,0}	-208.67317	346.4762	914.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:30.912343
2065	cuboid 184	red	{0,0,0}	31.497837	259.85715	915	0	0	37.568592	cuboid.usd	2025-03-29 15:45:30.914318
2066	cylinder 520	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:45:30.916335
2067	pentagonal prism 338	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:31.142732
2068	cube 635	pink	{0,0,0}	-209.49138	347.83475	920	0	0	59.620872	cube.usd	2025-03-29 15:45:31.146931
2069	cuboid 185	red	{0,0,0}	31.621342	260.87607	920	0	0	37.568592	cuboid.usd	2025-03-29 15:45:31.149011
2070	cylinder 521	green	{0,0,0}	-273.72223	218.38489	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:31.151071
2071	hexagonal prism 397	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:45:31.389099
2072	cube 636	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:45:31.391984
2073	pentagonal prism 339	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:31.394435
2074	cylinder 522	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:31.39677
2075	pentagonal prism 340	black	{0,0,0}	-128.9374	521.6551	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:31.60922
2076	cube 637	pink	{0,0,0}	-207.67778	347.44196	937.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:31.612187
2077	pentagonal prism 341	red	{0,0,0}	31.496155	260.82755	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:31.614246
2078	cylinder 523	green	{0,0,0}	-272.6386	218.50458	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:31.616445
2079	hexagonal prism 398	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:31.842338
2080	cube 638	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:31.846258
2081	cube 639	red	{0,0,0}	32.482143	259.85715	920	0	0	37.69424	cube.usd	2025-03-29 15:45:31.848182
2082	cylinder 524	green	{0,0,0}	-271.66885	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:31.85035
2083	hexagonal prism 399	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:32.075706
2084	cube 640	pink	{0,0,0}	-206.88084	345.12823	914.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:32.07969
2085	cuboid 186	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:45:32.081706
2086	cylinder 525	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:32.083852
2087	pentagonal prism 342	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:32.309734
2088	cube 641	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:32.314152
2089	cuboid 187	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:32.316959
2090	cylinder 526	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:32.319337
2091	hexagonal prism 400	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:32.540035
2092	cube 642	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:32.544412
2093	pentagonal prism 343	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:32.546666
2094	cylinder 527	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:32.548661
2095	pentagonal prism 344	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:32.775006
2096	cube 643	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:45:32.779449
2097	cuboid 188	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:45:32.781913
2098	cylinder 528	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:32.783858
2099	pentagonal prism 345	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:33.016991
2100	cube 644	pink	{0,0,0}	-206.70456	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:33.019831
2101	pentagonal prism 346	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:45:33.021819
2102	cylinder 529	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:33.023809
2103	hexagonal prism 401	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:33.251776
2104	cube 645	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:45:33.255683
2105	cube 646	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:33.257648
2106	cylinder 530	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:33.259748
2107	pentagonal prism 347	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:33.478362
2108	cube 647	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:45:33.481052
2109	cuboid 189	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	36.869896	cuboid.usd	2025-03-29 15:45:33.483125
2110	cylinder 531	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:45:33.485328
2111	hexagonal prism 402	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:33.713111
2112	cube 648	pink	{0,0,0}	-208.67317	346.4762	928.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:33.716759
2113	pentagonal prism 348	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:33.718676
2114	cylinder 532	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:45:33.720705
2115	hexagonal prism 403	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:33.94704
2116	cube 649	pink	{0,0,0}	-208.67317	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:45:33.950808
2117	cube 650	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:33.952762
2118	cylinder 533	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:33.955525
2119	hexagonal prism 404	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:34.178758
2120	cube 651	pink	{0,0,0}	-206.70456	346.4762	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:34.18144
2121	cuboid 190	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:45:34.183585
2122	cylinder 534	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:34.185559
2123	hexagonal prism 405	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:34.407485
2124	cube 652	pink	{0,0,0}	-206.88084	345.12823	932.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:34.411242
2125	cuboid 191	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:34.413389
2126	cylinder 535	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:34.415734
2127	pentagonal prism 349	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:34.636182
2128	cube 653	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:45:34.640508
2129	cuboid 192	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:45:34.642949
2130	cylinder 536	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:34.645249
2131	hexagonal prism 406	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:34.86062
2132	cube 654	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:34.863506
2133	cuboid 193	red	{0,0,0}	32.355774	258.8462	912.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:34.86567
2134	cylinder 537	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:34.867605
2135	pentagonal prism 350	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:35.094765
2136	cube 655	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:35.097821
2137	cuboid 194	red	{0,0,0}	32.355774	258.8462	929	0	0	37.874985	cuboid.usd	2025-03-29 15:45:35.099844
2138	cylinder 538	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:35.101889
2139	pentagonal prism 351	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:35.333303
2140	cube 656	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:45:35.335748
2141	cuboid 195	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	cuboid.usd	2025-03-29 15:45:35.337789
2142	cylinder 539	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:35.339637
2143	hexagonal prism 407	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:35.559031
2144	cube 657	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:35.561319
2145	pentagonal prism 352	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:45:35.563526
2146	cylinder 540	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:45:35.565724
2147	hexagonal prism 408	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:35.786159
2148	cube 658	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:45:35.789253
2149	pentagonal prism 353	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:35.791276
2150	cylinder 541	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:35.793427
2151	pentagonal prism 354	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:36.01082
2152	cube 659	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:36.015279
2153	cube 660	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:36.017667
2154	cylinder 542	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:36.019693
2155	pentagonal prism 355	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:36.245195
2156	cube 661	pink	{0,0,0}	-208.50322	347.83475	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:36.249137
2157	cuboid 196	red	{0,0,0}	31.621342	260.87607	925.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:45:36.251228
2158	cylinder 543	green	{0,0,0}	-273.72223	218.38489	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:36.253263
2159	hexagonal prism 409	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:36.480213
2160	cube 662	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:36.484083
2161	cuboid 197	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:36.486402
2162	cylinder 544	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:36.488608
2163	pentagonal prism 356	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:36.715278
2164	cube 663	pink	{0,0,0}	-208.67317	346.4762	905.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:36.719427
2165	cube 664	red	{0,0,0}	31.497837	259.85715	919	0	0	37.69424	cube.usd	2025-03-29 15:45:36.721371
2166	cylinder 545	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:45:36.723463
2167	pentagonal prism 357	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:36.945591
2168	cube 665	pink	{0,0,0}	-208.50322	347.83475	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:36.948191
2169	cuboid 198	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:36.950228
2170	cylinder 546	green	{0,0,0}	-273.72223	218.38489	935.00006	0	0	21.801407	cylinder.usd	2025-03-29 15:45:36.952269
2171	pentagonal prism 358	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:37.176217
2172	cube 666	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:37.180335
2173	cuboid 199	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:45:37.182795
2174	cylinder 547	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:37.184979
2175	pentagonal prism 359	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:37.416917
2176	cube 667	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:37.420724
2177	pentagonal prism 360	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:37.42273
2178	cylinder 548	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:45:37.424594
2179	pentagonal prism 361	black	{0,0,0}	-129.44986	522.7403	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:37.648002
2180	cube 668	pink	{0,0,0}	-209.49138	347.83475	929	0	0	59.534454	cube.usd	2025-03-29 15:45:37.651855
2181	cube 669	red	{0,0,0}	31.621342	260.87607	920	0	0	37.405357	cube.usd	2025-03-29 15:45:37.653944
2182	cylinder 549	green	{0,0,0}	-273.72223	218.38489	934	0	0	26.56505	cylinder.usd	2025-03-29 15:45:37.656181
2183	pentagonal prism 362	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:37.874588
2184	cube 670	pink	{0,0,0}	-206.88084	345.12823	931.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:37.877352
2185	cuboid 200	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:45:37.879701
2186	cylinder 550	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:37.881801
2187	hexagonal prism 410	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:38.099899
2188	cube 671	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:38.102261
2189	pentagonal prism 363	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:45:38.104299
2190	cylinder 551	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:45:38.106391
2191	pentagonal prism 364	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:45:38.3347
2192	cube 672	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:38.337451
2193	pentagonal prism 365	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:45:38.339345
2194	cylinder 552	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:38.341367
2195	hexagonal prism 411	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:38.562656
2196	cube 673	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:45:38.566545
2197	cube 674	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:45:38.568584
2198	cylinder 553	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:38.570584
2199	hexagonal prism 412	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:38.782184
2200	cube 675	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:45:38.785034
2201	cuboid 201	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:45:38.787259
2202	cylinder 554	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:38.789515
2203	hexagonal prism 413	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:39.018754
2204	cube 676	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:45:39.023033
2205	cuboid 202	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:45:39.02503
2206	cylinder 555	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:39.027334
2207	pentagonal prism 366	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:39.250025
2208	cube 677	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:39.252679
2209	pentagonal prism 367	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:39.254613
2210	cylinder 556	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:39.256589
2211	hexagonal prism 414	black	{0,0,0}	-128.9374	521.6551	654.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:39.484754
2212	cube 678	pink	{0,0,0}	-208.66203	347.44196	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:39.488919
2213	cuboid 203	red	{0,0,0}	31.496155	260.82755	913.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:45:39.491109
2214	cylinder 557	green	{0,0,0}	-272.6386	218.50458	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:39.493319
2215	pentagonal prism 368	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:39.712227
2216	cube 679	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:45:39.714984
2217	cuboid 204	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:45:39.717128
2218	cylinder 558	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:45:39.719434
2219	pentagonal prism 369	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal prism.usd	2025-03-29 15:45:39.932411
2220	cube 680	pink	{0,0,0}	-206.88084	345.12823	914.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:39.935896
2221	pentagonal prism 370	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:45:39.937979
2222	cylinder 559	green	{0,0,0}	-270.6119	216.68562	938	0	0	26.56505	cylinder.usd	2025-03-29 15:45:39.94009
2223	hexagonal prism 415	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:40.168954
2224	cube 681	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:45:40.172736
2225	cube 682	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:40.174911
2226	cylinder 560	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:40.177171
2227	pentagonal prism 371	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:40.395157
2228	cube 683	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 15:45:40.397649
2229	hexagonal prism 416	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:45:40.399712
2230	cylinder 561	green	{0,0,0}	-270.6119	216.68562	938	0	0	33.690063	cylinder.usd	2025-03-29 15:45:40.40209
2231	hexagonal prism 417	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:40.616134
2232	cube 684	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:40.619768
2233	cuboid 205	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:40.621852
2234	cylinder 562	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:40.624105
2235	pentagonal prism 372	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:40.850519
2236	cube 685	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 15:45:40.854741
2237	cuboid 206	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:45:40.856903
2238	cylinder 563	green	{0,0,0}	-270.6119	216.68562	915	0	0	26.56505	cylinder.usd	2025-03-29 15:45:40.858879
2239	pentagonal prism 373	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:45:41.085639
2240	cube 686	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:45:41.089934
2241	cube 687	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:41.091888
2242	cylinder 564	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:41.094337
2243	pentagonal prism 374	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:41.326573
2244	cube 688	pink	{0,0,0}	-206.88084	345.12823	935.00006	0	0	59.62088	cube.usd	2025-03-29 15:45:41.330303
2245	cuboid 207	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:45:41.332188
2246	cylinder 565	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:45:41.334159
2247	pentagonal prism 375	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:41.564137
2248	cube 689	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:41.566796
2249	cuboid 208	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	cuboid.usd	2025-03-29 15:45:41.569779
2250	cylinder 566	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:41.572251
2251	pentagonal prism 376	black	{0,0,0}	-129.44986	522.7403	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:41.800132
2252	cube 690	pink	{0,0,0}	-209.49138	347.83475	907.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:41.803071
2253	cube 691	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	36.869896	cube.usd	2025-03-29 15:45:41.805756
2254	cylinder 567	green	{0,0,0}	-273.72223	218.38489	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:41.808073
2255	hexagonal prism 418	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:42.030572
2256	cube 692	pink	{0,0,0}	-209.49138	347.83475	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:42.034696
2257	pentagonal prism 377	red	{0,0,0}	31.621342	260.87607	920	0	0	37.647625	pentagonal prism.usd	2025-03-29 15:45:42.037141
2258	cylinder 568	green	{0,0,0}	-273.72223	218.38489	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:42.039218
2259	pentagonal prism 378	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:42.267203
2260	cube 693	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:45:42.271337
2261	pentagonal prism 379	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:42.273489
2262	cylinder 569	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:42.276117
2263	hexagonal prism 419	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:42.495799
2264	cube 694	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:45:42.498472
2265	cube 695	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:42.500443
2266	cylinder 570	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:45:42.502407
2267	pentagonal prism 380	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:42.716605
2268	cube 696	pink	{0,0,0}	-208.67317	346.4762	915	0	0	59.03625	cube.usd	2025-03-29 15:45:42.719165
2269	pentagonal prism 381	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:42.721217
2270	cylinder 571	green	{0,0,0}	-272.65317	217.53194	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:42.723185
2271	pentagonal prism 382	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:45:42.952292
2272	cube 697	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:45:42.956205
2273	cube 698	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:42.958276
2274	cylinder 572	green	{0,0,0}	-271.66885	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:42.960499
2275	pentagonal prism 383	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:45:43.185211
2276	cube 699	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:43.189593
2277	pentagonal prism 384	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:45:43.191796
2278	cylinder 573	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:43.194073
2279	pentagonal prism 385	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:43.415119
2280	cube 700	pink	{0,0,0}	-208.67317	346.4762	936.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:43.418925
2281	pentagonal prism 386	red	{0,0,0}	31.497837	259.85715	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:45:43.421167
2282	cylinder 574	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:43.423266
2283	pentagonal prism 387	black	{0,0,0}	-128.94427	520.6986	660	0	0	90	pentagonal prism.usd	2025-03-29 15:45:43.64196
2284	cube 701	pink	{0,0,0}	-208.67317	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:43.645024
2285	pentagonal prism 388	red	{0,0,0}	31.497837	259.85715	924	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:45:43.64707
2286	cylinder 575	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:43.649327
2287	pentagonal prism 389	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:43.885046
2288	cube 702	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.420776	cube.usd	2025-03-29 15:45:43.889045
2289	cuboid 209	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:45:43.891173
2290	cylinder 576	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:43.893483
2291	pentagonal prism 390	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:44.120419
2292	cube 703	pink	{0,0,0}	-206.70456	346.4762	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:44.124544
2293	cube 704	red	{0,0,0}	32.482143	259.85715	914.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:44.126955
2294	cylinder 577	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:44.129094
2295	pentagonal prism 391	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:44.351853
2296	cube 705	pink	{0,0,0}	-206.70456	346.4762	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:44.354339
2297	hexagonal prism 420	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:45:44.356357
2298	cylinder 578	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:44.358382
2299	pentagonal prism 392	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:44.586659
2300	cube 706	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:44.590683
2301	cuboid 210	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:45:44.593071
2302	cylinder 579	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:44.595302
2303	pentagonal prism 393	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:44.818878
2304	cube 707	pink	{0,0,0}	-206.88084	345.12823	932.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:44.822917
2305	cuboid 211	red	{0,0,0}	32.355774	258.8462	912.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:44.824943
2306	cylinder 580	green	{0,0,0}	-270.6119	216.68562	920	0	0	18.434948	cylinder.usd	2025-03-29 15:45:44.827116
2307	hexagonal prism 421	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:45.057366
2308	cube 708	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:45:45.060153
2309	cuboid 212	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:45.062211
2310	cylinder 581	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:45.064297
2311	hexagonal prism 422	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:45.285149
2312	cube 709	pink	{0,0,0}	-207.68886	346.4762	907.00006	0	0	59.62088	cube.usd	2025-03-29 15:45:45.287698
2313	pentagonal prism 394	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:45.28981
2314	cylinder 582	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:45.29195
2315	hexagonal prism 423	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:45.516818
2316	cube 710	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:45.520858
2317	cuboid 213	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:45:45.52307
2318	cylinder 583	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:45.525243
2319	pentagonal prism 395	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:45.753442
2320	cube 711	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:45:45.757424
2321	cuboid 214	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:45.759743
2322	cylinder 584	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:45.761924
2323	pentagonal prism 396	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:45.987107
2324	cube 712	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:45.991016
2325	pentagonal prism 397	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:45:45.993241
2326	cylinder 585	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:45.995557
2327	hexagonal prism 424	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:46.232498
2328	cube 713	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.743565	cube.usd	2025-03-29 15:45:46.236671
2329	cube 714	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:46.239312
2330	cylinder 586	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:46.241584
2331	pentagonal prism 398	black	{0,0,0}	-127.95996	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:46.464251
2332	cube 715	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.743565	cube.usd	2025-03-29 15:45:46.466938
2333	pentagonal prism 399	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:45:46.468906
2334	cylinder 587	green	{0,0,0}	-271.66885	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:46.470841
2335	pentagonal prism 400	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:46.691691
2336	cube 716	pink	{0,0,0}	-206.88084	345.12823	913.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:46.694724
2337	cuboid 215	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:45:46.696723
2338	cylinder 588	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:46.698743
2339	hexagonal prism 425	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:46.926536
2340	cube 717	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:46.930376
2341	cube 718	red	{0,0,0}	31.497837	259.85715	924	0	0	37.303947	cube.usd	2025-03-29 15:45:46.932408
2342	cylinder 589	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:46.934444
2343	pentagonal prism 401	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:45:47.156415
2344	cube 719	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:45:47.160245
2345	cuboid 216	red	{0,0,0}	32.355774	258.8462	915	0	0	37.69424	cuboid.usd	2025-03-29 15:45:47.162168
2346	cylinder 590	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:45:47.164145
2347	pentagonal prism 402	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:47.388482
2348	cube 720	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:45:47.392413
2349	cuboid 217	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:45:47.39457
2350	cylinder 591	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:45:47.396693
2351	pentagonal prism 403	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:45:47.63008
2352	cube 721	pink	{0,0,0}	-206.70456	346.4762	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:47.633935
2353	cuboid 218	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:47.635919
2354	cylinder 592	green	{0,0,0}	-271.66885	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:45:47.637946
2355	pentagonal prism 404	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:45:47.852319
2356	cube 722	pink	{0,0,0}	-206.70456	346.4762	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:47.855002
2357	cuboid 219	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:47.856973
2358	cylinder 593	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:47.859111
2359	hexagonal prism 426	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:48.080107
2360	cube 723	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:45:48.084299
2361	cuboid 220	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:45:48.086544
2362	cylinder 594	green	{0,0,0}	-270.6119	216.68562	938	0	0	26.56505	cylinder.usd	2025-03-29 15:45:48.088654
2363	pentagonal prism 405	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:48.311743
2364	cube 724	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.62088	cube.usd	2025-03-29 15:45:48.315443
2365	cuboid 221	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:48.317597
2366	cylinder 595	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:48.319825
2367	hexagonal prism 427	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:48.547524
2368	cube 725	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:48.551502
2369	cuboid 222	red	{0,0,0}	32.355774	258.8462	915	0	0	37.69424	cuboid.usd	2025-03-29 15:45:48.553821
2370	cylinder 596	green	{0,0,0}	-270.6119	216.68562	934	0	0	33.690063	cylinder.usd	2025-03-29 15:45:48.555961
2371	pentagonal prism 406	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:48.77146
2372	cube 726	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.420776	cube.usd	2025-03-29 15:45:48.775241
2373	cuboid 223	red	{0,0,0}	31.497837	259.85715	920	0	0	37.69424	cuboid.usd	2025-03-29 15:45:48.777221
2374	cylinder 597	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:48.779354
2375	hexagonal prism 428	black	{0,0,0}	-127.45538	519.6258	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:49.009965
2376	cube 727	pink	{0,0,0}	-206.86989	346.0904	919	0	0	59.03625	cube.usd	2025-03-29 15:45:49.013385
2377	cuboid 224	red	{0,0,0}	32.354057	259.8129	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:49.015298
2378	cylinder 598	green	{0,0,0}	-270.59756	217.65457	934	0	0	26.56505	cylinder.usd	2025-03-29 15:45:49.017322
2379	hexagonal prism 429	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:49.234277
2380	cube 728	pink	{0,0,0}	-208.67317	346.4762	936.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:49.236745
2381	pentagonal prism 407	red	{0,0,0}	31.497837	259.85715	924	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:45:49.239027
2382	cylinder 599	green	{0,0,0}	-272.65317	217.53194	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:49.241462
2383	hexagonal prism 430	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:49.451414
2384	cube 729	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:45:49.453957
2385	cuboid 225	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:49.456232
2386	cylinder 600	green	{0,0,0}	-272.65317	217.53194	937.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:45:49.458375
2387	hexagonal prism 431	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:49.67337
2388	cube 730	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:45:49.676435
2389	cuboid 226	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:49.678542
2390	cylinder 601	green	{0,0,0}	-272.65317	217.53194	929	0	0	38.65981	cylinder.usd	2025-03-29 15:45:49.680603
2391	pentagonal prism 408	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:49.919685
2392	cube 731	pink	{0,0,0}	-208.50322	347.83475	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:49.923351
2393	pentagonal prism 409	red	{0,0,0}	31.621342	260.87607	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:49.925691
2394	cylinder 602	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:49.928187
2395	pentagonal prism 410	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:50.162685
2396	cube 732	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:45:50.166517
2397	pentagonal prism 411	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:50.168461
2398	cylinder 603	green	{0,0,0}	-271.66885	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:45:50.170722
2399	hexagonal prism 432	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:50.391158
2400	cube 733	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 15:45:50.395328
2401	cube 734	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:50.397333
2402	cylinder 604	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:50.399462
2403	pentagonal prism 412	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:45:50.630273
2404	cube 735	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.62088	cube.usd	2025-03-29 15:45:50.632679
2405	cuboid 227	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:45:50.634622
2406	cylinder 605	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:45:50.63644
2407	pentagonal prism 413	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:50.854646
2408	cube 736	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.62088	cube.usd	2025-03-29 15:45:50.858852
2409	cuboid 228	red	{0,0,0}	32.355774	258.8462	915	0	0	37.874985	cuboid.usd	2025-03-29 15:45:50.861329
2410	cylinder 606	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 15:45:50.863523
2411	pentagonal prism 414	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:51.100532
2412	cube 737	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:51.104668
2413	cuboid 229	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:51.106786
2414	cylinder 607	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:45:51.108984
2415	hexagonal prism 433	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	hexagonal prism.usd	2025-03-29 15:45:51.327247
2416	cube 738	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:51.330553
2417	pentagonal prism 415	red	{0,0,0}	32.355774	258.8462	920	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:45:51.33291
2418	cylinder 608	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:51.335398
2419	hexagonal prism 434	black	{0,0,0}	-129.44986	522.7403	657	0	0	0	hexagonal prism.usd	2025-03-29 15:45:51.555371
2420	cube 739	pink	{0,0,0}	-208.50322	347.83475	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:51.559993
2421	cuboid 230	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:45:51.562379
2422	cylinder 609	green	{0,0,0}	-273.72223	218.38489	929	0	0	36.869896	cylinder.usd	2025-03-29 15:45:51.564431
2423	pentagonal prism 416	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:51.789786
2424	cube 740	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:51.792634
2425	cube 741	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:51.795
2426	cylinder 610	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:51.797139
2427	hexagonal prism 435	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:52.041557
2428	cube 742	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.03624	cube.usd	2025-03-29 15:45:52.045064
2429	cuboid 231	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:52.047476
2430	cylinder 611	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:52.049638
2431	pentagonal prism 417	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:45:52.283916
2432	cube 743	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.62088	cube.usd	2025-03-29 15:45:52.288169
2433	cuboid 232	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:52.290409
2434	cylinder 612	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:52.292674
2435	hexagonal prism 436	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:52.508488
2436	cube 744	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:52.511385
2437	cuboid 233	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:52.514574
2438	cylinder 613	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:52.516901
2439	pentagonal prism 418	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:52.746806
2440	cube 745	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.620872	cube.usd	2025-03-29 15:45:52.75069
2441	cuboid 234	red	{0,0,0}	31.497837	259.85715	911.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:52.752737
2442	cylinder 614	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:52.754872
2443	pentagonal prism 419	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:52.976814
2444	cube 746	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:52.979295
2445	cube 747	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:45:52.98119
2446	cylinder 615	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:52.983167
2447	pentagonal prism 420	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:53.205698
2448	cube 748	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:53.209736
2449	cuboid 235	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:53.212303
2450	cylinder 616	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:53.214455
2451	pentagonal prism 421	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:53.454863
2452	cube 749	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:53.457972
2453	pentagonal prism 422	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:53.460285
2454	cylinder 617	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 15:45:53.462835
2455	hexagonal prism 437	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:53.682821
2456	cube 750	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:45:53.68592
2457	cuboid 236	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:53.687973
2458	cylinder 618	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:53.690338
2459	hexagonal prism 438	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:53.907118
2460	cube 751	pink	{0,0,0}	-206.88084	345.12823	933	0	0	59.03624	cube.usd	2025-03-29 15:45:53.911229
2461	pentagonal prism 423	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:45:53.913988
2462	cylinder 619	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:53.916103
2463	pentagonal prism 424	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:54.142494
2464	cube 752	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:54.146487
2465	cuboid 237	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:45:54.148592
2466	cylinder 620	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:45:54.150854
2467	pentagonal prism 425	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:54.375096
2468	cube 753	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:45:54.379518
2469	pentagonal prism 426	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:54.381841
2470	cylinder 621	green	{0,0,0}	-270.6119	216.68562	946.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:54.383813
2471	pentagonal prism 427	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:54.610946
2472	cube 754	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.03624	cube.usd	2025-03-29 15:45:54.614906
2473	cube 755	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.69424	cube.usd	2025-03-29 15:45:54.616935
2474	cylinder 622	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:54.618961
2475	hexagonal prism 439	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:45:54.842667
2476	cube 756	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:54.846871
2477	cuboid 238	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:45:54.848819
2478	cylinder 623	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:54.850913
2479	pentagonal prism 428	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:45:55.087688
2480	cube 757	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.420776	cube.usd	2025-03-29 15:45:55.091835
2481	cube 758	red	{0,0,0}	32.482143	259.85715	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:55.094185
2482	cylinder 624	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:45:55.096838
2483	pentagonal prism 429	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:45:55.307369
2484	cube 759	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:45:55.31
2485	pentagonal prism 430	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:45:55.312116
2486	cylinder 625	green	{0,0,0}	-270.6119	216.68562	920	0	0	33.690063	cylinder.usd	2025-03-29 15:45:55.314413
2487	pentagonal prism 431	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:55.526771
2488	cube 760	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.34933	cube.usd	2025-03-29 15:45:55.530057
2489	cube 761	red	{0,0,0}	31.497837	259.85715	920	0	0	37.874985	cube.usd	2025-03-29 15:45:55.532589
2490	cylinder 626	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:55.534834
2491	hexagonal prism 440	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	hexagonal prism.usd	2025-03-29 15:45:55.759474
2492	cube 762	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:55.761958
2493	cube 763	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.405357	cube.usd	2025-03-29 15:45:55.764094
2494	cylinder 627	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:55.766043
2495	pentagonal prism 432	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:45:55.982316
2496	cube 764	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.93142	cube.usd	2025-03-29 15:45:55.98535
2497	cuboid 239	red	{0,0,0}	32.355774	258.8462	929	0	0	37.647617	cuboid.usd	2025-03-29 15:45:55.987358
2498	cylinder 628	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:55.989251
2499	pentagonal prism 433	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:45:56.213313
2500	cube 765	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.420776	cube.usd	2025-03-29 15:45:56.217074
2501	pentagonal prism 434	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:56.219096
2502	cylinder 629	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:45:56.221169
2503	pentagonal prism 435	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:56.442345
2504	cube 766	pink	{0,0,0}	-205.90038	345.12823	909.00006	0	0	59.62088	cube.usd	2025-03-29 15:45:56.446549
2505	pentagonal prism 436	red	{0,0,0}	32.355774	258.8462	929	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:45:56.448754
2506	cylinder 630	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:56.450957
2507	pentagonal prism 437	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:56.681718
2508	cube 767	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.62088	cube.usd	2025-03-29 15:45:56.685427
2509	cube 768	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:56.687693
2510	cylinder 631	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:45:56.68978
2511	hexagonal prism 441	black	{0,0,0}	-127.95996	520.6986	653.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:56.908572
2512	cube 769	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:45:56.912439
2513	pentagonal prism 438	red	{0,0,0}	32.482143	259.85715	929	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:45:56.914922
2514	cylinder 632	green	{0,0,0}	-271.66885	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:56.917046
2515	pentagonal prism 439	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:57.140938
2516	cube 770	pink	{0,0,0}	-207.68886	346.4762	912.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:57.144998
2517	cuboid 240	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:45:57.147331
2518	cylinder 633	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:57.14935
2519	pentagonal prism 440	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:57.37637
2520	cube 771	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:57.378868
2521	pentagonal prism 441	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:57.381058
2522	cylinder 634	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:57.383162
2523	pentagonal prism 442	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:45:57.596372
2524	cube 772	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:57.599398
2525	cube 773	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:45:57.601517
2526	cylinder 635	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:45:57.603749
2527	hexagonal prism 442	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	hexagonal prism.usd	2025-03-29 15:45:57.836523
2528	cube 774	pink	{0,0,0}	-208.67317	346.4762	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:57.840354
2529	pentagonal prism 443	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:45:57.842436
2530	cylinder 636	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:45:57.844455
2531	pentagonal prism 444	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:58.063654
2532	cube 775	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:45:58.066349
2533	cuboid 241	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:58.068526
2534	cylinder 637	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:58.070502
2535	hexagonal prism 443	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:45:58.301793
2536	cube 776	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:58.305549
2537	hexagonal prism 444	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:45:58.307481
2538	cylinder 638	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:45:58.309581
2539	pentagonal prism 445	black	{0,0,0}	-127.95996	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:58.527877
2540	cube 777	pink	{0,0,0}	-206.70456	346.4762	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:58.531884
2541	cuboid 242	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:45:58.53418
2542	cylinder 639	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:58.536258
2543	hexagonal prism 445	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:45:58.775947
2544	cube 778	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:45:58.778354
2545	cube 779	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	cube.usd	2025-03-29 15:45:58.78026
2546	cylinder 640	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:58.782439
2547	pentagonal prism 446	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:45:58.997457
2548	cube 780	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:45:59.000566
2549	cuboid 243	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:45:59.002933
2550	cylinder 641	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:59.004889
2551	pentagonal prism 447	black	{0,0,0}	-127.95996	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:45:59.247425
2552	cube 781	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:45:59.250469
2553	cube 782	red	{0,0,0}	32.482143	259.85715	920	0	0	37.647625	cube.usd	2025-03-29 15:45:59.252582
2554	cylinder 642	green	{0,0,0}	-271.66885	217.53194	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:59.254733
2555	pentagonal prism 448	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:45:59.471045
2556	cube 783	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.420776	cube.usd	2025-03-29 15:45:59.473382
2557	cuboid 244	red	{0,0,0}	32.355774	258.8462	919	0	0	37.69424	cuboid.usd	2025-03-29 15:45:59.475321
2558	cylinder 643	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:59.477421
2559	hexagonal prism 446	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:45:59.696916
2560	cube 784	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.743565	cube.usd	2025-03-29 15:45:59.701017
2561	cuboid 245	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:45:59.70305
2562	cylinder 644	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:59.7052
2563	hexagonal prism 447	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	hexagonal prism.usd	2025-03-29 15:45:59.932049
2564	cube 785	pink	{0,0,0}	-208.67317	346.4762	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:45:59.934504
2565	pentagonal prism 449	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:45:59.936513
2566	cylinder 645	green	{0,0,0}	-272.65317	217.53194	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:45:59.938518
2567	pentagonal prism 450	black	{0,0,0}	-127.95996	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:00.159001
2568	cube 786	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:00.16144
2569	cuboid 246	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:00.163731
2570	cylinder 646	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:00.165876
2571	pentagonal prism 451	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:00.393461
2572	cube 787	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:00.397367
2573	pentagonal prism 452	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:00.39956
2574	cylinder 647	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:46:00.402063
2575	pentagonal prism 453	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:00.6169
2576	cube 788	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:46:00.619699
2577	cuboid 247	red	{0,0,0}	32.355774	258.8462	912.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:46:00.621703
2578	cylinder 648	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:00.62391
2579	pentagonal prism 454	black	{0,0,0}	-127.45538	519.6258	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:00.847263
2580	cube 789	pink	{0,0,0}	-206.86989	346.0904	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:00.850137
2581	cuboid 248	red	{0,0,0}	32.354057	259.8129	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:00.85252
2582	cylinder 649	green	{0,0,0}	-270.59756	217.65457	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:00.854602
2583	pentagonal prism 455	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:01.077281
2584	cube 790	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:01.081284
2585	pentagonal prism 456	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:01.083638
2586	cylinder 650	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:01.085842
2587	pentagonal prism 457	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:01.301208
2588	cube 791	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:01.304004
2589	cube 792	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:01.306039
2590	cylinder 651	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:01.308036
2591	pentagonal prism 458	black	{0,0,0}	-129.44986	522.7403	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:01.541366
2592	cube 793	pink	{0,0,0}	-208.50322	347.83475	930.00006	0	0	59.420776	cube.usd	2025-03-29 15:46:01.543884
2593	pentagonal prism 459	red	{0,0,0}	31.621342	260.87607	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:46:01.545881
2594	cylinder 652	green	{0,0,0}	-273.72223	218.38489	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:01.548015
2595	pentagonal prism 460	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:01.764354
2596	cube 794	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	60.255116	cube.usd	2025-03-29 15:46:01.767353
2597	pentagonal prism 461	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:46:01.770054
2598	cylinder 653	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:01.772518
2599	pentagonal prism 462	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:01.997233
2600	cube 795	pink	{0,0,0}	-205.90038	345.12823	909.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:02.000109
2601	pentagonal prism 463	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:02.002408
2602	cylinder 654	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:02.004355
2603	pentagonal prism 464	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:02.216315
2604	cube 796	pink	{0,0,0}	-209.49138	347.83475	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:02.219408
2605	cube 797	red	{0,0,0}	31.621342	260.87607	924	0	0	37.69424	cube.usd	2025-03-29 15:46:02.221851
2606	cylinder 655	green	{0,0,0}	-273.72223	218.38489	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:02.224039
2607	pentagonal prism 465	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:02.449668
2608	cube 798	pink	{0,0,0}	-206.70456	346.4762	913.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:02.453269
2609	cube 799	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.746803	cube.usd	2025-03-29 15:46:02.455344
2610	cylinder 656	green	{0,0,0}	-271.66885	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:46:02.457409
2611	pentagonal prism 466	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:02.679482
2612	cube 800	pink	{0,0,0}	-208.67317	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:02.683391
2613	cuboid 249	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.40536	cuboid.usd	2025-03-29 15:46:02.686081
2614	cylinder 657	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:02.688243
2615	hexagonal prism 448	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:02.902839
2616	cube 801	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:02.905841
2617	cube 802	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:02.907846
2618	cylinder 658	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:02.909953
2619	pentagonal prism 467	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:03.166897
2620	cube 803	pink	{0,0,0}	-206.70456	346.4762	938	0	0	59.03625	cube.usd	2025-03-29 15:46:03.172638
2621	cuboid 250	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:03.174944
2622	cylinder 659	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:03.176912
2623	hexagonal prism 449	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:46:03.393797
2624	cube 804	pink	{0,0,0}	-206.70456	346.4762	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:03.396579
2625	pentagonal prism 468	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:03.398658
2626	cylinder 660	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:03.401111
2627	pentagonal prism 469	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:03.615861
2628	cube 805	pink	{0,0,0}	-208.50322	347.83475	918.00006	0	0	59.420776	cube.usd	2025-03-29 15:46:03.619489
2629	pentagonal prism 470	red	{0,0,0}	31.621342	260.87607	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:03.621525
2630	cylinder 661	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:03.623686
2631	hexagonal prism 450	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:03.85689
2632	cube 806	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.62088	cube.usd	2025-03-29 15:46:03.861033
2633	pentagonal prism 471	red	{0,0,0}	32.355774	258.8462	924	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:46:03.863288
2634	cylinder 662	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:03.865612
2635	pentagonal prism 472	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:04.083814
2636	cube 807	pink	{0,0,0}	-209.49138	347.83475	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:04.088035
2637	cuboid 251	red	{0,0,0}	31.621342	260.87607	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:04.090041
2638	cylinder 663	green	{0,0,0}	-273.72223	218.38489	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:04.092173
2639	pentagonal prism 473	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:04.312436
2640	cube 808	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:04.315076
2641	cube 809	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:04.317049
2642	cylinder 664	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:04.319196
2643	pentagonal prism 474	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:04.536528
2644	cube 810	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.420776	cube.usd	2025-03-29 15:46:04.540112
2645	cuboid 252	red	{0,0,0}	32.355774	258.8462	912.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:46:04.542237
2646	cylinder 665	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:04.544445
2647	hexagonal prism 451	black	{0,0,0}	-129.44986	522.7403	657	0	0	0	hexagonal prism.usd	2025-03-29 15:46:04.796151
2648	cube 811	pink	{0,0,0}	-208.50322	347.83475	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:04.800201
2649	pentagonal prism 475	red	{0,0,0}	31.621342	260.87607	912.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:04.802767
2650	cylinder 666	green	{0,0,0}	-273.72223	218.38489	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:04.805236
2651	pentagonal prism 476	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:05.019457
2652	cube 812	pink	{0,0,0}	-208.67317	346.4762	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:05.023015
2653	cube 813	red	{0,0,0}	31.497837	259.85715	920	0	0	37.69424	cube.usd	2025-03-29 15:46:05.025222
2654	cylinder 667	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:05.02745
2655	pentagonal prism 477	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:05.249994
2656	cube 814	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:46:05.253808
2657	cuboid 253	red	{0,0,0}	32.355774	258.8462	919	0	0	36.869896	cuboid.usd	2025-03-29 15:46:05.255967
2658	cylinder 668	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:05.25788
2659	pentagonal prism 478	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:05.489523
2660	cube 815	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:05.493367
2661	cube 816	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:46:05.495557
2662	cylinder 669	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:05.499195
2663	pentagonal prism 479	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:05.716762
2664	cube 817	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:05.719812
2665	cube 818	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	cube.usd	2025-03-29 15:46:05.721974
2666	cylinder 670	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:05.724002
2667	pentagonal prism 480	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:05.962904
2668	cube 819	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:05.966961
2669	cuboid 254	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:46:05.968866
2670	cylinder 671	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:05.970933
2671	pentagonal prism 481	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:06.19966
2672	cube 820	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:06.203351
2673	pentagonal prism 482	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:06.205488
2674	cylinder 672	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:06.207433
2675	pentagonal prism 483	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:06.43222
2676	cube 821	pink	{0,0,0}	-206.70456	346.4762	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:06.434752
2677	cube 822	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.69424	cube.usd	2025-03-29 15:46:06.436963
2678	cylinder 673	green	{0,0,0}	-271.66885	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:06.439146
2679	pentagonal prism 484	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:06.652175
2680	cube 823	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:06.655345
2681	pentagonal prism 485	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:06.65764
2682	cylinder 674	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:06.659755
2683	pentagonal prism 486	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:06.881962
2684	cube 824	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:46:06.885668
2685	cuboid 255	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:06.888039
2686	cylinder 675	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:06.890484
2687	hexagonal prism 452	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:46:07.114247
2688	cube 825	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:07.118304
2689	cuboid 256	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:46:07.120326
2690	cylinder 676	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:46:07.12299
2691	hexagonal prism 453	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:46:07.338858
2692	cube 826	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:07.341276
2693	hexagonal prism 454	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 15:46:07.343176
2694	cylinder 677	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:46:07.345093
2695	pentagonal prism 487	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:07.575305
2696	cube 827	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:07.579136
2697	cube 828	red	{0,0,0}	32.355774	258.8462	911.00006	0	0	36.869896	cube.usd	2025-03-29 15:46:07.581104
2698	cylinder 678	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:07.583398
2699	pentagonal prism 488	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:07.801152
2700	cube 829	pink	{0,0,0}	-208.50322	347.83475	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:07.805268
2701	hexagonal prism 455	red	{0,0,0}	31.621342	260.87607	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:46:07.807452
2702	cylinder 679	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:07.809506
2703	pentagonal prism 489	black	{0,0,0}	-129.44986	522.7403	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:08.049713
2704	cube 830	pink	{0,0,0}	-209.49138	347.83475	919	0	0	59.534454	cube.usd	2025-03-29 15:46:08.05261
2705	cube 831	red	{0,0,0}	31.621342	260.87607	921.00006	0	0	37.874985	cube.usd	2025-03-29 15:46:08.054948
2706	cylinder 680	green	{0,0,0}	-273.72223	218.38489	934	0	0	26.56505	cylinder.usd	2025-03-29 15:46:08.057341
2707	pentagonal prism 490	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:08.268843
2708	cube 832	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:46:08.271578
2709	cuboid 257	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:46:08.274
2710	cylinder 681	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:08.276257
2711	pentagonal prism 491	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:08.49936
2712	cube 833	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:08.503206
2713	cuboid 258	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:46:08.505237
2714	cylinder 682	green	{0,0,0}	-272.65317	217.53194	924	0	0	18.434948	cylinder.usd	2025-03-29 15:46:08.507524
2715	hexagonal prism 456	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:08.720392
2716	cube 834	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:08.723329
2717	cuboid 259	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:46:08.725688
2718	cylinder 683	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:08.727981
2719	pentagonal prism 492	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:08.962638
2720	cube 835	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.420776	cube.usd	2025-03-29 15:46:08.966767
2721	cuboid 260	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:46:08.9689
2722	cylinder 684	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:08.971075
2723	pentagonal prism 493	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:09.186194
2724	cube 836	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:09.18964
2725	hexagonal prism 457	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:46:09.1919
2726	cylinder 685	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:09.194142
2727	pentagonal prism 494	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:09.416113
2728	cube 837	pink	{0,0,0}	-207.68886	346.4762	909.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:09.4199
2729	cube 838	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:09.422095
2730	cylinder 686	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:09.424706
2731	pentagonal prism 495	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:09.63876
2732	cube 839	pink	{0,0,0}	-208.50322	347.83475	919	0	0	59.534454	cube.usd	2025-03-29 15:46:09.641559
2733	cube 840	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	37.69424	cube.usd	2025-03-29 15:46:09.643816
2734	cylinder 687	green	{0,0,0}	-273.72223	218.38489	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:09.645701
2735	pentagonal prism 496	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:09.869376
2736	cube 841	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:09.873539
2737	pentagonal prism 497	red	{0,0,0}	32.355774	258.8462	924	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:46:09.875774
2738	cylinder 688	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:09.877918
2739	pentagonal prism 498	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:46:10.100768
2740	cube 842	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:46:10.104456
2741	cuboid 261	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:46:10.10682
2742	cylinder 689	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:10.109176
2743	pentagonal prism 499	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:10.321773
2744	cube 843	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:10.324442
2745	cuboid 262	red	{0,0,0}	31.497837	259.85715	936.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:10.326512
2746	cylinder 690	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:10.328452
2747	hexagonal prism 458	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:46:10.567181
2748	cube 844	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:46:10.571362
2749	pentagonal prism 500	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:10.573805
2750	cylinder 691	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:10.576213
2751	pentagonal prism 501	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:10.787229
2752	cube 845	pink	{0,0,0}	-208.67317	346.4762	925.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:10.790199
2753	cube 846	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:10.792473
2754	cylinder 692	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:10.794769
2755	pentagonal prism 502	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:11.0225
2756	cube 847	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:11.025161
2757	cube 848	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:11.027491
2758	cylinder 693	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:11.029772
2759	hexagonal prism 459	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:11.254124
2760	cube 849	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:46:11.25846
2761	cuboid 263	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:46:11.260785
2762	cylinder 694	green	{0,0,0}	-270.6119	216.68562	913.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:46:11.262817
2763	pentagonal prism 503	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:11.489057
2764	cube 850	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:11.49288
2765	cuboid 264	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	cuboid.usd	2025-03-29 15:46:11.495062
2766	cylinder 695	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:11.497199
2767	pentagonal prism 504	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:11.732045
2768	cube 851	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:46:11.735828
2769	pentagonal prism 505	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:46:11.737905
2770	cylinder 696	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:11.740104
2771	pentagonal prism 506	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:11.974322
2772	cube 852	pink	{0,0,0}	-206.88084	345.12823	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:11.976859
2773	cuboid 265	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	cuboid.usd	2025-03-29 15:46:11.978935
2774	cylinder 697	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:11.980921
2775	pentagonal prism 507	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:12.208364
2776	cube 853	pink	{0,0,0}	-208.67317	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:46:12.212481
2777	cuboid 266	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:46:12.214448
2778	cylinder 698	green	{0,0,0}	-272.65317	217.53194	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:12.216445
2779	hexagonal prism 460	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	hexagonal prism.usd	2025-03-29 15:46:12.442586
2780	cube 854	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:12.446841
2781	cuboid 267	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:12.448902
2782	cylinder 699	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:12.450972
2783	pentagonal prism 508	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:12.675434
2784	cube 855	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:12.678165
2785	cube 856	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cube.usd	2025-03-29 15:46:12.680433
2786	cylinder 700	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:12.682359
2787	pentagonal prism 509	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:12.907574
2788	cube 857	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:12.910587
2789	pentagonal prism 510	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:12.912776
2790	cylinder 701	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:12.914917
2791	hexagonal prism 461	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:46:13.139897
2792	cube 858	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:46:13.144031
2793	cube 859	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:13.146452
2794	cylinder 702	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:13.148565
2795	pentagonal prism 511	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:13.374802
2796	cube 860	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:13.378653
2797	cuboid 268	red	{0,0,0}	32.355774	258.8462	920	0	0	37.746803	cuboid.usd	2025-03-29 15:46:13.380799
2798	cylinder 703	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:13.383134
2799	pentagonal prism 512	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:13.609607
2800	cube 861	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:13.613344
2801	cuboid 269	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:46:13.615325
2802	cylinder 704	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:13.6174
2803	pentagonal prism 513	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:13.848227
2804	cube 862	pink	{0,0,0}	-206.70456	346.4762	917.00006	0	0	59.62088	cube.usd	2025-03-29 15:46:13.850845
2805	cube 863	red	{0,0,0}	32.482143	259.85715	913.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:13.852898
2806	cylinder 705	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:13.855112
2807	hexagonal prism 462	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:14.075163
2808	cube 864	pink	{0,0,0}	-208.67317	346.4762	906	0	0	59.743565	cube.usd	2025-03-29 15:46:14.079502
2809	pentagonal prism 514	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:14.081639
2810	cylinder 706	green	{0,0,0}	-272.65317	217.53194	929	0	0	18.434948	cylinder.usd	2025-03-29 15:46:14.083778
2811	pentagonal prism 515	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:14.310882
2812	cube 865	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:46:14.314702
2813	cuboid 270	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:14.316934
2814	cylinder 707	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:46:14.318977
2815	pentagonal prism 516	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:14.539929
2816	cube 866	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:46:14.544067
2817	pentagonal prism 517	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:14.546179
2818	cylinder 708	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:14.548186
2819	hexagonal prism 463	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	hexagonal prism.usd	2025-03-29 15:46:14.774353
2820	cube 867	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:46:14.778411
2821	cuboid 271	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:46:14.780463
2822	cylinder 709	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:14.782751
2823	pentagonal prism 518	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:15.013061
2824	cube 868	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.93142	cube.usd	2025-03-29 15:46:15.017249
2825	cuboid 272	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:46:15.019519
2826	cylinder 710	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:15.021542
2827	pentagonal prism 519	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:15.242108
2828	cube 869	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.62088	cube.usd	2025-03-29 15:46:15.244738
2829	cuboid 273	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:46:15.24689
2830	cylinder 711	green	{0,0,0}	-272.65317	217.53194	934	0	0	33.690063	cylinder.usd	2025-03-29 15:46:15.24899
2831	hexagonal prism 464	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:46:15.478769
2832	cube 870	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:15.482813
2833	hexagonal prism 465	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:46:15.484766
2834	cylinder 712	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:15.486781
2835	pentagonal prism 520	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:15.715114
2836	cube 871	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:46:15.719136
2837	pentagonal prism 521	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:15.721428
2838	cylinder 713	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:15.72359
2839	pentagonal prism 522	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:15.94184
2840	cube 872	pink	{0,0,0}	-206.70456	346.4762	928.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:15.945866
2841	pentagonal prism 523	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:46:15.948136
2842	cylinder 714	green	{0,0,0}	-271.66885	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:15.9503
2843	hexagonal prism 466	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:46:16.173793
2844	cube 873	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:16.17656
2845	cube 874	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	36.869896	cube.usd	2025-03-29 15:46:16.178867
2846	cylinder 715	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:46:16.181382
2847	hexagonal prism 467	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:46:16.403718
2848	cube 875	pink	{0,0,0}	-206.88084	345.12823	912.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:16.407825
2849	cuboid 274	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:46:16.409905
2850	cylinder 716	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:16.412269
2851	pentagonal prism 524	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:16.627944
2852	cube 876	pink	{0,0,0}	-207.68886	346.4762	935.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:16.630961
2853	cuboid 275	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:16.633163
2854	cylinder 717	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:46:16.635081
2855	hexagonal prism 468	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:46:16.860987
2856	cube 877	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:16.863331
2857	cuboid 276	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:46:16.866311
2858	cylinder 718	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:16.869158
2859	hexagonal prism 469	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:46:17.099338
2860	cube 878	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:17.103235
2861	pentagonal prism 525	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:17.105803
2862	cylinder 719	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:17.107883
2863	pentagonal prism 526	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:17.333402
2864	cube 879	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:17.33734
2865	pentagonal prism 527	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:17.339578
2866	cylinder 720	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:17.341849
2867	pentagonal prism 528	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:17.557745
2868	cube 880	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:17.561464
2869	cuboid 277	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:17.563799
2870	cylinder 721	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:17.565911
2871	pentagonal prism 529	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:17.799759
2872	cube 881	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:17.803762
2873	cuboid 278	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:46:17.806285
2874	cylinder 722	green	{0,0,0}	-270.6119	216.68562	919	0	0	18.434948	cylinder.usd	2025-03-29 15:46:17.808988
2875	hexagonal prism 470	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:46:18.052784
2876	cube 882	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:18.055614
2877	pentagonal prism 530	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:46:18.057448
2878	cylinder 723	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:18.05954
2879	pentagonal prism 531	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:18.27619
2880	cube 883	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:18.279091
2881	pentagonal prism 532	red	{0,0,0}	31.497837	259.85715	929	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:46:18.28158
2882	cylinder 724	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:18.283565
2883	pentagonal prism 533	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:18.509459
2884	cube 884	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:46:18.513418
2885	cube 885	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:18.5155
2886	cylinder 725	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:18.517559
2887	pentagonal prism 534	black	{0,0,0}	-127.95996	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:18.728713
2888	cube 886	pink	{0,0,0}	-206.70456	346.4762	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:18.732043
2889	pentagonal prism 535	red	{0,0,0}	32.482143	259.85715	929	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:46:18.734169
2890	cylinder 726	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:18.736252
2891	pentagonal prism 536	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:18.956613
2892	cube 887	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.93142	cube.usd	2025-03-29 15:46:18.960601
2893	cuboid 279	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:18.962956
2894	cylinder 727	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:18.965413
2895	pentagonal prism 537	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:19.191119
2896	cube 888	pink	{0,0,0}	-208.67317	346.4762	913.00006	0	0	59.62088	cube.usd	2025-03-29 15:46:19.193982
2897	cuboid 280	red	{0,0,0}	31.497837	259.85715	911.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:19.196471
2898	cylinder 728	green	{0,0,0}	-272.65317	217.53194	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:19.199054
2899	pentagonal prism 538	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:19.412941
2900	cube 889	pink	{0,0,0}	-209.49138	347.83475	928.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:19.416422
2901	cube 890	red	{0,0,0}	31.621342	260.87607	929	0	0	37.568592	cube.usd	2025-03-29 15:46:19.418506
2902	cylinder 729	green	{0,0,0}	-273.72223	218.38489	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:19.420719
2903	hexagonal prism 471	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	hexagonal prism.usd	2025-03-29 15:46:19.638854
2904	cube 891	pink	{0,0,0}	-206.88084	345.12823	910	0	0	59.534454	cube.usd	2025-03-29 15:46:19.643082
2905	pentagonal prism 539	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:19.645183
2906	cylinder 730	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:46:19.647714
2907	hexagonal prism 472	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:19.861132
2908	cube 892	pink	{0,0,0}	-208.67317	346.4762	932.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:19.863951
2909	pentagonal prism 540	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:19.866043
2910	cylinder 731	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:46:19.868106
2911	pentagonal prism 541	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:20.098905
2912	cube 893	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:46:20.102838
2913	cuboid 281	red	{0,0,0}	31.497837	259.85715	920	0	0	37.874985	cuboid.usd	2025-03-29 15:46:20.104786
2914	cylinder 732	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:20.106794
2915	hexagonal prism 473	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:20.339795
2916	cube 894	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:20.344152
2917	cube 895	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.647617	cube.usd	2025-03-29 15:46:20.346358
2918	cylinder 733	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:20.34868
2919	pentagonal prism 542	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:20.561302
2920	cube 896	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:20.563614
2921	cube 897	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:20.566147
2922	cylinder 734	green	{0,0,0}	-272.65317	217.53194	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:20.568269
2923	pentagonal prism 543	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:20.780107
2924	cube 898	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:20.783144
2925	cube 899	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:20.785228
2926	cylinder 735	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:20.787363
2927	pentagonal prism 544	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:21.013166
2928	cube 900	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.34933	cube.usd	2025-03-29 15:46:21.016928
2929	cuboid 282	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:46:21.019057
2930	cylinder 736	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:21.02109
2931	pentagonal prism 545	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:21.254175
2932	cube 901	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.620872	cube.usd	2025-03-29 15:46:21.258225
2933	pentagonal prism 546	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:46:21.260324
2934	cylinder 737	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:46:21.262337
2935	pentagonal prism 547	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:21.481886
2936	cube 902	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:46:21.486111
2937	pentagonal prism 548	red	{0,0,0}	32.355774	258.8462	929	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:46:21.488131
2938	cylinder 738	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:21.490265
2939	pentagonal prism 549	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:21.714436
2940	cube 903	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.03624	cube.usd	2025-03-29 15:46:21.718907
2941	cuboid 283	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:46:21.72134
2942	cylinder 739	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:21.723499
2943	hexagonal prism 474	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:46:21.948535
2944	cube 904	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:21.951412
2945	cube 905	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:21.953928
2946	cylinder 740	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:46:21.956323
2947	pentagonal prism 550	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:22.182346
2948	cube 906	pink	{0,0,0}	-207.68886	346.4762	911.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:22.184774
2949	cube 907	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:46:22.186743
2950	cylinder 741	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:46:22.188755
2951	pentagonal prism 551	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal prism.usd	2025-03-29 15:46:22.406121
2952	cube 908	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 15:46:22.410139
2953	pentagonal prism 552	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:22.41227
2954	cylinder 742	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:22.414281
2955	pentagonal prism 553	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:22.632741
2956	cube 909	pink	{0,0,0}	-206.88084	345.12823	931.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:22.636668
2957	cube 910	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	cube.usd	2025-03-29 15:46:22.638645
2958	cylinder 743	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:22.6407
2959	pentagonal prism 554	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:22.881202
2960	cube 911	pink	{0,0,0}	-208.67317	346.4762	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:22.884831
2961	cuboid 284	red	{0,0,0}	31.497837	259.85715	924	0	0	37.874985	cuboid.usd	2025-03-29 15:46:22.887035
2962	cylinder 744	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:22.889148
2963	hexagonal prism 475	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	hexagonal prism.usd	2025-03-29 15:46:23.115479
2964	cube 912	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:46:23.119558
2965	cuboid 285	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.40536	cuboid.usd	2025-03-29 15:46:23.121636
2966	cylinder 745	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:23.123756
2967	pentagonal prism 555	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:23.34804
2968	cube 913	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:46:23.350734
2969	pentagonal prism 556	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:23.352769
2970	cylinder 746	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:23.354945
2971	hexagonal prism 476	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:23.581281
2972	cube 914	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:46:23.585484
2973	cube 915	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.874985	cube.usd	2025-03-29 15:46:23.587784
2974	cylinder 747	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:23.589899
2975	pentagonal prism 557	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:23.816133
2976	cube 916	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.420776	cube.usd	2025-03-29 15:46:23.82015
2977	pentagonal prism 558	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:23.822467
2978	cylinder 748	green	{0,0,0}	-272.65317	217.53194	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:23.824475
2979	hexagonal prism 477	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	hexagonal prism.usd	2025-03-29 15:46:24.052254
2980	cube 917	pink	{0,0,0}	-208.50322	347.83475	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:24.056215
2981	cuboid 286	red	{0,0,0}	31.621342	260.87607	929	0	0	37.405357	cuboid.usd	2025-03-29 15:46:24.058224
2982	cylinder 749	green	{0,0,0}	-273.72223	218.38489	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:24.060506
2983	pentagonal prism 559	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:24.281893
2984	cube 918	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:24.285725
2985	cuboid 287	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:24.287868
2986	cylinder 750	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:24.289854
2987	pentagonal prism 560	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:24.521727
2988	cube 919	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:24.525639
2989	cube 920	red	{0,0,0}	32.355774	258.8462	924	0	0	36.869896	cube.usd	2025-03-29 15:46:24.527942
2990	cylinder 751	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:24.530174
2991	pentagonal prism 561	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:24.76082
2992	cube 921	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:24.764521
2993	cube 922	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:24.766759
2994	cylinder 752	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:24.768994
2995	pentagonal prism 562	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:24.981507
2996	cube 923	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:24.984526
2997	cube 924	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:24.986821
2998	cylinder 753	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:24.988914
2999	pentagonal prism 563	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:25.212747
3000	cube 925	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:46:25.217203
3001	pentagonal prism 564	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:46:25.220091
3002	cylinder 754	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:46:25.222348
3003	pentagonal prism 565	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:25.447551
3004	cube 926	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.34933	cube.usd	2025-03-29 15:46:25.451539
3005	cube 927	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	cube.usd	2025-03-29 15:46:25.453799
3006	cylinder 755	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:46:25.456121
3007	pentagonal prism 566	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:25.683249
3008	cube 928	pink	{0,0,0}	-205.90038	345.12823	906	0	0	59.03625	cube.usd	2025-03-29 15:46:25.687332
3009	cuboid 288	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:46:25.689458
3010	cylinder 756	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:25.69177
3011	hexagonal prism 478	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	hexagonal prism.usd	2025-03-29 15:46:25.917826
3012	cube 929	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:25.921876
3013	cube 930	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:25.923972
3014	cylinder 757	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:25.926046
3015	pentagonal prism 567	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:26.152905
3016	cube 931	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.420776	cube.usd	2025-03-29 15:46:26.155544
3017	pentagonal prism 568	red	{0,0,0}	31.497837	259.85715	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:26.157439
3018	cylinder 758	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:46:26.159479
3019	pentagonal prism 569	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:26.385622
3020	cube 932	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:46:26.388281
3021	pentagonal prism 570	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:26.390286
3022	cylinder 759	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:26.392305
3023	pentagonal prism 571	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:26.625048
3024	cube 933	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.34933	cube.usd	2025-03-29 15:46:26.629142
3025	cube 934	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.23483	cube.usd	2025-03-29 15:46:26.631094
3026	cylinder 760	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:26.633136
3027	pentagonal prism 572	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:26.850545
3028	cube 935	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 15:46:26.854159
3029	cuboid 289	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:26.856237
3030	cylinder 761	green	{0,0,0}	-270.6119	216.68562	920	0	0	38.65981	cylinder.usd	2025-03-29 15:46:26.858435
3031	pentagonal prism 573	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:27.087484
3032	cube 936	pink	{0,0,0}	-206.88084	345.12823	943	0	0	59.03625	cube.usd	2025-03-29 15:46:27.091604
3033	pentagonal prism 574	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:46:27.093901
3034	cylinder 762	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:27.096082
3035	pentagonal prism 575	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:27.317828
3036	cube 937	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:27.322039
3037	pentagonal prism 576	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:46:27.324157
3038	cylinder 763	green	{0,0,0}	-270.6119	216.68562	924	0	0	38.65981	cylinder.usd	2025-03-29 15:46:27.326357
3039	hexagonal prism 479	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:27.550535
3040	cube 938	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:27.554617
3041	pentagonal prism 577	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:27.556707
3042	cylinder 764	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:27.558881
3043	pentagonal prism 578	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:27.784868
3044	cube 939	pink	{0,0,0}	-208.50322	347.83475	934	0	0	59.34933	cube.usd	2025-03-29 15:46:27.788987
3045	pentagonal prism 579	red	{0,0,0}	31.621342	260.87607	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:27.790989
3046	cylinder 765	green	{0,0,0}	-273.72223	218.38489	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:27.793108
3047	pentagonal prism 580	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:28.019467
3048	cube 940	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:28.022393
3049	cube 941	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:28.024564
3050	cylinder 766	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:28.026649
3051	pentagonal prism 581	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:28.257919
3052	cube 942	pink	{0,0,0}	-206.70456	346.4762	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:28.261584
3053	cuboid 290	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:28.263667
3054	cylinder 767	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:28.26561
3055	pentagonal prism 582	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:28.48043
3056	cube 943	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:28.484197
3057	pentagonal prism 583	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:28.486446
3058	cylinder 768	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:28.488701
3059	pentagonal prism 584	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:28.715155
3060	cube 944	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:28.717479
3061	cuboid 291	red	{0,0,0}	32.482143	259.85715	924	0	0	37.69424	cuboid.usd	2025-03-29 15:46:28.719538
3062	cylinder 769	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:28.721484
3063	pentagonal prism 585	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:28.940442
3064	cube 945	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.743565	cube.usd	2025-03-29 15:46:28.943164
3065	cuboid 292	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:28.945159
3066	cylinder 770	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:28.947298
3067	hexagonal prism 480	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:29.164396
3068	cube 946	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:29.167977
3069	cuboid 293	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:46:29.170184
3070	cylinder 771	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:29.172649
3071	pentagonal prism 586	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:29.39114
3072	cube 947	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:29.394158
3073	pentagonal prism 587	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:29.396223
3074	cylinder 772	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:46:29.398421
3075	pentagonal prism 588	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:29.626454
3076	cube 948	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.743565	cube.usd	2025-03-29 15:46:29.630777
3077	cuboid 294	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:29.633104
3078	cylinder 773	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:29.635217
3079	pentagonal prism 589	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:29.857597
3080	cube 949	pink	{0,0,0}	-205.90038	345.12823	905.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:29.861456
3081	pentagonal prism 590	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:29.8634
3082	cylinder 774	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:29.865373
3083	pentagonal prism 591	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:30.085325
3084	cube 950	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:30.088033
3085	cuboid 295	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:46:30.090278
3086	cylinder 775	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:30.092292
3087	hexagonal prism 481	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:46:30.32098
3088	cube 951	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.620872	cube.usd	2025-03-29 15:46:30.325221
3089	pentagonal prism 592	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:30.32737
3090	cylinder 776	green	{0,0,0}	-272.65317	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:30.329486
3091	pentagonal prism 593	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:30.54925
3092	cube 952	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:30.553039
3093	hexagonal prism 482	red	{0,0,0}	31.375294	259.82666	930.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:46:30.555148
3094	cylinder 777	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:30.557734
3095	pentagonal prism 594	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:30.783637
3096	cube 953	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:30.787469
3097	pentagonal prism 595	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:30.789808
3098	cylinder 778	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:30.792071
3099	pentagonal prism 596	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:31.016226
3100	cube 954	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.743565	cube.usd	2025-03-29 15:46:31.020026
3101	cube 955	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	cube.usd	2025-03-29 15:46:31.022024
3102	cylinder 779	green	{0,0,0}	-271.66885	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:31.024751
3103	pentagonal prism 597	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:31.247059
3104	cube 956	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:46:31.250528
3105	pentagonal prism 598	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:31.252628
3106	cylinder 780	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:31.254653
3107	pentagonal prism 599	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:31.471873
3108	cube 957	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:31.474476
3109	pentagonal prism 600	red	{0,0,0}	32.482143	259.85715	924	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:46:31.476566
3110	cylinder 781	green	{0,0,0}	-271.66885	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:31.478479
3111	pentagonal prism 601	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:31.700031
3112	cube 958	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.743565	cube.usd	2025-03-29 15:46:31.703404
3113	cuboid 296	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:46:31.705378
3114	cylinder 782	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:31.707631
3115	pentagonal prism 602	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:31.93077
3116	cube 959	pink	{0,0,0}	-208.67317	346.4762	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:31.935375
3117	cube 960	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:31.937548
3118	cylinder 783	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:46:31.93957
3119	pentagonal prism 603	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:32.170889
3120	cube 961	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:32.17328
3121	cuboid 297	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:32.175599
3122	cylinder 784	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:46:32.177513
3123	pentagonal prism 604	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:32.408275
3124	cube 962	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:32.412181
3125	pentagonal prism 605	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:32.4141
3126	cylinder 785	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:32.416467
3127	pentagonal prism 606	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:32.638921
3128	cube 963	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:46:32.641261
3129	pentagonal prism 607	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:32.643688
3130	cylinder 786	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:32.64588
3131	hexagonal prism 483	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	hexagonal prism.usd	2025-03-29 15:46:32.873514
3132	cube 964	pink	{0,0,0}	-207.68886	346.4762	910	0	0	59.743565	cube.usd	2025-03-29 15:46:32.876518
3133	cuboid 298	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:46:32.878827
3134	cylinder 787	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:32.880844
3135	hexagonal prism 484	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:46:33.106463
3136	cube 965	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:46:33.110328
3137	cuboid 299	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:46:33.112653
3138	cylinder 788	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:46:33.114686
3139	pentagonal prism 608	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:33.336426
3140	cube 966	pink	{0,0,0}	-206.88084	345.12823	932.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:33.340324
3141	cube 967	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.746803	cube.usd	2025-03-29 15:46:33.342881
3142	cylinder 789	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:33.344981
3143	hexagonal prism 485	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:46:33.567417
3144	cube 968	pink	{0,0,0}	-206.70456	346.4762	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:33.571363
3145	cube 969	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:33.574002
3146	cylinder 790	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:33.576394
3147	pentagonal prism 609	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:33.80126
3148	cube 970	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:33.805213
3149	cube 971	red	{0,0,0}	32.355774	258.8462	933	0	0	37.568592	cube.usd	2025-03-29 15:46:33.807273
3150	cylinder 791	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:33.809697
3151	pentagonal prism 610	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:34.027859
3152	cube 972	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:34.030467
3153	cuboid 300	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:46:34.032406
3154	cylinder 792	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:34.034334
3155	pentagonal prism 611	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:34.258017
3156	cube 973	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.743565	cube.usd	2025-03-29 15:46:34.261056
3157	cube 974	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.746803	cube.usd	2025-03-29 15:46:34.263111
3158	cylinder 793	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:46:34.265029
3159	pentagonal prism 612	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:34.487834
3160	cube 975	pink	{0,0,0}	-205.90038	345.12823	935.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:34.491829
3161	cuboid 301	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:46:34.494065
3162	cylinder 794	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:34.496112
3163	pentagonal prism 613	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:34.726284
3164	cube 976	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:46:34.730177
3165	pentagonal prism 614	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:46:34.732288
3166	cylinder 795	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:34.734439
3167	pentagonal prism 615	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:34.958039
3168	cube 977	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:34.960691
3169	cylinder 796	red	{0,0,0}	30.51353	260.84146	922.00006	0	0	37.568592	cylinder.usd	2025-03-29 15:46:34.962783
3170	cylinder 797	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:34.964749
3171	pentagonal prism 616	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:35.193898
3172	cube 978	pink	{0,0,0}	-206.70456	346.4762	934	0	0	59.03625	cube.usd	2025-03-29 15:46:35.197458
3173	hexagonal prism 486	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:46:35.19937
3174	cylinder 798	green	{0,0,0}	-271.66885	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:35.201504
3175	hexagonal prism 487	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:35.426487
3176	cube 979	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:46:35.429276
3177	cuboid 302	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:35.431369
3178	cylinder 799	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:35.433227
3179	pentagonal prism 617	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:35.664565
3180	cube 980	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:46:35.667587
3181	cuboid 303	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:46:35.669755
3182	cylinder 800	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:35.671788
3183	hexagonal prism 488	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:46:35.895115
3184	cube 981	pink	{0,0,0}	-208.67317	346.4762	929	0	0	59.03624	cube.usd	2025-03-29 15:46:35.898896
3185	cuboid 304	red	{0,0,0}	31.497837	259.85715	933	0	0	37.568592	cuboid.usd	2025-03-29 15:46:35.901041
3186	cylinder 801	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:35.903127
3187	pentagonal prism 618	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:36.129745
3188	cube 982	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:36.133421
3189	cuboid 305	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:36.135328
3190	cylinder 802	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:36.137357
3191	pentagonal prism 619	black	{0,0,0}	-127.45538	519.6258	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:36.352946
3192	cube 983	pink	{0,0,0}	-205.88947	346.0904	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:36.355573
3193	pentagonal prism 620	red	{0,0,0}	32.354057	259.8129	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:36.357736
3194	cylinder 803	green	{0,0,0}	-270.59756	217.65457	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:36.359796
3195	pentagonal prism 621	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:36.579893
3196	cube 984	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:46:36.582982
3197	cube 985	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.874985	cube.usd	2025-03-29 15:46:36.58493
3198	cylinder 804	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:36.587088
3199	pentagonal prism 622	black	{0,0,0}	-129.44986	522.7403	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:36.808435
3200	cube 986	pink	{0,0,0}	-208.50322	347.83475	920	0	0	59.03625	cube.usd	2025-03-29 15:46:36.812596
3201	cube 987	red	{0,0,0}	31.621342	260.87607	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:36.815049
3202	cylinder 805	green	{0,0,0}	-273.72223	218.38489	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:46:36.817115
3203	hexagonal prism 489	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:37.039388
3204	cube 988	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:46:37.042196
3205	pentagonal prism 623	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:37.044636
3206	cylinder 806	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:37.046772
3207	hexagonal prism 490	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:37.256425
3208	cube 989	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:37.259179
3209	pentagonal prism 624	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:37.261502
3210	cylinder 807	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:37.263931
3211	pentagonal prism 625	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:37.493618
3212	cube 990	pink	{0,0,0}	-208.67317	346.4762	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:37.49777
3213	cube 991	red	{0,0,0}	31.497837	259.85715	929	0	0	37.405357	cube.usd	2025-03-29 15:46:37.499772
3214	cylinder 808	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:46:37.502435
3219	hexagonal prism 491	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:46:37.957711
3220	cube 993	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:37.960507
3221	pentagonal prism 627	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:46:37.962911
3222	cylinder 810	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:37.965129
3223	pentagonal prism 628	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:38.190258
3224	cube 994	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.420776	cube.usd	2025-03-29 15:46:38.1927
3225	cuboid 307	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:46:38.194772
3226	cylinder 811	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:38.19675
3227	pentagonal prism 629	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:38.422077
3228	cube 995	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:38.42495
3229	cube 996	red	{0,0,0}	32.355774	258.8462	911.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:38.427289
3230	cylinder 812	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:38.429837
3231	pentagonal prism 630	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:38.652459
3232	cube 997	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:38.657014
3233	pentagonal prism 631	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:46:38.659089
3234	cylinder 813	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:38.661584
3235	pentagonal prism 632	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:38.876003
3236	cube 998	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:38.87894
3237	cuboid 308	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:38.881256
3238	cylinder 814	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:38.883507
3239	pentagonal prism 633	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:39.11915
3240	cube 999	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 15:46:39.123516
3241	pentagonal prism 634	red	{0,0,0}	32.482143	259.85715	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:39.125605
3242	cylinder 815	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:39.127775
3243	pentagonal prism 635	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:39.351504
3244	cube 1000	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:39.355461
3245	pentagonal prism 636	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:39.358066
3246	cylinder 816	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:39.360203
3247	pentagonal prism 637	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:39.580825
3248	cube 1001	pink	{0,0,0}	-206.70456	346.4762	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:39.584766
3249	cuboid 309	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:39.586988
3250	cylinder 817	green	{0,0,0}	-271.66885	217.53194	925.00006	0	0	38.65981	cylinder.usd	2025-03-29 15:46:39.589379
3251	pentagonal prism 638	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:39.807794
3252	cube 1002	pink	{0,0,0}	-208.50322	347.83475	920	0	0	59.03625	cube.usd	2025-03-29 15:46:39.810568
3253	cube 1003	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:39.81275
3254	cylinder 818	green	{0,0,0}	-273.72223	218.38489	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:39.815072
3255	hexagonal prism 492	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:46:40.041447
3256	cube 1004	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:46:40.045587
3257	cuboid 310	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:40.04818
3258	cylinder 819	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:40.050576
3259	pentagonal prism 639	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:40.279659
3260	cube 1005	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:46:40.282365
3261	cuboid 311	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:40.284416
3262	cylinder 820	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:40.286327
3263	pentagonal prism 640	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:40.509874
3264	cube 1006	pink	{0,0,0}	-206.70456	346.4762	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:40.514259
3265	pentagonal prism 641	red	{0,0,0}	32.482143	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:40.516414
3266	cylinder 821	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:40.518537
3267	pentagonal prism 642	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:40.74501
3268	cube 1007	pink	{0,0,0}	-208.67317	346.4762	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:40.749476
3269	pentagonal prism 643	red	{0,0,0}	31.497837	259.85715	911.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:46:40.751527
3270	cylinder 822	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:40.75374
3271	pentagonal prism 644	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:40.980914
3272	cube 1008	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:46:40.984678
3273	pentagonal prism 645	red	{0,0,0}	31.497837	259.85715	913.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:40.986743
3274	cylinder 823	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:40.988857
3275	pentagonal prism 646	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:41.215033
3276	cube 1009	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 15:46:41.218901
3277	cube 1010	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:41.220886
3278	cylinder 824	green	{0,0,0}	-272.65317	217.53194	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:41.223174
3279	pentagonal prism 647	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:41.449343
3280	cube 1011	pink	{0,0,0}	-207.68886	346.4762	940.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:41.453572
3281	cube 1012	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.874985	cube.usd	2025-03-29 15:46:41.455918
3282	cylinder 825	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:41.458159
3283	pentagonal prism 648	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:41.683097
3284	cube 1013	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:41.687554
3285	hexagonal prism 493	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:46:41.68995
3286	cylinder 826	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:41.692162
3287	pentagonal prism 649	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:41.924125
3288	cube 1014	pink	{0,0,0}	-206.88084	345.12823	912.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:41.928041
3289	cuboid 312	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:46:41.930176
3290	cylinder 827	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:41.932755
3291	pentagonal prism 650	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:42.144973
3292	cube 1015	pink	{0,0,0}	-205.90038	345.12823	909.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:42.147701
3293	cube 1016	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:42.150326
3294	cylinder 828	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:42.152341
3295	hexagonal prism 494	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:46:42.379833
3296	cube 1017	pink	{0,0,0}	-206.70456	346.4762	929	0	0	59.420776	cube.usd	2025-03-29 15:46:42.382693
3297	cuboid 313	red	{0,0,0}	32.482143	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:42.384827
3298	cylinder 829	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:42.386981
3299	pentagonal prism 651	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:42.629444
3300	cube 1018	pink	{0,0,0}	-207.68886	346.4762	912.00006	0	0	59.03624	cube.usd	2025-03-29 15:46:42.633431
3301	cuboid 314	red	{0,0,0}	32.482143	259.85715	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:42.636039
3302	cylinder 830	green	{0,0,0}	-271.66885	217.53194	924	0	0	36.869896	cylinder.usd	2025-03-29 15:46:42.638094
3303	pentagonal prism 652	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:42.874723
3304	cube 1019	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:46:42.878926
3305	cube 1020	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.69424	cube.usd	2025-03-29 15:46:42.881092
3306	cylinder 831	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:46:42.883735
3307	pentagonal prism 653	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:43.095627
3308	cube 1021	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:46:43.09858
3309	hexagonal prism 495	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:46:43.100772
3310	cylinder 832	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:46:43.102723
3311	pentagonal prism 654	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:43.33685
3312	cube 1022	pink	{0,0,0}	-206.88084	345.12823	936.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:43.340977
3313	pentagonal prism 655	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:43.343205
3314	cylinder 833	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:43.345373
3315	pentagonal prism 656	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:43.560244
3316	cube 1023	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:43.565385
3317	pentagonal prism 657	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:43.567927
3318	cylinder 834	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:43.569976
3319	pentagonal prism 658	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:43.796079
3320	cube 1024	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.420776	cube.usd	2025-03-29 15:46:43.799958
3321	cube 1025	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:43.802178
3322	cylinder 835	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:43.804299
3323	pentagonal prism 659	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:44.033652
3324	cube 1026	pink	{0,0,0}	-206.70456	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:44.037863
3325	pentagonal prism 660	red	{0,0,0}	32.482143	259.85715	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:44.040056
3326	cylinder 836	green	{0,0,0}	-271.66885	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:46:44.042017
3327	hexagonal prism 496	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:46:44.271107
3328	cube 1027	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:44.275716
3329	cube 1028	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:44.278131
3330	cylinder 837	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:44.280271
3331	pentagonal prism 661	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:44.501497
3332	cube 1029	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:46:44.505716
3333	cuboid 315	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:46:44.507704
3334	cylinder 838	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:44.509755
3335	pentagonal prism 662	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:44.7336
3336	cube 1030	pink	{0,0,0}	-206.70456	346.4762	916.00006	0	0	59.62088	cube.usd	2025-03-29 15:46:44.73765
3337	cube 1031	red	{0,0,0}	32.482143	259.85715	915	0	0	37.568592	cube.usd	2025-03-29 15:46:44.739708
3338	cylinder 839	green	{0,0,0}	-271.66885	217.53194	924	0	0	33.690063	cylinder.usd	2025-03-29 15:46:44.741694
3339	pentagonal prism 663	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:44.963417
3340	cube 1032	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:44.967763
3341	pentagonal prism 664	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:44.970056
3342	cylinder 840	green	{0,0,0}	-270.6119	216.68562	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:44.973055
3343	hexagonal prism 497	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:45.198037
3344	cube 1033	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:45.200723
3345	hexagonal prism 498	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:46:45.202795
3346	cylinder 841	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:45.204876
3347	pentagonal prism 665	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:45.444595
3348	cube 1034	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:45.448835
3349	cuboid 316	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:46:45.451441
3350	cylinder 842	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:45.453528
3351	pentagonal prism 666	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:45.676257
3352	cube 1035	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:45.680096
3353	cube 1036	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:46:45.682161
3354	cylinder 843	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:45.684893
3355	pentagonal prism 667	black	{0,0,0}	-129.44986	522.7403	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:45.896994
3356	cube 1037	pink	{0,0,0}	-208.50322	347.83475	930.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:45.899916
3357	pentagonal prism 668	red	{0,0,0}	31.621342	260.87607	915	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:46:45.902185
3358	cylinder 844	green	{0,0,0}	-273.72223	218.38489	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:45.904308
3359	pentagonal prism 669	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:46.131754
3360	cube 1038	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:46:46.135848
3361	pentagonal prism 670	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:46:46.137842
3362	cylinder 845	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:46:46.139921
3363	pentagonal prism 671	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:46.372811
3364	cube 1039	pink	{0,0,0}	-207.68886	346.4762	913.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:46.375368
3365	pentagonal prism 672	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:46.377348
3366	cylinder 846	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:46.37982
3367	pentagonal prism 673	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:46.599222
3368	cube 1040	pink	{0,0,0}	-205.90038	345.12823	935.00006	0	0	59.62088	cube.usd	2025-03-29 15:46:46.604804
3369	cube 1041	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:46:46.607008
3370	cylinder 847	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:46.609177
3371	pentagonal prism 674	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:46.835948
3372	cube 1042	pink	{0,0,0}	-206.88867	345.1413	911.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:46.839953
3373	cube 1043	red	{0,0,0}	32.357	258.856	919	0	0	37.568592	cube.usd	2025-03-29 15:46:46.842017
3374	cylinder 848	green	{0,0,0}	-270.62216	216.69383	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:46.844217
3375	pentagonal prism 675	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:47.06827
3376	cube 1044	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:47.071975
3377	cuboid 317	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:46:47.07402
3378	cylinder 849	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:47.07632
3379	pentagonal prism 676	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:47.314658
3380	cube 1045	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:47.318669
3381	hexagonal prism 499	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:46:47.32101
3382	cylinder 850	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:47.323117
3383	pentagonal prism 677	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:47.542306
3384	cube 1046	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.420776	cube.usd	2025-03-29 15:46:47.546304
3385	pentagonal prism 678	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:47.548788
3386	cylinder 851	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:47.550902
3387	pentagonal prism 679	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:47.767764
3388	cube 1047	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:47.772534
3389	cuboid 318	red	{0,0,0}	32.355774	258.8462	919	0	0	38.04704	cuboid.usd	2025-03-29 15:46:47.774799
3390	cylinder 852	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:47.777013
3391	pentagonal prism 680	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:47.999157
3392	cube 1048	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:46:48.001672
3393	pentagonal prism 681	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:48.00428
3394	cylinder 853	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:48.006753
3395	pentagonal prism 682	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:46:48.235284
3396	cube 1049	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:48.2409
3397	cube 1050	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:46:48.244244
3398	cylinder 854	green	{0,0,0}	-270.6119	216.68562	913.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:48.248465
3399	pentagonal prism 683	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:48.461639
3400	cube 1051	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:48.465645
3401	pentagonal prism 684	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:48.467672
3402	cylinder 855	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:48.470198
3403	pentagonal prism 685	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:48.686979
3404	cube 1052	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:48.690068
3405	cuboid 319	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:46:48.692015
3406	cylinder 856	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:48.694271
3407	pentagonal prism 686	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:48.918065
3408	cube 1053	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:46:48.922089
3409	cube 1054	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.874985	cube.usd	2025-03-29 15:46:48.924073
3410	cylinder 857	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:48.926093
3411	hexagonal prism 500	black	{0,0,0}	-129.45485	522.7604	657	0	0	0	hexagonal prism.usd	2025-03-29 15:46:49.138724
3412	cube 1055	pink	{0,0,0}	-209.49944	347.8481	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:49.141802
3413	pentagonal prism 687	red	{0,0,0}	31.622557	260.8861	931.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:49.144026
3414	cylinder 858	green	{0,0,0}	-273.73276	218.39328	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:49.146267
3415	pentagonal prism 688	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:49.376797
3416	cube 1056	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:46:49.380963
3417	hexagonal prism 501	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:46:49.382939
3418	cylinder 859	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:46:49.38509
3419	pentagonal prism 689	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:49.604966
3420	cube 1057	pink	{0,0,0}	-208.67317	346.4762	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:49.609575
3421	pentagonal prism 690	red	{0,0,0}	31.497837	259.85715	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:49.611761
3422	cylinder 860	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:49.613839
3423	pentagonal prism 691	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:49.840767
3424	cube 1058	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:49.8446
3425	cuboid 320	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:49.846768
3426	cylinder 861	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:49.84885
3427	pentagonal prism 692	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:50.06991
3428	cube 1059	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:46:50.073799
3429	cube 1060	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:50.075917
3430	cylinder 862	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:50.077966
3431	pentagonal prism 693	black	{0,0,0}	-127.462135	518.67285	661	0	0	0	pentagonal prism.usd	2025-03-29 15:46:50.302277
3432	cube 1061	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 15:46:50.306203
3433	cube 1062	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:50.308248
3434	cylinder 863	green	{0,0,0}	-270.6119	216.68562	938	0	0	26.56505	cylinder.usd	2025-03-29 15:46:50.310617
3435	pentagonal prism 694	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:50.534065
3436	cube 1063	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:50.536779
3437	cube 1064	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:50.5393
3438	cylinder 864	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:46:50.54169
3439	pentagonal prism 695	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:50.766874
3440	cube 1065	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:46:50.770801
3441	cuboid 321	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:50.773148
3442	cylinder 865	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:50.775194
3443	pentagonal prism 696	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:51.003931
3444	cube 1066	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:46:51.008216
3445	pentagonal prism 697	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:51.010509
3446	cylinder 866	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:46:51.012683
3447	pentagonal prism 698	black	{0,0,0}	-128.94919	520.7185	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:51.237902
3448	cube 1067	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.420776	cube.usd	2025-03-29 15:46:51.242073
3449	cube 1068	red	{0,0,0}	31.499039	259.86707	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:51.244236
3450	cylinder 867	green	{0,0,0}	-272.66354	217.54024	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:51.246283
3451	pentagonal prism 699	black	{0,0,0}	-129.44986	522.7403	661	0	0	90	pentagonal prism.usd	2025-03-29 15:46:51.472064
3452	cube 1069	pink	{0,0,0}	-209.49138	347.83475	916.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:51.476194
3453	hexagonal prism 502	red	{0,0,0}	31.621342	260.87607	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:46:51.478343
3454	cylinder 868	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:51.480653
3455	pentagonal prism 700	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:51.711698
3456	cube 1070	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:46:51.715467
3457	cuboid 322	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	cuboid.usd	2025-03-29 15:46:51.717834
3458	cylinder 869	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:51.719922
3459	hexagonal prism 503	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:51.945579
3460	cube 1071	pink	{0,0,0}	-208.67317	346.4762	915	0	0	59.620872	cube.usd	2025-03-29 15:46:51.948047
3461	cuboid 323	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:46:51.950117
3462	cylinder 870	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:51.952269
3463	pentagonal prism 701	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:52.168993
3464	cube 1072	pink	{0,0,0}	-209.49138	347.83475	920	0	0	59.03625	cube.usd	2025-03-29 15:46:52.17323
3465	cuboid 324	red	{0,0,0}	31.621342	260.87607	919	0	0	37.568592	cuboid.usd	2025-03-29 15:46:52.175859
3466	cylinder 871	green	{0,0,0}	-273.72223	218.38489	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:52.17827
3467	pentagonal prism 702	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:52.40124
3468	cube 1073	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:52.404148
3469	cube 1074	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:46:52.406275
3470	cylinder 872	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:52.408898
3471	pentagonal prism 703	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:52.622127
3472	cube 1075	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:46:52.625836
3473	pentagonal prism 704	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:52.628088
3474	cylinder 873	green	{0,0,0}	-272.65317	217.53194	919	0	0	33.690063	cylinder.usd	2025-03-29 15:46:52.630282
3475	hexagonal prism 504	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:46:52.856896
3476	cube 1076	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:46:52.861056
3477	cuboid 325	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:46:52.863306
3478	cylinder 874	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:46:52.865584
3479	pentagonal prism 705	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:53.085244
3480	cube 1077	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:46:53.088457
3481	cube 1078	red	{0,0,0}	32.482143	259.85715	929	0	0	37.874985	cube.usd	2025-03-29 15:46:53.090971
3482	cylinder 875	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:53.093437
3483	pentagonal prism 706	black	{0,0,0}	-127.95996	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:53.319969
3484	cube 1079	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:46:53.322735
3485	hexagonal prism 505	red	{0,0,0}	32.482143	259.85715	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:46:53.32515
3486	cylinder 876	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:53.327406
3487	pentagonal prism 707	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:53.540671
3488	cube 1080	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:46:53.544023
3489	pentagonal prism 708	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:53.546152
3490	cylinder 877	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:53.548511
3491	pentagonal prism 709	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:53.773661
3492	cube 1081	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:53.777654
3493	cuboid 326	red	{0,0,0}	32.355774	258.8462	933	0	0	37.69424	cuboid.usd	2025-03-29 15:46:53.779943
3494	cylinder 878	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:46:53.782122
3495	pentagonal prism 710	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:54.005145
3496	cube 1082	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:54.009129
3497	cuboid 327	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:46:54.011187
3498	cylinder 879	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:54.013573
3499	pentagonal prism 711	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:54.238211
3500	cube 1083	pink	{0,0,0}	-208.67317	346.4762	934	0	0	59.03625	cube.usd	2025-03-29 15:46:54.240767
3501	cuboid 328	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:46:54.24293
3502	cylinder 880	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:54.244979
3503	pentagonal prism 712	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:54.476003
3504	cube 1084	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:46:54.47901
3505	cuboid 329	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:54.481285
3506	cylinder 881	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:54.483318
3507	pentagonal prism 713	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:54.704095
3508	cube 1085	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:54.706524
3509	cuboid 330	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:54.708765
3510	cylinder 882	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:54.711014
3511	pentagonal prism 714	black	{0,0,0}	-127.45538	519.6258	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:54.923191
3512	cube 1086	pink	{0,0,0}	-206.86989	346.0904	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:54.926781
3513	pentagonal prism 715	red	{0,0,0}	32.354057	259.8129	912.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:54.928876
3514	cylinder 883	green	{0,0,0}	-270.59756	217.65457	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:54.930889
3515	hexagonal prism 506	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:46:55.156778
3516	cube 1087	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:55.160577
3517	cuboid 331	red	{0,0,0}	32.355774	258.8462	934	0	0	37.746803	cuboid.usd	2025-03-29 15:46:55.162644
3518	cylinder 884	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:55.164876
3519	pentagonal prism 716	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:55.387506
3520	cube 1088	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:55.391667
3521	cuboid 332	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:46:55.394358
3522	cylinder 885	green	{0,0,0}	-270.6119	216.68562	934	0	0	36.869896	cylinder.usd	2025-03-29 15:46:55.396423
3523	pentagonal prism 717	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:46:55.624122
3524	cube 1089	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.34933	cube.usd	2025-03-29 15:46:55.628306
3525	pentagonal prism 718	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:55.630381
3526	cylinder 886	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:55.632627
3527	pentagonal prism 719	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:55.867391
3528	cube 1090	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:46:55.869692
3529	cube 1091	red	{0,0,0}	31.497837	259.85715	940.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:55.871683
3530	cylinder 887	green	{0,0,0}	-272.65317	217.53194	929	0	0	18.43495	cylinder.usd	2025-03-29 15:46:55.873859
3531	pentagonal prism 720	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:56.088099
3532	cube 1092	pink	{0,0,0}	-208.67317	346.4762	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:56.091114
3533	cuboid 333	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:46:56.093453
3534	cylinder 888	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:56.095688
3535	pentagonal prism 721	black	{0,0,0}	-127.95996	520.6986	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:56.305824
3536	cube 1093	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.420776	cube.usd	2025-03-29 15:46:56.308619
3537	pentagonal prism 722	red	{0,0,0}	32.482143	259.85715	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:56.310751
3538	cylinder 889	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:56.312714
3539	pentagonal prism 723	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:56.538868
3540	cube 1094	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:46:56.542552
3541	cube 1095	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.874985	cube.usd	2025-03-29 15:46:56.545048
3542	cylinder 890	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:46:56.547246
3543	pentagonal prism 724	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:56.78474
3544	cube 1096	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:46:56.789047
3545	cube 1097	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	cube.usd	2025-03-29 15:46:56.791252
3546	cylinder 891	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:56.793569
3547	pentagonal prism 725	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:57.022591
3548	cube 1098	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:57.026707
3549	cube 1099	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:46:57.02899
3550	cylinder 892	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:57.030987
3551	pentagonal prism 726	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:57.256572
3552	cube 1100	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:57.260797
3553	pentagonal prism 727	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:57.263059
3554	cylinder 893	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:57.265154
3555	pentagonal prism 728	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:46:57.488639
3556	cube 1101	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:46:57.492327
3557	cube 1102	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cube.usd	2025-03-29 15:46:57.494911
3558	cylinder 894	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:57.497032
3559	pentagonal prism 729	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:46:57.725074
3560	cube 1103	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:57.728951
3561	cuboid 334	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:46:57.731173
3562	cylinder 895	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:57.733514
3563	pentagonal prism 730	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:46:57.948089
3564	cube 1104	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.743565	cube.usd	2025-03-29 15:46:57.950438
3565	cuboid 335	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:46:57.952557
3566	cylinder 896	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:57.954522
3567	pentagonal prism 731	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:58.195092
3568	cube 1105	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.420776	cube.usd	2025-03-29 15:46:58.198906
3569	pentagonal prism 732	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:46:58.201154
3570	cylinder 897	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:58.203254
3571	pentagonal prism 733	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:58.426969
3572	cube 1106	pink	{0,0,0}	-209.49138	347.83475	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:46:58.43131
3573	cuboid 336	red	{0,0,0}	31.621342	260.87607	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:58.433679
3574	cylinder 898	green	{0,0,0}	-273.72223	218.38489	926.00006	0	0	38.65981	cylinder.usd	2025-03-29 15:46:58.436095
3575	pentagonal prism 734	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:58.661
3576	cube 1107	pink	{0,0,0}	-206.70456	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:46:58.665047
3577	cuboid 337	red	{0,0,0}	32.482143	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:58.667326
3578	cylinder 899	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:58.669448
3579	pentagonal prism 735	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:46:58.894175
3580	cube 1108	pink	{0,0,0}	-206.70456	346.4762	906	0	0	59.34933	cube.usd	2025-03-29 15:46:58.897306
3581	hexagonal prism 507	red	{0,0,0}	32.482143	259.85715	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:46:58.899313
3582	cylinder 900	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:46:58.901652
3583	pentagonal prism 736	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:59.123972
3584	cube 1109	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:46:59.126676
3585	cuboid 338	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:46:59.129147
3586	cylinder 901	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:59.131409
3587	pentagonal prism 737	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:46:59.352704
3588	cube 1110	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:46:59.35644
3589	cube 1111	red	{0,0,0}	32.355774	258.8462	919	0	0	37.874985	cube.usd	2025-03-29 15:46:59.358516
3590	cylinder 902	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:59.361091
3591	pentagonal prism 738	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:59.575283
3592	cube 1112	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.620872	cube.usd	2025-03-29 15:46:59.578358
3593	cuboid 339	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:46:59.580579
3594	cylinder 903	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:59.582609
3595	pentagonal prism 739	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:46:59.809181
3596	cube 1113	pink	{0,0,0}	-208.67317	346.4762	922.00006	0	0	60.255116	cube.usd	2025-03-29 15:46:59.81316
3597	pentagonal prism 740	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:46:59.815286
3598	cylinder 904	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:46:59.817674
3599	hexagonal prism 508	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:47:00.041646
3600	cube 1114	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:00.044319
3601	cube 1115	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:47:00.046669
3602	cylinder 905	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:00.048864
3603	hexagonal prism 509	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:47:00.263288
3604	cube 1116	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:47:00.266374
3605	pentagonal prism 741	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:00.268741
3606	cylinder 906	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:47:00.270837
3607	pentagonal prism 742	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:00.493583
3608	cube 1117	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:00.497399
3609	cube 1118	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:47:00.499397
3610	cylinder 907	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:00.501477
3611	hexagonal prism 510	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:47:00.723197
3612	cube 1119	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:00.727184
3613	cuboid 340	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:00.729353
3614	cylinder 908	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:00.731597
3615	pentagonal prism 743	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:00.963115
3616	cube 1120	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:00.966742
3617	pentagonal prism 744	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:00.969245
3618	cylinder 909	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:00.971276
3619	pentagonal prism 745	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:01.196759
3620	cube 1121	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:01.199699
3621	pentagonal prism 746	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:01.202822
3622	cylinder 910	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:01.205334
3623	pentagonal prism 747	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:01.421999
3624	cube 1122	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:01.424864
3625	cube 1123	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:01.426974
3626	cylinder 911	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:01.42909
3627	pentagonal prism 748	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:01.644125
3628	cube 1124	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:01.647021
3629	pentagonal prism 749	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:01.649254
3630	cylinder 912	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:01.651291
3631	pentagonal prism 750	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:01.876624
3632	cube 1125	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:01.880491
3633	cuboid 341	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:01.882646
3634	cylinder 913	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:01.884788
3635	pentagonal prism 751	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:02.108433
3636	cube 1126	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:02.112272
3637	cuboid 342	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	cuboid.usd	2025-03-29 15:47:02.114753
3638	cylinder 914	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:47:02.116886
3639	pentagonal prism 752	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:02.340679
3640	cube 1127	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.34933	cube.usd	2025-03-29 15:47:02.343144
3641	pentagonal prism 753	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:02.345157
3642	cylinder 915	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:02.347659
3643	pentagonal prism 754	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:02.559029
3644	cube 1128	pink	{0,0,0}	-205.90038	345.12823	938	0	0	59.534454	cube.usd	2025-03-29 15:47:02.561667
3645	cuboid 343	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:47:02.564002
3646	cylinder 916	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:02.566227
3647	pentagonal prism 755	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:02.790304
3648	cube 1129	pink	{0,0,0}	-208.67317	346.4762	911.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:02.794289
3649	hexagonal prism 511	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:47:02.796777
3650	cylinder 917	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:47:02.799331
3651	pentagonal prism 756	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:03.023676
3652	cube 1130	pink	{0,0,0}	-206.70456	346.4762	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:03.026301
3653	pentagonal prism 757	red	{0,0,0}	32.482143	259.85715	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:47:03.028621
3654	cylinder 918	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:03.030969
3655	pentagonal prism 758	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:03.24363
3656	cube 1131	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:03.246068
3657	cuboid 344	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:47:03.248341
3658	cylinder 919	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:03.250469
3659	pentagonal prism 759	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:47:03.464546
3660	cube 1132	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:03.467449
3661	cuboid 345	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:03.46959
3662	cylinder 920	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:03.471893
3663	pentagonal prism 760	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:03.695496
3664	cube 1133	pink	{0,0,0}	-208.67317	346.4762	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:03.699406
3665	hexagonal prism 512	red	{0,0,0}	31.497837	259.85715	915	0	0	37.746803	hexagonal prism.usd	2025-03-29 15:47:03.701495
3666	cylinder 921	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:03.703519
3667	pentagonal prism 761	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:03.930318
3668	cube 1134	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.743565	cube.usd	2025-03-29 15:47:03.934248
3669	cube 1135	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	cube.usd	2025-03-29 15:47:03.936328
3670	cylinder 922	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:03.938596
3671	pentagonal prism 762	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:04.15763
3672	cube 1136	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:04.16054
3673	cuboid 346	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:47:04.162509
3674	cylinder 923	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:04.164887
3675	pentagonal prism 763	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:04.381122
3676	cube 1137	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:04.384119
3677	cuboid 347	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:47:04.386064
3678	cylinder 924	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:04.388171
3679	pentagonal prism 764	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:04.616028
3680	cube 1138	pink	{0,0,0}	-206.70456	346.4762	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:04.619967
3681	cuboid 348	red	{0,0,0}	32.482143	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:04.622104
3682	cylinder 925	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:04.624222
3683	pentagonal prism 765	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:47:04.84771
3684	cube 1139	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:47:04.852008
3685	cuboid 349	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:47:04.854067
3686	cylinder 926	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:04.856188
3687	pentagonal prism 766	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:05.089714
3688	cube 1140	pink	{0,0,0}	-205.90038	345.12823	905.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:05.093953
3689	pentagonal prism 767	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:05.095929
3690	cylinder 927	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:05.098097
3691	pentagonal prism 768	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:05.309834
3692	cube 1141	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:47:05.312536
3693	cube 1142	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.746803	cube.usd	2025-03-29 15:47:05.3151
3694	cylinder 928	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:05.317586
3695	pentagonal prism 769	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:05.536979
3696	cube 1143	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.743565	cube.usd	2025-03-29 15:47:05.541399
3697	cuboid 350	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:47:05.544945
3698	cylinder 929	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:47:05.54989
3699	pentagonal prism 770	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:05.783526
3700	cube 1144	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:05.787899
3701	pentagonal prism 771	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:05.790088
3702	cylinder 930	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:05.79205
3703	pentagonal prism 772	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:06.013866
3704	cube 1145	pink	{0,0,0}	-206.70456	346.4762	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:06.017912
3705	pentagonal prism 773	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:06.020652
3706	cylinder 931	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:47:06.022773
3707	pentagonal prism 774	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:06.244009
3708	cube 1146	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:06.247885
3709	pentagonal prism 775	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:06.250274
3710	cylinder 932	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:06.25246
3711	pentagonal prism 776	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:06.479584
3712	cube 1147	pink	{0,0,0}	-206.88084	345.12823	934	0	0	59.03625	cube.usd	2025-03-29 15:47:06.483625
3713	cube 1148	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:06.485818
3714	cylinder 933	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:47:06.48829
3715	pentagonal prism 777	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:06.716202
3716	cube 1149	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:06.720343
3717	cuboid 351	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:06.722511
3718	cylinder 934	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:06.724679
3719	hexagonal prism 513	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	hexagonal prism.usd	2025-03-29 15:47:06.94904
3720	cube 1150	pink	{0,0,0}	-207.68886	346.4762	931.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:06.951981
3721	cuboid 352	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:06.95447
3722	cylinder 935	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:06.956797
3723	pentagonal prism 778	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:07.180043
3724	cube 1151	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:47:07.184089
3725	pentagonal prism 779	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:07.186391
3726	cylinder 936	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:07.188418
3727	pentagonal prism 780	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:07.414886
3728	cube 1152	pink	{0,0,0}	-206.88084	345.12823	935.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:07.419116
3729	cuboid 353	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:47:07.421193
3730	cylinder 937	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:07.423293
3731	pentagonal prism 781	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:07.645945
3732	cube 1153	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:47:07.648541
3733	cuboid 354	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:47:07.650509
3734	cylinder 938	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 15:47:07.652919
3735	hexagonal prism 514	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:47:07.874473
3736	cube 1154	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:47:07.877747
3737	cube 1155	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:07.879845
3738	cylinder 939	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:47:07.882161
3739	pentagonal prism 782	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:08.094255
3740	cube 1156	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.743565	cube.usd	2025-03-29 15:47:08.097209
3741	cuboid 355	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.694237	cuboid.usd	2025-03-29 15:47:08.099302
3742	cylinder 940	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:08.101582
3743	pentagonal prism 783	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:08.314133
3744	cube 1157	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:08.316519
3745	cuboid 356	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:08.318713
3746	cylinder 941	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:08.321765
3747	pentagonal prism 784	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:08.547847
3748	cube 1158	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:08.551775
3749	cuboid 357	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:08.554076
3750	cylinder 942	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:08.557607
3751	pentagonal prism 785	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:08.781914
3752	cube 1159	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:47:08.785691
3753	cube 1160	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:47:08.788098
3754	cylinder 943	green	{0,0,0}	-271.66885	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:08.790279
3755	pentagonal prism 786	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:09.011606
3756	cube 1161	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:09.015369
3757	cube 1162	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.405357	cube.usd	2025-03-29 15:47:09.017373
3758	cylinder 944	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:09.019937
3759	pentagonal prism 787	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:09.233562
3760	cube 1163	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:09.236994
3761	pentagonal prism 788	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:09.239009
3762	cylinder 945	green	{0,0,0}	-270.6119	216.68562	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:09.241242
3763	pentagonal prism 789	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:09.467847
3764	cube 1164	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.743565	cube.usd	2025-03-29 15:47:09.471809
3765	cube 1165	red	{0,0,0}	32.355774	258.8462	912.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:09.474116
3766	cylinder 946	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:47:09.476329
3767	pentagonal prism 790	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:09.697025
3768	cube 1166	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:09.699382
3769	hexagonal prism 515	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:47:09.702007
3770	cylinder 947	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:47:09.704368
3771	hexagonal prism 516	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:47:09.919397
3772	cube 1167	pink	{0,0,0}	-205.90038	345.12823	935.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:09.922372
3773	cuboid 358	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:47:09.924431
3774	cylinder 948	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:09.926517
3775	pentagonal prism 791	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:10.151347
3776	cube 1168	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:10.155628
3777	pentagonal prism 792	red	{0,0,0}	32.355774	258.8462	924	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:47:10.157739
3778	cylinder 949	green	{0,0,0}	-270.6119	216.68562	924	0	0	38.65981	cylinder.usd	2025-03-29 15:47:10.159732
3779	hexagonal prism 517	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	hexagonal prism.usd	2025-03-29 15:47:10.390629
3780	cube 1169	pink	{0,0,0}	-209.49138	347.83475	916.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:10.393705
3781	cube 1170	red	{0,0,0}	31.621342	260.87607	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:10.395854
3782	cylinder 950	green	{0,0,0}	-273.72223	218.38489	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:10.39801
3783	pentagonal prism 793	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:47:10.615826
3784	cube 1171	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:10.619732
3785	cuboid 359	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:10.621972
3786	cylinder 951	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:10.624098
3787	pentagonal prism 794	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:10.855474
3788	cube 1172	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:47:10.85946
3789	pentagonal prism 795	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:10.861887
3790	cylinder 952	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:10.863936
3791	pentagonal prism 796	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:11.081505
3792	cube 1173	pink	{0,0,0}	-208.67317	346.4762	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:11.084001
3793	cuboid 360	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:11.08624
3794	cylinder 953	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:11.088721
3795	pentagonal prism 797	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:11.300761
3796	cube 1174	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:47:11.304015
3797	cube 1175	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:11.306734
3798	cylinder 954	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:11.308883
3799	pentagonal prism 798	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:11.527934
3800	cube 1176	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:47:11.531995
3801	pentagonal prism 799	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:11.534005
3802	cylinder 955	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:11.536395
3803	pentagonal prism 800	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:11.76336
3804	cube 1177	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:47:11.767332
3805	cuboid 361	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:11.769942
3806	cylinder 956	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:11.772486
3807	pentagonal prism 801	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:12.002177
3808	cube 1178	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:47:12.006158
3809	cuboid 362	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:12.008385
3810	cylinder 957	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:47:12.011136
3811	pentagonal prism 802	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:12.239362
3812	cube 1179	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:12.243429
3813	cuboid 363	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:47:12.245457
3814	cylinder 958	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:47:12.247455
3815	pentagonal prism 803	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:12.467179
3816	cube 1180	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:12.469861
3817	cuboid 364	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	cuboid.usd	2025-03-29 15:47:12.472006
3818	cylinder 959	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:12.474161
3819	pentagonal prism 804	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:12.699734
3820	cube 1181	pink	{0,0,0}	-208.67317	346.4762	931.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:12.702014
3821	hexagonal prism 518	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:47:12.703977
3822	cylinder 960	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:12.70615
3823	hexagonal prism 519	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	hexagonal prism.usd	2025-03-29 15:47:12.922103
3824	cube 1182	pink	{0,0,0}	-208.67317	346.4762	919	0	0	59.34933	cube.usd	2025-03-29 15:47:12.925552
3825	cuboid 365	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:47:12.927712
3826	cylinder 961	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:47:12.93025
3827	pentagonal prism 805	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:13.159025
3828	cube 1183	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:13.161314
3829	pentagonal prism 806	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:13.163247
3830	cylinder 962	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:47:13.165203
3831	hexagonal prism 520	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:47:13.385199
3832	cube 1184	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.62088	cube.usd	2025-03-29 15:47:13.388175
3833	cube 1185	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:13.39057
3834	cylinder 963	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:13.392747
3835	hexagonal prism 521	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	hexagonal prism.usd	2025-03-29 15:47:13.605965
3836	cube 1186	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:47:13.609186
3837	cube 1187	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cube.usd	2025-03-29 15:47:13.611387
3838	cylinder 964	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:13.613496
3839	pentagonal prism 807	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:13.834827
3840	cube 1188	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:47:13.83755
3841	cuboid 366	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:13.839706
3842	cylinder 965	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:13.842066
3843	pentagonal prism 808	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:14.059055
3844	cube 1189	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:14.062097
3845	cuboid 367	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:14.064511
3846	cylinder 966	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:14.066635
3847	pentagonal prism 809	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:14.279485
3848	cube 1190	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:14.282086
3849	cuboid 368	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:14.284182
3850	cylinder 967	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 15:47:14.286091
3851	pentagonal prism 810	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:14.511391
3852	cube 1191	pink	{0,0,0}	-209.49138	347.83475	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:14.515429
3853	cuboid 369	red	{0,0,0}	31.621342	260.87607	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:14.517444
3854	cylinder 968	green	{0,0,0}	-273.72223	218.38489	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:14.51944
3855	pentagonal prism 811	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:14.736903
3856	cube 1192	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:14.740404
3857	pentagonal prism 812	red	{0,0,0}	32.355774	258.8462	919	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:14.74248
3858	cylinder 969	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:14.74538
3859	pentagonal prism 813	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:14.970608
3860	cube 1193	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.743565	cube.usd	2025-03-29 15:47:14.974369
3861	cuboid 370	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:47:14.977012
3862	cylinder 970	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:14.979348
3863	pentagonal prism 814	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:15.207645
3864	cube 1194	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 15:47:15.210197
3865	cuboid 371	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	38.290165	cuboid.usd	2025-03-29 15:47:15.212655
3866	cylinder 971	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:47:15.214794
3867	pentagonal prism 815	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:15.466029
3868	cube 1195	pink	{0,0,0}	-207.68886	346.4762	940.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:15.468273
3869	pentagonal prism 816	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:15.470183
3870	cylinder 972	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:15.472025
3871	pentagonal prism 817	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:15.700038
3872	cube 1196	pink	{0,0,0}	-208.67317	346.4762	925.00006	0	0	59.743565	cube.usd	2025-03-29 15:47:15.702798
3873	hexagonal prism 522	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:47:15.70508
3874	cylinder 973	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:15.707828
3875	pentagonal prism 818	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:15.924711
3876	cube 1197	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:47:15.928844
3877	cuboid 372	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:47:15.931661
3878	cylinder 974	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:15.934511
3879	pentagonal prism 819	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:16.165233
3880	cube 1198	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:16.168751
3881	cuboid 373	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:16.171559
3882	cylinder 975	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:16.173662
3883	pentagonal prism 820	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:16.406189
3884	cube 1199	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.62088	cube.usd	2025-03-29 15:47:16.408622
3885	cuboid 374	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:47:16.410918
3886	cylinder 976	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:16.413124
3887	pentagonal prism 821	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:47:16.637973
3888	cube 1200	pink	{0,0,0}	-207.68886	346.4762	934	0	0	59.620872	cube.usd	2025-03-29 15:47:16.641254
3889	pentagonal prism 822	red	{0,0,0}	31.497837	259.85715	924	0	0	37.647617	pentagonal prism.usd	2025-03-29 15:47:16.644077
3890	cylinder 977	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:16.646627
3891	pentagonal prism 823	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:16.866066
3892	cube 1201	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:16.869976
3893	cuboid 375	red	{0,0,0}	32.355774	258.8462	937.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:16.87199
3894	cylinder 978	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:16.873917
3895	pentagonal prism 824	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:17.103293
3896	cube 1202	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.743565	cube.usd	2025-03-29 15:47:17.107063
3897	pentagonal prism 825	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:17.109233
3898	cylinder 979	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:17.11143
3899	hexagonal prism 523	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:47:17.331422
3900	cube 1203	pink	{0,0,0}	-206.70456	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:47:17.335846
3901	pentagonal prism 826	red	{0,0,0}	32.482143	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:17.338143
3902	cylinder 980	green	{0,0,0}	-271.66885	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:17.340208
3903	pentagonal prism 827	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:47:17.580876
3904	cube 1204	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	60.255116	cube.usd	2025-03-29 15:47:17.586276
3905	cube 1205	red	{0,0,0}	31.497837	259.85715	920	0	0	37.746803	cube.usd	2025-03-29 15:47:17.590449
3906	cylinder 981	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:17.594441
3907	hexagonal prism 524	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:47:17.806345
3908	cube 1206	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.743565	cube.usd	2025-03-29 15:47:17.809167
3909	cuboid 376	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:17.811341
3910	cylinder 982	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:47:17.81334
3911	pentagonal prism 828	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:18.037444
3912	cube 1207	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:18.04026
3913	cuboid 377	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:18.042565
3914	cylinder 983	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:18.045535
3915	pentagonal prism 829	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:18.256203
3916	cube 1208	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.420776	cube.usd	2025-03-29 15:47:18.258875
3917	cuboid 378	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:47:18.261462
3918	cylinder 984	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:18.263753
3919	pentagonal prism 830	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:18.477972
3920	cube 1209	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:18.481144
3921	pentagonal prism 831	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:47:18.483184
3922	cylinder 985	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:18.485206
3923	pentagonal prism 832	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:18.701922
3924	cube 1210	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:18.704305
3925	cuboid 379	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:18.706479
3926	cylinder 986	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:18.708674
3927	pentagonal prism 833	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:18.929526
3928	cube 1211	pink	{0,0,0}	-208.67317	346.4762	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:18.932039
3929	pentagonal prism 834	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.694237	pentagonal prism.usd	2025-03-29 15:47:18.933898
3930	cylinder 987	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:18.935731
3931	pentagonal prism 835	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:19.177568
3932	cube 1212	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:19.180058
3933	cuboid 380	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:47:19.182329
3934	cylinder 988	green	{0,0,0}	-272.65317	217.53194	920	0	0	36.869896	cylinder.usd	2025-03-29 15:47:19.184462
3935	pentagonal prism 836	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:47:19.412803
3936	cube 1213	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:19.416006
3937	cuboid 381	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:19.41814
3938	cylinder 989	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:47:19.420372
3939	pentagonal prism 837	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:19.641507
3940	cube 1214	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:19.645743
3941	cuboid 382	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:19.648131
3942	cylinder 990	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:19.650326
3943	pentagonal prism 838	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:19.873051
3944	cube 1215	pink	{0,0,0}	-205.90038	345.12823	939.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:19.87566
3945	cylinder 991	red	{0,0,0}	32.355774	258.8462	919	0	0	37.874985	cylinder.usd	2025-03-29 15:47:19.877798
3946	cylinder 992	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:19.880407
3947	pentagonal prism 839	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:20.103157
3948	cube 1216	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.620872	cube.usd	2025-03-29 15:47:20.107198
3949	cube 1217	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.746803	cube.usd	2025-03-29 15:47:20.109233
3950	cylinder 993	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:20.111571
3951	pentagonal prism 840	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:20.342113
3952	cube 1218	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:20.34634
3953	cuboid 383	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	cuboid.usd	2025-03-29 15:47:20.348714
3954	cylinder 994	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:20.350795
3955	pentagonal prism 841	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:47:20.575711
3956	cube 1219	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:20.578024
3957	cuboid 384	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:47:20.580334
3958	cylinder 995	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:47:20.582579
3959	pentagonal prism 842	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:20.807826
3960	cube 1220	pink	{0,0,0}	-206.88084	345.12823	939.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:20.811593
3961	cuboid 385	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:47:20.814454
3962	cylinder 996	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:20.817102
3963	pentagonal prism 843	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:21.031243
3964	cube 1221	pink	{0,0,0}	-206.88084	345.12823	936.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:21.034296
3965	cylinder 997	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cylinder.usd	2025-03-29 15:47:21.036408
3966	cylinder 998	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:21.038549
3967	pentagonal prism 844	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:21.260379
3968	cube 1222	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:47:21.264434
3969	cuboid 386	red	{0,0,0}	31.497837	259.85715	924	0	0	37.874985	cuboid.usd	2025-03-29 15:47:21.266601
3970	cylinder 999	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:21.268678
3971	pentagonal prism 845	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:21.497235
3972	cube 1223	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:47:21.501275
3973	cuboid 387	red	{0,0,0}	31.497837	259.85715	929	0	0	37.405357	cuboid.usd	2025-03-29 15:47:21.503348
3974	cylinder 1000	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:21.505433
3975	pentagonal prism 846	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:21.729276
3976	cube 1224	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 15:47:21.733473
3977	cube 1225	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:21.735579
3978	cylinder 1001	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:47:21.737626
3979	pentagonal prism 847	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:21.95831
3980	cube 1226	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:21.961094
3981	cuboid 388	red	{0,0,0}	31.497837	259.85715	919	0	0	37.405357	cuboid.usd	2025-03-29 15:47:21.963398
3982	cylinder 1002	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:21.965645
3983	pentagonal prism 848	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:47:22.180222
3984	cube 1227	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:22.183531
3985	hexagonal prism 525	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:47:22.185819
3986	cylinder 1003	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:47:22.187942
3987	pentagonal prism 849	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:22.412904
3988	cube 1228	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:47:22.415816
3989	cuboid 389	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:22.418464
3990	cylinder 1004	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:22.420945
3991	pentagonal prism 850	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:22.643692
3992	cube 1229	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:22.646474
3993	pentagonal prism 851	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:22.648648
3994	cylinder 1005	green	{0,0,0}	-271.66885	217.53194	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:22.651092
3995	pentagonal prism 852	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:22.907671
3996	cube 1230	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.420776	cube.usd	2025-03-29 15:47:22.9106
3997	cube 1231	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:22.912781
3998	cylinder 1006	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:22.9156
3999	pentagonal prism 853	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:23.131339
4000	cube 1232	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:23.134127
4001	cube 1233	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cube.usd	2025-03-29 15:47:23.136184
4002	cylinder 1007	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:47:23.138229
4003	hexagonal prism 526	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:47:23.3731
4004	cube 1234	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.34933	cube.usd	2025-03-29 15:47:23.375677
4005	cuboid 390	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:23.377793
4006	cylinder 1008	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:23.380309
4007	pentagonal prism 854	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:23.593733
4008	cube 1235	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:23.596523
4009	pentagonal prism 855	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:23.598744
4010	cylinder 1009	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:23.600766
4011	pentagonal prism 856	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:23.833734
4012	cube 1236	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:47:23.836387
4013	cube 1237	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.746803	cube.usd	2025-03-29 15:47:23.838399
4014	cylinder 1010	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:47:23.840438
4015	pentagonal prism 857	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:24.058705
4016	cube 1238	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:24.063001
4017	cube 1239	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:24.066034
4018	cylinder 1011	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:47:24.068503
4019	pentagonal prism 858	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:24.292569
4020	cube 1240	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.420776	cube.usd	2025-03-29 15:47:24.296179
4021	cuboid 391	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:24.298428
4022	cylinder 1012	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:24.300643
4023	pentagonal prism 859	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:24.538365
4024	cube 1241	pink	{0,0,0}	-207.68886	346.4762	915	0	0	59.03625	cube.usd	2025-03-29 15:47:24.540859
4025	hexagonal prism 527	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.746803	hexagonal prism.usd	2025-03-29 15:47:24.542905
4026	cylinder 1013	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:47:24.544858
4027	pentagonal prism 860	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:24.763748
4028	cube 1242	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:24.766888
4029	cuboid 392	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:24.76916
4030	cylinder 1014	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:24.77144
4031	pentagonal prism 861	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:24.997074
4032	cube 1243	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.743565	cube.usd	2025-03-29 15:47:25.00099
4033	cuboid 393	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:25.003201
4034	cylinder 1015	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:47:25.005217
4035	hexagonal prism 528	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:47:25.226424
4036	cube 1244	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:47:25.230214
4037	cylinder 1016	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	cylinder.usd	2025-03-29 15:47:25.23254
4038	cylinder 1017	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:25.234951
4039	pentagonal prism 862	black	{0,0,0}	-129.44986	522.7403	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:25.445529
4040	cube 1245	pink	{0,0,0}	-209.49138	347.83475	917.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:25.448217
4041	pentagonal prism 863	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:25.450286
4042	cylinder 1018	green	{0,0,0}	-273.72223	218.38489	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:25.452597
4043	pentagonal prism 864	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:25.663355
4044	cube 1246	pink	{0,0,0}	-206.70456	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 15:47:25.666014
4045	cuboid 394	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:25.668201
4046	cylinder 1019	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:25.6703
4047	pentagonal prism 865	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:25.896332
4048	cube 1247	pink	{0,0,0}	-208.67317	346.4762	911.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:25.900327
4049	cube 1248	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:25.90269
4050	cylinder 1020	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:25.905865
4051	pentagonal prism 866	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:26.136933
4052	cube 1249	pink	{0,0,0}	-208.67317	346.4762	922.00006	0	0	59.420776	cube.usd	2025-03-29 15:47:26.139428
4053	cube 1250	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:47:26.141483
4054	cylinder 1021	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:26.143463
4055	pentagonal prism 867	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:26.360296
4056	cube 1251	pink	{0,0,0}	-208.67317	346.4762	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:26.364281
4057	cuboid 395	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cuboid.usd	2025-03-29 15:47:26.366708
4058	cylinder 1022	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:47:26.369014
4059	pentagonal prism 868	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:26.580425
4060	cube 1252	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:47:26.582922
4061	cuboid 396	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:26.585046
4062	cylinder 1023	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:47:26.587278
4063	pentagonal prism 869	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:26.815715
4064	cube 1253	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:26.81875
4065	cuboid 397	red	{0,0,0}	32.355774	258.8462	924	0	0	37.647617	cuboid.usd	2025-03-29 15:47:26.821222
4066	cylinder 1024	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:26.823296
4067	pentagonal prism 870	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:27.049847
4068	cube 1254	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.743565	cube.usd	2025-03-29 15:47:27.054082
4069	cuboid 398	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:27.056541
4070	cylinder 1025	green	{0,0,0}	-271.66885	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:27.058656
4071	pentagonal prism 871	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:27.277005
4072	cube 1255	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:47:27.279532
4073	cuboid 399	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:47:27.281638
4074	cylinder 1026	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:27.284018
4075	pentagonal prism 872	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:27.49839
4076	cube 1256	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:27.501289
4077	cuboid 400	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:27.503483
4078	cylinder 1027	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:27.505793
4079	pentagonal prism 873	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:27.733216
4080	cube 1257	pink	{0,0,0}	-206.70456	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:27.7374
4081	cuboid 401	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:27.739547
4082	cylinder 1028	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:27.741628
4083	pentagonal prism 874	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:27.963857
4084	cube 1258	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 15:47:27.966524
4085	hexagonal prism 529	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.69424	hexagonal prism.usd	2025-03-29 15:47:27.969059
4086	cylinder 1029	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:27.971235
4087	pentagonal prism 875	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:28.200357
4088	cube 1259	pink	{0,0,0}	-206.88084	345.12823	907.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:28.205108
4089	cuboid 402	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:28.20738
4090	cylinder 1030	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:28.209583
4091	pentagonal prism 876	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:28.436147
4092	cube 1260	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.743565	cube.usd	2025-03-29 15:47:28.439886
4093	cuboid 403	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cuboid.usd	2025-03-29 15:47:28.441961
4094	cylinder 1031	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:28.444024
4095	pentagonal prism 877	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:47:28.663957
4096	cube 1261	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:28.668036
4097	pentagonal prism 878	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:47:28.670163
4098	cylinder 1032	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:28.672373
4099	pentagonal prism 879	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:28.888512
4100	cube 1262	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:47:28.891418
4101	cuboid 404	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:28.893476
4102	cylinder 1033	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:28.895839
4103	pentagonal prism 880	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:29.114674
4104	cube 1263	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:29.118984
4105	pentagonal prism 881	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:29.121503
4106	cylinder 1034	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:29.124383
4107	pentagonal prism 882	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:47:29.362902
4108	cube 1264	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:47:29.366602
4109	pentagonal prism 883	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:29.368776
4110	cylinder 1035	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:29.370917
4111	pentagonal prism 884	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:29.592095
4112	cube 1265	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 15:47:29.594975
4113	pentagonal prism 885	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	38.157227	pentagonal prism.usd	2025-03-29 15:47:29.597084
4114	cylinder 1036	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:47:29.599233
4115	pentagonal prism 886	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:29.817306
4116	cube 1266	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:29.820358
4117	pentagonal prism 887	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:29.822793
4118	cylinder 1037	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:47:29.824802
4119	hexagonal prism 530	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:47:30.055639
4120	cube 1267	pink	{0,0,0}	-206.88084	345.12823	935.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:30.058294
4121	cuboid 405	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:30.060283
4122	cylinder 1038	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:30.062401
4123	pentagonal prism 888	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:30.282164
4124	cube 1268	pink	{0,0,0}	-206.70456	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:30.286291
4125	pentagonal prism 889	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:30.288456
4126	cylinder 1039	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:30.290762
4127	pentagonal prism 890	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:30.530311
4128	cube 1269	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:47:30.534314
4129	hexagonal prism 531	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:47:30.53675
4130	cylinder 1040	green	{0,0,0}	-270.6119	216.68562	933	0	0	18.434948	cylinder.usd	2025-03-29 15:47:30.539085
4131	pentagonal prism 891	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:30.750221
4132	cube 1270	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:30.75434
4133	cuboid 406	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:30.756984
4134	cylinder 1041	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:47:30.759293
4135	pentagonal prism 892	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:30.995192
4136	cube 1271	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:30.999234
4137	cuboid 407	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:47:31.001256
4138	cylinder 1042	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:47:31.003563
4139	pentagonal prism 893	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:31.215647
4140	cube 1272	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.420776	cube.usd	2025-03-29 15:47:31.218399
4141	cuboid 408	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:47:31.220548
4142	cylinder 1043	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:31.222947
4143	pentagonal prism 894	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:31.446541
4144	cube 1273	pink	{0,0,0}	-208.67317	346.4762	914.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:31.449479
4145	pentagonal prism 895	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:31.451594
4146	cylinder 1044	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:31.453749
4147	pentagonal prism 896	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:31.67841
4148	cube 1274	pink	{0,0,0}	-205.90038	345.12823	935.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:31.68258
4149	pentagonal prism 897	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:31.685485
4150	cylinder 1045	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:31.688359
4151	pentagonal prism 898	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:31.902151
4152	cube 1275	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:47:31.90461
4153	cuboid 409	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:31.906911
4154	cylinder 1046	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:31.908945
4155	pentagonal prism 899	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:32.148769
4156	cube 1276	pink	{0,0,0}	-207.68886	346.4762	912.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:32.151332
4157	cuboid 410	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:32.153511
4158	cylinder 1047	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:32.155978
4159	pentagonal prism 900	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:47:32.378432
4160	cube 1277	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 15:47:32.382954
4161	cuboid 411	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.647617	cuboid.usd	2025-03-29 15:47:32.385183
4162	cylinder 1048	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:32.387873
4163	pentagonal prism 901	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:32.610834
4164	cube 1278	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:47:32.613573
4165	cuboid 412	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:32.616785
4166	cylinder 1049	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:47:32.619062
4167	pentagonal prism 902	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:32.835821
4168	cube 1279	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:32.838924
4169	cuboid 413	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:32.841061
4170	cylinder 1050	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:32.843159
4171	pentagonal prism 903	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:33.071034
4172	cube 1280	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:33.074063
4173	pentagonal prism 904	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:47:33.076331
4174	cylinder 1051	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 15:47:33.07883
4175	pentagonal prism 905	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:33.318586
4176	cube 1281	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:33.323072
4177	cuboid 414	red	{0,0,0}	31.497837	259.85715	932.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:33.325493
4178	cylinder 1052	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:47:33.327993
4179	pentagonal prism 906	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:33.548404
4180	cube 1282	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:47:33.552335
4181	cube 1283	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.746803	cube.usd	2025-03-29 15:47:33.554425
4182	cylinder 1053	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:33.556907
4183	pentagonal prism 907	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:33.772005
4184	cube 1284	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:33.774912
4185	cuboid 415	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:33.777074
4186	cylinder 1054	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:47:33.779536
4187	hexagonal prism 532	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	hexagonal prism.usd	2025-03-29 15:47:34.003689
4188	cube 1285	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:34.00789
4189	cuboid 416	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:34.009976
4190	cylinder 1055	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:34.012186
4191	pentagonal prism 908	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:34.236919
4192	cube 1286	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:47:34.239796
4193	cube 1287	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:34.242183
4194	cylinder 1056	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:34.244544
4195	pentagonal prism 909	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:34.469479
4196	cube 1288	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:34.472276
4197	hexagonal prism 533	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:47:34.474583
4198	cylinder 1057	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:34.476812
4199	pentagonal prism 910	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:34.705582
4200	cube 1289	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:34.708061
4201	cube 1290	red	{0,0,0}	32.355774	258.8462	929	0	0	37.874985	cube.usd	2025-03-29 15:47:34.710145
4202	cylinder 1058	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:47:34.712158
4203	pentagonal prism 911	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:34.940268
4204	cube 1291	pink	{0,0,0}	-208.67317	346.4762	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:34.944452
4205	cuboid 417	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:34.946739
4206	cylinder 1059	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:34.949233
4207	pentagonal prism 912	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:35.161963
4208	cube 1292	pink	{0,0,0}	-206.70456	346.4762	931.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:35.164824
4209	cube 1293	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:35.166931
4210	cylinder 1060	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:35.168977
4211	pentagonal prism 913	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:47:35.409534
4212	cube 1294	pink	{0,0,0}	-208.67317	346.4762	912.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:35.4134
4213	hexagonal prism 534	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.746803	hexagonal prism.usd	2025-03-29 15:47:35.415521
4214	cylinder 1061	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:35.417708
4215	pentagonal prism 914	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:35.639539
4216	cube 1295	pink	{0,0,0}	-208.67317	346.4762	934	0	0	59.03625	cube.usd	2025-03-29 15:47:35.642182
4217	cuboid 418	red	{0,0,0}	31.497837	259.85715	937.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:35.64513
4218	cylinder 1062	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:47:35.647359
4219	pentagonal prism 915	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:35.87323
4220	cube 1296	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:35.877155
4221	cube 1297	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.405357	cube.usd	2025-03-29 15:47:35.87931
4222	cylinder 1063	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:35.881588
4223	pentagonal prism 916	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:36.108154
4224	cube 1298	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:36.112249
4225	cube 1299	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.874985	cube.usd	2025-03-29 15:47:36.11456
4226	cylinder 1064	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:36.116652
4227	hexagonal prism 535	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:47:36.35291
4228	cube 1300	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:47:36.357073
4229	cuboid 419	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:36.359349
4230	cylinder 1065	green	{0,0,0}	-270.6119	216.68562	941.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:36.361692
4231	pentagonal prism 917	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:36.585679
4232	cube 1301	pink	{0,0,0}	-206.88084	345.12823	931.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:36.589461
4233	cube 1302	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:36.591967
4234	cylinder 1066	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:36.594732
4235	pentagonal prism 918	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:36.808607
4236	cube 1303	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:36.811983
4237	cuboid 420	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	cuboid.usd	2025-03-29 15:47:36.813996
4238	cylinder 1067	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:36.816179
4239	pentagonal prism 919	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:37.039096
4240	cube 1304	pink	{0,0,0}	-206.88084	345.12823	914.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:37.043241
4241	cuboid 421	red	{0,0,0}	32.355774	258.8462	924	0	0	37.746803	cuboid.usd	2025-03-29 15:47:37.045609
4242	cylinder 1068	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:37.048072
4243	pentagonal prism 920	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:37.277978
4244	cube 1305	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:37.280436
4245	cube 1306	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:47:37.282525
4246	cylinder 1069	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:37.284645
4247	pentagonal prism 921	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:37.511109
4248	cube 1307	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:37.513758
4249	cuboid 422	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:37.515847
4250	cylinder 1070	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:47:37.51779
4251	pentagonal prism 922	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:37.739456
4252	cube 1308	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:37.743931
4253	cuboid 423	red	{0,0,0}	32.355774	258.8462	919	0	0	37.69424	cuboid.usd	2025-03-29 15:47:37.746064
4254	cylinder 1071	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:37.748169
4255	pentagonal prism 923	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:37.974284
4256	cube 1309	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:47:37.977073
4257	cuboid 424	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:47:37.979159
4258	cylinder 1072	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:47:37.981426
4259	pentagonal prism 924	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:38.205727
4260	cube 1310	pink	{0,0,0}	-206.70456	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:47:38.208722
4261	cuboid 425	red	{0,0,0}	32.482143	259.85715	913.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:38.211263
4262	cylinder 1073	green	{0,0,0}	-271.66885	217.53194	936.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:38.213482
4263	pentagonal prism 925	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:38.44087
4264	cube 1311	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:38.444531
4265	cube 1312	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cube.usd	2025-03-29 15:47:38.447811
4266	cylinder 1074	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:38.450446
4267	pentagonal prism 926	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:38.686484
4268	cube 1313	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:38.689096
4269	hexagonal prism 536	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:47:38.691187
4270	cylinder 1075	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:38.693435
4271	pentagonal prism 927	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:38.911897
4272	cube 1314	pink	{0,0,0}	-206.70456	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:47:38.915168
4273	hexagonal prism 537	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:47:38.917253
4274	cylinder 1076	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:38.919423
4275	pentagonal prism 928	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:39.144602
4276	cube 1315	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:47:39.14885
4277	cuboid 426	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:39.150944
4278	cylinder 1077	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:39.153019
4279	pentagonal prism 929	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:47:39.376229
4280	cube 1316	pink	{0,0,0}	-205.90038	345.12823	937.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:39.380088
4281	cuboid 427	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:39.382252
4282	cylinder 1078	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:39.384425
4283	pentagonal prism 930	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:39.619928
4284	cube 1317	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.620872	cube.usd	2025-03-29 15:47:39.62399
4285	pentagonal prism 931	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:39.626233
4286	cylinder 1079	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:39.628773
4287	pentagonal prism 932	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:39.861361
4288	cube 1318	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:39.864299
4289	cube 1319	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:39.866528
4290	cylinder 1080	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:39.868572
4291	pentagonal prism 933	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:40.090198
4292	cube 1320	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:47:40.093107
4293	cuboid 428	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:40.095717
4294	cylinder 1081	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:40.098003
4295	pentagonal prism 934	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:40.329416
4296	cube 1321	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:40.331838
4297	cube 1322	red	{0,0,0}	32.355774	258.8462	929	0	0	37.69424	cube.usd	2025-03-29 15:47:40.333832
4298	cylinder 1082	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:40.335765
4299	pentagonal prism 935	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:40.558548
4300	cube 1323	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:47:40.563065
4301	cube 1324	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	cube.usd	2025-03-29 15:47:40.56587
4302	cylinder 1083	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:40.568276
4303	pentagonal prism 936	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:40.795377
4304	cube 1325	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:40.799244
4305	cube 1326	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:47:40.801315
4306	cylinder 1084	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:47:40.80352
4307	hexagonal prism 538	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	hexagonal prism.usd	2025-03-29 15:47:41.030124
4308	cube 1327	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:47:41.032837
4309	cube 1328	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:41.035167
4310	cylinder 1085	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:41.037499
4311	pentagonal prism 937	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:41.26171
4312	cube 1329	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:47:41.26597
4313	pentagonal prism 938	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:41.268203
4314	cylinder 1086	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:41.270507
4315	pentagonal prism 939	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:41.493344
4316	cube 1330	pink	{0,0,0}	-207.68886	346.4762	937.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:41.497683
4317	cube 1331	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:41.49985
4318	cylinder 1087	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:41.501929
4319	pentagonal prism 940	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:41.737329
4320	cube 1332	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.420776	cube.usd	2025-03-29 15:47:41.739964
4321	cube 1333	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:41.741977
4322	cylinder 1088	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:41.744005
4323	pentagonal prism 941	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:41.959525
4324	cube 1334	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:41.963504
4325	cuboid 429	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:41.965752
4326	cylinder 1089	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:41.967946
4327	pentagonal prism 942	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:42.19553
4328	cube 1335	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:42.199437
4329	cube 1336	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:42.201655
4330	cylinder 1090	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:42.203971
4331	pentagonal prism 943	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:42.430548
4332	cube 1337	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.420776	cube.usd	2025-03-29 15:47:42.433366
4333	pentagonal prism 944	red	{0,0,0}	32.355774	258.8462	929	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:47:42.435428
4334	cylinder 1091	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 15:47:42.437373
4335	pentagonal prism 945	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:42.66139
4336	cube 1338	pink	{0,0,0}	-206.88084	345.12823	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:42.664098
4337	cube 1339	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:47:42.66624
4338	cylinder 1092	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:47:42.668357
4339	pentagonal prism 946	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:42.893231
4340	cube 1340	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:42.89681
4341	cube 1341	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:47:42.899462
4342	cylinder 1093	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:42.901597
4343	pentagonal prism 947	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:43.134911
4344	cube 1342	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:43.137602
4345	cube 1343	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:43.139759
4346	cylinder 1094	green	{0,0,0}	-272.65317	217.53194	920	0	0	36.869896	cylinder.usd	2025-03-29 15:47:43.141779
4347	pentagonal prism 948	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:43.358257
4348	cube 1344	pink	{0,0,0}	-207.68886	346.4762	933	0	0	59.534454	cube.usd	2025-03-29 15:47:43.360983
4349	cuboid 430	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:43.363602
4350	cylinder 1095	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:47:43.366599
4351	pentagonal prism 949	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:43.579905
4352	cube 1345	pink	{0,0,0}	-205.90038	345.12823	904.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:43.583152
4353	pentagonal prism 950	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:47:43.585376
4354	cylinder 1096	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:43.587468
4355	pentagonal prism 951	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:43.820404
4356	cube 1346	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:47:43.823564
4357	pentagonal prism 952	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:47:43.825832
4358	cylinder 1097	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:47:43.828508
4359	pentagonal prism 953	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:44.054787
4360	cube 1347	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:47:44.058387
4361	cube 1348	red	{0,0,0}	32.355774	258.8462	924	0	0	37.69424	cube.usd	2025-03-29 15:47:44.061375
4362	cylinder 1098	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:44.064062
4363	pentagonal prism 954	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:44.295261
4364	cube 1349	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:44.298177
4365	cuboid 431	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:44.300464
4366	cylinder 1099	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:44.302644
4367	pentagonal prism 955	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:44.529875
4368	cube 1350	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:44.533874
4369	cube 1351	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:47:44.535942
4370	cylinder 1100	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:44.537934
4371	pentagonal prism 956	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:44.760813
4372	cube 1352	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:44.765291
4373	pentagonal prism 957	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:47:44.767953
4374	cylinder 1101	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:44.770851
4375	pentagonal prism 958	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:44.996384
4376	cube 1353	pink	{0,0,0}	-207.68886	346.4762	934	0	0	59.93142	cube.usd	2025-03-29 15:47:44.998969
4377	pentagonal prism 959	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:45.001299
4378	cylinder 1102	green	{0,0,0}	-272.65317	217.53194	915	0	0	26.56505	cylinder.usd	2025-03-29 15:47:45.003425
4379	pentagonal prism 960	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:45.230797
4380	cube 1354	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:45.233769
4381	pentagonal prism 961	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:45.235884
4382	cylinder 1103	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:45.237882
4383	pentagonal prism 962	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:45.460064
4384	cube 1355	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 15:47:45.463361
4385	pentagonal prism 963	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:47:45.466639
4386	cylinder 1104	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:45.469286
4387	pentagonal prism 964	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:45.694774
4388	cube 1356	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:45.698797
4389	pentagonal prism 965	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:45.701394
4390	cylinder 1105	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:45.703802
4391	pentagonal prism 966	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:45.925118
4392	cube 1357	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:45.929362
4393	cuboid 432	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:45.932193
4394	cylinder 1106	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:45.934535
4395	pentagonal prism 967	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:46.160883
4396	cube 1358	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:46.164953
4397	cuboid 433	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:46.167346
4398	cylinder 1107	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:46.169557
4399	pentagonal prism 968	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:46.394102
4400	cube 1359	pink	{0,0,0}	-208.67317	346.4762	922.00006	0	0	59.62088	cube.usd	2025-03-29 15:47:46.397121
4401	cuboid 434	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:46.399202
4402	cylinder 1108	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:46.401354
4403	pentagonal prism 969	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:46.634514
4404	cube 1360	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.420776	cube.usd	2025-03-29 15:47:46.636924
4405	cube 1361	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	cube.usd	2025-03-29 15:47:46.639177
4406	cylinder 1109	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:46.641188
4407	pentagonal prism 970	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:46.862012
4408	cube 1362	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:46.864776
4409	pentagonal prism 971	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:46.867511
4410	cylinder 1110	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:46.86996
4411	pentagonal prism 972	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:47.083052
4412	cube 1363	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:47:47.085315
4413	cuboid 435	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:47:47.087341
4414	cylinder 1111	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:47.089294
4415	pentagonal prism 973	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:47.320193
4416	cube 1364	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:47.322706
4417	cuboid 436	red	{0,0,0}	31.497837	259.85715	934	0	0	37.568592	cuboid.usd	2025-03-29 15:47:47.324834
4418	cylinder 1112	green	{0,0,0}	-272.65317	217.53194	934	0	0	33.690063	cylinder.usd	2025-03-29 15:47:47.326922
4419	pentagonal prism 974	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:47.549274
4420	cube 1365	pink	{0,0,0}	-206.88084	345.12823	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:47.551747
4421	pentagonal prism 975	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:47.553826
4422	cylinder 1113	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 15:47:47.555709
4423	pentagonal prism 976	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:47.783121
4424	cube 1366	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:47:47.785798
4425	cuboid 437	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:47.78792
4426	cylinder 1114	green	{0,0,0}	-272.65317	217.53194	933	0	0	19.983105	cylinder.usd	2025-03-29 15:47:47.790027
4427	pentagonal prism 977	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:48.012906
4428	cube 1367	pink	{0,0,0}	-206.70456	346.4762	923.00006	0	0	59.743565	cube.usd	2025-03-29 15:47:48.015237
4429	cube 1368	red	{0,0,0}	32.482143	259.85715	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:48.017835
4430	cylinder 1115	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:48.019968
4431	pentagonal prism 978	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:48.2482
4432	cube 1369	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.420776	cube.usd	2025-03-29 15:47:48.251413
4433	cuboid 438	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:48.253627
4434	cylinder 1116	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:48.255693
4435	pentagonal prism 979	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:48.481819
4436	cube 1370	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:47:48.485854
4437	cuboid 439	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.647625	cuboid.usd	2025-03-29 15:47:48.488204
4438	cylinder 1117	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:48.490414
4439	pentagonal prism 980	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:48.713838
4440	cube 1371	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.03624	cube.usd	2025-03-29 15:47:48.71714
4441	pentagonal prism 981	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:47:48.719458
4442	cylinder 1118	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:48.721518
4443	pentagonal prism 982	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:48.95002
4444	cube 1372	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:47:48.952734
4445	cube 1373	red	{0,0,0}	32.355774	258.8462	933	0	0	37.874985	cube.usd	2025-03-29 15:47:48.955877
4446	cylinder 1119	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:48.958215
4447	pentagonal prism 983	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:49.172511
4448	cube 1374	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:49.174851
4449	pentagonal prism 984	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:49.176911
4450	cylinder 1120	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:49.178941
4451	pentagonal prism 985	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:49.406661
4452	cube 1375	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:49.410409
4453	cuboid 440	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:49.412453
4454	cylinder 1121	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:49.414555
4455	pentagonal prism 986	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:49.637232
4456	cube 1376	pink	{0,0,0}	-208.50322	347.83475	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:49.641419
4457	cuboid 441	red	{0,0,0}	31.621342	260.87607	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:49.643763
4458	cylinder 1122	green	{0,0,0}	-273.72223	218.38489	914.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:49.646057
4459	pentagonal prism 987	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:49.864822
4460	cube 1377	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:47:49.869257
4461	cuboid 442	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:49.871518
4462	cylinder 1123	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:49.873543
4463	hexagonal prism 539	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	hexagonal prism.usd	2025-03-29 15:47:50.107128
4464	cube 1378	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.62088	cube.usd	2025-03-29 15:47:50.109852
4465	cube 1379	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:50.11193
4466	cylinder 1124	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	38.65981	cylinder.usd	2025-03-29 15:47:50.113908
4467	pentagonal prism 988	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:50.345537
4468	cube 1380	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.03625	cube.usd	2025-03-29 15:47:50.349524
4469	cuboid 443	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:50.35182
4470	cylinder 1125	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:50.354563
4471	pentagonal prism 989	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:50.581573
4472	cube 1381	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:50.586115
4473	pentagonal prism 990	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:50.588901
4474	cylinder 1126	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:50.592642
4475	pentagonal prism 991	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:47:50.818839
4476	cube 1382	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:50.822872
4477	cuboid 444	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:50.82487
4478	cylinder 1127	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:47:50.826973
4479	pentagonal prism 992	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:51.048149
4480	cube 1383	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:51.051053
4481	cuboid 445	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:47:51.053747
4482	cylinder 1128	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:47:51.055853
4483	pentagonal prism 993	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:51.281051
4484	cube 1384	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 15:47:51.284635
4485	cube 1385	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:47:51.287632
4486	cylinder 1129	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:51.290317
4487	pentagonal prism 994	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:51.501545
4488	cube 1386	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:51.505502
4489	cuboid 446	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:47:51.507926
4490	cylinder 1130	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:47:51.510114
4491	pentagonal prism 995	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:51.753592
4492	cube 1387	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.420776	cube.usd	2025-03-29 15:47:51.757584
4493	cuboid 447	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:51.759604
4494	cylinder 1131	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:51.761721
4495	pentagonal prism 996	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:51.985979
4496	cube 1388	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:47:51.988981
4497	cube 1389	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:51.991281
4498	cylinder 1132	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:47:51.993255
4499	pentagonal prism 997	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:52.214225
4500	cube 1390	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:52.216881
4501	cuboid 448	red	{0,0,0}	32.482143	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:52.219087
4502	cylinder 1133	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:52.22151
4503	pentagonal prism 998	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:52.446018
4504	cube 1391	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.420776	cube.usd	2025-03-29 15:47:52.450117
4505	cube 1392	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:52.452209
4506	cylinder 1134	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:52.454589
4507	pentagonal prism 999	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:52.697626
4508	cube 1393	pink	{0,0,0}	-207.68886	346.4762	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:52.700434
4509	cuboid 449	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:52.702704
4510	cylinder 1135	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:52.705413
4511	hexagonal prism 540	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	hexagonal prism.usd	2025-03-29 15:47:52.928
4512	cube 1394	pink	{0,0,0}	-208.67317	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:47:52.930789
4513	cube 1395	red	{0,0,0}	31.497837	259.85715	919	0	0	37.405357	cube.usd	2025-03-29 15:47:52.932875
4514	cylinder 1136	green	{0,0,0}	-272.65317	217.53194	938	0	0	33.690063	cylinder.usd	2025-03-29 15:47:52.934946
4515	pentagonal prism 1000	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:53.149832
4516	cube 1396	pink	{0,0,0}	-207.68886	346.4762	913.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:53.152715
4517	pentagonal prism 1001	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:53.155387
4518	cylinder 1137	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:53.157693
4519	pentagonal prism 1002	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:53.384875
4520	cube 1397	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:53.387838
4521	cube 1398	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.405357	cube.usd	2025-03-29 15:47:53.390001
4522	cylinder 1138	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:53.392069
4523	pentagonal prism 1003	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:47:53.617669
4524	cube 1399	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:47:53.620415
4525	cube 1400	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:53.622828
4526	cylinder 1139	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:53.625026
4527	pentagonal prism 1004	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:53.860322
4528	cube 1401	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:53.864398
4529	cuboid 450	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:47:53.866741
4530	cylinder 1140	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:53.868932
4531	pentagonal prism 1005	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:54.085733
4532	cube 1402	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:47:54.089718
4533	pentagonal prism 1006	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:54.091912
4534	cylinder 1141	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:54.093967
4535	pentagonal prism 1007	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:54.317971
4536	cube 1403	pink	{0,0,0}	-206.88084	345.12823	934	0	0	59.620872	cube.usd	2025-03-29 15:47:54.321928
4537	pentagonal prism 1008	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:54.3241
4538	cylinder 1142	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:47:54.32626
4539	pentagonal prism 1009	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:54.556463
4540	cube 1404	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:54.560276
4541	cuboid 451	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:54.562611
4542	cylinder 1143	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:54.564837
4543	pentagonal prism 1010	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:54.786512
4544	cube 1405	pink	{0,0,0}	-205.90038	345.12823	909.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:54.790224
4545	cuboid 452	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:54.792951
4546	cylinder 1144	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:54.79546
4547	pentagonal prism 1011	black	{0,0,0}	-129.44986	522.7403	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:55.020729
4548	cube 1406	pink	{0,0,0}	-208.50322	347.83475	924	0	0	59.03625	cube.usd	2025-03-29 15:47:55.024613
4549	pentagonal prism 1012	red	{0,0,0}	31.621342	260.87607	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:55.026775
4550	cylinder 1145	green	{0,0,0}	-273.72223	218.38489	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:55.028868
4551	pentagonal prism 1013	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:55.250843
4552	cube 1407	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:55.254948
4553	pentagonal prism 1014	red	{0,0,0}	31.497837	259.85715	912.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:47:55.257172
4554	cylinder 1146	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:55.259415
4555	pentagonal prism 1015	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:55.486609
4556	cube 1408	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:47:55.490974
4557	cube 1409	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	cube.usd	2025-03-29 15:47:55.493341
4558	cylinder 1147	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:55.495626
4559	pentagonal prism 1016	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:47:55.724504
4560	cube 1410	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:47:55.728477
4561	pentagonal prism 1017	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:55.730587
4562	cylinder 1148	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:55.732707
4563	pentagonal prism 1018	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:55.95499
4564	cube 1411	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.420776	cube.usd	2025-03-29 15:47:55.957849
4565	cuboid 453	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:55.960217
4566	cylinder 1149	green	{0,0,0}	-270.6119	216.68562	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:55.962523
4567	pentagonal prism 1019	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:56.186247
4568	cube 1412	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:47:56.189497
4569	cuboid 454	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:47:56.19168
4570	cylinder 1150	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:56.193639
4571	pentagonal prism 1020	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:56.418254
4572	cube 1413	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:56.422349
4573	cube 1414	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:56.424679
4574	cylinder 1151	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:56.427038
4575	pentagonal prism 1021	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:56.639666
4576	cube 1415	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.03625	cube.usd	2025-03-29 15:47:56.643398
4577	cube 1416	red	{0,0,0}	32.355774	258.8462	924	0	0	37.746803	cube.usd	2025-03-29 15:47:56.645483
4578	cylinder 1152	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:47:56.64768
4579	pentagonal prism 1022	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:56.886157
4580	cube 1417	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:56.890409
4581	cuboid 455	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:47:56.892985
4582	cylinder 1153	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:47:56.895186
4583	pentagonal prism 1023	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:57.127444
4584	cube 1418	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:57.1316
4585	pentagonal prism 1024	red	{0,0,0}	31.497837	259.85715	913.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:57.133688
4586	cylinder 1154	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:57.135826
4587	pentagonal prism 1025	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:57.35338
4588	cube 1419	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.420776	cube.usd	2025-03-29 15:47:57.356121
4589	pentagonal prism 1026	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:57.358662
4590	cylinder 1155	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:47:57.360777
4591	pentagonal prism 1027	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:57.587293
4592	cube 1420	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:47:57.591576
4593	pentagonal prism 1028	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:47:57.593896
4594	cylinder 1156	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:57.595998
4595	pentagonal prism 1029	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:57.816894
4596	cube 1421	pink	{0,0,0}	-209.49138	347.83475	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:57.820952
4597	pentagonal prism 1030	red	{0,0,0}	31.621342	260.87607	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:47:57.823125
4598	cylinder 1157	green	{0,0,0}	-273.72223	218.38489	933	0	0	26.56505	cylinder.usd	2025-03-29 15:47:57.825536
4599	pentagonal prism 1031	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:58.037066
4600	cube 1422	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:47:58.039558
4601	pentagonal prism 1032	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:47:58.04205
4602	cylinder 1158	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:58.04487
4603	pentagonal prism 1033	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:58.271299
4604	cube 1423	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 15:47:58.275558
4605	hexagonal prism 541	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:47:58.277919
4606	cylinder 1159	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:58.279919
4607	pentagonal prism 1034	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:58.504592
4608	cube 1424	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:58.508303
4609	cuboid 456	red	{0,0,0}	31.497837	259.85715	913.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:47:58.510834
4610	cylinder 1160	green	{0,0,0}	-272.65317	217.53194	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:58.512963
4611	pentagonal prism 1035	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:58.721781
4612	cube 1425	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:47:58.724181
4613	pentagonal prism 1036	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:47:58.727051
4614	cylinder 1161	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:47:58.729189
4615	pentagonal prism 1037	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:47:58.957475
4616	cube 1426	pink	{0,0,0}	-208.67317	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:47:58.962106
4617	cuboid 457	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:47:58.964425
4618	cylinder 1162	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:58.966518
4619	pentagonal prism 1038	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:59.189521
4620	cube 1427	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:47:59.193477
4621	cube 1428	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:59.195902
4622	cylinder 1163	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:47:59.197993
4623	pentagonal prism 1039	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:47:59.417106
4624	cube 1429	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.743565	cube.usd	2025-03-29 15:47:59.420923
4625	cuboid 458	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:47:59.422951
4626	cylinder 1164	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:47:59.425011
4627	pentagonal prism 1040	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:47:59.646479
4628	cube 1430	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:47:59.649338
4629	cuboid 459	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:47:59.651531
4630	cylinder 1165	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:47:59.653628
4631	pentagonal prism 1041	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:47:59.880202
4632	cube 1431	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.34933	cube.usd	2025-03-29 15:47:59.88368
4633	cube 1432	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:47:59.885769
4634	cylinder 1166	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:47:59.887831
4635	pentagonal prism 1042	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:00.113955
4636	cube 1433	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:00.116402
4637	cube 1434	red	{0,0,0}	31.497837	259.85715	920	0	0	37.69424	cube.usd	2025-03-29 15:48:00.118533
4638	cylinder 1167	green	{0,0,0}	-272.65317	217.53194	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:00.120596
4639	pentagonal prism 1043	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:00.339589
4640	cube 1435	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:00.343979
4641	cuboid 460	red	{0,0,0}	31.497837	259.85715	924	0	0	37.746803	cuboid.usd	2025-03-29 15:48:00.347386
4642	cylinder 1168	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:00.350628
4643	pentagonal prism 1044	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:00.575362
4644	cube 1436	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:00.579511
4645	cube 1437	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	cube.usd	2025-03-29 15:48:00.581902
4646	cylinder 1169	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:48:00.584108
4647	pentagonal prism 1045	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:00.806226
4648	cube 1438	pink	{0,0,0}	-207.68886	346.4762	913.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:00.810621
4649	cube 1439	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:00.813467
4650	cylinder 1170	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:48:00.815643
4651	pentagonal prism 1046	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:01.031144
4652	cube 1440	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.420776	cube.usd	2025-03-29 15:48:01.034259
4653	cuboid 461	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:01.03644
4654	cylinder 1171	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:01.038608
4655	pentagonal prism 1047	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:01.260958
4656	cube 1441	pink	{0,0,0}	-207.6968	346.48944	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:01.263589
4657	cuboid 462	red	{0,0,0}	31.499039	259.86707	925.00006	0	0	37.303947	cuboid.usd	2025-03-29 15:48:01.265674
4658	cylinder 1172	green	{0,0,0}	-272.66354	217.54024	934	0	0	26.56505	cylinder.usd	2025-03-29 15:48:01.267737
4659	hexagonal prism 542	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:48:01.488819
4660	cube 1442	pink	{0,0,0}	-207.68886	346.4762	904.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:01.491615
4661	cube 1443	red	{0,0,0}	31.497837	259.85715	924	0	0	37.874985	cube.usd	2025-03-29 15:48:01.494193
4662	cylinder 1173	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:48:01.49663
4663	pentagonal prism 1048	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:01.718915
4664	cube 1444	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03624	cube.usd	2025-03-29 15:48:01.72245
4665	cuboid 463	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:01.724637
4666	cylinder 1174	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:01.726836
4667	hexagonal prism 543	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:48:01.940437
4668	cube 1445	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:01.94387
4669	pentagonal prism 1049	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:01.946368
4670	cylinder 1175	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:01.948617
4671	pentagonal prism 1050	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:02.173383
4672	cube 1446	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:48:02.176248
4673	pentagonal prism 1051	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:02.178971
4674	cylinder 1176	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:02.181354
4675	pentagonal prism 1052	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:02.406072
4676	cube 1447	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:02.410295
4677	pentagonal prism 1053	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:02.413081
4678	cylinder 1177	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:02.415332
4679	pentagonal prism 1054	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:02.632533
4680	cube 1448	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:48:02.635447
4681	cuboid 464	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:48:02.637551
4682	cylinder 1178	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:02.639576
4683	pentagonal prism 1055	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:02.856913
4684	cube 1449	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.34933	cube.usd	2025-03-29 15:48:02.859762
4685	cuboid 465	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:02.862586
4686	cylinder 1179	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:02.864993
4687	pentagonal prism 1056	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:03.088
4688	cube 1450	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.420776	cube.usd	2025-03-29 15:48:03.090678
4689	cube 1451	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:03.092825
4690	cylinder 1180	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:03.09562
4691	pentagonal prism 1057	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:03.309388
4692	cube 1452	pink	{0,0,0}	-208.67317	346.4762	915	0	0	59.743565	cube.usd	2025-03-29 15:48:03.312378
4693	cuboid 466	red	{0,0,0}	31.497837	259.85715	920	0	0	37.874985	cuboid.usd	2025-03-29 15:48:03.314631
4694	cylinder 1181	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:03.316747
4695	pentagonal prism 1058	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:03.544736
4696	cube 1453	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:48:03.549126
4697	cuboid 467	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:48:03.551499
4698	cylinder 1182	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:03.553521
4699	pentagonal prism 1059	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:03.784743
4700	cube 1454	pink	{0,0,0}	-208.67317	346.4762	911.00006	0	0	59.62088	cube.usd	2025-03-29 15:48:03.788814
4701	cuboid 468	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:48:03.791062
4702	cylinder 1183	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:03.793326
4703	pentagonal prism 1060	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:04.008256
4704	cube 1455	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:04.011471
4705	cuboid 469	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:04.014179
4706	cylinder 1184	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:48:04.016372
4707	pentagonal prism 1061	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:04.237703
4708	cube 1456	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:48:04.240569
4709	pentagonal prism 1062	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:04.242908
4710	cylinder 1185	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:04.245024
4711	pentagonal prism 1063	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:04.460026
4712	cube 1457	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:04.462509
4713	cuboid 470	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:48:04.465248
4714	cylinder 1186	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:48:04.467809
4715	hexagonal prism 544	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	hexagonal prism.usd	2025-03-29 15:48:04.685347
4716	cube 1458	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.62088	cube.usd	2025-03-29 15:48:04.691559
4717	cube 1459	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:04.694813
4718	cylinder 1187	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:04.698687
4719	pentagonal prism 1064	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:04.924832
4720	cube 1460	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.620872	cube.usd	2025-03-29 15:48:04.928392
4721	cuboid 471	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:48:04.930765
4722	cylinder 1188	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:04.933048
4723	pentagonal prism 1065	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:05.145621
4724	cube 1461	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:05.14882
4725	pentagonal prism 1066	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:05.151214
4726	cylinder 1189	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:05.153333
4727	pentagonal prism 1067	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:05.402463
4728	cube 1462	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:05.405161
4729	pentagonal prism 1068	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:48:05.407421
4730	cylinder 1190	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:48:05.409558
4731	pentagonal prism 1069	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:05.631826
4732	cube 1463	pink	{0,0,0}	-205.90038	345.12823	940.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:05.63463
4733	cube 1464	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:48:05.63722
4734	cylinder 1191	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:05.639625
4735	pentagonal prism 1070	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:05.863113
4736	cube 1465	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:48:05.865963
4737	cube 1466	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:48:05.86922
4738	cylinder 1192	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:05.872831
4739	pentagonal prism 1071	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:06.118059
4740	cube 1467	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:06.120782
4741	pentagonal prism 1072	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:06.122949
4742	cylinder 1193	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:06.124957
4743	pentagonal prism 1073	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:06.349966
4744	cube 1468	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:48:06.354217
4745	cube 1469	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:06.356423
4746	cylinder 1194	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:06.358493
4747	pentagonal prism 1074	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal prism.usd	2025-03-29 15:48:06.586819
4748	cube 1470	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:06.590578
4749	pentagonal prism 1075	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:06.592671
4750	cylinder 1195	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:48:06.594757
4751	pentagonal prism 1076	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:06.818224
4752	cube 1471	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:06.822169
4753	cuboid 472	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:06.824343
4754	cylinder 1196	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:06.826543
4755	pentagonal prism 1077	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:07.039912
4756	cube 1472	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:07.042929
4757	cube 1473	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:48:07.045003
4758	cylinder 1197	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:48:07.047308
4759	pentagonal prism 1078	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:07.261809
4760	cube 1474	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:48:07.265341
4761	cube 1475	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	cube.usd	2025-03-29 15:48:07.267566
4762	cylinder 1198	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:07.26969
4763	pentagonal prism 1079	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:07.496107
4764	cube 1476	pink	{0,0,0}	-206.70456	346.4762	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:07.500298
4765	cuboid 473	red	{0,0,0}	32.482143	259.85715	924	0	0	37.874985	cuboid.usd	2025-03-29 15:48:07.502856
4766	cylinder 1199	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:07.506533
4767	pentagonal prism 1080	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:07.727416
4768	cube 1477	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:07.730332
4769	pentagonal prism 1081	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:07.732487
4770	cylinder 1200	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:48:07.734868
4771	pentagonal prism 1082	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:07.960761
4772	cube 1478	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:07.96446
4773	cuboid 474	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	cuboid.usd	2025-03-29 15:48:07.966948
4774	cylinder 1201	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:07.969702
4775	pentagonal prism 1083	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:08.194974
4776	cube 1479	pink	{0,0,0}	-206.88084	345.12823	907.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:08.197758
4777	pentagonal prism 1084	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:08.201172
4778	cylinder 1202	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:08.203932
4779	pentagonal prism 1085	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:08.447774
4780	cube 1480	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:08.452281
4781	cylinder 1203	red	{0,0,0}	31.497837	259.85715	910	0	0	37.405357	cylinder.usd	2025-03-29 15:48:08.454639
4782	cylinder 1204	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:08.456851
4783	pentagonal prism 1086	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:08.690645
4784	cube 1481	pink	{0,0,0}	-207.68886	346.4762	913.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:08.695285
4785	pentagonal prism 1087	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:08.698343
4786	cylinder 1205	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:08.702068
4787	pentagonal prism 1088	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:08.92676
4788	cube 1482	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:08.929762
4789	cuboid 475	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:48:08.931893
4790	cylinder 1206	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:08.934085
4791	pentagonal prism 1089	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:09.153437
4792	cube 1483	pink	{0,0,0}	-206.88084	345.12823	938	0	0	59.03624	cube.usd	2025-03-29 15:48:09.156355
4793	cube 1484	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:09.158346
4794	cylinder 1207	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:48:09.16036
4795	pentagonal prism 1090	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:09.399753
4796	cube 1485	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:48:09.403122
4797	pentagonal prism 1091	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:09.405628
4798	cylinder 1208	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:48:09.408023
4799	pentagonal prism 1092	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:09.671882
4800	cube 1486	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:09.674968
4801	pentagonal prism 1093	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:09.677053
4802	cylinder 1209	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:48:09.679112
4803	pentagonal prism 1094	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:09.898365
4804	cube 1487	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:09.901655
4805	cube 1488	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.69424	cube.usd	2025-03-29 15:48:09.904146
4806	cylinder 1210	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:09.906364
4807	pentagonal prism 1095	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:10.130967
4808	cube 1489	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:10.134997
4809	hexagonal prism 545	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:10.137478
4810	cylinder 1211	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:10.139751
4811	pentagonal prism 1096	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:10.365527
4812	cube 1490	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03625	cube.usd	2025-03-29 15:48:10.368368
4813	cube 1491	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	cube.usd	2025-03-29 15:48:10.370773
4814	cylinder 1212	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:48:10.37294
4815	pentagonal prism 1097	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:10.600473
4816	cube 1492	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:10.604634
4817	pentagonal prism 1098	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	36.869892	pentagonal prism.usd	2025-03-29 15:48:10.607227
4818	cylinder 1213	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:10.609457
4819	pentagonal prism 1099	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:10.84218
4820	cube 1493	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:10.846132
4821	cuboid 476	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:10.848186
4822	cylinder 1214	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:10.850626
4823	pentagonal prism 1100	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:11.066052
4824	cube 1494	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:48:11.070362
4825	cylinder 1215	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	cylinder.usd	2025-03-29 15:48:11.072848
4826	cylinder 1216	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:11.074966
4827	pentagonal prism 1101	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:11.299912
4828	cube 1495	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:48:11.304212
4829	pentagonal prism 1102	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:11.306459
4830	cylinder 1217	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:11.308692
4831	pentagonal prism 1103	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:11.535018
4832	cube 1496	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:11.539026
4833	pentagonal prism 1104	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:11.541095
4834	cylinder 1218	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:11.543162
4835	hexagonal prism 546	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:48:11.768529
4836	cube 1497	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:48:11.772168
4837	cube 1498	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:11.774154
4838	cylinder 1219	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:48:11.777353
4839	pentagonal prism 1105	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:12.00811
4840	cube 1499	pink	{0,0,0}	-207.68886	346.4762	910	0	0	59.03625	cube.usd	2025-03-29 15:48:12.012374
4841	cube 1500	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.405357	cube.usd	2025-03-29 15:48:12.014608
4842	cylinder 1220	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:12.016723
4843	pentagonal prism 1106	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:12.248175
4844	cube 1501	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:48:12.252296
4845	cube 1502	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cube.usd	2025-03-29 15:48:12.254809
4846	cylinder 1221	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:48:12.257143
4847	pentagonal prism 1107	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:12.475681
4848	cube 1503	pink	{0,0,0}	-206.88084	345.12823	913.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:12.480028
4849	pentagonal prism 1108	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:12.482342
4850	cylinder 1222	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:12.484639
4851	pentagonal prism 1109	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:12.708922
4852	cube 1504	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:12.711282
4853	hexagonal prism 547	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:12.713277
4854	cylinder 1223	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:48:12.715493
4855	pentagonal prism 1110	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:12.95435
4856	cube 1505	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:12.956782
4857	cube 1506	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:48:12.958935
4858	cylinder 1224	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:12.961111
4859	pentagonal prism 1111	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:13.194662
4860	cube 1507	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:13.197345
4861	cube 1508	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:13.199338
4862	cylinder 1225	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:13.201467
4863	pentagonal prism 1112	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:13.419139
4864	cube 1509	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:13.423484
4865	cube 1510	red	{0,0,0}	31.497837	259.85715	915	0	0	37.405357	cube.usd	2025-03-29 15:48:13.426075
4866	cylinder 1226	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:48:13.42869
4867	pentagonal prism 1113	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:13.649844
4868	cube 1511	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:13.653811
4869	pentagonal prism 1114	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:13.656573
4870	cylinder 1227	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:13.658865
4871	pentagonal prism 1115	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:13.872114
4872	cube 1512	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:13.875826
4873	hexagonal prism 548	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:13.878548
4874	cylinder 1228	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:13.880834
4875	pentagonal prism 1116	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:14.109737
4876	cube 1513	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:14.113657
4877	pentagonal prism 1117	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:14.115651
4878	cylinder 1229	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:14.117975
4879	pentagonal prism 1118	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:14.336908
4880	cube 1514	pink	{0,0,0}	-206.88084	345.12823	914.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:14.340076
4881	pentagonal prism 1119	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:14.342316
4882	cylinder 1230	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:14.344906
4883	pentagonal prism 1120	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:14.570217
4884	cube 1515	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:14.574331
4885	cube 1516	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:14.576582
4886	cylinder 1231	green	{0,0,0}	-272.65317	217.53194	929	0	0	18.434948	cylinder.usd	2025-03-29 15:48:14.578829
4887	pentagonal prism 1121	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:14.802066
4888	cube 1517	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:48:14.806266
4889	pentagonal prism 1122	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:14.80832
4890	cylinder 1232	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:14.810499
4891	pentagonal prism 1123	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:15.047005
4892	cube 1518	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:15.051007
4893	pentagonal prism 1124	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:15.054236
4894	cylinder 1233	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:15.05656
4895	pentagonal prism 1125	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:15.270223
4896	cube 1519	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:48:15.273273
4897	pentagonal prism 1126	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:48:15.275595
4898	cylinder 1234	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:15.277894
4899	pentagonal prism 1127	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:15.508616
4900	cube 1520	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 15:48:15.513056
4901	cube 1521	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.874985	cube.usd	2025-03-29 15:48:15.516116
4902	cylinder 1235	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:15.518657
4903	hexagonal prism 549	black	{0,0,0}	-127.462135	518.67285	652	0	0	90	hexagonal prism.usd	2025-03-29 15:48:15.753607
4904	cube 1522	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:15.75798
4905	cube 1523	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:15.760339
4906	cylinder 1236	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:15.762657
4907	pentagonal prism 1128	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:15.988121
4908	cube 1524	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:15.992343
4909	cube 1525	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:48:15.99455
4910	cylinder 1237	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:15.996771
4911	pentagonal prism 1129	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:16.221427
4912	cube 1526	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:16.225733
4913	cube 1527	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:16.228175
4914	cylinder 1238	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:16.231044
4915	pentagonal prism 1130	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:16.457684
4916	cube 1528	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:16.460131
4917	cuboid 477	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:48:16.462337
4918	cylinder 1239	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:16.46471
4919	pentagonal prism 1131	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:16.705875
4920	cube 1529	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:48:16.709629
4921	cuboid 478	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	cuboid.usd	2025-03-29 15:48:16.711854
4922	cylinder 1240	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:48:16.713905
4923	pentagonal prism 1132	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:16.954785
4924	cube 1530	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:48:16.960422
4925	hexagonal prism 550	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:16.964074
4926	cylinder 1241	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:48:16.967182
4927	pentagonal prism 1133	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:17.207927
4928	cube 1531	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:17.212256
4929	cube 1532	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.746803	cube.usd	2025-03-29 15:48:17.214537
4930	cylinder 1242	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:48:17.216625
4931	pentagonal prism 1134	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:17.442727
4932	cube 1533	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:17.446817
4933	pentagonal prism 1135	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:17.449096
4934	cylinder 1243	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:17.451244
4935	pentagonal prism 1136	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:17.664406
4936	cube 1534	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:48:17.669124
4937	cuboid 479	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:48:17.67139
4938	cylinder 1244	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:17.673577
4939	pentagonal prism 1137	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:17.910835
4940	cube 1535	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:48:17.913613
4941	pentagonal prism 1138	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:48:17.915666
4942	cylinder 1245	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:17.917951
4943	pentagonal prism 1139	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:18.13983
4944	cube 1536	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 15:48:18.142583
4945	hexagonal prism 551	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:18.144956
4946	cylinder 1246	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690067	cylinder.usd	2025-03-29 15:48:18.147133
4947	pentagonal prism 1140	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:18.390513
4948	cube 1537	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:18.393389
4949	hexagonal prism 552	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:48:18.395838
4950	cylinder 1247	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:18.398083
4951	pentagonal prism 1141	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:18.629973
4952	cube 1538	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:48:18.633796
4953	pentagonal prism 1142	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:48:18.636
4954	cylinder 1248	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:18.638037
4955	pentagonal prism 1143	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:18.853003
4956	cube 1539	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:48:18.857251
4957	cube 1540	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.874985	cube.usd	2025-03-29 15:48:18.85959
4958	cylinder 1249	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:48:18.86194
4959	pentagonal prism 1144	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:19.097089
4960	cube 1541	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:19.10091
4961	pentagonal prism 1145	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:19.102992
4962	cylinder 1250	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:19.105318
4963	pentagonal prism 1146	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:19.343729
4964	cube 1542	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.931416	cube.usd	2025-03-29 15:48:19.347929
4965	cube 1543	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:19.3508
4966	cylinder 1251	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:19.354083
4967	pentagonal prism 1147	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:19.572684
4968	cube 1544	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 15:48:19.576712
4969	cube 1545	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:19.578871
4970	cylinder 1252	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:19.581067
4971	pentagonal prism 1148	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:48:19.812288
4972	cube 1546	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:48:19.816205
4973	cube 1547	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:19.818707
4974	cylinder 1253	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:19.820843
4975	pentagonal prism 1149	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:20.038007
4976	cube 1548	pink	{0,0,0}	-208.67317	346.4762	912.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:20.042088
4977	pentagonal prism 1150	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:48:20.044979
4978	cylinder 1254	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:20.047151
4979	pentagonal prism 1151	black	{0,0,0}	-128.94427	520.6986	660	0	0	90	pentagonal prism.usd	2025-03-29 15:48:20.273733
4980	cube 1549	pink	{0,0,0}	-208.67317	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:20.278118
4981	cuboid 480	red	{0,0,0}	31.497837	259.85715	934	0	0	37.568592	cuboid.usd	2025-03-29 15:48:20.280452
4982	cylinder 1255	green	{0,0,0}	-272.65317	217.53194	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:20.2827
4983	pentagonal prism 1152	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:20.514322
4984	cube 1550	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.34933	cube.usd	2025-03-29 15:48:20.518812
4985	cuboid 481	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:20.521637
4986	cylinder 1256	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:48:20.524363
4987	pentagonal prism 1153	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:20.745385
4988	cube 1551	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:48:20.748961
4989	cube 1552	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:20.751124
4990	cylinder 1257	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:48:20.753228
4991	pentagonal prism 1154	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:20.984829
4992	cube 1553	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:20.989108
4993	cube 1554	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	cube.usd	2025-03-29 15:48:20.991665
4994	cylinder 1258	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:20.994708
4995	pentagonal prism 1155	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:21.206725
4996	cube 1555	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:21.209731
4997	pentagonal prism 1156	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:21.21201
4998	cylinder 1259	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:21.214183
4999	pentagonal prism 1157	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:21.439381
5000	cube 1556	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:21.443397
5001	cuboid 482	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:21.445868
5002	cylinder 1260	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:21.44805
5003	pentagonal prism 1158	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:21.683308
5004	cube 1557	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:48:21.687439
5005	cube 1558	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.746803	cube.usd	2025-03-29 15:48:21.689502
5006	cylinder 1261	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:48:21.691831
5007	pentagonal prism 1159	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:21.91032
5008	cube 1559	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:48:21.912953
5009	cube 1560	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:21.915203
5010	cylinder 1262	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:21.917473
5011	pentagonal prism 1160	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:22.140572
5012	cube 1561	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:48:22.144719
5013	pentagonal prism 1161	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:22.147305
5014	cylinder 1263	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:22.149457
5015	pentagonal prism 1162	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:22.377257
5016	cube 1562	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:48:22.379893
5017	cuboid 483	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:22.381923
5018	cylinder 1264	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:22.384
5019	pentagonal prism 1163	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:22.60761
5020	cube 1563	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:22.611882
5021	cube 1564	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:22.614674
5022	cylinder 1265	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:48:22.61693
5023	pentagonal prism 1164	black	{0,0,0}	-127.46696	518.69244	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:22.845847
5024	cube 1565	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:22.84986
5025	pentagonal prism 1165	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:48:22.852568
5026	cylinder 1266	green	{0,0,0}	-270.62216	216.69383	934	0	0	18.434948	cylinder.usd	2025-03-29 15:48:22.854789
5027	pentagonal prism 1166	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:23.072325
5028	cube 1566	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:23.075113
5029	pentagonal prism 1167	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:23.077305
5030	cylinder 1267	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:23.079637
5031	pentagonal prism 1168	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:23.29327
5032	cube 1567	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:23.296436
5033	cuboid 484	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:23.298634
5034	cylinder 1268	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:23.300761
5035	pentagonal prism 1169	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:23.528324
5036	cube 1568	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:23.533009
5037	pentagonal prism 1170	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:23.535371
5038	cylinder 1269	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:23.537459
5039	pentagonal prism 1171	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:23.766611
5040	cube 1569	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:23.770835
5041	cube 1570	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:23.773011
5042	cylinder 1270	green	{0,0,0}	-270.6119	216.68562	924	0	0	36.869896	cylinder.usd	2025-03-29 15:48:23.775232
5043	pentagonal prism 1172	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:23.997797
5044	cube 1571	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:24.001983
5045	cuboid 485	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:24.004168
5046	cylinder 1271	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:24.006383
5047	pentagonal prism 1173	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:24.241091
5048	cube 1572	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:48:24.245544
5049	pentagonal prism 1174	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:24.247865
5050	cylinder 1272	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:24.249984
5051	pentagonal prism 1175	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:24.486884
5052	cube 1573	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:24.49109
5053	cuboid 486	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:24.493306
5054	cylinder 1273	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:24.495587
5055	pentagonal prism 1176	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:24.717773
5056	cube 1574	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:48:24.720944
5057	cube 1575	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:24.723283
5058	cylinder 1274	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:24.725634
5059	pentagonal prism 1177	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:24.943609
5060	cube 1576	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.620872	cube.usd	2025-03-29 15:48:24.948025
5061	cube 1577	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:24.950204
5062	cylinder 1275	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:24.952364
5063	pentagonal prism 1178	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:25.184481
5064	cube 1578	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:25.188414
5065	pentagonal prism 1179	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:25.190511
5066	cylinder 1276	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:25.192654
5067	pentagonal prism 1180	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:25.405841
5068	cube 1579	pink	{0,0,0}	-208.67317	346.4762	934	0	0	59.03625	cube.usd	2025-03-29 15:48:25.408504
5069	cube 1580	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:25.410548
5070	cylinder 1277	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:25.412728
5071	pentagonal prism 1181	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:25.629887
5072	cube 1581	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:25.633463
5073	cuboid 487	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:48:25.635814
5074	cylinder 1278	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:25.638016
5075	pentagonal prism 1182	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:25.864633
5076	cube 1582	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.34933	cube.usd	2025-03-29 15:48:25.868552
5077	cube 1583	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:25.870719
5078	cylinder 1279	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:25.872842
5079	pentagonal prism 1183	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:26.116379
5080	cube 1584	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:48:26.118836
5081	cube 1585	red	{0,0,0}	32.482143	259.85715	924	0	0	37.405357	cube.usd	2025-03-29 15:48:26.120931
5082	cylinder 1280	green	{0,0,0}	-271.66885	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:48:26.123113
5083	pentagonal prism 1184	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:26.346718
5084	cube 1586	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:26.351243
5085	pentagonal prism 1185	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:26.353334
5086	cylinder 1281	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:26.355452
5087	pentagonal prism 1186	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal prism.usd	2025-03-29 15:48:26.578691
5088	cube 1587	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:26.582827
5089	cube 1588	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:48:26.585051
5090	cylinder 1282	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:26.587223
5091	hexagonal prism 553	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	hexagonal prism.usd	2025-03-29 15:48:26.811736
5092	cube 1589	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:26.816213
5093	cuboid 488	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:48:26.818423
5094	cylinder 1283	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:26.820702
5095	pentagonal prism 1187	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:27.055766
5096	cube 1590	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:27.060085
5097	pentagonal prism 1188	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:27.062788
5098	cylinder 1284	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:27.065442
5099	pentagonal prism 1189	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:27.285263
5100	cube 1591	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:48:27.288059
5101	cuboid 489	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:27.290165
5102	cylinder 1285	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:27.292423
5103	pentagonal prism 1190	black	{0,0,0}	-127.95996	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:27.518214
5104	cube 1592	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:48:27.522701
5105	cube 1593	red	{0,0,0}	32.482143	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:48:27.525121
5106	cylinder 1286	green	{0,0,0}	-271.66885	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:27.527367
5107	pentagonal prism 1191	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:27.763816
5108	cube 1594	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:27.768317
5109	pentagonal prism 1192	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:27.770559
5110	cylinder 1287	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:48:27.772712
5111	pentagonal prism 1193	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:28.007393
5112	cube 1595	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:28.010962
5113	cube 1596	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:28.012996
5114	cylinder 1288	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:28.015653
5115	pentagonal prism 1194	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:28.232983
5116	cube 1597	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:48:28.235786
5117	cuboid 490	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cuboid.usd	2025-03-29 15:48:28.237916
5118	cylinder 1289	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:28.240054
5119	pentagonal prism 1195	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:28.463175
5120	cube 1598	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:28.467636
5121	cube 1599	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:28.469766
5122	cylinder 1290	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:28.471959
5123	pentagonal prism 1196	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:28.693689
5124	cube 1600	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:28.696677
5125	cuboid 491	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:48:28.699014
5126	cylinder 1291	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:48:28.701757
5127	pentagonal prism 1197	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:28.91419
5128	cube 1601	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:28.917599
5129	cube 1602	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	cube.usd	2025-03-29 15:48:28.919769
5130	cylinder 1292	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:48:28.921927
5131	pentagonal prism 1198	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:29.146241
5132	cube 1603	pink	{0,0,0}	-207.68886	346.4762	931.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:29.150719
5133	pentagonal prism 1199	red	{0,0,0}	31.497837	259.85715	924	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:48:29.15311
5134	cylinder 1293	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:29.155251
5135	pentagonal prism 1200	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:29.383743
5136	cube 1604	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:29.387361
5137	pentagonal prism 1201	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:29.389474
5138	cylinder 1294	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:48:29.391599
5139	pentagonal prism 1202	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:29.613603
5140	cube 1605	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:29.618133
5141	cube 1606	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:29.620295
5142	cylinder 1295	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:29.622389
5143	pentagonal prism 1203	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:29.858901
5144	cube 1607	pink	{0,0,0}	-208.67317	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:48:29.863464
5145	pentagonal prism 1204	red	{0,0,0}	31.497837	259.85715	924	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:48:29.866113
5146	cylinder 1296	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:29.868692
5147	pentagonal prism 1205	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:30.093284
5148	cube 1608	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.62088	cube.usd	2025-03-29 15:48:30.09697
5149	pentagonal prism 1206	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:48:30.099434
5150	cylinder 1297	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:30.101968
5151	pentagonal prism 1207	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:30.330574
5152	cube 1609	pink	{0,0,0}	-206.88084	345.12823	931.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:30.334989
5153	pentagonal prism 1208	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:30.337461
5154	cylinder 1298	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:30.339559
5155	pentagonal prism 1209	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:30.561148
5156	cube 1610	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.743565	cube.usd	2025-03-29 15:48:30.565286
5157	hexagonal prism 554	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:30.567614
5158	cylinder 1299	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:48:30.570053
5159	pentagonal prism 1210	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:30.788917
5160	cube 1611	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:30.791958
5161	cube 1612	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cube.usd	2025-03-29 15:48:30.79409
5162	cylinder 1300	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:48:30.796325
5163	pentagonal prism 1211	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:31.016295
5164	cube 1613	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:31.019796
5165	cube 1614	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cube.usd	2025-03-29 15:48:31.022141
5166	cylinder 1301	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:31.024349
5167	pentagonal prism 1212	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:31.248321
5168	cube 1615	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:31.252592
5169	pentagonal prism 1213	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:31.254806
5170	cylinder 1302	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:31.257026
5171	pentagonal prism 1214	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:31.491764
5172	cube 1616	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:31.494981
5173	cube 1617	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:48:31.49732
5174	cylinder 1303	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:31.499717
5175	pentagonal prism 1215	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:31.714034
5176	cube 1618	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:31.718293
5177	cube 1619	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:31.720928
5178	cylinder 1304	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:31.72319
5179	pentagonal prism 1216	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:31.936738
5180	cube 1620	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:31.940053
5181	cuboid 492	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:48:31.942249
5182	cylinder 1305	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:31.94444
5183	pentagonal prism 1217	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:32.170992
5184	cube 1621	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:32.174113
5185	cube 1622	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	cube.usd	2025-03-29 15:48:32.176209
5186	cylinder 1306	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:32.178549
5187	pentagonal prism 1218	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:32.404847
5188	cube 1623	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:48:32.409444
5189	cuboid 493	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:48:32.411717
5190	cylinder 1307	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:32.413931
5191	pentagonal prism 1219	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:32.641372
5192	cube 1624	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:32.645552
5193	cube 1625	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:32.647877
5194	cylinder 1308	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:48:32.650154
5195	pentagonal prism 1220	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:32.881833
5196	cube 1626	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:48:32.884808
5197	pentagonal prism 1221	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:32.887371
5198	cylinder 1309	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:32.889516
5199	pentagonal prism 1222	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:33.107627
5200	cube 1627	pink	{0,0,0}	-208.67317	346.4762	919	0	0	59.34933	cube.usd	2025-03-29 15:48:33.110254
5201	cuboid 494	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:33.112457
5202	cylinder 1310	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:33.114629
5203	pentagonal prism 1223	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:33.347669
5204	cube 1628	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:33.351856
5205	pentagonal prism 1224	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:48:33.354312
5206	cylinder 1311	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:48:33.356457
5207	pentagonal prism 1225	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:33.582617
5208	cube 1629	pink	{0,0,0}	-206.88084	345.12823	927.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:33.587089
5209	cuboid 495	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:48:33.589669
5210	cylinder 1312	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:33.591981
5211	pentagonal prism 1226	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:33.817008
5212	cube 1630	pink	{0,0,0}	-205.90038	345.12823	935.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:33.821451
5213	cuboid 496	red	{0,0,0}	32.355774	258.8462	940.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:48:33.82361
5214	cylinder 1313	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:33.825819
5215	pentagonal prism 1227	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:34.05616
5216	cube 1631	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:48:34.060396
5217	cube 1632	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:34.062426
5218	cylinder 1314	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:34.064927
5219	pentagonal prism 1228	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:34.286025
5220	cube 1633	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:34.288839
5221	cube 1634	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.405357	cube.usd	2025-03-29 15:48:34.290867
5222	cylinder 1315	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:34.292823
5223	pentagonal prism 1229	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:34.521025
5224	cube 1635	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.743565	cube.usd	2025-03-29 15:48:34.524957
5225	cube 1636	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:34.527045
5226	cylinder 1316	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:48:34.529049
5227	pentagonal prism 1230	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:34.778056
5228	cube 1637	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:34.780839
5229	cube 1638	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.874985	cube.usd	2025-03-29 15:48:34.783001
5230	cylinder 1317	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:34.785262
5231	pentagonal prism 1231	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:35.005993
5232	cube 1639	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:35.011028
5233	pentagonal prism 1232	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:35.01326
5234	cylinder 1318	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:35.015242
5235	pentagonal prism 1233	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:35.238556
5236	cube 1640	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:48:35.241139
5237	cuboid 497	red	{0,0,0}	32.355774	258.8462	912.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:48:35.243506
5238	cylinder 1319	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:35.24559
5239	pentagonal prism 1234	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:35.474681
5240	cube 1641	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:35.477456
5241	hexagonal prism 555	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:35.479845
5242	cylinder 1320	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:35.482281
5243	pentagonal prism 1235	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:35.69212
5244	cube 1642	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:48:35.695447
5245	hexagonal prism 556	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:35.697833
5246	cylinder 1321	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:35.699995
5247	pentagonal prism 1236	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:35.934239
5248	cube 1643	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:48:35.938577
5249	cuboid 498	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cuboid.usd	2025-03-29 15:48:35.941199
5250	cylinder 1322	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:35.943371
5251	pentagonal prism 1237	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:36.168879
5252	cube 1644	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:36.171734
5253	cube 1645	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:48:36.17395
5254	cylinder 1323	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:36.175995
5255	pentagonal prism 1238	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:36.404812
5256	cube 1646	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.534454	cube.usd	2025-03-29 15:48:36.408885
5257	pentagonal prism 1239	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:36.411019
5258	cylinder 1324	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:48:36.413336
5259	pentagonal prism 1240	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:36.641653
5260	cube 1647	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:36.645522
5261	cuboid 499	red	{0,0,0}	31.497837	259.85715	919	0	0	37.69424	cuboid.usd	2025-03-29 15:48:36.647507
5262	cylinder 1325	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:48:36.64965
5263	pentagonal prism 1241	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:36.873265
5264	cube 1648	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:48:36.876724
5265	cube 1649	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:48:36.878838
5266	cylinder 1326	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:48:36.880909
5267	pentagonal prism 1242	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:37.107856
5268	cube 1650	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:37.11198
5269	cuboid 500	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:37.114219
5270	cylinder 1327	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:37.116515
5271	pentagonal prism 1243	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:37.335075
5272	cube 1651	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:37.339521
5273	pentagonal prism 1244	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:37.342092
5274	cylinder 1328	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:48:37.344296
5275	pentagonal prism 1245	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:37.571829
5276	cube 1652	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:37.576212
5277	pentagonal prism 1246	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:37.578669
5278	cylinder 1329	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:37.581433
5279	pentagonal prism 1247	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:37.802192
5280	cube 1653	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.743565	cube.usd	2025-03-29 15:48:37.806719
5281	pentagonal prism 1248	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:48:37.809026
5282	cylinder 1330	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:37.811253
5283	pentagonal prism 1249	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:38.035238
5284	cube 1654	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:38.039369
5285	cube 1655	red	{0,0,0}	32.355774	258.8462	919	0	0	37.874985	cube.usd	2025-03-29 15:48:38.041968
5286	cylinder 1331	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:38.0441
5287	pentagonal prism 1250	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:38.276243
5288	cube 1656	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.62088	cube.usd	2025-03-29 15:48:38.27876
5289	cube 1657	red	{0,0,0}	32.355774	258.8462	924	0	0	38.65981	cube.usd	2025-03-29 15:48:38.281615
5290	cylinder 1332	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:48:38.284001
5291	pentagonal prism 1251	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:38.500073
5292	cube 1658	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:48:38.504324
5293	pentagonal prism 1252	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:38.507097
5294	cylinder 1333	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:38.509267
5295	pentagonal prism 1253	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:38.740106
5296	cube 1659	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:38.742764
5297	pentagonal prism 1254	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:38.744979
5298	cylinder 1334	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:38.747262
5299	pentagonal prism 1255	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:38.980879
5300	cube 1660	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:38.984594
5301	pentagonal prism 1256	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:38.987188
5302	cylinder 1335	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:38.989356
5303	pentagonal prism 1257	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:39.203783
5304	cube 1661	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 15:48:39.207104
5305	cuboid 501	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:48:39.209627
5306	cylinder 1336	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:39.211847
5307	pentagonal prism 1258	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:39.436821
5308	cube 1662	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:39.441077
5309	cube 1663	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:48:39.443271
5310	cylinder 1337	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:48:39.445357
5311	pentagonal prism 1259	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:39.692253
5312	cube 1664	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:39.694827
5313	cuboid 502	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:39.696929
5314	cylinder 1338	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:39.699114
5315	pentagonal prism 1260	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:39.924709
5316	cube 1665	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:39.928888
5317	cube 1666	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:48:39.93126
5318	cylinder 1339	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:39.933405
5319	pentagonal prism 1261	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:40.16711
5320	cube 1667	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:40.171249
5321	pentagonal prism 1262	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:40.174137
5322	cylinder 1340	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:40.176979
5323	pentagonal prism 1263	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:40.39718
5324	cube 1668	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:40.400132
5325	cube 1669	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	cube.usd	2025-03-29 15:48:40.40253
5326	cylinder 1341	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:40.404992
5327	pentagonal prism 1264	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:40.62835
5328	cube 1670	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:48:40.63256
5329	pentagonal prism 1265	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:40.634824
5330	cylinder 1342	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:40.636899
5331	pentagonal prism 1266	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:40.860352
5332	cube 1671	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:40.86325
5333	pentagonal prism 1267	red	{0,0,0}	31.497837	259.85715	933	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:40.865542
5334	cylinder 1343	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:40.867592
5335	pentagonal prism 1268	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:41.087786
5336	cube 1672	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:41.090644
5337	cuboid 503	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:41.093486
5338	cylinder 1344	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:41.095903
5339	pentagonal prism 1269	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:41.328268
5340	cube 1673	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:41.332142
5341	cuboid 504	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:48:41.334282
5342	cylinder 1345	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:48:41.336644
5343	pentagonal prism 1270	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:41.556792
5344	cube 1674	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:48:41.560445
5345	pentagonal prism 1271	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.184704	pentagonal prism.usd	2025-03-29 15:48:41.563182
5346	cylinder 1346	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:41.565631
5347	pentagonal prism 1272	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:41.787434
5348	cube 1675	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:48:41.791712
5349	cube 1676	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.746803	cube.usd	2025-03-29 15:48:41.794638
5350	cylinder 1347	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:48:41.797164
5351	pentagonal prism 1273	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:42.026876
5352	cube 1677	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:42.032843
5353	cuboid 505	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:48:42.035049
5354	cylinder 1348	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:42.037189
5355	pentagonal prism 1274	black	{0,0,0}	-127.95996	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:42.255233
5356	cube 1678	pink	{0,0,0}	-206.70456	346.4762	931.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:42.259431
5357	hexagonal prism 557	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:42.262109
5358	cylinder 1349	green	{0,0,0}	-271.66885	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:48:42.264244
5359	pentagonal prism 1275	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:42.49416
5360	cube 1679	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:48:42.498204
5361	cube 1680	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:42.500416
5362	cylinder 1350	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:42.50262
5363	pentagonal prism 1276	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:42.721564
5364	cube 1681	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:42.725316
5365	pentagonal prism 1277	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:48:42.728
5366	cylinder 1351	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:42.730482
5367	pentagonal prism 1278	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:42.957106
5368	cube 1682	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:42.960041
5369	cube 1683	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:42.962275
5370	cylinder 1352	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:42.964579
5371	pentagonal prism 1279	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:43.202198
5372	cube 1684	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:43.205018
5373	cube 1685	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:43.207253
5374	cylinder 1353	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:43.209379
5375	pentagonal prism 1280	black	{0,0,0}	-128.94427	520.6986	660	0	0	0	pentagonal prism.usd	2025-03-29 15:48:43.426705
5376	cube 1686	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:48:43.431261
5377	pentagonal prism 1281	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:48:43.433495
5378	cylinder 1354	green	{0,0,0}	-272.65317	217.53194	924	0	0	38.65981	cylinder.usd	2025-03-29 15:48:43.435686
5379	pentagonal prism 1282	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:43.665492
5380	cube 1687	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:43.667998
5381	cube 1688	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.874985	cube.usd	2025-03-29 15:48:43.670362
5382	cylinder 1355	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:43.672599
5383	pentagonal prism 1283	black	{0,0,0}	-127.95996	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:43.891734
5384	cube 1689	pink	{0,0,0}	-206.70456	346.4762	909.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:43.895733
5385	cuboid 506	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:43.898142
5386	cylinder 1356	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:43.900364
5387	pentagonal prism 1284	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:44.131258
5388	cube 1690	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:44.135339
5389	cuboid 507	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:44.137612
5390	cylinder 1357	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 15:48:44.139912
5391	pentagonal prism 1285	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:44.35836
5392	cube 1691	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:44.36268
5393	pentagonal prism 1286	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:48:44.364914
5394	cylinder 1358	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:44.367124
5395	pentagonal prism 1287	black	{0,0,0}	-127.46696	518.69244	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:44.598216
5396	cube 1692	pink	{0,0,0}	-206.88867	345.1413	913.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:44.602619
5397	pentagonal prism 1288	red	{0,0,0}	32.357	258.856	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:44.604876
5398	cylinder 1359	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:44.607042
5399	pentagonal prism 1289	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:44.827469
5400	cube 1693	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:48:44.831684
5401	cube 1694	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.874985	cube.usd	2025-03-29 15:48:44.833841
5402	cylinder 1360	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:44.836042
5403	pentagonal prism 1290	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:45.059379
5404	cube 1695	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:45.061918
5405	hexagonal prism 558	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:48:45.064243
5406	cylinder 1361	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:45.066361
5407	pentagonal prism 1291	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:45.300184
5408	cube 1696	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:45.302615
5409	pentagonal prism 1292	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:48:45.304702
5410	cylinder 1362	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:45.306686
5411	pentagonal prism 1293	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:45.529375
5412	cube 1697	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:45.533481
5413	pentagonal prism 1294	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:45.535578
5414	cylinder 1363	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:45.537746
5415	pentagonal prism 1295	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:45.764526
5416	cube 1698	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:45.768427
5417	cuboid 508	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:48:45.770613
5418	cylinder 1364	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:45.77288
5419	pentagonal prism 1296	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:45.994622
5420	cube 1699	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:48:45.999014
5421	cube 1700	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:46.001137
5422	cylinder 1365	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:46.003437
5423	pentagonal prism 1297	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:46.229532
5424	cube 1701	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:46.23371
5425	pentagonal prism 1298	red	{0,0,0}	32.355774	258.8462	912.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:46.235814
5426	cylinder 1366	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:46.237866
5427	pentagonal prism 1299	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:46.470546
5428	cube 1702	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:46.473399
5429	cuboid 509	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:46.475645
5430	cylinder 1367	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:46.477989
5431	pentagonal prism 1300	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:46.692754
5432	cube 1703	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:46.695619
5433	pentagonal prism 1301	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:46.698179
5434	cylinder 1368	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:46.700348
5435	pentagonal prism 1302	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:46.93411
5436	cube 1704	pink	{0,0,0}	-208.67317	346.4762	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:46.938393
5437	hexagonal prism 559	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:46.94055
5438	cylinder 1369	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:46.942749
5439	pentagonal prism 1303	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:47.160343
5440	cube 1705	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:47.163727
5441	cube 1706	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	cube.usd	2025-03-29 15:48:47.166505
5442	cylinder 1370	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:47.168682
5443	pentagonal prism 1304	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:47.392813
5444	cube 1707	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:48:47.395503
5445	cube 1708	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:47.397869
5446	cylinder 1371	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:47.400224
5447	pentagonal prism 1305	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:47.622464
5448	cube 1709	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:48:47.626846
5449	cube 1710	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:47.629012
5450	cylinder 1372	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	33.690067	cylinder.usd	2025-03-29 15:48:47.631334
5451	pentagonal prism 1306	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:47.846797
5452	cube 1711	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:48:47.849902
5453	pentagonal prism 1307	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:47.852113
5454	cylinder 1373	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:47.854263
5455	pentagonal prism 1308	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:48.081578
5456	cube 1712	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:48.084136
5457	cuboid 510	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:48.086425
5458	cylinder 1374	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:48.088636
5459	pentagonal prism 1309	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:48.311296
5460	cube 1713	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:48.315326
5461	cube 1714	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:48.317883
5462	cylinder 1375	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:48.320187
5463	pentagonal prism 1310	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:48.547897
5464	cube 1715	pink	{0,0,0}	-205.90038	345.12823	910	0	0	59.03625	cube.usd	2025-03-29 15:48:48.550979
5465	cube 1716	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	cube.usd	2025-03-29 15:48:48.553084
5466	cylinder 1376	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:48.555158
5467	pentagonal prism 1311	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:48.780148
5468	cube 1717	pink	{0,0,0}	-208.67317	346.4762	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:48.783959
5469	cuboid 511	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:48:48.786164
5470	cylinder 1377	green	{0,0,0}	-272.65317	217.53194	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:48.788424
5471	pentagonal prism 1312	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 15:48:49.013843
5472	cube 1718	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:49.017755
5473	cube 1719	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:49.019841
5474	cylinder 1378	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:49.021983
5475	pentagonal prism 1313	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:49.254131
5476	cube 1720	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:49.257054
5477	cube 1721	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:49.259146
5478	cylinder 1379	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:48:49.261285
5479	pentagonal prism 1314	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:49.483113
5480	cube 1722	pink	{0,0,0}	-205.90038	345.12823	939.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:49.487421
5481	cube 1723	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cube.usd	2025-03-29 15:48:49.489643
5482	cylinder 1380	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:49.491859
5483	pentagonal prism 1315	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:49.706676
5484	cube 1724	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:49.710466
5485	pentagonal prism 1316	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:49.712802
5486	cylinder 1381	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:49.715048
5487	pentagonal prism 1317	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:49.930106
5488	cube 1725	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:49.933837
5489	hexagonal prism 560	red	{0,0,0}	30.51353	260.84146	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:49.935911
5490	cylinder 1382	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:49.93819
5491	pentagonal prism 1318	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:48:50.168626
5492	cube 1726	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:50.172863
5493	cube 1727	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:48:50.175243
5494	cylinder 1383	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:50.177534
5495	pentagonal prism 1319	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:50.399285
5496	cube 1728	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:50.403697
5497	hexagonal prism 561	red	{0,0,0}	32.355774	258.8462	929	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:48:50.406176
5498	cylinder 1384	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:50.408272
5499	hexagonal prism 562	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:48:50.633475
5500	cube 1729	pink	{0,0,0}	-209.49138	347.83475	922.00006	0	0	60.255116	cube.usd	2025-03-29 15:48:50.636685
5501	cuboid 512	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:50.639061
5502	cylinder 1385	green	{0,0,0}	-273.72223	218.38489	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:50.641813
5503	pentagonal prism 1320	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:50.862623
5504	cube 1730	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:48:50.867008
5505	hexagonal prism 563	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:50.869301
5506	cylinder 1386	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:50.871849
5507	pentagonal prism 1321	black	{0,0,0}	-129.44986	522.7403	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:51.098233
5508	cube 1731	pink	{0,0,0}	-209.49138	347.83475	908.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:51.102431
5509	cube 1732	red	{0,0,0}	31.621342	260.87607	926.00006	0	0	37.405357	cube.usd	2025-03-29 15:48:51.104562
5510	cylinder 1387	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:51.106745
5511	pentagonal prism 1322	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:51.346762
5512	cube 1733	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:48:51.351314
5513	hexagonal prism 564	red	{0,0,0}	32.355774	258.8462	912.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:51.353741
5514	cylinder 1388	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:51.355989
5515	pentagonal prism 1323	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:51.585015
5516	cube 1734	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.62088	cube.usd	2025-03-29 15:48:51.588967
5517	cuboid 513	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:51.591496
5518	cylinder 1389	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:51.593896
5519	pentagonal prism 1324	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:51.813685
5520	cube 1735	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:51.817754
5521	cuboid 514	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:51.819893
5522	cylinder 1390	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:51.822226
5523	pentagonal prism 1325	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:52.062727
5524	cube 1736	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:52.066491
5525	cube 1737	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.874985	cube.usd	2025-03-29 15:48:52.069193
5526	cylinder 1391	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:52.071317
5527	pentagonal prism 1326	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:52.301396
5528	cube 1738	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:48:52.305456
5529	pentagonal prism 1327	red	{0,0,0}	31.497837	259.85715	934	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:52.307595
5530	cylinder 1392	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:52.309884
5531	pentagonal prism 1328	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:52.534817
5532	cube 1739	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:48:52.539468
5533	cuboid 515	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:48:52.542121
5534	cylinder 1393	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:48:52.544525
5535	pentagonal prism 1329	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:52.772083
5536	cube 1740	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:52.775063
5537	cuboid 516	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:52.777097
5538	cylinder 1394	green	{0,0,0}	-272.65317	217.53194	934	0	0	36.869896	cylinder.usd	2025-03-29 15:48:52.77921
5539	pentagonal prism 1330	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:48:52.997609
5540	cube 1741	pink	{0,0,0}	-206.88084	345.12823	931.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:53.002029
5541	pentagonal prism 1331	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:48:53.004494
5542	cylinder 1395	green	{0,0,0}	-270.6119	216.68562	934	0	0	33.690063	cylinder.usd	2025-03-29 15:48:53.00678
5543	pentagonal prism 1332	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:53.229554
5544	cube 1742	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:48:53.232389
5545	pentagonal prism 1333	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:48:53.234795
5546	cylinder 1396	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:53.237431
5547	pentagonal prism 1334	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:53.456109
5548	cube 1743	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:48:53.459166
5549	hexagonal prism 565	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:53.461257
5550	cylinder 1397	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:53.463563
5551	pentagonal prism 1335	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:53.686233
5552	cube 1744	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:48:53.690414
5553	hexagonal prism 566	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:53.692981
5554	cylinder 1398	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:48:53.695167
5555	pentagonal prism 1336	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:53.914062
5556	cube 1745	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:48:53.918245
5557	cuboid 517	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:53.920698
5558	cylinder 1399	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:53.922904
5559	pentagonal prism 1337	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:54.151185
5560	cube 1746	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:48:54.155734
5561	cuboid 518	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:54.158155
5562	cylinder 1400	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:54.160296
5563	pentagonal prism 1338	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:54.390969
5564	cube 1747	pink	{0,0,0}	-207.68886	346.4762	931.00006	0	0	59.743565	cube.usd	2025-03-29 15:48:54.395439
5565	cube 1748	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:48:54.398173
5566	cylinder 1401	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:54.400308
5567	pentagonal prism 1339	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:54.61999
5568	cube 1749	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:54.622551
5569	hexagonal prism 567	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:48:54.624714
5570	cylinder 1402	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:54.626816
5571	pentagonal prism 1340	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:54.851718
5572	cube 1750	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:48:54.856196
5573	pentagonal prism 1341	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:54.858434
5574	cylinder 1403	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:54.860679
5575	pentagonal prism 1342	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:55.090393
5576	cube 1751	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:48:55.094686
5577	cuboid 519	red	{0,0,0}	31.497837	259.85715	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:55.096989
5578	cylinder 1404	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:55.09937
5579	pentagonal prism 1343	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:55.317467
5580	cube 1752	pink	{0,0,0}	-207.68886	346.4762	915	0	0	59.03625	cube.usd	2025-03-29 15:48:55.321601
5581	pentagonal prism 1344	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:55.323912
5582	cylinder 1405	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:55.326033
5583	pentagonal prism 1345	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:55.55642
5584	cube 1753	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:48:55.560406
5585	cuboid 520	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:55.562546
5586	cylinder 1406	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:55.564955
5587	pentagonal prism 1346	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:55.785731
5588	cube 1754	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:55.789655
5589	cuboid 521	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:48:55.792014
5590	cylinder 1407	green	{0,0,0}	-272.65317	217.53194	920	0	0	33.690063	cylinder.usd	2025-03-29 15:48:55.794106
5591	pentagonal prism 1347	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:48:56.017266
5592	cube 1755	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:48:56.021721
5593	pentagonal prism 1348	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:48:56.024168
5594	cylinder 1408	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:56.026398
5595	pentagonal prism 1349	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:48:56.260399
5596	cube 1756	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:56.263407
5597	cuboid 522	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:56.265714
5598	cylinder 1409	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:56.267909
5599	pentagonal prism 1350	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:56.510443
5600	cube 1757	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:48:56.513421
5601	pentagonal prism 1351	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:56.515533
5602	cylinder 1410	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:56.517841
5603	pentagonal prism 1352	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:56.749405
5604	cube 1758	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:48:56.753547
5605	cuboid 523	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:48:56.756113
5606	cylinder 1411	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:48:56.758488
5607	pentagonal prism 1353	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:56.971586
5608	cube 1759	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:56.974692
5609	pentagonal prism 1354	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:48:56.97676
5610	cylinder 1412	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:56.978911
5611	pentagonal prism 1355	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:57.203171
5612	cube 1760	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.743565	cube.usd	2025-03-29 15:48:57.207384
5613	pentagonal prism 1356	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:48:57.209576
5614	cylinder 1413	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:57.21176
5615	pentagonal prism 1357	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:57.437127
5616	cube 1761	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:57.440397
5617	cuboid 524	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:48:57.44268
5618	cylinder 1414	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:57.444852
5619	pentagonal prism 1358	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:57.673618
5620	cube 1762	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:57.678395
5621	cuboid 525	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:57.681097
5622	cylinder 1415	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:48:57.683255
5623	pentagonal prism 1359	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 15:48:57.904534
5624	cube 1763	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.420776	cube.usd	2025-03-29 15:48:57.908459
5625	cube 1764	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:48:57.910609
5626	cylinder 1416	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:57.912829
5627	pentagonal prism 1360	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:48:58.169027
5628	cube 1765	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:48:58.171975
5629	cube 1766	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:48:58.174338
5630	cylinder 1417	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:58.176517
5631	pentagonal prism 1361	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:58.402467
5632	cube 1767	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:48:58.406703
5633	cuboid 526	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:48:58.408927
5634	cylinder 1418	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:58.411078
5635	pentagonal prism 1362	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:58.637002
5636	cube 1768	pink	{0,0,0}	-208.67317	346.4762	919	0	0	59.03625	cube.usd	2025-03-29 15:48:58.641252
5637	pentagonal prism 1363	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:58.643615
5638	cylinder 1419	green	{0,0,0}	-272.65317	217.53194	929	0	0	36.869896	cylinder.usd	2025-03-29 15:48:58.645696
5639	pentagonal prism 1364	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:58.874739
5640	cube 1769	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:48:58.877761
5641	cuboid 527	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:48:58.880078
5642	cylinder 1420	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:58.882257
5643	pentagonal prism 1365	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:59.113158
5644	cube 1770	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:48:59.117746
5645	cuboid 528	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:48:59.120256
5646	cylinder 1421	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:59.122388
5647	pentagonal prism 1366	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:48:59.352571
5648	cube 1771	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:59.356461
5649	cuboid 529	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:48:59.359183
5650	cylinder 1422	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:59.361493
5651	pentagonal prism 1367	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:59.60202
5652	cube 1772	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:48:59.606369
5653	pentagonal prism 1368	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:48:59.6089
5654	cylinder 1423	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:48:59.610956
5655	pentagonal prism 1369	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:48:59.820029
5656	cube 1773	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:48:59.822587
5657	pentagonal prism 1370	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:48:59.824855
5658	cylinder 1424	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:48:59.827024
5659	pentagonal prism 1371	black	{0,0,0}	-129.44986	522.7403	657	0	0	0	pentagonal prism.usd	2025-03-29 15:49:00.039046
5660	cube 1774	pink	{0,0,0}	-208.50322	347.83475	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:00.042329
5661	cube 1775	red	{0,0,0}	31.621342	260.87607	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:00.044722
5662	cylinder 1425	green	{0,0,0}	-273.72223	218.38489	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:00.046796
5663	pentagonal prism 1372	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:00.278156
5664	cube 1776	pink	{0,0,0}	-208.67317	346.4762	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:00.282283
5665	cube 1777	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:49:00.28453
5666	cylinder 1426	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:00.28709
5667	pentagonal prism 1373	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:00.503568
5668	cube 1778	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:00.507903
5669	cuboid 530	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:00.510118
5670	cylinder 1427	green	{0,0,0}	-272.65317	217.53194	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:00.512281
5671	pentagonal prism 1374	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:00.739908
5672	cube 1779	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:49:00.744265
5673	cuboid 531	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:49:00.746605
5674	cylinder 1428	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:49:00.748695
5675	pentagonal prism 1375	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:00.972449
5676	cube 1780	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:49:00.975343
5677	cube 1781	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:00.977644
5678	cylinder 1429	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:00.979991
5679	pentagonal prism 1376	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:01.218847
5680	cube 1782	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:01.222892
5681	hexagonal prism 568	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:01.225424
5682	cylinder 1430	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:01.227648
5683	pentagonal prism 1377	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:01.454542
5684	cube 1783	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:01.457513
5685	cuboid 532	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:49:01.46002
5686	cylinder 1431	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:01.462367
5687	pentagonal prism 1378	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:01.672858
5688	cube 1784	pink	{0,0,0}	-208.67317	346.4762	928.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:01.676878
5689	pentagonal prism 1379	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:01.679025
5690	cylinder 1432	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:01.681327
5691	pentagonal prism 1380	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:01.906324
5692	cube 1785	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 15:49:01.910355
5693	cuboid 533	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:01.912513
5694	cylinder 1433	green	{0,0,0}	-272.65317	217.53194	936.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:49:01.914647
5695	pentagonal prism 1381	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:02.144245
5696	cube 1786	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:49:02.148563
5697	cuboid 534	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:02.150755
5698	cylinder 1434	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:02.152966
5699	pentagonal prism 1382	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:02.372351
5700	cube 1787	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:02.375435
5701	pentagonal prism 1383	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:02.377943
5702	cylinder 1435	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:02.380122
5703	pentagonal prism 1384	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:02.607637
5704	cube 1788	pink	{0,0,0}	-205.90816	345.1413	915	0	0	59.03625	cube.usd	2025-03-29 15:49:02.612345
5705	cuboid 535	red	{0,0,0}	32.357	258.856	930.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:49:02.614401
5706	cylinder 1436	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:02.616705
5707	pentagonal prism 1385	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:02.851963
5708	cube 1789	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:02.854967
5709	pentagonal prism 1386	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:02.857033
5710	cylinder 1437	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:02.859181
5711	pentagonal prism 1387	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:03.090611
5712	cube 1790	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:03.09496
5713	hexagonal prism 569	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:03.097541
5714	cylinder 1438	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:03.09985
5715	pentagonal prism 1388	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:03.325936
5716	cube 1791	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:03.328891
5717	cuboid 536	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:49:03.33157
5718	cylinder 1439	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:03.334135
5719	pentagonal prism 1389	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:03.556551
5720	cube 1792	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:03.559216
5721	pentagonal prism 1390	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:03.561845
5722	cylinder 1440	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:49:03.564063
5723	pentagonal prism 1391	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:03.7734
5724	cube 1793	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.93142	cube.usd	2025-03-29 15:49:03.776401
5725	hexagonal prism 570	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:03.778834
5726	cylinder 1441	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:03.781047
5727	pentagonal prism 1392	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:03.994146
5728	cube 1794	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:03.99724
5729	cube 1795	red	{0,0,0}	31.497837	259.85715	930.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:03.999526
5730	cylinder 1442	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:04.001672
5731	pentagonal prism 1393	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:04.229399
5732	cube 1796	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.34933	cube.usd	2025-03-29 15:49:04.232138
5733	cuboid 537	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:04.234229
5734	cylinder 1443	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:04.23647
5735	pentagonal prism 1394	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:04.460486
5736	cube 1797	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:49:04.464815
5737	cube 1798	red	{0,0,0}	31.497837	259.85715	913.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:04.466852
5738	cylinder 1444	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:04.469203
5739	pentagonal prism 1395	black	{0,0,0}	-129.44986	522.7403	660	0	0	90	pentagonal prism.usd	2025-03-29 15:49:04.690963
5740	cube 1799	pink	{0,0,0}	-208.50322	347.83475	932.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:04.695453
5741	cuboid 538	red	{0,0,0}	31.621342	260.87607	924	0	0	37.405357	cuboid.usd	2025-03-29 15:49:04.697873
5742	cylinder 1445	green	{0,0,0}	-273.72223	218.38489	933	0	0	26.56505	cylinder.usd	2025-03-29 15:49:04.700057
5743	pentagonal prism 1396	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:04.924367
5744	cube 1800	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:49:04.928288
5745	cuboid 539	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:04.930533
5746	cylinder 1446	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:04.932785
5747	pentagonal prism 1397	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:05.158043
5748	cube 1801	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:49:05.162345
5749	cuboid 540	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:49:05.16477
5750	cylinder 1447	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:05.16704
5751	pentagonal prism 1398	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:05.394517
5752	cube 1802	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:49:05.398817
5753	cube 1803	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:05.401265
5754	cylinder 1448	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:05.403419
5755	pentagonal prism 1399	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:05.629186
5756	cube 1804	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:05.632252
5757	cube 1805	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:05.634424
5758	cylinder 1449	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:49:05.636657
5759	pentagonal prism 1400	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:05.867576
5760	cube 1806	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:05.871524
5761	cube 1807	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cube.usd	2025-03-29 15:49:05.873658
5762	cylinder 1450	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:05.875964
5763	pentagonal prism 1401	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:06.100861
5764	cube 1808	pink	{0,0,0}	-208.67317	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:49:06.105038
5765	cuboid 541	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cuboid.usd	2025-03-29 15:49:06.107093
5766	cylinder 1451	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:06.109556
5767	pentagonal prism 1402	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:06.328869
5768	cube 1809	pink	{0,0,0}	-205.90038	345.12823	941.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:06.332963
5769	cuboid 542	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:49:06.33506
5770	cylinder 1452	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:06.337181
5771	pentagonal prism 1403	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:06.574228
5772	cube 1810	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:06.578281
5773	cuboid 543	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:49:06.580689
5774	cylinder 1453	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:06.582887
5775	pentagonal prism 1404	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:06.812992
5776	cube 1811	pink	{0,0,0}	-206.88084	345.12823	913.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:06.815558
5777	pentagonal prism 1405	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:49:06.817694
5778	cylinder 1454	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:06.819731
5779	pentagonal prism 1406	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:07.043585
5780	cube 1812	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:49:07.047748
5781	cube 1813	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:49:07.050132
5782	cylinder 1455	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:49:07.052471
5783	pentagonal prism 1407	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:07.276486
5784	cube 1814	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:07.280357
5785	cube 1815	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:07.282503
5786	cylinder 1456	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:07.284679
5787	pentagonal prism 1408	black	{0,0,0}	-128.94427	520.6986	653.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:07.509847
5788	cube 1816	pink	{0,0,0}	-208.67317	346.4762	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:07.514322
5789	cuboid 544	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:49:07.516736
5790	cylinder 1457	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:07.518989
5791	pentagonal prism 1409	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:07.74103
5792	cube 1817	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:49:07.745157
5793	pentagonal prism 1410	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:07.747302
5794	cylinder 1458	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:07.749992
5795	pentagonal prism 1411	black	{0,0,0}	-127.95996	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:07.963284
5796	cube 1818	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.743565	cube.usd	2025-03-29 15:49:07.966577
5797	cuboid 545	red	{0,0,0}	32.482143	259.85715	929	0	0	37.568592	cuboid.usd	2025-03-29 15:49:07.968826
5798	cylinder 1459	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:07.971003
5799	pentagonal prism 1412	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:08.183522
5800	cube 1819	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:08.186584
5801	pentagonal prism 1413	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:08.189024
5802	cylinder 1460	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:08.191472
5803	pentagonal prism 1414	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:08.405315
5804	cube 1820	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:08.409305
5805	cube 1821	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:49:08.411305
5806	cylinder 1461	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:49:08.413328
5807	pentagonal prism 1415	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:08.634734
5808	cube 1822	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:08.637812
5809	cube 1823	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:49:08.640222
5810	cylinder 1462	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:49:08.642345
5811	hexagonal prism 571	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:49:08.86292
5812	cube 1824	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:08.868485
5813	cuboid 546	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:49:08.871135
5814	cylinder 1463	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:08.873323
5815	pentagonal prism 1416	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:09.097568
5816	cube 1825	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:49:09.102088
5817	cube 1826	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	cube.usd	2025-03-29 15:49:09.104348
5818	cylinder 1464	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:09.106534
5819	pentagonal prism 1417	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:09.328025
5820	cube 1827	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:49:09.332675
5821	cube 1828	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:49:09.335213
5822	cylinder 1465	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 15:49:09.337464
5823	pentagonal prism 1418	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:09.565857
5824	cube 1829	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:09.568308
5825	cube 1830	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:09.570352
5826	cylinder 1466	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:49:09.572438
5827	pentagonal prism 1419	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:09.797591
5828	cube 1831	pink	{0,0,0}	-205.90038	345.12823	909.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:09.80191
5829	pentagonal prism 1420	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:09.804128
5830	cylinder 1467	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:09.806338
5831	pentagonal prism 1421	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:10.031248
5832	cube 1832	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:49:10.035115
5833	cuboid 547	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:49:10.037094
5834	cylinder 1468	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:10.039327
5835	pentagonal prism 1422	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:10.26068
5836	cube 1833	pink	{0,0,0}	-208.67317	346.4762	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:10.264462
5837	cube 1834	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:10.266979
5838	cylinder 1469	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:10.269217
5839	pentagonal prism 1423	black	{0,0,0}	-127.45538	519.6258	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:10.510961
5840	cube 1835	pink	{0,0,0}	-206.86989	346.0904	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:10.515133
5841	cube 1836	red	{0,0,0}	32.354057	259.8129	921.00006	0	0	37.303947	cube.usd	2025-03-29 15:49:10.517936
5842	cylinder 1470	green	{0,0,0}	-270.59756	217.65457	933	0	0	26.56505	cylinder.usd	2025-03-29 15:49:10.520257
5843	pentagonal prism 1424	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:10.7473
5844	cube 1837	pink	{0,0,0}	-207.68886	346.4762	933	0	0	59.34933	cube.usd	2025-03-29 15:49:10.751295
5845	cube 1838	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:10.753583
5846	cylinder 1471	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:10.75567
5847	pentagonal prism 1425	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:49:10.978294
5848	cube 1839	pink	{0,0,0}	-205.90038	345.12823	907.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:10.982475
5849	pentagonal prism 1426	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:10.984848
5850	cylinder 1472	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:10.987022
5851	pentagonal prism 1427	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:11.216009
5852	cube 1840	pink	{0,0,0}	-206.88084	345.12823	931.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:11.218436
5853	cuboid 548	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:49:11.220548
5854	cylinder 1473	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:49:11.222707
5855	pentagonal prism 1428	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:11.450219
5856	cube 1841	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:11.454411
5857	cube 1842	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:11.456716
5858	cylinder 1474	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:11.45887
5859	pentagonal prism 1429	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:11.694096
5860	cube 1843	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:11.698608
5861	cube 1844	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:11.701342
5862	cylinder 1475	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:11.703593
5863	pentagonal prism 1430	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:11.93003
5864	cube 1845	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:49:11.935984
5865	cuboid 549	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:49:11.938369
5866	cylinder 1476	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:49:11.940697
5867	pentagonal prism 1431	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:12.181468
5868	cube 1846	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:12.185431
5869	cuboid 550	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:49:12.187774
5870	cylinder 1477	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:12.190005
5871	pentagonal prism 1432	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:12.42409
5872	cube 1847	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.620872	cube.usd	2025-03-29 15:49:12.427238
5873	cube 1848	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:12.429493
5874	cylinder 1478	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:12.431818
5875	pentagonal prism 1433	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:12.645012
5876	cube 1849	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:49:12.649416
5877	cube 1850	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:12.652213
5878	cylinder 1479	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:12.654422
5879	pentagonal prism 1434	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 15:49:12.865619
5880	cube 1851	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.93142	cube.usd	2025-03-29 15:49:12.868427
5881	pentagonal prism 1435	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:12.870619
5882	cylinder 1480	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 15:49:12.872853
5883	pentagonal prism 1436	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:13.100634
5884	cube 1852	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:49:13.103441
5885	cuboid 551	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:49:13.105632
5886	cylinder 1481	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:13.107898
5887	pentagonal prism 1437	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:13.331537
5888	cube 1853	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:13.334426
5889	hexagonal prism 572	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:13.337012
5890	cylinder 1482	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:13.339736
5891	pentagonal prism 1438	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:13.590644
5892	cube 1854	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:13.594123
5893	cuboid 552	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:13.596601
5894	cylinder 1483	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:13.599016
5895	pentagonal prism 1439	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:13.813978
5896	cube 1855	pink	{0,0,0}	-207.68886	346.4762	931.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:13.816804
5897	cube 1856	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.405357	cube.usd	2025-03-29 15:49:13.81956
5898	cylinder 1484	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:49:13.821784
5899	pentagonal prism 1440	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:14.073022
5900	cube 1857	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:49:14.075535
5901	cuboid 553	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:14.077704
5902	cylinder 1485	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:14.080776
5903	pentagonal prism 1441	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:14.305418
5904	cube 1858	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:14.309247
5905	cuboid 554	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:49:14.311397
5906	cylinder 1486	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:14.313707
5907	pentagonal prism 1442	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:14.531853
5908	cube 1859	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:49:14.535951
5909	hexagonal prism 573	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:14.538438
5910	cylinder 1487	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:14.540583
5911	pentagonal prism 1443	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:49:14.764614
5912	cube 1860	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:49:14.76882
5913	cuboid 555	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:49:14.771113
5914	cylinder 1488	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:49:14.773263
5915	pentagonal prism 1444	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:14.99951
5916	cube 1861	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:15.001959
5917	cube 1862	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:15.004223
5918	cylinder 1489	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:15.006421
5919	pentagonal prism 1445	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:15.216828
5920	cube 1863	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:15.220007
5921	cuboid 556	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:15.222299
5922	cylinder 1490	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:15.224467
5923	pentagonal prism 1446	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:15.470093
5924	cube 1864	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.420776	cube.usd	2025-03-29 15:49:15.474364
5925	pentagonal prism 1447	red	{0,0,0}	31.497837	259.85715	934	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:49:15.476421
5926	cylinder 1491	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:15.478595
5927	pentagonal prism 1448	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:15.699029
5928	cube 1865	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:15.703132
5929	cube 1866	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cube.usd	2025-03-29 15:49:15.705523
5930	cylinder 1492	green	{0,0,0}	-272.65317	217.53194	929	0	0	33.690067	cylinder.usd	2025-03-29 15:49:15.707783
5931	pentagonal prism 1449	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:15.932201
5932	cube 1867	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:49:15.936316
5933	cuboid 557	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:49:15.938723
5934	cylinder 1493	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:15.940969
5935	pentagonal prism 1450	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:16.173951
5936	cube 1868	pink	{0,0,0}	-206.88084	345.12823	932.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:16.17678
5937	pentagonal prism 1451	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:16.179092
5938	cylinder 1494	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:16.181238
5939	pentagonal prism 1452	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:16.412834
5940	cube 1869	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:16.415268
5941	cube 1870	red	{0,0,0}	31.497837	259.85715	919	0	0	37.568592	cube.usd	2025-03-29 15:49:16.417339
5942	cylinder 1495	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:49:16.419737
5943	pentagonal prism 1453	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:16.632404
5944	cube 1871	pink	{0,0,0}	-207.68886	346.4762	913.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:16.637117
5945	cube 1872	red	{0,0,0}	31.497837	259.85715	913.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:16.639697
5946	cylinder 1496	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:16.641849
5947	pentagonal prism 1454	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:49:16.867888
5948	cube 1873	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:16.872225
5949	cube 1874	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:16.874331
5950	cylinder 1497	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:16.876446
5951	pentagonal prism 1455	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:17.103351
5952	cube 1875	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03624	cube.usd	2025-03-29 15:49:17.107728
5953	cube 1876	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.746803	cube.usd	2025-03-29 15:49:17.110232
5954	cylinder 1498	green	{0,0,0}	-270.6119	216.68562	933	0	0	18.434948	cylinder.usd	2025-03-29 15:49:17.112454
5955	pentagonal prism 1456	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:17.336507
5956	cube 1877	pink	{0,0,0}	-206.88084	345.12823	935.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:17.340723
5957	cube 1878	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:17.342906
5958	cylinder 1499	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:17.345321
5959	pentagonal prism 1457	black	{0,0,0}	-129.44986	522.7403	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:17.570518
5960	cube 1879	pink	{0,0,0}	-208.50322	347.83475	913.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:17.57478
5961	cube 1880	red	{0,0,0}	31.621342	260.87607	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:17.577135
5962	cylinder 1500	green	{0,0,0}	-273.72223	218.38489	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:17.579283
5963	pentagonal prism 1458	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:17.820989
5964	cube 1881	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:17.824566
5965	pentagonal prism 1459	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:17.826725
5966	cylinder 1501	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:17.829064
5967	pentagonal prism 1460	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:49:18.048807
5968	cube 1882	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:18.052983
5969	cuboid 558	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:49:18.055131
5970	cylinder 1502	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:18.05778
5971	pentagonal prism 1461	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:18.270193
5972	cube 1883	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:18.273287
5973	cube 1884	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:18.275484
5974	cylinder 1503	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:18.277668
5975	pentagonal prism 1462	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:18.503754
5976	cube 1885	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:18.508149
5977	cuboid 559	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:49:18.510515
5978	cylinder 1504	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	38.659805	cylinder.usd	2025-03-29 15:49:18.512987
5979	pentagonal prism 1463	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:18.754336
5980	cube 1886	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:18.758378
5981	cuboid 560	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:49:18.760565
5982	cylinder 1505	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:18.762964
5983	pentagonal prism 1464	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:18.9902
5984	cube 1887	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:49:18.994628
5985	cuboid 561	red	{0,0,0}	32.355774	258.8462	935.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:18.996752
5986	cylinder 1506	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:18.999159
5987	pentagonal prism 1465	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:19.225719
5988	cube 1888	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:19.228576
5989	pentagonal prism 1466	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:19.230699
5990	cylinder 1507	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:19.233549
5991	pentagonal prism 1467	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:19.468184
5992	cube 1889	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:19.472462
5993	pentagonal prism 1468	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:19.474674
5994	cylinder 1508	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:19.47682
5995	pentagonal prism 1469	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:19.702906
5996	cube 1890	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.743565	cube.usd	2025-03-29 15:49:19.707625
5997	cube 1891	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.69424	cube.usd	2025-03-29 15:49:19.710073
5998	cylinder 1509	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:19.712159
5999	pentagonal prism 1470	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:19.939807
6000	cube 1892	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:19.943922
6001	cuboid 562	red	{0,0,0}	32.355774	258.8462	915	0	0	37.568592	cuboid.usd	2025-03-29 15:49:19.946055
6002	cylinder 1510	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:49:19.948275
6003	hexagonal prism 574	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	hexagonal prism.usd	2025-03-29 15:49:20.177486
6004	cube 1893	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:20.181681
6005	cuboid 563	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:49:20.183814
6006	cylinder 1511	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:20.185995
6007	pentagonal prism 1471	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:20.414838
6008	cube 1894	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:20.41804
6009	pentagonal prism 1472	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:20.420482
6010	cylinder 1512	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:20.422739
6011	pentagonal prism 1473	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:20.638548
6012	cube 1895	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:49:20.641627
6013	pentagonal prism 1474	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:20.643866
6014	cylinder 1513	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:20.646149
6015	pentagonal prism 1475	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:20.869334
6016	cube 1896	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:20.872458
6017	cuboid 564	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:20.875046
6018	cylinder 1514	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:20.877312
6019	pentagonal prism 1476	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:21.113929
6020	cube 1897	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:21.117873
6021	cylinder 1515	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cylinder.usd	2025-03-29 15:49:21.120075
6022	cylinder 1516	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:21.122312
6023	pentagonal prism 1477	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:21.367949
6024	cube 1898	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:21.372091
6025	pentagonal prism 1478	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:49:21.37427
6026	cylinder 1517	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:49:21.37646
6027	pentagonal prism 1479	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:21.587322
6028	cube 1899	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:49:21.59033
6029	cube 1900	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	cube.usd	2025-03-29 15:49:21.592844
6030	cylinder 1518	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:21.595125
6031	pentagonal prism 1480	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:21.834383
6032	cube 1901	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.93142	cube.usd	2025-03-29 15:49:21.836887
6033	pentagonal prism 1481	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:21.839244
6034	cylinder 1519	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:21.841499
6035	pentagonal prism 1482	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:22.05324
6036	cube 1902	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:22.056676
6037	hexagonal prism 575	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:22.058969
6038	cylinder 1520	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:22.061515
6039	pentagonal prism 1483	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:22.273279
6040	cube 1903	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:22.276739
6041	cuboid 565	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:49:22.27912
6042	cylinder 1521	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:22.28129
6043	pentagonal prism 1484	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:49:22.507708
6044	cube 1904	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.34933	cube.usd	2025-03-29 15:49:22.512144
6045	cube 1905	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:22.514585
6046	cylinder 1522	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:22.51681
6047	pentagonal prism 1485	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:22.736292
6048	cube 1906	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:22.740714
6049	cuboid 566	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	cuboid.usd	2025-03-29 15:49:22.743525
6050	cylinder 1523	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:49:22.745808
6051	pentagonal prism 1486	black	{0,0,0}	-127.462135	518.67285	660	0	0	0	pentagonal prism.usd	2025-03-29 15:49:22.965099
6052	cube 1907	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:22.969288
6053	hexagonal prism 576	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:49:22.971477
6054	cylinder 1524	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:22.973669
6055	pentagonal prism 1487	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:23.187653
6056	cube 1908	pink	{0,0,0}	-206.88084	345.12823	910	0	0	59.534454	cube.usd	2025-03-29 15:49:23.190349
6057	cube 1909	red	{0,0,0}	32.355774	258.8462	924	0	0	37.746803	cube.usd	2025-03-29 15:49:23.192603
6058	cylinder 1525	green	{0,0,0}	-270.6119	216.68562	920	0	0	33.690063	cylinder.usd	2025-03-29 15:49:23.194819
6059	pentagonal prism 1488	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:23.427855
6060	cube 1910	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.743565	cube.usd	2025-03-29 15:49:23.433095
6061	pentagonal prism 1489	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:23.43561
6062	cylinder 1526	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:49:23.437899
6063	pentagonal prism 1490	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:23.664791
6064	cube 1911	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:23.66734
6065	cuboid 567	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:23.669767
6066	cylinder 1527	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:49:23.671997
6067	pentagonal prism 1491	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:23.894541
6068	cube 1912	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:49:23.899084
6069	pentagonal prism 1492	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:23.901397
6070	cylinder 1528	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:23.903558
6071	pentagonal prism 1493	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:24.135015
6072	cube 1913	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:49:24.139276
6073	pentagonal prism 1494	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:24.141909
6074	cylinder 1529	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:49:24.144599
6075	pentagonal prism 1495	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:24.366098
6076	cube 1914	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:49:24.369359
6077	hexagonal prism 577	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:24.371497
6078	cylinder 1530	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:49:24.373672
6079	pentagonal prism 1496	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:24.601009
6080	cube 1915	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:24.604009
6081	pentagonal prism 1497	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:24.606451
6082	cylinder 1531	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:24.608662
6083	pentagonal prism 1498	black	{0,0,0}	-127.45538	519.6258	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:24.824516
6084	cube 1916	pink	{0,0,0}	-206.86989	346.0904	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:24.828219
6085	cube 1917	red	{0,0,0}	32.354057	259.8129	929	0	0	37.568592	cube.usd	2025-03-29 15:49:24.830613
6086	cylinder 1532	green	{0,0,0}	-270.59756	217.65457	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:24.832957
6087	pentagonal prism 1499	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:25.078908
6088	cube 1918	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.34933	cube.usd	2025-03-29 15:49:25.083122
6089	cube 1919	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:25.085306
6090	cylinder 1533	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:25.087519
6091	pentagonal prism 1500	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:25.311475
6092	cube 1920	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:25.315435
6093	cube 1921	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:25.317675
6094	cylinder 1534	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:25.320075
6095	pentagonal prism 1501	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:25.539732
6096	cube 1922	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:25.544378
6097	cube 1923	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:25.547029
6098	cylinder 1535	green	{0,0,0}	-272.65317	217.53194	920	0	0	18.434948	cylinder.usd	2025-03-29 15:49:25.549457
6099	pentagonal prism 1502	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:25.768721
6100	cube 1924	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:49:25.7728
6101	cuboid 568	red	{0,0,0}	32.355774	258.8462	929	0	0	37.746803	cuboid.usd	2025-03-29 15:49:25.775071
6102	cylinder 1536	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:25.777325
6103	pentagonal prism 1503	black	{0,0,0}	-127.95996	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:25.999348
6104	cube 1925	pink	{0,0,0}	-206.70456	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:49:26.002468
6105	pentagonal prism 1504	red	{0,0,0}	32.482143	259.85715	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:26.004896
6106	cylinder 1537	green	{0,0,0}	-271.66885	217.53194	929	0	0	18.434948	cylinder.usd	2025-03-29 15:49:26.007153
6107	pentagonal prism 1505	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:26.222919
6108	cube 1926	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:26.227078
6109	pentagonal prism 1506	red	{0,0,0}	31.497837	259.85715	929	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:49:26.229733
6110	cylinder 1538	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:26.232125
6111	pentagonal prism 1507	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:26.459231
6112	cube 1927	pink	{0,0,0}	-206.70456	346.4762	911.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:26.463471
6113	pentagonal prism 1508	red	{0,0,0}	32.482143	259.85715	926.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:26.466062
6114	cylinder 1539	green	{0,0,0}	-271.66885	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:26.468418
6115	pentagonal prism 1509	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:26.690992
6116	cube 1928	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03624	cube.usd	2025-03-29 15:49:26.695056
6117	cube 1929	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:26.697528
6118	cylinder 1540	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:26.699774
6119	pentagonal prism 1510	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:26.928985
6120	cube 1930	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.534454	cube.usd	2025-03-29 15:49:26.933258
6121	pentagonal prism 1511	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:26.935516
6122	cylinder 1541	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:26.937795
6123	pentagonal prism 1512	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:27.168127
6124	cube 1931	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:49:27.172362
6125	pentagonal prism 1513	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:27.174516
6126	cylinder 1542	green	{0,0,0}	-270.6119	216.68562	943	0	0	26.56505	cylinder.usd	2025-03-29 15:49:27.176751
6127	pentagonal prism 1514	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:27.401622
6128	cube 1932	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:27.40595
6129	cuboid 569	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:49:27.408187
6130	cylinder 1543	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:49:27.410314
6131	pentagonal prism 1515	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:27.627455
6132	cube 1933	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:49:27.631882
6133	hexagonal prism 578	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:49:27.634405
6134	cylinder 1544	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:27.636614
6135	pentagonal prism 1516	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:27.8612
6136	cube 1934	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.743565	cube.usd	2025-03-29 15:49:27.865588
6137	cube 1935	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:49:27.867907
6138	cylinder 1545	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:27.870107
6139	pentagonal prism 1517	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:28.093864
6140	cube 1936	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:28.097945
6141	cube 1937	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:49:28.100167
6142	cylinder 1546	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:28.102384
6143	pentagonal prism 1518	black	{0,0,0}	-128.94919	520.7185	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:28.328471
6144	cube 1938	pink	{0,0,0}	-207.6968	346.48944	929	0	0	59.420776	cube.usd	2025-03-29 15:49:28.33326
6145	cube 1939	red	{0,0,0}	31.499039	259.86707	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:28.335742
6146	cylinder 1547	green	{0,0,0}	-272.66354	217.54024	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:28.338107
6147	pentagonal prism 1519	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:28.589891
6148	cube 1940	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:49:28.594146
6149	pentagonal prism 1520	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:28.597022
6150	cylinder 1548	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:28.599797
6151	pentagonal prism 1521	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:28.812389
6152	cube 1941	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:28.815282
6153	cube 1942	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:49:28.817519
6154	cylinder 1549	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:28.819703
6155	pentagonal prism 1522	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:29.046177
6156	cube 1943	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.743565	cube.usd	2025-03-29 15:49:29.050588
6157	pentagonal prism 1523	red	{0,0,0}	32.355774	258.8462	919	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:29.052966
6158	cylinder 1550	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:29.055203
6159	pentagonal prism 1524	black	{0,0,0}	-128.94427	520.6986	660	0	0	90	pentagonal prism.usd	2025-03-29 15:49:29.285409
6160	cube 1944	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:49:29.289579
6161	hexagonal prism 579	red	{0,0,0}	31.497837	259.85715	924	0	0	37.303947	hexagonal prism.usd	2025-03-29 15:49:29.291754
6162	cylinder 1551	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:29.293924
6163	pentagonal prism 1525	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:29.508868
6164	cube 1945	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:29.513244
6165	pentagonal prism 1526	red	{0,0,0}	32.355774	258.8462	920	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:49:29.515794
6166	cylinder 1552	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:29.518048
6167	pentagonal prism 1527	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:29.755044
6168	cube 1946	pink	{0,0,0}	-205.90038	345.12823	937.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:29.759243
6169	cube 1947	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.746803	cube.usd	2025-03-29 15:49:29.761455
6170	cylinder 1553	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:49:29.763835
6171	pentagonal prism 1528	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:29.985443
6172	cube 1948	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:29.988064
6173	cuboid 570	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:49:29.990346
6174	cylinder 1554	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:29.99253
6175	pentagonal prism 1529	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:30.214264
6176	cube 1949	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:30.218317
6177	cuboid 571	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:49:30.220591
6178	cylinder 1555	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690067	cylinder.usd	2025-03-29 15:49:30.222731
6179	pentagonal prism 1530	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:30.444933
6180	cube 1950	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.34933	cube.usd	2025-03-29 15:49:30.448972
6181	pentagonal prism 1531	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:30.451143
6182	cylinder 1556	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:30.453367
6183	pentagonal prism 1532	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:30.681512
6184	cube 1951	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:30.68597
6185	cube 1952	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:30.688549
6186	cylinder 1557	green	{0,0,0}	-270.6119	216.68562	938	0	0	36.869896	cylinder.usd	2025-03-29 15:49:30.691044
6187	pentagonal prism 1533	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:30.929081
6188	cube 1953	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:30.933583
6189	cube 1954	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:49:30.935822
6190	cylinder 1558	green	{0,0,0}	-270.6119	216.68562	924	0	0	33.690063	cylinder.usd	2025-03-29 15:49:30.938231
6191	pentagonal prism 1534	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:31.161688
6192	cube 1955	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:31.166314
6193	pentagonal prism 1535	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.234837	pentagonal prism.usd	2025-03-29 15:49:31.168831
6194	cylinder 1559	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:31.170974
6195	pentagonal prism 1536	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:31.399253
6196	cube 1956	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.534454	cube.usd	2025-03-29 15:49:31.402553
6197	pentagonal prism 1537	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:31.40487
6198	cylinder 1560	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:31.407288
6199	pentagonal prism 1538	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:31.625744
6200	cube 1957	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:49:31.629688
6201	cube 1958	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:49:31.632229
6202	cylinder 1561	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:31.634901
6203	pentagonal prism 1539	black	{0,0,0}	-128.94427	520.6986	660	0	0	90	pentagonal prism.usd	2025-03-29 15:49:31.847302
6204	cube 1959	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:49:31.85068
6205	cuboid 572	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:49:31.852858
6206	cylinder 1562	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:31.855296
6207	pentagonal prism 1540	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:32.084033
6208	cube 1960	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:49:32.087379
6209	cube 1961	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:32.089527
6210	cylinder 1563	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:32.091766
6211	pentagonal prism 1541	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:32.314606
6212	cube 1962	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:32.317806
6213	cuboid 573	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:49:32.319994
6214	cylinder 1564	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:32.322183
6215	pentagonal prism 1542	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:32.552218
6216	cube 1963	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:32.556711
6217	cube 1964	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:32.558936
6218	cylinder 1565	green	{0,0,0}	-272.65317	217.53194	924	0	0	33.690063	cylinder.usd	2025-03-29 15:49:32.561279
6219	pentagonal prism 1543	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:32.783772
6220	cube 1965	pink	{0,0,0}	-208.67317	346.4762	930.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:32.786607
6221	cuboid 574	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:32.788892
6222	cylinder 1566	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:49:32.791045
6223	pentagonal prism 1544	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:33.018703
6224	cube 1966	pink	{0,0,0}	-208.67317	346.4762	915	0	0	59.34933	cube.usd	2025-03-29 15:49:33.02316
6225	cuboid 575	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:33.025445
6226	cylinder 1567	green	{0,0,0}	-272.65317	217.53194	929	0	0	18.434948	cylinder.usd	2025-03-29 15:49:33.027675
6227	pentagonal prism 1545	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:33.251524
6228	cube 1967	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:33.255937
6229	hexagonal prism 580	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:33.25816
6230	cylinder 1568	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:33.260409
6231	pentagonal prism 1546	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:33.483563
6232	cube 1968	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03624	cube.usd	2025-03-29 15:49:33.487993
6233	pentagonal prism 1547	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:33.490235
6234	cylinder 1569	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:33.492571
6235	pentagonal prism 1548	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:33.719972
6236	cube 1969	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.03624	cube.usd	2025-03-29 15:49:33.722422
6237	pentagonal prism 1549	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:49:33.724467
6238	cylinder 1570	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:33.726483
6239	pentagonal prism 1550	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:33.948576
6240	cube 1970	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:33.952558
6241	cuboid 576	red	{0,0,0}	32.355774	258.8462	929	0	0	37.746803	cuboid.usd	2025-03-29 15:49:33.954752
6242	cylinder 1571	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:33.956997
6243	pentagonal prism 1551	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:34.184708
6244	cube 1971	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:34.187531
6245	cube 1972	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:49:34.189679
6246	cylinder 1572	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:34.191821
6247	pentagonal prism 1552	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:34.41628
6248	cube 1973	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:49:34.420462
6249	cuboid 577	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:49:34.422617
6250	cylinder 1573	green	{0,0,0}	-270.6119	216.68562	929	0	0	38.65981	cylinder.usd	2025-03-29 15:49:34.424819
6251	pentagonal prism 1553	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:49:34.652384
6252	cube 1974	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.03625	cube.usd	2025-03-29 15:49:34.656569
6253	cylinder 1574	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	cylinder.usd	2025-03-29 15:49:34.658725
6254	cylinder 1575	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:34.660889
6255	pentagonal prism 1554	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:49:34.894566
6256	cube 1975	pink	{0,0,0}	-207.68886	346.4762	931.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:34.898553
6257	hexagonal prism 581	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:34.900803
6258	cylinder 1576	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:34.903332
6259	pentagonal prism 1555	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:35.116832
6260	cube 1976	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:49:35.119851
6261	cube 1977	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:35.122413
6262	cylinder 1577	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:35.124658
6263	pentagonal prism 1556	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:35.348066
6264	cube 1978	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:35.352572
6265	pentagonal prism 1557	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:35.354956
6266	cylinder 1578	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:35.35711
6267	pentagonal prism 1558	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:35.582571
6268	cube 1979	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:49:35.585694
6269	cuboid 578	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:35.588229
6270	cylinder 1579	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:35.590725
6271	pentagonal prism 1559	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:35.824727
6272	cube 1980	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:35.829096
6273	hexagonal prism 582	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:35.831353
6274	cylinder 1580	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:35.834031
6275	pentagonal prism 1560	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:49:36.054143
6276	cube 1981	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:49:36.057879
6277	cube 1982	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:36.060142
6278	cylinder 1581	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:36.062478
6279	pentagonal prism 1561	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:36.306601
6280	cube 1983	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:36.311004
6281	hexagonal prism 583	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:36.313324
6282	cylinder 1582	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:36.315496
6283	pentagonal prism 1562	black	{0,0,0}	-128.94427	520.6986	660	0	0	90	pentagonal prism.usd	2025-03-29 15:49:36.539802
6284	cube 1984	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:36.543832
6285	pentagonal prism 1563	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:36.546213
6286	cylinder 1583	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:36.548524
6287	pentagonal prism 1564	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:36.77624
6288	cube 1985	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:36.780587
6289	pentagonal prism 1565	red	{0,0,0}	32.355774	258.8462	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:36.782965
6290	cylinder 1584	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:36.785394
6291	pentagonal prism 1566	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:37.011517
6292	cube 1986	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:37.015728
6293	cube 1987	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:37.018006
6294	cylinder 1585	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:37.020425
6295	pentagonal prism 1567	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:37.233197
6296	cube 1988	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:37.235991
6297	cube 1989	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.69424	cube.usd	2025-03-29 15:49:37.238443
6298	cylinder 1586	green	{0,0,0}	-270.6119	216.68562	933	0	0	33.690063	cylinder.usd	2025-03-29 15:49:37.240752
6299	pentagonal prism 1568	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:37.471592
6300	cube 1990	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.534454	cube.usd	2025-03-29 15:49:37.475847
6301	cube 1991	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:49:37.478552
6302	cylinder 1587	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:37.480813
6303	pentagonal prism 1569	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:37.69961
6304	cube 1992	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.34933	cube.usd	2025-03-29 15:49:37.702363
6305	pentagonal prism 1570	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:37.704546
6306	cylinder 1588	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:37.706769
6307	pentagonal prism 1571	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:37.918795
6308	cube 1993	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:37.923186
6309	cube 1994	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:37.925423
6310	cylinder 1589	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:37.927566
6311	pentagonal prism 1572	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:38.151277
6312	cube 1995	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:38.154099
6313	cube 1996	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:38.156574
6314	cylinder 1590	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:49:38.158701
6315	pentagonal prism 1573	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:38.367996
6316	cube 1997	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:49:38.370991
6317	hexagonal prism 584	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:49:38.373995
6318	cylinder 1591	green	{0,0,0}	-272.65317	217.53194	924	0	0	45	cylinder.usd	2025-03-29 15:49:38.376436
6319	pentagonal prism 1574	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:38.599245
6320	cube 1998	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:49:38.603403
6321	pentagonal prism 1575	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:49:38.605994
6322	cylinder 1592	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:38.608263
6323	pentagonal prism 1576	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:38.81936
6324	cube 1999	pink	{0,0,0}	-205.90038	345.12823	910	0	0	59.534454	cube.usd	2025-03-29 15:49:38.822747
6325	cuboid 579	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:38.824986
6326	cylinder 1593	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:49:38.827488
6327	pentagonal prism 1577	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:39.060401
6328	cube 2000	pink	{0,0,0}	-208.67317	346.4762	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:39.062762
6329	cube 2001	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:39.064725
6330	cylinder 1594	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:39.066898
6331	pentagonal prism 1578	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:39.287359
6332	cube 2002	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:39.290198
6333	cuboid 580	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	cuboid.usd	2025-03-29 15:49:39.292591
6334	cylinder 1595	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:39.294807
6335	pentagonal prism 1579	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:39.520595
6336	cube 2003	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:49:39.524997
6337	cuboid 581	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:49:39.527584
6338	cylinder 1596	green	{0,0,0}	-270.6119	216.68562	911.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:39.529866
6339	pentagonal prism 1580	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:39.744306
6340	cube 2004	pink	{0,0,0}	-205.90038	345.12823	906	0	0	59.34933	cube.usd	2025-03-29 15:49:39.747374
6341	pentagonal prism 1581	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:49:39.749472
6342	cylinder 1597	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:39.751634
6343	pentagonal prism 1582	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:49:39.974163
6344	cube 2005	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:39.978247
6345	cuboid 582	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:39.980596
6346	cylinder 1598	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:39.982925
6347	pentagonal prism 1583	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:40.204057
6348	cube 2006	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:40.207932
6349	cube 2007	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.746803	cube.usd	2025-03-29 15:49:40.210335
6350	cylinder 1599	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:40.212656
6351	pentagonal prism 1584	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:40.444701
6352	cube 2008	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:49:40.44875
6353	cuboid 583	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:49:40.451063
6354	cylinder 1600	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:40.453437
6355	pentagonal prism 1585	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:40.678608
6356	cube 2009	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:40.681983
6357	cuboid 584	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:49:40.684357
6358	cylinder 1601	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:40.686632
6359	pentagonal prism 1586	black	{0,0,0}	-127.46696	518.69244	657	0	0	0	pentagonal prism.usd	2025-03-29 15:49:40.912512
6360	cube 2010	pink	{0,0,0}	-205.90816	345.1413	913.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:40.915661
6361	cylinder 1602	red	{0,0,0}	32.357	258.856	931.00006	0	0	37.568592	cylinder.usd	2025-03-29 15:49:40.918382
6362	cylinder 1603	green	{0,0,0}	-270.62216	216.69383	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:40.920946
6363	pentagonal prism 1587	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:41.134542
6364	cube 2011	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.620872	cube.usd	2025-03-29 15:49:41.138171
6365	cuboid 585	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:49:41.140386
6366	cylinder 1604	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:41.143037
6367	pentagonal prism 1588	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:49:41.354136
6368	cube 2012	pink	{0,0,0}	-206.88084	345.12823	922.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:41.357008
6369	cube 2013	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:49:41.359321
6370	cylinder 1605	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:41.36178
6371	pentagonal prism 1589	black	{0,0,0}	-128.9374	521.6551	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:41.598436
6372	cube 2014	pink	{0,0,0}	-207.67778	347.44196	920	0	0	59.534454	cube.usd	2025-03-29 15:49:41.6026
6373	pentagonal prism 1590	red	{0,0,0}	31.496155	260.82755	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:41.605025
6374	cylinder 1606	green	{0,0,0}	-272.6386	218.50458	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:41.607307
6375	pentagonal prism 1591	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:41.821724
6376	cube 2015	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:49:41.825119
6377	pentagonal prism 1592	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:41.827526
6378	cylinder 1607	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:41.829686
6379	pentagonal prism 1593	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:42.053788
6380	cube 2016	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:42.058022
6381	cuboid 586	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:49:42.060418
6382	cylinder 1608	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:49:42.062642
6383	pentagonal prism 1594	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:42.288941
6384	cube 2017	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.534454	cube.usd	2025-03-29 15:49:42.291889
6385	cuboid 587	red	{0,0,0}	32.355774	258.8462	920	0	0	37.69424	cuboid.usd	2025-03-29 15:49:42.294287
6386	cylinder 1609	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:42.296802
6387	pentagonal prism 1595	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:42.511942
6388	cube 2018	pink	{0,0,0}	-206.88084	345.12823	910	0	0	59.534454	cube.usd	2025-03-29 15:49:42.514794
6389	cuboid 588	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:49:42.516925
6390	cylinder 1610	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:49:42.519287
6391	pentagonal prism 1596	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:42.73633
6392	cube 2019	pink	{0,0,0}	-208.67317	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:42.740395
6393	cuboid 589	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:49:42.74286
6394	cylinder 1611	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:42.745132
6395	pentagonal prism 1597	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:42.95459
6396	cube 2020	pink	{0,0,0}	-208.67317	346.4762	929	0	0	59.34933	cube.usd	2025-03-29 15:49:42.957531
6397	hexagonal prism 585	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:42.96016
6398	cylinder 1612	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:42.963159
6399	pentagonal prism 1598	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:43.186131
6400	cube 2021	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:43.188606
6401	cuboid 590	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:43.190782
6402	cylinder 1613	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:43.194427
6403	pentagonal prism 1599	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:43.426465
6404	cube 2022	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.743565	cube.usd	2025-03-29 15:49:43.430522
6405	pentagonal prism 1600	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:43.432811
6406	cylinder 1614	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:43.435063
6407	pentagonal prism 1601	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:43.66853
6408	cube 2023	pink	{0,0,0}	-207.68886	346.4762	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:43.671316
6409	cuboid 591	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:43.673982
6410	cylinder 1615	green	{0,0,0}	-272.65317	217.53194	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:43.676411
6411	pentagonal prism 1602	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:43.891883
6412	cube 2024	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:49:43.89447
6413	cuboid 592	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:49:43.896635
6414	cylinder 1616	green	{0,0,0}	-270.6119	216.68562	941.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:43.898948
6415	pentagonal prism 1603	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:44.12528
6416	cube 2025	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.420776	cube.usd	2025-03-29 15:49:44.129802
6417	cuboid 593	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:44.132108
6418	cylinder 1617	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:44.134453
6419	pentagonal prism 1604	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:44.376856
6420	cube 2026	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.620872	cube.usd	2025-03-29 15:49:44.380913
6421	cuboid 594	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:49:44.383556
6422	cylinder 1618	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:44.385801
6423	pentagonal prism 1605	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:44.611759
6424	cube 2027	pink	{0,0,0}	-207.68886	346.4762	915	0	0	59.03625	cube.usd	2025-03-29 15:49:44.614176
6425	cube 2028	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:49:44.616383
6426	cylinder 1619	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:44.61877
6427	pentagonal prism 1606	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:49:44.843798
6428	cube 2029	pink	{0,0,0}	-206.88084	345.12823	921.00006	0	0	59.420776	cube.usd	2025-03-29 15:49:44.848032
6429	cuboid 595	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:49:44.850418
6430	cylinder 1620	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:44.852698
6431	pentagonal prism 1607	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:45.063575
6432	cube 2030	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.743565	cube.usd	2025-03-29 15:49:45.066263
6433	cuboid 596	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:49:45.068458
6434	cylinder 1621	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:49:45.070592
6435	pentagonal prism 1608	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:45.28957
6436	cube 2031	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:45.293686
6437	pentagonal prism 1609	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:49:45.296268
6438	cylinder 1622	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:49:45.298325
6439	pentagonal prism 1610	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:45.525494
6440	cube 2032	pink	{0,0,0}	-206.88084	345.12823	909.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:45.53001
6441	pentagonal prism 1611	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:45.532848
6442	cylinder 1623	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:45.53513
6443	pentagonal prism 1612	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:45.759449
6444	cube 2033	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:49:45.763588
6445	cuboid 597	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:45.766028
6446	cylinder 1624	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:49:45.768243
6447	pentagonal prism 1613	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:45.989411
6448	cube 2034	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:45.993097
6449	cube 2035	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:49:45.995555
6450	cylinder 1625	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:45.997777
6451	pentagonal prism 1614	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:46.207949
6452	cube 2036	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:49:46.2108
6453	cuboid 598	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:46.213072
6454	cylinder 1626	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:46.215258
6455	pentagonal prism 1615	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:46.440682
6456	cube 2037	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:46.443693
6457	cuboid 599	red	{0,0,0}	32.355774	258.8462	933	0	0	37.874985	cuboid.usd	2025-03-29 15:49:46.446094
6458	cylinder 1627	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:46.448403
6459	pentagonal prism 1616	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:46.688126
6460	cube 2038	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.03625	cube.usd	2025-03-29 15:49:46.69102
6461	pentagonal prism 1617	red	{0,0,0}	32.355774	258.8462	920	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:49:46.693336
6462	cylinder 1628	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:46.696161
6463	pentagonal prism 1618	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:46.908804
6464	cube 2039	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.743565	cube.usd	2025-03-29 15:49:46.912979
6465	cylinder 1629	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cylinder.usd	2025-03-29 15:49:46.916508
6466	cylinder 1630	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:46.91891
6467	pentagonal prism 1619	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:47.142822
6468	cube 2040	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:47.145608
6469	cuboid 600	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:47.148851
6470	cylinder 1631	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:49:47.15225
6471	pentagonal prism 1620	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:47.365689
6472	cube 2041	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:47.368271
6473	pentagonal prism 1621	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:47.370846
6474	cylinder 1632	green	{0,0,0}	-270.6119	216.68562	940.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:47.373872
6475	pentagonal prism 1622	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:47.601861
6476	cube 2042	pink	{0,0,0}	-205.90038	345.12823	905.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:47.604405
6477	pentagonal prism 1623	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:47.606581
6478	cylinder 1633	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:47.60898
6479	pentagonal prism 1624	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:47.852701
6480	cube 2043	pink	{0,0,0}	-208.67317	346.4762	931.00006	0	0	59.743565	cube.usd	2025-03-29 15:49:47.855439
6481	cuboid 601	red	{0,0,0}	31.497837	259.85715	933	0	0	37.568592	cuboid.usd	2025-03-29 15:49:47.857551
6482	cylinder 1634	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:47.859749
6483	pentagonal prism 1625	black	{0,0,0}	-128.94919	520.7185	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:48.089406
6484	cube 2044	pink	{0,0,0}	-207.6968	346.48944	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:48.092962
6485	cuboid 602	red	{0,0,0}	31.499039	259.86707	924	0	0	37.568592	cuboid.usd	2025-03-29 15:49:48.095287
6486	cylinder 1635	green	{0,0,0}	-272.66354	217.54024	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:48.09873
6487	pentagonal prism 1626	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:48.321215
6488	cube 2045	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:48.323767
6489	cuboid 603	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cuboid.usd	2025-03-29 15:49:48.326226
6490	cylinder 1636	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:48.329593
6491	pentagonal prism 1627	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:48.548706
6492	cube 2046	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:48.55121
6493	cuboid 604	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:49:48.553677
6494	cylinder 1637	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:48.555946
6495	pentagonal prism 1628	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:48.773749
6496	cube 2047	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:48.777582
6497	cuboid 605	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:49:48.779815
6498	cylinder 1638	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:48.782033
6499	pentagonal prism 1629	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:48.999831
6500	cube 2048	pink	{0,0,0}	-205.90038	345.12823	907.00006	0	0	59.743565	cube.usd	2025-03-29 15:49:49.002952
6501	cube 2049	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cube.usd	2025-03-29 15:49:49.005068
6502	cylinder 1639	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:49.007281
6503	pentagonal prism 1630	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:49.237872
6504	cube 2050	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:49.240511
6505	pentagonal prism 1631	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:49.242606
6506	cylinder 1640	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:49.24467
6507	pentagonal prism 1632	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:49.478539
6508	cube 2051	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.743565	cube.usd	2025-03-29 15:49:49.482848
6509	cylinder 1641	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.874985	cylinder.usd	2025-03-29 15:49:49.485096
6510	cylinder 1642	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:49.487609
6511	pentagonal prism 1633	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:49:49.736454
6512	cube 2052	pink	{0,0,0}	-207.68886	346.4762	936.00006	0	0	59.743565	cube.usd	2025-03-29 15:49:49.74034
6513	hexagonal prism 586	red	{0,0,0}	31.497837	259.85715	934	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:49.742554
6514	cylinder 1643	green	{0,0,0}	-272.65317	217.53194	920	0	0	18.434948	cylinder.usd	2025-03-29 15:49:49.744807
6515	pentagonal prism 1634	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:49.964753
6516	cube 2053	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.34933	cube.usd	2025-03-29 15:49:49.96942
6517	cube 2054	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.874985	cube.usd	2025-03-29 15:49:49.971837
6518	cylinder 1644	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:49.974054
6519	pentagonal prism 1635	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:50.221782
6520	cube 2055	pink	{0,0,0}	-208.67317	346.4762	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:50.225617
6521	cube 2056	red	{0,0,0}	31.497837	259.85715	924	0	0	37.746803	cube.usd	2025-03-29 15:49:50.227803
6522	cylinder 1645	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:50.230057
6523	pentagonal prism 1636	black	{0,0,0}	-127.462135	518.67285	652	0	0	90	pentagonal prism.usd	2025-03-29 15:49:50.468149
6524	cube 2057	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:49:50.470572
6525	cube 2058	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	cube.usd	2025-03-29 15:49:50.472747
6526	cylinder 1646	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:50.474806
6527	pentagonal prism 1637	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:50.690448
6528	cube 2059	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:50.694534
6529	pentagonal prism 1638	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:50.696875
6530	cylinder 1647	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:49:50.69971
6531	pentagonal prism 1639	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:50.923685
6532	cube 2060	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:50.927665
6533	cube 2061	red	{0,0,0}	32.355774	258.8462	924	0	0	37.746803	cube.usd	2025-03-29 15:49:50.929737
6534	cylinder 1648	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:49:50.932401
6535	pentagonal prism 1640	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:51.169198
6536	cube 2062	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:51.17311
6537	cuboid 606	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:49:51.175219
6538	cylinder 1649	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:49:51.17762
6539	pentagonal prism 1641	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:51.391103
6540	cube 2063	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:49:51.393834
6541	cube 2064	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:51.395906
6542	cylinder 1650	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:51.398032
6543	pentagonal prism 1642	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:51.623555
6544	cube 2065	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:51.62617
6545	cuboid 607	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:49:51.628211
6546	cylinder 1651	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:51.6304
6547	pentagonal prism 1643	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:51.849954
6548	cube 2066	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:49:51.852403
6549	cube 2067	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:49:51.85457
6550	cylinder 1652	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:51.857177
6551	pentagonal prism 1644	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:52.081388
6552	cube 2068	pink	{0,0,0}	-205.90816	345.1413	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:52.085945
6553	cube 2069	red	{0,0,0}	32.357	258.856	920	0	0	37.568592	cube.usd	2025-03-29 15:49:52.088455
6554	cylinder 1653	green	{0,0,0}	-270.62216	216.69383	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:52.090784
6555	pentagonal prism 1645	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:52.313011
6556	cube 2070	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:52.316225
6557	hexagonal prism 587	red	{0,0,0}	32.355774	258.8462	915	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:49:52.318696
6558	cylinder 1654	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:52.320994
6559	pentagonal prism 1646	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:52.543323
6560	cube 2071	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 15:49:52.54633
6561	cube 2072	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:49:52.54897
6562	cylinder 1655	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:52.551339
6563	pentagonal prism 1647	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:52.763531
6564	cube 2073	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:52.766696
6565	cuboid 608	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:52.769516
6566	cylinder 1656	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:52.771905
6567	pentagonal prism 1648	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:53.002061
6568	cube 2074	pink	{0,0,0}	-206.88084	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:53.005655
6569	cuboid 609	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cuboid.usd	2025-03-29 15:49:53.00881
6570	cylinder 1657	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:53.011834
6571	pentagonal prism 1649	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:53.229197
6572	cube 2075	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:49:53.232332
6573	cube 2076	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:53.234724
6574	cylinder 1658	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:53.237017
6575	pentagonal prism 1650	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:53.464969
6576	cube 2077	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.534454	cube.usd	2025-03-29 15:49:53.467694
6577	cuboid 610	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	cuboid.usd	2025-03-29 15:49:53.469909
6578	cylinder 1659	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:49:53.472069
6579	pentagonal prism 1651	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:53.702153
6580	cube 2078	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:49:53.704848
6581	hexagonal prism 588	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:53.707087
6582	cylinder 1660	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:53.709165
6583	pentagonal prism 1652	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:53.930455
6584	cube 2079	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:53.933291
6585	cube 2080	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:49:53.9357
6586	cylinder 1661	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:53.937833
6587	pentagonal prism 1653	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:54.173641
6588	cube 2081	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:54.176342
6589	pentagonal prism 1654	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:54.178811
6590	cylinder 1662	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:54.181244
6591	pentagonal prism 1655	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:54.428693
6592	cube 2082	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	60.01836	cube.usd	2025-03-29 15:49:54.432682
6593	cube 2083	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:54.435307
6594	cylinder 1663	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:49:54.437519
6595	pentagonal prism 1656	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:54.665261
6596	cube 2084	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:54.668302
6597	pentagonal prism 1657	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:54.670555
6598	cylinder 1664	green	{0,0,0}	-272.65317	217.53194	929	0	0	18.434948	cylinder.usd	2025-03-29 15:49:54.672848
6599	pentagonal prism 1658	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:54.893433
6600	cube 2085	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.743565	cube.usd	2025-03-29 15:49:54.896227
6601	pentagonal prism 1659	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:49:54.898774
6602	cylinder 1665	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:54.9014
6603	pentagonal prism 1660	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:55.143114
6604	cube 2086	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.743565	cube.usd	2025-03-29 15:49:55.147418
6605	cuboid 611	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cuboid.usd	2025-03-29 15:49:55.149938
6606	cylinder 1666	green	{0,0,0}	-272.65317	217.53194	924	0	0	36.869896	cylinder.usd	2025-03-29 15:49:55.152649
6607	pentagonal prism 1661	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:55.373771
6608	cube 2087	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:55.376292
6609	pentagonal prism 1662	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:55.378353
6610	cylinder 1667	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:55.380508
6611	pentagonal prism 1663	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:49:55.642855
6612	cube 2088	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.62088	cube.usd	2025-03-29 15:49:55.645354
6613	pentagonal prism 1664	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:55.647499
6614	cylinder 1668	green	{0,0,0}	-272.65317	217.53194	915	0	0	26.56505	cylinder.usd	2025-03-29 15:49:55.649628
6615	pentagonal prism 1665	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:55.864285
6616	cube 2089	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:49:55.867486
6617	cuboid 612	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:55.870118
6618	cylinder 1669	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:55.872628
6619	pentagonal prism 1666	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:56.097117
6620	cube 2090	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:56.101337
6621	cube 2091	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:49:56.103877
6622	cylinder 1670	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:49:56.106147
6623	pentagonal prism 1667	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:56.332497
6624	cube 2092	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:49:56.33685
6625	cube 2093	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:56.339102
6626	cylinder 1671	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:56.341495
6627	pentagonal prism 1668	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:56.564929
6628	cube 2094	pink	{0,0,0}	-205.90038	345.12823	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:49:56.568631
6629	pentagonal prism 1669	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:56.571093
6630	cylinder 1672	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:56.57336
6631	pentagonal prism 1670	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:56.804305
6632	cube 2095	pink	{0,0,0}	-205.90038	345.12823	910	0	0	59.03624	cube.usd	2025-03-29 15:49:56.807205
6633	pentagonal prism 1671	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:49:56.809312
6634	cylinder 1673	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:49:56.811469
6635	pentagonal prism 1672	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:49:57.034947
6636	cube 2096	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:49:57.039391
6637	cuboid 613	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:57.041653
6638	cylinder 1674	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:57.04378
6639	pentagonal prism 1673	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:49:57.267325
6640	cube 2097	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.03624	cube.usd	2025-03-29 15:49:57.270038
6641	cube 2098	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:49:57.272716
6642	cylinder 1675	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:57.275064
6643	pentagonal prism 1674	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:57.487502
6644	cube 2099	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:57.491026
6645	pentagonal prism 1675	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:57.493421
6646	cylinder 1676	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:57.495776
6647	pentagonal prism 1676	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:49:57.71789
6648	cube 2100	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:57.72225
6649	pentagonal prism 1677	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:49:57.724392
6650	cylinder 1677	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:57.726838
6651	pentagonal prism 1678	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:57.956622
6652	cube 2101	pink	{0,0,0}	-207.68886	346.4762	931.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:57.96071
6653	hexagonal prism 589	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:49:57.962916
6654	cylinder 1678	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:57.965264
6655	pentagonal prism 1679	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:58.186772
6656	cube 2102	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:58.191242
6657	cube 2103	red	{0,0,0}	31.497837	259.85715	933	0	0	37.568592	cube.usd	2025-03-29 15:49:58.194021
6658	cylinder 1679	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:58.196444
6659	pentagonal prism 1680	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:49:58.409017
6660	cube 2104	pink	{0,0,0}	-208.67317	346.4762	913.00006	0	0	59.34933	cube.usd	2025-03-29 15:49:58.412024
6661	cube 2105	red	{0,0,0}	31.497837	259.85715	924	0	0	37.69424	cube.usd	2025-03-29 15:49:58.41458
6662	cylinder 1680	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:58.416827
6663	pentagonal prism 1681	black	{0,0,0}	-127.45538	519.6258	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:58.634652
6664	cube 2106	pink	{0,0,0}	-205.88947	346.0904	933	0	0	59.34933	cube.usd	2025-03-29 15:49:58.637454
6665	pentagonal prism 1682	red	{0,0,0}	32.354057	259.8129	931.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:58.640032
6666	cylinder 1681	green	{0,0,0}	-270.59756	217.65457	920	0	0	26.56505	cylinder.usd	2025-03-29 15:49:58.642202
6667	pentagonal prism 1683	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:58.879537
6668	cube 2107	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.620872	cube.usd	2025-03-29 15:49:58.882297
6669	pentagonal prism 1684	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:58.884512
6670	cylinder 1682	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:58.886906
6671	pentagonal prism 1685	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:49:59.098395
6672	cube 2108	pink	{0,0,0}	-207.68886	346.4762	931.00006	0	0	59.03625	cube.usd	2025-03-29 15:49:59.102722
6673	pentagonal prism 1686	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:59.105407
6674	cylinder 1683	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:49:59.10767
6675	pentagonal prism 1687	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:59.334868
6676	cube 2109	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:49:59.339145
6677	cube 2110	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:49:59.34208
6678	cylinder 1684	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:59.344477
6679	pentagonal prism 1688	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:59.561201
6680	cube 2111	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03625	cube.usd	2025-03-29 15:49:59.564276
6681	pentagonal prism 1689	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:49:59.566574
6682	cylinder 1685	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:49:59.568954
6683	pentagonal prism 1690	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:49:59.783314
6684	cube 2112	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:49:59.787149
6685	cuboid 614	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:49:59.789534
6686	cylinder 1686	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:49:59.79185
6687	pentagonal prism 1691	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:00.005
6688	cube 2113	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:50:00.008462
6689	cuboid 615	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:50:00.0108
6690	cylinder 1687	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:00.013311
6691	pentagonal prism 1692	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:50:00.234148
6692	cube 2114	pink	{0,0,0}	-205.90038	345.12823	937.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:00.238231
6693	hexagonal prism 590	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:00.24083
6694	cylinder 1688	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:50:00.243341
6695	pentagonal prism 1693	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:00.474873
6696	cube 2115	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:00.479021
6697	cube 2116	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:50:00.481242
6698	cylinder 1689	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:50:00.483397
6699	pentagonal prism 1694	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:00.703495
6700	cube 2117	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:00.708054
6701	cube 2118	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	37.746803	cube.usd	2025-03-29 15:50:00.710458
6702	cylinder 1690	green	{0,0,0}	-270.6119	216.68562	920	0	0	18.434948	cylinder.usd	2025-03-29 15:50:00.712785
6703	pentagonal prism 1695	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:00.937262
6704	cube 2119	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.743565	cube.usd	2025-03-29 15:50:00.941604
6705	cuboid 616	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:00.944295
6706	cylinder 1691	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:00.946499
6707	pentagonal prism 1696	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:01.171918
6708	cube 2120	pink	{0,0,0}	-206.88084	345.12823	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:01.176272
6709	cuboid 617	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:50:01.178508
6710	cylinder 1692	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:01.180693
6711	pentagonal prism 1697	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:01.403298
6712	cube 2121	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:50:01.406205
6713	hexagonal prism 591	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:01.40864
6714	cylinder 1693	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:01.410962
6715	pentagonal prism 1698	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:01.635453
6716	cube 2122	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:50:01.63965
6717	pentagonal prism 1699	red	{0,0,0}	32.355774	258.8462	924	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:50:01.642129
6718	cylinder 1694	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:50:01.644307
6719	pentagonal prism 1700	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:01.867628
6720	cube 2123	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:50:01.870511
6721	cube 2124	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cube.usd	2025-03-29 15:50:01.872591
6722	cylinder 1695	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:01.875149
6723	pentagonal prism 1701	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:02.08641
6724	cube 2125	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.743565	cube.usd	2025-03-29 15:50:02.089383
6725	pentagonal prism 1702	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:50:02.092034
6726	cylinder 1696	green	{0,0,0}	-270.6119	216.68562	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:02.094262
6727	pentagonal prism 1703	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:02.32595
6728	cube 2126	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:02.328819
6729	hexagonal prism 592	red	{0,0,0}	32.355774	258.8462	924	0	0	37.746803	hexagonal prism.usd	2025-03-29 15:50:02.331284
6730	cylinder 1697	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:50:02.333625
6731	pentagonal prism 1704	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:02.555605
6732	cube 2127	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:50:02.559738
6733	pentagonal prism 1705	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:50:02.562623
6734	cylinder 1698	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:02.564894
6735	pentagonal prism 1706	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:02.790024
6736	cube 2128	pink	{0,0,0}	-205.90038	345.12823	908.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:02.793096
6737	cube 2129	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:50:02.795428
6738	cylinder 1699	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:02.797813
6739	pentagonal prism 1707	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:50:03.011661
6740	cube 2130	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:03.014955
6741	cuboid 618	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:50:03.017166
6742	cylinder 1700	green	{0,0,0}	-270.6119	216.68562	913.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:03.019431
6743	pentagonal prism 1708	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:03.240227
6744	cube 2131	pink	{0,0,0}	-208.67317	346.4762	910	0	0	59.03625	cube.usd	2025-03-29 15:50:03.243033
6745	cuboid 619	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:03.245633
6746	cylinder 1701	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:50:03.24787
6747	pentagonal prism 1709	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:03.471818
6748	cube 2132	pink	{0,0,0}	-206.88084	345.12823	930.00006	0	0	59.03624	cube.usd	2025-03-29 15:50:03.475835
6749	pentagonal prism 1710	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:03.478105
6750	cylinder 1702	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:50:03.480396
6751	pentagonal prism 1711	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:50:03.705287
6752	cube 2133	pink	{0,0,0}	-208.67317	346.4762	911.00006	0	0	59.743565	cube.usd	2025-03-29 15:50:03.709592
6753	cuboid 620	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:03.712142
6754	cylinder 1703	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:50:03.714293
6755	pentagonal prism 1712	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:03.950208
6756	cube 2134	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.420776	cube.usd	2025-03-29 15:50:03.952632
6757	cube 2135	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:03.954588
6758	cylinder 1704	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:03.95655
6759	pentagonal prism 1713	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:04.170585
6760	cube 2136	pink	{0,0,0}	-206.88084	345.12823	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:04.173563
6761	cuboid 621	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:04.176059
6762	cylinder 1705	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:04.1783
6763	pentagonal prism 1714	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:04.389795
6764	cube 2137	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:04.393277
6765	cube 2138	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:04.395792
6766	cylinder 1706	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:04.398401
6767	pentagonal prism 1715	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:04.633253
6768	cube 2139	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:04.63758
6769	cube 2140	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:04.640046
6770	cylinder 1707	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:50:04.642622
6771	pentagonal prism 1716	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:04.858845
6772	cube 2141	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.420776	cube.usd	2025-03-29 15:50:04.863546
6773	hexagonal prism 593	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:04.866081
6774	cylinder 1708	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:04.868423
6775	pentagonal prism 1717	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:50:05.100061
6776	cube 2142	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:05.103986
6777	hexagonal prism 594	red	{0,0,0}	32.355774	258.8462	933	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:50:05.106004
6778	cylinder 1709	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:50:05.108074
6779	pentagonal prism 1718	black	{0,0,0}	-128.94427	520.6986	660	0	0	90	pentagonal prism.usd	2025-03-29 15:50:05.334096
6780	cube 2143	pink	{0,0,0}	-208.67317	346.4762	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:05.337141
6781	pentagonal prism 1719	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:05.339325
6782	cylinder 1710	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:05.341595
6783	pentagonal prism 1720	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:05.554414
6784	cube 2144	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:05.557583
6785	cuboid 622	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:05.55973
6786	cylinder 1711	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:05.562145
6787	pentagonal prism 1721	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:50:05.788568
6788	cube 2145	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:50:05.793165
6789	pentagonal prism 1722	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:05.795695
6790	cylinder 1712	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:05.797816
6791	pentagonal prism 1723	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:06.023472
6792	cube 2146	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:06.027768
6793	pentagonal prism 1724	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:50:06.030465
6794	cylinder 1713	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:06.033379
6795	pentagonal prism 1725	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:06.257414
6796	cube 2147	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:50:06.261867
6797	cuboid 623	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:06.264322
6798	cylinder 1714	green	{0,0,0}	-270.6119	216.68562	915	0	0	26.56505	cylinder.usd	2025-03-29 15:50:06.266744
6799	pentagonal prism 1726	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:06.479106
6800	cube 2148	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:06.482276
6801	cube 2149	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.746803	cube.usd	2025-03-29 15:50:06.484435
6802	cylinder 1715	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:06.486761
6803	pentagonal prism 1727	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:06.701273
6804	cube 2150	pink	{0,0,0}	-205.90038	345.12823	906	0	0	59.534454	cube.usd	2025-03-29 15:50:06.706454
6805	pentagonal prism 1728	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:06.708968
6806	cylinder 1716	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:06.711422
6807	pentagonal prism 1729	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:06.926152
6808	cube 2151	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.620872	cube.usd	2025-03-29 15:50:06.929357
6809	cube 2152	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:06.932144
6810	cylinder 1717	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:06.934635
6811	pentagonal prism 1730	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:07.152978
6812	cube 2153	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:07.155913
6813	cuboid 624	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:50:07.158127
6814	cylinder 1718	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:07.160294
6815	pentagonal prism 1731	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:07.398839
6816	cube 2154	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:07.402869
6817	pentagonal prism 1732	red	{0,0,0}	32.355774	258.8462	919	0	0	37.746803	pentagonal prism.usd	2025-03-29 15:50:07.404898
6818	cylinder 1719	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:07.406999
6819	pentagonal prism 1733	black	{0,0,0}	-128.94427	520.6986	657	0	0	0	pentagonal prism.usd	2025-03-29 15:50:07.635521
6820	cube 2155	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:07.639566
6821	cuboid 625	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:07.641873
6822	cylinder 1720	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	19.983105	cylinder.usd	2025-03-29 15:50:07.644055
6823	pentagonal prism 1734	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:07.858421
6824	cube 2156	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:07.862735
6825	pentagonal prism 1735	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:50:07.865215
6826	cylinder 1721	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:50:07.867627
6827	pentagonal prism 1736	black	{0,0,0}	-128.94919	520.7185	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:08.110067
6828	cube 2157	pink	{0,0,0}	-207.6968	346.48944	916.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:08.115097
6829	pentagonal prism 1737	red	{0,0,0}	31.499039	259.86707	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:08.118567
6830	cylinder 1722	green	{0,0,0}	-272.66354	217.54024	919	0	0	26.56505	cylinder.usd	2025-03-29 15:50:08.121915
6831	pentagonal prism 1738	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:08.341014
6832	cube 2158	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03624	cube.usd	2025-03-29 15:50:08.343814
6833	cuboid 626	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:08.346561
6834	cylinder 1723	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:08.3495
6835	pentagonal prism 1739	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:08.589839
6836	cube 2159	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:08.594028
6837	cuboid 627	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cuboid.usd	2025-03-29 15:50:08.596797
6838	cylinder 1724	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:50:08.599107
6839	pentagonal prism 1740	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:08.819737
6840	cube 2160	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:50:08.822467
6841	cube 2161	red	{0,0,0}	31.497837	259.85715	936.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:08.824783
6842	cylinder 1725	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:08.82717
6843	pentagonal prism 1741	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:09.041091
6844	cube 2162	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:50:09.044735
6845	cube 2163	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:09.047102
6846	cylinder 1726	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:09.049297
6847	pentagonal prism 1742	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:09.2616
6848	cube 2164	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:50:09.264589
6849	pentagonal prism 1743	red	{0,0,0}	32.355774	258.8462	934	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:09.267252
6850	cylinder 1727	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:09.269704
6851	pentagonal prism 1744	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:09.501845
6852	cube 2165	pink	{0,0,0}	-208.67317	346.4762	907.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:09.505589
6853	pentagonal prism 1745	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:09.507722
6854	cylinder 1728	green	{0,0,0}	-272.65317	217.53194	919	0	0	33.690063	cylinder.usd	2025-03-29 15:50:09.510139
6855	pentagonal prism 1746	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:09.731271
6856	cube 2166	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.620872	cube.usd	2025-03-29 15:50:09.73537
6857	hexagonal prism 595	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:09.737582
6858	cylinder 1729	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:09.739654
6859	pentagonal prism 1747	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:09.970971
6860	cube 2167	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:09.975186
6861	cube 2168	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:50:09.977616
6862	cylinder 1730	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:09.97987
6863	pentagonal prism 1748	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:10.205494
6864	cube 2169	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:50:10.209557
6865	cuboid 628	red	{0,0,0}	31.497837	259.85715	931.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:10.211806
6866	cylinder 1731	green	{0,0,0}	-272.65317	217.53194	929	0	0	18.434948	cylinder.usd	2025-03-29 15:50:10.214309
6867	pentagonal prism 1749	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:10.431981
6868	cube 2170	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:10.436584
6869	pentagonal prism 1750	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:10.439727
6870	cylinder 1732	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:10.442747
6871	pentagonal prism 1751	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:10.667414
6872	cube 2171	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 15:50:10.671545
6873	cuboid 629	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:50:10.673819
6874	cylinder 1733	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:10.676069
6875	pentagonal prism 1752	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:10.913262
6876	cube 2172	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.620872	cube.usd	2025-03-29 15:50:10.916232
6877	hexagonal prism 596	red	{0,0,0}	31.497837	259.85715	911.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:50:10.918488
6878	cylinder 1734	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:10.920701
6879	pentagonal prism 1753	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:11.144771
6880	cube 2173	pink	{0,0,0}	-205.90038	345.12823	907.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:11.149254
6881	pentagonal prism 1754	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 15:50:11.151781
6882	cylinder 1735	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:11.153917
6883	pentagonal prism 1755	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:11.394955
6884	cube 2174	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:50:11.398185
6885	cube 2175	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	cube.usd	2025-03-29 15:50:11.400967
6886	cylinder 1736	green	{0,0,0}	-270.6119	216.68562	913.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:11.403491
6887	pentagonal prism 1756	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:11.631029
6888	cube 2176	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:11.635168
6889	hexagonal prism 597	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:11.638758
6890	cylinder 1737	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:50:11.64223
6891	pentagonal prism 1757	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:11.899141
6892	cube 2177	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:50:11.903652
6893	cuboid 630	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.69424	cuboid.usd	2025-03-29 15:50:11.906199
6894	cylinder 1738	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:11.908658
6895	pentagonal prism 1758	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:12.128577
6896	cube 2178	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:12.131478
6897	cuboid 631	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:12.134594
6898	cylinder 1739	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:12.137345
6899	pentagonal prism 1759	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:50:12.367749
6900	cube 2179	pink	{0,0,0}	-208.67317	346.4762	929	0	0	59.03625	cube.usd	2025-03-29 15:50:12.370907
6901	pentagonal prism 1760	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:12.373307
6902	cylinder 1740	green	{0,0,0}	-272.65317	217.53194	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:50:12.375607
6903	pentagonal prism 1761	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:12.595962
6904	cube 2180	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.34933	cube.usd	2025-03-29 15:50:12.600462
6905	cuboid 632	red	{0,0,0}	32.355774	258.8462	924	0	0	37.874985	cuboid.usd	2025-03-29 15:50:12.603154
6906	cylinder 1741	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	45	cylinder.usd	2025-03-29 15:50:12.605622
6907	pentagonal prism 1762	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:12.829014
6908	cube 2181	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:12.832107
6909	cube 2182	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:50:12.834796
6910	cylinder 1742	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:12.837228
6911	pentagonal prism 1763	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:13.074343
6912	cube 2183	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:50:13.078396
6913	cube 2184	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cube.usd	2025-03-29 15:50:13.080735
6914	cylinder 1743	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690067	cylinder.usd	2025-03-29 15:50:13.083411
6915	pentagonal prism 1764	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:13.304181
6916	cube 2185	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:50:13.306898
6917	cuboid 633	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:50:13.308932
6918	cylinder 1744	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:13.311022
6919	pentagonal prism 1765	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:13.529569
6920	cube 2186	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03624	cube.usd	2025-03-29 15:50:13.533696
6921	cube 2187	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.405357	cube.usd	2025-03-29 15:50:13.536028
6922	cylinder 1745	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:13.538436
6923	pentagonal prism 1766	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:13.769695
6924	cube 2188	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:13.772853
6925	cylinder 1746	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cylinder.usd	2025-03-29 15:50:13.775079
6926	cylinder 1747	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:13.777248
6927	pentagonal prism 1767	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:13.996273
6928	cube 2189	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:13.999295
6929	cuboid 634	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:50:14.002069
6930	cylinder 1748	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:50:14.004643
6931	pentagonal prism 1768	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:14.238559
6932	cube 2190	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:14.241683
6933	pentagonal prism 1769	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:14.243819
6934	cylinder 1749	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:50:14.246108
6935	pentagonal prism 1770	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:50:14.462659
6936	cube 2191	pink	{0,0,0}	-205.90038	345.12823	915	0	0	59.34933	cube.usd	2025-03-29 15:50:14.466496
6937	cube 2192	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:14.469476
6938	cylinder 1750	green	{0,0,0}	-270.6119	216.68562	919	0	0	33.690063	cylinder.usd	2025-03-29 15:50:14.472076
6939	pentagonal prism 1771	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:14.702462
6940	cube 2193	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:14.706509
6941	cuboid 635	red	{0,0,0}	32.355774	258.8462	920	0	0	37.746803	cuboid.usd	2025-03-29 15:50:14.708698
6942	cylinder 1751	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:14.711096
6943	pentagonal prism 1772	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:14.955332
6944	cube 2194	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:14.959622
6945	cuboid 636	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:14.962249
6946	cylinder 1752	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:14.964763
6947	pentagonal prism 1773	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:15.183469
6948	cube 2195	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:50:15.186792
6949	cube 2196	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:15.189033
6950	cylinder 1753	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:15.19109
6951	pentagonal prism 1774	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:15.412316
6952	cube 2197	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:50:15.416319
6953	pentagonal prism 1775	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:15.419719
6954	cylinder 1754	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:15.422158
6955	pentagonal prism 1776	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:15.649966
6956	cube 2198	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:50:15.654509
6957	cube 2199	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	cube.usd	2025-03-29 15:50:15.656973
6958	cylinder 1755	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	35.537674	cylinder.usd	2025-03-29 15:50:15.659209
6959	pentagonal prism 1777	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:50:15.879819
6960	cube 2200	pink	{0,0,0}	-206.88084	345.12823	933	0	0	59.534454	cube.usd	2025-03-29 15:50:15.884022
6961	cuboid 637	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:15.886658
6962	cylinder 1756	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:15.889077
6963	pentagonal prism 1778	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:16.100756
6964	cube 2201	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:16.104196
6965	cylinder 1757	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	cylinder.usd	2025-03-29 15:50:16.106695
6966	cylinder 1758	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:16.109007
6967	pentagonal prism 1779	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:16.332851
6968	cube 2202	pink	{0,0,0}	-206.88084	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:16.336017
6969	pentagonal prism 1780	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:16.338805
6970	cylinder 1759	green	{0,0,0}	-270.6119	216.68562	919	0	0	18.434948	cylinder.usd	2025-03-29 15:50:16.341078
6971	pentagonal prism 1781	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:16.568815
6972	cube 2203	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:16.573404
6973	pentagonal prism 1782	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:50:16.57622
6974	cylinder 1760	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:16.579471
6975	pentagonal prism 1783	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:16.818746
6976	cube 2204	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:50:16.823074
6977	cuboid 638	red	{0,0,0}	31.497837	259.85715	934	0	0	37.69424	cuboid.usd	2025-03-29 15:50:16.825477
6978	cylinder 1761	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:16.827827
6979	pentagonal prism 1784	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:17.064528
6980	cube 2205	pink	{0,0,0}	-205.90038	345.12823	938	0	0	59.03625	cube.usd	2025-03-29 15:50:17.069046
6981	pentagonal prism 1785	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:17.071314
6982	cylinder 1762	green	{0,0,0}	-270.6119	216.68562	919	0	0	33.690063	cylinder.usd	2025-03-29 15:50:17.073717
6983	pentagonal prism 1786	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:17.300388
6984	cube 2206	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.93142	cube.usd	2025-03-29 15:50:17.304597
6985	cuboid 639	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:17.306944
6986	cylinder 1763	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:17.309428
6987	pentagonal prism 1787	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:17.546382
6988	cube 2207	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:17.550664
6989	cuboid 640	red	{0,0,0}	32.355774	258.8462	931.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:50:17.553498
6990	cylinder 1764	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:17.556093
6991	pentagonal prism 1788	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:17.811851
6992	cube 2208	pink	{0,0,0}	-207.68886	346.4762	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:17.815892
6993	cuboid 641	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:50:17.818672
6994	cylinder 1765	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:17.821616
6995	pentagonal prism 1789	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:18.040881
6996	cube 2209	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:50:18.044096
6997	cuboid 642	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:50:18.046395
6998	cylinder 1766	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:18.048468
6999	pentagonal prism 1790	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:18.26196
7000	cube 2210	pink	{0,0,0}	-205.90038	345.12823	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:18.264578
7001	pentagonal prism 1791	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:18.266677
7002	cylinder 1767	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:18.268911
7003	pentagonal prism 1792	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:18.494714
7004	cube 2211	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:50:18.498664
7005	pentagonal prism 1793	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:18.500935
7006	cylinder 1768	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:18.503341
7007	pentagonal prism 1794	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:50:18.72713
7008	cube 2212	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:18.73116
7009	cube 2213	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:18.733463
7010	cylinder 1769	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:18.735748
7011	pentagonal prism 1795	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:18.96733
7012	cube 2214	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:18.971527
7013	cuboid 643	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:50:18.974466
7014	cylinder 1770	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:50:18.976961
7015	pentagonal prism 1796	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:19.201481
7016	cube 2215	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:19.204506
7017	cylinder 1771	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cylinder.usd	2025-03-29 15:50:19.207147
7018	cylinder 1772	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:19.209533
7019	pentagonal prism 1797	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:50:19.427078
7020	cube 2216	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:19.431008
7021	cuboid 644	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:50:19.433165
7022	cylinder 1773	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:19.435374
7023	pentagonal prism 1798	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:19.652455
7024	cube 2217	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:19.657272
7025	pentagonal prism 1799	red	{0,0,0}	31.497837	259.85715	927.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:19.659557
7026	cylinder 1774	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:50:19.661981
7027	pentagonal prism 1800	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:19.876245
7028	cube 2218	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.743565	cube.usd	2025-03-29 15:50:19.879154
7029	pentagonal prism 1801	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:19.881312
7030	cylinder 1775	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:19.883425
7031	pentagonal prism 1802	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:20.101112
7032	cube 2219	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:20.105651
7033	cuboid 645	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:50:20.108397
7034	cylinder 1776	green	{0,0,0}	-272.65317	217.53194	929	0	0	33.690063	cylinder.usd	2025-03-29 15:50:20.11063
7035	pentagonal prism 1803	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:20.332355
7036	cube 2220	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:20.335427
7037	pentagonal prism 1804	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:20.33791
7038	cylinder 1777	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:20.340822
7039	pentagonal prism 1805	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:20.558322
7040	cube 2221	pink	{0,0,0}	-206.88084	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:20.560995
7041	hexagonal prism 598	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:20.563193
7042	cylinder 1778	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:50:20.565516
7043	pentagonal prism 1806	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:20.789094
7044	cube 2222	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:50:20.793051
7045	cuboid 646	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:20.795156
7046	cylinder 1779	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:20.797209
7047	pentagonal prism 1807	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:21.02667
7048	cube 2223	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:21.030709
7049	cuboid 647	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:50:21.032892
7050	cylinder 1780	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:21.03545
7051	pentagonal prism 1808	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:21.250987
7052	cube 2224	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:21.255108
7053	cube 2225	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:21.257594
7054	cylinder 1781	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:21.259744
7055	pentagonal prism 1809	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:21.492171
7056	cube 2226	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.534454	cube.usd	2025-03-29 15:50:21.496615
7057	cuboid 648	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:21.499137
7058	cylinder 1782	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:21.501628
7059	pentagonal prism 1810	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:21.716493
7060	cube 2227	pink	{0,0,0}	-205.90038	345.12823	912.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:21.720521
7061	cube 2228	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:21.723202
7062	cylinder 1783	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:21.725626
7063	pentagonal prism 1811	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:21.958407
7064	cube 2229	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:21.961618
7065	cuboid 649	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:50:21.963941
7066	cylinder 1784	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:50:21.966206
7067	pentagonal prism 1812	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:22.181282
7068	cube 2230	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:50:22.185383
7069	cuboid 650	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:22.187713
7070	cylinder 1785	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:22.190621
7071	pentagonal prism 1813	black	{0,0,0}	-128.94427	520.6986	660	0	0	90	pentagonal prism.usd	2025-03-29 15:50:22.404756
7072	cube 2231	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:22.408742
7073	hexagonal prism 599	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:22.411412
7074	cylinder 1786	green	{0,0,0}	-272.65317	217.53194	919	0	0	26.56505	cylinder.usd	2025-03-29 15:50:22.41372
7075	pentagonal prism 1814	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:22.639359
7076	cube 2232	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:22.643829
7077	cuboid 651	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:22.646646
7078	cylinder 1787	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:22.648982
7079	pentagonal prism 1815	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:22.871105
7080	cube 2233	pink	{0,0,0}	-206.88084	345.12823	940.00006	0	0	59.743565	cube.usd	2025-03-29 15:50:22.875216
7081	cuboid 652	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:22.878072
7082	cylinder 1788	green	{0,0,0}	-270.6119	216.68562	937.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:22.880662
7083	pentagonal prism 1816	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:23.117383
7084	cube 2234	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.534454	cube.usd	2025-03-29 15:50:23.121428
7085	cuboid 653	red	{0,0,0}	31.497837	259.85715	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:23.123601
7086	cylinder 1789	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:23.126333
7087	pentagonal prism 1817	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:23.344762
7088	cube 2235	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:23.347361
7089	cube 2236	red	{0,0,0}	31.497837	259.85715	915	0	0	37.568592	cube.usd	2025-03-29 15:50:23.349537
7090	cylinder 1790	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:23.351797
7091	pentagonal prism 1818	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:23.604743
7092	cube 2237	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:23.609239
7093	pentagonal prism 1819	red	{0,0,0}	32.355774	258.8462	935.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:23.61212
7094	cylinder 1791	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:23.614473
7095	pentagonal prism 1820	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:23.840677
7096	cube 2238	pink	{0,0,0}	-207.68886	346.4762	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:23.84487
7097	cube 2239	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cube.usd	2025-03-29 15:50:23.847072
7098	cylinder 1792	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:50:23.849194
7099	pentagonal prism 1821	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:24.071749
7100	cube 2240	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:24.074854
7101	cube 2241	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cube.usd	2025-03-29 15:50:24.078063
7102	cylinder 1793	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:24.080839
7103	pentagonal prism 1822	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:50:24.308441
7104	cube 2242	pink	{0,0,0}	-205.90038	345.12823	906	0	0	59.03624	cube.usd	2025-03-29 15:50:24.311325
7105	pentagonal prism 1823	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:24.313565
7106	cylinder 1794	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:24.316108
7107	pentagonal prism 1824	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:50:24.538384
7108	cube 2243	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:50:24.541347
7109	pentagonal prism 1825	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:24.543829
7110	cylinder 1795	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:24.546183
7111	pentagonal prism 1826	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:24.795244
7112	cube 2244	pink	{0,0,0}	-207.68886	346.4762	913.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:24.79979
7113	cube 2245	red	{0,0,0}	31.497837	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:24.802768
7114	cylinder 1796	green	{0,0,0}	-272.65317	217.53194	915	0	0	26.56505	cylinder.usd	2025-03-29 15:50:24.805024
7115	pentagonal prism 1827	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:25.028798
7116	cube 2246	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:50:25.032969
7117	cube 2247	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	cube.usd	2025-03-29 15:50:25.035811
7118	cylinder 1797	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:25.038105
7119	pentagonal prism 1828	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:50:25.265534
7120	cube 2248	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:50:25.269535
7121	cuboid 654	red	{0,0,0}	31.497837	259.85715	912.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:25.271751
7122	cylinder 1798	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:25.273985
7123	pentagonal prism 1829	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:25.492226
7124	cube 2249	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:50:25.49678
7125	pentagonal prism 1830	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:25.499316
7126	cylinder 1799	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:25.501802
7127	pentagonal prism 1831	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:25.740205
7128	cube 2250	pink	{0,0,0}	-206.88084	345.12823	929	0	0	59.743565	cube.usd	2025-03-29 15:50:25.743242
7129	cuboid 655	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:25.745714
7130	cylinder 1800	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:25.747863
7131	pentagonal prism 1832	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:25.962691
7132	cube 2251	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:50:25.965239
7133	cuboid 656	red	{0,0,0}	31.497837	259.85715	932.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:25.967448
7134	cylinder 1801	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:25.969667
7135	pentagonal prism 1833	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:26.187412
7136	cube 2252	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:50:26.190273
7137	cuboid 657	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:50:26.19277
7138	cylinder 1802	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:26.195271
7139	pentagonal prism 1834	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:26.407834
7140	cube 2253	pink	{0,0,0}	-206.70456	346.4762	934	0	0	59.534454	cube.usd	2025-03-29 15:50:26.411255
7141	hexagonal prism 600	red	{0,0,0}	32.482143	259.85715	925.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:26.414051
7142	cylinder 1803	green	{0,0,0}	-271.66885	217.53194	922.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:50:26.416906
7143	pentagonal prism 1835	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:26.640213
7144	cube 2254	pink	{0,0,0}	-205.90038	345.12823	931.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:26.64446
7145	cube 2255	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:26.647156
7146	cylinder 1804	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:26.649537
7147	pentagonal prism 1836	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:26.878406
7148	cube 2256	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:50:26.882555
7149	pentagonal prism 1837	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:26.884697
7150	cylinder 1805	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:26.886922
7151	pentagonal prism 1838	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:27.110378
7152	cube 2257	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.03625	cube.usd	2025-03-29 15:50:27.114371
7153	cube 2258	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.405357	cube.usd	2025-03-29 15:50:27.11672
7154	cylinder 1806	green	{0,0,0}	-272.65317	217.53194	929	0	0	18.434948	cylinder.usd	2025-03-29 15:50:27.11889
7155	pentagonal prism 1839	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:27.340541
7156	cube 2259	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:27.343282
7157	cube 2260	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cube.usd	2025-03-29 15:50:27.345717
7158	cylinder 1807	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:50:27.348202
7159	pentagonal prism 1840	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:27.576118
7160	cube 2261	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:50:27.580784
7161	pentagonal prism 1841	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:27.583126
7162	cylinder 1808	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:50:27.585383
7163	pentagonal prism 1842	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:27.798138
7164	cube 2262	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:27.801469
7165	cube 2263	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cube.usd	2025-03-29 15:50:27.80366
7166	cylinder 1809	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:27.805936
7167	pentagonal prism 1843	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:28.022636
7168	cube 2264	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:50:28.026892
7169	cuboid 658	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:28.029455
7170	cylinder 1810	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:28.031727
7171	pentagonal prism 1844	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:28.262015
7172	cube 2265	pink	{0,0,0}	-205.90038	345.12823	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:28.265068
7173	cuboid 659	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:28.26743
7174	cylinder 1811	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:28.270166
7175	pentagonal prism 1845	black	{0,0,0}	-127.45538	519.6258	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:28.491414
7176	cube 2266	pink	{0,0,0}	-205.88947	346.0904	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:28.494204
7177	cuboid 660	red	{0,0,0}	32.354057	259.8129	927.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:28.496549
7178	cylinder 1812	green	{0,0,0}	-270.59756	217.65457	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:28.498654
7179	pentagonal prism 1846	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:28.709656
7180	cube 2267	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.620872	cube.usd	2025-03-29 15:50:28.712737
7181	cuboid 661	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:28.715537
7182	cylinder 1813	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:28.718084
7183	pentagonal prism 1847	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:50:28.936693
7184	cube 2268	pink	{0,0,0}	-205.90038	345.12823	942.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:28.93968
7185	hexagonal prism 601	red	{0,0,0}	32.355774	258.8462	932.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:28.942197
7186	cylinder 1814	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:50:28.944512
7187	pentagonal prism 1848	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:29.159327
7188	cube 2269	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:29.163153
7189	pentagonal prism 1849	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:29.165567
7190	cylinder 1815	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:29.167803
7191	pentagonal prism 1850	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:29.379684
7192	cube 2270	pink	{0,0,0}	-207.68886	346.4762	940.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:29.38324
7193	cuboid 662	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:29.38562
7194	cylinder 1816	green	{0,0,0}	-272.65317	217.53194	938	0	0	26.56505	cylinder.usd	2025-03-29 15:50:29.388257
7195	pentagonal prism 1851	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:29.604579
7196	cube 2271	pink	{0,0,0}	-205.90038	345.12823	910	0	0	59.03625	cube.usd	2025-03-29 15:50:29.610452
7197	hexagonal prism 602	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:29.612896
7198	cylinder 1817	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:29.615387
7199	pentagonal prism 1852	black	{0,0,0}	-127.46696	518.69244	660	0	0	90	pentagonal prism.usd	2025-03-29 15:50:29.831852
7200	cube 2272	pink	{0,0,0}	-205.90816	345.1413	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:29.836017
7201	cylinder 1818	red	{0,0,0}	32.357	258.856	923.00006	0	0	37.568592	cylinder.usd	2025-03-29 15:50:29.838564
7202	cylinder 1819	green	{0,0,0}	-270.62216	216.69383	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:29.840759
7203	pentagonal prism 1853	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:50:30.076956
7204	cube 2273	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:30.080017
7205	hexagonal prism 603	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:30.08277
7206	cylinder 1820	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:30.085937
7207	pentagonal prism 1854	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:30.335583
7208	cube 2274	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:30.338214
7209	pentagonal prism 1855	red	{0,0,0}	32.355774	258.8462	914.00006	0	0	36.869896	pentagonal prism.usd	2025-03-29 15:50:30.340566
7210	cylinder 1821	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:30.342973
7211	pentagonal prism 1856	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:30.574842
7212	cube 2275	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:50:30.577864
7213	pentagonal prism 1857	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:30.580475
7214	cylinder 1822	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:30.58311
7215	pentagonal prism 1858	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:30.812305
7216	cube 2276	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:30.816114
7217	cuboid 663	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:30.819503
7218	cylinder 1823	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:50:30.822659
7219	pentagonal prism 1859	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:31.057736
7220	cube 2277	pink	{0,0,0}	-207.68886	346.4762	907.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:31.06203
7221	cuboid 664	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:31.06519
7222	cylinder 1824	green	{0,0,0}	-272.65317	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:31.068428
7223	pentagonal prism 1860	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:31.316139
7224	cube 2278	pink	{0,0,0}	-206.88084	345.12823	915	0	0	59.620872	cube.usd	2025-03-29 15:50:31.32
7225	cuboid 665	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:31.322153
7226	cylinder 1825	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:50:31.324668
7227	pentagonal prism 1861	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:31.552402
7228	cube 2279	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:31.555516
7229	cuboid 666	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:31.557887
7230	cylinder 1826	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:50:31.560214
7231	pentagonal prism 1862	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:31.78947
7232	cube 2280	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:50:31.793209
7233	pentagonal prism 1863	red	{0,0,0}	32.355774	258.8462	922.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:31.795673
7234	cylinder 1827	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:50:31.798743
7235	pentagonal prism 1864	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:32.024865
7236	cube 2281	pink	{0,0,0}	-205.90816	345.1413	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:32.029247
7237	cube 2282	red	{0,0,0}	32.357	258.856	927.00006	0	0	37.746803	cube.usd	2025-03-29 15:50:32.031921
7238	cylinder 1828	green	{0,0,0}	-270.62216	216.69383	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:32.034453
7239	pentagonal prism 1865	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:32.26558
7240	cube 2283	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:32.26865
7241	cube 2284	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:32.272651
7242	cylinder 1829	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:32.276382
7243	pentagonal prism 1866	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:32.495016
7244	cube 2285	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.62088	cube.usd	2025-03-29 15:50:32.499223
7245	pentagonal prism 1867	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:32.501883
7246	cylinder 1830	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	36.869896	cylinder.usd	2025-03-29 15:50:32.504202
7247	pentagonal prism 1868	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:32.72441
7248	cube 2286	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.03624	cube.usd	2025-03-29 15:50:32.727092
7249	cuboid 667	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:50:32.729377
7250	cylinder 1831	green	{0,0,0}	-272.65317	217.53194	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:32.731583
7251	pentagonal prism 1869	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:50:32.952178
7252	cube 2287	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.620872	cube.usd	2025-03-29 15:50:32.955012
7253	cuboid 668	red	{0,0,0}	31.497837	259.85715	917.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:32.957274
7254	cylinder 1832	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:32.959516
7255	pentagonal prism 1870	black	{0,0,0}	-127.462135	518.67285	661	0	0	90	pentagonal prism.usd	2025-03-29 15:50:33.198717
7256	cube 2288	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:33.201862
7257	cuboid 669	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:50:33.204538
7258	cylinder 1833	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:50:33.206833
7259	pentagonal prism 1871	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:33.431547
7260	cube 2289	pink	{0,0,0}	-206.88084	345.12823	934	0	0	59.620872	cube.usd	2025-03-29 15:50:33.436004
7261	cuboid 670	red	{0,0,0}	32.355774	258.8462	929	0	0	37.405357	cuboid.usd	2025-03-29 15:50:33.438399
7262	cylinder 1834	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:33.440867
7263	pentagonal prism 1872	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:33.666254
7264	cube 2290	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:50:33.66909
7265	pentagonal prism 1873	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:33.671622
7266	cylinder 1835	green	{0,0,0}	-270.6119	216.68562	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:33.674087
7267	pentagonal prism 1874	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:50:33.916993
7268	cube 2291	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:33.921121
7269	cube 2292	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:33.923442
7270	cylinder 1836	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:50:33.925723
7271	pentagonal prism 1875	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:34.140055
7272	cube 2293	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.03624	cube.usd	2025-03-29 15:50:34.142789
7273	cuboid 671	red	{0,0,0}	31.497837	259.85715	924	0	0	37.405357	cuboid.usd	2025-03-29 15:50:34.144958
7274	cylinder 1837	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:34.147221
7275	pentagonal prism 1876	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:34.398753
7276	cube 2294	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:34.40298
7277	cuboid 672	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:50:34.40542
7278	cylinder 1838	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:34.407723
7279	pentagonal prism 1877	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:34.630703
7280	cube 2295	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.34933	cube.usd	2025-03-29 15:50:34.633484
7281	hexagonal prism 604	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:34.636408
7282	cylinder 1839	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:34.639086
7283	pentagonal prism 1878	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:34.870908
7284	cube 2296	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.420776	cube.usd	2025-03-29 15:50:34.873697
7285	cube 2297	red	{0,0,0}	32.355774	258.8462	920	0	0	37.874985	cube.usd	2025-03-29 15:50:34.875789
7286	cylinder 1840	green	{0,0,0}	-270.6119	216.68562	933	0	0	26.56505	cylinder.usd	2025-03-29 15:50:34.877927
7287	pentagonal prism 1879	black	{0,0,0}	-128.94427	520.6986	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:35.10876
7288	cube 2298	pink	{0,0,0}	-207.68886	346.4762	917.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:35.111587
7289	pentagonal prism 1880	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:35.113947
7290	cylinder 1841	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:35.11798
7291	pentagonal prism 1881	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:35.336144
7292	cube 2299	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 15:50:35.339069
7293	pentagonal prism 1882	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:35.341552
7294	cylinder 1842	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:35.34373
7295	pentagonal prism 1883	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:35.59504
7296	cube 2300	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:50:35.597575
7297	cube 2301	red	{0,0,0}	32.355774	258.8462	917.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:35.599735
7298	cylinder 1843	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:35.602518
7299	pentagonal prism 1884	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:35.833157
7300	cube 2302	pink	{0,0,0}	-205.90038	345.12823	917.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:35.836156
7301	cube 2303	red	{0,0,0}	32.355774	258.8462	918.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:35.838605
7302	cylinder 1844	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:35.841525
7303	pentagonal prism 1885	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:36.073669
7304	cube 2304	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.743565	cube.usd	2025-03-29 15:50:36.076747
7305	cuboid 673	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:36.0788
7306	cylinder 1845	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:50:36.080912
7307	pentagonal prism 1886	black	{0,0,0}	-127.462135	518.67285	657	0	0	0	pentagonal prism.usd	2025-03-29 15:50:36.306419
7308	cube 2305	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:36.308773
7309	pentagonal prism 1887	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:36.310959
7310	cylinder 1846	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:36.313202
7311	pentagonal prism 1888	black	{0,0,0}	-128.94427	520.6986	660	0	0	90	pentagonal prism.usd	2025-03-29 15:50:36.53499
7312	cube 2306	pink	{0,0,0}	-208.67317	346.4762	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:36.537917
7313	cuboid 674	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:36.54006
7314	cylinder 1847	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:36.542015
7315	pentagonal prism 1889	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:36.777961
7316	cube 2307	pink	{0,0,0}	-208.67317	346.4762	920	0	0	59.03624	cube.usd	2025-03-29 15:50:36.781902
7317	cuboid 675	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:36.784344
7318	cylinder 1848	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:36.787529
7319	pentagonal prism 1890	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:37.000702
7320	cube 2308	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:50:37.00413
7321	cuboid 676	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:50:37.006411
7322	cylinder 1849	green	{0,0,0}	-270.6119	216.68562	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:37.008725
7323	pentagonal prism 1891	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:37.232682
7324	cube 2309	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:50:37.23768
7325	cube 2310	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:50:37.241029
7326	cylinder 1850	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:37.244363
7327	pentagonal prism 1892	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:50:37.47825
7328	cube 2311	pink	{0,0,0}	-205.90038	345.12823	933	0	0	59.420776	cube.usd	2025-03-29 15:50:37.481872
7329	hexagonal prism 605	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:50:37.483997
7330	cylinder 1851	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:37.486745
7331	pentagonal prism 1893	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:50:37.701365
7332	cube 2312	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:50:37.704882
7333	cuboid 677	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:50:37.707351
7334	cylinder 1852	green	{0,0,0}	-270.6119	216.68562	924	0	0	18.434948	cylinder.usd	2025-03-29 15:50:37.710107
7335	pentagonal prism 1894	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:37.923926
7336	cube 2313	pink	{0,0,0}	-208.67317	346.4762	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:37.927563
7337	cuboid 678	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:50:37.92976
7338	cylinder 1853	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:37.931994
7339	pentagonal prism 1895	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:38.149718
7340	cube 2314	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:38.153043
7341	pentagonal prism 1896	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:38.155951
7342	cylinder 1854	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:38.158392
7343	pentagonal prism 1897	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:38.38976
7344	cube 2315	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:38.392147
7345	cuboid 679	red	{0,0,0}	32.355774	258.8462	913.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:38.394167
7346	cylinder 1855	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:38.396174
7347	pentagonal prism 1898	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:38.611454
7348	cube 2316	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:38.615709
7349	cuboid 680	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	cuboid.usd	2025-03-29 15:50:38.618518
7350	cylinder 1856	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:50:38.621333
7351	pentagonal prism 1899	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:38.857801
7352	cube 2317	pink	{0,0,0}	-207.68886	346.4762	919	0	0	59.420776	cube.usd	2025-03-29 15:50:38.860536
7353	cuboid 681	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:50:38.862811
7354	cylinder 1857	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:38.865091
7355	pentagonal prism 1900	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:50:39.105183
7356	cube 2318	pink	{0,0,0}	-207.68886	346.4762	918.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:39.109525
7357	pentagonal prism 1901	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:39.111964
7358	cylinder 1858	green	{0,0,0}	-272.65317	217.53194	915	0	0	33.690063	cylinder.usd	2025-03-29 15:50:39.114103
7359	pentagonal prism 1902	black	{0,0,0}	-127.45538	519.6258	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:39.34625
7360	cube 2319	pink	{0,0,0}	-205.88947	346.0904	919	0	0	59.03624	cube.usd	2025-03-29 15:50:39.349158
7361	cuboid 682	red	{0,0,0}	32.354057	259.8129	929	0	0	37.568592	cuboid.usd	2025-03-29 15:50:39.351278
7362	cylinder 1859	green	{0,0,0}	-270.59756	217.65457	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:39.353475
7363	pentagonal prism 1903	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:39.606869
7364	cube 2320	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:39.609845
7365	hexagonal prism 606	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:50:39.611886
7366	cylinder 1860	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:39.614099
7367	pentagonal prism 1904	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:39.839674
7368	cube 2321	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:39.84353
7369	pentagonal prism 1905	red	{0,0,0}	31.497837	259.85715	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:39.845801
7370	cylinder 1861	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:50:39.848097
7371	pentagonal prism 1906	black	{0,0,0}	-128.94427	520.6986	656	0	0	0	pentagonal prism.usd	2025-03-29 15:50:40.061229
7372	cube 2322	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:40.065165
7373	pentagonal prism 1907	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:40.067401
7374	cylinder 1862	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:40.06965
7375	pentagonal prism 1908	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:40.281742
7376	cube 2323	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.743565	cube.usd	2025-03-29 15:50:40.28591
7377	cube 2324	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:40.288869
7378	cylinder 1863	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:50:40.29138
7379	pentagonal prism 1909	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:40.503352
7380	cube 2325	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03625	cube.usd	2025-03-29 15:50:40.507021
7381	pentagonal prism 1910	red	{0,0,0}	31.497837	259.85715	920	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:40.509377
7382	cylinder 1864	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:40.511631
7383	pentagonal prism 1911	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:40.740576
7384	cube 2326	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:40.744414
7385	cuboid 683	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:40.746573
7386	cylinder 1865	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:40.748744
7387	pentagonal prism 1912	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:40.970643
7388	cube 2327	pink	{0,0,0}	-207.68886	346.4762	921.00006	0	0	59.620872	cube.usd	2025-03-29 15:50:40.973627
7389	cuboid 684	red	{0,0,0}	31.497837	259.85715	924	0	0	37.874985	cuboid.usd	2025-03-29 15:50:40.97576
7390	cylinder 1866	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:40.978239
7391	pentagonal prism 1913	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:41.202607
7392	cube 2328	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:50:41.206773
7393	cuboid 685	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:50:41.208952
7394	cylinder 1867	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:41.211221
7395	pentagonal prism 1914	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:41.432637
7396	cube 2329	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:41.436032
7397	cuboid 686	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:50:41.438347
7398	cylinder 1868	green	{0,0,0}	-272.65317	217.53194	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:41.440675
7399	pentagonal prism 1915	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:41.662934
7400	cube 2330	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:41.666998
7401	pentagonal prism 1916	red	{0,0,0}	32.355774	258.8462	930.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 15:50:41.669322
7402	cylinder 1869	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:41.671779
7403	pentagonal prism 1917	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:41.891236
7404	cube 2331	pink	{0,0,0}	-207.68886	346.4762	914.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:41.894564
7405	cuboid 687	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:41.896746
7406	cylinder 1870	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:41.899105
7407	pentagonal prism 1918	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:42.116745
7408	cube 2332	pink	{0,0,0}	-207.68886	346.4762	931.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:42.120901
7409	cuboid 688	red	{0,0,0}	31.497837	259.85715	934	0	0	37.568592	cuboid.usd	2025-03-29 15:50:42.123504
7410	cylinder 1871	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:42.125817
7411	pentagonal prism 1919	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:42.3529
7412	cube 2333	pink	{0,0,0}	-207.68886	346.4762	911.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:42.355751
7413	pentagonal prism 1920	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:42.358278
7414	cylinder 1872	green	{0,0,0}	-272.65317	217.53194	931.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:42.36054
7415	pentagonal prism 1921	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:42.5822
7416	cube 2334	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.03625	cube.usd	2025-03-29 15:50:42.586106
7417	pentagonal prism 1922	red	{0,0,0}	31.497837	259.85715	923.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:42.588603
7418	cylinder 1873	green	{0,0,0}	-272.65317	217.53194	918.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:42.591391
7419	pentagonal prism 1923	black	{0,0,0}	-128.94427	520.6986	660	0	0	90	pentagonal prism.usd	2025-03-29 15:50:42.81537
7420	cube 2335	pink	{0,0,0}	-207.68886	346.4762	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:42.819656
7421	pentagonal prism 1924	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:42.822662
7422	cylinder 1874	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:42.825285
7423	pentagonal prism 1925	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:43.050619
7424	cube 2336	pink	{0,0,0}	-207.68886	346.4762	932.00006	0	0	59.03624	cube.usd	2025-03-29 15:50:43.053729
7425	cube 2337	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cube.usd	2025-03-29 15:50:43.056127
7426	cylinder 1875	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:43.05884
7427	pentagonal prism 1926	black	{0,0,0}	-127.462135	518.67285	654.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:43.28254
7428	cube 2338	pink	{0,0,0}	-205.90038	345.12823	934	0	0	59.534454	cube.usd	2025-03-29 15:50:43.28528
7429	cuboid 689	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	cuboid.usd	2025-03-29 15:50:43.287567
7430	cylinder 1876	green	{0,0,0}	-270.6119	216.68562	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:43.289985
7431	pentagonal prism 1927	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:43.502754
7432	cube 2339	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.743565	cube.usd	2025-03-29 15:50:43.505537
7433	cube 2340	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cube.usd	2025-03-29 15:50:43.507925
7434	cylinder 1877	green	{0,0,0}	-270.6119	216.68562	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:43.510191
7435	pentagonal prism 1928	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:43.722312
7436	cube 2341	pink	{0,0,0}	-207.68886	346.4762	934	0	0	59.03625	cube.usd	2025-03-29 15:50:43.725563
7437	cuboid 690	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:50:43.727905
7438	cylinder 1878	green	{0,0,0}	-272.65317	217.53194	916.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:43.730239
7439	pentagonal prism 1929	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:43.952435
7440	cube 2342	pink	{0,0,0}	-206.88084	345.12823	913.00006	0	0	59.03624	cube.usd	2025-03-29 15:50:43.955345
7441	cuboid 691	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:50:43.957742
7442	cylinder 1879	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:50:43.960442
7443	pentagonal prism 1930	black	{0,0,0}	-127.46696	518.69244	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:44.1786
7444	cube 2343	pink	{0,0,0}	-206.88867	345.1413	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:44.181512
7445	cuboid 692	red	{0,0,0}	32.357	258.856	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:44.183837
7446	cylinder 1880	green	{0,0,0}	-270.62216	216.69383	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:44.185965
7447	pentagonal prism 1931	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:44.40008
7448	cube 2344	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:44.402711
7449	cuboid 693	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:44.404902
7450	cylinder 1881	green	{0,0,0}	-270.6119	216.68562	936.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:44.407152
7451	pentagonal prism 1932	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:44.62401
7452	cube 2345	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:44.627361
7453	pentagonal prism 1933	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:44.629582
7454	cylinder 1882	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:44.631834
7455	pentagonal prism 1934	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:44.851288
7456	cube 2346	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.743565	cube.usd	2025-03-29 15:50:44.855625
7457	pentagonal prism 1935	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:44.858378
7458	cylinder 1883	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	18.434948	cylinder.usd	2025-03-29 15:50:44.860967
7459	pentagonal prism 1936	black	{0,0,0}	-127.462135	518.67285	653.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:45.093072
7460	cube 2347	pink	{0,0,0}	-205.90038	345.12823	911.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:45.096026
7461	cuboid 694	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:50:45.098291
7462	cylinder 1884	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:45.100877
7463	pentagonal prism 1937	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:45.322665
7464	cube 2348	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:50:45.327342
7465	cuboid 695	red	{0,0,0}	32.355774	258.8462	915	0	0	37.405357	cuboid.usd	2025-03-29 15:50:45.329632
7466	cylinder 1885	green	{0,0,0}	-270.6119	216.68562	929	0	0	33.690063	cylinder.usd	2025-03-29 15:50:45.331993
7467	pentagonal prism 1938	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:45.554708
7468	cube 2349	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:50:45.559373
7469	cuboid 696	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:50:45.561936
7470	cylinder 1886	green	{0,0,0}	-270.6119	216.68562	917.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:45.56417
7471	pentagonal prism 1939	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:45.790731
7472	cube 2350	pink	{0,0,0}	-205.90038	345.12823	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:50:45.794995
7473	cylinder 1887	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	cylinder.usd	2025-03-29 15:50:45.797287
7474	cylinder 1888	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	33.690063	cylinder.usd	2025-03-29 15:50:45.799515
7475	pentagonal prism 1940	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:46.030038
7476	cube 2351	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.620872	cube.usd	2025-03-29 15:50:46.033951
7477	cuboid 697	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:46.036209
7478	cylinder 1889	green	{0,0,0}	-272.65317	217.53194	933	0	0	26.56505	cylinder.usd	2025-03-29 15:50:46.03834
7479	pentagonal prism 1941	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:46.25531
7480	cube 2352	pink	{0,0,0}	-205.90038	345.12823	928.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:46.257942
7481	cuboid 698	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:46.260788
7482	cylinder 1890	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:46.263106
7483	pentagonal prism 1942	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:46.488939
7484	cube 2353	pink	{0,0,0}	-207.68886	346.4762	928.00006	0	0	59.62088	cube.usd	2025-03-29 15:50:46.492011
7485	cuboid 699	red	{0,0,0}	31.497837	259.85715	924	0	0	37.874985	cuboid.usd	2025-03-29 15:50:46.494453
7486	cylinder 1891	green	{0,0,0}	-272.65317	217.53194	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:46.496604
7487	pentagonal prism 1943	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:46.726163
7488	cube 2354	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:50:46.730761
7489	pentagonal prism 1944	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:46.733238
7490	cylinder 1892	green	{0,0,0}	-270.6119	216.68562	920	0	0	36.869896	cylinder.usd	2025-03-29 15:50:46.735915
7491	pentagonal prism 1945	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:50:46.959348
7492	cube 2355	pink	{0,0,0}	-205.90816	345.1413	919	0	0	59.420776	cube.usd	2025-03-29 15:50:46.962132
7493	cube 2356	red	{0,0,0}	32.357	258.856	924	0	0	37.568592	cube.usd	2025-03-29 15:50:46.964531
7494	cylinder 1893	green	{0,0,0}	-270.62216	216.69383	931.00006	0	0	18.43495	cylinder.usd	2025-03-29 15:50:46.96686
7495	pentagonal prism 1946	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:47.195531
7496	cube 2357	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.534454	cube.usd	2025-03-29 15:50:47.200576
7497	cuboid 700	red	{0,0,0}	32.355774	258.8462	929	0	0	37.568592	cuboid.usd	2025-03-29 15:50:47.203171
7498	cylinder 1894	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:47.20541
7499	pentagonal prism 1947	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:47.422803
7500	cube 2358	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.03624	cube.usd	2025-03-29 15:50:47.426807
7501	cuboid 701	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	cuboid.usd	2025-03-29 15:50:47.42929
7502	cylinder 1895	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:47.431508
7503	pentagonal prism 1948	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:47.66449
7504	cube 2359	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:47.668072
7505	cube 2360	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:47.67026
7506	cylinder 1896	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:50:47.672566
7507	pentagonal prism 1949	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:47.893518
7508	cube 2361	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:47.897071
7509	cuboid 702	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:50:47.899224
7510	cylinder 1897	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:47.901458
7511	pentagonal prism 1950	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:48.125143
7512	cube 2362	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:50:48.129561
7513	hexagonal prism 607	red	{0,0,0}	32.355774	258.8462	924	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:50:48.132121
7514	cylinder 1898	green	{0,0,0}	-270.6119	216.68562	929	0	0	18.434948	cylinder.usd	2025-03-29 15:50:48.134434
7515	pentagonal prism 1951	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:48.359253
7516	cube 2363	pink	{0,0,0}	-207.68886	346.4762	934	0	0	59.03625	cube.usd	2025-03-29 15:50:48.362653
7517	pentagonal prism 1952	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:48.365113
7518	cylinder 1899	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:48.367693
7519	pentagonal prism 1953	black	{0,0,0}	-127.46696	518.69244	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:48.602915
7520	cube 2364	pink	{0,0,0}	-205.90816	345.1413	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:48.606917
7521	hexagonal prism 608	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.405357	hexagonal prism.usd	2025-03-29 15:50:48.609299
7522	cylinder 1900	green	{0,0,0}	-270.62216	216.69383	919	0	0	26.56505	cylinder.usd	2025-03-29 15:50:48.613031
7523	pentagonal prism 1954	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:48.828659
7524	cube 2365	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.03625	cube.usd	2025-03-29 15:50:48.832061
7525	pentagonal prism 1955	red	{0,0,0}	32.355774	258.8462	934	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:48.834451
7526	cylinder 1901	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:48.836892
7527	pentagonal prism 1956	black	{0,0,0}	-127.462135	518.67285	656	0	0	0	pentagonal prism.usd	2025-03-29 15:50:49.064505
7528	cube 2366	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:50:49.069464
7529	cuboid 703	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:49.073181
7530	cylinder 1902	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:50:49.077105
7531	pentagonal prism 1957	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:49.300264
7532	cube 2367	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:49.303173
7533	pentagonal prism 1958	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:49.305262
7534	cylinder 1903	green	{0,0,0}	-272.65317	217.53194	924	0	0	36.869896	cylinder.usd	2025-03-29 15:50:49.30757
7535	pentagonal prism 1959	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:49.525135
7536	cube 2368	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:49.530104
7537	pentagonal prism 1960	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:49.53271
7538	cylinder 1904	green	{0,0,0}	-270.6119	216.68562	920	0	0	26.56505	cylinder.usd	2025-03-29 15:50:49.535059
7539	pentagonal prism 1961	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:49.766766
7540	cube 2369	pink	{0,0,0}	-207.68886	346.4762	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:49.770359
7541	cuboid 704	red	{0,0,0}	31.497837	259.85715	912.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:49.772974
7542	cylinder 1905	green	{0,0,0}	-272.65317	217.53194	934	0	0	26.56505	cylinder.usd	2025-03-29 15:50:49.776332
7543	pentagonal prism 1962	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:50.002184
7544	cube 2370	pink	{0,0,0}	-205.90038	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:50:50.005949
7545	cuboid 705	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:50.008087
7546	cylinder 1906	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:50.010262
7547	pentagonal prism 1963	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:50.223014
7548	cube 2371	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:50.227366
7549	cylinder 1907	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.568592	cylinder.usd	2025-03-29 15:50:50.230172
7550	cylinder 1908	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:50.232417
7551	pentagonal prism 1964	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:50.467267
7552	cube 2372	pink	{0,0,0}	-205.90038	345.12823	921.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:50.469994
7553	pentagonal prism 1965	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:50.472297
7554	cylinder 1909	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:50.474813
7555	pentagonal prism 1966	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:50.692758
7556	cube 2373	pink	{0,0,0}	-205.90038	345.12823	919	0	0	59.03625	cube.usd	2025-03-29 15:50:50.697183
7557	cuboid 706	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:50:50.699493
7558	cylinder 1910	green	{0,0,0}	-270.6119	216.68562	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:50.701851
7559	pentagonal prism 1967	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:50.92651
7560	cube 2374	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.34933	cube.usd	2025-03-29 15:50:50.930821
7561	hexagonal prism 609	red	{0,0,0}	32.355774	258.8462	929	0	0	37.746803	hexagonal prism.usd	2025-03-29 15:50:50.933128
7562	cylinder 1911	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:50.935668
7563	pentagonal prism 1968	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:51.159434
7564	cube 2375	pink	{0,0,0}	-206.88084	345.12823	918.00006	0	0	59.03624	cube.usd	2025-03-29 15:50:51.163905
7565	cube 2376	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	cube.usd	2025-03-29 15:50:51.166181
7566	cylinder 1912	green	{0,0,0}	-270.6119	216.68562	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:51.168568
7567	pentagonal prism 1969	black	{0,0,0}	-127.46696	518.69244	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:51.395828
7568	cube 2377	pink	{0,0,0}	-205.90816	345.1413	924	0	0	59.03625	cube.usd	2025-03-29 15:50:51.400036
7569	cuboid 707	red	{0,0,0}	32.357	258.856	921.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:51.402507
7570	cylinder 1913	green	{0,0,0}	-270.62216	216.69383	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:51.404781
7571	pentagonal prism 1970	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:51.628449
7572	cube 2378	pink	{0,0,0}	-207.68886	346.4762	923.00006	0	0	59.03624	cube.usd	2025-03-29 15:50:51.632763
7573	cuboid 708	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	cuboid.usd	2025-03-29 15:50:51.635192
7574	cylinder 1914	green	{0,0,0}	-272.65317	217.53194	924	0	0	18.434948	cylinder.usd	2025-03-29 15:50:51.637477
7575	pentagonal prism 1971	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:51.85949
7576	cube 2379	pink	{0,0,0}	-205.90038	345.12823	925.00006	0	0	59.420776	cube.usd	2025-03-29 15:50:51.862604
7577	hexagonal prism 610	red	{0,0,0}	32.355774	258.8462	919	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:51.86516
7578	cylinder 1915	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:51.867352
7579	pentagonal prism 1972	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:50:52.103563
7580	cube 2380	pink	{0,0,0}	-207.68886	346.4762	922.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:52.107802
7581	cuboid 709	red	{0,0,0}	31.497837	259.85715	914.00006	0	0	37.874985	cuboid.usd	2025-03-29 15:50:52.110042
7582	cylinder 1916	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:52.112455
7583	pentagonal prism 1973	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:52.326437
7584	cube 2381	pink	{0,0,0}	-207.68886	346.4762	925.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:52.331188
7585	hexagonal prism 611	red	{0,0,0}	31.497837	259.85715	929	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:52.333715
7586	cylinder 1917	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:50:52.336093
7587	pentagonal prism 1974	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:52.560094
7588	cube 2382	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:52.564804
7589	pentagonal prism 1975	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:52.567343
7590	cylinder 1918	green	{0,0,0}	-270.6119	216.68562	924	0	0	26.56505	cylinder.usd	2025-03-29 15:50:52.569727
7591	pentagonal prism 1976	black	{0,0,0}	-127.462135	518.67285	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:52.796702
7592	cube 2383	pink	{0,0,0}	-205.90038	345.12823	916.00006	0	0	59.03624	cube.usd	2025-03-29 15:50:52.801107
7593	pentagonal prism 1977	red	{0,0,0}	32.355774	258.8462	928.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:52.8036
7594	cylinder 1919	green	{0,0,0}	-270.6119	216.68562	933	0	0	18.434948	cylinder.usd	2025-03-29 15:50:52.805753
7595	pentagonal prism 1978	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:53.031488
7596	cube 2384	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.420776	cube.usd	2025-03-29 15:50:53.035775
7597	cube 2385	red	{0,0,0}	32.355774	258.8462	924	0	0	37.746803	cube.usd	2025-03-29 15:50:53.038157
7598	cylinder 1920	green	{0,0,0}	-270.6119	216.68562	930.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:53.040509
7599	pentagonal prism 1979	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:53.264469
7600	cube 2386	pink	{0,0,0}	-206.88084	345.12823	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:53.267152
7601	pentagonal prism 1980	red	{0,0,0}	32.355774	258.8462	923.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:53.269617
7602	cylinder 1921	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:53.271908
7603	pentagonal prism 1981	black	{0,0,0}	-128.9374	521.6551	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:53.499308
7604	cube 2387	pink	{0,0,0}	-207.67778	347.44196	919	0	0	59.03624	cube.usd	2025-03-29 15:50:53.505212
7605	cuboid 710	red	{0,0,0}	31.496155	260.82755	923.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:53.507714
7606	cylinder 1922	green	{0,0,0}	-272.6386	218.50458	924	0	0	18.434948	cylinder.usd	2025-03-29 15:50:53.509924
7607	pentagonal prism 1982	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:53.732852
7608	cube 2388	pink	{0,0,0}	-205.90038	345.12823	932.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:53.737049
7609	cuboid 711	red	{0,0,0}	32.355774	258.8462	920	0	0	37.568592	cuboid.usd	2025-03-29 15:50:53.739274
7610	cylinder 1923	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:53.741423
7611	pentagonal prism 1983	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:53.955786
7612	cube 2389	pink	{0,0,0}	-207.68886	346.4762	929	0	0	59.534454	cube.usd	2025-03-29 15:50:53.959944
7613	pentagonal prism 1984	red	{0,0,0}	31.497837	259.85715	919	0	0	37.69424	pentagonal prism.usd	2025-03-29 15:50:53.96246
7614	cylinder 1924	green	{0,0,0}	-272.65317	217.53194	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:53.96466
7615	pentagonal prism 1985	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:54.194166
7616	cube 2390	pink	{0,0,0}	-205.90038	345.12823	920	0	0	59.620872	cube.usd	2025-03-29 15:50:54.198641
7617	pentagonal prism 1986	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:54.201335
7618	cylinder 1925	green	{0,0,0}	-270.6119	216.68562	934	0	0	26.56505	cylinder.usd	2025-03-29 15:50:54.203627
7619	pentagonal prism 1987	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:54.435226
7620	cube 2391	pink	{0,0,0}	-207.68886	346.4762	920	0	0	59.420776	cube.usd	2025-03-29 15:50:54.437717
7621	cuboid 712	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:54.440038
7622	cylinder 1926	green	{0,0,0}	-272.65317	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:54.442345
7623	pentagonal prism 1988	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:54.660955
7624	cube 2392	pink	{0,0,0}	-205.90038	345.12823	929	0	0	59.03625	cube.usd	2025-03-29 15:50:54.66364
7625	pentagonal prism 1989	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:54.666112
7626	cylinder 1927	green	{0,0,0}	-270.6119	216.68562	925.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:54.668712
7627	pentagonal prism 1990	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:54.898405
7628	cube 2393	pink	{0,0,0}	-205.90038	345.12823	918.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:54.902968
7629	cube 2394	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.405357	cube.usd	2025-03-29 15:50:54.905283
7630	cylinder 1928	green	{0,0,0}	-270.6119	216.68562	921.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:54.907489
7631	pentagonal prism 1991	black	{0,0,0}	-127.95996	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:55.141455
7632	cube 2395	pink	{0,0,0}	-206.70456	346.4762	928.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:55.145392
7633	cube 2396	red	{0,0,0}	32.482143	259.85715	922.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:55.147679
7634	cylinder 1929	green	{0,0,0}	-271.66885	217.53194	923.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:55.150439
7635	pentagonal prism 1992	black	{0,0,0}	-127.462135	518.67285	660	0	0	90	pentagonal prism.usd	2025-03-29 15:50:55.360802
7636	cube 2397	pink	{0,0,0}	-206.88084	345.12823	919	0	0	59.03624	cube.usd	2025-03-29 15:50:55.363537
7637	hexagonal prism 612	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:55.366373
7638	cylinder 1930	green	{0,0,0}	-270.6119	216.68562	919	0	0	26.56505	cylinder.usd	2025-03-29 15:50:55.368887
7639	pentagonal prism 1993	black	{0,0,0}	-128.94427	520.6986	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:55.594042
7640	cube 2398	pink	{0,0,0}	-208.67317	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:50:55.598158
7641	cuboid 713	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:55.601663
7642	cylinder 1931	green	{0,0,0}	-272.65317	217.53194	922.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:55.604308
7643	pentagonal prism 1994	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:55.828502
7644	cube 2399	pink	{0,0,0}	-206.88084	345.12823	924	0	0	59.03625	cube.usd	2025-03-29 15:50:55.833032
7645	cube 2400	red	{0,0,0}	32.355774	258.8462	927.00006	0	0	37.568592	cube.usd	2025-03-29 15:50:55.835659
7646	cylinder 1932	green	{0,0,0}	-270.6119	216.68562	939.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:55.837919
7647	pentagonal prism 1995	black	{0,0,0}	-127.462135	518.67285	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:56.066579
7648	cube 2401	pink	{0,0,0}	-206.88084	345.12823	920	0	0	59.534454	cube.usd	2025-03-29 15:50:56.070185
7649	pentagonal prism 1996	red	{0,0,0}	32.355774	258.8462	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:56.072555
7650	cylinder 1933	green	{0,0,0}	-270.6119	216.68562	935.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:56.074751
7651	pentagonal prism 1997	black	{0,0,0}	-128.94427	520.6986	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:56.308938
7652	cube 2402	pink	{0,0,0}	-207.68886	346.4762	930.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:56.312934
7653	cuboid 714	red	{0,0,0}	31.497837	259.85715	918.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:56.315452
7654	cylinder 1934	green	{0,0,0}	-272.65317	217.53194	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:56.318203
7655	pentagonal prism 1998	black	{0,0,0}	-127.462135	518.67285	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:56.532295
7656	cube 2403	pink	{0,0,0}	-206.88084	345.12823	923.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:56.535863
7657	pentagonal prism 1999	red	{0,0,0}	32.355774	258.8462	935.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 15:50:56.538084
7658	cylinder 1935	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:56.540235
7659	pentagonal prism 2000	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	0	pentagonal prism.usd	2025-03-29 15:50:56.783791
7660	cube 2404	pink	{0,0,0}	-205.90038	345.12823	935.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:56.78661
7661	cuboid 715	red	{0,0,0}	32.355774	258.8462	924	0	0	37.568592	cuboid.usd	2025-03-29 15:50:56.788813
7662	cylinder 1936	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:56.791025
7663	pentagonal prism 2001	black	{0,0,0}	-128.94427	520.6986	656	0	0	90	pentagonal prism.usd	2025-03-29 15:50:57.012743
7664	cube 2405	pink	{0,0,0}	-207.68886	346.4762	927.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:57.015798
7665	cuboid 716	red	{0,0,0}	31.497837	259.85715	934	0	0	37.568592	cuboid.usd	2025-03-29 15:50:57.018294
7666	cylinder 1937	green	{0,0,0}	-272.65317	217.53194	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:57.020648
7667	pentagonal prism 2002	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:57.247635
7668	cube 2406	pink	{0,0,0}	-208.67317	346.4762	916.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:57.25045
7669	pentagonal prism 2003	red	{0,0,0}	31.497837	259.85715	926.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 15:50:57.252846
7670	cylinder 1938	green	{0,0,0}	-272.65317	217.53194	920	0	0	26.56505	cylinder.usd	2025-03-29 15:50:57.254925
7671	pentagonal prism 2004	black	{0,0,0}	-127.462135	518.67285	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:57.507391
7672	cube 2407	pink	{0,0,0}	-205.90038	345.12823	926.00006	0	0	59.03625	cube.usd	2025-03-29 15:50:57.511356
7673	cuboid 717	red	{0,0,0}	32.355774	258.8462	925.00006	0	0	37.568592	cuboid.usd	2025-03-29 15:50:57.513413
7674	cylinder 1939	green	{0,0,0}	-270.6119	216.68562	928.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:57.515578
7675	pentagonal prism 2005	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:57.743229
7676	cube 2408	pink	{0,0,0}	-205.90038	345.12823	922.00006	0	0	59.34933	cube.usd	2025-03-29 15:50:57.747429
7677	cuboid 718	red	{0,0,0}	32.355774	258.8462	921.00006	0	0	37.405357	cuboid.usd	2025-03-29 15:50:57.74993
7678	cylinder 1940	green	{0,0,0}	-270.6119	216.68562	929	0	0	26.56505	cylinder.usd	2025-03-29 15:50:57.752334
7679	pentagonal prism 2006	black	{0,0,0}	-127.462135	518.67285	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:57.978394
7680	cube 2409	pink	{0,0,0}	-205.90038	345.12823	913.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:57.982594
7681	cuboid 719	red	{0,0,0}	32.355774	258.8462	916.00006	0	0	37.746803	cuboid.usd	2025-03-29 15:50:57.985086
7682	cylinder 1941	green	{0,0,0}	-270.6119	216.68562	926.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:57.987549
7683	pentagonal prism 2007	black	{0,0,0}	-128.94427	520.6986	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 15:50:58.21101
7684	cube 2410	pink	{0,0,0}	-207.68886	346.4762	940.00006	0	0	59.534454	cube.usd	2025-03-29 15:50:58.214665
7685	hexagonal prism 613	red	{0,0,0}	31.497837	259.85715	920	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:58.216877
7686	cylinder 1942	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:58.21937
7687	pentagonal prism 2008	black	{0,0,0}	-128.94427	520.6986	657	0	0	90	pentagonal prism.usd	2025-03-29 15:50:58.438558
7688	cube 2411	pink	{0,0,0}	-207.68886	346.4762	924	0	0	59.34933	cube.usd	2025-03-29 15:50:58.441637
7689	hexagonal prism 614	red	{0,0,0}	31.497837	259.85715	928.00006	0	0	37.568592	hexagonal prism.usd	2025-03-29 15:50:58.443808
7690	cylinder 1943	green	{0,0,0}	-272.65317	217.53194	932.00006	0	0	26.56505	cylinder.usd	2025-03-29 15:50:58.445924
7691	unknown 2	green	{0,0.01,0}	119.61831	344.14777	1909	0	0	4.763642	unknown.usd	2025-03-29 15:51:06.141452
764	pentagonal prism 3	black	{0,0,0}	-127.95996	520.6986	651	0	0	90	pentagonal prism.usd	2025-03-29 15:51:06.369079
768	hexagonal prism 3	red	{0,0,0}	31.497837	259.85715	920	0	0	37.874985	hexagonal prism.usd	2025-03-29 15:51:08.46163
1	pentagonal prism 2	black	{0,0,0}	-127.96484	518.7498	655.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:21.589794
5	cylinder 2	green	{0,0,0}	-271.6792	216.5559	897	0	0	38.65981	cylinder.usd	2025-03-29 16:11:21.604386
763	cube 3	pink	{0,0,0}	-207.6968	344.52072	923.00006	0	0	59.620872	cube.usd	2025-03-29 16:11:21.819789
765	cylinder 3	green	{0,0,0}	-271.6792	216.5559	897	0	0	45	cylinder.usd	2025-03-29 16:11:21.825125
26	pentagonal prism 9	red	{0,0,0}	31.621342	260.87607	915	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:22.288704
30	pentagonal prism 10	black	{0,0,0}	-129.44986	521.75214	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:22.522661
767	cylinder 9	green	{0,0,0}	-273.72223	218.38489	921.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:23.212219
136	pentagonal prism 49	red	{0,0,0}	31.621342	260.87607	918.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:27.631028
162	pentagonal prism 56	red	{0,0,0}	31.621342	260.87607	912.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:28.56758
111	cube 37	pink	{0,0,0}	-207.68886	345.4919	918.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:29.027056
100	hexagonal prism 8	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	hexagonal prism.usd	2025-03-29 16:11:30.656764
165	cylinder 45	green	{0,0,0}	-273.72223	218.38489	931.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:31.583781
169	cylinder 46	green	{0,0,0}	-271.66885	217.53194	928.00006	0	0	90	cylinder.usd	2025-03-29 16:11:31.821476
217	cylinder 58	green	{0,0,0}	-273.72223	218.38489	927.00006	0	0	26.56505	cylinder.usd	2025-03-29 16:11:34.607249
318	pentagonal prism 103	red	{0,0,0}	30.633175	260.87607	926.00006	0	0	37.303947	pentagonal prism.usd	2025-03-29 16:11:35.281175
237	cylinder 63	green	{0,0,0}	-271.66885	217.53194	933	0	0	90	cylinder.usd	2025-03-29 16:11:35.739744
378	pentagonal prism 123	red	{0,0,0}	31.621342	260.87607	913.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:38.072837
397	cylinder 104	green	{0,0,0}	-271.66885	217.53194	931.00006	0	0	36.869896	cylinder.usd	2025-03-29 16:11:44.115981
560	pentagonal prism 174	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:45.026919
594	pentagonal prism 185	red	{0,0,0}	32.482143	259.85715	923.00006	0	0	37.874985	pentagonal prism.usd	2025-03-29 16:11:46.413717
598	pentagonal prism 186	red	{0,0,0}	32.482143	259.85715	916.00006	0	0	38.04704	pentagonal prism.usd	2025-03-29 16:11:46.647977
363	cube 115	pink	{0,0,0}	-207.68886	345.4919	920	0	0	59.534454	cube.usd	2025-03-29 16:11:46.878829
379	cube 119	pink	{0,0,0}	-207.68886	345.4919	916.00006	0	0	59.03625	cube.usd	2025-03-29 16:11:47.809157
650	pentagonal prism 199	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:48.272084
702	pentagonal prism 214	red	{0,0,0}	31.621342	260.87607	916.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:50.153358
1401	pentagonal prism 220	black	{0,0,0}	-127.95996	519.7143	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:51.096934
1453	pentagonal prism 229	red	{0,0,0}	31.497837	259.85715	925.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 16:11:52.508414
1519	pentagonal prism 234	black	{0,0,0}	-127.95996	519.7143	657	0	0	90	pentagonal prism.usd	2025-03-29 16:11:53.631217
1551	pentagonal prism 240	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:54.549917
1605	pentagonal prism 246	red	{0,0,0}	31.497837	259.85715	921.00006	0	0	37.405357	pentagonal prism.usd	2025-03-29 16:11:55.252683
1657	pentagonal prism 259	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:11:57.340819
1659	pentagonal prism 260	red	{0,0,0}	32.482143	259.85715	921.00006	0	0	37.568592	pentagonal prism.usd	2025-03-29 16:11:57.347603
1717	pentagonal prism 271	black	{0,0,0}	-129.44986	521.75214	660	0	0	90	pentagonal prism.usd	2025-03-29 16:11:58.970684
184	cuboid 14	red	{0,0,0}	31.497837	259.85715	929	0	0	37.405357	cuboid.usd	2025-03-29 16:11:59.67211
677	cylinder 175	green	{0,0,0}	-271.66885	217.53194	930.00006	0	0	33.690063	cylinder.usd	2025-03-29 16:11:59.909577
1775	pentagonal prism 281	black	{0,0,0}	-127.95996	519.7143	659.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:12:00.601844
1823	pentagonal prism 285	black	{0,0,0}	-129.44986	521.75214	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:12:01.08594
1881	pentagonal prism 295	black	{0,0,0}	-127.95996	519.7143	658.00006	0	0	90	pentagonal prism.usd	2025-03-29 16:12:02.535337
880	cylinder 193	green	{0,0,0}	-271.66885	217.53194	929	0	0	26.56505	cylinder.usd	2025-03-29 16:12:04.190862
1933	pentagonal prism 307	black	{0,0,0}	-127.95996	519.7143	661	0	0	90	pentagonal prism.usd	2025-03-29 16:12:04.423338
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
1	2025-03-29 15:38:55.897147	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-03-29 15:38:55.897147	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 15:38:55.897147
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-03-29 15:38:55.897147
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-03-29 15:38:55.897147
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
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-03-29 15:38:55.897147
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-03-29 15:38:55.897147
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
1	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscar.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	2025-03-29 15:38:55.897147	2025-03-29 15:38:55.897147
2	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahul.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\N	\N	2025-03-29 15:38:55.897147	2025-03-29 15:38:55.897147
3	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanjay.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	2025-03-29 15:38:55.897147	2025-03-29 15:38:55.897147
4	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehdi.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	2025-03-29 15:38:55.897147	2025-03-29 15:38:55.897147
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 7691, true);


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

