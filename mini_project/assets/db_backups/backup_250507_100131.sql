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
    drop_pos_x double precision,
    drop_pos_y double precision,
    drop_pos_z double precision,
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
    operation_status boolean DEFAULT false
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
    operation_name text NOT NULL,
    task_order text,
    description text,
    trigger_keywords text[],
    script_path text,
    is_triggerable boolean DEFAULT true,
    trigger boolean DEFAULT false,
    state text DEFAULT 'idle'::text,
    last_triggered timestamp without time zone
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
    role text DEFAULT 'guest'::text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_role_check CHECK ((role = ANY (ARRAY['robot'::text, 'team'::text, 'guest'::text, 'admin'::text])))
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
2530	Fixture	black	{0,0,0}	59.685603934314884	123.6344652925094	0	0	0	92.29061004263853	Fixture.usd	2025-05-06 19:41:07.831862
2532	Holder	black	{0,0,0}	91.66003461341215	322.94174985888236	0	0	0	-77.5228333579943	Slide_Holder.usd	2025-05-06 19:41:07.833926
2533	Slide_1	green	{0.28,0.49,0.32}	69.68560393431488	128.6344652925094	0	0	0	92.29061004263853	Slide.usd	2025-05-06 19:41:07.834659
2534	Slide_2	orange	{0.81,0.61,0.4}	79.68560393431488	133.6344652925094	0	0	0	92.29061004263853	Slide.usd	2025-05-06 19:41:07.835232
2535	Slide_3	pink	{0.61,0.27,0.42}	89.68560393431488	138.6344652925094	0	0	0	92.29061004263853	Slide.usd	2025-05-06 19:41:07.835769
\.


--
-- Data for Name: drop_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.drop_op_parameters (sequence_id, operation_order, object_id, drop_height, drop_pos_x, drop_pos_y, drop_pos_z, operation_status) FROM stdin;
1	1	slide_1	0	\N	\N	\N	t
2	2	slide_2	0	\N	\N	\N	t
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
1	2025-04-29 12:01:01.268398	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-04-29 12:01:01.268398	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-04-29 12:01:01.268398
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-04-29 12:01:01.268398
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-04-29 12:01:01.268398
\.


--
-- Data for Name: isaac_sim_gui; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.isaac_sim_gui (sequence_id, gui_feature, operation_status) FROM stdin;
2	Reset	f
3	Load	f
1	Start	f
\.


--
-- Data for Name: lift_state_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.lift_state_parameters (sequence_id, operation_order, object_id, lift_height, operation_status) FROM stdin;
\.


--
-- Data for Name: operation_library; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.operation_library (id, operation_name, task_order, description, trigger_keywords, script_path, is_triggerable, trigger, state, last_triggered) FROM stdin;
1	slide_sorting	pick, travel, drop	Sort slides by shape and color into trays	{sort,slides,slide,sorting,tray,"sort slides"}	detect_slides_pgSQL.py	t	f	idle	2025-04-29 12:24:26.780865
2	shape_stacking	pick, travel, drop	Stack blocks of shapes based on their type and color	{stack,stacking,shapes,shape,"shape stacking"}	detect_shapes_pgSQL.py	t	t	triggered	2025-05-07 08:13:18.919311
\.


--
-- Data for Name: operation_sequence; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.operation_sequence (id, operation_id, sequence_id, sequence_name, object_name, command_id, processed, execution_time) FROM stdin;
48	1	1	pick	slide_1	7	f	2025-04-29 12:24:55.491588
49	2	2	travel	slide_1	7	f	2025-04-29 12:24:55.491588
50	3	3	drop	slide_1	7	f	2025-04-29 12:24:55.491588
51	4	1	pick	slide_2	7	f	2025-04-29 12:24:55.491588
52	5	2	travel	slide_2	7	f	2025-04-29 12:24:55.491588
53	6	3	drop	slide_2	7	f	2025-04-29 12:24:55.491588
54	7	6	go_home		7	f	2025-04-29 12:24:55.491588
\.


