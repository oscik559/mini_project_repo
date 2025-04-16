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
    pos_x double precision NOT NULL,
    pos_y double precision NOT NULL,
    pos_z double precision NOT NULL,
    rot_x double precision NOT NULL,
    rot_y double precision NOT NULL,
    rot_z double precision NOT NULL,
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
    block_height double precision NOT NULL,
    block_pick_height double precision NOT NULL,
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
4468	slide_1	green	{0,0,0}	236.25	46	-19	90	90	0	Slide.usd	2025-04-16 15:44:29.684055
4469	slide_2	green	{0,0,0}	175.25	46	-19	90	90	0	Slide.usd	2025-04-16 15:44:29.685498
4470	slide_3	pink	{0,0,0}	297.25	46	-19	90	90	0	Slide.usd	2025-04-16 15:44:29.686513
4471	slide_4	pink	{0,0,0}	114.25	46	-19	90	90	0	Slide.usd	2025-04-16 15:44:29.687248
4472	Fixture	black	{0,0,0}	499.75	1342.48	0	180	0	14.08	Fixture.usd	2025-04-16 15:44:29.688114
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
1	2025-04-16 15:08:15.052712	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-04-16 15:08:15.052712	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-04-16 15:08:15.052712
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-04-16 15:08:15.052712
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-04-16 15:08:15.052712
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
2	shape_stacking	pick, travel, drop
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
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-04-16 15:08:15.052712
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-04-16 15:08:15.052712
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

COPY public.usd_data (sequence_id, usd_name, type_of_usd, repository, block_height, block_pick_height, scale_x, scale_y, scale_z, prim_path, initial_pos_x, initial_pos_y, initial_pos_z, register_obstacle) FROM stdin;
1	Fixture.usd	GeometryPrim	/fixture_description/Slide_Fixture.usd	0	0	0.1	0.1	0.1	/World/fixtureprim	0.2	-0.07	0.094	f
2	Slide_Holder.usd	GeometryPrim	/fixture_description/Slide_Holder.usd	0	0	0.1	0.1	0.1	/World/fixtureprim	40	17	8	f
3	Slide.usd	RigidPrim	/fixture_description/Slide.usd	0.002	0.016	1	1	1	/World/fixtureprim/Fixture	0	0	0	t
4	Cuboid.usd	RigidPrim	/yumi_basic_shapes/cuboid.usd	0.025	0.015	0.1	0.1	0.1	/World/fixtureprim	0.55475	-0.116	0.113	t
5	Cylinder.usd	RigidPrim	/yumi_basic_shapes/cylinder.usd	0.025	0.015	0.1	0.1	0.1	/World/fixtureprim	0.41475	-0.116	0.113	t
6	Cube.usd	RigidPrim	/yumi_basic_shapes/cube.usd	0.025	0.015	0.1	0.1	0.1	/World/fixtureprim	0.34475	-0.116	0.113	t
7	Hexagon.usd	RigidPrim	/yumi_basic_shapes/hexagon.usd	0.025	0.015	0.1	0.1	0.1	/World/fixtureprim	0.48475	-0.116	0.113	t
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.users (user_id, first_name, last_name, liu_id, email, preferences, profile_image_path, interaction_memory, face_encoding, voice_embedding, created_at, last_updated) FROM stdin;
1	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscar.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	2025-04-16 15:08:15.052712	2025-04-16 15:08:15.052712
2	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahul.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\N	\N	2025-04-16 15:08:15.052712	2025-04-16 15:08:15.052712
3	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanjay.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	2025-04-16 15:08:15.052712	2025-04-16 15:08:15.052712
4	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehdi.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	2025-04-16 15:08:15.052712	2025-04-16 15:08:15.052712
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 4472, true);


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

