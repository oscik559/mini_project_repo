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
26301	square_1	green	{0,0,0}	15.73	35.31	1.25	0	0	0	Cube.usd	2025-05-28 08:43:12.986773
26302	circle_1	red	{0,0,0}	9.28	30.75	1.25	0	0	90	Cylinder.usd	2025-05-28 08:43:12.988394
26303	circle_2	blue	{0,0,0}	15.53	26.48	1.25	0	0	90	Cylinder.usd	2025-05-28 08:43:12.989409
\.


--
-- Data for Name: drop_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.drop_op_parameters (sequence_id, operation_order, object_id, drop_height, drop_pos_x, drop_pos_y, drop_pos_z, operation_status) FROM stdin;
39	1	slide_2	0	\N	\N	\N	t
40	2	slide_1	0	\N	\N	\N	t
\.


--
-- Data for Name: gesture_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.gesture_instructions (id, session_id, "timestamp", gesture_text, natural_description, confidence, hand_label, processed) FROM stdin;
1	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:15:32.905361	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9842816	Right	f
2	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:15:34.811182	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.9898993	Right	f
3	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:15:35.950946	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.989912	Right	f
4	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:15:37.561384	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.99288595	Right	f
5	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:15:38.221952	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.99253964	Right	f
6	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:15:50.567213	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9417579	Right	f
7	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:15:52.22057	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.9914149	Right	f
8	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:15:59.87974	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9487335	Right	f
9	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:00.956862	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.98007095	Right	f
10	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:02.907341	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9815587	Right	f
11	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:04.413453	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.9931382	Right	f
12	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:06.290262	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.9952887	Right	f
13	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:09.211782	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.9093009	Right	f
14	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:10.456687	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.98794574	Right	f
15	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:12.476396	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.94988346	Right	f
16	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:13.414836	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.98335	Right	f
17	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:26.49546	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.623464	Right	f
18	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:28.49692	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.95340633	Right	f
19	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:28.876054	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.99623805	Right	f
20	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:30.077775	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 1 fingers are open.	0.99581945	Right	f
21	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:32.093124	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9763803	Right	f
22	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:34.159546	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9743709	Right	f
23	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:35.968038	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.9825663	Right	f
24	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:36.900499	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.9911978	Right	f
25	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:50.971793	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.9844082	Left	f
26	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:51.05869	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99402153	Left	f
27	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:51.113172	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9986409	Right	f
28	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:51.113172	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99295396	Left	f
29	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:51.219389	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 1 fingers are open.	0.98829055	Left	f
30	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:51.296975	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99237394	Right	f
31	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:51.296975	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 1 fingers are open.	0.98575956	Left	f
32	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:51.3596	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9881999	Right	f
33	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:51.360599	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 1 fingers are open.	0.9875902	Left	f
34	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:51.423071	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 2 fingers are open.	0.97519314	Right	f
35	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:51.423071	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 0 fingers are open.	0.9906502	Left	f
36	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:53.43869	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 3 fingers are open.	0.98926914	Right	f
37	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:54.199653	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.99700564	Right	f
38	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:54.199653	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.992851	Left	f
39	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:54.266641	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9889194	Left	f
40	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:55.238863	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.87406075	Right	f
41	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:55.539518	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9551579	Left	f
42	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:57.558878	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 1 fingers are open.	0.9868364	Left	f
43	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:57.713916	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.99389493	Left	f
44	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:59.755988	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.98750985	Left	f
45	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:16:59.819821	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 1 fingers are open.	0.99096745	Left	f
46	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:01.62055	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.9596119	Left	f
47	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:04.599434	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.8706029	Left	f
48	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:13.323884	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 1 fingers are open.	0.9530665	Right	f
49	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:13.476887	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.6397997	Right	f
50	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:14.482238	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.6810418	Right	f
51	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:14.482238	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.954734	Left	f
52	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:14.816619	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.7329291	Right	f
53	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:14.869178	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.769524	Right	f
54	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.369913	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9107218	Left	f
55	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.369913	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.8625986	Right	f
56	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.433593	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.7667861	Left	f
57	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.433593	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 3 fingers are open.	0.8948304	Right	f
58	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.518112	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 3 fingers are open.	0.9280967	Left	f
59	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.519325	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 3 fingers are open.	0.9940304	Right	f
60	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.58283	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 3 fingers are open.	0.8921922	Left	f
61	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.58283	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 2 fingers are open.	0.9975099	Right	f
62	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.649443	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.86794347	Left	f
63	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.775023	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 1 fingers are open.	0.5214001	Left	f
64	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.850475	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9585703	Left	f
65	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.850475	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 3 fingers are open.	0.9944723	Right	f
66	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.916299	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.92954	Left	f
67	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.916299	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.99889874	Right	f
68	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.98466	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9919088	Left	f
69	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:15.98466	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.76864165	Right	f
70	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:16.052333	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.99168384	Left	f
71	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:16.053333	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.60205543	Left	f
72	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:16.099885	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.93777585	Left	f
73	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:16.252513	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.92713845	Right	f
74	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:16.379851	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.99892676	Right	f
75	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:16.447078	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9917982	Right	f
76	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:16.534366	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.99797064	Right	f
77	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:16.726234	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.996732	Right	f
78	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:16.726234	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9928478	Right	f
79	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:16.87572	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.8728668	Right	f
80	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:18.037869	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is down and 3 fingers are open.	0.951537	Right	f
81	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:18.134882	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.8593229	Right	f
82	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:18.186035	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is down and 2 fingers are open.	0.88004136	Left	f
83	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:21.204209	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.997585	Right	f
84	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:21.32482	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99442476	Right	f
85	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:21.871222	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9969468	Right	f
86	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:21.923814	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9967829	Right	f
87	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:21.975858	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99715585	Right	f
88	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:22.124526	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99725556	Right	f
89	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:22.267855	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9978424	Right	f
90	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:22.330752	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9951306	Right	f
91	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:22.380922	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99790335	Right	f
92	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:22.456105	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9953353	Right	f
93	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:22.670408	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99782145	Right	f
94	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:22.732661	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9941817	Right	f
95	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:23.183387	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99722874	Right	f
96	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:23.248583	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99653554	Right	f
97	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:23.311494	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9977213	Right	f
98	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:23.501039	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9965923	Right	f
99	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:23.77027	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99681646	Right	f
100	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:24.048216	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9976086	Right	f
101	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:24.111956	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9978251	Right	f
102	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:24.17875	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9968809	Right	f
103	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:24.58814	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99733263	Right	f
104	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:24.65483	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9973033	Right	f
105	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:24.721075	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9967237	Right	f
106	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:24.853474	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9966918	Right	f
107	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:25.053196	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99712247	Right	f
108	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:25.184952	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9267224	Right	f
109	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:25.337709	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.98954004	Right	f
110	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:25.67203	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is down and 2 fingers are open.	0.9761448	Right	f
111	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:25.741092	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.82561386	Right	f
112	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.225348	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.78794676	Left	f
113	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.298684	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.88246	Left	f
114	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.346469	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 4 fingers are open.	0.9786003	Right	f
115	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.346469	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.73923546	Right	f
116	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.412206	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 4 fingers are open.	0.97813225	Right	f
117	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.412206	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.83893156	Left	f
118	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.488736	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 4 fingers are open.	0.98571247	Right	f
119	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.488736	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.88173383	Left	f
120	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.545424	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 4 fingers are open.	0.98720545	Right	f
121	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.545424	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.67375124	Left	f
122	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.631006	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 4 fingers are open.	0.98707193	Right	f
123	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.631006	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.7748118	Left	f
124	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.694301	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 4 fingers are open.	0.9572857	Right	f
125	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.694301	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.90742534	Left	f
126	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.758245	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9896384	Right	f
127	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.760452	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9040957	Left	f
128	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.812027	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9816108	Right	f
129	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.8232	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.8947395	Left	f
130	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.878712	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9837266	Right	f
131	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.878712	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.8992393	Left	f
132	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.961451	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9839884	Right	f
133	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:29.961451	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.90919816	Left	f
134	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.017195	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.98231024	Right	f
135	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.023469	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9260441	Left	f
136	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.094634	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.98557377	Right	f
137	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.094634	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9323308	Left	f
138	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.160882	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.96912557	Right	f
139	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.161894	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.92223084	Left	f
140	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.213914	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.96317077	Right	f
141	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.213914	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9139264	Left	f
142	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.302936	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.8801659	Right	f
143	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.303704	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.8975695	Left	f
144	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.350247	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9694476	Right	f
145	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.350247	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.8743032	Left	f
146	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.400348	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.95176935	Right	f
147	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.400348	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.89316696	Left	f
148	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:30.978465	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.89705193	Left	f
149	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.049711	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.96978724	Right	f
150	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.049711	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.8841143	Left	f
151	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.103917	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9716284	Right	f
152	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.104722	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.8873923	Left	f
153	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.151212	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9620706	Right	f
154	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.151212	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.90179956	Left	f
155	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.201259	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9873302	Right	f
156	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.201259	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.88699496	Left	f
157	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.313135	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 2 fingers are open.	0.8680189	Left	f
158	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.313135	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.52794147	Right	f
159	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.361749	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 1 fingers are open.	0.8681275	Left	f
160	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.478066	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9916025	Right	f
161	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.527618	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9955769	Right	f
162	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.613306	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.991319	Right	f
163	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.679854	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9896465	Right	f
164	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.810066	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9380341	Right	f
165	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:31.943965	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 4 fingers are open.	0.99660075	Right	f
166	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:33.22647	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 4 fingers are open.	0.99292976	Right	f
167	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:33.691779	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 4 fingers are open.	0.98553604	Right	f
168	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:17:34.033339	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 3 fingers are open.	0.8851857	Right	f
169	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:00.51466	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9903192	Right	f
170	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:00.732038	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9767182	Right	f
171	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:01.720389	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9454737	Left	f
172	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:03.08393	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.8046143	Left	f
173	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:03.126026	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.6463583	Left	f
174	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:04.092613	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9996205	Right	f
175	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:04.236873	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9996714	Right	f
176	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:04.34	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9914497	Right	f
177	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:05.540222	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9635166	Right	f
178	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:05.791908	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.82872593	Right	f
179	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:06.467664	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9613032	Right	f
180	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:06.589703	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 3 fingers are open.	0.98110384	Right	f
181	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:06.714903	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 2 fingers are open.	0.97570604	Right	f
182	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:06.841126	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 2 fingers are open.	0.9745582	Right	f
183	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:07.057764	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.96037954	Right	f
184	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:07.258224	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.7983787	Left	f
185	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:07.329991	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.59779847	Left	f
186	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:07.519114	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.98652637	Right	f
187	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:07.724071	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 4 fingers are open.	0.98189753	Right	f
188	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:08.126248	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9589094	Right	f
189	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:08.199113	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.8136458	Right	f
190	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:08.869647	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9725239	Right	f
191	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:15.092351	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 4 fingers are open.	0.97402674	Right	f
192	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:17.236651	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 3 fingers are open.	0.95232385	Right	f
193	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:17.431919	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.724342	Left	f
194	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:17.431919	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9920369	Left	f
195	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:17.483958	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.74732184	Right	f
196	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:17.483958	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.91925013	Left	f
197	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:17.966324	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.59577703	Right	f
198	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:19.58721	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.8949153	Right	f
199	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:19.730144	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.88201845	Right	f
200	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:23.751835	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.912534	Right	f
201	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:25.790017	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.98490196	Right	f
202	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:26.3141	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.6831703	Left	f
203	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:30.519043	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.76930404	Right	f
204	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:40.247766	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.9389499	Left	f
205	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:40.781556	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.8145758	Right	f
206	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:40.86427	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 0 fingers are open.	0.9675377	Right	f
207	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:50.411219	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.76652974	Left	f
208	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:59.390646	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 2 fingers are open.	0.9481077	Right	f
209	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:18:59.880127	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.95956606	Right	f
210	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:07.36848	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.872177	Right	f
211	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:07.47704	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 1 fingers are open.	0.9889836	Right	f
212	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:07.965682	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 4 fingers are open.	0.9267733	Right	f
213	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:08.016034	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is up and 4 fingers are open.	0.8196652	Right	f
214	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:17.69118	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.94912964	Left	f
215	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:59.068692	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.97384375	Right	f
216	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:59.071268	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is up and 0 fingers are open.	0.9352289	Left	f
217	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:59.127629	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.7892367	Right	f
218	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:59.232964	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.97335184	Right	f
219	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:59.296268	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.87057316	Left	f
220	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:59.296682	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9737713	Right	f
221	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:59.339551	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9029805	Left	f
222	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:59.535771	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 1 fingers are open.	0.95465815	Left	f
223	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:59.924905	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 3 fingers are open.	0.9294662	Left	f
224	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:19:59.994992	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 3 fingers are open.	0.9282636	Left	f
225	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:00.141354	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 3 fingers are open.	0.9863823	Right	f
226	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:00.482636	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.8861276	Right	f
227	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:00.596759	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.67745686	Right	f
228	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:00.679465	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.6480526	Left	f
229	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.270403	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9117874	Left	f
230	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.328146	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9802973	Right	f
231	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.388847	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9854881	Left	f
232	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.468329	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.98737967	Right	f
233	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.475258	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9922844	Left	f
234	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.51946	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.98716605	Right	f
235	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.51946	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.98130375	Left	f
236	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.575083	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.980484	Right	f
237	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.575083	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.97100407	Left	f
238	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.652742	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9740894	Right	f
239	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.933669	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.97727346	Right	f
240	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.933669	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.7891469	Left	f
241	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.990402	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.834917	Right	f
242	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:01.990402	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.76537204	Left	f
243	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.274735	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.8097889	Left	f
244	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.27648	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.7598076	Left	f
245	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.337164	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.50300443	Left	f
246	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.337164	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.7701117	Left	f
247	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.39239	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.6134783	Left	f
248	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.39239	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.7031282	Left	f
249	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.47467	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.6495408	Left	f
250	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.47467	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.8014026	Left	f
251	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.575819	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.8170598	Right	f
252	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.576817	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.79294133	Left	f
253	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.637437	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.9178765	Right	f
254	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.637437	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.91211134	Left	f
255	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.703386	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.9128811	Right	f
256	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.703386	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9384578	Left	f
257	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.754517	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.7445786	Right	f
258	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.754517	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.84608036	Left	f
259	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.836904	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.93713725	Right	f
260	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.836904	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9549343	Left	f
261	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.905325	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.9327322	Right	f
262	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.905325	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9690252	Left	f
263	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.971286	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.9297884	Right	f
264	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:02.975885	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.976016	Left	f
265	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.037143	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 0 fingers are open.	0.9827235	Right	f
266	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.039617	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9708216	Left	f
267	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.088974	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.8891356	Right	f
268	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.088974	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9681464	Left	f
269	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.182172	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.94484216	Right	f
270	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.182172	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9888174	Left	f
271	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.238083	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.8593515	Right	f
272	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.238083	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99061036	Left	f
273	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.468127	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.98552155	Left	f
274	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.53781	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.58866644	Right	f
275	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.538277	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.91290426	Left	f
276	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.735446	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 2 fingers are open.	0.642908	Left	f
277	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.856357	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.7809635	Right	f
278	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:03.923325	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 3 fingers are open.	0.9854388	Right	f
279	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:04.854917	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.996484	Right	f
280	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:05.264342	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 3 fingers are open.	0.9985399	Right	f
281	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:05.334651	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 3 fingers are open.	0.99892515	Right	f
282	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:05.791495	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.98774683	Right	f
283	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:05.80154	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99539363	Right	f
284	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:07.059331	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.98402053	Right	f
285	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:07.061328	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9982186	Right	f
286	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:08.392484	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9447096	Right	f
287	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:08.392484	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9980501	Right	f
288	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:09.32526	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.95141006	Right	f
289	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:09.340273	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9978341	Right	f
290	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:09.551092	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9345888	Right	f
291	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:09.551092	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99851125	Right	f
292	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:09.677431	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.97247666	Right	f
293	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:09.677431	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9978262	Right	f
294	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:09.79314	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.955841	Right	f
295	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:09.79314	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.998112	Right	f
296	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:09.92576	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9636052	Right	f
297	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:09.92576	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9977884	Right	f
298	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:10.25948	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9639441	Right	f
299	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:10.275168	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99799705	Right	f
300	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:10.391668	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.932024	Right	f
301	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:10.391668	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99809635	Right	f
302	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:10.60435	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9829339	Right	f
303	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:10.60435	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9983241	Right	f
304	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:11.126187	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.97167695	Right	f
305	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:11.126187	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99746746	Right	f
306	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:11.449305	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.97334456	Right	f
307	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:11.451353	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99790007	Right	f
308	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:11.705267	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9826542	Right	f
309	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:11.721342	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9970929	Right	f
310	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:13.65674	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.99126303	Right	f
311	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:15.6625	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9837334	Right	f
312	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:17.18718	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99735826	Right	f
313	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:17.266074	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.9969548	Right	f
314	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:17.674158	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.94718933	Left	f
315	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:17.674158	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.98933226	Right	f
316	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.064057	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9014749	Left	f
317	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.300011	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9616537	Left	f
318	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.300011	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9855109	Left	f
319	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.416234	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.90213406	Right	f
320	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.416234	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9863877	Left	f
321	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.467333	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.9310979	Right	f
322	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.467333	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.94026554	Left	f
323	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.521634	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.86431223	Right	f
324	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.521634	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.97058517	Left	f
325	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.600013	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.7849168	Right	f
326	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.649434	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9983242	Right	f
327	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.766113	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.84146297	Right	f
328	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.766113	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.92010397	Right	f
329	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.850079	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.9803981	Right	f
330	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.947765	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9805259	Left	f
331	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:18.947765	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.9457822	Right	f
332	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:19.001052	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.97533935	Left	f
333	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:19.001052	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.9978959	Right	f
334	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:19.058771	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9385994	Left	f
335	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:19.527237	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9132986	Left	f
336	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:19.978386	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9274701	Left	f
337	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:20.048851	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.910412	Left	f
338	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:20.107403	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9084511	Left	f
339	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:20.174324	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.86873734	Left	f
340	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:20.661159	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9723164	Left	f
341	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:20.956836	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 2 fingers are open.	0.9774097	Right	f
342	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:21.146641	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is up and 0 fingers are open.	0.7476476	Right	f
343	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:21.146641	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 2 fingers are open.	0.99396574	Right	f
344	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:21.201764	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.58392704	Left	f
345	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:21.201764	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 2 fingers are open.	0.9912808	Right	f
346	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:22.252956	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 3 fingers are open.	0.9909411	Right	f
347	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:22.264797	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 3 fingers are open.	0.86398065	Left	f
348	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:23.394424	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.8313478	Right	f
349	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:23.4371	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99944675	Right	f
350	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:23.4371	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.98140645	Right	f
351	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:23.50312	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9990681	Right	f
352	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:23.680787	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9946717	Right	f
353	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:23.813992	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is down and 4 fingers are open.	0.5316202	Left	f
354	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:23.813992	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99606323	Right	f
355	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:23.936897	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.61613584	Left	f
356	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:24.000279	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.6189593	Right	f
357	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:24.170518	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.67608964	Right	f
358	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:24.243165	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 2 fingers are open.	0.9663428	Left	f
359	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:24.39051	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.6258309	Right	f
360	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:24.454426	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.92190194	Left	f
361	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:24.650541	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.8645112	Right	f
362	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:24.72152	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.87333024	Right	f
363	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:45.5438	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.98420835	Left	f
364	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:47.568359	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9920544	Left	f
365	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:49.612936	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99142665	Left	f
366	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:51.624742	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.98546404	Left	f
367	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:53.700585	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.98209953	Left	f
368	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:55.574605	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.96063584	Right	f
369	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:55.6378	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.9847452	Left	f
370	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:55.691788	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 1 fingers are open.	0.9886364	Right	f
371	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:55.691788	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.8989456	Right	f
372	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:55.835861	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.8040924	Left	f
373	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:55.835861	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 2 fingers are open.	0.9971466	Right	f
374	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:55.896934	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 4 fingers are open.	0.74991065	Left	f
375	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:55.896934	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 3 fingers are open.	0.9627889	Right	f
376	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:55.948116	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.53059757	Right	f
377	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:55.948116	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.97232103	Right	f
378	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:56.00243	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.98033595	Right	f
379	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:56.231567	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9588658	Right	f
380	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:57.94866	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 2 fingers are open.	0.9916511	Right	f
381	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:58.015553	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 3 fingers are open.	0.7797956	Right	f
382	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:58.076772	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.98762345	Right	f
383	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:58.146497	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9447728	Right	f
384	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:58.3487	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9859907	Right	f
385	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:59.349152	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.9503431	Right	f
386	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:59.537909	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.97835284	Left	f
387	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:59.663184	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.66786766	Left	f
388	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:59.663184	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9976318	Right	f
389	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:59.782824	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.97620153	Left	f
390	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:59.844903	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.98914737	Right	f
391	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:59.89059	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.91156113	Left	f
392	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:59.89059	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9951166	Right	f
393	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:59.967353	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.927962	Left	f
394	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:20:59.968352	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99507415	Right	f
395	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.026727	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.94775325	Left	f
396	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.026727	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.99619967	Right	f
397	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.084298	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.6090841	Left	f
398	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.084298	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9935884	Right	f
399	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.156383	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.86013687	Left	f
400	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.156383	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9811273	Right	f
401	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.220985	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.7672827	Left	f
402	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.220985	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9962089	Right	f
403	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.354491	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.99573034	Right	f
404	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.413123	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.94597226	Left	f
405	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.827005	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.6617657	Right	f
406	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.892945	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9603148	Left	f
407	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:00.979575	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.8354921	Right	f
408	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:01.026786	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9028407	Left	f
409	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:01.381286	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9923524	Right	f
410	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:01.381286	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9515587	Left	f
411	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:01.438459	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 2 fingers are open.	0.9742303	Right	f
412	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:01.439924	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.96230674	Left	f
413	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:01.48572	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 1 fingers are open.	0.9968643	Right	f
414	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:01.48572	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9533973	Left	f
415	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:01.745531	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9265267	Left	f
416	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:04.240702	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9850641	Left	f
417	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:06.266188	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.95093936	Left	f
418	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:08.289548	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9569566	Left	f
419	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:10.346753	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.93785805	Left	f
420	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:12.360562	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.94602966	Left	f
421	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:14.413365	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.915467	Left	f
422	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:15.335497	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.89635706	Left	f
423	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:15.413259	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.79057574	Left	f
424	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:16.363175	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.84737086	Left	f
425	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:16.421771	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.8343592	Right	f
426	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:17.097921	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.89752585	Left	f
427	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:17.097921	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.65105724	Right	f
428	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:17.932161	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.9554248	Left	f
429	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:17.998732	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.86413515	Left	f
430	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:18.224174	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.95389986	Left	f
431	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:18.411298	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9240648	Left	f
432	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:18.817574	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.59780407	Right	f
433	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:21:28.616248	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.69286907	Right	f
434	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:11.76734	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.9821172	Right	f
435	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:24.108609	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.90744	Left	f
436	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:24.152163	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.8008607	Left	f
437	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:24.616384	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.8474587	Left	f
438	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:24.69673	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.7815736	Left	f
439	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:49.840671	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.8299626	Left	f
440	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:50.18164	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 4 fingers are open.	0.96968	Left	f
441	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:50.302867	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9795011	Left	f
442	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:50.415869	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.98969996	Left	f
443	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:51.317278	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.7496975	Left	f
444	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:51.370018	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.98394614	Left	f
445	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:51.417118	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.95946026	Left	f
446	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:22:57.159677	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.54464674	Right	f
447	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:23:51.686733	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 0 fingers are open.	0.8996927	Left	f
448	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:23:51.756533	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.81950676	Left	f
449	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:23:51.993884	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9733671	Left	f
450	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:23:52.075478	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.56613356	Left	f
451	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:23:52.07642	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.90601176	Left	f
452	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:23:53.158937	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 4 fingers are open.	0.9663942	Left	f
453	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:23:54.183036	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is up and 0 fingers are open.	0.9302824	Left	f
454	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:26:00.399108	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9885473	Right	f
455	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:26:06.987533	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.98876095	Right	f
456	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:28:06.092181	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.90994185	Right	f
457	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:28:06.149353	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 0 fingers are open.	0.9810053	Right	f
458	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:28:06.266122	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9501922	Right	f
459	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:28:06.74537	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.96025914	Right	f
460	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:28:06.813113	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.950528	Right	f
461	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:28:07.083279	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.953538	Right	f
462	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:28:07.149632	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is up and 0 fingers are open.	0.67635745	Right	f
463	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:28:07.214571	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.95868313	Right	f
464	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:28:07.27864	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 0 fingers are open.	0.80417967	Right	f
465	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:28:07.357357	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is up and 0 fingers are open.	0.88983774	Left	f
466	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:28:07.432181	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 1 fingers are open.	0.56609666	Right	f
467	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:29:26.900364	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 1 fingers are open.	0.9878725	Right	f
468	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:29:28.116634	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.686419	Right	f
469	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:29:28.429766	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9992385	Right	f
470	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:36.446585	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.96021765	Right	f
471	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:38.476449	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.9387398	Right	f
472	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:38.535418	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9285285	Right	f
473	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:57.374086	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.6785592	Right	f
474	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:57.481265	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.5215579	Left	f
475	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:57.633548	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.5373054	Right	f
476	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:57.707488	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.658676	Right	f
477	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:57.767248	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.80614734	Right	f
478	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:58.459473	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.8615826	Left	f
479	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:58.517795	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.64989966	Left	f
480	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:58.558411	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.7812073	Right	f
481	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:58.678954	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.5953487	Right	f
482	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:58.805486	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.5296524	Left	f
483	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:30:58.875109	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9903864	Right	f
484	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:01.902302	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.90210485	Left	f
485	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:02.148952	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.710262	Right	f
486	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:02.205837	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.9043571	Right	f
487	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:02.294532	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.6773608	Left	f
488	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:02.871651	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.8885575	Right	f
489	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:03.008264	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.81904787	Right	f
490	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:03.147336	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.6212028	Left	f
491	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:03.49881	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.84138286	Right	f
492	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:03.554053	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.6684489	Right	f
493	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:06.854793	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 0 fingers are open.	0.9943277	Left	f
494	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:06.968735	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9920402	Left	f
495	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:07.177839	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 0 fingers are open.	0.98551816	Left	f
496	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:07.492236	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.6267804	Left	f
497	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:07.599239	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9929904	Left	f
498	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:07.847787	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.9926524	Left	f
499	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:08.920998	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9772579	Left	f
500	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:08.98501	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.98864126	Left	f
501	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:09.726112	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9949809	Left	f
502	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:12.124879	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.989517	Left	f
503	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:25.388029	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.99283737	Left	f
504	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:25.452121	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.96375614	Left	f
505	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:25.516057	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.95955586	Left	f
506	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:27.59984	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.919098	Left	f
507	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:29.65987	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.96259826	Left	f
508	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:29.730573	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.97058535	Left	f
509	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:30.660248	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9792438	Left	f
510	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:30.729453	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.988634	Left	f
511	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:31.117697	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.98176533	Left	f
512	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:31.337834	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.97815347	Left	f
513	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:31.679496	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9853387	Left	f
514	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:31.730694	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.98290265	Left	f
515	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:32.311076	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9726198	Left	f
516	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:32.382791	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.96554863	Left	f
517	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:32.711611	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.97542065	Left	f
518	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:32.778891	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9521912	Left	f
519	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:34.791154	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9630247	Left	f
520	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:36.844369	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.91389966	Left	f
521	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:55.12533	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.98386174	Right	f
522	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:55.389162	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 1 fingers are open.	0.9541835	Right	f
523	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:56.394765	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.993882	Right	f
524	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:57.266886	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.99870044	Right	f
525	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:57.339734	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.98620397	Left	f
526	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:57.339734	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.99621737	Right	f
527	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:57.392104	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 0 fingers are open.	0.98186165	Left	f
528	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:57.392104	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 0 fingers are open.	0.99347097	Right	f
529	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:31:58.709411	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9030548	Left	f
530	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:33:45.269724	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 1 fingers are open.	0.5432211	Right	f
531	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:33:45.628147	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 1 fingers are open.	0.9830203	Left	f
532	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:06.754366	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 1 fingers are open.	0.9931048	Left	f
533	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:45.341974	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.8891432	Left	f
534	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:45.574745	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.8539303	Right	f
535	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:45.644651	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 0 fingers are open.	0.8865939	Right	f
536	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:45.764718	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is up and 0 fingers are open.	0.8177388	Right	f
537	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:45.862144	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 0 fingers are open.	0.94091725	Right	f
538	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:45.911165	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is up and 0 fingers are open.	0.7260256	Right	f
539	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:45.994653	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is up and 0 fingers are open.	0.990324	Right	f
540	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:45.995407	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is down and 0 fingers are open.	0.60592294	Left	f
541	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:46.054405	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 0 fingers are open.	0.9601122	Right	f
542	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:46.054405	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is up and 3 fingers are open.	0.82391846	Right	f
543	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:46.11165	Grab	The hand is clenched into a fist, a posture often associated with grabbing or assertiveness. Additionally, the thumb is up and 0 fingers are open.	0.6825475	Right	f
544	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:46.229979	OK	The thumb and index finger are touching to form a circle, commonly known as the OK sign. Additionally, the thumb is down and 3 fingers are open.	0.5534457	Left	f
545	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:46.312487	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.5619664	Right	f
546	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:34:46.443494	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.9666163	Right	f
547	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:04.732908	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.97859263	Left	f
548	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:06.53163	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.98886853	Left	f
549	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:06.646423	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.95492643	Right	f
550	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:06.773285	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9943892	Right	f
551	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:07.611323	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is down and 4 fingers are open.	0.95355815	Right	f
552	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:08.925071	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9833761	Right	f
553	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:09.055903	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9850171	Right	f
554	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:09.591565	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.99494016	Right	f
555	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:10.00544	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9930009	Right	f
556	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:10.071879	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is up and 4 fingers are open.	0.9941605	Right	f
557	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:10.396257	Stop	All fingers are extended, showing an open hand posture which may signal a stop command. Additionally, the thumb is up and 4 fingers are open.	0.9875833	Right	f
558	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:12.95192	Select Object	The index finger is extended while the other fingers remain curled, suggesting the user is pointing. Additionally, the thumb is down and 0 fingers are open.	0.55122113	Right	f
559	890c673d-f45e-486b-a187-2c4c318aa025	2025-05-07 10:35:13.110002	Approval	The thumb is raised above the index finger, indicating a thumbs-up or approval gesture. Additionally, the thumb is down and 0 fingers are open.	0.64199626	Left	f
\.