--
-- Data for Name: pick_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.pick_op_parameters (sequence_id, operation_order, object_id, slide_state_status, slide_direction, distance_travel, operation_status) FROM stdin;
17	1	slide_1	f	y	0.01	f
18	2	slide_2	f	y	0.01	f
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
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-04-29 12:01:01.268398
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-04-29 12:01:01.268398
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
17	1	slide_1	0.085	z-axis	f
18	2	slide_2	0.085	z-axis	f
\.


--
-- Data for Name: unified_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.unified_instructions (id, session_id, "timestamp", liu_id, voice_command, gesture_command, unified_command, confidence, processed) FROM stdin;
1	session_voice_001	2025-04-29 12:03:03.806184	oscik559	Could you stack the shapes in this order?  The blue circle first, then the green square next, and finally the red circle.		Could you stack the shapes in this order?  The blue circle first, then the green square next, and finally the red circle.	0.95	t
2	session_voice_001	2025-04-29 12:04:38.920047	oscik559	Could you help us stack the shapes in this order?  The blue circle first, then the green square next, and then the red circle.		Could you help us stack the shapes in this order?  The blue circle first, then the green square next, and then the red circle.	0.95	t
4	session_voice_001	2025-04-29 12:14:38.086924	oscik559	Could you stack the shapes in this order, the green square first, then the blue circle next, and then the red circle?		Could you stack the shapes in this order, the green square first, then the blue circle next, and then the red circle?	0.95	t
5	session_voice_001	2025-04-29 12:19:15.53073	oscik559	Could you stack the shapes in this order the green square first then the blue circle next and then the red circle		Could you stack the shapes in this order the green square first then the blue circle next and then the red circle	0.95	t
6	session_voice_001	2025-04-29 12:21:29.138432	oscik559	yes could you stack the shapes in this order the green square first  then the blue circle next and then the red circle		yes could you stack the shapes in this order the green square first  then the blue circle next and then the red circle	0.95	t
7	session_voice_001	2025-04-29 12:24:55.429	oscik559	Could you sort the slides in the order of the green slide and then the orange slide?		Could you sort the slides in the order of the green slide and then the orange slide?	0.95	t
3	session_voice_001	2025-04-29 12:09:44.579096	oscik559	Could you start the shapes in this order? The green square first, then the blue circle next, and then the red circle.		Could you start the shapes in this order? The green square first, then the blue circle next, and then the red circle.	0.95	t
\.


--
-- Data for Name: usd_data; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.usd_data (sequence_id, usd_name, type_of_usd, repository, block_height, block_pick_height, scale_x, scale_y, scale_z, prim_path, initial_pos_x, initial_pos_y, initial_pos_z, register_obstacle) FROM stdin;
1	Fixture.usd	GeometryPrim	/fixture_description/Slide_Fixture.usd	0	0	0.1	0.1	0.1	/World/fixtureprim	0.2	-0.07	0.094	f
2	Slide_Holder.usd	GeometryPrim	/fixture_description/Slide_Holder.usd	0	0	0.1	0.1	0.1	/World/fixtureprim	40	17	8	f
3	Slide.usd	RigidPrim	/fixture_description/Slide1.usd	0.002	0.016	1	1	0.06	/World/fixtureprim/Fixture	0	0	0	t
4	Cuboid.usd	RigidPrim	/yumi_basic_shapes/cuboid.usd	0.025	0.015	0.1	0.11	0.1	/World/fixtureprim	0.55475	-0.116	0.113	t
5	Cylinder.usd	RigidPrim	/yumi_basic_shapes/cylinder.usd	0.025	0.015	0.1	0.1	0.1	/World/fixtureprim	0.41475	-0.116	0.113	t
6	Cube.usd	RigidPrim	/yumi_basic_shapes/cube.usd	0.025	0.015	0.1	0.1	0.1	/World/fixtureprim	0.34475	-0.116	0.113	t
7	Hexagon.usd	RigidPrim	/yumi_basic_shapes/hexagon.usd	0.025	0.015	0.1	0.1	0.1	/World/fixtureprim	0.48475	-0.116	0.113	t
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.users (user_id, first_name, last_name, liu_id, email, preferences, profile_image_path, interaction_memory, face_encoding, voice_embedding, role, created_at, last_updated) FROM stdin;
1	Yumi	Robot	yumi100	yumi100@lab.liu.ai	{"likes": ["AI", "Robotics"]}	/images/yumi001.jpg	{"last_task": "Assistance", "successful_tasks": 100}	\N	\N	robot	2025-04-29 12:01:01.268398	2025-04-29 12:01:01.288812
6	Marie	Jonsson	marjo33	marie.s.jonsson@liu.se	{"likes": ["Robots", "Composites"]}	/images/marjo33.jpg	{"last_task": "Fix robot battery", "successful_tasks": 2}	\N	\N	team	2025-04-29 12:01:01.268398	2025-04-29 12:01:01.288812
4	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanna58.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	admin	2025-04-29 12:01:01.268398	2025-04-29 12:01:01.288812
7	Aref	Aghaee	areag806	areag806@student.liu.se	{"likes": ["CATIA", "Turbine Blades"]}	/images/areag806.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-04-29 12:01:01.268398	2025-04-29 12:01:01.288812
8	Thomson	Kalliyath	thoka981	thoka981@student.liu.se	{"likes": ["Omniverse", "Aeronautics"]}	/images/thoka981.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-04-29 12:01:01.268398	2025-04-29 12:01:01.288812
9	Hamideh	Pourrasoul	hampo845	hampo845@student.liu.se	{"likes": ["CATIA", "Turbine Blades"]}	/images/hampo845.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-04-29 12:01:01.268398	2025-04-29 12:01:01.288812
10	John	Ashish	johas759	johas759@student.liu.se	{"likes": ["python", "aircraft wings"]}	/images/johas759.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-04-29 12:01:01.268398	2025-04-29 12:01:01.288812
11	Danial	Nikpey	danni741	danni741@student.liu.se	{"likes": ["vb.net", "aircraft wings"]}	/images/danni741.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-04-29 12:01:01.268398	2025-04-29 12:01:01.288812
5	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehta77.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	team	2025-04-29 12:01:01.268398	2025-04-29 12:01:01.288812
2	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscik559.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\\x8004958e040000000000005d948c156e756d70792e636f72652e6d756c74696172726179948c0c5f7265636f6e7374727563749493948c056e756d7079948c076e6461727261799493944b0085944301629487945294284b014b80859468048c0564747970659493948c02663894898887945294284b038c013c944e4e4e4affffffff4affffffff4b00749462894200040000000000004fa2c7bf000000005013c23f00000000c754c83f00000000ef9a45bf000000c00154993f000000600436adbf0000006045d0b13f000000805c669dbf00000020c5cec03f0000002022b0a4bf00000000ce12d13f000000a0b8b189bf000000e0dd6cc8bf00000040acd3c2bf000000a054d0b23f00000040ace5bf3f00000080c1a8c3bf0000004039f2b4bf00000060fb66b5bf000000c0c456bfbf000000608828a23f000000204c1ab53f0000006016fa95bf00000080c5b8973f000000602134b1bf00000040d949d2bf000000e024c2b5bf000000c0ba4ac2bf000000c0aa5ebf3f00000080c3f7bbbf000000c0d7ce863f0000000073f497bf000000a07c24c2bf000000c0125f8dbf00000020a7b6b6bf00000080d8c695bf000000a0559aab3f000000e03f29b5bf000000e0e506c13f00000060a58d9a3f000000006470bdbf00000080d793babf000000000ad693bf000000a0c30dd03f000000808d3ac73f000000c05845a5bf00000040c94586bf00000060cb3aa23f00000040b252a33f000000e01734cbbf000000409d97933f000000e007a6b43f0000000058b2c03f000000002dfaae3f0000006030b18e3f000000002a42bfbf00000040be42aebf00000040feb0a0bf000000a0a81dc7bf000000807dc69e3f000000a0c0c6b33f000000805c2fc0bf000000e05bf5c0bf000000e0ad9ca4bf00000040ae29c83f000000e0e5b5b23f000000005e3cbabf00000040840fc1bf00000000fdd3c73f000000a07c6bc2bf00000040b74f6fbf00000040a721b73f000000000932b8bf000000c08bc6aebf000000a06f6fcebf0000002060a0c13f000000404ed2d33f000000004f19bc3f00000000adc1c7bf000000806768a3bf000000c0f7aacebf00000080e281ac3f000000a0e87c94bf00000080e6dc80bf00000060c366b5bf000000602b4c9c3f000000608024c1bf00000040f87a7c3f00000000b60bb93f000000c05d478ebf00000080e4f293bf00000020cd7dcc3f00000040f04d853f00000080fc5491bf0000000057ae8a3f0000008075a694bf0000008067927dbf000000e05f9eafbf000000409f3faabf000000809cf396bf000000a0f27eb73f000000c00c00bfbf000000e06f14713f000000c01197b93f00000060a328c8bf000000c0e038c33f000000c01144ae3f000000609e2384bf000000e0aa5cae3f000000202af8a53f00000040f9c2c0bf00000060fb1fb2bf00000000966cc63f000000e0d370c5bf000000e0ccfcbc3f000000c05dd0c43f000000a0b9ab9d3f00000040c725c03f00000000b70aa13f00000080d094c43f00000020c2d2bbbf000000c02245b0bf00000020e0e5b1bf00000000635ba8bf00000000824daa3f000000201d3f86bf00000060cc7a89bf00000080f802a63f94749462612e	\\x80049508090000000000005d945d9428473f857463c0000000473f8d1ba360000000473fc033c540000000470000000000000000473f82e8e860000000473f9a9ee420000000473f9b0e2820000000473f839da8a0000000473fc0a3f440000000473fad238fe0000000473fc0270fe0000000473f9ffea200000000473fa9088700000000470000000000000000473fa7099ac0000000473f8f5aaa20000000473fc1e61760000000473f8f953720000000470000000000000000473f9c9df7e0000000473f9d59f720000000473fb2fc34a0000000470000000000000000470000000000000000470000000000000000473fc22cba40000000470000000000000000473f8b85b5c0000000473f980da9c0000000470000000000000000473fa7364e80000000473f8364e000000000473f4a452ee0000000473fa0a2faa0000000470000000000000000473faaf995c0000000473f9bbf16a0000000470000000000000000473fabc5fba0000000473f778a8f60000000470000000000000000470000000000000000473fbc0d3120000000473f6cd6e020000000470000000000000000470000000000000000473fa268a3e0000000473fb7897c60000000473fb569ddc0000000473fa3c2c240000000470000000000000000473fb282e0e0000000473f70aeac40000000470000000000000000473f6c634280000000470000000000000000473f78a18020000000470000000000000000473fc3396fa0000000473f9f8c34c0000000470000000000000000470000000000000000473f91f65220000000473fa37e9ea0000000473f80d0c900000000470000000000000000473fc2639e00000000473fc04213a0000000470000000000000000473f88ceb080000000470000000000000000473f80ab4100000000470000000000000000473faf3ee000000000473fa3f13100000000473fa982b5c0000000470000000000000000473fbb23f520000000470000000000000000473f88229d80000000470000000000000000470000000000000000473fbabbea60000000473fbb251b00000000470000000000000000470000000000000000470000000000000000473f9eae1b40000000470000000000000000473fc1ca1860000000473fb2f27f40000000470000000000000000473facdb4fc0000000470000000000000000473f69e31c80000000470000000000000000473fa63cc8e0000000470000000000000000470000000000000000470000000000000000473f5b686480000000470000000000000000473facbd9060000000473f9977d4a0000000473fab6031a0000000473f9c1de980000000473f3e1bf060000000473f780bf600000000470000000000000000473fa836e3e0000000470000000000000000473fa5ad3a20000000470000000000000000473f8ff02de0000000473fa92430c0000000470000000000000000473f808cbca0000000470000000000000000473fa5b74b00000000473f66ff1300000000473fac7dd6c0000000473fa1e61540000000473fb28e9720000000473f85ad22a0000000473fc6eaf780000000473f8eac5560000000473fa990d560000000473fb2dc6960000000473fab277420000000470000000000000000473fbdfa30a0000000470000000000000000473fbec0cc80000000473fa47e3e00000000473f3ef24600000000473fb64c7dc0000000473fa78d3e80000000470000000000000000473fa139af00000000473fb00f8b60000000470000000000000000470000000000000000473fc47440e0000000473f95322fa0000000470000000000000000473fbfac9660000000473fb6a494c0000000470000000000000000473fb680a180000000473fa570e760000000473fb68dd640000000473fc61b9f40000000470000000000000000473facd33c60000000473f84dabf20000000473fc6f21ce0000000470000000000000000470000000000000000470000000000000000473fb1c777a0000000473fc1f94280000000470000000000000000473fb528c3c0000000473f7d0c8d20000000473f8eb0f8e0000000473fc1e2e720000000473fa9170de0000000470000000000000000473fb88754c0000000473faa6cbe00000000470000000000000000470000000000000000473f36fce740000000470000000000000000470000000000000000473fbf2e4de0000000473fc55b46e0000000473fc0d92f60000000473f95768320000000473f7c6caa00000000473fba436a40000000470000000000000000473f8474e160000000473f9e42f0a0000000473fb1178420000000470000000000000000470000000000000000473fada57640000000473f7a264c00000000473f660597e0000000473fb07bdd80000000473fab1190a0000000470000000000000000473fab8b52e0000000470000000000000000470000000000000000473fb15a3cc0000000473fb5db3980000000473f9b08c9a0000000473fa9ead0a0000000473fa9faf080000000470000000000000000473f9551d900000000473fa0610c40000000470000000000000000470000000000000000473facd61340000000473f808c2300000000473f9a67fe80000000473faa5f4f20000000470000000000000000470000000000000000473fb894cfe0000000473f88b7b820000000470000000000000000473fc438e6c0000000470000000000000000473fab9951c0000000473fb36ce3e0000000470000000000000000473f7be44960000000473f9c148a00000000470000000000000000470000000000000000473fb57451c0000000473fa483cf80000000473fa2502da0000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473fc52d3fa0000000470000000000000000470000000000000000473fb31ea580000000473fc2d3c180000000473fb8f1e240000000473fb5f124c0000000473f9ed8f9e0000000473fb3ab1100000000473f8a6158e0000000473fa8fe6660000000473fb3f99680000000473f919b34a0000000473fbc51eaa0000000473fd5927440000000470000000000000000473fb80be960000000473faaeff760000000473f7f9d7800000000473fb39b8f80000000473f7b0fb7a0000000473f6b83b9c0000000473face8c78000000047000000000000000065612e	admin	2025-04-29 12:01:01.268398	2025-04-29 12:01:01.288812
3	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahch515.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\\x8004958e040000000000005d948c156e756d70792e636f72652e6d756c74696172726179948c0c5f7265636f6e7374727563749493948c056e756d7079948c076e6461727261799493944b0085944301629487945294284b014b80859468048c0564747970659493948c02663894898887945294284b038c013c944e4e4e4affffffff4affffffff4b00749462894200040000000000c01258c0bf000000c0f7fdaf3f00000040085dbb3f00000040500faebf000000c0422ea7bf00000080a504b0bf000000c0d9f48a3f000000c0e61f91bf000000203ffeca3f00000000383cb4bf000000c02cf0cb3f00000040572d7e3f000000203762c9bf0000002055bfc2bf000000c0790b913f00000000eb10ad3f000000601c54b9bf00000040babbb4bf00000040d304afbf0000002013fdb6bf000000805be49a3f00000060d6949abf000000806854963f000000405367a83f000000c07c09b9bf000000403cb6d6bf000000c070c3b6bf00000080974cc7bf000000c01d85bc3f000000209b08bdbf00000040f22683bf000000c042577d3f00000000da5bbfbf000000c0dac6adbf000000e0e603b6bf000000a0fda7af3f000000c0b3e7843f000000807a6fb1bf000000e0cfc0c53f0000000063219abf000000805827c1bf0000000072f7c0bf000000a0d204a4bf00000000d68eca3f000000603d23c33f000000c04f6a8e3f000000a06fd1a13f00000020c87380bf000000c074d5bc3f0000008049c2c9bf000000401cfeb53f000000c0795cbc3f00000060cecfbc3f000000408170993f000000e075d7c33f00000040d242c0bf000000007972a13f000000400fa2b03f000000802a3dcebf000000e041ec993f00000000c97e74bf000000a0998d98bf00000080b5d7b8bf000000c0a2e1a7bf000000c079c0c83f0000002000c1c23f00000040a79ca9bf0000008098a4babf000000c01edec53f000000801e1ec9bf00000080a792933f000000803aebb53f000000007a76bcbf00000040ad39bebf0000004077facdbf000000a0cc82b33f000000c0ad72d63f000000404242cc3f00000060f2bdbdbf000000c09472923f00000080d23cc0bf00000060f352a5bf000000200598ab3f000000606cdd95bf000000c0c324c4bf000000a0ce7cad3f0000004045f1b6bf000000c0c593a53f000000c0c058ad3f000000404fb5953f000000c0d15b90bf000000409eedc13f000000005b219ebf00000020e716a43f000000c0f9cc883f0000004051b4b3bf000000805510b7bf0000006098c88a3f00000020b280afbf000000c040859abf000000209d38c43f000000201186b8bf00000000c6f1a93f00000060e4f3a83f00000020388fc8bf00000020962cb03f000000a0045d793f00000000b2d7a2bf00000040009ba63f000000c0c6569e3f000000c07d60c1bf000000c06205a8bf00000020cd93c83f00000060020ac8bf000000e0ceaac53f000000c0bbb8c13f0000006079a7833f0000004014ecc13f000000c03b6db03f00000080e308b23f00000080bd5ba7bf0000008003b7b3bf000000c01f50b6bf000000a0f7fe66bf000000c01971a93f00000040b5e2a8bf00000040e2b8b03f00000000cccb43bf94749462612e	\N	admin	2025-04-29 12:01:01.268398	2025-04-29 12:01:01.288812
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
1	c070744c-f54a-4e7f-a38f-c7e6af05e212	Could you stack the shapes in this order?  The blue circle first, then the green square next, and finally the red circle.	\N	yoruba	f	2025-04-29 12:03:03.630235
2	c070744c-f54a-4e7f-a38f-c7e6af05e212	Could you help us stack the shapes in this order?  The blue circle first, then the green square next, and then the red circle.	\N	yoruba	f	2025-04-29 12:04:38.749517
3	c070744c-f54a-4e7f-a38f-c7e6af05e212	Could you start the shapes in this order? The green square first, then the blue circle next, and then the red circle.	\N	english	f	2025-04-29 12:09:44.516672
4	11bfc56f-8733-422a-91d6-7f7a894f3ddf	Could you stack the shapes in this order, the green square first, then the blue circle next, and then the red circle?	\N	yoruba	f	2025-04-29 12:14:38.024183
5	11bfc56f-8733-422a-91d6-7f7a894f3ddf	Could you stack the shapes in this order the green square first then the blue circle next and then the red circle	\N	yoruba	f	2025-04-29 12:19:15.468242
6	11bfc56f-8733-422a-91d6-7f7a894f3ddf	yes could you stack the shapes in this order the green square first  then the blue circle next and then the red circle	\N	english	f	2025-04-29 12:21:28.969676
7	11bfc56f-8733-422a-91d6-7f7a894f3ddf	Could you sort the slides in the order of the green slide and then the orange slide?	\N	english	f	2025-04-29 12:24:55.368006
8	ef5bf718-6a5d-4f59-8a52-35d5def28a59	What do you see?	\N	english	f	2025-05-05 18:53:40.379305
9	55676c9f-b389-4f27-ab33-d4a21053b7ad	Could you tell me what you see?	\N	english	f	2025-05-05 19:03:32.784705
10	5a707c0b-044e-4992-8713-8a8600cecc4a	Hello!	\N	nynorsk	f	2025-05-05 19:23:15.106399
11	832d90e9-2034-46c1-b026-f434a8bf9d51	What do you see?	\N	english	f	2025-05-06 11:12:36.409694
12	f2014a29-093f-4435-9dc2-1a1f2aa17204	What do you see?	\N	english	f	2025-05-06 11:19:37.289325
13	095147b6-f897-4f76-a151-13a15a1c8acb	What do you see?	\N	english	f	2025-05-06 15:15:59.983317
14	6baba9f4-e859-407a-8ed5-58a9420a2a33	What do you see?	\N	english	f	2025-05-06 15:19:18.517658
15	f2ecbb64-88df-4b67-99ed-e943bc130387	Can you tell me a joke?	\N	english	f	2025-05-06 15:21:14.719002
16	3b8a78f5-b980-4300-aec8-3fd7fda9635d	I have some friends in the lab today, can you tell us a joke?	\N	english	f	2025-05-06 15:24:12.342175
17	24c982aa-4b21-44af-8585-3f50c9dbd549	I've got some friends in the lab today, can you tell us a joke?	\N	english	f	2025-05-06 15:25:30.235225
18	24c982aa-4b21-44af-8585-3f50c9dbd549	I've got some friends in the lab today, can you tell us a joke?	\N	english	f	2025-05-06 15:26:10.953674
19	24c982aa-4b21-44af-8585-3f50c9dbd549	I've got some friends in the lab today, can you tell us a joke?	\N	english	f	2025-05-06 15:27:10.649915
20	2341f77a-b9af-432d-8c91-51c89060ee8d	What do you see?	\N	english	f	2025-05-06 19:44:44.786928
21	2341f77a-b9af-432d-8c91-51c89060ee8d	What do you see?	\N	english	f	2025-05-06 19:45:51.3539
22	2341f77a-b9af-432d-8c91-51c89060ee8d	Could you tell us a joke?	\N	english	f	2025-05-06 19:47:05.555131
23	8054c903-a92f-40a6-b305-e15becb88bd4	what do you see	\N	english	f	2025-05-07 07:16:35.61467
24	41b66b1b-6f80-49b6-958c-caf1f9cff325	Reset Memory	\N	english	f	2025-05-07 07:17:41.578697
25	41b66b1b-6f80-49b6-958c-caf1f9cff325	Reset Memory	\N	english	f	2025-05-07 07:17:56.153719
26	41b66b1b-6f80-49b6-958c-caf1f9cff325	What do you see?	\N	english	f	2025-05-07 07:18:10.5672
27	8df9ae35-258c-411e-8042-c22546ab92ad	I have a team of visitors in the lab today. Can you help them understand what the project is all about?	\N	english	f	2025-05-07 07:20:47.924838
28	8df9ae35-258c-411e-8042-c22546ab92ad	Could you sort the slides in the order of the green slide and then the orange slide?	\N	english	f	2025-05-07 07:22:03.023008
29	6139f375-2313-4c25-9eed-a52c0a2d941b	What do you see in this scene?	\N	english	f	2025-05-07 07:34:48.699286
30	0ac711ef-a2d0-4f71-ab86-f6572387f48b	What do you see on the table?	\N	english	f	2025-05-07 07:40:12.388855
31	43f7670d-f78f-4c44-920c-50096d80b56e	What do you see on the table?	\N	english	f	2025-05-07 07:42:59.4793
32	d1a5360d-24ba-43d8-8e0e-b19733dd8070	What do you see on the TV?	\N	english	f	2025-05-07 07:45:39.887171
33	97842c1b-36b9-4824-9346-f0d1fb7f1ab2	What do you see in this scene?	\N	latin	f	2025-05-07 07:55:18.100703
34	97842c1b-36b9-4824-9346-f0d1fb7f1ab2	What do you see in this scene?	\N	latin	f	2025-05-07 07:57:49.61321
35	97842c1b-36b9-4824-9346-f0d1fb7f1ab2	What do you see in this scene?	\N	latin	f	2025-05-07 07:58:04.784626
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 2535, true);


--
-- Name: drop_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.drop_op_parameters_sequence_id_seq', 2, true);


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

SELECT pg_catalog.setval('public.operation_sequence_id_seq', 54, true);


--
-- Name: pick_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.pick_op_parameters_sequence_id_seq', 18, true);


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

SELECT pg_catalog.setval('public.sort_order_order_id_seq', 19, true);


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

SELECT pg_catalog.setval('public.travel_op_parameters_sequence_id_seq', 18, true);


--
-- Name: unified_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.unified_instructions_id_seq', 7, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.users_user_id_seq', 22, true);


--
-- Name: voice_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.voice_instructions_id_seq', 35, true);


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
-- Name: operation_library operation_library_operation_name_key; Type: CONSTRAINT; Schema: public; Owner: oscar
--

ALTER TABLE ONLY public.operation_library
    ADD CONSTRAINT operation_library_operation_name_key UNIQUE (operation_name);


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