--
-- Data for Name: gesture_library; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.gesture_library (id, gesture_type, gesture_text, natural_description, config) FROM stdin;
1	thumbs_up	Approval	The thumb is raised above the index finger.	{"threshold": 0.0}
2	open_hand	Stop	All fingers are extended, signaling stop.	{"threshold": 0.0}
3	pointing	Select Object	The index finger is extended while other fingers are curled.	{"threshold": 0.0}
4	closed_fist	Grab	The hand is clenched into a fist.	{"threshold": 0.0}
5	victory	Confirm	The hand forms a V-shape with the index and middle fingers extended.	{"threshold": 0.0}
6	ok_sign	OK	The thumb and index finger are touching to form a circle.	{"threshold": 0.05}
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
1	2025-05-07 10:13:15.07466	1	voice	en	command	f	Pick up object	\N	0.95
2	2025-05-07 10:13:15.07466	2	text	en	command	f	Place object	\N	0.9
\.


--
-- Data for Name: interaction_memory; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.interaction_memory (interaction_id, user_id, instruction_id, interaction_type, data, start_time, end_time, "timestamp") FROM stdin;
1	1	1	task_query	{"task": "Pick Object"}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-05-07 10:13:15.07466
2	2	1	preference_update	{"preference": {"time": "morning"}}	2023-10-01 09:00:00	2023-10-01 17:00:00	2025-05-07 10:13:15.07466
3	1	2	task_execution	{"status": "success", "task": "Place Object"}	2023-10-02 09:00:00	2023-10-02 17:00:00	2025-05-07 10:13:15.07466
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
1	slide_sorting	pick, travel, drop	Sort slides by shape and color into trays	{sort,slides,slide,sorting,tray,"sort slides"}	detect_slides_pgSQL.py	t	f	idle	2025-05-27 14:46:00.673689
2	shape_stacking	pick, travel, drop	Stack blocks of shapes based on their type and color	{stack,stacking,shapes,shape,"shape stacking"}	detect_shapes_pgSQL.py	t	t	triggered	2025-05-27 14:55:44.374668
\.


--
-- Data for Name: operation_sequence; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.operation_sequence (id, operation_id, sequence_id, sequence_name, object_name, command_id, processed, execution_time) FROM stdin;
290	1	1	pick	square_1	52	f	2025-05-27 14:57:37.030653
291	2	2	travel	square_1	52	f	2025-05-27 14:57:37.030653
292	3	3	drop	square_1	52	f	2025-05-27 14:57:37.030653
293	4	1	pick	circle_2	52	f	2025-05-27 14:57:37.030653
294	5	2	travel	circle_2	52	f	2025-05-27 14:57:37.030653
295	6	3	drop	circle_2	52	f	2025-05-27 14:57:37.030653
296	7	1	pick	circle_1	52	f	2025-05-27 14:57:37.030653
297	8	2	travel	circle_1	52	f	2025-05-27 14:57:37.030653
298	9	3	drop	circle_1	52	f	2025-05-27 14:57:37.030653
299	10	6	go_home		52	f	2025-05-27 14:57:37.030653
\.


--
-- Data for Name: pick_op_parameters; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.pick_op_parameters (sequence_id, operation_order, object_id, slide_state_status, slide_direction, distance_travel, operation_status) FROM stdin;
85	1	square_1	t	y	0.01	t
86	2	circle_2	t	y	0.01	t
87	3	circle_1	t	y	0.01	t
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
1	1	t	{"accuracy": 0.95, "time_taken": 2.5}	No errors	2025-05-07 10:13:15.07466
2	2	f	{"accuracy": 0.8, "time_taken": 3.0}	Gripper misalignment	2025-05-07 10:13:15.07466
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
87	square_1	green
88	circle_2	blue
89	circle_1	red
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
85	1	square_1	0.085	z-axis	t
86	2	circle_2	0.085	z-axis	t
87	3	circle_1	0.085	z-axis	t
\.


--
-- Data for Name: unified_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.unified_instructions (id, session_id, "timestamp", liu_id, voice_command, gesture_command, unified_command, confidence, processed) FROM stdin;
1	session_voice_001	2025-05-09 07:58:22.394101	oscik559	sort the slides in order of orange slide and then green slide		sort the slides in order of orange slide and then green slide	0.95	t
2	session_voice_001	2025-05-09 08:38:17.927662	oscik559	Sort the slides in order of orange slide and then green slide		Sort the slides in order of orange slide and then green slide	0.95	t
3	session_voice_001	2025-05-09 08:38:29.112849	oscik559	Sort the slides in order of orange slide and then green slide		Sort the slides in order of orange slide and then green slide	0.95	t
4	session_voice_001	2025-05-09 15:13:10.965236	oscik559	sort the slides in the order of green, orange		sort the slides in the order of green, orange	0.95	t
5	session_voice_001	2025-05-10 01:54:14.274922	oscik559	sort the slides in order of  green slide and orange slide		sort the slides in order of  green slide and orange slide	0.95	t
6	session_voice_001	2025-05-10 01:54:49.519997	oscik559	sort the slides in order of green slide and orange slide and then  finally the pink slide		sort the slides in order of green slide and orange slide and then  finally the pink slide	0.95	t
7	session_voice_001	2025-05-10 03:35:27.872461	oscik559	tell me a joke		tell me a joke	0.95	f
8	session_voice_001	2025-05-10 03:37:45.803621	oscik559	Tell me a joke		Tell me a joke	0.95	f
9	session_voice_001	2025-05-10 04:13:47.596325	oscik559	Now i need to do the same in descending order		Now i need to do the same in descending order	0.95	f
10	session_voice_001	2025-05-10 04:19:24.764485	oscik559	Tell me a joke or sentence with 26 words or more having the start of each word as the letters of the alphabet in ascending order		Tell me a joke or sentence with 26 words or more having the start of each word as the letters of the alphabet in ascending order	0.95	f
11	session_voice_001	2025-05-10 05:04:08.557045	oscik559	tell me a joke about tech companies as characters		tell me a joke about tech companies as characters	0.95	f
12	session_voice_001	2025-05-10 05:04:40.208017	oscik559	tell me a joke about tech companies as characters		tell me a joke about tech companies as characters	0.95	f
13	session_voice_001	2025-05-10 05:05:28.488548	oscik559	tell me a joke about tech companies as characters		tell me a joke about tech companies as characters	0.95	f
14	session_voice_001	2025-05-10 05:10:35.239387	oscik559	tell me how to develop a chatbot for yumi		tell me how to develop a chatbot for yumi	0.95	f
15	session_voice_001	2025-05-10 05:44:55.511409	oscik559	which of the slides can be easily picked up by the robot		which of the slides can be easily picked up by the robot	0.95	f
16	session_voice_001	2025-05-10 05:45:10.700645	oscik559	which of them can be easily picked up by the robot		which of them can be easily picked up by the robot	0.95	f
17	session_voice_001	2025-05-12 08:40:44.965682	oscik559	sort the slides in order of green and pink		sort the slides in order of green and pink	0.95	t
18	session_voice_001	2025-05-12 16:43:42.619806	oscik559	Tell me a tough riddle		Tell me a tough riddle	0.95	f
19	session_voice_001	2025-05-12 21:24:54.768044	oscik559	sort the slides in order of green, pink and orange		sort the slides in order of green, pink and orange	0.95	t
20	session_voice_001	2025-05-12 21:33:01.581582	oscik559	Could you sort the slides in order of the colour names alphabetically		Could you sort the slides in order of the colour names alphabetically	0.95	t
21	session_voice_001	2025-05-12 21:37:07.580057	oscik559	sort the slides in order of green, pink, and orange		sort the slides in order of green, pink, and orange	0.95	t
22	session_voice_001	2025-05-12 22:33:00.936402	oscik559	Good bye		Good bye	0.95	f
23	session_voice_001	2025-05-13 13:23:57.937172	oscik559	Could you sort the slides in the order of the green, the pink and the orange?		Could you sort the slides in the order of the green, the pink and the orange?	0.95	t
24	session_voice_001	2025-05-14 13:33:11.059939	oscik559	I have placed some shapes for stacking in front of you can you find the shapes  or stack		I have placed some shapes for stacking in front of you can you find the shapes  or stack	0.95	t
25	session_voice_001	2025-05-14 13:35:17.194577	oscik559	Can you stack the shapes in the order of the red circle, the green square and the blue circle?		Can you stack the shapes in the order of the red circle, the green square and the blue circle?	0.95	t
26	session_voice_001	2025-05-14 14:00:56.829506	oscik559	just in swedish		just in swedish	0.95	f
27	session_voice_001	2025-05-14 14:30:49.103348	oscik559	stack the shapes in the order of green square, blue circle and red circle		stack the shapes in the order of green square, blue circle and red circle	0.95	t
28	session_voice_001	2025-05-14 14:58:07.474891	oscik559	Could you sort the slides in the order of the green slide and then the orange slide?		Could you sort the slides in the order of the green slide and then the orange slide?	0.95	t
29	session_voice_001	2025-05-14 15:45:35.991995	oscik559	Could you stack the shapes in the order of the green square, the blue circle and the red circle?		Could you stack the shapes in the order of the green square, the blue circle and the red circle?	0.95	t
30	session_voice_001	2025-05-14 22:20:14.415546	oscik559	stack the shapes in the order of the blue cylinder, the green cube, and finally the red cylinder.		stack the shapes in the order of the blue cylinder, the green cube, and finally the red cylinder.	0.95	t
31	session_voice_001	2025-05-15 13:21:49.859454	oscik559	Can you stack the shapes in the order of the green square, the blue circle and the red circle?		Can you stack the shapes in the order of the green square, the blue circle and the red circle?	0.95	t
32	session_voice_001	2025-05-15 15:00:07.280381	oscik559	Could you sort the shapes in the order of the red rectangle, the blue circle and the red circle?		Could you sort the shapes in the order of the red rectangle, the blue circle and the red circle?	0.95	t
33	session_voice_001	2025-05-15 15:06:47.670559	oscik559	Could you sort the shapes in the order of the blue circle and then the red circle?		Could you sort the shapes in the order of the blue circle and then the red circle?	0.95	f
34	session_voice_001	2025-05-15 15:08:18.779678	oscik559	Could you sort the shapes in the order of the blue circle and the red circle?		Could you sort the shapes in the order of the blue circle and the red circle?	0.95	t
35	session_voice_001	2025-05-15 15:17:19.604035	oscik559	Could you stack the shapes in the order of the green square, the blue circle and the red circle?		Could you stack the shapes in the order of the green square, the blue circle and the red circle?	0.95	t
36	session_voice_001	2025-05-15 15:18:11.523067	oscik559	Could you stack the shapes in the order of the green square, the blue circle and the red circle?		Could you stack the shapes in the order of the green square, the blue circle and the red circle?	0.95	t
37	session_voice_001	2025-05-15 15:28:28.824325	oscik559	Could you sort the slides in the order of the orange and then the green?		Could you sort the slides in the order of the orange and then the green?	0.95	t
38	session_voice_001	2025-05-15 15:43:40.886724	oscik559	Could you sort the slides in the order of the green and then the orange?		Could you sort the slides in the order of the green and then the orange?	0.95	t
39	session_voice_001	2025-05-15 16:56:39.81082	oscik559	Could you stack the shapes in the order of the green square, the blue circle and the red circle?		Could you stack the shapes in the order of the green square, the blue circle and the red circle?	0.95	t
40	session_voice_001	2025-05-15 16:58:31.886368	oscik559	Could you stack the shapes in the order of the green square, the blue circle and the red circle?		Could you stack the shapes in the order of the green square, the blue circle and the red circle?	0.95	t
41	session_voice_001	2025-05-16 11:06:17.145839	oscik559	Could you sort the slides in the order of the green and then the orange slide?		Could you sort the slides in the order of the green and then the orange slide?	0.95	t
42	session_voice_001	2025-05-16 11:09:26.459925	oscik559	could you stack the shapes in the order of the green  square the blue circle and the red circle		could you stack the shapes in the order of the green  square the blue circle and the red circle	0.95	t
43	session_voice_001	2025-05-16 11:13:32.014069	oscik559	Could you sort the slides in the order of the green slide and then the orange slide?		Could you sort the slides in the order of the green slide and then the orange slide?	0.95	t
44	session_voice_001	2025-05-16 11:21:35.645774	oscik559	Could you stack the shapes in the order of the green square, the blue circle and the red circle?		Could you stack the shapes in the order of the green square, the blue circle and the red circle?	0.95	t
45	session_voice_001	2025-05-16 11:25:37.790325	oscik559	Could you sort the slides in the order of the green and then the orange slide?		Could you sort the slides in the order of the green and then the orange slide?	0.95	t
46	session_voice_001	2025-05-16 13:14:40.725585	oscik559	Could you stack the shapes in the order of the green square, the blue circle and the red circle?		Could you stack the shapes in the order of the green square, the blue circle and the red circle?	0.95	t
47	session_voice_001	2025-05-27 14:07:19.716024	oscik559	Could you stack the shapes in the order of the green square, the blue circle and the red circle?		Could you stack the shapes in the order of the green square, the blue circle and the red circle?	0.95	t
48	session_voice_001	2025-05-27 14:15:08.418468	oscik559	Could you sort the slides in the order of the orange and then the green?		Could you sort the slides in the order of the orange and then the green?	0.95	t
49	session_voice_001	2025-05-27 14:23:50.741959	oscik559	Could you help me sort the slides in the order of the orange and then the green?		Could you help me sort the slides in the order of the orange and then the green?	0.95	t
50	session_voice_001	2025-05-27 14:30:26.981584	oscik559	Could you stack the shapes in the order of the green square, the blue circle and the red circle?		Could you stack the shapes in the order of the green square, the blue circle and the red circle?	0.95	t
51	session_voice_001	2025-05-27 14:46:29.226342	oscik559	could you sort the slides in the order of the orange and then the green		could you sort the slides in the order of the orange and then the green	0.95	t
52	session_voice_001	2025-05-27 14:57:36.964752	oscik559	Could you stack the shapes in the order of the green square, the blue circle and the red circle?		Could you stack the shapes in the order of the green square, the blue circle and the red circle?	0.95	t
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
1	Yumi	Robot	yumi100	yumi100@lab.liu.ai	{"likes": ["AI", "Robotics"]}	/images/yumi001.jpg	{"last_task": "Assistance", "successful_tasks": 100}	\N	\N	robot	2025-05-07 10:13:15.07466	2025-05-07 10:13:15.101938
6	Marie	Jonsson	marjo33	marie.s.jonsson@liu.se	{"likes": ["Robots", "Composites"]}	/images/marjo33.jpg	{"last_task": "Fix robot battery", "successful_tasks": 2}	\N	\N	team	2025-05-07 10:13:15.07466	2025-05-07 10:13:15.101938
4	Sanjay	Nambiar	sanna58	sanjay.nambiar@liu.se	{"likes": ["Programming", "Machine Learning"]}	/images/sanna58.jpg	{"last_task": "Slide object", "successful_tasks": 7}	\N	\N	admin	2025-05-07 10:13:15.07466	2025-05-07 10:13:15.101938
7	Aref	Aghaee	areag806	areag806@student.liu.se	{"likes": ["CATIA", "Turbine Blades"]}	/images/areag806.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-05-07 10:13:15.07466	2025-05-07 10:13:15.101938
8	Thomson	Kalliyath	thoka981	thoka981@student.liu.se	{"likes": ["Omniverse", "Aeronautics"]}	/images/thoka981.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-05-07 10:13:15.07466	2025-05-07 10:13:15.101938
9	Hamideh	Pourrasoul	hampo845	hampo845@student.liu.se	{"likes": ["CATIA", "Turbine Blades"]}	/images/hampo845.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-05-07 10:13:15.07466	2025-05-07 10:13:15.101938
10	John	Ashish	johas759	johas759@student.liu.se	{"likes": ["python", "aircraft wings"]}	/images/johas759.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-05-07 10:13:15.07466	2025-05-07 10:13:15.101938
11	Danial	Nikpey	danni741	danni741@student.liu.se	{"likes": ["vb.net", "aircraft wings"]}	/images/danni741.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\N	\N	guest	2025-05-07 10:13:15.07466	2025-05-07 10:13:15.101938
5	Mehdi	Tarkian	mehta77	mehdi.tarkian@liu.se	{"likes": ["Running", "Cats"]}	/images/mehta77.jpg	{"last_task": "Drop object", "successful_tasks": 2}	\N	\N	team	2025-05-07 10:13:15.07466	2025-05-07 10:13:15.101938
2	Oscar	Ikechukwu	oscik559	oscik559@student.liu.se	{"likes": ["AI", "Robotics"]}	/images/oscik559.jpg	{"last_task": "Pick object", "successful_tasks": 5}	\\x8004959b150000000000005d94288c156e756d70792e636f72652e6d756c74696172726179948c0c5f7265636f6e7374727563749493948c056e756d7079948c076e6461727261799493944b0085944301629487945294284b014b80859468048c0564747970659493948c02663894898887945294284b038c013c944e4e4e4affffffff4affffffff4b00749462894200040000000000805b4cc2bf0000000099f6be3f000000e0cfa0c53f00000000b7e595bf000000809cdf893f000000c0df76b9bf00000020a45fac3f000000e0ea53a3bf00000060a1f6c03f000000a00cd0aebf00000040a20dd13f000000c055636ebf000000a01bb5c6bf00000020084ac2bf00000000905e9a3f00000060afaec23f000000c056aec5bf00000080e5f0b7bf0000004092c9a9bf000000e0bf45c3bf000000a05d66ac3f000000a0512eae3f000000e095e0abbf00000000773aa63f00000080d964a8bf000000c0fafacfbf00000040388ebbbf000000803464c1bf000000601768bb3f000000e0e4f0bcbf000000e03cb8963f00000080d7ea98bf000000e0e010c1bf000000400dc1a0bf000000e0c276b4bf00000080bf48803f000000801bbb903f000000807548b6bf000000c0ad55ba3f000000c06f8db23f000000807b11afbf0000008020caafbf000000401442afbf00000000b071d23f00000080f650c43f000000a0d998aabf000000c0cb09903f00000000c95e713f000000a02432b03f000000406c92cebf000000402c4985bf00000000c940b83f000000404d38c03f0000008078deba3f000000a06b4d963f000000c044d8b9bf000000a0f5bda6bf00000000a8b2313f000000000677cbbf0000004014dca93f00000040efada13f00000080589ebdbf00000020951bbebf000000609367b0bf00000040eda3cb3f00000020a7fbbe3f00000080adacbdbf00000040949dc3bf000000407377c73f000000e0bcf3c0bf000000004ec4a8bf000000e08214b23f000000200b93b6bf0000004011b9abbf000000c045b9c9bf0000008016b3c33f00000020e1f9d33f000000207c41ba3f00000080ce69c5bf000000e02add8bbf000000c0b71bd0bf000000c02919a03f000000c074b9a4bf00000000d3f170bf0000008049a8a8bf0000004032ceab3f00000080f4d1bebf00000040004f9f3f000000a09b19b13f000000e04986b2bf00000020a9068ebf000000c02c3bcc3f00000020bf3699bf000000401412a13f000000e0f4ce853f0000006037a381bf000000c06705adbf000000000ecd4f3f000000c09e4da2bf00000020e86fabbf000000a00d89bc3f000000c028e5babf000000404e68a23f0000006002c5ab3f00000040994cc0bf000000002b31c53f000000c0c463a13f000000005091663f000000806200983f000000208a28993f0000006052a6c0bf000000a00f62a7bf0000008030c0c53f000000c08dfbc7bf00000000c417c93f000000e0457dc43f00000080669c803f000000609f17be3f0000000066ef983f0000002065cdbf3f00000020eaa3babf000000c00386babf00000080e5fca4bf000000a0542298bf000000c06282a03f00000000bf91913f000000005886a5bf0000000055548a3f94749462680368064b008594680887945294284b014b808594680d8c02663894898887945294284b0368114e4e4e4affffffff4affffffff4b00749462894200040000000000a0d357c6bf000000c09290bb3f000000408b0ec73f000000a01ab287bf000000408b50a43f000000009f49b6bf00000040da0db13f000000000047aebf000000e0c565bd3f00000080485badbf0000002083a3d03f000000802e6a86bf000000000e99c7bf000000c0dfa0c1bf000000c0e48ca33f000000802b30c13f000000005f75c3bf00000080c6d6b9bf000000000eb6b2bf000000e0822fbebf000000a00e78a63f000000a0d7b8aa3f000000a08a88b1bf000000404b5aa03f000000a0f320a6bf000000808b0ed0bf00000080acf9b5bf000000806388babf00000060c980be3f00000060bb4ebcbf00000000c55366bf00000000faeeb0bf00000040ff46c4bf00000000b0e9783f000000a0be61bbbf00000020bfd6a73f00000040650da13f00000080ced7babf0000002051e2b93f000000c0c9beb63f00000020c7c3b5bf0000008037a0b6bf00000040d184b0bf0000008066dad13f000000e0d251c63f000000005808b0bf000000005ffc88bf000000e0aaea8b3f00000080b362b43f00000020ca33d1bf000000c0be4586bf00000040eb04b63f000000e08cc5c23f000000200b42b73f000000805c66913f00000020223ebbbf000000c0830ea4bf000000001f1569bf0000004082b6cebf000000c03be9a83f000000403b9b993f000000a0e417bdbf000000c07225babf000000a0514aadbf000000206d6fc93f000000e0a951c13f000000a05f25bebf000000a09885bcbf000000a0ee89c83f000000a08663c0bf000000001fdd9cbf00000040b61ea33f000000c0a251b1bf00000000223bb4bf00000020d86fcdbf000000a0bf88c23f00000000c017d53f0000002074a5ba3f00000020df4ec6bf00000080de4a8bbf000000004f00d0bf0000008008a1863f000000a038c395bf000000c0b5c190bf00000040a556a8bf000000409d40ac3f000000e0aac5c1bf00000020582ea93f000000c06cf6b83f000000c0353bafbf000000c09dcb813f00000080dae7c93f00000040ab50a2bf000000e063818e3f00000000040285bf000000a0c7ea8d3f000000c0b87ca7bf00000040d3d9883f000000207d9ba0bf000000001b92a2bf000000c0bbfab93f000000605a73bebf000000a05325ad3f000000c08c3eab3f00000040d7b0c4bf000000a092e4c53f00000060e73bb53f000000c0b04992bf00000000cdb5a83f000000008ecc423f000000208042c0bf000000e0713b9ebf000000808a05c43f00000060b645c9bf000000002585ca3f00000040c56dc53f0000000098d9713f000000002622c03f000000204b4b803f000000c08b95bd3f000000e00ed0b5bf00000080980bb8bf00000020be01a4bf000000a06ceca3bf0000000070885f3f000000a023ee953f000000001de6a2bf00000040d540a93f94749462680368064b008594680887945294284b014b808594680d8c02663894898887945294284b0368114e4e4e4affffffff4affffffff4b00749462894200040000000000a05238c5bf000000a06285c03f00000080b579c53f000000e0f6d394bf0000004093ea8d3f00000000931fbcbf000000c056a5b73f00000040f0b18fbf000000a0d204c03f000000202cd6aabf000000406787d23f000000c0565980bf000000c07599c6bf000000c07c8dbebf000000606094aa3f000000405375c33f000000402165c4bf000000a0c71bc1bf000000e04c20b8bf000000a0be72bfbf000000c0bfe5a33f000000008646a43f000000608454b7bf000000808209b43f000000c02fb7abbf000000402c03ccbf0000008074c5b4bf00000080dcf9bdbf000000a000a8b63f0000008066a6bcbf000000c0b093983f00000020b21979bf0000000057a0c0bf00000080158d9ebf00000060787ea9bf000000606eeb993f000000e09c4baa3f00000040768eb4bf00000060ea0fc63f000000a07ba9b03f000000a09faebdbf000000a03979b6bf00000080516399bf00000060369dd53f0000002093fcc23f000000c0c768b4bf00000080e274743f000000008ff3ab3f000000205d48b23f0000006087c2cebf000000000011293f00000040ef4cbb3f00000020ae2fc63f000000001e75b93f000000005c4d80bf00000000b22eb7bf000000c01f7498bf0000004073cd9c3f00000040b8c0ccbf000000205b2ba93f000000205e4cb43f00000060dadfc6bf000000400a8bbebf000000007d81b1bf00000060d78acb3f000000000376bd3f000000e05b71bebf000000c037edc4bf000000c0c977c83f0000004083f9bfbf00000000002cb3bf000000805ddab43f000000206846bbbf000000c086dda4bf00000000e5a2ccbf000000806016c13f00000040ed24d53f00000000e8ceb53f000000a0469ac6bf0000002079a390bf00000000b6c6ccbf000000e0507f823f000000c03e71a5bf000000809124743f00000040facfabbf000000a0d47fae3f00000080c78ac0bf000000807acbab3f000000c06887c13f000000c0adf89bbf00000020d9c682bf00000060df8dc73f00000000891880bf000000c0ed5d9dbf000000a0ac9b703f000000c05fae8fbf00000040bf6d823f0000004043ee8bbf00000020a85ea8bf00000000c7246abf000000002600b43f00000000d17ebfbf00000080e8e2933f000000803bb4ad3f00000060e909c8bf000000604036c33f000000404bbea93f000000009cd134bf00000040e8b365bf000000802494a13f000000202d46c1bf00000080c6a5a0bf000000a03271c63f000000005dfbc6bf00000000594fc73f000000c048f7c43f000000202564a13f000000c098f6b13f000000c0af4a7b3f000000607bc1b83f000000602101b4bf00000040f12ebbbf00000000be59b2bf000000a046bcaabf000000803a45a93f0000000030ee493f000000a082678d3f00000080546ea23f94749462680368064b008594680887945294284b014b808594680d8c02663894898887945294284b0368114e4e4e4affffffff4affffffff4b007494628942000400000000000012bec0bf00000080f7c89c3f000000205f6fba3f00000040336991bf00000000653aa23f000000e06545c0bf00000060b0abb33f000000c0b850b2bf000000403c33c13f000000c06b2fa03f00000060c4dbce3f00000000213c73bf000000a0ca2dc6bf000000402265c9bf000000006f5cb03f0000006046f2b73f0000000050e4c5bf000000207bb4b3bf00000020140ab7bf00000040f37bc0bf000000006b57703f000000009606b33f000000205002a43f00000020cf1db33f0000006037f9b7bf000000603d49cdbf000000201e20bcbf000000002682cdbf00000080fb52bd3f00000000cc66b9bf00000000cfa565bf00000000fd84a93f00000080e751c5bf00000000bb67bebf00000040e0aa803f00000060b3a1a13f000000400a63aa3f000000c0b8bfadbf00000020b776c33f000000a0707f8f3f000000401ed3bcbf00000040dc5fbbbf000000e0fc8b8f3f000000e0b61fd03f0000002001ffc13f00000020d501b3bf000000807c66943f00000000b5d4a83f000000809c53be3f000000c002e2ccbf000000803ad4a13f000000e0f65fb03f000000c0b089c83f000000009798aa3f000000c03beeb73f000000e0dd13c5bf000000403614743f0000006093f7983f000000606412cabf00000060a1ceb23f00000040cae3863f00000040035eb2bf000000c0ebf7babf00000060385ba83f000000201bb1c13f000000000752bd3f000000a09b77acbf00000000f8becabf00000040e9e8c73f000000a014e0c2bf000000e0ca9e96bf000000a067e3c43f000000e032efbcbf000000c0c525b3bf0000006066bacfbf000000c09ab5ac3f000000e0f7eed43f00000000f83d9c3f000000a03c09cdbf0000008057df923f00000000f947cabf0000004091f3863f00000040d3ce6b3f000000e06df960bf000000c09904a8bf00000080393abe3f000000207fedc4bf000000803e1584bf00000000b69eb83f00000000c639b0bf0000008000b997bf00000020f175c83f000000009cbc52bf000000004a98a13f00000080cd33b53f000000c02b1a7bbf000000406dc594bf00000000193a86bf000000600f45b5bf000000c0b1a57abf000000005df8c03f000000e07912b3bf00000000deb280bf00000020614aad3f000000203072c3bf00000080b77ebd3f00000020a428aa3f00000080d54ea0bf000000c033149dbf000000804f8880bf00000040c6cab7bf00000000fcd1a4bf000000405201c53f00000000f918cdbf000000c090f4c73f000000e04142c33f00000040974fafbf00000020b76cb83f000000207894a7bf000000601e3fb03f000000c0f0e7adbf000000e0cad6adbf00000000b7edb0bf000000205f5dadbf000000601451a53f000000608fdba0bf00000080767bb7bf000000405b2a80bf94749462680368064b008594680887945294284b014b808594680d8c02663894898887945294284b0368114e4e4e4affffffff4affffffff4b007494628942000400000000008088ffc1bf0000008049c5b43f000000002b31c53f0000008042ee8fbf00000040730ea73f000000e03652c1bf000000807264bc3f000000404df5b5bf000000a02bacc03f0000006018bf97bf000000605f12d03f000000a0450e623f000000407160c5bf000000c0d2c7c9bf000000a0a095be3f00000060081fbe3f0000004068f9c2bf000000600305babf000000008ffeb0bf00000040f6fbbfbf000000a0290f9b3f000000604f7ca73f000000e0b32880bf000000a0ae0eae3f000000c06be9adbf00000080a77bd0bf000000608ddeb7bf00000080c4adc1bf000000e0586ead3f0000006038ceaabf0000004066f0ab3f000000e00028a03f000000e0ba28c3bf000000202f46adbf0000008039989dbf00000000c3b68d3f000000c0839a843f000000a0057cb0bf00000020f3a5bb3f000000008e0155bf00000000b4c8c1bf00000000d56cbbbf0000000050fb6e3f000000e0c5a0cf3f0000000016a4c23f000000a00c0bb3bf000000c0f3ae7b3f0000000079bea23f000000c074adb23f000000403319cdbf000000804539913f000000000cd4b03f00000040ad4ac23f000000004279ab3f00000060b4c4b63f000000c04ad8bfbf000000e0204a90bf00000080301d763f000000a06c6dc6bf00000020a99b9e3f00000080a3c29f3f000000c09d11babf000000006060b7bf000000a0bd8984bf00000000a5b0c13f00000060d7c5ba3f000000c0192db2bf00000040e7fbc4bf0000004089fcbf3f00000000f045c4bf00000000d3a2a7bf000000a0731dc03f000000c03cf4b7bf000000a0c85bb8bf00000080aa66cfbf00000080eec3b33f00000080eb75d33f00000000277bb43f000000a08f69cabf00000020c44295bf000000a024f5cabf000000c04911b13f000000803f57ab3f00000040104c64bf000000e08d4fa0bf000000808876b23f00000020c60ac4bf00000080cb5a9abf00000020dcf7b73f000000c0e0d8abbf0000002078baa3bf000000c04998ce3f0000008028cb66bf000000e0aff6843f000000c0b166923f000000a0e2a8aabf000000805e99943f00000020e4a5923f000000c06990b4bf000000809b1aa4bf00000060e5abb93f000000402bf7b1bf000000403f118c3f000000a08816ae3f000000602e3fc9bf000000e0aa52be3f000000401cdcb33f00000020014ba23f000000806000a43f0000004039aaa63f00000000b5fbbfbf0000008064cbb3bf000000a04018be3f000000400a0fcbbf000000e020d1c23f000000806278c63f00000080bf3ca8bf000000e000a0ba3f000000e002b38abf00000060d915b63f00000060262eb3bf000000c0e859bbbf00000000bb2da2bf000000a0d6aa56bf00000020ffa2ac3f00000020739f933f000000c0e975b1bf00000000e1255f3f94749462652e	\\x80049508090000000000005d945d9428470000000000000000470000000000000000473fc01ac180000000470000000000000000470000000000000000470000000000000000473fa5ca7ea0000000470000000000000000473fc2ec3e20000000470000000000000000473fc46a8100000000473fb7df6b00000000473fa8577f40000000470000000000000000470000000000000000470000000000000000473fc6db3ca0000000470000000000000000470000000000000000473fc6344160000000473faed5dbc0000000473f90b58700000000470000000000000000470000000000000000470000000000000000473fab5a5380000000470000000000000000473fa2c4be80000000470000000000000000470000000000000000473fc14f0920000000473f78a3a6a0000000470000000000000000470000000000000000470000000000000000473fa8a33300000000473fc0ae56e0000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473fb81f2c60000000470000000000000000470000000000000000470000000000000000473f8c155e00000000473f76e80de0000000473f9ddb9e60000000470000000000000000470000000000000000473fc48be500000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473fc725cc60000000473fab9fd740000000470000000000000000470000000000000000473f763df040000000473f812a3f80000000470000000000000000470000000000000000473fcb5258c0000000473fc6ad0540000000470000000000000000470000000000000000470000000000000000473f93ea0e40000000470000000000000000473fc2ef0be0000000470000000000000000470000000000000000470000000000000000473fc24af080000000470000000000000000473fc73164c0000000470000000000000000473fb2360c80000000473fa14e7ee0000000473fadae6d20000000470000000000000000470000000000000000470000000000000000473fb26a54c0000000470000000000000000473fb4ac5f20000000473fa509e040000000470000000000000000470000000000000000470000000000000000473f6687eac0000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473f5ed03dc0000000473fa0cacd20000000473f991ecde0000000473fa27afb20000000470000000000000000470000000000000000473f9cb4e080000000473fab4a9a20000000470000000000000000473fa153c040000000470000000000000000473fb848cca0000000473fa8da0300000000470000000000000000470000000000000000473f913441a0000000473f64857d40000000470000000000000000473fa00f64a0000000473f96760bc0000000473fc49f1c80000000470000000000000000473fb519a1a0000000473f9da67620000000473fc0a5e8a0000000473fc28e44c0000000473f96b5be20000000470000000000000000470000000000000000470000000000000000473f8daaf360000000473f7f2a7560000000473f9610e9c0000000470000000000000000470000000000000000470000000000000000473fb4401f40000000473fa48e1ea0000000470000000000000000470000000000000000473fbc8ea220000000470000000000000000473f84211040000000473fb52e1cc0000000473f9001ea00000000470000000000000000470000000000000000473f81060440000000473fb97805c0000000473fbaa669a0000000470000000000000000470000000000000000470000000000000000473fbc112ac0000000470000000000000000470000000000000000473fa3511520000000473fc23a9c80000000473fbfc48260000000470000000000000000473fada25980000000473fab528d60000000473f48715760000000473fbc8c6860000000473fa77db2a0000000473f94566ae0000000473fb99a6020000000473fc798b780000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473fc2e62620000000473f969d0240000000473fc2b26980000000473fa81ca800000000470000000000000000473fc3a79bc0000000473f974394a0000000470000000000000000473f90330f20000000473fa17bb120000000470000000000000000470000000000000000473faebee420000000470000000000000000470000000000000000473f73793220000000473fa7233ee0000000470000000000000000473f9d739e60000000470000000000000000473f817f74e0000000473f8932ca80000000473fa19d2a60000000473fc1eb4f20000000473f6271d640000000473f81fec000000000473f8283c100000000470000000000000000470000000000000000470000000000000000473fb8d93fe0000000470000000000000000473fa6c1c320000000473f70203ae0000000470000000000000000470000000000000000470000000000000000473fb8dfd9e0000000473fa0765440000000470000000000000000473f30a78c00000000470000000000000000473fb27574a0000000473facc576c0000000470000000000000000473f7b1675c0000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473fbbc1e7e0000000473f4c9e48e0000000470000000000000000470000000000000000473f8f495680000000470000000000000000470000000000000000470000000000000000470000000000000000473facfa5e00000000473fb42a5ba0000000473fb58bce80000000473fc0104160000000473fbe3f8fa0000000473fc2798100000000470000000000000000473f94494a40000000473fc1c6fb00000000470000000000000000473fb32927a0000000473fd1012680000000470000000000000000473fb6766da0000000470000000000000000470000000000000000473f9d245a20000000470000000000000000470000000000000000473f9b12136000000047000000000000000065612e	admin	2025-05-07 10:13:15.07466	2025-05-07 10:13:15.101938
3	Rahul	Chiramel	rahch515	rahch515@student.liu.se	{"likes": ["Aeroplanes", "Automation"]}	/images/rahch515.jpg	{"last_task": "Screw object", "successful_tasks": 10}	\\x8004958e040000000000005d948c156e756d70792e636f72652e6d756c74696172726179948c0c5f7265636f6e7374727563749493948c056e756d7079948c076e6461727261799493944b0085944301629487945294284b014b80859468048c0564747970659493948c02663894898887945294284b038c013c944e4e4e4affffffff4affffffff4b00749462894200040000000000c01258c0bf000000c0f7fdaf3f00000040085dbb3f00000040500faebf000000c0422ea7bf00000080a504b0bf000000c0d9f48a3f000000c0e61f91bf000000203ffeca3f00000000383cb4bf000000c02cf0cb3f00000040572d7e3f000000203762c9bf0000002055bfc2bf000000c0790b913f00000000eb10ad3f000000601c54b9bf00000040babbb4bf00000040d304afbf0000002013fdb6bf000000805be49a3f00000060d6949abf000000806854963f000000405367a83f000000c07c09b9bf000000403cb6d6bf000000c070c3b6bf00000080974cc7bf000000c01d85bc3f000000209b08bdbf00000040f22683bf000000c042577d3f00000000da5bbfbf000000c0dac6adbf000000e0e603b6bf000000a0fda7af3f000000c0b3e7843f000000807a6fb1bf000000e0cfc0c53f0000000063219abf000000805827c1bf0000000072f7c0bf000000a0d204a4bf00000000d68eca3f000000603d23c33f000000c04f6a8e3f000000a06fd1a13f00000020c87380bf000000c074d5bc3f0000008049c2c9bf000000401cfeb53f000000c0795cbc3f00000060cecfbc3f000000408170993f000000e075d7c33f00000040d242c0bf000000007972a13f000000400fa2b03f000000802a3dcebf000000e041ec993f00000000c97e74bf000000a0998d98bf00000080b5d7b8bf000000c0a2e1a7bf000000c079c0c83f0000002000c1c23f00000040a79ca9bf0000008098a4babf000000c01edec53f000000801e1ec9bf00000080a792933f000000803aebb53f000000007a76bcbf00000040ad39bebf0000004077facdbf000000a0cc82b33f000000c0ad72d63f000000404242cc3f00000060f2bdbdbf000000c09472923f00000080d23cc0bf00000060f352a5bf000000200598ab3f000000606cdd95bf000000c0c324c4bf000000a0ce7cad3f0000004045f1b6bf000000c0c593a53f000000c0c058ad3f000000404fb5953f000000c0d15b90bf000000409eedc13f000000005b219ebf00000020e716a43f000000c0f9cc883f0000004051b4b3bf000000805510b7bf0000006098c88a3f00000020b280afbf000000c040859abf000000209d38c43f000000201186b8bf00000000c6f1a93f00000060e4f3a83f00000020388fc8bf00000020962cb03f000000a0045d793f00000000b2d7a2bf00000040009ba63f000000c0c6569e3f000000c07d60c1bf000000c06205a8bf00000020cd93c83f00000060020ac8bf000000e0ceaac53f000000c0bbb8c13f0000006079a7833f0000004014ecc13f000000c03b6db03f00000080e308b23f00000080bd5ba7bf0000008003b7b3bf000000c01f50b6bf000000a0f7fe66bf000000c01971a93f00000040b5e2a8bf00000040e2b8b03f00000000cccb43bf94749462612e	\N	admin	2025-05-07 10:13:15.07466	2025-05-07 10:13:15.101938
23	Sanjay	Nambiar	sanna058	sanna058@student.liu.se	{}	C:\\Users\\oscik559\\Projects\\mini_project_repo\\mini_project\\assets\\face_capture\\sanna058.jpg	[]	\\x8004958e040000000000005d948c156e756d70792e636f72652e6d756c74696172726179948c0c5f7265636f6e7374727563749493948c056e756d7079948c076e6461727261799493944b0085944301629487945294284b014b80859468048c0564747970659493948c02663894898887945294284b038c013c944e4e4e4affffffff4affffffff4b00749462894200040000000000a0eb4269bf00000040af06bb3f000000c048fe89bf000000800605b0bf000000c0c06b73bf000000206a09abbf00000000a764abbf000000206ef5b0bf000000806a57bb3f00000060dbb3aebf000000a0e84aca3f000000202c3093bf00000000096fcdbf000000e0ecbfc3bf000000e02c3392bf0000008035cac13f000000e0e4cdc6bf000000e0b64ab5bf00000040813ba3bf000000c01052a3bf000000a0bbbe8bbf0000000074d5853f0000000000dbb63f000000200951b83f00000040e830a2bf000000c051f0d4bf000000a0492ea8bf00000000c447c0bf0000008098e2913f000000c076ffb1bf000000a08a51b0bf000000807f48b83f00000040fcbec1bf000000605973a7bf0000000051e6923f000000c0a08cb73f000000a0dbba97bf0000002049ce94bf000000a009d2cb3f000000201a73a43f00000000929eb2bf000000e0a91eb3bf000000401faaa43f0000008071c1d23f00000020b21cce3f000000e083d0b43f000000c052348d3f00000000354ca03f0000006013b5c03f000000c08b08d2bf00000000f9a9ae3f000000e0c820b73f0000008069f4c13f000000803c038d3f000000805d9db83f000000c084a3c5bf00000000d4aa7e3f000000003685a63f000000a0095bbdbf00000000cd91993f000000e02ca69ebf00000080303ba7bf00000080e5b8a7bf000000005dfda8bf000000c0e2ecd13f000000a060e1ab3f0000006007dac1bf000000603cc3a0bf000000008c7cbb3f000000c06314c4bf000000a06ffaadbf0000008086af9c3f000000603049bdbf000000c0b550bcbf0000006063f2d2bf00000000bb07673f000000006c09d43f000000808e99c53f000000a0ed64c4bf00000000104b8f3f000000e0d456a8bf000000c0e7d798bf00000040a7f0b53f000000004a91a53f000000a0f91eb7bf000000a0c3cc85bf000000c09dedc1bf00000000341f8fbf000000e0af3cc13f00000040887aa9bf000000a02738b4bf000000601ff0c53f000000002236b1bf00000040b031c13f000000c064d08ebf00000000bc08a1bf000000a049c7a7bf00000060a533973f000000c00300c1bf000000c0b07f953f0000008037c3b13f00000000fe67b2bf0000002069f294bf00000080dbe5b93f000000602d84c4bf0000000060c48e3f000000e01a797bbf000000207a58903f00000000b189a73f000000a04a5eac3f000000602a24cabf00000060f19cb3bf000000e05b60c13f0000000087b3cdbf000000e05cebc33f000000e00b5ac83f0000004056338abf000000a0d5d3b73f000000a0a6eeb93f00000080539baa3f000000204d55753f000000803851a9bf00000020ba2dc3bf00000040261bb8bf000000e0875db43f00000000be58813f00000060072aac3f000000409ea07f3f94749462612e	\\x80049508090000000000005d945d9428473fb63637c0000000470000000000000000473f9c2df480000000470000000000000000473f5d37dce0000000473f702a1500000000473fc0258420000000470000000000000000473f53fc57e0000000470000000000000000473f9c27a4a0000000473f8e68c6c0000000473f8ed7e700000000473f6f529c20000000473f6cca04a0000000470000000000000000473fbf112400000000473f986d81e0000000470000000000000000473f85e23f40000000473f9fa85ca0000000473f8c2b5c60000000470000000000000000470000000000000000470000000000000000473fa2b578c0000000470000000000000000473fba2d9720000000470000000000000000470000000000000000470000000000000000473f7462a140000000470000000000000000473f9165dd80000000473faa37ed60000000473fb823e400000000473fb8fcf500000000470000000000000000473f605b9ca0000000473fbb5520c0000000470000000000000000473f698c1b00000000473fbbcd67e0000000473f8e4e1660000000473fb179ab00000000470000000000000000473f72bb0280000000473f7a96b620000000470000000000000000470000000000000000470000000000000000473fc45e2dc0000000470000000000000000470000000000000000473f6c99ae40000000470000000000000000473fb3626c80000000470000000000000000470000000000000000473fb555dc20000000473f4acc28e0000000470000000000000000473fc8c95080000000473fa17346e0000000473f9c8c71c0000000470000000000000000473fbc59a8c0000000473faf29c4e0000000470000000000000000470000000000000000470000000000000000473f9308bd60000000470000000000000000473f79326fc0000000473f91842a40000000470000000000000000470000000000000000473fc17e0ce0000000473fb0b70ea0000000473fa9485660000000470000000000000000470000000000000000473fcc4f0a40000000470000000000000000470000000000000000473f826718e0000000473f7860e000000000470000000000000000470000000000000000473fa69bb280000000473fbd3f2940000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473f684fb7c0000000470000000000000000470000000000000000470000000000000000470000000000000000470000000000000000473f683d97c0000000473fb53de020000000473f95ada280000000473f8ca83960000000473f66ace560000000473f9ab40560000000470000000000000000473fc2b0db80000000470000000000000000473fa6fb3140000000473f64c89920000000473fbb355d80000000473faa5afc20000000470000000000000000473fa04a42c0000000473f828fb7e0000000473f999eca00000000473f81516c60000000470000000000000000473fb726f420000000473fa421be40000000473f93c0b580000000473fc8695e60000000473fbbbec340000000473fb33b4aa0000000473fc1b70be0000000473f14904b40000000470000000000000000473fa4052f80000000470000000000000000473fcbec7220000000473fae6f02e0000000473f9e1d3e40000000473fb4c0eb20000000473fa079e080000000470000000000000000473fa157c040000000473f9fbdbfa0000000470000000000000000470000000000000000473fc21bbda0000000473fa3475560000000470000000000000000473f946b9e00000000473fb69f9300000000470000000000000000473fbe040900000000473fab8927e0000000473fc01568e0000000473fc4cea600000000470000000000000000473f90215200000000470000000000000000473fc04470a0000000470000000000000000470000000000000000473faae53800000000470000000000000000473fc078c300000000470000000000000000473f946b6be0000000470000000000000000473fb6c07540000000473fc4fd1120000000473fb0e96120000000473fad8e4340000000473f8af70220000000473fbfc8e340000000470000000000000000470000000000000000473fbf5a5c80000000473f43d0c520000000470000000000000000473fa3fdc280000000473fa81aa440000000473fa3b0ee80000000473f5199be80000000473f7530a040000000473fb8099f60000000473f9aa0f120000000470000000000000000473fb60d28c0000000473f8eed39a0000000470000000000000000470000000000000000473fc00cdcc0000000470000000000000000470000000000000000473fc20fc460000000473fb690c340000000470000000000000000473fcebbfb40000000470000000000000000470000000000000000473fa25ba7c0000000473fc6686ce0000000473fb18f29c0000000473f8cb063c0000000473fa12c5380000000473f90f4e160000000470000000000000000470000000000000000470000000000000000470000000000000000473f31466f80000000470000000000000000473f7cda4b40000000470000000000000000470000000000000000470000000000000000473f7298c9e0000000473f6d86d6e0000000470000000000000000473f6d93fc80000000470000000000000000473fb7ea4a40000000473f9d8437c0000000470000000000000000473f3d1d0a40000000473fa665d0e0000000473f56de6980000000470000000000000000470000000000000000470000000000000000473f9e92e6c0000000473f66046a60000000470000000000000000470000000000000000473f8f205e20000000470000000000000000473fa76109e0000000470000000000000000470000000000000000473fb3377660000000473fc48066a0000000473fb945f240000000473fb9aae3e0000000473fb35acc80000000473fbeb3cca0000000473f7b1dabe0000000473f90abcf60000000473fca0191a0000000470000000000000000473f9e8edfe0000000473f9b952040000000470000000000000000473fc123b360000000473fbbfe1b80000000470000000000000000473f9712ce20000000470000000000000000470000000000000000473f9b33a8c000000047000000000000000065612e	guest	2025-05-16 11:43:05.827043	2025-05-16 11:43:05.827043
\.


--
-- Data for Name: voice_instructions; Type: TABLE DATA; Schema: public; Owner: oscar
--

COPY public.voice_instructions (id, session_id, transcribed_text, confidence, language, processed, "timestamp") FROM stdin;
1	fc092684-e745-4a25-8e25-17f89639d8e1	Can you stack the shapes in the order of the red circle, the green square and the blue circle?	\N	english	f	2025-05-14 13:35:17.13275
2	fc092684-e745-4a25-8e25-17f89639d8e1	Could you sort the slides in the order of the green slide and then the orange slide?	\N	english	f	2025-05-14 14:58:07.41292
3	fc092684-e745-4a25-8e25-17f89639d8e1	Could you stack the shapes in the order of the green square, the blue circle and the red circle?	\N	english	f	2025-05-14 15:45:35.930294
4	3288c013-ddaa-4831-9520-577c8d212442	Can you stack the shapes in the order of the green square, the blue circle and the red circle?	\N	yoruba	f	2025-05-15 13:21:49.794747
5	3288c013-ddaa-4831-9520-577c8d212442	Could you sort the shapes in the order of the red rectangle, the blue circle and the red circle?	\N	english	f	2025-05-15 15:00:07.206563
6	3288c013-ddaa-4831-9520-577c8d212442	Could you sort the shapes in the order of the blue circle and then the red circle?	\N	yoruba	f	2025-05-15 15:06:47.607097
7	3288c013-ddaa-4831-9520-577c8d212442	Could you sort the shapes in the order of the blue circle and the red circle?	\N	english	f	2025-05-15 15:08:18.712051
8	3288c013-ddaa-4831-9520-577c8d212442	Could you stack the shapes in the order of the green square, the blue circle and the red circle?	\N	english	f	2025-05-15 15:17:19.527172
9	3288c013-ddaa-4831-9520-577c8d212442	Could you stack the shapes in the order of the green square, the blue circle and the red circle?	\N	english	f	2025-05-15 15:18:11.457744
10	3288c013-ddaa-4831-9520-577c8d212442	Could you sort the slides in the order of the orange and then the green?	\N	english	f	2025-05-15 15:28:28.756933
11	3288c013-ddaa-4831-9520-577c8d212442	Could you sort the slides in the order of the green and then the orange?	\N	malay	f	2025-05-15 15:43:40.822202
12	3288c013-ddaa-4831-9520-577c8d212442	Could you stack the shapes in the order of the green square, the blue circle and the red circle?	\N	english	f	2025-05-15 16:56:39.74181
13	3288c013-ddaa-4831-9520-577c8d212442	Could you stack the shapes in the order of the green square, the blue circle and the red circle?	\N	english	f	2025-05-15 16:58:31.703977
14	dbcd1856-a5f8-41e3-a4bb-8a7cde20338c	Could you sort the slides in the order of the green and then the orange slide?	\N	english	f	2025-05-16 11:06:17.074667
15	dbcd1856-a5f8-41e3-a4bb-8a7cde20338c	could you stack the shapes in the order of the green  square the blue circle and the red circle	\N	english	f	2025-05-16 11:09:26.392169
16	dbcd1856-a5f8-41e3-a4bb-8a7cde20338c	Could you sort the slides in the order of the green slide and then the orange slide?	\N	english	f	2025-05-16 11:13:31.946576
17	dbcd1856-a5f8-41e3-a4bb-8a7cde20338c	Could you stack the shapes in the order of the green square, the blue circle and the red circle?	\N	english	f	2025-05-16 11:21:35.572477
18	dbcd1856-a5f8-41e3-a4bb-8a7cde20338c	Could you sort the slides in the order of the green and then the orange slide?	\N	english	f	2025-05-16 11:25:37.723146
19	b2ef7799-8b91-403d-93b6-a4145499e69f	Could you stack the shapes in the order of the green square, the blue circle and the red circle?	\N	english	f	2025-05-16 13:14:40.601892
20	458f4c11-660a-4add-afd9-5bfa03e121b0	Could you stack the shapes in the order of the green square, the blue circle and the red circle?	\N	english	f	2025-05-27 14:07:19.652598
21	458f4c11-660a-4add-afd9-5bfa03e121b0	Could you sort the slides in the order of the orange and then the green?	\N	english	f	2025-05-27 14:15:08.357873
22	458f4c11-660a-4add-afd9-5bfa03e121b0	Could you help me sort the slides in the order of the orange and then the green?	\N	english	f	2025-05-27 14:23:50.675237
23	458f4c11-660a-4add-afd9-5bfa03e121b0	Could you stack the shapes in the order of the green square, the blue circle and the red circle?	\N	english	f	2025-05-27 14:30:26.81246
24	458f4c11-660a-4add-afd9-5bfa03e121b0	could you sort the slides in the order of the orange and then the green	\N	english	f	2025-05-27 14:46:29.16423
25	458f4c11-660a-4add-afd9-5bfa03e121b0	Could you stack the shapes in the order of the green square, the blue circle and the red circle?	\N	english	f	2025-05-27 14:57:36.784329
\.


--
-- Name: camera_vision_object_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.camera_vision_object_id_seq', 26303, true);


--
-- Name: drop_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.drop_op_parameters_sequence_id_seq', 40, true);


--
-- Name: gesture_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.gesture_instructions_id_seq', 559, true);


--
-- Name: gesture_library_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.gesture_library_id_seq', 6, true);


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

SELECT pg_catalog.setval('public.operation_sequence_id_seq', 299, true);


--
-- Name: pick_op_parameters_sequence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.pick_op_parameters_sequence_id_seq', 87, true);


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

SELECT pg_catalog.setval('public.sort_order_order_id_seq', 89, true);


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

SELECT pg_catalog.setval('public.travel_op_parameters_sequence_id_seq', 87, true);


--
-- Name: unified_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.unified_instructions_id_seq', 52, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.users_user_id_seq', 26, true);


--
-- Name: voice_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: oscar
--

SELECT pg_catalog.setval('public.voice_instructions_id_seq', 25, true);


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

